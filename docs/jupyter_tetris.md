# TinyTetris Jupyter Demo

TinyTetris is a small bare-metal C application on top of the current generic
Jupyter interactive I/O layer. The RTL exposes generic app I/O; it does not
contain Tetris-specific hardware.

## Input Bits

| Bit | Name |
| --- | --- |
| `0` | Left |
| `1` | Right |
| `2` | Rotate |
| `3` | Soft drop |
| `4` | Hard drop |
| `5` | Start/restart |
| `6` | Pause |
| `7` | Hold |

Jupyter writes these bits to loader offset `0x10030`. The CPU polls
`HOST_INPUT` at `0x1000_0010`.

## App Outputs

| Register | TinyTetris meaning |
| --- | --- |
| `APP_STATUS` | running/game-over/paused/frame-ready/input-consumed bits |
| `APP_VALUE0` | score |
| `APP_VALUE1` | packed lines, level, next piece, and held piece |
| `FRAME_COUNTER` | frame count |
| `FRAMEBUFFER` | 10x20 board cells |

Status bits:

| Bit | Meaning |
| --- | --- |
| `0` | running |
| `1` | game over |
| `2` | paused |
| `3` | frame ready |
| `4` | input consumed |
| `5` | hold already used for current piece |

`APP_VALUE1` is packed as:

| Bits | Meaning |
| --- | --- |
| `15:0` | lines cleared |
| `23:16` | level |
| `27:24` | next piece, 1-7 |
| `31:28` | held piece, 1-7, or 0 for empty |

## Build And Run

Build the firmware:

```sh
make -C programs/tetris
```

Run the simulation smoke test:

```sh
make -C sim/cocotb test-v09-tetris-smoke
```

On PYNQ-Z2, use `notebooks/tetris_demo.ipynb` with the PYNQ/Jupyter AXI
overlay described in `pynqz2_bringup.md`. The notebook loads
`programs/tetris/firmware.hex`, creates button widgets, writes input through
`TetrisController`, and displays the framebuffer mirror. The loader/control
slave is mapped at PS address `0x43C0_0000`; the notebook discovers this from
the matching `.hwh`.

## Limitations

- This is a tiny teaching implementation, not a polished game engine.
- It implements seven-bag pieces, a one-piece hold slot, ghost projection,
  simple wall kicks, level-based gravity, soft drop, hard drop, and line-clear
  scoring.
- It uses Jupyter buttons, not keyboard events.
- It has no HDMI/VGA output.
- It has no interrupts or timer interrupts.
- Add screenshots or GIFs only after a real board run succeeds.
