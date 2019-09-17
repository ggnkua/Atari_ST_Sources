********************************************
* SwingShot Demo #2, 09 July 1997          *
* by Jason J Railton for ICTARI User Group *
********************************************

*Only the first set of scenery is provided.  If you want to see the snowy
*scenery, you'll need to copy SWING_F2.NEO and SWING_B2.NEO from the last
*demo, then find the subroutine "check_keyboard" below.  Move down and
*delete the "*"s from in front of the two "beq" statements, to enable
*the "1" and "2" keypresses, then assemble as "SWING_2.PRG" and run that
*instead.

*--------------------------------------------------------------------------
*My standard startup/exit code:
*--------------------------------------------------------------------------

WORKSPACE equ 32256+4096+15654+32128+64000+16000+128000+640+128
	
	include 'startup2.i'
	include 'load.i'	

*See prepare_load below for what all this
*memory is used for.  The 32256 is the back
*screen, the 32128 is a .NEO loading area
*and the rest is for data.

*--------------------------------------------------------------------------
*Macro definitions and usage:
*--------------------------------------------------------------------------
*SPRITE x,y,sprite_column/frame,sprite_row
SPRITE	MACRO
	move.w	\1,d1
	move.w	\2,d2
	move.w	\3,d3
	move.w	\4,d4
	bsr	draw_sprite
	ENDM

*SPRITEX x,y,sprite_column,sprite_row,frame(across)
SPRITEX	MACRO
	move.w	\1,d1
	move.w	\2,d2
	move.w	\3,d3
	move.w	\4,d4
	add.w	\5,d3
	bsr	draw_sprite
	ENDM

*SPRITEY x,y,sprite_column,sprite_row,frame(down)
SPRITEY	MACRO
	move.w	\1,d1
	move.w	\2,d2
	move.w	\3,d3
	move.w	\4,d4
	add.w	\5,d4
	bsr	draw_sprite
	ENDM

*OFFSPRITE x,y,x_offset,y_offset,sprite_column,sprite_row
OFFSPRITE	MACRO
	move.w	\1,d1
	move.w	\2,d2
	add.w	\3,d1
	add.w	\4,d2
	move.w	\5,d3
	move.w	\6,d4
	bsr	draw_sprite
	ENDM

*OFFSPRITEX x,y,x_offset,y_offset,sprite_column,sprite_row,frame(across)
OFFSPRITEX	MACRO
	move.w	\1,d1
	move.w	\2,d2
	add.w	\3,d1
	add.w	\4,d2
	move.w	\5,d3
	move.w	\6,d4
	add.w	\7,d3
	bsr	draw_sprite
	ENDM

*OFFSPRITEY x,y,x_offset,y_offset,sprite_column,sprite_row,frame(down)
OFFSPRITEY	MACRO
	move.w	\1,d1
	move.w	\2,d2
	add.w	\3,d1
	add.w	\4,d2
	move.w	\5,d3
	move.w	\6,d4
	add.w	\7,d4
	bsr	draw_sprite
	ENDM

*PALETTE palette_label
PALETTE	MACRO
	lea	\1,a0
	move.l	#$ffff8260,a1		|
	movem.l	(a0)+,d0-d7		|
	movem.l	d0-d7,-(a1)		Install paltte
	ENDM

*GET_PALETTE palette_pointer
GET_PALETTE MACRO
	move.l	\1,a0
	move.l	#$ffff8260,a1		|
	movem.l	(a0)+,d0-d7		|
	movem.l	d0-d7,-(a1)		Install paltte
	ENDM

*FILL_PALETTE colour
FILL_PALETTE MACRO
	move.l	#$ffff8260,a0
	move.w	\1,d0
	bsr	flood_palette
	ENDM

*MAKE_PALETTE palette_label, colour
MAKE_PALETTE MACRO
	lea	\1+32,a0
	move.w	\2,d0
	bsr	flood_palette
	ENDM

*FILL_RASTERS raster_label
FILL_RASTERS MACRO
	lea	\1,a0
	movem.l	(a0)+,d0-d7/a1-a5
	lea	raster_list+52,a0
	movem.l	d0-d7/a1-a5,-(a0)
	ENDM

*--------------------------------------------------------------------------
*Simple macros:
*--------------------------------------------------------------------------

CLS	MACRO
	bsr	cls
	ENDM
	
SCREEN_SWAP MACRO
	bsr	screen_swap
	ENDM

WAIT_VBI MACRO
	bsr	wait_vbi
	ENDM

INTERROGATE_MOUSE MACRO
	bsr	interrogate_mouse
	ENDM
	
PROCESS_MOUSE MACRO
	bsr	process_mouse
	ENDM
	
	
*--------------------------------------------------------------------------
*File names:	
*--------------------------------------------------------------------------

sprite_file	dc.b	'swing_sp.neo',0
		even

force_file	dc.b	'swing_ft.dat',0
		even

paths_file	dc.b	'swing_pa.dat',0
		even

fore_file_1	dc.b	'swing_f1.neo',0
		even
back_file_1	dc.b	'swing_b1.neo',0
		even

fore_file_2	dc.b	'swing_f2.neo',0
		even
back_file_2	dc.b	'swing_b2.neo',0
		even


***************************************************************************
*Main program:
***************************************************************************

main
	CLS
	SCREEN_SWAP
	CLS

	bsr	prepare_load
	FILL_PALETTE	#$777

	bsr	load_force_table
	FILL_PALETTE	#$567

	bsr	load_path_data
	FILL_PALETTE	#$357

	bsr	load_level_1		

*--------------------------------------------------------------------------
*Initialise system:
*--------------------------------------------------------------------------
initialise
	bsr	load_sprites		Load sprite screen
	bsr	setup_mouse
	bsr	install_rasters

*--------------------------------------------------------------------------
*Initialise variables:
*--------------------------------------------------------------------------

	bsr	reset_puck
	bsr	reset_ball
	bsr	reset_baddies
	
	bsr	reset_fore
	bsr	reset_back
	
*--------------------------------------------------------------------------
*Enter main loop:
*--------------------------------------------------------------------------

	CLS
	bsr	paint_back
	
	SCREEN_SWAP
	WAIT_VBI
	PALETTE	full_palette

	INTERROGATE_MOUSE
	st.b	mouse_called

main_loop	
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	PROCESS_MOUSE
	clr.b	mouse_called

	bsr	process_puck
	bsr	process_ball

	bsr	scroll_left
	
	SPRITE puck_x,puck_y,puck_frame,puck_seq
	SPRITE ball_x,ball_y,ball_frame,#4
	
	clr.w	baddies_free		|For counting vacant baddie slots.
	move.l	#baddie_var,a0		|First baddie slot.
	move.w	#7,d0			|Maximum 7 baddies, in loop counter.
draw_baddies_loop
	tst.b	(a0)			|Does baddie exist?
	bne	skip_baddie_free	|If it does, skip this bit...

baddie_free
	tst.w	baddies_req		|Are baddies required?
	bgt	insert_baddie		|If so, go and insert one.
	addq.w	#1,baddies_free		|If not, count this one for later.
	bra	baddie_done		|And that's this slot done.
		
insert_baddie
	subq.w	#1,baddies_req		|One less baddie waiting for a slot.
	
	move.w	#$ff00,(a0)		|Exists=True, Exploding=False
	move.w	baddie_frame,8(a0)	|Set first animation frame.
	addq.w	#1,baddie_frame		|Each baddie is introduced with the
	and.w	#$f,baddie_frame	|next animation frame.

	move.w	baddie_sprite,6(a0)	|Define the new baddie's sprite.

	move.w	baddie_path,d1		|Get it's flight path number.
	 add.w	d1,d1			 |(This code doubles the path
	 or.w	#$0001,d1		 |number, then adds 1 for every
	 move.w	d0,d2			 |other baddie, so they use
	 and.w	#$0001,d2		 |the flight paths in pairs).
	 eor.w	d2,d1			 |
	add.w	d1,d1			|
	move.l	path_data,a1		|Get the address of the path data.
	move.w	0(a1,d1),d2		|Offsets to start of specific path,
	move.w	2(a1,d1),d3		|and to end (where next path starts).
	lea	0(a1,d2),a2		|
	lea	0(a1,d3),a3		|Calculate start and end addresses.
	move.l	a2,10(a0)		|Store path start address.
	sub.w	baddie_delay,a2		|Wind back to delay sprite.
	move.l	a2,14(a0)		|Store wound back start point.
	move.l	a3,18(a0)		|Store path end address.
	
	add.w	#48,baddie_delay	|Wind next sprite back 12 steps.
skip_baddie_free

	tst.b	1(a0)			|Is baddie exploding?
	bne	exploding_baddie	|If so, do that.  Otherwise...

animate_baddie
	addq.w	#1,8(a0)		|
	and.w	#$f,8(a0)		|Advance sprite frame (0-15).

move_baddie
	move.l	14(a0),a1		|Get path pointer.
	move.w	(a1)+,2(a0)		|
	move.w	(a1)+,4(a0)		|Read X/Y co-ords from path.
	move.l	a1,14(a0)		|Get start of path.
	cmp.l	10(a0),a1		|Check path has started.
	ble	skip_draw_baddie	|If still wound back, skip.
	cmp.l	18(a0),a1		|Check against path end.
	blt	skip_cancel_baddie	|If not reached, skip this bit...

cancel_baddie
	clr.w	(a0)			|Exists=False, Exploding=False
skip_cancel_baddie

test_dead_baddie
	move.w	2(a0),d1		|
	move.w	4(a0),d2		|Get baddie co-ordinates.
	sub.w	ball_x,d1		|
	sub.w	ball_y,d2		|Calculate distance from ball.
	cmp.w	#-12,d1			|
	blt	no_dead_baddie		|
	cmp.w	#12,d1			|
	bgt	no_dead_baddie		|
	cmp.w	#-12,d2			|
	blt	no_dead_baddie		|
	cmp.w	#12,d2			|
	bgt	no_dead_baddie		|Check X and Y within range.
	move.w	#$ffff,(a0)		|Exists=True, Exploding=True
	clr.l	6(a0)			|Clear sprite and frame numbers.
	bra	exploding_baddie	|first frame of the explosion.
no_dead_baddie

draw_baddie
	movem.l	d0/a0,-(a7)
	SPRITE 2(a0),4(a0),8(a0),6(a0)
	movem.l	(a7)+,d0/a0

skip_draw_baddie
	bra	baddie_done

exploding_baddie
	movem.l	d0/a0,-(a7)		|Draw explosion frame.
	SPRITE 2(a0),4(a0),#19,8(a0)	
	movem.l	(a7)+,d0/a0		|
	addq.w	#1,8(a0)		|Animate explosion.
	cmp.w	#12,8(a0)		|Test for last frame.
	blt	baddie_done		|
	clr.w	(a0)			|Exists=False, Exploding=False
	
baddie_done
	lea	22(a0),a0		|For the next baddie slot.

check_mouse_timing
	tst.b	mouse_called		|
	bne	mouse_skip_in_loop	|
	lea	mouse_trigger,a5	|
	move.l	raster_store,a6		|
	cmp.l	a5,a6			|Request a mouse packet when the
	blt	mouse_skip_in_loop	|rasters reach a certain point.
	INTERROGATE_MOUSE		
	st.b	mouse_called		|Mark it as done this cycle.
mouse_skip_in_loop

	dbf	d0,draw_baddies_loop	

	tst.w	baddie_delay		|
	ble	baddie_delay_0		|
reset_baddie_delay
	subq.w	#4,baddie_delay		|Wind forward the baddie delay.
baddie_delay_0
	

	cmp.w	#8,baddies_free		|Are 8 or more slots free?	
	blt	not_enough_free		|
	tst.w	baddies_req		|And are we not inserting any
	bne	not_enough_free		|baddies at the moment?

new_baddie_seq
	move.w	baddie_sprite,d1	|If both OK, advance the
	addq.w	#1,d1			|baddie sprite,...
	cmp.w	#9,d1			|
	ble	baddie_sprite_in_9	|
	moveq.w	#5,d1			|
baddie_sprite_in_9		
	move.w	d1,baddie_sprite	|

	clr.w	baddie_frame		|...reset the animation frame...
	
	addq.w	#1,baddie_path		|...and advance the path number.
	cmp.w	#9,baddie_path		|
	blt	no_reset_path		|
	clr.w	baddie_path		|
no_reset_path

	clr.w	baddie_delay		|Clear the windback counter.
	move.w	#8,baddies_req		|Signal for 8 new baddies.
not_enough_free


	SCREEN_SWAP
	

	tst.b	mouse_called		|If the mouse hasn't been
	bne	mouse_was_in_loop	|interrogated yet, do so...
	lea	mouse_trigger,a5	|
wait_interrogate
	move.l	raster_store,a6		|
	cmp.l	a5,a6			|
	blt	wait_interrogate	|
	INTERROGATE_MOUSE		|
	st.b	mouse_called		|
mouse_was_in_loop

	WAIT_VBI	

	bsr	paint_back		|Background for next frame.
	
	bsr	check_keyboard

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	bra	main_loop

*--------------------------------------------------------------------------
*Flags:
*--------------------------------------------------------------------------

mouse_called	ds.w	1

*--------------------------------------------------------------------------
*Variables:
*--------------------------------------------------------------------------

puck_x		ds.w	1
puck_y		ds.w	1
puck_dx		ds.w	1
puck_dy		ds.w	1
puck_frame	ds.w	1
puck_seq	ds.w	1
magnet_on	ds.w	1
dive_timer	ds.w	1

ball_x		ds.l	1
ball_y		ds.l	1
ball_dx		ds.l	1
ball_dy		ds.l	1
ball_frame	ds.w	1

baddie_sprite	ds.w	1
baddie_path	ds.w	1
baddie_frame	ds.w	1
baddie_delay	ds.w	1

baddie_var	ds.b	22*16	|Ex.b, Expl.b, X.w, Y.w, Sprite.w, Frame.w,
*				|PathStart.l, PathPointer.l, PathEnd.l
baddies_free	ds.w	1
baddies_req	ds.w	1

*--------------------------------------------------------------------------
*Loaded data pointers:
*--------------------------------------------------------------------------

force_table	ds.l	1

path_data	ds.l	1

loading_area	ds.l	1
loaded_palette	ds.l	1
loaded_screen	ds.l	1

sprite_screen	ds.l	1

foreground	ds.l	1
background	ds.l	1
horizon		ds.l	1
moon		ds.l	1

backgrnd_store	ds.l	1

*--------------------------------------------------------------------------
*Small data space:
*--------------------------------------------------------------------------

full_palette	ds.w	16


***************************************************************************
check_keyboard
***************************************************************************
	move.w	#2,-(a7)		|
	move.w	#1,-(a7)		|
	trap	#13			|
	addq.l	#4,a7			|Bconstat
	tst.w	d0			|Check keyboard input status
	beq	no_keys
	
	move.w	#2,-(a7)		|
	move.w	#2,-(a7)		|
	trap	#13			|
	addq.l	#4,a7			|Bconin
	swap	d0			|Get key scancode
	
test_ESC
	cmp.b	#$01,d0
	beq	terminate

test_1
	cmp.b	#$02,d0
*	beq	switch_level_1
	
test_2
	cmp.b	#$03,d0
*	beq	switch_level_2
	
no_keys
	rts

*--------------------------------------------------------------------------
*Termination:
*--------------------------------------------------------------------------

terminate
	bra	exit


*--------------------------------------------------------------------------
*Switch scenery:
*--------------------------------------------------------------------------
switch_level_1
	bsr	install_vbi	(Disables rasters)

	CLS
	SCREEN_SWAP
	CLS

	bsr	load_level_1
	
	bra	initialise	

*--------------------------------------------------------------------------
switch_level_2
	bsr	install_vbi	(Disables rasters)

	CLS
	SCREEN_SWAP
	CLS

	bsr	load_level_2
	
	bra	initialise	


***************************************************************************
prepare_load
***************************************************************************
	move.l	m_block,a0

	add.w	#32256,a0
	move.l	a0,force_table

	add.w	#4096,a0
	move.l	a0,path_data

	add.w	#15654,a0
	move.l	a0,loading_area

	add.w	#4,a0
	move.l	a0,loaded_palette
	add.w	#124,a0
	move.l	a0,loaded_screen
	move.l	a0,sprite_screen

	add.w	#32000,a0
	move.l	a0,foreground

	add.l	#64000,a0
	move.l	a0,backgrnd_store
	
	add.l	#16000,a0
	move.l	a0,background
	
	add.l	#128000,a0
	move.l	a0,horizon

	add.w	#640,a0
	move.l	a0,moon

	rts


***************************************************************************
load_force_table
***************************************************************************
	LOAD force_file,force_table,4096

	tst.b	d0		|
	blt	exit		Check for a good load

	rts


*The force table is a small map used to repel
*the ball when it gets close to the puck.


***************************************************************************
load_path_data
***************************************************************************
	LOAD paths_file,path_data,15654

	tst.b	d0		|
	blt	exit		Check for a good load

	rts


***************************************************************************
load_sprites
***************************************************************************
	LOAD sprite_file,loading_area,32128

	tst.b	d0		|
	blt	exit		Check for a good load

	bsr	extract_sprites
	
	rts


***************************************************************************
load_level_1
***************************************************************************
	MAKE_PALETTE	full_palette,#$327
	CLS

	FILL_PALETTE	#$237

	LOAD back_file_1,loading_area,32128
	tst.b	d0		|
	blt	exit		Check for a good load
	bsr	extract_back

	FILL_PALETTE	#$226

	LOAD fore_file_1,loading_area,32128
	tst.b	d0		|
	blt	exit		Check for a good load
	bsr	extract_fore

	FILL_PALETTE	#$224

	FILL_RASTERS	level_1_rasters

	rts


level_1_rasters
	dc.w	$223,$223,$224,$224,$225,$226,$236,$346,$456,$666,$765
	dc.w	$766,$755
	dc.w	$010,$110,$110,$110,$110,$110,$110,$110,$110,$110,$110,$110
	dc.w	$110

***************************************************************************
load_level_2
***************************************************************************
	MAKE_PALETTE	full_palette,#$327
	CLS

	FILL_PALETTE	#$237

	LOAD back_file_2,loading_area,32128
	tst.b	d0		|
	blt	exit		Check for a good load
	bsr	extract_back

	FILL_PALETTE	#$226

	LOAD fore_file_2,loading_area,32128
	tst.b	d0		|
	blt	exit		Check for a good load
	bsr	extract_fore

	FILL_PALETTE	#$224

	FILL_RASTERS	level_2_rasters

	rts


level_2_rasters
	dc.w	$237,$237,$237,$237,$347,$347,$457,$567,$677,$777,$766
	dc.w	$755,$744
	dc.w	$666,$666,$014,$015,$015,$016,$016,$016,$016,$016,$016,$016
	dc.w	$016


***************************************************************************
reset_puck
***************************************************************************
	move.w	#128,puck_x
	move.w	#92,puck_y
	clr.w	puck_dx
	clr.w	puck_dy
	clr.w	puck_frame
	clr.w	puck_seq
	clr.b	magnet_on
	clr.w	dive_timer
	
	rts

	
***************************************************************************
reset_ball
***************************************************************************
	move.w	#184,ball_x
	clr.w	ball_x+2
	move.w	#92,ball_y
	clr.w	ball_y+2
	clr.l	ball_dx
	clr.l	ball_dy
	clr.w	ball_frame

	rts

	
***************************************************************************
reset_baddies
***************************************************************************
	move.w	#5,baddie_sprite
	clr.w	baddie_path
	clr.w	baddie_frame
	clr.w	baddie_delay
	clr.w	baddies_req

	move.l	#baddie_var,a0
	move.w	#(22*4)-1,d0
reset_baddies_loop
	clr.l	(a0)+
	dbf	d0,reset_baddies_loop

	rts

	
***************************************************************************
process_puck
***************************************************************************
	addq.w	#1,puck_frame		|
	and.w	#$f,puck_frame		|Animate

	tst.w	dive_timer		|
	ble	dive_timer_ok		|
	subq.w	#1,dive_timer		|Decrement counter after a dive.
dive_timer_ok
	
	moveq.w	#5,d2			|Maximum change in speed allowed.
check_x_accel	
	move.w	dx_mouse,d0		|Get mouse X-movement.
	sub.w	puck_dx,d0		|Subtract current puck X-velocity.
	beq	x_accel_done		|If no difference, no speed change.
	blt	neg_x_accel		|
pos_x_accel
	cmp.w	d2,d0			|
	ble	pos_x_accel_in		|Check speed change against limit.
	move.w	d2,d0			|Limit it accordingly.
pos_x_accel_in
	add.w	d0,puck_dx		|Speed up by calculated difference.
	bra	x_accel_done		|
neg_x_accel
	neg.w	d0			|
	cmp.w	d2,d0			|
	ble	neg_x_accel_in		|
	move.w	d2,d0			|
neg_x_accel_in	
	sub.w	d0,puck_dx		|Same, in the opposite direction.
x_accel_done

check_y_accel
	move.w	dy_mouse,d0		|
	sub.w	puck_dy,d0		|
	beq	y_accel_done		|
	blt	neg_y_accel		|
pos_y_accel
	cmp.w	d2,d0			|
	ble	pos_y_accel_in		|
	move.w	d2,d0			|
pos_y_accel_in
	add.w	d0,puck_dy		|
	bra	y_accel_done		|Same in positive Y direction.
neg_y_accel
	neg.w	d0			|
	cmp.w	d2,d0			|
	ble	neg_y_accel_in		|
	move.w	d2,d0			|
neg_y_accel_in
	sub.w	d0,puck_dy		|And in negative Y direction.
y_accel_done
	

move_puck
	move.w	puck_x,d0		|
	move.w	puck_y,d1		|
	add.w	puck_dx,d0		|
	add.w	puck_dy,d1		|Move by current speed.
	
check_puck_x
	tst.w	d0			|
	bge	puck_on_left		|
	moveq.w	#0,d0			|
	clr.w	puck_dx			|
puck_on_left
	cmp.w	#304,d0			|
	ble	puck_on_right		|
	move.w	#304,d0			|Check against left/right screen
	clr.w	puck_dx			|edges.
puck_on_right		
	move.w	d0,puck_x		|

check_puck_y
	tst.w	d1			|
	bge	puck_on_top		|
	moveq.w	#0,d1			|
	clr.w	puck_dy			|
puck_on_top
	cmp.w	#184,d1			|
	ble	puck_on_bottom		|
	move.w	#184,d1			|
	clr.w	puck_dy			|
puck_on_bottom		
	move.w	d1,puck_y		|Top/bottom edge.

check_puck_mode
	cmp.w	#1,puck_seq
	bne	check_diving
	tst.w	puck_frame
	bne	check_diving
	clr.w	puck_seq

check_diving
	cmp.w	#3,puck_seq
	beq	diving

test_dive
	tst.b	right_click
	beq	no_dive
	clr.b	right_click
	tst.w	dive_timer
	bne	no_dive
	move.w	#3,puck_seq
	clr.w	puck_frame
	clr.b	magnet_on
	move.w	#250,dive_timer
no_dive
		
	cmp.w	#2,puck_seq
	beq	still_open		

test_open
	tst.b	left_mouse
	beq	no_open

	tst.w	puck_seq
	bne	still_open
	
	move.w	#1,puck_seq
	clr.w	puck_frame
	st.b	magnet_on
no_open
	bra	puck_checked

diving
	tst.w	puck_frame
	bne	puck_checked
	clr.w	puck_seq
	bra	puck_checked
	
still_open
	cmp.w	#7,puck_frame
	blt	still_opening
	move.w	#2,puck_seq
still_opening
	tst.b	left_mouse
	beq	close_puck
	
	move.w	puck_x,d0
	move.w	puck_y,d1
	sub.w	ball_x,d0
	sub.w	ball_y,d1
	and.w	#$fffe,d0
	and.w	#$fffe,d1
	ext.l	d0
	ext.l	d1
	move.w	#12,d2
	asl.l	d2,d0
	asl.l	d2,d1
	add.l	d0,ball_dx
	add.l	d1,ball_dy
	
	bra	puck_checked
close_puck
	move.w	#8,puck_frame
	move.w	#1,puck_seq
	clr.b	magnet_on
puck_checked
	
	rts
	

***************************************************************************
process_ball
***************************************************************************
	addq.w	#1,ball_frame
	and.w	#$f,ball_frame

force_ball
	cmp.w	#3,puck_seq	|If puck is in a dive, ball will not be
	beq	no_force	|forced away.
	move.w	ball_x,d0	|If it is...
	move.w	ball_y,d1	|
	sub.w	puck_x,d0	|
	sub.w	puck_y,d1	|
	add.w	#31,d0		|
	blt	no_force	|
	add.w	#31,d1		|
	blt	no_force	|
	cmp.w	#62,d0		|
	bgt	no_force	|
	cmp.w	#62,d1		|
	bgt	no_force	|Check ball is close enough to be on table.
	and.w	#$fffe,d0	|Round off last bit of offset -
	and.w	#$fffe,d1	|(divide by 2, effectively).
	asl.w	#1,d0		|(X*4, effectively).
	asl.w	#6,d1		|(Y*128, effectively).
	add.w	d1,d0		|
	move.l	force_table,a0	|
	add.w	d0,a0		|Calculate address in force table.
	move.w	(a0)+,d0	|
	move.w	(a0),d1		|Get 16-bit forces.
	ext.l	d0		|
	ext.l	d1		|Make 32-bit...
	move.w	#4,d2		|
	asl.l	d2,d0		|
	asl.l	d2,d1		|And multiply up.
	add.l	d0,ball_dx	|
	add.l	d1,ball_dy	|Add to velocity, to move ball.
no_force

move_ball
	move.l	ball_x,d0	|
	move.l	ball_y,d1	|
	move.l	ball_dx,d2	|
	move.l	ball_dy,d3	|
	add.l	d2,d0		|
	add.l	d3,d1		|Move ball (32-bit co-ords).

slow_ball
	move.l	d2,d4		|
	move.l	d3,d5		|Get speed of ball.
	asr.l	#5,d4		|
	asr.l	#5,d5		|Divide down.
	sub.l	d4,d2		|
	sub.l	d5,d3		|Subtract, to slow ball gradually.

check_ball_x
	tst.l	d0		|Check ball against right edge of screen.
	bge	ball_on_left	|
	clr.l	d0		|Clip to left edge, and reverse velocity
	neg.l	d2		|to bounce off that edge.
ball_on_left
	cmp.l	#304*$10000,d0	|Right edge...
	ble	ball_on_right	|
	move.l	#304*$10000,d0	|
	neg.l	d2		|
ball_on_right

check_ball_y
	tst.l	d1		|Top edge...
	bge	ball_on_top	|
	clr.l	d1		|
	neg.l	d3		|
ball_on_top
	cmp.l	#184*$10000,d1	|Bottom edge...
	ble	ball_on_bottom	|
	move.l	#184*$10000,d1	|
	neg.l	d3		|
ball_on_bottom

	move.l	d0,ball_x
	move.l	d1,ball_y
	move.l	d2,ball_dx
	move.l	d3,ball_dy

	rts
	

***************************************************************************
cls
***************************************************************************
* Move to the back screen, and clear it.

	move.l	back,a0
	move.l	a0,logic
	add.w	#32000,a0
	move.w	#799,d0

	moveq.l	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	
cls_loop
	movem.l	d1-d6/a1-a4,-(a0)
	dbf	d0,cls_loop
	
	rts


***************************************************************************
scroll_left
***************************************************************************
	move.w	foreground_shift,d0
	addq.w	#4,d0
	cmp.w	#320,d0
	blt	fg_shifted
	clr.w	d0
fg_shifted
	move.w	d0,foreground_shift
	

	move.w	background_shift,d0
	addq.w	#1,d0
	cmp.w	#640,d0
	blt	bk_shifted
	clr.w	d0
bk_shifted
	move.w	d0,background_shift
	move.w	d0,d3
	and.w	#$fff0,d0
	and.w	#$000f,d3

	
scroll_back_right_col
	move.l	backgrnd_store,a0
	move.l	a0,a1
	move.l	background,a2
	move.w	d3,d4
	mulu	#8000,d4
	add.l	d4,a2

		
	asr.w	#2,d0
	add.w	#76,d0
check_right_on_back_store1
	cmp.w	#160,d0
	blt	right_on_back_store1
	sub.w	#160,d0
right_on_back_store1

	move.w	d0,d1
	addq.w	#4,d1
check_right_on_back_store2
	cmp.w	#160,d1
	blt	right_on_back_store2
	sub.w	#160,d1
right_on_back_store2

	move.w	d0,d2
	cmp.w	#80,d2
	blt	right_on_back1
	sub.w	#80,d2
right_on_back1

	add.w	d0,a0
	add.w	d1,a1
	add.w	d2,a2

	move.w	#99,d4
scroll_right_col
	move.w	(a1)+,d5
	swap	d5
	move.w	(a0)+,d5
	rol.l	d3,d5
	move.w	d5,(a2)+
	move.w	(a1),d5
	swap	d5
	move.w	(a0),d5
	rol.l	d3,d5
	move.w	d5,(a2)
	
	add.w	#158,a0
	add.w	#158,a1
	add.w	#78,a2
	dbf	d4,scroll_right_col
	
	rts
	
	
*--------------------------------------------------------------------------

foreground_shift	ds.w	1
background_shift	ds.w	1


***************************************************************************
paint_back
***************************************************************************
	move.l	back,a0
	move.l	a0,logic

	move.l	foreground,a1
		
	move.w	foreground_shift,d0
check_fg_shift
	cmp.w	#320,d0
	blt	fg_shift_lt_320
dec_fg_shift
	sub.w	#320,d0
	cmp.w	#320,d0
	bge	dec_fg_shift
fg_shift_lt_320
	move.w	d0,d1
	and.w	#$000c,d0
	mulu	#4000,d0
	add.l	d0,a1
	and.w	#$01f0,d1
	asr.w	#2,d1
	add.w	d1,a1
	neg.w	d1		|d1 = offset for modifying


	move.l	background,a2
	
	move.w	background_shift,d0
	cmp.w	#320,d0
	blt	bk_shift_lt_320
	sub.w	#320,d0
bk_shift_lt_320
	move.w	d0,d2
	and.w	#$000f,d0
	mulu	#8000,d0
	add.l	d0,a2
	and.w	#$01f0,d2
	asr.w	#2,d2
	add.w	d2,a2
	neg.w	d2		|d2 = offset for modifying


	cmp.w	d1,d2
	bge	d2_plus
d1_plus	
	addq.w	#4,d1
	bra	self_modify
d2_plus	
	addq.w	#4,d2


self_modify
	lea	end_paint_back_loop1,a3
	move.l	paint_sub_1,0(a3,d1.w)
	move.l	paint_sub_2,0(a3,d2.w)
	lea	end_paint_back_loop2,a4
	move.l	paint_sub_1,0(a4,d1.w)
	move.l	paint_sub_2,0(a4,d2.w)


	move.w	#99,d0
	
paint_back_loop
paint_line_1
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
end_paint_back_loop1
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+

	add.w	#80,a1

paint_line_2
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
end_paint_back_loop2
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a2)+,(a0)+

	add.w	#80,a1
	add.w	#80,a2

	dbf	d0,paint_back_loop

paint_lines_done
	move.l	paint_copy,0(a3,d1.w)
	move.l	paint_copy,0(a3,d2.w)
	move.l	paint_copy,0(a4,d1.w)
	move.l	paint_copy,0(a4,d2.w)


	move.l	logic,a0
	add.w	#4508,a0
	move.l	moon,a1
	move.w	#31,d0
or_moon
	movem.w	(a1)+,d1-d2
	move.w	2(a0),d3
	not.w	d3
	and.w	d3,d1
	
	move.w	10(a0),d3
	not.w	d3
	and.w	d3,d2
	
	or.w	d1,(a0)+
	or.w	d1,(a0)
	
	or.w	d2,6(a0)
	or.w	d2,8(a0)
	
	add.w	#158,a0
	dbf	d0,or_moon


	move.l	logic,a0
	add.w	#14086,a0
	move.l	horizon,a1
	move.w	#15,d0
or_horizon
	movem.w	(a1)+,d1-d5
	or.w	d1,(a0)
	or.w	d2,8(a0)
	or.w	d3,16(a0)
	or.w	d4,24(a0)
	or.w	d5,32(a0)
	movem.w	(a1)+,d1-d5
	or.w	d1,40(a0)
	or.w	d2,48(a0)
	or.w	d3,56(a0)
	or.w	d4,64(a0)
	or.w	d5,72(a0)
	movem.w	(a1)+,d1-d5
	or.w	d1,80(a0)
	or.w	d2,88(a0)
	or.w	d3,96(a0)
	or.w	d4,104(a0)
	or.w	d5,112(a0)
	movem.w	(a1)+,d1-d5
	or.w	d1,120(a0)
	or.w	d2,128(a0)
	or.w	d3,136(a0)
	or.w	d4,144(a0)
	or.w	d5,152(a0)

	add.w	#160,a0
	dbf	d0,or_horizon	

	rts


paint_copy	move.l	(a1)+,(a0)+
		move.l	(a2)+,(a0)+

paint_sub_1	sub.w	#80,a1
paint_sub_2	sub.w	#80,a2


***************************************************************************
flood_palette
***************************************************************************
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,-(a0)
	movem.l	d0-d3,-(a0)
	
	rts

***************************************************************************
extract_fore
***************************************************************************
	move.l	loaded_palette,a0
	lea	full_palette,a1
	move.w	(a0),(a1)	|Colour  0/ 0
	move.w	2(a0),2(a1)	|        1/ 1
	move.w	4(a0),4(a1)	|        2/ 2
	move.w	16(a0),16(a1)	|Colour  8/ 8
	move.w	18(a0),18(a1)	|        9/ 9
	move.w	20(a0),20(a1)	|       10/10
	move.w	24(a0),24(a1)	|Colour 12/12
	move.w	26(a0),26(a1)	|       13/13
	move.w	28(a0),28(a1)	|       14/14
	
	move.l	loaded_screen,a0
	move.l	foreground,a1
	move.w	#3999,d0
extract_fore_loop
	move.l	(a0),(a1)+
	addq.l	#8,a0
	dbf	d0,extract_fore_loop

	rts


***************************************************************************
extract_back
***************************************************************************
	move.l	loaded_palette,a0
	lea	full_palette,a1
	move.w	6(a0),6(a1)	|Colour  0/ 3
	move.w	22(a0),22(a1)	|Colour  8/11
	move.w	30(a0),30(a1)	|Colour 12/15
		

	move.l	loaded_screen,a0
	add.w	#14726,a0
	move.l	horizon,a1
	move.l	moon,a2
	move.w	#15,d0
store_moon_horizon
	move.w	(a0),(a2)
	move.w	8(a0),2(a2)
	move.w	16(a0),64(a2)
	move.w	24(a0),66(a2)
	add.w	#4,a2
	add.w	#32,a0

	move.w	96(a0),(a1)+
	move.w	104(a0),(a1)+
	move.w	112(a0),(a1)+
	move.w	120(a0),(a1)+
	move.w	#15,d1
store_horizon_line
	move.w	(a0),(a1)+
	addq.w	#8,a0
	dbf	d1,store_horizon_line

	dbf	d0,store_moon_horizon


	move.l	loaded_screen,a0
	addq.l	#4,a0
	move.l	a0,a1
	add.w	#17280,a1

	move.l	backgrnd_store,a2

	move.w	#91,d0
store_back_loop

	move.w	#19,d1
store_left_line
	move.l	(a0),(a2)+
	addq.l	#8,a0
	dbf	d1,store_left_line
	move.w	#19,d1
store_right_line
	move.l	(a1),(a2)+
	addq.l	#8,a1
	dbf	d1,store_right_line
	dbf	d0,store_back_loop	

	move.l	a2,a0
	sub.w	#160,a0
	move.w	#319,d0
dup_8_lines
	move.l	(a0)+,(a2)+
	dbf	d0,dup_8_lines

	rts
	

***************************************************************************
reset_back
***************************************************************************
	clr.w	background_shift

	move.l	backgrnd_store,a0
	move.l	background,a1
	move.w	#99,d0
reset_back_lines
	move.w	#19,d1
reset_back_line
	move.l	(a0)+,(a1)+
	dbf	d1,reset_back_line
	add.w	#80,a0
	dbf	d0,reset_back_lines	

	move.l	background,a0
	move.l	a0,a1
	add.w	#8000,a1

	move.w	#14,d0
copy_back_loop

	move.w	#15,d3
	sub.w	d0,d3

	move.w	#1999,d1
copy_one_back_loop
	move.l	(a0)+,(a1)+
	dbf	d1,copy_one_back_loop

	move.l	a1,a2
	move.l	backgrnd_store,a3
	add.w	#80,a3

	move.w	#99,d1
bscroll_lines_loop

	move.w	#19,d2
	move.w	(a3)+,d4
	roxl.w	d3,d4
bscroll_1_line_loop
	subq.w	#2,a2
	roxl.w	-(a2)
	dbf	d2,bscroll_1_line_loop

	add.w	#82,a2

	move.w	#19,d2
	move.w	(a3),d4
	roxl.w	d3,d4
bscroll_2_line_loop
	subq.w	#2,a2
	roxl.w	-(a2)
	dbf	d2,bscroll_2_line_loop

	subq.w	#2,a2

	add.w	#158,a3

	dbf	d1,bscroll_lines_loop		
	
	dbf	d0,copy_back_loop
	
	rts

***************************************************************************
reset_fore
***************************************************************************
	clr.w	foreground_shift
	
	move.l	foreground,a0
	move.l	a0,a1
	add.w	#16000,a1
	move.w	#2,d0
copy_fores


	move.w	#3999,d1
copy_fore
	move.l	(a0)+,(a1)+
	dbf	d1,copy_fore


	move.w	#3,d1
fscroll_once

	move.l	a1,a2
	
	move.w	#199,d3
fscroll_lines

	move.w	-80(a2),d4
	roxl.w	#1,d4
	move.w	#19,d4
fscroll_1_line
	subq.w	#2,a2
	roxl.w	-(a2)
	dbf	d4,fscroll_1_line

	add.w	#82,a2

	move.w	-80(a2),d4
	roxl.w	#1,d4
	move.w	#19,d4
fscroll_2_line
	subq.w	#2,a2
	roxl.w	-(a2)
	dbf	d4,fscroll_2_line

	subq.w	#2,a2

	dbf	d3,fscroll_lines
	dbf	d1,fscroll_once
	dbf	d0,copy_fores
	
	rts

***************************************************************************
extract_sprites
***************************************************************************
	move.l	loaded_palette,a0
	lea	full_palette,a1
	move.w	8(a0),8(a1)	|Colour  4/ 4
	move.w	10(a0),10(a1)	|        5/ 5
	move.w	12(a0),12(a1)	|        6/ 6
	move.w	14(a0),14(a1)	|        7/ 7


	move.l	sprite_screen,a0
	move.w	#3999,d0
make_sprite_mask
	
	move.w	(a0)+,d1	|
	or.w	(a0)+,d1	|
	or.w	(a0)+,d1	|
	or.w	(a0),d1		|
	not.w	d1		|Form the sprite mask in the fourth
	move.w	d1,(a0)+	|bitplane, colour 8.
	
	dbf	d0,make_sprite_mask


	rts


***************************************************************************
draw_sprite
***************************************************************************

*Calculate sprite address:

	move.l	sprite_screen,a1	

	asl.w	#3,d3		d3 = sprite column
	add.w	d3,a1		Add to address of sprite, scrap d3	
	
	move.w	d4,d3		d4 = sprite row
	asl.w	#2,d4		d4 * 4
	add.w	d3,d4		d4 * 5
	move.w	#9,d3		|
	asl.w	d3,d4		d4 * 16 * 160
	add.w	d4,a1		Add to address of sprite, scrap d4

	move.w	#15,d0		No of lines-1	
	
check_top
	tst.w	d2		|
	bge	on_top		Check top edge
	add.w	d2,d0		Calculate visible lines
	blt	sprite_done	Check for any visible lines
	neg.w	d2		|
	move.w	d2,d3		|
	asl.w	#2,d2		|
	add.w	d3,d2		|
	asl.w	#5,d2		No. to skip * 160
	add.w	d2,a1		Skip invisible lines
	clr.w	d2		Go to top line of screen
	bra	on_bottom
on_top

check_bottom
	cmp.w	#184,d2		|
	ble	on_bottom	Check bottom edge
	move.w	#199,d0		|
	sub.w	d2,d0		Calculate visible lines
	blt	sprite_done	Check for any visible lines
on_bottom
	
check_left
	cmp.w	#-15,d1
	blt	sprite_done
on_left

check_right
	cmp.w	#319,d1
	bgt	sprite_done
on_right

	
*Calculate screen address:

	move.l	logic,a0
	
	move.w	d2,d4		d2 = y ordinate
	asl.w	#2,d2		|
	add.w	d4,d2		d2 * 5
	asl.w	#5,d2		d2 * 160
	add.w	d2,a0		Add to screen address, scrap d2

	move.w	d1,d2		d1 = x ordinate
	and.w	#$fff0,d2	|
	asr.w	#1,d2		d2 = x as column boundary / 2
	add.w	d2,a0		Add to screen address
	
	and.w	#$f,d1		|d1 = x fine ordinate

	tst.w	d2
	blt	right_sprite

	cmp.w	#152,d2
	bge	left_sprite


*--------------------------------------------------------------------------
whole_sprite
*--------------------------------------------------------------------------
sprite_loop
	moveq.l	#0,d3		|
	moveq.l	#0,d4		|
	moveq.l	#0,d5		|
	moveq.l	#-1,d6		Clear space
	
	move.w	(a1)+,d3	|
	move.w	(a1)+,d4	|
	move.w	(a1)+,d5	|
	move.w	(a1),d6		|
	lea	154(a1),a1	Get one line

	ror.l	d1,d3		|
	ror.l	d1,d4		|
	ror.l	d1,d5		|
	ror.l	d1,d6		Fine shift

	and.w	d6,(a0)		|
	or.w	d3,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d4,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d5,(a0)+	|
	and.w	d6,(a0)		Draw left half
	lea	2(a0),a0

	swap	d3		|
	swap	d4		|
	swap	d5		|
	swap	d6		Get right half

	and.w	d6,(a0)		|
	or.w	d3,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d4,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d5,(a0)+	|
	and.w	d6,(a0)		Draw right half

	lea	146(a0),a0
	
	dbf	d0,sprite_loop
	
sprite_done
	rts	


*--------------------------------------------------------------------------
right_sprite
*--------------------------------------------------------------------------
	addq.w	#8,a0		|Skip left half
	
right_sprite_loop
	moveq.l	#0,d3		|
	moveq.l	#0,d4		|
	moveq.l	#0,d5		|
	moveq.l	#-1,d6		Clear space
	
	move.w	(a1)+,d3	|
	move.w	(a1)+,d4	|
	move.w	(a1)+,d5	|
	move.w	(a1),d6		|
	lea	154(a1),a1	Get one line

	ror.l	d1,d3		|
	ror.l	d1,d4		|
	ror.l	d1,d5		|
	ror.l	d1,d6		Fine shift

	swap	d3		|
	swap	d4		|
	swap	d5		|
	swap	d6		Get right half

	and.w	d6,(a0)		|
	or.w	d3,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d4,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d5,(a0)+	|
	and.w	d6,(a0)		Draw right half

	lea	154(a0),a0
	
	dbf	d0,right_sprite_loop
	
right_sprite_done
	rts	


*--------------------------------------------------------------------------
left_sprite
*--------------------------------------------------------------------------
left_sprite_loop
	moveq.l	#0,d3		|
	moveq.l	#0,d4		|
	moveq.l	#0,d5		|
	moveq.l	#-1,d6		Clear space
	
	move.w	(a1)+,d3	|
	move.w	(a1)+,d4	|
	move.w	(a1)+,d5	|
	move.w	(a1),d6		|
	lea	154(a1),a1	Get one line

	ror.l	d1,d3		|
	ror.l	d1,d4		|
	ror.l	d1,d5		|
	ror.l	d1,d6		Fine shift

	and.w	d6,(a0)		|
	or.w	d3,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d4,(a0)+	|
	and.w	d6,(a0)		|
	or.w	d5,(a0)+	|
	and.w	d6,(a0)		Draw left half

	lea	154(a0),a0
	
	dbf	d0,left_sprite_loop
	
left_sprite_done
	rts	

	
***************************************************************************
vbi_routine
***************************************************************************
* A simple vbi routine.

	st.b	vbi_flag		|Flags occurrence here.
	rte				|End of interrupt.


vbi_flag	ds.b	1
		even


***************************************************************************
* My new timer-interrupt routines.  Note that a6 is carried from one to
* the next, so should never be used by the main program whilst these are
* running.  Avoid system calls too.  System keyboard interrupts are at
* a higher level than these, and will not be interfered with.

vbi_with_rasters
	clr.b	$fffffa1b.w		|Pause rasters.
	st.b	vbi_flag		|Flags occurrence here.
	move.l	a6,-(a7)
	lea	raster_list,a6
	move.w	(a6)+,$ffff8246.w
	move.l	a6,raster_store
	move.l	(a7)+,a6
	move.b	#8,$fffffa1b.w		|Rasters on.
	rte				|End of interrupt.


raster_routine
	move.l	a6,-(a7)
	move.l	raster_store,a6
	move.w	(a6)+,$ffff8246.w
	move.l	a6,raster_store
	move.l	(a7)+,a6
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	rte				|End of interrupt.

raster_store	ds.l	1

***************************************************************************
wait_vbi
***************************************************************************
* Sub-routine to pause, and wait for my vbi interrupt to occur:

	clr.b	vbi_flag		|Clear vbi flag.
wait_vbi_flag
	tst.b	vbi_flag		|Wait for vbi routine to set
	beq	wait_vbi_flag		|flag byte, to indicate
	rts				|interrupt has occurred.


***************************************************************************
setup_mouse
***************************************************************************
*Set up the new mouse handler.

	pea	absolute_mode_wide	|Mouse instructions.
	move.w	#10,-(a7)		|
	move.w	#25,-(a7)		|
	trap	#14			|System call to send string
	addq.l	#8,a7			|to keyboard/mouse chip.

	pea	set_xy			|Mouse instructions.
	move.w	#5,-(a7)		|
	move.w	#25,-(a7)		|
	trap	#14			|System call to send string
	addq.l	#8,a7			|to keyboard/mouse chip.

	move.w	#$4000,x_mouse
	move.w	#$4000,y_mouse

clear_buffer
	clr.l	mouse_buffer		|Clear my interrupt reporting
	clr.l	mouse_buffer+4		|buffer.

clear_mouse_data
	clr.w	mouse_clicks		|
	clr.w	mouse_keys		|Clear the processed data
	clr.l	mouse_coordinates	|stores.

install_mouse_vector
	move.l	mouse_vector,a0 	|
	lea	mouse_handler,a1	|
	move.l	a1,(a0) 		|Install the new mouse handler.

	rts
	

mouse_commands:
absolute_mode_wide 
		dc.b	$09,$7f,$ff,$7f,$ff	|Absolute mode, max X.w/Y.w
		dc.b	$10			|Y-origin at top.
		dc.b	$07,$00 		|No auto reports on clicks.
		dc.b	$0c,$01,$01		|X/Y multipliers = 1.
		even

set_xy:		dc.b	$0e,$00,$40,$00,$40,$00	|Set initial X/Y.
		even
		
***************************************************************************
centre_mouse
***************************************************************************
*Set the mouse x/y co-ordinates.

	move.l	#set_xy,a0		|Address of the setting
	move.w	#5,d0			|instruction sequence.

wait_centre_mouse
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_centre_mouse	|to signal ready to receive.

	move.b	(a0)+,$fffffc02.w	|Send mouse command...
	dbra	d0,wait_centre_mouse	|...one byte at a time.

	move.w	#$4000,x_mouse
	move.w	#$4000,y_mouse

	rts


***************************************************************************
mouse_handler
***************************************************************************
*This is the handler now called by the system keyboard interrupt.

	move.l	a1,-(a7)		|Save a1 register.
	lea	mouse_buffer,a1 	|Locate buffer (a0 points to data).
	st.b	(a1)+			|Flag occurrence.
	move.b	(a0)+,(a1)+		|Copy button data to buffer.
	move.b	(a0)+,(a1)+		|Now on word boundary in my buffer,
	move.b	(a0)+,(a1)+		|so copy X-position...
	move.b	(a0)+,(a1)+		|...and...
	move.b	(a0)+,(a1)+		|...Y-position
	move.l	(a7)+,a1		|Restore a1 register.
	rts				|Exit.

mouse_buffer
	ds.b	8			|My packet data buffer.


***************************************************************************
interrogate_mouse
***************************************************************************
*Send command to request a mouse packet.

	clr.b	mouse_buffer

wait_get_mouse
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_get_mouse		|to signal ready to receive.

	move.b	#$0d,$fffffc02.w	|Interrogate mouse command.

	rts
	

***************************************************************************
process_mouse
***************************************************************************
*Process the mouse report.

wait_report
	tst.b	mouse_buffer		|
	beq	wait_report		|Check my handler has responded.

	move.w	x_mouse,d0		|
	move.w	y_mouse,d1		|Old X/Y co-ordinates

	move.w	mouse_buffer+2,d2	|
	move.w	mouse_buffer+4,d3	|New X/Y coordinates from buffer

	move.w	d2,x_mouse		|
	move.w	d3,y_mouse		|Store results

	sub.w	d0,d2			|
	sub.w	d1,d3			|Calculate change
	move.w	d2,dx_mouse		|
	move.w	d3,dy_mouse		|Store change


	move.b	mouse_buffer+1,d0	|Get mouse button status.

test_left_click
	btst	#2,d0			|Bit #2 = left button pressed
	beq	test_right_click	|since last check.
	st.b	left_click		|Note a left-click.
	st.b	left_mouse		|Set the 'left-button pressed' flag.

test_right_click
	btst	#0,d0			|Bit #0 = right button pressed
	beq	test_left_release	|since last check.
	st.b	right_click		|Note a right-click.
	st.b	right_mouse		|Set the right button flag.

test_left_release
	btst	#3,d0			|Bit #3 = left button released
	beq	test_right_release	|since last read.
	clr.b	left_mouse		|Clear left button flag.

test_right_release	
	btst	#1,d0			|Bit #1 = right button released
	beq	mouse_processed 	|since last read.
	clr.b	right_mouse		|Clear right button flag.

mouse_processed

check_mouse_range
	clr.l	d0
	clr.l	d1
	move.w	x_mouse,d0
	move.w	y_mouse,d1

	cmp.l	#$00000100,d0		|
	ble	centre_mouse		|
	cmp.l	#$00007f00,d0		|
	bge	centre_mouse		|If the mouse is near the limits of
	cmp.l	#$00000100,d1		|its absolute range, re-centre it
	ble	centre_mouse		|using the initialisation routine
	cmp.l	#$00007f00,d1		|(and RTS from there).
	bge	centre_mouse		|

	rts


***************************************************************************
* Mouse data storage area.

mouse_clicks:
left_click
click_left	ds.b	1
right_click
click_right	ds.b	1

mouse_keys:
left_mouse
mouse_left	ds.b	1
right_mouse
mouse_right	ds.b	1

mouse_coordinates:
x_mouse		ds.w	1
y_mouse		ds.w	1

dx_mouse	ds.w	1
dy_mouse	ds.w	1
		
***************************************************************************
install_vbi 
***************************************************************************
* De-activate any rasters, and install the basic vbi handler.

	move.w	#$2700,sr		|Disable interrupts.
	clr.b	$fffffa1b.w		|Freeze TIMER B (rasters).
	move.l	#vbi_routine,$70	|Install basic vbi routine.
	move.w	#$2300,sr		|Enable interrupts.
	rts				|Done.


***************************************************************************
install_rasters
***************************************************************************
* Activate the rasters.  Note that system vertical-blank interrupts are
* disabled, so a subroutine is provided to do a 'wait_vbi' instead of
* using the system's 'Vsync'.

	move.w	#$2700,sr		|Interrupts off.

	move.l	#vbi_with_rasters,$70	|Install special raster/vbi routine.
	move.l	#raster_routine,$120.w	|Install raster routine.
	move.b	#8,$fffffa21		|8 lines per raster.
	ori.b	#1,$fffffa07.w		|This...
	ori.b	#1,$fffffa13.w		|...and this enable rasters.
	clr.b	$fffffa1b.w		|Pause rasters (until vbi).

	move.w	#$2300,sr		|Interrupts on.
	
	rts				|Done.


***************************************************************************
raster_list
***************************************************************************
top_11_rasters:	
	dc.w	$223,$223,$224,$224
	dc.w	$225,$226,$236,$346
	dc.w	$456,$666,$765

horizon_2_rasters:	
	dc.w	$766,$755
	
lower_12_rasters:
	dc.w	$010,$110,$110,$110
	dc.w	$110,$110,$110
mouse_trigger
	dc.w	$110,$110,$110,$110,$110

null_raster:	
	dc.w	$110
