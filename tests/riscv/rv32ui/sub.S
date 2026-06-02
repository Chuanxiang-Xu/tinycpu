#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 50
    li x2, 8
    sub x3, x1, x2
    CHECK_EQ x3, 42, 2

    sub x4, x2, x1
    CHECK_EQ x4, -42, 3
    TEST_PASS
