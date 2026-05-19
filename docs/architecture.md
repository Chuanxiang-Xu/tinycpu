# Architecture

v0.5-rv32im-m-extension is a source-first PYNQ-Z2 SoC.

```text
tinycpu_core_rv32im_axil
    -> axil_interconnect
        -> axil_ram
        -> axil_gpio
```

The CPU target ISA is standard RISC-V RV32IM. The current milestone implements
fuller RV32I support plus the standard RV32M multiply/divide extension for
simple freestanding C compiled with `-march=rv32im -mabi=ilp32`.

The board wrapper, `pynqz2_top`, only connects PYNQ-Z2 pins to the SoC:

- `sysclk` to SoC clock
- `btn[0]` to active-high reset
- `sw[1:0]` to GPIO switch input
- `led[3:0]` to GPIO LED output

This project is an independent educational implementation. It does not require
private course repositories or generated Vivado project files.
