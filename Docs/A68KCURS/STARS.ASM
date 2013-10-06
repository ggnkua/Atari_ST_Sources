; A68KCURS.TXT	example files
; STARS.ASM	Generates a starfield
	include "tios.h"
	include "flib.h"
	xdef _main
	xdef _comment

_main:
	jsr flib::zap_screen
	move.w #199,d3
; Remember 200 - 1 = 199, DBRA!
_createstars:
; First the x coordinate
	move.w #240,d0
	jsr flib::random
; Save the x coordinate
	move.w d0,d1
; The y coordinate
	move.w #128,d0
	jsr flib::random
; Now push the coordinates onto the stack
	move.w d0,-(a7)
	move.w d1,-(a7)
	jsr flib::pixel_on
	lea 4(a7),a7
	dbra.w d3,_createstars
	jsr flib::idle_loop
	rts

_comment	dc.b "PRGM: Starfield",0
	END