TOPLEVEL_LANG = verilog

ROOT_DIR = ../..
.DEFAULT_GOAL := test-v03-gpio

VERILOG_SOURCES = \
	$(ROOT_DIR)/rtl/core/tinycpu_regfile.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_alu.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_decode.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_forwarding.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_muldiv.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_core_pipe.sv \
	$(ROOT_DIR)/rtl/mem/tinycpu_tdp_bram.sv \
	$(ROOT_DIR)/rtl/bus/tinycpu_axil_loader.sv \
	$(ROOT_DIR)/rtl/soc/tinycpu_dmem_decoder.sv \
	$(ROOT_DIR)/rtl/soc/tinycpu_soc.sv

TOPLEVEL ?= tinycpu_soc
COCOTB_TEST_MODULES ?= test_v03_soc_gpio

SIM ?= icarus
RAM_HEX ?= ../../programs/led_switch_demo.hex
RAM_INIT_WORDS ?= 4

RISCV_TEST_BUILD = $(ROOT_DIR)/build/riscv-tests
RISCV_TEST_TIMEOUT ?= 20000
export RISCV_TEST_NAME
export RISCV_EXPECT_FAIL
export RISCV_TEST_TIMEOUT
RV32UI_TESTS = \
	smoke_add \
	add addi sub and andi or ori xor xori \
	sll slli srl srli sra srai \
	slt slti sltu sltiu \
	lui auipc jal jalr \
	beq bne blt bge bltu bgeu \
	lw lb lbu lh lhu sw sb sh
RV32UM_TESTS = \
	mul mulh mulhsu mulhu \
	div divu rem remu \
	m_pipeline

COMPILE_ARGS += \
	-g2012 \
	-P tinycpu_soc.RAM_HEX=\"$(RAM_HEX)\" \
	-P tinycpu_soc.RAM_INIT_WORDS=$(RAM_INIT_WORDS)

.PHONY: test-v03-gpio test-v04-firmware-gpio test-v05-muldiv
.PHONY: test-v05-rv32im-grid test-all firmware-c-demo firmware-rv32im-demo
.PHONY: test-v05-rv32i-directed test-v05-branch-load-store
.PHONY: test-v06-bram test-v06-axil-loader test-v06-pipeline-overlap
.PHONY: test-v06-forwarding test-v06-load-use test-v06-branch-flush
.PHONY: test-v06-pipeline
.PHONY: test-v07-loader-mirror test-v07-pynq-loader
.PHONY: test-v08-framebuffer-mirror test-v08-framebuffer
.PHONY: firmware-interactive-demo firmware-tetris-demo
.PHONY: test-v09-host-input test-v09-interactive-io test-v09-tetris-smoke
.PHONY: test-v09-interactive
.PHONY: build-riscv-tests test-riscv-smoke test-rv32ui test-rv32um
.PHONY: test-riscv-isa

test-v03-gpio:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v03_soc_gpio \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v03-gpio

firmware-c-demo:
	$(MAKE) -C $(ROOT_DIR)/programs/c_demo

test-v04-firmware-gpio: firmware-c-demo
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v04_firmware_gpio \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/c_demo/firmware.hex \
		RAM_INIT_WORDS=256 \
		SIM_BUILD=sim_build/test-v04-firmware-gpio

test-v05-muldiv:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v05_muldiv_unit \
		TOPLEVEL=tinycpu_muldiv \
		SIM_BUILD=sim_build/test-v05-muldiv

sim_build/test-v05-rv32i-directed/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py rv32i-directed $@

test-v05-rv32i-directed: sim_build/test-v05-rv32i-directed/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v05_rv32i_directed \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v05-rv32i-directed/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v05-rv32i-directed

sim_build/test-v05-branch-load-store/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py branch-load-store $@

test-v05-branch-load-store: sim_build/test-v05-branch-load-store/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v05_branch_load_store \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v05-branch-load-store/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v05-branch-load-store

test-v06-bram:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_tdp_bram \
		TOPLEVEL=tinycpu_tdp_bram \
		SIM_BUILD=sim_build/test-v06-bram

sim_build/test-v06-pipeline-overlap/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py pipeline-overlap $@

test-v06-pipeline-overlap: sim_build/test-v06-pipeline-overlap/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_pipeline_overlap \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v06-pipeline-overlap/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v06-pipeline-overlap

sim_build/test-v06-forwarding/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py pipeline-forwarding $@

test-v06-forwarding: sim_build/test-v06-forwarding/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_forwarding \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v06-forwarding/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v06-forwarding

sim_build/test-v06-load-use/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py pipeline-load-use $@

test-v06-load-use: sim_build/test-v06-load-use/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_load_use \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v06-load-use/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v06-load-use

sim_build/test-v06-branch-flush/program.hex: tinycpu_test_programs.py
	python3 tinycpu_test_programs.py pipeline-branch-flush $@

test-v06-branch-flush: sim_build/test-v06-branch-flush/program.hex
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_branch_flush \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=sim_build/test-v06-branch-flush/program.hex \
		RAM_INIT_WORDS=128 \
		SIM_BUILD=sim_build/test-v06-branch-flush

test-v06-axil-loader:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v06_axil_loader \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v06-axil-loader

test-v06-pipeline: test-v06-bram test-v06-pipeline-overlap
test-v06-pipeline: test-v06-forwarding test-v06-load-use
test-v06-pipeline: test-v06-branch-flush test-v06-axil-loader

test-v07-loader-mirror:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v07_loader_mirror \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v07-loader-mirror

test-v07-pynq-loader: test-v07-loader-mirror

test-v08-framebuffer-mirror:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v08_framebuffer_mirror \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v08-framebuffer-mirror

test-v08-framebuffer: test-v08-framebuffer-mirror

firmware-interactive-demo:
	$(MAKE) -C $(ROOT_DIR)/programs/interactive_demo

firmware-tetris-demo:
	$(MAKE) -C $(ROOT_DIR)/programs/tetris

test-v09-host-input:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v09_interactive_io \
		COCOTB_TESTCASE=test_host_input_reaches_cpu_polling_program \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v09-host-input

test-v09-interactive-io:
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v09_interactive_io \
		COCOTB_TESTCASE=test_interactive_io_status_values_and_framebuffer \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v09-interactive-io

test-v09-tetris-smoke: firmware-tetris-demo
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v09_tetris_smoke \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/led_switch_demo.hex \
		RAM_INIT_WORDS=4 \
		SIM_BUILD=sim_build/test-v09-tetris-smoke

test-v09-interactive: test-v09-host-input test-v09-interactive-io
test-v09-interactive: test-v09-tetris-smoke

build-riscv-tests:
	python3 build_riscv_tests.py

test-riscv-smoke: build-riscv-tests
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_riscv_isa \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=$(RISCV_TEST_BUILD)/rv32ui/smoke_add/smoke_add.hex \
		RAM_INIT_WORDS=256 \
		RISCV_TEST_NAME=rv32ui/smoke_add \
		RISCV_TEST_TIMEOUT=$(RISCV_TEST_TIMEOUT) \
		SIM_BUILD=sim_build/test-riscv-smoke-pass
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_riscv_isa \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=$(RISCV_TEST_BUILD)/rv32ui/fail_status/fail_status.hex \
		RAM_INIT_WORDS=256 \
		RISCV_TEST_NAME=rv32ui/fail_status \
		RISCV_EXPECT_FAIL=1 \
		RISCV_TEST_TIMEOUT=$(RISCV_TEST_TIMEOUT) \
		SIM_BUILD=sim_build/test-riscv-smoke-fail

test-rv32ui: build-riscv-tests
	set -e; for test in $(RV32UI_TESTS); do \
		$(MAKE) sim \
			COCOTB_TEST_MODULES=test_riscv_isa \
			TOPLEVEL=tinycpu_soc \
			RAM_HEX=$(RISCV_TEST_BUILD)/rv32ui/$$test/$$test.hex \
			RAM_INIT_WORDS=256 \
			RISCV_TEST_NAME=rv32ui/$$test \
			RISCV_TEST_TIMEOUT=$(RISCV_TEST_TIMEOUT) \
			SIM_BUILD=sim_build/test-rv32ui-$$test; \
	done

test-rv32um: build-riscv-tests
	set -e; for test in $(RV32UM_TESTS); do \
		$(MAKE) sim \
			COCOTB_TEST_MODULES=test_riscv_isa \
			TOPLEVEL=tinycpu_soc \
			RAM_HEX=$(RISCV_TEST_BUILD)/rv32um/$$test/$$test.hex \
			RAM_INIT_WORDS=256 \
			RISCV_TEST_NAME=rv32um/$$test \
			RISCV_TEST_TIMEOUT=$(RISCV_TEST_TIMEOUT) \
			SIM_BUILD=sim_build/test-rv32um-$$test; \
	done

test-riscv-isa: test-rv32ui test-rv32um

firmware-rv32im-demo:
	$(MAKE) -C $(ROOT_DIR)/programs/rv32im_demo

test-v05-rv32im-grid: firmware-rv32im-demo
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v05_tetris_grid_math \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/rv32im_demo/firmware.hex \
		RAM_INIT_WORDS=256 \
		SIM_BUILD=sim_build/test-v05-rv32im-grid

test-all: test-v03-gpio test-v04-firmware-gpio test-v05-muldiv
test-all: test-v06-pipeline
test-all: test-riscv-smoke

include $(shell cocotb-config --makefiles)/Makefile.sim
