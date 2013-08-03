; set supervisor
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1

	move.w	#70,-(sp)
	bsr	set_rate
	addq	#2,sp
	move.w	#120,-(sp)
	bsr	set_pitch
	addq	#2,sp

; say something..
	pea	txt(pc)
	move.w	#1,-(sp)
	bsr	say	
	addq	#6,sp

; wait till ready..
loop:	move.w	#3,-(sp)
	bsr	say
	addq	#2,sp
	tst.b	d0
	bne.s	loop

	clr.w	-(sp)
	trap	#1

txt:	dc.b	"AY AY AY SAY SAY SAY FAY FAY SHAYT",0
	even

	include sayspl.s

