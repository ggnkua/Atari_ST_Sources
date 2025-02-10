
Gourad_fill:
	lea		Gourad_edges,a1
	move.w	Gourad_sides,d7
	bgt.s		.cont
	rts
.cont	subq		#1,d7
	move.w	d7,d0
	mulu		#5,d0
	lea		(a1,d0.w*2),a2
	move.l	(a2)+,Point_X1
	move.l	(a2)+,Point_RED1
	move.w	(a2)+,Point_BLUE1
	lea		Div65536,a3
	move.w	#0000,Gourad_Bot	
	move.w	#1000,Gourad_Top
.loop	push.w	d7
	move.l	(a1)+,Point_X2
	move.l	(a1)+,Point_RED2
	move.w	(a1)+,Point_BLUE2
	move.w	Point_X1,d0
	move.w	Point_Y1,d1
	move.w	Point_X2,d2
	move.w	Point_Y2,d3
	cmp.w		Gourad_Top,d3
	bge.s		.NMin
	move.w	d3,Gourad_Top
.NMin	cmp.w		Gourad_Bot,d3
	ble.s		.NMax
	move.w	d3,Gourad_Bot
.NMax	lea		R_XBuffer,a6
	move.l	Point_RED1,Point_RED1_Copy
	move.w	Point_BLUE1,Point_BLUE1_Copy
	move.l	Point_RED2,Point_RED2_Copy
	move.w	Point_BLUE2,Point_BLUE2_Copy
	cmp.w		d1,d3
	beq		.Next
	bgt.s		.DYpl
.DYmi	lea		L_XBuffer,a6
	move.l	Point_RED1,Point_RED2_Copy
	move.w	Point_BLUE1,Point_BLUE2_Copy
	move.l	Point_RED2,Point_RED1_Copy
	move.w	Point_BLUE2,Point_BLUE1_Copy
	exg		d0,d2
	exg		d1,d3
.DYpl	lea		(a6,d1.w*8),a6
	move.w	d2,d4
	sub.w		d1,d3
	move.w	(a3,d3.w*2),Point_scale
	addq		#1,d3
	move.w	d3,a4				; height = (y2-y1)+1
	move.w	Point_RED1_Copy,d1
	move.w	Point_RED2_Copy,d5
	move.w	Point_GREEN1_Copy,d2
	move.w	Point_GREEN2_Copy,d6
	move.w	Point_BLUE1_Copy,d3
	move.w	Point_BLUE2_Copy,d7
	sub.w		d0,d4
	sub.w		d1,d5
	sub.w		d2,d6
	sub.w		d3,d7
	muls		Point_scale,d4
	muls		Point_scale,d5
	muls		Point_scale,d6
	muls		Point_scale,d7
	add.l		d4,d4
	add.l		d5,d5
	add.l		d6,d6
	add.l		d7,d7
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	move.w	d4,d3
	move.w	d5,d0
	move.w	d6,d1
	move.w	d7,d2
	lsr.w		d0
	lsr.w		d1
	lsr.w		d2
	lsr.w		d3
	swap		d0
	swap		d1
	swap		d2
	swap		d3
	move.l	d4,a0
	move.w	d5,d4
	move.w	d6,d5
	move.w	d7,d6
	move.w	a0,d7
	swap		d4
	swap		d5
	swap		d6
	swap		d7
	sub.l		a5,a5
	move.l	d3,a0
	add.l		d7,d3
	move.w	a0,d3
.slp	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	move.w	d3,(a6)+
	addx.l	d4,d0
	addx.l	d5,d1
	addx.l	d6,d2
	addx.l	d7,d3
	subq.l	#1,a4
	cmp.l		a5,a4
	bne.s		.slp
.Next	move.l	Point_RED2,Point_RED1
	move.w	Point_BLUE2,Point_BLUE1
	move.l	Point_X2,Point_X1
	pop.w		d7
	dbra		d7,.loop
	tst.b		TRUE_FLAG
	beq		Gourad_bpl

Gourad_true:
	move.w	Gourad_Top,d1		; ypos
	move.w	Gourad_Bot,d7
	sub.w		d1,d7				; height
	ble		.Stop
	lea		L_XBuffer,a0
	lea		(a0,d1.w*8),a0
	lea		R_XBuffer-L_XBuffer(a0),a6
	lea		Div65536,a1
	move.w	logwid,a4
	move.l	LOG_SCR,a5
	move.l	(LOG_Y.l,d1.w*4),d1
	add.l		d1,a5
.Line	swap		d7
	move.w	(a6)+,d7			; fetch x2
	move.w	(a0)+,d6			; fetch x1
	move.w	(a6)+,d3			; fetch r2
	move.w	(a0)+,d0			; fetch r1
	move.w	(a6)+,d4			; fetch g2
	move.w	(a0)+,d1			; fetch g1
	move.w	(a6)+,d5			; fetch b2
	move.w	(a0)+,d2			; fetch b1
	cmp.w		d6,d7
	bge.s		.posi
	move.l	d6,a2
	move.w	d7,d6
	move.w	a2,d7
	exg		d0,d3
	exg		d1,d4
	exg		d2,d5
.posi	sub.w		d6,d7
	lea		(a5,d6.w*2),a3		; line offset

	move.w	(a1,d7.w*2),d6		; 1/length
	sub.w		d0,d3
	sub.w		d1,d4
	sub.w		d2,d5
	muls		d6,d3
	muls		d6,d4
	muls		d6,d5
	add.l		d3,d3
	add.l		d4,d4
	add.l		d5,d5
	move.w	d3,d6
	move.w	d4,d3
	move.w	d5,d4
	move.w	d6,d5
	swap		d3
	swap		d4
	swap		d5
	ext.l		d0
	ext.l		d1
	ext.l		d2
	addq		#1,d7
	moveq		#4-1,d6
	and.w		d7,d6
	neg.w		d6
	lsr.w		#2,d7
	move.l	d6,a2
	lsl.w		#2,d6
	add.w		a2,d6
	lea		(.strt.w,pc,d6.w*4),a2
	move.w	d2,d6
	add.l		d5,d2
	move.w	d6,d2
	jmp		(a2)
.xlp	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	d6,(a3)+
	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	d6,(a3)+
	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	d6,(a3)+
	bfins		d0,d6{16:8+7}
	bfins		d1,d6{21:8+7}
	bfins		d2,d6{27:8+7}
	addx.l	d3,d0
	addx.l	d4,d1
	addx.l	d5,d2
	move.w	d6,(a3)+
.strt	dbra		d7,.xlp
	add.l		a4,a5
	swap		d7
	dbra		d7,.Line
.Stop	rts

Gourad_bpl:
	move.w	Gourad_Top,d1		; ypos
	move.w	Gourad_Bot,d7
	sub.w		d1,d7				; height
	ble		.Stop
	lea		L_XBuffer,a0
	lea		(a0,d1.w*8),a0
	lea		R_XBuffer-L_XBuffer(a0),a6
	lea		Div65536,a1
	move.l	LOG_SCR,a5
	move.l	(LOG_Y.l,d1.w*4),d1
	add.l		d1,a5
.Line	swap		d7
	move.w	(a6)+,d7			; fetch x2
	move.w	(a0)+,d6			; fetch x1
	move.w	(a6)+,d3			; fetch r2
	move.w	(a0)+,d0			; fetch r1
	addq.l	#4,a6
	addq.l	#4,a0
	cmp.w		d6,d7
	bge.s		.posi
	move.l	d6,a2
	move.w	d7,d6
	move.w	a2,d7
	exg		d0,d3
.posi	sub.w		d6,d7
	moveq		#-16,d2
	and.w		d6,d2
	lea		(a5,d2.w),a3
	moveq		#16-1,d2
	and.w		d6,d2
	neg.w		d2
	add.w		#16-1,d2
	move.w	(a1,d7.w*2),d6		; 1/length
	sub.w		d0,d3
	muls		d6,d3
	add.l		d3,d3
	move.w	d3,a4
	move.w	d2,d3
	ext.l		d0
	moveq		#0,d1
	movem.l	(a3)+,d2/d4/d5/d6
.dots	move.w	d0,d1
	lsr.w		#7,d1
	remap		d6
	swap		d6
	remap		d6
	swap		d6
	remap		d5
	swap		d5
	remap		d5
	swap		d5
	remap		d4
	swap		d4
	remap		d4
	swap		d4
	remap		d2
	swap		d2
	remap		d2
	swap		d2
	swap		d1
	add.w		a4,d1
	swap		d1
	swap		d3
	addx.w	d3,d0
	swap		d3
	subq		#1,d3
	bpl.s		.nres
	move.w	#16-1,d3
	movem.l	d2/d4/d5/d6,-16(a3)
	movem.l	(a3)+,d2/d4/d5/d6
.nres	dbra		d7,.dots
	movem.l	d2/d4/d5/d6,-16(a3)
	add.w		logwid,a5
	swap		d7
	dbra		d7,.Line
.Stop	rts


Div65536:	dc.w		0
		dc.w		32767
Mult		set		2
		rept		1280-1
		dc.w		(32768/Mult)
Mult		set		Mult+1
		endr
