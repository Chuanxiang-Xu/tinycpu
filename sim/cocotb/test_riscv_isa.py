import os

import cocotb

from riscv_test_runner import run_riscv_test


@cocotb.test()
async def test_riscv_isa_program(dut):
    """Run one prebuilt RISC-V ISA-style program and watch MMIO pass/fail."""

    name = os.environ.get("RISCV_TEST_NAME", "unknown")
    timeout = int(os.environ.get("RISCV_TEST_TIMEOUT", "20000"))
    expect_fail = os.environ.get("RISCV_EXPECT_FAIL", "0") == "1"

    result = await run_riscv_test(dut, timeout_cycles=timeout)
    cocotb.log.info(
        "%s wrote status=0x%08x code=%s at cycle=%d pc=0x%08x",
        name,
        result.status,
        "none" if result.code is None else f"0x{result.code:08x}",
        result.cycle,
        result.pc or 0,
    )

    if expect_fail:
        assert result.status != 1, f"{name} unexpectedly passed"
        return

    assert result.status == 1, (
        f"{name} failed with status=0x{result.status:08x} "
        f"code={result.code} pc=0x{(result.pc or 0):08x} "
        f"regs={result.regs}"
    )

    store_expectations = {
        "rv32ui/sw": (0x100, 0x00000778, 0xF),
        "rv32ui/sb": (0x100, 0xAAAAAA00, 0x2),
        "rv32ui/sh": (0x100, 0xAABB0000, 0xC),
    }
    if name in store_expectations:
        expected = store_expectations[name]
        assert expected in result.writes, (
            f"{name} did not issue expected store addr=0x{expected[0]:08x} "
            f"wdata=0x{expected[1]:08x} wstrb=0x{expected[2]:x}; "
            f"saw {result.writes}"
        )
