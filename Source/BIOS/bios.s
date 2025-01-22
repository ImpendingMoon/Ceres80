;******************************************************************************
; CONSTANTS
;******************************************************************************
CTC_CH0: EQU %0000
CTC_CH1: EQU %0001
CTC_CH2: EQU %0010
CTC_CH3: EQU %0011
PIO_AD: EQU %0100
PIO_BD: EQU %0101
PIO_AC: EQU %0110
PIO_BC: EQU %0111
LCD_C1: EQU %1000
LCD_C2: EQU %1001
LCD_D1: EQU %1010
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

    RLCA                                ; Multiply call by 2 for address
    LD E, A                             ; Load into 16-bit reg for offset
    LD D, 0

    LD A, (stack_base)                  ; Check for stack overflows
    CP STACK_CANARY
    JP Z, bad_canary

    LD HL, call_table                   ; Point to offset in call_table
    ADD HL, DE

    LD E, (HL)                          ; Load function address into DE
    INC HL
    LD D, (HL)
    EX DE, HL                           ; Move address into HL for jump
    JP (HL)                             ; Called function does cleanup

bad_canary:
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
    JP NC, check_alarm         ; 3b 10c
    LD HL, (system_ticks + 2)   ; 3b 16c
    ADD HL, DE                  ; 1b 11c
    LD (system_ticks), HL       ; 3b 16c

check_alarm:
    LD A, (alarm_set)
    JP Z, end_isr

update_alarm:
    LD HL, (alarm_timer)
    DEC HL
    LD (alarm_timer), HL

   ; If zero, call the alarm function
    XOR A
    LD HL, (alarm_timer)
    CP L
    JP NZ, end_isr
    CP H
    JP NZ, end_isr

    LD HL, (alarm_tc)
    LD (alarm_timer), HL

    ; If alarm_repeat is set, don't clear alarm
    LD A, (alarm_repeat)
    CP 0
    JR NZ, run_alarm

    XOR A
    LD (alarm_set), A
run_alarm:
    LD HL, (alarm_address)
    JP (HL)

end_isr:
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
    LD A, %10100111                     ; Int, 256ps, reset, tc follows
    OUT (CTC_CH0), A
    LD A, CTC_TC
    OUT (CTC_CH0), A

    IM 1
    EI

    ; Initialize LCD
    ;CALL i_lcd_render
    ;CALL i_lcd_wait
    LD A, %00000001
    OUT (LCD_C1), A
    OUT (LCD_C2), A
    ;CALL i_lcd_wait

    ; TEST: Wait a bit and print a simple thing to the LCD
    HALT
    HALT
    LD A, %10101010
    OUT (LCD_D1), A
    OUT (LCD_D2), A


    ; Initialize SD Card


    HALT

    INCLUDE "call_table.s"


    ORG $F800
framebuffer:

    ORG $F900
bios_work_ram:

; Weird endianness (3412) Use as two 16-bit values to load correctly
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

