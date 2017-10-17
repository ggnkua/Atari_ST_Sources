/*****
* Single plane line drawing
*
* $Id: 1_line.s,v 1.3 2005/04/23 18:57:52 johan Exp $
*
* Copyright 1997-2002, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
*****/

#define both		0	// Write in both FastRAM and on screen
#define longs	1
#define get		1
#define mul		1	// Multiply rather than use table
#define shift	1
#define smartdraw	1

#include "pixelmac.inc"
#include "vdi.inc"

	.xdef		line_draw_1,_line_draw_1

	.ifeq		shift
	.xref		dot,lline,rline
	.endc
	.ifeq		mul
	.xref		row
	.endc

	.xref		clip_line
	.xref		get_colour,get_colour_masks


/*----------
* Draw line
*----------
* In:	a1	VDI struct (odd address marks table operation)
*	d0	logic operation
*	d1	x1 or table address
*	d2	y1 or table length (high) and type (0 - coordinate pairs, 1 - paris+moves)
*	d3	x2 or move point count
*	d4	y2 or move index address
*	d5	pattern
*	d6	colour
*/
_line_draw_1:
line_draw_1:
	exg		a1,d5
	bclr		#0,d5
	bne		unknown_line
	exg		d5,a1

	bsr		clip_line
	bvc		.draw
	moveq		#1,d0
	rts
.draw:

	move.w		d0,-(a7)		// Save for later use
	move.l		d6,d0
	bsr		get_colour
	bsr		get_colour_masks

	move.l		vwk_real_address(a1),a1	// a1 - workstation
	.ifne	mul
	move.l		wk_screen_mfdb_address(a1),a0
	.endc
	move.w		wk_screen_wrap(a1),d0	// screen width (bytes)

	move.w		d4,d6			// d6 = Y1-Y2 = dY
	sub.w		d2,d6
	beq		h_line
	move.w		d3,d5
	sub.w		d1,d5			// d5 = X2-X1 = dX
	beq		v_line
	bmi.s		line1			// dX < 0 ?
	move.w		d1,d4
	bra.w		n_line

line1:
	neg.w		d5			// X2 < X1
	neg.w		d6
	move.w		d4,d2
	move.w		d3,d4
n_line:
	addq.l		#2,a7			// ***** Doesn't use logic op yet *****
	tst.w		d6
	bpl.s		.n_line0
	neg.w		d6
	neg.w		d0
.n_line0:
	move.l		#0x80008000,d1
	move.w		d4,d7
	and.w		#0x0f,d7
	lsr.l		d7,d1
	lsr.w		#4,d4
	lsl.w		#1,d4

	.ifne	mul
	mulu.w		wk_screen_wrap(a1),d2
	add.w		d4,a0
	add.l		d2,a0			// logscreen adress
	.endc
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	add.w		d4,a0
	.endc

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		no_shadow
	move.l		d7,a4
	add.w		d4,a4
	add.l		d2,a4
	.endc

	cmp.w		d6,d5
	bmi		.n_line2
.n_line1:					// dX > dY
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	moveq		#0,d2
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endc

.lin1_lp2:
	or.l		d1,d2
	tst.w		d6
	bpl.s		.lin1_no_y
	add.w		d3,d6
	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

/* WRITE AND MOVE RIGHT */
	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	moveq		#0,d2

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			// Return as completed
	rts

.lin1_no_y:
	.ifeq	get
	add.w		d4,d6
	.endc
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endc

/* WRITE AND MOVE UP/DOWN  */
	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	moveq		#0,d2

	.ifne	both
	add.l		a1,a4
	subq.l		#2,a4
	.endc
	add.l		a1,a0
	subq.l		#2,a0

	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endc

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			// Return as completed
	rts

.n_line2:					// dX < dY
	exg		d6,d5
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	subq.l		#2,a1
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endc

.lin2_lp:
	tst.w		d6
	bpl.s		.lin2_no_x
	add.w		d3,d6

/* WRITE AND MOVE UP/DOWN */
	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	add.l		a1,a4
	.endc

	add.l		a1,a0

	dbra		d5,.lin2_lp

	moveq		#1,d0			// Return as completed
	rts

.lin2_no_x:
	.ifeq	get
	add.w		d4,d6
	.endc
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endc

/* WRITE AND MOVE RIGHT + UP/DOWN */
	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	add.l		a1,a4
	.endc

	add.l		a1,a0

	ror.l		#1,d1
	dbcs		d5,.lin2_lp

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endc

	subq.w		#1,d5
	bpl		.lin2_lp

	moveq		#1,d0			// Return as completed
	rts


.error:
	moveq		#1,d0			// Return as completed
	rts

unknown_line:
	moveq		#-1,d0
	rts


	.ifne	both
#undef both
#define both 0

no_shadow:
	cmp.w		d6,d5
	bmi		.n_line2
.n_line1:					// dX > dY
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	moveq		#0,d2
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endc

.lin1_lp2
	or.l		d1,d2
	tst.w		d6
	bpl.s		.lin1_no_y
	add.w		d3,d6
	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

/* WRITE AND MOVE RIGHT */
	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	moveq		#0,d2

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			// Return as completed
	rts

.lin1_no_y
	.ifeq	get
	add.w		d4,d6
	.endc
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endc

/* WRITE AND MOVE UP/DOWN */
	move.l		a2,d0
	and.l		d2,d0
	move.l		d2,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	moveq		#0,d2

	.ifne	both
	add.l		a1,a4
	subq.l		#2,a4
	.endc
	add.l		a1,a0
	subq.l		#2,a0

	ror.l		#1,d1
	dbcs		d5,.lin1_lp2

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endc

	subq.w		#1,d5
	bpl		.lin1_lp2

	moveq		#1,d0			// Return as completed
	rts

.n_line2:					// dX < dY
	exg		d6,d5
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	move.w		d0,a1
	subq.l		#2,a1
	.ifne	get
	swap		d3
	move.w		d4,d3
	swap		d3
	.endc

.lin2_lp
	tst.w		d6
	bpl.s		.lin2_no_x
	add.w		d3,d6

/* WRITE AND MOVE UP/DOWN */
	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	add.l		a1,a4
	.endc

	add.l		a1,a0

	dbra		d5,.lin2_lp

	moveq		#1,d0			// Return as completed
	rts

.lin2_no_x
	.ifeq	get
	add.w		d4,d6
	.endc
	.ifne	get
	swap		d3
	add.w		d3,d6
	swap		d3
	.endc

/* WRITE AND MOVE RIGHT + UP/DOWN */
	move.l		a2,d0
	and.l		d1,d0
	move.l		d1,d7
	not.l		d7

	.ifeq	both
	 .ifeq	get
	and.w		d7,(a0)
	or.w		d0,(a0)+
	 .endc
	 .ifne	get
	move.w		(a0),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	 .ifeq	get
	and.w		d7,(a4)
	or.w		d0,(a4)
	move.w		(a4)+,(a0)+
	 .endc
	 .ifne	get
	move.w		(a4),d4
	and.w		d7,d4
	or.w		d0,d4
	move.w		d4,(a4)+
	move.w		d4,(a0)+
	 .endc
	.endc

	.ifne	both
	add.l		a1,a4
	.endc

	add.l		a1,a0

	ror.l		#1,d1
	dbcs		d5,.lin2_lp

	addq.l		#2,a0
	.ifne	both
	addq.l		#2,a4
	.endc

	subq.w		#1,d5
	bpl		.lin2_lp

	moveq		#1,d0			// Return as completed
	rts


.error:
	moveq		#1,d0			// Return as completed
	rts


#undef both
#define both	1
	.endc
	
h_line:						// Y1 = Y2
	cmp.w		d1,d3
	bge.s		.hline1
	exg		d1,d3
.hline1:
	.ifne	mul
	mulu.w		wk_screen_wrap(a1),d2
	add.l		d2,a0			// screen adress
	.endc
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	.endc

	cmp.w		#3,(a7)+		// XOR?
	beq		h_line_xor

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	move.l		a0,a1			// Old a1 value was needed above
	beq		hno_shadow
	move.l		d7,a4
	add.l		d2,a4
	.endc

	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		hl_single

	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write1
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done1
.write1:
	 .endc
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done1:
	.endc

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl

.for_h:
	.ifeq	both
	move.w		a2,(a0)+
	.endc
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write2
	addq.l		#2,a0
	addq.l		#2,a4
	bra		.done2
.write2:
	 .endc
	move.w		a2,(a0)+
	move.w		a2,(a4)+
.done2:
	.endc
.shl:
	dbf		d7,.for_h

	move.l		a2,d2
	and.l		d1,d2
	move.l		a3,d3
	and.l		d1,d3
	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d1,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write3
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done3
.write3:
	 .endc
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done3:
	.endc

.end_h:
	moveq		#1,d0			// Return as completed
	rts

hl_single:
	and.l		d1,d0
	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	 .ifne	smartdraw
	cmp.w		(a4),d5
	bne		.write
	addq.l		#2,a4
	addq.l		#2,a0
	bra		.done
.write:
	 .endc
	move.w		d5,(a4)+
	move.w		d5,(a0)+
.done:
	.endc

	moveq		#1,d0			// Return as completed
	rts


	.ifne	both
#undef both
#define both 0

hno_shadow:
	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		mhl_single

	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl2

.for_h2:
	move.w		a2,(a0)+
	.ifne	both
	move.w		a2,(a4)+
	.endc
.shl2:
	dbf		d7,.for_h2

	move.l		a2,d2
	and.l		d1,d2
	move.l		a3,d3
	and.l		d1,d3
	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d1,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

.end_h2:
	moveq		#1,d0			// Return as completed
	rts

mhl_single:
	and.l		d1,d0
	move.l		a2,d2
	and.l		d0,d2
	move.l		a3,d3
	and.l		d0,d3
	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
	and.w		d0,d5
	or.w		d2,d5
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	moveq		#1,d0			// Return as completed
	rts

#undef both
#define both 1
	.endc


v_line:						// X1 = X2
	tst.w		d6
	bgt.s		.lvert2
	exg		d2,d4	
	neg.w		d6
.lvert2:
	.ifne	mul
	moveq		#0,d5
	move.w		wk_screen_wrap(a1),d5
	mulu.w		d5,d2
	add.l		d2,a0
	.endc
	.ifeq	mul
	lea		row(pc),a0
	move.l		(a0,d2.w*4),a0
	moveq		#0,d5
	move.w		wk_screen_wrap(a1),d5
	.endc

	cmp.w		#3,(a7)+		// XOR?
	beq		v_line_xor

	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		vno_shadow
	move.l		d7,a4
	add.l		d2,a4
	.endc

	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc
	move.l		d0,d2
	move.l		a2,d0
	and.l		d2,d0
	move.l		a3,d1
	and.l		d2,d1
	not.l		d2

	subq.l		#2,d5
//	bra.s		.svl

.for_v:
	.ifeq	both
	move.w		(a0),d3
	.endc
	.ifne	both
	move.w		(a4),d3
	.endc
	and.w		d2,d3
	or.w		d0,d3
	.ifeq	both
	move.w		d3,(a0)+
	.endc
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endc
	.ifne	both
	add.l		d5,a4
	.endc

	add.l		d5,a0
.svl:
	dbf		d6,.for_v
.end_v:
	moveq		#1,d0			// Return as completed
	rts


	.ifne	both
#undef both
#define both 0

vno_shadow:
	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc
	move.l		d0,d2
	move.l		a2,d0
	and.l		d2,d0
	move.l		a3,d1
	and.l		d2,d1
	not.l		d2

	subq.l		#2,d5
//	bra.s		.svl2

.for_v2:
	.ifeq	both
	move.w		(a0),d3
	.endc
	.ifne	both
	move.w		(a4),d3
	.endc
	and.w		d2,d3
	or.w		d0,d3
	.ifeq	both
	move.w		d3,(a0)+
	.endc
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endc
	.ifne	both
	add.l		d5,a4
	.endc

	add.l		d5,a0
.svl2:
	dbf		d6,.for_v2
.end_v2:
	moveq		#1,d0			// Return as completed
	rts

#undef both
#define both 1
	.endc


h_line_xor:						// Y1 = Y2
	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	move.l		a0,a1			// Old a1 value was needed above
	beq		hno_shadow_xor
	move.l		d7,a4
	add.l		d2,a4
	.endc

	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		hl_single_xor

//	move.l		a2,d2
//	and.l		d0,d2
//	move.l		a3,d3
//	and.l		d0,d3
//	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d0,d5
//	or.w		d2,d5
	eor.w		d0,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl3

.for_h3:
	.ifeq	both
//	move.w		a2,(a0)+
	not.w		(a0)+
	.endc
	.ifne	both
	move.w		(a4),d5
	not.w		d5
	move.w		d5,(a0)+
	move.w		d5,(a4)+
	.endc
.shl3:
	dbf		d7,.for_h3

//	move.l		a2,d2
//	and.l		d1,d2
//	move.l		a3,d3
//	and.l		d1,d3
//	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d1,d5
//	or.w		d2,d5
	eor.w		d1,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

.end_h3:
	moveq		#1,d0			// Return as completed
	rts

hl_single_xor:
	and.l		d1,d0
//	move.l		a2,d2
//	and.l		d0,d2
//	move.l		a3,d3
//	and.l		d0,d3
//	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d0,d5
//	or.w		d2,d5
	eor.w		d0,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	moveq		#1,d0			// Return as completed
	rts


	.ifne	both
#undef both
#define both 0

hno_shadow_xor:
	move.l		#0xffff0000,d0
	move.w		d1,d2
	and.w		#0x0f,d2
	lsr.l		d2,d0
	move.w		d0,d7
	swap		d0
	move.w		d7,d0
	not.l		d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc

	move.l		#0xffff8000,d1
	move.w		d3,d2
	and.w		#0x0f,d2
	lsr.l		d2,d1
	move.w		d1,d7
	swap		d1
	move.w		d7,d1
	lsr.w		#4,d3
	lsl.w		#1,d3
	add.w		d3,a1

	cmp.l		a0,a1
	beq		mhl_single_xor

//	move.l		a2,d2
//	and.l		d0,d2
//	move.l		a3,d3
//	and.l		d0,d3
//	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d0,d5
//	or.w		d2,d5
	eor.w		d0,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	move.l		a1,d7
	sub.l		a0,d7
	lsr.w		#1,d7
	bra		.shl4

.for_h4:
	.ifeq	both
//	move.w		a2,(a0)+
	not.w		(a0)+
	.endc
	.ifne	both
	move.w		(a4),d5
	not.w		d5
	move.w		d5,(a0)+
	move.w		d5,(a4)+
	.endc
.shl4:
	dbf		d7,.for_h4

//	move.l		a2,d2
//	and.l		d1,d2
//	move.l		a3,d3
//	and.l		d1,d3
//	not.l		d1

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d1,d5
//	or.w		d2,d5
	eor.w		d1,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

.end_h4:
	moveq		#1,d0			// Return as completed
	rts

mhl_single_xor:
	and.l		d1,d0
//	move.l		a2,d2
//	and.l		d0,d2
//	move.l		a3,d3
//	and.l		d0,d3
//	not.l		d0

	.ifeq	both
	move.w		(a0),d5
	.endc
	.ifne	both
	move.w		(a4),d5
	.endc
//	and.w		d0,d5
//	or.w		d2,d5
	eor.w		d1,d5		// new
	.ifeq	both
	move.w		d5,(a0)+
	.endc
	.ifne	both
	move.w		d5,(a4)+
	move.w		d5,(a0)+
	.endc

	moveq		#1,d0			// Return as completed
	rts


#undef both
#define both	1
	.endc


v_line_xor:						// X1 = X2
	.ifne	both
	move.l		wk_screen_shadow_address(a1),d7
	beq		vno_shadow_xor
	move.l		d7,a4
	add.l		d2,a4
	.endc

	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc
//	move.l		d0,d2
//	move.l		a2,d0
//	and.l		d2,d0
//	move.l		a3,d1
//	and.l		d2,d1
//	not.l		d2

	subq.l		#2,d5
//	bra.s		.svl3

.for_v3:
	.ifeq	both
	move.w		(a0),d3
	.endc
	.ifne	both
	move.w		(a4),d3
	.endc
//	and.w		d2,d3
//	or.w		d0,d3
	eor.w		d0,d3		// new
	.ifeq	both
	move.w		d3,(a0)+
	.endc
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endc
	.ifne	both
	add.l		d5,a4
	.endc

	add.l		d5,a0
.svl3:
	dbf		d6,.for_v3
.end_v3:
	moveq		#1,d0			// Return as completed
	rts


	.ifne	both
#undef both
#define both	0

vno_shadow_xor:
	move.l		#0x80008000,d0
	move.w		d1,d7
	and.w		#0x0f,d7
	lsr.l		d7,d0
	lsr.w		#4,d1
	lsl.w		#1,d1
	add.w		d1,a0
	.ifne	both
	add.w		d1,a4
	.endc
//	move.l		d0,d2
//	move.l		a2,d0
//	and.l		d2,d0
//	move.l		a3,d1
//	and.l		d2,d1
//	not.l		d2

	subq.l		#2,d5
//	bra.s		.svl4

.for_v4:
	.ifeq	both
	move.w		(a0),d3
	.endc
	.ifne	both
	move.w		(a4),d3
	.endc
//	and.w		d2,d3
//	or.w		d0,d3
	eor.w		d0,d3		// new
	.ifeq	both
	move.w		d3,(a0)+
	.endc
	.ifne	both
	move.w		d3,(a4)+
	move.w		d3,(a0)+
	.endc
	.ifne	both
	add.l		d5,a4
	.endc

	add.l		d5,a0
.svl4:
	dbf		d6,.for_v4
.end_v4:
	moveq		#1,d0			// Return as completed
	rts

#undef both
#define both 1
	.endc


	.end
