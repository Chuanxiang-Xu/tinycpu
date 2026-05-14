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


async def wait_led(dut, expected, cycles=200):
    for i in range(cycles):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if int(dut.led.value) == expected:
            return
    raise AssertionError(f"LED expected {expected:04b}, got {int(dut.led.value):04b}")


@cocotb.test()
async def test_cpu_reads_switch_and_writes_led_mmio(dut):
    """CPU fetches from RAM, reads GPIO switch MMIO, and writes GPIO LED MMIO."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)
    await wait_led(dut, 0)

    dut.sw.value = 0b01
    await wait_led(dut, 0b0001)

    dut.sw.value = 0b10
    await wait_led(dut, 0b0010)

    dut.sw.value = 0b11
    await wait_led(dut, 0b0011)
