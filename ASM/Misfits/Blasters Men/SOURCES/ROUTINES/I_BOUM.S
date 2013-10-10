init_boum	lea tmp_atb,a0
	lea 4(a1),a2
	move.w #3,(a1)+	tempo explosion
	move.w #1,(a1)	nb d'explosions
	move.w d1,(a2)+	crd x explo 1
	move.w d2,(a2)+	crd y
	moveq #1,d0
	moveq #1,d6		test a droite
	moveq #0,d7		si explosion aussi
	bsr.s iboum_s1
	moveq #-1,d6		test a gauche
	moveq #0,d7
	bsr.s iboum_s1
	moveq #0,d6		test dessous
	moveq #1,d7
	bsr.s iboum_s1
	moveq #0,d6		test dessus
	moveq #-1,d7

iboum_s1	movem.l d1-d2,-(sp)
	moveq #2,d5
iboum_s2	add.w d6,d1
	bmi.s iboum_s99
	cmp.w #20,d1
	beq.s iboum_s99
	add.w d7,d2
	bmi.s iboum_s99
	cmp.w #12,d2
	beq.s iboum_s99
	move.w d2,d3
	mulu #20,d3
	add.w d1,d3
	move.b (a0,d3.w),d4	recupere val
	bne.s iboum_s3	du block sous explo.
	move.w d1,(a2)+	si zero alors pas de
	move.w d2,(a2)+	probleme continu explosion
	addq.w #1,(a1)
	dbra d5,iboum_s2
iboum_s3	cmp.b #2,d4		est-ce un mur cassable ?
	bne.s iboum_s99	non alors stop explos.
	move.w d1,(a2)+
	move.w d2,(a2)+
	addq.w #1,(a1)
	clr.b (a0,d3.w)	sinon plus de mur
	subq.w #1,nb_blk	blk -1
	add.w d0,(a3)		increment score
	addq.w #1,d0		blk suivant=score +grand
iboum_s99	movem.l (sp)+,d1-d2
	rts
