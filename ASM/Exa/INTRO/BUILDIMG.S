rp=20
vp=20
bp=40


PAL1
	lea	PAL+128*4,a0
	lea	64*4(a0),a2
	move.w	#63,d7
.C	
	addq.w	#1,a0
	addq.w	#1,a2
	moveq	#0,d0
	move.b	(a0)+,d0
	mulu	#rp,d0
	divu	#100,d0
	and.b	#$f8,d0
	move.b	d0,(a2)+
	moveq	#0,d0
	move.b	(a0)+,d0
	mulu	#vp,d0
	divu	#100,d0
	and.b	#$fc,d0
	move.b	d0,(a2)+
	moveq	#0,d0
	move.b	(a0)+,d0
	mulu	#bp,d0
	divu	#100,d0
	and.b	#$f8,d0
	move.b	d0,(a2)+
	dbra	d7,.C
PALCONV
	lea	PAL,a0
	lea	PALTC,a1
	move.w	#255,d7
.C	addq.w	#1,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d1
	lsr.w	#3,d1
	lsl.w	#8,d1	
	lsl.w	#3,d1
	moveq	#0,d2
	move.b	(a0)+,d2
	lsr.b	#2,d2
	lsl.w	#5,d2	
	or.w	d2,d1
	moveq	#0,d2
	move.b	(a0)+,d2
	lsr.b	#3,d2
	or.w	d2,d1
	move.w	d1,(a1)+
	dbra	d7,.C


	;illegal
	lea	PALTC,a5
	lea	A+18,a0
	lea	ATC,a6
	bsr	CONV256
	lea	PALTC+128*2,a5
	lea	B+18,a0
	lea	BTC,a6
	bsr	CONV256
	;illegal
	lea	ATC,a0
	lea	BTC,a1
	lea	WORKED,a6
	move.l	#320*256,d7
LOOP
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	add.b	#128,d1
	tst.b	d0
	bne.s	.PLEIN	;;
	move.b	d1,d0
	bra.s	.SUITE
.PLEIN	cmp.b	#3,d0
	bne.s	.SUITE
	move.b	d1,d0
	add.b	#64,d0			
.SUITE	move.b	d0,(a6)+
	subq.l	#1,d7
	bne.s	LOOP
	
BUILDTG2
	lea	WORKED,a0
	lea	FINAL,a6
	lea	PALTC,a1
	moveq	#0,d0
	move.w	#(320*256/2)-1,d7
.C	
	rept	2
	move.b	(a0)+,d0
	move.w	(a1,d0.w*2),(a6)+
	endr
	dbra	d7,.C
	



	move.w	#0,-(sp)
	pea	fname3
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle	

	move.l	#FINAL,-(sp)
	move.l	#320*256*2,-(sp)
	move.w	fhandle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp


	lea	WORKED,a0
	lea	FINAL,a6
	move.l	#20*256,-(sp)
LOOP2
	move.w	#7,d7
PL16
	move.l	a0,a1
	moveq	#0,d1
	move.w	#15,d6
.C	moveq	#0,d0
	move.b	(a1),d0
	asr	d0
	addx	d1,d1		
	move.b	d0,(a1)+	
	dbra	d6,.C
	move.w	d1,(a6)+
	dbra	d7,PL16
	add.W	#16,a0
	subq.l	#1,(sp)
	bne	LOOP2
	tst.l	(sp)+

	move.w	#0,-(sp)
	pea	fname1
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle	

	move.l	#FINAL,-(sp)
	move.l	#320*256,-(sp)
	move.w	fhandle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	#0,-(sp)
	pea	fname2
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle	

	move.l	#PAL,-(sp)
	move.l	#1024,-(sp)
	move.w	fhandle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	
	illegal
fhandle	ds.w	1
fname1	dc.b	"d:\intro.256",0
	even
fname2	dc.b	"d:\intro.pal",0
	even
fname3	dc.b	"d:\intro.tg2",0
	even

CONV256
	move.l	#320*256,-(sp)
ALLPIC	move.w	(a0)+,d0
	move.l	a5,a1
	moveq	#0,d7
.SUITE	cmp.w	(a1)+,d0
	beq.s	.FOUND
	addq.b	#1,d7
	bra.s	.SUITE
.FOUND
	move.b	d7,(a6)+
	subq.l	#1,(sp)
	bne	ALLPIC
	tst.l	(sp)+
	rts
	

	

	
	DATA
PAL	incbin	intro.dac
A	incbin	fille.tg1
B	incbin	monstre.TG1

	BSS
PALTC	ds.w	256
ATC	ds.b	320*256
BTC	ds.b	320*256
WORKED	ds.b	320*256
FINAL	ds.w	320*256
