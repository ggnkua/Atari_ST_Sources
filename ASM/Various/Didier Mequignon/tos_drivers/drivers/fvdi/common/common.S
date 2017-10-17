/****
* fVDI->driver interface (assembly functions), by Johan Klockars
*
* $Id: common.s,v 1.5 2005/04/23 18:53:17 johan Exp $
*
* Most fVDI device drivers are expected to make use of this file.
*
* Since it would be difficult to do without this file when
* writing new device drivers, and to make it possible for
* some such drivers to be commercial, this file is put in
* the public domain. It's not copyrighted or under any sort
* of license.
****/

#define both			0	// Write in both FastRAM and on screen
#define upto8		0	// Handle 8 bit drawing

#include		"vdi.inc"
#include		"macros.inc"

	.xdef		_line
	.xdef		_set_pixel
	.xdef		_get_pixel
	.xdef		_expand
	.xdef		_fill
	.xdef		_fillpoly
	.xdef		_blit
	.xdef		_text
	.xdef		_mouse
	.xdef		_set_palette
	.xdef		_colour
	.xdef		_initialize_palette
	.xdef		get_colour_masks

	.xref		_line_draw_r,_write_pixel_r,_read_pixel_r,_expand_area_r
	.xref		_fill_area_r,_fill_poly_r,_blit_area_r,_text_area_r
	.xref		_mouse_draw_r
	.xref		_set_colours_r,_get_colour_r
	.xref		_fallback_line,_fallback_text,_fallback_fill
	.xref		_fallback_fillpoly,_fallback_expand,_fallback_blit
	.xref		clip_line
	.xref		_mask
	.xref		_update_mono


	.text

//	.asciz		"set_pixel"
//	.align		2
/*--------
* Set a coloured pixel
* In:	a0	VDI struct, destination MFDB (odd address marks table operation)
*	d0	colour
*	d1	x or table address
*	d2	y or table length (high) and type (0 - coordinates)
* Call:	a1	VDI struct, destination MFDB (odd address marks table operation)
*	d0	colour
*	d1	x or table address
*	d2	y or table length (high) and type (0 - coordinates)
*-------*/
_set_pixel:
set_pixel:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1

#ifdef COLDFIRE
	.chip		68060
	jsr		([_write_pixel_r])
	.chip		5200
#else
	ijsr		_write_pixel_r
#endif
	tst.l		d0
	bgt		.write_done

	tst.w		d2
	bne		.write_done		// Only straight coordinate tables available so far
	move.l		8*4(a7),d3		// Fetch a0
	bclr		#0,d3
	move.l		d3,-(a7)
	move.l		4+4(a7),-(a7)		// Fetch d1
	move.w		8+8(a7),-(a7)		// Fetch d2 (high)
.write_loop:
	move.l		2(a7),a2
	move.w		(a2)+,d1
	move.w		(a2)+,d2
	move.l		a2,2(a7)
	move.l		6(a7),a1
	move.l		10+0(a7),d0		// Fetch d0
#ifdef COLDFIRE
	.chip		68060
	jsr		([_write_pixel_r])
	.chip		5200
#else
	ijsr		_write_pixel_r
#endif
	subq.w		#1,(a7)
	bne		.write_loop
	add.w		#10,a7
.write_done:

	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"get_pixel"
//	.align		2
/*--------
* Get a coloured pixel
* In:	a0	VDI struct, source MFDB
*	d1	x
*	d2	y
* Call:	a1	VDI struct, source MFDB
*	d1	x
*	d2	y
* Out:	d0	line colour
*-------*/
_get_pixel:
get_pixel:
#ifndef COLDFIRE
	movem.l		d1-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1
	
#ifdef COLDFIRE
	.chip		68060
	jsr		([_read_pixel_r])
	.chip		5200
#else
	ijsr		_read_pixel_r
#endif

	movem.l		(a7)+,d1-d7/a0-a6
#endif
	rts


//	.asciz		"line"
//	.align		2
/*--------
* Draw a colored line between 2 points
* In:	a0	VDI struct (odd address marks table operation)
*	d0	colour
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	mode
* Call:	a1	VDI struct (odd adress marks table operation)
*	d0	logic operation
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - pairs+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	colour
*-------*/
_line:
line:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1
	exg		d0,d6

#ifdef COLDFIRE
	.chip		68060
	jsr		([_line_draw_r])
	.chip		5200
#else
	ijsr		_line_draw_r
#endif	
	tst.l		d0
	lbgt		.line1
	lbmi		.line2
	move.l		_fallback_line,d0
	bra		give_up

.line1:
	jsr		_update_mono
	movem.l		(a7)+,d0-d7/a0-a6
	rts

.line2:					// Transform multiline to single ones
	move.w		8+2(a7),d0
	move.w		d3,d7
	cmp.w		#1,d0
	bhi		.line_done		// Only coordinate pairs and pairs+marks available so far
	beq		.use_marks
	moveq		#0,d7			// Move count
.use_marks:
	swap		d7
	move.w		#1,d7			// Currrent index in high word
	swap		d7

	move.l		8*4(a7),d3		// Fetch a0
	bclr		#0,d3
	move.l		d3,a1
	move.l		1*4(a7),a2		// Table address

	move.l		d4,a6
	tst.w		d7
	beq		.no_start_move
	add.w		d7,a6
	add.w		d7,a6
	subq.l		#2,a6
	cmp.w		#-4,(a6)
	bne		.no_start_movex
	subq.l		#2,a6
	subq.w		#1,d7
.no_start_movex:
	cmp.w		#-2,(a6)
	bne		.no_start_move
	subq.l		#2,a6
	subq.w		#1,d7
.no_start_move:
	bra		.loop_end
.line_loop:
	movem.w		(a2),d1-d4
	move.l		a1,a0
	bsr		clip_line
	bvs		.no_draw
	move.l		0(a7),d6		// Colour
	move.l		5*4(a7),d5		// Pattern
	move.l		6*4(a7),d0		// Mode
	movem.l		d7/a1-a2/a6,-(a7)
#ifdef COLDFIRE
	.chip		68060
	jsr		([_line_draw_r])
	.chip		5200
#else
	ijsr		_line_draw_r
#endif
	movem.l		(a7)+,d7/a1-a2/a6
.no_draw:
	tst.w		d7
	beq		.no_marks
	swap		d7
	addq.w		#1,d7
	move.w		d7,d4
	add.w		d4,d4
	subq.w		#4,d4
	cmp.w		(a6),d4
	bne		.no_move
	subq.l		#2,a6
	addq.w		#1,d7
	swap		d7
	subq.w		#1,d7
	swap		d7
	addq.l		#4,a2
	subq.w		#1,2*4(a7)
.no_move:
	swap		d7
.no_marks:
	addq.l		#4,a2
.loop_end:
	subq.w		#1,2*4(a7)
	bgt		.line_loop
.line_done:
	jsr		_update_mono
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"expand"
//	.align		2
/*---------
* Expand a monochrome area to multiple bitplanes
* In:	a0	VDI struct, destination MFDB, VDI struct, source MFDB
*	d0	colour
*	d1-d2	x1,y1 source
*	d3-d6	x1,y1 x2,y2 destination
*	d7	logic operation
* Call:	d0	height and width to move (high and low word)
*	d1-d2	source coordinates
*	d3-d4	destination coordinates
*	d6	background and foreground colour
*	d7	logic operation
*-------*/
_expand:
expand:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3(/6)/4(/6)/6 for normal/both/upto8

	move.l		a0,a1

	exg		d0,d6
	sub.w		d4,d0
	addq.w		#1,d0
	swap		d0
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0

#ifdef COLDFIRE
	.chip		68060
	jsr		([_expand_area_r])
	.chip		5200
#else
	ijsr		_expand_area_r
#endif
	tst.l		d0
	lbgt		.expand1
	move.l		_fallback_expand,d0
	bra		give_up

.expand1:
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"fill"
//	.align		2
/*--------
* Fill a multiple bitplane area using a monochrome pattern
* In:	a0	VDI struct (odd address marks table operation)
*	d0	colour
*	d1	x1 destination or table address
*	d2	y1    - " -    or table length (high) and type (0 - y/x1/x2 spans)
*	d3-d4	x2,y2 destination
*	d5	pattern address
*	d6	mode
*	d7	interior/style
* Call:	a1	VDI struct (odd address marks table operation)
*	d0	height and width to fill (high and low word)
*	d1	x or table address
*	d2	y or table length (high) and type (0 - y/x1/x2 spans)
*	d3	pattern address
*	d4	colour
*	d6	mode
*	d7	interior/style
**	+colour in a really dumb way...
*-------*/
_fill:
fill:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1

// The colour fetching has been expanded to put the address
// of the background colour on the stack.
// That's needed for non-solid replace mode.
// None of this is any kind of good idea except for bitplanes!

  .ifne 0
// ******************** Should probably use get_colour_masks like the rest **************
	lea		_colour,a3
    .ifne	upto8
//	move.w		d0,d5
//	lsr.w		#1,d5			// (d5 >> 4) << 3
//	and.w		#0x0078,d5
//	move.l		(a3,d5.w),a5
//	move.l		4(a3,d5.w),a6
	move.l		d0,d5
	lsr.l		#1,d5			// (d5 >> 4) << 3
	and.l		#0x00780078,d5
	swap		d5
	pea		(a3,d5.w)
	swap		d5
	move.l		(a3,d5.w),a5
	move.l		4(a3,d5.w),a6
    .endc
//	and.w		#x0000f,d0
//	lsl.w		#3,d0
//	move.l		(a3,d0.w),a2
//	move.l		4(a3,d0.w),a3
	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
  .endc

	exg		d4,d0
//	move.w		d4,d0
	sub.w		d2,d0
	addq.w		#1,d0
	swap		d0
	move.w		d3,d0
	sub.w		d1,d0
	addq.w		#1,d0

	move.l		d5,d3

#ifdef COLDFIRE
	.chip		68060
	jsr		([_fill_area_r])
	.chip		5200
#else
	ijsr		_fill_area_r
#endif
	tst.l		d0
	lbgt		.fill1
	lbmi		.fill2
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endc
    .ifne	upto8
	addq.l		#8,a7
    .endc
  .endc
	move.l		_fallback_fill,d0
	bra		give_up

.fill1:
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endc
    .ifne	upto8
	addq.l		#8,a7
    .endc
  .endc
	jsr		_update_mono
	movem.l		(a7)+,d0-d7/a0-a6
	rts

.fill2:
	move.w		8+2(a7),d0
	tst.w		d0
	bne		.fill_done		// Only y/x1/x2 spans available so far
	move.l		8*4(a7),d3		// Fetch a0
	bclr		#0,d3
	move.l		d3,a1
	move.l		4(a7),a2		// Fetch d1
.fill_loop:
	moveq		#0,d2
	move.w		(a2)+,d2
	moveq		#0,d1
	move.w		(a2)+,d1
	moveq		#1,d0
	swap		d0
	move.w		(a2)+,d0
	sub.w		d1,d0
	addq.w		#1,d0
	move.l		5*4(a7),d3
	move.l		0(a7),d4
	movem.l		a1-a2,-(a7)
#ifdef COLDFIRE
	.chip		68060
	jsr		([_fill_area_r])
	.chip		5200
#else
	ijsr		_fill_area_r
#endif
	movem.l		(a7)+,a1-a2
	subq.w		#1,2*4(a7)
	bne		.fill_loop
.fill_done:
	jsr		_update_mono
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"fillpoly"
//	.align		2
/*--------
* Fill a multiple bitplane polygon using a monochrome pattern
* In:	a0	VDI struct (odd address marks table operation)
*	d0	colour
*	d1	points address
*	d2	number of points
*	d3	index address
*	d4	number of indices
*	d5	pattern address
*	d6	mode
*	d7	interior/style
* Call:	a1	VDI struct (odd address marks table operation)
*	d0	number of points and indices (high and low word)
*	d1	points address
*	d2	index address
*	d3	pattern address
*	d4	colour
*	d6	mode
*	d7	interior/style
**	+colour in a really dumb way...
*-------*/
_fillpoly:
fillpoly:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1

// The colour fetching has been expanded to put the address
// of the background colour on the stack.
// That's needed for non-solid replace mode.
// None of this is any kind of good idea except for bitplanes!

  .ifne 0
// ******************** Should probably use get_colour_masks like the rest **************
	lea		_colour,a3
    .ifne	upto8
//	move.w		d0,d5
//	lsr.w		#1,d5			// (d5 >> 4) << 3
//	and.w		#0x0078,d5
//	move.l		(a3,d5.w),a5
//	move.l		4(a3,d5.w),a6
	move.l		d0,d5
	lsr.l		#1,d5			// (d5 >> 4) << 3
	and.l		#0x00780078,d5
	swap		d5
	pea		(a3,d5.w)
	swap		d5
	move.l		(a3,d5.w),a5
	move.l		4(a3,d5.w),a6
    .endc
//	and.w		#0x000f,d0
//	lsl.w		#3,d0
//	move.l		(a3,d0.w),a2
//	move.l		4(a3,d0.w),a3
	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
  .endc

	swap	d2
	move.w	d4,d2
	move.l	d0,d4
	move.l	d2,d0
	move.l	d3,d2
	move.l	d5,d3

#ifdef COLDFIRE
	.chip		68060
	jsr		([_fill_poly_r])
	.chip		5200
#else
	ijsr		_fill_poly_r
#endif
	tst.l		d0
	lbgt		.fillpoly1

  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endc
    .ifne	upto8
	addq.l		#8,a7
    .endc
  .endc
	move.l		_fallback_fillpoly,d0
	bra		give_up

.fillpoly1:
  .ifne 0
    .ifeq	upto8
	addq.l		#4,a7
    .endc
    .ifne	upto8
	addq.l		#8,a7
    .endc
  .endc
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"blit"
//	.align		2
/*--------
* Blit an area
* In:	a0	VDI struct, destination MFDB, VDI struct, source MFDB
*	d0	logic operation
*	d1-d2	x1,y1 source
*	d3-d6	x1,y1 x2,y2 destination
* Call:	a1	VDI struct,destination MFDB, VDI struct, source MFDB
*	d0	height and width to move (high and low word)
*	d1-d2	source coordinates
*	d3-d4	destination coordinates
*	d5	logic operation
*-------*/
_blit:
blit:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Used to have -3/4/6 for normal/both/upto8

	move.l		a0,a1

	move.l		d0,d7

	move.w		d6,d0
	sub.w		d4,d0
	addq.w		#1,d0
	swap		d0
	move.w		d5,d0
	sub.w		d3,d0
	addq.w		#1,d0

#ifdef COLDFIRE
	.chip		68060
	jsr		([_blit_area_r])
	.chip		5200
#else
	ijsr		_blit_area_r
#endif
	tst.l		d0
	lbgt		.blit1
	move.l		_fallback_blit,d0
	bra		give_up

.blit1:
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"text"
//	.align		2
/*--------
* Draw some text
* In:	a0	VDI struct
*	a1	string address
*	a2	offset table or zero
*	d0	string length
*	d1	x1,y1 destination
* Call:	a1	VDI struct
*	a2	offset table or zero
*	d0	string length
*	d3-d4	destination coordinates
*	a4	string address
*-------*/
_text:
text:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Was d2-d7/a3-a6

	move.l		a1,a4
	move.l		a0,a1

	move.w		d1,d4
	swap		d1
	move.w		d1,d3

#ifdef COLDFIRE
	.chip		68060
	jsr		([_text_area_r])
	.chip		5200
#else
	ijsr		_text_area_r
#endif
	tst.l		d0
	lbgt		.text1
	move.l		_fallback_text,d0
	bra		give_up

.text1:
	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"mouse"
//	.align		2
/*--------
* Draw the mouse
* In:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move), 1 (hide), 2 (show), Mouse* (change)
* Call:	a1	Pointer to Workstation struct
*	d0	x (low), old op bits (high)
*	d1	y
*	d2	0 (move shown), 1 (move hidden), 2 (hide), 3 (show), Mouse* (change)
* Out:	d0	mouse op to try again (low), pointer delay (high)
*-------*/
_mouse:
mouse:
#ifdef COLDFIRE
	.chip		68060
	jsr		([_mouse_draw_r])
	.chip		5200
#else
	ijsr		_mouse_draw_r
#endif
	rts


//	.asciz		"set_palette"
//	.align		2
/*--------
* Set palette colours
* In:	a0	VDI struct
*	d0	number of entries, start entry
*	a1	requested colour values (3 word/entry)
*	a2	colour palette
*-------*/
_set_palette:
set_palette:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Overkill

#ifdef COLDFIRE
	.chip		68060
	jsr		([_set_colours_r])
	.chip		5200
#else
	ijsr		_set_colours_r
#endif

	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts


//	.asciz		"colour"
//	.align		2
/*--------
* Get palette colour
* In:	a0	VDI struct
*	d0	fore- and background colour indices
* Out:	d0	fore- and background colour
*-------*/
_colour:
colour:
#ifndef COLDFIRE
	movem.l		d1-d7/a0-a6,-(a7)

#ifdef COLDFIRE
	.chip		68060
	jsr		([_get_colour_r])
	.chip		5200
#else
	ijsr		_get_colour_r
#endif

	movem.l		(a7)+,d1-d7/a0-a6
#endif
	rts

  .ifne	1
//	.asciz		"initialize_palette"
//	.align		2
/*--------
* Set palette colours
* initialize_palette(Virtual *vwk, int start, int n, int requested[][3], Colour palette[])
* To be called from C
*-------*/
_initialize_palette:
#ifndef COLDFIRE
	movem.l		d0-d7/a0-a6,-(a7)	// Overkill

	move.l		15*4+4(a7),a0
	move.l		15*4+8(a7),d1
	move.l		15*4+12(a7),d0
	swap		d0
	move.w		d1,d0
	move.l		15*4+16(a7),a1
	move.l		15*4+20(a7),a2

#ifdef COLDFIRE
	.chip		68060
	jsr		([_set_colours_r])
	.chip		5200
#else
	ijsr		_set_colours_r
#endif

	movem.l		(a7)+,d0-d7/a0-a6
#endif
	rts
  .endc
  

/*---------
* Get colour masks
* get_colour_masks(int colour)
* In:	d0	background colour, foreground colour
* Out:	a2-a3	First four colour bits
*	a5-a6	Last four colour bits (only when 'upto8')
*	d0	Pointer to colour bits for background
* XXX:	d0
*-------*/
get_colour_masks:
#ifndef COLDFIRE
	lea		_mask,a3
  .ifne	upto8
	move.w		d0,a2
	lsr.l		#1,d0			// (d5 >> 4) << 3
	and.l		#0x00780078,d0
	move.l		(a3,d0.w),a5
	move.l		4(a3,d0.w),a6
	move.w		a2,d0
  .endc
	and.l		#0x000f000f,d0
	lsl.l		#3,d0
	swap		d0
	pea		0(a3,d0.w)
	swap		d0
	move.l		0(a3,d0.w),a2
	move.l		4(a3,d0.w),a3
	move.l		(a7)+,d0
#endif
	rts

#ifndef COLDFIRE
/*---------
* Give up and try other function
* This routine should only be branched to, it's not a subroutine!
* In:	d0	Address to other function
* Call:	d0-a6	Same values as at original call
*-------*/
give_up:
	pea	.return
	move.l	d0,-(a7)
	movem.l	8(a7),d0-d7/a0-a6
	rts
.return:
	movem.l	(a7)+,d0-d7/a0-a6
	rts
#endif
