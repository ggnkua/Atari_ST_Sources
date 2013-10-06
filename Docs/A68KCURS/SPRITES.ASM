; A68KCURS.TXT	example files
; SPRITES.ASM	Showing of a sprite

	include "flib.h"
	include "tios.h"
	include "macros.h"
	xdef _main
	xdef _comment

put8x8sprite:
; In	D0	X coordinate [ 0..28 ]
;	D1	Y coordinate [ 0..119 ]
;	A0	Pointer to the sprite
; Out	Nothing

; Building of the screenaddress
; ADDRESS = Y * 30 + X
; 30 bytes per line!
	mulu.w #30,d1
; + X
	add.w d0,d1
	move.l #LCD_MEM,a1
	lea 0(a1,d1.w),a1
	move.w #7,d0
; Looping to show every line
showsprite:
; Line x
	move.b (a0)+,(a1)
	lea 30(a1),a1
	dbra.w d0,showsprite
	rts

_main:
	jsr flib::zap_screen
	lea sprite1(PC),a0
	move.w #10,d0
	move.w #50,d1
	bsr put8x8sprite
	jsr flib::idle_loop
	rts

sprite1		dc.b %00011000,
		dc.b %00011000,
		dc.b %00011000,
		dc.b %11111111,
		dc.b %11111111,
		dc.b %00011000,
		dc.b %00011000,
		dc.b %00011000
_comment	dc.b "PRGM: Subroutines",0
	END