# Memory Map

| Address range | Device | Description |
| --- | --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | AXI-Lite RAM | Program and data RAM |
| `0x4000_0000` | AXI-Lite GPIO | LED output register |
| `0x4000_0004` | AXI-Lite GPIO | Switch input register |
| `0x4000_0010` | AXI-Lite GPIO | Future game input register |
| `0x4000_0014` | AXI-Lite GPIO | Future game status register |
| `0x4000_0100 - 0x4000_01FF` | AXI-Lite GPIO | Future 10x20 grid/framebuffer window |

Other addresses return an AXI-Lite slave error response from the interconnect.
The current CPU ignores response codes, which is enough for bring-up but should
be improved when trap/exception handling is added.
