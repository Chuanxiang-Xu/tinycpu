#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x10, 0x100
    li x1, 0x778
    nop
    nop
    nop
    sw x1, 0(x10)
    TEST_PASS
