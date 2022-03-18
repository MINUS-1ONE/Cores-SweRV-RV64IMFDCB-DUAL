/*
 NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
 This is an automatically generated file by riscv on Fri 18 Mar 2022 02:34:11 AM PDT

 cmd:    swerv -target=default -set iccm_enable 

*/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x0000000000000000;
  .text.init .  : { *(.text.init) }
   . = 0x6e000000 ;
  .text . : { *(.text) }
  _end = .;
  . = 0xf000000000580000;
  .data.io .  : { *(.data.io) }
    . = 0x70040000 ;
  .data  :  ALIGN(0x800) { *(.*data) *(.rodata*)}
  .bss :  {BSS_START = .; *(.*bss)}
  BSS_END = .;
  STACK = ALIGN(16) + 0x1000;
    . = 0xffffffffffffffff0; .iccm.ctl . : { LONG(0x6e000000); LONG(0x6e07ffff) }
    . = 0xffffffffffffffff8; .data.ctl : { LONG(0x70040000); LONG(STACK) }
}

