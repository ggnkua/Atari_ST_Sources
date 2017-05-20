* Font to Binary Converter By TERMINATOR of NOW 5 *

nochars		equ	95	number of chars in font

init		move.l	#start,-(sp)
		move	#38,-(sp)
		trap	#14		
		addq.l	#6,sp

start		lea	text,a0
		lea	workspace,a1
		rept	nochars
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		endr
		suba.l	#workspace,a1
		move.l	a1,a2
		move.l	#workspace,a1
		move.l	#filename,a0
		bsr	save

		clr.l	-(sp)
		trap	#1

save		move.w	#0,-(sp)
		move.l	a0,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.l	#8,sp

		move.l	a1,-(sp)
		move.l	a2,-(sp)
		move.w	d0,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		add.l	#12,sp
	
		move.w	d0,-(sp)
 		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		rts

*****************************
filename	dc.b	"88font.fn1",0	*output filename
		even
text		include	"font.s"	*font for conversion
		even
workspace	equ	*