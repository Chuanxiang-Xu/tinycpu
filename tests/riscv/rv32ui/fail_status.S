#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    TEST_FAIL 99
