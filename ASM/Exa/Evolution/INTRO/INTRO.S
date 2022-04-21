vsync	macro
	move.l	$466.w,d0
	cmp.l	$466.w,d0
	beq.s	*-4
	endm
	 	SECTION TEXT

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	lea	6(sp),sp

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp
	move.w	d0,SAVE_MODE

	jsr	RESERVE_ECRANS

	move.w	#3+32,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp

	jsr	SAVE_INTERRUPTS
	jsr	DETOURNE
	move.w	#$2700,sr

	stop	#$2300
	stop	#$2300
	move.l	#VBL,$70.w
	move.l	#0,$ffff9800.w
	move.l	#-1,$ffff9804.w
	jmp	BOUCLE0
BURO
	vsync
	move.l	LOG,d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	clr.l	$ffff9800.w

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
	
	move.w	#256,-(sp)	

	vsync
	move.l	PHYS,d0
	add.l	#320*50,d0
	move.b	d0,d1
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	move.b	d1,$c(a0)

FADE_UP
	vsync

	lea	REAL_PAL,a0
	lea	$ffff9800.w,a1
	move.w	#255,d7
.inst	
	move.l	(a0)+,(a1)+
	dbra	d7,.inst

	
	lea	REAL_PAL,a0
	lea	PAL2,a1
	bsr	CALCPAL

 	subq.w	#1,(sp)
	bne	FADE_UP
	tst.w	(sp)+

	move.w	#256,-(sp)	
FADE_UP2
	vsync
	lea	REAL_PAL,a0
	lea	$ffff9800.w,a1
	move.w	#255,d7
.inst	
	move.l	(a0)+,(a1)+
	dbra	d7,.inst

	
	lea	REAL_PAL,a0
	lea	PAL1,a1
	bsr	CALCPAL

 	subq.w	#1,(sp)
	bne	FADE_UP2
	tst.w	(sp)+


	bra.s	*
CALCPAL	
	move.w	#1,d2
	move.w	#255,d7
CALC
	move.w	#4-1,d6

COMP	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0),d0
	move.b	(a1)+,d1
	cmp.w	d0,d1
	beq.s   .FIN
	bgt	.UP
.DOWN
	sub	d2,d0
	bgt.s	.FIN
	move	d1,d0
	bra.s	.FIN
.UP
	add	d2,d0
	cmp.w	d0,d1
	bgt	.FIN
	move	d1,d0
.FIN
	move.b	d0,(a0)+
	dbra	d6,COMP
	dbra	d7,CALC
	rts
	
VBL
	addq.l	#1,$466.w
	cmp.b	#$39,$fffffc02.w
	bne	P_FIN
	jmp	FIN
P_FIN
	rte
	
	
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
	move.l	3*4(a0),d0
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
	
DETOURNE
	move.l	8.w,SAVE_BUS
	move.l	$0c.w,SAVE_ADR
	move.l	$10.w,SAVE_ILL
	
	move.l	#BUS,$8.w
	move.l	#BUS,$c.w
	move.l	#ILLEGAL,$10.w
	
	rts

BUS	add.l	#14,sp
	bra	FIN

ILLEGAL	addq.l	#6,sp
	bra	FIN
	

AFF_COUL
	rts
	
	
FIN

	move.l	SAVE_BUS,$8.w
	move.l	SAVE_ADR,$0c.w
	move.l	SAVE_ILL,$10.w


	jsr	RESTORE_INTERRUPTS
	
QUIT	move.l	SAVE_SSP,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp

	move.w	SAVE_MODE,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp

	clr.w	-(sp)
	trap	#1

	SECTION DATA
POSX	dc.w	384-2
IMG	incbin	intro.256
PAL1	incbin	intro.pal
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



