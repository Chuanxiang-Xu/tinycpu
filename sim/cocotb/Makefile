TOPLEVEL_LANG = verilog

ROOT_DIR = ../..

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

TOPLEVEL = tinycpu_soc
COCOTB_TEST_MODULES = test_v03_soc_gpio

SIM ?= icarus
COMPILE_ARGS += -g2012 -P tinycpu_soc.RAM_HEX=\"../../programs/led_switch_demo.hex\"

include $(shell cocotb-config --makefiles)/Makefile.sim
