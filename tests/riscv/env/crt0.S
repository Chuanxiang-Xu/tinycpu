.section .text.start, "ax", @progbits
.globl _start
_start:
    la sp, __stack_top
    call test_main

    /* Returning from a test body is considered success. */
    li t0, 0x10000FF0
    li t1, 1
    sw t1, 0(t0)
1:
    j 1b
