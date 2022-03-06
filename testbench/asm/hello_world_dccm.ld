
OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS {
  .text   : { *(.text*) }
 _end = .;
  . = 0xd000000050580000;
  .data.io   : { *(.data.io) }
  . = 0x70040000;
  .data  :  { *(.*data) *(.rodata*) *(.sbss) STACK = ALIGN(16) + 0x1000;}
  .bss 	 : { *(.bss)}
  . = 0xfffffff0;
  .data.ctl : { QUAD(0x70040000); QUAD(STACK) }
}
