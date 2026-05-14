// Decode/register-read stage helper.
module tinycpu_id_stage (
    input  logic [31:0] instr,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic        illegal
);

    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_u;
    logic [31:0] imm_j;
    logic        is_lui;
    logic        is_auipc;
    logic        is_jal;
    logic        is_jalr;
    logic        is_branch;
    logic        is_load;
    logic        is_store;
    logic        is_op_imm;
    logic        is_op;

    tinycpu_decode decode_i (
        .instr    (instr),
        .opcode   (opcode),
        .funct3   (funct3),
        .funct7   (funct7),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .imm_i    (imm_i),
        .imm_s    (imm_s),
        .imm_b    (imm_b),
        .imm_u    (imm_u),
        .imm_j    (imm_j),
        .is_lui   (is_lui),
        .is_auipc (is_auipc),
        .is_jal   (is_jal),
        .is_jalr  (is_jalr),
        .is_branch(is_branch),
        .is_load  (is_load),
        .is_store (is_store),
        .is_op_imm(is_op_imm),
        .is_op    (is_op),
        .illegal  (illegal)
    );

endmodule
