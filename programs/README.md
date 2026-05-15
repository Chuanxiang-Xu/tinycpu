# Programs

`led_switch_demo.hex` is loaded into AXI-Lite RAM at address `0x0000_0000`.
It contains standard 32-bit RISC-V instructions from the RV32I ISA.

The demo implements:

```c
while (1) {
    *(volatile uint32_t *)0x40000000 =
        *(volatile uint32_t *)0x40000004;
}
```

Regenerate the hex file with:

```sh
python3 programs/led_switch_demo.py
```

`led_switch_demo.S` is the human-readable assembly source. The v0.4 C firmware
flow lives in `programs/c_demo/`.
