********************************  gsxasm1.s  **********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/gsxasm1.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/13 11:37:39 $     $Locker:  $
* =============================================================================
*
* $Log:	gsxasm1.s,v $
* Revision 3.2  91/02/13  11:37:39  lozben
* Adjusted the code to work with the multiple linea variable structures..
* 
* Revision 3.1  91/02/07  18:35:38  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:09:28  lozben
* New generation VDI
* 
* Revision 2.5  90/05/03  16:36:03  lozben
* Added conditional code in pixfrag() to clear the instruction cache
* if one is available. We do this because we compile code on the stack.
* 
* Revision 2.4  90/02/16  12:22:34  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.3  89/05/16  13:01:52  lozben
* Changed pix_frag() to deal with a color index (FG_B_PLANES) instead
* of dealing with back plane flags (FG_BP_[1,2,3,4]).
* 
* Revision 2.2  89/04/13  20:14:48  lozben
* Moved hb_vline(), hb_hline() into another file. The idea
* is to have all the hard blit code in independent files.
* 
* Revision 2.1  89/02/21  17:21:12  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"
.include	"vdiincld.s"

*		global routines
		xdef	_ABLINE
		xdef	ST_ABLINE
		xdef	ST_HABLINE
		xdef	_HABLINE
		xdef	_CLC_FLIT
		xdef	_SMUL_DIV
		xdef	_vec_len
		xdef	 concat
		xdef	 fline
		xdef	 pixfrag


*		tables referenced from gsxasm2.s
		xdef	 lf_tab
		xdef	 rf_tab


*		external variables
		xref	_v_bas_ad

MAX_PLANES	equ	 08		; maximum planes for pixel fragment
FRAG_LEN	equ	 MAX_PLANES*4+4 ; space for fragment of 16 planes
	.text

*******************************************************************************
*******************************************************************************
**									     **
**	_vec_len							     **	
**									     **
**		This routine computes the length of a vector using the       **
**		formula: SQRT( dX**2 + dY**2 )				     **
**									     **
**		input:	4(sp) = dX					     **
**			6(sp) = dY					     **
**									     **
**		output: d0 = SQRT( dX**2 + dY**2 )			     **
**									     **
**		destroys: d0-d4						     **
**									     **
*******************************************************************************
*******************************************************************************


_vec_len:	move.w	4(sp),d0	; d0 <- dX
		muls	d0,d0		; d0 <- dX**2
		move.w	6(sp),d1	; d1 <- dY
		muls	d1,d1		; d1 <- dY**2
		add.l	d0,d1		; d1 <- dX**2 + dY**2
		beq	vl_out		; quit on null length

*   Compute an initial upper and lower bound on the square root. The lower
*   bound is the largest number that is no more than half the length of
*   The square; the upper bound is twice the lower bound.

		move.l	d1,d0		; d0 <- dX**2 + dY**2
		moveq.l	#00,d2		; d2 <- initial exponent: 2**00
		cmp.l	#$10000,d1	; significant digits in high word?
		bcs	bds_lp		; if so, concentrate on high word.

		swap	d1		; d1 <- high word of square
		moveq.l	#16,d2		; d2 <- initial exponent: 2**16

bds_lp:		cmp.w	#1,d1		; any significant digits left ?
		beq	bds_end		; no => time to calculate bounds

		addq.w	#1,d2		; d2 <- exponent +1
		lsr.w	#1,d1		; d1 <- square/2
		bra	bds_lp

bds_end:	asr.w	#1,d2		; d2 <- exponent/2  (square root)
		moveq.l	#1,d3
		asl.w	d2,d3		; d3 <- initial lower bound
		move.w	d3,d2
		add.w	d2,d2		; d2 <- initial upper bound
		bne	srch_lp		; check for overflow

		subq.w	#1,d2		; d2 <- maximum value: FFFF


*   Now, perform a binary search for the square root.

srch_lp:	move.w	d2,d1		; d1 <- upper bound
		sub.w	d3,d1		; d1 <- upper bound - lower bound
		cmp.w	#1,d1		; 
		beq	srch_end	; quit when the delta is 1

		asr.w	#1,d1		; d1 <- half the difference
		add.w	d3,d1		; d1 <- midway 'tween the boundries
		move.w	d1,d4		; d4 <- copy of candidate
		mulu	d1,d1		; d1 <- candidate**2
		cmp.l	d0,d1		; compare with target
		bhi	hi_adjust	; if candidate too large, branch.
		bcs	lo_adjust	; if candidate too small, branch.

		move.w	d4,d0		; d0 <- exactly the square root
		rts


hi_adjust:	move.w	d4,d2		; d2 <- new upper bound
		bra	srch_lp

lo_adjust:	move.w	d4,d3		; d3 <- new lower bound
		bra	srch_lp

srch_end:	move.w	d3,d0		; no match: use the lower bound

vl_out:		rts



*******************************************************************************
*******************************************************************************
**									     **
**	_CLC_FLIT							     **
**									     **
**		This routine calculates the fill intersections for a list of **
**	vectors.  The x-intersection of each vector with the scan-line of    **
**	interest is calculated and inserted into a buffer which is then      **
**	sorted in ascending order.  The resulting array of x-values are then **
**	pulled out pair-wise and used as inputs to "_HABLINE".		     **
**									     **
**		input:	CONTRL[1] = number of vectors.			     **
**			PTSIN[]   = array of vertices.			     **
**			Y1        = scan-line to calculate intersections for **
**									     **
**		output: fil_int  = number of intersections.		     **
**			fill_buf  = array of x-values.			     **
**									     **
**		destroys: everything.					     **
**									     **
*******************************************************************************
*******************************************************************************

x1		equ	0
y1		equ	2
x2		equ	4
y2		equ	6


_CLC_FLIT:	move.l  _lineAVar,a2	; a2 -> linea var struct
		move.l	_CONTRL(a2),a0
		move.w	2(a0),d0	; d0 <- number of vectors
		subq.w	#1,d0		; d0 <- dbra counter

		move.l	_PTSIN(a2),a0		; a0 -> array of vertices
		lea	_fill_buffer,a1		; a1 -> array of X coordinates
		clr.w	fil_intersect(a2)	; init cnt of fill intrsctions

flit_lp:	move.w	y2(a0),d1	; d1 <- Y coordinate of 2nd endpoint
		move.w	y1(a0),d2	; d2 <- Y coordinate of 1st endpoint
		sub.w	d2,d1		; d1 <- dY
		beq	no_fill_int	; Ignore Horizantal Vectors

		move.w	_Y1(a2),d3	; d3 <- scanline Y
		move.w	d3,d4
		sub.w	d2,d4		; d4 <- dY1
		sub.w	y2(a0),d3	; d3 <- dY2
		move.w	d4,d2
		eor.w	d3,d2		; are the signs equal?
		bpl	no_fill_int	; yes, ignore this vector.


*    This test also handles the case when dY1 = 0 or dY2 = 0.  Thus, the
*    singularity case discussed in Newman & Sproull is properly handled.

		move.w	x2(a0),d2	; d2 <-   X2
		sub.w	x1(a0),d2	; d2 <-   dX	   (really dX-1)
		add.w	d2,d2		; d2 <-  2dX       (greater precision)
		muls	d2,d4		; d4 <- 2(dX * dY1)
		divs	d1,d4		; d4 <- 2(dX * dY1) /dY
		bpl	int_pos


int_neg:	neg.w	d4		; Matt did it this way and it works
		addq.w	#1,d4
		asr.w	#1,d4
		neg.w	d4
		bra	ld_fill_int

*int_neg:	subq.w	#1,d4		; compensate for round off error
*		asr.w	#1,d4		; d4 <-  (dX * dY1) /dY
*		bra	ld_fill_int	; *%$@!# This Doesn't Work ?@!#$*

int_pos:	addq.w	#1,d4		; compensate for round off error
		asr.w	#1,d4		; d4 <-  (dX * dY1) /dY

ld_fill_int:	add.w	x1(a0),d4		; d4 <- ((dX * dY1) /dY) + X1
		move.w	d4,(a1)+		; put intrsctn X into fill buf
		addq.w	#1,fil_intersect(a2)	; increment intersection count

no_fill_int:	lea	4(a0),a0		; a0 -> next pair of endpoints
		dbra	d0,flit_lp


*   Now that all the intersections have been found, sort them.

sort_fill_int:	move.w	fil_intersect(a2),d0	; d0 <- intersections
		bne	sfi_cont
		rts				; quit if nothing to sort

sfi_cont:	lea	_fill_buffer,a0		; a0 -> list of intersections
		bsr	bub_sort		; bubble-sort it


*   Now, do the necessary work to fill between the intersections.

		move.w	fil_intersect(a2),d0
		asr.w	#1,d0			; d0 <- number of x-pairs.
		subq.w	#1,d0			; d0 <- dbra counter
		tst.w	_CLIP(a2)		; is clipping on?
		bne	dr_clip			; yes, branch.

draw_lp:	move.w	(a1)+,_X1(a2)	; grab a pair of X intersections.
		move.w	(a1)+,_X2(a2)
		move.w	d0,-(sp)	; save the count
		move.l	a1,-(sp)	; save the pointer
		bsr	_HABLINE	; fill between X's.
		move.l  _lineAVar,a2	; a2 -> linea var struct
		move.l	(sp)+,a1	; a1 -> next pair of points
		move.w	(sp)+,d0	; d0 <- dbra pair counter
		dbra	d0,draw_lp
		rts


dr_clip:	move.w	(a1)+,_X1(a2)		; grab a pair of X intrsections
		move.w	(a1)+,_X2(a2)
		move.w	_XMN_CLIP(a2),d1	; clip X pair to minimum
		move.w	_X1(a2),d2
		move.w	_X2(a2),d3
		cmp.w	d1,d2		; is X1 < MINIMUM X ?
		bge	drc_1		; if so, check for a total eclipse

		cmp.w	d1,d3		; is X2 < minimum X ?
		blt	drc_end		; if so, segment is totally obscured

		move.w	d1,_X1(a2)		; clip X1 to minimum

drc_1:		move.w	_XMX_CLIP(a2),d1	; clip X pair to maximum
		cmp.w	d1,d3			; is X2 > maximum X ?
		ble	drc_2			; no => draw segment

		cmp.w	d1,d2		; is X1 > maximum X ?
		bgt	drc_end		; if so, segment is totally obscured

		move.w	d1,_X2(a2)	; clip X2 to maximum

drc_2:		move.w	d0,-(sp)	; save the dbra count
		move.l	a1,-(sp)	; save the pointer to the point list
		bsr	_HABLINE	; fill between the X1 and X2
		move.l  _lineAVar,a2	; a2 -> linea var struct
		move.l	(sp)+,a1	; a1 -> next point pair
		move.w	(sp)+,d0	; d0 <- dbra count
drc_end:	dbra	d0,dr_clip
		rts


*******************************************************************************
*******************************************************************************
**									     **
**	bub_sort							     **
**									     **
**		This routine bubble-sorts an array of words into ascending   **
**		order.							     **
**									     **
**		input:	a0 = ptr to start of array.			     **
**			d0 = number of words in array.	(unsigned word)	     **
**									     **
**		output: a1 = ptr to start of sorted array.		     **
**									     **
**		destroys: d0-d2/a0-a1					     **
**									     **
*******************************************************************************
*******************************************************************************


bub_sort:	subq.w	#2,d0		; d0 <- number of compares -1
		bcs	bs_out		; there must be more than one point

		move.w	d0,d1		; d1 <- copy of swap count
		move.l	a0,a1		; a1 -> start of point list

bsl0_init:	move.w	d1,d0		; d0 <- initial dbra count
		move.l	a1,a0		; a1 -> start of list
bs_lp0:		move.w	(a0)+,d2	; d2 <- X1
		cmp.w	(a0),d2		; compare with X2
		ble	bs_noswap	; if in ascending order, skip exchange

		move.w	(a0),-2(a0)	; X1' <- X2
		move.w	d2,(a0)		; X2' <- X1
bs_noswap:	dbra	d0,bs_lp0	; completes 1 pass of the sort.
*					; the largest word has been bubbled
*					; down to the end of the array.
bsl1_end:	dbra	d1,bsl0_init	; shorten the count for the next pass.

bs_out:		rts


*******************************************************************************
*******************************************************************************
**									     **
**  smul_div (m1,m2,d1)							     **
**								     	     **
**	( ( M1 * M2 ) / D1 ) + 1					     **
**	M1 = signed 16 bit integer					     **
**	M2 = unsigned 15 bit integer					     **
**	D1 = signed 16 bit integer					     **
**									     **
*******************************************************************************
*******************************************************************************

_SMUL_DIV:	moveq.l	#1,d1		; d1 <- positive increment
		move.w	6(sp),d0
		muls	4(sp),d0	; d0 <- M2 * M1
		bge	smd_1

		neg.w	d1		; d1 <- negative increment

smd_1:		move.w	8(sp),d2	; d2 <- divisor  (D1)
		divs	d2,d0		; d0 <- M2 * M1 / D1
		tst.w	d2		; was divisor negative ?
		bge	smd_2

		neg.w	d1		; negate increment
		neg.w	d2		; d2 <- positive divisor

smd_2:		move.l	d3,-(sp)
		move.l	d0,d3
		bge	smd_3		; the remainder must be positive

		neg.l	d3		; d3[31:16] <- positive remainder

smd_3:		swap	d3		; d3[15:00] <- remainder
		add.w	d3,d3
		cmp.w	d2,d3
		blt	smd_4		; if remainder*2 > divisor,

		add.w	d1,d0		; round up

smd_4:		move.l	(sp)+,d3
		rts


*******************************************************************************
*******************************************************************************
**									     **
**	comments:							     **
**									     **
**	  Two bugs have been found and fixed in this 68000 implementation    **
**	  of these VDI line-drawing routines.  Both bugs were due to	     **
**	  entering "HABLINE" from "ABLINE" on horizontal lines.		     **
**									     **
**	    1) the XOR mode patch was not applied.			     **
**	    2) LN_MASK was not rotated to align with X2 on exit.	     **
**									     **
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
**									     **
**	concat								     **
**									     **
**	  This routine converts (by "concatenating") Y and X coordinates     **
**	  into the physical address and bit index into that word	     **
**									     **
**	  input:	d0.w = signed X coordinate.			     **
**			d1.w = signed Y coordinate.			     **
**									     **
**	  output:	d0.w = bit index into word    (X mod 16)	     **
**			d1.l = address offset				     **
**			       (Y * bytes_per_line) + (X & Xmask) >> Xshift  **
**									     **
**	  destroys: 	nothing.					     **
**									     **
*******************************************************************************
*******************************************************************************

concat:	movem.l	d2-d3/a0,-(sp)

	move.l  _lineAVar,a0		; a0 -> linea var struct
	muls	_bytes_lin(a0),d1	; d1 <- offset to (0,Y)

	move.w	_v_planes(a0),d3
	move.b	shf_tab-1(pc,d3.w),d3	; d3 <- shift factor for plane adjust

	move.w	d0,d2			; d2[15:00] <- signed X
	ext.l	d2			; d2[31:00] <- signed X
	and.w	#$FFF0,d2		; clamp to word boundry
	asr.w	d3,d2			; d2 <- X displacement (in bytes)
	add.l	d2,d1			; d1 <- offset into screen

	and.w	#$000F,d0		; d0 <- X mod 16

	movem.l	(sp)+,d2-d3/a0
	rts

shf_tab:   *    1 2   4       8		; number of planes

	dc.b	3,2,0,1,0,0,0,0		; right shift factor


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


_ABLINE:	move.l	_lineAVar,a4		; a4 -> base of LineA variables
		move.l	V_ROUTINES(a4),a5	; load vectrd list of primitives
		move.l	V_ABLINE(a5),a5		; vec to vert line primitive
		jmp	(a5)			; sft: "aline"  hrd: "hb_vline"

ST_ABLINE:	move.l	_lineAVar,a4	; a4 -> base of LineA variables
		moveq.l	#2,d0		; d0 <- XOR writing mode code

		movem.w	_X1(a4),d4-d7	; d4<-X1  d5<-Y1  d6<-X2  d7<-Y2
		cmp.w	d5,d7		; handle the horizontal case seperately
		beq	hline		; (also handles single points)

		cmp.w	d4,d6		; X1=X2 => vertical line
		bne	aline		; handle the vertical case seperately

*   SPECIAL CASE I.	Vertical line segments

		move.l	V_ROUTINES(a4),a5	; load vectrd list of primitives
		move.l	V_VLINE(a5),a5		; vec to vert line primitive
		jmp	(a5)			; sft: "aline"  hrd: "hb_vline"



*   SPECIAL CASE II.	Horizontal line segment
*
*   All single point lines (X1=X2, Y1=Y2) will be arrive here


hline:		cmp.w	_WRT_MODE(a4),d0	; the XOR writing mode requires
		bne	no_trunk	; special endpoint treatment

		tst.w	_LSTLIN(a4)	; If this isn't the last line and
		bne	no_trunk	; the line is longer than one point,
		cmp.w	d4,d6		; truncate the line at the X2 vertex
		beq	no_trunk	; (DRI: "works most of the time")
		blt	lf_trunk

rt_trunk:	subq.w	#2,d6		; d6 <- Xmax-2
lf_trunk:	addq.w	#1,d6		; d6 <- Xmin+1 or Xmax-1
		move.w	d6,_X2(a4)	; must stay compatible with last rev

no_trunk:	cmp.w	d4,d6		; X1 must not be greater than X2
		bge	in_order	; if it is, swap the endpoints

		exg	d4,d6		; d4<-X2  d6<-X1
		
in_order:	move.w	d6,d1		; d1 <-  Xmax
		sub.w	d4,d1		; d1 <-  Xmax-Xmin
		addq.w	#1,d1		; d1 <-  Xmax-Xmin+1
		and.w	#$000F,d1	; d1 <- (Xmax-Xmin+1) mod 16

		lea	_LN_MASK(a4),a0	; a0 -> line style pattern
		clr.w	d0		; d0 <- offset to next pattern plane

		move.w	d1,-(sp)
		bsr	xline		; do horizontal line
		move.w	(sp)+,d1	; d1 <- mask alignment factor

*   Update line pattern mask for next segment (this doesn't really work)

		move.w	(a0),d0		; d0 <- original _LN_MASK
		rol.w	d1,d0		; d0 <- rotated line pattern mask
		move.w	d0,(a0)		; store rotated _LN_MASK

		rts



*   Process lines of arbitrary slope.

aline:		lea	-FRAG_LEN(sp),sp  ; sp -> pixel fragment frame

		move.w	_v_planes(a4),d3  ; d3 <- number of planes
		cmp.w	#MAX_PLANES,d3	  ; too many planes for the buffer ?
		bhi	al_quit		  ; if so, end prematurely

		cmp.w	_WRT_MODE(a4),d0  ; don't build fragment for XOR mode
		beq	no_frag

		move.l	sp,a2		  ; a2 -> ram for pixel fragment code
		bsr	pixfrag


*	     Order the endpoints

no_frag:	cmp.w	d4,d6		; X1 must not be greater than X2
		bge	xy_ok		; if it is, swap the endpoints

		exg	d4,d6		; d4<-X2  d6<-X1
		exg	d5,d7		; d5<-Y2  d7<-Y1

xy_ok:		sub.w	d4,d6		; d6 <- dX

		moveq.l	#0,d1		; d1 <- premordial OR mask
		move.l	d1,a5		; a5 <- initial frag table offset

		move.w	d4,d0		; d0 <- Xmin
		not.w	d0
		and.w	#$000F,d0	; d0 <- bit number
		bset.l	d0,d1		; d1 <- OR mask

		move.l	_v_bas_ad,a0		; a0 <- video base address
		move.w	_v_planes(a4),d3	; d3 <- plane count
		add.w	d3,d3			; d3 <- off to nxt wrd in plane

		move.w	_bytes_lin(a4),d2	; d2 <- width of screen
		muls	d5,d2			; d2 <- offset to Y
		add.l	d2,a0			; a0 -> line containing Y
		asr.w	#4,d4			; d4 <- word offset to X
		muls	d3,d4			; d4 <- offset to Xmin
		add.l	d4,a0			; a0 -> word containing (Xmin,Y)

		move.w	_v_lin_wr(a4),d0	; d0 <- vertical offset

		sub.w	d5,d7		; d7 <- dY
		bge	dy_ge_0		; if dY<0, adjust related parameters

		neg.w	d7		; d7 <- positive dY
		neg.w	d0		; d0 <- negative Yinc
	
dy_ge_0:	move.w	d0,a1		; a1 <- Yinc
		cmp.w	d6,d7		; which delta is larger?
		bgt	dmax_dmin	; adjust if dX is larger than dY

		exg	d6,d7		; d6 <- dY (dMin)   d7 <- dX (dMax)
		lea	16(a5),a5	; a5 <- offset to records for dX>dY

dmax_dmin:	move.w	d6,d4		; d4 <- dMin
		add.w	d4,d4		; d4 <- 2dMin
		move.w	d4,d5		; d5 <- e1
		sub.w	d7,d4		; d4 <- epsilon        2dMin - dMax
		move.w	d4,d6		; d6 <- 2dMax -dMin
		sub.w	d7,d6		; d6 <- e2             2dMin - 2dMax

		move.w	_WRT_MODE(a4),d0	; d0 <- writing mode code
		lsl.w	#2,d0
		add.w	d0,a5		; a5 <- offset for particular mode

		subq.w	#8,d0		; if XOR mode ...
		bne	al_nxtmask
		tst.w	_LSTLIN(a4)	; and not last line ...
		bne	al_nxtmask

		subq.w	#1,d7		; DRI kludge: don't plot last point

al_nxtmask:	lea	_LN_MASK(a4),a3	; a3 -> line style mask
		move.w	(a3),d0		; d0 <- line style mask
		move.w	d7,d2		; d2 <- dbra pixel counter
		addq.w	#1,d2		; d2 <- pixels in line
		and.w	#$000F,d2	; d2 <- alignment count
		rol.w	d2,d0		; d0 <- line style mask for next line
		move.w	(a3),d2		; d2 <- line style mask for this line
		move.w	d0,(a3)		; store line style mask for next line

		move.w	d1,d0		; d1 <- OR mask
		not.w	d0		; d0 <- AND mask

		lea	wm_tbl(pc,a5.w),a5 ; a5 -> offset to pixel frag return
		move.l	 a5,a3		   ; a3 -> offset to pixel frag return
		add.w	(a5)+,a3	   ; a3 <- thread back from pixel frag
		move.l	 a3,a4		   ; a4 -> base of pixel tower
		sub.w	 d3,a4		   ; a4 <- thread into pixel tower
		add.w	(a5),a5		   ; a5 -> writing mode routine
		jsr	(a5)		   ; so go do it already

al_quit:	lea	FRAG_LEN(sp),sp	   ; clean up the stack
		rts


*   Offset table of Writing Mode entry points.
*   The absolute address of the table entry plus the word offset at that
*   entry becomes the absolute address of the writing mode entry point.

wm_tbl:		dc.w	wm0y_nxt-*
		dc.w	    wm0y-*	; replace		dY > dX
		dc.w	wm1y_nxt-*
		dc.w	    wm1y-*	; transparent		dY > dX
		dc.w	wm2y_nxt-*
		dc.w	    wm2y-*	; XOR			dY > dX
		dc.w	wm1y_nxt-*
		dc.w	    wm3y-*	; reverse transparent	dY > dX
		dc.w	wm0x_nxt-*
		dc.w	    wm0x-*	; replace		dX > dY
		dc.w	wm1x_nxt-*
		dc.w	    wm1x-*	; transparent		dX > dY
		dc.w	wm2x_nxt-*
		dc.w	    wm2x-*	; XOR			dX > dY
		dc.w	wm1x_nxt-*
		dc.w	    wm3x-*	; reverse transparent	dX > dY




*+
*   Build a fragment of code in ram that plots a pixel of the color specified
*   by the _FG_B_PLANES. The parameters passed into the fragment at run-time
*   will be:
*
*	a3	thread from fragment back to master routine
*	a5	pointer to word in plane 0 containing the pixel
*	d0	mask for clearing a bit via an AND operation
*	d1	mask for setting a bit via an OR operation
*
* in:	a2	points to area where pixel fragment can be constructed
*	d3	number of planes
*
* out:	a2	points to start of pixel fragment code
*
* munged: a0/d0-d3
*-
pixfrag:

.ifeq	P68030
		movec.l	cacr,d2			; d2 <- cache control register
		bset.l	#3,d2			; set "Clr Instr Cache" bit
		movec.l	d2,cacr			; clear the instruction cache
.endc
		subq.w	#1,d3			; d3 <- dbra plane counter

		movem.w	i_tbl(pc),d0-d1/a1	; cache instr data in registers
		move.l	a2,a0			; a0 <- working PC
		move.l	_FG_B_PLANES(a4),d2	; a1 -> bitplane color array

pf_loop:	roxr.l	#1,d2			; get color for this plane
		bcs	pf_or			; 0 => AND   1 => OR

pf_and:		move.w	d0,(a0)+		; load: and.w d0,(a5)+ SET BIT
		dbra	d3,pf_loop

		move.w	a1,(a0)+		; load: jmp (a3) RETURN THREAD
		rts

pf_or:		move.w	d1,(a0)+		; load: or.w d1,(a5)+ CLEAR BIT
		dbra	d3,pf_loop

		move.w	a1,(a0)+		; load: jmp (a3) RETURN THREAD

		rts

*	     Table of Instructions.

i_tbl:		and.w	d0,(a5)+
		or.w	d1,(a5)+
		jmp	(a3)



*		a5 = scratch
*		a4 = thread into clear/xor pixel tower		(modes 0,2)
*		a3 = thread back from color pixel fragment	(modes 0,1,2)
*		a2 = thread into color pixel fragment 		(modes 0,1,2)
*		a1 = offset to next line in Y
*		a0 = ptr to destination 
*
*		d7 = dbra pixel counter
*		d6 = e2
*		d5 = e1
*		d4 = epsilon
*		d3 = offset to next word in plane
*		d2 = line style mask
*		d1 = set pixel mask
*		d0 = clr pixel mask				(modes 0,1,2)



*	     WRITING MODE 0:  REPLACE			   dY > dX

wm0y:
wm0y_top:	rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm0y_clr	; branch if pixel is clear	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a2)		; a2 -> ram based set pixel fragment  8


wm0y_clr:	move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a4)		; a4 -> entry into clear pixel tower  8


		and.w	d0,(a5)+	; 8 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 4 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 2 planes			     12
		and.w	d0,(a5)+	; 1 plane			     12

wm0y_nxt:	add.w	a1,a0		; a0 -> next vertical word	      8
		tst.w	d4		; epsilon < 0  =>  don't change X     4
		bmi	wm0y_nc		; branch if X doesn't change	   10/8

		ror.w	#1,d0		; rotate the clr pixel mask	      8
		ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm0y_nf		; branch if no word fault	   10/8
	
		add.w	d3,a0		; a0 -> next horizontal word	      8

wm0y_nf:	add.w	d6,d4		; d4 <- epsilon + e2		      4
		dbra	d7,wm0y_top	; do next pixel			  14/10
		rts


wm0y_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm0y_top	; do next pixel			  14/10
		rts




*	     WRITING MODE 1:  TRANSPARENT		  dY > dX
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dY > dX

wm3y:		not.w	d2

wm1y:
wm1y_top:	rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm1y_nxt	; branch if pixel is clear	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a2)		; a2 -> ram based set pixel fragment  8


wm1y_nxt:	add.w	a1,a0		; a0 -> next vertical word	      8
		tst.w	d4		; epsilon < 0  =>  don't change X     4
		bmi	wm1y_nc		; branch if X doesn't change	   10/8

		ror.w	#1,d0		; rotate the clr pixel mask	      8
		ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm1y_nf		; branch if no word fault	   10/8
	
		add.w	d3,a0		; a0 -> next horizontal word	      8

wm1y_nf:	add.w	d6,d4		; d4 <- epsilon + e2		      4
		dbra	d7,wm1y_top	; do next pixel			  14/10
		rts


wm1y_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm1y_top	; do next pixel			  14/10
		rts



*	     WRITING MODE 2:  XOR			  dY > dX

wm2y:
wm2y_top:	rol.w	#1,d2		; cy: next style bit		      8


		bcc	wm2y_nxt	; branch if pixel is clear	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a4)		; a4 -> entry into xor pixel tower    8


		eor.w	d1,(a5)+	; 8 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 4 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 2 planes			     12
		eor.w	d1,(a5)+	; 1 plane			     12

wm2y_nxt:	add.w	a1,a0		; a0 -> next vertical word	      8
		tst.w	d4		; epsilon < 0  =>  don't change X     4
		bmi	wm2y_nc		; branch if X doesn't change	   10/8

		ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm2y_nf		; branch if no word fault	   10/8
	
		add.w	d3,a0		; a0 -> next horizontal word	      8

wm2y_nf:	add.w	d6,d4		; d4 <- epsilon + e2		      4
		dbra	d7,wm2y_top	; do next pixel			  14/10
		rts


wm2y_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm2y_top	; do next pixel			  14/10
		rts




*	     WRITING MODE 0:  REPLACE			   dX > dY

wm0x:
wm0x_top:	rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm0x_clr	; branch if style bit is 0	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a2)		; a2 -> ram based set pixel fragment  8


wm0x_clr:	move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a4)		; a4 -> entry into clear pixel tower  8


		and.w	d0,(a5)+	; 8 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 4 planes			     12
		and.w	d0,(a5)+	;				     12
		and.w	d0,(a5)+	; 2 planes			     12
		and.w	d0,(a5)+	; 1 plane			     12

wm0x_nxt:	ror.w	#1,d0		; rotate the clear pixel mask	      8
		ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm0x_nf		; check for word fault		   10/8

		add.w	d3,a0		; a0 -> next horizontal word	      8

wm0x_nf:	tst.w	d4		; epsilon < 0  =>  don't change Y     4
		bmi	wm0x_nc		; branch if Y doesn't change	   10/8

		add.w	d6,d4		; d4 <- epsilon + e2		      4
		add.w	a1,a0		; a0 -> next vertical word	      8
		dbra	d7,wm0x_top	; do next pixel			  14/10
		rts


wm0x_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm0x_top	; do next pixel			  14/10
		rts




*	     WRITING MODE 1:  TRANSPARENT		  dX > dY
*	     WRITING MODE 3:  REVERSE TRANSPARENT	  dX > dY

wm3x:		not.w	d2		; invert the style mask

wm1x:
wm1x_top:	rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm1x_nxt	; skip if style bit is 0	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a2)		; a2 -> ram based set pixel fragment  8


wm1x_nxt:	ror.w	#1,d0		; rotate the clr pixel mask	      8
		ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm1x_nf		; check for word fault		   10/8

		add.w	d3,a0		; a0 -> next horizontal word	      8

wm1x_nf:	tst.w	d4		; epsilon < 0  =>  don't change Y     4
		bmi	wm1x_nc		; branch if Y doesn't change	   10/8

		add.w	d6,d4		; d4 <- epsilon + e2		      4
		add.w	a1,a0		; a0 -> next vertical word	      8
		dbra	d7,wm1x_top	; do next pixel			  14/10
		rts


wm1x_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm1x_top	; do next pixel			  14/10
		rts




*	     WRITING MODE 2:  XOR			  dX > dY

wm2x:
wm2x_top:	rol.w	#1,d2		; cy: next style bit		      8
		bcc	wm2x_nxt	; skip if style bit is 0	   10/8

		move.l	a0,a5		; a5 -> 1st dst word containing pixel 4
		jmp	(a4)		; a4 -> entry into xor pixel tower    8


		eor.w	d1,(a5)+	; 8 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 4 planes			     12
		eor.w	d1,(a5)+	;				     12
		eor.w	d1,(a5)+	; 2 planes			     12
		eor.w	d1,(a5)+	; 1 plane			     12

wm2x_nxt:	ror.w	#1,d1		; rotate the set pixel mask	      8
		bcc	wm2x_nf		; check for word fault		   10/8

		add.w	d3,a0		; a0 -> next horizontal word	      8

wm2x_nf:	tst.w	d4		; epsilon < 0  =>  don't change Y     4
		bmi	wm2x_nc		; branch if Y doesn't change	   10/8

		add.w	d6,d4		; d4 <- epsilon + e2		      4
		add.w	a1,a0		; a0 -> next vertical word	      8
		dbra	d7,wm2x_top	; do next pixel			  14/10
		rts


wm2x_nc:	add.w	d5,d4		; d4 <- epsilon + e1		      4
		dbra	d7,wm2x_top	; do next pixel			  14/10
		rts



*******************************************************************************
*******************************************************************************
**									     **
**	HABLINE								     **
**									     **
**	This routine draws a line between (X1,Y1) and (X2,Y1) using the	     **
**	BLASTER hardware bit blt.					     **
**	The line has attributes of color, pattern, and writing mode	     **
**									     **
**	Note that 2 entry points are provided for ABLINE		     **
**									     **
**	input:		X1 = minimum X of line	     (assumed to be clipped) **
**			X2 = maximum X of line	     (assumed to be clipped) **
**			Y1 = row that line is on     (assumed to be clipped) **
**		    PATMSK = index mask for pattern			     **
**		    PATPTR = pointer to start of pattern		     **
**		 _v_planes = number of video planes			     **
**		 _WRT_MODE = writing mode				     **
**									     **
**			      0 => replace mode.			     **
**			      1 => transparent mode.			     **
**			      2 => xor mode.				     **
**			      3 => reverse transparent mode.		     **
**									     **
**		 V_HLINE = pointer to horizontal line primitive		     **
**									     **
**	output:	  nothing is returned					     **
**									     **
**	destroys: everything						     **
**									     **
*******************************************************************************
*******************************************************************************

lf_tab:	dc.w	$FFFF			; left fringe list	0:OLD 1:NEW
rf_tab:	dc.w	$7FFF,$3FFF,$1FFF,$0FFF	; right fringe list	0:NEW 1:OLD
	dc.w	$07FF,$03FF,$01FF,$00FF
	dc.w	$007F,$003F,$001F,$000F
	dc.w	$0007,$0003,$0001,$0000


_HABLINE:
	move.l	_lineAVar,a4		; a4 -> base of LineA variables
	move.l	V_ROUTINES(a4),a0	; load vectrd list of primitives
	move.l	V_HABLINE(a0),a0	; vec to vert line primitive
	jmp	(a0)			; sft: "aline"  hrd: "hb_vline"

ST_HABLINE:

	move.l	_lineAVar,a4		; a4 -> LineA variable base
	movem.w	_X1(a4),d4-d6		; d4 <- X1   d5 <- Y1   d6 <- X2

fline:	move.w	d5,d0			; d0 <- Y1
	and.w	_patmsk(a4),d0		; d0 <- initial pattern index
	add.w	d0,d0			; d0 <- initial pattern offset
	move.l	_patptr(a4),a0		; a0 -> start of pattern
	add.w	d0,a0			; a0 -> pattern word

	tst.w	_multifill(a4)		; d0 <- offset to next pattern plane
	sne	d0			; d0 <- 00: single plane pattern
	and.w	#32,d0			; d0 <- 32: multiple plane pattern

xline:	move.w	d4,d1			; d1 <- X1
	asr.w	#4,d1			; d1 <- word containing X1
	move.w	d6,d2			; d2 <- X2
	asr.w	#4,d2			; d2 <- word containing X2

	moveq.l	#$0F,d3			; d3 <- mod 16 mask

	and.w	d3,d4			; d4 <- X1 mod 16
	add.w	d4,d4			; d4 <- offset into fringe table
	move.w	lf_tab(pc,d4.w),d4	; d4 <- left fringe mask  (0:Dst 1:Src)

	and.w	d3,d6			; d6 <- X2 mod 16
	add.w	d6,d6			; d6 <- offset into right fringe table
	move.w	rf_tab(pc,d6.w),d6	; d6 <- inverted right fringe mask
	not.w	d6			; d6 <- right fringe mask (0:Dst 1:Src)

	sub.w	d1,d2			; d2 <- span-1 of line in words
	bne	hline_select		; 1 word span =>  merge lf & rt masks

	and.w	d6,d4			; d4 <- single fringe mask

hline_select:

	move.l	V_ROUTINES(a4),a5	; load vectored list of primitives
	move.l	V_HLINE(a5),a5		; vec to h line primitive
	jmp	(a5)			; sft: "aline"  hrd: "hb_vline"

	.end
