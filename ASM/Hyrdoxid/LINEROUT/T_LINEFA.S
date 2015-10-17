LINE
	movem.l	CLR,d0/a1/a3-a6/d3-d7
	move.l	WORKECR,a0
	move.w	CX1,d6		;x debut
 	move.w 	CX2,d7		;x fin	
	move.w	CY1,d3		;y debut
	move.w	CY2,d4		;y fin
;verifie si x1=x2 ou y1=y2
	cmp.w	d3,d4
	beq	HORIZ_LINE
	cmp.w	d6,d7
	beq	VERT_LINE
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
	move.w	CX1,d6		;x debut
 	move.w 	CX2,d7		;x fin	
	move.w	CY1,d3		;y debut
	move.w	CY2,d4		;y fin
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
	move.b	#1,IND		;indicateur pour type de pente
NO_SWAPY
;calcul de pente
	lsl	#8,d3		;multiplie par 512
	lsl.l	#1,d3		;pour enlever le reste
	lsl	#8,d4		;de la division
	lsl.l	#1,d4
	sub.w	d6,d7
	sub.l	d3,d4
	divu	d7,d4
	andi.l	#$ffff,d4		;multiplie par 128(512*128=65536)
	lsl.l	#7,d4		;valeur de pente en d4
	cmpi.l	#$10000,d4		;au cas ou dx=dy	
	bne.s	NO_PRB	
	subq.l	#1,d4
NO_PRB
;calcul de la position du point x de depart
	moveq	#0,d6
	move.w	CX1,d6
	lsl	d6
;calcul de la position du point x+y de depart
	move	d7,(a2)+		;sauve longueur de ligne
	lea	Y_TABLE,a1
	add.l	(a1,d0*4),d6
	add.l	d6,a0
 	moveq.w 	#0,d1		;Compteur de pente
	moveq	#-1,d2
	MOVE.L	#$3111,D6
	MOVEC.L	D6,CACR
	cmpi.b	#1,IND
	beq.s	LINE_XB
**********TRACE LIGNE/XA*******
LINE_XA
	move.l	a0,(a2)+
 	move.w 	d2,(a0)+		;Affiche point
 	add.w 	d4,d1		; pente 
 	bcc.s 	NO_INC_LINEA	; si pente>65536 passe y suivant
 	lea 	640(a0),a0
NO_INC_LINEA
 	dbf	d7,LINE_XA
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
 	rts
**********TRACE LIGNE/XB*******
LINE_XB
	move.l	a0,(a2)+
 	move.w 	d2,(a0)+		;Affiche point
 	add.w 	d4,d1		; pente 
 	bcc.s 	NO_INC_LINEB	; si pente>65536 passe y suivant
 	lea 	-640(a0),a0
NO_INC_LINEB
 	dbf	d7,LINE_XB
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
 	rts
************************CAS DY>DX***********************************************
LIGNEY
	clr.b	IND
	move.w	CX1,d6		;x debut
 	move.w 	CX2,d7		;x fin	
	move.w	CY1,d3		;y debut
	move.w	CY2,d4		;y fin
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
	move.b	#1,IND		;indicateur pour type de pente
NO_SWAPY2	 
;calcul de pente
	lsl.l	#8,d6		;multiplie par 512
	lsl.l	#1,d6		;pour enlever le reste
	lsl.l	#8,d7		;de la division
	lsl.l	#1,d7
	sub.w	d3,d4
	sub.l	d6,d7
	divu	d4,d7
	andi.l	#$ffff,d7		;multiplie par 128(512*128=65536)
	lsl	#7,d7		;valeur de pente en d7
;calcul de la position du point x de depart
	moveq	#0,d6
	move.w	CX1,d6
	lsl	d6
;calcul de la position du point x+y de depart
	move	d4,(a2)+		;sauve longueur de ligne
	lea	Y_TABLE,a1
	add.l	(a1,d0.w*4),d6
	add.l	d6,a0
 	moveq	#0,d1		;Compteur de pente
	moveq	#-1,d2
	MOVE.L	#$3111,D6
	MOVEC.L	D6,CACR
	cmpi.b	#1,IND
	beq.s	LINE_YB
**********TRACE LIGNE/YA*******
LINE_YA
	move.l	a0,(a2)+
 	move.w 	d2,(a0)		;Affiche point
 	lea 	640(a0),a0
 	add.w 	d7,d1		; pente 
 	bcc.s 	NO_INC_LINEA2	; si pente>65536 passe y suivant
 	addq 	#2,a0		;Point suivant
NO_INC_LINEA2
 	dbf	d4,LINE_YA
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
 	rts
**********TRACE LIGNE/YB*******
LINE_YB
	move.l	a0,(a2)+
 	move.w 	d2,(a0)		;Affiche point
 	lea 	-640(a0),a0
 	add.w 	d7,d1		; pente 
 	bcc.s 	NO_INC_LINEB2	; si pente>65536 passe y suivant
 	addq 	#2,a0		;Point suivant
NO_INC_LINEB2
 	dbf	d4,LINE_YB
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
 	rts
*********************LIGNE HORIZONTALE**************
HORIZ_LINE
	move.w	d7,d5
	sub.w	d6,d7
	bpl.s	NO_NEG
	neg	d7		;distance en d7
NO_NEG	
	cmp.w	d6,d5
	bhi.s	NO_SWAPH
	exg	d6,d5
NO_SWAPH	
;pos x pt de depart
	lsl	d6
;pos x+y
	move	d7,(a2)+		;sauve longueur de ligne
	lea	Y_TABLE,a1
	add.l	(a1,d3.w*4),d6
	add.l	d6,a0
	moveq	#-1,d2
	MOVE.L	#$3111,D6
	MOVEC.L	D6,CACR
****TRACE HORIZONTALE****
LINE_H
	move.l	a0,(a2)+
	move.w	d2,(a0)+	
	dbf	d7,LINE_H
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
	rts
*********************LIGNE VERTICALE**************
VERT_LINE
	moveq	#-1,d2
	move.w	d4,d1
	sub.w	d3,d4
	bpl.s	NO_NEG2
	neg	d4		;distance en d7
NO_NEG2	
	cmp.w	d3,d1
	bhi.s	NO_SWAPV
	exg	d3,d1
NO_SWAPV
;pos x pt de depart
	lsl	d6
;pos x+y
	move	d4,(a2)+		;sauve longueur de ligne
	lea	Y_TABLE,a1
	add.l	(a1,d3.w*4),d6
	add.l	d6,a0
	MOVE.L	#$3111,D6
	MOVEC.L	D6,CACR
****TRACE HORIZONTALE****
LINE_V	
	move.l	a0,(a2)+
	move.w	d2,(a0)	
	lea	640(a0),a0
	dbf	d4,LINE_V
	MOVE.L	#$2510,D6
	MOVEC.L	D6,CACR
	rts
											