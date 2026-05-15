// RV32M multiply/divide placeholder.
//
// The project targets RV32IM, but v0.4 implements fuller RV32I for C support
// first. M-extension instructions are decoded as unsupported by the core until
// this unit is wired into the execute stage in v0.5 or later.
module tinycpu_muldiv (
    input  logic        valid,
    input  logic [2:0]  funct3,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    output logic [31:0] result,
    output logic        ready
);

    always @* begin
        ready  = valid;
        result = 32'h0000_0000;

        case (funct3)
            3'b000: result = rs1 * rs2; // MUL preview path
            default: result = 32'h0000_0000;
        endcase
    end

endmodule
