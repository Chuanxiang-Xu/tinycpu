#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 7
    li x2, 8
    bne x1, x2, bne_taken
    TEST_FAIL 2
bne_taken:
    li x3, 1
    bne x1, x1, bne_not_taken
    addi x3, x3, 1
bne_not_taken:
    CHECK_EQ x3, 2, 3
    TEST_PASS
