/****
* fVDI device driver clip function
*
* Copyright 1997-2000, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
****/

#include	"vdi.inc"

	.xdef	clip_line

	.text
	
* clip_line - Internal function
*
* Clips line coordinates
* Todo:	?
* In:	a0	VDI struct
*	d1-d2	x1,y1
*	d3-d4	x2,y2
* Out:	d1-d4	clipped coordinates
clip_line:
#ifdef COLDFIRE
	lea		-16(a7),a7
	movem.l		d0/d5-d7,(a7)
#else
	movem.l		d0/d5-d7,-(a7)
#endif
	tst.w		vwk_clip_on(a0)
	beq		.end_clip

	moveq		#0,d0		// Coordinate flip flag
	move.w		vwk_clip_rectangle_x1(a0),d6
	move.w		vwk_clip_rectangle_y1(a0),d7
#ifdef COLDFIRE
	ext.l		d1
	ext.l		d2
	ext.l		d3
	ext.l		d4
	ext.l		d6
	ext.l		d7
	sub.l		d6,d1		// Change to coordinates
	sub.l		d7,d2		//  relative to the clip rectangle
	sub.l		d6,d3
	sub.l		d7,d4
#else
	sub.w		d6,d1		// Change to coordinates
	sub.w		d7,d2		//  relative to the clip rectangle
	sub.w		d6,d3
	sub.w		d7,d4
#endif

//	move.w		clip_h(pc),d7
	move.w		vwk_clip_rectangle_y2(a0),d7
#ifdef COLDFIRE
	move.w		vwk_clip_rectangle_y1(a0),d5	// d7 - max y-coordinate of clip rectangle
	ext.l		d7
	ext.l		d5
	sub.l		d5,d7
//	addq.l		#1,d7		// d7 - height of clip rectangle
	cmp.l		d2,d4
#else	
	sub.w		vwk_clip_rectangle_y1(a0),d7	// d7 - max y-coordinate of clip rectangle
//	addq.w		#1,d7		// d7 - height of clip rectangle
	cmp.w		d2,d4
#endif
	bge.s		.sort_y1y2	// Make sure max y-coordinate for <d3,d4>  (Was 'bpl')
#ifdef COLDFIRE
	move.l		d3,d5
	move.l		d1,d3
	move.l		d5,d1
	move.l		d4,d5
	move.l		d2,d4
	move.l		d5,d2
	not.l		d0		// Mark as flipped
#else
	exg		d1,d3
	exg		d2,d4
	not.w		d0		// Mark as flipped
#endif

.sort_y1y2:
#ifdef COLDFIRE
	cmp.l		d7,d2
	bgt		.error		// All below screen?  (Was 'bpl', with d7++)
	move.l		d4,d6
	blt		.error		// All above screen?  (Was 'bmi')
	sub.l		d2,d6		// d6 = dy (pos)
	move.l		d3,d5
	sub.l		d1,d5		// d5 = dx
#else
	cmp.w		d7,d2
	bgt		.error		// All below screen?  (Was 'bpl', with d7++)
	move.w		d4,d6
	blt		.error		// All above screen?  (Was 'bmi')
	sub.w		d2,d6		// d6 = dy (pos)
	move.w		d3,d5
	sub.w		d1,d5		// d5 = dx
#endif
	bne.s		.no_vertical

	tst.w		d2		// Clip vertical
	bge.s		.y1in		// Line to top/bottom  (Was 'bpl')
	moveq		#0,d2
.y1in:	cmp.w		d7,d4
	ble.s		.vertical_done	// (Was 'bmi', with d7++)
	move.w		d7,d4
	bra.s		.vertical_done

.no_vertical:
	tst.w		d2
	bge.s		.y1_inside	// (Was 'bpl')
	muls.w		d5,d2		// dx * (y1 - tc)
	divs.w		d6,d2		// dx * (y1 - tc) / (y2 - y1)
#ifdef COLDFIRE
	ext.l		d2
	sub.l		d2,d1		// x1' = x1 - (dx * (y1 - tc)) / (y2 - y1)
#else
	sub.w		d2,d1		// x1' = x1 - (dx * (y1 - tc)) / (y2 - y1)
#endif
	moveq		#0,d2		// y1' = ty

.y1_inside:
#ifdef COLDFIRE
	sub.l		d4,d7
#else
	sub.w		d4,d7
#endif
	bge.s		.y2_inside	// (Was 'bpl', with d7++ (which was probably wrong))
// Is a d7++ needed now when it isn't there above?
	muls.w		d7,d5		// dx * (bc - y2)
	divs.w		d6,d5		// dx * (bc - y2) / (y2 - y1)
#ifdef COLDFIRE
	ext.l		d5
	add.l		d5,d3		// x2' = x2 + (dx * (bc - y2)) / (y2 - y1)
	add.l		d7,d4		// y2' = by
#else
	add.w		d5,d3		// x2' = x2 + (dx * (bc - y2)) / (y2 - y1)
	add.w		d7,d4		// y2' = by
#endif

.y2_inside:
.vertical_done:
//	move.w		clip_w(pc),d7
	move.w		vwk_clip_rectangle_x2(a0),d7
#ifdef COLDFIRE
	move.l		d5,-(a7)
	move.w		vwk_clip_rectangle_x1(a0),d5	// d7 - max x-coordinate of clip rectangle
	ext.l		d7
	ext.l		d5
	sub.l		d5,d7
	move.l		(a7)+,d5
//	addq.l		#1,d7		// d7 - width of clip rectangle
	cmp.l		d1,d3
	bge.s		.sort_x1x2	// Make sure max x-coordinate for <d3,d4>  (Was 'bpl')
	move.l		d5,-(a7)
	move.l		d3,d5
	move.l		d1,d3
	move.l		d5,d1
	move.l		d4,d5
	move.l		d2,d4
	move.l		d5,d2
	move.l		(a7)+,d5
	not.l		d0		// Mark as flipped
#else
	sub.w		vwk_clip_rectangle_x1(a0),d7	// d7 - max x-coordinate of clip rectangle
//	addq.w		#1,d7		// d7 - width of clip rectangle
	cmp.w		d1,d3
	bge.s		.sort_x1x2	// Make sure max x-coordinate for <d3,d4>  (Was 'bpl')
	exg		d1,d3
	exg		d2,d4
	not.w		d0		// Mark as flipped
#endif

.sort_x1x2:
#ifdef COLDFIRE
	cmp.l		d7,d1
	bgt		.error		// All right of screen?  (Was 'bpl', with d7++)
	move.l		d3,d5
	blt		.error		// All left of screen?   (Was 'bmi')
	sub.l		d1,d5		// d5 = dx (pos)
	move.l		d4,d6
	sub.l		d2,d6		// d6 = dy
#else
	cmp.w		d7,d1
	bgt		.error		// All right of screen?  (Was 'bpl', with d7++)
	move.w		d3,d5
	blt		.error		// All left of screen?   (Was 'bmi')
	sub.w		d1,d5		// d5 = dx (pos)
	move.w		d4,d6
	sub.w		d2,d6		// d6 = dy
#endif
	bne.s		.no_horizontal

	tst.w		d1		// Clip horizontal
	bge.s		.x1in		// Line to left/right  (Was 'bpl')
	moveq		#0,d1
.x1in:
#ifdef COLDFIRE 
	cmp.l		d7,d3
	ble.s		.horizontal_done	// (Was 'bmi', with d7++)
	move.l		d7,d3
#else
	cmp.w		d7,d3
	ble.s		.horizontal_done	// (Was 'bmi', with d7++)
	move.w		d7,d3
#endif
	bra.s		.horizontal_done

.no_horizontal:
	tst.w		d1
	bge.s		.x1_inside	// (Was 'bpl')
	muls.w		d6,d1		// dy * (x1 - lc)
	divs.w		d5,d1		// dy * (x1 - lc) / (x2 - x1)
#ifdef COLDFIRE
	ext.l		d1
	sub.l		d1,d2		// y1' = y1 - (dy * (x1 - lc)) / (x2 - x1)
#else
	sub.w		d1,d2		// y1' = y1 - (dy * (x1 - lc)) / (x2 - x1)
	moveq		#0,d1		// x1' = lc
#endif

.x1_inside:
#ifdef COLDFIRE
	sub.l		d3,d7
#else
	sub.w		d3,d7
#endif
	bge.s		.x2_inside	// (Was 'bpl', with d7++ (which was probably wrong))
// Is a d7++ needed now when it isn't there above?
	muls.w		d7,d6		// dy * (rc - x2)
	divs.w		d5,d6		// dy * (rc - x2) / (x2 - x1)
#ifdef COLDFIRE
	ext.l		d6
	add.l		d6,d4		// y2' = y2 + (dx * (bc - y2)) / (y2 - y1)
	add.l		d7,d3		// x2' = rc
#else
	add.w		d6,d4		// y2' = y2 + (dx * (bc - y2)) / (y2 - y1)
	add.w		d7,d3		// x2' = rc
#endif

.x2_inside:
.horizontal_done:
	move.w		vwk_clip_rectangle_x1(a0),d6
	move.w		vwk_clip_rectangle_y1(a0),d7
#ifdef COLDFIRE
	ext.l		d6
	ext.l		d7
	add.l		d6,d1		// Change back to real coordinates
	add.l		d7,d2
	add.l		d6,d3
	add.l		d7,d4
#else
	add.w		d6,d1		// Change back to real coordinates
	add.w		d7,d2
	add.w		d6,d3
	add.w		d7,d4
#endif

	tst.w		d0
	beq		.end_clip
#ifdef COLDFIRE
	move.l		d3,d7
	move.l		d1,d3		// Flip back again if needed
	move.l		d7,d1
	move.l		d4,d7
	move.l		d2,d4
	move.l		d7,d2
#else
	exg		d1,d3		// Flip back again if needed
	exg		d2,d4
#endif
.end_clip:
#ifdef COLDFIRE
	movem.l		(a7),d0/d5-d7
	lea		16(a7),a7
#else
	movem.l		(a7)+,d0/d5-d7
#endif
	rts

.error:
#ifdef COLDFIRE
	moveq		 #-1,d0
	add.l		d0,d0
	movem.l		(a7),d0/d5-d7
	lea		16(a7),a7
	move.w		#2,ccr	// Return with the overflow flag set
	rts
#else
	movem.l		(a7)+,d0/d5-d7
	move.w		#2,-(a7)	// Return with the overflow flag set
	rtr
#endif
