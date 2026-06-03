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

## v0.7-pynq-jupyter-loader

- Add PS-visible mirrors for CPU-written `TEST_STATUS` and `TEST_CODE`.
- Keep CPU-side MMIO and loader-side AXI-Lite offsets separate.
- Prepare a Python/Jupyter loader flow for loading BRAM, setting `BOOT_PC`,
  releasing reset/halt, and polling pass/fail status.

## v0.8-jupyter-framebuffer-demo

- Add CPU-side `GAME_STATUS`, `FRAME_COUNTER`, and 10x20 framebuffer writes.
- Add loader-side mirrors for game status, frame counter, and packed
  framebuffer readback.
- Add a bare-metal framebuffer C demo and Jupyter text-grid display helper.
- Keep this scoped to framebuffer display only; full Tetris game logic is
  future work.

## v0.9-jupyter-interactive-io-tetris-demo

- Current development milestone.
- Add generic `HOST_INPUT`, `APP_STATUS`, `APP_VALUE0`, `APP_VALUE1`, and
  `FRAME_COUNTER` app I/O naming.
- Add loader-side host input writes and app/framebuffer mirrors.
- Add a generic interactive I/O smoke demo.
- Add TinyTetris as the first application on top of the generic interface.
- Keep Jupyter input button-based; keyboard events are future work.

## Follow-Up Work

- Realign the older v0.5 directed/grid regression expectations with the current
  pipeline core.
- Restore or document FPGA-oriented synchronous instruction BRAM timing if the
  implementation changes from the current simple imem model.
- Run the current PYNQ/Jupyter AXI overlay and notebooks on a real PYNQ-Z2
  board.
- Add real board screenshot/GIF evidence only after successful hardware runs.
- Improve TinyTetris controls or rendering if the button-based notebook flow
  feels too coarse on hardware.

## Later

- Add trap/debug reporting for illegal instructions and bus errors.
- Add optional keyboard event support for notebook demos.
- Add optional richer Jupyter rendering after the text-grid path is stable.
