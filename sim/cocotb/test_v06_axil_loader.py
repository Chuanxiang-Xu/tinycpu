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


def loader_program():
    return [
        asm.lui(31, 0x10000),
        asm.addi(30, asm.ZERO, 7),
        asm.sw(30, 31, 0),
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
async def test_axil_loader_loads_bram_and_starts_cpu(dut):
    """Load firmware through AXI-Lite, release reset/halt, then block live RAM writes."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    # Hold CPU reset+halt while taking ownership of BRAM port B.
    await axil_write(dut, CONTROL, 0b0011)
    for index, word in enumerate(loader_program()):
        await axil_write(dut, index * 4, word)
    await axil_write(dut, BOOT_PC, 0)
    await axil_write(dut, CONTROL, 0b1000)

    for _ in range(1000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if int(dut.led.value) == 0x7:
            break
    else:
        raise AssertionError(f"loader program did not set LED, got {int(dut.led.value):04b}")

    status = await axil_read(dut, STATUS)
    assert status & 0x1, "CPU should report running after loader start"

    # RAM writes while running are blocked with SLVERR.
    await axil_write(dut, 0, 0x00000013, expect_resp=0b10)
