;---------------------------------------------------------------;
;	3D Surfaces pleines - ska 1992		;
;	RUBBER VECTOR			;
;---------------------------------------------------------------;

	opt	d+,o-	PAS d'optimisation!

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	pile,a7

;---------------------------------------------------------------;
;	Construction routines		;
;---------------------------------------------------------------;

deblong	equ	$24
long	equ	128

	lea	debut,a3

	clr.b	long_word

	lea	polyrout_1a,a5
	lea	milieu_1,a6
	lea	fin_1,a4
	jsr	construc_rout

	lea	polyrout_1b,a5
	lea	milieu_2,a6
	lea	fin_2,a4
	jsr	construc_rout

	lea	polyrout_1a+deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1),a0
	move.w	#$2e79,(a0)+
	move.l	#sauve_a7,(a0)+
	move.l	#$4e434e75,(a0)
	lea	polyrout_1b+deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1),a0
	move.w	#$2e79,(a0)+
	move.l	#sauve_a7,(a0)+
	move.l	#$4e434e75,(a0)

;---------------------------------------------------------------;
;	Construction des tables		;
;---------------------------------------------------------------;

construc_1a:	lea	table_1a-320*4,a0
	move.w	#320-1,d0
.avant_table	move.l	#$ffff8000,(a0)+
	dbf	d0,.avant_table
	move.w	#$8000,d2
	move.w	#19*long,d3
	moveq	#20-1,d4
.next_word	move.w	#$ffff,d1
	moveq	#16-1,d0
.word_pixels	move.w	d1,(a0)+
	move.w	d2,(a0)+
	lsr.w	#1,d1
	dbf	d0,.word_pixels
	add.w	d3,d2
	sub.w	#long,d3
	dbf	d4,.next_word

construc_1b:	lea	table_1b-320*4,a0
	move.w	#320-1,d0
.avant_table	move.l	#$ffff0000,(a0)+
	dbf	d0,.avant_table
	move.w	#deblong,d2
	move.w	#long,d3
	moveq	#20-1,d4
.next_word	move.w	#$8000,d1
	moveq	#16-1,d0
.word_pixels	move.w	d1,(a0)+
	move.w	d2,(a0)+
	ror.w	#1,d1
	or.w	#$8000,d1
	dbf	d0,.word_pixels
	add.w	d3,d2
	dbf	d4,.next_word
	sub.w	d3,d2
	move.w	#320-1,d0
.apres_table	move.w	#$ffff,(a0)+
	move.w	d2,(a0)+
	dbf	d0,.apres_table
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+

	lea	table_1a+320*4,a0
	move.w	#$8000,d1
	sub.w	d2,d1
	move.w	#320-1,d0
.apres_table_a	move.w	#$0000,(a0)+
	move.w	d1,(a0)+
	dbf	d0,.apres_table_a		
	clr.w	(a0)+
	move.w	#(deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1))-32768,(a0)+
	clr.w	(a0)+
	move.w	#(deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1))-32768,(a0)+
	clr.w	(a0)+
	move.w	#(deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1))-32768,(a0)+

;--------------- Pour les trames -------------------------------;

	lea	table_1a-320*4,a0
	lea	table_1b-320*4,a1
	lea	table_2a-320*4,a2
	lea	table_2b-320*4,a3
	lea	table_3a-320*4,a4
	lea	table_3b-320*4,a5
	move.l	#$aaaaffff,d4
	move.l	#$5555ffff,d5

	move.w	#(320*3)-1,d6

.adapt_table	move.l	(a0)+,d0
	move.l	(a1)+,d1
	move.l	d0,d2
	move.l	d1,d3
	add.w	#10+(deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1)),d0
	and.l	d4,d0	
	and.l	d4,d1
	and.l	d5,d2	
	and.l	d5,d3	
	move.l	d0,(a2)+
	move.l	d1,(a3)+
	move.l	d2,(a4)+
	move.l	d3,(a5)+
	dbf	d6,.adapt_table	
	move.l	(a0),(a2)+
	move.l	(a0)+,(a4)+
	move.l	(a1),(a3)+
	move.l	(a1)+,(a5)+
	move.l	(a0),(a2)+
	move.l	(a0)+,(a4)+
	move.l	(a1),(a3)+
	move.l	(a1)+,(a5)+
	move.l	(a0),(a2)+
	move.l	(a0)+,(a4)+
	move.l	(a1),(a3)+
	move.l	(a1)+,(a5)+



;---------------------------------------------------------------;
;	Sauvegardes			;
;---------------------------------------------------------------;

	lea	save,a0
	move.l	d0,(a0)+
	move.l	$ffff8200.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$8c.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

;---------------------------------------------------------------;
;      Initialisations pour les ‚crans SEE + palettes	;
;---------------------------------------------------------------;

	clr.l	resume_adr
	clr.b	resume_clear
	move.w	#28,nb_see_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,see_screen
	move.l	d0,see_screen+4
	add.l	#32000,d0
	move.l	d0,see_screen+8
	move.l	d0,see_screen+12
	add.l	#32000,d0
	move.l	d0,see_screen+16
	move.l	d0,see_screen+20
	add.l	#32000,d0
	move.l	d0,see_screen+24
	move.l	d0,see_screen+28

	lea	palette1,a0
	lea	palette2,a1
	move.l	a0,see_pal
	move.l	a1,see_pal+4
	move.l	a0,see_pal+8
	move.l	a1,see_pal+12
	move.l	a0,see_pal+16
	move.l	a1,see_pal+20
	move.l	a0,see_pal+24
	move.l	a1,see_pal+28

;---------------------------------------------------------------;
;	Initialisations pour les ‚crans WORK	;
;---------------------------------------------------------------;

	move.w	#20-4,nb_work_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,work_screen
	addq.l	#4,d0
	move.l	d0,work_screen+4
	add.l	#32000-4,d0
	move.l	d0,work_screen+8
	addq.l	#4,d0
	move.l	d0,work_screen+12
	add.l	#32000-4,d0
	move.l	d0,work_screen+16
	addq.l	#4,d0
	move.l	d0,work_screen+20
	add.l	#32000-4,d0
	move.l	d0,work_screen+24
	addq.l	#4,d0
	move.l	d0,work_screen+28

;---------------------------------------------------------------;
;	Initialisations pour les ‚crans CLEAR	;
;---------------------------------------------------------------;

	move.w	#24-4,nb_clear_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,clear_screen
	move.l	d0,clear_screen+4
	add.l	#32000,d0
	move.l	d0,clear_screen+8
	move.l	d0,clear_screen+12
	add.l	#32000,d0
	move.l	d0,clear_screen+16
	move.l	d0,clear_screen+20
	add.l	#32000,d0
	move.l	d0,clear_screen+24
	move.l	d0,clear_screen+28

;---------------------------------------------------------------;
;  Initialisations pour partie de chaque ‚cran … vider (d‚but)	;
;---------------------------------------------------------------;

	lea	max_min_screen,a0
	move.w	#150,d0	on met
	move.w	#170,d1	des
	move.w	#90,d2	valeurs
	move.w	#110,d3	bidon.
	movem.w	d0-d3,(a0)	il n'y a
	movem.w	d0-d3,8(a0)	que 4 ‚crans
	movem.w	d0-d3,16(a0)	en
	movem.w	d0-d3,24(a0)	fait. (multiple de 8)

;---------------------------------------------------------------;
;	Initialisations			;
;---------------------------------------------------------------;

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,a0
	move.w	#8000*4-1,d0
	moveq	#0,d1
empty_screens	move.l	d1,(a0)+
	dbf	d0,empty_screens

	clr.l	$fffffa06.w
	stop	#$2300
	stop	#$2300
	move.b	#1,$ffff8260.w
	stop	#$2300
	move.b	#0,$ffff8260.w

	stop	#$2300
	stop	#$2300
	move.l	#vbl,$70.w
	move.l	#super_mode,$8c.w   On change le TRAP #3
	stop	#$2300

;---------------------------------------------------------------;
;	Boucle principale		;
;	1 boucle = 1 objet		;
;---------------------------------------------------------------;

start:	addq.w	#4,nb_work_screen
	cmp.w	#32,nb_work_screen
	blo.s	.ok
	clr.w	nb_work_screen
.ok	move.w	nb_work_screen,d0

	addq.w	#4,nb_clear_screen
	cmp.w	#32,nb_clear_screen
	blo.s	.ok2
	clr.w	nb_clear_screen
.ok2	move.w	nb_clear_screen,d1
	move.w	d1,d3
	and.w	#$fff8,d1

wait_for_vbl	move.w	nb_see_old,d2
	and.w	#$fff8,d2
	cmp.w	d2,d1
	beq.s	wait_for_vbl

	move.w	d3,d1
	lea	work_screen,a0
	move.l	(a0,d0.w),d2
	move.l	d2,work
	lea	clear_screen,a0
	move.l	(a0,d1.w),d2
	move.l	d2,clear	

	move.w	nb_work_screen,d0
	btst	#2,d0	    ‚cran multiple de 4 ?
	bne.s	.no_init_minmax	    oui: pas init min & max

	move.w	#640,minimum_x	    ces valeurs
	move.w	#-320,maximum_x	    ne peuvent etre
	move.w	#300,minimum_y	    que
	move.w	#-100,maximum_y     chang‚es!

.no_init_minmax
	move.w	no_rubuffer,d0
	addq.w	#4,d0
	and.w	#$7f,d0
	move.w	d0,no_rubuffer

	lea	adr_rubuffers,a0
	add.w	d0,a0
	move.l	(a0),work_buffer

	subq.w	#1,count_vbl
	bmi	fin_prg
	tst.w	sens
	beq.s	aug

dim	cmp.w	#182,count_vbl
	bhi.s	no_inc
	subq.w	#1,gros+2
	cmp.w	#-120,gros+2
	beq	fin_prg
	bra.s	no_inc

aug	cmp.w	#180-1,h_rub+2
	beq.s	no_inc0
	addq.w	#1,h_rub+2
	bra.s	no_inc
no_inc0	not.w	sens

no_inc	bsr	clear_rout
	bsr	precalculs_3d
	bsr	rotation_points
	bsr	trace_3d
	bsr	affiche_buffer

	addq.w	#1,otheta
	cmp.w	#360,otheta
	blo.s	.ok1
	clr.w	otheta

.ok1	addq.w	#2,ophi
	cmp.w	#360,ophi
	blo.s	.ok2
	clr.w	ophi

.ok2	addq.w	#1,ogamma
	cmp.w	#360,ogamma
	blo.s	.ok3
	clr.w	ogamma

.ok3	cmp.b	#1,$fffffc02.w
	bne.s	.ok4

	move.w	#4,$ffff8240.w

.ok4	cmp.b	#$39,$fffffc02.w
	bne	start

;---------------------------------------------------------------;
;	Fin du programme		;
;---------------------------------------------------------------;

fin_prg	lea	save,a0
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$ffff8200.w
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$8c.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

;---------------------------------------------------------------;
;	Routine de precalculs 3D en debut de VBL	;
;---------------------------------------------------------------;

precalculs_3d	lea	sintable,a5

	move.w	otheta,d1

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
	rts

;---------------------------------------------------------------;
;	Rotation des points espace		;
;---------------------------------------------------------------;

rotation_points	move.w	nb_point,d7
	subq.w	#1,d7

	lea	ocoordsx,a0
	lea	ocoordsy,a1
	lea	ocoordsz,a2
	
	lea	coord_2d,a3

rotate_point	lea	precalculs,a6

	move.w	(a0),d0
	move.w	(a1),d1
	move.w	(a2),d2
	muls	(a6)+,d0
	muls	(a6)+,d1
	muls	(a6)+,d2
	add.l	d1,d0
	add.l	d2,d0
	move.l	d0,d3	x0

	move.w	(a0),d0
	move.w	(a1),d1
	move.w	(a2),d2
	muls	(a6)+,d0
	muls	(a6)+,d1
	muls	(a6)+,d2
	add.l	d1,d0
	add.l	d2,d0
	move.l	d0,d4	y0

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
	move.l	d0,d5	z0

	swap	d5
	clr.w	d5
	swap	d5
grossi	add.w	#790,d5
	asr.l	#6,d3
	asr.l	#6,d4
	divs	d5,d3
	divs	d5,d4
gros	add.w	#88,d3
	add.w	#88,d4
	move.w	d3,(a3)+
	move.w	d4,(a3)+

test_minimum_x	cmp.w	minimum_x,d3
	bge.s	test_minimum_y
	move.w	d3,minimum_x

test_minimum_y	cmp.w	minimum_y,d4
	bge.s	test_maximum_x
	move.w	d4,minimum_y

test_maximum_x	cmp.w	maximum_x,d3
	ble.s	test_maximum_y
	move.w	d3,maximum_x

test_maximum_y	cmp.w	maximum_y,d4
	ble.s	end_test_xy
	move.w	d4,maximum_y

end_test_xy	dbf	d7,rotate_point

	move.w	nb_work_screen,d0     ‚cran de num‚ro
	and.w	#$fff8,d0	      multiple de 8
	lea	max_min_screen,a0     seulement.
	add.w	d0,d0
	add.w	d0,a0
	move.w	minimum_x,(a0)		
	move.w	maximum_x,2(a0)		
	move.w	minimum_y,4(a0)		
	move.w	maximum_y,6(a0)		
	rts

;---------------------------------------------------------------;
;	Gestion du trac‚ de polygones		;
;---------------------------------------------------------------;

trace_3d:	lea	polygone,a0
	lea	coord_2d,a1
	
;---------------------------------------------------------------;

next_poly	move.w	(a0)+,d7
	bmi	no_more_poly

one_polygone:	;subq.w	#1,d7

	bsr	hidden_face
	tst.l	d5
	bmi.s	trace_polygone

	move.w	(a0)+,d6
	add.w	d6,a0
	bra.s	next_poly

trace_polygone	addq.l	#2,a0
	move.w	(a0)+,couleur

next_line_poly	lea	lines_poly,a2	On va recopier
	move.w	d7,d0	deux fois
	add.w	d0,d0	nos coordonnees
	add.w	d0,d0	x et y.
	lea	(a2,d0.w),a3	dans lines_poly.

	subq.w	#2,d7

	move.w	(a0)+,d0	numero point
	add.w	d0,d0
	add.w	d0,d0
	move.w	2(a1,d0.w),d1	y
	move.w	(a1,d0.w),d0	x
	move.w	d1,d4	d4: y mini
	move.w	d1,d5	d5: y maxi
	move.l	a2,a4	a4: pointeur debut initial.
	move.w	d0,(a2)+
	move.w	d0,(a3)+
	move.w	d1,(a2)+
	move.w	d1,(a3)+

copie_coords	move.w	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.w	2(a1,d0.w),d1	y
	move.w	(a1,d0.w),d0	x

test_if_mini_y	cmp.w	d4,d1
	bge.s	test_if_maxi_y
	move.w	d1,d4
	move.l	a2,a4	a4: pointeur debut

test_if_maxi_y	cmp.w	d5,d1
	ble.s	not_maxi_y
	move.w	d1,d5

not_maxi_y	move.w	d0,(a2)+
	move.w	d0,(a3)+
	move.w	d1,(a2)+
	move.w	d1,(a3)+
	dbf	d7,copie_coords

	move.w	d4,mini_y
	move.w	d5,maxi_y
	sub.w	d4,d5	d4=mini y ; d5=hauteur
	move.w	d5,-(a7)

;---------------------------------------------------------------;
;	Delimitation droite polygone: (buffer2)	;
;---------------------------------------------------------------;

line_droite	moveq	#0,d6
	movem.w	(a4),d0-d3	x1,y1,x2,y2
	lea	4(a4),a4
	cmp.w	d1,d3
	bgt.s	.not_inverse
	exg	d0,d2
	exg	d1,d3

.not_inverse	sub.w	d0,d2	x2-x1
	move.w	d2,d4
	tst.w	d4
	bge.s	.dx_positif
	neg.w	d4
.dx_positif	sub.w	d1,d3	y2-y1
	beq	.si_if_ended
	move.w	d3,d6	decompte hauteur aprŠs.
	add.w	d1,d1
	lea	buffer2,a6
	add.w	d1,a6	a6=pointeur buffer.

	cmp.w	d4,d3
	bgt.s	.vert_slope

	moveq	#0,d4
	jsr	delim_hori
	bra.s	.si_if_ended

.vert_slope	moveq	#0,d4
	jsr	delim_vert

.si_if_ended	sub.w	d6,d5	on passe … l'autre buffer?
	bgt.s	line_droite	non.

	move.w	(a7)+,d5

;---------------------------------------------------------------;
;	Delimitation gauche polygone: (buffer1)	;
;---------------------------------------------------------------;

line_gauche	moveq	#0,d6
	movem.w	(a4),d0-d3
	lea	4(a4),a4
	cmp.w	d1,d3
	bgt.s	.not_inverse
	exg	d0,d2
	exg	d1,d3

.not_inverse	sub.w	d0,d2	x2-x1
	move.w	d2,d4
	tst.w	d4
	bge.s	.dx_positif
	neg.w	d4
.dx_positif	sub.w	d1,d3	y2-y1
	beq	.si_if_ended
	move.w	d3,d6	decompte hauteur aprŠs.
	add.w	d1,d1
	lea	buffer1,a6
	add.w	d1,a6	a6=pointeur buffer.

	cmp.w	d2,d4
	bgt.s	.vert_slope

	moveq	#0,d4
	jsr	delim_hori
	bra.s	.si_if_ended

.vert_slope	moveq	#0,d4
	jsr	delim_vert

.si_if_ended	sub.w	d6,d5	on passe … l'autre buffer?
	bgt.s	line_gauche	non.

;---------------------------------------------------------------;
	addq.l	#2,a0

	movem.l	a0-a1,-(a7)
	jsr	rempli_poly
	movem.l	(a7)+,a0-a1
	
	bra	next_poly

no_more_poly	rts

;---------------------------------------------------------------;
;	Routine de detection de face cachee	;
;---------------------------------------------------------------;

hidden_face	move.l	d7,-(a7)
	movem.w	4(a0),d5-d7
	rept	2
	add.w	d5,d5
	add.w	d6,d6
	add.w	d7,d7
	endr
	move.w	(a1,d5.w),d0
	move.w	2(a1,d5.w),d1
	move.w	(a1,d6.w),d2
	move.w	2(a1,d6.w),d3
	move.w	(a1,d7.w),d4
	move.w	2(a1,d7.w),d5
	sub.w	d2,d0
	sub.w	d3,d1
	sub.w	d2,d4
	sub.w	d3,d5
	muls	d0,d5
	muls	d1,d4
	sub.l	d4,d5
	add.l	#80,d5	il faut l'enlever
	move.l	(a7)+,d7
no_clearing	rts

;---------------------------------------------------------------;
;	Routine de vidage d'ecran		;
;---------------------------------------------------------------;

clear_rout:	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	work_buffer,a0
	lea	190*4*12(a0),a0
	rept	190
	movem.l	d0-d7/a1-a4,-(a0)
	endr
	rts

affiche_buffer	move.w	pos_rubcourbe,d0
	addq.w	#2,d0
	and.w	#$1ff,d0
	move.w	d0,pos_rubcourbe
	
	move.l	work,a1
	lea	10*160+32(a1),a1

	lea	courbe_rubber,a0
	lea	adr_rubuffers,a3
	move.w	no_rubuffer,d1
	lsr.w	#2,d1
	or.w	#$40,d1
	move.w	d1,a4
	sub.w	#$1f,a4

h_rub	move.w	#0,d7

	sub.l	a5,a5

rubberrout	move.w	(a0,d0.w),d1
	addq.w	#2,d0
	and.w	#$1ff,d0

	add.w	a4,d1

	and.w	#$1f,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a3,d1.w),a2	
	add.w	a5,a2

	movem.l	(a2)+,d1-d6
	move.l	d1,(a1)
	move.l	d2,8(a1)
	move.l	d3,$10(a1)
	move.l	d4,$18(a1)
	move.l	d5,$20(a1)
	move.l	d6,$28(a1)
	movem.l	(a2)+,d1-d6
	move.l	d1,$30(a1)
	move.l	d2,$38(a1)
	move.l	d3,$40(a1)
	move.l	d4,$48(a1)
	move.l	d5,$50(a1)
	move.l	d6,$58(a1)

	lea	48(a5),a5
	lea	160(a1),a1
	dbf	d7,rubberrout
	rts

pos_rubcourbe	dc.w	0

courbe_rubber
	incbin	rubwave.bin

;---------------------------------------------------------------;
;	Routine de remplissage de polygone	;
;---------------------------------------------------------------;

poly:	cmp.w	d5,d1
	bge.s	.ok1
	move.w	d1,d5	nouveau minimum

.ok1	cmp.w	d1,d6
	bge.s	.ok2
	move.w	d1,d6	nouveau maximum

.ok2	move.w	d5,mini_y
	move.w	d6,maxi_y

;---------------------------------------------------------------;
;	Choix du buffer			;
;	descend= buffer2+nb_droite (delim. a droite)	;
;	monte  = buffer1+nb_gauche (delim. a gauche)	;
;---------------------------------------------------------------;

	cmp.w	d1,d3
	beq	continue
	bgt.s	monte	pente > 0 => buffer1

descend	addq.w	#2,nb_droite
	movem.w	d0-d3,(a3)	a3=pts_droite
	lea	8(a3),a3

	exg	d0,d2
	exg	d1,d3
	lea	buffer2,a6

	bra.s	cont

monte	addq.w	#2,nb_gauche
	movem.w	d0-d3,(a2)	a2=pts_gauche
	lea	8(a2),a2
	lea	buffer1,a6

cont	sub.w	d1,d3
	beq	continue
	move.w	d1,d4

	add.w	d4,d4
	add.w	d4,a6	buffer au bon endroit

	move.w	d2,d4
	sub.w	d0,d4
	bgt	pente_posi

	neg.w	d4

pente_posi
;---------------------------------------------------------------;
;	Choix de la routine de d‚limitation	;
;---------------------------------------------------------------;

	cmp.w	d4,d3
	bgt	plutot_vert
	
plutot_hori	moveq	#0,d4
	jsr	delim_hori
	bra	continue

plutot_vert	jsr	delim_vert

;---------------------------------------------------------------;
;	Autre ligne			;
;---------------------------------------------------------------;

continue	move.w	mini_y,d5
	move.w	maxi_y,d6
fin_rout	rts
	
;---------------------------------------------------------------;
;	Remplissage			;
;---------------------------------------------------------------;

rempli_poly:	lea	buffer1,a0
	lea	buffer2,a1

	move.w	mini_y,d5
	move.w	maxi_y,d6

	cmp.w	#199,d6
	ble.s	ok_down

	move.w	#199,d6

ok_down	move.w	d6,d3	d3 va servir plus loin!

	tst.w	d5
	bpl.s	ok_up

	moveq	#0,d5

ok_up	move.b	d5,odd_y	pour trames (pair/impair)
	
	sub.w	d5,d6	hauteur dans d6

	move.w	d6,d2	hauteur dans d2
	subq.w	#1,d2
	bmi	fin_rout

	moveq	#0,d7
	move.w	d5,d7

	add.w	d5,d5	va servir un peu + loin!
	add.w	d5,a0
	add.w	d5,a1

	moveq	#0,d6
	move.w	couleur,d6	couleur: ...xxxxxXX
	and.w	#2,d6	XX=couleur r‚elle; x=trame
	add.l	work_buffer,d6
	lea	mul_48,a2
	add.w	d7,d7
	move.w	(a2,d7.w),d7
	add.l	d7,d6
	
	move.l	d6,a5
	move.w	d2,d6
	lea	-48(a5),a5

	add.w	d3,d3	  on indique
	lea	buffer1,a6	  dans les buffers
	move.w	#641*4,(a6,d3.w)  la fin du
	lea	buffer2,a6	  tracage du polygone
	move.w	#641*4,(a6,d3.w)  (ICI seulement)

	lea	polyrout_1a+32768,a3

un_seul_plan	btst.b	#7,couleur+1	  ; trame ?
	bne	trame

;---------------------------------------------------------------;
;	Lancement de la routine de remplissage (trame)	;
;---------------------------------------------------------------;

normal:	lea	table_1a,a4
	lea	table_1b,a2
	moveq	#-1,d7
	move.l	a7,sauve_a7
	move.w	#$300,sr
	bra	fill_polygone

;---------------------------------------------------------------;
;	Lancement de la routine de remplissage (trame)	;
;---------------------------------------------------------------;

trame:	move.l	a7,sauve_a7
	move.w	#$300,sr	  mode utilisateur

	lea	table_2a,a4
	lea	table_2b,a2
	move.l	#$55555555,d7
	move.l	#$aaaaaaaa,d6
	lea	table_3a,a7
	lea	table_3b,a6

	btst.b	#0,odd_y	  ligne paire ou impaire?
	bne.s	fill_polygone

	moveq	#-4,d0
	and.w	(a0)+,d0
	moveq	#-4,d1
	and.w	(a1)+,d1
	lea	48(a5),a5
	move.l	(a6,d1.w),d1
	move.l	(a7,d0.w),d0
	add.w	d0,d1
	jmp	(a3,d1.w)

fill_polygone	moveq	#-4,d0
	and.w	(a0)+,d0
	moveq	#-4,d1
	and.w	(a1)+,d1
	lea	48(a5),a5
	move.l	(a2,d1.w),d1
	move.l	(a4,d0.w),d0
	add.w	d0,d1
	jmp	(a3,d1.w)
	rts

;---------------------------------------------------------------;
;	Routines de delimitations du polygone	;
;---------------------------------------------------------------;

delim_hori:	addq.w	#1,d3
	ext.l	d2
	lsl.l	#7,d2
	divs	d3,d2
	subq.w	#1,d3	on remet d3 ok.
	ext.l	d2
	add.w	d2,d2
	lsl.l	#8,d2
	add.l	d2,d2
	add.l	d2,d2
	swap	d2
	move.w	d2,d1
	swap	d2
	neg.w	d3
	add.w	#$12c,d3
	move.w	d3,d4
	add.w	d4,d4
	lsl.w	#2,d3
	add.w	d4,d3
	add.l	d0,d0
	add.l	d0,d0
	move.w	d2,d4
	jmp	line1(pc,d3.w)

line1	rept	300
	add.w	d2,d4
	addx.w	d1,d0
	move.w	d0,(a6)+
	endr
	;move.w	d0,(a6)+
	rts

;---------------------------------------------------------------;

delim_vert:	ext.l	d2
	lsl.l	#7,d2
	divs	d3,d2
	ext.l	d2
	add.w	d2,d2
	lsl.l	#8,d2
	add.l	d2,d2
	add.l	d2,d2
	swap	d2
	move.w	d2,d1
	swap	d2
	neg.w	d3
	add.w	#$12c,d3
	move.w	d3,d4
	add.w	d4,d4
	lsl.w	#2,d3
	add.w	d4,d3
	add.l	d0,d0
	add.l	d0,d0
	;move.w	d2,d4	;enlev‚=ligne plus belle?
	jmp	line2(pc,d3.w)

line2	rept	300
	add.w	d2,d4
	addx.w	d1,d0
	move.w	d0,(a6)+
	endr
	;move.w	d0,(a6)+
	rts

;---------------------------------------------------------------;
;	Routine d'interruption VBL		;
;   Adresse ‚cran incr‚ment‚e … chaque VBL + installe palette	;
;---------------------------------------------------------------;

vbl:	movem.l	d0-d7/a0,save_registers

	move.w	nb_see_screen,nb_see_old

	addq.w	#4,nb_see_screen
	cmp.w	#32,nb_see_screen
	blo.s	.ok
	clr.w	nb_see_screen

.ok	move.w	nb_see_screen,d0

	cmp.w	nb_work_screen,d0
	beq	wait_nxt_vbl

	lea	see_screen,a0	   Attention!
	move.l	(a0,d0.w),d1	   l'adresse ‚cran sera
	lsr.w	#8,d1	   install‚e … la
	move.l	d1,$ffff8200.w	   -PROCHAINE- vbl!

	move.w	nb_see_old,d0	   palette de la PRESENTE
	lea	see_pal,a0	   vbl! attention!
	move.l	(a0,d0.w),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	save_registers,d0-d7/a0
	rte

wait_nxt_vbl	move.w	nb_see_old,nb_see_screen
	move.w	nb_see_old,d0	   palette de la PRESENTE
	lea	see_pal,a0	   vbl! attention!
	move.l	(a0,d0.w),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	save_registers,d0-d7/a0
	rte

;---------------------------------------------------------------;
;	Construction routines polygone		;
;---------------------------------------------------------------;

construc_rout:	lea	(a5),a0
	jsr	(a4)

	move.w	#20-1,d6

	lea	deblong(a5),a2
	move.w	#20*long,d7
	move.w	#20,d0
	move.w	#0,d1

next_block	move.l	a2,a0
	jsr	(a3)
	move.w	#$c041,(a0)+	  ;and.w d1,d0
	move.w	#$816d,(a0)+	  ;or.w d0,X(a5)
	move.w	d1,(a0)+	  ;
	tst.b	long_word
	beq.s	.word
	move.w	#$816d,(a0)+	  ;or.w d0,X(a5)
	move.w	d1,(a0)+	  ;
	addq.w	#2,-2(a0)
.word	jsr	(a4)

	lea	long(a2),a1
	move.w	d0,d4
	subq.w	#2,d4
	move.w	#-1,d5

	tst.w	d4
	bmi.s	no_more
one_block	move.l	a1,a0
	move.w	d1,d2
	move.w	d5,d3
	jsr	(a3)
	move.w	#$816d,(a0)+	  ;or.w d0,X(a5)
	move.w	d2,(a0)+	  ;
	addq.w	#2,d2
	tst.b	long_word
	beq.s	word_deb
	move.w	#$816d,(a0)+	  ;or.w d0,X+2(a5)
	move.w	d2,(a0)+	  ;
word_deb	addq.w	#2,d2
	tst.w	d3
	bmi.s	.no_word
.word	jsr	(a6)	  ;move.w d7,X(a5)
	move.w	d2,(a0)+	  ;
	addq.w	#4,d2
	dbf	d3,.word
.no_word	move.w	#$836d,(a0)+	  ;or.w d1,X(a5)
	move.w	d2,(a0)+	  ;
	addq.w	#2,d2
	tst.b	long_word
	beq.s	word_fin
	move.w	#$836d,(a0)+	  ;or.w d1,X+2(a5)
	move.w	d2,(a0)+	  ;
word_fin	jsr	(a4)
	lea	long(a1),a1
	addq.w	#1,d5
	dbf	d4,one_block

no_more	add.w	d7,a2
	sub.w	#long,d7
	subq.w	#1,d0
	addq.w	#4,d1	coz RUBBER
	dbf	d6,next_block
	rts

;---------------------------------------------------------------;
;	Data pour routines polygone:		;
;---------------------------------------------------------------;

debut:	move.w	#$4840,(a0)+	  ;swap d0
	move.w	#$4841,(a0)+	  ;swap d1
	rts

fin_1:	move.w	#$70fc,(a0)+	  ;moveq #-4,d0
	move.w	#$c058,(a0)+	  ;and.w (a0)+,d0
	move.w	#$72fc,(a0)+	  ;moveq #-4,d1
	move.w	#$c259,(a0)+	  ;and.w (a1)+,d1
	move.l	#$4bed0030,(a0)+  ;lea $30(a5),a5
	move.l	#$22321000,(a0)+  ;move.l (a2,d1.w),d1
	move.l	#$20340000,(a0)+  ;move.l (a4,d0.w),d0
	move.w	#$d240,(a0)+	  ;add.w d0,d1
	move.l	#$4ef31000,(a0)+  ;jmp (a3,d1.w),d1
	rts

fin_2:	move.w	#$70fc,(a0)+	  ;moveq #-4,d0
	move.w	#$c058,(a0)+	  ;and.w (a0)+,d0
	move.w	#$72fc,(a0)+	  ;moveq #-4,d1
	move.w	#$c259,(a0)+	  ;and.w (a1)+,d1
	move.l	#$4bed0030,(a0)+  ;lea $30(a5),a5
	move.l	#$22361000,(a0)+  ;move.l (a6,d1.w),d1
	move.l	#$20370000,(a0)+  ;move.l (a7,d0.w),d0
	move.w	#$d240,(a0)+	  ;add.w d0,d1
	move.l	#$4ef31000,(a0)+  ;jmp (a3,d1.w),d1
	rts

milieu_1:	move.w	#$3b47,(a0)+	  ;move.w d7,X(a5)
	rts

milieu_2:	move.w	#$3b46,(a0)+	  ;move.w d6,X(a5)
	rts

milieu_3:	move.w	#$2b47,(a0)+	  ;move.l d7,X(a5)
	rts

milieu_4:	move.w	#$2b46,(a0)+	  ;move.l d6,X(a5)
	rts


;---------------------------------------------------------------;
;	Detournement du TRAP #3		;
;---------------------------------------------------------------;

super_mode	move.w	#$2300,(a7)
	rte

;---------------------------------------------------------------;
	DATA			;
;	Divers			;
;---------------------------------------------------------------;
	even
restore_rout	dc.l	$b2406d10,$22321000,$20340000,$d2404ef6,$10004e75

;---------------------------------------------------------------;
;	Concernant les calculs 3D		;
;---------------------------------------------------------------;
	even
sintable	incbin	trigotbl.bin

w	set	$0

otheta	dc.w	w
ophi	dc.w	w
ogamma	dc.w	w

k	set	30

ocoordsx
	dc.w	-5*k,-5*k,5*k,5*k
	dc.w	-5*k,-5*k,5*k,5*k

ocoordsy	dc.w	-5*k,5*k,5*k,-5*k
	dc.w	-5*k,5*k,5*k,-5*k

ocoordsz	dc.w	-5*k,-5*k,-5*k,-5*k
	dc.w	5*k,5*k,5*k,5*k

nb_point	dc.w	8

clear_reg	dcb.l	16,0


	;	  0    1    2   1+2   4   4+1  4+2 4+2+1  8   8+1 8+2 8+2+1 8+4 8+4+1 8+4+2 8+4+2+1
palette1	dc.w	$000,$444,$666,$777,$000,$444,$666,$777,$000,$444,$666,$777,$000,$444,$666,$777
palette2	dc.w	$000,$000,$000,$000,$444,$444,$444,$444,$666,$666,$666,$666,$777,$777,$777,$777

;---------------------------------------------------------------;
;	Concernant les Polygones		;
;---------------------------------------------------------------;
	even
polygone:	;dc.w	4	nb de sommets
	;dc.w	12	a ajouter
	;dc.w	0	couleur (0 ou 2) $80=trame
	;dc.w	0,1,2,3,0	No de lignes.

	dc.w	4,12,0,0,3,2,1,0
	dc.w	4,12,2,4,7,3,0,4
	dc.w	4,12,0,5,6,7,4,5
	dc.w	4,12,2,1,2,6,5,1
	dc.w	4,12,0+$80,4,0,1,5,4
	dc.w	4,12,0+$80,3,7,6,2,3

	dc.w	-1

;---------------------------------------------------------------;
;	Table de multipilcation par 160		;
;---------------------------------------------------------------;

mul_48
x	set	0
	rept	250
	dc.w	x
x	set	x+48
	endr

;---------------------------------------------------------------;
;	Table des buffers pour la RUBBER	;
;---------------------------------------------------------------;

no_rubuffer	dc.w	0
work_buffer	dc.l	0

adr_rubuffers
x	set	0
	rept	32
	dc.l	rubuffers+x
x	set	x+((12*4)*180)
	endr

count_vbl	dc.w	50*10
sens	dc.w	0

;---------------------------------------------------------------;
	BSS			;
;---------------------------------------------------------------;

	even
	ds.l	100
pile	ds.l	1
	even
sauve_a7	ds.l	1
save	ds.l	20
save_registers	ds.l	16

flag_vbl	ds.w	1

see_screen	ds.l	8
see_pal	ds.l	8
nb_see_screen	ds.w	1
nb_see_old	ds.w	1

work_screen	ds.l	8
nb_work_screen	ds.w	1

clear_screen	ds.l	8
nb_clear_screen	ds.w	1

max_min_screen	ds.w	4*8    4 ‚crans (pas 8),et 4 mots par ‚cran 

see	ds.l	1
work	ds.l	1
clear	ds.l	1

resume_adr	ds.l	1

resume_clear	ds.b	1

;---------------------------------------------------------------;
;	Concernant les calculs 3D		;
;---------------------------------------------------------------;

	even
precalculs	ds.w	18

stheta	ds.w	1
ctheta	ds.w	1
sphi	ds.w	1
cphi	ds.w	1
sgamma	ds.w	1
cgamma	ds.w	1

coord_2d	ds.w	100

;---------------------------------------------------------------;
;	Concernant les Polygones		;
;---------------------------------------------------------------;

odd_y	ds.b	1
	even
couleur	ds.w	1

maxi_y	ds.w	1
mini_y	ds.w	1

minimum_x	ds.w	1
maximum_x	ds.w	1
minimum_y	ds.w	1
maximum_y	ds.w	1

height_clearing	ds.w	1
width_routine	ds.w	1

lines_poly	ds.l	20

nb_gauche	ds.w	1
nb_droite	ds.w	1
pts_gauche	ds.w	100
pts_droite	ds.w	100

	ds.w	400
buffer1	ds.w	3000
	ds.w	400
buffer2	ds.w	3000

long_word	ds.b	1
	even
polyrout_1a	ds.b	10+deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1)
polyrout_1b	ds.b	10+deblong+long*(20+19+18+17+16+15+14+13+12+11+10+9+8+7+6+5+4+3+2+1)
	
	ds.l	320
table_1a	ds.l	320+320+3
	ds.l	320
table_1b	ds.l	320+320+3
	ds.l	320
table_2a	ds.l	320+320+3
	ds.l	320
table_2b	ds.l	320+320+3
	ds.l	320
table_3a	ds.l	320+320+3
	ds.l	320
table_3b	ds.l	320+320+3

ecran0	ds.l	8000+64
ecran1	ds.l	8000
ecran2	ds.l	8000
ecran3	ds.l	8000

rubuffers	ds.b	((12*4)*180)*32