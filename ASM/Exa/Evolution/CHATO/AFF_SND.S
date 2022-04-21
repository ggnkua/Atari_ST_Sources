larg_Ecran=128000	
	include	MACRO&CO.S

	 	SECTION TEXT
	
	bsr	init_systeme_ecran
	
	lea	raw_img1,a0
	lea	raw_img2,a1
	move.l	#640*28,d0
	move.l	#$60006,d1
loop_cls_img
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	subq.l	#4,d0
	bne.s	loop_cls_img
	
	move.l	$70.w,-(sp)
	move.l	a7,old_pile
	move.l	#VBL,$70.w
	
	move.l	(parametre1,[$40c.w]),aff_ptr

	clr.w	$208.w

BOUCLE1
	tst.w	cpt
	bne.s	boucle1

	vsync
	lea	raw_img1+640*28,a0
	move.l	ECRAN+BASE_ECRAN,a1
	move.l	ECRAN+BASE_ECRAN+4,a2
	move.w	#320*200/2-1,d7
.C	move.l	(a0),(a1)+
	move.l	(a0),(a2)+
	dbra	d7,.C

	clr.w	$208.w
.lop
	vsync
	tst.b	$208.w
	beq.s	.lop

	move.l	#-1,$ffff9800.w
	vsync	
	move.l	#$33333333,$ffff9800.w
AAA
	move.l	#VBL_NF,$70.w
	vsync
	aset_video	#4
	clr.l	$fffff9800.w
	lea	base_ecran,a6
	st	flag(a6)
BOUCLE	
	bsr	search_ecran
	movem.l	d0-a6,-(sp)
	bsr.s	aff
	movem.l	(sp)+,d0-a6
	bsr	next_ecran
	bra	BOUCLE

AFF
	move.l	aff_ptr,a0
	move.w	(a0)+,d7
	cmp.w	#$1234,d7
	beq	FIN
	subq.w	#1,d7
	move.l	trace_ecran+base_ecran,a6
	lea	palette,a1
	moveq	#0,d0
ONE	move.b	(a0)+,d0
	move.w	(a1,d0.w*2),d1
	move	d1,d2
	swap	d1
	move	d2,d1
	moveq	#0,d6
	move.b	(a0)+,d6
	asr	d6
	bcs.s	.A
	move.w	d1,(a6)+
	subq	#1,d6
.A
	bmi.s	.G
.C	move.l	d1,(a6)+
	dbra	d6,.C
.G	dbra	d7,ONE
	move.l	a0,aff_ptr
	rts



VBL
	movem.l	d0-a6,-(sp)
	trap	#3
	addq.l	#1,$466.w	
	addq.l	#1,$200.w
	;subq.w	#1,CPT0
	;bne.s	SUITE
	tst.b	$208.w
	beq.s	suite
	move.w	#1,CPT0
	tst.w	CPT
	beq.s	SUITE
	subq.w	#1,CPT
	bsr.s	DISPLAY                   
SUITE	
	;cmp.b	#$39,$fffffc02.w
	;beq	FIN
	trap	#4
	movem.l	(sp)+,d0-a6
	rte

VBL_NF
	addq.l	#1,$200.w
	addq.l	#1,$466.w
	trap	#3
	bsr	ecran_vbl
	trap	#4
	rte



DISPLAY
	move.l	TABLE_PTR,a6
	move.w	#128-1,d5
PTS	
	move.l	$42e.w,a1
	sub.l	#320*256*2,a1
	move.l	#raw_img1,a0
	moveq	#0,d0
	move.w	(a6)+,d0
	move.l	d0,d1
	lsr.w	#6,d0
	mulu	#320*2,d0
	and.l	#63,d1
	add.l	d1,d0
	add.l	d1,d0
	add.l	d0,a0
	add.l	d0,a1
	
	move.w	#4-1,d7
.Y	move.w	#5-1,d6
	move.l	a0,a2
	move.l	a1,a3
	add.l	#320*64*2,a0
	add.l	#320*64*2,a1
.X	move.w	(a2),(a3)
	add.w	#128,a2
	add.w	#128,a3
	dbra	d6,.X
	dbra	d7,.Y
	dbra	d5,PTS
	move.l	a6,TABLE_PTR
	rts

	
	

;-------------------------------
search_ecran
	lea	base_ecran,a6
.loop_attente
	move	ptr_log(a6),d0
	cmp	ptr_phys(a6),d0	;la routine va trop vite
	beq.s	.loop_attente
	lea	ecran(a6),a0	;si il ya d'autre ecran ben va s'y
	move.l	(a0,d0*4),trace_ecran(a6)
	rts
	
;-----------------------------
next_ecran
	move	ptr_log(a6),d0
	addq	#1,d0
	cmp	nbr_ecran(a6),d0
	bne.s	.no_end_circular_ecran
	moveq	#0,d0
.no_end_circular_ecran	
	move	d0,ptr_log(a6)
	rts
;-----------------------------

;-------------------------------------
init_systeme_ecran
	lea	base_ecran,a6	
	lea	log_buf,a0
	move.l	a0,d0
	and.b	#$fc,d0
	move.l	d0,a0
	lea	ecran(a6),a1
	moveq	#2,d7	
	move	d7,nbr_ecran(a6)
	subq	#1,d7
	move.L	#$60006,d1
.install_ecran
	move.l	a0,(a1)+
	add.l	#larg_ecran,a0
	dbf	d7,.install_ecran
	move.l	#img+18,d0
	and.b	#$fc,d0
	move.L	d0,(a1)+
	move.l	$42e.w,a0
	sub.l	#128000,a0
	move.l	a0,(a1)+
	move	#0,ptr_phys(a6)
	move	#0,ptr_log(a6)
	move	#1,speed_relatif_anim(a6)
	sf	flag(a6)
	rts

;----------------------------------
;	mettre en vbl
;----routine a copier--------------
ecran_vbl
	movem.l	d0-a6,-(sp)
	lea	base_ecran,a6
	tst.b	flag(a6)
	beq.s	.no_systeme_flash_ecran
	move	ptr_log(a6),d0
	sub	ptr_phys(a6),d0
	bgt.s	.no_neg_circular_buffer
	add	nbr_ecran(a6),d0	
.no_neg_circular_buffer
;	d0	=nbr_ecran d'avance
	addq	#1,speed_relatif_next_ecran(a6)
	move	speed_relatif_next_ecran(a6),speed_relatif_anim(a6)
	cmp	#1,d0
	beq.s	.affiche_same_ecran
	clr	speed_relatif_next_ecran(a6)
	move	ptr_phys(a6),d0
	addq	#1,d0
	cmp	nbr_ecran(a6),d0
	bne.s	.no_end_circular_ecran
	moveq	#0,d0
.no_end_circular_ecran
	move	d0,ptr_phys(a6)
;------------------------------
.affiche_same_ecran
	move	ptr_phys(a6),d0
	lea	ecran(a6,d0*4),a0
;	affiche_ecran ici
	lea $fffff8200.W,a1
	move.b 1(a0),1(a1)
	move.b 2(a0),3(a1)
	move.b 3(a0),$d(a1)
.no_systeme_flash_ecran
	movem.l	(sp)+,d0-a6
	rts

	
	incdir d:\sources\
	
	
FIN
	move.l	old_pile,a7
	move.l	(sp)+,$70.w
	move.w	#$2300,sr

	lea	base_ecran,a6
	move	ptr_phys(a6),d0
	move.l	ecran(a6,d0*4),a0
	
	move.l	$42e,a1
	move.l	#128000,d0
	sub.l	d0,a1
	move.l	a1,a2
.loop_copy
	move.l	(a0)+,(a1)+
	subq.l	#4,d0
	bne.s	.loop_copy
	aset_screen	a2
	rts



	SECTION DATA
CPT		dc.w	64*64/128
CPT0		dc.w	50*5
raw_img1
		ds.b	(640*28)-18
IMG		incbin	debut2.tg1
raw_img2
		ds.b	(640*28)
TABLE_PTR	dc.l	TABLE1
TABLE1		incbin	alea6464.dat
aff_ptr		dc.l		0
;A		incbin		d:\A.dat
		dc.w		$1234
PALETTE		incbin	PAL.PAL
	even
	SECTION	BSS
old_pile	ds.l	1
base_ecran			rsreset
vbl_ecran			rs.l	1
trace_ecran			rs.l	1
flag				rs	1
ptr_log				rs	1
ptr_phys			rs	1
speed_relatif_next_ecran	rs	1
speed_relatif_anim		rs	1
nbr_ecran			rs	1
ecran				rs.l	10
				ds.l	20
				ds.l	1
LOG_BUF				ds.w	256+320*200*2
END_T		



