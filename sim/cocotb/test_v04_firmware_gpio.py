import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def reset_soc(dut):
    dut.rst.value = 1
    dut.sw.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


async def wait_led(dut, expected, cycles=800):
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if int(dut.led.value) == expected:
            return
    raise AssertionError(f"LED expected {expected:04b}, got {int(dut.led.value):04b}")


@cocotb.test()
async def test_gcc_bare_metal_c_reads_switch_and_writes_led(dut):
    """Run programs/c_demo C output and observe the GPIO MMIO loop."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)
    await wait_led(dut, 0)

    for sw_value in (0b01, 0b10, 0b11, 0b00):
        dut.sw.value = sw_value
        await wait_led(dut, sw_value)
