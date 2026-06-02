#!/usr/bin/env python3
"""Build tinycpu-owned RISC-V ISA assembly tests for cocotb simulation."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TEST_ROOT = ROOT / "tests" / "riscv"
ENV_DIR = TEST_ROOT / "env"
BUILD_ROOT = ROOT / "build" / "riscv-tests"


def find_tool(names: list[str]) -> str:
    for name in names:
        path = shutil.which(name)
        if path:
            return path
    raise SystemExit(
        "error: missing RISC-V toolchain; install riscv64-unknown-elf-gcc "
        "or riscv32-unknown-elf-gcc"
    )


def write_hex_from_bin(bin_path: Path, hex_path: Path, min_words: int = 16384) -> None:
    data = bin_path.read_bytes()
    if len(data) % 4:
        data += b"\x00" * (4 - (len(data) % 4))

    words = []
    for index in range(0, len(data), 4):
        words.append(int.from_bytes(data[index : index + 4], byteorder="little"))

    words.extend([0x00000013] * max(0, min_words - len(words)))
    hex_path.write_text("".join(f"{word:08x}\n" for word in words), encoding="ascii")


def discover_tests(group: str | None) -> list[Path]:
    groups = [group] if group else ["rv32ui", "rv32um"]
    tests: list[Path] = []
    for name in groups:
        tests.extend(sorted((TEST_ROOT / name).glob("*.S")))
    return tests


def build_one(source: Path, gcc: str, objcopy: str, objdump: str) -> Path:
    rel = source.relative_to(TEST_ROOT)
    out_dir = BUILD_ROOT / rel.parent / source.stem
    out_dir.mkdir(parents=True, exist_ok=True)

    elf = out_dir / f"{source.stem}.elf"
    bin_file = out_dir / f"{source.stem}.bin"
    hex_file = out_dir / f"{source.stem}.hex"
    dump = out_dir / f"{source.stem}.dump"

    common = [
        gcc,
        "-march=rv32im",
        "-mabi=ilp32",
        "-nostdlib",
        "-nostartfiles",
        "-ffreestanding",
        "-fno-pic",
        "-fno-pie",
        "-Wl,--no-relax",
        "-T",
        str(ENV_DIR / "linker.ld"),
        "-I",
        str(ENV_DIR),
        str(ENV_DIR / "crt0.S"),
        str(source),
        "-o",
        str(elf),
    ]
    subprocess.run(common, check=True)
    subprocess.run([objcopy, "-O", "binary", str(elf), str(bin_file)], check=True)
    with dump.open("w", encoding="ascii") as dump_file:
        subprocess.run([objdump, "-d", "-S", str(elf)], check=True, stdout=dump_file)
    write_hex_from_bin(bin_file, hex_file)
    return hex_file


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--group", choices=["rv32ui", "rv32um"])
    parser.add_argument("--test", help="build one test by stem name")
    args = parser.parse_args()

    gcc = find_tool(["riscv64-unknown-elf-gcc", "riscv32-unknown-elf-gcc"])
    objcopy = find_tool(["riscv64-unknown-elf-objcopy", "riscv32-unknown-elf-objcopy"])
    objdump = find_tool(["riscv64-unknown-elf-objdump", "riscv32-unknown-elf-objdump"])

    tests = discover_tests(args.group)
    if args.test:
        tests = [test for test in tests if test.stem == args.test]
        if not tests:
            raise SystemExit(f"error: unknown RISC-V test '{args.test}'")

    for source in tests:
        hex_file = build_one(source, gcc, objcopy, objdump)
        print(hex_file.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
