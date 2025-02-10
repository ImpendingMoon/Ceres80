;******************************************************************************
; CONSTANTS
;******************************************************************************
BIOS_MAJOR_VER: EQU 0
BIOS_MINOR_VER: EQU 0
BIOS_PATCH_VER: EQU 2

CTC_CH0: EQU %0000
CTC_CH1: EQU %0001
CTC_CH2: EQU %0010
CTC_CH3: EQU %0011
PIO_AD: EQU %0100
PIO_BD: EQU %0101
PIO_AC: EQU %0110
PIO_BC: EQU %0111
LCD_C1: EQU %1000
LCD_D1: EQU %1001
LCD_C2: EQU %1010
LCD_D2: EQU %1011

STACK_CANARY: EQU $A7
CTC_TC: EQU 23

;******************************************************************************
; CODE
;******************************************************************************

    ORG $0000
    JP _start

    DS $0008-$
    ORG $0008
call_handler:
    PUSH DE
    PUSH HL

    ADD A                               ; Multiply call by 2 for address offset
    LD E, A                             ; Load into 16-bit reg to add offset
    LD D, 0

    LD A, (stack_base)                  ; Check for stack overflows
    CP STACK_CANARY
    JR NZ, bad_canary

    LD HL, call_table                   ; Point to offset in call_table
    ADD HL, DE

    LD E, (HL)                          ; Load function address into DE
    INC HL
    LD D, (HL)
    EX DE, HL                           ; Move address into HL for jump
    JP (HL)                             ; Called function does cleanup and ret

bad_canary:
    LD SP, $FFFF                        ; Stack already bad, reset
    LD HL, 0
    ;CALL i_set_charmap                  ; Charmap might be clobbered, reset
    ;LD DE, str_bad_canary              ; Print error message at 0,0
    ;CALL i_print_string

.canary_input:
    ;CALL i_get_buttons
    AND L                               ; Get only newly pressed buttons
    JP Z, .canary_input                 ; Wait for any button press then reset
    RST $00

invalid_call:
    POP HL
    POP DE
    RET

    ; MAX: 48 bytes between call_handler and isr
    DS $0038-$
    ORG $0038
isr:
    EXX
    EX AF, AF'

    ; Increment system ticks
    ; 16b 34/58/82/93c (34c 99.6% of runs)
    LD HL, system_ticks
    INC (HL)
    JR NC, .check_alarm
    INC HL
    INC (HL)
    JR NC, .check_alarm
    INC HL
    INC (HL)
    JR NC, .check_alarm
    INC HL
    INC (HL)

.check_alarm:
    LD A, (alarm_set)
    AND 1
    JP Z, .end_isr

.update_alarm:
    LD HL, (alarm_timer)
    DEC HL
    LD (alarm_timer), HL

    ; If zero, call the alarm function
    XOR A
    LD HL, (alarm_timer)
    CP L
    JP NZ, .end_isr
    CP H
    JP NZ, .end_isr

    ; Reset timer
    LD HL, (alarm_tc)
    LD (alarm_timer), HL

    ; If alarm_repeat is set, don't clear alarm
    LD A, (alarm_repeat)
    CP 0
    JR NZ, .run_alarm

    XOR A
    LD (alarm_set), A
.run_alarm:
    LD HL, (alarm_address)
    JP (HL)

.end_isr:
    EXX
    EX AF, AF'
    EI
    RETI



_start:
    ; Clear framebuffer, working RAM, and stack
    LD HL, framebuffer
    LD DE, framebuffer + 1
    LD (HL), 0
    LD BC, $FFFF - framebuffer - 1
    LDIR

    ; Setup stack
    LD SP, stack_top
    LD A, STACK_CANARY
    LD (stack_base), A

    ; Initialize Timer
    LD A, %10100111                     ; Int, 256ps, tc follows
    OUT (CTC_CH0), A
    LD A, CTC_TC
    OUT (CTC_CH0), A

    IM 1
    EI

    ; Initialize LCD
    CALL i_lcd_wait
    LD A, %00111111                     ; Display On
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    ; Initialize SD Card

    ; TEMP: Draw stuff to make sure I actually know how
.draw_temp:
    LD HL, smail
    LD DE, framebuffer
    LD BC, 1024
    LDIR

.loop:
    CALL i_render
    LD HL, framebuffer
    RLC (HL)
    LD HL, 500
    CALL i_sleep
    JR .loop

.end:
    ; Eventually this will load the shell program or wait for an SD Card
    HALT
    JR .end

    INCLUDE "control.s"
    INCLUDE "display.s"
    INCLUDE "call_table.s"

smail:
    INCBIN "smail.img"


;*******************************************************************************
; RAM
;*******************************************************************************
    ORG $F800
framebuffer:

    ORG $F900
bios_work_ram:

system_ticks: DS 4

alarm_address: DS 2
alarm_timer: DS 2
alarm_tc: DS 2
alarm_set: DS 1
alarm_repeat: DS 1

    ORG $FD00
stack_base:

    ORG $FFFF
stack_top:
