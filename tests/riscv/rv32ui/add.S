#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 20
    li x2, 22
    add x3, x1, x2
    CHECK_EQ x3, 42, 2

    add x4, x3, x2
    CHECK_EQ x4, 64, 3

    li x5, 0x7fffffff
    li x6, 1
    add x7, x5, x6
    CHECK_EQ x7, 0x80000000, 4

    li x8, -1
    add x9, x8, x6
    CHECK_EQ x9, 0, 5

    li x10, 13
    li x11, 11
    add x10, x10, x11
    CHECK_EQ x10, 24, 6

    li x12, 14
    add x11, x12, x11
    CHECK_EQ x11, 25, 7

    li x13, 30
    li x14, 16
    add x0, x13, x14
    CHECK_EQ x0, 0, 8
    TEST_PASS
