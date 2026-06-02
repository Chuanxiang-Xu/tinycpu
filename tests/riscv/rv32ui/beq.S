#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 7
    li x2, 7
    beq x1, x2, beq_taken
    TEST_FAIL 2
beq_taken:
    li x3, 1
    beq x1, x0, beq_not_taken
    addi x3, x3, 1
beq_not_taken:
    CHECK_EQ x3, 2, 3

    li x4, -1
    li x5, -1
    beq x4, x5, beq_negative_taken
    TEST_FAIL 4
beq_negative_taken:
    li x6, 1
    beq x0, x0, beq_flush_ok
    addi x6, x6, 1
    addi x6, x6, 1
beq_flush_ok:
    addi x6, x6, 1
    CHECK_EQ x6, 2, 5

    li x7, 3
beq_backward_loop:
    addi x7, x7, -1
    beq x7, x0, beq_backward_done
    beq x0, x0, beq_backward_loop
    TEST_FAIL 6
beq_backward_done:
    CHECK_EQ x7, 0, 7
    TEST_PASS
