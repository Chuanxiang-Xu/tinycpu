#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x500
    ori x2, x1, 0x0aa
    CHECK_EQ x2, 0x5aa, 2
    TEST_PASS
