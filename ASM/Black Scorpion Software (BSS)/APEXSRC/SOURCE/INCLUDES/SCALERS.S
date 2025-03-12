
Superscale_zone:
	tst.b		PHYS_CANVAS
	bne.s		.rts
	tst.b		ENABLE_GUIDES
	beq		Scale_zone
	push.l	SCALE_SCR
	move.l	PACK_SCR,SCALE_SCR
	move.l	LOG_SCR,d0
	move.l	PACK_SCR,LOG_SCR
	move.l	d0,PACK_SCR
	jsr		CopyBack
	move.l	LOG_SCR,d0
	move.l	PACK_SCR,LOG_SCR
	move.l	d0,PACK_SCR
	bsr		Overlays
	bsr.s		Scale_zone
	pop.l		SCALE_SCR
.rts	rts

Superscaler:
	tst.b		PHYS_CANVAS
	bne.s		.rts
	tst.b		ENABLE_GUIDES
	beq		Scale_pic
	move.l	SCALE_SCR,a0
	move.l	PACK_SCR,a1
	move.l	CANVAS_SIZE,d0
	jsr		memcpy
	push.l	SCALE_SCR
	move.l	PACK_SCR,SCALE_SCR
	bsr		Overlays
	bsr		Scale_pic
	pop.l		SCALE_SCR
.rts	rts

Scale_zone:
	addq.b	#1,BUSY
	move.w	CUR_DELTAFRAME,d0
	move.w	(Delta_list.l,d0.w*2),d0
	jsr		Find_block
	move.l	delta_size(a0),FRAME_MEM
	move.l	SCALE_SCR,a0
	move.l	PHYS_SCR,a1
	bsr		Get_max_window
	move.w	Scale_factor,d2
	and.w		#4-1,d2
	move.w	Copy_Y1,d0
	sub.w		Window_Y,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1	lsl.w		d2,d0
	move.w	Screen_Y1,d5
	yresfactor	d5
	cmp.w		d5,d0
	bge.s		.c1
	move.w	d5,d0
.c1	move.w	Copy_Y2,d1
	sub.w		Window_Y,d1
	bmi.s		.err
	lsl.w		d2,d1
	cmp.w		Y_RESOLUTION,d1
	ble.s		.ok3
	move.w	Y_RESOLUTION,d1
.ok3	move.w	Screen_Y2,d5
	yresfactor	d5
	cmp.w		d5,d1
	ble.s		.c2
	move.w	d5,d1
.c2	move.w	Window_X,d4
	move.w	Window_Y,d5
	move.l	(LOG_Y.l,d5.w*4),d5
	add.l		d5,a0
	tst.b		TRUE_FLAG
	bne.s		.true
	and.w		#-16,d4
	bra.s		.add
.true	add.w		d4,d4
.add	add.w		d4,a0
	lsr.w		d2,d0
	lsr.w		d2,d1
	sub.w		d0,d1
	ble.s		.err
	cmp.w		#1,d2
	beq		ScaleX2_rout
	cmp.w		#2,d2
	beq		ScaleX4_rout
	cmp.w		#3,d2
	beq		ScaleX8_rout
	bra		ScaleX1_rout
.err	subq.b	#1,BUSY
	rts

Scale_pic:
	addq.b	#1,BUSY
	move.w	CUR_DELTAFRAME,d0
	move.w	(Delta_list.l,d0.w*2),d0
	jsr		Find_block
	move.l	delta_size(a0),FRAME_MEM
	move.l	SCALE_SCR,a0
	move.l	PHYS_SCR,a1
	move.w	Screen_Y1,d0
	move.w	Screen_Y2,d1
	move.w	Window_X,d4
	move.w	Window_Y,d5
	move.w	Scale_factor,d2
	and.w		#4-1,d2
	move.l	(LOG_Y.l,d5.w*4),d5
	add.l		d5,a0
	tst.b		TRUE_FLAG
	bne.s		.true
	and.w		#-16,d4
	bra.s		.add
.true	add.w		d4,d4
.add	add.w		d4,a0
	lsr.w		d2,d0
	lsr.w		d2,d1
	sub.w		d0,d1
	yresfactor	d0
	yresfactor	d1
	cmp.w		#1,d2
	beq		ScaleX2_rout
	cmp.w		#2,d2
	beq		ScaleX4_rout
	cmp.w		#3,d2
	beq		ScaleX8_rout
	bra		ScaleX1_rout

*-----------------------------------------*
Get_max_window:
*-----------------------------------------*
	move.w	Y1,d0
	cmp.w		Y2,d0
	ble.s		.ny2
	move.w	Y2,d0
.ny2	cmp.w		OLD_Y1,d0
	ble.s		.noy1
	move.w	OLD_Y1,d0
.noy1	cmp.w		OLD_Y2,d0
	ble.s		.noy2
	move.w	OLD_Y2,d0
.noy2	move.w	Y1,d1
	cmp.w		Y2,d1
	bge.s		.nY2
	move.w	Y2,d1
.nY2	cmp.w		OLD_Y1,d1
	bge.s		.noY1
	move.w	OLD_Y1,d1
.noY1	cmp.w		OLD_Y2,d1
	bge.s		.noY2
	move.w	OLD_Y2,d1
.noY2	sub.w		brush_deviance,d0
	add.w		brush_deviance,d1
	move.w	d0,Copy_Y1
	addq		#1,d1
	move.w	d1,Copy_Y2
	move.w	X1,d0
	cmp.w		X2,d0
	ble.s		.nx2
	move.w	X2,d0
.nx2	cmp.w		OLD_X1,d0
	ble.s		.nox1
	move.w	OLD_X1,d0
.nox1	cmp.w		OLD_X2,d0
	ble.s		.nox2
	move.w	OLD_X2,d0
.nox2	move.w	X1,d1
	cmp.w		X2,d1
	bge.s		.nX2
	move.w	X2,d1
.nX2	cmp.w		OLD_X1,d1
	bge.s		.noX1
	move.w	OLD_X1,d1
.noX1	cmp.w		OLD_X2,d1
	bge.s		.noX2
	move.w	OLD_X2,d1
.noX2	sub.w		brush_deviance,d0
	add.w		brush_deviance,d1
	move.w	d0,Copy_X1
	addq		#1,d1
	move.w	d1,Copy_X2
	rts

*-----------------------------------------*
Make_scaletables:
*-----------------------------------------*
	lea		ScaleX2,a0
	move.w	#256-1,d0
	moveq		#0,d1
.X2lp	moveq		#16/2-1,d7
	moveq		#0,d6
	move.w	d1,d2
.mkX2	move.b	d2,d3
	lsl.b		d2
	addx.w	d6,d6
	lsl.b		d3
	addx.w	d6,d6
	dbra		d7,.mkX2
	move.w	d6,(a0)+
	addq		#1,d1
	dbra		d0,.X2lp
	lea		ScaleX4,a0
	move.w	#256-1,d0
	moveq		#0,d1
.X4lp	moveq		#32/4-1,d7
	moveq		#0,d6
	move.w	d1,d2
.mkX4	move.b	d2,d3
	lsl.b		d2
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	dbra		d7,.mkX4
	move.l	d6,(a0)+
	addq		#1,d1
	dbra		d0,.X4lp
	lea		ScaleX8,a0
	move.w	#256-1,d0
	moveq		#0,d1
.X8lp	moveq		#32/8-1,d7
	moveq		#0,d6
	move.w	d1,d2
.mX8a	move.b	d2,d3
	lsl.b		d2
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	dbra		d7,.mX8a
	move.l	d6,(a0)+
	moveq		#32/8-1,d7
	moveq		#0,d6
	move.w	d1,d2
	lsl.b		#4,d2
.mX8b	move.b	d2,d3
	lsl.b		d2
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	move.b	d3,d4
	lsl.b		d4
	addx.l	d6,d6
	dbra		d7,.mX8b
	move.l	d6,(a0)+
	addq		#1,d1
	dbra		d0,.X8lp
	rts	

*-----------------------------------------*
Overlays:						*
*-----------------------------------------*
	push.b	MORPH_HANDLES
*-----------------------------------------*
	tst.w		GUIDE_COUNT
	beq		.err
*-----------------------------------------*
	jsr		get_range
	jsr		sort_range
	move.w	d0,OLAY_START
	move.w	d1,OLAY_END
	cmp.w		d0,d1
	beq		.err				; quit if only one frame
	move.w	CUR_DELTAFRAME,d2
	st		MORPH_HANDLES
	cmp.w		d0,d2
	beq.s		.strt				; continue if on first frame
	blt		.err				; quit if below first frame 
	cmp.w		d1,d2
	beq.s		.strt				; continue if on last frame
	bgt		.err				; quit if above last frame
*-----------------------------------------*
	sf		MORPH_HANDLES
*-----------------------------------------*
.strt	move.w	CUR_DELTAFRAME,d1
	sub.w		OLAY_START,d1
	move.w	OLAY_END,d2
	sub.w		OLAY_START,d2
	ext.l		d1
	ext.l		d2
	swap		d1
	divu.l	d2,d1				; T#
	move.l	d1,T
*-----------------------------------------*
	push.l	LOG_SCR
	move.l	PACK_SCR,LOG_SCR
	move.w	FIRST_GUIDE,d0
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
*-----------------------------------------*
.loop	push.l	a0
*-----------------------------------------*
	move.l	T,d7
	moveq		#1,d6
	swap		d6
	sub.l		d7,d6				; (1.0-T#)
*-----------------------------------------*
	move.w	guide_x1_1(a0),d0
	move.w	guide_x1_2(a0),d1
	ext.l		d0
	ext.l		d1
	mulu.l	d6,d0
	mulu.l	d7,d1
	add.l		d0,d1
	swap		d1
	move.w	guide_y1_1(a0),d0
	move.w	guide_y1_2(a0),d2
	ext.l		d0
	ext.l		d2
	mulu.l	d6,d0
	mulu.l	d7,d2
	add.l		d0,d2
	swap		d2
	move.w	guide_x2_1(a0),d0
	move.w	guide_x2_2(a0),d3
	ext.l		d0
	ext.l		d3
	mulu.l	d6,d0
	mulu.l	d7,d3
	add.l		d0,d3
	swap		d3
	move.w	guide_y2_1(a0),d0
	move.w	guide_y2_2(a0),d4
	ext.l		d0
	ext.l		d4
	mulu.l	d6,d0
	mulu.l	d7,d4
	add.l		d0,d4
	swap		d4
*-----------------------------------------*
	tst.b		MORPH_HANDLES
	beq.s		.norm
	move.w	IFACE_COLOURS+2*iface_orange,d0
	or.b		gensol,d0
	move.w	guide_name(a0),d5
	cmp.w		GUIDE_SELECTED,d5
	beq.s		.go
.norm	move.w	IFACE_COLOURS+2*iface_visible,d0
	or.b		gensol,d0
.go	movem.w	d1-d4,-(sp)
	bsr		DRAW_LOG_LINE
	movem.w	(sp)+,d1-d4
	tst.b		MORPH_HANDLES
	beq.s		.no
	movem.w	d3-d4,-(sp)
	jsr		Draw_handle
	movem.w	(sp)+,d1-d2
	jsr		Draw_handle
*-----------------------------------------*
.no	pop.l		a0
	move.w	guide_next(a0),d0
	bmi.s		.done
	mulu		#guide_len,d0
	lea		(MORPH_BUFFER.l,d0.l),a0
	bra		.loop
*-----------------------------------------*
.done	pop.l		LOG_SCR
.err	pop.b		MORPH_HANDLES
	rts

OLAY_START:		ds.w	1
OLAY_END:		ds.w	1

*-----------------------------------------*
*	Standard scalers (no x-clipping)	*
*-----------------------------------------*

ScaleX1_rout:	
	tst.w		Screen_Y1
	bne		ScalecX1_rout
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	add.l		d7,a1
	move.w	logwid,d4
	move.w	physwid,d5
	ext.l		d4
	ext.l		d5
	move.w	x_factor,d6
	tst.b		TRUE_FLAG
	beq.s		.ok
	add.w		d6,d6
.ok	subq		#1,d6
	move.w	d1,d0
	subq		#1,d0
	bmi		.out
	cacheoff	d7
.loop	move.l	a0,a2
	move.l	a1,a3
	move.w	d6,d7
.xlp	move.l	(a2)+,(a3)+
	rept		(320/4)-1
	move.l	(a2)+,(a3)+
	endr
	dbra		d7,.xlp
	add.l		d4,a0
	add.l		d5,a1
	dbra		d0,.loop	
	cacheon	d7
.out	subq.b	#1,BUSY
	rts

ScaleX2_rout:
	tst.w		Screen_Y1
	bne		ScalecX2_rout
	tst.b		TRUE_FLAG
	bne		ScaleX2_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	add.l		d7,a1
	add.l		d7,a1
	move.w	d1,d3
	subq		#1,d3
	bmi		.err
	move.w	X_RESOLUTION,d4
	lsr.w		#5,d4
	subq		#1,d4
	lea		ScaleX2,a6
	move.l	a0,a3
	move.l	a1,d7
	moveq		#0,d0
	move.w	physwid,d5
	ext.l		d5
	moveq		#16,d2
.line	move.l	a3,a0			; a3/a0 = src
	move.l	d7,a1			; d7/a1 = dst
	move.l	a1,a2
	add.l		d2,a2
	move.l	a1,a4
	add.l		d5,a4
	move.l	a2,a5
	add.l		d5,a5
	move.w	d4,d6			; width of scanline * 2 
.xsiz	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a1)+
	move.w	d1,(a4)+
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a2)+
	move.w	d1,(a5)+
	rept		8-1
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a1)+
	move.w	d1,(a4)+
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a2)+
	move.w	d1,(a5)+
	endr
	add.l		d2,a1
	add.l		d2,a2
	add.l		d2,a4
	add.l		d2,a5
	dbra		d6,.xsiz
	add.w		logwid,a3
	add.l		d5,d7
	add.l		d5,d7
	dbra		d3,.line
.err	subq.b	#1,BUSY
	rts

ScaleX2_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	add.l		d7,a1
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	#39-1,d1		; 320 wide
	move.w	physwid,d5
	ext.l		d5
	move.l	a1,a2
	add.l		d5,a2
	move.l	a0,a3
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	(a0)+,d0
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	move.w	d1,d2
.dots	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra		d2,.dots
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	dbra		d4,.doub
	add.w		logwid,a3
	add.l		d5,a1
	add.l		d5,a2
	dbra		d7,.line
.err	subq.b	#1,BUSY
	rts

ScaleX4_rout:
	tst.w		Screen_Y1
	bne		ScalecX4_rout
	tst.b		TRUE_FLAG
	bne		ScaleX4_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	add.l		d7,d7
	add.l		d7,d7
	add.l		d7,a1
	move.w	d1,d3
	subq		#1,d3
	bmi		.err
	move.w	X_RESOLUTION,d4
	lsr.w		#6,d4
	lea		ScaleX4,a6
	move.l	a0,a3
	move.l	a1,a4
	move.w	physwid,d5
	lsl.w		#2,d5
	ext.l		d5
	jsr		standard_x4_bpl
	jsr		standard_x4copy_bpl
.err	subq.b	#1,BUSY
	rts

ScaleX4_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	add.l		d7,d7
	add.l		d7,d7
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	physwid,d5
	ext.l		d5
	lea		(a1,d5.l),a2
	lea		(a2,d5.l),a4
	lea		(a4,d5.l),a5
	move.l	d5,d6
	add.l		d5,d6
	add.l		d5,d6
	move.w	logwid,d5
	ext.l		d5
	move.l	a0,a3
	moveq		#40-1,d1		; 320 wide
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	d1,d2
.dots	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	dbra		d2,.dots
	dbra		d4,.doub
	add.l		d5,a3
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a4
	add.l		d6,a5
	dbra		d7,.line
.err	subq.b	#1,BUSY
	rts

ScaleX8_rout:
	tst.w		Screen_Y1
	bne		ScalecX8_rout
	tst.b		TRUE_FLAG
	bne		ScaleX8_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	lsl.l		#3,d7
	add.l		d7,a1
	subq		#1,d1
	bmi		Stop_zoomx8
	lea		ScaleX8,a6
	move.w	X_RESOLUTION,d3
	lsr.w		#6,d3
	subq		#1,d3
	move.w	physwid,d0
	ext.l		d0
	move.l	d0,d5
	lsl.l		#3,d5
	sub.l		d0,d5
	moveq		#0,d0
	push.w	d1
	push.l	a1
.ylop	move.w	Window_X,d6
	lsr.w		#3,d6			; byte offset
	and.w		#2-1,d6
	push.l	a0
	move.w	d3,d4
.xlop	move.b	(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	2(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	4(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	6(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	8(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	10(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	12(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	14(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	addq		#1,d6
	and.w		#2-1,d6
	bne.s		.nwrp
	lea		16(a0),a0
.nwrp	lea		16*3(a1),a1
	dbra		d4,.xlop
	add.l		d5,a1
	pop.l		a0
	add.w		logwid,a0
	dbra		d1,.ylop
	pop.l		a0
	pop.w		d1

SX8_copy:
	move.w	#32,a6
	move.w	physwid,d6	
	ext.l		d6
	move.w	X_RESOLUTION,d7
	lsr.w		#6,d7
.copy	push.w	d1
	lea		(a0,d6.w),a1
	lea		(a1,d6.w),a2
	lea		(a2,d6.w),a3
	push.w	d7
	subq		#1,d7
.xsiz	movem.l	(a0),d0-d5/a4/a5		; 8*4 = 32
	movem.l	d0-d5/a4/a5,(a1)
	movem.l	d0-d5/a4/a5,(a2)
	movem.l	d0-d5/a4/a5,(a3)
	movem.l	d0-d5/a4/a5,(a0,d6.w*4)
	movem.l	d0-d5/a4/a5,(a1,d6.w*4)
	movem.l	d0-d5/a4/a5,(a2,d6.w*4)
	movem.l	d0-d5/a4/a5,(a3,d6.w*4)
	add.l		a6,a0
	add.l		a6,a1
	add.l		a6,a2
	add.l		a6,a3
	movem.l	(a0),d0-d5/a4/a5		; 8*4 = 32
	movem.l	d0-d5/a4/a5,(a1)
	movem.l	d0-d5/a4/a5,(a2)
	movem.l	d0-d5/a4/a5,(a3)
	movem.l	d0-d5/a4/a5,(a0,d6.w*4)
	movem.l	d0-d5/a4/a5,(a1,d6.w*4)
	movem.l	d0-d5/a4/a5,(a2,d6.w*4)
	movem.l	d0-d5/a4/a5,(a3,d6.w*4)
	add.l		a6,a0
	add.l		a6,a1
	add.l		a6,a2
	add.l		a6,a3
	dbra		d7,.xsiz
	pop.w		d7
	sub.l		d6,a0
	lea		(a0,d6.w*8),a0
	pop.w		d1
	dbra		d1,.copy
Stop_zoomx8:
	subq.b	#1,BUSY
	rts

ScaleX8_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	lsl.l		#3,d7
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	physwid,d5
	ext.l		d5
	lea		alt1(pc),a2
	moveq		#16-1,d6
.lp	move.w	d5,(a2)
	addq.l	#6,a2
	dbra		d6,.lp
	lea		(a1,d5.l*2),a2
	lea		(a2,d5.l*2),a4
	lea		(a4,d5.l*2),a5
	move.l	d5,d6
	lsl.l		#3,d6
	sub.l		d5,d6
	moveq		#40-1,d1		; 320 wide
	move.l	a0,a3
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	d1,d2
.dots	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
.smc
	rept		4
	move.l	d0,4(a1)
	move.l	d0,(a1)+
	endr
	rept		4
	move.l	d0,4(a2)
	move.l	d0,(a2)+
	endr
	rept		4
	move.l	d0,4(a4)
	move.l	d0,(a4)+
	endr
	rept		4
	move.l	d0,4(a5)
	move.l	d0,(a5)+
	endr
	dbra		d2,.dots
	dbra		d4,.doub
	add.w		logwid,a3
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a4
	add.l		d6,a5
	dbra		d7,.line
.err	subq.b	#1,BUSY
	rts

alt1	=		.smc+2

*-----------------------------------------*
*	X-Clipped scalers				*
*-----------------------------------------*

ScalecX1_rout:	
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	move.w	#32,d2
	xresfactor	d2
	ext.l		d2
	add.l		d0,a0
	add.l		d7,a1
	move.w	logwid,d4
	move.w	physwid,d5
	ext.l		d4
	ext.l		d5
	move.w	x_factor,d6
	tst.b		TRUE_FLAG
	beq.s		.ok
	add.l		d2,d2
	add.w		d6,d6
.ok	add.l		d2,a0
	add.l		d2,a1
	subq		#1,d6
	move.w	d1,d0
	subq		#1,d0
	bmi		.out
.loop	move.l	a0,a2
	move.l	a1,a3
	move.w	d6,d7
.xlp	move.l	(a2)+,(a3)+
	rept		(288/4)-1
	move.l	(a2)+,(a3)+
	endr
	dbra		d7,.xlp
	add.l		d4,a0
	add.l		d5,a1
	dbra		d0,.loop	
.out	subq.b	#1,BUSY
	rts

ScalecX2_rout:
	tst.b		TRUE_FLAG
	bne		ScalecX2_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	moveq		#16,d2
	xresfactor	d2
	ext.l		d2
	add.l		d2,a0
	add.l		d2,a1
	add.l		d2,a1			; skip past tool-bar
	add.l		d0,a0
	add.l		d7,a1
	add.l		d7,a1
	move.w	d1,d3
	subq		#1,d3
	bmi		.err
	move.w	X_RESOLUTION,d4
	lsr.w		#5,d4
	subq		#2,d4
	cmp.w		#1,x_factor
	beq.s		.x1
	subq		#1,d4
.x1	lea		ScaleX2,a6
	move.l	a0,a3
	move.l	a1,d7
	moveq		#0,d0
	move.w	physwid,d5
	ext.l		d5
	moveq		#16,d2
.line	move.l	a3,a0			; a3/a0 = src
	move.l	d7,a1			; d7/a1 = dst
	move.l	a1,a2
	add.l		d2,a2
	move.l	a1,a4
	add.l		d5,a4
	move.l	a2,a5
	add.l		d5,a5
	move.w	d4,d6			; width of scanline * 2 
.xsiz	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a1)+
	move.w	d1,(a4)+
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a2)+
	move.w	d1,(a5)+
	rept		8-1
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a1)+
	move.w	d1,(a4)+
	move.b	(a0)+,d0
	move.w	(a6,d0.w*2),d1
	move.w	d1,(a2)+
	move.w	d1,(a5)+
	endr
	add.l		d2,a1
	add.l		d2,a2
	add.l		d2,a4
	add.l		d2,a5
	dbra		d6,.xsiz
	add.w		logwid,a3
	add.l		d5,d7
	add.l		d5,d7
	dbra		d3,.line
.err	subq.b	#1,BUSY
	rts

ScalecX2_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	moveq		#16*2,d2
	xresfactor	d2
	ext.l		d2
	add.l		d2,a0
	add.l		d2,a1
	add.l		d2,a1			; skip past tool-bar
	add.l		d0,a0
	add.l		d7,a1
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	#(288/8)-2,d1	; 320 wide
	move.w	physwid,d5
	ext.l		d5
	move.l	a1,a2
	add.l		d5,a2
	moveq		#32*2,d2
	xresfactor	d2
	ext.l		d2
	add.l		d2,d5
	move.l	a0,a3
	cacheoff	d4
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	(a0)+,d0
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	move.w	d1,d2
.dots	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra		d2,.dots
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.w	d0,(a1)+
	move.w	d0,(a2)+
	dbra		d4,.doub
	add.w		logwid,a3
	add.l		d5,a1
	add.l		d5,a2
	dbra		d7,.line
	cacheon	d7
.err	subq.b	#1,BUSY
	rts

ScalecX4_rout:
	tst.b		TRUE_FLAG
	bne		ScalecX4_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	cmp.w		#1,x_factor
	beq.s		.xl
	moveq		#16,d2
	ext.l		d2
	add.l		d2,a0
	lsl.l		#2,d2
	add.l		d2,a1			; skip past tool-bar
.xl	add.l		d0,a0
	add.l		d7,d7
	add.l		d7,d7
	add.l		d7,a1
	move.w	d1,d3
	subq		#1,d3
	bmi		.err
	move.w	X_RESOLUTION,d4
	lsr.w		#6,d4
	lea		ScaleX4,a6
	move.l	a0,a3
	move.l	a1,a4
	move.w	physwid,d5
	lsl.w		#2,d5
	ext.l		d5
	cmp.w		#2,x_factor
	bne.s		.low
	subq		#1,d4
	jsr		standard_x4_bpl
	jsr		clipped_x4copy_bpl
	bra.s		.err
.low	jsr		clipped_x4_bpl
	lea		32(a0),a0
	jsr		clipped_x4copy_bpl
.err	subq.b	#1,BUSY
	rts

standard_x4_bpl:
	push.w	d3
	push.l	a1
	moveq		#16*3,d2
	moveq		#0,d0
.line	move.l	a3,a0
	move.l	a4,a1
	lea		32(a1),a2
	move.w	d4,d6			; width of scanline * 2 
	subq		#1,d6
.xsiz	moveq		#2-1,d7
.doub	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a1)
	swap		d1
	move.w	d1,(a1)+
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	rept		4-1
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a1)
	swap		d1
	move.w	d1,(a1)+
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	endr
	dbra		d7,.doub
	add.l		d2,a1
	add.l		d2,a2
	dbra		d6,.xsiz
	add.w		logwid,a3
	add.l		d5,a4
	dbra		d3,.line
	pop.l		a0
	pop.w		d7
	rts
	
standard_x4copy_bpl:
	moveq		#2,d0
	xresfactor	d0
	move.w	d0,a4
	moveq		#32,d6
.ylop	move.w	physwid,d0
	lea		(a0,d0.w),a1
	lea		(a1,d0.w),a2
	lea		(a2,d0.w),a3
	swap		d7
	move.w	a4,d7
	subq		#1,d7
.xlop	movem.l	(a0)+,d0-d5/a5/a6		; 32 (2 words)
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	dbra		d7,.xlop
	move.w	physwid,d0
	ext.l		d0
	add.l		d0,a0
	add.l		d0,a0
	add.l		d0,a0	
	swap		d7
	dbra		d7,.ylop
	rts

clipped_x4_bpl:
	push.w	d3
	push.l	a1
	moveq		#16*3,d2
	moveq		#0,d0
.line	move.l	a3,a0
	move.l	a4,a1
	lea		32(a1),a2
	move.w	d4,d6			; width of scanline * 2 
	subq		#2,d6			; adjust for clip-skip
	moveq		#2-1,d7
.dou1	addq.l	#1,a0
	addq.l	#2,a1
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	rept		4-1
	addq.l	#1,a0
	addq.l	#2,a1
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	endr
	dbra		d7,.dou1
	add.l		d2,a1
	add.l		d2,a2
.xsiz	moveq		#2-1,d7
.dou2	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a1)
	swap		d1
	move.w	d1,(a1)+
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	rept		4-1
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a1)
	swap		d1
	move.w	d1,(a1)+
	move.b	(a0)+,d0
	move.l	(a6,d0.w*4),d1
	move.w	d1,16(a2)
	swap		d1
	move.w	d1,(a2)+
	endr
	dbra		d7,.dou2
	add.l		d2,a1
	add.l		d2,a2
	dbra		d6,.xsiz
	add.w		logwid,a3
	add.l		d5,a4
	dbra		d3,.line
	pop.l		a0
	pop.w		d7
	rts

clipped_x4copy_bpl:
	moveq		#2,d0
	xresfactor	d0
	subq		#1,d0
	move.w	d0,a4
	moveq		#32,d6
	move.l	d6,d5
	xresfactor	d5
	move.l	d5,.skip
.ylop	move.w	physwid,d0
	lea		(a0,d0.w),a1
	lea		(a1,d0.w),a2
	lea		(a2,d0.w),a3
	swap		d7
	move.w	a4,d7
	cmp.w		#1,x_factor
	beq.s		.ls
	bra.s		.hs
.xlop	movem.l	(a0)+,d0-d5/a5/a6		; 32 (2 words)
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
.ls	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
.hs	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	movem.l	(a0)+,d0-d5/a5/a6
	movem.l	d0-d5/a5/a6,(a1)
	movem.l	d0-d5/a5/a6,(a2)
	movem.l	d0-d5/a5/a6,(a3)
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a3
	dbra		d7,.xlop
	move.w	physwid,d0
	ext.l		d0
	add.l		d0,a0
	add.l		d0,a0
	add.l		d0,a0	
	move.l	.skip(pc),d5
	add.l		d5,a0
	swap		d7
	dbra		d7,.ylop
	rts
.skip	ds.l		1

ScalecX4_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	moveq		#8*2,d2
	xresfactor	d2
	ext.l		d2
	add.l		d2,a0
	lsl.l		#2,d2
	add.l		d2,a1			; skip past tool-bar
	add.l		d0,a0
	add.l		d7,d7
	add.l		d7,d7
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	physwid,d5
	ext.l		d5
	lea		(a1,d5.l),a2
	lea		(a2,d5.l),a4
	lea		(a4,d5.l),a5
	move.l	d5,d6
	add.l		d5,d6
	add.l		d5,d6
	moveq		#32*2,d5
	xresfactor	d5
	add.l		d5,d6
	move.w	logwid,d5
	ext.l		d5
	move.l	a0,a3
	moveq		#36-1,d1		; 288 wide
	cacheoff	d4
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	d1,d2
.dots	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.l	d0,(a5)+
	move.l	d0,(a5)+
	dbra		d2,.dots
	dbra		d4,.doub
	add.l		d5,a3
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a4
	add.l		d6,a5
	dbra		d7,.line
	cacheon	d7
.err	subq.b	#1,BUSY
	rts

ScalecX8_rout:
	tst.b		TRUE_FLAG
	bne		ScalecX8_true
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	add.l		d0,a0
	lsl.l		#3,d7
	add.l		d7,a1
	subq		#1,d1
	bmi		Stop_zoomcx8
	lea		ScaleX8,a6
	move.w	X_RESOLUTION,d3
	lsr.w		#6,d3
	subq		#1,d3
	move.w	physwid,d0
	ext.l		d0
	move.l	d0,d5
	lsl.l		#3,d5
	sub.l		d0,d5
	moveq		#0,d0
	cmp.w		#2,x_factor
	beq.s		.hi
.low	jsr		clipped_lowx8_bpl
	bra.s		SX8c_copy
.hi	jsr		clipped_hix8_bpl
		
SX8c_copy:
	moveq		#32,d6
	xresfactor	d6
	move.l	d6,.skip
	add.l		d6,a0
	move.w	#32,a6
	move.w	physwid,d6	
	ext.l		d6
	move.w	X_RESOLUTION,d7
	lsr.w		#6,d7
.copy	push.w	d1
	lea		(a0,d6.w),a1
	lea		(a1,d6.w),a2
	lea		(a2,d6.w),a3
	push.w	d7
	subq		#1,d7
	cmp.w		#1,x_factor
	beq.s		.ls
	bra.s		.hs
.xsiz	movem.l	(a0),d0-d5/a4/a5		; 8*4 = 32
	movem.l	d0-d5/a4/a5,(a1)
	movem.l	d0-d5/a4/a5,(a2)
	movem.l	d0-d5/a4/a5,(a3)
	movem.l	d0-d5/a4/a5,(a0,d6.w*4)
	movem.l	d0-d5/a4/a5,(a1,d6.w*4)
	movem.l	d0-d5/a4/a5,(a2,d6.w*4)
	movem.l	d0-d5/a4/a5,(a3,d6.w*4)
	add.l		a6,a0
	add.l		a6,a1
	add.l		a6,a2
	add.l		a6,a3
.ls	movem.l	(a0),d0-d5/a4/a5		; 8*4 = 32
	movem.l	d0-d5/a4/a5,(a1)
	movem.l	d0-d5/a4/a5,(a2)
	movem.l	d0-d5/a4/a5,(a3)
	movem.l	d0-d5/a4/a5,(a0,d6.w*4)
	movem.l	d0-d5/a4/a5,(a1,d6.w*4)
	movem.l	d0-d5/a4/a5,(a2,d6.w*4)
	movem.l	d0-d5/a4/a5,(a3,d6.w*4)
	add.l		a6,a0
	add.l		a6,a1
	add.l		a6,a2
	add.l		a6,a3
.hs	dbra		d7,.xsiz
	move.l	.skip(pc),d7
	add.l		d7,a0
	pop.w		d7
	sub.l		d6,a0
	lea		(a0,d6.w*8),a0
	pop.w		d1
	dbra		d1,.copy
	bra.s		.done
.skip	ds.l		1
.done	

Stop_zoomcx8:
	subq.b	#1,BUSY
	rts

clipped_lowx8_bpl:
	push.w	d1
	push.l	a1
.ylop	move.w	Window_X,d6
	lsr.w		#3,d6			; byte offset
	and.w		#2-1,d6
	push.l	a0
	move.w	d3,d4
	subq		#1,d4
.xstr	move.b	(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	2(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	4(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	6(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	8(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	10(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	12(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	14(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	addq.l	#2,a1
	addq.l	#4,a5
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	addq		#1,d6
	and.w		#2-1,d6
	bne.s		.nwrp
	lea		16(a0),a0
.nwrp	lea		16*3(a1),a1
.xlop	move.b	(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	2(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	4(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	6(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	8(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	10(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	12(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	14(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	addq		#1,d6
	and.w		#2-1,d6
	bne.s		.nwr2
	lea		16(a0),a0
.nwr2	lea		16*3(a1),a1
	dbra		d4,.xlop
	add.l		d5,a1
	pop.l		a0
	add.w		logwid,a0
	dbra		d1,.ylop
	pop.l		a0
	pop.w		d1
	rts

clipped_hix8_bpl:
	push.w	d1
	push.l	a1
.ylop	move.w	Window_X,d6
	lsr.w		#3,d6			; byte offset
	and.w		#2-1,d6
	push.l	a0
	move.w	d3,d4
	lea		16(a1),a1
	bra		.kick
.xlop	move.b	(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	2(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	4(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	6(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	8(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	10(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	12(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
	move.b	14(a0,d6.w),d0
	lea		(a6,d0.w*8),a5
	move.w	(a5)+,(a1)+
	move.w	(a5)+,16-2(a1)
	move.w	(a5)+,32-2(a1)
	move.w	(a5)+,48-2(a1)
.kick	addq		#1,d6
	and.w		#2-1,d6
	bne.s		.nwrp
	lea		16(a0),a0
.nwrp	lea		16*3(a1),a1
	dbra		d4,.xlop
	add.l		d5,a1
	pop.l		a0
	add.w		logwid,a0
	dbra		d1,.ylop
	pop.l		a0
	pop.w		d1
	rts

ScalecX8_true:
	move.w	d0,d7
	move.l	(LOG_Y.l,d0.w*4),d0
	move.l	(PHYS_Y.l,d7.w*4),d7
	moveq		#4*2,d2
	xresfactor	d2
	ext.l		d2
	add.l		d2,a0
	lsl.l		#3,d2
	add.l		d2,a1			; skip past tool-bar
	add.l		d0,a0
	lsl.l		#3,d7
	add.l		d7,a1
	move.w	d1,d7
	subq		#1,d7
	bmi		.err
	move.w	x_factor,d3
	subq		#1,d3			; double up?
	move.w	physwid,d5
	ext.l		d5
	lea		alt2(pc),a2
	moveq		#16-1,d6
.lp	move.w	d5,(a2)
	addq.l	#6,a2
	dbra		d6,.lp
	lea		(a1,d5.l*2),a2
	lea		(a2,d5.l*2),a4
	lea		(a4,d5.l*2),a5
	move.l	d5,d6
	lsl.l		#3,d6
	sub.l		d5,d6
	moveq		#32*2,d5
	xresfactor	d5
	add.l		d5,d6
	moveq		#36-1,d1		; 320 wide
	move.l	a0,a3
	cacheoff	d4
.line	move.l	a3,a0
	move.w	d3,d4
.doub	move.w	d1,d2
.dots	move.w	(a0),d0
	swap		d0
	move.w	(a0)+,d0
.smc
	rept		4
	move.l	d0,4(a1)
	move.l	d0,(a1)+
	endr
	rept		4
	move.l	d0,4(a2)
	move.l	d0,(a2)+
	endr
	rept		4
	move.l	d0,4(a4)
	move.l	d0,(a4)+
	endr
	rept		4
	move.l	d0,4(a5)
	move.l	d0,(a5)+
	endr
	dbra		d2,.dots
	dbra		d4,.doub
	add.w		logwid,a3
	add.l		d6,a1
	add.l		d6,a2
	add.l		d6,a4
	add.l		d6,a5
	dbra		d7,.line
	cacheon	d7
.err	subq.b	#1,BUSY
	rts

alt2	=		.smc+2
