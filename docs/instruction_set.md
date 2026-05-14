# Instruction Set

The target ISA is standard RISC-V `RV32IM`.

v0.3-open-rv32im implements this bring-up subset:

| Instruction | Status |
| --- | --- |
| `LUI` | Implemented |
| `AUIPC` | Implemented |
| `ADDI` | Implemented |
| `ADD` | Implemented |
| `SUB` | Implemented |
| `LW` | Implemented |
| `SW` | Implemented |
| `BEQ` | Implemented |
| `BNE` | Implemented |
| `JAL` | Implemented |
| `JALR` | Implemented |

Strict rules:

- Standard RISC-V opcodes only.
- 32-bit fixed-length instructions.
- Standard register numbering.
- `x0` is hardwired to zero.
- Memory is byte-addressed.
- Loads and stores are little-endian.
- Reset PC is `0x0000_0000`.
- Unsupported instructions trap/halt instead of executing custom behavior.

Planned RV32I coverage:

- Branches: `BLT`, `BGE`, `BLTU`, `BGEU`
- Loads: `LB`, `LH`, `LBU`, `LHU`
- Stores: `SB`, `SH`
- Immediate ops: `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`
- Shifts: `SLLI`, `SRLI`, `SRAI`
- Register ops: `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`

Planned RV32M coverage:

- `MUL`, `MULH`, `MULHSU`, `MULHU`
- `DIV`, `DIVU`, `REM`, `REMU`
