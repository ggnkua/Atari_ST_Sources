

overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "poly.i"

#define sp A7
#define a7 A7
#define a6 A6
#define a5 A5
#define a4 A4
#define a3 A3
#define a2 A2
#define a1 A1
#define a0 A0
#define d7 D7
#define d6 D6
#define d5 D5
#define d4 D4
#define d3 D3
#define d2 D2
#define d1 D1
#define d0 D0

extern struct LLpoint *free_points;
extern struct poly *yclip();

#define first_param 32
#define poly first_param
#define y first_param+4

asm {
yclip:
	movem.l	a2/a3/a5/a6/d4/d5/d6,-(sp)
/*pt		=:	a0
*next_pt	=:	a1
*poly 		=: 	a2
*pt_list	=:	a3
*free_points	=:	a6
*last_out	=:	a5

*pt_count	=:	d2
*y		=:	d3
*in		=:	d4
*next_in	=:	d5
*i		=:	d6
*/

	move.l	poly(sp),a2
	move.w	poly_pt_count(a2),d2		;pt_count
	ble	yclip_return0

	move.w	y(sp),d3
	move.l	poly_clipped_list(a2),a3	;pt_list
	move.l	free_points(a4),a6

	move.l	a3,a0
	move.w	d2,d6			;	set up counter

ycloop0:	
	cmp.w	llpoint_y(a0),d3
	blt.s	y_ina
	subq	#1,d6
	ble	yclip_return0
	move.l	llpoint_next(a0),a0
	bra	ycloop0
/*a0->first in point
*d3 = remaining points to check
*if all points out have returned NULL
*/

y_ina:
	move.l	a0,poly_clipped_list(a2)
	move.l  llpoint_next(a0),a1
	move.w	d2,d6			;	set up counter
	subq	#1,d6

yin_in:
	cmp.w	llpoint_y(a1),d3		;		next_in?
	bge.s	yin_out

	move.l	a1,a0
	move.l	llpoint_next(a1),a1
	dbf	d6,yin_in
	bra	lz

yin_out:
	move.w	llpoint_x(a1),d0
	sub.w	llpoint_x(a0),d0
	bvs	yclip_return0	;on overflow HUGE polygon, abort
	move.w	llpoint_y(a0),d1
	sub.w	d3,d1
	muls	d1,d0
	move.w	llpoint_y(a0),d1
	sub.w	llpoint_y(a1),d1
	bvs	yclip_return0	;on overflow HUGE polygon, abort
	divs	d1,d0
	add.w	llpoint_x(a0),d0
	move.w	d0,llpoint_x(a6)
	move.w	d3,llpoint_y(a6)
	move.w	llpoint_level(a1),llpoint_level(a6)
	tst.w	poly_type(a2)
	beq	stkluge		;a kludge to avoid blank line at top on st
	ori.w	#1,llpoint_level(a6)

stkluge: move.l	a6,llpoint_next(a0)
	move.l	a6,a5
	lea	size_llpoint(a6),a6
	addq	#1,d2

yout_out:
	move.l	a1,a0
	move.l	llpoint_next(a1),a1
	subq	#1,d6
	subq	#1,d2
	cmp.w	llpoint_y(a1),d3		;		next_in?
	bge.s	yout_out

yout_in:
	move.w	llpoint_x(a0),d0
	sub.w	llpoint_x(a1),d0
	bvs	yclip_return0	;on overflow HUGE polygon, abort
	move.w	llpoint_y(a1),d1
	sub.w	d3,d1
	muls	d1,d0
	move.w	llpoint_y(a1),d1
	sub.w	llpoint_y(a0),d1
	bvs	yclip_return0	;on overflow HUGE polygon, abort
	divs	d1,d0
	add.w	llpoint_x(a1),d0
	move.w	d0,llpoint_x(a6)
	move.w	d3,llpoint_y(a6)
	move.w	llpoint_level(a0),llpoint_level(a6)
	move.l	a1,llpoint_next(a6)

	move.l	a6,llpoint_next(a5)
	lea	size_llpoint(a6),a6
	addq	#1,d2

	tst.w	d6
	bge	yin_in

lz:
	move.l	a6,free_points(a4)
	move.w	d2,poly_pt_count(a2)
	move.l	a2,d0

yclipreturn:
	movem.l	(sp)+,a2/a3/a5/a6/d4/d5/d6
	rts
yclip_return0:
	clr.l	d0
	bra.s	yclipreturn
}

