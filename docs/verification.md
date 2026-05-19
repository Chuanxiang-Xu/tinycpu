# Verification

This page tracks the current verification coverage for
`v0.5-rv32im-m-extension`.

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

- v0.6 pipeline cleanup.
- Valid/bubble pipeline registers.
- Forwarding.
- Load-use stall.
- Branch flush.
- Stronger ISA tests.
