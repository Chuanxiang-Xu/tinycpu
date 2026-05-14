// Instruction fetch stage bookkeeping.
module tinycpu_if_stage #(
    parameter logic [31:0] RESET_PC = 32'h0000_0000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        advance,
    input  logic        redirect_valid,
    input  logic [31:0] redirect_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= RESET_PC;
        end else if (redirect_valid) begin
            pc <= redirect_pc;
        end else if (advance) begin
            pc <= pc + 32'd4;
        end
    end

endmodule
