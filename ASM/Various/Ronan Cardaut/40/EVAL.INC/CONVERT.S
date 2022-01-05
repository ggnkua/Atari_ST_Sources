yop
	move.l	#chaine123,a0
	bsr	convert
	lea	chaine_retour,a0
	bsr	convert_inv
	nop
	
	
	
convert::
***********************************************
** routine qui convertit une chaine ascii en **
** un nombre retourne dans d0.d1             **
** chaine dans a0 non modifi‚e               **
** a0 non plus                               **
**  % binaire                                **
**  $ ou rien hexa                           **
**  \ decimal                                **
** le signe est place avant ou apres l'id.   **
** ex : -$fada    ou \-123456789             **
***********************************************
	movem.l	d2-a6,-(sp)
	
	moveq	#0,d6
	moveq	#0,d7


	move.b	#0,d3			; flag pour le negatif	
	move.l	#1,d4
	cmp.b	#'-',(a0)
	bne.s	.p_moins
	move.b	#2,d4
	move.b	#1,d3
.p_moins
	cmp.b	#'-',1(a0)
	bne.s	.p_moins1
	move.b	#1,d3
	move.b	#2,d4
.p_moins1
	cmp.b	#'+',(a0)
	bne.s	.p_plus
	move.b	#2,d4
	move.b	#0,d3
.p_plus
	cmp.b	#'+',1(a0)
	bne.s	.p_plus1
	move.b	#2,d4
	move.b	#0,d3
.p_plus1
	
	cmp.b	#'$',(a0)			; traitement de l'hexa
	beq.s	.hexa
	cmp.b	#'$',1(a0)
	bne	.p_hexa
.hexa	add.l	d4,a0
	
	moveq	#0,d6
	moveq	#0,d7

.a	tst.b	(a0)
	beq	.zero
	rept	4
	lsl.l	d7
	roxl.l	d6	
	endr
	
	
	move.b	(a0)+,d1
	
	cmp.b	#'0',d1
	blt	.p_nb
	cmp.b	#'9',d1
	bgt	.p_nb
	sub.b	#'0',d1
.p_nb
	cmp.b	#'A',d1
	blt	.p_car_ma
	cmp.b	#'F',d1
	bgt	.p_car_ma
	sub.b	#'A',d1
	add.b	#$a,d1
.p_car_ma

	cmp.b	#'a',d1
	blt	.p_car_mi
	cmp.b	#'f',d1
	bgt	.p_car_mi
	sub.b	#'a',d1
	add.b	#$a,d1
.p_car_mi
	or.b	d1,d7
	bra	.a
	
.zero

	bra	.quit
	
.p_hexa
	cmp.b	#'%',(a0)			; traitement du binaire
	beq.s	.bin
	cmp.b	#'%',1(a0)
	bne.s	.p_bin	
.bin
	add.l	d4,a0
	
	moveq	#0,d2
.a1	tst.b	(a0)
	beq.s	.zero1
	
	;lsl.l	#1,d2
	
	lsl.l	d7
	roxl.l	d6
	
	move.b	(a0)+,d1
	sub.b	#'0',d1
	or.b	d1,d7
	bra.s	.a1
.zero1

	bra	.quit
.p_bin
	cmp.b	#'\',(a0)			; traitement du decimal
	beq.s	.deci
	cmp.b	#'\',1(a0)
	bne	.hexa1				; hexa par defaut	
.deci
	add.l	d4,a0
	
	moveq	#0,d1
	moveq	#0,d2
.a2	tst.b	(a0)
	beq.s	.zero2
	mulu.l	#10,d2
	move.b	(a0)+,d1
	sub.b	#'0',d1
	add.l	d1,d2
	bra.s	.a2
.zero2
	
	move.l	#0,d6		; attention suelement sur 32 bit	
	move.l	d2,d7
	bra	.quit
.hexa1
	subq.l	#1,d4
	bra	.hexa

.quit
	tst.b	d3
	beq.s	.n_e		; calcul du n‚gatif
	neg.l	d6	
	neg.l	d7
.n_e
	move.l	d7,d1
	move.l	d6,d0

	movem.l	(sp)+,d2-a6
	rts
	
	






convert_inv::
***************************************************
** routine qui convertit un nombre dans d0.d1    **
** en une chaine en hexa, en decimal en binaire  **
** la chaine en transmise dans a0                **
***************************************************
	movem.l	d0-a6,-(sp)
	
	move.l	d0,d6		; on sauve les registre
	move.l	d1,d7
	
	
	move.b	#'$',(a0)+		; on commence par l'hexa
	
	tst.l	d0
	beq.s	.p_partie_haute
	bsr	affiche_nombre_z		; calcul de la partie haute
	lea	nombre,a2			; sans les zeros inutiles
.cop	move.b	(a2)+,(a0)+
	bne.s	.cop
	
	subq.l	#1,a0
	
	move.l	d1,d0				; affiche la partie basse avec les zeros
	bsr	affiche_nombre
	lea	nombre,a2
.cop1	move.b	(a2)+,(a0)+
	bne.s	.cop1
	subq.l	#1,a0
	bra.s	.decimal

.p_partie_haute
	tst.l	d1
	beq.s	.nombre_0		
	move.l	d1,d0				; affiche la partie basse avec les zeros
	bsr	affiche_nombre_z
	lea	nombre,a2
.cop2	move.b	(a2)+,(a0)+
	bne.s	.cop2
	subq.l	#1,a0
	bra.s	.decimal

.nombre_0
	move.b	#'0',(a0)+		; le nombre vaut zero
	move.l	#' \0 ',(a0)+		; tout d'un coup !
	move.w	#'%0',(a0)+
	move.b	#'.',(a0)+
	bra	.exit
	
.decimal

	move.w	#' \',(a0)+
	move.l	d7,d1			; convertion sur 32 bits
	lea	temp,a2
	move.l	d6,d0
	move.l	#0,d2
.encore	
	move.l	#10,d2
	bsr	div_l
	
	add.b	#'0',d2
	move.b	d2,(a2)+
	
	tst.l	d0
	bne.s	.encore
	tst.l	d1
	bne.s	.encore
	
	
	
	
	clr.b	(a2)
	lea	temp,a2
	lea	temp1,a3
	bsr	inverse_chaine	
.copi	clr.b	(a3)+
	move.b	(a2)+,(a0)+
	tst.b	(a2)
	bne.s	.copi
	
	
	moveq	#0,d3
	
	move.w	#' %',(a0)+		; on attaque le binaire
	
	move.l	d7,d1
	move.l	d6,d0
	
	moveq	#0,d2			; on efface d2 qui dit quand y plus de zero de debut
	
	moveq	#63,d5

.k
	lsl.l	#1,d1
	roxl.l	#1,d0
	bcc.s	.u
	move.b	#1,d2				; mets a un l'autorisation d'aff des zero
	move.b	#'1',(a0)+			; permet de supprimr les zeros inutiles
	bra.s	.m
.u
	tst.b	d2
	beq.s	.m
	move.b	#'0',(a0)+
.m
	addq.b	#1,d3
	cmp.b	#8,d3
	bne.s	.d
	clr.b	d3
	tst.b	d2
	beq.s	.d
	move.b	#'.',(a0)+
	
.d
	dbra	d5,.k
.kze
.exit
	
	subq.l	#1,a0			; cela va supprimer le dernier point binaire
	
	
	
	move.l	d7,d1
	move.l	d6,d0
	move.b	#' ',(a0)+
	
	lea	temp,a6
	move.l	d6,(a6)
	move.l	d7,4(a6)
	
	
	moveq	#7,d7
.kopi	move.b	(a6)+,d0
	tst.b	d0
	beq.s	.s
	cmp.b	#$d,d0
	beq.s	.s
	cmp.b	#$9,d0
	beq.s	.s
	cmp.b	#$a,d0
	beq.s	.s
	move.b	d0,(a0)+
.s
	dbra	d7,.kopi
	
	
	
	
	
	
	clr.b	(a0)
	movem.l	(sp)+,d0-a6

	rts	



inverse_chaine
********************
** chaine dans a0 **
********************
	
	movem.l	a0-a3,-(sp)
	
	move.l	a2,a1
.cherche
	tst.b	(a2)+
	bne.s	.cherche
	
	lea	temp1,a3
	subq.l	#1,a2
.o	move.b	-(a2),(a3)+
	cmp.l	a2,a1
	bne.s	.o
	
	lea	temp1,a1
.k	move.b	(a1)+,(a2)+
	tst.b	(a1)
	bne.s	.k
	
	
	movem.l	(sp)+,a0-a3
	
	
	
	rts
	
	
	
div_l
*********************************************
** routine qui fait la div de d0.d1 par d2 **
** DANS TOUS LES CAS, ELLE MARCHE          **
** dans d0.d1 le quotient, d2 => reste     **
*********************************************
	
	move.l	d3,-(sp)
	move.l	#0,d3
	divu.l	d2,d3:d0
	divu.l	d2,d3:d1
	move.l	d3,d2
	move.l	(sp)+,d3
	
	rts
	
	



affiche_nombre
	
	include	'eval.inc\aff_n.s'
	
	
	DATA
		
chaine123
	;dc.b	'1234',0
	;dc.b	'1234567890abcdef0',0
	;dc.b	'$1234567890abcdef01234567',0
	dc.b	'%1111111011',0
	;dc.b	'$1AafF90',0
	
	even

	BSS


nbe	ds.l	3

temp
	ds.b	256
temp1
	ds.b	256

chaine_retour
	ds.b	256
	
