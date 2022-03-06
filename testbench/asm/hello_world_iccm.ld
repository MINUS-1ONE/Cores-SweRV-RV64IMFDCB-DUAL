OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS {
  .text  :  { *(.text*) }
  . = 0x10000;
  .data  :  { *(.*data) *(.rodata*)}
  . = ALIGN(8);
  printf_start = .;
  . = 0x6e000000;
  .data_load : AT(printf_start) {*(.data_text)}
  printf_end = printf_start + SIZEOF(.data_load);
}
