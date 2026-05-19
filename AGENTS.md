# AGENTS.md

## Project identity

tinycpu is a clean-room educational RV32IM SoC for the PYNQ-Z2 FPGA board.

Current milestone: `v0.5-rv32im-m-extension`.

The current CPU is an RV32IM-target educational core. It is organized around
IF, ID, EX, MEM, and WB stage helper modules, but it is not a fully overlapped
five-stage pipeline. The current implementation is a stage-structured
serialized control path with one AXI-Lite master shared by instruction fetch
and load/store operations.

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
make -C sim/cocotb test-v05-rv32im-grid
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
