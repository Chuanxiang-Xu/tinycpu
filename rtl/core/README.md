# tinycpu RV32IM-target Core

`tinycpu_core_pipe` is the current v0.6 clean-room educational CPU core
targeting standard RISC-V RV32IM with simple Harvard-style instruction/data
memory ports.

The earlier `v0.5-rv32im-m-extension` milestone added RV32M multiply/divide
instructions: `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, and
`REMU`. The current v0.6 milestone carries that ISA support into the pipelined
core.

The current v0.6 implementation is an overlapped pipeline using IF/ID, ID/EX,
EX/MEM, and MEM/WB registers. The SoC maps instruction and data ports to a
unified BRAM and dmem-side MMIO decoder.

The M-extension unit uses a `start`/`busy`/`done` handshake and stalls the
current instruction until the multiply/divide result is ready for writeback.
Selected rv32ui-style and rv32um-style ISA tests run in cocotb through the
`tests/riscv/` environment, including byte/halfword loads and M-result pipeline
dependency stress coverage. This is simulation coverage, not a full compliance
claim.
