# Memory Map

| Address range | Device | Description |
| --- | --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | Unified BRAM | Program and data RAM |
| `0x1000_0000` | dmem MMIO | LED output register |
| `0x1000_0004` | dmem MMIO | Switch input register |
| `0x1000_0010` | dmem MMIO | `HOST_INPUT`, formerly `GAME_INPUT`; CPU polls host/Jupyter input |
| `0x1000_0014` | dmem MMIO | `APP_STATUS`, formerly `GAME_STATUS`; CPU-written status register |
| `0x1000_0018` | dmem MMIO | `APP_VALUE0`, app-defined value such as score |
| `0x1000_001C` | dmem MMIO | `APP_VALUE1`, app-defined value such as lines/level |
| `0x1000_0020` | dmem MMIO | `FRAME_COUNTER`, CPU-written frame counter |
| `0x1000_0024` | dmem MMIO | `COMMAND_ACK`, optional app acknowledgement |
| `0x1000_0100 - 0x1000_01FF` | dmem MMIO | 10x20 grid/framebuffer window |
| `0x1000_0FF0` | dmem MMIO | RISC-V ISA test status register: `0 = idle`, `1 = pass`, other nonzero = fail |
| `0x1000_0FF4` | dmem MMIO | RISC-V ISA test code register: optional failing test/debug code |

Framebuffer format:

- Logical grid: 10 columns x 20 rows = 200 cells.
- Each cell is 1 byte.
- `0` means empty.
- `1` through `7` are reserved block/color IDs for future Tetris pieces.
- The remaining 56 bytes in the 256-byte window are reserved.

The AXI-Lite loader/control slave has its own PS-visible local map:

| Loader offset | Description |
| --- | --- |
| `0x00000 - 0x0FFFF` | 64 KiB RAM loader window |
| `0x10000` | CONTROL register |
| `0x10004` | STATUS register |
| `0x10008` | BOOT_PC register |
| `0x1000C` | Reserved/debug register |
| `0x10010` | Read-only mirror of CPU-side `TEST_STATUS` |
| `0x10014` | Read-only mirror of CPU-side `TEST_CODE` |
| `0x10018` | Read-only mirror of CPU-side `APP_STATUS` |
| `0x1001C` | Read-only mirror of CPU-side `APP_VALUE0` |
| `0x10020` | Read-only mirror of CPU-side `APP_VALUE1` |
| `0x10024` | Read-only mirror of CPU-side `FRAME_COUNTER` |
| `0x10030` | Write/read `HOST_INPUT_WRITE` register |
| `0x10034` | Write/read optional `HOST_COMMAND_WRITE` register |
| `0x10038` | Write `HOST_INPUT_CLEAR` register |
| `0x10100 - 0x101FF` | Read-only packed framebuffer mirror |

Framebuffer mirror reads return packed 32-bit little-endian words:

```text
word[7:0]   = cell n
word[15:8]  = cell n + 1
word[23:16] = cell n + 2
word[31:24] = cell n + 3
```

Other CPU-side addresses currently read as zero or ignore writes. Trap/bus
error behavior is future work.
