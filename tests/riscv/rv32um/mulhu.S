#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -1
    li x2, 2
    mulhu x3, x1, x2
    CHECK_EQ x3, 1, 2

    li x4, -1
    mulhu x5, x4, x4
    CHECK_EQ x5, 0xfffffffe, 3

    li x6, 0x80000000
    li x7, 0xffff8000
    mulhu x8, x6, x7
    CHECK_EQ x8, 0x7fffc000, 4

    li x9, 13
    li x10, 11
    mulhu x9, x9, x10
    CHECK_EQ x9, 0, 5

    li x11, 33
    li x12, 34
    mulhu x0, x11, x12
    CHECK_EQ x0, 0, 6
    TEST_PASS
