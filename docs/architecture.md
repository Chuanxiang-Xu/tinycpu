# Architecture

v0.4-fuller-rv32i-c-support is a source-first PYNQ-Z2 SoC.

```text
tinycpu_core_rv32im_axil
    -> axil_interconnect
        -> axil_ram
        -> axil_gpio
```

The CPU target ISA is standard RISC-V RV32IM. The current milestone implements
fuller RV32I support for simple freestanding C and keeps RV32M planned for the
next CPU milestone.

The board wrapper, `pynqz2_top`, only connects PYNQ-Z2 pins to the SoC:

- `sysclk` to SoC clock
- `btn[0]` to active-high reset
- `sw[1:0]` to GPIO switch input
- `led[3:0]` to GPIO LED output

This project is an independent educational implementation. It does not require
private course repositories or generated Vivado project files.
