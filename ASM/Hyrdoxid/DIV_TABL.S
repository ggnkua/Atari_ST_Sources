	bsr	PREC_DIVISION
	bsr	USE_DIV
PREC_DIVISION
;precalcul d'une table de division:512/1...512/n 
	lea	DIV_TABL,a0
	move	#512*16,d0
	move	#5000,d1
	moveq	#1,d2
BOUCLE_DIV
	move.l	#512*16,d0
	divu	d2,d0		;512/n
	move.w	d0,(a0)+
	addq	#1,d2
	dbf	d1,BOUCLE_DIV
	rts

USE_DIV
	clr	$ffff9800
	lea	DIV_TABL,a0
	move	#5*16,d0
	move	(a0,d0.w*2),d0
	rts

	SECTION	BSS
DIV_TABL	DS.L	500*2