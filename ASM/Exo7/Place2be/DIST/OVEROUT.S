clear1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear12:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2+8,a0
	nop
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	movem.l	zero,d3-d7/a1-a4
	movem.l	d3-d6,(a0)
	lea	4*4(a0),a0
	dcb.w	89-23-12,$4e71
	rts
clear2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	movem.l	d3-d6,(a0)
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d6,4*4(a0)
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	movem.l	d3-d7/a1-a4,8*4(a0)
	movem.l	d3-d7/a1-a4,17*4(a0)
	movem.l	d3-d7/a1-a4,26*4(a0)
	movem.l	d3-d7/a1-a4,35*4(a0)
	move.w	d3,44*4(a0)
	lea	44*4+2(a0),a0
;	dcb.w	3,$4e71
	rts

diste1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR-14,a0
	lea	position,a2
	lea	letinit,a3
	rts
diste12:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89-15,$4e71
	move.l	log3,a0
	add.l	#204+230*HAUTEUR2-14,a0
	lea	position2,a2
	lea	letinit2,a3
	rts
diste2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	lea	14(a0),a0
	lea	texte2,a4
	move.w	(a2)+,d6
	ext.l	d6
	move.w	(a3)+,d7
	lea	(a4,d7.w),a4
	lea	troisplans2,a1
	add.l	(a4)+,a1
	lea	6(a1,d6.w),a1
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	subq.l	#6,a0
	lea	troisplans2,a1
	add.l	d6,a1
	move.l	a1,d4
	dcb.w	89-40,$4e71	
	rts
diste22:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	lea	14(a0),a0
	lea	texte22,a4
	move.w	(a2)+,d6
	ext.l	d6
	move.w	(a3)+,d7
	lea	(a4,d7.w),a4
	lea	troisplans2,a1
	add.l	(a4)+,a1
	lea	6(a1,d6.w),a1
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	subq.l	#6,a0
	lea	troisplans2,a1
	add.l	d6,a1
	move.l	a1,d4
	dcb.w	89-40,$4e71	
	rts
diste3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	dcb.w	2,$4e71
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	nop
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	
	rept	2
	move.l	d4,a1
	add.l	(a4)+,a1
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	addq.l	#2,a0
	move.l	(a1)+,d3
	or.l	d3,(a0)+
	move.w	(a1)+,d3
	or.w	d3,(a0)+
	subq.l	#6,a0
	endr
	dcb.w	2,$4e71
	rts
setcolorscroll:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
St	set	0
	rept	8
	move.l	pal_3plans+St,$ffff8240+St.w
St	set	St+4
	endr
	dcb.w	89-64,$4e71
	rts
