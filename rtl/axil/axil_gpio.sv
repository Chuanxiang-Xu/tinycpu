// AXI-Lite GPIO peripheral.
//
// Register map:
//   0x4000_0000: LED output register
//   0x4000_0004: switch input register
//   0x4000_0010: future game input register
//   0x4000_0014: future game status register
//   0x4000_0100 - 0x4000_01FF: future 10x20 game grid/framebuffer window
module axil_gpio #(
    parameter logic [31:0] GPIO_BASE = 32'h4000_0000
) (
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] s_axi_awaddr,
    input  logic        s_axi_awvalid,
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    input  logic [1:0]  sw,
    output logic [3:0]  led
);

    localparam logic [31:0] LED_OFFSET = 32'h0000_0000;
    localparam logic [31:0] SW_OFFSET  = 32'h0000_0004;
    localparam logic [31:0] GAME_INPUT_OFFSET  = 32'h0000_0010;
    localparam logic [31:0] GAME_STATUS_OFFSET = 32'h0000_0014;
    localparam logic [31:0] FRAMEBUFFER_BASE   = 32'h0000_0100;
    localparam logic [31:0] FRAMEBUFFER_LAST   = 32'h0000_01FF;

    logic [31:0] led_reg;
    logic [31:0] game_input_reg;
    logic [31:0] game_status_reg;
    logic [31:0] framebuffer [0:63];
    logic [31:0] awaddr_q;
    logic [31:0] wdata_q;
    logic [3:0]  wstrb_q;
    logic        aw_seen;
    logic        w_seen;
    logic [31:0] read_offset;
    logic [31:0] write_offset;
    logic        read_framebuffer;
    logic        write_framebuffer;
    logic [5:0]  read_framebuffer_index;
    logic [5:0]  write_framebuffer_index;

    integer i;

    assign led = led_reg[3:0];

    assign s_axi_awready = !aw_seen && !s_axi_bvalid;
    assign s_axi_wready  = !w_seen && !s_axi_bvalid;
    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_rresp   = 2'b00;

    assign read_offset  = s_axi_araddr - GPIO_BASE;
    assign write_offset = awaddr_q - GPIO_BASE;
    assign read_framebuffer = (read_offset >= FRAMEBUFFER_BASE) && (read_offset <= FRAMEBUFFER_LAST);
    assign write_framebuffer = (write_offset >= FRAMEBUFFER_BASE) && (write_offset <= FRAMEBUFFER_LAST);
    assign read_framebuffer_index = read_offset[7:2];
    assign write_framebuffer_index = write_offset[7:2];

    always_ff @(posedge clk) begin
        if (rst) begin
            led_reg      <= 32'h0000_0000;
            game_input_reg  <= 32'h0000_0000;
            game_status_reg <= 32'h0000_0000;
            s_axi_bvalid <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'h0000_0000;
            awaddr_q     <= 32'h0000_0000;
            wdata_q      <= 32'h0000_0000;
            wstrb_q      <= 4'b0000;
            aw_seen      <= 1'b0;
            w_seen       <= 1'b0;
            for (i = 0; i < 64; i = i + 1) begin
                framebuffer[i] <= 32'h0000_0000;
            end
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                if (read_framebuffer) begin
                    s_axi_rdata <= framebuffer[read_framebuffer_index];
                end else begin
                    case (read_offset)
                        LED_OFFSET:         s_axi_rdata <= led_reg;
                        SW_OFFSET:          s_axi_rdata <= {30'b0, sw};
                        GAME_INPUT_OFFSET:  s_axi_rdata <= game_input_reg;
                        GAME_STATUS_OFFSET: s_axi_rdata <= game_status_reg;
                        default:            s_axi_rdata <= 32'h0000_0000;
                    endcase
                end
                s_axi_rvalid <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end

            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_q <= s_axi_awaddr;
                aw_seen  <= 1'b1;
            end

            if (s_axi_wvalid && s_axi_wready) begin
                wdata_q <= s_axi_wdata;
                wstrb_q <= s_axi_wstrb;
                w_seen  <= 1'b1;
            end

            if (aw_seen && w_seen && !s_axi_bvalid) begin
                if (write_offset == LED_OFFSET) begin
                    if (wstrb_q[0]) led_reg[7:0]   <= wdata_q[7:0];
                    if (wstrb_q[1]) led_reg[15:8]  <= wdata_q[15:8];
                    if (wstrb_q[2]) led_reg[23:16] <= wdata_q[23:16];
                    if (wstrb_q[3]) led_reg[31:24] <= wdata_q[31:24];
                end else if (write_offset == GAME_INPUT_OFFSET) begin
                    if (wstrb_q[0]) game_input_reg[7:0]   <= wdata_q[7:0];
                    if (wstrb_q[1]) game_input_reg[15:8]  <= wdata_q[15:8];
                    if (wstrb_q[2]) game_input_reg[23:16] <= wdata_q[23:16];
                    if (wstrb_q[3]) game_input_reg[31:24] <= wdata_q[31:24];
                end else if (write_offset == GAME_STATUS_OFFSET) begin
                    if (wstrb_q[0]) game_status_reg[7:0]   <= wdata_q[7:0];
                    if (wstrb_q[1]) game_status_reg[15:8]  <= wdata_q[15:8];
                    if (wstrb_q[2]) game_status_reg[23:16] <= wdata_q[23:16];
                    if (wstrb_q[3]) game_status_reg[31:24] <= wdata_q[31:24];
                end else if (write_framebuffer) begin
                    if (wstrb_q[0]) framebuffer[write_framebuffer_index][7:0]   <= wdata_q[7:0];
                    if (wstrb_q[1]) framebuffer[write_framebuffer_index][15:8]  <= wdata_q[15:8];
                    if (wstrb_q[2]) framebuffer[write_framebuffer_index][23:16] <= wdata_q[23:16];
                    if (wstrb_q[3]) framebuffer[write_framebuffer_index][31:24] <= wdata_q[31:24];
                end
                s_axi_bvalid <= 1'b1;
                aw_seen      <= 1'b0;
                w_seen       <= 1'b0;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

endmodule
