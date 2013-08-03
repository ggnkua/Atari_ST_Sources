;version 280 sprites : Version Debug
;sprite en OR uniquement
DEC_ON	equ	0	;voir les sprites	0/1 -> on/off
DEB_ON	equ	0

	IFEQ	DEC_ON
BOUCLE	equ	360	;nombre de position de la courbe
	ELSE
BOUCLE	equ	1
	ENDC

DELAY	equ	20000	;delai d'attente entre 2 touches	

	IFEQ	DEC_ON
trajs	equ	210592
	ELSE
trajs	equ	352
	ENDC

ad200	equ	$200
ad202	equ	$202

COL1	EQU	$411
COL2	EQU	$666
COL3	EQU	$522

	opt	o+,w-,d+
;	opt	o+,w-,s-,d-

SECTION	TEXT

	jmp	go

move_or

	lea	160*8(a6),a6
	
	movem.l	(a4)+,d0-d6
fr00_0		
	add.w	(a5)+,a6
	or.w	d0,-8*160(a6)
	or.w	d1,-7*160(a6)
	or.w	d2,-6*160(a6)
	or.w	d3,-5*160(a6)
	or.l	d4,-4*160(a6)
	or.l	d5,-3*160(a6)
	or.l	d6,-2*160(a6)
	or.l	d6,-1*160(a6)
	or.l	d6,(a6)
	or.l	d6,1*160(a6)
	or.l	d5,2*160(a6)
	or.l	d4,3*160(a6)
	or.w	d3,4*160(a6)
	or.w	d2,5*160(a6)
	or.w	d1,6*160(a6)
	or.w	d0,7*160(a6)
	tst.w	(a5)
	bne.s	fr00_0

	adda.w	#2,a5
	movem.l	(a4)+,d0-d6
fr01_0		
	add.w	(a5)+,a6
	or.w	d0,-8*160(a6)
	or.w	d1,-7*160(a6)
	or.w	d2,-6*160(a6)
	or.w	d3,-5*160(a6)
	or.l	d4,-4*160(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.w	d3,4*160(a6)
	or.w	d2,5*160(a6)
	or.w	d1,6*160(a6)
	or.w	d0,7*160(a6)
	tst.w	(a5)
	bne.s	fr01_0

	adda.w	#2,a5
	movem.l	(a4)+,d0-d6
fr02_0		
	add.w	(a5)+,a6
	or.w	d0,-8*160(a6)
	or.w	d1,-7*160(a6)
	or.w	d3,-6*160(a6)
	or.w	d2,-5*160(a6)
	or.b	d5,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d5,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d5,3*160+8(a6)
	or.w	d2,4*160(a6)
	or.b	d5,4*160+8(a6)
	or.w	d3,5*160(a6)
	or.w	d1,6*160(a6)
	or.w	d0,7*160(a6)
	tst.w	(a5)
	bne.s	fr02_0

	adda.w	#2,a5
	movem.l	(a4)+,d1-d2/d4-d6
	moveq	#$fc,d0
fr03_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.w	d2,-7*160(a6)
	or.w	d1,-6*160(a6)
	or.b	d4,-6*160+8(a6)
	or.w	d3,-5*160(a6)
	or.b	d5,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d5,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d5,3*160+8(a6)
	or.w	d3,4*160(a6)
	or.b	d5,4*160+8(a6)
	or.w	d1,5*160(a6)
	or.b	d4,5*160+8(a6)
	or.w	d2,6*160(a6)
	or.b	d0,7*160+1(a6)
	tst.w	(a5)
	bne.s	fr03_0

	adda.w	#2,a5
	movem.l	(a4)+,d3-d6
	moveq	#$80,d7
	moveq	#$7e,d0
fr04_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.w	d3,-7*160(a6)
	or.b	d7,-7*160+8(a6)
	or.w	d2,-6*160(a6)
	or.b	d4,-6*160+8(a6)
	or.w	d1,-5*160(a6)
	or.b	d5,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d5,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d5,3*160+8(a6)
	or.w	d1,4*160(a6)
	or.b	d5,4*160+8(a6)
	or.w	d2,5*160(a6)
	or.b	d4,5*160+8(a6)
	or.w	d3,6*160(a6)
	or.b	d7,6*160+8(a6)
	or.b	d0,7*160+1(a6)
	tst.w	(a5)
	bne.s	fr04_0

	adda.w	#2,a5
	movem.l	(a4)+,d4-d6
	moveq	#$3f,d1
	moveq	#$c0,d7
fr05_0		
	add.w	(a5)+,a6
	or.b	d1,-8*160+1(a6)
	move.b	d3,-7*160+1(a6)
	or.b	d7,-7*160+8(a6)
	or.w	d3,-6*160(a6)
	or.b	d4,-6*160+8(a6)
	or.w	d2,-5*160(a6)
	or.b	d5,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d5,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d5,3*160+8(a6)
	or.w	d2,4*160(a6)
	or.b	d5,4*160+8(a6)
	or.w	d3,5*160(a6)
	or.b	d4,5*160+8(a6)
	move.b	d3,6*160+1(a6)
	or.b	d7,6*160+8(a6)
	or.b	d1,7*160+1(a6)
	tst.w	(a5)
	bne.s	fr05_0

	adda.w	#2,a5
	movem.l	(a4)+,d4-d6
	moveq	#$1f,d0
	moveq	#$7f,d1
	moveq	#$e0,d2
	moveq	#$f0,d7
fr06_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	bset	d0,-8*160+8(a6)
	or.b	d1,-7*160+1(a6)
	or.b	d2,-7*160+8(a6)
	move.b	d3,-6*160+1(a6)
	or.b	d7,-6*160+8(a6)
	or.w	d3,-5*160(a6)
	or.b	d5,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d5,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d5,3*160+8(a6)
	or.w	d3,4*160(a6)
	or.b	d5,4*160+8(a6)
	move.b	d3,5*160+1(a6)
	or.b	d7,5*160+8(a6)
	or.b	d1,6*160+1(a6)
	or.b	d2,6*160+8(a6)
	or.b	d0,7*160+1(a6)
	bset	d0,7*160+8(a6)
	tst.w	(a5)
	bne	fr06_0

	adda.w	#2,a5
	movem.l	(a4)+,d2-d7
	moveq	#$f,d0
	moveq	#$c0,d1
fr07_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.b	d1,-8*160+8(a6)
	or.b	d2,-7*160+1(a6)
	move.b	d3,-5*160+1(a6)
	or.b	d7,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d7,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.b	d6,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.b	d6,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.b	d6,-1*160+8(a6)
	or.l	d6,(a6)
	or.b	d6,8(a6)
	or.l	d6,1*160(a6)
	or.b	d6,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.b	d6,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d7,3*160+8(a6)
	move.b	d3,4*160+1(a6)
	or.b	d7,4*160+8(a6)
	or.b	d2,6*160+1(a6)
	or.b	d0,7*160+1(a6)
	or.b	d1,7*160+8(a6)
	swap	d2
	swap	d3
	swap	d7
	or.b	d2,-7*160+8(a6)
	or.b	d3,-6*160+1(a6)
	or.b	d7,-6*160+8(a6)
	or.b	d3,5*160+1(a6)
	or.b	d7,5*160+8(a6)
	or.b	d2,6*160+8(a6)
	swap	d2
	swap	d3
	swap	d7
	tst.w	(a5)
	bne	fr07_0

	adda.w	#2,a5
	movem.l	(a4)+,d2-d7
	moveq	#$7,d0
	moveq	#$e0,d1
fr08_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.b	d1,-8*160+8(a6)
	or.b	d2,-7*160+1(a6)
	or.b	d6,-5*160+1(a6)
	or.b	d7,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	or.b	d7,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	move.b	d3,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	move.b	d3,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	move.b	d3,-1*160+8(a6)
	or.l	d6,(a6)
	move.b	d3,8(a6)
	or.l	d6,1*160(a6)
	move.b	d3,1*160+8(a6)
	or.l	d5,2*160(a6)
	move.b	d3,2*160+8(a6)
	or.l	d4,3*160(a6)
	or.b	d7,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	or.b	d7,4*160+8(a6)
	or.b	d2,6*160+1(a6)
	or.b	d0,7*160+1(a6)
	or.b	d1,7*160+8(a6)
	swap	d2
	swap	d3
	swap	d7
	or.b	d2,-7*160+8(a6)
	or.b	d3,-6*160+1(a6)
	or.b	d7,-6*160+8(a6)
	or.b	d3,5*160+1(a6)
	or.b	d7,5*160+8(a6)
	or.b	d2,6*160+8(a6)
	swap	d2
	swap	d3
	swap	d7
	tst.w	(a5)
	bne	fr08_0

	adda.w	#2,a5
	movem.l	(a4)+,d0-d7
	moveq	#$3,d0
fr09_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.b	d1,-8*160+8(a6)
	or.b	d2,-7*160+1(a6)
	or.b	d5,-6*160+1(a6)
	or.b	d6,-5*160+1(a6)
	move.b	d3,-5*160+8(a6)
	or.l	d4,-4*160(a6)
	move.b	d3,-4*160+8(a6)
	or.l	d5,-3*160(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d5,2*160(a6)
	or.l	d4,3*160(a6)
	move.b	d3,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	move.b	d3,4*160+8(a6)
	or.b	d5,5*160+1(a6)
	or.b	d2,6*160+1(a6)
	or.b	d0,7*160+1(a6)
	or.b	d1,7*160+8(a6)
	swap	d1
	swap	d3
	swap	d7
	or.b	d3,-7*160+8(a6)
	or.b	d1,-6*160+8(a6)
	or.w	d7,-3*160+8(a6)
	or.w	d7,2*160+8(a6)
	or.b	d1,5*160+8(a6)
	or.b	d3,6*160+8(a6)
	swap	d1
	swap	d3
	swap	d7
	tst.w	(a5)
	bne	fr09_0

	adda.w	#2,a5
	movem.l	(a4)+,d1-d7
	moveq	#$1,d0
fr10_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+1(a6)
	or.b	d1,-8*160+8(a6)
	or.b	d3,-7*160+1(a6)
	or.b	d2,-7*160+8(a6)
	or.b	d4,-6*160+1(a6)
	or.b	d6,-5*160+1(a6)
	or.l	d3,-4*160(a6)
	or.l	d4,-3*160(a6)
	or.l	d5,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d4,2*160(a6)
	or.l	d5,2*160+8(a6)
	or.l	d3,3*160(a6)
	or.b	d6,4*160+1(a6)
	or.b	d4,5*160+1(a6)
	or.b	d3,6*160+1(a6)
	or.b	d2,6*160+8(a6)
	or.b	d0,7*160+1(a6)
	or.b	d1,7*160+8(a6)
	swap	d1
	swap	d2
	move.b	d1,-6*160+8(a6)
	or.w	d2,-5*160+8(a6)
	or.w	d2,-4*160+8(a6)
	or.w	d2,3*160+8(a6)
	or.w	d2,4*160+8(a6)
	move.b	d1,5*160+8(a6)
	swap	d1
	swap	d2
	tst.w	(a5)
	bne	fr10_0

	adda.w	#2,a5
	movem.l	(a4)+,d1-d2/d4-d7
	moveq	#$fc,d0
fr11_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+8(a6)
	or.b	d2,-7*160+1(a6)
	move.b	d1,-7*160+8(a6)
	or.b	d3,-6*160+1(a6)
	or.b	d6,-5*160+1(a6)
	or.l	d2,-4*160(a6)
	or.l	d4,-4*160+8(a6)
	or.l	d3,-3*160(a6)
	or.l	d5,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d3,2*160(a6)
	or.l	d5,2*160+8(a6)
	or.l	d2,3*160(a6)
	or.l	d4,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	or.b	d3,5*160+1(a6)
	or.b	d2,6*160+1(a6)
	move.b	d1,6*160+8(a6)
	or.b	d0,7*160+8(a6)
	swap	d1
	swap	d4
	or.w	d1,-6*160+8(a6)
	or.w	d4,-5*160+8(a6)
	or.w	d4,4*160+8(a6)
	or.w	d1,5*160+8(a6)
	swap	d1
	swap	d4
	tst.w	(a5)
	bne	fr11_0

	adda.w	#2,a5
	movem.l	(a4)+,d1-d7
	moveq	#$7e,d0
fr12_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+8(a6)
	or.b	d2,-7*160+1(a6)
	or.w	d1,-7*160+8(a6)
	or.b	d4,-6*160+1(a6)
	or.b	d6,-5*160+1(a6)
	or.l	d2,-4*160(a6)
	or.l	d3,-4*160+8(a6)
	or.l	d4,-3*160(a6)
	or.l	d5,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d4,2*160(a6)
	or.l	d5,2*160+8(a6)
	or.l	d2,3*160(a6)
	or.l	d3,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	or.b	d4,5*160+1(a6)
	or.b	d2,6*160+1(a6)
	or.w	d1,6*160+8(a6)
	or.b	d0,7*160+8(a6)
	swap	d1
	swap	d3
	or.w	d1,-6*160+8(a6)
	or.w	d3,-5*160+8(a6)
	or.w	d3,4*160+8(a6)
	or.w	d1,5*160+8(a6)
	swap	d1
	swap	d3
	tst.w	(a5)
	bne	fr12_0

	adda.w	#2,a5
	movem.l	(a4)+,d4/d6-d7
	moveq	#$3f,d0
	moveq	#$c0,d1
	moveq	#$e0,d3
fr13_0		
	add.w	(a5)+,a6
	or.b	d0,-8*160+8(a6)
	or.w	d1,-7*160+8(a6)
	or.b	d2,-6*160+1(a6)
	or.w	d3,-6*160+8(a6)
	or.b	d6,-5*160+1(a6)
	or.b	d6,-4*160+1(a6)
	or.l	d5,-4*160+8(a6)
	or.l	d2,-3*160(a6)
	or.l	d4,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d2,2*160(a6)
	or.l	d4,2*160+8(a6)
	or.b	d6,3*160+1(a6)
	or.l	d5,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	or.b	d2,5*160+1(a6)
	or.w	d3,5*160+8(a6)
	or.w	d1,6*160+8(a6)
	or.b	d0,7*160+8(a6)
	swap	d5
	or.w	d5,-5*160+8(a6)
	or.w	d5,4*160+8(a6)
	swap	d5
	tst.w	(a5)
	bne.s	fr13_0

	adda.w	#2,a5
	movem.l	(a4)+,d0-d1/d4-d7
	moveq	#$f0,d2
	moveq	#$f8,d3
fr14_0		
	add.w	(a5)+,a6
	or.w	d0,-8*160+8(a6)
	or.w	d1,-7*160+8(a6)
	or.w	d2,-6*160+8(a6)
	or.b	d6,-5*160+1(a6)
	or.w	d3,-5*160+8(a6)
	or.b	d6,-4*160+1(a6)
	or.l	d4,-4*160+8(a6)
	or.l	d5,-3*160+8(a6)
	or.l	d6,-2*160(a6)
	or.l	d7,-2*160+8(a6)
	or.l	d6,-1*160(a6)
	or.l	d7,-1*160+8(a6)
	or.l	d6,(a6)
	or.l	d7,8(a6)
	or.l	d6,1*160(a6)
	or.l	d7,1*160+8(a6)
	or.l	d5,2*160+8(a6)
	or.b	d6,3*160+1(a6)
	or.l	d4,3*160+8(a6)
	or.b	d6,4*160+1(a6)
	or.w	d3,4*160+8(a6)
	or.w	d2,5*160+8(a6)
	or.w	d1,6*160+8(a6)
	or.w	d0,7*160+8(a6)
	swap	d6
	or.b	d6,-3*160+1(a6)
	or.b	d6,2*160+1(a6)
	swap	d6
	tst.w	(a5)
	bne.s	fr14_0

	adda.w	#2,a5
	movem.l	(a4)+,d0-d2/d4-d6
	moveq	#$1,d7
	moveq	#$fc,d3
fr15_0		
	add.w	(a5)+,a6
	or.w	d0,-8*160+8(a6)
	or.w	d1,-7*160+8(a6)
	or.w	d2,-6*160+8(a6)
	or.w	d3,-5*160+8(a6)
	or.l	d4,-4*160+8(a6)
	or.w	d7,-3*160(a6)
	or.l	d5,-3*160+8(a6)
	or.w	d7,-2*160(a6)
	or.l	d6,-2*160+8(a6)
	or.w	d7,-1*160(a6)
	or.l	d6,-1*160+8(a6)
	or.w	d7,(a6)
	or.l	d6,8(a6)
	or.w	d7,1*160(a6)
	or.l	d6,1*160+8(a6)
	or.w	d7,2*160(a6)
	or.l	d5,2*160+8(a6)
	or.l	d4,3*160+8(a6)
	or.w	d3,4*160+8(a6)
	or.w	d2,5*160+8(a6)
	or.w	d1,6*160+8(a6)
	or.w	d0,7*160+8(a6)
	tst.w	(a5)
	bne.s	fr15_0

	adda.w	#2,a5

	rts

;*************************

go	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	save(pc),a0
	move.l	d0,(a0)

	lea	newpile(pc),a7

	bsr	sauve
	bsr.s	init
	bsr	cls
	bsr	back
	bsr	l_init
	bsr	cpal
	bsr	lance	
	bra	test_return

init	movem.l	noir(pc),d0-a6
	moveq	#0,d1
	lea	datas(pc),a5
	add.l	#trajs,a5
	move.l	a5,d0
cherch	add.l	#256,d1	
	cmp.l	d1,d0
	bpl.s	cherch
	lea	ecran1(pc),a1
	move.l	d1,(a1)
	lea	$ffff8201.w,a0
	stop	#$2300
	stop	#$2300
	move.b	1(a1),(a0)
	move.b	2(a1),2(a0)

	move.b  #0,$ffff8260.w
 	move.b  #2,$ffff820a.w

	movem.l	noir(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	rts

cls 	lea	datas(pc),a0
	add.l	#trajs,a0
	moveq	#0,d0
	move.l	#8160-1,d1
.1	move.l	d0,(a0)+
	dbf	d1,.1
	rts


cpal	lea	palz(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

lance	move.w	#$2700,sr

	IFEQ	DEB_ON
	moveq	#0,d0
	move.l	d0,$fffffa06.w
	move.l	d0,$fffffa12.w
	
	lea	nvbl(pc),a5
	move.l	a5,$68.w
	move.l	a5,$110.w
	move.l	a5,$114.w
	move.l	a5,$120.w
	move.l	a5,$134.w
	
	lea	fvbl(pc),a5
	move.l	a5,$70.w
	ENDC
	
	move.w	#$2300,sr
	movem.l	noir(pc),d0-a6

	clr.w	ad200
	move.w	#DELAY,ad202

	bsr	affiche_frame
	bsr	affiche_delay
	bsr	sprit
	
	rts

sauve
	IFEQ	DEB_ON
	lea	mfp(pc),a5
	move.b	$fffffa07.w,(a5)+
	move.b	$fffffa09.w,(a5)+
	move.b	$fffffa13.w,(a5)+
	move.b	$fffffa15.w,(a5)+
	
	lea	vect(pc),a5
	move.l	$68.w,(a5)+
	move.l	$70.w,(a5)+
	move.l	$110.w,(a5)+ 
	move.l	$114.w,(a5)+
	move.l	$120.w,(a5)+
	move.l	$134.w,(a5)+ 
	ENDC

 	lea	resol(pc),a5
 	move.b  $ffff8260.w,(a5)
	lea	ancpal(pc),a5
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a5)

	lea	ancecr(pc),a5
	move.l	$44e.w,(a5)
 	rts

remet	move.w	#$2700,sr

	IFEQ	DEB_ON
	lea	mfp(pc),a5
	move.b	(a5)+,$fffffa07.w
	move.b	(a5)+,$fffffa09.w
	move.b	(a5)+,$fffffa13.w
	move.b	(a5)+,$fffffa15.w

	lea	vect(pc),a5
	move.l	(a5)+,$68.w
	move.l	(a5)+,$70.w
	move.l	(a5)+,$110.w
	move.l	(a5)+,$114.w
	move.l	(a5)+,$120.w
	move.l	(a5)+,$134.w
	ENDC

	move.w	#$2300,sr

	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w

	movem.l	noir(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	ancecr(pc),a1
	lea	$ffff8201.w,a0
	stop	#$2300
	stop	#$2300
	move.b	1(a1),(a0)
	move.b	2(a1),2(a0)
 	move.b  resol(pc),$ffff8260.w
 	move.b  #2,$ffff820a.w

	movem.l	ancpal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
 	move.b  #8,$fffffc02.w
	move.b	#$e,$484.w

.1	btst.b	#0,$fffffc00.w
	beq.s	.2
	move.b	$fffffc02.w,d0
	bra.s	.1	

.2	rts

fvbl	addq.b	#1,$466.w
nvbl	rte

back	move.l	ecran1(pc),a3
	lea	fond(pc),a0
	lea	160*25(a3),a1
	moveq	#15,d0
.2	moveq	#4,d1
.1	move.l	(a0),(a1)
	move.l	4(a0),8(a1)
	move.l	8(a0),16(a1)
	move.l	12(a0),24(a1)
	lea	32(a1),a1
	dbf	d1,.1
	lea	16(a0),a0
	dbf	d0,.2

	lea	160*25(a3),a3
	moveq	#3,d0
.3	lea	(a3),a1
	moveq	#15,d1
.4	moveq	#19,d2
.5	move.l	(a1),160*35(a1)
	lea	8(a1),a1
	dbf	d2,.5
	dbf	d1,.4
	lea	160*35(a3),a3
	dbf	d0,.3
	rts

l_init	lea	pos_b(pc),a6
	lea	datas(pc),a3
	move.l	a3,(a6)
	move.l	a3,4(a6)
	move.w	#BOUCLE,8(a6)

	lea	ecran1(pc),a1
	addq.l	#4,(a1)

	rts
	
sprit
 	move.l	ecran1(pc),a1
	moveq	#0,d0
	move.l	#4000-1,d1
.1	move.l	d0,(a1)
	lea	8(a1),a1
	dbf	d1,.1

	lea	precal(pc),a4
	move.l	pos_b(pc),a5
	move.l	ecran1(pc),a6

	jsr	move_or	

	lea	pos_b(pc),a6
	move.l	a5,(a6)

	subq.w	#1,8(a6)
	bne.s	.2

	move.w	#BOUCLE,8(a6)
	move.l	4(a6),(a6)
.2
	rts

;*************************

test_return
	tst.w	ad200
	beq.s	.1
	subq.w	#1,ad200
	bra	test_espace
.1	cmpi.b	#$1c,$fffffc02.w
	bne.s	.2
	move.w	ad202,ad200
	bsr	affiche_frame
	bsr	sprit
.2
test_plus
	cmpi.b	#$4e,$fffffc02.w
	bne.s	.2
	move.w	#2000,ad200
	cmpi.w	#30000,ad202
	beq.s	.2
	add.w	#1000,ad202
	bsr	affiche_delay
.2
test_moins
	cmpi.b	#$4a,$fffffc02.w
	bne.s	.2
	move.w	#2000,ad200
	tst.w	ad202
	beq.s	.2
	sub.w	#1000,ad202
	bsr	affiche_delay
.2
test_espace
	cmpi.b	#$39,$fffffc02.w
	bne	test_return
	lea	nvbl(pc),a0
	move.l	a0,$70.w
.1	cmpi.b	#$b9,$fffffc02.w
	bne.s	.1

	jsr	remet

	move.l	save(pc),-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.l	-(a7)
	trap	#1

affiche_delay
	move.l	ecran1(pc),a0
	lea	160*194-4(a0),a0
	move.l	a0,a2
	moveq	#0,d1
	moveq	#19,d0
.0	move.l	d1,(a2)
	lea	8(a2),a2
	dbf	d0,.0
	
	moveq	#-1,d1
	move.w	ad202,d0
	divu	#1500,d0
	subq.w	#1,d0
	tst.w	d0
	bpl.s	.1
	moveq	#0,d0
.1	cmpi.w	#20,d0
	blt.s	.2
	moveq	#19,d0
.2	move.l	d1,(a0)
	lea	8(a0),a0
	dbf	d0,.2
.3	
	rts

affiche_frame
p	set	187
q	set	-4

	lea	numero(pc),a1
	lea	frame(pc),a0
	move.w	pos_b+8(pc),d4
	moveq	#0,d6
	moveq	#0,d5
	move.w	#BOUCLE,d7
	sub.w	d4,d7
	move.b	d7,d5
	move.b	d7,d6
	lsr.w	#8,d7
	lsr.w	#4,d6
	and.w	#$f,d5

	move.l	ecran1(pc),a0

	lsl.w	#2,d7
	move.l	(a1,d7.w),d0
	move.l	d0,d4
	swap	d4
	move.l	d0,d1
	lsr.w	#4,d1
	move.l	d1,d2
	lsr.w	#4,d2
	move.l	d2,d3
	lsr.w	#4,d3
	andi.l	#$f,d0
	andi.l	#$f,d1
	andi.l	#$f,d2
	andi.l	#$f,d3
	andi.l	#$f,d4
	move.b	d4,(p+0)*160+q(a0)
	move.b	d3,(p+1)*160+q(a0)
	move.b	d2,(p+2)*160+q(a0)
	move.b	d1,(p+3)*160+q(a0)
	move.b	d0,(p+4)*160+q(a0)

	lsl.w	#2,d6
	move.l	(a1,d6.w),d0
	move.l	d0,d4
	swap	d4
	move.l	d0,d1
	lsr.w	#4,d1
	move.l	d1,d2
	lsr.w	#4,d2
	move.l	d2,d3
	lsr.w	#4,d3
	andi.l	#$f,d0
	andi.l	#$f,d1
	andi.l	#$f,d2
	andi.l	#$f,d3
	andi.l	#$f,d4
	move.b	d4,(p+0)*160+q+1(a0)
	move.b	d3,(p+1)*160+q+1(a0)
	move.b	d2,(p+2)*160+q+1(a0)
	move.b	d1,(p+3)*160+q+1(a0)
	move.b	d0,(p+4)*160+q+1(a0)

	lsl.w	#2,d5
	move.l	(a1,d5.w),d0
	move.l	d0,d4
	swap	d4
	move.l	d0,d1
	lsr.w	#4,d1
	move.l	d1,d2
	lsr.w	#4,d2
	move.l	d2,d3
	lsr.w	#4,d3
	andi.l	#$f,d0
	andi.l	#$f,d1
	andi.l	#$f,d2
	andi.l	#$f,d3
	andi.l	#$f,d4
	move.b	d4,(p+0)*160+q+8(a0)
	move.b	d3,(p+1)*160+q+8(a0)
	move.b	d2,(p+2)*160+q+8(a0)
	move.b	d1,(p+3)*160+q+8(a0)
	move.b	d0,(p+4)*160+q+8(a0)

	rts

frame	ds.w	1
numero	dc.l	$eaaae,$26a22,$6a24e,$c242c,$88ae2	;01234
	dc.l	$e8c2c,$68ca4,$e2488,$ea4ae,$4a62c	;56789
	dc.l	$4aeaa,$cacac,$68886			;abc
	dc.l	$caaac,$e8c8e,$e8c88			;def

;*************************

SECTION	DATA
	even
	ds.l	63
newpile	ds.l	1
noir	ds.l	16 
vect	ds.l	6
save	ds.l	1
mfp	ds.l	1
ancpal	ds.l	16
ecran1	ds.l	1
pos_b	ds.l	2
	ds.w	1
ancecr	ds.l	1
resol	ds.w	1
nbrspr	ds.w	1
precal
	dc.l	$000007E0,$00001FF8,$00003FFC,$00007FFE,$7FFE1C00,$FFFF3E00,$C7FF7F00
	dc.l	$000003F0,$00000FFC,$00001FFE,$00003FFF,$3FFF0E00,$7FFF1F00,$63FF3F80
	dc.l	$000001F8,$000007FE,$00001FFF,$00000FFF,$1FFF0700,$3FFF0F80,$31FF1FC0
	dc.l	$000007FF,$000003FF,$0FFF0380,$1FFF07C0,$18FF0FE0
	dc.l	$000001FF,$07FF01C0,$0FFF03E0,$0C7F07F0
	dc.l	$03FF00E0,$07FF01F0,$063F03F8
	dc.l	$01FF0070,$03FF00F8,$031F01FC
	dc.l	$00F0003F,$007F00FF,$00FF0038,$01FF007C,$018F00FE,$00F800FC
	dc.l	$00F8001F,$003F00FF,$007F001C,$00FF003E,$00C7007F,$00FC00FE
	dc.l	$001F0003,$00FE00F0,$003F000F,$00FC00FF,$003F000E,$007F001F,$0063003F,$FF808000
	dc.l	$00FF00F8,$FF8000FE,$001F0007,$003F000F,$FFC08000,$0031001F,$FFC0C000
	dc.l	$FF8000FF,$000F0003,$FFC08000,$FFE0C000,$0018000F,$FFE0E000
	dc.l	$FFC0FF80,$00070001,$FFE0C000,$000F0003,$FFF0E000,$000C0007,$7FF0F000
	dc.l	$FFF8F000,$00060003,$3FF8F800
	dc.l	$00001F80,$00007FE0,$FFF87000,$FFFCF800,$00030001,$1FFCFC00
	dc.l	$00000FC0,$00003FF0,$00007FF8,$FFFC3800,$FFFE7C00,$8FFEFE00

fond	dc.l	$FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF 
	dc.l	$C000FFFF,$0000FFFF,$0000FFFF,$0001FFFE 
	dc.l	$C000FFFF,$0000FFFF,$0000FFFF,$0001FFFE 
	dc.l	$C000FFFF,$0000FFFF,$0000FFFF,$0001FFFE 
	dc.l	$C070FFFF,$A082FFFF,$5F9CFFFF,$3601FFFE 
	dc.l	$C0D9FFDB,$B1C7B7CF,$46366E36,$7701F77E 
	dc.l	$C0D9FFD9,$B147B34F,$46366E76,$7701773E 
	dc.l	$C0D9FFD9,$B367B36F,$C636EE76,$7B017B3E 
	dc.l	$C0F9FFF9,$F366F366,$C636CE76,$6B016B3E 
	dc.l	$C0C1FFCF,$B3E6B3E6,$C636CE76,$6B016F3E 
	dc.l	$C0C1FFCF,$B366B366,$46364E76,$6B016F3E 
	dc.l	$C040FFCF,$A142B366,$421C6E7E,$2A016F3E 
	dc.l	$C000FFEF,$000097AF,$00006F78,$0001F57E 
	dc.l	$C000FFFF,$0000FFFF,$0000FFFF,$0001FFFE 
	dc.l	$C000FFFF,$0000FFFF,$0000FFFF,$0001FFFE 
	dc.l	$FFFFC000,$FFFF0000,$FFFF0000,$FFFF0000 
palz	dc.w	$000
	dc.w	$666,$232,$454,COL1
	dc.w	COL1,COL1,COL1,COL2
	dc.w	COL2,COL2,COL2,COL3
	dc.w	COL3,COL3,COL3
datas
traj	IFEQ	DEC_ON
	incbin	TRAJC()D.280
	ELSE
	dc.w	160,0
	rept	7
	dc.w	160*17,0
	endr
	dc.w	-160*17*7+16,0
	rept	7
	dc.w	160*17,0
	endr
	ENDC
ecran	ds.l	8320