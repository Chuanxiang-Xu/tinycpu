#include "../env/tinycpu_test_macros.S"

.section .text
.globl test_main
test_main:
    lui x1, 0x12345
    CHECK_EQ x1, 0x12345000, 2
    TEST_PASS
