# tinycpu RV32IM-target core

`tinycpu_core_rv32im_axil` is a clean-room educational CPU core targeting
standard RISC-V RV32IM.

v0.4-fuller-rv32i-c-support implements fuller RV32I for simple freestanding C:
standard U-type, jump, branch, load, store, immediate ALU, and register ALU
instructions. RV32M remains the target ISA roadmap for v0.5.

The core is organized around IF, ID, EX, MEM, and WB stage helper modules. The
current implementation uses a single AXI-Lite master, so instruction fetch and
load/store access are serialized around bus transactions. The hazard and
mul/div modules are intentionally present now so the design can grow into an
overlapped RV32IM pipeline without changing the project shape.
