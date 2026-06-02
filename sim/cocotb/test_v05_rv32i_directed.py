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


async def wait_led_pass(dut, expected, cycles=12000):
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        led = int(dut.led.value)
        if led == 0x1:
            raise AssertionError("directed RV32I program reported failure")
        if led == expected:
            return
    raise AssertionError(f"LED expected {expected:04b}, got {int(dut.led.value):04b}")


@cocotb.test()
async def test_rv32i_integer_directed_program(dut):
    """Run directed RV32I ALU/immediate/jump/x0 checks from generated RAM hex."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)
    await wait_led_pass(dut, 0xA)
