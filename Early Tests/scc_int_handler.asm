;*******************************************************************************
; FILE    scc_int_handler.asm
; PROJECT Serial Interrupt Handler
; AUTHOR  ImpendingMoon
; DATE    2024-04-26
;
; Uses IM1 to handle SCC communication through dedicated handlers
; NOTE: Runs at 38400 baud
;******************************************************************************* 

; A1->D/C, A2->A/B
SCC_BC: EQU 00000000b
SCC_BD: EQU 00000010b
SCC_AC: EQU 00000100b
SCC_AD: EQU 00000110b

    ORG     0h
    JP      _start

    DS      38h-$
    ORG     38h
_int:
    EX      AF, AF'
    EXX
    ; Read the interrupt vector with status bits to get jump vector
    LD      A, 2                        ; Select Register 2
    OUT     (SCC_BC), A
    IN      A, (SCC_BC)                 ; Read vector w/ status
    LD      H, 0                        ; Move to HL
    LD      L, A

    ; Get interrupt handler address from vector
    LD      E, (HL)
    INC     HL
    LD      D, (HL)

    ; Jump to interrupt handler
    EX      DE, HL
    JP      (HL)

_int_end:
    ; Reset highest Interrupt Under Service status in SCC
    LD      A, 00111000b
    OUT     (SCC_AC), A

    EXX
    EI
    RETI

; Can be odd-aligned
_int_handlers:
    DW      _int_end                    ; B Tx Empty
    DW      _int_end                    ; B External/Status
    DW      _int_end                    ; B Rx Recieve
    DW      _int_end                    ; B Rx Special
    DW      _int_end                    ; A Tx Empty
    DW      _int_end                    ; A External/Status
    DW      _int_rx_handler             ; A Rx Recieve
    DW      _int_rx_handler             ; A Rx Special

    DS      100h-$
    ORG     100h

_start:
    LD      SP, 0FFFFh                  ; Load SP to top of RAM

    ; Run the setup routine for the SCC
    LD      C, SCC_AC
    LD      B, SCC_INIT_NUM_CMDS
    LD      HL, SCC_INIT_ROUTINE
    OTIR

    ; Enable interrupts
    IM      1
    EI

_end:
    ; Indefinitely wait for an interrupt
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
    DB 02h, _int_handlers               ; Interrupt vector
    DB 01h, 00010001b                   ; Interrupt on all Rx, never on Tx
    DB 09h, 00101000b                   ; Software INTACK, MIE
    DB 05h, 01101000b                   ; 8-bit, Enable Tx
    DB 03h, 11000001b                   ; 8-bit, Enable Rx
SCC_INIT_ROUTINE_END:
SCC_INIT_NUM_CMDS: EQU SCC_INIT_ROUTINE_END-SCC_INIT_ROUTINE



_int_rx_handler:
    IN      A, (SCC_AD)                 ; Not handling status yet
    OUT     (SCC_AD), A                 ; Just echo back char

.end_int_rx_handler:
    ; Reset highest Interrupt Under Service status in SCC
    LD      A, 00111000b
    OUT     (SCC_AC), A

    EX      AF, AF'
    EXX
    EI
    RETI
