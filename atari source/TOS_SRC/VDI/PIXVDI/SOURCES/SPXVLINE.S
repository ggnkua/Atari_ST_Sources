*********************************  spxvline.s  ********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/sbblit.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 17:34:28 $     $Locker:  $
* =============================================================================
*
* $Log:	sbblit.s,v $
*******************************************************************************


.include	"lineaequ.s"


		.globl	spx_vline


*	Soft Vertical Line Code
*
*  in:	d4	X
*	d5	Y1
*	d6	X
*	d7	Y2
*
*	a4	pointer to LineA variable base

spx_vline:
 	move.l	_v_bas_ad,a1		; a1 -> base of screen
	move.w	_v_lin_wr(a4),d1	; d1 <- dst width (in bytes)
	move.w	d1,d2			; d2 <- dst width (in bytes)
	mulu	byt_per_pix(a4),d6	; d6 <- x portion of offset
	mulu	d5,d2			; d1 <- y portion of offset
	add.l	d6,d2			; d1 <- byte offs into mem frm
	add.l	d2,a1			; a0 -> (x,y)

	sub.w	d5,d7			; d7 <- dY: Y2-Y1
	bge	spx0			; dY<0  => plot from bottom up

	neg.w	d1			; d1 <- offset to next line up
	neg.w	d7			; d7 <- |dY|

spx0:	moveq.l	#$0F,d5			; d5 <- mod16 mask

	tst.w	_LSTLIN(a4)		; and not last line ...
	bne	spx1
;	subq.w	#1,d7			; don't plot last point  (DRI kludge)

spx1:	move.w	_LN_MASK(a4),d2		; d2 <- line style mask for this line
	move.w	d2,d3			; d3 <- line style mask for next line
	move.w	d7,d4			; d4 <- dbra pixel counter
	addq.w	#1,d4			; d4 <- line length
	and.w	d5,d4			; d4 <- alignment value: LENGTH mod16
	rol.w	d4,d3			; d3 <- line style mask for next line
	move.w	d3,_LN_MASK(a4)		; store line style mask for next line

	move.l	#-1,d0			; mask for XOR mode
	move.l	_FG_B_PLANES(a4),d3	; a1 -> bitplane color array
	lsl.w	#2,d3			; make d3 long word offset
	add.l	#pal_map,d3		; d3 <- desired offset
	move.l	(a4,d3.w),d3		; d3 <- desired foreground col
	move.l	pal_map(a4),d4		; d4 <- desired background col
	
	cmp.w	#16,_v_planes(a4)	; see how many bits per pixel
	beq	spx16Tab		; do 16 bits per pixel case
	blt	spx8Tab			; do 8 bits per pixel case
	lea	VLine32Tab,a2		; a2 -> table of 32 bit routines
	bra	tab_set

spx16Tab:
	lea	VLine16Tab,a2		; a2 -> table of 16 bit routines
	bra	tab_set

spx8Tab:	
	lea	VLine8Tab,a2		; a2 -> table of 8 bit routines

tab_set:
	move.w	_WRT_MODE(a4),d5	; clear for later use
	lsl.w	#2,d5			; d2 <- offset into the table
	move.l	(a2,d5.w),a0		; a0 -> desired routine
	jmp	(a0)			; go to the desired routine

VLine32Tab:	dc.l	V32M1Line,V32M2Line,V32M3Line,V32M4Line
VLine16Tab:	dc.l	V16M1Line,V16M2Line,V16M3Line,V16M4Line
VLine8Tab:	dc.l	V8M1Line,V8M2Line,V8M3Line,V8M4Line

*+
*	d0	contains $ffffffff
*	d1	line wrap (can be negative)
*	d2	line style mask
*	d3	foreground color ?
*	d4	background color ?
*	d7	# of pixels to plot - 1
*
*	a1	points to the first pixel
*-

******************************************************************************
******************************* 32 bit VLINE CASE ****************************
******************************************************************************
*+
* Replace mode (1)
*-
V32M1Line:
	rol.w	d2			; rotate the line style mask
	bcs	V32M1FG			; if cary is set set to foreground
	move.l	d4,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M1Line		; do nest pixel
	rts

V32M1FG:
	move.l	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M1Line		; do nest pixel
	rts

*+
* Transparent mode (2)
*-
V32M2Line:
	rol.w	d2			; rotate the line style mask
	bcs	V32M2FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M2Line		; do nest pixel
	rts

V32M2FG:
	move.l	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M2Line		; do nest pixel
	rts

*+
* XOR mode (3)
*-
V32M3Line:
	rol.w	d2			; rotate the line style mask
	bcs	V32M3FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M3Line		; do nest pixel
	rts

V32M3FG:
	eor.l	d0,(a1)			; XOR with -1
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M3Line		; do nest pixel
	rts

*+
* Reverse Transparent mode (4)
*-
V32M4Line:
	rol.w	d2			; rotate the line style mask
	bcs	V32M4FG			; if cary is set set to foreground
	move.l	d3,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M4Line		; do nest pixel
	rts

V32M4FG:
	add.w	d1,a1			; point to next pixel
	dbra	d7,V32M4Line		; do nest pixel
	rts

******************************************************************************
******************************* 16 bit VLINE CASE ****************************
******************************************************************************
*+
* Replace mode (1)
*-
V16M1Line:
	rol.w	d2			; rotate the line style mask
	bcs	V16M1FG			; if cary is set set to foreground
	move.w	d4,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M1Line		; do nest pixel
	rts

V16M1FG:
	move.w	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M1Line		; do nest pixel
	rts

*+
* Transparent mode (2)
*-
V16M2Line:
	rol.w	d2			; rotate the line style mask
	bcs	V16M2FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M2Line		; do nest pixel
	rts

V16M2FG:
	move.w	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M2Line		; do nest pixel
	rts

*+
* XOR mode (3)
*-
V16M3Line:
	rol.w	d2			; rotate the line style mask
	bcs	V16M3FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M3Line		; do nest pixel
	rts

V16M3FG:
	eor.w	d0,(a1)			; XOR with -1
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M3Line		; do nest pixel
	rts

*+
* Reverse Transparent mode (4)
*-
V16M4Line:
	rol.w	d2			; rotate the line style mask
	bcs	V16M4FG			; if cary is set set to foreground
	move.w	d3,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M4Line		; do nest pixel
	rts

V16M4FG:
	add.w	d1,a1			; point to next pixel
	dbra	d7,V16M4Line		; do nest pixel
	rts

******************************************************************************
*******************************  8 bit VLINE CASE ****************************
******************************************************************************
*+
* Replace mode (1)
*-
V8M1Line:
	rol.w	d2			; rotate the line style mask
	bcs	V8M1FG			; if cary is set set to foreground
	move.b	d4,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M1Line		; do nest pixel
	rts

V8M1FG:
	move.b	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M1Line		; do nest pixel
	rts

*+
* Transparent mode (2)
*-
V8M2Line:
	rol.w	d2			; rotate the line style mask
	bcs	V8M2FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M2Line		; do nest pixel
	rts

V8M2FG:
	move.b	d3,(a1)			; set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M2Line		; do nest pixel
	rts

*+
* XOR mode (3)
*-
V8M3Line:
	rol.w	d2			; rotate the line style mask
	bcs	V8M3FG			; if cary is set set to foreground
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M3Line		; do nest pixel
	rts

V8M3FG:
	eor.b	d0,(a1)			; XOR with -1
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M3Line		; do nest pixel
	rts

*+
* Reverse Transparent mode (4)
*-
V8M4Line:
	rol.w	d2			; rotate the line style mask
	bcs	V8M4FG			; if cary is set set to foreground
	move.b	d3,(a1)			; set to background
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M4Line		; do nest pixel
	rts

V8M4FG:
	add.w	d1,a1			; point to next pixel
	dbra	d7,V8M4Line		; do nest pixel
	rts

