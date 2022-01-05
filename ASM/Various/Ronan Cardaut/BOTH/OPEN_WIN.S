*****************************************************
*****************************************************
*****************************************************
*****	CE SOURCE EST INCLUS DANS AFF_FONT.S	*****
*****************************************************
*****************************************************
*****************************************************



*------------------------------------------------------------------------------
* recherche un slot dispo
* recherche le meilleur emplacement pour ouvrir la fenetre
*------------------------------------------------------------------------------

*in
*		d0:	no d‚sir‚ (-1 = hasard)
NEW_WINDOW::
	xref	WINDOW_LIST
	tst	d0
	bmi.s	.HAZARD

	lea	(WINDOW_LIST+4,d0.w*4),a0
	tst.l	(a0)		
	beq	.OK	

.HAZARD
	*-------------------*
	* recherche du premier slot
	*-------------------*
	lea	WINDOW_LIST,a0
	move	#31,d7
.LOOP0	move.l	(a0)+,d0
	beq.s	.OK
	dbra	d7,.LOOP0
	sub.l	a1,a1
	bra	.FIN		;plus de slot libre
.OK	
	subq	#4,a0
	move.l	a0,d0
	sub.l	#WINDOW_LIST,d0
	lsr.l	#2,d0
	
	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a1

	*-------------------*
	* on parcours tout l'‚cran
	* et on calcule la surface de la fenetre
	* … chaque fois
	*-------------------*
	*a0=	ptr_win
		
	sub.l	a2,a2		;surface
	moveq	#1,d7	
	move	RESO_Y,-(sp)
	subq	#1,(sp)

.YLOOP	moveq	#0,d6
	move	RESO_X,-(sp)
		
.XLOOP	move	d6,d0
	move	d7,d1
	move	d0,d2					
	move	d1,d3		;x1,y1,x2,y2
	bsr	check_coll
	bne	.INF	
	moveq	#3,d4

.LOOP
	tst	d4
	beq	.SURF	
	*-------------------*
	* on incremente
	* on v‚rifie s'il y a collision
	*-------------------*
	addq	#1,d2
	bsr	check_coll
	beq	.OK0
	subq	#1,d2
	bra	.SURF

.OK0	addq	#1,d3
	bsr	check_coll
	beq	.OK1
	subq	#1,d3
	and	#%10,d4
	bra	.SURF
.OK1	bra	.LOOP
	*-------------------*

.SURF	*-------------------*
	* calcul de la surface
	*-------------------*
	move	d2,d4
	sub	d0,d4
	move	d3,d5
	sub	d1,d5		
	muls	d5,d4
	bpl.s	.POS
	neg.l	d4
.POS	
	cmp.l	a2,d4
	ble.s	.INF
	sub	d0,d2
	sub	d1,d3
	cmp	#4,d2
	ble.s	.INF		
	cmp	#3,d3
	ble.s	.INF		
	move	d0,W_X1(a1)		
	move	d1,W_Y1(a1)		
	move	d2,Largeur(a1)
	move	d3,Hauteur(a1)
		
	move.l	d4,a2
	cmp.l	#12*12,a2
	bge.s	.OUT
.INF
	addq	#1,d6
	subq	#1,(sp)
	bne	.XLOOP
	addq	#2,sp

	addq	#1,d7
	subq	#1,(sp)
	bne	.YLOOP
	addq	#2,sp

.FIN	
	tst.l	a1
	beq.S	.ERREUR
	tst.l	a2
	beq.S	.ERREUR
	move.l	a1,(a0)		;place la fenetre
	rts

.ERREUR
	clr.l	(a0)		;plus de place … l'ecran
	sub.l	a1,a1
	rts
.OUT	addq	#4,sp
	bra.s	.FIN		

check_coll
	movem.l	d0-d7/a0-a1,-(sp)
	
	cmp	RESO_X,d2
	blt	.OKX
	st	d6
	bra.s	.FIN
.OKX	cmp	RESO_Y,d3
	blt	.OKY
	st	d6
	bra.s	.FIN
.OKY	


	lea	WINDOW_LIST,a0
	move	#31,d7
	moveq	#0,d6
.LOOP	move.l	(a0)+,d4
	beq.s	.OK0
	move.l	d4,a1	
	
	move	W_X1(a1),d4	
	move	W_Y1(a1),d5
	cmp	d4,d2
	blt.s	.OK0
	cmp	d5,d3
	blt.s	.OK0

	add	Largeur(a1),d4
	add	Hauteur(a1),d5
	subq	#1,d4			
	subq	#1,d5
	cmp	d4,d0
	bgt.s	.OK0			
	cmp	d5,d1
	bgt.s	.OK0		
	st	d6	
.OK0	dbra	d7,.LOOP
.FIN	tst	d6		

	movem.l	(sp)+,d0-d7/a0-a1
	rts
	




