;*******************************************************************************
; @file math.c
; @brief Functions and variables relating to the Math set of System Calls
;
; @license GPL-3.0-or-later
;*******************************************************************************

.globl _rng_state_1
.globl _rng_state_2
.globl _random

;**
; Code sourced from https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
;**
_random:
	ld hl, (_rng_state_1)
	ld b, h
	ld c, l
	add hl, hl
	add hl, hl
	inc l
	add hl, bc
	ld (_rng_state_1), hl
	ld hl, (_rng_state_2)
	add hl, hl
	sbc a, a
	and a, #0b00101101
	xor l
	ld l, a
	ld (_rng_state_2),hl
	add hl, bc
	ret
