# Simulation

`v0.6-pipeline-bram-loader` work in progress uses cocotb and Icarus Verilog
for lightweight RTL simulation.

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
make -C sim/cocotb test-v06-bram
make -C sim/cocotb test-v06-axil-loader
make -C sim/cocotb test-v06-pipeline-overlap
make -C sim/cocotb test-v06-forwarding
make -C sim/cocotb test-v06-load-use
make -C sim/cocotb test-v06-branch-flush
make -C sim/cocotb test-v06-pipeline
make -C sim/cocotb test-all
```

The default and `test-v03-gpio` targets check the full path:

```text
program in unified BRAM -> tinycpu_core_pipe -> dmem MMIO -> LED
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

The v0.6-specific targets cover the new architecture:

- `test-v06-bram`: byte writes, dual-port reads, and same-cycle port access.
- `test-v06-axil-loader`: AXI-Lite firmware load, boot control, and blocked
  live RAM writes.
- `test-v06-pipeline-overlap`: multiple valid pipeline stages at once.
- `test-v06-forwarding`: EX/MEM, MEM/WB, priority, and store-data forwarding.
- `test-v06-load-use`: load-use stalls for ALU, store address/data, and branch
  compare.
- `test-v06-branch-flush`: taken branch, not-taken branch, JAL, and JALR
  flush behavior.

`test-all` is the CI aggregate for the current v0.6 branch. It runs the GPIO
smoke test, C GPIO firmware test, standalone RV32M mul/div unit test, and the
v0.6 BRAM/loader/pipeline suite. The v0.5 directed and grid firmware targets
remain individually runnable while their expectations are being realigned with
the v0.6 pipeline core.

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
