# Programs

`led_switch_demo.hex` is loaded into the unified 64 KiB BRAM at address
`0x0000_0000`. It contains standard 32-bit RISC-V instructions from the RV32I
ISA.

The demo implements:

```c
while (1) {
    *(volatile uint32_t *)0x10000000 =
        *(volatile uint32_t *)0x10000004;
}
```

Regenerate the hex file with:

```sh
python3 programs/led_switch_demo.py
```

`led_switch_demo.S` is the human-readable assembly source. The C firmware flow
lives in `programs/c_demo/`, the RV32IM multiply/divide grid-math demo lives
in `programs/rv32im_demo/`, the framebuffer display demo lives in
`programs/framebuffer_demo/`, the generic interactive I/O smoke demo lives in
`programs/interactive_demo/`, and TinyTetris lives in `programs/tetris/`.

Shared bare-metal support for newer demos lives in `programs/common/`:

- `crt0.S`: reset entry, stack setup, and BSS clearing.
- `linker.ld`: 64 KiB BRAM memory layout.
- `tinycpu_mmio.h`: CPU-side MMIO register definitions.
- `makehex.py`: binary-to-hex conversion helper.

Build the framebuffer demo with:

```sh
make -C programs/framebuffer_demo
```

Build the interactive I/O and TinyTetris demos with:

```sh
make -C programs/interactive_demo
make -C programs/tetris
```

The generated firmware outputs are ignored and should not be committed.
