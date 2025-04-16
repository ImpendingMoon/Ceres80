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



; NOTE: This cannot be optimized further for speed due to the LCD's rate limit.
; NOTE: This should be optimized for size
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
    LD HL, framebuffer                  ; HL is a pointer to the current tile
    LD DE, FB_WIDTH_TILES * 7           ; Stride -1 row, adds at end of row
    LD B, FB_HEIGHT_TILES
.render_rows:
    CALL i_lcd_wait
    LD A, FB_HEIGHT_TILES
    SUB B
    OR %10111000                        ; Set X = 8 - C
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    PUSH BC                             ; Render tiles stack frame

    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0 (it gets clobbered)
    OUT (LCD_C1), A

    LD C, LCD_D1                        ; Left LCD data port
    LD B, FB_WIDTH_TILES / 2            ; Render half the row
.render_left_tiles:
    CALL i_rotate_send_tile             ; Send current tile
    INC HL                              ; Move to the next tile
    DJNZ .render_left_tiles

    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0 (it gets clobbered)
    OUT (LCD_C2), A

    LD C, LCD_D2                        ; Right LCD data port
    LD B, FB_WIDTH_TILES / 2            ; Render the other half
.render_right_tiles:
    CALL i_rotate_send_tile             ; Send current tile
    INC HL                              ; Move to the next tile
    DJNZ .render_right_tiles

    POP BC                              ; End render tiles stack frame
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
    
    LD DE, FB_WIDTH_TILES               ; Stride
    LD B, 8                             ; 8 rows per tile
.rotate_tile_cols:
    PUSH BC                             ; Inner stack frame
    PUSH HL
    LD B, 8                             ; 8 bits/cols per pixel
.rotate_tile_rows:
    RLC (HL)                            ; Rotate MSB out of row
    RRA                                 ; Rotate into MSB of new col
    ADD HL, DE                          ; Point to next row
    DJNZ .rotate_tile_rows              ; Repeat until col is filled

    OUT (C), A                          ; Send col

    POP HL
    POP BC                              ; End inner stack frame
    DJNZ .rotate_tile_cols

    POP DE
    POP BC
    RET
