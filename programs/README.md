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
lives in `programs/c_demo/`, and the RV32IM multiply/divide grid-math demo
lives in `programs/rv32im_demo/`.
