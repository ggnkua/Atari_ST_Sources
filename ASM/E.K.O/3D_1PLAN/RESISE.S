	lea	stars,a0
	move.w	(a0)+,d0
	subq	#1,d0
poil
	movem.w	(a0),d1-d3
	muls	#128,d1
	muls	#128,d2
	muls	#128,d3
	divs.l	#70,d1
	divs.l	#70,d2
	divs.l	#70,d3


;	asr.l	#1,d1
;	asr.l	#1,d2
;	asr.l	#1,d3
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	dbf	d0,poil


	move.w	#0,-(sp)
	pea	fname
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,-(sp)


	pea	stars
	move.l	#count,-(sp)
	move.w	d0,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	(sp)+,d0
	move.w	d0,-(sp)	
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#4,sp

	move.w	#0,-(sp)
	trap	#1
		



fname		dc.b	'd:\treck1.dat',0
	even


stars	incbin	d:\3d_16col\concave\star.dat
srat
count	equ	srat-stars
