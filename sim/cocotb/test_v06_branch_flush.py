import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


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


@cocotb.test()
async def test_branch_flush_program(dut):
    """Check taken branch, not-taken branch, JAL, and JALR flush behavior."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    for _ in range(10000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        led = int(dut.led.value)
        if led == 0x1:
            raise AssertionError("branch-flush program reported failure")
        if led == 0xF:
            return

    raise AssertionError(f"LED expected 1111, got {int(dut.led.value):04b}")
