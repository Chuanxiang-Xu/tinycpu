# Bare-Metal C

tinycpu v0.5 supports simple freestanding C programs for the implemented
RV32I/RV32M instruction set.

## Toolchain

The default Makefile prefix is:

```make
CROSS ?= riscv64-unknown-elf
CC      := $(CROSS)-gcc
OBJCOPY := $(CROSS)-objcopy
OBJDUMP := $(CROSS)-objdump
```

The `riscv64-unknown-elf` multilib toolchain can emit 32-bit code when passed
the RV32 flags. A `riscv32-unknown-elf` toolchain can also be used:

```sh
make -C programs/c_demo CROSS=riscv32-unknown-elf
```

Required freestanding/link flags:

```text
-ffreestanding -nostdlib -nostartfiles
```

Do not use these in v0.5 firmware:

- Compressed instructions.
- libc.
- `printf`.
- `malloc`.
- OS syscalls.

## Basic RV32I GPIO Demo

`programs/c_demo/` is the basic bare-metal C GPIO demo:

- `startup.S`
- `linker.ld`
- `main.c`
- `Makefile`
- generated `firmware.elf`
- generated `firmware.bin`
- generated `firmware.hex`

It defaults to:

```text
-march=rv32i -mabi=ilp32
```

Build it with:

```sh
make -C programs/c_demo
```

## RV32IM Demo

`programs/rv32im_demo/` exercises operations that lower to M-extension
instructions, including `row * 10 + col`, `% 7`, signed division, and signed
remainder.

It defaults to:

```text
-march=rv32im -mabi=ilp32
```

Build it with:

```sh
make -C programs/rv32im_demo
```

## Startup

`startup.S` uses standard RISC-V ABI register aliases and assembler
pseudoinstructions:

| Name | Meaning |
| --- | --- |
| `zero` | `x0`, hardwired zero |
| `ra` | `x1`, return address |
| `sp` | `x2`, stack pointer |
| `t0` | `x5`, temporary |
| `t1` | `x6`, temporary |

| Pseudoinstruction | Use |
| --- | --- |
| `la rd, symbol` | Load the address of a linker symbol |
| `call symbol` | Call a function, writing the return address to `ra` |
| `j label` | Unconditional jump |

The startup code sets `sp`, clears `.bss`, calls `main`, and loops forever if
`main` returns.

## References

- UPenn RV32IM ISA Reference Sheet:
  `https://www.seas.upenn.edu/~cis2400/24fa/notes/riscv_ref.pdf`
- Project F RISC-V Assembler Cheat Sheet:
  `https://projectf.io/posts/riscv-cheat-sheet/`
- riscv-gnu-toolchain:
  `https://github.com/riscv-collab/riscv-gnu-toolchain`
