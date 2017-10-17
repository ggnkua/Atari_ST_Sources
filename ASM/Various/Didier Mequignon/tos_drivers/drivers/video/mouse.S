#include "config.h"
#include "vdi.inc"
#include "types.inc"
#include "../../include/fire.h"

	.xref	_me

	.xdef	mouse_draw,_mouse_draw
	.xdef	_mouse_pos


	.text

#ifdef COLDFIRE /* Videl usage */
/*	d0.w	x
*	d1.w	y
*	d2	0 - move shown  1 - move hidden  2 - hide  3 - show  >7 - change shape (pointer to mouse struct)
*/
_mouse_draw:
mouse_draw:
#ifdef COLDFIRE
	move.l	d2,-(a7)
	move.w	hotspot_x,d2
	ext.l	d2
	sub.l	d2,d0
	ext.l	d0
	bpl	.x_positive
	moveq	#0,d0
.x_positive:
	move.w	hotspot_y,d2
	ext.l	d2
	sub.l	d2,d1
	ext.l	d1
	bpl	.y_positive
	moveq	#0,d1
.y_positive:
	move.l	(a7)+,d2
#else
	sub.w	hotspot_x,d0
	bpl	.x_positive
	move.w	#0,d0
.x_positive:
	sub.w	hotspot_y,d1
	bpl	.y_positive
	moveq	#0,d1
.y_positive:
#endif
	swap	d1
	move.w	d0,d1
	move.l	d1,_mouse_pos
	
//	tas	here_already
//	bne	.in_use

	swap	d0

	cmp.l	#8,d2
	bcs	.skip_shape_setup
//	bcc	.shape_setup
//	btst	#4,d0
//	beq	.skip_shape_setup
//	move.l	shape_data,d2
//.shape_setup:
	move.l	d2,a0				// Points to mouse structure
#ifdef COLDFIRE
	move.l	mouse_hotspot(a0),a1
	move.l	a1,hotspot_x	// Both coordinates
#else
	move.l	mouse_hotspot(a0),hotspot_x	// Both coordinates
#endif
	lea	mouse_data(a0),a1
	move.l	a1,cursor
	lea	mouse_mask(a0),a1
	move.l	a1,_mask
	move.l	mouse_colour(a0),d0
	move.l	_me,a0
	move.l	driver_default_vwk(a0),a0
	move.l	vwk_real_address(a0),a1
	move.l	wk_r_get_colour(a1),a1 // Index to real colour
	jsr	(a1)		
	move.l	d0,colour
	bra	.finish
.skip_shape_setup:

#ifdef COLDFIRE
	ext.l	d2		// move shown
	beq	.move
	cmp.l	#1,d2		// mode hidden
	beq	.finish
	cmp.l	#2,d2		// hide
	beq	.restore
	cmp.l	#3,d2		// show 
	beq	.draw
	cmp.l	#4,d2		// Check for forced moves
	beq	.move
	cmp.l	#5,d2
#else
	cmp.w	#0,d2		// move shown
	beq	.move
	cmp.w	#1,d2		// mode hidden
	beq	.finish
	cmp.w	#2,d2		// hide
	beq	.restore
	cmp.w	#3,d2		// show 
	beq	.draw
	cmp.w	#4,d2		// Check for forced moves
	beq	.move
	cmp.w	#5,d2
#endif
	beq	.finish
.restore:
	bsr	restore_mouse
	bra	.finish
.move:
	bsr	restore_mouse
.draw:
	bsr	draw_cursor

.finish:
	moveq	#0,d0
//	clr.b	here_already
.end:
	rts

//.in_use:
//	cmp.l	#7,d2
//	bhi	.wanted_shape
//	bset	d0,d2
//	or.l	#0xffff0000,d0
//	bra	.end

//.wanted_shape:
//	or.l	#0xffff0010,d0
//	move.l	d2,shape_data
//	bra	.end



/* Restore old mouse background */
restore_mouse:
#ifdef COLDFIRE
	lea	-32(a7),a7
	movem.l	d3-d7/a2-a4,(a7)
#else
	movem.l	d3-d7/a2-a4,-(a7)
#endif
	move.l	back_pos,d1
	moveq	#0,d0
	move.w	d1,d0
	swap	d1
	lea	back_buffer,a0	
	move.l	_me,a1
	move.l	driver_default_vwk(a1),a1
	move.l	vwk_real_address(a1),a1
	move.l	back_address,a3
	move.w	d0,d7
	move.w	wk_screen_mfdb_height(a1),d5
#ifdef COLDFIRE
	ext.l	d5
	ext.l	d1
	sub.l	d1,d5
	cmp.l	#16,d5
	bls	.at_bottom_hide
	moveq	#16,d5
.at_bottom_hide:
	subq.l	#1,d5
#else
	sub.w	d1,d5
	cmp.w	#16,d5
	bls	.at_bottom_hide
	moveq	#16,d5
.at_bottom_hide:
	subq.w	#1,d5
#endif
.rows_hide_8:
	moveq	#15,d6
	move.w	d7,d1
#ifdef COLDFIRE
	ext.l	d1
#endif
	move.l	a3,a4
	moveq	#0,d3
	move.w	wk_screen_mfdb_bitplanes(a1),d3	
	cmp.l	#16,d3
	beq.s	.cols_hide_16
	bhi.s	.cols_hide_32	
.cols_hide_8:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.next_8
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	wk_screen_coordinates_max_x(a1),d0
	cmp.l	d0,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.next_8
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.next_8
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.next_8
	move.b	(a0)+,(a4)+
.next_8:
#ifdef COLDFIRE
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_hide_8
	moveq	#0,d0
	move.w	wk_screen_wrap(a1),d0
	lea	(a3,d0.l),a3
	addq.l	#1,d2
	subq.l	#1,d5
	bpl	.rows_hide_8
	movem.l	(a7),d3-d7/a2-a4
	lea	32(a7),a7
#else
	addq.w	#1,d1
	dbra	d6,.cols_hide_8
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_hide_8
	movem.l	(a7)+,d3-d7/a2-a4
#endif
	rts
.rows_hide_16:
	moveq	#15,d6
	move.w	d7,d1
#ifdef COLDFIRE
	ext.l	d1
#endif
	move.l	a3,a4
.cols_hide_16:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.next_16
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	wk_screen_coordinates_max_x(a1),d0
	cmp.l	d0,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.next_16
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.next_16
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.next_16
	move.w	(a0)+,(a4)+
.next_16:
#ifdef COLDFIRE
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_hide_16
	moveq	#0,d0
	move.w	wk_screen_wrap(a1),d0
	lea	(a3,d0.l),a3
	addq.l	#1,d2
	subq.l	#1,d5
	bpl	.rows_hide_16
	movem.l	(a7),d3-d7/a2-a4
	lea	32(a7),a7
#else
	addq.w	#1,d1
	dbra	d6,.cols_hide_16
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_hide_16
	movem.l	(a7)+,d3-d7/a2-a4
#endif
	rts
.rows_hide_32:
	moveq	#15,d6
	move.w	d7,d1
#ifdef COLDFIRE
	ext.l	d1
#endif
	move.l	a3,a4
.cols_hide_32:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.next_32
#ifdef COLDFIRE
	moveq	#0,d0
	move.w	wk_screen_coordinates_max_x(a1),d0
	cmp.l	d0,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.next_32
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.next_32
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.next_32
	move.l	(a0)+,(a4)+
.next_32:
#ifdef COLDFIRE
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_hide_32
	moveq	#0,d0
	move.w	wk_screen_wrap(a1),d0
	lea	(a3,d0.l),a3
	addq.l	#1,d2
	subq.l	#1,d5
	bpl	.rows_hide_32
	movem.l	(a7),d3-d7/a2-a4
	lea	32(a7),a7
#else
	addq.w	#1,d1
	dbra	d6,.cols_hide_32
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_hide_32
	movem.l	(a7)+,d3-d7/a2-a4
#endif
	rts

/* This routine both draws a new cursor and
* moves the background to the backbuffer
*
* In:	d0.w	cursor x-pos
*	d1.w	cursor y-pos
*
* Set d5 to lineoffset
* d6 is a mask used to mask off the cursor on the right side 
*    it is 1 where the cursor should be seen
*/
draw_cursor:
#ifdef COLDFIRE
	lea	-36(a7),a7
	movem.l	d3-d7/a2-a5,(a7)
#else
	movem.l	d3-d7/a2-a5,-(a7)
#endif
	move.l	_mouse_pos,d1
	move.l	d1,back_pos
	moveq	#0,d0
	move.w	d1,d0
	swap	d1
	move.l	_me,a1
	move.l	driver_default_vwk(a1),a1
	move.l	vwk_real_address(a1),a1
	lea	back_buffer,a0
	move.l	_mask,a2
	move.l	cursor,a5	
	move.l	wk_screen_mfdb_address(a1),a3
	move.w	d1,d2
	mulu	wk_screen_wrap(a1),d2
	add.l	d2,a3
	move.w	wk_screen_mfdb_bitplanes(a1),d3
	mulu	d0,d3
	lsr.l	#3,d3
	add.l	d3,a3
	move.w	wk_screen_mfdb_height(a1),d5
#ifdef COLDFIRE
	ext.l	d1
	ext.l	d5
	sub.l	d1,d5
	cmp.l	#16,d5
	bls	.at_bottom
	moveq	#16,d5
.at_bottom:
	subq.l	#1,d5
#else
	sub.w	d1,d5
	cmp.w	#16,d5
	bls	.at_bottom
	moveq	#16,d5
.at_bottom:
	subq.w	#1,d5
#endif
	move.w	d0,d7
	move.w	d1,d2
	move.l	a3,back_address
	move.l	colour,d0
	moveq	#0,d3
	move.w	wk_screen_mfdb_bitplanes(a1),d3
	cmp.l	#16,d3
	beq.s	.rows_show_16
	bhi	.rows_show_32
.rows_show_8:
#ifdef COLDFIRE
	move.l	d5,-(a7)
#endif
	moveq	#15,d6
	move.w	(a2)+,d3
	move.w	(a5)+,d4
	move.w	d7,d1
	move.l	a3,a4
.cols_show_8:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.plotted_8
#ifdef COLDFIRE
	moveq	#0,d5
	move.w	wk_screen_coordinates_max_x(a1),d5
	cmp.l	d5,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.plotted_8
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.plotted_8
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.plotted_8
	move.b	(a4),(a0)+		// Save old data
#ifdef COLDFIRE
	add.l	d3,d3		//  and then write new
	btst	#16,d3
	beq	.no_pixel_8
	add.l	d4,d4
	btst	#16,d4
	beq	.background_8
#else
	add.w	d3,d3		//  and then write new
	bcc	.no_pixel_8
	add.w	d4,d4
	bcc	.background_8
#endif
	move.b       d0,(a4)
	bra	.plotted_8
.background_8:
	swap	d0
	move.b       d0,(a4)
	swap	d0
.plotted_8:
#ifdef COLDFIRE
	lsr.l	#1,d4		// Shift back again
.no_pixel_8:
	addq.l	#1,a4
	add.l	d4,d4		//  to make this possible
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_show_8
	moveq	#0,d5
	move.w 	wk_screen_wrap(a1),d5
	lea	(a3,d5.l),a3
	move.l	(a7)+,d5
	subq.l	#1,d5
	bpl	.rows_show_8
	movem.l	(a7),d3-d7/a2-a5
	lea	36(a7),a7
#else
	lsr.w	#1,d4		// Shift back again
.no_pixel_8:
	addq.w	#1,a4
	add.w	d4,d4		//  to make this possible
	addq.w	#1,d1
	dbra	d6,.cols_show_8
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_show_8
	movem.l	(a7)+,d3-d7/a2-a5
#endif
	rts
.rows_show_16:
#ifdef COLDFIRE
	move.l	d5,-(a7)
#endif
	moveq	#15,d6
	move.w	(a2)+,d3
	move.w	(a5)+,d4
	move.w	d7,d1
	move.l	a3,a4
.cols_show_16:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.plotted_16
#ifdef COLDFIRE
	moveq	#0,d5
	move.w	wk_screen_coordinates_max_x(a1),d5
	cmp.l	d5,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.plotted_16
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.plotted_16
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.plotted_16
	move.w	(a4),(a0)+		// Save old data
#ifdef COLDFIRE
	add.l	d3,d3		//  and then write new
	btst	#16,d3
	beq	.no_pixel_16
	add.l	d4,d4
	btst	#16,d4
	beq	.background_16
#else
	add.w	d3,d3		//  and then write new
	bcc	.no_pixel_16
	add.w	d4,d4
	bcc	.background_16
#endif
	move.w       d0,(a4)
	bra	.plotted_16
.background_16:
	swap	d0
	move.w       d0,(a4)
	swap	d0
.plotted_16:
#ifdef COLDFIRE
	lsr.l	#1,d4		// Shift back again
.no_pixel_16:
	addq.l	#2,a4
	add.l	d4,d4		//  to make this possible
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_show_16
	moveq	#0,d5
	move.w 	wk_screen_wrap(a1),d5
	lea	(a3,d5.l),a3
	move.l	(a7)+,d5
	subq.l	#1,d5
	bpl	.rows_show_16
	movem.l	(a7),d3-d7/a2-a5
	lea	36(a7),a7
#else
	lsr.w	#1,d4		// Shift back again
.no_pixel_16:
	addq.w	#2,a4
	add.w	d4,d4		//  to make this possible
	addq.w	#1,d1
	dbra	d6,.cols_show_16
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_show_16
	movem.l	(a7)+,d3-d7/a2-a5
#endif
	rts
.rows_show_32:
#ifdef COLDFIRE
	move.l	d5,-(a7)
#endif
	moveq	#15,d6
	move.w	(a2)+,d3
	move.w	(a5)+,d4
	move.w	d7,d1
	move.l	a3,a4
.cols_show_32:
//	cmp.w	wk_screen_coordinates_min_x(a1),d1
//	blt	.plotted_32
#ifdef COLDFIRE
	moveq	#0,d5
	move.w	wk_screen_coordinates_max_x(a1),d5
	cmp.l	d5,d1
#else
	cmp.w	wk_screen_coordinates_max_x(a1),d1
#endif
	bgt	.plotted_32
//	cmp.w	wk_screen_coordinates_min_y(a1),d2
//	blt	.plotted_32
//	cmp.w	wk_screen_coordinates_max_y(a1),d2
//	bgt	.plotted_32
	move.l	(a4),(a0)+		// Save old data
#ifdef COLDFIRE
	add.l	d3,d3		//  and then write new
	btst	#16,d3
	beq	.no_pixel_32
	add.l	d4,d4
	btst	#16,d4
	beq	.background_32
#else
	add.w	d3,d3		//  and then write new
	bcc	.no_pixel_32
	add.w	d4,d4
	bcc	.background_32
#endif
	move.l       d0,(a4)
	bra	.plotted_32
.background_32:
	move.l	#0x00ffffff,(a4)
.plotted_32:
#ifdef COLDFIRE
	lsr.l	#1,d4		// Shift back again
.no_pixel_32:
	addq.l	#4,a4
	add.l	d4,d4		//  to make this possible
	addq.l	#1,d1
	subq.l	#1,d6
	bpl	.cols_show_32
	moveq	#0,d5
	move.w 	wk_screen_wrap(a1),d5
	lea	(a3,d5.l),a3
	move.l	(a7)+,d5
	subq.l	#1,d5
	bpl	.rows_show_32
	movem.l	(a7),d3-d7/a2-a5
	lea	36(a7),a7
#else
	lsr.w	#1,d4		// Shift back again
.no_pixel_32:
	addq.w	#4,a4
	add.w	d4,d4		//  to make this possible
	addq.w	#1,d1
	dbra	d6,.cols_show_32
	add.w	wk_screen_wrap(a1),a3
	addq.w	#1,d2
	dbra	d5,.rows_show_32
	movem.l	(a7)+,d3-d7/a2-a5
#endif
	rts

	.lcomm hotspot_x,2
	.lcomm hotspot_y,2
	.lcomm _mask,4
	.lcomm cursor,4
	.lcomm colour,4
//	.lcomm here_already,2
	.lcomm _mouse_pos,4
	.lcomm back_pos,4
//	.lcomm shape_data,4
	.lcomm back_address,4 	// Address at which to replace background
	.lcomm back_buffer,16*16*4	// Maximal backbuffer needed for mouse
				// 2*8*16 words are needed for 8 bpp modes
				// 16*16, words for 16 bpps modes

#endif
