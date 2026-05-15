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

## v0.4-fuller-rv32i-c-support

- Fuller RV32I instruction coverage for simple freestanding C.
- Bare-metal firmware flow under `programs/c_demo/` with `startup.S`,
  `linker.ld`, `main.c`,
  `firmware.elf`, `firmware.bin`, and `firmware.hex`.
- GCC flags: `-march=rv32i`, `-mabi=ilp32`, `-ffreestanding`,
  `-nostdlib`, and `-nostartfiles`.
- cocotb entry point for running the GCC-built C GPIO demo.
- Byte and halfword load/store support with little-endian lane handling.
- Branch and jump redirect behavior remains resolved in the execute stage.

## v0.5

- Implement RV32M multiply/divide instructions.
- Replace global bus serialization with clearer valid/bubble pipeline registers.
- Add explicit forwarding and load-use stall coverage for the overlapped
  pipeline implementation.
- Add trap/debug reporting for illegal instructions and bus errors.

## Later

- Add Jupyter/Python MMIO bridge flow.
- Add framebuffer or grid memory.
- Build a small game demo such as Tetris.
