# Verification

This page tracks the current verification coverage for
`v0.6-pipeline-bram-loader`.

## Existing Tests

- GPIO SoC smoke test: `make -C sim/cocotb test-v03-gpio`.
- Firmware GPIO test: `make -C sim/cocotb test-v04-firmware-gpio`.
- RV32M mul/div unit test: `make -C sim/cocotb test-v05-muldiv`.
- RISC-V ISA smoke pass/fail protocol test:
  `make -C sim/cocotb test-riscv-smoke`.
- Selected rv32ui-style ISA subset:
  `make -C sim/cocotb test-rv32ui`.
- Selected rv32um-style ISA subset:
  `make -C sim/cocotb test-rv32um`.
- RV32I directed ALU/immediate/jump/`x0` test:
  `make -C sim/cocotb test-v05-rv32i-directed`.
- Branch/load-store edge test:
  `make -C sim/cocotb test-v05-branch-load-store`.
- RV32IM grid math firmware test:
  `make -C sim/cocotb test-v05-rv32im-grid`.

Current local v0.6 status:

- `make -C sim/cocotb test-v03-gpio` passes with the pipelined core and
  unified BRAM/MMIO SoC.
- `make -C sim/cocotb test-v06-bram` passes.
- `make -C sim/cocotb test-v06-axil-loader` passes.
- `make -C sim/cocotb test-v06-pipeline-overlap` passes.
- `make -C sim/cocotb test-v06-forwarding` passes.
- `make -C sim/cocotb test-v06-branch-flush` passes.
- `make -C sim/cocotb test-v06-load-use` passes after the conservative
  load-use stall fix.
- `make -C sim/cocotb test-v06-pipeline` passes the v0.6 BRAM, loader,
  overlap, forwarding, load-use, and branch-flush suite.
- `make -C sim/cocotb test-riscv-smoke` passes the tinycpu-owned smoke add
  test and confirms a deliberate failing test reports a non-pass status.
- `make -C sim/cocotb test-rv32ui` passes the selected RV32I clean-room test
  subset listed below.
- `make -C sim/cocotb test-rv32um` passes the selected RV32M clean-room test
  subset listed below.
- `make -C sim/cocotb test-all` is the CI aggregate for this branch and runs
  GPIO smoke, C GPIO firmware, standalone RV32M mul/div, the v0.6 pipeline
  suite, and the RISC-V ISA smoke target.
- The older v0.5 directed and grid firmware targets remain individually
  runnable. They are kept separate from `test-all` while their expectations are
  reviewed against the v0.6 pipeline/BRAM architecture.

## RISC-V ISA Test Infrastructure

The ISA-style tests are tinycpu-owned assembly programs under `tests/riscv/`.
They use a minimal freestanding environment:

- `tests/riscv/env/linker.ld`: places `.text` at `0x0000_0000` and uses the
  64 KiB BRAM as program/data memory.
- `tests/riscv/env/crt0.S`: initializes `sp` to the top of BRAM and calls
  `test_main`.
- `tests/riscv/env/tinycpu_test_macros.S`: defines `TEST_PASS`,
  `TEST_FAIL`, `CHECK_EQ`, and `CHECK_REG`.

The test-only MMIO convention is:

| Address | Meaning |
| --- | --- |
| `0x8000_0000` | `MMIO_TEST_STATUS`; write `1` for pass, non-`1` for fail |
| `0x8000_0004` | `MMIO_TEST_CODE`; optional debug/fail code |

The build flow detects `riscv64-unknown-elf-*` or `riscv32-unknown-elf-*` and
generates `.elf`, `.bin`, `.hex`, and `.dump` outputs under
`build/riscv-tests/`.

Run the infrastructure and selected subsets with:

```sh
make -C sim/cocotb build-riscv-tests
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
make -C sim/cocotb test-riscv-isa
```

The external `riscv-tests` repository is used only as a coverage reference and
is not vendored. The current claim is selected rv32ui-style and rv32um-style
simulation coverage, not full RISC-V compliance.

| Instruction group | Tests | Status | Notes |
| --- | --- | --- | --- |
| Smoke | `smoke_add`, `fail_status` | PASS | Confirms pass write and deliberate fail reporting. |
| ALU | `add/addi/sub/and/andi/or/ori/xor/xori` | PASS | Includes immediate next-use, signed wraparound, source/destination aliasing, and `x0` checks. |
| Shift | `sll/slli/srl/srli/sra/srai` | PASS | Covers logical and arithmetic shifts. |
| Compare | `slt/slti/sltu/sltiu` | PASS | Covers signed and unsigned comparisons. |
| PC control | `lui/auipc/jal/jalr` | PASS | Checks link writeback and JALR bit-0 clearing. |
| Branch | `beq/bne/blt/bge/bltu/bgeu` | PASS | Includes taken flush, not-taken fallthrough, negative equality, and backward branch checks. |
| Load/store | `lw/lb/lbu/lh/lhu/sw/sb/sh` | PASS | Covers little-endian loads, byte/halfword sign and zero extension, offset addressing, and store dmem address/data/strobes. |
| M extension | `mul/mulh/mulhsu/mulhu/div/divu/rem/remu` | PASS | Covers signed, unsigned, divide-by-zero, signed overflow, remainder sign behavior, source/destination aliasing, zero-destination behavior, and selected high-product edge cases. |
| M pipeline stress | `m_pipeline` | PASS | Covers M-result consumers through ALU, store, branch, and back-to-back M operations. |

## Missing Tests

- External `riscv-tests` compatibility harness.
- Full RV32I architectural compliance matrix.
- Misaligned load/store trap behavior.
- Invalid instruction behavior.
- Invalid AXI address and response handling.
- CSRs, privileged instructions, interrupts, exceptions, `ECALL`, and
  `EBREAK`.

## Recommended Roadmap

- Realign or retire older v0.5 directed/grid expectations now that v0.6 has
  focused pipeline and ISA-style coverage.
- Add invalid instruction, bus error, and misaligned access tests once the trap
  behavior is specified.
- Expand selected ISA-style tests only when the clean-room scope and expected
  behavior are documented.
