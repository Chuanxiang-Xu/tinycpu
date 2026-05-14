# Jupyter Tetris Plan

Long-term demo goal:

- tinycpu runs RV32IM game logic in the PYNQ-Z2 PL.
- Jupyter/Python displays a game grid or framebuffer.
- Jupyter/Python writes keyboard/control input through MMIO.
- tinycpu writes game state through MMIO or BRAM-backed framebuffer memory.

Reserved GPIO/MMIO addresses:

| Address range | Purpose |
| --- | --- |
| `0x4000_0010` | Future game input register |
| `0x4000_0014` | Future game status register |
| `0x4000_0100 - 0x4000_01FF` | Future 10x20 grid/framebuffer window |

The current v0.3 design only verifies the CPU/RAM/GPIO path with switches and
LEDs. The game-facing registers are included to keep the memory map stable.
