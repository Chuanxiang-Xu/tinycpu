#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    la x10, data_word
    nop
    nop
    nop
    lhu x11, 0(x10)
    CHECK_EQ x11, 0x3344, 2
    lhu x12, 2(x10)
    CHECK_EQ x12, 0x8011, 3
    TEST_PASS

.align 2
data_word:
    .word 0x80113344
