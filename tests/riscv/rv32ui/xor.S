#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x5aa
    li x2, 0x0f0
    xor x3, x1, x2
    CHECK_EQ x3, 0x55a, 2
    TEST_PASS
