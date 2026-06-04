# tinycpu RV32IM-target Core

`tinycpu_core_pipe` is the current clean-room educational CPU core targeting
standard RISC-V RV32IM with simple Harvard-style instruction/data memory ports.
For v1.0 it is treated as the stable pipeline-core release candidate.

The earlier `v0.5-rv32im-m-extension` milestone added RV32M multiply/divide
instructions: `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, and
`REMU`. The current pipelined core carries that ISA support forward.

The current implementation is an overlapped pipeline using IF/ID, ID/EX,
EX/MEM, and MEM/WB registers. The SoC maps instruction and data ports to a
unified BRAM and dmem-side MMIO decoder.

The M-extension unit uses a `start`/`busy`/`done` handshake and stalls the
current instruction until the multiply/divide result is ready for writeback.
Selected rv32ui-style and rv32um-style ISA tests run in cocotb through the
`tests/riscv/` environment, including byte/halfword loads and M-result pipeline
dependency stress coverage. This is simulation coverage, not a full compliance
claim.

The v1.0 core claim is intentionally narrow: selected RV32I/RV32M tests,
pipeline forwarding/load-use/branch-flush tests, C firmware smoke tests, and
AXI-Lite loader/control simulation pass through the SoC. CSRs, interrupts,
architectural exception/trap handling, misaligned access traps, caches, custom
instructions, and accelerators are outside this core release claim.
