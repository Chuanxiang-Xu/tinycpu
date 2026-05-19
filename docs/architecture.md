# Architecture

`v0.5-rv32im-m-extension` is a source-first, clean-room educational RV32IM SoC
for the PYNQ-Z2 FPGA board.

```text
PYNQ-Z2 pins
  -> pynqz2_top
      -> tinycpu_soc
          -> tinycpu_core_rv32im_axil
          -> axil_interconnect
              -> axil_ram
              -> axil_gpio
```

The CPU target ISA is standard RISC-V RV32IM. The current milestone implements
RV32I plus the standard RV32M multiply/divide extension for simple freestanding
C programs.

The core is stage-structured around IF, ID, EX, MEM, and WB helper modules, but
v0.5 is not a fully overlapped five-stage pipeline. One AXI-Lite master is
shared by instruction fetch and load/store traffic, so the control path
serializes bus operations.

The board wrapper, `pynqz2_top`, connects PYNQ-Z2 pins to the SoC:

- `sysclk` to SoC clock.
- `btn[0]` to active-high reset.
- `sw[1:0]` to GPIO switch input.
- `led[3:0]` to GPIO LED output.

The Vivado project name for this milestone is:

```text
tinycpu_pynq_v0_5_rv32im_m_extension
```

This project is an independent educational implementation. It does not require
private course repositories, generated Vivado project files, or local reference
directories.
