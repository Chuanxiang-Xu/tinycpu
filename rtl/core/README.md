# tinycpu RV32IM-target Core

`tinycpu_core_rv32im_axil` is a clean-room educational CPU core targeting
standard RISC-V RV32IM.

`v0.5-rv32im-m-extension` implements RV32I for simple freestanding programs plus
the standard RV32M multiply/divide instructions: `MUL`, `MULH`, `MULHSU`,
`MULHU`, `DIV`, `DIVU`, `REM`, and `REMU`.

The core is organized around IF, ID, EX, MEM, and WB stage helper modules. The
current implementation uses a single AXI-Lite master, so instruction fetch and
load/store access are serialized around bus transactions. It is stage-structured
but not a fully overlapped five-stage pipeline.

The M-extension unit uses a `start`/`busy`/`done` handshake and stalls the
current instruction until the multiply/divide result is ready for writeback.
