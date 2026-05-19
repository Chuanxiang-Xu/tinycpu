TOPLEVEL_LANG = verilog

ROOT_DIR = ../..
.DEFAULT_GOAL := test-v03-gpio

VERILOG_SOURCES = \
	$(ROOT_DIR)/rtl/core/tinycpu_regfile.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_alu.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_decode.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_if_stage.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_id_stage.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_ex_stage.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_mem_stage.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_wb_stage.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_hazard.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_muldiv.sv \
	$(ROOT_DIR)/rtl/core/tinycpu_core_rv32im_axil.sv \
	$(ROOT_DIR)/rtl/axil/axil_ram.sv \
	$(ROOT_DIR)/rtl/axil/axil_gpio.sv \
	$(ROOT_DIR)/rtl/axil/axil_interconnect.sv \
	$(ROOT_DIR)/rtl/soc/tinycpu_soc.sv

TOPLEVEL ?= tinycpu_soc
COCOTB_TEST_MODULES ?= test_v03_soc_gpio

SIM ?= icarus
RAM_HEX ?= ../../programs/led_switch_demo.hex
RAM_INIT_WORDS ?= 4

COMPILE_ARGS += \
	-g2012 \
	-P tinycpu_soc.RAM_HEX=\"$(RAM_HEX)\" \
	-P tinycpu_soc.RAM_INIT_WORDS=$(RAM_INIT_WORDS)

.PHONY: test-v03-gpio test-v04-firmware-gpio test-v05-muldiv
.PHONY: test-v05-rv32im-grid test-all firmware-c-demo firmware-rv32im-demo

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

firmware-rv32im-demo:
	$(MAKE) -C $(ROOT_DIR)/programs/rv32im_demo

test-v05-rv32im-grid: firmware-rv32im-demo
	$(MAKE) sim \
		COCOTB_TEST_MODULES=test_v05_tetris_grid_math \
		TOPLEVEL=tinycpu_soc \
		RAM_HEX=../../programs/rv32im_demo/firmware.hex \
		RAM_INIT_WORDS=256 \
		SIM_BUILD=sim_build/test-v05-rv32im-grid

test-all: test-v03-gpio test-v04-firmware-gpio test-v05-muldiv test-v05-rv32im-grid

include $(shell cocotb-config --makefiles)/Makefile.sim
