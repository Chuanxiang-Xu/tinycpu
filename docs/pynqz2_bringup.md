# PYNQ-Z2 Bring-Up

Build the bitstream from the repository root:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

To build the board image with the GCC C firmware instead of the checked-in
assembly demo:

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

Runtime behavior:

- Hold `BTN0` high to reset the SoC.
- Release `BTN0`.
- `LED[1:0]` follows `SW[1:0]` through CPU-executed RV32I MMIO loads/stores.

There is no Zynq PS, DDR, or AXI bridge in this stage.
