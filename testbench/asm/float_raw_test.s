// Assembly code for RV64FD test

#include "defines.h"

#define STDOUT 0xd000000050580000


// Code to execute
.section .text
.global _start
_start:

    // Clear minstret
    csrw minstret, zero
    //there is no minstreth in RV64I
    //csrw minstreth, zero

    // Set up MTVEC - not expecting to use it though
    li x1, RV_ICCM_SADR
    csrw mtvec, x1


    // Enable Caches in MRAC
    li x1, 0x5f555555
    csrw 0x7c0, x1

    // Test fadd.s
    // 1.5f + 1.0f = 2.5f
    // 1.5f
    li x1, 0x3fc00000
    sw x1, 0(x4)
    // 1.0f
    li x1, 0x3f800000
    sw x1, 8(x4)
    // 2.5f
    li x1, 0x40200000
    sw x1, 16(x4)
    // 0.5f
    li x1, 0x3f000000
    sw x1, 24(x4)
    // Load 1.5f to FGPRs
    flw f1, 0(x4)
    // Load 1.0f to FGPRs
    flw f2, 8(x4)
    // Do fadd.s, expect 2.5f as a result
    fadd.s f3, f1, f2
    // Do fsub.s, expect 0.5f as a result
    fsub.s f4, f1, f2

    // Load string from hw_data
    // and write to stdout address

    li x3, STDOUT
    la x4, hw_data

loop:
   lb x5, 0(x4)
   sb x5, 0(x3)
   addi x4, x4, 1
   bnez x5, loop

// Write 0xff to STDOUT for TB to terminate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr

.global hw_data
.data
hw_data:
.ascii "-----------------------------------------\n"
.ascii "Hello World from SweRV EH1 64-bit @XMU !!\n"
.ascii ".data/.rodata is preload by tb to DCCM !!\n"
.ascii "-----------------------------------------\n"
.byte 0
