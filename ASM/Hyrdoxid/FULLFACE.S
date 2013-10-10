;ne pas oublier:
;4 DC.W:CX1,CY1,CX2,CY2 pour les coordonnees des 2 points

LINE
;x en d6,d7   
;y en d3,d4
;pente en d0
;init coord x et y
;d1-d2
***********
;creer 2 tableaux: un pour x_max et 1 pour x_min
***********

	movem.l	CLR,d0-d7
	MOVE.L	X_SAVE,a1
	MOVE.L	Y_SAVE,a2
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
;verifie les distances: si dx>dy ou dy>dx
	sub.w	d3,d4
	bpl.s	NO_SUB1
	neg	d4
NO_SUB1
	sub.w	d6,d7
	bpl.s	NO_SUB2
	neg	d7
NO_SUB2
	cmp.w	d7,d4
	bhi	LIGNEY
***********************CAS DX>DY************************************************
LIGNEX
	clr.b	IND
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
	move.w	d3,d0
;verifie si xb>xa ou yb>ya
	cmp.w	d6,d7
	bhi.s	NO_SWAPX
	exg	d6,d7
	move.w	d6,CX1
	exg	d3,d4
	move.w	d3,d0
NO_SWAPX	
	cmp.w	d3,d4			
	bhi.s	NO_SWAPY
	exg	d3,d4			
	move.b	#1,IND			;indicateur pour type de pente
NO_SWAPY
;calcul de pente
	lsl	#8,d3			;multiplie par 512
	lsl.l	#1,d3			;pour enlever le reste
	lsl	#8,d4			;de la division
	lsl.l	#1,d4
	sub.w	d6,d7
	sub.l	d3,d4
	divu	d7,d4
	andi.l	#$ffff,d4		;multiplie par 128(512*128=65536)
	lsl.l	#7,d4			;valeur de pente en d4
	cmpi.l	#$10000,d4		;au cas ou dx=dy
	bne.s	NO_PRB
	subq.l	#1,d4
NO_PRB
;calcul de la position du point x de depart
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	move.w	d0,d3			;y debut
 	moveq.w #0,d1			;Compteur de pente
;sauve x_min et y _min pour test de comparaison
	move.w	d6,X_MIN	
	cmpi.b	#1,IND
	beq.s	LINE_XB
	move.w	d3,Y_MIN		
**********TRACE LIGNE/XA*******
LINE_XA
	move.w	d6,(a1)+
	move.w	d3,(a2)+
 	addq.w 	#1,d6			;x suivant
 	add.w 	d4,d1			; pente 
 	bcc.s 	NO_INC_LINEA		; si pente>65536 passe y suivant
 	addq.w	#1,d3			;y suivant
NO_INC_LINEA
 	dbf	d7,LINE_XA
 	rts
**********TRACE LIGNE/XB*******
LINE_XB
	move.w	d6,(a1)+
	move.w	d3,(a2)+
	addq.w	#1,d6
 	add.w 	d4,d1			; pente 
 	bcc.s 	NO_INC_LINEB		; si pente>65536 passe y suivant
	subq.w	#1,d3
NO_INC_LINEB
 	dbf	d7,LINE_XB
	move.w	d3,Y_MIN		
 	rts
************************CAS DY>DX***********************************************
LIGNEY
	clr.b	IND
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
	move.w	d3,d0
;verifie si xb>xa ou yb>ya
	cmp.w	d6,d7
	bhi.s	NO_SWAPX2
	exg	d6,d7
	move.w	d6,CX1
	exg	d3,d4
	move.w	d3,d0
NO_SWAPX2 				
	cmp.w	d3,d4			
	bhi.s	NO_SWAPY2		
	exg	d3,d4			
	move.b	#1,IND			;indicateur pour type de pente
NO_SWAPY2	
;calcul de pente
	lsl.l	#8,d6			;multiplie par 512
	lsl.l	#1,d6			;pour enlever le reste
	lsl.l	#8,d7			;de la division
	lsl.l	#1,d7
	sub.w	d3,d4
	sub.l	d6,d7
	divu	d4,d7
	andi.l	#$ffff,d7		;multiplie par 128(512*128=65536)
	lsl	#7,d7			;valeur de pente en d7
;calcul de la position du point x de depart
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	move.w	d0,d3			;y debut
 	moveq.w #0,d1			;Compteur de pente
;sauve x_min et y _min pour test de comparaison
	move.w	d3,X_MIN
	cmpi.b	#1,IND
	beq.s	LINE_YB
	move.w	d6,Y_MIN
**********TRACE LIGNE/YA*******
LINE_YA	
	cmp.w	-2(a1),d6		;verifie si old_y=new_y
	beq.s	NO_SAVE
	move.w	d6,(a1)+
	move.w	d3,(a2)+
NO_SAVE
	addq.w	#1,d3
 	add.w 	d7,d1			; pente 
 	bcc.s 	NO_INC_LINEA2		; si pente>65536 passe y suivant
	addq.w	#1,d6			;Point suivant
NO_INC_LINEA2
 	dbf	d4,LINE_YA
 	rts
**********TRACE LIGNE/YB*******
LINE_YB
	cmp.w	-2(a1),d6		;verifie si old_y=new_y
	beq.s	NO_SAVE2
	move.w	d6,(a1)+
	move.w	d3,(a2)+
NO_SAVE2
	subq.w	#1,d3
 	add.w 	d7,d1			; pente 
 	bcc.s 	NO_INC_LINEB2		; si pente>65536 passe y suivant
 	addq.w	#1,d6			;Point suivant
NO_INC_LINEB2
 	dbf	d4,LINE_YB
	move.w	d6,Y_MIN
 	rts
											