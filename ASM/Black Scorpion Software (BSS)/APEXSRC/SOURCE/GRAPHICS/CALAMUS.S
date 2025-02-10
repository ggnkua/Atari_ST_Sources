*-----------------------------------------------------------------------*
*	Slightly non-approved Calamus font driver for the Falcon030 DSP	*
*-----------------------------------------------------------------------*
*	(C) 1994 Douglas Little / Black Scorpion					*
*-----------------------------------------------------------------------*
*	All 68030 code has not been optimised, and is advised before use.	*
*	All DSP code is heavily optimised and needs little work.		*
*	Requires Devpac 2/3 - set TABS to [6] for easy reading!		*
*-----------------------------------------------------------------------*


*-----------------------------------------------------------------------*
print_cfn:
*-----------------------------------------------------------------------*
	move.w	CFN_HANDLE,d0
	jsr		Find_block
	move.l	a0,a1
	move.l	a1,cfnptr
	add.l		block_size-block_head(a0),a1
	move.l	a1,cfnend
	lea		$2b4(a0),a1
	move.l	a1,kern_list
	move.w	CFN,d1
	sub.w		#32,d1
	lsl.w		#4,d1
	lea		(a1,d1.w),a1
	move.l	this_kern(pc),last_kern
	move.l	a1,this_kern
	jsr		find_new_x
	move.w	$1da(a0),topline
	move.w	$1e0(a0),baseline
	lea		$10bc(a0),a1
	lea		$1442(a0),a2	; find font definitions
	move.w	CFN,d1
	sub.w		#'A',d1
	add.w		#33,d1
	move.l	(a1,d1.w*4),d0	; get this character data
	bmi		error
	add.l		d0,a2
	cmp.l		cfnptr(pc),a2
	blt		error
	cmp.l		cfnend(pc),a2
	bgt		error
	push.l	a2
	jsr		check_character
	pop.l		a2
	tst.w		d0
	bmi		error
	jsr		build_character
*-----------------------------------------------------------------------*
draw_character:
*-----------------------------------------------------------------------*
	dspread	d3			; read back start-y coordinate
	add.w		cfn_y(pc),d3
.new	dspread	d1			; read back X1 (code)
	bpl.s		.posi
	cmp.w		#-32766,d1		; if code is -2, then no more data!
	beq		error
	cmp.w		#-32767,d1		; if code is -1 then onto next scanline
	bne.s		.posi
.line	addq		#1,d3			; down a line
	bra.s		.new
.posi	dspread	d2			; read back X2
	tst.w		d3
	bmi.s		.new
	cmp.w		CANVAS_HEIGHT,d3
	bge.s		.new
	cmp.w		Y1,d3
	bge.s		.nmny
	move.w	d3,Y1
.nmny	cmp.w		Y2,d3
	ble.s		.nmxy
	move.w	d3,Y2
.nmxy	add.w		cfn_x(pc),d1
	add.w		cfn_x(pc),d2
	cmp.w		d1,d2
	bge.s		.ordr
	exg		d1,d2
.ordr	tst.w		d2
	bmi.s		.new
	cmp.w		CANVAS_WIDTH,d1
	bge.s		.new
	tst.w		d1
	bpl.s		.x1p
	moveq		#0,d1
.x1p	cmp.w		CANVAS_WIDTH,d2
	blt.s		.x2i
	move.w	CANVAS_WIDTH,d2
	subq		#1,d2
.x2i	cmp.w		X1,d1
	bge.s		.nmnx
	move.w	d1,X1
.nmnx	cmp.w		X2,d2
	ble.s		.nmxx
	move.w	d2,X2
.nmxx	push.w	d3
	move.w	FG_COLOUR,d0
	jsr		horizontal_logline_d
	pop.w		d3
	bra		.new
error	rts

reset_kerning:
	pushall
	move.w	CFN_HANDLE,d0
	jsr		Find_block
	move.w	$1e6(a0),d0
	ext.l		d0
	muls.l	scaler(pc),d0
	lsl.l		#3,d0
	sub.l		d0,cfn_x
	move.w	$1a(a0),cfnxgap
	move.w	$1e2(a0),d0
	sub.w		$1dc(a0),d0
	add.w		cfnxgap(pc),d0
	move.w	d0,cfnygap
	lea		$2b4(a0),a1
	move.l	a1,kern_list
	clr.l		this_kern
	clr.l		last_kern
	popall
	rts

find_new_x:
	pushall
	moveq		#0,d1
	move.w	#-512,d3
	move.l	this_kern(pc),a1
	move.l	last_kern(pc),d0
	move.l	d0,a0
	lea		8(a0),a0
	tst.l		d0
	beq.s		.frst
	moveq		#8-1,d0
.look	moveq		#0,d2
	move.b	(a0)+,d2
	move.b	(a1)+,d1
	sub.w		d1,d2
	cmp.w		d3,d2
	ble.s		.cont
	move.w	d2,d3
.cont	dbra		d0,.look
.done	add.w		cfnxgap(pc),d3
	sub.w		#100,d3
	add.w		cfnxgap2(pc),d3
	ext.l		d3
	lsl.l		#6,d3
	muls.l	scaler(pc),d3
	lsl.l		#3,d3
	add.l		d3,cfn_x
.err	popall
	rts
.frst	moveq		#8-1,d0
.lok2	move.w	#0,d2
	move.b	(a1)+,d1
	sub.w		d1,d2
	cmp.w		d3,d2
	ble.s		.con2
	move.w	d2,d3
.con2	dbra		d0,.lok2
	bra.s		.done

	ifd		hinting
hint:	ext.l		d1
	ext.l		d2
	ext.l		d3
	muls.l	scaler,d1
	muls.l	scaler,d2
	muls.l	scaler,d3
	lsl.l		#3,d1
	lsl.l		#3,d2
	lsl.l		#3,d3
	swap		d1
	swap		d2
	swap		d3
	add.w		cfn_y,d3
	tst.w		d3
	bmi		.new
	cmp.w		CANVAS_HEIGHT,d3
	bge.s		.new
	cmp.w		Y1,d3
	bge.s		.nmny
	move.w	d3,Y1
.nmny	cmp.w		Y2,d3
	ble.s		.nmxy
	move.w	d3,Y2
.nmxy	add.w		cfn_x(pc),d1
	add.w		cfn_x(pc),d2
	cmp.w		d1,d2
	bge.s		.ordr
	exg		d1,d2
.ordr	tst.w		d2
	bmi.s		.new
	cmp.w		CANVAS_WIDTH,d1
	bge.s		.new
	tst.w		d1
	bpl.s		.x1p
	moveq		#0,d1
.x1p	cmp.w		CANVAS_WIDTH,d2
	blt.s		.x2i
	move.w	CANVAS_WIDTH,d2
	subq		#1,d2
.x2i	cmp.w		X1,d1
	bge.s		.nmnx
	move.w	d1,X1
.nmnx	cmp.w		X2,d2
	ble.s		.nmxx
	move.w	d2,X2
.nmxx	push.w	d3
	move.w	FG_COLOUR,d0
	jsr		horizontal_logline_d
	pop.w		d3
.new	rts
	endc
		
*-----------------------------------------------------------------------*
check_character:
*-----------------------------------------------------------------------*
.loop	move.w	(a2)+,d7
	cmp.w		#15,d7
	beq		.exit
	move.w	d7,d6
	and.w		#-4,d6
	bne.s		.err
	jmp		([.check_routs.l,d7.w*4])
.err	moveq		#-1,d0
	rts
.check_routs
	dc.l		.strt
	dc.l		.line
	dc.l		.bezi
	dc.l		.err
.strt	addq.l	#4,a2
	bra.s		.loop
.line	addq.l	#4,a2
	bra.s		.loop
.bezi	lea		12(a2),a2
	bra.s		.loop
.exit	moveq		#0,d0
	rts

*-----------------------------------------------------------------------*
build_character:
*-----------------------------------------------------------------------*
	move.l	scaler,d0
	dspwrite	d0			; send arbitrary scaling value
	dspwrite	baseline
	lea		$FFFFA202.w,a0
	lea		$FFFFA206.w,a1
next_pair:
	move.w	(a2)+,d0		; read and transfer line/curve codes
	move.w	d0,d1
	and.w		#-4,d1
	bne		end_path
	jmp		([CFN_routs.l,d0.w*4])
	
CFN_routs:
	dc.l		start_path
	dc.l		draw_to
	dc.l		curve_to
	dc.l		end_path

sendpair		macro
.wx\@	btst		#1,(a0)
	beq.s		.wx\@
	move.w	\1,(a1)
.wy\@	btst		#1,(a0)
	beq.s		.wy\@
	move.w	\1,(a1)
	endm
	
last_cfnx:	ds.w	1
last_cfny:	ds.w	1

start_path:
	dspwrite	#0			; send code #0 & X1:Y1
	sendpair	(a2)+
	ifd		hinting
	move.w	-4(a2),last_cfnx	
	move.w	-2(a2),last_cfny	
	endc
	jmp		next_pair
draw_to:
	dspwrite	#1			; send code #1 (line) & X2:Y2
	sendpair	(a2)+
	ifd		hinting
	move.w	-4(a2),d1
	move.w	-2(a2),d2
	cmp.w		last_cfny,d2
	bne.s		.skip	
	pushall
	move.w	d2,d3
	move.w	d1,d2
	move.w	last_cfnx(pc),d1
	sub.w		baseline(pc),d3
	jsr		hint
	popall
.skip	move.w	-4(a2),last_cfnx	
	move.w	-2(a2),last_cfny	
	endc
	jmp		next_pair
curve_to:
	dspwrite	#2			; send code #2 (curve) & P2,P3,X2:Y2
	sendpair	(a2)+
	sendpair	(a2)+
	sendpair	(a2)+
	jmp		next_pair
end_path:
	dspwrite	#3			; send code #3 (no more data)
	rts

Init_DSP_CFN:
	pushall
	moveq		#1,d1
	move.l	#DSPCFN_L,d0
	lea		DSPCFN,a0
	jsr		DspExecProg
	move.w	cfnsmooth,d0
	ext.l		d0
	dspwritel	d0
	popall
	rts

*-----------------------------------------------------------------------*


cfnptr:	ds.l		1
cfnend:	ds.l		1

cfnxgap2:	dc.w		100
cfnsmooth:	dc.w		20

CFN:		ds.w		1
cfn_x:	ds.l		1
cfn_y:	ds.l		1
scaler:	dc.l		50

lc_cfn_x:	ds.l		1
lc_cfn_y:	ds.l		1
lc_cfn_lk:	ds.l		1

cfn_count:	ds.w		1
cfn_pos:	ds.w		1
cfnxgap:	ds.w		1
cfnygap:	ds.w		1

ascender:	ds.w		1
descender:	ds.w		1
leftedge:	ds.w		1
topline:	ds.w		1
baseline:	ds.w		1

kern_list:	ds.l		1
last_kern:	ds.l		1
this_kern:	ds.l		1

*-----------------------------------------------------------------------*
