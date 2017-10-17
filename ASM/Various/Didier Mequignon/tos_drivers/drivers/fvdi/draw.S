/****
* fVDI drawing functions
*
* $Id: draw.s,v 1.9 2005/07/10 00:08:52 johan Exp $
*
* Copyright 1997-2003, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
****/

#include "vdi.inc"
#include "macros.inc"

	.xdef	_default_line
	.xref	setup_plot,clip_line

	.data
	
/* _default_line - Pixel by pixel line routine
* In:	a0	VDI struct (odd address marks table operation)
*	d0	Colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5.w	Pattern
*	d6	Logic operation
* Call:	a0	VDI struct, 0 (destination MFDB)
*	d1-d2.w	Coordinates
*	a3-a4	Set/get pixel
*/
_default_line:
#ifdef COLDFIRE
	lea	-20(a7),a7	
	movem.l	d6-d7/a1/a3-a4,(a7)
	move.l	a0,d7
	and.l	#1,d7
	sub.l	d7,a0
#else
	movem.l	d6-d7/a1/a3-a4,-(a7)
	move.w	a0,d7
	and.w	#1,d7
	sub.w	d7,a0
#endif

	move.l	vwk_real_address(a0),a1
	move.l	wk_r_get_colour(a1),a1	// Index to real colour
	jsr	(a1)

	clr.l	-(a7)			// No MFDB => draw on screen
	move.l	a0,-(a7)

	move.w	d6,-(a7)
	bsr	setup_plot		// Setup pixel plot functions (a1/a3/a4)
	addq.l	#2,a7

	tst.w	d7
	bne	.multiline

	jsr	clip_line
	bvs	.skip_draw

	move.l	a7,a0			// a0 no longer -> VDI struct!

	bsr	.draw
.skip_draw:

	move.l	(a7),a0
	addq.l	#8,a7

#ifdef COLDFIRE
	movem.l	(a7),d6-d7/a1/a3-a4
	lea	20(a7),a7
#else
	movem.l	(a7)+,d6-d7/a1/a3-a4
#endif
	rts
	
.draw:
	move.l	#0x00010001,d7		// d7 = y-step, x-step
#ifdef COLDFIRE
	move.l	d0,-(a7)
	move.l	d6,-(a7)
	move.w	d1,d0
	move.w	d3,d6
	ext.l	d0
	ext.l	d6
	sub.l	d0,d6
	move.w	d6,d3		// d3 = dx
	bge	.ok1
	neg.l	d6
	move.w	d6,d3
	move.w	d7,d6
	neg.l	d6
	move.w	d6,d7
.ok1:
	move.w	d2,d0
	move.w	d4,d6
	ext.l	d0
	ext.l	d6
	sub.l	d0,d6			// d4 = dy
	move.w	d6,d4
	bge	.ok2
	neg.l	d6
	move.w	d6,d4
	swap	d7
	move.w	d7,d6
	neg.l	d6
	move.w	d6,d7
	swap	d7
.ok2:
	move.l	(a7)+,d6
#else
	sub.w	d1,d3			// d3 = dx
	bge	.ok1
	neg.w	d3
	neg.w	d7	
.ok1:
	sub.w	d2,d4			// d4 = dy
	bge	.ok2
	neg.w	d4
	swap	d7
	neg.w	d7
	swap	d7
.ok2:
#endif
	and.l	#0xffff,d5
#ifdef COLDFIRE
	move.l	d2,-(a7)
	move.w	d3,d0
	move.w	d4,d2
	ext.l	d0
	ext.l	d2
	cmp.l	d0,d2
	bls	.xmajor
	or.l	#0x80000000,d5
	move.w	d4,d3
	move.w	d0,d4
.xmajor:
	move.w	d4,d2
	ext.l	d2
	add.l	d2,d2
	move.w	d2,d4			// d4 = incrE = 2dy
	move.w	d3,d0
	ext.l	d0
	sub.l	d0,d2			// d6 = lines, d = 2dy - dx
	move.w	d2,d6
	swap	d4
	sub.l	d0,d2			// d4 = incrE, incrNE = 2(dy - dx)
	move.w	d2,d4

	moveq	#0,d2
	move.w	d5,d2
	add.l	d2,d2
	move.l	d2,d0
	swap	d0
	or.l	d2,d0
	move.w	d0,d5
	move.l	(a7)+,d2
	move.l	(a7)+,d0
	move	d5,ccr
#else
	cmp.w	d3,d4
	bls	.xmajor
	or.l	#0x80000000,d5
	exg	d3,d4
.xmajor:
	add.w	d4,d4			// d4 = incrE = 2dy
	move.w	d4,d6
	sub.w	d3,d6			// d6 = lines, d = 2dy - dx
	swap	d4
	move.w	d6,d4
	sub.w	d3,d4	

	rol.w	#1,d5
#endif
	jsr	(a1)

	swap	d1
	move.w	d2,d1
	swap	d1			// d1 = y, x
	bra	.loop_end1

.loop1:
	tst.w	d6
	bgt	.both
	swap	d4
#ifdef COLDFIRE
	move.l	d0,-(a7)
	move.w	d4,d0
	move.w	d6,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d6
	move.l	(a7)+,d0
#else
	add.w	d4,d6
#endif
	swap	d4
	tst.l	d5
	bmi	.ymajor
#ifdef COLDFIRE
	move.l	d0,-(a7)
	move.w	d7,d0
	move.w	d1,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d1
	move.l	(a7)+,d0
#else
	add.w	d7,d1
#endif
	bra	.plot
.ymajor:
	swap	d7
	swap	d1
#ifdef COLDFIRE
	move.l	d0,-(a7)
	move.w	d7,d0
	move.w	d1,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d1
	move.l	(a7)+,d0
#else
	add.w	d7,d1
#endif
	swap	d7
	swap	d1
	bra	.plot
.both:
#ifdef COLDFIRE
	move.l	d0,-(a7)
	move.w	d4,d0
	move.w	d6,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d6
	move.w	d7,d0
	move.w	d1,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d1
#else
	add.w	d4,d6
	add.w	d7,d1
#endif
	swap	d7
	swap	d1
#ifdef COLDFIRE
	move.w	d7,d0
	move.w	d1,d2
	ext.l	d0
	ext.l	d2
	add.l	d0,d2
	move.w	d2,d1
	move.l	(a7)+,d0
#else
	add.w	d7,d1
#endif
	swap	d7
	swap	d1
.plot:
#ifdef COLDFIRE
	move.l	d0,-(a7)
	moveq	#0,d2
	move.w	d5,d2
	add.l	d2,d2
	move.l	d2,d0
	swap	d0
	or.l	d2,d0
	move.w	d0,d5	
	move.l	(a7)+,d0
	move.l	d1,d2
	swap	d2
	move	d5,ccr
#else
	move.l	d1,d2
	swap	d2
	rol.w	#1,d5
#endif
	jsr	(a1)

.loop_end1:
#ifdef COLDFIRE
	move.l	d2,-(sp)
	move.w	d3,d2
	subq.l	#1,d2
	move.w	d2,d3
	move.l	(sp)+,d2
	tst.w	d3	
	bpl	.loop1
#else
	dbra	d3,.loop1
#endif
	rts
	
.multiline:				// Transform multiline to single ones
#ifdef COLDFIRE
	move.l	d2,-(a7)
	ext.l	d2
	cmp.l	#1,d2
	bhi.s	.line_done_cf	// Only coordinate pairs and pairs+marks available so far
	bne.s	.not_use_marks
	move.l	(a7)+,d2
	bra.s	.use_marks
.line_done_cf:
	move.l	(a7)+,d2
	bra	.line_done
.not_use_marks:
	moveq	#0,d3			// Move count
.use_marks:
	move.l	(a7)+,d2
#else
	cmp.w	#1,d2
	bhi	.line_done		// Only coordinate pairs and pairs+marks available so far
	beq	.use_marks
	moveq	#0,d3			// Move count
.use_marks:
#endif
	swap	d3
	move.w	#1,d3			// Current index in high word
	swap	d3
#ifdef COLDFIRE
	lea	-28(a7),a7
	movem.l	d0/d2/d3/d5/a0/a5-a6,(a7)
#else
	movem.l	d0/d2/d3/d5/a0/a5-a6,-(a7)
#endif
	move.l	d1,a5			// Table address
	move.l	d4,a6			// Move index address
	tst.w	d3			//  may not be set
	beq	.no_start_move
#ifdef COLDFIRE
	move.w	d3,d1
	ext.l	d1
	add.l	d1,a6
	add.l	d1,a6
	subq.l	#2,a6
	move.w	(a6),d1
	ext.l	d1
	cmp.l	#-4,d1
#else
	add.w	d3,a6
	add.w	d3,a6
	subq.l	#2,a6
	cmp.w	#-4,(a6)
#endif
	bne	.no_start_movex
	subq.l	#2,a6
#ifdef COLDFIRE
	move.w	d3,d1
	subq.l	#1,d1
	move.w	d1,d3
#else
	sub.w	#1,d3
#endif
.no_start_movex:
#ifdef COLDFIRE
	move.w	(a6),d1
	ext.l	d1
	cmp.l	#-2,d1
#else
	cmp.w	#-2,(a6)
#endif
	bne	.no_start_move
	subq.l	#2,a6
#ifdef COLDFIRE
	move.w	d3,d1
	subq.l	#1,d1
	move.w	d1,d3
#else
	sub.w	#1,d3
#endif
.no_start_move:
	bra	.line_loop_end
.line_loop:
#ifdef COLDFIRE
	move.w	(a5),d1
	move.w	2(a5),d2
	move.w	4(a5),d3
	move.w	6(a5),d4
	ext.l	d1
	ext.l	d2
	ext.l	d3
	ext.l	d4
#else
	movem.w	(a5),d1-d4
#endif
	move.l	7*4(a7),a0
	jsr	clip_line
	bvs	.no_draw
	move.l	0(a7),d6		// Colour
	move.l	3*4(a7),d5		// Pattern
//	move.l	xxx(a7),d0		// Logic operation
	lea	7*4(a7),a0
	bsr	.draw
.no_draw:
	move.l	2*4(a7),d3
	tst.w	d3
	beq	.no_marks
	swap	d3
#ifdef COLDFIRE
	move.w	d3,d1
	ext.l	d1
	addq.l	#1,d1
	move.w	d1,d3
	move.l	d1,d4
	add.l	d4,d4
	subq.l	#4,d4
	move.w	(a6),d1
	ext.l	d1
	cmp.l	d1,d4
#else
	addq.w	#1,d3
	move.w	d3,d4
	add.w	d4,d4
	subq.w	#4,d4
	cmp.w	(a6),d4
#endif
	bne	.no_move
	subq.l	#2,a6
#ifdef COLDFIRE
	addq.l	#1,d1
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	subq.l	#1,d1
	move.w	d1,d3
	swap	d3
	addq.l	#4,a5
	move.w	1*4(a7),d1
	subq.l	#1,d1
	move.w	d1,1*4(a7)
#else
	addq.w	#1,d3
	swap	d3
	subq.w	#1,d3
	swap	d3
	addq.l	#4,a5
	subq.w	#1,1*4(a7)
#endif
.no_move:
	swap	d3
	move.l	d3,2*4(a7)
.no_marks:
	addq.l	#4,a5
.line_loop_end:
#ifdef COLDFIRE
	move.w	1*4(a7),d1
	subq.l	#1,d1
	move.w	d1,1*4(a7)
	bgt	.line_loop
	movem.l	(a7),d0/d2/d3/d5/a0/a5-a6
	lea	28(a7),a7
#else
	subq.w	#1,1*4(a7)
	bgt	.line_loop
	movem.l	(a7)+,d0/d2/d3/d5/a0/a5-a6
#endif
.line_done:
	move.l	(a7),a0
	addq.l	#8,a7

#ifdef COLDFIRE
	movem.l	(a7),d6-d7/a1/a3-a4
	lea	20(a7),a7
#else
	movem.l	(a7)+,d6-d7/a1/a3-a4
#endif
	rts
