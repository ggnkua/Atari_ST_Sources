	DATA

; ---------------------------------------------------------------------
; -------------	Macro de mapping
; -------------	ecran,image,coords ecran,coords image,nb de points
; ---------------------------------------------------------------------

MAPPING	MACRO	ecran,image,c_ecr,c_img,nb
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	\1,a0
	move.l	\2,a1
	move.l	\3,a2
	move.l	\4,a3
	move	\5,d0

; -------------	Routine de mapping
;	a0 ecran
;	a1 image
;	a2 polygone
;	a3 mapping
;	d0 nb de points du polygone

; -------------	Parcours le polygone

	move	#resy-1,ypmin
	clr	ypmax

	move	d0,d1
	subq	#1,d1
mapping_poly2	movem.l	d0-d1,-(sp)
	movem.l	(a2),d2-d5	; pour le polygone
	movem.l	(a3),d0-d1/d6-d7 ; et pour le mapping
	bsr	map_poly
	movem.l	(sp)+,d0-d1
	addq	#8,a2
	addq	#8,a3
	dbra	d1,mapping_poly2

; -------------	Trace le polygone mapp‚

	move	ypmin,d0
	mulu	#resx*2,d0
	add.l	d0,a0	; affichage
	move	ypmax,d0
	move	ypmin,d1
	sub	d1,d0
	bmi	mapping_fin
	lea	(xpmin.l,d1.w*4),a2
	lea	(xpmax.l,d1.w*4),a3
mapping_ligne	
	move.l	(a3)+,d7
	move.l	(a2)+,d2
	sub.l	d2,d7
	bmi	mapping_finligne
	swap	d2
	swap	d7
	move.l	d7,d5
	lea	(a0,d2.w*2),a4
	move.l	#1<<16,d3
	divs	d5,d3
	move	d3,d5

	; DX = (xmax-xmin)/dx

	move.l	(xmmax.l,d1.w*4),d4
	sub.l	(xmmin.l,d1.w*4),d4
	swap	d4
	muls	d3,d4
	move.l	d4,a5	; d3 coef x

	move	(xmmin.l,d1.w*4),d4 ; d4 x

	; DY = (ymax-ymin)/dx
	
	move.l	(ymmax.l,d1.w*4),d6
	sub.l	(ymmin.l,d1.w*4),d6
	swap	d6
	muls	d5,d6
	move.l	d6,d5	; d5 coef y
	lsr.l	#8,d5
	move	d5,a6

	move	(ymmin.l,d1.w*4),d6 ; d6 y
	asl	#8,d6

	move.l	a5,d5
	swap	d5
	moveq	#0,d2
	moveq	#0,d3
mapping_colonne
	move	d6,d3	; d6 -> index
	move.b	d4,d3	; d4 -> index
	
	move	(a1,d3.l*2),(a4)+

	add	a5,d2	
	addx	d5,d4
	add	a6,d6
	dbra	d7,mapping_colonne
mapping_finligne
	addq	#1,d1
	lea	resx*2(a0),a0
	dbra	d0,mapping_ligne
mapping_fin	bra	mapping_realfin
	
; -------------	Trace des lignes
;	a4,a5,a6 libres
;	d6,d7 libres
;	d2,d3 x1,y1 d4,d5 x2,y2

map_poly	
	lea	xpmax,a4
	lea	xmmax,a5
	lea	ymmax,a6
	cmp	d3,d5
	bpl.s	y2plusgrand
	lea	xpmin,a4
	lea	xmmin,a5
	lea	ymmin,a6
	exg	d2,d4
	exg	d3,d5
	exg	d0,d6
	exg	d1,d7
y2plusgrand
	cmp	ypmin,d3
	bpl.s	yminpluspetit
	move	d3,ypmin
yminpluspetit	cmp	ypmax,d5
	bmi.s	ymaxplusgrand
	move	d5,ypmax
ymaxplusgrand
	swap	d2
	swap	d4

	sub	d3,d5	; = |dy|
	beq.s	horizontale

	lea	(a4,d3.w*4),a4	; polygone
	lea	(a5,d3.w*4),a5	; table x mapping
	lea	(a6,d3.w*4),a6	; table y mapping

	sub.l	d2,d4	; d4=x2-x1
	divs.l	d5,d4	; d4=(x2-x1)/dy*256

	sub.l	d0,d6
	divs.l	d5,d6	; d6 coef x

	sub.l	d1,d7
	divs.l	d5,d7	; d7 = coef y
diagonale_bcl
	move.l	d2,(a4)+
	add.l	d4,d2
	move.l	d0,(a5)+
	add.l	d6,d0
	move.l	d1,(a6)+
	add.l	d7,d1
	dbra	d5,diagonale_bcl
	rts

horizontale	cmp.l	d2,d4
	bpl.s	x2plusgrand
	exg.l	d2,d4
	exg.l	d0,d6
	exg.l	d1,d7
x2plusgrand	move.l	d2,(xpmin.l,d3.w*4)
	move.l	d4,(xpmax.l,d3.w*4)
	move.l	d0,(xmmin.l,d3.w*4)
	move.l	d1,(ymmin.l,d3.w*4)
	move.l	d6,(xmmax.l,d3.w*4)
	move.l	d7,(ymmax.l,d3.w*4)
	rts

; -------------	Fin du mapping

mapping_realfin	movem.l	(sp)+,d0-d7/a0-a6
	ENDM

; ---------------------------------------------------------------------
;	Gouraud shading
; ---------------------------------------------------------------------

GOURAUD	MACRO	ecran,palette,c_ecr,c_pal,nb
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	\1,a0
	move.l	\2,a1
	move.l	\3,a2
	move.l	\4,a3
	move	\5,d0

;	a0 ecran
;	a1 palette
;	a2 polygone
;	a3 couleurs
;	d0 nb de points du polygone

; -------------	Parcours le polygone

	move	#resy-1,ypmin
	clr	ypmax

	move	d0,d1
	subq	#1,d1
gouraud_poly2	movem.l	(a2),d2-d5	; pour le polygone
	movem.l	(a3),d6-d7	; et pour le gouraud
	bsr	gouraud_poly
	addq	#8,a2
	addq	#4,a3
	dbra	d1,gouraud_poly2

; -------------	Trace le polygone mapp‚

	move	ypmin,d0
	mulu	#resx*2,d0
	add.l	d0,a0	; affichage
	move	ypmax,d0
	move	ypmin,d1
	sub	d1,d0
	bmi	gouraud_fin
	lea	(xpmin.l,d1.w*4),a2
	lea	(xpmax.l,d1.w*4),a3
	lea	(xgmin.l,d1.w*4),a5
	lea	(xgmax.l,d1.w*4),a6
gouraud_ligne	
	move.l	(a3)+,d7
	move.l	(a2)+,d2
	sub.l	d2,d7
	bmi	gouraud_finligne
	swap	d2	; point de depart
	swap	d7	; dx
	move	d7,d6
	ext.l	d6
	lea	(a0,d2.w*2),a4

	move.l	(a6)+,d5	; d5 = couleurs
	sub.l	(a5)+,d5
	divs.l	d6,d5
	swap	d5	; d5 = coef x

	moveq	#0,d4
	move.b	-4+1(a5),d4 ; d4 x
	;and	#255,d4
gouraud_colonne
	move	(a1,d4.w*2),(a4)+
	addx.l	d5,d4
	dbra	d7,gouraud_colonne
gouraud_finligne
	lea	resx*2(a0),a0
	dbra	d0,gouraud_ligne
gouraud_fin	bra	gouraud_realfin
	
; -------------	Trace des lignes
;	a4,a5,a6 libres
;	d6,d7 libres
;	d2,d3 x1,y1 d4,d5 x2,y2

gouraud_poly	
	lea	xpmax,a4
	lea	xgmax,a5
	cmp	d3,d5
	bpl.s	gou_y2plusgrand
	lea	xpmin,a4
	lea	xgmin,a5
	exg	d2,d4
	exg	d3,d5
	exg	d6,d7
gou_y2plusgrand
	cmp	ypmin,d3
	bpl.s	gou_yminpluspetit
	move	d3,ypmin
gou_yminpluspetit
	cmp	ypmax,d5
	bmi.s	gou_ymaxplusgrand
	move	d5,ypmax
gou_ymaxplusgrand
	swap	d2
	swap	d4

	sub	d3,d5	; = |dy|
	beq.s	gou_horizontale

	lea	(a4,d3.w*4),a4	; polygone
	lea	(a5,d3.w*4),a5	; table gouraud

	sub.l	d2,d4	; d4 = x2-x1
	divs.l	d5,d4	; d4 = dx/dy

	sub.l	d6,d7
	divs.l	d5,d7	; d7 coef gouraud
gou_diagonale_bcl
	move.l	d2,(a4)+
	add.l	d4,d2
	move.l	d6,(a5)+
	add.l	d7,d6
	dbra	d5,gou_diagonale_bcl
	rts

gou_horizontale	cmp.l	d2,d4
	bpl.s	gou_x2plusgrand
	exg.l	d2,d4
	exg.l	d6,d7
gou_x2plusgrand	move.l	d2,(xpmin.l,d3.w*4)
	move.l	d4,(xpmax.l,d3.w*4)
	move.l	d6,(xgmin.l,d3.w*4)
	move.l	d7,(xgmax.l,d3.w*4)
	rts

; -------------	Fin du gouraud

gouraud_realfin	movem.l	(sp)+,d0-d7/a0-a6
	ENDM

; ---------------------------------------------------------------------
;	Zbuffer + Gouraud shading
; ---------------------------------------------------------------------

ZBUFFER_INIT	MACRO
	movem.l	d0-d2/a0,-(sp)
	lea	zbuffer,a0
	move	#0,d2
	move	#resy-1,d1
zbuf_y	move	#resx-1,d0
zbuf_x	move	d2,(a0)+
	dbra	d0,zbuf_x
	dbra	d1,zbuf_y
	movem.l	(sp)+,d0-d2/a0
	ENDM

ZGOURAUD	MACRO	ecran,palette,c_ecr,c_pal,nb
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	\1,a0
	move.l	\2,a1
	move.l	\3,a2
	move.l	\4,a3
	move	\5,d0

;	a0 ecran
;	a1 palette
;	a2 polygone
;	a3 couleurs
;	d0 nb de points du polygone

; -------------	Parcours le polygone

	move	#resy-1,ypmin
	clr	ypmax

	move	d0,d1
	subq	#1,d1
zgouraud_poly2	movem.l	(a2),d2-d5	; pour le polygone
	movem.l	(a3),d6-d7	; et pour le gouraud
	bsr	zgouraud_poly
	addq	#8,a2
	addq	#4,a3
	dbra	d1,zgouraud_poly2

; -------------	Trace le polygone mapp‚

	move	ypmin,d0
	mulu	#resx*2,d0
	add.l	d0,a0	; affichage
	lea	(zbuffer.l,d0.l),a6
	move	ypmax,d0
	move	ypmin,d1
	sub	d1,d0
	bmi	zgouraud_fin
	
	lea	(xpmin.l,d1.w*4),a2
	lea	(xpmax.l,d1.w*4),a3
zgouraud_ligne	
	move.l	a6,-(sp)
	move.l	(a3)+,d7
	move.l	(a2)+,d2
	sub.l	d2,d7
	bmi	zgouraud_finligne
	swap	d2
	swap	d7
	move	d7,d6
	ext.l	d6
	lea	(a0,d2.w*2),a4
	lea	(a6,d2.w*2),a6

	; DX = (xmax-xmin)/dx

	move.l	(xgmax.l,d1.w*4),d5
	sub.l	(xgmin.l,d1.w*4),d5
	divs.l	d6,d5
	move	d5,a5	; a5 coef x
	swap	d5

	move	(xgmin.l,d1.w*4),d4 ; d4 x
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d6
zgouraud_colonne
	move.b	d4,d3
	cmp	(a6)+,d3
	bmi	z_affiche
	move	d3,-2(a6)
	move	(a1,d3.w*2),(a4)
z_affiche	
	add	a5,d2	
	addx	d5,d4
	addq	#2,a4
	dbra	d7,zgouraud_colonne
zgouraud_finligne
	addq	#1,d1
	lea	resx*2(a0),a0
	move.l	(sp)+,a6
	lea	resx*2(a6),a6
	dbra	d0,zgouraud_ligne
zgouraud_fin	bra	zgouraud_realfin
	
; -------------	Trace des lignes
;	a4,a5,a6 libres
;	d6,d7 libres
;	d2,d3 x1,y1 d4,d5 x2,y2

zgouraud_poly	
	lea	xpmax,a4
	lea	xgmax,a5
	cmp	d3,d5
	bpl.s	zgou_y2plusgrand
	lea	xpmin,a4
	lea	xgmin,a5
	exg	d2,d4
	exg	d3,d5
	exg	d6,d7
zgou_y2plusgrand
	cmp	ypmin,d3
	bpl.s	zgou_yminpluspetit
	move	d3,ypmin
zgou_yminpluspetit
	cmp	ypmax,d5
	bmi.s	zgou_ymaxplusgrand
	move	d5,ypmax
zgou_ymaxplusgrand
	swap	d2
	swap	d4

	sub	d3,d5	; = |dy|
	beq.s	zgou_horizontale

	lea	(a4,d3.w*4),a4	; polygone
	lea	(a5,d3.w*4),a5	; table gouraud

	sub.l	d2,d4	; = dx
	divs.l	d5,d4

	sub.l	d6,d7
	divs.l	d5,d7	; d7 coef gouraud
zgou_diagonale_bcl
	move.l	d2,(a4)+
	add.l	d4,d2
	move.l	d6,(a5)+
	add.l	d7,d6
	dbra	d5,zgou_diagonale_bcl
	rts

zgou_horizontale
	cmp.l	d2,d4
	bpl.s	zgou_x2plusgrand
	exg.l	d2,d4
	exg.l	d6,d7
zgou_x2plusgrand
	move.l	d2,(xpmin.l,d3.w*4)
	move.l	d4,(xpmax.l,d3.w*4)
	move.l	d6,(xgmin.l,d3.w*4)
	move.l	d7,(xgmax.l,d3.w*4)
	rts

; -------------	Fin du gouraud

zgouraud_realfin	movem.l	(sp)+,d0-d7/a0-a6
	ENDM


	BSS

ypmin	ds.l	1	; polygone
ypmax	ds.l	1
xpmin	ds.l	resy
xpmax	ds.l	resy

xmmin	ds.l	resy	; mapping
ymmin	ds.l	resy
xmmax	ds.l	resy
ymmax	ds.l	resy

xgmin	ds.l	resy	; gouraud
xgmax	ds.l	resy

zbuffer	ds.w	resx*resy	; zbuffer