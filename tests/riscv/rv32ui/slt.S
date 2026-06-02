#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -1
    li x2, 1
    slt x3, x1, x2
    CHECK_EQ x3, 1, 2
    slt x4, x2, x1
    CHECK_EQ x4, 0, 3
    TEST_PASS
