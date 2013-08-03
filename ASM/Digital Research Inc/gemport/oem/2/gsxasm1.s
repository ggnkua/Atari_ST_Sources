*************************************************************************
*									*
*				GSXASM1.S				*
*									*
*************************************************************************
	.text

	.globl	_CLC_FLIT	* calculate fill intersections of vector list
	.globl	_SMUL_DIV	* signed integer multiply and divide
	.globl	_vec_len	* compute length of a vector
	.globl	_HABLINE	* draw a horizontal line
	.globl	_ABLINE		* draw a line (general purpose)
	.globl	concat		* convert x,y coordinates to buffer offsets
	.globl	xline		* alternate entry to HABLINE
	.globl	ortbl		* OR mask table for line drawing
	.globl	lf_tab          * left fringe look-up table
	.globl	htab		* jump table for drawing horizontal lines

	.page
*************************************************************************
*									*
*			Externally Defined Labels			*
*									*
*************************************************************************

	.xdef	_CONTRL
	.xdef	_INTOUT
	.xdef	_PTSIN
	.xdef	_CLIP
	.xdef	_XMN_CLI
	.xdef	_XMX_CLI
	.xdef	_fill_bu
	.xdef	_fil_int
	.xdef	_multifill
	.xdef	_TERM_CH
*
	.xdef	_FG_BP_1
	.xdef	_FG_BP_2
	.xdef	_FG_BP_3
	.xdef	_FG_BP_4
*
	.xdef	_X1
	.xdef	_X2
	.xdef	_Y1
	.xdef	_Y2
	.xdef	_LSTLIN
	.xdef	_LN_MASK
	.xdef	_WRT_MODE
	.xdef	_patmsk
	.xdef	_patptr
*
	.xdef	_v_bas_ad
	.xdef	_v_planes
	.xdef	_v_lin_wr

	.page
*************************************************************************
*									*
*			Local Constants					*
*									*
*************************************************************************

vme10	=	0		* flag for cond'l assembly of VME/10 code
test	=	0		* flag for cond'l assembly of test changes
rev_vid =	1		* for selecting reverse video line styles

x1	.equ	0		* offsets used by CLC_FLIT for accessing
y1	.equ	2		* parameters passed on the stack
x2	.equ	4
y2	.equ	6

ifeq	vme10
v_pl_dspl	.equ	$10000	* size of vme/10 video plane
endc

	.page
*************************************************************************
*									*
*	_vec_len							*
*									*
*	This routine computes the length of a vector using the		*
*	formula sqrt(dx*dx + dy*dy).					*
*									*
*	input:								*
*	   4(sp) = dx.							*
*	   6(sp) = dy.							*
*									*
*	output:								*
*	   d0 = sqrt(dx*dx + dy*dy).					*
*									*
*	destroys:	d0, d1, d2, d3, d4				*
*									*
*************************************************************************

*
*	Compute the sum of the squares of the x and y-deltas of the
*	vector.  If the sum is 0 then the vector has a length of 0.
*
_vec_len:
	move.w	4(sp),d0	* compute the square of x-delta
	muls	d0,d0
	move.w	6(sp),d1	* compute the square of y-delta
	muls	d1,d1
	add.l	d0,d1		* compute the sum of the squares
	beq	vl_out		* if sum is 0 then length is 0 - done

*
*	Compute an initial upper and lower bound on the square root.
*	The lower bound is the smallest number that is no more than half
*	the length of the square and the upper bound is twice the lower bound.
*
*	The first step in computing the lower bound is to determine the
*	position of the most significant bit of the sum of the squares.  If
*	the sum is 64k or larger then the bit position is set to start at 16
*	and the upper word of the sum is then checked.  Otherwise, the bit
*	position is set to start at 0 and the lower word of the sum is then
*	checked.
*
	move.l	d1,d0		* save square for later comparisons
	clr.w	d2		* starting square length defaults to 0
	cmpi.l	#$10000,d1	* does high order word contain 1's?
	bcs	bds_lp		* nope - don't need upper word
	swap	d1		* yes - look for most sig. bit in high word
	moveq	#16,d2		* set starting square length to 16

*
*	Loop checking the selected word.  If its current value is greater
*	than 1 then increment the bit position of the most significant bit.
*
bds_lp:
	cmpi.w	#1,d1		; done generating initial lower bound?
	bls	bds_end		; yes, branch.
	addq.w	#1,d2		; no, increment square length.
	lsr.w	#1,d1		; shift the square right.
	bra	bds_lp

*
*	Set the lower bound of the square root to the nth power of 2, where
*	n is equal to half the bit length of the sum of the squares.  Set
*	the upper bound to twice the lower bound.
*
bds_end:
	asr.w	#1,d2		; square_length/2.
	moveq	#1,d3
	asl.w	d2,d3		; initial lower bound.
	move.w	d3,d2
	asl.w	#1,d2		; initial upper bound.
	bne	srch_lp		; check for overflow.
	subq.w	#1,d2		; if overflow, upper bound := $FFFF.

*
*	Now, perform a binary search for the square root.  This is done by
*	first computing the difference between the upper and lower bounds.
*	If the difference is 1 then the result is the lower bound.  Other-
*	wise, the difference is halved and added to the lower bound.  This
*	temporary value is squared and compared with the sum of the squares.
*	If they are equal then the temporary value is the result.  If the
*	temporary square is less then the lower bound is set to the temporary
*	value.  If the temporary square is greater then the upper bound is
*	set to the temporary value.
*
srch_lp:
	move.w	d2,d1
	sub.w	d3,d1		; upper - lower.
	cmpi.w	#1,d1		; search done?
	beq	srch_end	; yes, branch.
	asr.w	#1,d1		; (upper-lower)/2.
	add.w	d3,d1		; candidate = lower + (upper-lower)/2.
	move.w	d1,d4		; save candidate for adjustment.
	mulu	d1,d1		; candidate*candidate.
	cmp.l	d0,d1		; compare with target square.
	bhi	hi_adjust	; if candidate too large, branch.
	bcs	lo_adjust	; if candidate too small, branch.
	move.w	d4,d0		; if candidate exact square root, done.
	rts

*
*	The square of the temporary value is greater than the sum of the
*	squares so set the upper bound of the square root to the temporary
*	value.
*
hi_adjust:
	move.w	d4,d2		; move upper bound down to last candidate.
	bra	srch_lp

*
*	The square of the temporary value is less than the sum of the squares
*	so set the lower bound of the square root to the temporary value.
*
lo_adjust:
	move.w	d4,d3		; move lower bound up to last candidate.
	bra	srch_lp

*
*	The lower bound of the square root is 1 less than the upper bound so
*	there can be no exact square root.  We therefore use the lower bound.
*
srch_end:
	move.w	d3,d0		; use the lower bound.
vl_out:
	rts

	.page
*************************************************************************
*									*
*	_CLC_FLIT							*
*									*
*	This routine calculates the fill intersections for a list	*
*	of vectors.  The x-intersection of each vector with the		*
*	scan-line of interest is calculated and inserted into a		*
*	buffer which is then sorted in ascending order.  The re-	*
*	sulting array of x-values are then pulled out pair-wise		*
*	and used as inputs to "_HABLINE".				*
*									*
*	This version of the routine has several changes from the	*
*	original version contained in the screen driver.  The code	*
*	has been optimized in several places for improvements in	*
*	both size and execution time.  It also has been changed to	*
*	prevent the drawing of the outline of a figure with the		*
*	fill pattern.  These changes are all included as condition-	*
*	ally assembled code.						*
*									*
*	input:								*
*	    CONTRL[1] = number of vectors.				*
*	    PTSIN[]   = array of vertices.				*
*	    Y1        = scan-line to calculate intersections for.	*
*	    fil_int   = 0.						*
*									*
*	output:								*
*	    fil_int  = number of intersections.				*
*	    fill_buf  = array of x-values.				*
*									*
*	destroys:	everything.					*
*									*
*************************************************************************

*
*	Initialize the pointers and counters.
*
_CLC_FLIT:
	move.l	_CONTRL,a0	; fetch number of vectors.
	move.w	#2(a0),d0
	subq.w	#1,d0		; minus 1 for dbra
	move.l	_PTSIN,a0	; point to array of vertices.
	lea	_fill_bu,a1	; point to array of x-values.

*
*	Determine if the current vector is horizontal.  If it is then
*	ignore it.
*
*	This may not be safe.  It could in some instances cause part of the
*	border to be drawn with the interior style.  This will cause prob-
*	lems in the exclusive or mode with border visibility on	and in all
*	modes with border visibility off.
*
flit_lp:
	move.w	y2(a0),d1	; fetch y-value of 2nd endpoint.
	move.w	y1(a0),d2	; fetch y-value of 1st endpoint.
	sub.w	d2,d1		; dy.
	beq	no_fill_int	; dy = 0 => ignore this vector.

*
*	Determine whether the current vector intersects with the scan
*	line we wish to draw.  This test is performed by computing the
*	y-deltas of the two endpoints from the scan line.  If they both
*	have the same sign then the line does not intersect and can be
*	ignored.  The origin for this test is found in Newman and Sproull.
*
*	This test may not be entirely safe either for the same reasons as
*	above.
*
	move.w	_Y1,d3		; fetch scan-line y.
	move.w	d3,d4
	sub.w	d2,d4		; delta y1.
	sub.w	y2(a0),d3	; delta y2.
	move.w	d4,d2
	eor.w	d3,d2		; are the signs equal?
	bpl	no_fill_int	; yes, ignore this vector.

*
*	Compute the x-coordinate of the point of intersection of the vector
*	with the current scan line.  The law of similar triangles is used.
*
	move.w	x2(a0),d2	; fetch x2.
	sub.w	x1(a0),d2	; dx.
	bmi.b	rtol		* negative delta - use x2 and delta y2
	move.w	x1(a0),d3	* get x1
	bra.b	getdx
rtol:
	move.w	d3,d4		* replace delta y1 with delta y2
	move.w	x2(a0),d3	* get x2
	neg.w	d1		* negate dy
	neg.w	d2		* negate dx
getdx:
	asl.w	#1,d2		; 2*dx. (for more precision)
	muls	d2,d4		; (2*dx) * delta y1.
	divs	d1,d4		; (2*dx) * delta y1 / dy.
	bmi	int_neg
	addq.w	#1,d4		; rounding.
	bra	round_x
int_neg:
	subq.w	#1,d4		* rounding
round_x:
	asr.w	#1,d4
ld_fill_int:
	add.w	d3,d4		; add in x1.
	move.w	d4,(a1)+	; put in fill_buf.
	addq.w	#1,_fil_int	; increment # of intersections.
no_fill_int:
	addq.w	#4,a0   	; next pair of endpoints. (next vector)
	dbra	d0,flit_lp

*
*	All of the points of intersection have now been found.  If there were
*	none then there is nothing more to do.  Otherwise, sort the list of
*	points of intersection in ascending order.  (The list contains only
*	the x-coordinates of the points.)
*
sort_fill_int:
	move.w	_fil_int,d0	; how many intersections?
	bne	sfi_cont	; 2 or more => sort them.
	rts			; 0 => nothing else to do.
sfi_cont:
	lea	_fill_bu,a0
	bsr	bub_sort	; bubble-sort the fill buffer.

*
*	The points are now sorted.  If a clipping rectangle is in use then
*	branch to special code.
*
	move.w	_fil_int,d0	* get number of buffered points
	asr.w	#1,d0		* convert to number of pairs of points
	subq.w	#1,d0		* adjust count for loop
	tst.w	_CLIP		* is clipping on?
	bne	dr_clip		* yes, branch.

*
*	Clipping is not in force.  Draw from point to point.
*
*	This code has been modified from the version in the screen driver.
*	The x-coordinates of each line segment are adjusted so that the
*	border of the figure will not be drawn with the fill pattern.  If
*	the starting point is greater than the ending point then nothing is
*	done.
*
draw_lp:
	move.w	(a1)+,d1	* grab a pair of endpoints
	move.w	(a1)+,d2
	addq.w	#1,d1		* adjust the endpoints
	subq.w	#1,d2
	cmp.w	d1,d2		* is start still to left of end?
	blt	dr_lp1		* nope - nothing to draw
	move.w	d1,_X1		* store the adjusted endpoints
	move.w	d2,_X2
	move.w	d0,-(sp)	* save the number of pairs
	move.l	a1,-(sp)	* save the pointer to the array
	bsr	_HABLINE	* draw the line segment
	move.l	(sp)+,a1	* restore the pointer to the array
	move.w	(sp)+,d0	* restore the number of pairs
dr_lp1:
	dbra	d0,draw_lp	* loop until done
	rts

*
*	Clipping is in force.  Once the endpoints of the line segment have
*	been adjusted for the border, clip them to the left and right sides
*	of the clipping rectangle.
*
*	This code has been modified from the version in the screen driver.
*	The x-coordinates of each line segment are adjusted so that the
*	border of the figure will not be drawn with the fill pattern.  If
*	the starting point is greater than the ending point then nothing is
*	done.
*

dr_clip:
	move.w	_XMN_CLI,d1	* get clip minimum
	move.w	_XMX_CLI,d2	* get clip maximum
drc_0:
	move.w	(a1)+,d3	* grab a pair of intersections
	move.w	(a1)+,d4
	addq.w	#1,d3		* adjust the endpoints
	subq.w	#1,d4
	cmp.w	d4,d3		* is start still to left of end?
	bgt	drc_end		* nope - nothing to draw
	cmp.w	d1,d3		* is x1 < xmn_clip?
	bge	drc_1		* nope - check for clip on right
	cmp.w	d1,d4		* entire segment to left of clip rect?
	blt	drc_end		* yes - nothing to draw
	move.w	d1,d3		* nope - clip left end of line
drc_1:
	cmp.w	d2,d4		* is x2 > xmx_clip?
	ble	drc_2		* nope - ready to draw now
	cmp.w	d2,d3		* entire segment to right of clip rect?
	bgt	drc_end		* yes - nothing to draw
	move.w	d2,d4		* nope - clip right end of line
drc_2:
	move.w	d3,_X1		* save the endpoints
	move.w	d4,_X2
	move.w	d0,-(sp)	* save the number of pairs
	move.w	d1,-(sp)	* save the clip values
	move.w	d2,-(sp)
	move.l	a1,-(sp)	* save pointer to the array
	bsr	_HABLINE	* fill the line segment
	move.l	(sp)+,a1	* restore the pointer to the array
	move.w	(sp)+,d2	* restore the clip values
	move.w	(sp)+,d1
	move.w	(sp)+,d0	* restore the number of pairs
drc_end:
	dbra	d0,drc_0	* loop until done
	rts

	.page
*************************************************************************
*									*
*	bub_sort							*
*									*
*	This routine bubble-sorts an array of words into ascending	*
*	order.								*
*									*
*	input:								*
*	   a0 = ptr to start of array.					*
*	   d0 = number of words in array.				*
*									*
*	output:								*
*	   a1 = ptr to start of sorted array.				*
*									*
*	destroys:	d0, d1, d2, a0, a1				*
*									*
*************************************************************************

*
*	If the array is empty or if there is only one entry to sort then
*	return.  Otherwise, initialize the necessary pointers and counters.
*
bub_sort:
	subq.w	#2,d0		* compute number of compares - 1
	blt.b	bs_out		* array empty or only one entry - done
	move.w	d0,d1		* save the number of compares
	move.l	a0,a1		* save pointer to the array

*
*	Initialize the counter and pointer necessary for this pass through
*	the sort.
*
bsl0_init:
	move.w	d1,d0		* get the number of compares to perform
	move.l	a1,a0		* get the pointer to the array

*
*	Make a single pass through the array comparing pairs of values. If
*	the nth value is greater than the n+1th value then swap them.  Each
*	time this loop is completed the next largest value will be moved to
*	its appropriate place at the end of the array.
*
bs_lp0:
	move.w	(a0)+,d2	* get next value
	cmp.w	(a0),d2		* is it <= the next one?
	ble	bs_noswap	* yes - do nothing
	move.w	(a0),-2(a0)	* nope - swap them
	move.w	d2,(a0)
bs_noswap:
	dbra	d0,bs_lp0	* loop until an entire pass is complete

*
*	The next largest value has been sorted to its place int the array.
*	loop until all the values are sorted.
*
bsl1_end:
	dbra	d1,bsl0_init	* one less value to sort next time
bs_out:
	rts

	.page
*************************************************************************
*									*
*	smul_div (m1,m2,d1)						*
*									*
*	( ( m1 * m2 ) / d1 ) + 1/2					*
*									*
*	m1 = signed 16 bit integer					*
*	m2 = unsigned 15 bit integer					*
*	d1 = signed 16 bit integer					*
*									*
*************************************************************************

_SMUL_DIV:
	moveq	#1,d1		* preload increment
	move	6(sp),d0
	muls	4(sp),d0	* m2 * m1
	bpl	smd_1
	neg	d1		* negate increment
smd_1:
	move	8(sp),d2
	divs	d2,d0		* m2 * m1 / d1
	and	d2,d2		* test if divisor is negative
	bpl	smd_2
	neg	d1		* negate increment
	neg	d2		* make divisor positive
smd_2:
	move.l	d3,-(sp)
	move.l	d0,d3		* extract remainder
	swap	d3
	and	d3,d3		* test if remainder is negative
	bpl	smd_3
	neg	d3		* make remainder positive
smd_3:
	asl	#1,d3		* see if 2*remainder is > divisor
	cmp	d2,d3
	blt	smd_4
	add	d1,d0		* add increment
smd_4:
	move.l	(sp)+,d3
	rts

	.page
*************************************************************************
*									*
*	concat								*
*									*
*	This routine converts x and y coordinates into a physical	*
*	offset to a word in the screen buffer and an index to the	*
*	desired bit within that word.					*
*									*
*	input:								*
*	   d0.w = x coordinate.						*
*	   d1.w = y coordinate.						*
*									*
*	output: 							*
*	   d0.w = word index. (x mod 16)				*
*	   d1.w = physical offset -- (y*bytes_per_line)			*
*					+ (x & xmask)>>xshift		*
*									*
*	destroys:	nothing						*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and convert the y-coordinate
*	into an offset to the start of the desired scan row.
*
concat:
	movem.w	d2/d3,-(sp)	* save the registers that get clobbered
	mulu	_v_lin_wr,d1	* compute offset to scan row

*
*	Compute the bit offset into the desired word, save it, and remove
*	these bits from the x-coordinate.
*
	move.w	d0,d2		* save the x-coordinate for later
	andi.w	#$000F,d0	* bit offset = x-coordinate mod 16
	andi.w	#$FFF0,d2	* clear bits for offset into word

*
*	Convert the adjusted x-coordinate to a word offset into the current
*	scan line.  If the planes are arranged in an interleaved fashion with
*	a word for each plane then shift the x-coordinate by a value contained
*	in the shift table.  If the planes are arranged as separate, consecu-
*	tive entities then divide the x-coordinate by 8 to get the number of
*	bytes.
*
ifne	vme10
	move.w	_v_planes,d3	* get number of planes
	move.b	shf_tab-1(pc,d3.w),d3	* get shift factor
	lsr.w	d3,d2		* convert x-coordinate to offset
endc
ifeq	vme10
	lsr.w	#3,d2		* convert x-coordinate to offset
endc

*
*	Compute the offset to the desired word by adding the offset to the
*	start of the scan line to the offset within the scan line, restore
*	the clobbered registers, and exit.
*
	add.w	d2,d1		* compute total offset into screen buffer
	movem.w	(sp)+,d2/d3	* restore the clobbered registers
	rts

ifne	vme10
*************************************************************************
*									*
*	Shift Table for Computing Offsets into a Scan Line When		*
*	the Video Planes Are Interleaved				*
*									*
*************************************************************************
shf_tab:
	dc.b	3			; 1 plane
	dc.b	2			; 2 planes
	dc.b	0			; not used
	dc.b	1			; 4 planes
endc

	.page
*************************************************************************
*									*
*	ABLINE								*
*									*
*	This routine draws a line between (_X1,_Y1) and (_X2,_Y2)	*
*	using Bresenham's algorithm.  The line is modified by the	*
*	_LN_MASK and _WRT_MODE variables.  This routine handles all	*
*	3 video resolutions.						*
*									*
*	Note that for line-drawing in GSX, the background color is	*
*	always 0 (i.e., there is no user-settable background color).	*
*	This fact allows coding short-cuts in the implementation of	*
*	"replace" and "not" modes, resulting in faster execution of	*
*	their inner loops.						*
*									*
*	input:								*
*	   _X1, _Y1, _X2, _Y2 = coordinates.				*
*	   num_planes	      = number of video planes. (resolution)	*
*	   _LN_MASK	      = line mask. (for dashed/dotted lines)	*
*	   _WRT_MODE	      = writing mode.				*
*				   0 => replace mode.			*
*				   1 => or mode.			*
*				   2 => xor mode.			*
*				   3 => not mode.			*
*									*
*	output:								*
*	   _LN_MASK rotated to proper alignment with (_X2,_Y2).		*
*									*
*	destroys:	everything					*
*									*
*************************************************************************

*
*	Initialize the necessary pointers and counters and determine
*	whether the line should be drawn using x1,y1 or x2,y2 as the
*	starting point.
*
_ABLINE:
	move.l	_v_bas_ad,a5	* get base address of first plane
	lea	_FG_BP_1,a4	* get address of bit plane mask table
ifeq	vme10
	move.w	_v_planes,d3	* get number of planes - 1
	subq.w	#1,d3
	moveq.l	#2,d6		* get offset to next word in a plane
	movea.l	#v_pl_dspl,a1	* get offset to next video plane
endc
ifne	vme10
	move.w	_v_planes,d3	* get number of video planes
	move.w	d3,d6		* save it
	subq.w	#1,d3		* get number of planes - 1
	asl.w	#1,d6		* get offset to next word in plane
endc
	move.w	_v_lin_wr,d7	* get offset to next scan in plane
	move.w	_X2,d5		* compute delta x
	sub.w	_X1,d5
	bmi	swap		* if delta x < 0 then draw from point 2 to 1

*
*	The point at x1,y1 is to the left of the point at x2,y2 so we will
*	draw the line using x1,y1 as the starting point.  Compute the address
*	of the word in the plane that contains the first point in the line.
*
	move.w	_X1,d0		* delta x is positive - start from x1,y1
	move.w	_Y1,d1
	bsr	concat		* compute offset of x1,y1 into plane
ifeq	vme10
	adda.l	d1,a5		* get address of word containing first point
endc
ifne	vme10
	adda.w	d1,a5		* get address of word containing first point
endc

*
*	Compute the delta y of the line.  If the line is horizontal then
*	draw the line using the routine HABLINE because we can draw the
*	line much faster that way.
*
	move.w	_Y2,d4		* compute delta y
	sub.w	_Y1,d4
	bne	nothor		* branch if the line is not horizontal

*
*	We need to draw a horizontal line.  If we are in the exclusive or
*	writing mode and this is not the last line in a polyline then
*	decrement the x-coordinate of the ending point in order to prevent
*	polylines from xor'ing themselves at the intersection points.
*
	cmpi.w	#2,_WRT_MODE	* in xor mode?
	bne	xln_ok		* nope - don't adjust the line
	tst.w	_LSTLIN		* last line in a polyline?
	bne	xln_ok		* nope - don't adjust the line
	tst.w	d5		* are the start and end points the same?
	beq	xln_ok		* yes - don't adjust the line
	subq.w	#1,_X2		* decrement the ending x-coordinate
xln_ok:
	bsr	xl_noswap	* call habline to draw the line fast
	move.w	_X2,d0		* recompute delta x
	sub.w	_X1,d0
	bra	xl_out

*
*	The point at x1,y1 was to the right of the point at x2,y2 resulting
*	in a negative delta x.  Since we only draw from left to right, use
*	x2,y2 as the starting point for the line.  Compute the address of
*	the word in the plane that contains the first point of the line.
*
swap:
	move.w	_X2,d0		* delta x is negative - start from x2,y2
	move.w	_Y2,d1
	bsr	concat		* compute offset of x2,y2 into plane
ifeq	vme10
	adda.l	d1,a5		* get address of word containing first point
endc
ifne	vme10
	adda.w	d1,a5		* get address of word containing first point
endc
	neg.w	d5		* get absolute value of delta x
	move.w	_Y1,d4		* compute delta y
	sub.w	_Y2,d4
	bne	nothor		* branch if the line is not horizontal

*
*	We need to draw a horizontal line.  If we are in the exclusive or
*	writing mode and this is not the last line in a polyline then
*	decrement the x-coordinate of the ending point in order to prevent
*	polylines from xor'ing themselves at the intersection points.
*
	cmpi.w	#2,_WRT_MODE	* in xor mode?
	bne	xls_ok		* nope - don't adjust the line
	tst.w	_LSTLIN		* last line in a polyline?
	bne	xls_ok		* nope - don't adjust the line
	tst.w	d5		* are the start and end points the same?
	beq	xls_ok		* yes - don't adjust the line
	addq.w	#1,_X2		* shorten the line from the starting end
	addq.w	#1,d0		* increment the index into the word
	andi.w	#$0F,d0		* overflow into the next word?
	bne	xls_ok		* nope
	adda.w	d6,a5		* yes - increment pointer to next word
xls_ok:
	bsr	xl_swap		* call habline to draw the line fast
	move.w	_X1,d0		* recompute delta x
	sub.w	_X2,d0
xl_out:
	addq.w	#1,d0		* adjust for true length of the line segment
	andi.w	#$000F,d0	* get length mod 16
	move.w	_LN_MASK,d1	* get the line style
	rol.w	d0,d1		* rotate it to align the next line segment
	move.w	d1,_LN_MASK	* save it for the next time through
	rts

*
*	We want to draw a line that is not horizontal.  Test delta y to
*	determine if the slope of the line is positive or negative.  If it
*	is negative then make delta y positive and the offset to the next
*	scan line negative.
nothor:
	bpl	abnorm		* branch if delta y is positive
	neg.w	d4		* it's negative - get its absolute value
	neg.w	d7		* negate the offset to the next scan line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to 1st word of line.
*	d6 = xinc.		a1 = offset to next plane (vme/10 only)
*	d5 = dx.
*	d4 = dy.
*	d3 = (# of planes) - 1.
*

*
*	Get the or mask for the current index into the word and compare
*	delta x with delta y to determine which is greater.
*
abnorm:
	asl.w	#1,d0		* convert the word index to a table index
	move.w	ortbl(pc,d0.w),d0	* get the or mask
	cmp.w	d4,d5		* which delta is larger?
	bmi	dygtdx		* delta y - branch to separate code

*
*	We want to draw a line where delta x is greater than delta y so we
*	will use the x-axis as the frame of reference.  Initialize the loop
*	counter for plotting individual pixels, calculate the decision
*	variables for Bresenham's Algorithm, and jump to the appropriate
*	line drawing routine for the current writing mode.
*
dxgedy:
	move.w	d5,d2		* loop count = # of pixels - 1
	asl.w	#1,d4		* e1 = 2dy
	move.w	d4,a3		* save e1
	sub.w	d5,d4		* epsilon = 2dy - dx
	move.w	d4,a2		* e2 = 2dy - 2dx
	suba.w	d5,a2
	move.w	_LN_MASK,d1	* get the line mask
	move.w	_WRT_MODE,d5	* get the writing mode
	asl.w	#2,d5		* convert it to a word offset
	move.l	dxge(pc,d5.w),a0	* get address of mode service routine
	move.w	d0,d5		* get the or table mask
	not.w	d5		* complement it
	jmp	(a0)		* go draw the line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to destination.
*	d6 = xinc.		a4 = ptr to _FG_BP_1.
*	d5 = not or table mask.	a3 = e1.
*	d4 = epsilon.		a2 = e2.
*	d3 = # of bit_planes - 1.
*	d2 = line loop counter - 1.
*	d1 = line mask.		a1 = offset to next plane (vme/10 only)
*	d0 = or table mask.
*

	.page
*************************************************************************
*									*
*	OR Mask Table							*
*									*
*************************************************************************

ortbl		dc.w	$8000
		dc.w	$4000
		dc.w	$2000
		dc.w	$1000
		dc.w	$0800
		dc.w	$0400
		dc.w	$0200
		dc.w	$0100
		dc.w	$0080
		dc.w	$0040
		dc.w	$0020
		dc.w	$0010
		dc.w	$0008
		dc.w	$0004
		dc.w	$0002
		dc.w	$0001

*************************************************************************
*									*
*	Write Mode Address Table					*
*									*
*************************************************************************

ifne rev_vid
dxge	dc.l	rep_dxge
	dc.l	or_dxge
	dc.l	xor_dxge
	dc.l	nor_dxge
endc
ifeq rev_vid
dxge	dc.l	rep_dxge
	dc.l	nor_dxge
	dc.l	xor_dxge
	dc.l	or_dxge
endc
	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Replace Mode When Delta X is	*
*	Greater than Delta Y						*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be written with the line style or 0's for the current
*	drawing color.
*
rep_dxge:
	movem.w d0-d2/d4/d5,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		* write this plane with pattern or 0's
ifne rev_vid
	bne	r_dx_ltop	* use pattern
endc
ifeq rev_vid
	bne	r_dx_rev	* use inverted pattern
endc
	clr.w	d1		* use 0's
*
*	If the current bit in the pattern is 0 then clear the current bit
*	in the plane.  If it is 1 then set the bit in the plane.
*
ifeq rev_vid
r_dx_rev:
	not.w	d1		* invert pattern for reverse video
endc
r_dx_ltop:
	rol.w	#1,d1		* put current bit of pattern in carry
	bcc	r_dx_clr	* branch if bit is zero
r_dx_set:
	or.w	d0,(a5)		* bit in pattern is 1 - set bit in plane
	bra	r_dx_xinc
r_dx_clr:
	and.w	d5,(a5)		* bit in pattern is 0 - clear bit in plane

*
*	Update the masks for clearing and setting bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
r_dx_xinc:
	ror.w	#1,d5		* rotate mask for clearing bits
	ror.w	#1,d0		* rotate mask for setting bits
	bcc	r_dx_yinc	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
r_dx_yinc:
	tst.w	d4		* epsilon < 0?
	bmi	r_dx_same1	* yes - don't increment y
	add.w	a2,d4		* nope - epsilon = epsilon + e2
	adda.w	d7,a5		* increment y
	dbra	d2,r_dx_ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
r_dx_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,rep_dxge	* loop until all planes are drawn
	bra	abl_out		* take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
r_dx_same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,r_dx_ltop	* loop until done with line segment
	bra	r_dx_bp		* done - check for more planes to draw

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Transparent Mode When Delta X	*
*	Is Greater than Delta Y						*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be set or cleared for the current foreground color.
*
or_dxge:
	movem.w d0-d2/d4/d5,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)
ifeq rev_vid
	not.w	d1		* complement the line style
endc
	tst.w	(a4)+		* set bits in this plane for the fgnd color?
ifne rev_vid
	beq	o_dx_0ltop	* nope - clear bits where mask = fgnd color
endc
ifeq rev_vid
	bne	o_dx_0ltop	* nope - clear bits where mask = fgnd color
endc
*
*	If the current bit in the mask is set then set the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dx_1ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	o_dx_1xinc	* it is 0 - do nothing
	or.w	d0,(a5)		* it is 1 - set the current bit in the line

*
*	Update the mask for setting bits.  If we have overflowed the current
*	word then update the pointer to the next word in the plane.
*
o_dx_1xinc:
	ror.w	#1,d0		* rotate mask for setting bits
	bcc	o_dx_1yinc	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_1yinc:
	tst.w	d4		* epsilon < 0?
	bmi	o_dx_1same1	* yes - don't increment y
	add.w	a2,d4		* nope - epsilon = epsilon +e2
	adda.w	d7,a5		* increment y
	dbra	d2,o_dx_1ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
o_dx_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,or_dxge	* loop until all planes are drawn
	bra	abl_out		* take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_1same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,o_dx_1ltop	* loop until done with line segment
	bra	o_dx_bp		* done - check for more planes to draw

*
*	If the current bit in the mask is set then clear the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dx_0ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	o_dx_0xinc	* it is 0 - do nothing
	and.w	d5,(a5)		* it is 1 - clear the current bit in the line

*
*	Update the mask for clearing bits.  If we have overflowed the current
*	word then update the pointer to the next word in the plane.
*
o_dx_0xinc:
	ror.w	#1,d5		* rotate mask for clearing bits
	bcs	o_dx_0yinc	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_0yinc:
	tst.w	d4		* epsilon < 0?
	bmi	o_dx_0same1	* yes - don't increment y
	add.w	a2,d4		* nope - epsilon = epsilon + e2
	adda.w	d7,a5		* increment y
	dbra	d2,o_dx_0ltop	* loop until done with line segment
	bra	o_dx_bp		* done - check for more planes to draw

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_0same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,o_dx_0ltop	* loop until done with line segment
	bra	o_dx_bp		* done - check for more planes to draw

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Exclusive Or Mode When Delta	*
*	X Is Greater than Delta Y					*
*									*
*************************************************************************

*
*	Save the registers that get clobbered.
*
xor_dxge:
	movem.w d0-d2/d4,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)

*
*	If the endpoint at x2,y2 should be drawn then don't adjust the line.
*	If the line is a singularity (point) then do nothing.  If we are
*	drawing from x1,y1 then decrement the number of times to go through
*	the pixel drawing loop. If we are drawing from x2,y2 then update
*	epsilon and decrement the loop count without actually drawing the
*	first time through the loop.
*
	tst.w	_LSTLIN		* should the final endpoint be omitted?
	beq	x_dx_ltop	* nope - don't adjust that endpoint
	and.w	d2,d2		* is line a single point?
	beq	x_dx_bp		* yes - don't even bother to draw it
	movea.w	_X2,a0		* compute delta x
	cmpa.w	_X1,a0
	blt	x_dx_xinc	* drawing from x2,y2 - don't draw first point
	subq.w	#1,d2		* drawing from x1,y1 - don't draw last point

*
*	If the current bit in the mask is set then exclusive or it with the
*	current bit in the line segment.  Otherwise, do nothing.
*
x_dx_ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	x_dx_xinc	* it is 0 - do nothing
	eor.w	d0,(a5)		* it is 1 - xor it with bit in line

*
*	Update the mask for exclusive or'ing bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
x_dx_xinc:
	ror.w	#1,d0		* rotate mask for xor'ing bits
	bcc	x_dx_yinc	* branch if no overflow to next word
	adda.w	d6,a5		* overflow occurred - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
x_dx_yinc:
	tst.w	d4		* epsilon < 0?
	bmi	x_dx_same1	* yes - don't increment y
	add.w	a2,d4		* nope - epsilon = epsilon + e2
	adda.w	d7,a5		* increment y
	dbra	d2,x_dx_ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
x_dx_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,xor_dxge	* loop until all planes are drawn

*
*	General Purpose Exit For ABLINE -- Take the actual number of pixels
*	in the line segment (less 1 if in the xor mode and we are not drawing
*	the last segment in a polyline) modulo 16 and rotate left the line
*	style by that amount.  Save the new line style for next time through.
*
abl_out:
	addq.w	#1,d2		* get number of pixels in the line
	andi.w	#$0F,d2		* get it mod 16
	rol.w	d2,d1		* rotate left the line style that many bits
	move.w	d1,_LN_MASK	* save the result for next time
	rts

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
x_dx_same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,x_dx_ltop	* loop until done with line segment
	bra	x_dx_bp		* done - check for more planes to draw

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Reverse Transparent Mode When	*
*	Delta X is Greater than Delta Y					*
*									*
*************************************************************************

*
*	Draw a line in the reverse transparent mode by complementing the
*	line style and calling the code for drawing a line in the transparent
*	mode.
*
nor_dxge:
	not.w	d1		* complement the line style
	bsr	or_dxge		* call the transparent mode code to draw line
	not.w	_LN_MASK	* restore the proper states of the style bits
	rts

	.page
*
*	We want to draw a line where delta y is greater than delta x so we
*	will use the y-axis as the frame of reference.  Initialize the loop
*	counter for plotting individual pixels, calculate the decision
*	variables for Bresenham's Algorithm, and jump to the appropriate
*	line drawing routine for the current writing mode.
*
dygtdx:
	exg	d4,d5		* swap delta x and delta y
	move.w	d5,d2		* loop count = # of pixels - 1
	asl.w	#1,d4		* e1 = 2dx
	move.w	d4,a3		* save e1
	sub.w	d5,d4		* epsilon = 2dx - dy
	move.w	d4,a2		* e2 = 2dx - 2dy
	suba.w	d5,a2
	move.w	_LN_MASK,d1	* get the line mask
	move.w	_WRT_MODE,d5	* get the writing mode
	asl.w	#2,d5		* convert it to a word offset
	move.l	dygt(pc,d5.w),a0	* get address of mode service routine
	move.w	d0,d5		* get the or table mask
	not.w	d5		* complement it
	jmp	(a0)		* go draw the line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to destination.
*	d6 = xinc.		a4 = ptr to _FG_BP_1.
*	d5 = not or table mask.	a3 = e1.
*	d4 = epsilon.		a2 = e2.
*	d3 = # of bit_planes - 1.
*	d2 = line loop counter - 1.
*	d1 = line mask.		a1 = offset to next plane (vme/10 only)
*	d0 = or table mask.
*

*************************************************************************
*									*
*	Write Mode Address Table					*
*									*
*************************************************************************
ifne rev_vid
dygt	dc.l	rep_dygt
	dc.l	or_dygt
	dc.l	xor_dygt
	dc.l	nor_dygt
endc
ifeq rev_vid
dygt	dc.l	rep_dygt
	dc.l	nor_dygt
	dc.l	xor_dygt
	dc.l	or_dygt
endc
	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Replace Mode When Delta Y is	*
*	Greater than Delta X						*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and text whether the current
*	plane should be written with the line style or 0's for the current
*	drawing color.
*
rep_dygt:
	movem.w d0-d2/d4/d5,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		* write this plane with pattern or 0's?
ifne rev_vid
	bne	r_dy_ltop	* use pattern
endc
ifeq rev_vid
	bne	r_dy_rev	* use inverted pattern
endc
	clr.w	d1		* use 0's
*
*	If the current bit in the pattern is 0 then clear the current bit
*	in the plane.  If it is 1 then set the bit in the plane.
*
ifeq rev_vid
r_dy_rev:
	not.w	d1		* invert pattern for reverse video
endc	
r_dy_ltop:
	rol.w	#1,d1		* put current bit of pattern in carry
	bcc	r_dy_clr	* branch if bit is 0
r_dy_set:
	or.w	d0,(a5)		* bit in pattern is 1 - set bit in plane
	bra	r_dy_yinc
r_dy_clr:
	and.w	d5,(a5)		* bit in pattern is 0 - clear bit in plane

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
r_dy_yinc:
	adda.w	d7,a5		* increment y
	tst.w	d4		* epsilon < 0?
	bmi	r_dy_same1	* yes - don't increment x
	add.w	a2,d4		* nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the masks for clearing and setting bits.
*	If we have overflowed the current word then update the pointer to the
*	next word in the plane.  Loop until all the bits in the line segment
*	have been drawn.
*
	ror.w	#1,d5		* rotate mask for clearing bits
	ror.w	#1,d0		* rotate mask for setting bits
	bcc	r_dy_llp_end	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word
r_dy_llp_end:
	dbra	d2,r_dy_ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
r_dy_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,rep_dygt	* loop until all planes are drawn
	bra	abl_out		* take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
r_dy_same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,r_dy_ltop	* loop until done with line segment
	bra	r_dy_bp		* done - check for more planes to draw

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Replace Mode When Delta X is	*
*	Greater than Delta Y						*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and text whether the current
*	plane should be set or cleared for the current foreground color.
*
or_dygt:
	movem.w d0-d2/d4/d5,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)
ifeq rev_vid
	not.w	d1		* complement the line style
endc
	tst.w	(a4)+		* set bits in this plane for the fgnd color?
ifne rev_vid
	beq	o_dy_0ltop	* nope - clear bits where mask = fgnd color
endc
ifeq rev_vid
	bne	o_dy_0ltop	* nope - clear bits where mask = fgnd color
endc
*
*	If the current bit in the mask is set then set the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dy_1ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	o_dy_1yinc	* it is 0 - do nothing
	or.w	d0,(a5)		* it is 1 - set the current bit in the line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
o_dy_1yinc:
	adda.w	d7,a5		* increment y
	tst.w	d4		* epsilon < 0?
	bmi	o_dy_1same1	* yes - don't increment x
	add.w	a2,d4		* nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the mask for setting bits.  If we have
*	overflowed the current word then update the pointer to the next word
*	in the plane.  Loop until all bits in the line segment have been drawn.
*
	ror.w	#1,d0		* rotate mask for setting bits
	bcc	o_dy_1llp_end	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word
o_dy_1llp_end:
	dbra	d2,o_dy_1ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
o_dy_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,or_dygt	* loop until all planes are drawn
	bra	abl_out		* take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dy_1same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,o_dy_1ltop	* loop until done with line segment
	bra	o_dy_bp		* done - check for more planes to draw

*
*	If the current bit in the mask is set then clear the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dy_0ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	o_dy_0yinc	* it is 0 - do nothing
	and.w	d5,(a5)		* it is 1 - clear the current bit in the line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
o_dy_0yinc:
	adda.w	d7,a5		* increment y
	tst.w	d4		* epsilon < 0?
	bmi	o_dy_0same1	* yes - don't increment x
	add.w	a2,d4		* nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the mask for clearing bits.  If we have
*	overflowed the current word then update the pointer to the next word
*	in the plane.  Loop until all bits in the line segment have been drawn.
*
	ror.w	#1,d5		* rotate mask for clearing bits
	bcs	o_dy_0llp_end	* branch if no overflow to next word
	adda.w	d6,a5		* overflowed word - bump pointer to next word
o_dy_0llp_end:
	dbra	d2,o_dy_0ltop	* loop until done with line segment
	bra	o_dy_bp		* done - check for more planes to draw

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dy_0same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,o_dy_0ltop	* loop until done with line segment
	bra	o_dy_bp

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Exclusive Or Mode When Delta	*
*	Y Is Greater than Delta X					*
*									*
*************************************************************************

ifeq	vme10
*
*	Save the registers that get clobbered.
*
xor_dygt:
	movem.w d0-d2/d4,-(sp)	* save the registers that get clobbered
	move.l	a5,-(sp)

*
*	If the endpoint at x2,y2 should be drawn then don't adjust the line.
*	If the line is a singularity (point) then do nothing.  If we are
*	drawing from x1,y1 then decrement the number of times to go through
*	the pixel drawing loop. If we are drawing from x2,y2 then update
*	epsilon and decrement the loop count without actually drawing the
*	first time through the loop.
*
	tst.w	_LSTLIN		* should the final endpoint be omitted?
	beq	x_dy_ltop	* nope - don't adjust that endpoint
	and.w	d2,d2		* is line a single point?
	beq	x_dy_bp		* yes - don't even bother to draw it
	movea.w	_X2,a0		* compute delta x
	cmpa.w	_X1,a0
	blt	x_dy_yinc	* drawing from x2,y2 - don't draw first point
	subq.w	#1,d2		* drawing from x1,y1 - don't draw last point
endc

*
*	If the current bit in the mask is set then exclusive or it with the
*	current bit in the line segment.  Otherwise, do nothing.
*
x_dy_ltop:
	rol.w	#1,d1		* get next bit from mask (line style)
	bcc	x_dy_yinc	* it is 0 - do nothing
	eor.w	d0,(a5)		* it is 1 - xor it with bit in line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
x_dy_yinc:
	adda.w	d7,a5		* increment y
	tst.w	d4		* epsilon < 0?
	bmi	x_dy_same1	* yes - don't increment x
	add.w	a2,d4		* nope - epsilon = epsilon + e2

*
*	Update the mask for exclusive or'ing bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
	ror.w	#1,d0		* rotate mask for xor'ing bits
	bcc	x_dy_llp_end	* branch if no overflow to next word
	adda.w	d6,a5		* overflow occurred - bump pointer to next word
x_dy_llp_end:
	dbra	d2,x_dy_ltop	* loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
x_dy_bp:
	move.l	(sp)+,a5	* restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4
ifeq	vme10
	adda.l	a1,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,xor_dygt	* loop until all planes are drawn
	bra	abl_out		* take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
x_dy_same1:
	add.w	a3,d4		* epsilon = epsilon + e1
	dbra	d2,x_dy_ltop	* loop until done with line segment
	bra	x_dy_bp		* done - check for more planes to draw

	.page
*************************************************************************
*									*
*	Line Drawing Routine for the Reverse Transparent Mode When	*
*	Delta Y Is Greater than Delta X					*
*									*
*************************************************************************

*
*	Draw a line in the reverse transparent mode by complementing the
*	line style and calling the code for drawing a line in the transparent
*	mode.
*
nor_dygt:
	not.w	d1		* complement the line style
	bsr	or_dygt		* call the transparent mode code to draw line
	not.w	_LN_MASK	* restore the proper states of the style bits
	rts

	.page
*************************************************************************
*									*
*	HABLINE								*
*									*
*	This routine draws a line between (_X1,_Y1) and (_X2,_Y1)	*
*	using a left fringe, inner loop, right fringe bitblt algor-	*
*	ithm.  The line is modified by the pattern and _WRT_MODE	*
*	variables.  This routine handles all 3 video resolutions.	*
*	Note that 2 entry points are provided for ABLINE.		*
*									*
*	input:								*
*	   _X1,_Y1,_X2	= coordinates.					*
*	   _v_planes	= number of video planes. (resolution)		*
*	   _patmsk	= index into pattern.				*
*	   _patptr	= ptr to pattern.				*
*	   _WRT_MODE	= writing mode.					*
*				0 => replace mode.			*
*				1 => or mode.				*
*				2 => xor mode.				*
*				3 => not mode.				*
*									*
*	output:		nothing.					*
*									*
*	destroys:	everything.					*
*									*
*************************************************************************

*
*	This is the entry point used by ABLINE when a horizontal line is
*	to be drawn using the current line style.
*
xl_noswap:
	lea	_LN_MASK,a0	* get the current line style
	movea.l	a1,a3		* get # of bytes between graphic planes
	clr.w	a1		* line style is monoplaned - no offset
	move.w	_X1,d4		* get starting x-coordinate
	move.w	_X2,d2		* get ending x-coordinate
	bra	xline

*
*	This is the entry point used by ABLINE when a horizontal line is
*	to be drawn using the current line style but when the two endpoints
*	need to be swapped.
*
xl_swap:
	lea	_LN_MASK,a0	* get the current line style
	movea.l	a1,a3		* get # of bytes between graphic planes
	clr.w	a1		* line style is monoplaned - no offset
	move.w	_X2,d4		* get starting x-coordinate
	move.w	_X1,d2		* get ending x-coordinate
	bra	xline

*
*	Main entry point to _HABLINE
*
*	Compute the address of the word containing the starting point of
*	the line to be drawn and the offset of the starting bit within the
*	word.
*
_HABLINE:
	movea.l	_v_bas_ad,a5	* get base address of first video plane
	lea	_FG_BP_1,a4	* get address of bit plane mask table
ifeq	vme10
	move.w	_v_planes,d3	* get number of planes - 1
	subq.w	#1,d3
	move.l	#v_pl_dspl,a3	* get offset to next video plane
endc
ifne	vme10
	movea.w	_v_planes,a3	* get number of planes
	move.w	a3,d3		* get number of planes - 1
	subq.w	#1,d3
	adda.w	a3,a3		* get offset to next word in same plane
endc
	move.w	_X1,d0		* get starting x-coordinate (input to concat)
	move.w	d0,d4		* save it for later use
	move.w	_Y1,d1		* get y-coordinate (input to concat)
	move.w	d1,d5		* save it for later use
	bsr	concat		* compute word offset and bit offset
ifne vme10
	adda.w	d1,a5		* compute actual address of starting word
endc 
ifeq vme10
	adda.l	d1,a5		* compute actual address of starting word
endc
	move.w	_X2,d2		* get ending x-coordinate

*
*	Get the pattern with which the line is to be drawn.
*
	and.w	_patmsk,d5	* get index into pattern
	asl.w	#1,d5		* convert to offset into pattern def table
	move.l	_patptr,a0	* get pointer to start of pattern definition
	adda.w	d5,a0		* get pointer to desired word of pattern def
	clr.w	a1		* init offset to next plane of pattern to 0
	tst.w	_multifill	* using multi-planed patterns?
	beq	xline		* nope
	move.w	#32,a1		* yes - offset = length of 1 plane of pat def

*
*	At this point the register usages are as follows:
*
*	d7 = scratch.		a5 = ptr to destination.
*	d6 = scratch.		a4 = ptr to _FG_BP_1.
*	d5 = scratch.		a3 = offset to next plane
*	d4 = _X1.		a2 = scratch
*	d3 = # of bit_planes - 1.
*	d2 = _X2.		a1 = offset to next plane of fill pattern
*	d1 = scratch		a0 = ptr to fill pattern
*	d0 = _X1 and $000F.
*

*
*	Compute the left and right fringe masks for the line.
*
xline:
	asl.w	#1,d0		* convert bit offset of 1st bit to word index
	move.w	lf_tab(pc,d0.w),d0	* get not of left fringe mask
	not.w	d0		* invert bits of mask to proper value
	move.w	d2,d7		* get ending x-coordinate
	andi.w	#$000F,d7	* get bit offset into its word
	asl.w	#1,d7		* convert bit offset of last bit to word index
	move.w	rf_tab(pc,d7.w),d7	* get right fringe mask

*
*	Compute the number of entire words to be written with the line.
*
	asr.w	#4,d4		* compute # of words preceeding starting point
	asr.w	#4,d2		* compute # of words preceeding ending point
	sub.w	d4,d2		* compute word offset between the endpoints
	subq.w	#1,d2		* compute # of full words in line

*
*	If the number of full words in the line segment is negative then the
*	two endpoints lie in the same word.  Combine the two fringe masks,
*	set the inner loop count to 0, and modify the right fringe mask so
*	that it will have no effect.
*
	bpl	hab_decode	* count >= 0 so this is a normal case
	or.w	d7,d0		* combine fringe masks
	clr.w	d2		* set inner loop count to 0
	moveq	#-1,d7		* prevent right mask from affecting screen
*
*	Jump to the appropriate handling routine for the current write mode
*	for both the general and special cases.
*
hab_decode:
	move.w	_WRT_MODE,d5	* write mode used to select HABLINE entry 
	asl.w	#2,d5		* convert to longword index
	move.l	htab(pc,d5.w),a2	* get address of handling routine
	jmp	(a2)		* jump to it

*
*	At this point the register usages are as follows:
*
*	d7 = right mask.	a5 = ptr to destination.
*	d6 = scratch.		a4 = ptr to _FG_BP_1.
*	d5 = scratch.		a3 = offset to next plane or next word in plane
*	d4 = scratch.		a1 = offset to next bitplane's fill pattern
*	d3 = # of bit_planes - 1.
*	d2 = inner loop count.	a0 = ptr to fill pattern
*	d1 = scratch
*	d0 = left mask (or left "and" right masks).
*

	.page
*************************************************************************
*									*
*	Word Mask Table							*
*									*
*	The table has been compacted by taking the one's complement	*
*	of the left fringe table and combining it with the right	*
*	fringe table.							*
*									*
*************************************************************************

lf_tab		dc.w	$FFFF		; origin for not left fringe lookup.
rf_tab		dc.w	$7FFF		; origin for right fringe lookup.
		dc.w	$3FFF
		dc.w	$1FFF
		dc.w	$0FFF
		dc.w	$07FF
		dc.w	$03FF
		dc.w	$01FF
                dc.w    $00FF
                dc.w    $007F
                dc.w    $003F
                dc.w    $001F
                dc.w    $000F
                dc.w    $0007
                dc.w    $0003
                dc.w    $0001
                dc.w    $0000

*************************************************************************
*									*
*	HABLINE Mode Address Table					*
*									*
*	This table contains the jump addresses for the line drawing	*
*	routines for the four writing modes.				*
*									*
*************************************************************************

ifne rev_vid
htab	dc.l	rep_x
	dc.l	or_x
	dc.l	xor_x
	dc.l	nor_x
endc
ifeq rev_vid
htab	dc.l	rep_x
	dc.l	nor_x
	dc.l	xor_x
	dc.l	or_x
endc
	.page
*************************************************************************
*									*
*	Line Drawing Routine for Replace Mode				*
*									*
*************************************************************************
                           
*
*	Save the registers that are clobbered and test whether the current
*	plane should be written with the line style or 0's.
*
rep_x:
	move.w	d2,-(sp)	* save registers that get clobbered
	move.l	a5,-(sp)
	move.w	(a0),d1		* get line style or fill pattern

	adda.w	a1,a0		* update line style/fill pattern pointer
	tst.w	(a4)+		* write this plane with pattern or 0's?
	bne	r_x_lf		* use pattern
	clr.w	d1		* use 0's

*
*	Draw the left fringe.
*
ifeq rev_vid
r_x_lf:
	not.w	d1		* invert line style or fill pattern
	move.w	(a5),d5		* get source data
endc
ifne rev_vid
r_x_lf:
	move.w	(a5),d5		* get source data
endc
	eor.w	d1,d5		* xor the pattern with the source
	and.w	d0,d5		* isolate the bits outside the fringe
	eor.w	d1,d5		* restore the bits outside the fringe
ifeq	vme10
	move.w	d5,(a5)+	* write the fringe and advance to next word
endc
ifne	vme10
	move.w	d5,(a5)		* write the fringe
	adda.w	a3,a5		* update pointer to next word in plane
endc

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	rx_lend		* test if any entire words are to be drawn
ifeq	vme10
rx_ltop:
	move.w	d1,(a5)+	* write current word and advance to next
endc
ifne	vme10
rx_ltop:
	move.w	d1,(a5)		* write current word
	adda.w	a3,a5		* update pointer to next word in plane
endc
rx_lend:
	dbra	d2,rx_ltop	* loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		* get source data
	eor.w	d1,d5		* xor the pattern with the source
	and.w	d7,d5		* isolate the bits outside the fringe
	eor.w	d1,d5		* restore the bits outside the fringe
	move.w	d5,(a5)		* write the fringe and advance to next word

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	move.l	(sp)+,a5	* restore the clobbered registers
	move.w	(sp)+,d2
ifeq	vme10
	adda.l	a3,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra	d3,rep_x	* loop until all planes are drawn
	rts

	.page
*************************************************************************
*									*
*	Line Drawing Routine for Transparent Mode			*
*									*
*	This mode is not to be confused with a true 'or' mode.		*
*									*
*************************************************************************

*
*	If the foreground color requires that bits in the current plane
*	be set then 'or' the mask with the source.  Otherwise, the fore-
*	ground color requires that bits in the current plane be cleared
*	so 'and' the complement of the mask with the source.  Bits that
*	would be drawn with the background color (black) are left unchanged.
*

*
*	Call a subroutine common to the transparent and reverse transparent
*	modes to draw the line segment.
*
or_x:
	move.w	(a0),d1		* get current scan of pattern
	bsr	or_nor		* draw the line segment
	dbra	d3,or_x		* loop until all planes drawn
	rts

	.page
*************************************************************************
*									*
*	Line Drawing Routine for Reverse Transparent Mode		*
*									*
*************************************************************************
                           
*
*	Get the one's complement of the pattern and call a subroutine
*	common to the transparent and reverse transparent modes to draw
*	the line segment.
*
nor_x:
	move.w	(a0),d1		* get current scan of pattern
	not.w	d1		* get one's complement of the pattern
	bsr	or_nor		* draw the line segment
	dbra	d3,nor_x	* loop until all planes drawn
	rts

	.page
*************************************************************************
*									*
*	General Purpose Line Drawing Routine for Both Transparent	*
*	and Reverse Transparent Writing Modes				*
*									*
*************************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be set or cleared for the current foreground color.
*
or_nor:
	movem.l	d2/a5,-(sp)	* save registers that get clobbered
	adda.w	a1,a0		* update pointer to next plane's pattern
ifeq rev_vid
	not.w	d1		* get complement of mask with source
endc
	tst.w	(a4)+		* set bits in this plane for the fgnd color?
ifne rev_vid
	bne	o_x_lf1		* yes - or mask with source
endc
ifeq rev_vid
	beq	o_x_lf1		* yes - or mask with source
endc
	not.w	d1		* nope - and complement of mask with source
*
*	Draw the left fringe by clearing bits in this plane.
*
o_x_lf0:
	move.w	(a5),d5		* get source data
	move.w	d5,d4		* save it
	and.w	d1,d5		* and complement of mask with source
	eor.w	d5,d4		* isolate changed bits
	and.w	d0,d4		* isolate changed bits outside of fringe
	eor.w	d4,d5		* restore them to original states
ifeq	vme10
	move.w	d5,(a5)+	* write left fringe and step to next word
endc
ifne	vme10
	move.w	d5,(a5) 	* write left fringe
	adda.w	a3,a5		* update pointer to next word in plane
endc

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	oxc_lend	* first test for any full words to be drawn
ifeq	vme10
oxc_ltop:
	and.w	d1,(a5)+	* clear all bits to contain foreground color
endc
ifne	vme10
oxc_ltop:
	and.w	d1,(a5)		* clear all bits to contain foreground color
	adda.w	a3,a5		* update pointer to next word in plane
endc
oxc_lend:
	dbra	d2,oxc_ltop	* loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		* get source data
	move.w	d5,d4		* save it
	and.w	d1,d5		* nope - and complement of mask with source
ox_merge:
	eor.w	d5,d4		* isolate changed bits
	and.w	d7,d4		* isolate changed bits outside of pattern
	eor.w	d4,d5		* restore them to original states
	move.w	d5,(a5)		* write out right fringe

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	movem.l	(sp)+,d2/a5	* restore the clobbered registers
ifeq	vme10
	adda.l	a3,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	rts

*
*	Draw the left fringe by setting bits in this plane.
*
o_x_lf1:
	move.w	(a5),d5		* get source data
	move.w	d5,d4		* save it
	or.w	d1,d5		* or mask with source
	eor.w	d5,d4		* isolate changed bits
	and.w	d0,d4		* isolate changed bits outside of fringe
	eor.w	d4,d5		* restore them to original states
ifeq	vme10
	move.w	d5,(a5)+	* write left fringe and step to next word
endc
ifne	vme10
	move.w	d5,(a5)		* write left fringe
	adda.w	a3,a5		* update pointer to next word in plane
endc

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	oxs_lend	* first test for any full words to be drawn
ifeq	vme10
oxs_ltop:
	or.w	d1,(a5)+	* set all bits to contain forground color
endc
ifne	vme10
	or.w	d1,(a5)		* clear all bits to contain foreground color
	adda.w	a3,a5		* update pointer to next word in plane
endc
oxs_lend:
	dbra	d2,oxs_ltop	* loop until done

*
*	Draw the right fringe by setting bits in this plane.
*
	move.w	(a5),d5		* get source data
	move.w	d5,d4		* save it
	or.w	d1,d5		* or mask with source
	bra	ox_merge	* jump to common code for setting and clearing

	.page
*************************************************************************
*									*
*	Line Drawing Routine for Exclusive Or Mode			*
*									*
*************************************************************************

*
*	Save the registers that get clobbered.
*
xor_x:
	movem.l	d2/a5,-(sp)	* save registers that get clobbered
	move.w	(a0),d1		* get line style or fill pattern
	adda.w	a1,a0		* update line style/fill pattern pointer

*
*	Draw the left fringe.
*
x_x_lf:
	move.w	(a5),d5		* get the source
	move.w	d5,d4		* save it
	eor.w	d1,d5		* xor the pattern with the source
	eor.w	d5,d4		* xor result with source - now have pattern
	and.w	d0,d4		* isolate changed bits outside of fringe
	eor.w	d4,d5		* restore states of bits outside of fringe
ifeq	vme10
	move.w	d5,(a5)+	* write left fringe and advance to next word
endc
ifne	vme10
	move.w	d5,(a5)		* write left fringe
	adda.w	a3,a5		* update pointer to next word in plane
endc

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	xx_lend		* test if any entire words are to be drawn
ifeq	vme10
xx_ltop:
	eor.w	d1,(a5)+	* draw current word and advance to next
endc
ifne	vme10
xx_ltop:
	eor.w	d1,(a5)		* draw current word
	adda.w	a3,a5		* update pointer to next word in plane
endc
xx_lend:
	dbra	d2,xx_ltop	* loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		* get the source
	move.w	d5,d4		* save it
	eor.w	d1,d5		* xor the pattern with the source
	eor.w	d5,d4		* xor result with source - now have pattern
	and.w	d7,d4		* isolate changed bits outside of fringe
	eor.w	d4,d5		* restore states of bits outside of fringe
	move.w	d5,(a5)		* write out right fringe

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	movem.l (sp)+,d2/a5     * restore the clobbered registers
ifeq	vme10
	adda.l  a3,a5		* update pointer to next plane
endc
ifne	vme10
	addq.w	#2,a5		* update pointer to next plane
endc
	dbra    d3,xor_x        * loop until all bit planes are drawn
	rts
	.end
