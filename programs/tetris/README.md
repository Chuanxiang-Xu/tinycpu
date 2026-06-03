# TinyTetris Demo

This is a small bare-metal C application for the v0.9 generic Jupyter
interactive I/O layer. Jupyter writes `HOST_INPUT`; tinycpu polls it, updates
the game state, writes app status/value registers, and draws the 10x20
framebuffer.

The game uses the seven standard tetromino families, 4x4 shape masks, a
seven-bag piece source, clockwise rotation with simple wall kicks, ghost
projection, line clearing, level-based gravity, score/line mirrors, next/hold
metadata, pause, restart, soft drop, and hard drop. It is still intentionally
small and deterministic for an educational FPGA demo rather than a full desktop
Tetris clone.

Build:

```sh
make -C programs/tetris
```

Generated firmware outputs are ignored and should not be committed.
