************  ROTATION DE L'ECRAN PAR RAPPORT AU CENTRE  *************
***********************  (C) 1995 , PHILOU ***************************

	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

debut			;adresse de debut de programme

;trace une ligne horizontale

	move.l	$44e,a4
	adda.l	#40*100,a4
	move.w	#39,d0
ligne	move.l	#$ffffffff,(a4)+
	dbf	d0,ligne

;ouverture fichier tabcos

	move.w	#0,-(sp)	
	move.l	#fichcos,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	
;lecture fichier tabcos

	move.l	#valcos,-(sp)
	move.l	#57600,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp

;Fermeture fichier tabcos

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
;ouverture fichier tabsin

	move.w	#0,-(sp)	
	move.l	#fichsin,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	
;lecture fichier tabsin

	move.l	#valsin,-(sp)
	move.l	#57600,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp

;Fermeture fichier tabsin

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
	lea.l	valsin,a4
	lea.l	valcos,a3
	
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
	addi.l	#$f8000,point
	lea.l	(point),a1
	
;boucle infinie

loop	

;initialisation pointeur de table

	lea.l	1,a0

;tant que a0<=$369c0

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
	addi.l	#$f8000,point
	lea.l	(point),a2
	
	move.l	(a2),d0
	move.l	(a1),(a2)
	move.l	a2,a1
	
	addq.l	#4,a0
	cmpa.l	#$369c0,a0
	bhi	tantque
	
;	bra	loop

	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1
	
	section data
	
fichcos	dc.b	"a:\TABCOS.BIN",0
fichsin	dc.b	"a:\TABSIN.BIN",0

	section bss

valcos	ds.b	57600
valsin	ds.b	57600
point	ds.l	1
handle	ds.w	1

	end