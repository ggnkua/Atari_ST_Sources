; Mapping d'une surface opaque
; (AD)//(BC) et A, B, C, D toujours dans cette ordre
;    _
; A |\¹-_J
;   | \ |¹-_
;   |  \|   ¹- B
;   |   +I    |
;   |   |\    |
;   |   | \   |
;   |   |  \  |
;   |   |   \ |
;   |   |    \|
;   |   |  _-¹ C
;   |   _-¹
; D |_-¹K
;

	opt	e+
	opt	w+
	opt	x+
	opt	p=68030
	output	'A:\MAPPING1.PRG'



	TEXT

_lwidth:	equ	640		; Ecran de 320 pixels en Hi-color
_lnbr:	equ	200		; et de 200 lignes
_sizex:	equ	320		; Largeur de la fenˆtre (multiple de 8)
_sizey:	equ	200		; Hauteur de la fenˆtre



	move.l	#m_ecran,adrecr
	move.w	#36,-(sp)
	move.w	#3,-(sp)
	move.l	#m_ecran,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#14,sp
	lea	m_ecran,a0
	move.w	#31999,d0
	moveq	#-1,d1
looop:	move.l	d1,(a0)+
	dbra	d0,looop
	lea	map_var(pc),a0
	move.l	#$00000000,map_pxa(a0)
	move.l	#$01500001,map_pza(a0)
	move.l	#$00000150,map_pyb(a0)
	move.l	#$00010070,map_pyc(a0)

	bsr	clear_z_buffer

	move.w	#$bf,d0
bbbb:	move.w	d0,-(sp)
	bsr	mapping_vertical
	move.w	(sp)+,d0
	addq.w	#1,map_pxb(a0)
	addq.w	#1,map_pyc(a0)
	;addq.w	#1,map_pyd(a0)
	subq.w	#1,map_pza(a0)
	subq.w	#1,map_pzb(a0)
	dbra	d0,bbbb

;	lea	map_var(pc),a0
;	move.w	#(map_end/2)-1,d7
;boucle:	move.b	(a0)+,d0
;	bsr	hexa
;	move.b	(a0)+,d0
;	bsr	hexa
;	movem.l	d7/a0,-(sp)
;	move.l	#$20020,-(sp)
;	trap	#1
;	addq.l	#4,sp
;	movem.l	(sp)+,d7/a0
;	dbra	d7,boucle
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	#42,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#14,sp
	clr.w	-(sp)
	trap	#1



;------------------------------------------------------------------------------
;	Mapping d'une face verticale. Les coordonn‚es de A, B C et D
;	doivent ˆtre fournies
;------------------------------------------------------------------------------
mapping_vertical:

; Teste si le polygone a bien une partie dans la fenˆtre
; et calcule les diff‚rentes distances entre les points
	lea	sprite,a2		; a2 pointe sur le sprite
	lea	palette,a6		; a6 pointe sur sa palette
	lea	map_var(pc),a0	; a0 pointe sur les variables de mapping
	cmp.w	#_sizex,map_pxa(a0)
	bge	fin_mapping_v	; fin si xA=>sizex
	cmp.w	#_sizey,map_pya(a0)
	bge	fin_mapping_v	; fin si yA=>sizey
	moveq	#0,d1
	move.w	map_pxb(a0),d1
	tst.w	d1
	blt	fin_mapping_v	; fin si xB<0
	sub.w	map_pxa(a0),d1
	move.w	d1,map_dx(a0)	; d1 = dx
	move.w	map_pyb(a0),d0
	cmp.w	#_sizey,d0
	bge	fin_mapping_v	; fin si yB=>sizey
	sub.w	map_pya(a0),d0
	move.w	d0,map_dy1(a0)
	move.w	map_pyc(a0),d0
	tst.w	d0
	blt	fin_mapping_v	; fin si yC<0
	sub.w	map_pyd(a0),d0
	move.w	d0,map_dy2(a0)
	move.w	map_pyd(a0),d0
	tst.w	d0
	blt	fin_mapping_v	; fin si xD<0
	sub.w	map_pya(a0),d0
	move.w	d0,map_dy3(a0)
	move.w	map_pyc(a0),d0
	sub.w	map_pyb(a0),d0
	move.w	d0,map_dy4(a0)
	move.w	map_pzb(a0),d0
	sub.w	map_pza(a0),d0
	move.w	d0,map_dz(a0)

; Calcule les diff‚rentes pentes pour x, y et z
	tst.w	d1
	bne.s	.sinon
	clr.l	map_yhi(a0)	; si xA=xB
	clr.l	map_ybi(a0)
	clr.w	map_xinc(a0)
	clr.l	map_zinc(a0)
	bra.s	.finsi
.sinon:				; si xA<xB
	moveq	#0,d0
	move.w	map_dy1(a0),d0
	swap	d0
	divs.l	d1,d0
	move.l	d0,map_yhi(a0)	; yhi = dy1/dx
	moveq	#0,d0
	move.w	map_dy2(a0),d0
	swap	d0
	divs.l	d1,d0
	move.l	d0,map_ybi(a0)	; ybi = dy2/dx
	moveq	#0,d0
	move.w	map_dz(a0),d0
	swap	d0
	divs.l	d1,d0
	move.l	d0,map_zinc(a0)	; zinc = dz/dx
	moveq	#1,d0
	swap	d0
	divu.w	d1,d0
	move.w	d0,map_xinc(a0)	; xinc = 1/dx
.finsi:

; Initialise les variables d‚pendantes de l'abscisse
	move.l	adrecr(pc),a1	; a1 pointe en haut … gauche de la fenˆtre (elle mˆme en haut … gauche de l'‚cran)
	lea	z_buffer(pc),a4	; a4 pointe en haut … gauche du z-buffer
	moveq	#0,d1
	move.w	map_pxa(a0),d1	; d1 = xA
	tst.w	d1
	blt.s	.sinon2
	clr.w	map_xp(a0)		; si xA=>0
	move.w	map_pya(a0),map_yh(a0)
	clr.w	map_yh+2(a0)
	move.w	map_pyd(a0),map_yb(a0)
	clr.w	map_yb+2(a0)
	move.w	map_pza(a0),map_zp(a0)
	clr.w	map_zp+2(a0)
	move.w	map_dx(a0),d7	; d7 = compteur de colonnes
	add.w	d1,d1
	add.w	d1,a1		; a1 pointe sur la 1Šre colonne … afficher
	add.w	d1,a4		; a4 sur la 1Šre colonne … afficher dans le z-buffer
	bra.s	.finsi2
.sinon2:				; si xA<0
	move.w	map_xinc(a0),d0
	muls.w	d1,d0
	neg.l	d0
	move.l	d0,map_xp(a0)
	moveq	#0,d2
	move.w	map_pya(a0),d2
	swap	d2
	move.l	map_yhi(a0),d0
	muls.l	d1,d0
	sub.l	d0,d2
	move.l	d2,map_yh(a0)
	moveq	#0,d2
	move.w	map_pyd(a0),d2
	swap	d2
	move.l	map_ybi(a0),d0
	muls.l	d1,d0
	sub.l	d0,d2
	move.l	d2,map_yb(a0)
	moveq	#0,d2
	move.w	map_pza(a0),d2
	swap	d2
	move.l	map_zinc(a0),d0
	muls.l	d1,d0
	sub.l	d0,d2
	move.l	d2,map_zp(a0)
	move.w	map_dx(a0),d7
	sub.w	d1,d7		; Ajuste d7 le compteur de colonnes
.finsi2:
	cmp.w	#_sizex,map_pxb(a0)	; Clipping … droite
	ble.s	.finsi3
	add.w	#_sizex,d7
	sub.w	map_pxb(a0),d7
.finsi3:
	subq.w	#1,d7
	move.w	#_lwidth,d4
	move.w	#_sizex*2,d5

; Boucle en x
mapping_v_loopx:
	tst.w	map_yb(a0)
	blt	map_v_loopx_fin
	cmp.w	#_sizey,map_yh(a0)
	bge	map_v_loopx_fin
	moveq	#0,d1
	move.w	map_xp(a0),d1	; d1 = xp
	moveq	#1,d0
	swap	d0
	subq.l	#1,d0
	sub.l	d1,d0		; Les 2 mulu suivants sont optimisables
	mulu.w	map_dy3(a0),d0	; d0 = p1 = (1-xp)*dy3
	mulu.w	map_dy4(a0),d1	; d1 = p2 = xp*dy4
	add.l	d1,d0		; d0 = p1+p2
	lsl.l	#6,d1		; d1 = 64*p2
	divu.l	d0,d1
	lsl.w	#6,d1		; d1 = xpos*64 (entier)

	moveq	#0,d6
	move.w	map_yb(a0),d6
	sub.w	map_yh(a0),d6	; d6 = yb-yh (entier) = compteur de lignes
	moveq	#64,d2
	swap	d2
	divu.l	d6,d2		; d2 = yinc = 64/(yb-yh) (r‚el)

	move.l	d1,d3
	swap	d3		; d3 = ypos+xpos*64 (r‚el)
	tst.w	map_yh(a0)		; Clipping haut
	bge.s	.sinon
	moveq	#-1,d0
	move.w	map_yh(a0),d0
	add.w	d0,d6		; Corrige le nbr de lignes … afficher
	muls.l	d2,d0
	sub.l	d0,d3		; d3 = ypos+xpos*64-yinc*yh (r‚el)
	move.l	a1,a3		; a3 adresse d'affichage
	move.l	a4,a5		; a5 z-buffer
.sinon:
	move.w	map_yh(a0),d0
	move.w	d0,d1
	mulu.w	d4,d0
	lea	(a1,d0.l),a3	; a3 adresse d'affichage
	mulu.w	d5,d1
	lea	(a4,d1.l),a5	; a5 adresse dans le z-buffer
.finsi:
	move.w	map_zp(a0),d0	; d0 = position z
	move.w	d0,d1
	lsr.w	#1,d1		; d1 = intensit‚ d'‚clairage

	cmp.w	#_sizey,map_yb(a0)	; Clipping bas
	ble.s	.finsi2
	add.w	#_sizey,d6
	sub.w	map_yb(a0),d6
.finsi2:
	subq.w	#1,d6

; Boucle en y
mapping_v_loopy:
	cmp.w	(a5),d0		; Compare les z
	bge.s	.finsi		; S'il y a qqc devant, on n'affiche rien
	move.w	d0,(a5)
	swap	d3
	move.b	(a2,d3.w),d1	; Num‚ro de la couleur
	move.w	(a6,d1.w),(a3)	; D‚code la palette et affiche le pixel
	swap	d3
.finsi:

	add.w	d4,a3
	add.w	d5,a5
	add.l	d2,d3
	dbra	d6,mapping_v_loopy

map_v_loopx_fin:
	move.l	map_yhi(a0),d0
	add.l	d0,map_yh(a0)
	move.l	map_ybi(a0),d0
	add.l	d0,map_yb(a0)
	move.w	map_xinc(a0),d0
	add.w	d0,map_xp(a0)
	move.l	map_zinc(a0),d0
	add.l	d0,map_zp(a0)
	addq.w	#2,a1		; Colonne suivante
	addq.w	#2,a4
	dbra	d7,mapping_v_loopx
fin_mapping_v:
	rts



;------------------------------------------------------------------------------
;	Routine d'effacement du z-buffer
;------------------------------------------------------------------------------
clear_z_buffer:
	movem.l	d0/d1/a0,-(sp)
	lea	z_buffer(pc),a0
	move.l	#$7FFF7FFF,d0	; Remplissage avec z maximum
	move.w	#(_sizey*4)-1,d1
clrzbuf_loop:			; Nettoie 1/4 de ligne
	REPT	_sizex/8		; Ca doit tenir dans le cache
	move.l	d0,(a0)+
	ENDR
	dbra	d1,clrzbuf_loop
	movem.l	(sp)+,d0/d1/a0
	rts


;------------------------------------------------------------------------------
;	Affichage d'un octet en hexa contenu dans d0
;------------------------------------------------------------------------------
hexa:
	movem.l	d0/d1/a0/a1,-(sp)
	and.w	#255,d0
	move.b	d0,d1
	lsr.b	#4,d0
	cmp.b	#10,d0
	blt.s	.suite1
	add.b	#7,d0
.suite1:	add.b	#48,d0
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	and.b	#15,d1
	cmp.b	#10,d1
	blt.s	.suite2
	add.b	#7,d1
.suite2:	add.b	#48,d1
	move.w	d1,2(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d0/d1/a0/a1
	rts


	DATA

palette:	incbin	'a:\pal1_map.bin'
;	ds.w	128*64		; Palette de 128 couleurs de
				; 64 niveaux d'intensit‚
sprite:	incbin	'a:\spr1_map.bin'
;	ds.w	64*64		; Sprite de 64x64 pixels


	BSS

	rsreset

; Structure des diff‚rentes variables utiles au mapping d'une face verticale
map_pxa:	rs.w	1	; Coordonn‚es x, y et z des diff‚rents points
map_pya:	rs.w	1
map_pza:	rs.w	1	; idem pour D
map_pxb:	rs.w	1	; idem pour C
map_pyb:	rs.w	1
map_pzb:	rs.w	1	; idem pour C
map_pyc:	rs.w	1
map_pyd:	rs.w	1
map_dx:	rs.w	1
map_dy1:	rs.w	1
map_dy2:	rs.w	1
map_dy3:	rs.w	1
map_dy4:	rs.w	1
map_dz:	rs.w	1
map_xp:	rs.w	1
map_xinc:	rs.w	1
map_yh:	rs.l	1
map_yhi:	rs.l	1
map_yb:	rs.l	1
map_ybi:	rs.l	1
map_xpos:	rs.w	1
map_ypos:	rs.l	1
map_yinc:	rs.l	1
map_zp:	rs.l	1
map_zinc:	rs.l	1
map_end:	rs.w	1

adrecr:	ds.l	1		; Adresse de l'‚cran logique
map_var:	ds.w	map_end		; Variables utiles au mapping
z_buffer:	ds.w	_sizex*_sizey	; Buffer contenant les coordonn‚es
				; z de chaque point de l'‚cran
m_ecran:	ds.b	_lwidth*_lnbr	; m‚moire ‚cran
