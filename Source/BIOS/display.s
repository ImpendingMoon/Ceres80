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
; init_lcd: Initialize LCD
; Resets the LCD's X,Y,Z registers and turns the display on
; Parameters: None
; Returns: None
;**
i_init_lcd:
    CALL i_lcd_wait
    LD A, %00111111                     ; Display On
    OUT (LCD_C1), A
    OUT (LCD_C2), A

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
    LD HL, framebuffer
    LD C, FB_HEIGHT_TILES
.render_rows:
    LD A, 8                             ; X = 8 - C (0, 1, ..., 7)
    SUB C
    AND %111
    OR %10111000                        ; LCD Command: Set X
    OUT (LCD_C1), A
    OUT (LCD_C2), A
    CALL i_lcd_wait

    LD DE, FB_WIDTH_TILES               ; Add to HL to index next row
    LD B, FB_WIDTH_TILES / 2
.render_left_tiles:
    PUSH BC
    LD C, PX_PER_TILE
.render_left_tile_cols:
    PUSH HL                             ; Save original pointer
    LD B, PX_PER_TILE
.render_left_tile_rows:
    RLC (HL)                            ; Shift pixel out of row
    RRA                                 ; Shift pixel into new column (LSB=top)
    ADD HL, DE                          ; Point to next row of tile
    DJNZ .render_left_tile_rows         ; Repeat for all rows in the tile

    OUT (LCD_D1), A                     ; Send new column out
    CALL i_lcd_wait

    POP HL                              ; Restore original pointer
    DEC C
    JR NZ, .render_left_tile_cols       ; Repeat for all cols in the tile

    POP BC
    INC HL                              ; Point to next tile in the row
    DJNZ .render_left_tiles             ; Repeat for all tiles in this row

    LD B, FB_WIDTH_TILES / 2
.render_right_tiles:
    PUSH BC
    LD C, PX_PER_TILE
.render_right_tile_cols:
    PUSH HL                             ; Save original pointer
    LD B, PX_PER_TILE
.render_right_tile_rows:
    RLC (HL)                            ; Shift pixel out of row
    RRA                                 ; Shift pixel into new column (LSB=top)
    ADD HL, DE                          ; Point to next row of tile
    DJNZ .render_right_tile_rows        ; Repeat for all rows in the tile

    OUT (LCD_D2), A                     ; Send new column out
    CALL i_lcd_wait

    POP HL                              ; Restore original pointer
    DEC C
    JR NZ, .render_right_tile_cols      ; Repeat for all cols in the tile

    POP BC
    INC HL                              ; Point to next tile in the row
    DJNZ .render_right_tiles            ; Repeat for all tiles in this row

    ; HL is currently at the start of the next row
    LD DE, FB_WIDTH_TILES * 7           ; Skip forward to next tile start
    ADD HL, DE
    DEC C
    JR NZ, .render_rows

    POP HL
    POP DE
    POP BC
    RET

