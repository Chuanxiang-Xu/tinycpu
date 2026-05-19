# Simulation

`v0.5-rv32im-m-extension` uses cocotb and Icarus Verilog for lightweight RTL
simulation.

## Setup

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
sudo apt install -y iverilog
```

Firmware-backed tests also require a RISC-V bare-metal GNU toolchain such as
`riscv64-unknown-elf-gcc`.

## Test Targets

Run the default smoke test:

```sh
make -C sim/cocotb
```

Run named tests:

```sh
make -C sim/cocotb test-v03-gpio
make -C sim/cocotb test-v04-firmware-gpio
make -C sim/cocotb test-v05-muldiv
make -C sim/cocotb test-v05-rv32i-directed
make -C sim/cocotb test-v05-branch-load-store
make -C sim/cocotb test-v05-rv32im-grid
make -C sim/cocotb test-all
```

The default and `test-v03-gpio` targets check the full path:

```text
program in RAM -> tinycpu_core_rv32im_axil -> AXI-Lite GPIO -> LED
```

`test-v04-firmware-gpio` builds and runs the basic RV32I C GPIO firmware:

```sh
make -C programs/c_demo
make -C sim/cocotb test-v04-firmware-gpio
```

`test-v05-muldiv` runs the standalone RV32M multiply/divide unit test:

```sh
make -C sim/cocotb test-v05-muldiv
```

`test-v05-rv32i-directed` generates a temporary RAM hex file and runs directed
RV32I ALU, immediate, jump, and `x0` checks:

```sh
make -C sim/cocotb test-v05-rv32i-directed
```

`test-v05-branch-load-store` generates a temporary RAM hex file and runs branch
direction plus byte/halfword load-store checks:

```sh
make -C sim/cocotb test-v05-branch-load-store
```

`test-v05-rv32im-grid` builds and runs the RV32IM grid math firmware:

```sh
make -C programs/rv32im_demo
make -C sim/cocotb test-v05-rv32im-grid
```

## Generated Outputs

cocotb and firmware outputs are generated artifacts and should stay out of
version control:

```text
sim_build/
results.xml
programs/c_demo/firmware.elf
programs/c_demo/firmware.bin
programs/c_demo/firmware.hex
programs/rv32im_demo/firmware.elf
programs/rv32im_demo/firmware.bin
programs/rv32im_demo/firmware.hex
```
