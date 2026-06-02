#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -43
    li x2, 7
    rem x3, x1, x2
    CHECK_EQ x3, -1, 2

    li x4, 42
    li x5, 0
    rem x6, x4, x5
    CHECK_EQ x6, 42, 3

    li x7, 0x80000000
    li x8, -1
    rem x9, x7, x8
    CHECK_EQ x9, 0, 4

    li x10, 20
    li x11, -6
    rem x12, x10, x11
    CHECK_EQ x12, 2, 5

    li x13, -20
    rem x14, x13, x11
    CHECK_EQ x14, -2, 6

    rem x15, x7, x5
    CHECK_EQ x15, 0x80000000, 7

    li x16, 1
    rem x17, x16, x5
    CHECK_EQ x17, 1, 8
    TEST_PASS
