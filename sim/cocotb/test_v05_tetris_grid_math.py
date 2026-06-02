import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


EXPECTED_LED_BY_SW = {
    0b00: 0x4,
    0b01: 0x1,
    0b10: 0x0,
    0b11: 0x8,
}


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


async def wait_led(dut, expected, cycles=8000):
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if int(dut.led.value) == expected:
            return
    raise AssertionError(f"LED expected {expected:04b}, got {int(dut.led.value):04b}")


@cocotb.test()
async def test_rv32im_c_grid_math_for_tetris_like_logic(dut):
    """Run programs/rv32im_demo and check row*10+col plus random%7 style math."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    for sw_value, expected_led in EXPECTED_LED_BY_SW.items():
        dut.sw.value = sw_value
        await wait_led(dut, expected_led)
