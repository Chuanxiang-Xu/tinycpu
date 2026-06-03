# tinycpu

[![tinycpu CI](https://github.com/Chuanxiang-Xu/tinycpu/actions/workflows/ci.yml/badge.svg)](https://github.com/Chuanxiang-Xu/tinycpu/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![ISA: RV32IM](https://img.shields.io/badge/ISA-RV32IM-blue.svg)
![FPGA: PYNQ-Z2](https://img.shields.io/badge/FPGA-PYNQ--Z2-green.svg)

tinycpu is a source-first, clean-room educational RV32IM SoC for the PYNQ-Z2
FPGA board, with dmem-side MMIO, an AXI-Lite loader/control block, cocotb
simulation, and a Vivado Tcl flow.

Current development milestone: `v0.9-jupyter-interactive-io-tetris-demo`.

Important status note: the repository contains an overlapped educational
pipeline core with Harvard-style simple memory ports, a unified BRAM/loader
SoC wrapper, selected RV32I/RV32M ISA-style tests, and a PYNQ/Jupyter AXI
overlay path for interactive demos. Some test target names retain their
historical `v0.x` prefixes because they mark when that coverage was added.

This repository does not depend on private course solution code, local homework
directories, generated Vivado projects, or non-public RTL.

## Current Status

- RV32IM-target educational core.
- RV32I implemented with RV32M multiply/divide support carried forward.
- Overlapped IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers.
- Unified 64 KiB BRAM behind simple instruction/data memory ports.
- AXI-Lite loader/control slave at the SoC boundary.
- PYNQ/Jupyter AXI overlay that connects Zynq PS `M_AXI_GP0` to the loader.
- PYNQ-Z2 LED/switch MMIO demo through the dmem-side MMIO decoder.
- Generic PYNQ/Jupyter interactive I/O helpers, framebuffer display, and
  TinyTetris as the first app demo.
- Vivado Tcl flows for pin smoke, pure PL preloaded firmware, and the
  PYNQ/Jupyter AXI overlay.

## Teaching Path

This project is meant to be read as a small SoC, not only as isolated RTL
files:

1. Start with `rtl/soc/tinycpu_soc.sv` to see how the CPU, BRAM, MMIO decoder,
   and AXI-Lite loader fit together.
2. Read `rtl/core/tinycpu_core_pipe.sv` next. It is the main pipeline control
   path, with stage registers, hazards, forwarding, branch flushes, and RV32M
   stalls in one place.
3. Use `docs/memory_map.md` while reading firmware or tests so CPU-side MMIO
   and loader-side AXI-Lite addresses do not get mixed up.
4. Run the focused cocotb targets in `docs/simulation.md`; each one is a small
   lesson about one hardware feature.
5. Treat `tests/riscv/` as selected clean-room ISA coverage, not as a full
   imported RISC-V compliance suite.

## Quick Start

```sh
git clone https://github.com/Chuanxiang-Xu/tinycpu.git
cd tinycpu

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

make -C sim/cocotb
```

Build the basic RV32I bare-metal C GPIO demo:

```sh
make -C programs/c_demo
```

Build the RV32IM multiply/divide/grid math demo:

```sh
make -C programs/rv32im_demo
```

Build the framebuffer demo firmware:

```sh
make -C programs/framebuffer_demo
```

Build the interactive I/O and TinyTetris demos:

```sh
make -C programs/interactive_demo
make -C programs/tetris
```

Build the pure PL PYNQ-Z2 bitstream from Tcl:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Build the PYNQ/Jupyter AXI overlay:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
```

## Repository Layout

```text
rtl/core/       RV32IM-target pipeline core, regfile, ALU, forwarding, mul/div
rtl/bus/        AXI-Lite loader/control module
rtl/mem/        Unified BRAM and memory-oriented building blocks
rtl/soc/        SoC integration
rtl/board/      PYNQ-Z2 board tops, pin smoke test, and AXI overlay wrapper
programs/       Hand-written demo, C demos, shared bare-metal support
sim/cocotb/     cocotb tests and Makefile test entry points
notebooks/      PYNQ/Jupyter loader, framebuffer, and TinyTetris helpers
fpga/vivado/    Vivado Tcl and PYNQ-Z2 constraints
docs/           Architecture, ISA, simulation, verification, bring-up notes
```

## Architecture Overview

```text
PYNQ-Z2 pins
  -> pynqz2_top
      -> tinycpu_soc
          -> tinycpu_core_pipe
          -> unified 64 KiB BRAM
          -> dmem MMIO decoder
          -> AXI-Lite loader/control slave

PYNQ-Z2 PS M_AXI_GP0
  -> tinycpu_pynq_system block design
      -> tinycpu_pynq_axi_overlay
          -> tinycpu_soc AXI-Lite loader/control slave
```

RAM is initialized from a hex file. The CPU reset PC is `0x0000_0000`.
The core uses simple instruction and data memory ports; AXI-Lite is now at the
SoC loader/control boundary instead of inside the CPU pipeline.

## What You Should See

The default FPGA top keeps two debug LEDs active:

| Board IO | Meaning |
| --- | --- |
| `LED0` | CPU-written GPIO bit following `SW0` |
| `LED1` | CPU-written GPIO bit following `SW1` |
| `LED2` | Direct reset/debug indicator following `BTN0` |
| `LED3` | Clock heartbeat from `sysclk` |

After programming the tinycpu bitstream:

1. Press `BTN0`: `LED2` should turn on.
2. Release `BTN0`: `LED2` should turn off and `LED3` should blink.
3. Toggle `SW0` and `SW1`: `LED0` and `LED1` should follow.

If you only want to verify the board pins before debugging the CPU, build the
pin smoke test in the steps below.

## Prerequisites

On Ubuntu:

```sh
sudo apt update
sudo apt install -y python3 python3-venv make iverilog
```

For firmware builds, install a RISC-V bare-metal GNU toolchain. The Makefiles
default to the common multilib prefix:

```text
riscv64-unknown-elf-gcc
riscv64-unknown-elf-objcopy
riscv64-unknown-elf-objdump
```

For FPGA builds:

- Xilinx Vivado
- PYNQ-Z2 board
- PYNQ-Z2 part `xc7z020clg400-1`

If your Vivado install path differs, adjust the `source` command shown below.

## Simulation

Run the default assembly GPIO smoke test:

```sh
make -C sim/cocotb
```

Run the named test targets:

```sh
make -C sim/cocotb test-v03-gpio
make -C sim/cocotb test-v04-firmware-gpio
make -C sim/cocotb test-v05-muldiv
make -C sim/cocotb test-v05-rv32i-directed
make -C sim/cocotb test-v05-branch-load-store
make -C sim/cocotb test-v05-rv32im-grid
make -C sim/cocotb test-v06-bram
make -C sim/cocotb test-v06-axil-loader
make -C sim/cocotb test-v06-pipeline-overlap
make -C sim/cocotb test-v06-forwarding
make -C sim/cocotb test-v06-load-use
make -C sim/cocotb test-v06-branch-flush
make -C sim/cocotb test-v06-pipeline
make -C sim/cocotb test-v07-loader-mirror
make -C sim/cocotb test-v08-framebuffer-mirror
make -C sim/cocotb test-v08-framebuffer
make -C sim/cocotb test-v09-host-input
make -C sim/cocotb test-v09-interactive-io
make -C sim/cocotb test-v09-tetris-smoke
make -C sim/cocotb test-v09-interactive
make -C sim/cocotb build-riscv-tests
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
make -C sim/cocotb test-riscv-isa
make -C sim/cocotb test-all
```

`test-v04-firmware-gpio` builds `programs/c_demo/firmware.hex` first.
`test-v05-rv32im-grid` builds `programs/rv32im_demo/firmware.hex` first.
Both firmware-backed tests require a RISC-V GNU toolchain.
The directed RV32I tests generate temporary RAM hex files under `sim_build/`.
The `test-v06-*` pipeline targets also generate temporary RAM hex files under
`sim_build/`; `test-v06-pipeline` runs the BRAM, loader, overlap, forwarding,
load-use, and branch-flush coverage together.
The RISC-V ISA simulation tests build tinycpu-owned assembly programs into
ELF, HEX, BIN, and DUMP files under `build/riscv-tests/`, preload the unified
BRAM, and watch the CPU-side MMIO test status registers at
`0x1000_0FF0` / `0x1000_0FF4`:

```sh
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
make -C sim/cocotb test-riscv-isa
```

These targets pass a selected rv32ui-style and rv32um-style subset in
simulation, including byte/halfword loads and an M-result pipeline stress
case. They are not a full RISC-V compliance claim.
The `test-all` target is the current CI aggregate: GPIO smoke, C GPIO
firmware, standalone RV32M mul/div, the BRAM/loader/pipeline suite, and the
RISC-V ISA smoke target. GitHub Actions also runs `test-riscv-isa` so the
selected rv32ui-style and rv32um-style tests are covered before release.
The older v0.5 directed/grid tests remain available as individual regression
targets while they are being realigned with the current pipeline core.

Expected result for each single-test cocotb target:

```text
TESTS=1 PASS=1 FAIL=0
```

## Firmware Demos

`programs/c_demo/` is a basic bare-metal C GPIO demo. It defaults to:

```text
-march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -nostartfiles
```

Build it with:

```sh
make -C programs/c_demo
```

Run it in cocotb:

```sh
make -C sim/cocotb test-v04-firmware-gpio
```

`programs/rv32im_demo/` is the RV32IM multiply/divide/grid math demo. It
defaults to:

```text
-march=rv32im -mabi=ilp32 -ffreestanding -nostdlib -nostartfiles
```

Build it with:

```sh
make -C programs/rv32im_demo
```

`programs/framebuffer_demo/` is the RV32IM framebuffer demo. It clears a
10x20 CPU-side framebuffer, draws a simple moving 2x2 block, updates
`GAME_STATUS` and `FRAME_COUNTER`, and writes `TEST_STATUS = 1` after a finite
smoke sequence before continuing animation for Jupyter display.

Build it with:

```sh
make -C programs/framebuffer_demo
```

The generated ELF/BIN/HEX/DUMP files are ignored and should not be committed.

## Jupyter Framebuffer Demo

The framebuffer flow uses `notebooks/tinycpu_loader.py` and
`notebooks/framebuffer_demo.ipynb`. A PYNQ/Jupyter host loads
`programs/framebuffer_demo/firmware.hex` through the AXI-Lite loader, starts
the CPU, reads loader-side framebuffer mirror offsets, and renders the first
200 cells as a 10x20 text grid.

This is not a full Tetris implementation. It does not add HDMI/VGA, keyboard
input, interrupts, CSRs, or board demo media.

## Jupyter Interactive I/O And TinyTetris

The current PYNQ/Jupyter flow uses a generic app I/O layer:

```text
Jupyter writes HOST_INPUT -> tinycpu polls HOST_INPUT
tinycpu writes APP_STATUS / APP_VALUE0 / APP_VALUE1 / FRAME_COUNTER
tinycpu writes FRAMEBUFFER -> Jupyter reads mirrors and renders a grid
```

TinyTetris is the first app on top of this interface. The RTL is generic and
can support other small demos such as Snake, Pong, drawing demos, sorting
visualizations, or benchmark dashboards.

Build and smoke-test the interactive demos:

```sh
make -C programs/interactive_demo
make -C programs/tetris
make -C sim/cocotb test-v09-interactive
```

Run it in cocotb:

```sh
make -C sim/cocotb test-v05-rv32im-grid
```

Run the standalone RV32M unit test:

```sh
make -C sim/cocotb test-v05-muldiv
```

Run the directed RV32I and branch/load-store edge tests:

```sh
make -C sim/cocotb test-v05-rv32i-directed
make -C sim/cocotb test-v05-branch-load-store
```

## Build the Pin Smoke Bitstream

Use this first if you are bringing up a board. It bypasses the CPU and only
tests PYNQ-Z2 pins.

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pin_smoke.tcl
```

Bitstream:

```text
build/vivado/tinycpu_pynq_pin_smoke/tinycpu_pynq_pin_smoke.runs/impl_1/pynqz2_pin_smoke_top.bit
```

Expected board behavior:

| Board IO | Expected behavior |
| --- | --- |
| `LED0` | follows `SW0` |
| `LED1` | follows `SW1` |
| `LED2` | follows `BTN0` |
| `LED3` | blinks from `sysclk` |

If this does not work, debug the Vivado programming flow, board selection,
cable, or constraints before debugging the CPU.

## Build the TinyCPU Bitstream

Default build, using the checked-in hand-written assembly demo:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Project name:

```text
tinycpu_pynq_v0_6_pipeline_bram_loader
```

Bitstream:

```text
build/vivado/tinycpu_pynq_v0_6_pipeline_bram_loader/tinycpu_pynq_v0_6_pipeline_bram_loader.runs/impl_1/pynqz2_top.bit
```

Build with the GCC-generated C firmware instead:

```sh
make -C programs/c_demo

source ~/vivado/2025.2/Vivado/settings64.sh
TINYCPU_RAM_HEX=programs/c_demo/firmware.hex TINYCPU_RAM_INIT_WORDS=256 \
    vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

The Vivado log should include:

```text
RAM_HEX=/absolute/path/to/programs/c_demo/firmware.hex RAM_INIT_WORDS=256
$readmem data file '/absolute/path/to/programs/c_demo/firmware.hex' is read successfully
```

## Build the PYNQ Jupyter Overlay

The Jupyter demos need the Zynq PS `M_AXI_GP0` port connected to the tinycpu
AXI-Lite loader/control slave. Build that overlay with:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
```

Project name:

```text
tinycpu_pynq_v0_9_jupyter_axi_overlay
```

Bitstream and hardware handoff:

```text
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.runs/impl_1/tinycpu_pynq_system_wrapper.bit
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.gen/sources_1/bd/tinycpu_pynq_system/hw_handoff/tinycpu_pynq_system.hwh
```

Copy both files to the PYNQ board and give them matching base names, for
example `tinycpu.bit` and `tinycpu.hwh`, before opening the notebooks.

## Program the PYNQ-Z2

Open Vivado Hardware Manager:

```sh
vivado
```

Then:

1. Open Hardware Manager.
2. Open Target.
3. Auto Connect.
4. Program Device.
5. Select `pynqz2_top.bit` for the pure PL preloaded demo, or
   `tinycpu_pynq_system_wrapper.bit` for the PYNQ/Jupyter AXI overlay.

Use this bitstream for the full CPU demo:

```text
build/vivado/tinycpu_pynq_v0_6_pipeline_bram_loader/tinycpu_pynq_v0_6_pipeline_bram_loader.runs/impl_1/pynqz2_top.bit
```

## Memory Map

CPU-side map:

| Address range | Device |
| --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | Unified BRAM program/data RAM |
| `0x1000_0000` | dmem MMIO LED output register |
| `0x1000_0004` | dmem MMIO switch input register |
| `0x1000_0010` | `HOST_INPUT`, formerly game input |
| `0x1000_0014` | `APP_STATUS`, formerly game status |
| `0x1000_0018` | `APP_VALUE0`, app-defined value such as score |
| `0x1000_001C` | `APP_VALUE1`, app-defined value such as lines/level |
| `0x1000_0020` | Frame counter register |
| `0x1000_0024` | Optional command acknowledgement register |
| `0x1000_0100 - 0x1000_01FF` | App framebuffer window |
| `0x1000_0FF0` | RISC-V ISA test status register |
| `0x1000_0FF4` | RISC-V ISA test code register |

ISA test result registers:

| Address | Name | Meaning |
| --- | --- | --- |
| `0x1000_0FF0` | `TEST_STATUS` | `0 = idle`, `1 = pass`, other nonzero = fail |
| `0x1000_0FF4` | `TEST_CODE` | Optional failing test/debug code |

Loader-side AXI-Lite map:

| Loader offset | Device |
| --- | --- |
| `0x00000 - 0x0FFFF` | BRAM loader window |
| `0x10000` | CONTROL register |
| `0x10004` | STATUS register |
| `0x10008` | BOOT_PC register |
| `0x1000C` | Reserved/debug register |
| `0x10010` | Read-only `TEST_STATUS` mirror |
| `0x10014` | Read-only `TEST_CODE` mirror |
| `0x10018` | Read-only `APP_STATUS` mirror |
| `0x1001C` | Read-only `APP_VALUE0` mirror |
| `0x10020` | Read-only `APP_VALUE1` mirror |
| `0x10024` | Read-only `FRAME_COUNTER` mirror |
| `0x10030` | Write/read `HOST_INPUT` register |
| `0x10034` | Write/read optional host command register |
| `0x10038` | Write host input clear register |
| `0x10100 - 0x101FF` | Read-only packed framebuffer mirror |

## Documentation

- [Architecture](docs/architecture.md)
- [Instruction set](docs/instruction_set.md)
- [Pipeline status](docs/pipeline.md)
- [Simulation](docs/simulation.md)
- [Bare-metal C](docs/baremetal_c.md)
- [Memory map](docs/memory_map.md)
- [Jupyter framebuffer demo](docs/jupyter_framebuffer.md)
- [Jupyter interactive I/O](docs/jupyter_interactive_io.md)
- [TinyTetris Jupyter demo](docs/jupyter_tetris.md)
- [Verification](docs/verification.md)
- [Release checklist](docs/release_checklist.md)
- [v0.6 release notes draft](docs/releases/v0.6-pipeline-bram-isa-tests.md)
- [Roadmap](docs/roadmap.md)

## Demo Media

Board demo media can be added under `docs/images/` after a real PYNQ-Z2 run,
for example `docs/images/pynqz2_led_demo.gif`. The README intentionally does
not reference screenshots or GIFs until those files actually exist.

## Rebuild the Hand-Written Demo Hex

```sh
python3 programs/led_switch_demo.py
```

This regenerates:

```text
programs/led_switch_demo.hex
```

## Troubleshooting

If `LED2` does not follow `BTN0`, the full tinycpu design is not the first
thing to debug. Run the pin smoke bitstream and check that you programmed the
correct device with the correct `.bit` file.

If `LED2` follows `BTN0` but `LED3` does not blink, the `sysclk` path is not
working or the wrong bitstream was programmed.

If `LED2` and `LED3` work but `LED0/LED1` do not follow switches, the board
pins are good and the issue is inside the CPU/RAM/GPIO path.

If the C demo traps immediately, check that `firmware.elf` starts at zero:

```sh
riscv64-unknown-elf-objdump -d programs/c_demo/firmware.elf | head -30
```

If Vivado builds but timing fails, the current educational core may still run
for the LED demo, but the design needs timing cleanup or a slower board clock
for a robust release.

## Source-First Policy

Keep generated artifacts out of Git:

```text
.venv/
.Xil/
build/
sim_build/
results.xml
*.jou
*.log
*.bit
*.hwh
programs/c_demo/firmware.elf
programs/c_demo/firmware.bin
programs/c_demo/firmware.hex
programs/rv32im_demo/firmware.elf
programs/rv32im_demo/firmware.bin
programs/rv32im_demo/firmware.hex
```

The checked-in source files should be enough to rebuild simulation outputs,
firmware, Vivado projects, and bitstreams from a fresh clone.

## License

MIT. See `LICENSE`.
