************************************************************
*  void c2p(a0.l * src, a1 * dst)
*
* Blit the virtual view buffer (8bpp) into the given physical
* screen (8bpl), by Mikael Kalms
************************************************************

		section	text
c2p		move.l	#$0f0f0f0f,d4
		move.l	#$00ff00ff,d5
		move.l	#$55555555,d6

		lea.l	(PHYSX*PHYSY.l,a0),a2	; &src[PHYSX*PHYSY] (upper limit)

		movem.l	(a0)+,d0-d3	; Load 16 pixels (8bpp)

		move.l	d1,d7
		lsr.l	#4,d7
		eor.l	d0,d7
		and.l	d4,d7
		eor.l	d7,d0
		lsl.l	#4,d7
		eor.l	d7,d1
		move.l	d3,d7
		lsr.l	#4,d7
		eor.l	d2,d7
		and.l	d4,d7
		eor.l	d7,d2
		lsl.l	#4,d7
		eor.l	d7,d3

		move.l	d2,d7
		lsr.l	#8,d7
		eor.l	d0,d7
		and.l	d5,d7
		eor.l	d7,d0
		lsl.l	#8,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#8,d7
		eor.l	d1,d7
		and.l	d5,d7
		eor.l	d7,d1
		lsl.l	#8,d7
		eor.l	d7,d3
	
		bra.s	.start
		
.pix16		movem.l	(a0)+,d0-d3	; Load 16 pixels (8bpp)
	
		move.l	d1,d7
		lsr.l	#4,d7
		eor.l	d0,d7
		and.l	d4,d7
		eor.l	d7,d0
		lsl.l	#4,d7
		eor.l	d7,d1
		move.l	d3,d7
		lsr.l	#4,d7
		eor.l	d2,d7
		and.l	d4,d7
		eor.l	d7,d2
		lsl.l	#4,d7
		eor.l	d7,d3

		move.l	d2,d7
		lsr.l	#8,d7
		eor.l	d0,d7
		and.l	d5,d7
		eor.l	d7,d0
		lsl.l	#8,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#8,d7
		eor.l	d1,d7
		and.l	d5,d7
		eor.l	d7,d1
		lsl.l	#8,d7
		eor.l	d7,d3
	
		move.l	a3,(a1)+
		move.l	a4,(a1)+
		move.l	a5,(a1)+
		move.l	a6,(a1)+
	
.start		move.l	d2,d7
		lsr.l	#1,d7
		eor.l	d0,d7
		and.l	d6,d7
		eor.l	d7,d0
		add.l	d7,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#1,d7
		eor.l	d1,d7
		and.l	d6,d7
		eor.l	d7,d1
		add.l	d7,d7
		eor.l	d7,d3

		move.w	d2,d7
		move.w	d0,d2
		swap.w	d2
		move.w	d2,d0
		move.w	d7,d2
		move.w	d3,d7
		move.w	d1,d3
		swap.w	d3
		move.w	d3,d1
		move.w	d7,d3

		move.l	d2,d7
		lsr.l	#2,d7
		eor.l	d0,d7
		andi.l	#$33333333,d7
		eor.l	d7,d0
		lsl.l	#2,d7
		eor.l	d7,d2
		move.l	d3,d7
		lsr.l	#2,d7
		eor.l	d1,d7
		andi.l	#$33333333,d7
		eor.l	d7,d1
		lsl.l	#2,d7
		eor.l	d7,d3

		swap.w	d0
		swap.w	d1
		swap.w	d2
		swap.w	d3
		move.l	d0,a6
		move.l	d2,a5
		move.l	d1,a4
		move.l	d3,a3

		cmpa.l	a0,a2
		bne.w	.pix16

		move.l	a3,(a1)+	; Store 16 pixels (8bpl)
		move.l	a4,(a1)+
		move.l	a5,(a1)+
		move.l	a6,(a1)+
		rts
