; Source to be integrated in fullscreen lines

	move.w 	d1,(a6)
	move.l 	d1,(a6)
	move.w 	d1,$12(a6)
	move.l 	d1,$12(a6)
	move.l 	d1,a2
	move.l 	d1,a3
	movem.l $12(a5),d0-d3
	movem.l d0-d3,$12(a6)
	movem.l $12(a5),d1-d4
	movem.l d1-d4,$12(a6)
	move.l 	#$12341234,d7
	and.l 	d7,(a6)
	and.l 	d7,(a6)+
	move.l 	a0,d7
	or.l	d0,(a6)+
	or.l	d7,(a6)+
	or.w 	d0,(a6)+
	or.w 	d7,(a6)+
	or.w 	d7,128(a6)
	move.l 	d7,(a6)
	move.l 	d7,(a6)+
	move.l 	d7,$123(a6)
