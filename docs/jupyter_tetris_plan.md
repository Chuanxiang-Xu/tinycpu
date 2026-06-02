# Jupyter Tetris Plan

Long-term demo goal:

- tinycpu runs RV32IM game logic in the PYNQ-Z2 PL.
- Jupyter/Python displays a game grid or framebuffer.
- Jupyter/Python writes keyboard/control input through MMIO.
- tinycpu writes game state through MMIO or BRAM-backed framebuffer memory.

Reserved GPIO/MMIO addresses:

| Address range | Purpose |
| --- | --- |
| `0x1000_0010` | Future game input register |
| `0x1000_0014` | Future game status register |
| `0x1000_0100 - 0x1000_01FF` | Future 10x20 grid/framebuffer window |

The current v0.6 design verifies the CPU/BRAM/MMIO path with a tiny assembly
demo, a GCC-built freestanding C demo, focused pipeline tests, and selected
clean-room RV32I/RV32M ISA simulation tests. The game-facing registers are
reserved to keep the teaching memory map stable for later Jupyter demos.
