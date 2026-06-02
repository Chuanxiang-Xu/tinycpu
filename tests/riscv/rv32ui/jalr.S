#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    la x5, jalr_target
    addi x5, x5, 1
    jalr x1, 0(x5)
jalr_link:
    TEST_FAIL 2
jalr_target:
    la x2, jalr_link
    nop
    nop
    nop
    bne x1, x2, 2f
    TEST_PASS
2:
    TEST_FAIL 3
