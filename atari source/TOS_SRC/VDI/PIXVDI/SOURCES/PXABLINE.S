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


	.globl	PX_ABLINE


*******************************************************************************
*******************************************************************************
**									     **
**	ABLINE								     **
**		 							     **
**	  This routine draws a line between (_X1,_Y1) and (_X2,_Y2) using    **
**	  Bresenham's algorithm. The line is modified by the _LN_MASK and    **
**	  _WRT_MODE variables. This routine handles all 3 video resolutions  **
**									     **
**	Note:								     **
**									     **
**	  For line-drawing in VDI, the background color is fixed as 0	     **
**	  (i.e., there is no user-settable background color). This fact	     **
**	  allows coding short-cuts in the implementation of "replace" and    **
**	  "not" modes, resulting in faster execution of their inner loops.   **
**									     **
**	input:								     **
**									     **
**	   _X1,_Y1,_X2,_Y2 = coordinates.				     **
**	         _v_planes = number of video planes. (resolution)	     **
**	          _LN_MASK = line mask. (for dashed/dotted lines)	     **
**	         _WRT_MODE = writing mode.			  	     **
**									     **
**			     0 => replace mode.				     **
**			     1 => or mode.				     **
**			     2 => xor mode.				     **
**			     3 => not or mode.				     **
**									     **
**	output:								     **
**									     **
**	  _LN_MASK rotated to proper alignment with ( _X2,_Y2 ).	     **
**									     **
**									     **
**	destroys:							     **
**									     **
**	    everything.							     **
**									     **
**	FEATURES:							     **
**									     **
**	 o In the horizontal case, the pattern is not alligned prior to	     **
**	   the line being drawn, hence the pattern isn't in phase with	     **
**	   the pattern in the succeeding line. In any case, the entire	     **
**	   method for aligning horizontal patterns is incorrect.	     **
**									     **
**	 o The pattern is always implemented starting at the minimum vertex  **
**	   regardless of the intended direction of line segment. hence,      **
**	   patterns in consecutive segments are likely not to dovetail or    **
**	   to have a reversed pattern.					     **
**									     **
**	 o The procedure for preventing the endpoints in consecutive	     **
**	   segments that are XORed to the destination from cancelling 	     **
**	   is incorrectly implemented. The current method eliminates the     **
**	   last point at the maximum vertex regardless of the order of	     **
**	   the entered verticies (or direction of the preceeding segment).   **
**									     **
**									     **
*******************************************************************************
*******************************************************************************


PX_ABLINE:	
	move.l	_lineAVar,a4		; a4 -> base of LineA variables
	moveq.l	#2,d0			; d0 <- XOR writing mode code

	movem.w	_X1(a4),d4-d7		; d4<-X1  d5<-Y1  d6<-X2  d7<-Y2
	cmp.w	d5,d7			; handle the horizontal case seperately
	beq	hline			; (also handles single points)

	cmp.w	d4,d6			; X1=X2 => vertical line
	bne	aline			; handle the vertical case seperately


	;
	;   SPECIAL CASE I.	Vertical line segments
	;
	move.l	V_ROUTINES(a4),a5	; load vectrd list of primitives
	move.l	V_VLINE(a5),a5		; vec to vert line primitive
	jmp	(a5)			; sft: "aline"  hrd: "hb_vline"


	;   SPECIAL CASE II.	Horizontal line segment
	;
	;   All single point lines (X1=X2, Y1=Y2) will be arrive here

hline:		
	cmp.w	_WRT_MODE(a4),d0	; the XOR writing mode requires
	bne	no_trunk		; special endpoint treatment

	tst.w	_LSTLIN(a4)		; If this isn't the last line and
	bne	no_trunk		; the line is longer than one point,
	cmp.w	d4,d6			; truncate the line at the X2 vertex
	beq	no_trunk		; (DRI: "works most of the time")
	blt	lf_trunk

rt_trunk:	
	subq.w	#2,d6			; d6 <- Xmax-2
lf_trunk:
	addq.w	#1,d6			; d6 <- Xmin+1 or Xmax-1
	move.w	d6,_X2(a4)		; must stay compatible with last rev

no_trunk:
	cmp.w	d4,d6			; X1 must not be greater than X2
	bge	in_order		; if it is, swap the endpoints

	exg	d4,d6			; d4<-X2  d6<-X1
		
in_order:	
	move.w	d6,d1			; d1 <-  Xmax
	sub.w	d4,d1			; d1 <-  Xmax-Xmin
	addq.w	#1,d1			; d1 <-  Xmax-Xmin+1
	and.w	#$000F,d1		; d1 <- (Xmax-Xmin+1) mod 16

	lea	_LN_MASK(a4),a0		; a0 -> line style pattern
	clr.w	d0			; d0 <- offset to next pattern plane

	move.w	d1,-(sp)
	moveq.l	#0,d7			; means pattern is not rotated
	move.l	V_ROUTINES(a4),a5	; load vectrd list of primitives
	move.l	V_HLINE(a5),a5		; vec to vert line primitive
	jsr	(a5)			; sft: "aline"  hrd: "hb_vline"
	move.w	(sp)+,d1		; d1 <- mask alignment factor

	;
	; Update line pattern mask for next segment (this doesn't really work)
	;
	move.w	(a0),d0			; d0 <- original _LN_MASK
	rol.w	d1,d0			; d0 <- rotated line pattern mask
	move.w	d0,(a0)			; store rotated _LN_MASK
	rts

	;
	;   Process lines of arbitrary slope.
	;
aline:
	;
	; Order the endpoints
	;
no_frag:
	cmp.w	d4,d6			; X1 must not be greater than X2
	bge	xy_ok			; if it is, swap the endpoints

	exg	d4,d6			; d4<-X2  d6<-X1
	exg	d5,d7			; d5<-Y2  d7<-Y1

xy_ok:	sub.w	d4,d6			; d6 <- dX

	move.l	#0,a5			; a5 <- initial frag table offset

	move.l	_v_bas_ad,a0		; a0 <- video base address

	move.w	_bytes_lin(a4),d2	; d2 <- width of screen
	muls	d5,d2			; d2 <- offset to Y
	add.l	d2,a0			; a0 -> line containing Y
	move.w	byt_per_pix(a4),d3	; d3 <- bytes per pixel
	muls	d3,d4			; d4 <- offset to Xmin
	add.l	d4,a0			; a0 -> pixel containing (Xmin,Y)

	move.w	_v_lin_wr(a4),d0	; d0 <- vertical offset

	sub.w	d5,d7			; d7 <- dY
	bge	dy_ge_0			; if dY<0, adjust related parameters

	neg.w	d7			; d7 <- positive dY
	neg.w	d0			; d0 <- negative Yinc
	
dy_ge_0:	
	move.w	d0,a1			; a1 <- Yinc
	cmp.w	d6,d7			; which delta is larger?
	bgt	dmax_dmin		; adjust if dX is larger than dY

	exg	d6,d7			; d6 <- dY (dMin)   d7 <- dX (dMax)
	lea	16(a5),a5		; a5 <- offset to records for dX>dY

dmax_dmin:	
	move.w	d6,d4			; d4 <- dMin
	add.w	d4,d4			; d4 <- 2dMin
	move.w	d4,d5			; d5 <- e1
	sub.w	d7,d4			; d4 <- epsilon        2dMin - dMax
	move.w	d4,d6			; d6 <- 2dMax -dMin
	sub.w	d7,d6			; d6 <- e2             2dMin - 2dMax

	move.w	_WRT_MODE(a4),d0	; d0 <- writing mode code
	lsl.w	#2,d0
	add.w	d0,a5			; a5 <- offset for particular mode

	subq.w	#8,d0			; if XOR mode ...
	bne	al_nxtmask
	tst.w	_LSTLIN(a4)		; and not last line ...
	bne	al_nxtmask

	subq.w	#1,d7			; DRI kludge: don't plot last point

al_nxtmask:	

	lea	_LN_MASK(a4),a3		; a3 -> line style mask
	move.w	(a3),d0			; d0 <- line style mask
	move.w	d7,d2			; d2 <- dbra pixel counter
	addq.w	#1,d2			; d2 <- pixels in line
	and.w	#$000F,d2		; d2 <- alignment count
	rol.w	d2,d0			; d0 <- line style mask for next line
	move.w	(a3),d2			; d2 <- line style mask for this line
	move.w	d0,(a3)			; store line style mask for next line

	move.l	_FG_B_PLANES(a4),d0	; a1 -> bitplane color array
	lsl.w	#2,d0			; make d0 long word offset
	add.l	#pal_map,d0		; d0 <- desired offset
	move.l	(a4,d0.w),d0		; d0 <- desired foreground col
	move.l	pal_map(a4),d1		; d1 <- desired background col

	cmp.w	#16,_v_planes(a4)	; see how many bits per pixel
	beq	px16Tab			; do 16 bits per pixel case
	blt	px8Tab			; do 8 bits per pixel case
	add.l	#wm32_tbl,a5		; point to proper table entry
	move.l	(a5),a5			; a5 -> proper 32 bit routine
	jmp	(a5)

px16Tab:
	add.l	#wm16_tbl,a5		; point to proper table entry
	move.l	(a5),a5			; a5 -> proper 16 bit routine
	jmp	(a5)

px8Tab:
	add.l	#wm8_tbl,a5		; point to proper table entry
	move.l	(a5),a5			; a5 -> proper 8 bit routine
	jmp	(a5)

al_quit:
	rts

*+
*   Offset table of Writing Mode entry points.
*   The absolute address of the table entry plus the word offset at that
*   entry becomes the absolute address of the writing mode entry point.
*-
wm32_tbl:	dc.l	    wm32_0y	; replace		dY > dX
		dc.l	    wm32_1y	; transparent		dY > dX
		dc.l	    wm32_2y	; XOR			dY > dX
		dc.l	    wm32_3y	; reverse transparent	dY > dX
		dc.l	    wm32_0x	; replace		dX > dY
		dc.l	    wm32_1x	; transparent		dX > dY
		dc.l	    wm32_2x	; XOR			dX > dY
		dc.l	    wm32_3x	; reverse transparent	dX > dY

wm16_tbl:	dc.l	    wm16_0y	; replace		dY > dX
		dc.l	    wm16_1y	; transparent		dY > dX
		dc.l	    wm16_2y	; XOR			dY > dX
		dc.l	    wm16_3y	; reverse transparent	dY > dX
		dc.l	    wm16_0x	; replace		dX > dY
		dc.l	    wm16_1x	; transparent		dX > dY
		dc.l	    wm16_2x	; XOR			dX > dY
		dc.l	    wm16_3x	; reverse transparent	dX > dY

wm8_tbl:	dc.l	    wm8_0y	; replace		dY > dX
		dc.l	    wm8_1y	; transparent		dY > dX
		dc.l	    wm8_2y	; XOR			dY > dX
		dc.l	    wm8_3y	; reverse transparent	dY > dX
		dc.l	    wm8_0x	; replace		dX > dY
		dc.l	    wm8_1x	; transparent		dX > dY
		dc.l	    wm8_2x	; XOR			dX > dY
		dc.l	    wm8_3x	; reverse transparent	dX > dY

*+
*		a4   points to line A variable struct
*		a1 = offset to next line in Y
*		a0 = ptr to destination 
*
*		d7 = dbra pixel counter
*		d6 = e2
*		d5 = e1
*		d4 = epsilon
*		d3 = bytes per pixel
*		d2 = line style mask
*		d1 = background color
*		d0 = foreground color
*-

******************************************************************************
******************************* 32 bit case **********************************
******************************************************************************
*+
*	     WRITING MODE 0:  REPLACE			   dY > dX
*-
wm32_0y:	rol.w	d2		; cy: next style bit
		bcs	wm32_0yFG	; branch if style bit is set
		move.l	d1,(a0)		; set to background
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_0y	; do next pixel
		rts

wm32_0yFG:	move.l	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_0y	; do next pixel
		rts

wm32_0y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_0y	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dY > dX
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dY > dX
*-
wm32_3y:	not.w	d2
wm32_1y:	rol.w	d2		; cy: next style bit
		bcs	wm32_1yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_1y	; do next pixel
		rts

wm32_1yFG:	move.l	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_1y	; do next pixel
		rts

wm32_1y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_1y	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dY > dX
*-

wm32_2y:	move.l	#-1,d0		; set for XOR mode
wm32_2yL:	rol.w	d2		; cy: next style bit
		bcs	wm32_2yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_2yL	; do next pixel
		rts

wm32_2yFG:	eor.l	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_2yL	; do next pixel
		rts

wm32_2y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_2yL	; do next pixel
		rts

*+
*	     WRITING MODE 0:  REPLACE			   dX > dY
*-
wm32_0x:	rol.w	#1,d2		; cy: next style bit
		bcs	wm32_0xFG	; branch if style bit is 1
		move.l	d1,(a0)+	; set to background
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_0x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_0x	; do next pixel
		rts

wm32_0xFG:	move.l	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm32_0x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_0x	; do next pixel
		rts

wm32_0x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_0x	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dX > dY
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dX > dY
*-
wm32_3x:	not.w	d2		; invert the style mask
wm32_1x:	rol.w	#1,d2		; cy: next style bit
		bcs	wm32_1xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_1x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_1x	; do next pixel
		rts

wm32_1xFG:	move.l	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm32_1x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_1x	; do next pixel
		rts

wm32_1x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_1x	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dX > dY
*-
wm32_2x:	move.l	#-1,d0		; set eor mask of XOR mode
wm32_2xL:	rol.w	#1,d2		; cy: next style bit
		bcs	wm32_2xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm32_2x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_2xL	; do next pixel
		rts

wm32_2xFG:	eor.l	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm32_2x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm32_2xL	; do next pixel
		rts

wm32_2x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm32_2xL	; do next pixel
		rts

******************************************************************************
******************************* 16 bit case **********************************
******************************************************************************

*+
*	     WRITING MODE 0:  REPLACE			   dY > dX
*-
wm16_0y:	rol.w	d2		; cy: next style bit
		bcs	wm16_0yFG	; branch if style bit is set
		move.w	d1,(a0)		; set to background
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_0y	; do next pixel
		rts

wm16_0yFG:	move.w	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_0y	; do next pixel
		rts

wm16_0y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_0y	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dY > dX
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dY > dX
*-
wm16_3y:	not.w	d2
wm16_1y:	rol.w	d2		; cy: next style bit
		bcs	wm16_1yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_1y	; do next pixel
		rts

wm16_1yFG:	move.w	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_1y	; do next pixel
		rts

wm16_1y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_1y	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dY > dX
*-

wm16_2y:	move.w	#-1,d0		; set for XOR mode
wm16_2yL:	rol.w	d2		; cy: next style bit
		bcs	wm16_2yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_2yL	; do next pixel
		rts

wm16_2yFG:	eor.w	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_2yL	; do next pixel
		rts

wm16_2y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_2yL	; do next pixel
		rts

*+
*	     WRITING MODE 0:  REPLACE			   dX > dY
*-
wm16_0x:	rol.w	#1,d2		; cy: next style bit
		bcs	wm16_0xFG	; branch if style bit is 1
		move.w	d1,(a0)+	; set to background
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_0x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_0x	; do next pixel
		rts

wm16_0xFG:	move.w	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm16_0x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_0x	; do next pixel
		rts

wm16_0x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_0x	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dX > dY
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dX > dY
*-
wm16_3x:	not.w	d2		; invert the style mask
wm16_1x:	rol.w	#1,d2		; cy: next style bit
		bcs	wm16_1xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_1x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_1x	; do next pixel
		rts

wm16_1xFG:	move.w	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm16_1x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_1x	; do next pixel
		rts

wm16_1x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_1x	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dX > dY
*-
wm16_2x:	move.w	#-1,d0		; set eor mask of XOR mode
wm16_2xL:	rol.w	#1,d2		; cy: next style bit
		bcs	wm16_2xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm16_2x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_2xL	; do next pixel
		rts

wm16_2xFG:	eor.w	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm16_2x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm16_2xL	; do next pixel
		rts

wm16_2x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm16_2xL	; do next pixel
		rts

******************************************************************************
*******************************  8 bit case **********************************
******************************************************************************

*+
*	     WRITING MODE 0:  REPLACE			   dY > dX
*-
wm8_0y:		rol.w	d2		; cy: next style bit
		bcs	wm8_0yFG	; branch if style bit is set
		move.b	d1,(a0)		; set to background
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_0y	; do next pixel
		rts

wm8_0yFG:	move.b	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_0y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_0y	; do next pixel
		rts

wm8_0y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_0y	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dY > dX
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dY > dX
*-
wm8_3y:		not.w	d2
wm8_1y:		rol.w	d2		; cy: next style bit
		bcs	wm8_1yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_1y	; do next pixel
		rts

wm8_1yFG:	move.b	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_1y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_1y	; do next pixel
		rts

wm8_1y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_1y	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dY > dX
*-

wm8_2y:		move.b	#-1,d0		; set for XOR mode
wm8_2yL:	rol.w	d2		; cy: next style bit
		bcs	wm8_2yFG	; branch if style bit is set
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_2yL	; do next pixel
		rts

wm8_2yFG:	eor.b	d0,(a0)		; set to foreground
		add.w	a1,a0		; a0 -> next vertical word
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_2y_nc	; branch if X doesn't change
		add.w	d3,a0		; point to next pixel in X dir
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_2yL	; do next pixel
		rts

wm8_2y_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_2yL	; do next pixel
		rts

*+
*	     WRITING MODE 0:  REPLACE			   dX > dY
*-
wm8_0x:		rol.w	#1,d2		; cy: next style bit
		bcs	wm8_0xFG	; branch if style bit is 1
		move.b	d1,(a0)+	; set to background
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_0x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_0x	; do next pixel
		rts

wm8_0xFG:	move.b	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm8_0x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_0x	; do next pixel
		rts

wm8_0x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_0x	; do next pixel
		rts

*+
*	     WRITING MODE 1:  TRANSPARENT		  dX > dY
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dX > dY
*-
wm8_3x:		not.w	d2		; invert the style mask
wm8_1x:		rol.w	#1,d2		; cy: next style bit
		bcs	wm8_1xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_1x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_1x	; do next pixel
		rts

wm8_1xFG:	move.b	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm8_1x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_1x	; do next pixel
		rts

wm8_1x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_1x	; do next pixel
		rts

*+
*	     WRITING MODE 2:  XOR			  dX > dY
*-
wm8_2x:		move.b	#-1,d0		; set eor mask of XOR mode
wm8_2xL:	rol.w	#1,d2		; cy: next style bit
		bcs	wm8_2xFG	; branch if style bit is 1
		add.w	d3,a0		; point to next X pixel
		tst.w	d4		; epsilon < 0  =>  don't change X
		bmi	wm8_2x_nc	; branch if X doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_2xL	; do next pixel
		rts

wm8_2xFG:	eor.b	d0,(a0)+	; set to foreground
		tst.w	d4		; epsilon < 0  =>  don't change Y
		bmi	wm8_2x_nc	; branch if Y doesn't change
		add.w	a1,a0		; a0 -> next vertical word
		add.w	d6,d4		; d4 <- epsilon + e2
		dbra	d7,wm8_2xL	; do next pixel
		rts

wm8_2x_nc:	add.w	d5,d4		; d4 <- epsilon + e1
		dbra	d7,wm8_2xL	; do next pixel
		rts
