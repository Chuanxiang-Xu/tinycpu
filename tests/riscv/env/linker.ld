OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  bram (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
  .text 0x00000000 :
  {
    KEEP(*(.text.start))
    *(.text .text.*)
  } > bram

  .rodata ALIGN(4) :
  {
    *(.rodata .rodata.*)
  } > bram

  .data ALIGN(4) :
  {
    *(.sdata .sdata.*)
    *(.data .data.*)
  } > bram

  .bss ALIGN(4) (NOLOAD) :
  {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > bram

  PROVIDE(__stack_top = ORIGIN(bram) + LENGTH(bram));
}
