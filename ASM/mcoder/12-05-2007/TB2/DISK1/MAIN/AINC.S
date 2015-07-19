debut	equ	1
try:
posx:	move.w	posx,d1
demi:	move.w	demi,d2
	lsr.w	#3,d2
tabcolspr:
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

	* a4=spr
ptmap:
	move.l	ptmap,a2
posy:
	move.w	posx,d1
	move.w	posy,d2
tab28
	lsr.w	#4,d2
	lea	tab28,a5
	add.w	d2,d2
	adda.w	d2,a5
	move.w	(a5),d2
	adda.w	d2,a2

	lsr.w	#4,d1
	adda.w	d1,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en haut a gauche
colbri
	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique haut gauche

	moveq	#0,d6

st	set	0
	rept	16
	move.w	st(a4),d1		* sprite
	and.w	(a3)+,d1		* ET fond
	or.w	d1,d6		* resultat total dans d6
st	set	st+4
	endr

* a2=posmap toujours

	addq.l	#1,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en haut a droite

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique haut droite

st	set	2
	rept	16
	move.w	st(a4),d1		* sprite		* 12
	and.w	(a3)+,d1		* ET fond		*  8
	or.w	d1,d6		* resultat total dans d6	* 4
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
	or.w	d1,d6		* resultat total dans d6	* 4
st	set	st+4				* = 24*16=384 cycles
	endr

* bas droite

	addq.l	#1,a2

	moveq	#0,d1
	move.b	(a2),d1		* no brique en bas a droite

	lea	colbri,a3
	lsl.w	#5,d1
	adda.w	d1,a3		* on est sur la brique bas droite

st	set	2
	rept	16
	move.w	st(a4),d1		* sprite		* 12
	and.w	(a3)+,d1		* ET fond		*  8
	or.w	d1,d6		* resultat total dans d6	* 4
st	set	st+4				* = 24*16=384 cycles
	endr


	move.w	posx,d1
	move.w	posy,d2

ecr1:	move.l	ecr1,a2
	adda.w	#debut,a2

tab230	lea	tab230,a3
	add.w	d2,d2
	add.w	d2,d2
	adda.w	d2,a3
	move.l	(a3),d2
	add.l	d2,a2

	move.w	d1,d2
	lsr.w	#4,d2
	lsl.w	#3,d2
	adda.w	d2,a2


	and.w	#%1111,d1
tabpred	lea	tabpred,a3
	add.w	d1,d1
	add.w	d1,d1
	adda.w	d1,a3
	move.l	(a3),a3
	
ptrestore1
	move.l	ptrestore1,a4
	move.l	a2,(a4)+
	adda.w	#15*16,a4
	
*	a2=fond
*	a3=sprites
*	a4=sauve fond


st	set	0
	rept	15
	movem.l	st(a2),d1-d4	* 12+8*4=	34
	movem.l	d1-d4,-(a4)	* 8+8*4=	40
	and.l	(a3),d1		* 	16
	and.l	(a3)+,d2		*	16
	or.l	(a3)+,d1		*	16
	or.l	(a3)+,d2		*	16
	and.l	(a3),d3		*	16
	and.l	(a3)+,d4		*	16
	or.l	(a3)+,d3		*	16
	or.l	(a3)+,d4		*	16
	movem.l	d1-d4,st(a2)	*	40 = 242
st	set	st+230
	endr
	move.l	ptrestore1,a4
	move.l	(a4)+,a2

st	set	14*230
	rept	15
	movem.l	(a4)+,d1-d4
	movem.l	d1-d4,st(a2)
st	set	st-230
	endr
