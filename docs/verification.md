# Verification

This page tracks the current verification coverage for
`v0.6-pipeline-bram-loader`.

tinycpu uses selected clean-room simulation tests for RV32I/RV32M behavior and
focused cocotb regressions for the v0.6 BRAM, loader, MMIO, and pipeline
infrastructure. This is not a full RISC-V architectural compliance claim.

## How To Run

```sh
make -C sim/cocotb test-all
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
make -C sim/cocotb test-riscv-isa
```

`test-all` is the current CI aggregate for the v0.6 branch. GitHub Actions also
runs `test-riscv-isa` so the selected rv32ui-style and rv32um-style tests are
covered before release.

## Existing Test Targets

| Target | Purpose | Status |
| --- | --- | --- |
| `test-v03-gpio` | GPIO SoC smoke test | PASS |
| `test-v04-firmware-gpio` | Bare-metal C GPIO firmware | PASS |
| `test-v05-muldiv` | Standalone RV32M mul/div unit | PASS |
| `test-v06-bram` | Unified BRAM behavior | PASS |
| `test-v06-axil-loader` | AXI-Lite loader/control path | PASS |
| `test-v06-pipeline-overlap` | Pipeline overlap smoke/regression | PASS |
| `test-v06-forwarding` | Pipeline forwarding | PASS |
| `test-v06-load-use` | Load-use stall | PASS |
| `test-v06-branch-flush` | Branch flush | PASS |
| `test-riscv-smoke` | Minimal RISC-V ISA smoke test | PASS |
| `test-rv32ui` | Selected rv32ui-style RV32I tests | PASS |
| `test-rv32um` | Selected rv32um-style RV32M tests | PASS |

The older v0.5 directed and grid firmware targets remain available as
individual regression targets while their expectations are reviewed against the
v0.6 pipeline/BRAM architecture.

## RISC-V ISA Test Infrastructure

The ISA-style tests are tinycpu-owned assembly programs under `tests/riscv/`.
They use a minimal freestanding environment:

- `tests/riscv/env/linker.ld`: places `.text` at `0x0000_0000` and uses the
  64 KiB BRAM as program/data memory.
- `tests/riscv/env/crt0.S`: initializes `sp` to the top of BRAM and calls
  `test_main`.
- `tests/riscv/env/tinycpu_test_macros.S`: defines `TEST_PASS`,
  `TEST_FAIL`, `CHECK_EQ`, `CHECK_REG`, and related check macros.

The ISA tests use CPU-side dmem MMIO result registers in the normal
`0x1000_0000 - 0x1000_0FFF` MMIO page:

| Address | Name | Meaning |
| --- | --- | --- |
| `0x1000_0FF0` | `TEST_STATUS` | `0 = idle`, `1 = pass`, other nonzero = fail |
| `0x1000_0FF4` | `TEST_CODE` | Optional failing test/debug code |

The build flow detects `riscv64-unknown-elf-*` or `riscv32-unknown-elf-*` and
generates `.elf`, `.bin`, `.hex`, and `.dump` outputs under the ignored
`build/riscv-tests/` directory.

The external `riscv-tests` repository is used only as a coverage reference and
is not vendored. The current claim is selected rv32ui-style and rv32um-style
simulation coverage.

## Selected rv32ui-Style Coverage

| Group | Instructions / cases | Status | Notes |
| --- | --- | --- | --- |
| Basic ALU | `add`, `addi`, `sub`, `and`, `andi`, `or`, `ori`, `xor`, `xori` | PASS | Register/immediate ALU coverage. |
| Shifts | `sll`, `slli`, `srl`, `srli`, `sra`, `srai` | PASS | Logical/arithmetic shifts and shamt behavior. |
| Comparisons | `slt`, `slti`, `sltu`, `sltiu` | PASS | Signed and unsigned compare. |
| Upper immediates | `lui`, `auipc` | PASS | U-type immediate and PC-relative add. |
| Jumps | `jal`, `jalr` | PASS | PC+4 link and JALR target masking. |
| Branches | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` | PASS | Taken/not-taken and flush behavior. |
| Loads | `lw`, `lb`, `lbu`, `lh`, `lhu` | PASS | Sign/zero extension and little-endian behavior. |
| Stores | `sw`, `sb`, `sh` | PASS | Byte write strobes and store data path. |
| Pipeline hazards | ALU-use, load-use, store-data, branch flush | PASS | Selected pipeline-specific cases. |

## Selected rv32um-Style Coverage

| Group | Instructions / cases | Status | Notes |
| --- | --- | --- | --- |
| Low multiply | `mul` | PASS | Low 32-bit result. |
| High multiply | `mulh`, `mulhsu`, `mulhu` | PASS | Signed/signed, signed/unsigned, unsigned/unsigned high result. |
| Signed divide | `div`, `rem` | PASS | Signed quotient and remainder behavior. |
| Unsigned divide | `divu`, `remu` | PASS | Unsigned quotient and remainder behavior. |
| Divide by zero | `div`, `divu`, `rem`, `remu` edge cases | PASS | RISC-V-defined divide-by-zero behavior. |
| Signed overflow | `INT_MIN / -1` | PASS | RISC-V-defined signed overflow behavior. |
| M pipeline hazards | M-result to ALU/store/branch, back-to-back M ops | PASS | Multi-cycle M-unit interaction with pipeline. |

## Not Claimed

- No full RISC-V architectural compliance claim.
- No official `riscv-tests`, `riscv-arch-test`, or RISCOF claim.
- CSR/trap/interrupt behavior is not claimed unless explicitly implemented and
  tested.
- Misaligned trap behavior is not claimed unless explicitly implemented and
  tested.
- Invalid instruction behavior is not claimed unless explicitly implemented and
  tested.
- PYNQ/Jupyter program-loading demo is planned for v0.7.

## Recommended Roadmap

- Realign or retire older v0.5 directed/grid expectations now that v0.6 has
  focused pipeline and ISA-style coverage.
- Add invalid instruction, bus error, and misaligned access tests once the trap
  behavior is specified.
- Expand selected ISA-style tests only when the clean-room scope and expected
  behavior are documented.
