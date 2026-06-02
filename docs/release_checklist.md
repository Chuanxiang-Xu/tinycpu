# Release Checklist

## v0.6-pipeline-bram-isa-tests

Required before tagging:

- README current status matches RTL/docs.
- `docs/memory_map.md` includes CPU-side `TEST_STATUS` and `TEST_CODE`.
- `docs/verification.md` lists selected rv32ui/rv32um coverage.
- No generated files are committed.
- CI is green.
- The following local tests pass:

```sh
make -C sim/cocotb test-all
make -C sim/cocotb test-riscv-smoke
make -C sim/cocotb test-rv32ui
make -C sim/cocotb test-rv32um
```

Manual GitHub steps after merge:

- Add GitHub About description.
- Add GitHub topics.
- Create release tag.

Suggested GitHub About description:

```text
A clean-room educational RV32IM SoC for learning pipelined CPU design, MMIO, cocotb verification, and PYNQ-Z2 FPGA bring-up.
```

Suggested topics:

```text
riscv, rv32im, systemverilog, fpga, pynq-z2, cocotb, cpu, soc, vivado, axi-lite, computer-architecture, educational
```

Demo media:

- Board demo media can be added under `docs/images/` after a real PYNQ-Z2 run,
  for example `docs/images/pynqz2_led_demo.gif`.
- Do not add screenshots or GIFs unless they came from an actual run.
