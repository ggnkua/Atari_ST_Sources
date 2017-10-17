/****
* fVDI text drawing functions
*
* $Id: text.s,v 1.8 2005/05/07 18:38:55 standa Exp $
*
* Copyright 1997-2003, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
****/

#define transparent	1		// Fall through?

#include	"vdi.inc"
#include	"macros.inc"

	.xref	lib_vrt_cpyfm
	.xref	_allocate_block,_free_block
	.xref	text_area

	.xdef	_default_text

	.data

	
/* _default_text - Buffer rendering or individual character mono-expand text routine
* Todo:	Add effects of effects to the size
* In:	a0	VDI struct
*	a1	Pointer to string
*	a2	Pointer to character offset table or zero
*	d0	String length
*	d1	Coordinates
* Call:	a0	VDI struct
*	a1	Parameters for lib_vrt_cpyfm
*/
_default_text:
#ifdef COLDFIRE
	lea	-36(sp),sp
	movem.l	d3-d7/a3-a6,(sp)
#else
	movem.l	d3-d7/a3-a6,-(sp)
#endif

/* Some other method should be used for this! */
	move.l	vwk_text_current_font(a0),a3

	moveq	#0,d4		// Offset extension of length
	move.l	a2,d3
	beq	.no_offsets
	move.l	a2,a3
	move.w	d0,d3
#ifdef COLDFIRE
	ext.l	d3
	subq.l	#1,d3
#else
	subq.w	#1,d3
#endif
.test_offsets:
	move.l	(a3)+,d5
	beq	.no_offset_here
	tst.w	d5
	bne	.single_char
	swap	d5
#ifdef COLDFIRE
	ext.l	d5
	add.l	d5,d4
.no_offset_here:
	subq.l	#1,d3
	bpl.s	.test_offsets
#else
	add.w	d5,d4
.no_offset_here:
	dbra	d3,.test_offsets
#endif
.no_offsets:

	move.l	d0,a3
#ifdef COLDFIRE
	lea	-20(sp),sp
	movem.l      d1-d2/a0-a2,(sp)
#else
	movem.l      d1-d2/a0-a2,-(sp)
#endif
	clr.l	-(sp)			// Get a memory block of any size (hopefully large)
	jsr	_allocate_block
	addq.l	#4,sp
#ifdef COLDFIRE
	move.l	d0,d1
	move.l	a3,d0
	move.l	d1,a3
	tst.l	d1
	movem.l      (sp),d1-d2/a0-a2
	lea	20(sp),sp
#else
	movem.l      (sp)+,d1-d2/a0-a2
	tst.l	d0
	exg	d0,a3
#endif
	beq	.single_char
	move.l	a3,-(sp)			// For free_block below

	move.l	vwk_text_current_font(a0),a5	// Font structure
	move.w	font_height(a5),d5
	swap	d5

	btst	#3,font_flags(a5)		// Proportional?
	bne	.nonproportional

#ifdef COLDFIRE
	lea	-28(sp),sp
	movem.l	d0-d2/d4-d5/a1/a3,(sp)
#else
	movem.l	d0-d2/d4/a1/a3,-(sp)
#endif
	move.l	font_table_character(a5),a3
	move.w	font_code_low(a5),d2
	move.w	font_code_high(a5),d4
#ifdef COLDFIRE
	ext.l	d0
	ext.l	d2
	ext.l	d4
#endif
	moveq	#0,d3			// Width total
	lbra	.no_char2
.size_loop1:
#ifdef COLDFIRE
	moveq	#0,d1
	move.w	(a1)+,d1
    	sub.l	d2,d1			// Negative numbers are higher
	cmp.l	d4,d1			//  than code_high
	lbhi	.no_char2
	add.l	d1,d1
	move.w	2(a3,d1.l),d5
	ext.l	d5
	add.l	d5,d3
	move.w	0(a3,d1.l),d5
	ext.l	d5
	sub.l	d5,d3
.no_char2:
	subq.l	#1,d0
	bpl.s	.size_loop1
	movem.l	(sp),d0-d2/d4-d5/a1/a3
	lea	28(sp),sp
#else
	move.w	(a1)+,d1
	sub.w	d2,d1			// Negative numbers are higher
	cmp.w	d4,d1			//  than code_high
	lbhi	.no_char2
	add.w	d1,d1
	add.w	2(a3,d1.w),d3
	sub.w	0(a3,d1.w),d3
.no_char2:
	ldbra	d0,.size_loop1
	movem.l	(sp)+,d0-d2/d4/a1/a3
#endif
	bra	.width_done
	
.nonproportional:
	move.w	font_widest_cell(a5),d3
	mulu	d0,d3

.width_done:

	tst.w	d4
	beq	.keep_width
#ifdef COLDFIRE
	move.w	font_widest_cell(a5),d3
	ext.l	d3
	ext.l	d4
	add.l	d4,d3
#else
	move.w	d4,d3
	add.w	font_widest_cell(a5),d3
#endif
.keep_width:
#ifdef COLDFIRE
	move.l	d5,-(sp)
	moveq	#0,d5
	move.w	d3,d5
	add.l	#15,d5
	lsr.l	#4,d5
	addq.l	#1,d5
	and.l	#0xfffe,d5	// Even number of words wide
	add.l	d5,d5		// d5 - height, bytes wide
	move.w	d5,2(sp)
	move.l	(sp)+,d5

	lea	-8(sp),sp
	movem.l	d1/d3,(sp)
	lea	-16(sp),sp
	movem.l	d5/a0/a3/a5,(sp)
#else
	move.w	d3,d5
	add.w	#15,d5
	lsr.w	#4,d5
	addq.w	#1,d5
	and.w	#0xfffe,d5	// Even number of words wide
	add.w	d5,d5		// d5 - height, bytes wide

	movem.l	d1/d3,-(sp)
	movem.l	d5/a0/a3/a5,-(sp)
#endif

	tst.w	d4
	beq	.no_clear
	move.l	d5,d1
	swap	d1
	mulu	d5,d1
#ifdef COLDFIRE
	lsr.l	#4,d1
#else
	lsr.w	#4,d1
#endif
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
.loop_1:
	movem.l	d3-d6,(a3)
	add.l	#16,a3
#ifdef COLDFIRE
	subq.l	#1,d1
	bpl	.loop_1
#else
	ldbra	d1,.loop_1
#endif
	movem.l	(sp),d5/a0/a3/a5
.no_clear:

	move.l	a1,a4				// String address
	sub.l	a1,a1				// Clip rectangle
	moveq	#5,d6				// Fake top line alignment
	moveq	#0,d3				// Coordinates
	moveq	#0,d4
	bsr	text_area
	move.l	4(sp),a0
	move.w	vwk_text_effects(a0),d0
	btst	#0,d0
	beq	.no_bold	
	movem.l	(sp),d5/a0/a3/a5
	move.l	a3,a0
	move.l	a3,a1
	move.w	d5,a6
#ifdef COLDFIRE
	moveq	#0,d3
	move.w	d5,d3
	lsr.l	#1,d3
#else
	move.w	d5,d3
	lsr.w	#1,d3
#endif
	swap	d5
	move.w	d5,d7
	move.w	font_thickening(a5),d4
	bsr	bold
	move.l	4(sp),a0
	move.w	vwk_text_effects(a0),d0
.no_bold:

	btst	#3,d0
	beq	.no_underline
	movem.l	(sp),d5/a0/a3/a5
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	d5,d0
	move.w	font_distance_top(a5),d1
	ext.l	d1
	addq.l	#1,d1
	mulu	d0,d1
	add.l	d1,a3
	lsr.l	#2,d0
	subq.l	#1,d0
	move.w	font_underline(a5),d1
	ext.l	d1
	subq.l	#1,d1
#else
	move.w	d5,d0
	move.w	font_distance_top(a5),d1
	addq.w	#1,d1
	mulu	d0,d1
	add.l	d1,a3
	lsr.w	#2,d0
	subq.w	#1,d0
	move.w	font_underline(a5),d1
	subq.w	#1,d1
#endif
	moveq	#-1,d3
.loop11:
	move.l	a3,a0
	move.w	d0,d2
#ifdef COLDFIRE
	ext.l	d2
#endif
.loop22:
	move.l	d3,(a0)+
#ifdef COLDFIRE
	subq.l	#1,d2
	bpl.s	.loop22
#else
	ldbra	d2,.loop22
#endif
#ifdef COLDFIRE
	move.w	d5,d0
	ext.l	d0
	lea	(a3,d0.l),a3
	subq.l	#1,d1
	bpl.s	.loop11
#else
	add.w	d5,a3
	ldbra	d1,.loop11
#endif
	move.l	4(sp),a0
	move.w	vwk_text_effects(a0),d0
.no_underline:

	btst	#2,d0
	beq	.no_italic
	movem.l	(sp),d5/a0/a3/a5
	move.w	font_distance_top(a5),d1
#ifdef COLDFIRE
	move.w	font_distance_bottom(a5),d0
	ext.l	d0
	ext.l	d1
	add.l	d0,d1
	addq.l	#1,d1
	moveq	#0,d0
	move.w	d5,d0	
	mulu	d0,d1
	add.l	d1,a3
	lsr.l	#1,d0
	subq.l	#2,d0
	move.l	d5,d1
	swap	d1
	ext.l	d1
	subq.l	#1,d1
#else
	move.w	d5,d0
	add.w	font_distance_bottom(a5),d1
	addq.w	#1,d1
	mulu	d0,d1
	add.l	d1,a3
	lsr.w	#1,d0
	subq.w	#2,d0
	move.l	d5,d1
	swap	d1
	subq.w	#1,d1
#endif
	move.w	font_skewing(a5),d3
	moveq	#0,d4
.loop1b1:
	move.l	a3,a0
	move.w	d0,d2
#ifdef COLDFIRE
	ext.l	d2
	ext.l	d3
#endif
.loop2b2:
	move.l	-4(a0),d6
	lsr.l	d4,d6
	move.w	d6,-(a0)
#ifdef COLDFIRE
	subq.l	#1,d2
	bpl.s	.loop2b2
#else
	ldbra	d2,.loop2b2
#endif
	moveq	#0,d6
	move.w	-(a0),d6
	lsr.l	d4,d6
	move.w	d6,(a0)
#ifdef COLDFIRE
	move.w	d5,d6
	ext.l	d6
	sub.l	d6,a3
	move.l	d3,d6
	lsl.l	#1,d6
	moveq	#15,d0
	lsr.l	d0,d3
	or.l	d6,d3
	btst	#16,d6
	lbne	.skip3
	addq.l	#1,d4
.skip3:
	subq.l	#1,d1
	bpl.s	.loop1b1
#else
	sub.w	d5,a3
	rol.w	#1,d3
	lbcc	.skip3
	addq.w	#1,d4
.skip3:
	ldbra	d1,.loop1b1
#endif
	move.l	4(sp),a0
	move.w	vwk_text_effects(a0),d0
.no_italic:

	btst	#4,d0
	beq	.no_outline
	movem.l	(sp),d5/a0/a3/a5
	move.l	a3,a0
	move.l	a3,a1
	move.w	d5,a6
#ifdef COLDFIRE
	moveq	#0,d3
#endif
	move.w	d5,d3
	swap	d5
	move.w	d5,d7
	mulu	d3,d5
	add.l	d5,a1
	move.l	a1,8(sp)		// New bitmap address
#ifdef COLDFIRE
	lsr.l	#1,d3
#else
	lsr.w	#1,d3
#endif
	bsr	outline
	move.l	4(sp),a0
	move.w	vwk_text_effects(a0),d0
.no_outline:

	btst	#1,d0
	beq	.no_light
	movem.l	(sp),d5/a0/a3/a5
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	d5,d0
	lsr.l	#2,d0
	subq.l	#1,d0
	move.l	d5,d1
	swap	d1
	ext.l	d1
	subq.l	#1,d1
	ext.l	d5
	move.l	d7,-(sp)
#else	
	move.w	d5,d0
	lsr.w	#2,d0
	subq.w	#1,d0
	move.l	d5,d1
	swap	d1
	subq.w	#1,d1
#endif
	move.w	font_lightening(a5),d2
	move.w	d2,d3
	swap	d3
	move.w	d2,d3
.loop1c1:
	move.l	a3,a0
#ifdef COLDFIRE
	move.l	d0,d2
#else
	move.w	d0,d2
#endif
.loop2c2:
	and.l	d3,(a0)+
#ifdef COLDFIRE
	subq.l	#1,d2
	bpl.s	.loop2c2
#else
	ldbra	d2,.loop2c2
#endif
#ifdef COLDFIRE
	add.l	d5,a3
	move.l	d3,d7
	lsl.l	#1,d7
	moveq	#31,d2
	lsr.l	d2,d3
	or.l	d7,d3
	subq.l	#1,d1
	bpl.s	.loop1c1
	move.l	(sp)+,d7
#else
	add.w	d5,a3
	rol.l	#1,d3
	ldbra	d1,.loop1c1
#endif
.no_light:

#ifdef COLDFIRE
	movem.l	(sp),d5/a0/a3/a5
	lea	16(sp),sp
	movem.l	(sp),d1/d3
	lea	8(sp),sp
#else
	movem.l	(sp)+,d5/a0/a3/a5
	movem.l	(sp)+,d1/d3
#endif

	move.l	vwk_text_colour(a0),d0
	swap	d0
	move.l	d0,-(sp)
                                                    // Create pens
	sub.l	#20,sp		// Create source MFDB for rendering buffer
	move.l	a3,mfdb_address(sp)	// Start address of buffer
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	d5,d0
	lsr.l	#1,d0
	move.w	d0,mfdb_wdwidth(sp)	// Width in words
	lsl.l	#4,d0
#else
	move.w	d5,d0
	lsr.w	#1,d0
	move.w	d0,mfdb_wdwidth(sp)	// Width in words
	lsl.w	#4,d0
#endif
	move.w	d0,mfdb_width(sp)	// Width in pixels
	swap	d5
	move.w	d5,mfdb_height(sp)	// Height in pixels
#ifdef COLDFIRE
	moveq	#1,d4
	move.w	d4,mfdb_standard(sp)	// Standard format
	move.w	d4,mfdb_bitplanes(sp)	// Monochrome
#else	
	move.w	#1,mfdb_standard(sp)	// Standard format
	move.w	#1,mfdb_bitplanes(sp)	// Monochrome
#endif

	sub.l	#16,sp			// Create points
	clr.l	(sp)		// Source left, top
#ifdef COLDFIRE
	ext.l	d3
	subq.l	#1,d3
	move.w	d3,4(sp)		// Source right
	ext.l	d5
	subq.l	#1,d5	
#else
	subq.w	#1,d3
	move.w	d3,4(sp)		// Source right
	subq.w	#1,d5
#endif
	move.w	d5,6(sp)		// Source bottom

	move.l	vwk_text_current_font(a0),a5	// Font structure
	move.w	vwk_text_alignment_vertical(a0),d4
#ifdef COLDFIRE
	ext.l	d4
	add.l	d4,d4
	move.w	font_extra_distance(a5,d4.l),d4
	ext.l	d4
	move.w	d1,d0
	ext.l	d0
	add.l	d4,d0
	move.w	d0,d1
	move.l	d1,8(sp)		// Destination left,top
	ext.l	d0	
	add.l	d5,d0
	move.w	d0,d1
	move.w	d1,14(sp)		// Destination bottom
	swap	d1
	move.w	d1,d0
	ext.l	d0
	add.l	d3,d0
	move.w	d0,d1
#else
	add.w	d4,d4
	add.w	font_extra_distance(a5,d4.w),d1
	move.l	d1,8(sp)		// Destination left,top
	add.w	d5,d1
	move.w	d1,14(sp)		// Destination bottom
	swap	d1
	add.w	d3,d1
#endif
	move.w	d1,12(sp)		// Destination right

	sub.l	#18,sp			// Create parameters
	move.w	vwk_mode(a0),(sp)	// Mode
	lea	18(sp),a3
	move.l	a3,2(sp)		// Points
	lea	16(a3),a3
	move.l	a3,6(sp)		// Source MFDB
	clr.l	10(sp)		// Screen as destination
	lea	20(a3),a3
	move.l	a3,14(sp)		// Pens

	move.l	sp,a1
	jsr	lib_vrt_cpyfm

	add.l	#18+16+20+4,sp

	jsr	_free_block
	addq.l	#4,sp

#ifdef COLDFIRE
	movem.l	(sp),d3-d7/a3-a6
	lea	36(sp),sp
#else
	movem.l	(sp)+,d3-d7/a3-a6
#endif
	rts


.single_char:
	sub.l	#4,sp			// Create pens
	move.l	vwk_text_colour(a0),d5
	swap	d5
	move.l	d5,0(sp)

	sub.l	#20,sp			// Create source MFDB for font
	move.l	vwk_text_current_font(a0),a5	// Font structure
	move.l	font_data(a5),d5
	move.l	d5,mfdb_address(sp)	// Start address of font
#ifdef COLDFIRE
	moveq	#0,d5
	move.w	font_width(a5),d5
	lsr.l	#1,d5
	move.w	d5,mfdb_wdwidth(sp)	// Width in words
	lsl.l	#4,d5
#else
	move.w	font_width(a5),d5
	lsr.w	#1,d5
	move.w	d5,mfdb_wdwidth(sp)	// Width in words
	lsl.w	#4,d5
#endif
	move.w	d5,mfdb_width(sp)	// Width in pixels
	move.w	font_height(a5),mfdb_height(sp)	// Height in pixels
#ifdef COLDFIRE
	moveq	#0,d3
	move.w	d3,mfdb_standard(sp)	// Standard format
	move.w	d3,mfdb_bitplanes(sp)	// Monochrome
#else
	move.w	#1,mfdb_standard(sp)	// Standard format
	move.w	#1,mfdb_bitplanes(sp)	// Monochrome
#endif

	sub.l	#16,sp			// Create points
	clr.w	2(sp)		// Source top
	move.w	font_height(a5),d5
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif
	move.w	d5,6(sp)		// Source bottom

	move.l	d1,d3

	move.w	vwk_text_alignment_vertical(a0),d4
#ifdef COLDFIRE
	ext.l	d4
	add.l	d4,d4
	move.w	font_extra_distance(a5,d4.l),d4
	ext.l	d4
	move.l	d0,-(sp)
	move.w	d3,d0
	ext.l	d0
	add.l	d4,d0
	move.w	d0,d3	
	move.l	d3,8+4(sp)		// Destination left,top
	ext.l	d0
	add.l	d5,d0
	move.w	d0,d3
	move.w	d3,14+4(sp)		// Destination bottom
	swap	d3
	move.w	d3,d0
	ext.l	d0
	subq.l	#1,d0			// Previous character's right edge,
	move.w	d0,d3
	move.l	(sp)+,d0
#else
	add.w	d4,d4
	add.w	font_extra_distance(a5,d4.w),d3
	move.l	d3,8(sp)		// Destination left,top
	add.w	d5,d3
	move.w	d3,14(sp)		// Destination bottom
	swap	d3
	subq.w	#1,d3			// Previous character's right edge,
#endif
	move.w	d3,12(sp)		//   current width is added below

	sub.l	#18,sp			// Create parameters
	move.w	vwk_mode(a0),0(sp)	// Mode
	lea	18(sp),a3
	move.l	a3,2(sp)		// Points
	lea	16(a3),a3
	move.l	a3,6(sp)		// Source MFDB
	clr.l	10(sp)		// Screen as destination
	lea	20(a3),a3
	move.l	a3,14(sp)		// Pens

	move.l	a1,a3			// String
	move.w	d0,d3			// Length
#ifdef COLDFIRE
	ext.l	d3
#endif
	move.w	font_code_low(a5),d1	// First character

	move.l	font_table_character(a5),a5	// Character offset table

	move.l	a2,d0
	bne	.loopend_offset
	bra	.loopend

.loop_char:			// .loop:
	move.w	(a3)+,d4	// Get character
#ifdef COLDFIRE
	ext.l	d4
	ext.l	d1
	sub.l	d1,d4
	add.l	d4,d4
	move.w	0(a5,d4.l),d0
	move.w	d0,0+18(sp)	// Character source left coordinate
	move.w	2(a5,d4.l),d5
#else
	sub.w	d1,d4
	add.w	d4,d4
	move.w	0(a5,d4.w),d0
	move.w	d0,0+18(sp)	// Character source left coordinate
	move.w	2(a5,d4.w),d5
#endif
	move.w	d5,4+18(sp)	// Character source right coordinate
#ifdef COLDFIRE
	ext.l	d0
	sub.l	d0,d5		// Character width
	move.w	12+18(sp),d4
	ext.l	d4
	add.l	d5,d4
	move.w	d4,12+18(sp)	// Character destination right coordinate
#else
	sub.w	d0,d5		// Character width
	add.w	d5,12+18(sp)	// Character destination right coordinate
#endif
	
	move.l	sp,a1
	jsr	lib_vrt_cpyfm

#ifdef COLDFIRE
	move.w	8+18(sp),d4
	ext.l	d4
	ext.l	d5
	add.l	d5,d4
	move.w	d4,8+18(sp)	// Increase destination x coordinate
#else
	add.w	d5,8+18(sp)	// Increase destination x coordinate
#endif

.loopend:
#ifdef COLDFIRE
	subq.l	#1,d3
	bpl.s	.loop_char
#else
	dbra	d3,.loop_char
#endif

.default_text_end:
	add.l	#18+16+20+4,sp
#ifdef COLDFIRE
	movem.l	(sp),d3-d7/a3-a6
	lea	36(sp),sp
#else
	movem.l	(sp)+,d3-d7/a3-a6
#endif
	rts

.loop_offset:			// .loop:
	move.w	(a3)+,d4	// Get character
#ifdef COLDFIRE
	ext.l	d4
	ext.l	d1
	sub.l	d1,d4
	add.l	d4,d4
	move.w	0(a5,d4.l),d0
	move.w	d0,0+18(sp)	// Character source left coordinate
	move.w	2(a5,d4.l),d5
#else
	sub.w	d1,d4
	add.w	d4,d4
	move.w	0(a5,d4.w),d0
	move.w	d0,0+18(sp)	// Character source left coordinate
	move.w	2(a5,d4.w),d5
#endif
	move.w	d5,4+18(sp)	// Character source right coordinate
#ifdef COLDFIRE
	ext.l	d0
	sub.l	d0,d5		// Character width
	move.w	8+18(sp),d4
	ext.l	d4
	add.l	d4,d5
	subq.l	#1,d5
#else
	sub.w	d0,d5		// Character width
	add.w	8+18(sp),d5
	subq.w	#1,d5
#endif
	move.w	d5,12+18(sp)	// Character destination right coordinate
	
	move.l	sp,a1
	move.l	a2,-(sp)
	jsr	lib_vrt_cpyfm
	move.l	(sp)+,a2

.loopend_offset:
	move.w	(a2)+,d4

#ifdef COLDFIRE
	move.w	8+18(sp),d0
	ext.l	d0
	add.l	d4,d0
	move.w	d0,8+18(sp)	// Increase destination x/y coordinates
	move.w	(a2)+,d4
	move.w	10+18(sp),d0
	ext.l	d0
	add.l	d4,d0
	move.w	d0,10+18(sp)
	
	subq.l	#1,d3
	bpl.s	.loop_offset
#else
	add.w	d4,8+18(sp)	// Increase destination x/y coordinates
	move.w	(a2)+,d4
	add.w	d4,10+18(sp)
	
	dbra	d3,.loop_offset
#endif
	bra	.default_text_end


/* In:	a0	area1
*	a1	area2
*	a6	wrap
*	d4	fattening
*	d3	words
*	d7	lines
*/
bold:
	move.w	d3,d0
#ifdef COLDFIRE
	ext.l	d0
	ext.l	d4
	ext.l	d3
	ext.l	d7
	add.l	d0,d0
	sub.l	d0,a6
	subq.l	#1,d4
	subq.l	#1,d3
	subq.l	#1,d7
#else
	add.w	d0,d0
	sub.w	d0,a6
	subq.w	#1,d4
	subq.w	#1,d3
	subq.w	#1,d7
#endif
.lines_b:
	.ifne 1
	moveq	 #0,d1
	.endc
#ifdef COLDFIRE
	move.l	d3,d6
	move.l	d7,-(sp)
#else
	move.w	d3,d6
#endif
.words_b:
	.ifne 1
	move.w	(a0)+,d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0		// Remember in top word
	.else
	move.l	(a0)+,d1	// Doesn't work in place
	addq.l	#2,a0  
	.endc
#ifdef COLDFIRE
	move.l	d4,d5
#else
	move.w	d4,d5
#endif
.shifts_b:
	lsr.l	#1,d1
#ifdef COLDFIRE
	move.w	d0,d7
	or.l	d1,d7
	move.w	d7,d0
	subq.l	#1,d5
	bpl.s	.shifts_b
#else
	or.w	d1,d0
	dbra	d5,.shifts_b
#endif
	move.w	d0,(a1)+
	.ifne 1
	move.l	d0,d1		// Restore top word
	.endc
#ifdef COLDFIRE
	subq.l	#1,d6
	bpl.s	.words_b
#else
	dbra	d6,.words_b
#endif
	add.l	a6,a0
	add.l	a6,a1
#ifdef COLDFIRE
	move.l	(sp)+,d7
	subq.l	#1,d7
	bpl.s	.lines_b
#else
	dbra	d7,.lines_b
#endif
	rts


/* In:	a0	area1
*	a1	area2
*	a6	wrap
*	d3	words
*	d7	lines
*/
outline:
/* Do <-x-> expansion rather than bold(2) (x->->). Easier EOR stage. */
	move.l	a6,a3
#ifdef COLDFIRE
	ext.l	d3
	ext.l	d7
	sub.l	d3,a3
	sub.l	d3,a3
	subq.l	#1,d7
	move.l	d7,-(sp)
	subq.l	#1,d3
#else
	sub.w	d3,a3
	sub.w	d3,a3
	subq.w	#1,d7
	move.w	d7,d0
	swap	d7
	move.w	d0,d7
	subq.w	#1,d3
#endif
	move.l	a0,a4 // area1
	move.l	a1,a5 // area2
.lines_o1:
#ifdef COLDFIRE
	move.l	d3,d6
	move.l	d7,-(sp)
#else
	move.w	d3,d6
#endif
	moveq	#0,d1
	move.w	(a0)+,d1
	move.w	d1,d2
.words_o1:
	move.w	d1,d0
	swap	d2
	move.w	(a0)+,d2
	lsr.l	#1,d1
#ifdef COLDFIRE
	move.w	d0,d7
	or.l	d1,d7
	move.w	d7,d0
#else
	or.w	d1,d0
#endif
	move.l	d2,d1
	add.l	d1,d1
	swap	d1
#ifdef COLDFIRE
	move.w	d0,d7
	or.l	d1,d7
	move.w	d7,d0
#else
	or.w	d1,d0
#endif
	move.l	d2,d1
	move.w	d0,(a1)+
#ifdef COLDFIRE
	subq.l	#1,d6
	bpl.s	.words_o1
#else
	dbra	d6,.words_o1
#endif
	add.l	a3,a0
	subq.l	#2,a0
	add.l	a3,a1
#ifdef COLDFIRE
	move.l	(sp)+,d7
	subq.l	#1,d7
	bpl.s	.lines_o1
#else
	dbra	d7,.lines_o1
#endif

/* Optimization to think about:  combine EOR into vertical bold. */

#ifdef COLDFIRE
	move.l	(sp)+,d7
	addq.l	#2,d3
	and.l	#0xfffe,d3
	lsr.l	#1,d3
	subq.l	#1,d3
#else
	swap	d7
	addq.w	#2,d3
	and.w	#0xfffe,d3
	lsr.w	#1,d3
	subq.w	#1,d3
#endif
.longs_o2:
	move.l	a4,a1 // area1
	move.l	a5,a0 // area2
#ifdef COLDFIRE
	move.l	d7,d6
#else
	move.w	d7,d6
#endif
	moveq	#0,d0
	move.l	(a0),d1
	add.l	a6,a0
.lines_o2:
	move.l	(a0),d2
	or.l	d1,d0
	or.l	d2,d0
	move.l	(a1),d5
	eor.l	d5,d0
	move.l	d0,(a0)
	move.l	d1,d0
	move.l	d2,d1	
	add.l	a6,a0
	add.l	a6,a1
#ifdef COLDFIRE
	subq.l	#1,d6
	bpl.s	.lines_o2
#else
	dbra	d6,.lines_o2
#endif
	or.l	d1,d0
	move.l	d0,(a0)
	addq.l	#4,a4
	addq.l	#4,a5
#ifdef COLDFIRE
	subq.l	#1,d3
	bpl.s	.longs_o2
#else
	dbra	d3,.longs_o2
#endif
	rts

#if 0

dscale:
  .ifne 0
	move.w	(a0)+,d0
	moveq	#15,d5
	moveq	#15,d7
	add.w	d0,d0
	scs	d6
.put_d:
	add.w	d3,d3
	sub.b	d6,d3
	subq.w	#1,d7
	bpl	.no_write_d
	move.w	d3,(a1)+
	moveq	#15,d7
.no_write_d:
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif
	bpl	.no_fetch_d
#ifdef COLDFIRE
	ext.l	d4
	subq.l	#1,d4
#else
	subq.w	#1,d4
#endif
	bmi	.finished_d
	move.w	(a0)+,d0
	moveq	 #15,d5
.no_fetch_d:
	add.w	d0,d0
	scs	d6
	add.w	d1,d2
	bvc	.no_write_d
	bra	.put_d	
  .else
	moveq	#15,d7
.not_finished_d:
	move.w	(a0)+,d0
	moveq	 #15,d5
.no_fetch_d:
	add.w	d1,d2
	bvc	.no_write_d
.put_d:
	add.w	d0,d0
	addx.w	d3,d3
#ifdef COLDFIRE
	subq.l	#1,d7
	bpl.s	.no_write_d1
#else
	dbra	d7,.no_write_d1
#endif
	move.w	d3,(a1)+
	moveq	#15,d7
.no_write_d1:
#ifdef COLDFIRE
	subq.l	#1,d5
	bpl.s	.no_fetch_d
	subq.l	#1,d4
	bpl.s	.not_finished_d
#else
	dbra	d5,.no_fetch_d
	dbra	d4,.not_finished_d
#endif
	bra	.finished_d
.no_write_d:
	add.w	d0,d0
#ifdef COLDFIRE
	subq.l	#1,d5
	bpl.s	.no_fetch_d
	subq.l	#1,d4
	bpl.s	.not_finished_d
#else
	dbra	d5,.no_fetch_d
	dbra	d4,.not_finished_d
#endif
  .endc
.finished_d:
	cmp.w	#15,d7
	bne	.done_d
	lsl.w	d7,d3
	move.w	d3,(a1)+
.done_d:
	rts


uscale:
  .ifne 0
	move.w	(a0)+,d0
	moveq	#15,d5
	moveq	#15,d7
	add.w	d0,d0
	scs	d6
.put_u:
	add.w	d3,d3
	sub.b	d6,d3
	subq.w	#1,d7
	bpl	.no_write_u
	move.w	d3,(a1)+
	moveq	#15,d7
.no_write_u:
	add.w	d1,d2
	bvc	.put_u
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif
	bpl	.no_fetch_u
#ifdef COLDFIRE
	ext.l	d4
	subq.l	#1,d4
#else
	subq.w	#1,d4
#endif
	bmi	.finished_u
	move.w	(a0)+,d0
	moveq	 #15,d5
.no_fetch_u:
	add.w	d0,d0
	scs	d6
	bra	.put_u
  .else
	moveq	#15,d7
.not_finished_u:
	move.w	(a0)+,d0
	moveq	#15,d5
.no_fetch_u:
	add.w	d0,d0
	scs	d6
.put_u:
	add.w	d3,d3
	sub.b	d6,d3
#ifdef COLDFIRE
	subq.l	#1,d7
	bpl.s	.no_write_u
#else
	dbra	d7,.no_write_u
#endif
	move.w	d3,(a1)+
	moveq	#15,d7
.no_write_u:
	add.w	d1,d2
	bvc	.put_u
#ifdef COLDFIRE
	subq.l	#1,d5
	bpl.s	.no_fetch_u
	subq.l	#1,d4
	bpl.s	.not_finished_u
#else
	dbra	d5,.no_fetch_u
	dbra	d4,.not_finished_u
#endif
	bra	.finished_u
  .endc
.finished_u:
	cmp.w	#15,d7
	bne	.done_u
	lsl.w	d7,d3
	move.w	d3,(a1)+
.done_u:
	rts

#endif
