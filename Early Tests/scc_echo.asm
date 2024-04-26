;*******************************************************************************
; FILE    scc_echo.asm
; PROJECT Serial Echo
; AUThOR  ImpendingMoon
; DATE    2024-04-26
; Sets up the SCC to echo back any character at 9600 baud
;*******************************************************************************

; A1->D/C, A2->A/B
SCC_BC: EQU %00000000
SCC_BD: EQU %00000010
SCC_AC: EQU %00000100
SCC_AD: EQU %00000110

    ORG 0h
    jp      start

    ; Padding because z80asm doesn't add any bytes...
    DEFS 38h-$

    ORG 38h
    reti

    DEFS 100h-$

    ORG 100h
start:
    ; Reset SCC
    ld      A, 9                        ; Select R9
    out     (SCC_AC), A
    ld      A, 11000000b                ; Hardware reset
    out     (SCC_AC), A
    
    nop                                 ; Wait for SCC to reset
    nop
    nop
    nop

    ; Baud Rate Generator
    ; TC = Clock Frequency / (2 * Baud Rate * Prescaler)
    ; 10,000,000 / (2 * 9600 * 16) = 31.55
    ; Truncated to 31, actual rate of 9469.7
    ; 1.37% difference, within 2.5% tolerance of RS232
    ld      A, 12                       ; Select R12
    out     (SCC_AC), A
    ld      A, 31                       ; Lower byte of time constant
    out     (SCC_AC), A
    ld      A, 13                       ; Select R13
    out     (SCC_AC), A
    ld      A, 0                        ; Upper byte of time constant
    out     (SCC_AC), A

    ld      A, 14                       ; Select R14
    out     (SCC_AC), A
    ld      A, 00001011b                ; Auto Echo, Use PCLK, Enable BRG
    out     (SCC_AC), A

    ; Clock Control
    ld      A, 11                       ; Select R11
    out     (SCC_AC), A
    ld      A, 01010110b                ; Tx Rx use BRG, output BRG on TRxC
    out     (SCC_AC), A

    ; 85C30 Extended Functions
    ld      A, 15                       ; Select R15
    out     (SCC_AC), A
    ld      A, 00000001b                ; WR7' Enable
    out     (SCC_AC), A

    ld      A, 7                        ; Select R7'
    out     (SCC_AC), A
    ld      A, 01000000b                ; Enable Extended Read
    out     (SCC_AC), A

    ld      A, 15                       ; Select R15
    out     (SCC_AC), A
    ld      A, 00000000b                ; WR7' Disable
    out     (SCC_AC), A

    ; Tx/Rx Misc. Parameters/Modes
    ld      A, 4                        ; Select R4
    out     (SCC_AC), A
    ld      A, 01000100b                ; X16 CLK, 1 Stop Bit, No Parity
    out     (SCC_AC), A

    ; Tx/Rx Misc. Control
    ld      A, 10                       ; Select R10
    out     (SCC_AC), A
    ld      A, 00000000b                ; No CRC, NRZ Encoding
    out     (SCC_AC), A

    ; Interrupt Vector
    ld      A, 2                        ; Relect R2
    out     (SCC_AC), A
    ld      A, 00000000b                ; No interrupt vector (IM 1, eventually)
    out     (SCC_AC), A

    ; Interrupt Enable
    ld      A, 9                        ; Select R9
    out     (SCC_AC), A
    ld      A, 00101000b                ; Software INTACK, MIE
    out     (SCC_AC), A

    ; Tx Enable
    ld      A, 5                        ; Select R5
    out     (SCC_AC), A
    ld      A, 01101000b                ; 8-bit, Enable Tx
    out     (SCC_AC), A

    ; Rx Enable
    ld      A, 3                        ; Select R3
    out     (SCC_AC), A
    ld      A, 11000001b                ; 8-bit, Enable Rx
    out     (SCC_AC), A

end:
    halt
    jr      end
