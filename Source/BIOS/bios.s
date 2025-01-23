;******************************************************************************
; CONSTANTS
;******************************************************************************
BIOS_MAJOR_VER: EQU 0
BIOS_MINOR_VER: EQU 0
BIOS_PATCH_VER: EQU 1

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

    RLCA                                ; Multiply call by 2 for address offset
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

    ; Update system ticks
    ; Use ADD because INC HL doesn't set flags for carry detection
    ; 20b 63/106c
    LD DE, 1                    ; 3b 10c
    LD HL, (system_ticks)       ; 3b 16c
    ADD HL, DE                  ; 1b 11c
    LD (system_ticks), HL       ; 3b 16c
    JP NC, .check_alarm         ; 3b 10c
    LD HL, (system_ticks + 2)   ; 3b 16c
    ADD HL, DE                  ; 1b 11c
    LD (system_ticks), HL       ; 3b 16c

.check_alarm:
    LD A, (alarm_set)
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
    LD A, %00111111                     ; Display On
    OUT (LCD_C1), A
    OUT (LCD_C2), A
    CALL i_lcd_wait
    LD A, %11000000                     ; Start line 0 (reset scroll)
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    ; Initialize SD Card

    ; TEMP: Print stuff to the display
    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    CALL i_lcd_wait
    LD A, %10111000                     ; Set X=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    LD B, 1
.draw_loop:
    CALL i_lcd_wait
    LD A, B
    OUT (LCD_D1), A
    OUT (LCD_D2), A
    RLCA
    LD B, A
    LD A, 0x03
    LD HL, 1000
    RST $08
    JR .draw_loop

.end:
    ; Eventually this will load the shell program or wait for an SD Card
    HALT
    JR .end

    INCLUDE "control.s"
    INCLUDE "display.s"
    INCLUDE "call_table.s"



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

