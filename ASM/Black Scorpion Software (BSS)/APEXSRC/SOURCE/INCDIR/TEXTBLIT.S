
;	include	blit.s

linebufferwidth	=	640
fontlines		=	8

waitblitter		macro
.wb1	btst		#7,blit_stat.w
	bne.s		.wb1
	endm

render_string:
;	a0		=	ASCII string address (0 terminated)
;	a6		=	8x8 system font address
;	d1.w		=	x-pixel coordinate
;	d2.w		=	y-pixel coordinate
;	txtscrptr.l	=	screen address
;	txtscrwid.w	=	screen bytes/line
;	txtscrbpl.w	=	screen bitplanes
;	txtink.b	=	drawing colour (ink)

	waitblitter
	moveq		#2,d0
	move.b	d0,HOP.w
	move.w	d0,src_xinc.w
	mulu.w	txtscrbpl,d0
	move.w	d0,dst_xinc.w
	move.b	#0,skew.w
	lea		linebuffer,a5
	move.w	#256,a3
	move.w	#(linebufferwidth/8),a4
.new	move.l	txtscrptr,a1
	mulu		txtscrwid,d2
	add.l		d2,a1
	moveq		#-16,d4
	and.w		d1,d4
	lsr.w		#3,d4
	mulu.w	txtscrbpl,d4
	add.l		d4,a1
	and.w		#16-1,d1
	move.w	d1,d3
	moveq		#0,d0
	moveq		#0,d4
.loop	move.b	(a0)+,d0
	beq		.out
	cmp.b		#32,d0
	beq		.gap
	cmp.b		#27,d0
	beq		.ctrl
	move.l	a6,a2
	add.l		d0,a2
	rept		fontlines
	move.b	(a2),d4
	add.l		a3,a2
	bfins		d4,(a5){d3:8}
	add.l		a4,a5
	endr
	lea		linebuffer,a5
.gap	addq.l	#8,d3
	bra		.loop
.out	bsr.s		blit_string
	rts
.ctrl	move.b	(a0)+,d0
	cmp.b		#"Y",d0
	bne		.loop
.pos	bsr.s		blit_string
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	bra		.new

blit_string:
	moveq		#16-1,d5
	move.w	d3,d4
	subq		#1,d4
	and.w		d5,d4
	addq		#1,d4
	add.w		d5,d3
	lsr.w		#4,d3
	beq.s		.none
	moveq		#-1,d2
	lsr.w		d1,d2
	move.w	d2,endmask1.w
	moveq		#-1,d2
	sub.w		d2,d2
	lsr.l		d4,d2
	cmp.w		#1,d3
	bne.s		.long
	and.w		d2,endmask1.w
	bra.s		.shrt
.long	move.w	d2,endmask3.w
.shrt	move.w	d3,x_size.w
	lsl.w		d3
	move.w	#(linebufferwidth/8),d4
	sub.w		d3,d4
	add.w		src_xinc.w,d4
	move.w	d4,src_yinc.w
	mulu.w	txtscrbpl,d3
	move.w	txtscrwid,d4
	sub.w		d3,d4
	add.w		dst_xinc.w,d4
	move.w	d4,dst_yinc.w
	moveq		#fontlines,d3
	move.b	#192,d4
	move.b	txtink,d1
	move.w	txtscrbpl,d7
	bra.s		.bps
.bpl	moveq		#7,d2
	lsr.b		d1
	bcs.s		.set
	moveq		#4,d2
.set	move.b	d2,blit_op.w
	move.l	a5,src_addr.w
	move.l	a1,dst_addr.w
	move.w	d3,y_size.w
	move.b	d4,blit_stat.w
	addq.l	#2,a1
.bps	dbra		d7,.bpl
.none	rts

*-----------------------------------*
			data
*-----------------------------------*

textpos		macro
	dc.b		27,"Y"
	dc.b		((\1)>>8),((\1)&255)
	dc.b		((\2)>>8),((\2)&255)
	endm
	
;craptext:
;	textpos	552,32+(8*00)
;	dc.b		"Create"
;	textpos	552,32+(8*01)
;	dc.b		"Select"
;	textpos	552,32+(8*02)
;	dc.b		"Modify"
;	dc.b		0
;	even

*-----------------------------------*
			bss
*-----------------------------------*

txtscrptr:		ds.l	1
txtscrwid:		ds.w	1
txtscrbpl:		ds.w	1
txtink:		ds.b	1
			even

linebuffer:		ds.b	(linebufferwidth/8)*fontlines
			even
		
*-----------------------------------*
			text
*-----------------------------------*
