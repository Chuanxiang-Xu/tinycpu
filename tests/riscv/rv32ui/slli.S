#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    li x1, 3
    slli x2, x1, 5
    CHECK_EQ x2, 96, 2
    TEST_PASS
