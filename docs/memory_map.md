# Memory Map

| Address range | Device | Description |
| --- | --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | Unified BRAM | Program and data RAM |
| `0x1000_0000` | dmem MMIO | LED output register |
| `0x1000_0004` | dmem MMIO | Switch input register |
| `0x1000_0010` | dmem MMIO | Future game input register |
| `0x1000_0014` | dmem MMIO | Future game status register |
| `0x1000_0100 - 0x1000_01FF` | dmem MMIO | Future 10x20 grid/framebuffer window |

The AXI-Lite loader/control slave has its own PS-visible local map:

| Loader offset | Description |
| --- | --- |
| `0x00000 - 0x0FFFF` | 64 KiB RAM loader window |
| `0x10000` | CONTROL register |
| `0x10004` | STATUS register |
| `0x10008` | BOOT_PC register |
| `0x1000C` | Reserved/debug register |

Other CPU-side addresses currently read as zero or ignore writes. Trap/bus
error behavior is future work.
