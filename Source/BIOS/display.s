FB_WIDTH_PX: EQU 128
FB_WIDTH_TILES: EQU 16
FB_HEIGHT_PX: EQU 64
FB_HEIGHT_TILES: EQU 8

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
;**
e_render:
    POP HL
    POP DE
i_render:
    PUSH BC
    PUSH DE
    PUSH HL

    CALL i_lcd_wait
    LD A, %01000000                     ; Set Y=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    CALL i_lcd_wait
    LD A, %11000000                     ; Set Z=0
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    LD HL, framebuffer                  ; Point to the framebuffer

    LD DE, 128
    LD B, 8
.render_screen:
    CALL i_lcd_wait
    LD A, %10111000                     ; Command Set X
    OR C                                ; Mask counter
    INC C                               ; Increment counter
    OUT (LCD_C1), A
    OUT (LCD_C2), A

    PUSH BC
    LD C, LCD_D1                        ; Send left half of row to left LCD
    LD B, 8
.render_row_left:
    CALL i_rotate_send_tile
    INC HL
    DJNZ .render_row_left

    LD C, LCD_D2                        ; Send right half of row to right LCD
    LD B, 8
.render_row_right:
    CALL i_rotate_send_tile
    INC HL
    DJNZ .render_row_right

    POP BC
    ADD HL, DE
    DJNZ .render_screen

    POP HL
    POP DE
    POP BC
    RET



i_rotate_send_tile:
    PUSH BC
    PUSH DE

    LD DE, FB_WIDTH_TILES               ; Add width to point to next row

    LD B, 8                             ; 8 rows per tile
.render_tile:
    PUSH HL                             ; Save pointer
    PUSH BC                             ; Save outer counter
    CALL i_lcd_wait
    LD B, 8
.render_tile_inner:
    RLC (HL)                            ; Rotate pixel from row
    RRA                                 ; Rotate into new column
    ADD HL, DE                          ; Point to next row
    DJNZ .render_tile_inner             ; Repeat for all rows
    OUT (C), A                          ; Send column

    POP BC                              ; Restore outer counter
    POP HL                              ; Restore original pointer

    DJNZ .render_tile

    POP DE
    POP BC
    RET
