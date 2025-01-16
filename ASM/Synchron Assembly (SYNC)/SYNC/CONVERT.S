	lea.l	sample+12(pc),a0
	move.w	#sampleend-sample-13,d0
loop	sub.b	#128,(a0)+
	dbra.w	d0,loop
	clr.w	-(sp)
	pea	filnamn(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	pea	sample+12(pc)
	move.l	#sampleend-sample-12,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea.l	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	clr.w	-(sp)
	trap	#1
sample	incbin	piano1_m.sam
sampleend	equ	*
filnamn	dc.b	'PIANO1_M.SPL',0
