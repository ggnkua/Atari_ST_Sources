	include	MACRO&CO.S
	 	SECTION TEXT
env	macro
	btst	#1,$ffffa202.w
	beq.s	*-4-2
	endm
rec	macro
	btst	#0,$ffffa202.w
	beq.s	*-4-2
	endm
	jsr	load_dsp_prog
	jsr	INIT_COUL
	jsr	send_coul
	jsr	RESERVE_ECRANS
	aset_video	#2
	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr
BOUCLE
	aset_screen	LOG
	vsync
	ori	#1,$ffff82c2.w
	move.l	LOG,d0
	move.l	PHYS,LOG
	move.l	d0,PHYS
	bsr.s	DSP
	bsr	send_coul	
	cmp	#128,cpt2
	beq	FIN
	bra	BOUCLE
	
DSP	
	lea	$ffffa206.w,a6
	bsr	display
	move.l	LOG,a0
	move.w	#120-1,d7
Y	rec
	move.w	#(384/(2*16))-1,d6
.C
	rept	16
	move.w	(a6),d0
	move.l	d0,(a0)+
	swap	d0
	endr
	dbra	d6,.C
	swap	d0
	dbra	d7,Y
	rts

display
	move.l	ptr_table_rota(pc),a0
	subq	#1,pt
	bpl.s	.no_pt
	move	#100,pt
	lea	12*2(a0),a0
	cmp.w	#$1234,(a0)
	bne.s	.cont
	move.l	#table_rota2,a0
.cont
	move.l	a0,ptr_table_rota
	lea	inc_sin1(pc),a1
	rept	6
	move.l	(a0)+,(a1)+
	endr
.no_pt
	env
	lea	inc_sin1(pc),a1
	clr.w	-2(a6)
	rept	12
	move.w	(a1)+,(a6)
	endr
	rts
pt		dc.w	0
inc_sin1	ds.w	12
ptr_table_rota	dc.l	table_rota
table_rota
	dc.w	-3,1,-3,5,-1,2,-3,1,2,4,4,-2		
table_rota2
	dc.w	-1,2,-4,3,-1,2,-3,1,2,4,4,-2		
	dc.w	-2,1,-5,4,-1,2,-3,1,2,4,4,-2		
	dc.w	$1234



send_coul
	cmp.w	#128,CPT0
	beq.s	PAL2
	addq.w	#1,CPT0
.X	move.w	CPT0,d7
	lsr	#1,d7
	lea	B+18,a0
	lea	COUL1,a1
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C
	bra.s	SUITE
PAL2	
	cmp.w	#128,CPT1
	beq.s	pal3
	addq.w	#1,CPT1
.V	move.w	CPT1,d7
	lsr	#1,d7
	lea	C,a0
	lea	COUL2,a1
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C
	bra.s	SUITE
pal3
	subq	#1,cpt3
	bpl.s	suite
	cmp.w	#128,CPT2
	beq	PAL2
	addq.w	#1,CPT2
.X	move.w	CPT2,d7
	lsr	#1,d7
	moveq	#-1,d0
	lea	COUL1,a1
	lea	COUL2,a2
.C	
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra	d7,.C
suite
	lea	COUL1,a0
	lea	$ffffa206.w,a6
	move.w	#128-1,d7
.C	env
	move.w	(a0)+,(a6)
	dbra	d7,.C
	lea	COUL2,a0
	move.w	#128-1,d7
.C0	env
	move.w	(a0)+,(a6)
	dbra	d7,.C0
	rts
	


RESERVE_ECRANS
	move.l	#LOG_BUF+256,d0
	sf	d0
	move.l	d0,LOG
	move.l	#PHYS_BUF+256,d0
	sf	d0
	move.l	d0,PHYS
	move.l	log,a0
	lea	gato1,a1
	move.w	#16+16*64+16*32*64,d0
	move	d0,d1
	swap	d0
	move	d1,d0
.eff
	move.l	d0,(a0)+
	cmp.l	a1,a0
	ble.s	.eff
	rts


INIT_COUL	
	lea	COUL1,a0
	lea	COUL2,a1
	move.w	#16+16*64+16*32*64,d0
	move.w	#256-1,d7
.C	
	move.w	d0,(a0)+
	move.w	d0,(a1)+
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
	bra.s	FIN

ILLEGAL	addq.l	#6,sp
	bra.s	FIN
	

AFF_COUL
	rts
	
load_dsp_prog
	lea	dsp_rout,a0		
	move.w	#dsp_size/3,d0	
	jsr	(pload_dsp_prg,[$40c+4+4.w])
	;pea	dsp_size/3.w	
	;pea	dsp_rout(pc)	
	;move.w	#$6d,-(sp)	
	;trap	#14		
	;lea	10(sp),sp		
	rts

	
FIN
	move.l	$42e.w,a1
	sub.l	#384*240*2,a1
	move.l	a1,d0
	move.l	LOG,a0
	move.w	#384*240/2-1,d7
.C	move.l	(a0)+,(a1)+
	dbra	d7,.C
	vsync
	aset_screen	d0	
	vsync

	rts

	SECTION DATA
CPT0		dc.W	-1
CPT1		dc.W	-1
CPT2		dc.W	-1
CPT3		dc.W	250/4
dsp_rout	incbin	"good.P56"
dsp_size	equ	*-dsp_rout
		even
b		incbin	plasma.dat
c		equ	b+18+640*2
;B		incbin	a.tg1
;C		incbin	b.tg1

	SECTION	BSS
SAVE_MODE	ds.w	1
SAVE_SSP	ds.l	1
SAVE_BUS	ds.l	1
SAVE_ILL	ds.l	1
SAVE_ADR	ds.l	1
LOG		ds.l	1
PHYS		ds.l	1
buffer_dsp1	ds.l	5000
COUL1		ds.w	256*4
COUL2		ds.w	256*4
LOG_BUF		ds.w	256+384*240
PHYS_BUF	ds.w	256+384*240
GATO1		ds.w	192*120
END_T		
	end

send_coul
	cmp.w	#255,CPT0
	beq	PAL2
	addq.w	#1,CPT0
.X	move.w	CPT0,d7
	lea	B+18,a0
	lea	COUL1,a1
.C	move.w	(a0)+,(a1)+
	dbra	d7,.C
	bra.s	SUITE
PAL2	
	cmp.w	#255,CPT1
	beq	pal3
	addq.w	#1,CPT1
.V	move.w	CPT1,d7
	lea	C,a0
	lea	COUL2,a1
.C	move.w	(a0)+,(a1)+
	dbra	d7,.C
	bra.s	SUITE
pal3
	subq	#1,cpt3
	bpl.s	suite
	cmp.w	#255,CPT2
	beq	PAL2
	addq.w	#1,CPT2
.X	move.w	CPT2,d7
	moveq	#-1,d0
	lea	COUL1,a1
	lea	COUL2,a2
.C	
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	dbra	d7,.C
suite
	lea	COUL1,a0
	lea	$ffffa206.w,a6
	move.w	#128-1,d7
.C	env
	move.w	(a0)+,d0
	move.w	d0,(a6)
	dbra	d7,.C
	lea	COUL2,a0
	move.w	#128-1,d7
.C0	env
	move.w	(a0)+,d0
	move.w	d0,(a6)
	dbra	d7,.C0
	rts
	


