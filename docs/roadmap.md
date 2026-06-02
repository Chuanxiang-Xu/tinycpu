# Roadmap

## v0.3-open-rv32im

- RV32IM target documented.
- Standard RV32I bring-up subset.
- Five-stage structure files.
- Legacy AXI-Lite RAM path.
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

- RV32M multiply/divide instructions: `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`,
  `DIVU`, `REM`, and `REMU`.
- Multi-cycle `tinycpu_muldiv` unit with `start`, `busy`, `done`, and `result`.
- Core stall/writeback path for M-extension results.
- `programs/rv32im_demo/` build flow defaults to
  `-march=rv32im -mabi=ilp32`.
- RV32IM C demo for grid math such as `row * 10 + col` and `% 7`.
- cocotb coverage for the mul/div unit and RV32IM grid math firmware.

## v0.6-pipeline-bram-loader

- Current milestone.
- Replace global bus serialization with valid/bubble pipeline registers.
- Move the CPU core to Harvard-style simple imem/dmem ports.
- Add unified 64 KiB BRAM, dmem MMIO decoder, and AXI-Lite loader/control
  slave.
- Keep the pipeline readable for teaching: explicit stage registers,
  forwarding choices, load-use stalls, branch flushes, and RV32M stalls.
- Add focused cocotb coverage for BRAM behavior, loader control, pipeline
  overlap, forwarding, load-use stalls, and branch/jump flushing.
- Add selected clean-room rv32ui-style and rv32um-style ISA simulation tests
  without vendoring the external `riscv-tests` repository.

## Follow-Up Work

- Realign the older v0.5 directed/grid regression expectations with the v0.6
  pipeline core.
- Restore or document FPGA-oriented synchronous instruction BRAM timing if the
  implementation changes from the current simple imem model.

## Later

- Add trap/debug reporting for illegal instructions and bus errors.
- Add Jupyter/Python MMIO bridge flow.
- Add framebuffer or grid memory.
- Build a small game demo such as Tetris.
