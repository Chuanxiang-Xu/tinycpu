#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    la x10, data_word
    nop
    nop
    nop
    lw x5, 0(x10)
    add x6, x5, x5
    CHECK_EQ x5, 0x11223344, 2
    CHECK_EQ x6, 0x22446688, 3
    TEST_PASS

.align 2
data_word:
    .word 0x11223344
