*********************************************************
* SPRITE CODE - BEATING THE 16 PIXEL BOUNDARY			*
*														*
* (c) Nick Bates <ictari> 1994							*
* Version: 1.0											*
* Last modified: 06/06/94								*
*														*
* SET TAB TO 4											*
*********************************************************

		bra		main
		include	graphics.lib
		include	init.lib
		include	dinit.lib
		include	sprite.lib

main	bsr		setup
		bsr		main_loop
		bsr		restore

		clr.l	-(sp)				QUIT
		trap	#1

*********
* SETUP *
*********
setup	
	bsr	go_super						SUPERVISOR MODE
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
	bsr	go_user							USER MODE
	rts

*********************
* MAIN PROGRAM LOOP *
*********************
main_loop
		movem.l	palette,d0-d7
		movem.l	d0-d7,$ffff8240.w		CHANGE PALETTE

.loop	bsr		wait_vbi				WAIT FOR VBI			
		bsr		clear_screen			CLEAR SCREEN					


*****************************************************************
* EXPERIMENT WITH THESE VALUES

		move.w	#0,d0					X CO-ORDINATES
		move.w	#0,d1					Y CO-ORDINATES
		move.w	#0,d2					SPRITE NUMBER

******************************************************************

		bsr		draw_sprite_16

		bsr		flip_screen				FLIP SCREENS

		cmp.b	#$39,$fffffc02			TEST FOR <SPACE BAR>
		beq		.exit
		bra		.loop

.exit	rts


*****************************************************
sprites	incbin	"b:\assembly\sprite\source\pac.obj"
pic		dc.l	1

palette			dc.w	$000,$007,$005,$003,$770,$700,$060,$707
				dc.w	$000,$440,$500,$744,$373,$047,$505,$777
	bss

	even
old_res			ds.b	1
old_pal			ds.w	16
vbi_done		ds.b	1
old_vbi			ds.l	1
old_stk			ds.l	1
old_scrn		ds.l	1
log				ds.l	1
phys			ds.l	1
screen			ds.b	32000+256