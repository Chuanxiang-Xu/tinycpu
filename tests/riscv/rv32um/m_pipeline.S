#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 6
    li x2, 7
    li x3, 5

    mul x13, x1, x2
    nop
    nop
    nop
    add x6, x13, x3
    CHECK_EQ x6, 47, 2

    la x10, scratch
    div x7, x13, x1
    nop
    nop
    nop
    sw x7, 0(x10)
    lw x8, 0(x10)
    CHECK_EQ x8, 7, 3

    mul x9, x0, x2
    nop
    nop
    nop
    beq x9, x0, zero_mul_ok
    TEST_FAIL 4
zero_mul_ok:
    mul x11, x1, x2
    mul x12, x2, x3
    CHECK_EQ x11, 42, 5
    CHECK_EQ x12, 35, 6
    TEST_PASS

.align 2
scratch:
    .word 0
