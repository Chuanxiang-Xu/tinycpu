#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    jal x1, jal_target
jal_link:
    TEST_FAIL 2
jal_target:
    la x2, jal_link
    nop
    nop
    nop
    bne x1, x2, 2f
    li x3, 5
    jal x0, jal_skip
    li x3, 9
jal_skip:
    CHECK_EQ x3, 5, 3
    TEST_PASS
2:
    TEST_FAIL 4
