#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 7
    li x2, 6
    mul x3, x1, x2
    CHECK_EQ x3, 42, 2

    li x4, -7
    mul x5, x4, x2
    CHECK_EQ x5, -42, 3

    add x6, x3, x1
    CHECK_EQ x6, 49, 4

    li x7, -1
    mul x8, x7, x7
    CHECK_EQ x8, 1, 5

    li x9, 13
    li x10, 11
    mul x9, x9, x10
    CHECK_EQ x9, 143, 6

    li x11, 14
    li x12, 11
    mul x12, x11, x12
    CHECK_EQ x12, 154, 7

    li x13, 33
    li x14, 34
    mul x0, x13, x14
    CHECK_EQ x0, 0, 8
    TEST_PASS
