dither_CPU:	move.w	coded_picture_width(pc),d5
			lea.l	chromframe,a0
			lea.l	lumframe,a1
			lea		(a1,d5),a2
			lea		dithered_image,a3
			lea		(a3,d5*2),a4
			move.w	coded_picture_height(pc),d6
			moveq	#0,d3
ydith_lp:	move.w	d5,d4
xdith_lp:	moveq	#0,d0
			moveq	#0,d1
			move.b	(a0)+,d0
			lsr.b	#3,d0
			lsl.l	#8,d0
			lsl.l	#5,d0
			move.b	(a0)+,d1
			lsr.b	#3,d1
			lsl.w	#8,d1
			add.l	d1,d0
			lea		(ytab,d0.l*2),a5
			move.b	(a1)+,d3
			move.w	(a5,d3*2),d2
			swap	d2
			move.b	(a1)+,d3
			move.w	(a5,d3*2),d2
			move.l	d2,(a3)+
			move.b	(a2)+,d3
			move.w	(a5,d3*2),d2
			swap	d2
			move.b	(a2)+,d3
			move.w	(a5,d3*2),d2
			move.l	d2,(a4)+
			subq	#2,d4
			bne.s	xdith_lp
			add.w	d5,a1
			add.w	d5,a2
			lea		(a3,d5*2),a3
			lea		(a4,d5*2),a4
			subq	#2,d6
			bne.s	ydith_lp
			rts
			
