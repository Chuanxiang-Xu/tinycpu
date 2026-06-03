# Jupyter Tetris Plan Status

This document records the original Jupyter/TinyTetris direction and points to
the current implementation. The active user-facing TinyTetris instructions are
in `jupyter_tetris.md`, and the board-level overlay flow is in
`pynqz2_bringup.md`.

## Original Goal

- tinycpu runs RV32IM game logic in the PYNQ-Z2 PL.
- Jupyter/Python displays a game grid or framebuffer.
- Jupyter/Python writes control input through MMIO-like loader registers.
- tinycpu writes game state through CPU-side app/framebuffer MMIO.

## Current Status

The current `v0.9-jupyter-interactive-io-tetris-demo` milestone implements the
core pieces of that plan:

- `programs/tetris/` contains a small TinyTetris firmware demo.
- `programs/interactive_demo/` contains a generic host-input/app-output smoke
  demo.
- `notebooks/tinycpu_loader.py` wraps the loader/control AXI-Lite map.
- `notebooks/tetris_controller.py` wraps TinyTetris input bits.
- `notebooks/tetris_demo.ipynb` loads firmware, starts the CPU, sends button
  inputs, and renders the mirrored 10x20 board.
- `fpga/vivado/build_pynq_axi_overlay.tcl` builds the PYNQ overlay that
  connects Zynq PS `M_AXI_GP0` to the tinycpu loader/control slave.

## App I/O Registers

| CPU-side address | Current name | Purpose |
| --- | --- | --- |
| `0x1000_0010` | `HOST_INPUT` | Host/Jupyter input bits polled by firmware |
| `0x1000_0014` | `APP_STATUS` | App status bits |
| `0x1000_0018` | `APP_VALUE0` | App-defined value, score for TinyTetris |
| `0x1000_001C` | `APP_VALUE1` | App-defined value, lines for TinyTetris |
| `0x1000_0020` | `FRAME_COUNTER` | App frame counter |
| `0x1000_0100 - 0x1000_01FF` | `FRAMEBUFFER` | 10x20 byte-cell board/window |

## Remaining Work

- Run the PYNQ/Jupyter overlay and notebooks on a real PYNQ-Z2 board.
- Add real screenshot/GIF evidence only after board success.
- Add optional keyboard event handling; current notebook input uses buttons.
- Consider HDMI/VGA/UART only as later extensions.
