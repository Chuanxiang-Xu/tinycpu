# Roadmap

## v0.3-open-rv32im

- RV32IM target documented
- Standard RV32I bring-up subset
- Five-stage pipeline structure files
- AXI-Lite RAM
- AXI-Lite GPIO
- AXI-Lite interconnect
- PYNQ-Z2 bitstream flow
- cocotb simulation

## v0.4

- Complete RV32I instruction coverage.
- Replace global bus serialization with clearer valid/bubble pipeline registers.
- Add forwarding from MEM/WB to EX.
- Add load-use stall tests.
- Add branch flush tests.

## v0.5

- Implement RV32M multiply/divide instructions.
- Add assembler or ELF-to-hex flow.
- Add trap/debug reporting for illegal instructions and bus errors.

## Later

- Add Jupyter/Python MMIO bridge flow.
- Add framebuffer or grid memory.
- Build a small game demo such as Tetris.
