; Atari ST/e synclock demosystem
; September 3, 2011
;
; sys/fade.s
;
; Generic colour fader
;
; input:
; a0 = start palette (will be overwritten with new palette)
; a1 = end palette

		section	text

fade:
		lea	fade_ste2norm,a2
		lea	fade_norm2ste,a3

		moveq	#16-1,d7
.loop:
		move.w	(a0),d0
		move.w	d0,d1
		move.w	d0,d2
		move.w	(a1)+,d3
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0f00,d0
		and.w	#$00f0,d1
		and.w	#$000f,d2
		and.w	#$0f00,d3
		and.w	#$00f0,d4
		and.w	#$000f,d5

		lsr.w	#8,d0
		lsr.w	#4,d1
		lsr.w	#8,d3
		lsr.w	#4,d4
		
		move.b	(a2,d0.w),d0
		move.b	(a2,d1.w),d1
		move.b	(a2,d2.w),d2
		move.b	(a2,d3.w),d3
		move.b	(a2,d4.w),d4
		move.b	(a2,d5.w),d5

		cmp.b	d0,d3
		beq.s	.reddone
		bgt.s	.redadd
		subq.b	#1,d0
		bra.s	.reddone
.redadd:	addq.b	#1,d0
.reddone:	cmp.b	d1,d4
		beq.s	.greendone
		bgt.s	.greenadd
		subq.b	#1,d1
		bra.s	.greendone
.greenadd:	addq.b	#1,d1
.greendone:	cmp.b	d2,d5
		beq.s	.bluedone
		bgt.s	.blueadd
		subq.b	#1,d2
		bra.s	.bluedone
.blueadd:	addq.b	#1,d2
.bluedone:
		move.b	(a3,d0.w),d0
		move.b	(a3,d1.w),d1
		move.b	(a3,d2.w),d2
		lsl.w	#8,d0
		lsl.w	#4,d1
		or.w	d1,d0
		or.w	d2,d0
		move.w	d0,(a0)+

		dbra	d7,.loop
		
		rts


component_fade:
		lea	fade_ste2norm,a2
		lea	fade_norm2ste,a3

		move.w	.shift,d3
		move.w	.and,d4
		move.w	.and2,d5

		moveq	#16-1,d7
.loop:

		move.w	(a0),d0
		move.w	(a1)+,d1

		move.w	d0,d2
		and.w	d5,d2

		and.w	d4,d0
		and.w	d4,d1
		lsr.w	d3,d0
		lsr.w	d3,d1
		
		move.b	(a2,d0.w),d0
		move.b	(a2,d1.w),d1

		cmp.b	d0,d1
		beq.s	.done
		bgt.s	.add
		subq.b	#1,d0
		bra.s	.done
.add:		addq.b	#1,d0
.done:
		move.b	(a3,d0.w),d0
		lsl.w	d3,d0
		or.w	d0,d2
		move.w	d2,(a0)+

		dbra	d7,.loop

		lea	.shift(pc),a0
		move.w	(a0),d0
		move.w	2(a0),(a0)+
		move.w	2(a0),(a0)+
		move.w	d0,(a0)+

		lea	.and(pc),a0
		move.w	(a0),d0
		move.w	2(a0),(a0)+
		move.w	2(a0),(a0)+
		move.w	d0,(a0)+

		lea	.and2(pc),a0
		move.w	(a0),d0
		move.w	2(a0),(a0)+
		move.w	2(a0),(a0)+
		move.w	d0,(a0)+
		
		rts
.shift:		dc.w	8,4,0
.and:		dc.w	$0f00,$00f0,$000f
.and2:		dc.w	$f0ff,$ff0f,$fff0

fade_ste2norm:	dc.b	$00,$02,$04,$06,$08,$0a,$0c,$0e,$01,$03,$05,$07,$09,$0b,$0d,$0f
fade_norm2ste:	dc.b	$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06,$0e,$07,$0f

			
		section	text
