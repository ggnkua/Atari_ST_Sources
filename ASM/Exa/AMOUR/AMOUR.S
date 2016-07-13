vsync	macro
	move.l	$466.w,d0
	cmp.l	$466.w,d0
	beq.s	*-4
	endm
env	macro
	btst	#1,$ffffa202.w
	beq.s	*-4-2
	endm
rec	macro
	btst	#0,$ffffa202.w
	beq.s	*-4-2
	endm

	 	SECTION TEXT



	
	bsr	startup
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	lea	6(sp),sp
	
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp
	move.w	d0,SAVE_MODE



	jsr	load_dsp_prog
	jsr	RESERVE_ECRANS
	move.w	#4+64,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp
	jsr	SAVE_INTERRUPTS
	jsr	DETOURNE
	
	stop	#$2300
	move.l	#VBL,$70.w
	move.l	#INTER_BOUCLE,-(sp)
	move.l	#BOUCLE2,-(sp)
	
BOUCLE1
	vsync
	rept	4
	bsr	PLAQUE	
	endr

	bra	BOUCLE1
BOUCLE2
	vsync
	rept	4
	bsr	PLAQUE_MAP
	endr
	bra	BOUCLE2
INTER_BOUCLE
	move.l	LOG,a0
	move.l	PHYS,a1
	move.w	#240-1,d7
.Y	move.w	#192-1,d6
.X	move.l	(a0)+,(a1)+
	dbra	d6,.X
	add.w	#768,a0
	add.w	#768,a1
        dbra	d7,.Y
	
BOUCLE
	vsync
	move.l	#0,$ffff9800.w

	move.l	LOG,d0
	move.l	PHYS,LOG
	move.l	d0,PHYS

	movec	cacr,d0
	bset	#9,d0
	movec	d0,cacr
	bsr	GRAF_SCREEN_2
	movec	cacr,d0
	bclr	#9,d0
	movec	d0,cacr
	

	;move.l	ROT_PTR,a0
	;moveq	#0,d0
	;move.w	(a0)+,d0
	;swap	d0
	;add.l	d0,angle_x
	;move.l	a0,ROT_PTR

	add.l	#$20000,angle_X
	add.l	#$8000,zoom_X
	sub.l	#$4000,zoom_y
	
	move.l	#-1,$ffff9800.w
	tst	FLAG_FIN
	beq	BOUCLE
	jmp	FIN

PLAQUE_MAP
	lea	DEZIGN+18,a0
	move.l	a0,a1
	move.l	LOG,a5
	move.l	a5,a6
	move.w	X_PLAQUE,d7
	lea	(a5,d7.w*2),a5
	lea	(a0,d7.w*2),a0
	move.w	Y_PLAQUE,d6
	muls	#768,d6
	add.l	d6,a6
        add.l	d6,a6
	add.l	d6,a1
	move.w	Y_PLAQUE,d7
	subq.w	#1,d7
	bmi.s	.C
.X	move.w	(a0)+,(a5)+
	add.w	#768-2,a0
	add.w	#768*2-2,a5
	dbra	d7,.X
.C	
	move.w	X_PLAQUE,d7
	;subq	#1,d7
	bmi.s	.C2
.Y	
	move.w	(a1)+,(a6)+
	dbra	d7,.Y
.C2
	subq.w	#1,X_PLAQUE
	tst	X_PLAQUE
	bge.s	.OK
	addq.l	#4,sp
	rts
		
.OK	move.l	#240*65536/384,d0
	sub.l	d0,Y_PLAQUE
	rts

	
PLAQUE
	move.l	LOG,a6
	move.w	X_PLAQUE,d7
	lea	(a6,d7.w*2),a6
	move.w	Y_PLAQUE,d6
	muls	#768*2,d6
	add.l	d6,a6
	move.l	a6,a5
	moveq	#-1,d0
	move.w	#384,d7
	sub.w	X_PLAQUE,d7
	subq.w	#1,d7
.X	
	move.w	d0,(a5)+
	dbra	d7,.X
	move.w	#240,d7
	sub.w	Y_PLAQUE,d7
	subq.w	#1,d7
.Y	
	move.w	d0,(a6)+
	add.w	#768*2-2,a6
	dbra	d7,.Y

	subq.w	#1,X_PLAQUE
	tst	X_PLAQUE
	bge.s	.OK
	addq.w	#1,X_PLAQUE
	move.l	#383*65536,X_PLAQUE
	move.l	#239*65536,Y_PLAQUE
	addq.l	#4,sp
	rts
	
	
.OK	move.l	#240*65536/384,d0
	sub.l	d0,Y_PLAQUE
	rts
	

GRAF_SCREEN_2
	lea	$ffffa204.w,a6
	lea cos_table,a4
	lea sin_table,a5
	move.w	ANGLE_X,d2
	and.w	#511,d2
	move.w	(a4,d2.w*2),d0
	move.w	(a5,d2.w*2),d1
	ext.l	d0
	ext.l	d1
	muls.w	zoom_x,d0
	asr.l	#8,d0
	muls.w	zoom_y,d1
	asr.l	#8,d1
	lea	$ffffa204.w,a6
	env	
	move.l	d0,(a6)		;ix
	move.l	d1,(a6)		;iy
	neg.l	d1
	env
	move.l	d1,(a6)		;ix
	move.l	d0,(a6)		;iy
	asr.l	#8,d0
	asr.l	#8,d1
	asr.l	#1,d0
	asr.l	#2,d1
	env
	move.l	d1,(a6)		;ix
	move.l	d0,(a6)		;iy

TOTO
	lea	$ffffa206.w,a6
	move.l	LOG,a0
	add.l	#112*2+768*2*40,a0
	move.w	#160-1,d7

Y_BOU	
	move	#(80)-1,d6
	rec
EN_X
	move.w	(a6),(a0)+
	move.w	(a6),(a0)+
	dbra	d6,EN_X
	add.w	#768*2-160*2,a0
	dbra	d7,Y_BOU
	
	move.l	alea_ptr,a0
	move.w	(a0),d0
	cmp.w	#$9876,d0
	bne.s	OK_ALEAT
	lea	aleat,a0
	move.l	script_ptr,a1
	move.l	(a1)+,d0
	bmi.s	.OK
	move.l	a1,script_ptr
	move.l	d0,ima_ptr
	bra.s	OK_ALEAT
.OK	st	TRANS
		
OK_ALEAT
	;clr.w	-2(a6)
	moveq	#0,d0
	move.l	ima_ptr,a1
	move.w	#512-1,d7
.F	
	env
	move.w	(a0)+,d0
	move.w	d0,(a6)
	env
	move.w	(a1,d0.w*2),(a6)
	dbra	d7,.F
	move.l	a0,alea_ptr
	rts


VBL
	movem.l	d0-a6,-(sp)
	move.l	LOG,d0
	tst	TRANS
	beq.s	NOK
	move.l	amort_ptr,a0
	moveq	#0,d1
	move.w	(a0)+,d1
	bpl.S	.C
	subq.l	#4,a0
	move.w	(a0)+,d1
.C	
	move.l	a0,amort_ptr
	add	d1,d1
	add.l	d1,d0
NOK
	lea	$ffff8200.w,a0
	move.b	d0,d1
	lsr.l	#8,d0
	movep.w	d0,1(a0)
	move.b	d1,$d(a0)
	
	move.w	#384,$ffff820e.w
	addq.l	#1,$466.w
	cmp.b	#$39,$fffffc02.w
	bne	P_FIN
	jmp	FIN
P_FIN
	movem.l	(sp)+,d0-a6
	rte
	


	
RESERVE_ECRANS
	move.l	#LOG_BUF+256,d0
	sf	d0
	move.l	d0,LOG
	move.l	d0,a0

	move.l	#PHYS_BUF+256,d0
	sf	d0
	move.l	d0,PHYS
	move.l	d0,a1

	move.l	#$200000,a2
	lea	IMG+18,a3
	
	move.w	#240-1,d7
.Y	move.w	#192-1,d6
.X1	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbra	d6,.X1
	move.w	#192-1,d6
.X2	move.l	(a3),(a0)+
	move.l	(a3)+,(a1)+
	dbra	d6,.X2
	dbra	d7,.Y

CO
	lea	$ffffa206.w,a6
	env
	clr.w	-2(a6)	
	move.w	#64-1,d7
.Y	move.w	#128-1,d6
.X	
	env
	move.w	#0,(a6)
	dbra	d6,.X
	dbra	d7,.Y
	rts
	
	incdir d:\sources\
	
	SECTION TEXT
	include	'FALC_INT.S'
	SECTION TEXT
COUL_ZERO
	lea	VIDE,a0
	movem.l	(a0),d0-d7
	lea	$ffff8240.w,a0
	movem.l	d0-d7,(a0)
	rts

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
	

load_dsp_prog
	pea	dsp_size/3.w	
	pea	dsp_rout	
	move.w	#$6d,-(sp)	
	trap	#14		
	lea	10(sp),sp		
	rts


	
FIN
	move.l	SAVE_BUS,$8.w
	move.l	SAVE_ADR,$0c.w
	move.l	SAVE_ILL,$10.w
	
	jsr	RESTORE_INTERRUPTS

	move.w	SAVE_MODE,-(sp)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp

QUIT	move.l	SAVE_SSP,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp

	
	clr.w	-(sp)
	trap	#1

	SECTION DATA
TRANS		dc	0
FLAG_FIN	dc	0
IMG		;incbin	juanita.tg1
script_ptr	dc.l	script
script	
		rept	2
		dc.l	ima
		endr
A		set	0
		rept	10
		dc.l	IMA+A*16384
A		set	A+1
		endr
A		set	9
		rept	2
		dc.l	IMA+A*16384
		endr
		rept	10
		dc.l	IMA+A*16384
A		set	A+1
		endr		
A		set	19
		rept	2
		dc.l	IMA+A*16384
		endr
		rept	10
		dc.l	IMA+A*16384
A		set	A+1
		endr		
A		set	29
		rept	6
		dc.l	IMA+A*16384
		endr
		dc.l	-1
ima_ptr		dc.l	ima
ima		
		incbin	roto2.dat
		;incbin	roto0.dat
		;incbin	roto1.dat
fimg

dsp_rout	incbin	"love3.P56"
dsp_size	equ	*-dsp_rout
		even

cos_table
sin_table	equ cos_table+1024
		incbin	cosin.dat

X_PLAQUE	dc	383,0
Y_PLAQUE	dc	239,0

X	dc.w	320
Y	dc.w	200
inc_X	dc.w	10
inc_Y	dc.w	10
VIDE	dcb.w	16,0
ANGLE_X	dc.w	0,0
GAUCHE	
	dc.l	400-200,300-200
	dc.l	400-200,300+200
DROITE
	dc.l	400+200,300-200
	dc.l	400+200,300+200
zoom_X	dc.w	256,0
zoom_Y	dc.w	800,0
IX	dc.l	1
IY	dc.l	-1
LEFT	dc.w	0
RIGHT	dc.w	0
UP	dc.w	0
DOWN	dc.w	0
	
DEZIGN	incbin	celtic3.TG1

alea_ptr	dc.l	aleat
ALEAT		incbin	aleat.dat
		dc.w	$9876
amort_ptr	dc.l	amort
AMORT		incbin	amort.dat
		dc.w	-1

ROT_PTR		dc.l	ROTX
ROTX		
		dc.l	2,2,3,3,-2,-2,-3,-3






	SECTION	BSS
CPT		ds.W	1
SAVE_MODE	ds.w	1
SAVE_SSP	ds.l	1
SAVE_BUS	ds.l	1
SAVE_ILL	ds.l	1
SAVE_ADR	ds.l	1
size_buffer	ds.l 	1
RESULT		ds.l	4*4
LOG		ds.l	1
PHYS		ds.l	1
buffer_dsp1	ds.l 	20000	
TAB_DIAG	ds.w	384
LOG_BUF		ds.w	256+768*240
PHYS_BUF	ds.w	256+768*240
END_T		



