# tinycpu

[![tinycpu CI](https://github.com/Chuanxiang-Xu/tinycpu/actions/workflows/ci.yml/badge.svg)](https://github.com/Chuanxiang-Xu/tinycpu/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![ISA: RV32IM](https://img.shields.io/badge/ISA-RV32IM-blue.svg)
![FPGA: PYNQ-Z2](https://img.shields.io/badge/FPGA-PYNQ--Z2-green.svg)

tinycpu is a source-first, clean-room educational RV32IM SoC for the PYNQ-Z2
FPGA board, with AXI-Lite MMIO, cocotb simulation, and a Vivado Tcl flow.

Current milestone: `v0.5-rv32im-m-extension`.

Important status note: the CPU is stage-structured around IF, ID, EX, MEM, and
WB, but it is not a fully overlapped five-stage pipeline yet. The current core
serializes instruction fetch and load/store traffic through one AXI-Lite master.

This repository does not depend on private course solution code, local homework
directories, generated Vivado projects, or non-public RTL.

## Current Status

- RV32IM-target educational core.
- RV32I implemented with RV32M multiply/divide implemented in v0.5.
- Stage-structured serialized control path, not a fully overlapped pipeline.
- PYNQ-Z2 LED/switch MMIO demo through AXI-Lite GPIO.
- Vivado Hardware Manager bitstream programming flow.
- PYNQ Overlay/Jupyter flow is planned later.

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

Build the PYNQ-Z2 bitstream from Tcl:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

## Repository Layout

```text
rtl/core/       RV32IM-target core, stage helpers, regfile, ALU, mul/div
rtl/axil/       AXI-Lite RAM, GPIO, and interconnect
rtl/soc/        SoC integration
rtl/board/      PYNQ-Z2 board tops, including pin smoke test
programs/       Hand-written demo, RV32I C demo, RV32IM C demo
sim/cocotb/     cocotb tests and Makefile test entry points
fpga/vivado/    Vivado Tcl and PYNQ-Z2 constraints
docs/           Architecture, ISA, simulation, verification, bring-up notes
```

## Architecture Overview

```text
PYNQ-Z2 pins
  -> pynqz2_top
      -> tinycpu_soc
          -> tinycpu_core_rv32im_axil
          -> axil_interconnect
              -> axil_ram
              -> axil_gpio
```

RAM is initialized from a hex file. The CPU reset PC is `0x0000_0000`.

The design uses one AXI-Lite master for both instruction fetch and data
load/store operations, so the v0.5 core waits around bus transactions instead
of overlapping all five stages.

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
make -C sim/cocotb test-all
```

`test-v04-firmware-gpio` builds `programs/c_demo/firmware.hex` first.
`test-v05-rv32im-grid` builds `programs/rv32im_demo/firmware.hex` first.
Both firmware-backed tests require a RISC-V GNU toolchain.
The directed RV32I tests generate temporary RAM hex files under `sim_build/`.

Expected cocotb result:

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
tinycpu_pynq_v0_5_rv32im_m_extension
```

Bitstream:

```text
build/vivado/tinycpu_pynq_v0_5_rv32im_m_extension/tinycpu_pynq_v0_5_rv32im_m_extension.runs/impl_1/pynqz2_top.bit
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
5. Select `pynqz2_top.bit`.

Use this bitstream for the full CPU demo:

```text
build/vivado/tinycpu_pynq_v0_5_rv32im_m_extension/tinycpu_pynq_v0_5_rv32im_m_extension.runs/impl_1/pynqz2_top.bit
```

## Memory Map

| Address range | Device |
| --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | AXI-Lite RAM |
| `0x4000_0000` | GPIO LED output register |
| `0x4000_0004` | GPIO switch input register |
| `0x4000_0010` | Future game input register |
| `0x4000_0014` | Future game status register |
| `0x4000_0100 - 0x4000_01FF` | Future game grid/framebuffer window |

## Documentation

- [Architecture](docs/architecture.md)
- [Instruction set](docs/instruction_set.md)
- [Pipeline status](docs/pipeline.md)
- [Simulation](docs/simulation.md)
- [Bare-metal C](docs/baremetal_c.md)
- [Memory map](docs/memory_map.md)
- [Verification](docs/verification.md)
- [Roadmap](docs/roadmap.md)

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
