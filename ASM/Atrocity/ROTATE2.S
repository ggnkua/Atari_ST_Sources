************  ROTATION DE L'ECRAN PAR RAPPORT AU CENTRE  *************
***********************  (C) 1995 , PHILOU ***************************

	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$44e,a4
	adda.l	#192*100,a4
	move.w	#191,d0
ligne	move.l	#$ffffffff,(a4)+
	dbf	d0,ligne
	
	lea	valsin,a4
	lea	valcos,a3
	move.l	$44e,a5
		
;calcul de la premiäre adresse de ligne et de colonne
	
	move.b	valsin,d0
	sub.l	#100,d0
	neg.l	d0
	mulu	#160,d0
	
	move.b	valcos,d1
	add.l	#80,d1
	asl.l	#4,d1
	
	move.l	d0,point
	add.l	d1,point
	move.l	a5,d6
	add.l	d6,point
	lea.l	(point),a1
	
;initialisation pointeur de table

	move.l	#50,d5
	
loop	bsr	VBL
	lea.l	1,a0

tantque
;calcul de l'adresse de ligne et de colonne

	move.l	(a0,a4.l),d0
	sub.l	#100,d0
	neg.l	d0
	mulu	#160,d0
	
	move.l	(a0,a3.l),d1
	add.l	#80,d1
	asl.l	#4,d1
	
	move.l	d0,point
	add.l	d1,point
	move.l	a5,d6
	add.l	d6,point
	lea.l	(point),a2
	
	move.l	(a2),d0
	move.l	(a1),(a2)
	move.l	a2,a1
	
	addq.l	#4,a0
	cmpa.l	#$369c0,a0
	bhi	tantque
	
	dbf	d5,loop

	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

VBL	MOVE.L	$466.W,D7
VBL1	CMP.L	$466.W,D7
	BEQ.B	VBL1
	RTS

	section data
	
valcos	incbin	e:\TABCOS.BIN
valsin	incbin	e:\TABSIN.BIN

	section bss

point	ds.l	1
handle	ds.w	1

	end