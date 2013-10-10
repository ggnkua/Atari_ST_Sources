	include	MACRO&CO.S
	 	SECTION TEXT
	jsr	RESERVE_ECRANS
	aset_video	#6
	aset_screen	LOG
	vsync
	move.l	#0,$ffff9800.w
	move.l	#-1,$ffff9804.w
BURO
	aset_screen	LOG
	vsync

	move.l	LOG,a0
	move.w	POSX,d0
	lea	(a0,d0.w*2),a0
	move.w	#255,d7
.C	clr.l	(a0)
	add.w	#384*2,a0
	dbra	d7,.C
	subq.w	#2,POSX
	tst.w	POSX
	bpl	BURO
	vsync
	aset_video	#7
	aset_screen	LOG
BOUCLE0
	vsync
	move.l	LOG,d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	
	move.l	LOG,a0
	add.w	#6*16,a0
	move.w	#16,-(sp)
BOUCLE
	vsync	
	move.w	#15,d6
LIGNE
	move.w	#$3ff,(a0)
A	set	1
	rept	7
	move.w	#-1,A*16(a0)
A	set	A+1
	endr
	add.w	#320,a0
	dbra	d6,LIGNE
	subq.w	#1,(sp)
	bne.s	BOUCLE
	tst.w	(sp)+

FORE_GROUND
	move.l	PHYS,a1
	lea	IMG,a0
	move.w	#320*256/4-1,d7
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C
	
	lea	REAL_PAL,a0
	move.w	#255,d7
.D	move.l	#$ffffffff,(a0)+
	dbra	d7,.D
	
	move.w	#155,-(sp)	
FADE_UP
	aset_screen	PHYS
	aset_palette	#REAL_PAL
	vsync
	lea	REAL_PAL,a0
	lea	PAL2,a1
	move.w	#7,d2
	bsr	CALCPAL

 	subq.w	#1,(sp)
	bne	FADE_UP
	tst.w	(sp)+

	move.w	#100,-(sp)	
FADE_UP2
	aset_screen	PHYS
	aset_palette	#REAL_PAL
	vsync
	lea	REAL_PAL,a0
	lea	REAL_PAL,a0
	lea	PAL1,a1
	move.w	#5,d2
	bsr	CALCPAL

 	subq.w	#1,(sp)
	bne	FADE_UP2
	tst.w	(sp)+

	move.w	#75,d7
.KK	vsync
	dbra	d7,.KK

	lea	TGA,a0
	move.l	LOG,a1
	move.w	#320*256/2-1,d7
.copy_log	move.l	(a0)+,(a1)+
	dbra	d7,.copy_log

	vsync
	aset_video 	#5
	aset_screen	log
	vsync

	lea	tga,a0
	move.l	phys,a2
	move.w	#320*256/2-1,d7
.copy_phys	move.l	(a0)+,(a2)+
	dbra	d7,.copy_phys
	vsync
	lea	logo,a0
	move	#18-1,d0
.loop	clr.w	(a0)+
	dbf	d0,.loop

CIRCLE_AFF
 	aset_screen	log
	vsync
	move.l	LOG,d0
	move.l	PHYS,d1
	move.l	d1,LOG
	move.l	d0,PHYS

	move.l	TABXPTR,d0
	move.l	TABXPTR+4,d1
	move.l	d1,TABXPTR
	move.l	d0,TABXPTR+4


	move.l	CIRPTR,a6
	move.l	LOG,a1
	add.l	#640*128+320,a1
	move.l	#LOGO+18+640,a0
	add.l	#640*128+320,a0
	move.l	TABXPTR,a5
	moveq	#0,d6
	move.w	(a6)+,d7
	cmp.w	#$1234,d7
	beq	FIN
	moveq	#0,d0	
	move.w	d7,d0
	add.w	d0,d0
	addq.w	#2,d0
	add.l	d0,CIRPTR
	cmp.w	#129,d7
	ble.s	.OK
	move.w	#129,d7
.OK	
	subq.w	#1,d7
LIGNE11
	move.w	(a6)+,d0
	move.w	(a5)+,d1
	cmp.w	#159,d1
	bgt.s	SUITE
	move.w	d0,d2
	sub	d1,d2
	subq.w	#1,d2
	bmi.s	SUITE
	move.w	d0,-2(a5)
	lea	(a0,d1.w*2),a2
	lea	(a1,d1.w*2),a3
	sub.l	d6,a2
	sub.l	d6,a3
	move.w	d2,d3
.X1	move.w	(a2)+,(a3)+
	dbra	d3,.X1			;HD

	lea	(a0,d1.w*2),a2
	lea	(a1,d1.w*2),a3
	add.l	d6,a2
	add.l	d6,a3
	move.w	d2,d3
.X2	move.w	(a2)+,(a3)+
	dbra	d3,.X2
	move.l	a0,a2
	move.l	a1,a3
	add	d1,d1
	sub.w	d1,a2
	sub.w	d1,a3
	sub.l	d6,a2
	sub.l	d6,a3
	move.w	d2,d3
.X3	move.w	-(a2),-(a3)
	dbra	d3,.X3			;HG

	move.l	a0,a2
	move.l	a1,a3
	sub.w	d1,a2
	sub.w	d1,a3
	add.l	d6,a2
	add.l	d6,a3
	move.w	d2,d3
.X4	move.w	-(a2),-(a3)
	dbra	d3,.X4			;BG

SUITE	
	add.l	#640,d6	
	dbra	d7,LIGNE11

	bra	CIRCLE_AFF

CALCPAL	
	move.w	#255,d7
CALC
	move.w	#4-1,d6

COMP	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0),d0
	move.b	(a1)+,d1
	cmp.w	d0,d1
	beq.s   .FIN
	bgt.s	.UP
.DOWN
	sub	d2,d0
	bgt.s	.FIN
	move	d1,d0
	bra.s	.FIN
.UP
	add	d2,d0
	cmp.w	d0,d1
	bgt.s	.FIN
	move	d1,d0
.FIN
	move.b	d0,(a0)+
	dbra	d6,COMP
	dbra	d7,CALC
	rts

	
RESERVE_ECRANS
	move.l	#LOG_BUF+256,d0
	sf	d0
	move.l	d0,LOG

	move.l	#PHYS_BUF+256,d0
	sf	d0
	move.l	d0,PHYS

	move.l	LOG,a0
	move.l	PHYS,a1
	move.l	#-1,d0
	move.w	#384*256/2-1,d7
.CC	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbra	d7,.CC	
	
	lea	PAL1,a0
	lea	PAL2,a1
	move.w	#255,d7
.C	
	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	2(a0),d2
	move.b	3(a0),d3
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	move.b	d0,(a0)+
	move.b	d3,(a0)+
	move.l	-4(a0),(a1)+
	dbra	d7,.C
MODIF
	lea	PAL2,a0
	move.l	3*4(a0),d0			;no couleur*4...
	lea	128*4(a0),a1
	lea	64*4(a1),a2
	move.w	#63,d7
.C	clr.l	(a1)+
	move.l	d0,(a2)+
	dbra	d7,.C

	rts
	
	incdir d:\sources\
	
	SECTION TEXT
	include	'FALC_INT.S'
	SECTION TEXT
	
FIN
	move.l	LOG,a0
	move.l	$42e.w,a1
	sub.l	#768*264,a1
	move.l	a1,d5
	move.w	#15,d7
.X1	clr.l	(a1)+
	dbra	d7,.X1
	move.w	#255,d7
.Y	move.w	#159,d6
.X2	move.l	(a0)+,(a1)+
	dbra	d6,.X2
	move.w	#31,d6
.X3	clr.l	(a1)+	
	dbra	d6,.X3
	dbra	d7,.Y
	vsync
	aset_video	#6
	aset_screen	d5
.lo
	vsync
	tst.b	$208.w
	beq.s	.lo

	lea	kag(pc),a0
	move	#5-1,d7
load_palette
	vsync	
	move.l	(a0)+,$fffff9800.w
	dbf	d7,load_palette
	rts

	SECTION DATA
kag	dc.l	-1,$aaaaaaaa,$55555555,$2a2a2a2a,$0

POSX	dc.w	384-2
IMG	incbin	intro.256
PAL1	incbin	intro.pal
	dcb.w	768,0
TGA	incbin	intro.tg2
	dcb.w	768,0
TABXPTR	dc.l	TABX1,TABX2
TABX1	dcb.w	200,0
TABX2	dcb.w	200,0
CIRPTR	dc.l	TABCIR
TABCIR	incbin	circle.dat
	dc.w	$1234
LOGO	incbin	darwinn5.TG1
	dcb	640*2,2
	SECTION	BSS
CPT		ds.W	1
SAVE_MODE	ds.w	1
SAVE_SSP	ds.l	1
SAVE_BUS	ds.l	1
SAVE_ILL	ds.l	1
SAVE_ADR	ds.l	1
PAL2		ds.l	256
REAL_PAL	ds.l	256
LOG		ds.l	1
PHYS		ds.l	1
LOG_BUF		ds.w	256+320*256
PHYS_BUF	ds.w	256+320*256
END_T		



