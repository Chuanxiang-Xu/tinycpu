#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x5, 1
    li x6, 2
    add x7, x5, x6
    CHECK_EQ x7, 3, 2
    TEST_PASS
