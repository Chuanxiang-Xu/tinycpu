# Instruction Set

The target ISA is standard RISC-V `RV32IM`.

The earlier `v0.5-rv32im-m-extension` milestone added RV32M
multiply/divide support. The current `v0.6-pipeline-bram-loader` milestone
carries that RV32IM target into the pipelined core and verifies a selected
clean-room ISA subset in cocotb.

## Implemented Status

- RV32I is implemented.
- RV32M multiply/divide is implemented.
- The v0.6 simulation flow passes a selected rv32ui-style and rv32um-style
  clean-room test subset, including byte/halfword loads and M-result pipeline
  dependency stress coverage. This is not a full RISC-V compliance claim.
- 32-bit fixed-length instructions are supported.
- The compressed `C` extension is not supported.
- Privileged instructions, CSRs, interrupts, exceptions, atomics, and floating
  point are not supported.
- Unsupported instructions halt/trap instead of executing custom behavior.
- AXI-Lite response codes are not yet surfaced as architectural traps.
- Misaligned access traps are not implemented.

## Formats

| Format | Bits 31:25 | Bits 24:20 | Bits 19:15 | Bits 14:12 | Bits 11:7 | Bits 6:0 |
| --- | --- | --- | --- | --- | --- | --- |
| R-type | `funct7` | `rs2` | `rs1` | `funct3` | `rd` | `opcode` |
| I-type | `imm[11:0]` | `imm[4:0]` | `rs1` | `funct3` | `rd` | `opcode` |
| S-type | `imm[11:5]` | `rs2` | `rs1` | `funct3` | `imm[4:0]` | `opcode` |
| B-type | `imm[12,10:5]` | `rs2` | `rs1` | `funct3` | `imm[4:1,11]` | `opcode` |
| U-type | `imm[31:12]` | `imm[31:12]` | `imm[31:12]` | `imm[31:12]` | `rd` | `opcode` |
| J-type | `imm[20,10:1,11,19:12]` | `imm[20,10:1,11,19:12]` | `imm[20,10:1,11,19:12]` | `imm[20,10:1,11,19:12]` | `rd` | `opcode` |

## Opcode Groups

| Group | Opcode |
| --- | --- |
| `LUI` | `0110111` |
| `AUIPC` | `0010111` |
| `JAL` | `1101111` |
| `JALR` | `1100111` |
| Branch | `1100011` |
| Load | `0000011` |
| Store | `0100011` |
| OP-IMM | `0010011` |
| OP | `0110011` |

## Current Instruction Coverage

| Instruction | Status |
| --- | --- |
| `LUI` | Implemented |
| `AUIPC` | Implemented |
| `JAL` | Implemented |
| `JALR` | Implemented |
| `BEQ` | Implemented |
| `BNE` | Implemented |
| `BLT` | Implemented |
| `BGE` | Implemented |
| `BLTU` | Implemented |
| `BGEU` | Implemented |
| `LB` | Implemented |
| `LH` | Implemented |
| `LW` | Implemented |
| `LBU` | Implemented |
| `LHU` | Implemented |
| `SB` | Implemented |
| `SH` | Implemented |
| `SW` | Implemented |
| `ADDI` | Implemented |
| `SLTI` | Implemented |
| `SLTIU` | Implemented |
| `XORI` | Implemented |
| `ORI` | Implemented |
| `ANDI` | Implemented |
| `SLLI` | Implemented |
| `SRLI` | Implemented |
| `SRAI` | Implemented |
| `ADD` | Implemented |
| `SUB` | Implemented |
| `SLL` | Implemented |
| `SLT` | Implemented |
| `SLTU` | Implemented |
| `XOR` | Implemented |
| `SRL` | Implemented |
| `SRA` | Implemented |
| `OR` | Implemented |
| `AND` | Implemented |
| `MUL` | Implemented |
| `MULH` | Implemented |
| `MULHSU` | Implemented |
| `MULHU` | Implemented |
| `DIV` | Implemented |
| `DIVU` | Implemented |
| `REM` | Implemented |
| `REMU` | Implemented |

Strict rules:

- Standard RISC-V opcodes only.
- Standard register numbering.
- `x0` is hardwired to zero.
- Memory is byte-addressed.
- Loads and stores are little-endian.
- Reset PC is `0x0000_0000`.

RV32M instructions use OP opcode `0110011`, funct7 `0000001`, and funct3:

| funct3 | Instruction |
| --- | --- |
| `000` | `MUL` |
| `001` | `MULH` |
| `010` | `MULHSU` |
| `011` | `MULHU` |
| `100` | `DIV` |
| `101` | `DIVU` |
| `110` | `REM` |
| `111` | `REMU` |

## References

- UPenn RV32IM ISA Reference Sheet:
  `https://www.seas.upenn.edu/~cis2400/24fa/notes/riscv_ref.pdf`
- riscv-gnu-toolchain:
  `https://github.com/riscv-collab/riscv-gnu-toolchain`
