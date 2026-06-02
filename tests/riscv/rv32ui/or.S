#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x500
    li x2, 0x00aa
    or x3, x1, x2
    CHECK_EQ x3, 0x5aa, 2
    TEST_PASS
