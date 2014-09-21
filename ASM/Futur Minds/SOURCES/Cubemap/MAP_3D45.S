;---------------------------------------------------------------;
;	3D Surfaces pleines - ska 1992 - MAPPING	;
;	FINISH
;	marche avec grossi=240
;	===> ... n'importe quoi?!!
;---------------------------------------------------------------;
	opt	d+,o-	PAS d'optimisation!

pente	macro
	add.l	a0,d1
	addx.w	d0,d1
	add.l	a1,d2
	addx.w	d0,d2
	move.w	d2,d3
	move.b	d1,d3
	move.b	(a2,d3.l),d4
	dc.w	$4efb,\1
	illegal
	illegal
	illegal
	illegal
	endm

;---------------------------------------------------------------;
pente2	macro
	add.l	a0,d1
	addx.w	d0,d1
	add.l	a1,d2
	addx.w	d0,d2
	move.w	d2,d3
	move.b	d1,d3
	move.b	(a2,d3.l),d4
	move.l	d5,(a4)+
	move.l	d6,(a4)+
	moveq	#0,d5
	moveq	#0,d6
	dc.w	$4efb,\1
	endm

;---------------------------------------------------------------;
point	Macro
	or.l	#\1,d5
	or.w	#\2,d5
	or.w	#\2,d6
	pente	$4078

	or.l	#\1,d5
	or.w	#\2,d5
	or.l	#\1,d6
	pente	$404c

	or.l	#\1+\2,d6
	or.w	#\2,d5
	pente	$4026

	or.l	#\1+\2,d6
	or.l	#\1+\2,d5
	pente	$40fe

	or.l	#\1,d5
	or.l	#\1+\2,d6
	pente	$40d6

	or.l	#\1,d6
	or.l	#\1,d5
	pente	$40ae

	or.w	#\2,d6
	or.l	#\1,d5
	pente	$4088

	dcb.w	63,$4e71
	endm

;---------------------------------------------------------------;
point2	Macro
	or.l	#\1,d5
	or.w	#\2,d5
	or.w	#\2,d6
	pente2	$4070

	or.l	#\1,d5
	or.w	#\2,d5
	or.l	#\1,d6
	pente2	$4044

	or.l	#\1+\2,d6
	or.w	#\2,d5
	pente2	$401e

	or.l	#\1+\2,d6
	or.l	#\1+\2,d5
	pente2	$40f6

	or.l	#\1,d5
	or.l	#\1+\2,d6
	pente2	$40ce

	or.l	#\1,d6
	or.l	#\1,d5
	pente2	$40a6

	or.w	#\2,d6
	or.l	#\1,d5
	pente2	$4080

	dcb.w	63,$4e71
	Endm


;---------------------------------------------------------------;
	output	b:\3dmap.prg
	opt	d+,o-	PAS d'optimisation!

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	pile,a7

;---------------------------------------------------------------;
;	Construction des tables pour les trames	;
;---------------------------------------------------------------;

	lea	table_1a-320*4,a0
	lea	table_1b-320*4,a1
	lea	table_2a-320*4,a2
	lea	table_2b-320*4,a3
	lea	table_3a-320*4,a4
	lea	table_3b-320*4,a5
	move.l	#$aaaaffff,d1
	move.l	#$5555ffff,d2
	move.w	#26842,d5
	move.w	#960-1+3,d6

copie_tables	move.l	(a0)+,d3
	move.l	d3,d4
	and.l	d1,d3
	and.l	d2,d4
	add.w	d5,d3	pour aller en polyrout_1b
	move.l	d3,(a2)+
	move.l	d4,(a4)+

	move.l	(a1)+,d3
	move.l	d3,d4
	and.l	d1,d3
	and.l	d2,d4
	move.l	d3,(a3)+
	move.l	d4,(a5)+

	dbf	d6,copie_tables

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

	;clr.l	resume_adr
	;clr.b	resume_clear
	move.w	#12,nb_see_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,see_screen
	add.l	#32000,d0
	move.l	d0,see_screen+4
	add.l	#32000,d0
	move.l	d0,see_screen+8
	add.l	#32000,d0
	move.l	d0,see_screen+12

	lea	palette1,a0
	move.l	a0,see_pal
	move.l	a0,see_pal+4
	move.l	a0,see_pal+8
	move.l	a0,see_pal+12

;---------------------------------------------------------------;
;	Initialisations pour les ‚crans WORK	;
;---------------------------------------------------------------;

	move.w	#4-4,nb_work_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,work_screen
	add.l	#32000,d0
	move.l	d0,work_screen+4
	add.l	#32000,d0
	move.l	d0,work_screen+8
	add.l	#32000,d0
	move.l	d0,work_screen+12

;---------------------------------------------------------------;
;	Initialisations pour les ‚crans CLEAR	;
;---------------------------------------------------------------;

	move.w	#8-4,nb_clear_screen

	move.l	#ecran0+256,d0
	clr.b	d0
	move.l	d0,clear_screen
	add.l	#32000,d0
	move.l	d0,clear_screen+4
	add.l	#32000,d0
	move.l	d0,clear_screen+8
	add.l	#32000,d0
	move.l	d0,clear_screen+12

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
	cmp.w	#16,nb_work_screen
	blo.s	.ok
	clr.w	nb_work_screen
.ok	move.w	nb_work_screen,d0

	addq.w	#4,nb_clear_screen
	cmp.w	#16,nb_clear_screen
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

.no_init_minmax	bsr	clear_rout
	bsr	precalculs_3d
	bsr	rotation_points
	bsr	trace_3d

	addq.w	#5,otheta
	cmp.w	#360,otheta
	blo.s	.ok1
	clr.w	otheta

.ok1	addq.w	#1,ophi
	cmp.w	#360,ophi
	blo.s	.ok2
	clr.w	ophi

.ok2	addq.w	#2,ogamma
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

	lea	save,a0
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
grossi	add.w	#228,d5
	asr.l	#6,d3
	asr.l	#6,d4
	divs	d5,d3
	divs	d5,d4
	add.w	#160,d3
	add.w	#100,d4
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
	
next_poly	move.w	(a0)+,d7
	beq	one_map
	bmi	no_more_poly
	nop
no_more_poly	rts

one_map:	;subq.w	#1,d7

	move.l	d7,-(a7)
	move.w	2(a0),d5	point 1
	move.w	8(a0),d6	point 2
	move.w	14(a0),d7	point 3
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

	tst.l	d5
	bmi.s	trace_mapping

	move.w	(a0)+,d6
	add.w	d6,d6
	move.w	d6,d0
	add.w	d6,d6
	add.w	d0,d6
	add.w	d6,a0
	bra.s	next_poly

trace_mapping	;addq.l	#2,a0
	move.w	(a0)+,d7	nb points polygone mapping.

next_line_poly	lea	lines_poly,a2	On va recopier
	move.w	d7,d0	deux fois
	add.w	d0,d0	nos coordonnees
	add.w	d0,d0	x et y.
	add.w	d0,d0	-OUI-
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
	move.l	(a0),(a2)+	Pour le
	move.l	(a0)+,(a3)+	mapping.

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
	move.l	(a0),(a2)+	Pour le
	move.l	(a0)+,(a3)+	mapping.
	dbf	d7,copie_coords

	move.w	d4,mini_y
	move.w	d5,maxi_y
	sub.w	d4,d5	d4=mini y ; d5=hauteur
	move.w	d5,-(a7)

	lea	4(a4),a5	Coord. point du MAPPING

	lea	hauteur_and_y,a3

;---------------------------------------------------------------;
;	Delimitation droite polygone: (buffer1)	;
;---------------------------------------------------------------;

line_droite	moveq	#0,d6
	movem.w	(a4),d0/d1	x1,y1
	movem.w	8(a4),d2/d3	x2,y2
	lea	8(a4),a4
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
	move.w	d3,(a3)+	POUR MAPPING
	move.w	d1,(a3)+
	tst.w	d3
	beq	.si_if_ended
	move.w	d3,d6	decompte hauteur aprŠs.
	add.w	d1,d1
	lea	buffer1,a6
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

	move.w	(a7),d5

;---------------------------------------------------------------;
;	Delimitation gauche polygone: (buffer2)	;
;---------------------------------------------------------------;

line_gauche	moveq	#0,d6
	movem.w	(a4),d0/d1	x1,y1
	movem.w	8(a4),d2/d3	x2,y2
	lea	8(a4),a4
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
	move.w	d3,(a3)+
	move.w	d1,(a3)+
	tst.w	d3
	beq	.si_if_ended
	move.w	d3,d6	decompte hauteur aprŠs.
	add.w	d1,d1
	lea	buffer2,a6
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
;	Delimitation droite mapping: (buffer_1)	;
;	(d‚part coordonn‚es image map: a5)	;
;---------------------------------------------------------------;

	move.w	(a7),d5

	lea	fin_rout_droite,a4
	lea	hauteur_and_y,a3
	lea	table_mul,a6

line_map_droite	move.w	(a3)+,d1	;hauteur ligne polygone
	move.w	d1,d7
	add.w	#$140,d1
	add.w	d1,d1
	move.w	(a6,d1.w),d1	

	lea	buffer_1,a2
	move.w	(a3)+,d0	;depart y ligne polygone
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a2

	movem.w	(a5),d2/d3
	movem.w	8(a5),d0/d4
	lea	8(a5),a5
	sub.w	d2,d0
	sub.w	d3,d4
	muls	d1,d0
	muls	d1,d4
	add.l	d0,d0
	add.l	d4,d4
	swap	d0
	swap	d4
	move.w	d7,d6
	add.w	d6,d6
	add.w	d6,d6
	neg.w	d6
	move.w	d6,d1
	add.w	d6,d6
	add.w	d1,d6
	moveq	#0,d1
	move	#0,ccr
	jmp	(a4,d6.w)

	rept	400	ON EN A RAJOUT‚
	add.l	d0,d2
	addx.w	d1,d2
	move.w	d2,(a2)+
	add.l	d4,d3
	addx.w	d1,d3
	move.w	d3,(a2)+
	endr

fin_rout_droite	sub.w	d7,d5	;d5=hauteur totale polygone
	bgt	line_map_droite

;---------------------------------------------------------------;
;	Delimitation gauche mapping: (buffer_2)	;
;---------------------------------------------------------------;

	move.w	(a7),d5

	lea	fin_rout_gauche,a4

line_map_gauche	move.w	(a3)+,d1	;hauteur ligne polygone
	move.w	d1,d7
	add.w	#$140,d1
	add.w	d1,d1
	move.w	(a6,d1.w),d1	

	lea	buffer_2,a2
	move.w	(a3)+,d0	;depart y ligne polygone
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a2

	movem.w	(a5),d2/d3
	movem.w	8(a5),d0/d4
	lea	8(a5),a5
	sub.w	d0,d2
	sub.w	d4,d3
	muls	d1,d2
	muls	d1,d3
	add.l	d2,d2
	add.l	d3,d3
	swap	d2
	swap	d3
	move.w	d7,d6
	add.w	d6,d6
	add.w	d6,d6
	neg.w	d6
	move.w	d6,d1
	add.w	d6,d6
	add.w	d1,d6
	moveq	#0,d1
	move	#0,ccr
	jmp	(a4,d6.w)

	rept	400	ON EN A RAJOUT‚
	add.l	d2,d0
	addx.w	d1,d0
	move.w	d0,(a2)+
	add.l	d3,d4
	addx.w	d1,d4
	move.w	d4,(a2)+
	endr

fin_rout_gauche	sub.w	d7,d5	;d5=hauteur totale polygone
	bgt	line_map_gauche

;---------------------------------------------------------------;
;	Trac‚ de l'image incrust‚e sur le polygone	;
;---------------------------------------------------------------;

	move.w	(a7)+,d7	; hauteur totale
	subq.w	#1,d7

	movem.l	a0-a1,-(a7)
	move.w	mini_y,d0
	move.w	d0,d1

	lea	buffer1,a3
	add.w	d0,d0
	add.w	d0,a3
	lea	buffer_1,a5
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a5

	jsr	aff_poly	; question:<-CA marche ?
	movem.l	(a7)+,a0-a1

;---------------------------------------------------------------;
	bra	next_poly

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

clear_rout:	;tst.b	resume_clear
	;beq.s	new_clear
	;clr.b	resume_clear
	;bra	resume

new_clear	;st.b	resume_clear

	move.w	nb_clear_screen,d0
	and.w	#$fff8,d0	‚crans multiple de 8.
	add.w	d0,d0
	lea	max_min_screen,a0
	add.w	d0,a0
	movem.w	(a0),d3-d6   d3=minX 4=maxX d5=minY d6=maxY

	move.l	clear,a0

	move.w	d5,d0	d5=minimum_y
	bpl.s	.ok
	clr.w	d0
.ok	move.w	d6,d1	d6=maximum_y
	bmi	no_clearing
	cmp.w	#199,d1
	ble.s	.ok0
	move.w	#199,d1
.ok0	move.w	d1,d7
	mulu.w	#160,d1
	add.w	d1,a0

	sub.w	d0,d7	hauteur du carr‚ … vider
;	btst	#0,d7	hauteur impaire ?
;	beq.s	hauteur_paire	=> non.
;hauteur_impaire	lsr.w	#1,d7
;	move.w	d7,height_clearing
;	addq.w	#1,d7
;	bra.s	one_line_added
;hauteur_paire	lsr.w	#1,d7	hauteur/2
;	move.w	d7,height_clearing

one_line_added	move.w	d3,d0	d3=minimum_x
	bpl.s	.ok1
	clr.w	d0
.ok1	move.w	d4,d1	d4=maximum_x
	bmi	no_clearing
	cmp.w	#319,d1
	ble.s	.ok2
	move.w	#319,d1
.ok2	and.w	#-16,d0	arrondit multiple 16.
	and.w	#-16,d1	arrondit multiple 16
	lsr.w	#1,d0	=> multiple de 8
	lsr.w	#1,d1	=> multiple de 8
	addq.w	#8,d1           => arrondit d1 au SUPERIEUR

	add.w	d0,a0
	sub.w	d0,d1	largeur (multiple de 8)
	add.w	d1,a0	on ajoute la largeur.
	lsr.w	#1,d1	multiple de 8 => de 4.

	movem.w	clear_reg,d0/d2-d6/a1-a6

	move.w	d1,width_routine
	jmp	clearing(pc,d1.w)

clearing	bra	width_h0
	bra	width_h8
	bra	width_h10
	bra	width_h18
	bra	width_h20
	bra	width_h28
	bra	width_h30
	bra	width_h38
	bra	width_h40
	bra	width_h48
	bra	width_h50
	bra	width_h58
	bra	width_h60
	bra	width_h68
	bra	width_h70
	bra	width_h78
	bra	width_h80
	bra	width_h88
	bra	width_h90
	bra	width_h98
	bra	width_ha0

;resume	move.l	resume_adr,a0
;	move.w	height_clearing,d7
;	move.w	width_routine,d1
;	movem.w	clear_reg,d0/d2-d6/a1-a6
;	jmp	clearing(pc,d1.w)

width_h0	bra	end_clear_rout

width_h8	moveq	#0,d1
.cl	move.l	d0,-(a0)
	move.l	d0,-(a0)
	lea	-(160-2*4)(a0),a0
	dbf	d7,.cl	
	bra	end_clear_rout

width_h10	moveq	#0,d1
.cl	movem.l	d0-d3,-(a0)
	lea	-(160-4*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h18	moveq	#0,d1
.cl	movem.l	d0-d5,-(a0)
	lea	-(160-6*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h20	moveq	#0,d1
.cl	movem.l	d0-d6/a1,-(a0)
	lea	-(160-8*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h28	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a3,-(a0)
	lea	-(160-10*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h30	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a5,-(a0)
	lea	-(160-12*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h38	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	move.l	d0,-(a0)
	lea	-(160-14*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h40	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d2,-(a0)
	lea	-(160-16*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h48	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d4,-(a0)
	lea	-(160-18*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h50	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	lea	-(160-20*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h58	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a2,-(a0)
	lea	-(160-22*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h60	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a4,-(a0)
	lea	-(160-24*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h68	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	lea	-(160-26*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h70	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	move.l	d0,-(a0)
	move.l	d0,-(a0)
	lea	-(160-28*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h78	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d3,-(a0)
	lea	-(160-30*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h80	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d5,-(a0)
	lea	-(160-32*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h88	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1,-(a0)
	lea	-(160-34*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h90	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a3,-(a0)
	lea	-(160-36*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_h98	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a5,-(a0)
	lea	-(160-38*4)(a0),a0
	dbf	d7,.cl
	bra	end_clear_rout

width_ha0	moveq	#0,d1
.cl	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	move.l	d0,-(a0)
	dbf	d7,.cl

end_clear_rout	;move.l	a0,resume_adr
	rts



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
	
	sub.w	d5,d6

	move.w	d6,d2	hauteur dans d2
	subq.w	#1,d2
	bmi	fin_rout

	moveq	#0,d7
	move.w	d5,d7

	add.w	d5,d5	va servir un peu + loin!

	moveq	#0,d6
	move.w	couleur,d6	couleur: ...xxxxxXX
	and.w	#2,d6	XX=couleur r‚elle; x=trame
	add.l	work,d6
	lea	mul_160,a2
	add.w	d7,d7
	move.w	(a2,d7.w),d7
	add.l	d7,d6
	
	moveq	#-1,d7

	;lea	poly_lines,a6

	move.l	d6,a5
	move.w	d2,d6
	lea	-160(a5),a5

;---------------------------------------------------------------;
;	Buffer gauche, buffer droite ?		;
;---------------------------------------------------------------;

	;move.w	#$7,$ffff8240.w

	lea	buffer1,a2
	lea	buffer2,a3
	lea	pts_gauche,a4
	cmp.w	#2,nb_gauche
	bne.s	cont_test
	lea	pts_droite,a4
	exg	a2,a3
	cmp.w	#2,nb_droite
	bne	cont_test

special	addq.l	#2,a4
	move.w	(a4)+,d0
	add.w	d0,d0
	move.w	(a2,d0.w),d1
	cmp.w	(a3,d0.w),d1
	beq.s	special
	bgt.s	a2_sup_a3
a3_sup_a2
	lea	(a2,d5.w),a0
	lea	(a3,d5.w),a1
	bra	pas_change
a2_sup_a3
	lea	(a3,d5.w),a0
	lea	(a2,d5.w),a1
	bra	pas_change

cont_test	addq.l	#2,a4
	move.w	(a4)+,d0
	cmp.w	mini_y,d0
	beq.s	cont_test
	cmp.w	maxi_y,d0
	beq.s	cont_test
	add.w	d0,d0
	move.w	(a2,d0.w),d1
	cmp.w	(a3,d0.w),d1
	bgt.s	autre
	lea	(a2,d5.w),a0
	lea	(a3,d5.w),a1
	bra.s	pas_change
autre
	lea	(a3,d5.w),a0
	lea	(a2,d5.w),a1

pas_change	;move.w	#$0,$ffff8240.w

	add.w	d3,d3	  on indique
	lea	buffer1,a6	  dans les buffers
	move.w	#641*4,(a6,d3.w)  la fin du
	lea	buffer2,a6	  tracage du polygone
	move.w	#641*4,(a6,d3.w)  (ICI seulement)

	lea	polyrout_1a+32768,a3

	btst.b	#2,couleur+1
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
	lea	160(a5),a5
	move.l	(a6,d1.w),d1
	move.l	(a7,d0.w),d0
	add.w	d0,d1
	jmp	(a3,d1.w)

fill_polygone	moveq	#-4,d0
	and.w	(a0)+,d0
	moveq	#-4,d1
	and.w	(a1)+,d1
	lea	160(a5),a5
	move.l	(a2,d1.w),d1
	move.l	(a4,d0.w),d0
	add.w	d0,d1
	jmp	(a3,d1.w)
	rts

;---------------------------------------------------------------;
;	Routines de remplissage		;
;---------------------------------------------------------------;

polyrout_1a	incbin	routs_1a.bin
polyrout_1b	incbin	routs_1b.bin

;---------------------------------------------------------------;
;	Routines de delimitations du polygone	;
;---------------------------------------------------------------;

delim_hori	addq.w	#1,d3
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
	add.w	#400,d3
	move.w	d3,d4
	add.w	d4,d4
	lsl.w	#2,d3
	add.w	d4,d3
	add.l	d0,d0
	add.l	d0,d0
	move.w	d2,d4
	jmp	line1(pc,d3.w)

line1	rept	400
	add.w	d2,d4
	addx.w	d1,d0
	move.w	d0,(a6)+
	endr
	;move.w	d0,(a6)+
	rts

;---------------------------------------------------------------;

delim_vert	ext.l	d2
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
	add.w	#400,d3
	move.w	d3,d4
	add.w	d4,d4
	lsl.w	#2,d3
	add.w	d4,d3
	add.l	d0,d0
	add.l	d0,d0
	;move.w	d2,d4	;enlev‚=ligne plus belle?
	jmp	line2(pc,d3.w)

line2	rept	400
	add.w	d2,d4
	addx.w	d1,d0
	move.w	d0,(a6)+
	endr
	;move.w	d0,(a6)+
	rts

;---------------------------------------------------------------;
;	Affichage image-polygone		;
;---------------------------------------------------------------;

count_lines	dc.w	0

aff_poly:	moveq	#0,d6
	move.l	work,adr_ecr
	moveq	#0,d0
	move.w	mini_y,d0
	bpl.s	.ok
	move.w	d0,d4
	moveq	#0,d0
	neg.w	d4
	sub.w	d4,d7
	add.w	d4,d4
	add.w	d4,a3
	add.w	d4,d4
	add.w	d4,a5
.ok	move.w	d0,d4
	mulu.w	#160,d0
	add.l	d0,adr_ecr
	lea	picture,a2

	move.w	d4,d0
	add.w	d7,d0
	cmp.w	#199,d0
	bls.s	.ok2	
	sub.w	#199,d0
	sub.w	d0,d7	
.ok2	move.w	d7,count_lines
	pea	one_line(pc)
	bra	first_line

fin_trace_map	lea	4(a7),a7
	rts

sauve_a6	dc.l	0
;---------------------------------------------------------------;

one_line	or.l	d5,(a4)+
	or.l	d6,(a4)+
	pea	one_line(pc)

	move.l	sauve_a6,a6
	move.w	#$d288,d5	On restaure les ADD.L A0,D1
	move.w	d5,$e(a6)
	move.w	d5,$3a(a6)
	move.w	d5,$60(a6)
	move.w	d5,$88(a6)
	move.w	d5,$b0(a6)
	move.w	d5,$d8(a6)
	move.w	d5,$fe(a6)

first_line	subq.w	#1,count_lines
	bmi.s	fin_trace_map

	add.l	#160,adr_ecr
	move.l	adr_ecr,a4

	moveq	#4,d4
	neg.w	d4
	and.w	(a3)+,d4	    fin
	bgt.s	.okay1
	addq.l	#4,a5
	bra.s	first_line
.okay1	moveq	#4,d0
	neg.w	d0
	and.w	(1200*2-2)(a3),d0   debut
	cmp.w	#320*4,d0
	blt.s	.okay2
	addq.l	#4,a5
	bra.s	first_line
.okay2
	cmp.w	d0,d4
	blt.s	first_line
	
	lea	no_pixel,a6
	move.l	(a6,d4.w),a6	adresse pixel fin.
	move.w	#$4e75,d5	On met des RTS
	move.w	d5,$e(a6)
	move.w	d5,$3a(a6)
	move.w	d5,$60(a6)
	move.w	d5,$88(a6)
	move.w	d5,$b0(a6)
	move.w	d5,$d8(a6)
	move.w	d5,$fe(a6)
	move.l	a6,sauve_a6
	
	lea	dec_ecran,a6
	add.w	2(a6,d0.w),a4
	lea	masque,a6
	move.l	(a6,d0.w),d7	

	lea	no_pixel,a6
	move.l	(a6,d0.w),a6	adresse pixel debut.

			;!=>chang‚ qq de place ICI

	sub.w	d0,d4

	lsr.w	#1,d4
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d5

	move.w	(a5)+,d5
	move.w	$7ce(a5),d1
	sub.w	d1,d5
	muls	table_mul2(pc,d4.l),d5
	add.l	d5,d5
	move.w	(a5)+,d3
	move.w	$7ce(a5),d2
	sub.w	d2,d3
	muls	table_mul2(pc,d4.l),d3
	add.l	d3,d3
	swap	d5
	swap	d3
	move.l	d5,a0
	move.l	d3,a1

	moveq	#0,d0
	moveq	#0,d3
	move.l	(a4),d5
	move.l	4(a4),d6
	and.l	d7,d5
	and.l	d7,d6
	move.w	#$100,d4

	cmp.l	#mapping_rout,a6
	bhs.s	dans_ecran
	jmp	(a6)
dans_ecran	lea	-$100(a6),a6
	add.w	#128,d2
	move.w	d2,d3	move.w	d2,d7
	move.b	d1,d3	move.w	d4,d7
	move.b	(a2,d3.l),d4
	jmp	(a6,d4.w)

table_mul2	incbin	tblmul2.bin

	rept	100
	add.l	a0,d1
	addx.w	d0,d1
	add.l	a1,d2
	addx.w	d0,d2
	endr
mapping_rout	rept	20
	point	$80000000,$8000
	point	$40000000,$4000
	point	$20000000,$2000
	point	$10000000,$1000
	point	$8000000,$800
	point	$4000000,$400
	point	$2000000,$200
	point	$1000000,$100
	point	$800000,$80
	point	$400000,$40
	point	$200000,$20
	point	$100000,$10
	point	$80000,$8
	point	$40000,$4
	point	$20000,$2
	point2	$10000,$1
	endr

;---------------------------------------------------------------;
	even
	rept	100
	dc.l	$ffffffff
	endr
masque	rept	20
	dc.l	$00000000,$80008000,$c000c000,$e000e000
	dc.l	$f000f000,$f800f800,$fc00fc00,$fe00fe00
	dc.l	$ff00ff00,$ff80ff80,$ffc0ffc0,$ffe0ffe0
	dc.l	$fff0fff0,$fff8fff8,$fffcfffc,$fffefffe
	endr

x	set	100
	rept	100
	dc.l	mapping_rout-x*8
x	set	x-1
	endr
no_pixel
x	set	0
	rept	320
	dc.l	mapping_rout+x*408
x	set	x+1
	endr
lastpix	rept	100
	dc.l	mapping_rout+319*408
	endr

	dcb.l	100,0
dec_ecran
x	set	0
	rept	20
	dcb.l	16,x
x	set	x+8
	endr

table_mul	incbin	tblmul1.bin
picture	incbin	ska2_2.bin

numero_pts	dc.w	4,12,8,4,0,1
;coord_2d	dc.w	$0,$0,$a00,$10,$a00-8*20,175,8*20,198
coord_pic	dc.w	0,0,$0,$7f00,$7f,$7f00,$7f,0

gauche
x	set	0
	rept	20
	dc.l	$ffffffff,x,$7fff7fff,x,$3fff3fff,x
	dc.l	$1fff1fff,x,$0fff0fff,x,$07ff07ff,x
	dc.l	$03ff03ff,x,$01ff01ff,x,$00ff00ff,x
	dc.l	$007f007f,x,$003f003f,x,$001f001f,x
	dc.l	$000f000f,x,$00070007,x,$00030003,x
	dc.l	$00010001,x
x	set	x+$80000
	endr

droite
x	set	0
	rept	20
	dc.l	$80008000,x,$c000c000,x,$e000e000,x
	dc.l	$f000f000,x,$f800f800,x,$fc00fc00,x
	dc.l	$fe00fe00,x,$ff00ff00,x,$ff80ff80,x
	dc.l	$ffc0ffc0,x,$ffe0ffe0,x,$fff0fff0,x
	dc.l	$fff8fff8,x,$fffcfffc,x,$fffefffe,x
	dc.l	$ffffffff,x
x	set	x+$80000
	endr

;---------------------------------------------------------------;
;	Routine d'interruption VBL		;
;   Adresse ‚cran incr‚ment‚e … chaque VBL + installe palette	;
;---------------------------------------------------------------;

vbl:	movem.l	d0-d7/a0,save_registers

	move.w	nb_see_screen,nb_see_old

	addq.w	#4,nb_see_screen
	cmp.w	#16,nb_see_screen
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

w	set	0

otheta	dc.w	0
ophi	dc.w	0
ogamma	dc.w	0

k	set	15	AUGMENTE CA

ocoordsx	dc.w	-5*k,-5*k,5*k,5*k
	dc.w	-5*k,-5*k,5*k,5*k

ocoordsy	dc.w	-5*k,5*k,5*k,-5*k
	dc.w	-5*k,5*k,5*k,-5*k

ocoordsz	dc.w	-5*k,-5*k,-5*k,-5*k
	dc.w	5*k,5*k,5*k,5*k

nb_point	dc.w	8

clear_reg	dcb.l	16,0

palette1	dc.w	0,$333,$444,$666,$777
	dcb.w	10,$777
	dc.w	$777

;---------------------------------------------------------------;
;	Concernant les Polygones		;
;---------------------------------------------------------------;
	even
polygone:	;dc.w	4	nb de sommets
	;dc.w	12	a ajouter
	;dc.w	0	couleur (0 ou 2)
	;dc.w	0,1,2,3,0	No de lignes.

	dc.w	0
	dc.w	4,2,$0000,$7f00,1,$0000,$0000,0,$007f,$0000,3,$007f,$7f00	;1=bidon
	dc.w	0
	dc.w	4,3,$0000,$7f00,0,$0000,$0000,4,$007f,$0000,7,$007f,$7f00
	dc.w	0
	dc.w	4,7,$0000,$7f00,4,$0000,$0000,5,$007f,$0000,6,$007f,$7f00
	dc.w	0
	dc.w	4,6,$0000,$7f00,5,$0000,$0000,1,$007f,$0000,2,$007f,$7f00
	dc.w	0
	dc.w	4,1,$0000,$7f00,5,$0000,$0000,4,$007f,$0000,0,$007f,$7f00
	dc.w	0
	dc.w	4,6,$0000,$7f00,2,$0000,$0000,3,$007f,$0000,7,$007f,$7f00

	dc.w	-1

	dc.w	4,12,2+4,13,2,3,14,13
	dc.w	4,12,0+4,3,4,15,14,3
	dc.w	4,12,2+4,5,16,15,4,5
	dc.w	4,12,2+4,0,11,16,5,0
	dc.w	4,12,0+4,0,1,12,11,0
	dc.w	4,12,2+4,12,1,2,13,12
	dc.w	4,12,2+4,6,17,13,2,6
	dc.w	4,12,0+4,6,7,18,17,6
	dc.w	4,12,2+4,18,7,8,19,18
	dc.w	4,12,2+4,19,8,9,20,19
	dc.w	4,12,0+4,9,10,21,20,9
	dc.w	4,12,2+4,2,13,21,10,2

	dc.w	4,12,0,1,0,5,2,1
	dc.w	4,12,0,2,5,4,3,2
	dc.w	4,12,0,7,6,2,8,7
	dc.w	4,12,0,8,2,10,9,8

	dc.w	4,12,0,11,12,13,16,11
	dc.w	4,12,0,16,13,14,15,16
	dc.w	4,12,0,17,18,19,13,17
	dc.w	4,12,0,13,19,20,21,13

	dc.w	-1

;---------------------------------------------------------------;
;	Table buffer gauche		;
;	(on retire 32768 seulement l…)		;
;---------------------------------------------------------------;

	rept	320
	dc.w	$ffff,-32768
	endr

table_1a	incbin	table_1a.bin

	rept	320
	dc.w	0,-$9a4-32768
	endr
	dc.w	0,26832-32768
	dc.w	0,26832-32768
	dc.w	0,26832-32768

;---------------------------------------------------------------;
;	Table buffer droit		;
;---------------------------------------------------------------;

	rept	320
	dc.w	$ffff,0	largeur=21 mots (only DBF)
	endr

table_1b	incbin	table_1b.bin

	rept	320
	dc.w	$ffff,$9a4
	endr
	dc.w	0,0
	dc.w	0,0
	dc.w	0,0

;---------------------------------------------------------------;
;	Table de multipilcation par 160		;
;---------------------------------------------------------------;

mul_160
x	set	0
	rept	250
	dc.w	x
x	set	x+160
	endr

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
;	Pour les tables (buffers gauche et droit)	;
;---------------------------------------------------------------;

	ds.l	320
table_2a	ds.l	640+3
	ds.l	320
table_2b	ds.l	640+3
	ds.l	320
table_3a	ds.l	640+3
	ds.l	320
table_3b	ds.l	640+3

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

nb_gauche	ds.w	1
nb_droite	ds.w	1
pts_gauche	ds.w	100
pts_droite	ds.w	100

	ds.w	400
buffer1	ds.w	800
	ds.w	400
buffer2	ds.w	800

ecran0	ds.l	8000+64
ecran1	ds.l	8000
ecran2	ds.l	8000
ecran3	ds.l	8000

adr_ecr	ds.l	1
sauve_d7	ds.w	1

lines_poly	ds.l	50
hauteur_and_y	ds.l	50

buf	ds.w	100

buffer_1	ds.b	$7d0
buffer_2	ds.b	$7d0
buffer_3	ds.b	$7d0
buffer_4	ds.b	$7d0
