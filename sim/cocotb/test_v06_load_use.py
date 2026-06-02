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
async def test_load_use_program(dut):
    """Check load-use stalls for ALU, store address/data, and branch compare."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    saw_load_use_stall = False
    for _ in range(10000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        saw_load_use_stall = saw_load_use_stall or (
            int(dut.core_i.load_use_hazard.value) == 1
        )
        led = int(dut.led.value)
        if led == 0x1:
            raise AssertionError("load-use program reported failure")
        if led == 0xE:
            assert saw_load_use_stall, "load-use hazard signal was never observed"
            return

    raise AssertionError(f"LED expected 1110, got {int(dut.led.value):04b}")
