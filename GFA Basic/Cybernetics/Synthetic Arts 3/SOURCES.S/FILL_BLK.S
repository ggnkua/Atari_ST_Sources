*-------------------------------------------------------------------------*
*									  *
*	SYNTHETIC ARTS III		      - METAL PRODUCTION 1992 -	  *
*									  *
*	Detourage de forme pour prise de bloc				  *
*									  *
*-------------------------------------------------------------------------*

	opt	o+
	
	output	e:\code\synthy.art\curent\fichiers.inl\detoure.inl
				
				* Param	:  1 Long: adresse pile 
				*	   1 Word: x
	lea	table(pc),a5	* 	   1 Word: y	
	move.l	4(sp),a6	* 	   1 Long: adr ecran 1
	move.l	a6,10(a5)	*	   1 Long: adr ecran 2
	move.w	#-1,(a6)+	*	   1 Long: adr var line A
	move.w	8(sp),(a6)+
	move.w	10(sp),(a6)+
	move.l	12(sp),a3	
	move.l	16(sp),a4
	move.l	20(sp),6(a5)
	
fill:	move.w	-(a6),d5	* Y
	move.w	-(a6),d4	* X
	tst.w	-(a6)		* Mode ?
	beq.s	norech
rech:	subq.w	#1,d4
	blt.s	endrech
	move.w	d4,d0		* Test point
	move.w	d5,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	rech		
endrech:
	addq.w	#1,d4
norech:

	moveq.l	#0,d3		* Test hauteur

	move.w	d4,(a5)		* X1
	move.w	d5,d7
	addq.w	#1,d7
	move.w	d5,d6
	subq.w	#1,d6		* Si y < 1
	
	blt.s	nohight
	move.w	d4,d0
	move.w	d6,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nohight
	move.w	#-1,(a6)+
	move.w	d4,(a6)+
	move.w	d6,(a6)+
	moveq.l	#-1,d3
nohight:
	
	cmp.w	#199,d5	
	bge.s	nolow
	move.w	d4,d0
	move.w	d7,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nolow
	move.w	#-1,(a6)+
	move.w	d4,(a6)+
	move.w	d7,(a6)+
	moveq.l	#1,d3
nolow:
	addq.w	#1,d4

	tst.w	d3
	beq.s	find
	bgt.s	find3
					* Recherche  normale

					* Recherche sans le haut
find2:							
	move.w	d4,d0
	subq.w	#1,d0
	move.w	d7,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nofound2_2
	move.w	d4,d0
	move.w	d7,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	nofound2_2
	clr.w	(a6)+
	move.w	d4,(a6)+
	move.w	d7,(a6)+
nofound2_2:

	addq.w	#1,d4
	cmp.w	#320,d4
	beq.s	exitfind2
	move.w	d4,d0
	move.w	d5,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	find2
exitfind2:
	bra	trace

find3:							
	move.w	d4,d0		
	subq.w	#1,d0
	move.w	d6,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nofound1_3
	move.w	d4,d0
	move.w	d6,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	nofound1_3
	clr.w	(a6)+
	move.w	d4,(a6)+
	move.w	d6,(a6)+
nofound1_3:

	addq.w	#1,d4
	cmp.w	#320,d4
	beq.s	exitfind3
	move.w	d4,d0
	move.w	d5,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	find3
exitfind3:
	bra.s	trace

find:							
	move.w	d4,d0		
	subq.w	#1,d0
	move.w	d6,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nofound1
	move.w	d4,d0
	move.w	d6,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	nofound1
	clr.w	(a6)+
	move.w	d4,(a6)+
	move.w	d6,(a6)+
nofound1:

	move.w	d4,d0
	subq.w	#1,d0
	move.w	d7,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	beq.s	nofound2
	move.w	d4,d0
	move.w	d7,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	nofound2
	clr.w	(a6)+
	move.w	d4,(a6)+
	move.w	d7,(a6)+
nofound2:

	addq.w	#1,d4
	cmp.w	#320,d4
	beq.s	exitfind
	move.w	d4,d0
	move.w	d5,d1
	move.l	a3,a0
	bsr	ptst
	tst.w	d0
	bne.s	find
exitfind:

trace:
	subq.w	#1,d4

	movem.l	d0-a6,-(sp)
	moveq.l	#-1,d0
	move.w	d0,-(sp)
	move.l	d0,-(sp)
	move.l	a4,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	movem.l	(sp)+,d0-a6

	move.l	2(a5),a0
	move.w	(a5),38(a0)
	move.w	d5,40(a0)
	move.w	d4,42(a0)	
	move.w	d5,44(a0)
	moveq.l	#-1,d0
	move.l	d0,24(a0)
	move.l	d0,28(a0)
	clr.w	36(a0)
	lea	6(a5),a1
	move.l	a1,46(a0)
	move.w	d0,50(a6)
	dc.w	$A004

	movem.l	d0-a6,-(sp)
	moveq.l	#-1,d0
	move.w	d0,-(sp)
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	movem.l	(sp)+,d0-a6

	move.l	2(a5),a0
	move.w	(a5),38(a0)
	move.w	d5,40(a0)
	move.w	d4,42(a0)	
	move.w	d5,44(a0)
	moveq.l	#0,d0
	move.l	d0,24(a0)
	move.l	d0,28(a0)
	clr.w	36(a0)
	lea	6(a5),a1
	move.l	a1,46(a0)
	move.w	d0,50(a6)
	dc.w	$A004
	
	cmp.l	10(a5),a6
	bgt	fill
	
	rts

ptst:	
	move.w	d1,d2			* y * 160 
	lsl.w	#5,d2			
	lsl.w	#7,d1			
	add.w	d2,d1
	add.w	d1,a0			* + Adr
	
	move.w	d0,d1
	and.w	#$fff0,d1
	lsr.w	#1,d1
	add.w	d1,a0			* Adr + Offset x en adr 
	
	and.w	#15,d0			* Offset pixel

	move.l	(a0)+,d1		
	move.l	(a0)+,d2
	lsl.l	d0,d1
	lsl.l	d0,d2

	moveq.l	#0,d0
	add.w	d2,d2
	addx.w	d0,d0
	swap	d2
	add.w	d2,d2
	addx.w	d0,d0

	add.w	d1,d1
	addx.w	d0,d0
	swap	d1
	add.w	d1,d1
	addx.w	d0,d0

	rts
	
	Section  data

table:	dc.w	0			* Sauvegarde x1
	dc.l	0			* Adresse var line a
	dc.l	-1			* Motif de remplissage
	dc.l	0			* Adr base de la pile
