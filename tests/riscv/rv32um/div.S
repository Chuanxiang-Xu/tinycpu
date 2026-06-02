#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -42
    li x2, 7
    div x3, x1, x2
    CHECK_EQ x3, -6, 2

    li x4, 42
    li x5, 0
    div x6, x4, x5
    CHECK_EQ x6, -1, 3

    li x7, 0x80000000
    li x8, -1
    div x9, x7, x8
    CHECK_EQ x9, 0x80000000, 4

    li x10, 20
    li x11, -6
    div x12, x10, x11
    CHECK_EQ x12, -3, 5

    li x13, -20
    div x14, x13, x11
    CHECK_EQ x14, 3, 6

    li x15, 1
    div x16, x15, x5
    CHECK_EQ x16, -1, 7
    TEST_PASS
