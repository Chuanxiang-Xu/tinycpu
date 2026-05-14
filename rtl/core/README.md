# tinycpu RV32IM-target core

`tinycpu_core_rv32im_axil` is a clean-room educational CPU core targeting
standard RISC-V RV32IM.

v0.3-open-rv32im implements the bring-up subset:

- `LUI`
- `AUIPC`
- `ADDI`
- `ADD`
- `SUB`
- `LW`
- `SW`
- `BEQ`
- `BNE`
- `JAL`
- `JALR`

The core is organized around IF, ID, EX, MEM, and WB stage helper modules. The
current implementation uses a single AXI-Lite master, so instruction fetch and
load/store access are globally stalled around bus transactions. The hazard and
mul/div modules are intentionally present now so the design can grow into fuller
RV32IM support without changing the project shape.
