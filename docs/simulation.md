# Simulation

v0.5-rv32im-m-extension uses cocotb and Icarus Verilog for lightweight RTL
simulation.

Setup:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
sudo apt install -y iverilog
```

Run:

```sh
cd sim/cocotb
make
```

The test checks the full path:

```text
program in RAM -> tinycpu_core_rv32im_axil -> AXI-Lite GPIO -> LED
```

To run the bare-metal C demo, first build the firmware with a RISC-V GNU
toolchain:

```sh
cd programs/c_demo
make

cd ../../sim/cocotb
make COCOTB_TEST_MODULES=test_v04_firmware_gpio RAM_HEX=../../programs/c_demo/firmware.hex RAM_INIT_WORDS=256
```

Run the RV32M unit test:

```sh
cd sim/cocotb
make TOPLEVEL=tinycpu_muldiv COCOTB_TEST_MODULES=test_v05_muldiv_unit
```

Run the RV32IM grid-math firmware test:

```sh
cd programs/rv32im_demo
make

cd ../../sim/cocotb
make COCOTB_TEST_MODULES=test_v05_tetris_grid_math RAM_HEX=../../programs/rv32im_demo/firmware.hex RAM_INIT_WORDS=256
```
