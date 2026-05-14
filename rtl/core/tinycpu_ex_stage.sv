// Execute stage helper for ALU and branch comparisons.
module tinycpu_ex_stage (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic        eq
);

    tinycpu_alu alu_i (
        .op  (alu_op),
        .a   (a),
        .b   (b),
        .y   (result),
        .zero()
    );

    assign eq = (a == b);

endmodule
