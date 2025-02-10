;**
; lcd_wait: Wait for LCD
; Waits for the LCD to report that it is ready to process input
; Parameters: None
; Returns: None
;**
i_lcd_wait:
    PUSH BC
.lcd_wait_loop:
    LD B, 17                            ; Wait ~37us for LCD
    DJNZ $

    IN A, (LCD_C1)
    RLCA
    JR C, .lcd_wait_loop
    IN A, (LCD_C2)
    RLCA
    JR C, .lcd_wait_loop
    
    POP BC
    RET
