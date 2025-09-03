;******************************************************************************
; @file crt0.s
; @brief ROSS C Runtime
; @license BSD-3-Clause
;******************************************************************************

    .module crt0
    .globl  _main
    .globl  l__DATA
    .globl  s__DATA
    .globl  s__INITIALIZED
    .globl  l__INITIALIZER
    .globl  s__INITIALIZER
    .globl  l__BSS
    .globl  s__BSS
    .globl  _isr



    .area   _HEADER (ABS)

    .org 0x0000
    di
    jp start



    ; System Call Dispatcher
    .org 0x0008
    ret



    ; Interrupt Service Routine
    .org 0x0038
    jp _isr



    .area   _HOME
    .area   _CODE
    .area   _INITIALIZER
    .area   _GSINIT
    .area   _GSFINAL

    .area   _DATA
    .area   _INITIALIZED
    .area   _BSEG
    .area   _BSS



    .area   _CODE

start:
    ld  sp, #0xF97F      ; set stack pointer at top of program RAM

    call gsinit          ; initialize data and bss

    call _main

end:
    di
    halt

gsinit:
    ; Copy initialized data from ROM (s__INITIALIZER) to RAM (s__DATA)
    ld  hl, #s__INITIALIZER
    ld  de, #s__DATA
    ld  bc, #l__INITIALIZER
    ldir

    ; Zero out BSS
    ld  hl, #s__BSS
    ld  de, #s__BSS+1
    ld  bc, #l__BSS-1
    ld  a, #0
    ld  (hl), a
    ldir

    ret



    .area _DATA
