;---------------------------------------------------------------;
;	3D Surfaces pleines		;
;	ska - 1992!			;
;	V1.2: plus de pb pour les polygones plats	;
;	V2.0: choix des buffers: OK		;
;	      (encore quelques problŠmes)	;
;	V2.1: nouvelle routine de choix des buffers	;
;	      gauche et droit. Mais Bug a un moment	;
;		(17vbl apres w=74)	;
;	V2.2: plus de bug choix des buffers!	;
;	V2.3: routine de polygone encore plus optimis‚e!;
;	V2.4: trames			;
;	V2.5: boucle indep. VBL/trace polygones (8 ecr.);
;	V2.6: zone vidage d'‚cran calcul‚e: Ok!	;
;	V2.7: plus de reloc pour routines polygone	;
;           Reste … faire:			;
;	-rajouter routines polygones de couleur 3	;
;	 (pour cela reconstruire tables et routines)	;
;	-faire attendre la VBL sur le tracage des	;
;	 objets pour ceux qui sont en plusieurs VBLs.	;
;---------------------------------------------------------------;

	output	c:\cube.prg
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

.no_init_minmax	bsr	clear_rout
	bsr	precalculs_3d
	bsr	rotation_points
	bsr	trace_3d

	addq.w	#2,otheta
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
grossi	add.w	#157,d5
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
	bmi	no_more_poly

	subq.w	#1,d7

	bsr	hidden_face
	tst.l	d5
	bmi.s	trace_polygone

	move.w	(a0)+,d6
	add.w	d6,a0
	bra.s	next_poly

trace_polygone	addq.l	#2,a0
	move.w	(a0)+,couleur
	move.w	#-200,d6
	move.w	#400,d5

	lea	pts_gauche,a2
	lea	pts_droite,a3
	clr.w	nb_droite
	clr.w	nb_gauche

next_line	move.w	(a0)+,d0
	move.w	(a0)+,d2
	add.w	d0,d0
	add.w	d0,d0
	add.w	d2,d2
	add.w	d2,d2
	move.w	2(a1,d0.w),d1
	move.w	(a1,d0.w),d0
	move.w	2(a1,d2.w),d3
	move.w	(a1,d2.w),d2

	subq.l	#2,a0

	movem.l	d7/a0-a1,-(a7)
	jsr	poly
	movem.l	(a7)+,d7/a0-a1

	dbf	d7,next_line
	addq.l	#2,a0

	moveq	#-1,d7
	move.l	d7,(a2)	d7=-1 !
	move.l	d7,(a3)

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
	;add.l	#300,d5	il faut l'enlever
	move.l	(a7)+,d7
no_clearing	rts

;---------------------------------------------------------------;
;	Routine de vidage d'ecran		;
;---------------------------------------------------------------;

clear_rout:	tst.b	resume_clear
	beq.s	new_clear
	clr.b	resume_clear
	bra	resume

new_clear	st.b	resume_clear

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
	btst	#0,d7	hauteur impaire ?
	beq.s	hauteur_paire	=> non.
hauteur_impaire	lsr.w	#1,d7
	move.w	d7,height_clearing
	addq.w	#1,d7
	bra.s	one_line_added
hauteur_paire	lsr.w	#1,d7	hauteur/2
	move.w	d7,height_clearing

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

resume	move.l	resume_adr,a0
	move.w	height_clearing,d7
	move.w	width_routine,d1
	movem.w	clear_reg,d0/d2-d6/a1-a6
	jmp	clearing(pc,d1.w)

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

end_clear_rout	move.l	a0,resume_adr
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

delim_hori	;sub.w	d1,d3

	sub.w	d0,d2

	addq.w	#1,d3
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

delim_vert	;sub.w	d1,d3	plutot vertical
	sub.w	d0,d2
	ext.l	d2
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

k	set	5

ocoordsx	dc.w	-10*k,-10*k,10*k,10*k
	dc.w	-10*k,10*k
	dc.w	-10*k,10*k

ocoordsy	dc.w	-10*k,10*k,10*k,-10*k
	dc.w	-10*k,-10*k
	dc.w	10*k,10*k

ocoordsz	dc.w	10*k,10*k,10*k,10*k
	dc.w	-10*k,-10*k
	dc.w	-10*k,-10*k

nb_point	dc.w	8

clear_reg	dcb.l	16,0

palette1	dc.w	$000,$444,$700,$444,$000,$444,$700,$444,$000,$444,$700,$444,$000,$444,$700,$444
palette2	dc.w	$000,$000,$000,$000,$444,$444,$444,$444,$700,$700,$700,$700,$444,$444,$444,$444

;---------------------------------------------------------------;
;	Concernant les Polygones		;
;---------------------------------------------------------------;
	even
polygone:	dc.w	4	nb de sommets
	dc.w	12	a ajouter
	dc.w	0	couleur (0 ou 2)
	dc.w	0,1,2,3,0	No de lignes.

	dc.w	4
	dc.w	12
	dc.w	2+4
	dc.w	4,0,3,5,4

	dc.w	4
	dc.w	12
	dc.w	0	(+4=trame)
	dc.w	6,4,5,7,6

	dc.w	4
	dc.w	12
	dc.w	2+4
	dc.w	1,6,7,2,1

	dc.w	4
	dc.w	12
	dc.w	0+4
	dc.w	3,2,7,5,3

	dc.w	4
	dc.w	12
	dc.w	2
	dc.w	4,6,1,0,4

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
buffer1	ds.w	3000
	ds.w	400
buffer2	ds.w	3000

ecran0	ds.l	8000+64
ecran1	ds.l	8000
ecran2	ds.l	8000
ecran3	ds.l	8000
