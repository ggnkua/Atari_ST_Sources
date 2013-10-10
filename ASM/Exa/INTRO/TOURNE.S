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


	move.w	#4+32,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp

	move.l	#LOG_BUF,LOG
	move.l	#PHYS_BUF,PHYS
	jsr	SAVE_INTERRUPTS
	jsr	DETOURNE
	move.w	#$2700,sr

	stop	#$2300
	stop	#$2300
	move.l	#VBL,$70.w
BOUCLE
	vsync
	move.l	LOG,d0	
	move.b	d0,d1
	lsr.l	#8,d0
	lea	$ffff8200.w,a0
	movep.w	d0,1(a0)
	move.b	d1,$d(a0)

	move.l	LOG,d0
	move.l	PHYS,d1
	move.l	d1,LOG
	move.l	d0,PHYS

	move.l	TABXPTR,d0
	move.l	TABXPTR+4,d1
	move.l	d1,TABXPTR
	move.l	d0,TABXPTR+4

	
	clr.l	$ffff9800.w
	move.l	CIRPTR,a6
	move.l	LOG,a1
	add.l	#640*128+320,a1
	move.l	#IMG+18,a0
	add.l	#640*128+320,a0
	move.l	TABXPTR,a5
	moveq	#0,d6
	move.w	(a6)+,d7
	cmp.w	#$1234,d7
	beq	BOUCLE
	moveq	#0,d0	
	move.w	d7,d0
	add.w	d0,d0
	addq.w	#2,d0
	add.l	d0,CIRPTR
	cmp.w	#128,d7
	ble	.OK
	move.w	#128,d7
.OK	
	subq.w	#1,d7
LIGNE
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
	dbra	d7,LIGNE

	move.l	#-1,$ffff9800.w
	bra	BOUCLE
	
VBL
	addq.l	#1,$466.w
	cmp.b	#$39,$fffffc02.w
	bne	P_FIN
	jmp	FIN
P_FIN
	rte
	
	
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
TABXPTR	dc.l	TABX1,TABX2
TABX1	dcb.w	200,0
TABX2	dcb.w	200,0
CIRPTR	dc.l	TABCIR
TABCIR	incbin	circle.dat
	dc.w	$1234
IMG	incbin	devant.tg1
	SECTION	BSS
CPT		ds.W	1
SAVE_MODE	ds.w	1
SAVE_SSP	ds.l	1
SAVE_BUS	ds.l	1
SAVE_ILL	ds.l	1
SAVE_ADR	ds.l	1
LOG		ds.l	1
PHYS		ds.l	1
LOG_BUF		ds.w	256+320*256
PHYS_BUF	ds.w	256+320*256



