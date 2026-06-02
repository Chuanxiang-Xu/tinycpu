#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x555
    xori x2, x1, 0x0ff
    CHECK_EQ x2, 0x5aa, 2
    TEST_PASS
