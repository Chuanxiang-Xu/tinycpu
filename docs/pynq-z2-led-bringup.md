# PYNQ-Z2 LED Bring-Up

The pure PL LED bring-up path uses the preloaded tinycpu bitstream. The LED
behavior is driven by a standard RISC-V program running from unified BRAM, not
by direct switch-to-LED wiring.

Build:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Expected behavior after programming the board:

- `BTN0` resets the SoC.
- `SW[1:0]` is read by the CPU through dmem MMIO at `0x1000_0004`.
- `LED[1:0]` is written by the CPU through dmem MMIO at `0x1000_0000`.

For the full flow, see `docs/pynqz2_bringup.md`.
