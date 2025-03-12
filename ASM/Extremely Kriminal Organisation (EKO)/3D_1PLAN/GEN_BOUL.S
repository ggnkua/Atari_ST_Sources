	opt	d+

calkul	
	move.w	#399,d7
	lea	stars,a0
.re
	movem.l	d0-a6,-(sp)
	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEX

	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEY

	move.w	#17,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$1ff,d0
	move.w	d0,ANGLEZ

	move.w	#300,X1
	move.w	#0,Y1
	move.w	#0,Z1
	bsr	CALCUL
	asl.l	#1,d0
	asl.l	#1,d1
	asl.l	#1,d2
	move.w	d0,X1
	move.w	d1,Y1
	move.w	d2,Z1
	movem.l	(sp)+,d0-a6
	move.w	X1,(a0)+		
	move.w	Y1,(a0)+		
	move.w	Z1,(a0)+		

	dbf	d7,.re
	nop
	nop
	nop
	nop




X1	dc.w	0
Y1	DC.W	0
Z1	DC.W	0
ANGLEX	DC.W	0                                             
ANGLEY	DC.W	0
ANGLEZ	DC.W	0
SINX	DC.W	0
COSX	DC.W	0
SINY	DC.W	0
COSY	DC.W	0
SINZ	DC.W	0
COSZ	DC.W	0
CALCUL	
	MOVEM.W	X1,D0-D5	
	ADD.W	D3,D3
	ADD.W	D4,D4
	ADD.W	D5,D5
	LEA	SINUS,A0
	LEA	SINX(PC),A1
	LEA	SINY(PC),A3
	LEA	SINZ(PC),A4
	MOVE.W	(A0,D3.W),(A1)
	MOVE.W	(A0,D4.W),$4(A1)
	MOVE.W	(A0,D5.W),$8(A1)
	LEA	COSINUS,A0
	LEA	COSX(PC),A2
	MOVE.W	(A0,D3.W),(A2)
	MOVE.W	(A0,D4.W),$4(A2)
	MOVE.W	(A0,D5.W),$8(A2)

	MOVEM.W	(A1),D3-D4	
       	MULS	D0,D4		
	NEG	D3	
	MULS	D1,D3
	ADD.L	D3,D4
	ADD.L	D4,D4
	SWAP	D4		* cos a*x-sin a*y= X=d4
	MOVEM.W	(A1),D5-D6	
       	MULS	D0,D5
	MULS	D1,D6
	ADD.L	D6,D5
	ADD.L	D5,D5
	SWAP	D5		* sin a*x+cos a*y= Y=d5

	MOVEM.W	(A3),D0-D1	* z= Z=d2
	MULS	D4,D1
	MULS	D2,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVEM.W	(A3),D6-D7	* cos b*X+sin b*Z=X' =d0 
	NEG	D6		
	MULS	D4,D6		
	MULS	D2,D7		
	ADD.L	D6,D7		
	ADD.L	D7,D7		
	SWAP 	D7		

	MOVEM.W	(A4),D1-D2	* cos b*Z-sin b*X=Z' =d7  
	MULS	D5,D2 		* Y= Y'=D5
	NEG	D1
	MULS	D7,D1
	ADD.L	D2,D1
	ADD.L	D1,D1
	SWAP 	D1		* cos c*Y'-sin c*Z'= YY''=D1
**********
	MOVEM.W	(A4),D2-D3	
	MULS	D5,D2 		
	MULS	D7,D3
	ADD.L	D3,D2
	ADD.L	D2,D2		 
	SWAP 	D2		*	XX''=D0    ZZ''=D2
**********	
	RTS	
*********************************
																																
SINUS		incbin	f:\PURE_C\new_sin.tab
		EVEN
COSINUS		EQU	SINUS+256



stars	ds.w	2000*3