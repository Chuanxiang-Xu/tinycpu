# Architecture

`v0.9-jupyter-interactive-io-tetris-demo` is a source-first, clean-room
educational RV32IM SoC for the PYNQ-Z2 FPGA board.

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

The CPU target ISA is standard RISC-V RV32IM. The current milestone carries
RV32I plus the standard RV32M multiply/divide extension into an educational
overlapped pipeline.

The core uses IF, ID, EX, MEM, and WB pipeline registers with valid bits,
forwarding hooks, load-use stall policy, and branch flush policy. AXI-Lite is
no longer mixed into the CPU core; the pipeline uses simple Harvard-style
instruction and data memory ports.

Physical RAM is a unified 64 KiB memory. Port A is used for instruction fetch.
Port B is selected between CPU data RAM access and the AXI-Lite loader while
the CPU is halted or reset. CPU-side loads and stores outside BRAM are handled
by the dmem MMIO decoder.

For teaching, keep these two address spaces separate:

- CPU-side addresses are what RISC-V programs use: BRAM at `0x0000_0000` and
  dmem MMIO at `0x1000_0000`.
- Loader-side offsets are what the PS/Jupyter host uses through the AXI-Lite
  loader/control slave in the `build_pynq_axi_overlay.tcl` overlay.

The loader/control slave also exposes read-only mirrors of CPU-written
`TEST_STATUS` and `TEST_CODE` registers so a PS/Jupyter host can load a
program, start the CPU, and poll a small pass/fail result without pretending to
access the CPU-side `0x1000_xxxx` MMIO page directly.

For `v0.9-jupyter-interactive-io-tetris-demo`, the same mirror pattern is
extended to generic app I/O: Jupyter writes `HOST_INPUT` at loader offset
`0x10030`, while the CPU polls `HOST_INPUT` at `0x1000_0010` and writes
`APP_STATUS`, `APP_VALUE0`, `APP_VALUE1`, `FRAME_COUNTER`, and a packed
framebuffer. The CPU continues to use only its dmem MMIO page.

The pure PL board wrapper, `pynqz2_top`, connects PYNQ-Z2 pins to the SoC:

- `sysclk` to SoC clock.
- `btn[0]` to active-high reset.
- `sw[1:0]` to GPIO switch input.
- `led[3:0]` to GPIO LED output.

The Jupyter overlay wrapper, `tinycpu_pynq_axi_overlay`, is used as a Vivado
block-design module reference. The Zynq PS provides `FCLK_CLK0`,
`FCLK_RESET0_N`, and `M_AXI_GP0`; an AXI interconnect maps the loader/control
slave at PS address `0x43C0_0000`. PL `btn[0]` remains an active-high local
reset input, while the loader can also reset, halt, load, and start the CPU.

The pure PL Vivado project name is:

```text
tinycpu_pynq_v0_6_pipeline_bram_loader
```

The PYNQ/Jupyter AXI overlay project name is:

```text
tinycpu_pynq_v0_9_jupyter_axi_overlay
```

This project is an independent educational implementation. It does not require
private course repositories, generated Vivado project files, or local reference
directories.
