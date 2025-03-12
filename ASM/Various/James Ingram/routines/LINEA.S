* Line-A library routines
*  by James Ingram, April 1993



	ifd	link_library
	MODULE	LINEA_INIT

	XDEF	init_linea
	XDEF	line_a_addr
	XDEF	col_from_d0
	endc


init_linea:
	dc.w	$a000
	move.l	a0,line_a_addr
	rts


col_from_d0:
* take colour in d0 and put it into fg_bp_?
	move.w	d0,d1
	and.w	#1,d1
	move.w	d1,_fg_bp_1(a0)

	move.w	d0,d1
	lsr.w	#1,d1
	and.w	#1,d1
	move.w	d1,_fg_bp_2(a0)

	move.w	d0,d1
	lsr.w	#2,d1
	and.w	#1,d1
	move.w	d1,_fg_bp_3(a0)

	move.w	d0,d1
	lsr.w	#3,d1
	and.w	#1,d1
	move.w	d1,_fg_bp_4(a0)
	rts



	ifd	link_library
	section	bss
	endc

line_a_addr:
	ds.l	1


	ifd	link_library
	MODULE	PIXELS
	XDEF	put_pixel,get_pixel

	XREF	line_a_addr
	endc


put_pixel:
* co-ords in d0,d1 colour in d2

	move.l	line_a_addr,a0		; get addr of linea vars
	move.l	intin(a0),a1		; get intin addr
	move.l	ptsin(a0),a2		; get ptsin addr

	move.w	d2,(a1)		; pass colour
	move.w	d0,(a2)
	move.w	d1,2(a2)	; pass co-ords

	dc.w	$a001
	rts


get_pixel:
* co-ords in d0,d1

	move.l	line_a_addr,a0

	move.l	ptsin(a0),a1	; get PTSIN array
	move.w	d0,(a1)+
	move.w	d1,(a1)		; pass co-ords

	dc.w	$a002
	rts


	ifd	link_library
	MODULE	LINES
	XDEF	line,horiz_line

	XREF	line_a_addr,col_from_d0
	endc


line:
* co-ords 1 in d0,d1
* co-ords 2 in d2,d3
* colour in d4
* line mask in d5
* write mod in d6


	move.l	line_a_addr,a0

	move.w	d0,_x1(a0)
	move.w	d1,_y1(a0)
	move.w	d2,_x2(a0)
	move.w	d3,_y2(a0)	; insert co-ords

	move.w	d5,_ln_mask(a0)	; mask
	move.w	d6,_wrt_mod(a0)	; write mode
	move.w	#-1,_lstlin(a0)

	move.w	d4,d0
	bsr	col_from_d0

	dc.w	$a003
	rts


horiz_line:
* co-ords 1 in d0,d1
* co-ords 2 in d2,d3	( d3 will be ignored)
* colour in d4
* line mask in d5
* write mod in d6


	move.l	line_a_addr,a0

	move.w	d0,_x1(a0)
	move.w	d1,_y1(a0)
	move.w	d2,_x2(a0)	; insert co-ords

	move.w	d5,_ln_mask(a0)	; mask
	move.w	d6,_wrt_mod(a0)	; write mode
	move.w	#-1,_lstlin(a0)

	move.w	d4,d0
	bsr	col_from_d0

	dc.w	$a004
	rts



	ifd	link_library
	MODULE	FILLS
	XDEF	filled_rectangle

	XREF	line_a_addr,col_from_d0
	endc


filled_rectangle:
* d0-d1 = coords 1
* d2-d3 = coords 2
* d4 = colour
* d5 = write mode
* d6 = patptr
* d7 = patmsk
* stack = clipping flag
* IF clipping on
*	clipping co-ords on stack in reverse order

	move.l	line_a_addr,a0
	movem.w	d0-d3,_x1(a0)

	move.w	d4,d0
	bsr	col_from_d0

	move.w	d5,_wrt_mod(a0)
	move.l	d6,_patptr(a0)
	move.w	d7,_patmsk(a0)

	move.l	(a7)+,a1

	move.w	(a7)+,d0
	move.w	d0,_clip(a0)

	tst.w	d0
	beq.s	no_clipping

* clipping required!

	move.w	(a7)+,d3
	move.w	(a7)+,d2
	move.w	(a7)+,d1
	move.w	(a7)+,d0

	movem.w	d0-d3,_xmn_clip(a0)


no_clipping:
	pea	(a1)
	dc.w	$a005
	rts



