#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 3
    li x2, 5
    sll x3, x1, x2
    CHECK_EQ x3, 96, 2
    TEST_PASS
