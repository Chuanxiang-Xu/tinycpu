# Jupyter Framebuffer Demo

The framebuffer demo is the simplest display path for the current
PYNQ/Jupyter flow. It is not a full game implementation.

The goal is:

```text
bare-metal C framebuffer demo
  -> AXI-Lite loader writes HEX into BRAM
  -> tinycpu runs the program
  -> C writes CPU-side framebuffer/status MMIO
  -> AXI-Lite loader exposes read-only mirrors
  -> Jupyter reads and renders a 10x20 grid
```

## CPU-Side Map

Programs running on tinycpu use the normal dmem MMIO page:

| CPU address | Name | Description |
| --- | --- | --- |
| `0x1000_0010` | `HOST_INPUT` / `GAME_INPUT` | Host input for v0.9 and later |
| `0x1000_0014` | `APP_STATUS` / `GAME_STATUS` | CPU-written status register |
| `0x1000_0018` | `APP_VALUE0` / `GAME_SCORE` | App-defined value |
| `0x1000_001C` | `APP_VALUE1` | App-defined value |
| `0x1000_0020` | `FRAME_COUNTER` | CPU-written frame counter |
| `0x1000_0100 - 0x1000_01FF` | `FRAMEBUFFER` | 256-byte framebuffer window |
| `0x1000_0FF0` | `TEST_STATUS` | `0 = idle`, `1 = pass`, other nonzero = fail |
| `0x1000_0FF4` | `TEST_CODE` | Optional fail/debug code |

Framebuffer format:

- Logical grid: 10 columns x 20 rows = 200 cells.
- Each cell is 1 byte.
- `0` means empty.
- `1` through `7` are reserved color/block IDs for future Tetris pieces.
- The remaining 56 bytes in the 256-byte window are reserved.

## Loader-Side Mirrors

PYNQ/Jupyter reads the AXI-Lite loader/control address space, not CPU-side
`0x1000_xxxx` addresses:

| Loader offset | Name | Description |
| --- | --- | --- |
| `0x10018` | `APP_STATUS_MIRROR` | Read-only mirror of CPU-side `APP_STATUS` |
| `0x1001C` | `APP_VALUE0_MIRROR` | Read-only mirror of CPU-side `APP_VALUE0` |
| `0x10020` | `APP_VALUE1_MIRROR` | Read-only mirror of CPU-side `APP_VALUE1` |
| `0x10024` | `FRAME_COUNTER_MIRROR` | Read-only mirror of CPU-side `FRAME_COUNTER` |
| `0x10100 - 0x101FF` | `FRAMEBUFFER_MIRROR` | Read-only packed framebuffer mirror |

Framebuffer mirror words are packed little-endian:

```text
word[7:0]   = cell n
word[15:8]  = cell n + 1
word[23:16] = cell n + 2
word[31:24] = cell n + 3
```

For the 10x20 board, Jupyter reads the first 50 words and ignores the reserved
tail of the 256-byte window.

## Build And Display

Build the demo firmware:

```sh
make -C programs/framebuffer_demo
```

Run the mirror regression before board testing:

```sh
make -C sim/cocotb test-v08-framebuffer-mirror
```

On a PYNQ-Z2 board, use `notebooks/framebuffer_demo.ipynb` with the
PYNQ/Jupyter AXI overlay described in `pynqz2_bringup.md`. The notebook
loads `programs/framebuffer_demo/firmware.hex`, starts the CPU, reads the
framebuffer mirror through `notebooks/tinycpu_loader.py`, and prints a 10x20
text grid.

## Limitations

- No game logic.
- No HDMI/VGA output.
- No keyboard or controller input path.
- No timer interrupts or interrupt-driven animation.
- No real board screenshot/GIF is included until an actual board run succeeds.
