i_lcd_wait:
    IN A, (LCD_C1)
    RLCA
    JR C, .lcd_wait_loop
    IN A, (LCD_C2)
    RLCA
    JR C, .lcd_wait_loop
    RET

.lcd_wait_loop:
    LD B, 17                            ; Wait ~37us for LCD
    DJNZ $
    JR i_lcd_wait

