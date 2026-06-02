#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -1
    li x2, 1
    bgeu x1, x2, bgeu_taken
    TEST_FAIL 2
bgeu_taken:
    bgeu x2, x1, 2f
    TEST_PASS
2:
    TEST_FAIL 3
