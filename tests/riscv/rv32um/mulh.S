#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x80000000
    li x2, 2
    mulh x3, x1, x2
    CHECK_EQ x3, -1, 2

    li x4, -7
    li x5, -6
    mulh x6, x4, x5
    CHECK_EQ x6, 0, 3

    li x7, 0x7fffffff
    mulh x8, x7, x7
    CHECK_EQ x8, 0x3fffffff, 4

    li x9, 0xffffffff
    mulh x10, x9, x9
    CHECK_EQ x10, 0, 5

    li x11, 13
    li x12, 11
    mulh x11, x11, x12
    CHECK_EQ x11, 0, 6

    li x13, 33
    li x14, 34
    mulh x0, x13, x14
    CHECK_EQ x0, 0, 7
    TEST_PASS
