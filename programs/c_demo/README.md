# C Demo Firmware

This directory builds the v0.4 freestanding C demo for tinycpu.

The default tool prefix is `riscv64-unknown-elf`, which is the common multilib
prefix from riscv-gnu-toolchain. A `riscv32-unknown-elf` toolchain can be used
by overriding `CROSS`.

Build:

```sh
make
make CROSS=riscv32-unknown-elf
```

The important v0.4 flags are:

```sh
-march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -nostartfiles
```

Do not use `-march=rv32im` until the M extension is wired into the execute
stage. Do not use compressed instructions, libc, `printf`, `malloc`, or OS
syscalls in v0.4.

Outputs:

- `firmware.elf`
- `firmware.bin`
- `firmware.hex`

`startup.S` uses standard assembler register aliases and pseudoinstructions:

- `sp` for stack pointer `x2`
- `t0` and `t1` for temporary registers `x5` and `x6`
- `zero` for hardwired-zero register `x0`
- `la` to materialize linker symbols
- `call main` for the C entry point
- `j label` for unconditional local loops

The C demo reads the switch MMIO register at `0x40000004` and writes the LED
MMIO register at `0x40000000`.

References:

- UPenn RV32IM ISA Reference Sheet for instruction encodings.
- Project F RISC-V Assembler Cheat Sheet for ABI names and pseudoinstructions.
- riscv-gnu-toolchain for the `riscv64-unknown-elf` workflow.
