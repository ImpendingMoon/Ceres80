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


;**
; rand_init: Initialize RNG
; Sets rng_state to a nonzero value based on system_ticks
; Works best after system has been running for some time
; Parameters: None
; Returns: None
;**
i_rand_init:
    PUSH BC
    PUSH DE
    PUSH HL

    ; System ticks should not be zero (1 in 4 billion chance)
.rand_init_time_entropy:
    LD HL, system_ticks
    LD DE, rng_state
    LD BC, 4
    LDIR

    ; Read raw button state, want non-debounced state for entropy
.rand_init_button_entropy:
    LD HL, rng_state
    IN A, (PIO_AD)
    XOR (HL)
    LD (HL), A
    INC HL
    IN A, (PIO_AD)
    XOR (HL)
    LD (HL), A
    INC HL
    IN A, (PIO_AD)
    XOR (HL)
    LD (HL), A
    INC HL
    IN A, (PIO_AD)
    XOR (HL)
    LD (HL), A

    ; Make sure it still isn't zero
.rand_init_check_zero:
    LD HL, rng_state
    LD A, (HL)
    INC HL
    OR (HL)
    INC HL
    OR (HL)
    INC HL
    OR (HL)
    JR Z, .rand_init_time_entropy

    POP HL
    POP DE
    POP BC
    RET


;**
; rand: Random Integer
; Generates a random integer between 0 and 65535 using xorshift
; Parameters: None
; Returns:
; - HL: Random integer
;**
e_rand:
    POP HL
    POP DE
i_rand:
    PUSH BC
    PUSH DE

    DI
    ; x ^= x << 13
    CALL .rand_copy                     ; scratch = state
    LD B, 13
    CALL .rand_shift_left               ; scratch = scratch << 13
    CALL .rand_xor                      ; state = state ^ scratch

    ; x ^= x >> 17
    CALL .rand_copy
    LD B, 17
    CALL .rand_shift_right
    CALL .rand_xor

    ; x ^= x << 5
    CALL .rand_copy
    LD B, 5
    CALL .rand_shift_left
    CALL .rand_xor

    LD HL, rng_state+1                  ; Pull middle 16 bits from 32-bit state
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL                           ; Move to HL for return value

    EI
    POP DE
    POP BC
    RET

; Copy current state to scratch
.rand_copy:
    LD HL, rng_state
    LD DE, rng_scratch
    LD B, 4
.rand_copy_loop:
    LD A, (HL)
    LD (DE), A
    INC HL
    INC DE
    DJNZ .rand_copy_loop
    RET

; Shift scratch to the left B times
.rand_shift_left:
    LD HL, rng_scratch
    SLA (HL)
    INC HL
    RL (HL)
    INC HL
    RL (HL)
    INC HL
    RL (HL)
    DJNZ .rand_shift_left
    RET

; Shift scratch to the right B times
.rand_shift_right:
    LD HL, rng_scratch + 3
    SRL (HL)
    DEC HL
    RR (HL)
    DEC HL
    RR (HL)
    DEC HL
    RR (HL)
    DJNZ .rand_shift_right
    RET

; XORs rng_sratch with rng_state, result in rng_state
.rand_xor:
    LD HL, rng_scratch
    LD DE, rng_state
    LD B, 4
.rand_xor_loop:
    LD A, (DE)
    XOR (HL)
    LD (DE), A
    INC HL
    INC DE
    DJNZ .rand_xor_loop
    RET

