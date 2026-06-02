#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 0x57f
    andi x2, x1, 0x0f0
    CHECK_EQ x2, 0x070, 2
    TEST_PASS
