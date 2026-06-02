#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x10, 0x100
    li x2, 0xaa
    nop
    nop
    nop
    sb x2, 1(x10)
    TEST_PASS
