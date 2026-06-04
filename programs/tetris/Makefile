CROSS ?= riscv64-unknown-elf
CC      := $(CROSS)-gcc
OBJCOPY := $(CROSS)-objcopy
OBJDUMP := $(CROSS)-objdump

COMMON_DIR := ../common

MARCH ?= rv32im
MABI  ?= ilp32
ARCH_FLAGS := -march=$(MARCH) -mabi=$(MABI) -mno-relax
CFLAGS := $(ARCH_FLAGS) -Os -ffreestanding -fno-builtin -fno-pic -Wall -Wextra
LDFLAGS := $(ARCH_FLAGS) -T $(COMMON_DIR)/linker.ld -nostdlib -nostartfiles
LDFLAGS += -Wl,--no-relax -Wl,--gc-sections -Wl,--build-id=none

TARGET := firmware
SOURCES := $(COMMON_DIR)/crt0.S tetris.c

.PHONY: all clean disasm

all: $(TARGET).hex $(TARGET).dump

$(TARGET).elf: $(SOURCES) $(COMMON_DIR)/linker.ld $(COMMON_DIR)/tinycpu_mmio.h Makefile
	$(CC) $(CFLAGS) -I$(COMMON_DIR) $(LDFLAGS) -o $@ $(SOURCES)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin $(COMMON_DIR)/makehex.py
	python3 $(COMMON_DIR)/makehex.py $< $@

$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

disasm: $(TARGET).elf
	$(OBJDUMP) -d $<

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).dump
