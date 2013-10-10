lwidth:	EQU	160
nplans:	EQU	4


	TEXT

; a0 pointe sur la chaåne Ö afficher
; a1 contient l'adresse d'affichage
; d0 contient la couleur d'affichage

	lea.l	buffer_ligne66(pc),a2	; a2 = buffer
	moveq	#32,d2		; d2 = numÇro du bit d'affichage
	lea.l	fonte66(pc),a3	; a3 pointe sur les fontes
afch66_lp:
	move.b	(a0)+,d3
	tst.b	d3
	beq	afch66_ecran
	ext.w	d3
	move.w	d3,d4
	lsl.w	#3,d3
	sub.w	d4,d3
	lea.l	(a3,d3.w),a4	; a4 sur caractäre courant
	move.b	(a4)+,d3		; d3 = largeur en pix du caract.
	sub.b	d3,d2
	moveq	#5,d4
	move.l	a2,a5
afch66_lp1:
	move.b	(a4)+,d5
	bfins	d5,(a5){d2:d3}
	add.w	#lwidth,a5
	dbra	d5,afch66_lp1
	cmp.b	#16,d2
	bgt.s	afch66_lp
	addq.l	#2,a3
	add.b	#16,d2
	bra.s	afch66_lp
afch66_ecran:


	clr.w	-(sp)
	trap	#1


	DATA

fonte66:	DCB	256*7,0

	BSS

buffer_ligne66:
	DS.b	lwidth*6