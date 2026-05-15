# tinycpu-pynq

`tinycpu-pynq` is a source-first, clean-room educational RISC-V CPU/SoC for the
PYNQ-Z2 FPGA board.

The long-term ISA target is standard RISC-V `RV32IM`. The current milestone,
`v0.4-fuller-rv32i-c-support`, implements enough standard `RV32I` to run simple
freestanding C programs compiled with a RISC-V GNU toolchain. RV32M multiply and
divide instructions are kept on the roadmap for v0.5.

This repository does not depend on private course solution code, local homework
directories, generated Vivado projects, or non-public RTL.

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

## SoC Overview

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

## Repository Layout

```text
rtl/core/       RV32IM-target core, pipeline helpers, regfile, ALU, mul/div
rtl/axil/       AXI-Lite RAM, GPIO, and interconnect
rtl/soc/        SoC integration
rtl/board/      PYNQ-Z2 board tops, including pin smoke test
programs/       Hand-written demo and GCC bare-metal C demo
sim/cocotb/     cocotb tests
fpga/vivado/    Vivado Tcl and PYNQ-Z2 constraints
docs/           Architecture, ISA, simulation, bare-metal C, bring-up notes
```

## Prerequisites

On Ubuntu:

```sh
sudo apt update
sudo apt install -y python3 python3-venv make iverilog
```

For the C demo, install a RISC-V bare-metal GNU toolchain. The Makefile defaults
to the common multilib prefix:

```sh
riscv64-unknown-elf-gcc
riscv64-unknown-elf-objcopy
riscv64-unknown-elf-objdump
```

For FPGA builds:

- Xilinx Vivado
- PYNQ-Z2 board
- PYNQ-Z2 part `xc7z020clg400-1`

If your Vivado install path differs, adjust the `source` command shown below.

## Fresh Clone Setup

```sh
git clone https://github.com/Chuanxiang-Xu/tinycpu.git
cd tinycpu

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 1. Run RTL Simulation

Run the default assembly GPIO demo:

```sh
cd sim/cocotb
make
```

Expected result:

```text
TESTS=1 PASS=1 FAIL=0
```

Return to the repository root:

```sh
cd ../..
```

## 2. Build the Bare-Metal C Demo

The C demo lives in `programs/c_demo/`.

```sh
cd programs/c_demo
make
```

Generated files:

```text
firmware.elf
firmware.bin
firmware.hex
```

The important compiler flags are:

```text
-march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -nostartfiles
```

Check that the reset entry point is at `0x00000000`:

```sh
riscv64-unknown-elf-objdump -d firmware.elf | head -30
```

You should see:

```text
00000000 <_start>:
```

Run the C firmware in cocotb:

```sh
cd ../../sim/cocotb
make COCOTB_TEST_MODULES=test_v04_firmware_gpio RAM_HEX=../../programs/c_demo/firmware.hex RAM_INIT_WORDS=18
```

Return to the repository root:

```sh
cd ../..
```

## 3. Build the Pin Smoke Bitstream

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

Program it with Vivado Hardware Manager. Expected board behavior:

| Board IO | Expected behavior |
| --- | --- |
| `LED0` | follows `SW0` |
| `LED1` | follows `SW1` |
| `LED2` | follows `BTN0` |
| `LED3` | blinks from `sysclk` |

If this does not work, debug the Vivado programming flow, board selection, cable,
or constraints before debugging the CPU.

## 4. Build the TinyCPU Bitstream

Default build, using the checked-in hand-written assembly demo:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Bitstream:

```text
build/vivado/tinycpu_pynq_v0_4_fuller_rv32i_c_support/tinycpu_pynq_v0_4_fuller_rv32i_c_support.runs/impl_1/pynqz2_top.bit
```

Build with the GCC-generated C firmware instead:

```sh
cd programs/c_demo
make

cd ../..
source ~/vivado/2025.2/Vivado/settings64.sh
TINYCPU_RAM_HEX=programs/c_demo/firmware.hex TINYCPU_RAM_INIT_WORDS=18 \
    vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

The Vivado log should include:

```text
RAM_HEX=/absolute/path/to/programs/c_demo/firmware.hex RAM_INIT_WORDS=18
$readmem data file '/absolute/path/to/programs/c_demo/firmware.hex' is read successfully
```

## 5. Program the PYNQ-Z2

Open Vivado Hardware Manager:

```sh
vivado
```

Then:

1. Open Hardware Manager
2. Open Target
3. Auto Connect
4. Program Device
5. Select `pynqz2_top.bit`

Use this bitstream for the full CPU demo:

```text
build/vivado/tinycpu_pynq_v0_4_fuller_rv32i_c_support/tinycpu_pynq_v0_4_fuller_rv32i_c_support.runs/impl_1/pynqz2_top.bit
```

Expected board behavior:

| Board IO | Expected behavior |
| --- | --- |
| `LED0` | follows `SW0` through CPU-executed MMIO |
| `LED1` | follows `SW1` through CPU-executed MMIO |
| `LED2` | follows `BTN0` directly |
| `LED3` | blinks from `sysclk` |

## Memory Map

| Address range | Device |
| --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | AXI-Lite RAM |
| `0x4000_0000` | GPIO LED output register |
| `0x4000_0004` | GPIO switch input register |
| `0x4000_0010` | Future game input register |
| `0x4000_0014` | Future game status register |
| `0x4000_0100 - 0x4000_01FF` | Future game grid/framebuffer window |

## Rebuild the Hand-Written Demo Hex

```sh
python3 programs/led_switch_demo.py
```

This regenerates:

```text
programs/led_switch_demo.hex
```

## Troubleshooting

If `LED2` does not follow `BTN0`, the full tinycpu design is not the first thing
to debug. Run the pin smoke bitstream and check that you programmed the correct
device with the correct `.bit` file.

If `LED2` follows `BTN0` but `LED3` does not blink, the `sysclk` path is not
working or the wrong bitstream was programmed.

If `LED2` and `LED3` work but `LED0/LED1` do not follow switches, the board pins
are good and the issue is inside the CPU/RAM/GPIO path.

If the C demo traps immediately, check that `firmware.elf` starts at zero:

```sh
riscv64-unknown-elf-objdump -d programs/c_demo/firmware.elf | head -30
```

If Vivado builds but timing fails, the current educational core may still run
for the LED demo, but the design needs timing cleanup or a slower board clock
for a robust release.

## Current ISA Status

Target ISA: `RV32IM`

Implemented in v0.4: fuller `RV32I` for simple C support.

Planned for v0.5: RV32M multiply/divide integration.

See:

- `docs/instruction_set.md`
- `docs/baremetal_c.md`
- `docs/pipeline.md`
- `docs/roadmap.md`

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
```

The checked-in files should be enough to rebuild simulation outputs, firmware,
Vivado projects, and bitstreams from a fresh clone.

## License

MIT. See `LICENSE`.
