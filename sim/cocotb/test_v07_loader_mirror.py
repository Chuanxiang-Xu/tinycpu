import sys
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

sys.path.insert(0, str(Path(__file__).resolve().parent))
import tinycpu_test_programs as asm  # noqa: E402


CONTROL = 0x10000
STATUS = 0x10004
BOOT_PC = 0x10008
TEST_STATUS_MIRROR = 0x10010
TEST_CODE_MIRROR = 0x10014


def mirror_program():
    return [
        asm.lui(31, 0x10000),
        asm.addi(31, 31, 0x7F0),
        asm.addi(31, 31, 0x7F0),
        asm.addi(30, asm.ZERO, 0x5A),
        asm.sw(30, 31, 20),
        asm.addi(30, asm.ZERO, 1),
        asm.sw(30, 31, 16),
        asm.jal(asm.ZERO, 0),
    ]


async def reset_soc(dut):
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


async def axil_write(dut, addr, data, wstrb=0xF, expect_resp=0):
    dut.s_axi_awaddr.value = addr
    dut.s_axi_wdata.value = data
    dut.s_axi_wstrb.value = wstrb
    dut.s_axi_awvalid.value = 1
    dut.s_axi_wvalid.value = 1

    while True:
        await RisingEdge(dut.clk)
        awready = int(dut.s_axi_awready.value)
        wready = int(dut.s_axi_wready.value)
        if awready:
            dut.s_axi_awvalid.value = 0
        if wready:
            dut.s_axi_wvalid.value = 0
        if awready and wready:
            break

    while not int(dut.s_axi_bvalid.value):
        await RisingEdge(dut.clk)
    assert int(dut.s_axi_bresp.value) == expect_resp
    await RisingEdge(dut.clk)


async def axil_read(dut, addr, expect_resp=0):
    dut.s_axi_araddr.value = addr
    dut.s_axi_arvalid.value = 1

    while True:
        await RisingEdge(dut.clk)
        if int(dut.s_axi_arready.value):
            dut.s_axi_arvalid.value = 0
            break

    while not int(dut.s_axi_rvalid.value):
        await RisingEdge(dut.clk)
    data = int(dut.s_axi_rdata.value)
    assert int(dut.s_axi_rresp.value) == expect_resp
    await RisingEdge(dut.clk)
    return data


@cocotb.test()
async def test_loader_reads_cpu_test_status_mirrors(dut):
    """Run a loaded program and read CPU-side TEST_STATUS/TEST_CODE via AXI-Lite."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    await axil_write(dut, CONTROL, 0b0011)
    for index, word in enumerate(mirror_program()):
        await axil_write(dut, index * 4, word)
    await axil_write(dut, BOOT_PC, 0)

    assert await axil_read(dut, TEST_STATUS_MIRROR) == 0
    assert await axil_read(dut, TEST_CODE_MIRROR) == 0

    await axil_write(dut, TEST_STATUS_MIRROR, 0xFFFF_FFFF, expect_resp=0b10)
    assert await axil_read(dut, TEST_STATUS_MIRROR) == 0

    await axil_write(dut, CONTROL, 0b1000)

    for _ in range(1000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        status = await axil_read(dut, TEST_STATUS_MIRROR)
        if status != 0:
            break
    else:
        status = await axil_read(dut, TEST_STATUS_MIRROR)
        raise AssertionError(f"TEST_STATUS mirror did not update, got {status:#x}")

    code = await axil_read(dut, TEST_CODE_MIRROR)
    assert status == 1
    assert code == 0x5A

    loader_status = await axil_read(dut, STATUS)
    assert loader_status & 0x1, "CPU should still report running after test pass"
