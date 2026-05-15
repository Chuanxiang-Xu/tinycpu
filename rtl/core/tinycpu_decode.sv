// RISC-V RV32I decode helper for the tinycpu teaching core.
//
// This module only decodes standard RISC-V instruction fields and immediates.
// Unsupported instructions are marked illegal so the core can trap/halt instead
// of silently executing the wrong behavior.
module tinycpu_decode (
    input  logic [31:0] instr,

    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,

    output logic [31:0] imm_i,
    output logic [31:0] imm_s,
    output logic [31:0] imm_b,
    output logic [31:0] imm_u,
    output logic [31:0] imm_j,

    output logic        is_lui,
    output logic        is_auipc,
    output logic        is_jal,
    output logic        is_jalr,
    output logic        is_branch,
    output logic        is_load,
    output logic        is_store,
    output logic        is_op_imm,
    output logic        is_op,
    output logic        illegal
);

    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_OP_IMM = 7'b0010011;
    localparam logic [6:0] OPCODE_OP     = 7'b0110011;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31:12], 12'b0};
    assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    assign is_lui    = (opcode == OPCODE_LUI);
    assign is_auipc  = (opcode == OPCODE_AUIPC);
    assign is_jal    = (opcode == OPCODE_JAL);
    assign is_jalr   = (opcode == OPCODE_JALR);
    assign is_branch = (opcode == OPCODE_BRANCH);
    assign is_load   = (opcode == OPCODE_LOAD);
    assign is_store  = (opcode == OPCODE_STORE);
    assign is_op_imm = (opcode == OPCODE_OP_IMM);
    assign is_op     = (opcode == OPCODE_OP);

    always @* begin
        illegal = 1'b0;

        case (opcode)
            OPCODE_LUI,
            OPCODE_AUIPC,
            OPCODE_JAL: begin
                illegal = 1'b0;
            end

            OPCODE_JALR: begin
                illegal = (funct3 != 3'b000);
            end

            OPCODE_BRANCH: begin
                illegal = !((funct3 == 3'b000) || (funct3 == 3'b001) ||
                            (funct3 == 3'b100) || (funct3 == 3'b101) ||
                            (funct3 == 3'b110) || (funct3 == 3'b111));
            end

            OPCODE_LOAD: begin
                illegal = !((funct3 == 3'b000) || (funct3 == 3'b001) ||
                            (funct3 == 3'b010) || (funct3 == 3'b100) ||
                            (funct3 == 3'b101));
            end

            OPCODE_STORE: begin
                illegal = !((funct3 == 3'b000) || (funct3 == 3'b001) ||
                            (funct3 == 3'b010));
            end

            OPCODE_OP_IMM: begin
                case (funct3)
                    3'b000, // ADDI
                    3'b010, // SLTI
                    3'b011, // SLTIU
                    3'b100, // XORI
                    3'b110, // ORI
                    3'b111: illegal = 1'b0; // ANDI
                    3'b001: illegal = (funct7 != 7'b0000000); // SLLI
                    3'b101: illegal = !((funct7 == 7'b0000000) || (funct7 == 7'b0100000)); // SRLI/SRAI
                    default: illegal = 1'b1;
                endcase
            end

            OPCODE_OP: begin
                case (funct3)
                    3'b000: illegal = !((funct7 == 7'b0000000) || (funct7 == 7'b0100000)); // ADD/SUB
                    3'b001, // SLL
                    3'b010, // SLT
                    3'b011, // SLTU
                    3'b100, // XOR
                    3'b110, // OR
                    3'b111: illegal = (funct7 != 7'b0000000); // AND
                    3'b101: illegal = !((funct7 == 7'b0000000) || (funct7 == 7'b0100000)); // SRL/SRA
                    default: illegal = 1'b1;
                endcase
            end

            default: begin
                illegal = 1'b1;
            end
        endcase
    end

endmodule
