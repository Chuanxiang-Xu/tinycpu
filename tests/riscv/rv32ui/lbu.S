#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    la x10, data_word
    nop
    nop
    nop
    lbu x11, 0(x10)
    CHECK_EQ x11, 0x44, 2
    lbu x12, 3(x10)
    CHECK_EQ x12, 0x80, 3
    TEST_PASS

.align 2
data_word:
    .word 0x80112244
