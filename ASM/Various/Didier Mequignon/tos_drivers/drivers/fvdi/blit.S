/****
* fVDI blit type functions
*
* $Id: blit.s,v 1.11 2005/07/26 21:39:06 johan Exp $
*
* Copyright 1997-2002, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
****/

#define lookup32	0		// Palette lookup for 32 bit vr_trn_fm?

#include "config.h"
#include "vdi.inc"
#include "macros.inc"

	.xref	clip_rect
	.xref	expand_area
	.xref	setup_plot
	
	.xdef	_default_fill

	.xdef	lib_vr_trn_fm

	.xdef	_lib_vr_trn_fm
	.xdef	_default_expand,_default_blit

	.data
	
//	.chip 68060

/* _default_fill - Line by line (or pixel by pixel) fill routine
* In:	a0	VDI struct (odd address marks table operation)
*	d0	Colours
*	d1	x1 destination or table address
*	d2	y1   - " -     or table length (high) and type (0 - y/x1/x2 spans)
*	d3-d4.w	x2,y2 destination
*	d5	Pointer to pattern
*	d6	Mode
*	d7	Interior/style
* Call:	a0	VDI struct, 0 (destination MFDB)
*	d0	Colours
*	d1-d2.w	Start coordinates
*	d3-d4.w	End coordinates
*	d5	Pattern
*/
_default_fill:
#ifdef COLDFIRE
	lea	-40(a7),a7
	movem.l	d1-d7/a0-a2,(a7)
#else
	movem.l	d1-d7/a0-a2,-(a7)
#endif
#ifdef COLDFIRE
	move.l	a0,d7
	and.l	#1,d7
	sub.l	d7,a0
#else
	move.w	a0,d7
	and.w	#1,d7
	sub.w	d7,a0
#endif

	move.l	d5,a2

#ifdef COLDFIRE
	ext.l	d6
	cmp.l	#1,d6
#else
	cmp.w	#1,d6			// Not replace?
#endif
	bne	.pattern

	move.l	a2,a1
	moveq	#8-1,d5
	move.l	d6,-(a7)
.check_pattern:
	move.l	(a1)+,d6		// All ones?
	addq.l	#1,d6
#ifdef COLDFIRE
	bne.s	.end_check_pattern
	subq.l	#1,d5
	bpl.s	.check_pattern
	bra	.no_pattern
.end_check_pattern:
#else
	dbne	d5,.check_pattern
	beq	.no_pattern
#endif
	move.l	(a7)+,d6
	bra	.pattern
.no_pattern:
	move.l	(a7)+,d6
	moveq	#-1,d5

	move.l	vwk_real_address(a0),a1
	move.l	wk_r_line(a1),a1
	cmp.l	#_default_line,a1	// No real acceleration?
	beq	.pattern

#ifdef COLDFIRE
	tst.l	d7
#else
	tst.w	d7
#endif
	bne	.table_lfill

#ifdef COLDFIRE
	ext.l	d2
	ext.l	d4
	move.l	d4,d7
#else
	move.w	d4,d7
#endif
	moveq	#0,d6
	move.w	vwk_mode(a0),d6
.loopy_sl:
#ifdef COLDFIRE
	move.l	d2,d4
#else
	move.w	d2,d4
#endif
	jsr	(a1)
#ifdef COLDFIRE
	addq.l	#1,d2
	cmp.l	d7,d2
#else
	addq.w	#1,d2
	cmp.w	d7,d2
#endif
	ble	.loopy_sl

.end_default_fill:
#ifdef COLDFIRE
	movem.l	(a7),d1-d7/a0-a2
	lea	40(a7),a7
#else
	movem.l	(a7)+,d1-d7/a0-a2
#endif
	rts

.table_lfill:
	tst.w	d2
	bne	.end_default_fill	// Only y/x1/x2 spans available so far
	move.l	d2,d6
	swap	d6
#ifdef COLDFIRE
	ext.l	d6
	subq.l	#1,d6	
#else
	subq.w	#1,d6
#endif
	blt	.end_default_fill
	move.l	d1,a2
.tlfill_loop:
	moveq	#0,d2
	move.w	(a2)+,d2
	move.w	d2,d4
	moveq	#0,d1
	move.w	(a2)+,d1
	move.w	(a2)+,d3
	jsr	(a1)
#ifdef COLDFIRE
	subq.l	#1,d6
	bpl.s	.tlfill_loop
#else
	dbra	d6,.tlfill_loop
#endif
	bra	.end_default_fill

/* Call:	a0	VDI struct, 0 (destination MFDB)
*	d0	Colour values
*	d1-d2.w	Coordinates
*	d6	Mode
*	a3-a4	Set/get pixel
*/
.pattern:
#ifdef COLDFIRE
	move.l	a3,-(a7)
	move.l	a4,-(a7)
	ext.l	d3
	ext.l	d4
#else
	movem.l	a3-a4,-(a7)
#endif

	move.l	vwk_real_address(a0),a1
	move.l	wk_r_get_colour(a1),a1	// Index to real colour
	jsr	(a1)

	move.w	d6,-(a7)
	bsr	setup_plot
	addq.l	#2,a7

	clr.l	-(a7)			// No MFDB => draw on screen
	move.l	a0,-(a7)
	move.l	a7,a0			// a0 no longer -> VDI struct!

#ifdef COLDFIRE
	tst.l	d7
#else
	tst.w	d7
#endif
	bne	.table_pfill

#ifdef COLDFIRE
	ext.l	d1
	ext.l	d2
	move.l	d1,d6
#else
	move.w	d1,d6
#endif
.loopy_pp:
	move.w	d6,d1			// x
	move.w	d2,d5
#ifdef COLDFIRE
	move.l	d0,-(a7)
	and.l	#0x000f,d5
	add.l	d5,d5
	move.w	0(a2,d5.l),d5
	moveq	#15,D0
	and.l	d1,d0
	asl.l	d0,d5
	move.l	d5,d0
	clr.w	d0
	swap	d0
	or.l	d0,d5
	move.l	(a7)+,d0
.loopx_pp:
	move.l	d0,-(a7)
	move.l	d2,-(a7)
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
	and.w	#0x000f,d5
	add.w	d5,d5
	move.w	0(a2,d5.w),d5
	rol.w	d1,d5
.loopx_pp:
	rol.w	#1,d5
#endif
	jsr	(a1)
#ifdef COLDFIRE
	addq.l	#1,d1
	cmp.l	d3,d1
	ble	.loopx_pp
	addq.l	#1,d2
	cmp.l	d4,d2
#else
	addq.w	#1,d1
	cmp.w	d3,d1
	ble	.loopx_pp
	addq.w	#1,d2
	cmp.w	d4,d2
#endif
	ble	.loopy_pp
.end_pfill:
	move.l	(a7),a0
	addq.l	#8,a7
#ifdef COLDFIRE
	move.l	(a7)+,a4
	move.l	(a7)+,a3
#else
	movem.l	(a7)+,a3-a4
#endif
	bra	.end_default_fill

.table_pfill:
	tst.w	d2
	bne	.end_pfill		// Only y/x1/x2 spans available so far
	move.l	d2,d6
	swap	d6
#ifdef COLDFIRE
	ext.l	d6
	subq.l	#1,d6	
#else
	subq.w	#1,d6
#endif
	blt	.end_pfill

	move.l	a5,-(a7)
	move.l	d1,a5
.tploopy_pp:
	moveq	#0,d2
	move.w	(a5)+,d2
	moveq	#0,d1
	move.w	(a5)+,d1
	move.w	(a5)+,d3

	move.w	d2,d5
#ifdef COLDFIRE
	move.l	d0,-(a7)
	and.l	#0x000f,d5
	add.l	d5,d5
	move.w	0(a2,d5.l),d5
	moveq	#15,D0
	and.l	d1,d0
	asl.l	d0,d5
	move.l	d5,d0
	clr.w	d0
	swap	d0
	or.l	d0,d5
	move.l	(a7)+,d0
.tploopx_pp:
	move.l	d0,-(a7)
	move.l	d2,-(a7)
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
	and.w	#0x000f,d5
	add.w	d5,d5
	move.w	0(a2,d5.w),d5
	rol.w	d1,d5
.tploopx_pp:
	rol.w	#1,d5
#endif
	jsr	(a1)
#ifdef COLDFIRE
	addq.l	#1,d1
	cmp.l	d3,d1
	ble	.tploopx_pp
	subq.l	#1,d6
	bpl	.tploopy_pp
#else
	addq.w	#1,d1
	cmp.w	d3,d1
	ble	.tploopx_pp
	dbra	d6,.tploopy_pp
#endif
	move.l	(a7)+,a5
	bra	.end_pfill

#if 0
/* lib_vrt_cpyfm - Standard Library function
* Todo: ?
*	Clipping should probably not be done for non-screen destinations
* In:   a1      Parameters (mode, points, source, destination, pens)
*       a0      VDI struct
*/
_lib_vrt_cpyfm:
lib_vrt_cpyfm:
	move.l	14(a1),a2
	move.l	(a2),d0		// Background colour (top word)
	swap	d0		// Foreground colour (bottom word)

	move.l	vwk_real_address(a0),a2
	cmp.w	wk_screen_palette_size(a2),d0
	blo	.okf
	move.w	#BLACK,d0
.okf:
	swap	d0
	cmp.w	wk_screen_palette_size(a2),d0
	blo	.okb
	move.w	#WHITE,d0
.okb:
	swap	d0
	uses_d1
	movem.l	d2-d4/a3-a5,-(a7)

	sub.l	#16,a7		// VDI struct, destination MFDB, VDI struct, source MFDB
	move.l	a0,(a7)
	move.l	a0,8(a7)

	move.l	2(a1),a2	// Get rectangle coordinates
	movem.w	8(a2),d1-d4

	// This should not be done if bitmap scaling is possible!
	move.w	d1,d3		// Do not use lower right destination coordinates at all
	move.w	d2,d4
	sub.w	0(a2),d3
	add.w	4(a2),d3
	sub.w	2(a2),d4
	add.w	6(a2),d4

	bsr	clip_rect	// Clipping necessary?
	blt	.end_vrt_cpyfm	// .end

	movem.w	d1-d4,-(a7)
	sub.w	8(a2),d1	// Calculate clipped source coordinates
	sub.w	10(a2),d2
	add.w	0(a2),d1
	add.w	2(a2),d2

	move.l	10(a1),a2	// a2 - destination MFDB
	move.l	a2,8+4(a7)

	move.l	6(a1),a2	// a2 - source MFDB
	move.l	a2,8+12(a7)

	move.l	vwk_real_address(a0),a3
	move.l	wk_r_expand(a3),d3

	movem.l	d5-d7,-(a7)
	move.w	0(a1),d7	// Mode
	move.l	d3,a1
	movem.w	12(a7),d3-d6	// Destination coordinates
	lea	12+8(a7),a0	// a0 no longer -> VDI struct!
	jsr	(a1)
	move.l	(a0),a0
	movem.l	(a7)+,d5-d7
	addq.l	#8,a7

.end_vrt_cpyfm:			// .end:
	add.l	#16,a7
	movem.l	(a7)+,d2-d4/a3-a5
	used_d1
	moveq	#1,d0		// Successful
	rts

#endif

/* lib_vr_trn_fm - Standard Library function
* Todo: Should use C2P from MGIF instead of the current crap!
* In:   a1      Parameters   lib_vr_trn_fm(source, dest)
*       a0      VDI struct
*/
_lib_vr_trn_fm:
lib_vr_trn_fm:
	uses_d1
#ifdef COLDFIRE
	lea	-40(a7),a7
	movem.l	d2-d7/a3-a6,(a7)
#else
	movem.l	d2-d7/a3-a6,-(a7)
#endif
	move.l	(a1)+,a2
	move.l	(a1),a1
#ifdef COLDFIRE
	move.l	a1,d1
	move.l	a2,a1
	move.l	d1,a2
#else
	exg	a1,a2		// a1 - source, a2 - dest
#endif

	move.l	mfdb_address(a1),a3
	move.l	mfdb_address(a2),a4
	move.w	mfdb_height(a1),d0
	move.w	mfdb_wdwidth(a1),d1
	move.w	mfdb_bitplanes(a1),d2

	cmp.l	a3,a4
	beq	in_place

	tst.w	mfdb_standard(a1)
	beq	to_standard

/* Reorganize standard bitplanes into device specific ones.
* Does not work in place.
* In:	d0.w	mfdb_height
*	d1.w	mfdb_wdwidth (pixels / 16)
*	d2.w	bitplanes
*	a3	mfdb_address source
*	a4	mfdb_address destination
*/
	move.w	d0,d3
	mulu	d1,d3
	add.l	d3,d3			// d3 = pix/16 * height * 2 = words/plane

	move.l	a3,a5

	move.w	d0,d7
#ifdef COLDFIRE
	ext.l	d7
	subq.l	#1,d7
#else
	subq.w	#1,d7
#endif

.loop1_1:
	move.w	d1,d6
#ifdef COLDFIRE
	ext.l	d6
	subq.l	#1,d6
#else
	subq.w	#1,d6
#endif

.loop2_2:
	move.w	d2,d5
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif

.loop3_3:
	move.w	(a3),(a4)+
	add.l	d3,a3
#ifdef COLDFIRE
	subq.l	#1,d5
	bpl.s	.loop3_3
#else
	ldbra	d5,.loop3_3
#endif
	addq.l	#2,a5
	move.l	a5,a3
#ifdef COLDFIRE
	subq.l	#1,d6
	bpl.s	.loop2_2
	subq.l	#1,d7
	bpl.s	.loop1_1
#else
	ldbra	d6,.loop2_2
	ldbra	d7,.loop1_1
#endif
	bra	finish_up


to_standard:
	move.l	vwk_real_address(a0),a5
	move.l	wk_driver(a5),a5
	move.l	driver_device(a5),a5
	move.w	dev_format(a5),d6
#ifdef COLDFIRE
	and.l	#2,d6
#else
	and.w	#2,d6
#endif
	beq	not_chunky_ts

	move.w	d0,d7
	mulu	d1,d7
	add.l	d7,d7			// d7 = pix/16 * height * 2 = words/plane
	moveq	#2,d6

#ifdef COLDFIRE
	ext.l	d2
	cmp.l	#16,d2
#else
	cmp.w	#16,d2
#endif
	bne	.not_16bit_ts
	bsr	to_standard_16
	bra	end_vr_trn_fm

.not_16bit_ts:
#ifdef COLDFIRE
	cmp.l	#8,d2
#else
	cmp.w	#8,d2
#endif
	bne	.not_8bit_ts
	bsr	to_standard_8
	bra	end_vr_trn_fm

.not_8bit_ts:
#ifdef COLDFIRE
	cmp.l	#32,d2
#else
	cmp.w	#32,d2
#endif
	bne	not_32bit_ts
	bsr	to_standard_32
	bra	end_vr_trn_fm


/* Transform device specific to standard format.
* Works in place due to source copying.
* In:	d0.w	mfdb_height
*	d1.w	mfdb_wdwidth (pixels / 16)
*	d6.w	group result step (2 or 16/32/64)
*	d7.l	single result step (bytes per plane or 2)
*	a3	mfdb_address source
*	a4	mfdb_address destination
*/
to_standard_8:
	lea	-16(sp),sp			// This is specialized for 8 bit!
	move.l	a7,a6			// Doesn't seem to work correctly (Jinnee)
	move.l	a4,a5

	move.w	d6,d1
#ifdef COLDFIRE
	ext.l	d1
	ext.l	d0
	subq.l	#1,d0
#else
	subq.w	#1,d0
#endif

.loop0b_0:
#ifdef COLDFIRE
	move.l	d0,-(sp)
	moveq	#0,d0
	move.w	mfdb_wdwidth(a1),d0
	subq.l	#1,d0			// d1 = width - 1
#else
	swap	d0
	move.w	mfdb_wdwidth(a1),d0
	subq.w	#1,d0
#endif

.loop1b_1:
#ifdef COLDFIRE
	movem.l	(a3),d2-d5
	lea	16(a3),a3
#else
	movem.l	(a3)+,d2-d5
#endif
	movem.l	d2-d5,(a6)
	moveq	#7,d3		// Was 15

.loop2b_2:
	moveq	#15,d4		// Was 14

.loop3b_3:
	move.b	0(a6,d4),d5	// Was .w
#ifdef COLDFIRE
	asl.l	#8,D5
	swap	d5
	swap	d6
	add.l	d5,d5
	addx.l	d6,d6
	swap	d5
	swap	d6
	lsr.l	#8,d5
#else	
	add.b	d5,d5		// Was .w
	addx.w	d6,d6		// Was .b
#endif
	move.b	d5,0(a6,d4)	// Was .w
	subq.l	#1,d4		// Was 2
	lbpl	.loop3b_3
	move.w	d6,(a4)		// Was .b
	add.l	d7,a4

#ifdef COLDFIRE
	subq.l 	#1,d3
	bpl.s	.loop2b_2
	add.l	d1,a5
	move.l	a5,a4
	subq.l	#1,d0
	bpl.s	.loop1b_1
	move.l	(sp)+,d0
	subq.l	#1,d0
	bpl.s	.loop0b_0
#else
	ldbra	d3,.loop2b_2
	add.w	d1,a5
	move.l	a5,a4
	ldbra	d0,.loop1b_1
	swap	d0
	ldbra	d0,.loop0b_0
#endif

	lea	16(sp),sp
	rts


to_standard_16:
	lea	-32(sp),sp			// This is specialized for 16 bit!
	move.l	a7,a6
	move.l	a4,a5

	move.w	d6,d1
#ifdef COLDFIRE
	ext.l	d1
	ext.l	d0
	subq.l	#1,d0
#else
	subq.w	#1,d0			// d0 = height - 1
#endif

.loop_0_0:
#ifdef COLDFIRE
	move.l	d0,-(sp)
	moveq	#0,d0
	move.w	mfdb_wdwidth(a1),d0
	subq.l	#1,d0			// d1 = width - 1
#else
	swap	d0
	move.w	mfdb_wdwidth(a1),d0
	subq.w	#1,d0			// d1 = width - 1
#endif

.loop_1_1:
#ifdef COLDFIRE
	movem.l	(a3),d2-d5		// Copy 16 words due to bad dechunky routine
	lea	16(a3),a3
	movem.l	d2-d5,(a6)
	movem.l	(a3),d2-d5
	lea	16(a3),a3
	movem.l	d2-d5,16(a6)
#else
	movem.l	(a3)+,d2-d5		// Copy 16 words due to bad dechunky routine
	movem.l	d2-d5,(a6)
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,16(a6)
#endif
	moveq	#15,d3			// d3 = bitplanes - 1 

.loop_2_2:
	moveq	#30,d4			// d4 = last word index

.loop_3_3:
	move.w	0(a6,d4),d5
#ifdef COLDFIRE
	swap	d5
	add.l	d5,d5
	move.w	d6,d5
	addx.l	d6,d6
	swap	d6
	move.w	d5,d6
	swap	d5
	lsr.l	#1,d6
#else
	add.w	d5,d5
	roxr.w	#1,d6		// This _is_ the right one!
#endif
	move.w	d5,0(a6,d4)
	subq.l	#2,d4
	lbpl	.loop_3_3
	move.w	d6,(a4)
	add.l	d7,a4

#ifdef COLDFIRE
	subq.l 	#1,d3
	bpl.s	.loop_2_2
	add.l	d1,a5
	move.l	a5,a4
	subq.l	#1,d0
	bpl.s	.loop_1_1
	move.l	(sp)+,d0
	subq.l	#1,d0
	bpl.s	.loop_0_0
#else
	ldbra	d3,.loop_2_2
	add.w	d1,a5
	move.l	a5,a4
	ldbra	d0,.loop_1_1
	swap	d0
	ldbra	d0,.loop_0_0
#endif
	lea	32(sp),sp
	rts


to_standard_32:
	lea	-64(sp),sp			// This is specialized for 32 bit!
	move.l	a7,a6			// Doesn't seem to work correctly (Jinnee)
	move.l	a4,a5

	move.w	d6,d1
#ifdef COLDFIRE
	ext.l	d1
	ext.l	d0
	subq.l	#1,d0
#else
	subq.w	#1,d0			// d0 = height - 1
#endif

.loop0c_0:
#ifdef COLDFIRE
	move.l	d0,-(sp)
	moveq	#0,d0
	move.w	mfdb_wdwidth(a1),d0
	subq.l	#1,d0			// d1 = width - 1
#else
	swap	d0
	move.w	mfdb_wdwidth(a1),d0
	subq.w	#1,d0
#endif

.loop1c_1:
#ifdef COLDFIRE
	movem.l	(a3),d2-d5
	lea	16(a3),a3
	movem.l	d2-d5,(a6)
	movem.l	(a3),d2-d5
	lea	16(a3),a3
	movem.l	d2-d5,16(a6)
	movem.l	(a3),d2-d5
	lea	16(a3),a3
	movem.l	d2-d5,32(a6)
	movem.l	(a3),d2-d5
	lea	16(a3),a3
	movem.l	d2-d5,48(a6)
#else
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,(a6)
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,16(a6)
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,32(a6)
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,48(a6)
#endif
	moveq	#31,d3		// Was 15

.loop2c_2:
	moveq	#60,d4		// Was 62

.loop3c_3:
	move.l	0(a6,d4),d5	// Was .w
	add.l	d5,d5		// Was .w
#ifdef COLDFIRE
	swap d6
             addx.l	d6,d6
             swap	d6
#else
	addx.w	d6,d6		// Was .l
#endif
	move.l	d5,0(a6,d4)	// Was .w
	subq.l	#4,d4		// Was 2
	lbpl	.loop3c_3
	move.w	d6,(a4)		// Was .l
	add.l	d7,a4

#ifdef COLDFIRE
	subq.l 	#1,d3
	bpl.s	.loop2c_2
	add.l	d1,a5
	move.l	a5,a4
	subq.l	#1,d0
	bpl.s	.loop1c_1
	move.l	(sp)+,d0
	subq.l	#1,d0
	bpl.s	.loop0c_0
#else
	ldbra	d3,.loop2c_2
	add.w	d1,a5
	move.l	a5,a4
	ldbra	d0,.loop1c_1
	swap	d0
	ldbra	d0,.loop0c_0
#endif

	lea	64(sp),sp
	rts


not_32bit_ts:
not_chunky_ts:
	move.w	d2,d3			// Reorganize device specific
#ifdef COLDFIRE
	ext.l	d3
	add.l	d3,d3
#else
	add.w	d3,d3			//  bitplanes into standard ones
#endif
	move.l	a3,a5

	move.w	d2,d7
#ifdef COLDFIRE
	ext.l	d7
	subq.l	#1,d7
#else
	subq.w	#1,d7
#endif

.loop1d_1:
	move.w	d0,d6
#ifdef COLDFIRE
	ext.l	d6
	subq.l	#1,d6
#else
	subq.w	#1,d6
#endif

.loop2d_2:
	move.w	d1,d5
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif

.loop3d_3:
	move.w	(a3),(a4)+
#ifdef COLDFIRE
	add.l	d3,a3
	subq.l	#1,d5
	bpl.s	.loop3d_3
	subq.l	#1,d6
	bpl.s	.loop2d_2
	addq.l	#2,a5
	move.l	a5,a3
	subq.l	#1,d7
	bpl.s 	.loop1d_1
#else
	add.w	d3,a3
	ldbra	d5,.loop3d_3
	ldbra	d6,.loop2d_2
	addq.w	#2,a5
	move.l	a5,a3
	ldbra	d7,.loop1d_1
#endif
	bra	end_vr_trn_fm


in_place:
	cmp.w	#1,d2			// Single plane is the same
	beq	end_vr_trn_fm
	tst.w	mfdb_standard(a1)
	beq	to_standard_ip

/* Reorganize standard bitplanes into device specific ones.
* In:	d0.w	mfdb_height
*	d1.w	mfdb_wdwidth (pixels / 16)
*	d2.w	bitplanes
*	a3	mfdb_address source
*	a4	mfdb_address destination
*/
	move.w	d0,d7			// Reorganize standard bitplanes
	move.w	d1,d6			//  into device specific ones

	move.w	d1,d3
	mulu	d2,d3
	mulu	d0,d3
	add.l	d3,d3			// d0 = pix/16 * planes * height * 2 = total bytes

	mulu	d0,d1
#ifdef COLDFIRE
	add.l	d1,d1
#else
	add.w	d1,d1			// d1 = bytes per standard line * height
#endif

	move.l	d3,d0
	subq.l	#2,d0
	subq.l	#2,d1
	addq.l	#2,a4

	move.l	a0,-(a7)
#ifdef COLDFIRE
	ext.l	d7
	subq.l	#1,d7
#else
	subq.w	#1,d7
#endif

.loop11:
	move.w	d6,d5
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif

.loop22:
	move.w	d2,d4
#ifdef COLDFIRE
	ext.l	d4
	subq.l	#1,d4
#else
	subq.w	#1,d4
#endif

.loop33:
	move.l	a4,a0
	bsr	rotate_mem
	addq.l	#2,a4
	subq.l	#2,d0
#ifdef COLDFIRE
	subq.l	#1,d4
	bpl.s	.loop33
	subq.l	#2,d1
	subq.l	#1,d5
	bpl.s	.loop22
	subq.l	#1,d7
	bpl.s	.loop11
#else
	ldbra	d4,.loop33
	subq.w	#2,d1
	ldbra	d5,.loop22
	ldbra	d7,.loop11
#endif
	move.l	(a7)+,a0
	bra	finish_up


to_standard_ip:			// Should have code for chunky modes (working on it)
	move.l	vwk_real_address(a0),a5
	move.l	wk_driver(a5),a5
	move.l	driver_device(a5),a5
	move.w	dev_format(a5),d6
#ifdef COLDFIRE
	and.l	#2,d6
#else
	and.w	#2,d6
#endif
	beq	.not_chunky_ts_ip

	move.w	d0,d7
	mulu	d1,d7
	add.l	d7,d7			// d7 = pix/16 * height * 2 = words/plane
	moveq	#2,d6

#ifdef COLDFIRE
	ext.l	d2
	cmp.l	#16,d2
#else
	cmp.w	#16,d2
#endif
	bne	.not_16bit_ts_ip
	bsr	to_standard_16
	bra	end_vr_trn_fm

.not_16bit_ts_ip:
#ifdef COLDFIRE
	cmp.l	#8,d2
#else
	cmp.w	#8,d2
#endif
	bne	.not_8bit_ts_ip
	bsr	to_standard_8
	bra	end_vr_trn_fm

.not_8bit_ts_ip:
#ifdef COLDFIRE
	cmp.l	#32,d2
#else
	cmp.w	#32,d2
#endif
	bne	.not_32bit_ts_ip
	bsr	to_standard_32
	bra	end_vr_trn_fm


.not_32bit_ts_ip:
.not_chunky_ts_ip:
#ifdef COLDFIRE
	move.l	d1,d7
	move.l	d2,d1
	move.l	d7,d2
#else	
	exg	d1,d2
#endif
	move.w	d0,d7
	move.w	d1,d6

	move.w	d1,d3
	mulu	d2,d3
	mulu	d0,d3
	add.l	d3,d3			// d3 = pix/16 * planes * height * 2 = total bytes

#ifdef COLDFIRE
	ext.l	d1
	add.l	d1,d1			// d1 = bytes per 16 pixel block
#else
	add.w	d1,d1			// d1 = bytes per 16 pixel block
#endif

	move.l	d3,d0
	subq.l	#2,d0

#ifdef COLDFIRE
	subq.l	#2,d1
#else
	subq.w	#2,d1
	ext.l	d1
#endif
	addq.l	#2,a4

	move.l	a0,-(a7)

#ifdef COLDFIRE
	ext.l	d6
	subq.l	#1,d6
#else
	subq.w	#1,d6
#endif

.loop_11:
	move.w	d7,d5
#ifdef COLDFIRE
	ext.l	d5
	subq.l	#1,d5
#else
	subq.w	#1,d5
#endif

.loop_22:
	move.w	d2,d4
#ifdef COLDFIRE
	ext.l	d4
	subq.l	#1,d4
#else
	subq.w	#1,d4
#endif

.loop_33:
	move.l	a4,a0
	bsr	rotate_mem
	addq.l	#2,a4
	subq.l	#2,d0
#ifdef COLDFIRE
	subq.l	#1,d4
	bpl.s	.loop_33
	subq.l	#1,d5
	bpl.s	.loop_22
	subq.l	#2,d1
	subq.l	#1,d6
	bpl.s	.loop_11
#else
	ldbra	d4,.loop_33
	ldbra	d5,.loop_22
	subq.w	#2,d1
	ldbra	d6,.loop_11
#endif
	move.l	(a7)+,a0
	bra	end_vr_trn_fm


finish_up:
	move.l	vwk_real_address(a0),a4	// Should this really check driver?
	move.l	wk_driver(a4),a4
	move.l	driver_device(a4),a4
	move.w	dev_format(a4),d0
#ifdef COLDFIRE
	and.l	#2,d0
#else
	and.w	#2,d0
#endif
	beq	.not_chunky

	move.w	mfdb_bitplanes(a1),d0
#ifdef COLDFIRE
	cmp.l	#16,d0
#else
	cmp.w	#16,d0
#endif
	bne	.not_16bit
	move.l	mfdb_address(a2),a4
	move.l	a4,a3
	move.w	mfdb_height(a1),d0
	moveq	#32,d6
	moveq	#2,d7
	bsr	to_standard_16		// Is its own inverse!
	bra	end_vr_trn_fm


.not_16bit:
#ifdef COLDFIRE
	cmp.l	#8,d0
	bne	.not_8bit
	sub.l	#16,a7			// This is specialized for 8 bit!
#else
	cmp.w	#8,d0
	bne	.not_8bit
	sub.w	#16,a7			// This is specialized for 8 bit!
#endif
	move.l	a7,a3
	move.l	mfdb_address(a2),a4
	move.w	mfdb_height(a1),d0
#ifdef COLDFIRE
	subq.l	#1,d0
#else
	subq.w	#1,d0
#endif

.loop_0_0_:
	move.w	mfdb_wdwidth(a1),d1
#ifdef COLDFIRE
	ext.l	d1
	subq.l	#1,d1
#else
	subq.w	#1,d1
#endif

.loop_1_1_:
	movem.l	(a4),d2-d5
	movem.l	d2-d5,(a3)
	moveq	#15,d3

.loop_2_2_:
	moveq	#14,d4

.loop_3_3_:
	move.w	0(a3,d4),d5
#ifdef COLDFIRE
	swap	d5
	add.l	d5,d5
	addx.l	d6,d6
	swap	d5
	move.w	d5,0(a3,d4)
	subq.l	#2,d4
#else
	add.w	d5,d5
	addx.b	d6,d6
	move.w	d5,0(a3,d4)
	subq.w	#2,d4
#endif
	lbpl	.loop_3_3_
	move.b	d6,(a4)+

#ifdef COLDFIRE
	subq.l	#1,d3
	bpl.s	.loop_2_2_
	subq.l	#1,d1
	bpl.s	.loop_1_1_
	subq.l	#1,d0
	bpl.s	.loop_0_0_

	add.l	#16,a7
#else
	ldbra	d3,.loop_2_2_
	ldbra	d1,.loop_1_1_
	ldbra	d0,.loop_0_0_

	add.w	#16,a7
#endif
	bra	end_vr_trn_fm


.not_8bit:
#ifdef COLDFIRE
	cmp.l	#32,d0
#else
	cmp.w	#32,d0
#endif
	bne	.not_32bit

	move.l	vwk_real_address(a0),a5
	lea	vdi_colours,a6

	move.l	vwk_palette(a0),d0
	bne	.local_palette
	move.l	wk_screen_palette_colours(a5),d0
.local_palette:
	move.l	d0,a5

#ifdef COLDFIRE
	sub.l	#64,a7			// This is specialized for 32 bit!
#else
	sub.w	#64,a7			// This is specialized for 32 bit!
#endif
	move.l	a7,a3
	move.l	mfdb_address(a2),a4
	move.w	mfdb_height(a1),d0
#ifdef COLDFIRE
	ext.l	d0
	subq.l	#1,d0
#else
	subq.w	#1,d0
#endif

.loop_0b0:
	move.w	mfdb_wdwidth(a1),d1
#ifdef COLDFIRE
	ext.l	d1
	subq.l	#1,d1
#else
	subq.w	#1,d1
#endif

.loop_1b1:
	movem.l	(a4),d2-d5
	movem.l	d2-d5,(a3)
	movem.l	16(a4),d2-d5
	movem.l	d2-d5,16(a3)
	movem.l	32(a4),d2-d5
	movem.l	d2-d5,32(a3)
	movem.l	48(a4),d2-d5
	movem.l	d2-d5,48(a3)
	moveq	#15,d3

.loop_2b2:
	moveq	#62,d4

.loop_3b3:
	move.w	0(a3,d4),d5
#ifdef COLDFIRE
	swap	d5
	add.l	d5,d5
#else
	add.w	d5,d5
#endif


  .ifne lookup32
	addx.l	d6,d6
#ifdef COLDFIRE
	swap	d5
	move.w	d5,0(a3,d4)
	subq.l	#2,d4
#else
	move.w	d5,0(a3,d4)
	subq.w	#2,d4
#endif
	lbpl	.loop_3b3

#ifdef COLDFIRE
	and.l	#$00ff,d6		// Higher palette entries aren't possible (optimize above!)
	cmp.l	#16,d6
	lblo	.lookup5		// 0-15
	cmp.l	#255,d6
#else
	and.w	#$00ff,d6		// Higher palette entries aren't possible (optimize above!)
	cmp.b	#16,d6
	lblo	.lookup5		// 0-15
	cmp.b	#255,d6
#endif
	lbne	.colour_ok,6		// 16-254
	moveq	#1,d6
	lbra	.colour_ok,6

.lookup5:
	move.b	0(a6,d6),d6

.colour_ok6:
#ifdef COLDFIRE
	lsl.l	#4,d6			// Assume 16 byte palette entries
#else
	lsl.w	#4,d6			// Assume 16 byte palette entries
#endif
	move.l	12(a5,d6),d5
#ifdef COLDFIRE
	move.l	d5,d7
	lsr.l	#8,d7
	lsl.l	#8,d5
	or.l	d7,d5
	swap	d5
	clr.w	d5
	move.l	d5,-(a7)
	move.w	12(a5,d6),d5
	move.l	d5,d7
	lsr.l	#8,d7
	lsl.l	#8,d5
	or.l	d7,d5
	and.l	#0xffff,d5
	or.l	(a7)+,d5
#else
	ror.w	#8,d5
	swap	d5
	ror.w	#8,d5
#endif
	swap	d5
	move.l	d5,(a4)+
  .else
#ifdef COLDFIRE
	move.l	d5,-(a7)
	addx.l	d7,d7
	moveq	#31,d5
	asl.l	d5,d7
	lsr.l	#1,d6
	or.l	d7,d6
	move.l	(a7)+,d5
	swap	d5
#else
	roxr.l	#1,d6		// This _is_ the right one!
#endif
	move.w	d5,0(a3,d4)
#ifdef COLDFIRE
	subq.l	#2,d4
#else
	subq.w	#2,d4
#endif
	lbpl	.loop_3b3

	move.l	d6,(a4)+
  .endc

.skipb4:
#ifdef COLDFIRE
	subq.l	#1,d3
	bpl.s	.loop_2b2
	subq.l	#1,d1
	bpl.s	.loop_1b1
	subq.l	#1,d0
	bpl.s	.loop_0b0

	add.l	#64,a7
#else
	ldbra	d3,.loop_2b2
	ldbra	d1,.loop_1b1
	ldbra	d0,.loop_0b0

	add.w	#64,a7
#endif
	bra	end_vr_trn_fm

.not_32bit:
.not_chunky:		

end_vr_trn_fm:
	moveq	#1,d0
	tst.w	mfdb_standard(a1)
	beq	.was_not_standard
	moveq	#0,d0
.was_not_standard:
	move.w	d0,mfdb_standard(a2)
#ifdef COLDFIRE
	movem.l	(a7),d2-d7/a3-a6
	lea	40(a7),a7
#else
	movem.l	(a7)+,d2-d7/a3-a6
#endif
	used_d1
	rts
	
/* rotate_mem - Support function
*              Rotates a memory area in a reasonably smart way
* Todo: Use stack buffer for small amounts
* In:   a0      Pointer to data
*       d0	Size
*       d1      Shift
*/
rotate_mem:
#ifdef COLDFIRE
	lea	-24(a7),a7
	movem.l	d0-d3/a2-a3,(a7)
#else
	movem.l	d0-d3/a2-a3,-(a7)
#endif
	move.l	a0,a2
	cmp.l	d0,d1
	bge	.end_rotate
	tst.l	d1
	beq	.end_rotate
.rotate:
	move.l	a2,a3
	add.l	d1,a3
	move.l	d0,d2
	sub.l	d1,d2
	subq.l	#1,d2

.loopr1:
	move.b	(a2),d3
	move.b	(a3),(a2)+
	move.b	d3,(a3)+
#ifdef COLDFIRE
	subq.l	#1,d2
	bpl.s	.loopr1
#else
	ldbra	d2,.loopr1
#endif
	sub.l	#0x10000,d2
	lbpl	.loopr1
	move.l	d0,d2
	move.l	d1,d0
	divu	d1,d2
	swap	d2
	ext.l	d2
	sub.l	d2,d1
//	bpl	.positive
//	neg.l	d1
//.positive:
	cmp.l	d0,d1
	blt	.rotate
.end_rotate:
#ifdef COLDFIRE
	movem.l	(a7),d0-d3/a2-a3
	lea	24(a7),a7
#else
	movem.l	(a7)+,d0-d3/a2-a3
#endif
	rts


	.data

vdi_colours:
	dc.b	0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255


