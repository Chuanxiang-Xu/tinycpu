#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 64
    srli x2, x1, 4
    CHECK_EQ x2, 4, 2
    TEST_PASS
