// Data-memory side decoder for the pipelined tinycpu SoC.
//
// CPU RAM accesses are sent to unified BRAM port B. GPIO/switch/status and the
// future game framebuffer window are handled as simple single-cycle MMIO.
module tinycpu_dmem_decoder #(
    parameter logic [31:0] RAM_BASE  = 32'h0000_0000,
    parameter logic [31:0] GPIO_BASE = 32'h1000_0000
) (
    input  logic        clk,
    input  logic        rst,

    input  logic        dmem_valid,
    input  logic        dmem_we,
    input  logic [3:0]  dmem_wstrb,
    input  logic [31:0] dmem_addr,
    input  logic [31:0] dmem_wdata,
    output logic        dmem_ready,
    output logic [31:0] dmem_rdata,

    output logic        bram_en,
    output logic [15:0] bram_addr,
    output logic [31:0] bram_wdata,
    output logic [3:0]  bram_wstrb,
    input  logic [31:0] bram_rdata,

    input  logic [1:0]  sw,
    input  logic [31:0] host_input_i,
    output logic [3:0]  led,
    output logic [31:0] test_status_o,
    output logic [31:0] test_code_o,
    output logic [31:0] app_status_o,
    output logic [31:0] app_value0_o,
    output logic [31:0] app_value1_o,
    output logic [31:0] frame_counter_o,
    input  logic [7:0]  fb_mirror_index_i,
    output logic [31:0] fb_mirror_rdata_o
);

    localparam logic [31:0] LED_OFFSET         = 32'h0000_0000;
    localparam logic [31:0] SW_OFFSET          = 32'h0000_0004;
    localparam logic [31:0] HOST_INPUT_OFFSET  = 32'h0000_0010;
    localparam logic [31:0] APP_STATUS_OFFSET  = 32'h0000_0014;
    localparam logic [31:0] APP_VALUE0_OFFSET  = 32'h0000_0018;
    localparam logic [31:0] APP_VALUE1_OFFSET  = 32'h0000_001C;
    localparam logic [31:0] FRAME_COUNTER_OFFSET = 32'h0000_0020;
    localparam logic [31:0] COMMAND_ACK_OFFSET = 32'h0000_0024;
    localparam logic [31:0] FRAMEBUFFER_BASE   = 32'h0000_0100;
    localparam logic [31:0] FRAMEBUFFER_LAST   = 32'h0000_01FF;
    localparam logic [31:0] TEST_STATUS_OFFSET = 32'h0000_0FF0;
    localparam logic [31:0] TEST_CODE_OFFSET   = 32'h0000_0FF4;

    logic        req_is_ram_q;
    logic        req_is_mmio_q;
    logic        req_pending_q;
    logic [31:0] req_offset_q;
    logic [31:0] led_reg;
    logic [31:0] app_status_reg;
    logic [31:0] app_value0_reg;
    logic [31:0] app_value1_reg;
    logic [31:0] frame_counter_reg;
    logic [31:0] command_ack_reg;
    logic [31:0] test_status_reg;
    logic [31:0] test_code_reg;
    logic [31:0] framebuffer [0:63];

    logic is_ram;
    logic is_mmio;
    logic [31:0] mmio_offset;
    logic write_framebuffer;
    logic read_framebuffer_q;

    integer i;
    integer lane;

    assign is_ram = (dmem_addr >= RAM_BASE) && (dmem_addr < (RAM_BASE + 32'h0001_0000));
    assign is_mmio = ((dmem_addr & 32'hFFFF_F000) == GPIO_BASE);
    assign mmio_offset = dmem_addr - GPIO_BASE;
    assign write_framebuffer = (mmio_offset >= FRAMEBUFFER_BASE) &&
                               (mmio_offset <= FRAMEBUFFER_LAST);
    assign read_framebuffer_q = (req_offset_q >= FRAMEBUFFER_BASE) &&
                                (req_offset_q <= FRAMEBUFFER_LAST);

    assign bram_en    = dmem_valid && is_ram;
    assign bram_addr  = dmem_addr[15:0];
    assign bram_wdata = dmem_wdata;
    assign bram_wstrb = (dmem_valid && dmem_we && is_ram) ? dmem_wstrb : 4'b0000;

    assign led = led_reg[3:0];
    assign test_status_o = test_status_reg;
    assign test_code_o = test_code_reg;
    assign app_status_o = app_status_reg;
    assign app_value0_o = app_value0_reg;
    assign app_value1_o = app_value1_reg;
    assign frame_counter_o = frame_counter_reg;
    assign fb_mirror_rdata_o = (fb_mirror_index_i < 8'd64) ?
                               framebuffer[fb_mirror_index_i[5:0]] :
                               32'h0000_0000;

    always_ff @(posedge clk) begin
        if (rst) begin
            dmem_ready     <= 1'b0;
            dmem_rdata     <= 32'h0000_0000;
            req_is_ram_q   <= 1'b0;
            req_is_mmio_q  <= 1'b0;
            req_pending_q  <= 1'b0;
            req_offset_q   <= 32'h0000_0000;
            led_reg        <= 32'h0000_0000;
            app_status_reg <= 32'h0000_0000;
            app_value0_reg <= 32'h0000_0000;
            app_value1_reg <= 32'h0000_0000;
            frame_counter_reg <= 32'h0000_0000;
            command_ack_reg <= 32'h0000_0000;
            test_status_reg <= 32'h0000_0000;
            test_code_reg   <= 32'h0000_0000;
            for (i = 0; i < 64; i = i + 1) begin
                framebuffer[i] <= 32'h0000_0000;
            end
        end else begin
            dmem_ready    <= req_pending_q;
            req_is_ram_q  <= dmem_valid && is_ram;
            req_is_mmio_q <= dmem_valid && is_mmio;
            req_pending_q <= dmem_valid;
            req_offset_q  <= mmio_offset;

            if (dmem_valid && dmem_we && is_mmio) begin
                if (mmio_offset == LED_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            led_reg[lane * 8 +: 8] <= dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == APP_STATUS_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            app_status_reg[lane * 8 +: 8] <= dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == APP_VALUE0_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            app_value0_reg[lane * 8 +: 8] <= dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == APP_VALUE1_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            app_value1_reg[lane * 8 +: 8] <= dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == FRAME_COUNTER_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            frame_counter_reg[lane * 8 +: 8] <=
                                dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == COMMAND_ACK_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            command_ack_reg[lane * 8 +: 8] <=
                                dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == TEST_STATUS_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            test_status_reg[lane * 8 +: 8] <=
                                dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (mmio_offset == TEST_CODE_OFFSET) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            test_code_reg[lane * 8 +: 8] <= dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end else if (write_framebuffer) begin
                    for (lane = 0; lane < 4; lane = lane + 1) begin
                        if (dmem_wstrb[lane]) begin
                            framebuffer[mmio_offset[7:2]][lane * 8 +: 8] <=
                                dmem_wdata[lane * 8 +: 8];
                        end
                    end
                end
            end

            if (req_is_ram_q) begin
                dmem_rdata <= bram_rdata;
            end else if (req_is_mmio_q) begin
                case (req_offset_q)
                    LED_OFFSET:         dmem_rdata <= led_reg;
                    SW_OFFSET:          dmem_rdata <= {30'b0, sw};
                    HOST_INPUT_OFFSET:  dmem_rdata <= host_input_i | {30'b0, sw};
                    APP_STATUS_OFFSET:  dmem_rdata <= app_status_reg;
                    APP_VALUE0_OFFSET:  dmem_rdata <= app_value0_reg;
                    APP_VALUE1_OFFSET:  dmem_rdata <= app_value1_reg;
                    FRAME_COUNTER_OFFSET: dmem_rdata <= frame_counter_reg;
                    COMMAND_ACK_OFFSET: dmem_rdata <= command_ack_reg;
                    TEST_STATUS_OFFSET: dmem_rdata <= test_status_reg;
                    TEST_CODE_OFFSET:   dmem_rdata <= test_code_reg;
                    default: begin
                        if (read_framebuffer_q) begin
                            dmem_rdata <= framebuffer[req_offset_q[7:2]];
                        end else begin
                            dmem_rdata <= 32'h0000_0000;
                        end
                    end
                endcase
            end else begin
                dmem_rdata <= 32'h0000_0000;
            end
        end
    end

endmodule
