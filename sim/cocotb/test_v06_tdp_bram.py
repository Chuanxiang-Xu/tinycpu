import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def settle():
    await Timer(1, unit="ns")


@cocotb.test()
async def test_true_dual_port_bram_byte_writes_and_reads(dut):
    """Exercise port A reads, port B writes, byte strobes, and dual access."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.a_en.value = 0
    dut.a_addr.value = 0
    dut.a_wdata.value = 0
    dut.a_wstrb.value = 0
    dut.b_en.value = 0
    dut.b_addr.value = 0
    dut.b_wdata.value = 0
    dut.b_wstrb.value = 0
    await RisingEdge(dut.clk)

    # Full-word write through port B, read through both ports.
    dut.b_en.value = 1
    dut.b_addr.value = 0x20
    dut.b_wdata.value = 0x11223344
    dut.b_wstrb.value = 0b1111
    await RisingEdge(dut.clk)
    dut.b_wstrb.value = 0

    dut.a_en.value = 1
    dut.a_addr.value = 0x20
    await settle()
    assert int(dut.a_rdata.value) == 0x11223344

    dut.b_en.value = 1
    dut.b_addr.value = 0x20
    await RisingEdge(dut.clk)
    await settle()
    assert int(dut.b_rdata.value) == 0x11223344

    # Byte write enable should only update lane 1.
    dut.b_addr.value = 0x20
    dut.b_wdata.value = 0x0000AA00
    dut.b_wstrb.value = 0b0010
    await RisingEdge(dut.clk)
    dut.b_wstrb.value = 0
    dut.a_addr.value = 0x20
    await settle()
    assert int(dut.a_rdata.value) == 0x1122AA44

    # Halfword write at byte offset 2 should update upper half.
    dut.b_addr.value = 0x20
    dut.b_wdata.value = 0xBEEF0000
    dut.b_wstrb.value = 0b1100
    await RisingEdge(dut.clk)
    dut.b_wstrb.value = 0
    await settle()
    assert int(dut.a_rdata.value) == 0xBEEFAA44

    # Same-cycle instruction and data accesses to different words.
    dut.a_addr.value = 0x20
    dut.b_addr.value = 0x24
    dut.b_wdata.value = 0xCAFEBABE
    dut.b_wstrb.value = 0b1111
    await RisingEdge(dut.clk)
    dut.b_wstrb.value = 0
    await settle()
    assert int(dut.a_rdata.value) == 0xBEEFAA44

    dut.a_addr.value = 0x24
    await settle()
    assert int(dut.a_rdata.value) == 0xCAFEBABE
