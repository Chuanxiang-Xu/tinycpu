.ifndef TINYCPU_TEST_MACROS_S
.set TINYCPU_TEST_MACROS_S, 1

.equ MMIO_TEST_STATUS, 0x10000FF0
.equ MMIO_TEST_CODE,   0x10000FF4

.macro TEST_PASS
    li t0, MMIO_TEST_STATUS
    li t1, 1
    sw t1, 0(t0)
.L_test_pass_\@:
    j .L_test_pass_\@
.endm

.macro TEST_FAIL id
    li t0, MMIO_TEST_CODE
    li t1, \id
    sw t1, 0(t0)
    li t0, MMIO_TEST_STATUS
    li t1, \id
    sw t1, 0(t0)
.L_test_fail_\@:
    j .L_test_fail_\@
.endm

.macro CHECK_EQ reg, expected, fail_id
    li t5, \expected
    bne \reg, t5, .L_check_eq_fail_\@
    j .L_check_eq_done_\@
.L_check_eq_fail_\@:
    TEST_FAIL \fail_id
.L_check_eq_done_\@:
.endm

.macro CHECK_REG expected, reg, fail_id
    CHECK_EQ \reg, \expected, \fail_id
.endm

.macro CHECK_NE reg, expected, fail_id
    li t5, \expected
    beq \reg, t5, .L_check_ne_fail_\@
    j .L_check_ne_done_\@
.L_check_ne_fail_\@:
    TEST_FAIL \fail_id
.L_check_ne_done_\@:
.endm

.endif
