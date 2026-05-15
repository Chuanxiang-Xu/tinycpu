# tinycpu-pynq

`tinycpu-pynq` is an independent educational FPGA CPU/SoC project for the
PYNQ-Z2 board.

The long-term ISA target is standard RISC-V `RV32IM`. The project is clean-room:
it is not a homework solution repository, does not use private course solution
code, and is intended to be reproducible from a public GitHub clone.

## v0.4-fuller-rv32i-c-support

v0.4-fuller-rv32i-c-support builds a small RISC-V SoC:

```text
tinycpu_core_rv32im_axil
    -> axil_interconnect
        -> axil_ram
        -> axil_gpio
            -> PYNQ-Z2 LEDs / switches
```

The CPU target is RV32IM. This milestone implements fuller RV32I for simple
freestanding C programs built with a RISC-V GNU toolchain using
`-march=rv32i -mabi=ilp32`.

The M extension structure is present through `tinycpu_muldiv.sv`, but full
RV32M instruction support is planned for v0.5.

## Demo Programs

The checked-in assembly demo and the GCC-built C firmware both implement:

```c
while (1) {
    *(volatile uint32_t *)0x40000000 =
        *(volatile uint32_t *)0x40000004;
}
```

On PYNQ-Z2, `LED[1:0]` follows `SW[1:0]` through CPU-executed MMIO loads and
stores.

## Repository Layout

```text
rtl/core/       RV32IM-target core, pipeline helpers, regfile, ALU, mul/div
rtl/axil/       AXI-Lite RAM, GPIO, interconnect
rtl/soc/        SoC integration
rtl/board/      PYNQ-Z2 top wrapper
programs/       Demo assembly, linker script, hex generator, C demo firmware
sim/cocotb/     cocotb tests
fpga/vivado/    Vivado Tcl and PYNQ-Z2 XDC
docs/           Architecture, memory map, pipeline, roadmap
```

## Prerequisites

For simulation:

- Python 3.10 or newer
- Icarus Verilog with SystemVerilog support
- `make`

On Ubuntu:

```sh
sudo apt update
sudo apt install -y python3 python3-venv make iverilog
```

For FPGA bitstream generation:

- Xilinx Vivado
- PYNQ-Z2 board
- PYNQ-Z2 part number confirmed as `xc7z020clg400-1` or updated in
  `fpga/vivado/create_project.tcl`

For the v0.4 C firmware:

- `riscv64-unknown-elf-gcc` and `riscv64-unknown-elf-objcopy`, or the
  equivalent `riscv32-unknown-elf` tools selected with `CROSS=...`

## Memory Map

| Address range | Device |
| --- | --- |
| `0x0000_0000 - 0x0000_FFFF` | AXI-Lite RAM |
| `0x4000_0000` | GPIO LED output register |
| `0x4000_0004` | GPIO switch input register |
| `0x4000_0010` | Future game input register |
| `0x4000_0014` | Future game status register |
| `0x4000_0100 - 0x4000_01FF` | Future game grid/framebuffer window |

## Run Simulation

From a fresh clone:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

cd sim/cocotb
make
```

The test verifies that the CPU fetches instructions from RAM, reads GPIO switch
MMIO, and writes GPIO LED MMIO.

Expected result:

```text
TESTS=1 PASS=1 FAIL=0
```

## Regenerate Program Hex

```sh
python3 programs/led_switch_demo.py
```

The checked-in `programs/led_switch_demo.hex` is intentionally tiny and
reproducible from the Python generator.

## Build Bare-Metal C Firmware

```sh
cd programs/c_demo
make
```

This produces `firmware.elf`, `firmware.bin`, and `firmware.hex` using:

```text
-march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -nostartfiles
```

Run the C firmware in cocotb:

```sh
cd ../..
cd sim/cocotb
make COCOTB_TEST_MODULES=test_v04_firmware_gpio RAM_HEX=../../programs/c_demo/firmware.hex RAM_INIT_WORDS=256
```

## Build Bitstream

From the repository root:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

The script targets the common PYNQ-Z2 part `xc7z020clg400-1`. Confirm the part
number for your board revision if Vivado reports a mismatch.

To bake the GCC-built C firmware into the RAM image:

```sh
cd programs/c_demo
make

cd ../..
TINYCPU_RAM_HEX=programs/c_demo/firmware.hex TINYCPU_RAM_INIT_WORDS=256 \
    vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Expected bitstream path:

```text
build/vivado/tinycpu_pynq_v0_4_fuller_rv32i_c_support/tinycpu_pynq_v0_4_fuller_rv32i_c_support.runs/impl_1/pynqz2_top.bit
```

## Run On PYNQ-Z2

Program the generated bitstream with Vivado Hardware Manager. After programming:

- Hold `BTN0` high to reset the SoC.
- Release `BTN0`.
- Toggle `SW[1:0]`.
- `LED[1:0]` should follow `SW[1:0]` through CPU-executed MMIO loads/stores.

This stage uses only FPGA PL logic. It does not use Zynq PS, DDR, or AXI from
the processing system.

## Documentation

- `docs/architecture.md`
- `docs/memory_map.md`
- `docs/instruction_set.md`
- `docs/baremetal_c.md`
- `docs/pipeline.md`
- `docs/pynqz2_bringup.md`
- `docs/jupyter_tetris_plan.md`
- `docs/roadmap.md`

## GitHub Upload Checklist

Before pushing, the repository should contain only source-first files:

```text
AGENTS.md
LICENSE
NOTICE.md
README.md
docs/
fpga/vivado/
programs/
requirements.txt
rtl/
sim/cocotb/
```

Do not upload local virtual environments, Vivado generated projects, waveform
files, private reference material, or local build logs. `.gitignore` is set up
to exclude those artifacts.

## License

MIT. See `LICENSE`.
