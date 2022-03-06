
OUTPUT_ARCH( "riscv" )
ENTRY(_start)
MEMORY {
    EXTCODE : ORIGIN = 0,          LENGTH = 0x10000
    EXTDATA : ORIGIN = 0x10000,    LENGTH = 0x10000
    ICCM    : ORIGIN = 0x6e000000, LENGTH = 0x80000
    DCCM    : ORIGIN = 0x70040000, LENGTH = 0x10000
    CTL     : ORIGIN = 0xffffffe0, LENGTH = 32
    IO      : ORIGIN = 0xd000000050580000, LENGTH = 0x1000
}
SECTIONS {
  .text.init : {*(.text.init)} > EXTCODE
  init_end = .;
  .data.io  : { *(.data.io) } > IO
  .text : { *(.text) *(.text.startup)} > ICCM
   text_end = .;
  .data  :  { *(.*data) *(.rodata*) *(.sbss) STACK = ALIGN(16) + 0x1000;} > DCCM
  .bss : { *(.bss)} > DCCM
  .data.ctl :  { QUAD(ADDR(.text)); QUAD(text_end); QUAD(0x70040000); QUAD(STACK)}>CTL
}
