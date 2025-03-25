;**
; get_button_state: Get Button State
; Reads the buttons with software debouncing
; Parameters: None
; Returns:
; - A: Current button state
; - L: Buttons changed since last read
;**
e_get_button_state:
    POP HL
    POP DE
i_get_button_state:
    PUSH BC
    PUSH HL

    LD B, 8                             ; Read 8 times for debounce
    LD C, 0
.get_button_state_loop:
    IN A, (PIO_AD)                      ; Pull-up buttons (0 = pressed, 1 = up)
    OR C                                ; OR to prefer not pressing buttons
    LD C, A
    DJNZ .get_button_state_loop
    XOR $FF                             ; Invert so 0 = up, 1 = pressed

    LD HL, button_state
    XOR A, (HL)                         ; Get buttons that changed
    LD (HL), C                          ; Store current button state

    POP HL

    LD L, A                             ; Move to return values
    LD A, C

    POP BC
    RET
