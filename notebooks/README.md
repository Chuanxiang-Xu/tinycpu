# tinycpu Jupyter Demos

This directory contains the PYNQ-side notebooks and Python helpers for running
tinycpu demos from a PYNQ-Z2 board. The notebooks use the Zynq PS AXI master to
load firmware into tinycpu BRAM, control CPU reset/run state, write app input,
and read app/framebuffer mirrors.

Generated overlays, `.hwh` files, screenshots, demo media, and firmware build
outputs are not tracked here.

## Prerequisites

- A PYNQ-Z2 board.
- A Vivado-built tinycpu PYNQ AXI overlay bitstream and matching `.hwh`.
- PYNQ Jupyter access on the board.
- Built firmware hex files for the demos you want to run.

## Contents

| File | Purpose |
| --- | --- |
| `README.md` | This guide. |
| `tinycpu_loader.py` | AXI-Lite loader/control helper used by all notebooks. |
| `tetris_controller.py` | Button/input wrapper used by the TinyTetris notebook. |
| `interactive_io_demo.ipynb` | First hardware smoke test for host input, app mirrors, and framebuffer reads. |
| `framebuffer_demo.ipynb` | Framebuffer animation/readback demo. |
| `tetris_demo.ipynb` | TinyTetris firmware loader, button controls, status display, and board rendering. |

## Build Firmware

Run these commands from the repository root before copying notebooks or
firmware to the board:

```sh
make -C programs/framebuffer_demo
make -C programs/interactive_demo
make -C programs/tetris
```

The notebooks load these generated files:

| Notebook | Firmware |
| --- | --- |
| `interactive_io_demo.ipynb` | `../programs/interactive_demo/firmware.hex` |
| `framebuffer_demo.ipynb` | `../programs/framebuffer_demo/firmware.hex` |
| `tetris_demo.ipynb` | `../programs/tetris/firmware.hex` |

## Build Overlay

Build the PYNQ AXI overlay from the repository root:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
```

Expected generated files:

```text
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.runs/impl_1/tinycpu_pynq_system_wrapper.bit
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.gen/sources_1/bd/tinycpu_pynq_system/hw_handoff/tinycpu_pynq_system.hwh
```

Copy both files to the PYNQ board and give them matching base names, for
example:

```text
tinycpu.bit
tinycpu.hwh
```

The notebooks currently use `Overlay("tinycpu.bit")`.

For the complete board-level flow, including pin smoke and pure PL fallback
builds, see `../docs/pynqz2_bringup.md`.

## Deploy To PYNQ-Z2

Copy these items to the board:

```text
tinycpu.bit
tinycpu.hwh
notebooks/
programs/framebuffer_demo/firmware.hex
programs/interactive_demo/firmware.hex
programs/tetris/firmware.hex
```

Keep the relative `../programs/.../firmware.hex` paths intact if you run the
notebooks from the copied `notebooks/` directory.

## Run Order

1. Open Jupyter on the PYNQ-Z2.
2. Open `notebooks/interactive_io_demo.ipynb`.
3. Run all cells and confirm that input patterns update app mirrors and the
   framebuffer view.
4. Open `notebooks/framebuffer_demo.ipynb` for a display-only framebuffer demo.
5. Open `notebooks/tetris_demo.ipynb` for TinyTetris controls and board
   rendering.

If automatic IP discovery picks the wrong IP block, set `LOADER_IP_NAME` or
`preferred_name` in the notebook to the exact tinycpu loader/control IP name
shown in `overlay.ip_dict`.

## Addressing Model

The Vivado block design maps the tinycpu loader/control slave at PS address
`0x43C0_0000`. PYNQ reads that base address from the `.hwh` via
`overlay.ip_dict`; `tinycpu_loader.py` methods use offsets relative to that
base.

These loader-side offsets are not CPU-side MMIO addresses. CPU firmware uses
the separate CPU-side map documented in `../docs/memory_map.md` and
`../programs/common/tinycpu_mmio.h`.

## Loader Offset Reference

| Offset | Helper method | Meaning |
| --- | --- | --- |
| `0x00000` | `load_words`, `load_hex` | BRAM program/data load window while the CPU is halted or reset. |
| `0x10000` | `halt`, `reset`, `clear_pipeline`, `run` | CPU control register. |
| `0x10004` | `read_status` | Loader/CPU status register. |
| `0x10008` | `set_boot_pc` | CPU boot PC. |
| `0x10010` | `read_test_status` | CPU-written test status mirror. |
| `0x10014` | `read_test_status` | CPU-written test code mirror. |
| `0x10018` | `read_app_status` | Generic app status mirror. |
| `0x1001C` | `read_app_value0` | Generic app value 0 mirror, used as score by TinyTetris. |
| `0x10020` | `read_app_value1` | Generic app value 1 mirror; TinyTetris packs lines, level, next piece, and held piece. |
| `0x10024` | `read_frame_counter` | CPU-written frame counter mirror. |
| `0x10030` | `write_input` | Host input register visible to CPU firmware. |
| `0x10034` | `write_command` | Optional host command register. |
| `0x10038` | `clear_input` | Clears the host input register. |
| `0x10100` | `read_framebuffer` | 10x20 byte-cell framebuffer mirror. |

## Demo Notes

- `interactive_io_demo.ipynb` is the best first hardware test because it writes
  obvious input patterns and reads back app values plus framebuffer cells.
- `framebuffer_demo.ipynb` is display-only after the firmware starts.
- `tetris_demo.ipynb` keeps game logic in tinycpu firmware. The notebook only
  sends input bits and displays status, score, lines, level, next piece, held
  piece, frame count, and the mirrored board.
- Button presses in `tetris_controller.py` write an input bit, hold it briefly,
  and then clear the input register. For manual experiments, call
  `cpu.write_input(value)` directly if you want to hold an input level across
  multiple CPU polling loops.

## Troubleshooting

- If `Overlay("tinycpu.bit")` cannot find hardware metadata, check that
  `tinycpu.bit` and `tinycpu.hwh` are in the same directory and share the same
  base name.
- If `find_loader_ip()` chooses the wrong IP, set `LOADER_IP_NAME` in the
  notebook.
- If firmware loading fails, reset or halt the CPU before calling `load_hex()`.
- If the framebuffer stays blank, run `interactive_io_demo.ipynb` first and
  confirm that `read_app_status()` and `read_frame_counter()` change.
- If Tetris buttons still feel too short for manual experiments, use
  `cpu.write_input(value)` directly instead of the auto-clearing controller
  helpers.
