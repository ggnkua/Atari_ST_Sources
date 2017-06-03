*****************************************************************
* ANTIALIASING TRANSLATABLE By METAL AGES From THE CYBERNETICS  * 
* For SYNTHETIC ARTS V 2.02					*	
*****************************************************************

	opt	a+,o+,p+	*options	

	move.l	4(sp),a1	*ecran+Y*160
	move.l	8(sp),a3	*ecran dest
	move.w	12(sp),d4	*x1
	move.w	14(sp),d5	*x2
	move.w	16(sp),d6	*y1
	move.w	18(sp),d7	*y2
	move.w	20(sp),a5	*puissance

	move.w	d4,a6		*sauve x1 pour loopy
	
loopy:
loopx:	moveq.l	#0,d1		*D1: MOYENNE
	move.w	a5,d2		*D2: NBRE DE POINTS TESTES

	move.w	d4,d0		*on travaille sur d0
	move.l	a1,a0		*et a0

	bsr.s	ptst		*POINT 1   : X/Y
	mulu.w	d2,d3
	add.w	d3,d1	
			
	subq.w  #1,d0		*POINT 2   : X-1/Y
	cmp.w	#0,d0		
	blt.s	asaut
	bsr.s	ptst		
	add.w	d3,d1
	addq.w	#1,d2
asaut:	

	addq.w  #2,d0		*POINT 3   : X+1/Y
	cmp.w	#319,d0	
	bgt.s	bsaut
	bsr.s	ptst		
	add.w	d3,d1
	addq.w	#1,d2
bsaut:	
	
	move.w  d4,d0		*POINT 4   : X/Y-1
	lea	-160(a0),a0	
	cmp.w	#1,d6	
	blt.s	csaut
	bsr.s	ptst		
	add.w	d3,d1
	addq.w	#1,d2
csaut:	
	lea	320(a0),a0	*POINT 5   : X/Y+1
	cmp.w	#198,d6	
	bgt.s	dsaut
	bsr.s	ptst		
	add.w	d3,d1
	addq.w	#1,d2
dsaut:	
	divu.w	d2,d1		*Calcul et affichage point
	move.w	d1,d3
	move.l	a3,a0
	move.w	d4,d0
	bsr.s	pset	

	addq.w	#1,d4		*GESTION BOUCLE X
	cmp.w	d5,d4
	ble.s	loopx
	move.w	a6,d4

	lea	160(a1),a1	*GESTION BOUCLE Y
	lea	160(a3),a3
	addq.w	#1,d6
	cmp.w	d7,d6
	ble.s	loopy
			
	rts

ptst:					*PROCEDURE TEST POINT 
					*A0: adr ec+y*160
					*D0: x
	move.l	a0,-(sp)
	move.l	d0,-(sp)	
	move.l	d1,-(sp)
	move.l	d2,-(sp)

	moveq.w	#0,d3
	move.w	d0,d2
	and.w	#$fff0,d0	
	lsr.w	#1,d0
	add.w	d0,a0
	and.w	#15,d2
	neg.w	d2
	add.w	#15,d2
	move.l	(a0)+,d0
	move.l	(a0),d1
	btst.l	d2,d0
	beq.s	saut1
	or.w	#2,d3
saut1:	swap	d0
	btst.l	d2,d0
	beq.s	saut2
	or.w	#1,d3
saut2:	btst.l	d2,d1
	beq.s	saut3
	or.w	#8,d3
saut3:	swap 	d1
	btst.l	d2,d1
	beq.s	saut4
	or.w	#4,d3
saut4:
	move.l	(sp)+,d2
	move.l	(sp)+,d1
	move.l	(sp)+,d0
	move.l	(sp)+,a0

	rts


pset:					*PROCEDURE POINT SET 
					*A0: adr ec+y*160
					*D0: x
					*D3: couleur
	move.l	a0,-(sp)	
	move.l	d0,-(sp)	
	move.l	d1,-(sp)
	move.l	d2,-(sp)

	move.w	d0,d2
	and.w	#$fff0,d0	
	lsr.w	#1,d0
	add.w	d0,a0
	and.w	#15,d2
	neg.w	d2
	add.w	#15,d2			*decalage dans d2+adr dans a0
	move.l	(a0)+,d0
	move.l	(a0),d1
	bclr.l	d2,d0	
	bclr.l	d2,d1	
	swap	d0
	swap	d1
	bclr.l	d2,d0	
	bclr.l	d2,d1	
	btst.l	#0,d3
	beq.s	saut12
	bset.l	d2,d0
saut12:	swap	d0
	btst.l	#1,d3
	beq.s	saut22
	bset.l	d2,d0
saut22:	btst.l	#2,d3
	beq.s	saut32
	bset.l	d2,d1
saut32:	swap 	d1
	btst.l	#3,d3
	beq.s	saut42
	bset.l	d2,d1
saut42:
	move.l	d0,-4(a0)
	move.l	d1,(a0)

	move.l	(sp)+,d2
	move.l	(sp)+,d1
	move.l	(sp)+,d0
	move.l	(sp)+,a0

	rts
