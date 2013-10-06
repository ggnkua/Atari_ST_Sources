; A68KCURS.TXT	example files
; HELLO.ASM	shows "Hello world!" on the screen

	include "flib.h"
	include "tios.h"
	xdef _main
	xdef _comment

_main:
	jsr flib::zap_screen
	move.w #4,-(a7)
	pea helloworld(PC)
	move.w #50,-(a7)
	move.w #50,-(a7)
	jsr tios::DrawStrXY
	lea 10(a7),a7
	jsr flib::idle_loop
	rts

helloworld	dc.b "Hello world!",0
_comment	dc.b "PRGM: Hello world!",0
	END