#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -1
    sltiu x2, x1, 1
    CHECK_EQ x2, 0, 2
    sltiu x3, x0, 1
    CHECK_EQ x3, 1, 3
    TEST_PASS
