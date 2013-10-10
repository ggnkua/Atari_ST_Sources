LINE_NEW
	movem.l	d0/a0-a1,-(sp)
	movem.l	clr,a0-a6/d0-d7
	move.w	CX1,d6			;x debut
 	move.w 	CX2,d7			;x fin	
	move.w	CY1,d3			;y debut
	move.w	CY2,d4			;y fin
;regarde si la droite est horizontale,si oui casos !!!
	cmp.w	d3,d4
	bne.s	NO_CASOS
	movem.l	(sp)+,d0/a0-a1
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
	moveq	#16,d5
	sub.w	d6,d7
	andi.l	#$ffff,d7
	sub.l	d3,d4
	lsl.l	d5,d4			;de la division
	divu.l	d7,d4
	cmpi.l	#$10000,d4			;au cas ou dx=dy	
	beq	OTHER_TRACE
	move	d4,a2
;calcul de la position du point x de depart
	move.w	CX1,d6
	moveq	#0,d4
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
 	add.w 	a2,d1			; pente 
 	addx	d4,d0			;y suivant
 	dbf	d7,LINE_XA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
 	rts
**********TRACE LIGNE/XB*******
LINE_XB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d6			;x suivant
 	add.w 	a2,d1			; pente 
	subx	d4,d0			;y suivant
 	dbf	d7,LINE_XB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
 	rts
****************************************************************
OTHER_TRACE
;calcul de la position du point x de depart
	move.w	CX1,d6
;calcul de la position du point x+y de depart
	MOVE.L	#$3111,D5			;cache on		
	MOVEC.L	D5,CACR
 	moveq.w 	#0,d1			;Compteur de pente
	move.w	YMIN,d5			;D5=YMIN
	cmpi.b	#1,IND
	beq.s	LINE_XB3
**********SI PENTE DE 1************************************************
LINE_XA3	
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d6			;x suivant
 	addq.w	#1,d0			;y suivant
 	dbf	d7,LINE_XA3
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
 	rts
**********TRACE LIGNE/XB*******
LINE_XB3
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	move.w	d6,(a0,d2.w*2)
	addq.w	#1,d6			;x suivant
 	subq.w	#1,d0			;y suivant
 	dbf	d7,LINE_XB3
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
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
	moveq	#16,d5
	sub.w	d3,d4
	andi.l	#$ffff,d4
	sub.l	d6,d7
	lsl.l	d5,d7			;*65536
	divu.l	d4,d7
	move	d7,a2
;calcul de la position du point x de depart
	moveq	#0,d7
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
	cmp.w	(a1,d2.w*2),d6			;x>xmax
	ble.s	.NO_XMAX3
	move.w	d6,(a1,d2.w*2)
.NO_XMAX3
	cmp.w	(a0,d2.w*2),d6			;x<xmin
	bgt.s	.NO_XMIN3
	move.w	d6,(a0,d2.w*2)
.NO_XMIN3
	addq.w	#1,d0			; y suivant
	add.w 	a2,d1			; pente 
	addx	d7,d6			; x suivant
 	dbf	d4,LINE_YA
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
 	rts
**********TRACE LIGNE/YB*******
LINE_YB
	move.w	d0,d2
	sub.w	d5,d2			;y-ymin
	cmp.w	(a1,d2*2),d6			;x>xmax
	ble.s	NO_XMAX4
	move.w	d6,(a1,d2.w*2)
NO_XMAX4
	cmp.w	(a0,d2*2),d6			;x<xmin
	bgt.s	NO_XMIN4
	move.w	d6,(a0,d2.w*2)
NO_XMIN4
	subq.w	#1,d0			; y suivant
	add.w 	a2,d1			; pente 
	addx	d7,d6			; x suivant
 	dbf	d4,LINE_YB
	MOVE.L	#$2510,D0			;cache off		
	MOVEC.L	D0,CACR		
	movem.l	(sp)+,d0/a0-a1
 	rts																						
																						