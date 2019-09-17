*********************************************************
* MAIN PROGRAM											*
*														*
* NOW WITH CLIPPING AND JOYSTICK MOVEMENT !!!!!!		*
*														*
* (c) Nick Bates <ictari> 1994							*
* Version: 1.1											*
* Last modified: 10/07/94								*
*														*
* SET TAB TO 4											*
*********************************************************

		bra		main
		include	graphics.lib
		include	sprite.lib
		include mouse.lib  
		include	joystick.lib

main	bsr		setup
		bsr		main_loop
		bsr		restore

		clr.l	-(sp)					QUIT
		trap	#1

*********
* SETUP *
*********
setup	
	bsr	go_super						SUPERVISOR MODE
	bsr	kill_mouse						
	bsr	init_joystick					JOYSTICK ROUTINE
	bsr	save_palette					STORE PALETTE
	bsr	get_screen_addr					GET PHYSICAL AND LOGICAL SCREEN ADDRESS
	bsr	save_vbi						SAVE VBI
	bsr	go_low							GO TO LOW RESOLUTION
	rts         

***********
* RESTORE *
***********
restore 	
	bsr	restore_screen					RESTORE OLD SCREEN
	bsr	restore_palette					RESTORE OLD PALETTE
	bsr	show_mouse
	bsr	go_user							USER MODE
	rts

*********************
* MAIN PROGRAM LOOP *
*********************
main_loop
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w			CHANGE PALETTE

.loop
	bsr		wait_vbi					WAIT FOR VBI			
	bsr		clear_screen				CLEAR SCREEN					


*****************************************************************
* PLAYER CO-ORDINATES

	move.w	player_x,d0					X CO-ORDINATES
	move.w	player_y,d1					Y CO-ORDINATES
	move.w	#0,d2						SPRITE NUMBER

******************************************************************

	bsr		draw_sprite_16
	bsr		flip_screen					FLIP SCREENS

	bsr		move_player					JOYSTICK MOVEMENT

	cmp.b	#$39,$fffffc02				TEST FOR <SPACE BAR>
	beq		.exit						YES

.jloop	
	btst.b	#1,$fffffc00				IS KEYBOARD READY ???
	beq.s	.jloop						NO  - LOOP
	move.b	#$16,$fffffc02				YES - REQAUEST JOY PACKET
	bra		.loop

.exit	
	rts

***************
* MOVE_PLAYER *
***************
move_player
	movem.w	joy_xy,d6/d7


* TEST FOR JOYSTICK MOVEMENT *
* 
* D7 = VERTICAL MOVEMENT	 	-1 = UP, 	-1 = DOWN, 	0 = NO MOVEMENT
* D6 = HORIZONTAL MOVEMENT		-1 = LEFT, 	-1 = RIGHT,	0 = NO MOVEMENT

	cmp.w	#0,d7				ANY VERTICAL MOVEMENT
	beq		.horiz				NO !!!!
	blt		.up

* JOYSTICK DOWN					
	add.w	#1,player_y			ADD 1 TO PLAYER POSITION
	cmp.w	#201,player_y		IS IT OFF LIMIT ????
	blt		.horiz				NO
	move.w	#200,player_y		YES - SO FIX TO LIMIT
	bra.s	.horiz

* JOYSTICK UP

.up	sub.w	#1,player_y			
	cmp.w	#-16,player_y
	bgt		.horiz
	move.w	#-15,player_y

.horiz
	cmp.w	#0,d6				ANY HORIZONTAL MOVEMENT
	beq		.exit				NO!!!
	bgt		.right

* JOTSTICK LEFT
	sub.w	#1,player_x
	cmp.w	#-16,player_x
	bgt		.exit
	move.w	#-15,player_x	
	bra.s	.exit

* JOYSTICK RIGHT
.right
	add.w	#1,player_x
	cmp.w	#321,player_x
	blt		.exit
	move.w	#320,player_x

.exit
	rts

sprites	incbin	"b:\assembly\sprite\source\pac.obj"
pic		dc.l	1

palette			dc.w	$000,$007,$005,$003,$770,$700,$060,$707
				dc.w	$000,$440,$500,$744,$373,$047,$505,$777

set_relative	dc.b	$08

	bss

	even
old_res			ds.b	1
old_pal			ds.w	16
vbi_done		ds.b	1
old_vbi			ds.l	1
old_stk			ds.l	1
old_scrn		ds.l	1
old_mvec		ds.l	1

playerxy
player_x		ds.w	1
player_y		ds.w	1

joy_xy
joy_x			ds.w	1
joy_y			ds.w	1
fire			ds.b	1

jpack_addr		ds.l	1
mpacket			ds.l	1
kvtable			ds.l	1

log				ds.l	1
phys			ds.l	1
screen			ds.b	32000+256
