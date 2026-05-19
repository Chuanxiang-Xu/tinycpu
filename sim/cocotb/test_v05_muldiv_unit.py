import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


MASK32 = 0xFFFF_FFFF


def u32(value):
    return value & MASK32


def s32(value):
    value &= MASK32
    return value - (1 << 32) if value & (1 << 31) else value


def rv32m_expected(op, rs1, rs2):
    rs1 = u32(rs1)
    rs2 = u32(rs2)

    if op == 0:
        return u32(rs1 * rs2)
    if op == 1:
        return u32((s32(rs1) * s32(rs2)) >> 32)
    if op == 2:
        return u32((s32(rs1) * rs2) >> 32)
    if op == 3:
        return u32((rs1 * rs2) >> 32)
    if op == 4:
        if rs2 == 0:
            return MASK32
        if rs1 == 0x8000_0000 and rs2 == MASK32:
            return 0x8000_0000
        return u32(int(s32(rs1) / s32(rs2)))
    if op == 5:
        return MASK32 if rs2 == 0 else u32(rs1 // rs2)
    if op == 6:
        if rs2 == 0:
            return rs1
        if rs1 == 0x8000_0000 and rs2 == MASK32:
            return 0
        quotient = int(s32(rs1) / s32(rs2))
        return u32(s32(rs1) - quotient * s32(rs2))
    if op == 7:
        return rs1 if rs2 == 0 else u32(rs1 % rs2)
    raise ValueError(op)


async def reset_unit(dut):
    dut.rst.value = 1
    dut.start.value = 0
    dut.op.value = 0
    dut.rs1.value = 0
    dut.rs2.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


async def run_case(dut, op, rs1, rs2):
    dut.op.value = op
    dut.rs1.value = u32(rs1)
    dut.rs2.value = u32(rs2)
    dut.start.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    saw_busy = bool(dut.busy.value)
    dut.start.value = 0

    for _ in range(40):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        saw_busy = saw_busy or bool(dut.busy.value)
        if int(dut.done.value):
            expected = rv32m_expected(op, rs1, rs2)
            actual = int(dut.result.value)
            assert actual == expected, (
                f"op={op} rs1=0x{u32(rs1):08x} rs2=0x{u32(rs2):08x} "
                f"expected=0x{expected:08x} actual=0x{actual:08x}"
            )
            assert saw_busy
            return

    raise AssertionError(f"muldiv op {op} did not finish")


@cocotb.test()
async def test_rv32m_mul_div_rem_operations(dut):
    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_unit(dut)

    cases = [
        (0, 0x12345678, 0x00000123),
        (1, 0xFFFF_FFFE, 0x0000_0007),
        (2, 0xFFFF_FFFE, 0x8000_0000),
        (3, 0xFFFF_FFFF, 0xFFFF_FFFE),
        (4, 0xFFFF_FFF1, 0x0000_0004),
        (5, 0xFFFF_FFF1, 0x0000_0004),
        (6, 0xFFFF_FFF1, 0x0000_0004),
        (7, 0xFFFF_FFF1, 0x0000_0004),
        (4, 0x1234_5678, 0x0000_0000),
        (6, 0x1234_5678, 0x0000_0000),
        (4, 0x8000_0000, 0xFFFF_FFFF),
        (6, 0x8000_0000, 0xFFFF_FFFF),
    ]

    for case in cases:
        await run_case(dut, *case)
