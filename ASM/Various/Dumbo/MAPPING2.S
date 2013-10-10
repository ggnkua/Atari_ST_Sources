******************************************************************************
*	Programme de mapping d'une face verticale			*
*	M‚thode par interpolation lin‚aire			*
******************************************************************************



*÷÷÷ Constantes ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

_LWIDTH:		Equ	640	; Ecran de 320 pixels en Hi-color
_LNBR:		Equ	200	; et de 200 lignes
_SIZEX:		Equ	320	; Largeur de la fenˆtre (multiple de 8)
_SIZEY:		Equ	200	; Hauteur de la fenˆtre

;--- Structures des variables de mapping vertical ----------------------------
		RsReset
vmap_point_xa:	Rs.w	1	; Coordonn‚es planes du point A
vmap_point_ya:	Rs.w	1
vmap_point_za:	Rs.w	1	; Plus son Z pour le Z-buffer
vmap_point_xb:	Rs.w	1	; Idem pour B
vmap_point_yb:	Rs.w	1
vmap_point_zb:	Rs.w	1
vmap_point_yc:	Rs.w	1	; Ordonn‚e de C (X et Z pareils que pour B)
vmap_point_yd:	Rs.w	1	; Ordonn‚e de D (X et Z pareils que pour A)
vmap_spradr:	Rs.l	1	; Adresse du sprite … mapper
vmap_sprsx:	Rs.w	1	; Largeur du sprite
vmap_sprsy:	Rs.w	1	; Hauteur du sprite
vmap_xinc:		Rs.l	1
vmap_zinc:		Rs.l	1
vmap_yintinc:	Rs.l	1
vmap_yfracinc:	Rs.w	1
vmap_end:		Rs	1



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Text

;-----------------------------------------------------------------------------
;	Mapping d'une face verticale
;	Fournir les coordonn‚es planes des points
;-----------------------------------------------------------------------------
vertical_mapping:

;--- Teste si le polygone est bien dans la fenˆtre ---------------------------
	lea	vmap_var(pc),a0	; a0 pointe sur les variables de mapping

	move.w	vmap_point_xa(a0),d0	; d0 = xA
	move.w	vmap_point_xb(a0),d2	; d2 = xB

	moveq	#0,d0
	moveq	#0,d2
	cmp.w	#_sizex/2,d0	; Fin si xA ò sx/2
	bge	vertical_mapping_end
	cmp.w	#-_sizex/2,d2	; Fin si xB ó -sx/2
	ble	vertical_mapping_end
	sub.w	d0,d2		; d2 = largeur … mapper
	beq	vertical_mapping_end	; Pas d'affichage si une seule colonne

	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	vmap_point_ya(a0),d1	; d1 = yA
	move.w	vmap_point_yb(a0),d3	; d3 = yB
	move.w	vmap_point_yc(a0),d4	; d4 = yC
	move.w	vmap_point_yc(a0),d5	; d5 = yD

	cmp.w	#_sizey/2,d1	; Fin si yA ò sy/2
	bge	vertical_mapping_end
	cmp.w	#_sizey/2,d3	; Fin si yB ò sy/2
	bge	vertical_mapping_end
	cmp.w	#-_sizey/2,d4	; Fin si yC ó -sy/2
	ble	vertical_mapping_end
	cmp.w	#-_sizey/2,d5	; Fin si yD ó -sy/2
	ble	vertical_mapping_end
	sub.w	d3,d4		; d4 = yC - yB
	sub.w	d1,d5		; d5 = yD - yA
	sub.w	d3,d1		; d3 = yB - yA

;--- Calcul de l'incr‚ment en X ----------------------------------------------
	moveq	#0,d6
	move.w	vmap_sprsx(a0),d6	; Largeur du sprite
	swap	d6
	divu.l	d2,d6
	swap	d6		; Incr‚ment X invers‚
	move.l	d6,vmap_xinc(a0)

;--- Calcul de l'incr‚ment en Z ----------------------------------------------
	moveq	#0,d6
	move.w	vmap_point_zb(a0),d6
	sub.w	vmap_point_za(a0),d6	; Profondeur du mapping
	swap	d6
	divs.l	d2,d6
	swap	d6		; Incr‚ment Z invers‚
	move.l	d6,vmap_zinc(a0)

;--- Calul de l'incr‚ment en Y d'affichage -----------------------------------
	swap	d3
	divs.l	d2,d3
	move.w	d3,vmap_yfracinc(a0)	; Incr‚ment Y, partie fractionnaire
	swap	d3
	muls.w	#_LWIDTH,d3
	move.l	d3,vmap_yintinc	; Incr‚ment Y, partie entiŠre, en m‚moire ‚cran

;--- Calcul de l'incr‚ment d'incr‚ment en H ----------------------------------
	moveq	#0,d6
	move.w	vmap_sprsy(a0),d6
	swap	d6
	move.l	d6,d7
	divu.l	d5,d6
	divu.l	d4,d7
	sub.l	d6,d7
	divs.l	d2,d7
	move.l	d7,d4
	swap	d4
	move.l	d4,vmap_hinc(a0)	; d4 = incr‚ment d'incr‚ment H invers‚
	swap	d6		; d6 = incr‚ment en Y spr

	move.l	adrecr(pc),a1
	add.l	d0,a1
	add.l	d0,a1
	muls.w	#_LWIDTH,d1
	add.l	d1,a1		; a1 = adresse d'affichage du point sur [AB]
	moveq	#0,d7		; d7 = ordonn‚e fractionnaire
	subq.w	#1,d2		; d2 = compteur en X
	add.w	#SIZEX/2,d0	; d0 = abscisse courante par rapport … la fenˆtre

;--- Boucle en X -------------------------------------------------------------
vertical_mapping_loopx:
	tst.w	d0
	bmi.s	vertical_mapping_nextx
	cmp.w	#SIZEX,d0
	bge.s	vertical_mapping_nextx







vertical_mapping_nextx:
	addq.w	#1,d0		; Abscisse suivante
	add.l	vmap_intincy(a0),a1	; Bresenham pour l'adresse ‚cran
	add.w	vmap_fracincy(a0),d7
	bcc.s	.vmnx_s
	add.w	#_LWIDTH,a1
.vmnx_s:	dbra	d2,vertical_mapping_loopx

vertical_mapping_end:
	rts


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Data



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Bss

screen_address:	Ds.l	1	; Adresse de l'‚cran
vmap_var:		Ds.b	vmap_end	; Variables du mapping vertical
z_buffer:		Ds.w	_sizex*_sizey	; Le Z-buffer
screen_memory:	Ds.b	_lwidth*_lnbr	; M‚moire ‚cran


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
