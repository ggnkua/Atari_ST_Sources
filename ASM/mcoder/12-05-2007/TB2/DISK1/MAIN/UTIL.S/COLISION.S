*
*	Au niveau des collisions le sprite fait 16 de haut !!
*

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	posx,d1
	move.w	posy,d2

	and.w	#%1111,d1
	lea	tabcolspr,a4
	add.w	d1,d1
	add.w	d1,d1
	adda.w	d1,a4
	move.l	(a4),a4		* predecalage pour x

*==> calcul de la hauteur

*	yspr = (y-(y div 16))*4
	
	and.w	#%1111,d2
	add.w	#16,d2
	add.w	d2,d2
	add.w	d2,d2

	adda.w	d2,a4		* predecalage pris a la bonne hauteur
	move.l	a4,posspr

	* a4=spr

	move.l	ptmap,a2

	move.w	posx,d1
	move.w	posy,d2

	lsr.w	#4,d2
	lea	tab28,a5
	add.w	d2,d2
	adda.w	d2,a5
	move.w	(a5),d2
	adda.w	d2,a2

	lsr.w	#4,d1
	adda.w	d1,a2
	move.l	a2,posmap

	moveq	#0,d1
	move.b	(a2),d1		* no brique en haut a gauche

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique haut gauche

	moveq	#0,d7

st	set	0
	rept	16
	move.w	st(a4),d1		* sprite
	and.w	(a3)+,d1		* ET fond
	or.w	d1,d7		* resultat total dans d7
st	set	st+4
	endr

* a2=posmap toujours

	addq.l	#1,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en haut a droite

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique haut droite

st	set	4
	rept	16
	move.w	st(a4),d1		* sprite		* 12
	and.w	(a3)+,d1		* ET fond		*  8
	or.w	d1,d7		* resultat total dans d7	* 4
st	set	st+4				* = 24*16=384 cycles
	endr

* passage au bas du sprite:

	adda.w	#64,a4

* bas gauche

	add.l	#27,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en bas a gauche

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique bas gauche

st	set	0
	rept	16
	move.w	st(a4),d1		* sprite		* 12
	and.w	(a3)+,d1		* ET fond		*  8
	or.w	d1,d7		* resultat total dans d7	* 4
st	set	st+4				* = 24*16=384 cycles
	endr

* bas droite

	addq.l	#1,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en bas a droite

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique bas droite

st	set	4
	rept	16
	move.w	st(a4),d1		* sprite		* 12
	and.w	(a3)+,d1		* ET fond		*  8
	or.w	d1,d7		* resultat total dans d7	* 4
st	set	st+4				* = 24*16=384 cycles
	endr


	
	illegal	

	section	data

ptmap:
	dc.l	map

map:	dcb.b	50,30

posx:	dc.w	1
posy:	dc.w	1

tabcolspr:
st	set	0
	rept	16
	dc.l	colspr+st
st	set	st+192
	endr

colbri:
	incbin	"a:\col.ter"
	even

colspr:
	incbin	"a:\spr.col"
	even

tab28:
st	set	0
	rept	200
	dc.w	st
st	set	st+28
	endr

	section	bss

posmap:	ds.l	1
posspr:	ds.l	1


	end