#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 10
    addi x2, x1, 5
    CHECK_EQ x2, 15, 2

    addi x3, x2, -20
    CHECK_EQ x3, -5, 3

    li x4, 0x7fffffff
    addi x5, x4, 1
    CHECK_EQ x5, 0x80000000, 4

    li x6, 0
    addi x7, x6, -1
    CHECK_EQ x7, -1, 5

    li x8, 13
    addi x8, x8, 11
    CHECK_EQ x8, 24, 6

    addi x9, x0, 32
    CHECK_EQ x9, 32, 7

    li x10, 50
    addi x0, x10, 33
    CHECK_EQ x0, 0, 8
    TEST_PASS
