LINE_NEW
	movem.l	CLR,d0-d7/a1-a6
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
;regarde si la droite est horizontale,si oui casos !!!
	cmp.w	d3,d4
	bne.s	NO_CASOS
	rts
NO_CASOS	
;verifie les distances: si dx>dy ou dy>dx
	sub.w	d3,d4
	bpl.s	NO_SUB1
	neg	d4
NO_SUB1
	sub.w	d6,d7
	bpl.s	NO_SUB22
	neg	d7
NO_SUB22
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
	sub.w	d6,d7
	sub.l	d3,d4
	lsl	#8,d4			;de la division
	lsl.l	#2,d4
	divu	d7,d4
	andi.l	#$ffff,d4			;multiplie par 128(512*128=65536)
	lsl.l	#6,d4
	cmpi.l	#$10000,d4			;au cas ou dx=dy	
	bne.s	NO_PRB	
	subq.l	#1,d4
	addq	#1,d7
NO_PRB
;calcul de la position du point x de depart
	move.w	CX1,d6
	addq	#1,d7
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5			;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_XB
**********TRACE LIGNE/XA*******
LINE_XA	
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d6			;x suivant
 	add.w 	d4,d1			; pente 
 	bcc.s 	NO_INC_LINEA		; si pente>65536 passe y suivant
 	addq.w	#1,d0			;y suivant
NO_INC_LINEA
 	dbf	d7,LINE_XA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
**********TRACE LIGNE/XB*******
LINE_XB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d6			;x suivant
 	add.w 	d4,d1			; pente 
 	bcc.s 	NO_INC_LINEB		; si pente>65536 passe y suivant
 	subq.w	#1,d0			;y suivant
NO_INC_LINEB
 	dbf	d7,LINE_XB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
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
	sub.w	d3,d4
	sub.l	d6,d7
	lsl.l	#8,d7			;de la division
	lsl.l	#2,d7
	divu	d4,d7
	andi.l	#$ffff,d7			;multiplie par 128(512*128=65536)
	lsl	#6,d7			;valeur de pente en d7
	cmpi.l	#$10000,d7			;au cas ou dx=dy	
	bne.s	NO_PRB2	
	subq.l	#1,d7
NO_PRB2
;calcul de la position du point x de depart
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5		;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_YB
**********TRACE LIGNE/YA*******
LINE_YA
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d0			; y suivant
	add.w 	d7,d1			; pente 
 	bcc.s 	NO_INC_LINEA2		; si pente>65536 passe y suivant
	addq.w	#1,d6			; x suivant
NO_INC_LINEA2
 	dbf	d4,LINE_YA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
**********TRACE LIGNE/YB*******
LINE_YB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	subq.w	#1,d0			; y suivant
	add.w 	d7,d1			; pente 
 	bcc.s 	NO_INC_LINEB3		; si pente>65536 passe y suivant
	addq.w	#1,d6			; x suivant
NO_INC_LINEB3
 	dbf	d4,LINE_YB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
 	rts
																						