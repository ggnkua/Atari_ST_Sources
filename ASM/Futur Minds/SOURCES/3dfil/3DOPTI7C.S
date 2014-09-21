;---------------------------------------------------------------------;
;	3-DIMENSIONAL DEMO			;
;	(C) Ska from Future Minds			;
;	Algo. faces cachees avec prod. vect. repere DROIT: OK.	;
;---------------------------------------------------------------------;

	opt	d+,o-
	dc.w	$a00a

	pea	0.w
	move.w	#$20,-(a7)
	trap	#1
	lea	6(a7),a7
	move.l	d0,sauve_usp

;---------------------------------------------------------------------;
;	Initialisations			;
;---------------------------------------------------------------------;

	move.l	#pile,a7

	move.l	#scrolltext,scroll_a0

	lea	ecrans,a0
	move.w	#21983,d0
	moveq	#0,d1
vide_ecrans	move.l	d1,(a0)+
	dbf	d0,vide_ecrans

	move.l	#ecrans,d0
	tst.b	d0
	beq.s	multiple_256
	clr.b	d0
	add.w	#$100,d0
multiple_256
	move.l	d0,adr0
	move.l	d0,clr0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,switch
	add.l	#$ac00,d1
	move.l	d1,adr2_0
	move.l	d1,clr2_0
	lsr.l	#8,d1
	move.b	d1,$ffff8203.w
	lsr.l	#8,d1
	move.b	d1,$ffff8201.w

	move.l	adr0,a0
	move.l	adr2_0,a1
	lea	logo,a2
	move.w	#1399,d0
copie_logo	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+
	dbf	d0,copie_logo

	lea	division,a0
	move.w	#199,d3

	moveq	#0,d1
divise0	moveq	#1,d0
	move.w	#319,d4
divise	move.l	d1,d2
	divu	d0,d2
	move.w	d2,(a0)+
 	addq.w	#1,d0
	dbf	d4,divise
	add.l	#$10000,d1
	dbf	d3,divise0

	move.l	#waou,d1
	move.l	#waou2,d2
	move.l	#waou4,d3
	lea	adr_table,a1
	lea	adr_table2,a2
	lea	adr_table3,a3
	move.w	#319,d0
add_address	add.l	d1,(a1)+
	add.l	d2,(a2)+
	add.l	d3,(a3)+
	dbf	d0,add_address

	lea	restau,a0
	move.l	$70.w,(a0)+
	move.l	$68.w,(a0)+
	move.l	$8c.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	move.b	$484.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1f.w,(a0)+

	clr.b	$484.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa1b.w

	move.w	#$2300,sr

	stop	#$2300
	stop	#$2300
	clr.b	$ffff8260.w

	move.w	#$2300,sr

	lea	music+$b7c,a0
	jsr	music

	move.l	#it_trap3,$8c.w
	move.l	#it_vbl,$70.w

	bsr	otranw

;---------------------------------------------------------------------;
;	Fin du prg - r‚initialisations		;
;---------------------------------------------------------------------;

	lea	$ffff8800.w,a0
	move.b	#8,(a0)
	clr.b	2(a0)
	move.b	#9,(a0)
	clr.b	2(a0)
	move.b	#10,(a0)
	clr.b	2(a0)

	clr.w	$ffff8240.w
	move.w	#$777,$ffff825e.w
	move.w	#$777,$ffff8246.w

	lea	restau,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$8c.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820d.w
	move.b	(a0)+,$484.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1f.w

	move.l	sauve_usp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	lea	6(a7),a7

	clr.w	-(a7)
	trap	#1

;---------------------------------------------------------------------;
;		PRECALCULS			;
;---------------------------------------------------------------------;

otranw	;subq.w	#5,zoom

	lea	temoin,a1

	tst.b	(a1)
	bne.s	v_synchron

	not.w	odd_flag

	move.l	switch,d0
	move.l	$ffff8200.w,d1
	move.l	d1,switch
	move.l	d0,$ffff8200.w
	move.l	d0,current_adr

	move.l	clr0,d0
	move.l	clr2_0,d1
	move.l	d1,clr0
	move.l	d0,clr2_0

v_synchron	clr.w	flag_vbl
synchro	tst.w	flag_vbl
	beq.s	synchro

	move.l	#it_hbl,$68.w
	move.w	#$2100,sr

	movem.l	logo_colors,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	$fffffa00.w,a2
	move.b	#38,$21(a2)
	move.b	#8,$1b(a2)
	move.b	#1,$7(a2)
	move.b	#1,$13(a2)
	move.l	#it_timerb_1,$120.w

	lea	colors_3d,a0
	lea	colors_3d_2,a2

	tst.b	(a1)
	beq	v1_234
	cmpi.b	#1,(a1)
	beq	v2_134
	cmpi.b	#2,(a1)
	beq	v3_124

v4_123
	movem.l	col_4_3d,d0-d7
	movem.l	d0-d7,colors_3d
	movem.l	col_4_scrol,d0-d7
	movem.l	d0-d7,colors_3d_2
	
	clr.b	(a1)
	clr.b	adr3

	move.b	#1,temoin2

	move.b	adr1,d0
	move.b	adr2_1,d1
	move.b	d1,adr1
	move.b	d0,adr2_1
	move.b	adr2,d0
	move.b	adr2_2,d1
	move.b	d1,adr2
	move.b	d0,adr2_2

	bra	clear_screen

v1_234
	movem.l	col_1_3d,d0-d7
	movem.l	d0-d7,colors_3d
	movem.l	col_1_scrol,d0-d7
	movem.l	d0-d7,colors_3d_2

	addq.b	#1,(a1)
	move.b	#2,adr3

	bra	clear_screen

v2_134
	movem.l	col_2_3d,d0-d7
	movem.l	d0-d7,colors_3d
	movem.l	col_2_scrol,d0-d7
	movem.l	d0-d7,colors_3d_2

	addq.b	#1,(a1)
	move.b	#4,adr3

	bra	clear_screen

v3_124
	movem.l	col_3_3d,d0-d7
	movem.l	d0-d7,colors_3d
	movem.l	col_3_scrol,d0-d7
	movem.l	d0-d7,colors_3d_2

	addq.b	#1,(a1)
	move.b	#6,adr3

;---------------------------------------------------------------------;
;---------------------------------------------------------------------;

clear_screen

	movem.l	d0-d7/a0-a6,sauve_reg
	bsr	calculs_3d
	bsr	scroller_rout
	movem.l	sauve_reg,d0-d7/a0-a6

	cmp.b	#1,temoin
	bne	cont_cleaning

	movem.w	resetcolors,d0-d5

	move.w	bas3,d0
	bge.s	not_under
	clr.w	d0
not_under	move.w	d0,d5		d5=bas en pix
	add.w	d0,d0
	lea	mul_160,a0
	move.w	0(a0,d0.w),d0		Bas

	move.w	haut3,d1
	cmp.w	#$c7,d1
	bls.s	not_over
	move.w	#$c7,d1
not_over	move.w	d1,d4
	sub.w	d5,d4		haut-bas en pix
	lsr.w	#2,d4		hauteur/4
	addq.w	#1,d4		+++++++++1 !!!
	move.w	d4,clean_height	>0
	add.w	d1,d1
	move.w	0(a0,d1.w),d1		Haut

	move.w	droite3,d2
	cmp.w	#$13f,d2
	bls.s	under_319
	move.w	#$13f,d2
under_319	andi.w	#-16,d2
	lsr.w	#1,d2
	addq.w	#8,d2

	move.w	gauche3,d3
	tst.w	d3
	bge.s	over_0
	clr.w	d3
over_0	andi.w	#-16,d3
	lsr.w	#1,d3

	move.w	#$300,sr

	move.l	a7,sauve_a7

	move.l	clr0,a7
	lea	160*41(a7),a7
	add.w	d1,a7
	add.w	d2,a7	adresse de d‚part
	lea	160(a7),a7	il le faut !
	sub.w	d3,d2	largeur en octets dans d2

	move.l	a7,cleaning_part
	lsr.w	#1,d2	adresse de 4 en 4
	move.w	d2,widthcleaning
	bra.s	cont_cleanin2

cont_cleaning	move.w	#$300,sr
	move.l	a7,sauve_a7

cont_cleanin2	move.l	cleaning_part,a7

	movem.w	resetcolors,d1-d7/a1-a6

	move.w	widthcleaning,d0
	lea	clearoutine,a0
	jmp	0(a0,d0.w)

clearoutine	nop
	nop
	bra	c8
	bra	c16
	bra	c24
	bra	c32
	bra	c40
	bra	c48
	bra	c56
	bra	c64
	bra	c72
	bra	c80
	bra	c88
	bra	c96
	bra	c104
	bra	c112
	bra	c120
	bra	c128
	bra	c136
	bra	c144
	bra	c152
	bra	c160

c8	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c9	movem.l	d1-d2,-(a7)
	lea	-152(a7),a7
	dbf	d0,c9
	bra	qq

c16	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c17	movem.l	d1-d4,-(a7)
	lea	-144(a7),a7
	dbf	d0,c17
	bra	qq

c24	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c25	movem.l	d1-d6,-(a7)
 	lea	-136(a7),a7
	dbf	d0,c25
	bra	qq

c32	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c33	movem.l	d1-d7/a0,-(a7)
	lea	-128(a7),a7
	dbf	d0,c33
	bra	qq

c40	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c41	movem.l	d1-d7/a0-a2,-(a7)
	lea	-120(a7),a7
	dbf	d0,c41
	bra	qq

c48	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c49	movem.l	d1-d7/a0-a4,-(a7)
	lea	-112(a7),a7
	dbf	d0,c49
	bra	qq

c56	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c57	movem.l	d1-d7/a0-a6,-(a7)
	lea	-104(a7),a7
	dbf	d0,c57
	bra	qq

c64	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c65	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d2,-(a7)
	lea	-96(a7),a7
	dbf	d0,c65
	bra	qq

c72	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c73	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	-88(a7),a7
	dbf	d0,c73
	bra	qq

c80	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c81	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	-80(a7),a7
	dbf	d0,c81
	bra	qq

c88	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c89	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0,-(a7)
	lea	-72(a7),a7
	dbf	d0,c89
	bra	qq

c96	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c97	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a2,-(a7)
	lea	-64(a7),a7
	dbf	d0,c97
	bra	qq

c104	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c105	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a4,-(a7)
	lea	-56(a7),a7
	dbf	d0,c105
	bra	qq

c112	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c113	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	lea	-48(a7),a7
	dbf	d0,c113
	bra	qq

c120	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c121	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d2,-(a7)
	lea	-40(a7),a7
	dbf	d0,c121
	bra	qq

c128	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c129	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d4,-(a7)
	lea	-32(a7),a7
	dbf	d0,c129
	bra	qq

c136	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c137	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d6,-(a7)
	lea	-24(a7),a7
	dbf	d0,c137
	bra	qq

c144	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c145	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0,-(a7)
	lea	-16(a7),a7
	dbf	d0,c145
	bra	qq

c152	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c153	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a2,-(a7)
	lea	-8(a7),a7
	dbf	d0,c153
	bra	qq

c160	moveq	#0,d0
	move.l	d0,a0
	move.w	clean_height,d0
c161	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	d1-d7/a0-a4,-(a7)
	dbf	d0,c161

qq	move.l	a7,cleaning_part
	move.l	sauve_a7,a7

	trap	#3

qq2
;	movem.l	d0-d7/a0-a6,-(a7)
;	jsr	music+$86	
;	movem.l	(a7)+,d0-d7/a0-a6

	bra	hiphop

;---------------------------------------------------------------------;
;---------------------------------------------------------------------;

calculs_3d	lea	sintable,a5

	move.w	otheta,d1	;Calcul des sinus

	add.w	d1,d1
	move.w	0(a5,d1.w),stheta
	add.w	#722,d1
	move.w	0(a5,d1.w),ctheta

	move.w	ophi,d1

	add.w	d1,d1
	move.w	0(a5,d1.w),sphi
	add.w	#722,d1
	move.w	0(a5,d1.w),cphi

	move.w	ogamma,d1

	add.w	d1,d1
	move.w	0(a5,d1.w),sgamma
	add.w	#722,d1
	move.w	0(a5,d1.w),cgamma

	lea	stheta,a0	sin theta
	lea	ctheta,a1	cos theta 
	lea	sphi,a2	sin phi
	lea	cphi,a3	cos phi
	lea	sgamma,a4	sin gamma
	lea	cgamma,a5	cos gamma

	lea	precalculs,a6

.x_x0	move.w	(a3),d0
	muls	(a5),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.y_x0	move.w	(a3),d0
	muls	(a4),d0
	neg.l	d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.z_x0	move.w	(a2),(a6)+

.x_y0	move.w	(a1),d0
	muls	(a4),d0
	move.w	(a0),d1
	muls	(a2),d1
	lsl.l	#2,d1
	swap	d1
	muls	(a5),d1
	add.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.y_y0	move.w	(a1),d0
	muls	(a5),d0
	move.w	(a0),d1
	muls	(a2),d1
	lsl.l	#2,d1
	swap	d1
	muls	(a4),d1
	sub.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.z_y0	move.w	(a0),d0
	muls	(a3),d0
	neg.l	d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.x_z0	move.w	(a0),d0
	muls	(a4),d0
	move.w	(a1),d1
	muls	(a2),d1
	lsl.l	#2,d1
	swap	d1
	muls	(a5),d1
	sub.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.y_z0	move.w	(a0),d0
	muls	(a5),d0
	move.w	(a1),d1
	muls	(a2),d1
	lsl.l	#2,d1
	swap	d1
	muls	(a4),d1
	add.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+

.z_z0	move.w	(a1),d0
	muls	(a3),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)

;---------------------------------------------------------------------;
;	ROTATIONS DANS L'ESPACE			;
;---------------------------------------------------------------------;

	lea	coord_hid,a4

	move.l	rebond,a5
	cmp.w	#-999,(a5)
	bne.s	cont_rot

	lea	courbe_y,a5

cont_rot	lea	coord_2d,a3
	move.w	oncoords,d7	the number
	subq.w	#1,d7	or this is the count

	lea	ocoordsx,a0	the
	lea	ocoordsy,a1	source
	lea	ocoordsz,a2	coords.

debut	lea	precalculs,a6	12

	move.w	(a0),d0
	move.w	(a1),d1
	move.w	(a2),d2
	muls	(a6)+,d0
	muls	(a6)+,d1
	muls	(a6)+,d2
	add.l	d1,d0
	add.l	d2,d0
	move.l	d0,d3	; x0
	swap	d3
	move.w	d3,(a4)+
	swap	d3

	move.w	(a0),d0
	move.w	(a1),d1
	move.w	(a2),d2
	muls	(a6)+,d0
	muls	(a6)+,d1
	muls	(a6)+,d2
	add.l	d1,d0
	add.l	d2,d0
	move.l	d0,d4	; y0
	swap	d4
	move.w	d4,(a4)+
	swap	d4

	move.w	(a0)+,d0
	move.w	(a1)+,d1
	move.w	(a2)+,d2
	muls	(a6)+,d0
	muls	(a6)+,d1
	muls	(a6)+,d2
	add.l	d1,d0
	add.l	d2,d0
	lsl.l	#2,d0
	swap	d0
	move.l	d0,d5	; z0   Total=792
	move.w	d5,(a4)+
	clr.w	(a4)+

	swap	d5
	clr.w	d5
	swap	d5
grossi	add.w	#180*2,d5
	asr.l	#6,d3
	asr.l	#6,d4
	divs	d5,d3
	divs	d5,d4
	add.w	#160,d3
	add.w	#100,d4
	add.w	(a5),d4	rebond

	cmp.w	#0001,temoin
	bne.s	test

	move.w	gauche,gauche2	Non!
	move.w	droite,droite2
	move.w	haut,haut2
	move.w	bas,bas2

	move.w	d3,gauche
	move.w	d3,droite
	move.w	d4,haut
	move.w	d4,bas
	move.b	#0,temoin2
	bra.s	limits_end

test	cmp.w	gauche,d3
	bge.s	bof_1
	move.w	d3,gauche
bof_1	cmp.w	droite,d3
	ble.s	limits
	move.w	d3,droite
limits	cmp.w	bas,d4
	bge.s	bof_2
	move.w	d4,bas
bof_2	cmp.w	haut,d4
	ble.s	limits_end
	move.w	d4,haut

limits_end	move.w	d3,(a3)+
	move.w	d4,(a3)+

	dbf	d7,debut

	addq.l	#2,a5
	move.l	a5,rebond

	move.w	gauche2,gauche3
	move.w	droite2,droite3
	move.w	haut2,haut3
	move.w	bas2,bas3

	bsr	test_hidface

	rts

;---------------------------------------------------------------------;
;	          TRACE LES LIGNES			;
;---------------------------------------------------------------------;

hiphop	move.l	visibilite,$ffe00
	move.l	visibilite+4,$ffe04

	move.l	adr0,a0
	lea	160*41(a0),a0
	move.l	a0,adr_3d

	move.w	basevectors,d7
	subq.w	#1,d7
	lea	visibilite,a2

see_if_vis	move.l	(a2)+,a1
	cmpa.l	#-1,a1
	bne.s	affich_face
	dbf	d7,see_if_vis
	bra	fin_affichage

affich_face	lea	coord_2d,a0

debut_lignes	move.w	(a1)+,d4		No point source
	bmi.s	fin_trace

	move.w	(a1)+,d5		No point dest.
	add.w	d4,d4
	add.w	d4,d4
	add.w	d5,d5
	add.w	d5,d5

	move.w	0(a0,d4.w),d0		Coord. xp1
	move.w	2(a0,d4.w),d1		Coord. yp1
	move.w	0(a0,d5.w),d2		Coord. yp2
	move.w	2(a0,d5.w),d3		Coord. yp2

	movem.l	a0-a2/d7,-(a7)
	move.l	adr_3d,a6
	bsr	line_rout
	movem.l	(a7)+,a0-a2/d7

	bra.s	debut_lignes
 
fin_trace	dbf	d7,see_if_vis


fin_affichage	lea	otheta,a0

	addq.w	#3,(a0)	Rotation d'axe x
	cmp.w	#360,(a0)
	bls.s	dac0
	sub.w	#360,(a0)

dac0	addq.w	#2,2(a0)	Rotation d'axe y
	cmp.w	#360,2(a0)
	bls.s	dac2
	sub.w	#360,2(a0)

dac2	addq.w	#2,4(a0)	Rotation d'axe z
	cmp.w	#360,4(a0)
	bls	dac1
	sub.w	#360,4(a0)

	bra	dac1


;---------------------------------------------------------------------;
;	Faces cachees				;
;---------------------------------------------------------------------;

test_hidface

	lea	basevectors,a6
	lea	visibilite,a5

	move.w	(a6)+,d7
	subq.w	#1,d7

exam_face	lea	coord_hid,a0

	movem.w	(a6)+,d0-d2
	rept	3
	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2
	endr	
	lea	0(a0,d0.w),a1		adresses
	lea	0(a0,d1.w),a2		coord
	lea	0(a0,d2.w),a3		points ds espace.

	bsr	prod_vect		resultat ds d0/d2.l

	bsr	prod_scal

	dbf	d7,exam_face

	rts

;---------------------------------------------------------------------;
;	Routine de produit vectoriel		;
;---------------------------------------------------------------------;

prod_vect	movem.w	(a1)+,d0-d2	x1,y1,z1	1er point (0) OK!
	movem.w	d0-d2,important

	movem.w	(a2)+,d3-d5	x2,y2,z2	2e point (1)

	sub.w	d0,d3	xa	1er vecteur
	move.w	d3,-(a7)
	sub.w	d1,d4	ya	0
	move.w	d4,-(a7)		I
	sub.w	d2,d5	za	I
	move.w	d5,-(a7)		1

				;1er point (0)
	movem.w	(a3)+,d3-d5	x1	2e point (3)

	sub.w	d0,d3	xb=x1	2eme vecteur
	sub.w	d1,d4	yb=y1	
	sub.w	d2,d5	zb=z1  (0-3)	0--3

	move.w	(a7)+,d2	za=z2  (1	maintenant on a
	move.w	(a7)+,d1	ya=y2   I	nos 2 vecteurs
	move.w	(a7)+,d0	xa=x2   0)	calcul. le x vect.

	moveq	#0,d6	;on calcule   V1^V2
	move.w	d4,d6
	muls	d2,d6	y1*z2
	move.l	d6,x3_1
	moveq	#0,d6
	move.w	d5,d6
	muls	d1,d6	z1*y2
	sub.l	d6,x3_1

	moveq	#0,d6
	move.w	d5,d6
	muls	d0,d6	z1*x2 ;x1*z2   Repere DROIT,ici.
	move.l	d6,y3_1

	moveq	#0,d6
	move.w	d3,d6
	muls	d2,d6	x1*z2 ;z1*x2
	sub.l	d6,y3_1

	moveq	#0,d6
	move.w	d3,d6
	muls	d1,d6	x1*y2
	move.l	d6,z3_1

	moveq	#0,d6
	move.w	d4,d6
	muls	d0,d6	y1*x2
	sub.l	d6,z3_1	

	rts

;---------------------------------------------------------------------;
;	Routine de produit scalaire			;
;---------------------------------------------------------------------;

prod_scal	move.l	x3_1,d0	x1  coordonnees
	move.l	y3_1,d1	y1  du vecteur normal
	move.l	z3_1,d2	z1 

	;move.l	d0,$ffe00
	;move.l	d1,$ffe04
	;move.l	d2,$ffe08

point_vue	moveq	#0,d3	coordonnees
	moveq	#0,d4	arbitraires
	moveq	#0,d5	du point de vue
	move.w	#-370,d5	+ visible -256<val<-128 - visible

	lea	important,a0
	sub.w	(a0)+,d3	x2 coordonees
	sub.w	(a0)+,d4	y2 du vecteur
	sub.w	(a0)+,d5	z2 dirige vers l'obervateur

	moveq	#0,d6
	move.w	d0,d6
	muls	d3,d6	x1*x2
	move.l	d6,scal1
	moveq	#0,d6
	move.w	d1,d6
	muls	d4,d6	y1*y2
	move.l	d6,d4
	moveq	#0,d6
	move.w	d2,d6
	muls	d5,d6	z1*z2

	add.l	d6,d4
	add.l	d4,scal1

	tst.l	scal1
	bmi.s	non_visible

	move.l	(a6)+,(a5)+		face visible!
	rts

non_visible	addq.l	#4,a6
	move.l	#-1,(a5)+
	rts

;---------------------------------------------------------------------;
;	Routine de scroller du bas			;
;---------------------------------------------------------------------;

scroller_rout
	cmp.w	#4,scrolly
	bne	decal_scroll

scroller_2	clr.w	scrolly
	move.l	scroll_a0,a0

	moveq	#0,d0
	move.b	(a0)+,d0
	bpl.s	char_non_nul		>=0
	lea	scrolltext,a0
	move.b	(a0)+,d0

char_non_nul	lea	char_width,a1
	move.b	0(a1,d0.w),d1		Largeur (2 ou 3)

	lea	chartble,a1
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a1,d0.w),a4

	tst.w	odd_flag
	bmi.s	impair
	lea	fonte_2,a1
	bra.s	suite_scr

impair	lea	fonte_1,a1
suite_scr	move.l	a1,a2		Adresse ‚cran

xc	add.l	a4,a1

	tst.w	attention
	beq.s	caroule

	add.l	#8,a1	(cas 3)   (odd_flag=-1)
	lea	fonte_2,a2

	not.w	odd_flag
	not.w	attention

	bra	char_normal


caroule	cmp.l	#fonte_1,a2
	beq.s	ecran_impair

ecran_pair	tst.b	d1
	beq.s	char_normal

position_0	lea	fonte_1,a2	(Cas 2)   (odd_flag=0)
	not.w	attention	(= on garde encore le M)

	moveq	#0,d0
	move.b	(a0),d0		2Šme lettre
	tst.b	d0
	bpl.s	nonul
	lea	scrolltext,a0
	move.b	(a0),d0
nonul
	bra	beware

ecran_impair	tst.b	d1
	beq.s	char_normal

	move.l	a1,a2	(Cas 1)   (odd_flag=-1)
	bra	onyva2

char_normal
	moveq	#0,d0
	move.b	(a0),d0		2Šme lettre
	bpl.s	char_non_nul2
	lea	scrolltext,a0
	move.b	(a0),d0
char_non_nul2
	tst.w	odd_flag
	bmi.s	beware
	move.l	a0,scroll_a0
beware
	lea	chartble,a4
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a4,d0.w),a4

	add.l	a4,a2
	sub.l	#8,a2

onyva2	move.l	switch,d0
	lsl.w	#8,d0
	move.l	d0,a3		Adresse AUTRE ‚cran
	add.l	#160*243+216,a3

	movem.l	a0-a3,scroll_reg

decal_scroll	rts

;---------------------------------------------------------------------;
;	Fin de la vbl				;
;---------------------------------------------------------------------;

dac1
	jsr	music+$86	

	cmpi.b	#1,$fffffc02.w
	beq.s	cpu_time

suite
	cmpi.b	#$39,$fffffc02.w
	bne	otranw

	rts

cpu_time	move.w	#$5,$ffff8240.w
	bra.s	suite

clipend	rts

;---------------------------------------------------------------------;
;	ROUTINE DE TRACE DE LIGNE			;
;---------------------------------------------------------------------;

;---------------------------------------------------------------------;
;	CLIPPING				;
;---------------------------------------------------------------------;

line_rout	cmp.w	d0,d2
	bgt.s	clip1
	exg	d0,d2	
	exg	d1,d3	
clip1	move.w	d2,d5
	sub.w	d0,d5
	move.w	d3,d6
	sub.w	d1,d6
	cmp.w	#$140,d0
	bcs.s	clip2
	bpl.s	clipend
	tst.w	d5
	beq.s	clipend
	muls	d6,d0
	divs	d5,d0
	sub.w	d0,d1
	sub.w	d0,d0
clip2	cmp.w	#$140,d2
	bcs.s	clip3
	bmi.s	clipend
	tst.w	d5
	beq.s	clipend
	subi.w	#$13f,d2
	muls	d6,d2
	divs	d5,d2
	sub.w	d2,d3
	move.w	#$13f,d2
clip3	cmp.w	d1,d3
	bgt.s	clip4
	exg	d0,d2
	exg	d1,d3
clip4	move.w	d2,d5
	sub.w	d0,d5
	move.w	d3,d6
	sub.w	d1,d6
	cmp.w	#$c7,d1
	bcs.s	clip5
	bpl.s	clipend
	tst.w	d6
	beq.s	clipend
	muls	d5,d1
	divs	d6,d1
	sub.w	d1,d0
	sub.w	d1,d1
clip5	cmp.w	#$c7,d3
	bcs.s	clip6
	bmi.s	clipend
	tst.w	d6
	beq.s	clipend
	subi.w	#$c6,d3
	muls	d5,d3
	divs	d6,d3
	sub.w	d3,d2
	move.w	#$c6,d3
clip6
	cmp.w	d0,d2
	bne.s	not_id
	cmp.w	d1,d3
	bne.s	not_id
 
identite	lea	mul_160,a0
	add.w	d1,d1
	move.w	0(a0,d1.w),d1
	add.w	d1,a6

	andi.w	#-16,d2
	lsr.w	#1,d2
	add.w	d2,a6

	moveq	#0,d7
	andi.w	#15,d0
	subi.w	#15,d0
	neg.w	d0
	bset	d0,d7
	or.w	d7,(a6)

	rts

;---------------------------------------------------------------------;
not_id	move.w	#160,d6

	cmp.w	d0,d2
	bgt.s	ascend

	exg	d0,d2
	exg	d1,d3

ascend	move.w	d1,d4	d3!
	lea	mul_160,a0
	add.w	d4,d4
	move.w	0(a0,d4.w),d4
	add.w	d4,a6

	sub.w	d0,d2	d2 > d0
	beq	vertical

	sub.w	d1,d3
	bge.s	pos_slope

	neg.w	d6
	neg.w	d3

pos_slope	cmp.w	d2,d3
	bgt	hislope
	beq	oblique

	move.w	d0,d7
	andi.w	#15,d0
	cmp.w	#7,d0
	bls.s	pas_aug_1
	addq.w	#1,a6
pas_aug_1	andi.w	#-16,d7
	lsr.w	#1,d7
	add.w	d7,a6

	addq.w	#1,d3	Assure la prop. des lignes ?
	cmp.w	d2,d3
	bne.s	ne1
	subq.w	#1,d3
ne1
	move.w	d2,d4
	subq.w	#1,d2
	lea	division,a1
	lea	multi_640,a0
	add.w	d3,d3
	add.w	d3,d3
	add.l	0(a0,d3.w),a1
	add.w	d2,d2
	add.w	d2,a1
	move.w	(a1),a3
	move.w	d4,d2
	moveq	#0,d4

	lea	adr_table,a0
	add.w	d0,d2
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a1		debut
	add.w	d2,d2
	add.w	d2,d2
	move.l	0(a0,d2.w),a2
	move.w	(a2),sauve_mot
	move.w	d6,a4
	movem.w	val_reg,d0-d3/d5-d7
	move.w	#$4e75,(a2)
	jsr	(a1)
	move.w	sauve_mot,(a2)
	rts

waou	include	optlin53.s
	rts


hislope
	move.w	d0,d7
	andi.w	#15,d0
	cmp.w	#7,d0
	bls.s	pas_aug_2
	addq.w	#1,a6
pas_aug_2	andi.w	#-16,d7
	lsr.w	#1,d7
	add.w	d7,a6

	move.w	d2,d7

	addq.w	#1,d2	Assure la prop. des lignes ?
	cmp.w	d2,d3
	bne.s	ne2
	subq.w	#1,d2
ne2
	subq.w	#1,d3
	lea	division,a1
	lea	multi_640,a0
	add.w	d2,d2
	add.w	d2,d2
	add.l	0(a0,d2.w),a1
	add.w	d3,d3
	add.w	d3,a1
	move.w	(a1),a3

	moveq	#0,d4

	lea	adr_table2,a0
	add.w	d0,d7
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a1		debut
	addq.w	#1,d7		<= Yes sir !!!!
	add.w	d7,d7
	add.w	d7,d7
	move.l	0(a0,d7.w),a2
	move.w	(a2),sauve_mot
	move.w	d6,a4
	movem.w	val_reg,d0-d3/d5-d7
	move.w	#$4e75,(a2)
	jsr	(a1)
	move.w	sauve_mot,(a2)
	rts

waou2	include	optli5b3.s
	rts


oblique
	move.w	d0,d7
	andi.w	#15,d0
	cmp.w	#7,d0
	bls.s	pas_aug_3
	addq.w	#1,a6
pas_aug_3	andi.w	#-16,d7
	lsr.w	#1,d7
	add.w	d7,a6

	move.w	d2,d7

	lea	adr_table3,a0
	add.w	d0,d7
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a1		debut
	addq.w	#1,d7		<= Yes sir !!!!
	add.w	d7,d7
	add.w	d7,d7
	move.l	0(a0,d7.w),a2
	move.w	(a2),sauve_mot
	move.w	#$4e75,(a2)
	move.w	d6,a4
	move.w	a4,a5
	addq.w	#1,a5
	move.w	a4,a3
	addq.w	#7,a3
	movem.w	val_reg,d1-d7
	moveq	#1,d0
	jsr	(a1)
	move.w	sauve_mot,(a2)
	rts

waou4	include	optli5d3.s
	rts

vertical	sub.w	d1,d3
	bge.s	pos_slope_2
	neg.w	d6
	neg.w	d3
pos_slope_2
	move.w	d0,d7
	andi.w	#15,d0
	subi.w	#15,d0
	neg.w	d0
	moveq	#0,d4
	bset	d0,d4
	andi.w	#-16,d7
	lsr.w	#1,d7
	add.w	d7,a6

	lea	waou5,a0
	addq.w	#1,d3
	add.w	d3,d3	
	add.w	d3,d3
	move.w	0(a0,d3.w),d2
	move.w	#$4e75,0(a0,d3.w)
	jsr	waou5
	move.w	d2,0(a0,d3.w)
	rts

waou5	rept	320
	or.w	d4,(a6)
	add.w	d6,a6
	endr
	rts

;---------------------------------------------------------------------;
;	Routines d'interruption			;
;---------------------------------------------------------------------;

it_trap3	move.w	#$2300,(a7)
	rte

it_vbl	not.w	flag_vbl
;	movem.l	d0-d7/a0-a6,-(a7)
;	jsr	music+$86+4
;	movem.l	(a7)+,d0-d7/a0-a6
	rte

it_hbl	rept	32
	addq.l	#6,$68.w
	rte
	endr
	subq.l	#6,$68.w
	stop	#$2100
	move.w	#$2700,sr
	or.w	#$300,(a7)
	dcb.w	58,$4e71
	move.b	#0,$ffff820a.w	
	dcb.w	35,$4e71
	move.b	#2,$ffff820a.w
	rte

it_timerb_1	movem.l	d0/a0-a1,sauve_reg

	lea	$ffff8209.w,a0
attend_count0	cmp.b	#$10,(a0)
	blt.s	attend_count0
	move.w	#$30,d0
	sub.b	(a0),d0
	lsr.l	d0,d0

	dcb.w	53,$4e71

	lea	$ffff8240.w,a0
	lea	colors_sync,a1
	rept	36
	move.w	(a1)+,(a0)
	endr

	lea	colors_3d,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr

	clr.b	$fffffa1b.w
	
	move.b	#188,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#it_timerb_2,$120.w
	bclr.b	#0,$fffffa0f.w

	movem.l	sauve_reg,d0/a0-a1
	rte

it_timerb_2	movem.l	d0/a0,-(a7)

	lea	$ffff8209.w,a0
attend_count	cmp.b	#$d0,(a0)
	blo.s	attend_count
	move.w	#$f0,d0
	sub.b	(a0),d0
	lsr.l	d0,d0

	dcb.w	36,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	17,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	68,$4e71

	clr.b	$fffffa1b.w
	
	move.b	#10,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#it_timerb_3,$120.w

	bclr.b	#0,$fffffa0f.w

	movem.l	(a7)+,d0/a0
	rte

it_timerb_3	clr.b	$fffffa1b.w
	movem.l	d0/a0-a1,sauve_reg

	lea	$ffff8209.w,a0
attend_count1	cmp.b	#$b0,(a0)
	blo.s	attend_count1
	move.w	#$d0,d0
	sub.b	(a0),d0
	lsr.l	d0,d0


	dcb.w	1+9,$4e71
	lea	colors_3d_2,a0	12
	lea	$ffff8240.w,a1	8
	rept	8	
	move.l	(a0)+,(a1)+		140
	endr

	lea	$ffff8240.w,a0
	lea	colors_sync,a1
	rept	36
	move.w	(a1)+,(a0)
	endr

	clr.b	$fffffa1b.w
	
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#it_timerb_4,$120.w

	bclr.b	#0,$fffffa0f.w

	movem.l	sauve_reg,d0/a0-a1
	rte

it_timerb_4
	clr.b	$fffffa1b.w
	addq.w	#1,scrolly
	movem.l	d0-d7/a0-a6,-(a7)

	lea	$ffff8209.w,a0
attend_count2	cmp.b	#$a0,(a0)
	blo.s	attend_count2
	move.w	#$c0,d0
	sub.b	(a0),d0
	lsr.l	d0,d0

	dcb.w	8+4+4+8+4+4+9-13,$4e71
	movem.l	scroll_reg,a0-a3

u	set	0
	rept	5
	move.b	#$2,$ffff8260.w
	move.b	#$0,$ffff8260.w
	movem.l	-200+u(a3),d0-d7/a0-a2/a4-a6
	movem.l	d0-d7/a0-a2/a4-a6,-208+u(a3)
	movem.l	-144+u(a3),d0-d7/a0-a1
	move.b	#$0,$ffff820a.w
	move.b	#$2,$ffff820a.w
	dcb.w	8,$4e71
	move.b	#$1,$ffff8260.w
	move.b	#$0,$ffff8260.w
	dcb.w	9,$4e71
	move.b	#$2,$ffff8260.w
	move.b	#$0,$ffff8260.w
	movem.l	d0-d7/a0-a1,-152+u(a3)
	movem.l	-104+u(a3),d0-d7/a0-a2/a4-a6
	movem.l	d0-d7/a0-a2/a4-a6,-112+u(a3)
	nop
	move.b	#$0,$ffff820a.w
	move.b	#$2,$ffff820a.w
	dcb.w	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	9,$4e71
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	movem.l	-48+u(a3),d0-d7/a0-a2/a4-a6
	movem.l	d0-d7/a0-a2/a4-a6,-56+u(a3)
	dcb.w	24,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	9,$4e71
u	set	u+230
	endr

	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w

	movem.l	scroll_reg+4,a1-a3

	rept	2
	move.l	(a1)+,d0	12
	or.l	(a2)+,d0	16
	move.l	d0,(a3)+	12
	move.l	(a1),d0	12
	or.l	(a2),d0	16
	move.l	d0,(a3)	12
	lea	156(a1),a1	8
	lea	156(a2),a2	8
	lea	226(a3),a3	8=104
	endr

	dcb.w	24,$4e71
	
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb.w	8,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb.w	9,$4e71

	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	
	rept	3
	move.l	(a1)+,d0	12
	or.l	(a2)+,d0	16
	move.l	d0,(a3)+	12
	move.l	(a1),d0	12
	or.l	(a2),d0	16
	move.l	d0,(a3)	12
	lea	156(a1),a1	8
	lea	156(a2),a2	8
	lea	226(a3),a3	8=104
	endr
	
	dcb.w	9,$4e71

	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w

	dcb.w	8,$4e71

	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w

	dcb.w	9,$4e71

	rept	2
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	87,$4e71
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	9,$4e71
	endr
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	87-12-21,$4e71
	movem.l	a0-a3,scroll_reg
	movem.l	resetcolors,d0-d7
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	dcb.w	8,$4e71
	move.b	#1,$ffff8260.w
	move.b	#0,$ffff8260.w
	dcb.w	9,$4e71

st	movem.l	d0-d7,$ffff8240.w
	movem.l	(a7)+,d0-d7/a0-a6
	clr.b	$fffffa1b.w
	bclr.b	#0,$fffffa0f.w

	rte

;---------------------------------------------------------------------;
;	TABLE TRIGONOMETRIQUE - TABLES DE MULTIPLICATION	;
;---------------------------------------------------------------------;

odd_flag	dc.w	-1
scrolly	dc.w	4
attention	dc.w	0
lc	dc.w	0

char_width	dc.b	1,1,1,1,1
	dc.b	1,1,1,0,1
	dc.b	1,0,0,1,1
	dc.b	1,1,1,1,1
	dc.b	1,1,0,1,1
	dc.b	1,1,0,1,1
	dc.b	1,1,1,1,1
	dc.b	1,0,0,0,0
	dc.b	0,0,0,0,1
	dc.b	0,0,0,0,0,0,0,0,0,0

chartble	incbin	chartble.bin

	even
scrolltext	incbin	text.bin
	dc.b	-1

	even
sintable	incbin	trigotbl.bin
adr_table	incbin	adrtable.bin
adr_table2	incbin	adrtablb.bin
adr_table3	incbin	adrtablc.bin

	even
zoom	dc.w	2000

haut	dc.w	110
bas	dc.w	90
gauche	dc.w	150
droite	dc.w	170

haut2	dc.w	0
bas2	dc.w	0
gauche2	dc.w	0
droite2	dc.w	0

haut3	dc.w	0
bas3	dc.w	0
gauche3	dc.w	0
droite3	dc.w	0

multi_640
offset_640	set	0
	rept	200
	dc.l	offset_640
offset_640	set	offset_640+640
	endr

multi_1
offset_160	set	-160*50
	rept	300
	dc.w	offset_160
offset_160	set	offset_160+160
	endr

multi_2
offset_18	set	0
	rept	300
	dc.w	offset_18
offset_18	set	offset_18+18
	endr

multi_3
offset_12	set	0
	rept	300
	dc.w	offset_12
offset_12	set	offset_12+12
	endr

mul_160	equ	multi_1+100
mul_18	equ	multi_2
mul_12	equ	multi_3

;---------------------------------------------------------------------;
;	DATA				;
;	DONNEES PRINCIPALES			;
;	Angles, coordonn‚es, sinus et cosinus des angles...	;
;---------------------------------------------------------------------;

val_reg	dc.w	$2,$4,$8,$10,$20,$40,$80

adr_efface	dc.l	$f0000
sauve_a7	dc.l	0 

otheta	dc.w	0
ophi	dc.w	0
ogamma	dc.w	0

m	set	16

k	set	-12*m
l	set	-2*m

xcenter	set	0
ycenter	set	0
zcenter	set	0

ocoordsx
	dc.w	-5*m,-5*m,5*m,5*m
	dc.w	-5*m,-5*m,5*m,5*m

	dc.w	-4*m,4*m,4*m,-4*m
	dc.w	-3*m,-3*m,3*m,3*m
	dc.w	5*m,5*m,5*m,5*m

	dc.w	-5*m,-5*m,-5*m,-5*m

ocoordsy
	dc.w	-5*m,-5*m,-5*m,-5*m
	dc.w	5*m,5*m,5*m,5*m

	dc.w	-4*m,-4*m,4*m,4*m
	dc.w	-5*m,-5*m,-5*m,-5*m
	dc.w	-2*m,-2*m,2*m,2*m

	dc.w	0*m,-5*m,0*m,5*m

ocoordsz
	dc.w	-5*m,5*m,5*m,-5*m
	dc.w	-5*m,5*m,5*m,-5*m

	dc.w	-5*m,-5*m,-5*m,-5*m
	dc.w	-3*m,3*m,3*m,-3*m
	dc.w	-2*m,2*m,2*m,-2*m

	dc.w	-5*m,0*m,5*m,0*m

oncoords	dc.w	24

persmatx	dc.w	100,0,0,0,0,100,0,0,0,0,0,0,0,0,1,100

trace_ligne
	dc.w	0,1,0,3
	dc.w	1,2,2,3
	dc.w	-1

face1	dc.w	0,1,1,2,2,3,3,0,12,14,13,15,-1
face2	dc.w	1,2,2,6,6,5,5,1,1,6,2,5,-1
face3	dc.w	5,6,6,7,7,4,4,5,4,6,-1
face4	dc.w	0,3,3,7,7,4,4,0,8,9,9,10,10,11,11,8,-1
face5	dc.w	0,1,1,5,5,4,4,0,20,21,21,22,22,23,23,20,-1
face6	dc.w	3,2,2,6,6,7,7,3,16,17,17,18,18,19,19,16,-1

basevectors	dc.w	6	1 face a traiter
	dc.w	0,1,3	Face1
	dc.l	face1
	dc.w	1,5,2
	dc.l	face2
	dc.w	5,4,6
	dc.l	face3
	dc.w	4,0,7
	dc.l	face4
	dc.w	5,1,4
	dc.l	face5
	dc.w	7,3,6
	dc.l	face6

visibilite	dc.l	0,0,0,0,0,0,0

rebond	dc.l	courbe_y

courbe_y	incbin	rebond.bin
	dc.w	-999

	even
cmpt	dc.w	0
clean	dc.l	0

temoin	dc.b	0
temoin2	dc.b	0

flag_vbl	dc.w	0

line_counter	dc.w	42

fonte_1	incbin	fonte1.bin
fonte_2	incbin	fonte2.bin

logo	incbin	logo2.pi1
logo_colors	dc.w	$000,$2,$3,$4,$5,$6,$27,$37,$47,$57,$67,$77,$477,$577,$677,$777

colors_sync
	dc.w	$7,$6,$5,$4,$3,$2,$1,$0,$101,$202,$303,$404,$505,$606,$707,$706,$705,$704,$703,$702,$701,$700
	dc.w	$601,$502,$403,$302,$201,$100,$110,$220,$330,$440,$550,$660,$000,$000

	;	  0    1    2   3     4   5    6    7    8    9    10   11   12   13   14   15
col_1_3d	dc.w	$000,$007,$000,$227,$000,$447,$000,$667,$000,$777,$000,$667,$000,$447,$000,$227
col_2_3d	dc.w	$000,$000,$007,$227,$000,$000,$447,$667,$000,$000,$777,$667,$000,$000,$447,$227
col_3_3d	dc.w	$000,$000,$000,$000,$007,$227,$447,$667,$000,$000,$000,$000,$777,$667,$447,$227
col_4_3d	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$007,$227,$447,$667,$777,$667,$447,$227

col_1_scrol	dc.w	$000,$777,$000,$777,$000,$777,$000,$777,$000,$777,$000,$777,$000,$777,$000,$777
col_2_scrol	dc.w	$000,$000,$777,$777,$000,$000,$777,$777,$000,$000,$777,$777,$000,$000,$777,$777
col_3_scrol	dc.w	$000,$000,$000,$000,$777,$777,$777,$777,$000,$000,$000,$000,$777,$777,$777,$777
col_4_scrol	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777

resetcolors	dcb.l	16,$000

music	incbin	omega.mus

;---------------------------------------------------------------------;
	BSS				;
;---------------------------------------------------------------------;

res	ds.b	50000	on doit mettre un BIG espace ici!

restau	ds.l	20

switch	ds.l	1

adr_3d	ds.l	1

adr0	ds.b	1
adr1	ds.b	1
adr2	ds.b	1
adr3	ds.b	1

adr2_0	ds.b	1
adr2_1	ds.b	1
adr2_2	ds.b	1
adr2_3	ds.b	1

clr0	ds.b	1
clr1	ds.b	1
clr2	ds.b	1
clr3	ds.b	1

clr2_0	ds.b	1
clr2_1	ds.b	1
clr2_2	ds.b	1
clr2_3	ds.b	1

precalculs	ds.w	18

stheta	ds.w	1
ctheta	ds.w	1
sphi	ds.w	1
cphi	ds.w	1
sgamma	ds.w	1
cgamma	ds.w	1

clavier	ds.b	1
high_bas	ds.b	1
low_bas	ds.b	1
val_8203	ds.b	1

	even
	ds.l	200
pile	ds.l	1
non_sense	ds.l	16
sauve_reg	ds.l	16
colors_3d	ds.w	16
colors_3d_2	ds.w	16
current_adr	ds.l	1
abc	ds.w	1
scroll_a0	ds.l	1
scroll_reg	ds.l	4
sauve_mot	ds.w	1
coord_2d	ds.w	200
coord_hid	ds.w	1000
sauve_usp	ds.l	1
cleaning_part	ds.l	1
widthcleaning	ds.w	1
clean_height	ds.w	1
sss	ds.l	1
sauve_sr	ds.l	1
x3_1	ds.l	1
x3_2	ds.l	1
y3_1	ds.l	1
y3_2	ds.l	1
z3_1	ds.l	1
z3_2	ds.l	1
important	ds.w	3
scal1	ds.l	3
division	ds.w	320*200

ecrans	ds.b	(160*274)*2+256
