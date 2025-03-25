FB_WIDTH_TILES: EQU 16
FB_HEIGHT_TILES: EQU 8
PX_PER_TILE: EQU 8

;**
; lcd_wait: Wait for LCD
; Waits for the LCD to report that it is ready to process input
; Parameters: None
; Returns: None
;**
i_lcd_wait:
    PUSH BC
    LD C, %1001000                      ; Mask BUSY and RST bits
.lcd_wait_loop:
    LD B, 17
    DJNZ $

    IN A, (LCD_C1)
    AND C
    JR NZ, .lcd_wait_loop
    IN A, (LCD_C2)
    AND C
    JR NZ, .lcd_wait_loop
    
    POP BC
    RET



;**
; lcd_init: Initialize LCD
; Resets the LCD's X,Y,Z registers and turns the display on
; Parameters: None
; Returns: None
;**
i_lcd_init:
    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    CALL i_lcd_wait
    LD A, %11000000                     ; Set Z=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    CALL i_lcd_wait
    LD A, %10111000                     ; Set X=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    CALL i_lcd_wait
    LD A, %00111111                     ; Display On
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    RET



;**
; clear_screen: Clear Screen
; Clears all pixels in the framebuffer
; Parameters: None
; Returns: None
;**
e_clear_screen:
    POP HL
    POP DE
i_clear_screen:
    PUSH BC
    PUSH DE
    PUSH HL

    LD HL, framebuffer
    LD DE, framebuffer + 1
    LD (HL), 0
    LD BC, bios_work_ram - framebuffer - 1
    LDIR

    POP HL
    POP DE
    POP BC
    RET


e_render:
    POP HL
    POP DE
i_render:
    PUSH BC
    PUSH DE
    PUSH HL

    CALL i_lcd_wait
    LD A, %11000000                     ; Set Z=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    DI
    LD HL, framebuffer
    LD DE, FB_WIDTH_TILES * 7           ; Add to HL to skip 7 rows
    LD B, 8
.render_rows:
    CALL i_lcd_wait
    LD A, FB_HEIGHT_TILES               ; X = 8 - C (0, 1, ..., 7)
    SUB B
    OR %10111000                        ; LCD Command: Set X
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    PUSH BC
    LD C, LCD_D1
    LD B, 8

    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0
    OUT (LCD_C1), A
.render_left_tiles:
    CALL i_rotate_send_tile
    INC HL
    DJNZ .render_left_tiles

    LD C, LCD_D2
    LD B, 8

    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0
    OUT (LCD_C2), A
.render_right_tiles:
    CALL i_rotate_send_tile
    INC HL
    DJNZ .render_right_tiles

    POP BC
    ADD HL, DE                          ; Skip forward to next tile row
    DJNZ .render_rows
    EI

    POP HL
    POP DE
    POP BC
    RET



i_rotate_send_tile:
    PUSH BC
    PUSH DE
    
    LD DE, FB_WIDTH_TILES
    LD B, 8
.rotate_tile_cols:
    PUSH BC
    PUSH HL
    LD B, 8
.rotate_tile_rows:
    RLC (HL)
    RRA
    ADD HL, DE
    DJNZ .rotate_tile_rows

    OUT (C), A

    POP HL
    POP BC
    DJNZ .rotate_tile_cols

    POP DE
    POP BC
    RET
