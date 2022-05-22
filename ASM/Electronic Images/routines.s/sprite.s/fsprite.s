
; Generate masks (inverted).
	lea	sprite(pc),a0
	move.l	masks(pc),a1
	move.w	#((2*56)*10)-1,d0
genmask:
	move.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	not.w	d1
	move.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	not.w	d2
	move.w	d2,(a1)+
	move.w	d1,(a1)+
	dbra	d0,genmask


putmask:
	move.w	d0,d1
	neg.w	d1
	add.w	#16,d1
	move.w	#%1111111111111111,d6
	move.w	d6,d7
	lsl.w	d1,d6
	lsr.w	d0,d7
	move.w	d7,a3
	move.w	d7,d3
	move.l	masks(pc),a0
	move.w	anoff(pc),d1
	add.w	mtopoff(pc),d1
	lsr.w	#2,d1
	adda.w	d1,a0
	moveq	#spritehg-1,d5
	sub.w	erase+2(pc),d5
	cmp.w	#0,a2
	bne	swapmask
	
maskit1:
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	ror.l	d0,d1
	move.w	d6,d4
	and.w	d1,d4
	or.w	d6,d1
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	swap	d1
	and.l	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+

	ror.l	d0,d2
	move.w	a3,d7
	or.w	d2,d7
	or.w	d6,d1
	and.w	d3,d2
	or.w	d4,d2
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	swap	d2
	and.l	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+

	lea	160-40(a1),a1
	dbra	d5,maskit1
	rts

swapmask:
	move.w	d0,-(sp)
	move.w	d0,d1
	moveq	#16,d0
	sub.w	d1,d0
maskit2:
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	swap	d1
	rol.l	d0,d1
	move.w	d6,d4
	and.w	d1,d4
	or.w	d6,d1
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	swap	d1
	and.l	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+

	swap	d2
	rol.l	d0,d2
	move.w	a3,d7
	or.w	d2,d7
	or.w	d6,d1
	and.w	d3,d2
	or.w	d4,d2
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	swap	d2
	and.l	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d2,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+
	and.w	d7,(a1)+

	lea	160-40(a1),a1
	dbra	d5,maskit2
	move.w	(sp)+,d0
	rts	

putdata:
	lea	sprite(pc),a0
	adda.w	anoff(pc),a0
	adda.w	mtopoff(pc),a0
	moveq	#spritehg-1,d7
	sub.w	erase+2(pc),d7
	move.w	#%1111111111111111,d5
	lsr.w	d0,d5
	move.w	d5,d6
	swap	d5
	move.w	d6,d5
	move.l	d5,d6
	not.l	d6
	move.l	d6,a3
	cmp.w	#0,a2
	bne	swapdata

data1:	
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d6
	move.l	a3,d4
	ror.l	d0,d1
	and.l	d1,d6
	and.l	d5,d1
	or.l	d1,(a1)+
	ror.l	d0,d2
	and.l	d2,d4
	and.l	d5,d2
	or.l	d2,(a1)+
	swap	d6
	swap	d4
	move.l	d4,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d4
	ror.l	d0,d1
	and.l	d1,d4
	and.l	d5,d1
	or.l	d6,d1
	or.l	d1,(a1)+
	ror.l	d0,d2
	move.l	a3,d6
	and.l	d2,d6
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d4
	swap	d6
	move.l	d6,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d6
	ror.l	d0,d1
	and.l	d1,d6
	and.l	d5,d1
	or.l	d4,d1
	or.l	d1,(a1)+
	ror.l	d0,d2
	move.l	a3,d4
	and.l	d2,d4
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d6
	swap	d4
	move.l	d4,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d4
	ror.l	d0,d1
	and.l	d1,d4
	and.l	d5,d1
	or.l	d6,d1
	or.l	d1,(a1)+
	ror.l	d0,d2
	move.l	a3,d6
	and.l	d2,d6
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d4
	swap	d6
	or.l	d4,(a1)+
	or.l	d6,(a1)+

	lea	160-40(a1),a1
	dbra	d7,data1
	rts

swapdata:
	move.w	d0,d1
	moveq	#16,d0
	sub.w	d1,d0
data2:	
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d6
	move.l	a3,d4
	swap	d1
	rol.l	d0,d1
	and.l	d1,d6
	and.l	d5,d1
	or.l	d1,(a1)+
	swap	d2
	rol.l	d0,d2
	and.l	d2,d4
	and.l	d5,d2
	or.l	d2,(a1)+
	swap	d6
	swap	d4
	move.l	d4,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d4
	swap	d1
	rol.l	d0,d1
	and.l	d1,d4
	and.l	d5,d1
	or.l	d6,d1
	or.l	d1,(a1)+
	swap	d2
	rol.l	d0,d2
	move.l	a3,d6
	and.l	d2,d6
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d4
	swap	d6
	move.l	d6,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d6
	swap	d1
	rol.l	d0,d1
	and.l	d1,d6
	and.l	d5,d1
	or.l	d4,d1
	or.l	d1,(a1)+
	swap	d2
	rol.l	d0,d2
	move.l	a3,d4
	and.l	d2,d4
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d6
	swap	d4
	move.l	d4,d3

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a3,d4
	swap	d1
	rol.l	d0,d1
	and.l	d1,d4
	and.l	d5,d1
	or.l	d6,d1
	or.l	d1,(a1)+
	swap	d2
	rol.l	d0,d2
	move.l	a3,d6
	and.l	d2,d6
	and.l	d5,d2
	or.l	d3,d2
	or.l	d2,(a1)+
	swap	d4
	swap	d6
	or.l	d4,(a1)+
	or.l	d6,(a1)+

	lea	160-40(a1),a1
	dbra	d7,data2

	rts
