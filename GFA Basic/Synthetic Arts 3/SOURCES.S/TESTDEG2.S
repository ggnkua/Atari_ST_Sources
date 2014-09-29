	output 	e:\code\synthy.art\curent\fichiers.inl\testdeg.inl

*-------------------------------------------------------------------------*
*	SYNTHETIC ARTS 2.6					1992	  *
*									  *
*	FOURNIT LA LISTE DES POINTS DEPART/ARRIVEE POUR AUTO-DEGRADE	  *
*	v 2								  *
*-------------------------------------------------------------------------*

	move.l	4(sp),a0	* ecran dans A0
	move.l	8(sp),a1	* ado dans A1
	lea	32000(a1),a2	* ado+32000 dans A2
	move.w	12(sp),d0	* x1
	add.w	d0,d0		* x1*4
	add.w	d0,d0		*
	lea	sauv(pc),a3	*
	move.w	d0,(a3)		* on sauve x1 * 4	
	move.w	14(sp),d1	* y1
	move.w	d1,d2		* adresse ecran + y1 * 160
	mulu.w	#160,d2		* 
	add.w	d2,a0		*
	move.w	16(sp),d2	* x2
	move.w	18(sp),d3	* y2	
	move.w	20(sp),a3	* debc
	move.w	22(sp),a4	* endc
	move.l	a2,a5		* exit = ado + 32000
	lea	32000(a2),a6	* exit2 = ado + 64000
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d2
	add.w	d2,d2
	add.w	d3,d3
	add.w	d3,d3
	moveq.l	#0,d7

loop:				
	move.w	d0,d6		* adr point
	lsr.w	#2,d6		* x/4
	and.w	#$fff0,d6	* and $fff0
	lsr.w   #1,d6		* /2
	move.l	(a0,d6.w),d4	* va chercher le bitmap correspondant sur l'‚cran
	move.l	4(a0,d6.w),d5
	move.w	d0,d6		* 
	lsr.w	#2,d6		* x/4
	and.w	#15,d6		* offset pixel point
	lsl.l	d6,d4		* decalage d5 & d6 (bitmap)
	lsl.l	d6,d5
	moveq.l	#0,d6
	
	add.w	d5,d5		* 4em plan
	addx.w	d6,d6
	add.l	d5,d5
	addx.w	d6,d6		* 3em plan
	add.w	d4,d4		
	addx.w	d6,d6		* 2em plan
	add.l	d4,d4
	addx.w	d6,d6		* 1er plan

	cmp.w	d6,a3		* si couleur point = debc
	bne.s	nodebc
	move.w	d0,(a1)+	
	move.w	d1,(a1)+
	add.l	#$10000,d7	
	cmp.l	a5,a1
	beq.s	end1
	bra.s	noendc
nodebc:
	cmp.w	d6,a4		* si couleur point = endc
	bne.s	noendc
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#1,d7
	cmp.l	a6,a2
	beq.s	end2	
noendc:	
	addq.w	#4,d0
	cmp.w	d2,d0
	blt.s	loop
	move.w	sauv(pc),d0
	lea	160(a0),a0
	addq.w	#4,d1
	cmp.w	d3,d1
	blt.s	loop	

	move.l	d7,d0			* Renvoie le nombre de points (Dep/Arr)
	rts

end1:	bset.l	#31,d7
	move.l	d7,d0
	rts

end2:	bset.l	#15,d7
	move.l	d7,d0
	rts

sauv:	dc.w	0