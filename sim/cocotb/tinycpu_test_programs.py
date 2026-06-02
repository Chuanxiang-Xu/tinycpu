#!/usr/bin/env python3
"""Generate small RV32I hex programs for cocotb directed tests."""

from __future__ import annotations

import sys
from pathlib import Path


OP_LUI = 0x37
OP_AUIPC = 0x17
OP_JAL = 0x6F
OP_JALR = 0x67
OP_BRANCH = 0x63
OP_LOAD = 0x03
OP_STORE = 0x23
OP_IMM = 0x13
OP = 0x33

ZERO = 0
RA = 1
GPIO = 31
LED_VALUE = 30


def check_reg(value: int, bits: int, name: str) -> int:
    if not 0 <= value < (1 << bits):
        raise ValueError(f"{name} out of range: {value}")
    return value


def i_imm(value: int) -> int:
    if not -2048 <= value <= 2047:
        raise ValueError(f"I immediate out of range: {value}")
    return value & 0xFFF


def u_imm(value: int) -> int:
    return check_reg(value, 20, "U immediate")


def reg(value: int) -> int:
    return check_reg(value, 5, "register")


def r_type(funct7: int, rs2: int, rs1: int, funct3: int, rd: int) -> int:
    return (
        (check_reg(funct7, 7, "funct7") << 25)
        | (reg(rs2) << 20)
        | (reg(rs1) << 15)
        | (check_reg(funct3, 3, "funct3") << 12)
        | (reg(rd) << 7)
        | OP
    )


def i_type(imm: int, rs1: int, funct3: int, rd: int, opcode: int = OP_IMM) -> int:
    return (
        (i_imm(imm) << 20)
        | (reg(rs1) << 15)
        | (check_reg(funct3, 3, "funct3") << 12)
        | (reg(rd) << 7)
        | check_reg(opcode, 7, "opcode")
    )


def s_type(imm: int, rs2: int, rs1: int, funct3: int) -> int:
    imm12 = i_imm(imm)
    return (
        ((imm12 >> 5) << 25)
        | (reg(rs2) << 20)
        | (reg(rs1) << 15)
        | (check_reg(funct3, 3, "funct3") << 12)
        | ((imm12 & 0x1F) << 7)
        | OP_STORE
    )


def b_type(offset: int, rs2: int, rs1: int, funct3: int) -> int:
    if offset % 2:
        raise ValueError(f"branch offset must be 2-byte aligned: {offset}")
    if not -4096 <= offset <= 4094:
        raise ValueError(f"branch offset out of range: {offset}")
    imm = offset & 0x1FFF
    return (
        (((imm >> 12) & 0x1) << 31)
        | (((imm >> 5) & 0x3F) << 25)
        | (reg(rs2) << 20)
        | (reg(rs1) << 15)
        | (check_reg(funct3, 3, "funct3") << 12)
        | (((imm >> 1) & 0xF) << 8)
        | (((imm >> 11) & 0x1) << 7)
        | OP_BRANCH
    )


def u_type(imm20: int, rd: int, opcode: int) -> int:
    return (u_imm(imm20) << 12) | (reg(rd) << 7) | check_reg(opcode, 7, "opcode")


def j_type(offset: int, rd: int) -> int:
    if offset % 2:
        raise ValueError(f"JAL offset must be 2-byte aligned: {offset}")
    if not -(1 << 20) <= offset <= (1 << 20) - 2:
        raise ValueError(f"JAL offset out of range: {offset}")
    imm = offset & 0x1FFFFF
    return (
        (((imm >> 20) & 0x1) << 31)
        | (((imm >> 1) & 0x3FF) << 21)
        | (((imm >> 11) & 0x1) << 20)
        | (((imm >> 12) & 0xFF) << 12)
        | (reg(rd) << 7)
        | OP_JAL
    )


def lui(rd: int, imm20: int) -> int:
    return u_type(imm20, rd, OP_LUI)


def auipc(rd: int, imm20: int) -> int:
    return u_type(imm20, rd, OP_AUIPC)


def addi(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b000, rd)


def slti(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b010, rd)


def sltiu(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b011, rd)


def xori(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b100, rd)


def ori(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b110, rd)


def andi(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b111, rd)


def slli(rd: int, rs1: int, shamt: int) -> int:
    return i_type(shamt, rs1, 0b001, rd)


def srli(rd: int, rs1: int, shamt: int) -> int:
    return i_type(shamt, rs1, 0b101, rd)


def srai(rd: int, rs1: int, shamt: int) -> int:
    return i_type((0b0100000 << 5) | shamt, rs1, 0b101, rd)


def jal(rd: int, offset: int) -> int:
    return j_type(offset, rd)


def jalr(rd: int, rs1: int, imm: int = 0) -> int:
    return i_type(imm, rs1, 0b000, rd, OP_JALR)


def lb(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b000, rd, OP_LOAD)


def lh(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b001, rd, OP_LOAD)


def lw(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b010, rd, OP_LOAD)


def lbu(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b100, rd, OP_LOAD)


def lhu(rd: int, rs1: int, imm: int) -> int:
    return i_type(imm, rs1, 0b101, rd, OP_LOAD)


def sb(rs2: int, rs1: int, imm: int) -> int:
    return s_type(imm, rs2, rs1, 0b000)


def sh(rs2: int, rs1: int, imm: int) -> int:
    return s_type(imm, rs2, rs1, 0b001)


def sw(rs2: int, rs1: int, imm: int) -> int:
    return s_type(imm, rs2, rs1, 0b010)


def add(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b000, rd)


def sub(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0b0100000, rs2, rs1, 0b000, rd)


def sll(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b001, rd)


def slt(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b010, rd)


def sltu(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b011, rd)


def xor(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b100, rd)


def srl(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b101, rd)


def sra(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0b0100000, rs2, rs1, 0b101, rd)


def or_(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b110, rd)


def and_(rd: int, rs1: int, rs2: int) -> int:
    return r_type(0, rs2, rs1, 0b111, rd)


class Program:
    def __init__(self) -> None:
        self.items: list[int | tuple[str, str] | tuple[str, str, int, int, int]] = []
        self.labels: dict[str, int] = {}

    @property
    def pc(self) -> int:
        return len(self.items) * 4

    def label(self, name: str) -> None:
        self.labels[name] = self.pc

    def emit(self, word: int) -> None:
        self.items.append(word & 0xFFFF_FFFF)

    def branch(self, funct3: int, rs1: int, rs2: int, label: str) -> None:
        self.items.append(("branch", label, funct3, rs1, rs2))

    def jump(self, label: str, rd: int = ZERO) -> None:
        self.items.append(("jal", label))
        if rd != ZERO:
            raise ValueError("label jumps only support x0 in this helper")

    def words(self) -> list[int]:
        encoded: list[int] = []
        for pc, item in enumerate(self.items):
            byte_pc = pc * 4
            if isinstance(item, int):
                encoded.append(item)
            elif item[0] == "branch":
                _, label, funct3, rs1, rs2 = item
                encoded.append(b_type(self.labels[label] - byte_pc, rs2, rs1, funct3))
            elif item[0] == "jal":
                _, label = item
                encoded.append(jal(ZERO, self.labels[label] - byte_pc))
            else:
                raise ValueError(f"unknown item: {item}")
        return encoded


def bne(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b001, rs1, rs2, label)


def beq(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b000, rs1, rs2, label)


def blt(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b100, rs1, rs2, label)


def bge(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b101, rs1, rs2, label)


def bltu(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b110, rs1, rs2, label)


def bgeu(rs1: int, rs2: int, label: str, p: Program) -> None:
    p.branch(0b111, rs1, rs2, label)


def li(p: Program, rd: int, value: int) -> None:
    value &= 0xFFFF_FFFF
    signed = value if value < 0x8000_0000 else value - 0x1_0000_0000
    if -2048 <= signed <= 2047:
        p.emit(addi(rd, ZERO, signed))
        return

    upper = (value + 0x800) >> 12
    lower = value - (upper << 12)
    if lower >= 2048:
        lower -= 4096
        upper += 1
    p.emit(lui(rd, upper & 0xFFFFF))
    if lower:
        p.emit(addi(rd, rd, lower))


def fail(p: Program, code: int = 1) -> None:
    p.label("fail")
    li(p, LED_VALUE, code)
    p.emit(sw(LED_VALUE, GPIO, 0))
    p.jump("fail")


def pass_loop(p: Program, code: int) -> None:
    p.label("pass")
    li(p, LED_VALUE, code)
    p.emit(sw(LED_VALUE, GPIO, 0))
    p.jump("pass")


def expect_eq(p: Program, rs1: int, rs2: int) -> None:
    bne(rs1, rs2, "fail", p)


def expect_ne(p: Program, rs1: int, rs2: int) -> None:
    beq(rs1, rs2, "fail", p)


def rv32i_directed() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)

    li(p, 1, 0x1234_5678)
    li(p, 2, 0x1234_5678)
    expect_eq(p, 1, 2)

    p.emit(addi(3, ZERO, -1))
    p.emit(slti(4, 3, 0))
    p.emit(addi(5, ZERO, 1))
    expect_eq(p, 4, 5)
    p.emit(sltiu(4, 3, 1))
    expect_eq(p, 4, ZERO)

    p.emit(andi(6, 1, 0x0F0))
    p.emit(addi(7, ZERO, 0x070))
    expect_eq(p, 6, 7)
    p.emit(ori(6, 7, 0x00F))
    p.emit(addi(7, ZERO, 0x07F))
    expect_eq(p, 6, 7)
    p.emit(xori(6, 7, 0x055))
    p.emit(addi(7, ZERO, 0x02A))
    expect_eq(p, 6, 7)

    p.emit(addi(8, ZERO, 1))
    p.emit(slli(8, 8, 5))
    p.emit(addi(9, ZERO, 32))
    expect_eq(p, 8, 9)
    p.emit(srli(8, 8, 3))
    p.emit(addi(9, ZERO, 4))
    expect_eq(p, 8, 9)
    li(p, 8, 0xFFFF_FFF0)
    p.emit(srai(8, 8, 2))
    li(p, 9, 0xFFFF_FFFC)
    expect_eq(p, 8, 9)

    p.emit(addi(10, ZERO, 9))
    p.emit(addi(11, ZERO, 4))
    p.emit(add(12, 10, 11))
    p.emit(addi(13, ZERO, 13))
    expect_eq(p, 12, 13)
    p.emit(sub(12, 10, 11))
    p.emit(addi(13, ZERO, 5))
    expect_eq(p, 12, 13)
    p.emit(sll(12, 11, 11))
    p.emit(addi(13, ZERO, 64))
    expect_eq(p, 12, 13)
    p.emit(slt(12, 3, ZERO))
    p.emit(addi(13, ZERO, 1))
    expect_eq(p, 12, 13)
    p.emit(sltu(12, 10, 3))
    expect_eq(p, 12, 13)
    p.emit(xor(12, 10, 11))
    p.emit(addi(13, ZERO, 13))
    expect_eq(p, 12, 13)
    p.emit(srl(12, 10, 11))
    expect_eq(p, 12, ZERO)
    p.emit(sra(12, 3, 11))
    li(p, 13, 0xFFFF_FFFF)
    expect_eq(p, 12, 13)
    p.emit(or_(12, 10, 11))
    p.emit(addi(13, ZERO, 13))
    expect_eq(p, 12, 13)
    p.emit(and_(12, 10, 11))
    expect_eq(p, 12, ZERO)

    p.emit(addi(ZERO, ZERO, 7))
    expect_eq(p, ZERO, ZERO)

    p.jump("after_jal")
    p.jump("fail")
    p.label("after_jal")
    li(p, 14, p.pc + 12)
    p.emit(jalr(ZERO, 14, 0))
    p.jump("fail")
    p.label("after_jalr")

    pass_loop(p, 0xA)
    fail(p)

    # Patch the JALR target now that the label address is known.
    words = p.words()
    target = p.labels["after_jalr"]
    # The generated sequence at li(x14, p.pc + 12) is one ADDI for this small
    # address. It is followed by JALR.
    for idx, word in enumerate(words):
        if word == addi(14, ZERO, p.labels["after_jalr"]):
            break
    else:
        raise AssertionError("could not patch JALR target")
    words[idx] = addi(14, ZERO, target)
    return words


def branch_load_store() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)

    p.emit(addi(1, ZERO, 5))
    p.emit(addi(2, ZERO, 5))
    p.emit(addi(3, ZERO, 7))
    p.emit(addi(4, ZERO, -1))

    beq(1, 2, "beq_ok", p)
    p.jump("fail")
    p.label("beq_ok")
    beq(1, 3, "fail", p)
    bne(1, 3, "bne_ok", p)
    p.jump("fail")
    p.label("bne_ok")
    blt(4, 1, "blt_ok", p)
    p.jump("fail")
    p.label("blt_ok")
    bge(1, 4, "bge_ok", p)
    p.jump("fail")
    p.label("bge_ok")
    bltu(1, 4, "bltu_ok", p)
    p.jump("fail")
    p.label("bltu_ok")
    bgeu(4, 1, "bgeu_ok", p)
    p.jump("fail")
    p.label("bgeu_ok")

    li(p, 20, 0x100)
    li(p, 5, 0x1122_3344)
    p.emit(sw(5, 20, 0))
    p.emit(lw(6, 20, 0))
    expect_eq(p, 6, 5)

    p.emit(addi(7, ZERO, 0x80))
    p.emit(sb(7, 20, 1))
    p.emit(lbu(8, 20, 1))
    expect_eq(p, 8, 7)
    p.emit(lb(9, 20, 1))
    li(p, 10, 0xFFFF_FF80)
    expect_eq(p, 9, 10)

    li(p, 11, 0x0000_ABCD)
    p.emit(sh(11, 20, 2))
    p.emit(lhu(12, 20, 2))
    expect_eq(p, 12, 11)
    p.emit(lh(13, 20, 2))
    li(p, 14, 0xFFFF_ABCD)
    expect_eq(p, 13, 14)

    p.emit(addi(15, ZERO, 0x7F))
    p.emit(sb(15, 20, 3))
    p.emit(lbu(16, 20, 3))
    expect_eq(p, 16, 15)

    pass_loop(p, 0xB)
    fail(p)
    return p.words()


PROGRAMS = {
    "rv32i-directed": rv32i_directed,
    "branch-load-store": branch_load_store,
}


def pipeline_overlap() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)

    p.emit(addi(1, ZERO, 1))
    p.emit(addi(2, ZERO, 2))
    p.emit(addi(3, ZERO, 3))
    p.emit(addi(4, ZERO, 4))
    p.emit(addi(5, ZERO, 5))
    p.emit(addi(6, ZERO, 6))
    p.emit(addi(7, ZERO, 7))
    p.emit(addi(8, ZERO, 8))

    pass_loop(p, 0xC)
    fail(p)
    return p.words()


def pipeline_forwarding() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)

    p.emit(addi(1, ZERO, 10))
    p.emit(addi(2, ZERO, 3))

    # EX/MEM -> EX forwarding.
    p.emit(add(3, 1, 2))
    p.emit(add(4, 3, 2))
    p.emit(addi(5, ZERO, 16))
    expect_eq(p, 4, 5)

    # MEM/WB -> EX forwarding with one independent instruction between.
    p.emit(add(6, 1, 2))
    p.emit(addi(7, ZERO, 1))
    p.emit(add(8, 6, 7))
    p.emit(addi(9, ZERO, 14))
    expect_eq(p, 8, 9)

    # EX/MEM priority over MEM/WB when two older instructions write same rd.
    p.emit(addi(10, ZERO, 1))
    p.emit(addi(10, 10, 2))
    p.emit(add(11, 10, 2))
    p.emit(addi(12, ZERO, 6))
    expect_eq(p, 11, 12)

    # Store data forwarding.
    li(p, 20, 0x100)
    p.emit(addi(13, ZERO, 0x5A))
    p.emit(sw(13, 20, 0))
    p.emit(lw(14, 20, 0))
    expect_eq(p, 14, 13)

    pass_loop(p, 0xD)
    fail(p)
    return p.words()


def pipeline_load_use() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)
    li(p, 20, 0x100)

    p.emit(addi(1, ZERO, 7))
    p.emit(sw(1, 20, 0))

    # Load followed immediately by ALU use.
    p.emit(lw(2, 20, 0))
    p.emit(addi(3, 2, 5))
    p.emit(addi(4, ZERO, 12))
    expect_eq(p, 3, 4)

    # Load followed by store address use.
    p.emit(addi(5, ZERO, 0x20))
    p.emit(sw(5, 20, 4))
    p.emit(lw(6, 20, 4))
    p.emit(sw(1, 6, 0))
    p.emit(lw(7, 5, 0))
    expect_eq(p, 7, 1)

    # Load followed by store data use.
    p.emit(lw(8, 20, 0))
    p.emit(sw(8, 20, 8))
    p.emit(lw(9, 20, 8))
    expect_eq(p, 9, 1)

    # Load followed by branch compare.
    p.emit(lw(10, 20, 0))
    beq(10, 1, "load_branch_ok", p)
    p.jump("fail")
    p.label("load_branch_ok")

    pass_loop(p, 0xE)
    fail(p)
    return p.words()


def pipeline_branch_flush() -> list[int]:
    p = Program()
    li(p, GPIO, 0x1000_0000)

    p.emit(addi(1, ZERO, 1))
    p.emit(addi(2, ZERO, 1))

    # Taken branch must skip the wrong-path LED failure store.
    beq(1, 2, "taken_ok", p)
    li(p, LED_VALUE, 1)
    p.emit(sw(LED_VALUE, GPIO, 0))
    p.label("taken_ok")

    # Not-taken branch must continue normally.
    bne(1, 2, "fail", p)

    # JAL must skip a wrong-path store.
    p.jump("jal_ok")
    li(p, LED_VALUE, 1)
    p.emit(sw(LED_VALUE, GPIO, 0))
    p.label("jal_ok")

    # JALR must skip a wrong-path store.
    li(p, 14, 0)
    p.emit(jalr(ZERO, 14, 0))
    p.jump("fail")
    p.label("jalr_ok")

    pass_loop(p, 0xF)
    fail(p)

    words = p.words()
    target = p.labels["jalr_ok"]
    for idx, word in enumerate(words):
        if word == addi(14, ZERO, 0):
            words[idx] = addi(14, ZERO, target)
            break
    else:
        raise AssertionError("could not patch JALR target")
    return words


PROGRAMS.update({
    "pipeline-overlap": pipeline_overlap,
    "pipeline-forwarding": pipeline_forwarding,
    "pipeline-load-use": pipeline_load_use,
    "pipeline-branch-flush": pipeline_branch_flush,
})


def write_hex(words: list[int], out_path: Path, min_words: int = 128) -> None:
    padded = words + [addi(ZERO, ZERO, 0)] * max(0, min_words - len(words))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("".join(f"{word:08x}\n" for word in padded), encoding="ascii")


def main() -> int:
    if len(sys.argv) != 3 or sys.argv[1] not in PROGRAMS:
        names = ", ".join(sorted(PROGRAMS))
        print(f"usage: {sys.argv[0]} {{{names}}} output.hex", file=sys.stderr)
        return 2

    write_hex(PROGRAMS[sys.argv[1]](), Path(sys.argv[2]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
