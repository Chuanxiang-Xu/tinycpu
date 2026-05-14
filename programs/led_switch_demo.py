#!/usr/bin/env python3
"""Generate the tinycpu v0.3-open-rv32im LED/switch demo program.

The program is intentionally tiny:

    x2 = 0x40000000
loop:
    x1 = *(uint32_t *)(x2 + 4)
    *(uint32_t *)(x2 + 0) = x1
    goto loop

It uses only standard RV32I encodings: LUI, LW, SW, and JAL.
"""

from pathlib import Path


def lui(rd: int, imm20: int) -> int:
    return ((imm20 & 0xFFFFF) << 12) | ((rd & 0x1F) << 7) | 0x37


def lw(rd: int, rs1: int, imm: int) -> int:
    return ((imm & 0xFFF) << 20) | ((rs1 & 0x1F) << 15) | (0b010 << 12) | ((rd & 0x1F) << 7) | 0x03


def sw(rs2: int, rs1: int, imm: int) -> int:
    imm12 = imm & 0xFFF
    return (
        ((imm12 >> 5) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | (0b010 << 12)
        | ((imm12 & 0x1F) << 7)
        | 0x23
    )


def jal(rd: int, offset: int) -> int:
    imm = offset & 0x1FFFFF
    return (
        (((imm >> 20) & 0x1) << 31)
        | (((imm >> 1) & 0x3FF) << 21)
        | (((imm >> 11) & 0x1) << 20)
        | (((imm >> 12) & 0xFF) << 12)
        | ((rd & 0x1F) << 7)
        | 0x6F
    )


PROGRAM = [
    lui(2, 0x40000),   # x2 = GPIO base
    lw(1, 2, 4),       # x1 = switch register
    sw(1, 2, 0),       # LED register = x1
    jal(0, -8),        # jump back to lw
]


def main() -> None:
    out = Path(__file__).with_suffix(".hex")
    out.write_text("".join(f"{word:08x}\n" for word in PROGRAM), encoding="ascii")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
