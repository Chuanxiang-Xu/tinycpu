// Simple AXI-Lite RAM with optional hex initialization.
module axil_ram #(
    parameter integer ADDR_WIDTH = 16,
    parameter integer INIT_WORDS = 4,
    parameter         MEM_HEX    = "programs/led_switch_demo.hex"
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
    input  logic        s_axi_rready
);

    localparam integer WORDS = (1 << ADDR_WIDTH) / 4;

    logic [31:0] mem [0:WORDS-1];
    logic [31:0] awaddr_q;
    logic [31:0] wdata_q;
    logic [3:0]  wstrb_q;
    logic        aw_seen;
    logic        w_seen;

    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1) begin
            mem[i] = 32'h0000_0013;
        end
        if (MEM_HEX != "") begin
            $readmemh(MEM_HEX, mem, 0, INIT_WORDS - 1);
        end
    end

    assign s_axi_awready = !aw_seen && !s_axi_bvalid;
    assign s_axi_wready  = !w_seen && !s_axi_bvalid;
    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_rresp   = 2'b00;

    always_ff @(posedge clk) begin
        if (rst) begin
            s_axi_bvalid <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 32'h0000_0000;
            aw_seen      <= 1'b0;
            w_seen       <= 1'b0;
            awaddr_q     <= 32'h0000_0000;
            wdata_q      <= 32'h0000_0000;
            wstrb_q      <= 4'b0000;
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rdata  <= mem[s_axi_araddr[ADDR_WIDTH-1:2]];
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
                if (wstrb_q[0]) mem[awaddr_q[ADDR_WIDTH-1:2]][7:0]   <= wdata_q[7:0];
                if (wstrb_q[1]) mem[awaddr_q[ADDR_WIDTH-1:2]][15:8]  <= wdata_q[15:8];
                if (wstrb_q[2]) mem[awaddr_q[ADDR_WIDTH-1:2]][23:16] <= wdata_q[23:16];
                if (wstrb_q[3]) mem[awaddr_q[ADDR_WIDTH-1:2]][31:24] <= wdata_q[31:24];
                s_axi_bvalid <= 1'b1;
                aw_seen      <= 1'b0;
                w_seen       <= 1'b0;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

endmodule
