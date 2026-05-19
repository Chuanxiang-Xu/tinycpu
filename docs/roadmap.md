# Roadmap

## v0.3-open-rv32im

- RV32IM target documented.
- Standard RV32I bring-up subset.
- Five-stage structure files.
- AXI-Lite RAM.
- AXI-Lite GPIO.
- AXI-Lite interconnect.
- PYNQ-Z2 bitstream flow.
- cocotb simulation.

## v0.4-fuller-rv32i-c-support

- Fuller RV32I instruction coverage for simple freestanding C.
- Basic bare-metal firmware flow under `programs/c_demo/` with `startup.S`,
  `linker.ld`, `main.c`, and generated firmware outputs.
- GCC flags: `-march=rv32i`, `-mabi=ilp32`, `-ffreestanding`, `-nostdlib`, and
  `-nostartfiles`.
- cocotb entry point for running the GCC-built C GPIO demo.
- Byte and halfword load/store support with little-endian lane handling.
- Branch and jump redirect behavior resolved in the execute stage.

## v0.5-rv32im-m-extension

- Current milestone.
- RV32M multiply/divide instructions: `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`,
  `DIVU`, `REM`, and `REMU`.
- Multi-cycle `tinycpu_muldiv` unit with `start`, `busy`, `done`, and `result`.
- Core stall/writeback path for M-extension results.
- `programs/rv32im_demo/` build flow defaults to
  `-march=rv32im -mabi=ilp32`.
- RV32IM C demo for grid math such as `row * 10 + col` and `% 7`.
- cocotb coverage for the mul/div unit and RV32IM grid math firmware.

## v0.6 Pipeline Cleanup Candidate

- Replace global bus serialization with clearer valid/bubble pipeline
  registers.
- Add explicit forwarding.
- Add load-use stall handling.
- Add branch flush handling.
- Add stronger ISA and hazard tests.

## Later

- Add trap/debug reporting for illegal instructions and bus errors.
- Add Jupyter/Python MMIO bridge flow.
- Add framebuffer or grid memory.
- Build a small game demo such as Tetris.
