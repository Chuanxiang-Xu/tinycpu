#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x10, 0x100
    li x2, 0xaabb
    nop
    nop
    nop
    sh x2, 2(x10)
    TEST_PASS
