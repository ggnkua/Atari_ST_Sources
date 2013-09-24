; Falcon demosystem
;
; Six bitplanes C2P routine by Kalms / TBL
; Adapted to do partial part of the screen

		section	text

bplbigwidth:	640						;Width of screen
bplwidth:	320						;Width of chunky
bplheight:	180						;Height

; --------------------------------------------------------------
c2p_6pl_hi:
c2p1x1_6_falcon_hi:
; --------------------------------------------------------------
; in		a0	chunky
;		a1	screen

		movem.l	d2-d7/a2-a6,-(sp)
		move.l	a0,a2
		move.l	#$0f0f0f0f,d4
		move.l	#$00ff00ff,d5
		move.l	#$55555555,d6

	ifne	0
	
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

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

	endc

		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

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
	
		move.l	d2,d7
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
		swap	d2
		move.w	d2,d0
		move.w	d7,d2
		move.w	d3,d7
		move.w	d1,d3
		swap	d3
		move.w	d3,d1
		move.w	d7,d3

		move.l	#$33333333,d7
		and.l	d7,d0
		and.l	d7,d2
		lsl.l	#2,d0
		or.l	d2,d0

		move.l	d3,d7
		lsr.l	#2,d7
		eor.l	d1,d7
		and.l	#$33333333,d7
		eor.l	d7,d1
		lsl.l	#2,d7
		eor.l	d7,d3

		swap	d0
		swap	d1
		swap	d3

		move.l	d0,a6
		move.l	d1,a5
		move.l	d3,a4

		move.w	#bplheight-1,.y
.pix_y:		move.w	#bplwidth/16-1,.x
.pix_x:		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	(a0)+,d2
		move.l	(a0)+,d3

		move.l	d1,d7
		lsr.l	#4,d7
		move.l	a4,(a1)+
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
		move.l	a5,(a1)+
		lsl.l	#4,d7
		eor.l	d7,d3

		move.l	d2,d7
		lsr.l	#8,d7
		eor.l	d0,d7
		and.l	d5,d7
		eor.l	d7,d0
		lsl.l	#8,d7
		eor.l	d7,d2
		move.l	a6,(a1)+
		move.l	d3,d7
		lsr.l	#8,d7
		addq.l	#4,a1
		eor.l	d1,d7
		and.l	d5,d7
		eor.l	d7,d1
		lsl.l	#8,d7
		eor.l	d7,d3
	
.start:		move.l	d2,d7
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
		swap	d2
		move.w	d2,d0
		move.w	d7,d2
		move.w	d3,d7
		move.w	d1,d3
		swap	d3
		move.w	d3,d1
		move.w	d7,d3

		move.l	#$33333333,d7
		and.l	d7,d0
		and.l	d7,d2
		lsl.l	#2,d0
		or.l	d2,d0

		move.l	d3,d7
		lsr.l	#2,d7
		eor.l	d1,d7
		and.l	#$33333333,d7
		eor.l	d7,d1
		lsl.l	#2,d7
		eor.l	d7,d3

		swap	d0
		swap	d1
		swap	d3

		move.l	d0,a6
		move.l	d1,a5
		move.l	d3,a4

		subq.w	#1,.x
		bpl	.pix_x

		lea	bplbigwidth-bplwidth(a1),a1

		subq.w	#1,.y
		bpl	.pix_y

		movem.l	(sp)+,d2-d7/a2-a6
		rts

.x:		dc.w	0
.y:		dc.w	0
