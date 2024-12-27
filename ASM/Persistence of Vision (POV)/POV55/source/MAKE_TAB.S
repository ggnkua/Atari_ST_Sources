	moveq	#0,d2
	lea	table,a0
	move.w	#16-1,d0
octave	move.w	#255,d1
notes	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	move.b	d2,(a0)+
	sub.w	#1,d1
	bne.s	notes
	dbf	d0,octave
bp
	clr.w	-(sp)
	trap	#1

table	dcb.b	8192,0
