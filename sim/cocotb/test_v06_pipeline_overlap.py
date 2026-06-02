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


def valid_count(dut):
    return (
        int(dut.core_i.dbg_if_id_valid.value)
        + int(dut.core_i.dbg_id_ex_valid.value)
        + int(dut.core_i.dbg_ex_mem_valid.value)
        + int(dut.core_i.dbg_mem_wb_valid.value)
    )


@cocotb.test()
async def test_pipeline_has_overlapping_valid_stages(dut):
    """Run independent ALU code and observe multiple valid pipeline stages."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    saw_overlap = False
    for _ in range(4000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        saw_overlap = saw_overlap or (valid_count(dut) >= 3)
        led = int(dut.led.value)
        if led == 0x1:
            raise AssertionError("pipeline overlap program reported failure")
        if led == 0xC:
            assert saw_overlap, "pipeline never showed at least three valid stages"
            return

    raise AssertionError(f"LED expected 1100, got {int(dut.led.value):04b}")
