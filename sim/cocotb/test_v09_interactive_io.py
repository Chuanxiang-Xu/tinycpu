import sys
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

sys.path.insert(0, str(Path(__file__).resolve().parent))
import tinycpu_test_programs as asm  # noqa: E402


CONTROL = 0x10000
BOOT_PC = 0x10008
TEST_STATUS_MIRROR = 0x10010
APP_STATUS_MIRROR = 0x10018
APP_VALUE0_MIRROR = 0x1001C
APP_VALUE1_MIRROR = 0x10020
FRAME_COUNTER_MIRROR = 0x10024
HOST_INPUT_WRITE = 0x10030
HOST_INPUT_CLEAR = 0x10038
FRAMEBUFFER_MIRROR = 0x10100


def interactive_program():
    return [
        asm.lui(31, 0x10000),
        asm.lw(30, 31, 0x010),
        asm.b_type(-4, asm.ZERO, 30, 0b000),
        asm.sw(30, 31, 0x018),
        asm.addi(29, asm.ZERO, 0x11),
        asm.sw(29, 31, 0x014),
        asm.addi(29, asm.ZERO, 0x22),
        asm.sw(29, 31, 0x01C),
        asm.addi(29, asm.ZERO, 0x33),
        asm.sw(29, 31, 0x020),
        asm.addi(29, 31, 0x100),
        asm.sb(30, 29, 0),
        asm.srli(28, 30, 8),
        asm.sb(28, 29, 1),
        asm.addi(29, 31, 0x7F0),
        asm.addi(29, 29, 0x7F0),
        asm.addi(30, asm.ZERO, 1),
        asm.sw(30, 29, 16),
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


async def load_program_and_run(dut, program):
    await axil_write(dut, CONTROL, 0b0011)
    for index, word in enumerate(program):
        await axil_write(dut, index * 4, word)
    await axil_write(dut, BOOT_PC, 0)
    await axil_write(dut, CONTROL, 0b1000)


@cocotb.test()
async def test_host_input_reaches_cpu_polling_program(dut):
    """Write HOST_INPUT through AXI-Lite and observe CPU-read value in mirrors."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)
    await load_program_and_run(dut, interactive_program())
    await axil_write(dut, HOST_INPUT_WRITE, 0x0000_12A5)

    for _ in range(1000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if await axil_read(dut, TEST_STATUS_MIRROR) == 1:
            break
    else:
        raise AssertionError("host input polling program did not finish")

    assert await axil_read(dut, HOST_INPUT_WRITE) == 0x0000_12A5
    assert await axil_read(dut, APP_VALUE0_MIRROR) == 0x0000_12A5

    await axil_write(dut, HOST_INPUT_CLEAR, 1)
    assert await axil_read(dut, HOST_INPUT_WRITE) == 0


@cocotb.test()
async def test_interactive_io_status_values_and_framebuffer(dut):
    """Verify generic app status/value/framebuffer mirrors after host input."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)
    await load_program_and_run(dut, interactive_program())
    await axil_write(dut, HOST_INPUT_WRITE, 0x0000_00C3)

    for _ in range(1000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if await axil_read(dut, TEST_STATUS_MIRROR) == 1:
            break
    else:
        raise AssertionError("interactive I/O program did not finish")

    assert await axil_read(dut, APP_STATUS_MIRROR) == 0x11
    assert await axil_read(dut, APP_VALUE0_MIRROR) == 0xC3
    assert await axil_read(dut, APP_VALUE1_MIRROR) == 0x22
    assert await axil_read(dut, FRAME_COUNTER_MIRROR) == 0x33
    assert await axil_read(dut, FRAMEBUFFER_MIRROR) == 0x000000C3
