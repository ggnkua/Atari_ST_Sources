/*****
* Single plane fill
*
* $Id: 1_fill.s,v 1.3 2005/04/23 18:57:52 johan Exp $
*
* Copyright 1998-2002, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
*****/

#define both		0	// Write in both FastRAM and on screen
#define longs	1
#define get		1
#define mul		1	// Multiply rather than use table
#define shift	1

#include "pixelmac.inc"
#include "vdi.inc"

	.xdef		fill_area_1,_fill_area_1

	.ifeq		shift
	.xref		dot,lline,rline
	.endc
	.ifeq		mul
	.xref		row
	.endc

	.xref		get_colour,get_colour_masks


/* In:	a1	VDI struct (odd address marks table operation)
*	d0	height and width to fill (high and low word)
*	d1	x or table address
*	d2	y or table length (high) and type (0 - y/x1/x2 spans)
*	d3	pattern address
*	d4	colour
*/
_fill_area_1:
fill_area_1:
	move.l		a1,d5
	bclr		#0,d5
	bne		.unknown_fill
	move.l		d5,a1

	tst.w		d0			// First check that there
	beq		.error			//  really is an area
	sub.l		#0x10000,d0		// Height only used via dbra
	bmi		.error

	exg		d4,d0
	bsr		get_colour
	bsr		get_colour_masks
	move.l		d0,-(a7)		// Pointer to background bits
	move.l		d4,d0

	move.w		vwk_mode(a1),d5
	add.w		d5,d5
	add.w		d5,d5
	add.w		d5,d5
	lea		mode_table,a0
	pea		(a0,d5.w)		// Pointer to address of correct output routine on stack
	
	move.w		d2,d5
	and.w		#0x000f,d5
	add.w		d5,d5			// d5 - index for first pattern word
	swap		d5

	move.l		vwk_real_address(a1),a1

	.ifne	mul
	move.l		wk_screen_mfdb_address(a1),a0
	.endc

	.ifne	mul
	move.w		wk_screen_wrap(a1),d5	// d5 - index, wrap
	mulu.w		d5,d2
	add.l		d2,a0
	.endc
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d4.w*4),a0
	.endc

	exg		a0,a1			// Workstation used below

	.ifne	both
	move.l		wk_screen_shadow_address(a0),d7
	beq		.no_shadow
	move.l		d7,a4
	add.l		d2,a4
	.endc

	move.w		d1,d4
	and.w		#0x0f,d1			// d1 - first bit number in dest MFDB

	lsr.w		#4,d4
	lsl.w		#1,d4
	add.w		d4,a1			// a1 - start address in dest MFDB
	.ifne	both
	add.w		d4,a4			// a4 - start address in shadow
	.endc					// d4 scratch

	move.l		d3,a0

	add.w		d1,d0
	subq.w		#1,d0
	move.w		d0,d2
	move.w		d0,d4

	lsr.w		#4,d4
	lsl.w		#1,d4
	sub.w		d4,d5
	swap		d5			// d5 - wrap-blit, index

	and.w		#0x0f,d2
	addq.w		#1,d2			// d2 - final bit number in dest MFDB

	move.l		a0,d7
	move.l		(a7)+,a0
	move.l		(a0),-(a7)
	move.l		d7,a0
	rts					// Call correct routine

.error:
	moveq		#1,d0			// Return as completed
	rts

.unknown_fill:
	moveq		#-1,d0
	rts


.no_shadow:
	move.w		d1,d4
	and.w		#0x0f,d1			// d1 - first bit number in dest MFDB

	lsr.w		#4,d4
	lsl.w		#1,d4
	add.w		d4,a1			// a1 - start address in dest MFDB
						// d4 scratch
	move.l		d3,a0

	add.w		d1,d0
	subq.w		#1,d0
	move.w		d0,d2
	move.w		d0,d4

	lsr.w		#4,d4
	lsl.w		#1,d4
	sub.w		d4,d5
	swap		d5			// d5 - wrap-blit, index

	and.w		#0x0f,d2
	addq.w		#1,d2			// d2 - final bit number in dest MFDB

	move.l		a0,d7
	move.l		(a7)+,a0
	move.l		4(a0),-(a7)
	move.l		d7,a0
	rts					// Call correct routine


/**********
*
* Import the actual drawing routines
*
**********/

// Standard mode
#undef shadow
#define shadow 0
#if both
#define oldboth 1
#else
#define oldboth 0
#endif
#undef both
#define both	0
#include "1_fill.inc"

// Shadow mode, if asked for
#undef both
#if oldboth
#define both 1
#else
#define both 0
#endif
	.ifne	both
#undef shadow
#define shadow 1
#include "1_fill.inc"
	.endc

	.data

mode_table:
	.ifne	both
	dc.l		0,0,shadow_replace,mfdb_replace,shadow_transparent,mfdb_transparent
	dc.l		shadow_xor,mfdb_xor,shadow_revtransp,mfdb_revtransp
	.endc
	.ifeq	both
	dc.l		0,0,mfdb_replace,mfdb_replace,mfdb_transparent,mfdb_transparent
	dc.l		mfdb_xor,mfdb_xor,mfdb_revtransp,mfdb_revtransp
	.endc

	.end
