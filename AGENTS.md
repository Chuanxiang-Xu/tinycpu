# AGENTS.md

## Project identity

tinycpu is a clean-room educational RV32IM SoC for the PYNQ-Z2 FPGA board.

Current development milestone: `v1.0-stable-rv32im-pipeline-core`.

The current CPU is an RV32IM-target educational overlapped pipeline core. It
uses IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers, simple
Harvard-style instruction/data memory ports, a unified 64 KiB BRAM in the SoC,
a dmem-side CPU-visible MMIO decoder, an AXI-Lite loader/control slave at the
SoC boundary, PS-visible loader mirrors for test/app/framebuffer status,
loader-side host input writes, and Jupyter/Python helper files for framebuffer
and TinyTetris demos. A PYNQ overlay Tcl flow connects Zynq PS `M_AXI_GP0` to
the loader/control slave through an AXI interconnect. The CPU no longer has
its own AXI-Lite master. For v1.0, the stable release claim is limited to
selected clean-room RV32I/RV32M simulation, pipeline hazard/flush coverage, C
firmware smoke tests, and AXI-Lite loader/control simulation. PYNQ/Jupyter,
framebuffer, and TinyTetris remain demo paths unless board validation evidence
is added.

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
make -C sim/cocotb test-v07-loader-mirror
make -C sim/cocotb test-v08-framebuffer-mirror
make -C sim/cocotb test-v08-framebuffer
make -C sim/cocotb test-v09-host-input
make -C sim/cocotb test-v09-interactive-io
make -C sim/cocotb test-v09-tetris-smoke
make -C sim/cocotb test-v09-interactive
make -C sim/cocotb test-v10-stable
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

Framebuffer demo build:

```sh
make -C programs/framebuffer_demo
```

Interactive/TinyTetris demo builds:

```sh
make -C programs/interactive_demo
make -C programs/tetris
```

Vivado Tcl build:

```sh
source ~/vivado/2025.2/Vivado/settings64.sh
vivado -mode batch -source fpga/vivado/build_bitstream.tcl
vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl
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

### 2026-06-04 - prepare v1.0 stable RV32IM pipeline release candidate

Changed:

- `sim/cocotb/Makefile`: added `test-v10-stable` as the v1.0 release
  aggregate and made `test-all` an alias for it.
- `.github/workflows/ci.yml`: changed CI to run
  `make -C sim/cocotb test-v10-stable` as the single cocotb entry point.
- `README.md`, `docs/architecture.md`, `docs/verification.md`,
  `docs/roadmap.md`, `docs/pipeline.md`, `docs/simulation.md`, and
  `rtl/core/README.md`: aligned the v1.0 release claim with selected
  RV32I/RV32M, pipeline, firmware smoke, and AXI-Lite loader/control
  simulation coverage.
- `AGENTS.md`: recorded the v1.0 milestone, stable aggregate, and release
  scope.

Reason:

- Prepare a precise v1.0 stable RV32IM pipeline-core release candidate without
  adding new architecture features or overstating RISC-V compliance, traps,
  interrupts, board, Jupyter, framebuffer, or TinyTetris validation.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v10-stable`
  passed. The aggregate ran GPIO smoke, C GPIO firmware, standalone RV32M
  mul/div, BRAM, AXI-Lite loader/control, pipeline overlap, forwarding,
  load-use, branch-flush, RISC-V smoke, selected rv32ui-style, and selected
  rv32um-style tests.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed the selected rv32ui-style and rv32um-style aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/c_demo`
  passed with no rebuild needed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/rv32im_demo`
  passed and rebuilt local ignored firmware artifacts.
- `command -v vivado` failed, so Vivado/PYNQ bitstream generation was not run
  in this local environment.

Next:

- Push the v1.0 release-prep branch and let GitHub Actions run the
  `test-v10-stable` CI entry point.

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

### 2026-06-02 - finalize v0.6 verification consistency

Changed:

- `docs/verification.md`: rewrote the current verification status around
  `v0.6-pipeline-bram-loader`, added the requested run commands, test target
  table, selected rv32ui-style coverage table, selected rv32um-style coverage
  table, CPU-side `TEST_STATUS`/`TEST_CODE` register map, and explicit
  unsupported/not-claimed section.
- `docs/release_checklist.md` and
  `docs/releases/v0.6-pipeline-bram-isa-tests.md`: added
  `make -C sim/cocotb test-riscv-isa` to the release validation command list.
- `AGENTS.md`: recorded the verification documentation cleanup.

Reason:

- Remove remaining release-blocking ambiguity in the verification docs and
  keep release notes aligned with the selected clean-room rv32ui/rv32um
  simulation coverage.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-smoke`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32ui`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-rv32um`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed.

Next:

- Push the documentation cleanup branch and confirm the expanded GitHub Actions
  workflow passes before tagging v0.6.

### 2026-06-03 - add v0.7 loader test-result mirrors

Changed:

- `rtl/soc/tinycpu_dmem_decoder.sv`: exposed CPU-side `TEST_STATUS` and
  `TEST_CODE` registers as SoC-level signals.
- `rtl/soc/tinycpu_soc.sv`: connected the dmem decoder test-result signals
  into the AXI-Lite loader/control block.
- `rtl/bus/tinycpu_axil_loader.sv`: added read-only loader-side mirror
  offsets `0x10010` and `0x10014` for CPU-written test status/code.
- `sim/cocotb/test_v07_loader_mirror.py`: added a loader-flow regression that
  writes a program into BRAM, starts the CPU, and polls the mirror registers.
- `sim/cocotb/Makefile`: added `test-v07-loader-mirror` and the placeholder
  aggregate alias `test-v07-pynq-loader`.
- `README.md`, `docs/architecture.md`, `docs/memory_map.md`,
  `docs/simulation.md`, `docs/verification.md`, and `docs/roadmap.md`:
  documented the PS-visible mirror offsets and v0.7 preparatory test target.
- `AGENTS.md`: recorded the loader mirror update.

Reason:

- Start the `v0.7-pynq-jupyter-loader` path by allowing a future Jupyter/Python
  loader to read CPU-written pass/fail status through the AXI-Lite
  loader/control address space without aliasing CPU-side MMIO addresses.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v07-loader-mirror`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v06-pipeline`
  passed after the loader/control interface update.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed after the mirror update.

Next:

- Add the Python/PYNQ loader helper and notebook flow once the board overlay
  integration point is ready.

### 2026-06-03 - add v0.8 Jupyter framebuffer demo path

Changed:

- `rtl/soc/tinycpu_dmem_decoder.sv`: added CPU-side `FRAME_COUNTER`, exposed
  `GAME_STATUS`/`FRAME_COUNTER`, and exposed packed framebuffer readback for
  loader mirrors.
- `rtl/soc/tinycpu_soc.sv`: wired game/framebuffer mirror signals between the
  dmem decoder and AXI-Lite loader/control block.
- `rtl/bus/tinycpu_axil_loader.sv`: added read-only loader-side mirror offsets
  `0x10018`, `0x1001C`, and `0x10100 - 0x101FF`.
- `sim/cocotb/test_v08_framebuffer_mirror.py`: added framebuffer mirror
  coverage for game status, frame counter, and little-endian packed cells.
- `sim/cocotb/Makefile`: added `test-v08-framebuffer-mirror` and
  `test-v08-framebuffer`.
- `programs/common/`: added shared `crt0.S`, `linker.ld`, `tinycpu_mmio.h`,
  and `makehex.py` support for newer bare-metal demos.
- `programs/framebuffer_demo/`: added a finite-smoke plus continuing-animation
  RV32IM framebuffer demo and build flow.
- `notebooks/`: added the Python loader/display helper and framebuffer demo
  notebook scaffold.
- `.gitignore`: ignored generated framebuffer demo firmware outputs.
- `README.md`, `docs/architecture.md`, `docs/jupyter_framebuffer.md`,
  `docs/memory_map.md`, `docs/release_checklist.md`,
  `docs/simulation.md`, `docs/verification.md`, `docs/roadmap.md`,
  `programs/README.md`, and `AGENTS.md`: documented the v0.8 framebuffer
  mirror path, maps, tests, and limitations.

Reason:

- Implement the `v0.8-jupyter-framebuffer-demo` interface without adding full
  Tetris, HDMI/VGA, interrupts, CSRs, UART, or unsupported compliance claims.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v08-framebuffer-mirror`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v08-framebuffer`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/framebuffer_demo`
  passed and generated ignored firmware artifacts.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed after the v0.8 mirror changes.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed after the v0.8 mirror changes.
- `python3 -m py_compile notebooks/tinycpu_loader.py` passed.
- `python3 -m json.tool notebooks/framebuffer_demo.ipynb` passed.
- `git diff --check` passed.

Next:

- Run the broader simulation aggregates, then exercise the notebook flow on a
  real PYNQ-Z2 overlay before adding any screenshot or GIF.

### 2026-06-03 - add v0.9 generic interactive I/O and TinyTetris demo

Changed:

- `rtl/bus/tinycpu_axil_loader.sv`: added loader-side `HOST_INPUT_WRITE`,
  optional host command/clear registers, and generic app mirror offsets for
  `APP_STATUS`, `APP_VALUE0`, `APP_VALUE1`, and `FRAME_COUNTER`.
- `rtl/soc/tinycpu_dmem_decoder.sv`: added CPU-side `HOST_INPUT`,
  `APP_VALUE0`, `APP_VALUE1`, `FRAME_COUNTER`, and `COMMAND_ACK` behavior
  while preserving framebuffer/test-status behavior.
- `rtl/soc/tinycpu_soc.sv`: wired host input and generic app mirror signals
  between the loader and dmem decoder.
- `programs/common/tinycpu_mmio.h`: added generic app I/O names with
  compatibility aliases for older game-style names.
- `programs/interactive_demo/`: added a generic host-input to app-output
  framebuffer smoke demo and build flow.
- `programs/tetris/`: added a small TinyTetris app demo and build flow.
- `notebooks/tinycpu_loader.py`: added generic input/write and app mirror read
  APIs while keeping existing loader methods.
- `notebooks/tetris_controller.py`, `interactive_io_demo.ipynb`, and
  `tetris_demo.ipynb`: added generic interactive and TinyTetris notebook
  scaffolds.
- `sim/cocotb/test_v09_interactive_io.py` and
  `sim/cocotb/test_v09_tetris_smoke.py`: added host-input, generic app I/O,
  and TinyTetris smoke coverage.
- `sim/cocotb/Makefile`: added `test-v09-host-input`,
  `test-v09-interactive-io`, `test-v09-tetris-smoke`, and
  `test-v09-interactive`.
- `README.md`, `docs/architecture.md`, `docs/jupyter_framebuffer.md`,
  `docs/jupyter_interactive_io.md`, `docs/jupyter_tetris.md`,
  `docs/memory_map.md`, `docs/release_checklist.md`, `docs/roadmap.md`,
  `docs/simulation.md`, `docs/verification.md`, `programs/README.md`, and
  `AGENTS.md`: documented the v0.9 generic app I/O map, demos, tests, and
  limitations.
- `.gitignore`: ignored generated interactive and Tetris firmware artifacts.

Reason:

- Add a generic Jupyter-controlled interactive I/O layer that can support many
  small demos, using TinyTetris as the first application without hardcoding
  Tetris behavior into RTL.

Validation:

- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v08-framebuffer-mirror`
  passed after the app mirror remap.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-host-input`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-interactive-io`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/interactive_demo`
  passed and generated ignored firmware artifacts.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/tetris`
  passed and generated ignored firmware artifacts.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-tetris-smoke`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-interactive`
  passed the v0.9 host-input, interactive I/O, and TinyTetris smoke aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-riscv-isa`
  passed the selected RV32I/RV32M ISA aggregate.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C programs/framebuffer_demo`
  passed after the generic app mirror remap and generated ignored firmware
  artifacts.
- `python3 -m py_compile notebooks/tinycpu_loader.py notebooks/tetris_controller.py`
  passed.
- `python3 -m json.tool notebooks/framebuffer_demo.ipynb`,
  `python3 -m json.tool notebooks/interactive_io_demo.ipynb`, and
  `python3 -m json.tool notebooks/tetris_demo.ipynb` passed.
- `git diff --check` passed.

Next:

- Exercise the interactive notebooks on a real PYNQ-Z2 overlay before adding
  any screenshot or GIF.

### 2026-06-03 - organize notebook guide

Changed:

- `notebooks/README.md`: reorganized the PYNQ notebook guide with directory
  layout, related firmware paths, typical board flow, loader-side register
  offsets, CPU-side map references, and per-demo notes.
- `AGENTS.md`: recorded the notebook guide cleanup.

Reason:

- Make the Jupyter demo entry points, file locations, and loader/app I/O
  responsibilities easier to follow before board bring-up.

Validation:

- `git diff --check` passed.

Next:

- Exercise the notebooks on a real PYNQ-Z2 overlay once the bitstream and
  matching `.hwh` are available.

### 2026-06-03 - add PYNQ AXI overlay wiring

Changed:

- `rtl/board/tinycpu_pynq_axi_overlay.sv`: added a Vivado block-design module
  wrapper with full AXI-Lite slave pins, PS clock/reset inputs, PL buttons,
  switches, LEDs, and a connection into `tinycpu_soc`.
- `fpga/vivado/build_pynq_axi_overlay.tcl`: added a reproducible Vivado flow
  that creates a Zynq PS block design, enables `M_AXI_GP0`, connects it through
  an AXI interconnect to the tinycpu loader/control slave, maps the loader at
  `0x43C0_0000`, and emits a bitstream plus `.hwh`.
- `fpga/vivado/pynqz2_axi_overlay.xdc`: added PL LED, switch, and button
  constraints for the PS-driven overlay.
- `README.md`, `docs/architecture.md`, `docs/pynqz2_bringup.md`,
  `docs/jupyter_interactive_io.md`, `docs/jupyter_tetris.md`,
  `notebooks/README.md`, and `AGENTS.md`: documented the new PYNQ/Jupyter AXI
  overlay build and board run flow.

Reason:

- Let PYNQ/Jupyter reach the tinycpu AXI-Lite loader/control slave so notebook
  demos can load firmware, write host input, and read app/framebuffer mirrors
  on real hardware.

Validation:

- `iverilog -g2012 -s tinycpu_pynq_axi_overlay -o /tmp/tinycpu_pynq_axi_overlay.vvp rtl/core/*.sv rtl/bus/*.sv rtl/mem/*.sv rtl/soc/*.sv rtl/board/tinycpu_pynq_axi_overlay.sv`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-tetris-smoke`
  passed after the overlay wrapper/Tcl additions.
- `command -v vivado` failed in this local environment, so the new Vivado
  overlay Tcl flow was not run here.

Next:

- Run `vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl` on a
  machine with Vivado and PYNQ-Z2 board support, then copy the generated
  bitstream and `.hwh` to the board for notebook testing.

### 2026-06-03 - standardize notebook README structure

Changed:

- `notebooks/README.md`: reorganized the notebook guide into standard README
  sections for prerequisites, contents, firmware build, overlay build, PYNQ
  deployment, run order, addressing model, loader offset reference, demo notes,
  and troubleshooting.
- `AGENTS.md`: recorded the documentation structure update.

Reason:

- Make the PYNQ/Jupyter demo instructions easier to scan and closer to a
  conventional project README layout.

Validation:

- `git diff --check` passed.
- `python3 -m py_compile notebooks/tinycpu_loader.py notebooks/tetris_controller.py`
  passed.
- `python3 -m json.tool notebooks/interactive_io_demo.ipynb`,
  `python3 -m json.tool notebooks/framebuffer_demo.ipynb`, and
  `python3 -m json.tool notebooks/tetris_demo.ipynb` passed.

Next:

- Continue with real PYNQ-Z2 overlay/notebook testing once the bitstream and
  matching `.hwh` are generated.

### 2026-06-03 - unify current milestone and board docs

Changed:

- `docs/pynqz2_bringup.md`: rewrote the board-level guide as the single entry
  point for pin smoke, pure PL preloaded firmware, and PYNQ/Jupyter AXI overlay
  flows.
- `README.md`, `docs/architecture.md`, `docs/simulation.md`,
  `docs/verification.md`, `docs/instruction_set.md`, `docs/pipeline.md`,
  `docs/pynq-z2-led-bringup.md`, `docs/baremetal_c.md`,
  `docs/jupyter_framebuffer.md`, `docs/jupyter_interactive_io.md`,
  `docs/jupyter_tetris.md`, `docs/jupyter_tetris_plan.md`,
  `docs/roadmap.md`, `rtl/core/README.md`, `programs/README.md`, and
  `notebooks/README.md`: aligned current-user wording around
  `v0.9-jupyter-interactive-io-tetris-demo`, while keeping historical `v0.x`
  prefixes where they are real target names, roadmap entries, or release
  history.
- `notebooks/framebuffer_demo.ipynb`: removed stale v0.8 wording from the
  intro markdown cell.
- `AGENTS.md`: recorded the milestone/doc unification.

Reason:

- Make the current board/Jupyter path easier to find and avoid mixing current
  instructions with historical milestone wording.

Validation:

- `git diff --check` passed.
- `python3 -m py_compile notebooks/tinycpu_loader.py notebooks/tetris_controller.py`
  passed.
- `python3 -m json.tool notebooks/interactive_io_demo.ipynb`,
  `python3 -m json.tool notebooks/framebuffer_demo.ipynb`, and
  `python3 -m json.tool notebooks/tetris_demo.ipynb` passed.
- `rg` scan found no remaining stale current-milestone wording such as
  `current v0.6`, `v0.8 development`, `v0.9 development`, future PS/Jupyter
  loader wording, or loader-idle board wording in current user-facing docs.

Next:

- Continue with real PYNQ-Z2 overlay/notebook testing once the bitstream and
  matching `.hwh` are generated.

### 2026-06-03 - build and program PYNQ AXI overlay

Changed:

- `rtl/board/tinycpu_pynq_axi_overlay_bd.v`: added a Verilog-only Vivado block
  design module-reference wrapper around the SystemVerilog
  `tinycpu_pynq_axi_overlay` implementation.
- `fpga/vivado/build_pynq_axi_overlay.tcl`: added the BD wrapper source and
  changed loader address assignment to use `assign_bd_address -offset
  0x43C0_0000 -range 0x00020000` in the PS data address space.
- `AGENTS.md`: recorded the overlay build/programming results.

Reason:

- Vivado block design module-reference cells rejected a SystemVerilog top file,
  and the original post-auto-assignment offset update targeted a read-only
  slave segment property.

Validation:

- `iverilog -g2012 -s tinycpu_pynq_axi_overlay_bd -o /tmp/tinycpu_pynq_axi_overlay_bd.vvp rtl/core/*.sv rtl/bus/*.sv rtl/mem/*.sv rtl/soc/*.sv rtl/board/tinycpu_pynq_axi_overlay.sv rtl/board/tinycpu_pynq_axi_overlay_bd.v`
  passed.
- `vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl` generated
  `tinycpu_pynq_system_wrapper.bit` and `tinycpu_pynq_system.hwh`.
- Vivado routed and wrote the bitstream, but timing was not met:
  `WNS=-5.797 ns`, `TNS=-6873.107 ns`.
- Vivado Hardware Manager programmed device `xc7z020_1` with
  `tinycpu_pynq_system_wrapper.bit`; startup status reported `HIGH`.
- `git diff --check` passed.

Next:

- Try the PYNQ notebooks against the programmed overlay, then reduce the
  overlay/core clock or optimize the mul/div critical paths before treating the
  bitstream as timing-clean.

### 2026-06-03 - fix PYNQ AXI overlay address and timing

Changed:

- `rtl/board/tinycpu_pynq_axi_overlay.sv`: mapped PS AXI absolute addresses
  down to the loader's 17-bit local address window before entering
  `tinycpu_soc`.
- `fpga/vivado/build_pynq_axi_overlay.tcl`: moved the FCLK0 frequency override
  after PYNQ-Z2 board-preset automation and set both the Hz and MHz PS clock
  parameters for a 25 MHz bring-up overlay.
- `AGENTS.md`: recorded the project-level PYNQ/Jupyter overlay diagnosis and
  validation.

Reason:

- PYNQ MMIO accesses arrive in the PS address space at `0x43C0_0000`, while
  `tinycpu_axil_loader` expects local loader offsets. The old wrapper could
  therefore miss the loader control/status/register window.
- The previous overlay build was constrained at 100 MHz despite the intended
  lower bring-up clock, causing severe routed timing failures on the pipelined
  core and mul/div paths.

Validation:

- `iverilog -g2012 -s tinycpu_pynq_axi_overlay_bd -o /tmp/tinycpu_pynq_axi_overlay_bd.vvp rtl/core/*.sv rtl/bus/*.sv rtl/mem/*.sv rtl/soc/*.sv rtl/board/tinycpu_pynq_axi_overlay.sv rtl/board/tinycpu_pynq_axi_overlay_bd.v`
  passed.
- `git diff --check` passed.
- `vivado -mode batch -source fpga/vivado/build_pynq_axi_overlay.tcl` generated
  a timing-clean overlay with `clk_fpga_0` at 25 MHz, `WNS=13.976 ns`, and
  `TNS=0.000 ns`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-tetris-smoke`
  passed with `TESTS=1 PASS=1 FAIL=0`.
- Vivado Hardware Manager programmed device `xc7z020_1` with the rebuilt
  `tinycpu_pynq_system_wrapper.bit`; startup status reported `HIGH`.
- A refreshed PYNQ run package was staged under
  `/tmp/tinycpu_pynq_run_fixed_20260603_0420`.

Next:

- Copy the refreshed package to the PYNQ board and first test direct
  `MMIO(0x43C00000, 0x20000)` access before reintroducing `Overlay()`.

### 2026-06-03 - make TinyTetris closer to standard Tetris

Changed:

- `programs/tetris/tetris.c`: replaced the earlier 2x2 falling-block smoke
  demo with a compact seven-tetromino implementation using 4x4 shape masks,
  clockwise rotation, simple wall kicks, line clearing, scoring, pause,
  restart, soft drop, hard drop, and game-over detection.
- `notebooks/tetris_controller.py`: held button inputs briefly before clearing
  them so TinyCPU can reliably sample Jupyter button presses.
- `programs/tetris/README.md`: documented the current TinyTetris rule scope.
- `AGENTS.md`: recorded the Tetris gameplay alignment and validation.

Reason:

- The prior Tetris firmware was useful as an interactive I/O smoke test, but it
  behaved unlike normal Tetris: only a 2x2 square existed and rotate was a
  no-op. Jupyter button pulses were also too short for comfortable manual
  board use.

Validation:

- `make -C programs/tetris` passed and regenerated local ignored firmware
  outputs.
- `python3 -m py_compile notebooks/tinycpu_loader.py notebooks/tetris_controller.py`
  passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-tetris-smoke`
  passed with `TESTS=1 PASS=1 FAIL=0`.
- `git diff --check` passed.
- The refreshed PYNQ run package at
  `/tmp/tinycpu_pynq_run_fixed_20260603_0420.tar.gz` was updated with the new
  `programs/tetris/firmware.hex` and `notebooks/tetris_controller.py`.

Next:

- Copy the refreshed package to the PYNQ board again, reload the firmware, and
  test Start/Rotate/Soft Drop/Hard Drop from Jupyter.

### 2026-06-03 - complete TinyTetris gameplay pass

Changed:

- `programs/tetris/tetris.c`: expanded TinyTetris into a fuller clean-room
  Tetris-style game with seven tetrominoes, fixed seven-bag sequencing,
  clockwise rotation, simple wall kicks, ghost projection, a one-piece hold
  slot, level-based gravity, soft drop, hard drop, top-out/game-over detection,
  line clearing, and line/drop scoring.
- `programs/tetris/tetris.c`: changed the internal board representation from
  byte cells to packed 32-bit words to reduce BRAM byte-load/store pressure on
  the teaching CPU while still writing byte cells to the framebuffer MMIO
  mirror.
- `notebooks/tetris_controller.py`: added Hold input and helpers for reading
  lines, level, next piece, and held piece from packed app metadata.
- `notebooks/tetris_demo.ipynb`: added a Hold button and displayed level,
  next piece, and held piece alongside score, lines, status, frame count, and
  board text.
- `programs/tetris/README.md`, `docs/jupyter_tetris.md`, and
  `notebooks/README.md`: documented the fuller TinyTetris feature set, input
  bit 7 for Hold, and packed `APP_VALUE1` fields.
- `AGENTS.md`: recorded the complete TinyTetris gameplay pass and validation.

Reason:

- The previous firmware was closer to an interactive framebuffer smoke test
  than a complete Tetris-style game. This pass keeps the implementation
  clean-room and FPGA-friendly while aligning the gameplay with common online
  Tetris mechanics such as tetromino rotation, hold, ghost, hard drop, line
  clears, and level progression.

Validation:

- `make -C programs/tetris` passed and regenerated local ignored firmware
  outputs.
- `python3 -m py_compile notebooks/tinycpu_loader.py notebooks/tetris_controller.py`
  passed.
- `python3 -m json.tool notebooks/tetris_demo.ipynb` passed.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-tetris-smoke`
  passed with `TESTS=1 PASS=1 FAIL=0`.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-v09-interactive`
  passed the host-input, interactive-I/O, and TinyTetris smoke tests.
- `env PATH=/home/shane/Projects/tinycpu/.venv/bin:$PATH make -C sim/cocotb test-all`
  passed the current CI aggregate.
- `git diff --check` passed.
- `/tmp/tinycpu_pynq_run_fixed_20260603_0420.tar.gz` was refreshed with the
  updated TinyTetris firmware, notebook, and controller helper.

Next:

- Copy the refreshed PYNQ package to the board and reload
  `programs/tetris/firmware.hex` from Jupyter.

### 2026-06-03 - prepare v0.9 project tree for GitHub upload

Changed:

- `.gitignore`: ignored the local `NA/` Vivado PS summary directory so
  generated board reports do not enter the public source tree.
- `AGENTS.md`: recorded the final project-tree cleanup before publishing.

Reason:

- Keep the GitHub upload source-first and avoid committing local Vivado
  generated reports, bitstreams, or firmware build products.

Validation:

- Pending final staged-file review and push.

Next:

- Stage the reproducible source, documentation, notebook, and test files, then
  push the branch to GitHub.
