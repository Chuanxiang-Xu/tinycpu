import time


class TetrisController:
    LEFT = 1 << 0
    RIGHT = 1 << 1
    ROTATE = 1 << 2
    SOFT_DROP = 1 << 3
    HARD_DROP = 1 << 4
    START = 1 << 5
    PAUSE = 1 << 6
    HOLD = 1 << 7

    def __init__(self, cpu):
        self.cpu = cpu

    def press(self, value: int, clear: bool = True, hold_s: float = 0.08) -> None:
        self.cpu.write_input(value)
        if clear:
            time.sleep(hold_s)
            self.cpu.clear_input()

    def left(self) -> None:
        self.press(self.LEFT)

    def right(self) -> None:
        self.press(self.RIGHT)

    def rotate(self) -> None:
        self.press(self.ROTATE)

    def soft_drop(self) -> None:
        self.press(self.SOFT_DROP)

    def hard_drop(self) -> None:
        self.press(self.HARD_DROP)

    def start(self) -> None:
        self.press(self.START)

    def pause(self) -> None:
        self.press(self.PAUSE)

    def hold(self) -> None:
        self.press(self.HOLD)

    def score(self) -> int:
        return self.cpu.read_app_value0()

    def lines(self) -> int:
        return self.cpu.read_app_value1() & 0xFFFF

    def level(self) -> int:
        return (self.cpu.read_app_value1() >> 16) & 0xFF

    def next_piece(self) -> int:
        return (self.cpu.read_app_value1() >> 24) & 0x0F

    def held_piece(self) -> int:
        return (self.cpu.read_app_value1() >> 28) & 0x0F
