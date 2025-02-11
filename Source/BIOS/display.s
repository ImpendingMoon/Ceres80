FB_WIDTH_PX: EQU 128
FB_WIDTH_TILES: EQU 16
FB_HEIGHT_PX: EQU 64
FB_HEIGHT_TILES: EQU 8
PX_PER_TILE: EQU 8

;**
; lcd_wait: Wait for LCD
; Waits for the LCD to report that it is ready to process input
; Parameters: None
; Returns: None
;**
i_lcd_wait:
    IN A, (LCD_C1)
    RLCA
    JR C, i_lcd_wait
    IN A, (LCD_C2)
    RLCA
    JR C, i_lcd_wait
    
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



;**
; render: Render Framebuffer
; Blits data in the framebuffer to the LCD
; Parameters: None
; Returns: None
; Notes:
; - Cannot optimize rotation and sending further: Already faster than LCD
;**
e_render:
    POP HL
    POP DE
i_render:
    PUSH BC
    PUSH DE
    PUSH HL
    LD HL, framebuffer                  ; Point to the framebuffer

    DI
    LD B, FB_HEIGHT_TILES
.render_rows:
    CALL i_lcd_wait
    LD A, %10111000                     ; Command Set X
    OR C                                ; Mask counter
    INC C                               ; Increment counter
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    LD DE, FB_WIDTH_TILES               ; Add width to point to next row

    PUSH BC
    LD B, FB_WIDTH_TILES / 2
.render_row:
    CALL i_lcd_wait
    PUSH BC
    LD C, FB_WIDTH_TILES / 2
.render_left_side:
    PUSH HL                             ; Save pointer
    LD B, PX_PER_TILE
.render_left_tile_row:
    ; Rotate leftmost pixel from each row into a new column
    RLC (HL)                            ; Rotate pixel from row
    RRA                                 ; Rotate into new column
    ADD HL, DE                          ; Point to next row
    DJNZ .render_left_tile_row

    OUT (LCD_D1), A                     ; Send column

    POP HL                              ; Restore original pointer
    DEC C
    JR NZ, .render_left_side

    CALL i_lcd_wait
    LD C, FB_WIDTH_TILES / 2
.render_right_side:
    PUSH HL                             ; Save pointer
    LD B, PX_PER_TILE
.render_right_tile_row:
    ; Rotate leftmost pixel from each row into a new column
    RLC (HL)                            ; Rotate pixel from row
    RRA                                 ; Rotate into new column
    ADD HL, DE                          ; Point to next row
    DJNZ .render_right_tile_row

    OUT (LCD_D2), A                     ; Send column

    POP HL                              ; Restore original pointer
    DEC C
    JR NZ, .render_right_side

    POP BC
    INC HL
    DJNZ .render_row

    POP BC
    LD DE, FB_WIDTH_TILES * PX_PER_TILE
    ADD HL, DE
    DJNZ .render_rows

    EI

    POP HL
    POP DE
    POP BC
    RET

