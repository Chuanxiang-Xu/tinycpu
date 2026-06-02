#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -16
    li x2, 4
    sra x3, x1, x2
    CHECK_EQ x3, -1, 2
    TEST_PASS
