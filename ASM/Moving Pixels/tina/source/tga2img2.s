sh:	equ	240
sw:	equ	320
*********************************************************
*	Some code to write a really big file out	*
*	to the 1 gig HD.				*
*********************************************************
start:
	move.w	#0,-(sp)
	move.l	#fname,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

	bsr	converttarga
	bsr	write1meg

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	clr.w	-(sp)
	trap	#1


write1meg:
	move.l	#screen1,-(sp)
	move.l	#153600,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts


converttarga:
	lea	screen1,a1
	add.l	#153600,a1
	lea	targadata,a0
	lea	18(a0),a0
	move	#sh,d0
	subq.w	#1,d0
	sub.l	#sw*2,a1
.dsloop:
	rept	sw
	move.b	1(a0),d1
	lsl.w	#8,d1
	lsl.w	#1,d1
	moveq	#0,d2
	move.b	(a0),d2
	move.l	d2,d3
	and.b	#%11100000,d2
	lsl.w	#1,d2
	and.b	#%00011111,d3
	or.b	d3,d2
	or.w	d2,d1

	addq.l	#2,a0
	move.w	d1,(a1)+
	endr
	sub.l	#(sw*2)*2,a1
	dbf	d0,.dsloop
	rts




handle:		dc.w	0
fname:		dc.b	'G:\help.img',0
	even
targadata:
	incbin	'help.tga'
	section bss
screen1:
	ds.b	153600


