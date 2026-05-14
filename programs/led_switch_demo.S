    .section .text
    .globl _start

_start:
    lui   x2, 0x40000        # x2 = 0x4000_0000 GPIO base

loop:
    lw    x1, 4(x2)          # x1 = switch register
    sw    x1, 0(x2)          # LED register = x1
    jal   x0, loop           # repeat forever
