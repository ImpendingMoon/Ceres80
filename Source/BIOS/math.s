;**
; mul8: Multiply 8-bit
; Multiplies two unsigned 8-bit integers into an unsigned 16-bit integer
; Parameters:
; - H: Multiplicand
; - L: Multiplier
; Returns:
; - HL: Product
; Notes:
; - Sourced from: https://map.grauw.nl/articles/mult_div_shifts.php
;**
e_mul8:
    POP HL
    POP DE
i_mul8:
    PUSH BC
    PUSH DE

    LD E, L
    LD D, 0
    LD L, D

    LD B, 8
.mul8_loop:
    ADD HL, HL
    JR NC, .mul8_skip
    ADD HL, DE
.mul8_skip:
    DJNZ .mul8_loop

    POP BC
    POP DE
    RET


;**
; div8: Divide 8-bit
; Divides two unsigned 8-bit integers into two unsigned 8-bit integers
; Parameters:
; - H: Dividend
; - L: Divisor
; Returns:
; - H: Quotient
; - L: Remainder
; Notes:
; - Does not check for Divide By Zero, returns garbage
; - Sourced from: https://map.grauw.nl/articles/mult_div_shifts.php
;**
e_div8:
    POP HL
    POP DE
i_div8:
    PUSH BC

    XOR A

    LD B, 8
.div8_loop:
    RL H
    RLA
    SUB L
    JR NC, .div8_skip
    ADD A, L
.div8_skip:
    DJNZ .div8_loop

    LD L, A
    LD A, H
    RLA
    CPL
    LD H, A

    POP BC
    RET



;**
; mul16: Multiply 16-bit
; Multiplies two unsigned 16-bit integers into an unsigned 32-bit integer
; Parameters:
; - HL: Multiplicand
; - DE: Multiplier
; Returns:
; - HLDE: Product
; Notes:
; - Sourced from: https://map.grauw.nl/articles/mult_div_shifts.php
;**
e_mul16:
    POP HL
    POP DE
i_mul16:
    PUSH BC

    LD A, L
    LD C, H
    LD HL, 0

    LD B, 16
.mul16_loop:
    ADD HL, HL
    RLA
    RL C
    JR NC, .mul16_skip
    ADD HL, DE
    ADC A, 0
    JP NC, .mul16_skip
    INC C
.mul16_skip:
    DJNZ .mul16_loop
    
    LD E, C
    LD D, A
    EX DE, HL
    POP BC
    RET



;**
; div16: Divide 16-bit
; Divides two unsigned 16-bit integers into two unsigned 16-bit integers
; Parameters:
; - HL: Dividend
; - DE: Divisor
; Returns:
; - HL: Quotient
; - DE: Remainder
; Notes:
; - Does not check for Divide By Zero, returns garbage
; - Sourced from: https://map.grauw.nl/articles/mult_div_shifts.php
;**
e_div16:
    POP HL
    POP DE
i_div16:
    PUSH BC

    LD A, H
    LD C, L
    LD HL, 0

    LD B, 8
.div16_loop1:
    RLA
    ADC HL,HL
    SBC HL,DE
    JR NC, .div16_skip1
    ADD HL, DE
.div16_skip1:
    DJNZ .div16_loop1

    RLA
    CPL
    LD B, A
    LD A, C
    LD C, B

    LD B, 8
.div16_loop2:
    RLA
    ADC HL, HL
    SBC HL, DE
    JR NC, .div16_skip2
    ADD HL, DE
.div16_skip2:
    DJNZ .div16_loop2
    RLA
    CPL
    EX DE, HL
    LD H, C
    LD L, A

    POP BC
    RET
