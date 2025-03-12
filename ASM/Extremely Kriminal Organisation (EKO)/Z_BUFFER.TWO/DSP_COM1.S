
send_1_sur_x
	move.l	#$ffffff,d0
	moveq	#0,d1
	move.w	#1500-1,d7
	moveq	#0,d2
.re	btst	#1,$ffffa202.w
	beq.s	.re	
	move.l	d2,$ffffa204.w
	move.l	d0,d2
	addq	#2,d1
	divu.l	d1,d2
	dbf	d7,.re
	rts

send_coordonnees
	bsr	.wait
	move.l	#1,$ffffa204.w
	bsr	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	bsr	.wait
	move.l	d0,$ffffa204.w
	subq	#1,d1	
.re
	move.w	(a0)+,d2
	ext.l	d2
	bsr	.wait
	move.l	d2,$ffffa204.w
	move.w	(a0)+,d2
	ext.l	d2
	bsr	.wait
	move.l	d2,$ffffa204.w
	move.w	(a0)+,d2
	ext.l	d2
	bsr	.wait
	move.l	d2,$ffffa204.w
	dbf	d1,.re	

	bsr	.wait
	move.w	(a0)+,d3
	ext.l	d3
	move.l	d3,$ffffa204.w
	bsr.	.wait
	move.w	(a0)+,d2
	ext.l	d2
	move.l	d2,$ffffa204.w
	tst.l	d2
	beq.s	.nothing	
	subq	#1,d2
.rel
	bsr	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	bsr	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	bsr	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	bsr	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	bsr.s	.wait
	move.w	(a0)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	dbf	d2,.rel
.nothing
	move.l	a0,a1
	moveq	#0,d7
	subq	#1,d3
	move.w	d3,d4
.comp	move.w	(a1)+,d0
	lea	(a0,d0.w),a2
	move.w	(a2)+,d6
	add.w	d6,d7		
	dbf	d3,.comp

	subq	#1,d6		

.red	addq	#2,a2
	move.w	(a2)+,d2
	lea	(a2,d2.w*2),a2		
	dbf	d6,.red

	sub.l	a1,a2
	move.l	a2,d0
	lsr.w	#1,d0
	sub.w	d7,d0

	bsr.s	.wait
	move.l	d0,$ffffa204.w

.redif		
	bsr.s	.wait
	move.w	(a1)+,d1
	ext.l	d1
	move.l	d1,$ffffa204.w
	subq	#1,d1
.complik2	
	addq	#2,a1
	move.w	(a1)+,d2
	ext.l	d2
	bsr.s	.wait
	move.l	d2,$ffffa204.w
	subq	#1,d2
.complik1
	move.w	(a1)+,d3
	ext.l	d3
	move.l	d3,d0
	add.l	d3,d3
	add.l	d0,d3
	add.l	#768,d3
	bsr.s	.wait
	move.l	d3,$ffffa204.w
	dbf	d2,.complik1
	dbf	d1,.complik2	
	dbf	d4,.redif

	rts

.wait	btst	#1,$ffffa202.w
	beq.s	.wait
	rts

receive_coordonnees
	move.l	#$ffffa202,a6
	move.l	#$ffffa206,a5

	lea	new_p,a0
.r1	btst	#0,(a6)		
	beq.s	.r1	
	move.w	(a5),d0		; reception du nb de points
	lsl.w	#1,d0
	subq	#1,d0
.r2	btst	#0,(a6)		
	beq.s	.r2		; reception des nb*x et nb*y coordonnees
	move.w	(a5),(a0)+
	dbf	d0,.r2

.r3	btst	#0,(a6)		
	beq.s	.r3
	move.w	(a5),d0		; reception du nb d'objets
	lea	liste_aff,a0
	subq	#1,d0
	move.w	d0,d1		; d1 nb d objets-1
.r4	btst	#0,(a6)		
	beq.s	.r4
	move.w	(a5),(a0)+	; reception de la liste d affichage
	dbf	d0,.r4

	lea	receive_pv,a0
	lea	tab_receive_pv,a1
.r5	move.l	a0,(a1)+
.r6	btst	#0,(a6)		
	beq.s	.r6
	move.w	(a5),d2
	subq	#1,d2
.r7	btst	#0,(a6)		
	beq.s	.r7
	move.w	(a5),(a0)+
	dbf	d2,.r7
	dbf	d1,.r5
	rts

