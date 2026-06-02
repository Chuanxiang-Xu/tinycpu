#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
1:
    auipc x1, 0
    la x2, 1b
    nop
    nop
    nop
    bne x1, x2, 2f
    TEST_PASS
2:
    TEST_FAIL 3
