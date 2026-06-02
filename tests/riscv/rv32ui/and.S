#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x5aa
    li x2, 0x0f0
    and x3, x1, x2
    CHECK_EQ x3, 0x0a0, 2
    TEST_PASS
