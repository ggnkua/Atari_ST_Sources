
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "poly.i"

#define SP A7
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
extern struct poly *de_z();
extern mfree();
extern WORD perspective, ground_z, sys_scale, ssc_yoff, ssc_xoff, ssc_zoff;
extern WORD story_xoff, story_yoff;
extern WORD clip_alloc;
extern struct LLpoint *clip_points;
extern struct poly clip_poly;

asm {
de_z:
L44:
	movem.l	D4/D5/D6/D7/A2/A3/A5/A6,-(sp)
L45:
/*
*a0 = poly->pt_list
*a1 = lpoly->pt_list
*a2 = poly
*a3 = lpoly = &z_poly
*a5 - scratch

*d3 = lpoly->pt_count
*d4 = ground_z
*d5 = z
*d6 = ssc_xoff
*d7 = ssc_yoff
*/

	move.l	9*4(sp),a2	;a2 = poly

	move.w  poly_pt_count(a2),d3
	bgt.s   some_pts1
	clr.l	d0
	bra	de_z_return
/*return quickly with NULL if no points*/

some_pts1:
	lea	clip_poly(a4),a3
/*	move.l	#_clip_poly,a3 */
	move.w	d3,d2
	add.w	d2,d2
	addq.w	#4,d2
/*new_size = poly->pt_count*2 + 4*/
	cmp.w	clip_alloc(a4),d2
	ble.s	enough_alloc

/*here we have to allocate some more points*/
	movem.l d2/d3/a6,-(sp)	;save what Aztec C trashes
	move.w	clip_alloc(a4),d0  
	muls	#size_llpoint,d0
	move.w	d0,-(sp)
	move.l	clip_points(a4),-(sp)
	jsr	mfree		;free up the old clip_points array	
	addq #6,sp
	movem.l (sp)+,d2/d3/a6

	movem.l d2/d3/a6,-(sp)	;save what Aztec C trashes
	move.w	d2,d0
	muls	#size_llpoint,d0
	move.w	d0,-(sp)
	jsr	alloc		;allocate the new clip_points
/*alloc(new_size * sizeof(LLpoint) )*/
	addq	#2,sp
	movem.l (sp)+,d2/d3/a6
	move.l	d0,clip_points(a4)
	move.w	d2,clip_alloc(a4)

enough_alloc:
	move.l	a2,a0
	move.l  a3,a1
	move.w  #(size_poly/2)-1,d0
copys1:
	move.w	(a0)+,(a1)+
	dbf	d0,copys1
/*copy_structure(poly, &clip_poly, sizeof(Poly) );*/

	move.l  clip_points(a4),a1
	move.l	a1,poly_clipped_list(a3)
	move.l	poly_pt_list(a2),a0
	move.w	d3,d2
	move.w	ssc_xoff(a4),d6
	move.w	ssc_yoff(a4),d7

	tst.w	perspective(a4)
	beq	no_persp
	move.w	ground_z(a4),d4
	move.w	7*4+4(sp),d5	;d5 = z
main_while:
	subq.w	#1,d2
	ble	end_mwhile

	move.w	point_z(a0),d1
	add.w	ssc_zoff(a4),d1
	cmp.w	D5,D1
	bge.s	nozclip

	subq.w	#1,d3
	addq.l	#size_point,a0
	bra.s	main_while

nozclip:
	cmp.w	d4,d1
	beq.s	L11
L10:
	move.w	(a0)+,d0
	add.w	d6,d0
	subi.l	#160,D0  /*  XMAX/2 */
	muls	d4,d0
	divs	d1,d0
	addi.w	#160,d0
	move.w	d0,(a1)+

	move.w	(a0)+,d0
	add.w	d7,d0
	subi.l	#100,D0  /*  YMAX/2 */
	muls	d4,d0
	divs	d1,d0
	addi.w	#100,d0
	move.w	d0,(a1)+
	bra.s	L9
L11:
	move.w 	(a0)+,d0
	add.w	d6,d0
	move.w	d0,(a1)+
	move.w 	(a0)+,d0
	add.w	d7,d0
	move.w	d0,(a1)+
L9:
	addq	#2,a0		;skip z on source	
	move.w	(a0)+,(a1)+	;copy level
	lea	4(a1),a5
	move.l	a5,(a1)+
	bra	main_while

end_mwhile:
	move.w	point_z(a0),d1
	add.w	ssc_zoff(a4),d1
	cmp.w	D5,D1
	bge.s	nozclipa

	subq.w	#1,d3
	bgt.s   nontriv1
	clr.l	d0
	bra	de_z_return
nontriv1:
	move.l	clip_points(a4),-(a1)
	bra	test_sys_scale
nozclipa:
	cmp.w	d4,d1
	beq.s	L11a
L10a:
	move.w	(a0)+,d0
	add.w	d6,d0
	subi.l	#160,D0  /*  XMAX/2 */
	muls	d4,d0
	divs	d1,d0
	addi.w	#160,d0
	move.w	d0,(a1)+

	move.w	(a0)+,d0
	add.w	d7,d0
	subi.l	#100,D0  /*  YMAX/2 */
	muls	d4,d0
	divs	d1,d0
	addi.w	#100,d0
	move.w	d0,(a1)+
	bra.s	L9a

L11a:
	move.w 	(a0)+,d0
	add.w	d6,d0
	move.w	d0,(a1)+
	move.w 	(a0)+,d0
	add.w	d7,d0
	move.w	d0,(a1)+
L9a:
	addq	#2,a0		;skip z on source	
	move.w	(a0)+,d0	;copy level
	move.w	poly_type(a3),d1
	cmp.w	#JUST_LINE,d1
	bne.s	not_out
	ori.w	#1,d0	;or skip bit into last point's level if JUST_LINE
not_out:
	move.w	d0,(a1)+
	move.l	clip_points(a4),(a1)
	bra.s	test_sys_scale

no_persp:
	subq.w	#1,D2
	ble.s	L37
L34:
	move.w 	(a0)+,d0
	add.w	d6,d0
	move.w	d0,(a1)+	; x = ox + ssc_xoff
	move.w 	(a0)+,d0
	add.w	d7,d0
	move.w	d0,(a1)+	; y = oy + ssc_yoff
	addq.l	#2,a0		;skip z coordinate on source
	move.w	(a0)+,(a1)+	;copy level
	lea	4(a1),a5
	move.l	a5,(a1)+
	bra.s	no_persp
L37:
	move.w 	(a0)+,d0
	add.w	d6,d0
	move.w	d0,(a1)+
	move.w 	(a0)+,d0
	add.w	d7,d0
	move.w	d0,(a1)+	; y = oy + ssc_yoff
	addq.l	#2,a0		;skip z coordinate on source
	move.w	(a0)+,d0	;copy level
	move.w	poly_type(a3),d1
	cmp.w	#JUST_LINE,d1
	bne.s	not_outa
	ori.w	#1,d0	;or skip bit into last point's level if JUST_LINE
not_outa:
	move.w	d0,(a1)+
	move.l	clip_points(a4),(a1)

test_sys_scale:
	tst.w	sys_scale(a4)
	beq.s	sys_scaled
	move.l	clip_points(a4),a1
	move.w	d3,d2
sscale_loop:
	subq.w	#1,D2
	blt.s	sys_scaled
	move.w	(a1),d0
	asr.w	#2,d0
	add.w	story_xoff(a4),d0
	move.w	d0,(a1)+

	move.w	(a1),d0
	asr.w	#2,d0
	add.w	story_yoff(a4),d0
	move.w	d0,(a1)

	addq.l	#8,a1
	bra.s	sscale_loop

sys_scaled:
	move.w	d3,poly_pt_count(a3)
	mulu	#10,d3
	add.l	clip_points(a4),d3
	move.l	d3,free_points(a4)
	move.l	a3,d0

de_z_return:
	movem.l	(sp)+,D4/D5/D6/D7/A2/A3/A5/A6
	rts	
}



