# Verification

This page tracks verification coverage for the current
`v1.0-stable-rv32im-pipeline-core` release candidate.

tinycpu uses selected clean-room simulation tests for RV32I/RV32M behavior and
focused cocotb regressions for BRAM, AXI-Lite loader/control, MMIO, and
pipeline behavior. This is not a full RISC-V architectural compliance claim.
PYNQ/Jupyter, framebuffer, and TinyTetris tests remain demo-path regressions
outside the core v1.0 stability claim unless real board validation evidence is
added.

## How To Run

```sh
make -C sim/cocotb test-all
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
make -C sim/cocotb test-riscv-isa
make -C sim/cocotb test-v10-stable
make -C sim/cocotb test-v07-loader-mirror
make -C sim/cocotb test-v08-framebuffer-mirror
make -C sim/cocotb test-v09-host-input
make -C sim/cocotb test-v09-interactive-io
make -C sim/cocotb test-v09-tetris-smoke
```

`test-v10-stable` is the v1.0 stable release aggregate and the GitHub Actions
entry point. It includes the selected rv32ui-style and rv32um-style aggregates,
so CI does not need a separate `test-riscv-isa` step. `test-all` is an alias
for `test-v10-stable`. Some target names retain their historical `v0.x`
prefixes because they mark when that coverage was introduced.

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
| `test-v07-loader-mirror` | PS-visible test status/code mirrors | PASS |
| `test-v08-framebuffer-mirror` | PS-visible framebuffer/status mirrors | PASS |
| `test-v09-host-input` | Generic host-to-CPU input path | PASS |
| `test-v09-interactive-io` | Generic app output/mirror path | PASS |
| `test-v09-tetris-smoke` | TinyTetris starts and draws through mirrors | PASS |
| `test-riscv-smoke` | Minimal RISC-V ISA smoke test | PASS |
| `test-rv32ui` | Selected rv32ui-style RV32I tests | PASS |
| `test-rv32um` | Selected rv32um-style RV32M tests | PASS |
| `test-v10-stable` | v1.0 stable CI/release aggregate | PASS |

The v0.7/v0.8/v0.9 loader mirror, framebuffer, host-input, interactive I/O,
and TinyTetris targets remain available as demo-path regressions. They are not
part of the v1.0 core stability claim. The older v0.5 directed and grid
firmware targets remain available as individual regression targets outside the
v1.0 stable aggregate.

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

The AXI-Lite loader/control slave exposes read-only PS-visible mirrors at
loader offsets `0x10010` and `0x10014`. The v0.9 interactive path also exposes
generic `APP_STATUS`, `APP_VALUE0`, `APP_VALUE1`, `FRAME_COUNTER`, a host input
write register, and a packed 256-byte framebuffer mirror at loader offsets
`0x10018`, `0x1001C`, `0x10020`, `0x10024`, `0x10030`, and
`0x10100 - 0x101FF`. These are intentionally separate from the CPU-side
`0x1000_xxxx` address space and are intended for the PYNQ/Jupyter
loader/display/input flow.

The framebuffer mirror test verifies little-endian packing, including the
pattern `01 02 03 04` reading as `0x04030201` at loader offset `0x10100`.

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

## v1.0 Pipeline Claim Trace

| Claim area | Covered by |
| --- | --- |
| ALU result used immediately by ALU | `test-v06-forwarding`, selected rv32ui ALU tests |
| ALU result used by branch | selected rv32ui branch/compare tests |
| ALU result used as store data | `test-v06-forwarding` |
| Load result used by ALU | `test-v06-load-use` |
| Load result used by branch | `test-v06-load-use` |
| Load result used as store address | `test-v06-load-use` |
| Load result used as store data | `test-v06-load-use` |
| Branch taken flush prevents wrong-path side effects | `test-v06-branch-flush`, selected rv32ui branch tests |
| JAL/JALR flush prevents wrong-path side effects | `test-v06-branch-flush`, selected rv32ui jump tests |
| Mul/div result used immediately by ALU/store/branch | `test-rv32um` through `m_pipeline` |
| Back-to-back RV32M instructions | `test-rv32um` through `m_pipeline` |
| `x0` is never written | selected rv32ui and rv32um tests |
| Byte/halfword load/store endian and strobes | `test-v06-bram`, selected rv32ui load/store tests, store-channel checks in `test_riscv_isa.py` |

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
- PYNQ/Jupyter framebuffer and TinyTetris display paths are implemented as
  source-level demo paths, but real board execution and screenshot/GIF evidence
  are not claimed yet.
- TinyTetris is covered by a short simulation smoke test, not a full gameplay
  verification suite.

## Recommended Roadmap

- Realign or retire older v0.5 directed/grid expectations now that the current
  pipeline has focused pipeline and ISA-style coverage.
- Add invalid instruction, bus error, and misaligned access tests once the trap
  behavior is specified.
- Expand selected ISA-style tests only when the clean-room scope and expected
  behavior are documented.
