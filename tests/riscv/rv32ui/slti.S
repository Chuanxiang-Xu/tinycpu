#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -1
    slti x2, x1, 1
    CHECK_EQ x2, 1, 2
    slti x3, x1, -2
    CHECK_EQ x3, 0, 3
    TEST_PASS
