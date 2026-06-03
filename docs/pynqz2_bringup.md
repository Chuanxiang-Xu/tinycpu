# PYNQ-Z2 Bring-Up

This is the board-level entry point for the current
`v0.9-jupyter-interactive-io-tetris-demo` milestone. There are three useful
hardware flows:

| Flow | Purpose | Build script |
| --- | --- | --- |
| Pin smoke | Check PYNQ-Z2 constraints, cable, clock, buttons, switches, and LEDs. | `fpga/vivado/build_pin_smoke.tcl` |
| Pure PL preloaded demo | Run tinycpu from BRAM initialized at bitstream build time. | `fpga/vivado/build_bitstream.tcl` |
| PYNQ/Jupyter AXI overlay | Let Jupyter load firmware, write input, and read app/framebuffer mirrors. | `fpga/vivado/build_pynq_axi_overlay.tcl` |

Generated Vivado projects, bitstreams, `.hwh` files, and logs are ignored and
should not be committed.

## 1. Pin Smoke

Use this first on a new board or after changing constraints:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pin_smoke.tcl
```

Expected bitstream:

```text
build/vivado/tinycpu_pynq_pin_smoke/tinycpu_pynq_pin_smoke.runs/impl_1/pynqz2_pin_smoke_top.bit
```

Expected behavior:

| Board IO | Behavior |
| --- | --- |
| `LED0` | follows `SW0` |
| `LED1` | follows `SW1` |
| `LED2` | follows `BTN0` |
| `LED3` | blinks from the PL clock |

If this fails, debug board selection, cable, constraints, or programming before
debugging the CPU.

## 2. Pure PL Preloaded Demo

This flow does not use the Zynq PS AXI master. Firmware is preloaded into the
64 KiB unified BRAM while building the bitstream.

Build the default checked-in assembly demo:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Expected bitstream:

```text
build/vivado/tinycpu_pynq_v0_6_pipeline_bram_loader/tinycpu_pynq_v0_6_pipeline_bram_loader.runs/impl_1/pynqz2_top.bit
```

Build with C GPIO firmware instead:

```sh
make -C programs/c_demo

source ~/vivado/2025.2/Vivado/settings64.sh
TINYCPU_RAM_HEX=programs/c_demo/firmware.hex TINYCPU_RAM_INIT_WORDS=256 \
    vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

Expected behavior:

- Hold `BTN0` high to reset the SoC.
- Release `BTN0`.
- `LED[1:0]` follows `SW[1:0]` through CPU-executed MMIO code.

## 3. PYNQ/Jupyter AXI Overlay

This is the current board flow for `notebooks/`. The Vivado block design
connects Zynq PS `M_AXI_GP0` through an AXI interconnect to the tinycpu
AXI-Lite loader/control slave.

Build the overlay:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
```

Expected outputs:

```text
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.runs/impl_1/tinycpu_pynq_system_wrapper.bit
build/vivado/tinycpu_pynq_v0_9_jupyter_axi_overlay/tinycpu_pynq_v0_9_jupyter_axi_overlay.gen/sources_1/bd/tinycpu_pynq_system/hw_handoff/tinycpu_pynq_system.hwh
```

The loader/control slave is mapped at PS address `0x43C0_0000`. PYNQ discovers
that base address from the `.hwh`; notebook helpers use offsets relative to the
loader base.

Build demo firmware before copying files to the board:

```sh
make -C programs/interactive_demo
make -C programs/framebuffer_demo
make -C programs/tetris
```

Copy these files/directories to the PYNQ-Z2:

```text
tinycpu.bit
tinycpu.hwh
notebooks/
programs/interactive_demo/firmware.hex
programs/framebuffer_demo/firmware.hex
programs/tetris/firmware.hex
```

Rename the generated bitstream and `.hwh` with matching stems before opening
the notebooks:

```text
tinycpu_pynq_system_wrapper.bit -> tinycpu.bit
tinycpu_pynq_system.hwh         -> tinycpu.hwh
```

Run notebooks in this order:

1. `notebooks/interactive_io_demo.ipynb`
2. `notebooks/framebuffer_demo.ipynb`
3. `notebooks/tetris_demo.ipynb`

The interactive I/O notebook is the best first hardware check because it
verifies firmware loading, host input writes, CPU app output writes, and
framebuffer mirror reads.

## Programming Notes

- Use Vivado Hardware Manager for the pure PL bitstreams.
- Use PYNQ `Overlay("tinycpu.bit")` for the Jupyter AXI overlay so the matching
  `.hwh` is parsed and `overlay.ip_dict` contains the loader IP metadata.
- If automatic loader discovery picks the wrong IP, set `LOADER_IP_NAME` or
  `preferred_name` in the notebook.
- If firmware loading fails, reset or halt the CPU before calling `load_hex()`.
