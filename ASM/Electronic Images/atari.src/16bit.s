; Accurate 8x8 IDCT.
; a0 -> source
; a1 -> dest

		EXPORT dither_16bit
		
		IMPORT table_15bit,coded_picture_width,coded_picture_height

dither_16bit:
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	60+4(sp),a0
		move.l	60+8(sp),a1
		move.l	60+12(sp),a2
		move.l	60+16(sp),a4
		move.w	coded_picture_width,d6
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.w	coded_picture_height,d7
		move.w	d6,d4
		add.w	d4,d4
		lea	(a2,d6.w),a3
		lea	(a4,d4),a5
.y_lp:	move.w	d6,d5
.x_lp:	move.w	(a0)+,d0
		and.w	#$f0f0,d0
		move.w	(a1)+,d1
		lsr.w	#4,d1
		and.b	#$0f,d1
		or.w	d0,d1
		move.w	d1,d0
		clr.b	d1
		lea	(table_15bit,d1.l*2),a6
		move.b	(a2)+,d2
		move.w	(a6,d2.w*2),d3
		swap	d3
		move.b	(a2)+,d2
		move.w	(a6,d2.w*2),d3
		move.l	d3,(a4)+
		move.b	(a3)+,d2
		move.w	(a6,d2.w*2),d3
		swap	d3
		move.b	(a3)+,d2
		move.w	(a6,d2.w*2),d3
		lsl.w	#8,d0
		move.l	d3,(a5)+
		lea	(table_15bit,d0.l*2),a6
		move.b	(a2)+,d2
		move.w	(a6,d2.w*2),d3
		swap	d3
		move.b	(a2)+,d2
		move.w	(a6,d2.w*2),d3
		move.l	d3,(a4)+
		move.b	(a3)+,d2
		move.w	(a6,d2.w*2),d3
		swap	d3
		move.b	(a3)+,d2
		move.w	(a6,d2.w*2),d3
		move.l	d3,(a5)+
		
		subq	#4,d5
		bne.s	.x_lp	
		
		add.w	d4,a4
		add.w	d4,a5
		add.w	d6,a2
		add.w	d6,a3
		subq	#2,d7
		bne.s	.y_lp
		
		movem.l (sp)+,d0-d7/a0-a6
		moveq	#0,d0
		rts
		
		