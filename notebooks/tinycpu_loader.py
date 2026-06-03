from __future__ import annotations

import time
from pathlib import Path


class TinyCPULoader:
    RAM_BASE = 0x00000

    CONTROL = 0x10000
    STATUS = 0x10004
    BOOT_PC = 0x10008
    DEBUG = 0x1000C

    TEST_STATUS = 0x10010
    TEST_CODE = 0x10014
    APP_STATUS = 0x10018
    APP_VALUE0 = 0x1001C
    APP_VALUE1 = 0x10020
    FRAME_COUNTER = 0x10024
    HOST_INPUT = 0x10030
    HOST_COMMAND = 0x10034
    HOST_INPUT_CLEAR = 0x10038
    FRAMEBUFFER = 0x10100

    GAME_STATUS = APP_STATUS

    def __init__(self, mmio):
        self.mmio = mmio

    def halt(self) -> None:
        self.mmio.write(self.CONTROL, 0b0010)

    def reset(self) -> None:
        self.mmio.write(self.CONTROL, 0b0011)

    def clear_pipeline(self) -> None:
        self.mmio.write(self.CONTROL, 0b1010)

    def set_boot_pc(self, pc: int = 0) -> None:
        self.mmio.write(self.BOOT_PC, pc & 0xFFFFFFFF)

    def load_words(self, words, base_addr: int = 0) -> None:
        for index, word in enumerate(words):
            self.mmio.write(base_addr + index * 4, int(word) & 0xFFFFFFFF)

    def load_hex(self, path, base_addr: int = 0) -> None:
        words = []
        for line in Path(path).read_text(encoding="ascii").splitlines():
            text = line.strip()
            if text:
                words.append(int(text, 16))
        self.load_words(words, base_addr)

    def run(self) -> None:
        self.mmio.write(self.CONTROL, 0b1000)

    def read_status(self) -> int:
        return int(self.mmio.read(self.STATUS))

    def read_test_status(self) -> tuple[int, int]:
        return int(self.mmio.read(self.TEST_STATUS)), int(self.mmio.read(self.TEST_CODE))

    def wait_for_test_status(self, timeout_s: float = 2.0) -> tuple[int, int]:
        deadline = time.monotonic() + timeout_s
        while time.monotonic() < deadline:
            status, code = self.read_test_status()
            if status != 0:
                return status, code
            time.sleep(0.01)
        return self.read_test_status()

    def read_game_status(self) -> int:
        return self.read_app_status()

    def write_input(self, value: int) -> None:
        self.mmio.write(self.HOST_INPUT, value & 0xFFFFFFFF)

    def clear_input(self) -> None:
        self.mmio.write(self.HOST_INPUT_CLEAR, 1)

    def write_command(self, value: int) -> None:
        self.mmio.write(self.HOST_COMMAND, value & 0xFFFFFFFF)

    def read_app_status(self) -> int:
        return int(self.mmio.read(self.APP_STATUS))

    def read_app_value0(self) -> int:
        return int(self.mmio.read(self.APP_VALUE0))

    def read_app_value1(self) -> int:
        return int(self.mmio.read(self.APP_VALUE1))

    def read_frame_counter(self) -> int:
        return int(self.mmio.read(self.FRAME_COUNTER))

    def read_framebuffer(self, width: int = 10, height: int = 20) -> list[int]:
        cell_count = width * height
        word_count = (cell_count + 3) // 4
        cells: list[int] = []

        for index in range(word_count):
            word = int(self.mmio.read(self.FRAMEBUFFER + index * 4))
            cells.extend(
                [
                    word & 0xFF,
                    (word >> 8) & 0xFF,
                    (word >> 16) & 0xFF,
                    (word >> 24) & 0xFF,
                ]
            )

        return cells[:cell_count]

    def render_text_grid(self, cells, width: int = 10, height: int = 20) -> str:
        palette = ".123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        lines = []
        for row in range(height):
            values = cells[row * width:(row + 1) * width]
            line = "".join(palette[cell] if 0 <= cell < len(palette) else "?" for cell in values)
            lines.append(line)
        return "\n".join(lines)

    def print_board(self, cells, width: int = 10, height: int = 20) -> None:
        print(self.render_text_grid(cells, width, height))


def find_loader_ip(overlay, preferred_name: str | None = None):
    if preferred_name:
        return overlay.ip_dict[preferred_name]

    for name, info in overlay.ip_dict.items():
        lower = name.lower()
        if "loader" in lower or "tinycpu" in lower:
            return info

    raise KeyError("Could not find tinycpu loader IP; pass preferred_name explicitly.")
