// 32 x 32-bit integer register file.
//
// Register x0 is hard-wired to zero. Reads are combinational and writes happen
// on the rising clock edge, which keeps the multi-cycle core easy to inspect.
module tinycpu_regfile (
    input  logic        clk,
    input  logic        rst,

    input  logic [4:0]  rs1_addr,
    output logic [31:0] rs1_rdata,
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs2_rdata,

    input  logic        rd_we,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_wdata
);

    logic [31:0] regs [0:31];
    integer i;

    assign rs1_rdata = (rs1_addr == 5'd0) ? 32'h0000_0000 : regs[rs1_addr];
    assign rs2_rdata = (rs2_addr == 5'd0) ? 32'h0000_0000 : regs[rs2_addr];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'h0000_0000;
            end
        end else if (rd_we && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_wdata;
        end
    end

endmodule
