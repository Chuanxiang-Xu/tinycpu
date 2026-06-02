"""Reusable cocotb runner for tinycpu RISC-V ISA-style tests."""

from __future__ import annotations

from dataclasses import dataclass

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


MMIO_TEST_STATUS = 0x80000000
MMIO_TEST_CODE = 0x80000004


@dataclass
class RiscvTestResult:
    status: int
    code: int | None
    cycle: int
    pc: int | None
    writes: list[tuple[int, int, int]]
    regs: dict[int, int]


async def reset_soc(dut) -> None:
    dut.s_axi_awaddr.value = 0
    dut.s_axi_awvalid.value = 0
    dut.s_axi_wdata.value = 0
    dut.s_axi_wstrb.value = 0
    dut.s_axi_wvalid.value = 0
    dut.s_axi_bready.value = 1
    dut.s_axi_araddr.value = 0
    dut.s_axi_arvalid.value = 0
    dut.s_axi_rready.value = 1
    dut.rst.value = 1
    dut.sw.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


def _signal_int(handle, default: int | None = None) -> int | None:
    try:
        return int(handle.value)
    except Exception:
        return default


async def run_riscv_test(dut, timeout_cycles: int = 20000) -> RiscvTestResult:
    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    last_code: int | None = None
    last_pc: int | None = None
    writes: list[tuple[int, int, int]] = []
    for cycle in range(timeout_cycles):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

        last_pc = _signal_int(dut.core_i.pc_q, last_pc)
        valid = _signal_int(dut.dmem_valid, 0)
        we = _signal_int(dut.dmem_we, 0)
        addr = _signal_int(dut.dmem_addr, 0)
        wdata = _signal_int(dut.dmem_wdata, 0)

        if valid and we and addr == MMIO_TEST_CODE:
            last_code = wdata
        if valid and we:
            wstrb = _signal_int(dut.dmem_wstrb, 0)
            writes.append((addr, wdata, wstrb or 0))
        if valid and we and addr == MMIO_TEST_STATUS:
            return RiscvTestResult(
                status=wdata,
                code=last_code,
                cycle=cycle,
                pc=last_pc,
                writes=writes,
                regs=_snapshot_regs(dut),
            )

    raise AssertionError(
        "RISC-V ISA test timed out after "
        f"{timeout_cycles} cycles; last_pc=0x{(last_pc or 0):08x}"
    )


def _snapshot_regs(dut) -> dict[int, int]:
    regs: dict[int, int] = {}
    try:
        reg_array = dut.core_i.regfile_i.regs
        for index in range(32):
            regs[index] = int(reg_array[index].value)
    except Exception:
        pass
    return regs
