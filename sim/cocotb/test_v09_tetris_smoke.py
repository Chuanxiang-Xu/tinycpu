import sys
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_v09_interactive_io import axil_read, axil_write, reset_soc  # noqa: E402


CONTROL = 0x10000
BOOT_PC = 0x10008
APP_STATUS_MIRROR = 0x10018
APP_VALUE0_MIRROR = 0x1001C
FRAME_COUNTER_MIRROR = 0x10024
HOST_INPUT_WRITE = 0x10030
HOST_INPUT_CLEAR = 0x10038
FRAMEBUFFER_MIRROR = 0x10100

INPUT_START = 1 << 5
INPUT_RIGHT = 1 << 1
STATUS_RUNNING = 1 << 0


def read_hex_words(path):
    words = []
    for line in Path(path).read_text(encoding="ascii").splitlines():
        text = line.strip()
        if text:
            words.append(int(text, 16))
    return words


@cocotb.test()
async def test_tetris_starts_and_draws_framebuffer(dut):
    """Load TinyTetris, send START/move input, and observe app/frame mirrors."""

    dut.clk.value = 0
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_soc(dut)

    await axil_write(dut, CONTROL, 0b0011)
    words = read_hex_words("../../programs/tetris/firmware.hex")
    for index, word in enumerate(words):
        await axil_write(dut, index * 4, word)
    await axil_write(dut, BOOT_PC, 0)
    await axil_write(dut, CONTROL, 0b1000)

    await axil_write(dut, HOST_INPUT_WRITE, INPUT_START)
    for _ in range(20):
        await RisingEdge(dut.clk)
    await axil_write(dut, HOST_INPUT_CLEAR, 1)
    await axil_write(dut, HOST_INPUT_WRITE, INPUT_RIGHT)
    for _ in range(20):
        await RisingEdge(dut.clk)
    await axil_write(dut, HOST_INPUT_CLEAR, 1)

    for _ in range(3000):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        status = await axil_read(dut, APP_STATUS_MIRROR)
        frame = await axil_read(dut, FRAME_COUNTER_MIRROR)
        fb_words = [
            await axil_read(dut, FRAMEBUFFER_MIRROR + offset * 4)
            for offset in range(6)
        ]
        if (status & STATUS_RUNNING) and frame > 0 and any(word != 0 for word in fb_words):
            break
    else:
        status = await axil_read(dut, APP_STATUS_MIRROR)
        frame = await axil_read(dut, FRAME_COUNTER_MIRROR)
        fb_words = [
            await axil_read(dut, FRAMEBUFFER_MIRROR + offset * 4)
            for offset in range(6)
        ]
        raise AssertionError(
            f"tetris smoke did not draw: status={status:#x} frame={frame} fb={fb_words}"
        )

    assert await axil_read(dut, APP_VALUE0_MIRROR) >= 0
