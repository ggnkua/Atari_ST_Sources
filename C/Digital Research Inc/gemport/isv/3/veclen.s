		.text
		.globl	_vec_len

********************************************************************************
********************************************************************************
**									      **
**	_vec_len:							      **
**		This routine computes the length of a vector using the form-  **
**	ula sqrt(dx*dx + dy*dy).					      **
**									      **
**		input:	4(sp) = dx.					      **
**			6(sp) = dy.					      **
**									      **
**		output: d0 = sqrt(dx*dx + dy*dy).			      **
**									      **
**		destroys: d0,d1,d2,d3 & d4.				      **
**									      **
********************************************************************************
********************************************************************************
*
*
_vec_len:	move.w	4(sp),d0	; fetch dx.
		muls	d0,d0		; dx*dx.
		move.w	6(sp),d1	; fetch dy.
		muls	d1,d1		; dy*dy.
		add.l	d0,d1		; (dx*dx + dy*dy).
		beq	vl_out		; if length = 0, branch.
*
*		Compute an initial upper and lower bound on the square root.
*	The lower bound is the smallest number that is no more than half the length
*   of the square; the upper bound is twice the lower bound.
*
		move.l	d1,d0		; save square for later comparisons.
		moveq.l	#0,d2		; start square length at 0.
		cmp.l	#$10000,d1	; does high order word contain 1's?
		bcs	bds_lp		; no, branch.
		swap	d1		; yes, work on high word.
		move.w	#16,d2		; start square length at 16.
*
bds_lp:		cmp.w	#1,d1		; done generating initial lower bound?
		beq	bds_end		; yes, branch.
		addq.w	#1,d2		; no, increment square length.
		lsr.w	#1,d1		; shift the square right.
		bra	bds_lp
*
bds_end:	asr.w	#1,d2		; square_length/2.
		moveq.l	#1,d3
		asl.w	d2,d3		; initial lower bound.
		move.w	d3,d2
		asl.w	#1,d2		; initial upper bound.
		bne	srch_lp		; check for overflow.
		subq.w	#1,d2		; if overflow, upper bound := $FFFF.
*
*	Now, perform a binary search for the square root.
*
srch_lp:	move.w	d2,d1
		sub.w	d3,d1		; upper - lower.
		cmp.w	#1,d1		; search done?
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
hi_adjust:	move.w	d4,d2		; move upper bound down to last candidate.
		bra	srch_lp
*
lo_adjust:	move.w	d4,d3		; move lower bound up to last candidate.
		bra	srch_lp
*
srch_end:	move.w	d3,d0		; use the lower bound.
vl_out:		rts
		.end
