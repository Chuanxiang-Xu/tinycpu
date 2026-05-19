# RV32IM C Demo

This demo is built for `-march=rv32im -mabi=ilp32`. It exercises multiply,
divide, and remainder operations that appear naturally in grid-based C code:

- `row * 10 + col`
- `(123 + sw) % 7`
- signed `/` and `%`

Build:

```sh
make -C programs/rv32im_demo
```

Run in cocotb:

```sh
make -C sim/cocotb COCOTB_TEST_MODULES=test_v05_tetris_grid_math \
    RAM_HEX=../../programs/rv32im_demo/firmware.hex RAM_INIT_WORDS=256
```
