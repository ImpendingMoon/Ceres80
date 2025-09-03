;******************************************************************************
; @file call_table.s
; @brief System call table and invalid call function definition
;
; @license GPL-3.0-or-later
;******************************************************************************

.globl call_table

.globl _exit
.globl _get_version
.globl _sleep
.globl _get_uptime

invalid_call:
    ld a, #-1
    ld l, #-1
    ret

call_table:
    .dw _exit
    .dw _get_version
    .dw _sleep
    .dw _get_uptime
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
    .dw invalid_call
