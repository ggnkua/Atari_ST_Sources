; this one draws out a text message

	opt	o+,x-,s-,w-
	bra.s	prog
	ds.l	14
prog
	lea	text(pc),a0
loop
	move.l	a0,-(sp)
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	(sp)+,a0
	tst.b	(a0)+		; get past letter just printed
	tst.b	(a0)		; test for 0 - end of text
	bne.s	loop
	rts
text	dc.b	"This is a test of",10,13
	dc.b	"my text printing boot",10,13
	dc.b	"sector....  I guess it works!!",0