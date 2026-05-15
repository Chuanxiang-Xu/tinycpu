OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    . = ORIGIN(ram);

    /DISCARD/ : {
        *(.note*)
        *(.comment*)
    }

    .text : {
        KEEP(*(.init))
        *(.text*)
    } > ram

    .rodata : {
        *(.rodata*)
        *(.srodata*)
    } > ram

    .data : {
        *(.data*)
        *(.sdata*)
    } > ram

    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > ram

    . = ALIGN(16);
    __stack_top = ORIGIN(ram) + LENGTH(ram);
}
