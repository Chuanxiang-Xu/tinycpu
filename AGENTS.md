# AGENTS.md

## Project identity

tinycpu is a clean-room educational RV32IM SoC for the PYNQ-Z2 FPGA board.

Current milestone: `v0.6-pipeline-bram-loader`.

The current CPU is an RV32IM-target educational overlapped pipeline core. It
uses IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers, simple
Harvard-style instruction/data memory ports, a unified 64 KiB BRAM in the SoC,
a dmem-side CPU-visible MMIO decoder, and an AXI-Lite loader/control slave at
the SoC boundary. The CPU no longer has its own AXI-Lite master.

Do not add private course code, private solution code, generated Vivado
projects, bitstreams, firmware binaries, or local reference directories.

## Repository rules

- Do not commit generated artifacts.
- Do not commit bitstreams.
- Do not commit firmware binaries.
- Do not commit local Vivado builds.
- Do not commit `.jou`, `.log`, `.Xil/`, `build/`, `sim_build/`,
  `results.xml`, `.elf`, `.bin`, or generated `.hex` files.
- Keep RTL clean-room and educational.
- Prefer simple SystemVerilog over clever abstractions.
- Keep Vivado projects reproducible from Tcl.
- Keep cocotb tests runnable from a fresh clone with `requirements.txt`.
- Document every reproducible build or test step in README, docs, or scripts.

## Build and test commands

Python setup:

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Default cocotb smoke test:

```sh
make -C sim/cocotb
```

Named cocotb tests:

```sh
make -C sim/cocotb test-v03-gpio
make -C sim/cocotb test-v04-firmware-gpio
make -C sim/cocotb test-v05-muldiv
make -C sim/cocotb test-v05-rv32i-directed
make -C sim/cocotb test-v05-branch-load-store
make -C sim/cocotb test-v05-rv32im-grid
make -C sim/cocotb test-v06-bram
make -C sim/cocotb test-v06-axil-loader
make -C sim/cocotb test-v06-pipeline-overlap
make -C sim/cocotb test-v06-forwarding
make -C sim/cocotb test-v06-load-use
make -C sim/cocotb test-v06-branch-flush
make -C sim/cocotb test-v06-pipeline
make -C sim/cocotb test-all
```

C demo build:

```sh
make -C programs/c_demo
```

RV32IM demo build:

```sh
make -C programs/rv32im_demo
```

Vivado Tcl build:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
```

## Documentation synchronization rule

After modifying RTL, Makefiles, Tcl scripts, programs, cocotb tests, the memory
map, ISA status, or milestone names, check and update these files as needed:

- `README.md`
- `docs/architecture.md`
- `docs/instruction_set.md`
- `docs/pipeline.md`
- `docs/simulation.md`
- `docs/roadmap.md`
- `docs/memory_map.md`
- `rtl/core/README.md`
- `AGENTS.md`

Every file modification must include a synchronized update to this root
`AGENTS.md`. Do not create `agent.md` or `Agent.md`.

## Maintenance log

### 2026-05-19 - unify v0.5 milestone narrative

Changed:

- `README.md`: rewrote the top-level status, quick start, demo descriptions,
  Vivado project name, bitstream path, and source-first policy around
  `v0.5-rv32im-m-extension`.
- `docs/architecture.md`: clarified the RV32IM SoC structure, serialized
  AXI-Lite control path, and project name.
- `docs/instruction_set.md`: documented RV32I implemented status, RV32M v0.5
  coverage, and unsupported instruction classes.
- `docs/pipeline.md`: clarified that v0.5 is stage-structured but serialized,
  not a fully overlapped five-stage pipeline.
- `docs/roadmap.md`: aligned v0.4, v0.5, and v0.6 candidate wording.
- `docs/baremetal_c.md`: separated the RV32I C GPIO demo from the RV32IM grid
  math demo.
- `rtl/core/README.md`: aligned core status with the v0.5 milestone.
- `programs/c_demo/Makefile`: changed the default `MARCH` to `rv32i`.
- `fpga/vivado/build_bitstream.tcl`: aligned generated status messages with
  the v0.5 project name and README bitstream path.
- `AGENTS.md`: expanded repository guidance into the required multi-line
  maintenance document.

Reason:

- Keep public documentation accurate and consistent with the current
  `v0.5-rv32im-m-extension` milestone without overstating the CPU as a fully
  overlapped pipeline.

Validation:

- Pending in this working batch.

Next:

- Run cocotb tests after the Makefile and CI updates are in place.

### 2026-05-19 - format documentation and build entry points

Changed:

- `README.md`: reformatted into readable Markdown sections, tables, command
  blocks, and links.
- `docs/*.md`: kept Markdown line lengths readable and command examples
  explicit.
- `sim/cocotb/Makefile`: kept recipe tabs and split long variable assignments
  across lines.
- `fpga/vivado/build_bitstream.tcl`: split variables and messages across
  readable Tcl lines.
- `AGENTS.md`: recorded formatting and synchronization rules.

Reason:

- Make the repository easier to review and maintain without changing intended
  build behavior.

Validation:

- Pending in this working batch.

Next:

- Verify Makefile targets still run after formatting.

### 2026-05-19 - add GitHub Actions CI

Changed:

- `.github/workflows/ci.yml`: added Ubuntu CI for checkout, system dependency
  install, Python dependency install, and cocotb tests.
- `README.md`: added the CI badge.
- `AGENTS.md`: recorded the CI entry point.

Reason:

- Run basic non-Vivado simulation tests automatically on push and pull request.

Validation:

- Pending local cocotb run.

Next:

- Confirm CI command matches local `sim/cocotb/Makefile` targets.

### 2026-05-19 - clarify cocotb test targets

Changed:

- `sim/cocotb/Makefile`: added `test-v03-gpio`,
  `test-v04-firmware-gpio`, `test-v05-muldiv`, `test-v05-rv32im-grid`, and
  `test-all` targets.
- `docs/simulation.md`: documented the named targets and firmware
  prerequisites.
- `README.md`: updated simulation command examples.
- `.github/workflows/ci.yml`: runs `make -C sim/cocotb test-all`.
- `AGENTS.md`: listed the named test commands.

Reason:

- Make local and CI simulation entry points discoverable and consistent.

Validation:

- Pending local cocotb run.

Next:

- Run the default smoke test and the expanded test target if toolchains are
  available.

### 2026-05-19 - improve README presentation

Changed:

- `README.md`: added badges, concise project description, current status,
  quick start, architecture overview, demo separation, and a clear pipeline
  warning.
- `AGENTS.md`: logged the README presentation update.

Reason:

- Make the GitHub landing page more professional and accurate for a v0.5
  teaching SoC repository.

Validation:

- Pending Markdown and command review.

Next:

- Check rendered Markdown structure and run available tests.

### 2026-05-19 - document verification coverage

Changed:

- `docs/verification.md`: added current tests, missing coverage, and
  recommended verification roadmap.
- `README.md`: linked to `docs/verification.md`.
- `AGENTS.md`: logged the verification documentation update.

Reason:

- Make current test coverage and known gaps visible without pretending all ISA
  behavior is already exhaustively verified.

Validation:

- Pending local cocotb run.

Next:

- Convert the missing coverage list into directed cocotb tests over time.

### 2026-05-19 - clean remaining source-first metadata

Changed:

- `programs/c_demo/README.md`: corrected the default C GPIO demo flags to
  `-march=rv32i -mabi=ilp32`.
- `.gitignore`: added RV32IM demo generated firmware side products.
- `NOTICE.md`: aligned the public project name and serialized-core wording.
- `AGENTS.md`: recorded the additional metadata cleanup.

Reason:

- Remove stale RV32IM wording from the RV32I C demo and keep generated firmware
  outputs out of version control.

Validation:

- Pending local cocotb run.

Next:

- Run available tests and update this log with final validation results.

### 2026-05-19 - fix cocotb default target duplication

Changed:

- `sim/cocotb/Makefile`: replaced the custom `all` target with
  `.DEFAULT_GOAL := test-v03-gpio` so plain `make` runs the smoke test once
  without merging with cocotb's included `all: sim` target.
- `AGENTS.md`: recorded the Makefile correction.

Reason:

- The first local smoke-test run passed but executed the same default test
  twice, which would waste local and CI time.

Validation:

- `make -C sim/cocotb` passed before this correction but duplicated the smoke
  test.

Next:

- Re-run `make -C sim/cocotb` and then run the expanded test targets.

### 2026-05-19 - isolate cocotb build directories

Changed:

- `sim/cocotb/Makefile`: assigned a separate `SIM_BUILD` directory to each
  named test target so SoC and `tinycpu_muldiv` simulations do not reuse stale
  compiled top-levels.
- `AGENTS.md`: recorded the test isolation fix.

Reason:

- `make -C sim/cocotb test-all` passed the v0.3 and v0.4 tests, then failed
  the v0.5 mul/div test because the shared `sim_build` still contained a
  `tinycpu_soc` simulation image.

Validation:

- `make -C sim/cocotb` passed after the default-target fix.
- `make -C sim/cocotb test-all` failed before this correction at
  `test-v05-muldiv` with `Couldn't find root handle tinycpu_muldiv`.

Next:

- Re-run `make -C sim/cocotb test-all`.

### 2026-05-19 - rebuild firmware when Makefiles change

Changed:

- `programs/c_demo/Makefile`: added `Makefile` as a prerequisite for
  `firmware.elf` so `MARCH` changes trigger a rebuild.
- `programs/rv32im_demo/Makefile`: added the same firmware dependency.
- `AGENTS.md`: recorded the firmware rebuild dependency fix.

Reason:

- Local validation showed an existing `programs/c_demo/firmware.hex` could be
  reused after changing the default C demo ISA flags because the firmware target
  did not depend on its Makefile.

Validation:

- `make -C sim/cocotb test-all` passed before this dependency fix after the
  isolated `SIM_BUILD` change.

Next:

- Rebuild both firmware demos and re-run the full cocotb test suite.

### 2026-05-19 - final local validation

Changed:

- `AGENTS.md`: updated the maintenance log with final validation results for
  this repository cleanup pass.

Reason:

- Record the commands that were actually run after the documentation,
  Makefile, Tcl, CI, and verification updates.

Validation:

- `python3 -m venv .venv` passed.
- `.venv/bin/python -m pip install -r requirements.txt` passed with cocotb
  already installed in the local virtual environment.
- `make -C sim/cocotb` passed with `TESTS=1 PASS=1 FAIL=0`.
- `make -B -C programs/c_demo` passed and rebuilt with `-march=rv32i`.
- `make -B -C programs/rv32im_demo` passed and rebuilt with `-march=rv32im`.
- `make -C sim/cocotb test-all` passed all four cocotb tests:
  `test-v03-gpio`, `test-v04-firmware-gpio`, `test-v05-muldiv`, and
  `test-v05-rv32im-grid`.
- Vivado bitstream generation was not run because `vivado` is not available in
  this local environment.

Next:

- Run the GitHub Actions workflow on the remote branch and run the Vivado Tcl
  flow on a machine with Vivado installed.

### 2026-05-19 - add RV32I directed cocotb coverage

Changed:

- `sim/cocotb/tinycpu_test_programs.py`: added a small source generator for
  temporary RV32I RAM hex programs used by cocotb tests.
- `sim/cocotb/test_v05_rv32i_directed.py`: added directed ALU, immediate,
  jump, and `x0` suppression coverage.
- `sim/cocotb/test_v05_branch_load_store.py`: added branch direction and
  byte/halfword load-store edge coverage.
- `sim/cocotb/Makefile`: added `test-v05-rv32i-directed` and
  `test-v05-branch-load-store`; included both in `test-all`.
- `README.md`: listed the new simulation targets.
- `docs/simulation.md`: documented the generated-hex directed tests.
- `docs/verification.md`: moved initial RV32I directed and branch/load-store
  coverage into the existing-tests section and narrowed the remaining gaps.
- `AGENTS.md`: recorded the new test coverage and validation status.

Reason:

- Start closing the verification gaps documented for RV32I directed behavior,
  branch handling, and load/store byte-enable behavior without committing
  generated `.hex` artifacts.

Validation:

- `command -v vivado` failed, so the Vivado Tcl bitstream flow could not be run
  in this local environment.
- GitHub Actions public API showed run `26126543631` on `main` completed with
  conclusion `success`; its `cocotb` job and `Install system dependencies`
  step also completed successfully.
- `python3 sim/cocotb/tinycpu_test_programs.py rv32i-directed /tmp/rv32i.hex`
  passed.
- `python3 sim/cocotb/tinycpu_test_programs.py branch-load-store /tmp/branch.hex`
  passed.
- `make -C sim/cocotb test-v05-rv32i-directed` passed with
  `TESTS=1 PASS=1 FAIL=0`.
- `make -C sim/cocotb test-v05-branch-load-store` passed with
  `TESTS=1 PASS=1 FAIL=0`.
- `make -C sim/cocotb test-all` passed the expanded six-test suite:
  `test-v03-gpio`, `test-v04-firmware-gpio`, `test-v05-muldiv`,
  `test-v05-rv32i-directed`, `test-v05-branch-load-store`, and
  `test-v05-rv32im-grid`.

Next:

- Push the follow-up test coverage branch and confirm the expanded GitHub
  Actions run.

### 2026-06-02 - start v0.6 pipeline BRAM loader migration

Changed:

- `rtl/core/tinycpu_core_pipe.sv`: added a first-cut overlapped IF/ID, ID/EX,
  EX/MEM, and MEM/WB pipeline core with Harvard-style imem/dmem ports,
  forwarding hooks, load-use stall policy, branch flush policy, and RV32M unit
  integration.
- `rtl/core/tinycpu_forwarding.sv`: added EX/MEM and MEM/WB forwarding select
  logic.
- `rtl/mem/tinycpu_tdp_bram.sv`: added a reusable 64 KiB byte-writeable
  dual-port memory used as unified program/data RAM.
- `rtl/soc/tinycpu_dmem_decoder.sv`: added dmem-side RAM/MMIO decoding for
  BRAM, LED, switch, and future game/framebuffer registers at `0x1000_0000`.
- `rtl/bus/tinycpu_axil_loader.sv`: added an AXI-Lite RAM loader and
  CPU reset/halt/boot control block.
- `rtl/soc/tinycpu_soc.sv`: rewired the SoC around `tinycpu_core_pipe`,
  unified BRAM, dmem MMIO, and the loader/control slave.
- `rtl/board/pynqz2_top.sv`: tied the loader AXI-Lite interface idle for the
  current pin-level PYNQ-Z2 top.
- `sim/cocotb/Makefile`: added the new pipeline, BRAM, loader, and decoder RTL
  sources.
- `programs/*` and `sim/cocotb/tinycpu_test_programs.py`: moved GPIO constants
  from `0x4000_0000` to `0x1000_0000`.
- `README.md`, `docs/architecture.md`, `docs/pipeline.md`,
  `docs/memory_map.md`, `docs/simulation.md`, `docs/verification.md`,
  `docs/roadmap.md`, `programs/README.md`, and `programs/c_demo/README.md`:
  documented the v0.6 work-in-progress architecture, memory map, loader map,
  and current limitations.
- `fpga/vivado/create_project.tcl` and `fpga/vivado/build_bitstream.tcl`:
  included new RTL directories and updated v0.6 project/status wording.

Reason:

- Begin moving tinycpu from the serialized AXI-Lite-master core toward an
  educational overlapped RV32IM pipeline with a unified BRAM that appears as
  Harvard instruction/data memory to the CPU and can be loaded by PS/Jupyter
  through AXI-Lite while the CPU is halted or reset.

Validation:

- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v03-gpio` passed with the new
  pipelined core and unified BRAM/MMIO SoC.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v05-rv32i-directed` failed in
  the JAL/JALR/control-flow tail.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v05-branch-load-store` failed
  early in the branch/load-store directed program.
- Vivado bitstream generation was not run in this local environment.

Next:

- Fix remaining control-hazard and forwarding/load-store issues, restore a
  fully synchronous instruction BRAM path, and add the dedicated pipeline,
  BRAM, and AXI-Lite loader cocotb tests before claiming v0.6 complete.

### 2026-06-02 - add v0.6 pipeline and loader cocotb tests

Changed:

- `sim/cocotb/tinycpu_test_programs.py`: added generators for
  `pipeline-overlap`, `pipeline-forwarding`, `pipeline-load-use`, and
  `pipeline-branch-flush` temporary RAM programs.
- `sim/cocotb/test_v06_tdp_bram.py`: added BRAM byte-write, dual-port read,
  and same-cycle port access coverage.
- `sim/cocotb/test_v06_axil_loader.py`: added AXI-Lite loader coverage for
  loading firmware into BRAM while halted/reset, setting `boot_pc`, starting
  the CPU, checking status, and blocking live RAM writes.
- `sim/cocotb/test_v06_pipeline_overlap.py`: added a pipeline overlap smoke
  test that checks multiple valid stage bits are high concurrently.
- `sim/cocotb/test_v06_forwarding.py`: added EX/MEM, MEM/WB, priority, and
  store-data forwarding coverage.
- `sim/cocotb/test_v06_load_use.py`: added load-use coverage for ALU, store
  address, store data, and branch compare dependencies.
- `sim/cocotb/test_v06_branch_flush.py`: added taken branch, not-taken branch,
  JAL, and JALR flush coverage.
- `sim/cocotb/Makefile`: added individual `test-v06-*` targets and a
  `test-v06-pipeline` aggregate target. The v0.6 aggregate is intentionally
  separate from `test-all` while broader v0.5-era regressions are still being
  realigned with the pipeline core.
- `README.md`, `docs/simulation.md`, `docs/verification.md`, and `AGENTS.md`:
  documented the new test targets and current pass/fail status.

Reason:

- Make the v0.6 architecture change testable with explicit coverage for the
  unified BRAM, AXI-Lite firmware loader, pipeline overlap, forwarding,
  load-use stalls, and branch/jump flushing.

Validation:

- `python3 sim/cocotb/tinycpu_test_programs.py pipeline-overlap /tmp/pipeline-overlap.hex`
  passed.
- `python3 sim/cocotb/tinycpu_test_programs.py pipeline-forwarding /tmp/pipeline-forwarding.hex`
  passed.
- `python3 sim/cocotb/tinycpu_test_programs.py pipeline-load-use /tmp/pipeline-load-use.hex`
  passed.
- `python3 sim/cocotb/tinycpu_test_programs.py pipeline-branch-flush /tmp/pipeline-branch-flush.hex`
  passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-bram` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-axil-loader` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline-overlap` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-forwarding` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-branch-flush` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-load-use` failed before
  the follow-up RTL fix with `load-use program reported failure`, confirming
  the remaining load-use/store dependency bug was covered by a regression.

Next:

- Fix the RTL issue exposed by `test-v06-load-use`, then run
  `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline`.

### 2026-06-02 - fix v0.6 load-use/store dependency stall

Changed:

- `rtl/core/tinycpu_core_pipe.sv`: extended the load-use hazard detector to
  keep IF/ID frozen while a matching load is in ID/EX, EX/MEM, or MEM/WB.
- `sim/cocotb/test_v06_load_use.py`: removed temporary diagnostic logging after
  the failing dependency path was fixed.
- `README.md`, `docs/verification.md`, and `AGENTS.md`: updated v0.6
  load-use status from known failing to passing.

Reason:

- The dmem path and writeback timing in the current first-cut pipeline require
  holding a dependent instruction until the load has passed through MEM/WB, so
  store-address, store-data, branch-compare, and ALU users observe the loaded
  value reliably.

Validation:

- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-load-use` passed.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline` passed all six
  v0.6 targets: BRAM, pipeline overlap, forwarding, load-use, branch flush, and
  AXI-Lite loader.

Next:

- Continue realigning the older v0.5 directed and firmware regressions with
  the v0.6 pipeline/BRAM architecture.

### 2026-06-02 - consolidate AXI-Lite RTL under bus directory

Changed:

- `rtl/bus/axil_gpio.sv`, `rtl/bus/axil_interconnect.sv`, and
  `rtl/bus/axil_ram.sv`: moved the legacy AXI-Lite support modules from
  `rtl/axil/` into `rtl/bus/`.
- `sim/cocotb/Makefile`: updated cocotb source paths to the consolidated
  `rtl/bus/` directory.
- `fpga/vivado/create_project.tcl`: removed the old `rtl/axil/*.sv` glob and
  kept `rtl/bus/*.sv` as the single AXI-Lite/bus source directory.
- `README.md` and `rtl/board/pynqz2_top.sv`: updated repository layout
  wording to describe `rtl/bus/` and `rtl/mem/`.

Reason:

- Keep the v0.6 source tree easier to scan by grouping AXI-Lite RAM/GPIO,
  interconnect, and loader/control modules under one bus-facing directory.

Validation:

- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline` passed after
  the directory consolidation.
- `PATH=.venv/bin:$PATH make -C sim/cocotb test-v03-gpio` passed after the
  directory consolidation.

Next:

- Commit, push, and open a draft GitHub PR for the v0.6 pipeline/BRAM/loader
  update.

### 2026-06-02 - realign CI aggregate with v0.6 tests

Changed:

- `sim/cocotb/Makefile`: changed `test-all` to run the current branch
  aggregate: GPIO smoke, C GPIO firmware, standalone RV32M mul/div, and
  `test-v06-pipeline`.
- `README.md`, `docs/simulation.md`, `docs/verification.md`, and `AGENTS.md`:
  documented that the older v0.5 directed/grid targets remain individually
  runnable while they are being realigned with the v0.6 pipeline core.

Reason:

- GitHub Actions failed because CI still used `test-all`, and that aggregate
  still included v0.5 directed/grid regressions that are known to need v0.6
  pipeline expectation updates.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the updated aggregate: `test-v03-gpio`, `test-v04-firmware-gpio`,
  `test-v05-muldiv`, `test-v06-bram`, `test-v06-pipeline-overlap`,
  `test-v06-forwarding`, `test-v06-load-use`, `test-v06-branch-flush`, and
  `test-v06-axil-loader`.

Next:

- Commit, push, and confirm the GitHub Actions rerun.

### 2026-06-02 - add clean-room RISC-V ISA simulation tests

Changed:

- `tests/riscv/env/linker.ld`, `tests/riscv/env/crt0.S`, and
  `tests/riscv/env/tinycpu_test_macros.S`: added a freestanding RV32IM
  simulation environment with `_start`, a 64 KiB BRAM memory layout, and
  `MMIO_TEST_STATUS`/`MMIO_TEST_CODE` pass/fail macros.
- `tests/riscv/rv32ui/*.S`: added tinycpu-owned rv32ui-style tests for smoke,
  ALU, shifts, comparisons, PC control, branches, and load/store coverage.
- `tests/riscv/rv32um/*.S`: added tinycpu-owned rv32um-style tests for multiply,
  divide, remainder, edge cases, and a pending combined M pipeline stress
  source.
- `sim/cocotb/build_riscv_tests.py`: added toolchain detection and ELF, BIN,
  HEX, and DUMP generation under `build/riscv-tests/`.
- `sim/cocotb/riscv_test_runner.py` and `sim/cocotb/test_riscv_isa.py`: added
  a generic BRAM-preload cocotb runner that resets the SoC, watches dmem MMIO
  pass/fail writes, records fail codes, and checks selected store
  address/data/strobe behavior.
- `sim/cocotb/Makefile`: added `build-riscv-tests`, `test-riscv-smoke`,
  `test-rv32ui`, `test-rv32um`, and `test-riscv-isa`; included only the
  stable RISC-V smoke target in `test-all`.
- `rtl/core/tinycpu_core_pipe.sv`: added a conservative decode-stage hold for
  immediate consumers of an ID/EX M-extension operation.
- `README.md`, `docs/simulation.md`, `docs/instruction_set.md`,
  `docs/verification.md`, `rtl/core/README.md`, and `AGENTS.md`: documented the
  ISA simulation flow, selected pass status, and unsupported/pending coverage.

Reason:

- Provide a reusable clean-room RISC-V ISA simulation harness before board or
  Jupyter-loader work, while avoiding vendoring the external `riscv-tests`
  repository or claiming full compliance.

Validation:

- `python3 sim/cocotb/build_riscv_tests.py` passed and generated ELF, BIN,
  HEX, and DUMP artifacts under ignored `build/riscv-tests/`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-smoke`
  passed the `smoke_add` pass case and the expected-fail `fail_status` case.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed the selected rv32ui-style subset: `smoke_add`, ALU, shift,
  comparison, PC-control, branch, `lw`, and store-channel `sw`/`sb`/`sh`
  tests.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed the selected rv32um-style subset: `mul`, `mulh`, `mulhsu`, `mulhu`,
  `div`, `divu`, `rem`, and `remu`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the CI aggregate with GPIO smoke, C GPIO firmware, standalone RV32M
  mul/div, the v0.6 BRAM/pipeline/loader suite, and the RISC-V ISA smoke
  target.

Next:

- Completed in the follow-up Phase 1-3 ISA aggregate coverage log below.

### 2026-06-02 - complete Phase 1-3 ISA aggregate coverage

Changed:

- `rtl/core/tinycpu_regfile.sv`: added same-cycle writeback bypass on both
  read ports so ID-stage reads observe WB-stage results without an extra
  conservative stall.
- `tests/riscv/env/tinycpu_test_macros.S`: replaced numeric local labels inside
  pass/fail/check macros with unique macro-local labels.
- `tests/riscv/rv32ui/lb.S`, `lbu.S`, `lh.S`, and `lhu.S`: moved load targets
  away from `ra`/`sp` into ordinary test registers.
- `tests/riscv/rv32um/m_pipeline.S`: avoided pass/fail macro temporary
  registers for M-result values and replaced a numeric branch label with a
  named label.
- `sim/cocotb/riscv_test_runner.py` and `test_riscv_isa.py`: added best-effort
  register snapshots to RISC-V ISA failure messages.
- `sim/cocotb/Makefile`: added `lb`, `lbu`, `lh`, `lhu`, and `m_pipeline` to
  the selected rv32ui/rv32um aggregate targets.
- `README.md`, `docs/simulation.md`, `docs/instruction_set.md`,
  `docs/verification.md`, `rtl/core/README.md`, and `AGENTS.md`: updated the
  selected ISA test status from partial to passing while keeping the explicit
  non-compliance-claim wording.

Reason:

- Finish the strict Phase 1-3 RISC-V ISA simulation acceptance criteria by
  bringing byte/halfword load tests and the combined M pipeline dependency
  stress test into the normal simulation aggregates.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb build-riscv-tests`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb sim COCOTB_TEST_MODULES=test_riscv_isa TOPLEVEL=tinycpu_soc RAM_HEX=../../build/riscv-tests/rv32ui/lb/lb.hex RAM_INIT_WORDS=256 RISCV_TEST_NAME=rv32ui/lb RISCV_TEST_TIMEOUT=20000 SIM_BUILD=sim_build/test-rv32ui-lb-fixed`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb sim COCOTB_TEST_MODULES=test_riscv_isa TOPLEVEL=tinycpu_soc RAM_HEX=../../build/riscv-tests/rv32ui/lbu/lbu.hex RAM_INIT_WORDS=256 RISCV_TEST_NAME=rv32ui/lbu RISCV_TEST_TIMEOUT=20000 SIM_BUILD=sim_build/test-rv32ui-lbu-fixed`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb sim COCOTB_TEST_MODULES=test_riscv_isa TOPLEVEL=tinycpu_soc RAM_HEX=../../build/riscv-tests/rv32um/m_pipeline/m_pipeline.hex RAM_INIT_WORDS=256 RISCV_TEST_NAME=rv32um/m_pipeline RISCV_TEST_TIMEOUT=20000 SIM_BUILD=sim_build/test-rv32um-m_pipeline-fixed2`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed with the expanded selected RV32I aggregate, including `lb`, `lbu`,
  `lh`, and `lhu`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed with the expanded selected RV32M aggregate, including `m_pipeline`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed the expanded selected rv32ui-style and rv32um-style aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline`
  passed after the register-file writeback bypass.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate after the ISA aggregate updates.

Next:

- Keep the current simulation wording as selected rv32ui-style/rv32um-style
  coverage, not a full RISC-V compliance claim.

### 2026-06-02 - strengthen RV32M tests with riscv-tests reference points

Changed:

- `tests/riscv/rv32um/mul.S`: added source/destination aliasing,
  zero-destination, and additional signed low-product cases.
- `tests/riscv/rv32um/mulh.S`, `mulhsu.S`, and `mulhu.S`: added high-product
  boundary cases, source/destination aliasing, and zero-destination checks
  inspired by the upstream `riscv-tests` rv32um coverage categories.
- `tests/riscv/rv32um/div.S`, `divu.S`, `rem.S`, and `remu.S`: added more
  signed/unsigned sign combinations, divide-by-zero, unsigned large-value, and
  remainder edge cases.
- `docs/verification.md` and `AGENTS.md`: documented the stronger selected
  RV32M coverage while keeping the non-compliance-claim wording.

Reason:

- Use `riscv-software-src/riscv-tests` as a reference for relevant RV32M
  coverage ideas without copying the upstream harness or vendoring external
  test files.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb build-riscv-tests`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed with the expanded selected RV32M tests.

Next:

- Continue treating these as selected clean-room simulation tests, not a full
  imported riscv-tests compliance flow.

### 2026-06-02 - strengthen selected RV32I tests with riscv-tests reference points

Changed:

- `tests/riscv/rv32ui/add.S` and `addi.S`: added signed wraparound,
  source/destination aliasing, and `x0` source/destination checks inspired by
  upstream rv32ui coverage categories.
- `tests/riscv/rv32ui/beq.S`: added negative equality, extra taken-branch
  flush, and backward-branch loop coverage.
- `tests/riscv/rv32ui/lb.S`: added negative offset, non-aligned base plus
  offset, and load destination overwrite checks.
- `docs/verification.md` and `AGENTS.md`: documented that upstream
  `riscv-tests` is used only as a coverage reference for selected clean-room
  tests.

Reason:

- Strengthen the selected rv32ui-style subset by referencing relevant
  `riscv-software-src/riscv-tests` UI coverage ideas without copying the
  upstream test files or harness.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb build-riscv-tests`
  passed after the RV32I updates.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed with the expanded selected RV32I tests.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed the combined selected rv32ui-style and rv32um-style aggregate after
  the UI and UM reference-point additions.

Next:

- Keep the tests clean-room and selected-scope while using upstream
  `riscv-tests` only as a coverage reference.

### 2026-06-02 - align teaching documentation with v0.6 code

Changed:

- `README.md`: added a teaching path, updated v0.6 status wording and top-level
  SoC wording, corrected Vivado project/bitstream paths, listed the ISA
  simulation targets, and split CPU-side and loader-side memory maps.
- `docs/architecture.md`: clarified the current v0.6 SoC structure and
  separated CPU-side program addresses from loader-side AXI-Lite offsets.
- `docs/instruction_set.md`: changed the coverage heading and status wording
  from v0.5-only to current v0.6 RV32IM instruction coverage.
- `docs/pipeline.md` and `docs/simulation.md`: replaced stale work-in-progress
  and AXI-Lite RAM/load-store wording with current simple imem/dmem port
  descriptions and clarified the conservative teaching hazard policy.
- `docs/roadmap.md`: moved the current milestone from v0.5 to
  `v0.6-pipeline-bram-loader` and documented focused follow-up work.
- `docs/baremetal_c.md`, `docs/pynq-z2-led-bringup.md`,
  `docs/pynqz2_bringup.md`, `docs/jupyter_tetris_plan.md`, and
  `programs/README.md`: aligned program, board, and future Jupyter notes with
  unified BRAM, dmem MMIO, and the `0x1000_0000` MMIO map.
- `docs/verification.md` and `rtl/core/README.md`: clarified that v0.6 carries
  RV32M into the pipelined core and that older v0.5 tests are separate
  regression targets.

Reason:

- Keep the repository explanation consistent with the current RTL and make the
  project easier to read as a teaching SoC.

Validation:

- `rg` documentation scan found no remaining stale v0.5 current-milestone,
  `0x4000_...`, or AXI-Lite CPU RAM/load-store wording outside historical
  roadmap context.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate: GPIO smoke, C GPIO firmware, standalone
  RV32M mul/div, v0.6 BRAM/pipeline/loader tests, and RISC-V ISA smoke.

Next:

- Review rendered Markdown before committing.

### 2026-06-02 - map ISA test status registers into CPU MMIO space

Changed:

- `rtl/soc/tinycpu_dmem_decoder.sv`: added CPU-side dmem MMIO
  `TEST_STATUS` and `TEST_CODE` registers at `0x1000_0FF0` and
  `0x1000_0FF4`, with reset-to-zero, byte-lane write strobes, and readback.
- `tests/riscv/env/tinycpu_test_macros.S` and `tests/riscv/env/crt0.S`:
  moved the RISC-V ISA pass/fail protocol from `0x8000_0000` to the real
  `0x1000_0000` CPU MMIO page.
- `sim/cocotb/riscv_test_runner.py`: updated the watched ISA test status/code
  addresses to `0x1000_0FF0` and `0x1000_0FF4`.
- `README.md`, `docs/memory_map.md`, `docs/simulation.md`,
  `docs/verification.md`, and `AGENTS.md`: documented the unified CPU-side ISA
  test result registers while keeping the AXI-Lite loader/control local map
  separate.

Reason:

- Make simulation ISA tests and future board-side flows use the same
  CPU-visible MMIO result protocol instead of a test-only address outside the
  documented dmem MMIO page.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-smoke`
  passed; the pass case wrote `TEST_STATUS = 1`, and the expected-fail case
  wrote status/code `0x63`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed the selected RV32I clean-room aggregate with the new CPU-side MMIO
  test result registers.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed the selected RV32M clean-room aggregate, including `m_pipeline`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate: GPIO smoke, C GPIO firmware, standalone
  RV32M mul/div, v0.6 BRAM/pipeline/loader tests, and RISC-V ISA smoke.

Next:

- Keep the AXI-Lite loader/control local map separate from CPU-side dmem MMIO
  when future Jupyter or board-side flows use these registers.

### 2026-06-02 - remove legacy v0.5 RTL path from current source set

Changed:

- Removed the unused serialized AXI-Lite CPU core and its stage helper files:
  `rtl/core/tinycpu_core_rv32im_axil.sv`, `tinycpu_if_stage.sv`,
  `tinycpu_id_stage.sv`, `tinycpu_ex_stage.sv`, `tinycpu_mem_stage.sv`,
  `tinycpu_wb_stage.sv`, and `tinycpu_hazard.sv`.
- Removed unused legacy AXI-Lite support modules:
  `rtl/bus/axil_gpio.sv`, `rtl/bus/axil_interconnect.sv`, and
  `rtl/bus/axil_ram.sv`.
- `sim/cocotb/Makefile`: narrowed `VERILOG_SOURCES` to the current v0.6
  pipeline, BRAM, loader, dmem decoder, and SoC modules.
- `README.md` and `docs/pipeline.md`: updated repository layout and pipeline
  wording to describe the remaining current implementation instead of the
  historical helper-module path.
- `AGENTS.md`: recorded the cleanup.

Reason:

- The project no longer needs to preserve the earlier teaching path. Keeping
  only the current v0.6 pipeline/BRAM/loader RTL reduces duplicated constants,
  stale helper modules, and confusion when explaining the final design.

Validation:

- `rg` scan found no active RTL, simulation, program, or documentation
  references to the removed modules outside historical `AGENTS.md` log text.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed after the source-list cleanup.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -B -C sim/cocotb test-all`
  passed from forced rebuild; the iverilog invocations compiled only the
  current v0.6 RTL source set: regfile, ALU, decode, forwarding, mul/div,
  pipeline core, BRAM, AXI-Lite loader, dmem decoder, and SoC.

Next:

- Continue explaining and extending the current v0.6 pipeline/BRAM/loader
  design without preserving the older serialized AXI-Lite CPU path.

### 2026-06-02 - prepare v0.6 release documentation

Changed:

- `docs/release_checklist.md`: added the v0.6 release checklist, local test
  commands, manual GitHub About/topics steps, and real-media-only demo media
  guidance.
- `docs/releases/v0.6-pipeline-bram-isa-tests.md`: added the v0.6 release
  notes draft with highlights, verification commands, and limitations.
- `docs/images/.gitkeep`: added a tracked placeholder for future real board
  demo media.
- `README.md`: linked the release checklist and notes draft, clarified that
  the PYNQ Overlay/Jupyter program-loading demo is planned for v0.7, and added
  a note that board demo media should only be added after a real PYNQ-Z2 run.
- `AGENTS.md`: updated the current milestone at the top of this file to
  `v0.6-pipeline-bram-loader` and recorded the release-readiness cleanup.

Reason:

- Make the repository ready for a clean v0.6 release before starting the v0.7
  Jupyter overlay loader work, without adding generated artifacts or fake demo
  media.

Validation:

- `rg` stale-wording scan found no active test protocol references to
  `0x8000_0000`/`0x8000_0004` or "test-only MMIO"; remaining `0x8000_...`
  hits are arithmetic edge-case constants or historical log text.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-smoke`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed the selected RV32I clean-room aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed the selected RV32M clean-room aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate.

Next:

- Complete manual GitHub release steps after merge, then start the v0.7
  Jupyter overlay loader task separately.

### 2026-06-02 - expand CI to selected ISA aggregate

Changed:

- `.github/workflows/ci.yml`: split the cocotb job into the current `test-all`
  aggregate and a follow-up `test-riscv-isa` step.
- `README.md`, `docs/verification.md`, and `AGENTS.md`: documented that CI
  runs both the v0.6 smoke/pipeline aggregate and the selected rv32ui/rv32um
  ISA aggregate.

Reason:

- Align GitHub Actions with the v0.6 release-readiness claim that selected
  clean-room rv32ui-style and rv32um-style tests pass, while keeping
  `test-all` as the fast branch aggregate.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed after the CI workflow update.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed after the CI workflow update.

Next:

- Push the branch and confirm the expanded GitHub Actions workflow passes.
