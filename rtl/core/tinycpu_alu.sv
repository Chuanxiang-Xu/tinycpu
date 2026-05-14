// Small combinational ALU for the teaching core.
module tinycpu_alu (
    input  logic [3:0]  op,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y,
    output logic        zero
);

    localparam logic [3:0] ALU_ADD = 4'd0;
    localparam logic [3:0] ALU_SUB = 4'd1;
    localparam logic [3:0] ALU_AND = 4'd2;
    localparam logic [3:0] ALU_OR  = 4'd3;
    localparam logic [3:0] ALU_XOR = 4'd4;

    always @* begin
        case (op)
            ALU_ADD: y = a + b;
            ALU_SUB: y = a - b;
            ALU_AND: y = a & b;
            ALU_OR:  y = a | b;
            ALU_XOR: y = a ^ b;
            default: y = 32'h0000_0000;
        endcase
    end

    assign zero = (y == 32'h0000_0000);

endmodule
