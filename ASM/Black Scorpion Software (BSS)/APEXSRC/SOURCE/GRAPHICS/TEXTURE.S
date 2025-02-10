*-----------------------------------------------------------------------*
*	Texture mapping code								*
*-----------------------------------------------------------------------*

texture_map:
	bsr		texture_clip
	move.l	polygon_out,a1
	move.l	texture_out,a2
	move.w	polysides,d7
	ble		.Stop
	move.w	d7,edgecount
	subq		#1,d7
	movem.w	(a1,d7.w*4),d0-d1		; first destination point
	movem.w	(a2,d7.w*4),d4-d5		; first source point
	move.w	#$3FFF,X1
	move.w	#$3FFF,Y1
	clr.w		X2
	clr.w		Y2
.loop	move.w	(a1)+,d2			; next destination point
	move.w	(a1)+,d3
	move.w	(a2)+,d6			; next source point
	move.w	(a2)+,d7
	cmp.w		Y1,d3
	bge.s		.NLow
	move.w	d3,Y1
.NLow	cmp.w		Y2,d3
	ble.s		.NMax
	move.w	d3,Y2
.NMax	cmp.w		X1,d2
	bge.s		.NmnX
	move.w	d2,X1
.NmnX	cmp.w		X2,d2
	ble.s		.NmnY
	move.w	d2,X2
.NmnY	bsr		calc_edge
	move.w	d2,d0
	move.w	d3,d1				; old=new
	move.w	d6,d4
	move.w	d7,d5
	subq		#1,edgecount
	bne.s		.loop
	move.w	Y1,d1				; ypos
	move.w	Y2,d0
	sub.w		d1,d0				; height
	ble		.Stop
	move.w	d0,d7
	move.w	d1,d2
	lsl.w		#3,d2
	add.w		d1,d1
	sub.w		d1,d2
	ext.l		d2
	lsr.w		d1
	lea		L_XBuffer,a0
	lea		R_XBuffer,a6
	add.l		d2,a0
	add.l		d2,a6
	bsr.s		draw_texture
.Stop	addq		#1,Y2
	addq		#1,X2
	move.l	X1,BX1
	move.l	X2,BX2
	rts

draw_texture:
	lea		DSPCTRL.w,a1
	lea		DSPLONG.w,a4
	tst.b		TRUE_FLAG
	beq		draw_texture_bpl
	tst.b		ACCEL
	bne		draw_texture_slow
	move.l	texture_ptr,a2
	move.l	LOG_SCR,a5
	move.w	logwid,d0
	mulu		d0,d1
	add.l		d1,a5
	move.w	d0,d6
	ext.l		d6
.Line	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d5
	move.w	(a6)+,d3
	move.w	(a6)+,d0
	move.w	(a6)+,d4
	bpl.s		.n1
	moveq		#0,d4
.n1	tst.w		d5
	bpl.s		.n2
	moveq		#0,d5
.n2	cmp.w		d2,d3				; line length
	bpl.s		.cont
	exg		d2,d3
	exg		d1,d0
	exg		d5,d4
.cont	sub.w		d2,d3
	addq		#1,d3
	dspwrite	d3,(a1),2(a4)
	dspwrite	d0,(a1),2(a4)
	dspwrite	d1,(a1),2(a4)
	dspwrite	d4,(a1),2(a4)
	dspwrite	d5,(a1),2(a4)
	lea		(a5,d2.w*2),a3		; line offset
	moveq		#8-1,d0
	and.w		d3,d0
	move.w	d0,d1
	lsl.w		#2,d0
	lsr.w		#3,d3
	sub.w		d1,d0
	neg.w		d0
.wo	btst		#0,(a1)
	beq.s		.wo
	jmp		.Dots(pc,d0.w*2)
.xlp	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
.Dots	dbra		d3,.xlp
.Next	add.l		d6,a5
	dbra		d7,.Line
.Stop	rts

draw_texture_bpl:
	tst.b		ACCEL
	bne		draw_texture_bpl_slow
	move.l	bpl_texture,a2
	move.l	LOG_SCR,a5
	move.w	logwid,d0
	mulu		d0,d1
	add.l		d1,a5
.Line	swap		d7
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d5
	move.w	(a6)+,d3
	move.w	(a6)+,d0
	move.w	(a6)+,d4
	bpl.s		.n1
	moveq		#0,d4
.n1	tst.w		d5
	bpl.s		.n2
	moveq		#0,d5
.n2	cmp.w		d2,d3				; line length
	bpl.s		.cont
	exg		d2,d3
	exg		d1,d0
	exg		d5,d4
.cont	sub.w		d2,d3
	addq		#1,d3
	dspwrite	d3,(a1),2(a4)
	dspwrite	d0,(a1),2(a4)
	dspwrite	d1,(a1),2(a4)
	dspwrite	d4,(a1),2(a4)
	dspwrite	d5,(a1),2(a4)
	moveq		#16-1,d5
	and.w		d2,d5
	neg.w		d5
	add.w		#16-1,d5
	moveq		#-16,d0
	and.w		d2,d0
	lea		(a5,d0.w),a3
	move.w	d3,d7
	subq.w	#1,d7
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	moveq		#-1,d6
.wo	btst		#0,(a1)
	beq.s		.wo
.xlp	move.l	(a4),d0
	move.b	(a2,d0.l),d0
	add.b		d0,d0
	addx.w	d4,d4
	add.b		d0,d0
	swap		d4
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	add.b		d0,d0
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	add.b		d0,d0
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	add.b		d0,d0
	swap		d1
	addx.w	d1,d1
	swap		d1
	bclr		d5,d6
	subq		#1,d5
	bpl.s		.skip
.draw	move.w	d6,d5
	swap		d6
	move.w	d5,d6
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d1,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d2,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d3,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d4,d5
	move.l	d5,(a3)+
	moveq		#-1,d6
	moveq		#15,d5
	dbra		d7,.xlp
	bra.s		.next
.skip	dbra		d7,.xlp
	addq		#1,d5
	lsl.l		d5,d1
	lsl.l		d5,d2
	lsl.l		d5,d3
	lsl.l		d5,d4
.last	move.w	d6,d5
	swap		d6
	move.w	d5,d6
	not.l		d6
	and.l		d6,d1
	and.l		d6,d2
	and.l		d6,d3
	and.l		d6,d4
	not.l		d6
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d1,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d2,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d3,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d4,d5
	move.l	d5,(a3)+
.next	add.w		logwid,a5
	swap		d7
	dbra		d7,.Line
.Stop	rts

draw_texture_slow:
	tst.b		TRUE_FLAG
	beq		draw_texture_bpl
	move.l	texture_ptr,a2
	move.l	LOG_SCR,a5
	move.w	logwid,d0
	mulu		d0,d1
	add.l		d1,a5
	move.w	d0,d6
	ext.l		d6
.Line	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d5
	move.w	(a6)+,d3
	move.w	(a6)+,d0
	move.w	(a6)+,d4
	bpl.s		.n1
	moveq		#0,d4
.n1	tst.w		d5
	bpl.s		.n2
	moveq		#0,d5
.n2	cmp.w		d2,d3				; line length
	bpl.s		.cont
	exg		d2,d3
	exg		d1,d0
	exg		d5,d4
.cont	sub.w		d2,d3
	addq		#1,d3
	dspwrite	d3,(a1),2(a4)
	dspwrite	d0,(a1),2(a4)
	dspwrite	d1,(a1),2(a4)
	dspwrite	d4,(a1),2(a4)
	dspwrite	d5,(a1),2(a4)
	lea		(a5,d2.w*2),a3		; line offset
	subq		#1,d3
	bmi.s		.Next
.xlp	btst		#0,(a1)
	beq.s		.xlp
	move.l	(a4),d0
	move.w	(a2,d0.l*2),(a3)+
	dbra		d3,.xlp
.Next	add.l		d6,a5
	dbra		d7,.Line
.Stop	rts

draw_texture_bpl_slow:
	move.l	bpl_texture,a2
	move.l	LOG_SCR,a5
	move.w	logwid,d0
	mulu		d0,d1
	add.l		d1,a5
.Line	swap		d7
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d5
	move.w	(a6)+,d3
	move.w	(a6)+,d0
	move.w	(a6)+,d4
	bpl.s		.n1
	moveq		#0,d4
.n1	tst.w		d5
	bpl.s		.n2
	moveq		#0,d5
.n2	cmp.w		d2,d3				; line length
	bpl.s		.cont
	exg		d2,d3
	exg		d1,d0
	exg		d5,d4
.cont	sub.w		d2,d3
	addq		#1,d3
	dspwrite	d3,(a1),2(a4)
	dspwrite	d0,(a1),2(a4)
	dspwrite	d1,(a1),2(a4)
	dspwrite	d4,(a1),2(a4)
	dspwrite	d5,(a1),2(a4)
	moveq		#16-1,d5
	and.w		d2,d5
	neg.w		d5
	add.w		#16-1,d5
	moveq		#-16,d0
	and.w		d2,d0
	lea		(a5,d0.w),a3
	move.w	d3,d7
	subq.w	#1,d7
	moveq		#0,d1
	moveq		#0,d2
	moveq		#0,d3
	moveq		#0,d4
	moveq		#-1,d6
.xlp	btst		#0,(a1)
	beq.s		.xlp
	move.l	(a4),d0
	move.b	(a2,d0.l),d0
	add.b		d0,d0
	addx.w	d4,d4
	add.b		d0,d0
	swap		d4
	addx.w	d4,d4
	swap		d4
	add.b		d0,d0
	addx.w	d3,d3
	add.b		d0,d0
	swap		d3
	addx.w	d3,d3
	swap		d3
	add.b		d0,d0
	addx.w	d2,d2
	add.b		d0,d0
	swap		d2
	addx.w	d2,d2
	swap		d2
	add.b		d0,d0
	addx.w	d1,d1
	add.b		d0,d0
	swap		d1
	addx.w	d1,d1
	swap		d1
	bclr		d5,d6
	subq		#1,d5
	bpl.s		.skip
.draw	move.w	d6,d5
	swap		d6
	move.w	d5,d6
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d1,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d2,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d3,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d4,d5
	move.l	d5,(a3)+
	moveq		#-1,d6
	moveq		#15,d5
	dbra		d7,.xlp
	bra.s		.next
.skip	dbra		d7,.xlp
	addq		#1,d5
	lsl.l		d5,d1
	lsl.l		d5,d2
	lsl.l		d5,d3
	lsl.l		d5,d4
.last	move.w	d6,d5
	swap		d6
	move.w	d5,d6
	not.l		d6
	and.l		d6,d1
	and.l		d6,d2
	and.l		d6,d3
	and.l		d6,d4
	not.l		d6
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d1,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d2,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d3,d5
	move.l	d5,(a3)+
	move.l	(a3),d5
	and.l		d6,d5
	or.l		d4,d5
	move.l	d5,(a3)+
.next	add.w		logwid,a5
	swap		d7
	dbra		d7,.Line
.Stop	rts

calc_edge:
	movem.l	d0-a6,-(sp)
	lea		R_XBuffer,a6
	cmp.w		d1,d3
	bgt.s		.DYpl
	blt.s		.DYmi
	movem.l	(sp)+,d0-a6
	rts
.DYmi	lea		L_XBuffer,a6
	exg		d0,d2
	exg		d1,d3
	exg		d4,d6
	exg		d5,d7
.DYpl	sub.w		d1,d3			; DY
	move.w	d3,a4
	addq		#1,d3
	ext.l		d3
	ext.l		d1	
	add.l		d1,d1			; Ypos
	add.l		d1,a6
	add.l		d1,a6
	add.l		d1,a6
	lea		6.w,a5
	cmp.w		d0,d2
	bpl.s		.cont
	exg		d0,d2
	exg		d4,d6
	exg		d5,d7
	lea		-6.w,a5
	move.w	a4,d1
	mulu		#6,d1
	add.l		d1,a6
.cont	sub.w		d0,d2
	addq		#1,d2
	swap		d2
	clr.w		d2
	divs.l	d3,d2
	move.l	d2,d1
	swap		d0
	clr.w		d0
	lsr.l		d2
	add.l		d2,d0
	swap		d0
	sub.w		d4,d6
	swap		d6
	clr.w		d6
	divs.l	d3,d6
	move.l	d6,d2	
	swap		d4
	move.w	d2,d4
	lsr.w		d4
	swap		d4
	sub.w		d5,d7
	bpl.s		.c3
	subq		#2,d7
.c3	addq		#1,d7
	swap		d7
	clr.w		d7
	divs.l	d3,d7
	move.l	d7,d3	
	swap		d5
	move.w	d3,d5
	lsr.w		d5
	swap		d5
	move.w	a4,d7
.clp	movem.w	d0/d4/d5,(a6)
	add.l		a5,a6
	swap		d0
	swap		d4
	swap		d5
	add.l		d1,d0
	add.l		d2,d4
	add.l		d3,d5
	swap		d0
	swap		d4
	swap		d5
	dbra		d7,.clp
.end	movem.l	(sp)+,d0-a6
	rts

*-------------------------------------------------------------------------*
*	Texture clipping									  *
*-------------------------------------------------------------------------*

texture_clip:
	clr.w		clip_x1
	clr.w		clip_y1
	move.w	CANVAS_WIDTH,d0
	subq		#1,d0
	move.w	d0,clip_x2
	move.w	CANVAS_HEIGHT,d0
	subq		#1,d0
	move.w	d0,clip_y2
	move.l	polygon_in,a0
	lea		polylist_2,a1
	move.l	texture_in,a5
	lea		textlist_2,a6
	lea		polyclips,a2
	move.w	polysides,d7
	bsr		CLIP_X1
	lea		polylist_2,a0
	lea		polylist_1,a1
	lea		textlist_2,a5
	lea		textlist_1,a6
	lea		polysides,a2
	move.w	polyclips,d7
	bsr		CLIP_Y1
	lea		polylist_1,a0
	lea		polylist_2,a1
	lea		textlist_1,a5
	lea		textlist_2,a6
	lea		polyclips,a2
	move.w	polysides,d7
	bsr		CLIP_X2
	lea		polylist_2,a0
	move.l	polygon_out,a1
	lea		textlist_2,a5
	move.l	texture_out,a6
	lea		polysides,a2
	move.w	polyclips,d7
	bsr		CLIP_Y2
.out	rts

CLIP_X1:	
	clr.w		(a2)
	subq		#1,d7
	bmi		.rts
	move.w	d7,d0
	add.w		d0,d0
	add.w		d0,d0
	move.l	a0,a3
	add.w		d0,a3
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.l	a5,a3
	add.w		d0,a3
	move.l	(a3)+,sX1			*
.edge	movem.w	(a0)+,d3-d4
	move.l	(a5)+,sX2			*
	cmp.w		clip_x1(pc),d1
	bmi.s		.x1_outside
	cmp.w		clip_x1(pc),d3
	bmi		.clip_x2
.all_inside
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	addq		#1,(a2)
	bra		.next
.x1_outside
	cmp.w		clip_x1(pc),d3
	bpl.s		.clip_x1
.all_outside
	bra		.next
.clip_x1
	move.w	clip_x1(pc),d0
	cmp.w		d1,d3
	blt.s		.rgt1
	bsr		intersect_x
	bra.s		.don1
.rgt1	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_x
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don1	addq		#1,(a2)
	bra		.next
.clip_x2
	move.w	clip_x1(pc),d0
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	cmp.w		d1,d3
	blt.s		.rgt2
	bsr		intersect_x
	bra.s		.don2
.rgt2	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_x
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don2	addq		#2,(a2)
.next	move.w	d3,d1			; x1,y1 = old x2,y1 clipped
	move.w	d4,d2
	move.l	sX2(pc),sX1			*
	dbra		d7,.edge
.rts	rts

CLIP_Y1:	
	clr.w		(a2)
	subq		#1,d7
	bmi		.rts
	move.w	d7,d0
	add.w		d0,d0
	add.w		d0,d0
	move.l	a0,a3
	add.w		d0,a3
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.l	a5,a3
	add.w		d0,a3
	move.l	(a3)+,sX1			*
.edge	movem.w	(a0)+,d3-d4
	move.l	(a5)+,sX2			*
	cmp.w		clip_y1(pc),d2
	bmi.s		.y1_outside
	cmp.w		clip_y1(pc),d4
	bmi		.clip_y2
.all_inside
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	addq		#1,(a2)
	bra		.next
.y1_outside
	cmp.w		clip_y1(pc),d4
	bpl.s		.clip_y1
.all_outside
	bra		.next
.clip_y1
	move.w	clip_y1(pc),d0
	cmp.w		d2,d4
	blt.s		.dwn1
	bsr		intersect_y
	bra.s		.don1
.dwn1	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_y
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don1	addq		#1,(a2)
	bra		.next
.clip_y2
	move.w	clip_y1(pc),d0
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	cmp.w		d2,d4
	blt.s		.dwn2
	bsr		intersect_y
	bra.s		.don2
.dwn2	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_y
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don2	addq		#2,(a2)
.next	move.w	d3,d1			; x1,y1 = old x2,y1 clipped
	move.w	d4,d2
	move.l	sX2(pc),sX1			*
	dbra		d7,.edge
.rts	rts

CLIP_X2:	
	clr.w		(a2)
	subq		#1,d7
	bmi		.rts
	move.w	d7,d0
	add.w		d0,d0
	add.w		d0,d0
	move.l	a0,a3
	add.w		d0,a3
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.l	a5,a3
	add.w		d0,a3
	move.l	(a3)+,sX1			*
.edge	movem.w	(a0)+,d3-d4
	move.l	(a5)+,sX2			*
	cmp.w		clip_x2(pc),d1
	bgt.s		.x1_outside
	cmp.w		clip_x2(pc),d3
	bgt		.clip_x2
.all_inside
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	addq		#1,(a2)
	bra		.next
.x1_outside
	cmp.w		clip_x2(pc),d3
	ble.s		.clip_x1
.all_outside
	bra		.next
.clip_x1
	move.w	clip_x2(pc),d0
	cmp.w		d1,d3
	blt.s		.rgt1
	bsr		intersect_x
	bra.s		.don1
.rgt1	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_x
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don1	addq		#1,(a2)
	bra		.next
.clip_x2
	move.w	clip_x2(pc),d0
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	cmp.w		d1,d3
	blt.s		.rgt2
	bsr		intersect_x
	bra.s		.don2
.rgt2	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_x
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don2	addq		#2,(a2)
.next	move.w	d3,d1			; x1,y1 = old x2,y1 clipped
	move.w	d4,d2
	move.l	sX2(pc),sX1			*
	dbra		d7,.edge
.rts	rts

CLIP_Y2:	
	clr.w		(a2)
	subq		#1,d7
	bmi		.rts
	move.w	d7,d0
	add.w		d0,d0
	add.w		d0,d0
	move.l	a0,a3
	add.w		d0,a3
	move.w	(a3)+,d1
	move.w	(a3)+,d2
	move.l	a5,a3
	add.w		d0,a3
	move.l	(a3)+,sX1			*
.edge	movem.w	(a0)+,d3-d4
	move.l	(a5)+,sX2			*
	cmp.w		clip_y2(pc),d2
	bgt.s		.y1_outside
	cmp.w		clip_y2(pc),d4
	bgt		.clip_y2
.all_inside
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	addq		#1,(a2)
	bra		.next
.y1_outside
	cmp.w		clip_y2(pc),d4
	ble.s		.clip_y1
.all_outside
	bra		.next
.clip_y1
	move.w	clip_y2(pc),d0
	cmp.w		d2,d4
	blt.s		.dwn1
	bsr		intersect_y
	bra.s		.don1
.dwn1	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)
	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_y
	move.l	(sp)+,sX2
	move.l	(sp)+,sX1
	move.l	(sp)+,d4
	move.l	(sp)+,d3
.don1	addq		#1,(a2)
	bra		.next
.clip_y2
	move.w	clip_y2(pc),d0
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.l	sX1(pc),(a6)+			*
	cmp.w		d2,d4
	blt.s		.dwn2
	bsr		intersect_y
	bra.s		.don2
.dwn2
	move.l	d3,-(sp)
	move.l	d4,-(sp)

	move.l	sX1(pc),-(sp)
	move.l	sX2(pc),-(sp)

	move.l	sX1(pc),d5
	move.l	sX2(pc),sX1
	move.l	d5,sX2
	exg		d1,d3
	exg		d2,d4
	bsr		intersect_y

	move.l	(sp)+,sX2
	move.l	(sp)+,sX1

	move.l	(sp)+,d4
	move.l	(sp)+,d3

.don2	addq		#2,(a2)
.next	move.w	d3,d1			; x1,y1 = old x2,y1 clipped
	move.w	d4,d2
	move.l	sX2(pc),sX1			*
	dbra		d7,.edge
.rts	rts

intersect_x:
	move.w	d0,(a1)+	; new x
	move.w	d3,d5		; x2
	move.w	d4,d6		; y2
	sub.w		d1,d5		; -x1 = dx
	sub.w		d2,d6		; -y1 = dy
	sub.w		d1,d0		; divisor
	muls		d0,d6
	divs		d5,d6
	add.w		d2,d6		; new y
	move.w	d6,(a1)+
	move.w	sX2(pc),d6
	sub.w		sX1(pc),d6	; bxw
	muls		d0,d6		; *axf
	divs		d5,d6		; /axw
	add.w		sX1(pc),d6
	move.w	d6,(a6)+
	move.w	sY2(pc),d6
	sub.w		sY1(pc),d6	; bxw
	muls		d0,d6		; *axf
	divs		d5,d6		; /axw
	add.w		sY1(pc),d6
	move.w	d6,(a6)+
	rts

intersect_y:
	move.w	d3,d5		; x2
	move.w	d4,d6		; y2
	sub.w		d1,d5		; -x1 = dx
	sub.w		d2,d6		; -y1 = dy
	sub.w		d2,d0		; divisor
	muls		d0,d5
	divs		d6,d5
	add.w		d1,d5		; new x
	move.w	d5,(a1)+	; new x
	move.w	sX2(pc),d5
	sub.w		sX1(pc),d5	; bxw
	muls		d0,d5		; *axf
	divs		d6,d5		; /axw
	add.w		sX1(pc),d5
	move.w	d5,(a6)+
	move.w	sY2(pc),d5
	sub.w		sY1(pc),d5	; bxw
	muls		d0,d5		; *axf
	divs		d6,d5		; /axw
	add.w		sY1(pc),d5
	move.w	d5,(a6)+
	add.w		d2,d0
	move.w	d0,(a1)+	; new y
	rts
	
sX1:			ds.w	1
sY1:			ds.w	1
sX2:			ds.w	1
sY2:			ds.w	1

clip_x1:		ds.w	1
clip_y1:		ds.w	1
clip_x2:		ds.w	1
clip_y2:		ds.w	1

polyclips:		ds.w	1
edgecount:		ds.w	1

MinX:			ds.w	1
MaxX:			ds.w	1

polylist_2:		ds.l	10
textlist_2:		ds.l	10

xlist:		ds.l	1
ylist:		ds.l	1
zlist:		ds.l	1
slist:		ds.l	1
olist:		ds.l	1
vertices:		ds.w	1
surfaces:		ds.w	1

object_x:		ds.w	1
object_y:		ds.w	1
object_z:		ds.w	1

object_xa:		ds.w	1
object_ya:		ds.w	1
object_za:		ds.w	1

clip3d_x1:		dc.w	64
clip3d_y1:		dc.w	16
clip3d_x2:		dc.w	319-64
clip3d_y2:		dc.w	199-16

load_object:
	moveq		#1,d1
	move.l	#DSP3D_L,d0
	lea		DSP3D,a0
	jsr		DspExecProg
	moveq		#0,d1
	moveq		#0,d2
	move.w	#320,d3
	move.w	#200,d4
	xresfactor	d1,d3
	yresfactor	d2,d4
	subq		#1,d3
	move.w	d1,clip3d_x1
	move.w	d2,clip3d_y1
	move.w	d3,clip3d_x2
	move.w	d4,clip3d_y2
	moveq		#0,d1
	move.w	clip3d_x1,d1
	dspwritel	d1
	move.w	clip3d_y1,d1
	dspwritel	d1
	move.w	clip3d_x2,d1
	dspwritel	d1
	move.w	clip3d_y2,d1
	dspwritel	d1

	move.w	#160,d1
	xresfactor	d1
	ext.l		d1
	dspwritel	d1

	move.w	#100,d1
	yresfactor	d1
	ext.l		d1
	dspwritel	d1

	dspwrite	x_factor
	dspwrite	y_factor

	move.l	slist,a0
	move.w	(a0)+,vertices
	move.w	(a0)+,surfaces
	move.l	a0,olist
	move.w	vertices,d1
	move.w	d1,d0
	addq		#1,d0
	dspwrite	d0
	move.w	d1,d0
	move.l	xlist,a0
.xlp	move.w	(a0)+,d2
	ext.l		d2
	dspwritel	d2
	dbra		d0,.xlp
	move.w	d1,d0
	move.l	ylist,a0
.ylp	move.w	(a0)+,d2
	ext.l		d2
	dspwritel	d2
	dbra		d0,.ylp
	move.w	d1,d0
	move.l	zlist,a0
.zlp	move.w	(a0)+,d2
	ext.l		d2
	dspwritel	d2
	dbra		d0,.zlp
	move.w	surfaces,d1
	move.w	d1,d0
	addq		#1,d0
	dspwrite	d0
	move.w	d1,d0
	move.l	olist,a0
.slp	move.w	(a0)+,d1
	dspwrite	d1
	move.w	(a0)+,d2
	dspwrite	d2
	subq		#1,d2
.elp	move.w	(a0)+,d3
	addq.l	#2,a0
	lsr.w		d3
	dspwrite	d3
	dbra		d2,.elp
	dbra		d0,.slp
	rts

clear_object_bpl:
	dspwritel	#1
	lea		$FFFFA206.w,a0
	move.l	PACK_SCR,a3
	move.l	PHYS_SCR,a5
	dspread	d0
	mulu		physwid,d0
	add.l		d0,a3
	add.l		d0,a5
	dspread	d3
	tst.w		d3
	ble.s		.done
	lea		cpoly_bpl,a6
	tst.b		TRUE_FLAG
	beq.s		.sk1
	lea		cpoly_true,a6
.sk1	jsr		(a6)
.done	rts

cpoly_bpl
.wait	btst		#0,-4(a0)
	beq.s		.wait
	bra		.strt
.next	move.w	(a0),d1
	move.w	(a0),d2
	cmp		clip3d_x2(pc),d2
	bne.s		.norm
	move.w	(a0),d2
	move.w	(a0),d2
	bra.s		.go
.norm	subq		#1,d2
	jsr		cline_bpl
	move.w	(a0),d1
	move.w	(a0),d2
	addq		#1,d1
.go	jsr		cline_bpl
	move.w	physwid,d1
	ext.l		d1
	add.l		d1,a3
	add.l		d1,a5
.strt	dbra		d3,.next
	rts

cline_bpl:
	addq		#1,d2
	moveq		#-16,d0
	and.w		d1,d0
	lea		(a5,d0.w),a6
	lea		(a3,d0.w),a4
	moveq		#16-1,d7
	and.w		d7,d1			; lmask
	and.w		d2,d7			; rmask
	moveq		#-1,d4
	lsr.w		d1,d4
	move.w	d4,d5
	swap		d5
	move.w	d4,d5
	move.l	d5,d4
	not.l		d4
	moveq		#-1,d6
	lsr.w		d7,d6
	move.w	d6,d7
	swap		d7
	move.w	d6,d7
	move.l	d7,d6
	not.l		d7
	lsr.w		#4,d0			; lword
	lsr.w		#4,d2			; rword
	sub.w		d0,d2			; width
	ble.s		.one
	move.l	(a6),d1
	and.l		d4,d1
	move.l	(a4)+,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	(a4)+,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	(a4)+,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	(a4)+,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	subq		#1,d2
	bra.s		.xs
.one	bmi.s		.line
	or.l		d4,d6
	and.l		d5,d7
	bra.s		.end
.ilp	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
.xs	dbra		d2,.ilp	
.end	move.l	(a6),d1
	and.l		d6,d1
	move.l	(a4)+,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	(a4)+,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	(a4)+,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	(a4)+,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
.line	rts

cpoly_true
.wait	btst		#0,-4(a0)
	beq.s		.wait
	bra		.strt
.next	move.w	(a0),d1
	move.w	(a0),d2
	cmp		clip3d_x2(pc),d2
	bne.s		.norm
	move.w	(a0),d2
	move.w	(a0),d2
	bra.s		.go
.norm	subq		#1,d2
	jsr		cline_true
	move.w	(a0),d1
	move.w	(a0),d2
	addq		#1,d1
.go	jsr		cline_true
	move.w	physwid,d1
	ext.l		d1
	add.l		d1,a3
	add.l		d1,a5
.strt	dbra		d3,.next
	rts

cline_true:
	addq		#1,d2
	lea		(a5,d1.w*2),a6
	lea		(a3,d1.w*2),a4
	sub.w		d1,d2
	ble.s		.line
	moveq		#8-1,d1
	and.w		d2,d1
	lsr.w		#3,d2	
	neg.w		d1
	jmp		.jmp(pc,d1.w*2)
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
	move.w	(a4)+,(a6)+
.jmp	dbra		d2,.xlp
	bra.s		.line
.xlp	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	dbra		d2,.xlp
.line	rts

draw_object_bpl:
	dspwritel	#0
	move.w	object_xa,d5
	move.w	object_ya,d6
	move.w	object_za,d7
	ext.l		d5
	ext.l		d6
	ext.l		d7
	dspwritel	d5
	dspwritel	d6
	dspwritel	d7
	move.w	object_x,d2
	sub.w		#160,d2
	ext.l		d2
	dspwritel	d2
	move.w	object_y,d2
	sub.w		#100,d2
	ext.l		d2
	dspwritel	d2
	move.w	object_z,d2
	neg.w		d2
	ext.l		d2
	dspwritel	d2
	move.l	#poly_bpl,PRIMITIVE
	tst.b		TRUE_FLAG
	beq.s		.sk1
	move.l	#poly_true,PRIMITIVE
.sk1	lea		$FFFFA206.w,a0
.loop	dspread	d3
	ble		.done
	dspread	d2			; start-y
	dspread	d0			; colour
	move.w	(.map.w,pc,d0.w*2),d0
	move.w	(IFACE_COLOURS.l,d0.w*2),d0
	jsr		([PRIMITIVE.l])	
	bra		.loop
.done	rts

.map	dc.w		iface_black,iface_white,iface_lgrey,iface_grey,iface_dgrey

poly_bpl
	and.w		#$FF,d0
	add.w		d0,d0
	movem.l	(PLANE_TABLE.l,d0.w*8),a1-a4
	move.l	PHYS_SCR,a5
	mulu		physwid,d2
	add.l		d2,a5
.wait	btst		#0,-4(a0)
	beq.s		.wait
	bra		.strt
.next	move.w	(a0),d1
	move.w	(a0),d2
	addq		#1,d2
	moveq		#-16,d0
	and.w		d1,d0
	lea		(a5,d0.w),a6
	moveq		#16-1,d7
	and.w		d7,d1			; lmask
	and.w		d2,d7			; rmask
	moveq		#-1,d4
	lsr.w		d1,d4
	move.w	d4,d5
	swap		d5
	move.w	d4,d5
	move.l	d5,d4
	not.l		d4
	moveq		#-1,d6
	lsr.w		d7,d6
	move.w	d6,d7
	swap		d7
	move.w	d6,d7
	move.l	d7,d6
	not.l		d7
	lsr.w		#4,d0			; lword
	lsr.w		#4,d2			; rword
	sub.w		d0,d2			; width
	ble.s		.one
	move.l	(a6),d1
	and.l		d4,d1
	move.l	a1,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	a2,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	a3,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d4,d1
	move.l	a4,d0
	and.l		d5,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	subq		#1,d2
	bra.s		.xs
.one	bmi.s		.line
	or.l		d4,d6
	and.l		d5,d7
	bra.s		.end
.ilp	move.l	a1,(a6)+
	move.l	a2,(a6)+
	move.l	a3,(a6)+
	move.l	a4,(a6)+
.xs	dbra		d2,.ilp	
.end	move.l	(a6),d1
	and.l		d6,d1
	move.l	a1,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	a2,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	a3,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
	move.l	(a6),d1
	and.l		d6,d1
	move.l	a4,d0
	and.l		d7,d0
	or.l		d0,d1
	move.l	d1,(a6)+
.line	add.w		physwid,a5
.strt	dbra		d3,.next
	rts

poly_true:
	move.w	d0,d5
	swap		d0
	move.w	d5,d0
	move.l	PHYS_SCR,a5
	mulu		physwid,d2
	add.l		d2,a5
.wait	btst		#0,-4(a0)
	beq.s		.wait
	bra.s		.strt
.next	move.w	(a0),d1
	move.w	(a0),d2
	addq		#1,d2
	lea		(a5,d1.w*2),a6
	sub.w		d1,d2
	ble.s		.line
	moveq		#8-1,d1
	and.w		d2,d1
	lsr.w		#3,d2	
	neg.w		d1
	jmp		.jmp(pc,d1.w*2)
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
	move.w	d0,(a6)+
.jmp	dbra		d2,.xlp
	bra.s		.line
.xlp	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	move.l	d0,(a6)+
	dbra		d2,.xlp
.line	add.w		physwid,a5
.strt	dbra		d3,.next
	rts

