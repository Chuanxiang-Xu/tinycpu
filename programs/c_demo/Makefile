CROSS ?= riscv64-unknown-elf
CC      := $(CROSS)-gcc
OBJCOPY := $(CROSS)-objcopy
OBJDUMP := $(CROSS)-objdump

ARCH_FLAGS := -march=rv32i -mabi=ilp32 -mno-relax
CFLAGS := $(ARCH_FLAGS) -Os -ffreestanding -fno-builtin -fno-pic -Wall -Wextra
LDFLAGS := $(ARCH_FLAGS) -T linker.ld -nostdlib -nostartfiles -Wl,--no-relax -Wl,--gc-sections -Wl,--build-id=none

TARGET := firmware
SOURCES := startup.S main.c

.PHONY: all clean disasm

all: $(TARGET).hex

$(TARGET).elf: $(SOURCES) linker.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ startup.S main.c

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin makehex.py
	python3 makehex.py $< $@

disasm: $(TARGET).elf
	$(OBJDUMP) -d $<

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).hex
