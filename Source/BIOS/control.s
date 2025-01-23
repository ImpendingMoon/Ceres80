;**
; e_exit: External function for Exit
; Parameters:
; - None
; Returns:
; - N/A
;**
e_exit:
    RST $00


;**
; e_sleep: External function for Sleep Milliseconds
; Halts the system for at least a number of milliseconds
; Parameters:
; - HL (stack): Milliseconds to sleep
; Returns: None
e_sleep:
    POP HL                              ; Pop parameters from stack
    POP DE

;**
; i_sleep: Internal function for Sleep Milliseconds
; Halts the system for at least a number of milliseconds
; Parameters:
; - HL: Milliseconds to sleep
; Returns:
; - None
;**
i_sleep:
    PUSH BC
    XOR A
    HALT                                ; Halt first for minimum time guarantee
.i_delay_loop:
    HALT
    DEC HL
    CP L
    JP NZ, .i_delay_loop
    CP H
    JP NZ, .i_delay_loop

    POP BC
    RET

