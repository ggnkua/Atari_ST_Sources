; improved c2p by MiKRO, http://mikro.atari.org

; in	a0	chunky (aligned on 16 bytes boundary)
;	a1	screen (aligned on 4 bytes boundary)

; time between each write to ST-RAM:
; on 16 MHZ data bus: 2*4*(1/16000000) / (1/66666000) ~ 33 cycles
; on 24 MHZ data bus: 2*4*(1/24000000) / (1/66666000) ~ 22 cycles
; on 060 in "superscalar mode" take 20 instructions ~10 cycles
; on 040 or 060 in normal mode take 20 instructions ~20 cycles

; make sure you have enabled intruction & data & branch cache,
; enabled FIFO buffer for data cache and
; enabled "superscalar mode" in PCR !

c2p_falcon:	movem.l	d0-d7/a2-a6,-(sp)
		move.l	a0,a2
		adda.l	#320*240,a2
		move.l	#$0f0f0f0f,d4
		move.l	#$00ff00ff,d5

		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3
		
		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3

.c2p_loop:	tst.w	0*16+15(a0)			; line 0 & 1
		tst.w	2*16+15(a0)			; line 2 & 3
		tst.w	4*16+15(a0)			; line 4 & 5
		tst.w	6*16+15(a0)			; line 6 & 7
		tst.w	8*16+15(a0)			; line 8 & 9
		tst.w	10*16+15(a0)			; line 10 & 11
		tst.w	12*16+15(a0)			; line 12 & 13
		tst.w	14*16+15(a0)			; line 14 & 15

		REPT	15
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		move.l	a3,(a1)+
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a4,(a1)+
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
			
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.l	a5,(a1)+
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a6,(a1)+
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3

		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3
		ENDR
		
		cmpa.l	a0,a2
		beq.w	.end_loop
		
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		move.l	d3,d6
		lsr.l	#4,d7
		lsr.l	#4,d6
		move.l	a3,(a1)+
		eor.l	d0,d7
		eor.l	d2,d6
		and.l	d4,d7
		and.l	d4,d6
		eor.l	d7,d0
		eor.l	d6,d2
		lsl.l	#4,d7
		lsl.l	#4,d6
		eor.l	d7,d1
		eor.l	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#8,d7
		lsr.l	#8,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	d5,d7
		and.l	d5,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a4,(a1)+
		lsl.l	#8,d7
		lsl.l	#8,d6
		eor.l	d7,d2
		eor.l	d6,d3
			
		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#1,d7
		lsr.l	#1,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$55555555,d7
		and.l	#$55555555,d6
		eor.l	d7,d0
		eor.l	d6,d1
		add.l	d7,d7
		add.l	d6,d6
		eor.l	d7,d2
		eor.l	d6,d3
	
		move.w	d2,d7
		move.w	d3,d6
		move.l	a5,(a1)+
		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		move.w	d2,d0
		move.w	d3,d1
		move.w	d7,d2
		move.w	d6,d3

		move.l	d2,d7
		move.l	d3,d6
		lsr.l	#2,d7
		lsr.l	#2,d6
		eor.l	d0,d7
		eor.l	d1,d6
		and.l	#$33333333,d7
		and.l	#$33333333,d6
		eor.l	d7,d0
		eor.l	d6,d1
		move.l	a6,(a1)+
		lsl.l	#2,d7
		lsl.l	#2,d6
		eor.l	d7,d2
		eor.l	d6,d3

		swap	d0
		swap	d1
		swap	d2
		swap	d3

		movea.l	d0,a6
		movea.l	d2,a5
		movea.l	d1,a4
		movea.l	d3,a3
		
		bra.w	.c2p_loop
		
.end_loop:	move.l	a3,(a1)+
		move.l	a4,(a1)+
		move.l	a5,(a1)+
		move.l	a6,(a1)+
	
		movem.l	(sp)+,d0-d7/a2-a6
		rts