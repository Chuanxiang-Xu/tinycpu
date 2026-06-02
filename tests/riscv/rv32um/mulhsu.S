#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -2
    li x2, 3
    mulhsu x3, x1, x2
    CHECK_EQ x3, -1, 2

    li x4, 0x40000000
    li x5, 4
    mulhsu x6, x4, x5
    CHECK_EQ x6, 1, 3

    li x7, 0x80000000
    li x8, 2
    mulhsu x9, x7, x8
    CHECK_EQ x9, -1, 4

    li x10, -1
    li x11, 0xffffffff
    mulhsu x12, x10, x11
    CHECK_EQ x12, -1, 5

    li x13, 13
    li x14, 11
    mulhsu x13, x13, x14
    CHECK_EQ x13, 0, 6
    TEST_PASS
