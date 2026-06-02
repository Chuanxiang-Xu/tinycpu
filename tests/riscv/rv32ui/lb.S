#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    la x10, data_word
    nop
    nop
    nop
    lb x11, 0(x10)
    CHECK_EQ x11, 0x44, 2
    lb x12, 3(x10)
    CHECK_EQ x12, -128, 3

    la x13, data_end
    lb x14, -2(x13)
    CHECK_EQ x14, 0x11, 4

    la x15, data_word
    addi x15, x15, -5
    lb x16, 6(x15)
    CHECK_EQ x16, 0x22, 5

    lb x17, 0(x10)
    li x17, 2
    CHECK_EQ x17, 2, 6
    TEST_PASS

.align 2
data_word:
    .word 0x80112244
data_end:
