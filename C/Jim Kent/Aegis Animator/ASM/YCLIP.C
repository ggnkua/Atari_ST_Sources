
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
extern struct poly *Yclip();

#define first_param 32
#define poly first_param
#define Y first_param+4

asm {

/*file is same as xclip.asm except for a few changes.  Labels make more sense
*in xclip.
*/

Yclip:
	movem.l	a2/a3/a5/a6/d4/d5/d6,-(sp)
/*pt		=:	a0
*next_pt	=:	a1
*poly 		=: 	a2
*pt_list	=:	a3
*free_points	=:	a6
*last_out	=:	a5

*pt_count	=:	d2
*x		=:	d3
*in		=:	d4
*next_in	=:	d5
*i		=:	d6
*/

	move.l	poly(sp),a2
	move.w	poly_pt_count(a2),d2	;	pt_count
	ble	Yclip_return0

	move.w	Y(sp),d3
	subq.w	#1,d3
	move.l	poly_clipped_list(a2),a3 ;	pt_list
	move.l	free_points(a4),a6

	move.l	a3,a0
	move.w	d2,d6			;	set up counter

xcloop0:	
	cmp.w	llpoint_y(a0),d3
	bgt.s	x_ina
	subq	#1,d6
	ble	Yclip_return0
	move.l	llpoint_next(a0),a0
	bra	xcloop0
/*a0->first in point
*d3 = remaining points to check
*if all points out have returned NULL
*/

x_ina:
	move.l	a0,poly_clipped_list(a2)
	move.l	llpoint_next(a0),a1
	move.w	d2,d6			;	set up counter
	subq	#1,d6

xin_in:
	cmp.w	llpoint_y(a1),d3	;			next_in?
	ble.s	xin_out

	move.l	a1,a0
	move.l	llpoint_next(a1),a1
	dbf	d6,xin_in
	bra	lz

xin_out:
	move.w	llpoint_x(a1),d0
	sub.w	llpoint_x(a0),d0
	bvs	Yclip_return0	; abort on HUGE polygon overflow
	move.w	llpoint_y(a0),d1
	sub.w	d3,d1
	bvs	Yclip_return0	; abort on HUGE polygon overflow
	muls	d1,d0
	move.w	llpoint_y(a0),d1
	sub.w	llpoint_y(a1),d1
	bvs	Yclip_return0	; abort on HUGE polygon overflow
	divs	d1,d0
	add.w	llpoint_x(a0),d0
	move.w	d0,llpoint_x(a6)
	move.w	d3,llpoint_y(a6)
	move.w	llpoint_level(a1),llpoint_level(a6)
	ori.w	#1,llpoint_level(a6)

	move.l	a6,llpoint_next(a0)
	move.l	a6,a5
	lea	size_llpoint(a6),a6
	addq	#1,d2

xout_out:
	move.l	a1,a0
	move.l	llpoint_next(a1),a1
	subq	#1,d6
	subq	#1,d2
	cmp.w	llpoint_y(a1),d3	;			next_in?
	ble.s	xout_out

xout_in:
	move.w	llpoint_x(a0),d0
	sub.w	llpoint_x(a1),d0
	bvs	Yclip_return0	; abort on HUGE polygon overflow
	move.w	llpoint_y(a1),d1
	sub.w	d3,d1
	bvs	Yclip_return0	; abort on HUGE polygon overflow
	muls	d1,d0
	move.w	llpoint_y(a1),d1
	sub.w	llpoint_y(a0),d1
	bvs	Yclip_return0	; abort on HUGE polygon overflow
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
	bge	xin_in

lz:
	move.l	a6,free_points(a4)
	move.w	d2,poly_pt_count(a2)
	move.l	a2,d0

Yclipreturn:
	movem.l	(sp)+,a2/a3/a5/a6/d4/d5/d6
	rts
Yclip_return0:
	clr.l	d0
	bra.s	Yclipreturn

}
