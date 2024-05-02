;*******************************************************************************
; FILE    mem_bank.asm
; PROJECT Memory Banking
; AUTHOR  ImpendingMoon
; DATE    2024-04-27
;
; Uses the SCC to test memory banking
;*******************************************************************************  

SCC_BC: EQU 00000000b
SCC_BD: EQU 00000010b
SCC_AC: EQU 00000100b
SCC_AD: EQU 00000110b

BANK_ROM: EQU 11100000b
BANK_RAM: EQU 11100001b

    ORG     00h

_start:
    LD      SP, 0FFFFh                  ; Load SP to top of RAM

    LD      C, SCC_AC                   ; Run the setup routine for the SCC
    LD      B, SCC_INIT_NUM_CMDS
    LD      HL, SCC_INIT_ROUTINE
    OTIR

    CALL    testLRAM
    ADD     '0'
    CALL    putc

_end:
    HALT
    JR      _end



SCC_INIT_ROUTINE:
    DB 09h, 11000000b                   ; Hardware Reset
    DB 00h, 00000000b                   ; NOP (wait for reset)
    DB 0Ch, 6                           ; BRG Time Constant Lower (38400 baud)
    DB 0Dh, 0                           ; BRG Time Constant Upper
    DB 0Eh, 00000011b                   ; Use PCLK, Enable BRG
    DB 0Bh, 01010110b                   ; Tx Rx use BRG, output BRG on TRxC
    DB 0Fh, 00000001b                   ; WR7' Enable
    DB 07h, 01000000b                   ; Enable Extended Read
    DB 0Fh, 00000000b                   ; WR7' Disable
    DB 04h, 01000100b                   ; X16 CLK, 1 Stop Bit, No Parity
    DB 0Ah, 00000000b                   ; No CRC, NRZ Encoding
    DB 02h, 00000000b                   ; Interrupt vector
    DB 01h, 00010001b                   ; Interrupt on all Rx, never on Tx
    DB 09h, 00101000b                   ; Software INTACK, MIE
    DB 05h, 01101000b                   ; 8-bit, Enable Tx
    DB 03h, 11000001b                   ; 8-bit, Enable Rx
SCC_INIT_ROUTINE_END:
SCC_INIT_NUM_CMDS: EQU SCC_INIT_ROUTINE_END-SCC_INIT_ROUTINE



;*******************************************************************************
; putc: Put Character
; Sends a character to the terminal through SCC Channel A
; @param  A (char) Character to print
; @return void
;*******************************************************************************
putc:
    PUSH    BC
    LD      B, A
.loop_putc:
    ; Wait until SCC is ready to transmit another character
    LD      A, 1                        ; Select Register 1
    OUT     (SCC_AC), A
    IN      A, (SCC_AC)                 ; Status
    RRA                                 ; R1.0: All Sent
    JP      NC, .loop_putc

    ; Write character
    LD      A, B
    OUT     (SCC_AD), A

    POP     BC
    RET




;*******************************************************************************
; testLRAM: Test Low Memory Bank
; Runs a simple test to see if the low memory bank can be accessed
; @return A (bool) 0 if failed, 1 if successful
;*******************************************************************************
testLRAM:
    PUSH    BC
    PUSH    DE
    PUSH    HL

    ; Load test program into HRAM (since ROM will be banked out)
    LD      HL, start_testLRAM_Copy
    LD      DE, testLRAM_Target
    LD      BC, TEST_LRAM_SZ
    LDIR
    CALL    testLRAM_Target

    POP     HL
    POP     DE
    POP     BC
    RET

start_testLRAM_Copy:
    ; Fill LRAM with 0
    OUT     (BANK_RAM), A

    XOR     A
    LD      (0000h), A                  ; Seed first value
    LD      HL, 0
    LD      DE, 1
    LD      BC, 7FFFh
    LDIR

    ; Test to see if LRAM is all 0s. ROM has the program, so won't be all 0s.
    LD      BC, 8000h
    LD      HL, 0
.testLoop:
    LD      A, (HL)
    INC     HL
    AND     A
    JR      NZ, .wasROM
    DJNZ    .testLoop

.wasNotROM:
    LD      A, 1
    JR      .end_testLRAM_Copy

.wasROM:
    XOR     A

.end_testLRAM_Copy:
    OUT     (BANK_ROM), A
    RET


_end_testLRAM_Copy:
TEST_LRAM_SZ: EQU _end_testLRAM_Copy - start_testLRAM_Copy

    ORG     8000h                       ; Start of RAM

testLRAM_Target:
