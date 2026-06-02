# Verification

This page tracks the current verification coverage for
`v0.6-pipeline-bram-loader` work in progress.

## Existing Tests

- GPIO SoC smoke test: `make -C sim/cocotb test-v03-gpio`.
- Firmware GPIO test: `make -C sim/cocotb test-v04-firmware-gpio`.
- RV32M mul/div unit test: `make -C sim/cocotb test-v05-muldiv`.
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
- `make -C sim/cocotb test-all` is the CI aggregate for this branch and runs
  GPIO smoke, C GPIO firmware, standalone RV32M mul/div, and the v0.6 pipeline
  suite.
- `make -C sim/cocotb test-v05-rv32i-directed` currently fails in the
  JAL/JALR/control-flow tail.
- `make -C sim/cocotb test-v05-branch-load-store` currently fails early in the
  branch/load-store directed program.

## Missing Tests

- Full RV32I per-instruction directed matrix.
- More branch/jump edge cases, including negative offsets and link register
  checks.
- More load/store byte-enable combinations and unaligned halfword policy
  coverage.
- Signed/unsigned comparison edge cases.
- Divide-by-zero.
- `INT_MIN / -1` signed overflow.
- Invalid instruction behavior.
- Invalid AXI address and response handling.

## Recommended Roadmap

- Finish v0.6 control-hazard and store/load forwarding fixes.
- Add explicit pipeline overlap, forwarding, load-use, branch-flush, BRAM, and
  AXI-Lite loader cocotb tests.
- Stronger ISA tests.
