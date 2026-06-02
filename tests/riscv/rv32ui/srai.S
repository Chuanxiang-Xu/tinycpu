#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, -16
    srai x2, x1, 4
    CHECK_EQ x2, -1, 2
    TEST_PASS
