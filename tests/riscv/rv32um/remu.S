#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 43
    li x2, 7
    remu x3, x1, x2
    CHECK_EQ x3, 1, 2

    li x4, 42
    li x5, 0
    remu x6, x4, x5
    CHECK_EQ x6, 42, 3

    li x7, -20
    li x8, 6
    remu x9, x7, x8
    CHECK_EQ x9, 2, 4

    li x10, 20
    li x11, -6
    remu x12, x10, x11
    CHECK_EQ x12, 20, 5

    li x13, 0x80000000
    li x14, 0
    remu x15, x13, x14
    CHECK_EQ x15, 0x80000000, 6
    TEST_PASS
