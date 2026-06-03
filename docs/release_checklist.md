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
make -C sim/cocotb test-riscv-isa
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

## v0.8-jupyter-framebuffer-demo

Required before tagging:

- v0.6/v0.7 simulation tests still pass.
- `test-v08-framebuffer-mirror` passes.
- `programs/framebuffer_demo` builds ELF, HEX, and DUMP artifacts locally.
- `docs/memory_map.md` documents CPU-side framebuffer/status registers and
  loader-side framebuffer mirror offsets.
- Jupyter can load the framebuffer demo through the AXI-Lite loader.
- Jupyter can read and display the 10x20 framebuffer.
- No generated Vivado projects, bitstreams, `.hwh` files, screenshots, GIFs,
  ELF/BIN/HEX/DUMP artifacts, or `sim_build/` outputs are committed.

Suggested local validation:

```sh
make -C sim/cocotb test-all
make -C sim/cocotb test-riscv-isa
make -C sim/cocotb test-v07-loader-mirror
make -C sim/cocotb test-v08-framebuffer-mirror
make -C programs/framebuffer_demo
```

Demo media:

- Add a real board screenshot/GIF only after the PYNQ-Z2 overlay and notebook
  demo have run successfully on hardware.

## v0.9-jupyter-interactive-io-tetris-demo

Required before tagging:

- v0.6/v0.7/v0.8 simulation tests still pass.
- `test-v09-host-input` passes.
- `test-v09-interactive-io` passes.
- `test-v09-tetris-smoke` passes.
- `programs/interactive_demo` builds ELF, HEX, and DUMP artifacts locally.
- `programs/tetris` builds ELF, HEX, and DUMP artifacts locally.
- `fpga/vivado/build_pynq_axi_overlay.tcl` builds a bitstream and matching
  `.hwh`.
- Jupyter can write `HOST_INPUT`.
- tinycpu can read input and update app state.
- Jupyter can read framebuffer/status/score mirrors.
- TinyTetris is playable through Jupyter buttons.
- Real screenshot/GIF is added only after actual board success.

Suggested local validation:

```sh
make -C sim/cocotb test-all
make -C sim/cocotb test-riscv-isa
make -C sim/cocotb test-v08-framebuffer-mirror
make -C sim/cocotb test-v09-host-input
make -C sim/cocotb test-v09-interactive-io
make -C sim/cocotb test-v09-tetris-smoke
make -C programs/interactive_demo
make -C programs/tetris
```

Suggested Vivado validation on a machine with Vivado:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
```
