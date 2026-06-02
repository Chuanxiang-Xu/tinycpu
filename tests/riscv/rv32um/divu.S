#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 42
    li x2, 5
    divu x3, x1, x2
    CHECK_EQ x3, 8, 2

    li x4, 42
    li x5, 0
    divu x6, x4, x5
    CHECK_EQ x6, -1, 3

    li x7, -20
    li x8, 6
    divu x9, x7, x8
    CHECK_EQ x9, 715827879, 4

    li x10, 0x80000000
    li x11, 1
    divu x12, x10, x11
    CHECK_EQ x12, 0x80000000, 5

    li x13, 0x80000000
    li x14, -1
    divu x15, x13, x14
    CHECK_EQ x15, 0, 6
    TEST_PASS
