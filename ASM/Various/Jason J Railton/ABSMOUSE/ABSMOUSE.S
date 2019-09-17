***************************************************************************
* Mouse and stable rasters routine, by Jason J Railton 17/05/96.	  *
*									  *
*		Press both mouse buttons to exit.			  *
*									  *
* Mouse is handled in absolute mode, and rasters are stable except	  *
* for a slight twitch when keyboard keys are pressed and released.  This  *
* cannot be corrected without loss of system-level keyboard support.	  *
*									  *
*In this demo, mouse Y-origin is at the bottom, not the top of the screen.*
*									  *
***************************************************************************

* The mouse only reports its position when interrogated, but the
* keyboard chip replies some time (approximately 50 scan lines, or a sixth
* of a 50Hz frame) after the interrogation, and pauses the rasters when it
* does.  This means that if the mouse interrogation command is passed
* on the vertical blank interrupt, the response will interfere with any
* rasters triggered in the top few lines of the graphics screen.
*
* My raster routine uses register a6 as a pointer to the values in the
* raster colour table.	This register should not be used in any code
* whilst the rasters are active.  Not pushing/restoring it every interrupt
* saves a lot of time.
*
* The trick is to monitor a6 in the main program, and wait for it to pass
* beyond the raster data for the 150th line of the screen, before giving
* the command to interrogate the mouse.  The mouse response then interrupts
* a short time after the last raster, but before the next vertical blank.
* Thus neither interrupt is delayed.  This should not be neccessary if
* your first raster is well down the screen, as the MFP chip should still
* be counting scanlines even if the system is interrupted.
*
* If you see any twitching of the rasters at the bottom of the screen,
* increase the value compared with a6 (the 'add' in line 124), to move 
* the call further down.  Do not exceed an 'add' of 190.  To correct
* twitching at the top of the screen (or of the whole set of rasters),
* reduce the value.
*
* I can only get away with values between 147 and 152.	Anything else
* and the rasters begin to twitch.

	move.w	#4,-(a7)		|
	trap	#14			|
	addq.l	#2,a7			|
	move.w	d0,res			|Get screen resolution in d0.

	cmp.w	#2,res			|
	beq	gem_exit		|Quit if hi-res.

	dc.w	$A000			|Line A routines...
	dc.w	$A00A			|hide mouse.

	move.l	#$0000ffff,d1		|Two long words, to flood med-res
	move.l	#$0000ffff,d2		| screen with colour 1.
	tst.w	res			|If in low-res, the two words would
	bne	two_planes		| represent colour 10, so clear
	clr.l	d2			| the second one.
two_planes
	
	move.w	#2,-(sp)		|
	trap	#14			|
	addq.l	#2,a7			|
	move.l	d0,screen_pointer	|Get and store the screen address.

	move.l	d0,old_loc		|Dummy old sprite position.
	
	move.l	d0,a0			|Start of screen.
	move.w	#3999,d0		|4000*8 bytes =32000, 1 screen.
flood_screen
	move.l	d1,(a0)+		|Flood screen with the two long
	move.l	d2,(a0)+		|words 4000 times, to get whole
	dbra	d0,flood_screen 	|screen in colour 1.

	move.w	#34,-(a7)		|
	trap	#14			|Get the address of the keyboard
	addq.l	#2,a7			|vector table in d0.
	
	move.l	d0,a0			|
	add.l	#16,a0			|Address of the mouse vector.
	
	move.l	a0,loc_mousevec 	|Store this address...
	move.l	(a0),old_mousevec	|and the vector itself.
	
	tst.w	res			|Check screen resolution. X-limit
	beq	mouse_in_low_res	|for mouse depends on res. 
mouse_in_med_res
	pea	absolute_mode_med	|Med-res mouse instructions.
	bra	setup_mouse		|
mouse_in_low_res	
	pea	absolute_mode_low	|Low-res mouse instructions.
setup_mouse
	move.w	#16,-(a7)		|
	move.w	#25,-(a7)		|
	trap	#14			|System call to send string
	addq.l	#8,a7			|to keyboard/mouse chip.

clear_buffer
	clr.l	mouse_buffer		|Clear my interrupt reporting
	clr.l	mouse_buffer+4		|buffer.

clear_mouse_data
	clr.w	mouse_clicks		|
	clr.w	mouse_keys		|Clear the processed data
	clr.l	mouse_coordinates	|stores.

install_mouse_vector
	move.l	loc_mousevec,a0 	|
	lea	mouse_handler,a1	|
	move.l	a1,(a0) 		|Install the new mouse handler.

supervisor_mode
	clr.l	-(a7)			|
	move.w	#$20,-(a7)		|
	trap	#1			|
	addq.l	#6,a7			|Enter supervisor mode.

activate_rasters
	bsr	rasters_on		|Call raster setup.
	
*-----------------------------------------------------------------------*
loop
	move.l	#raster_data,a0 	|Work out the location of the
	add.w	#150,a0 		|data for the 75th raster.
*					|(Rasters are set to occur every
*					|two lines, so the 75th raster
*					|is on the 150th line.	Also
*					|75*words = 150 bytes into the
*					|raster table).
wait_raster
	cmp.l	a0,a6			|Wait for the raster routine to
	blt	wait_raster		|get this far down the screen.

wait_get_mouse
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_get_mouse		|to signal ready to receive.
	move.b	#$0d,$fffffc02.w	|Interrogate mouse command.

	bsr	wait_vbi		|Wait for my 50Hz interrupt.

wait_report
	tst.b	mouse_buffer		|
	beq	wait_report		|Check my handler has responded.

process_mouse
	move.w	mouse_buffer+2,x_mouse	|
	move.w	mouse_buffer+4,y_mouse	|Simply word X/Y coordinates.

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

colour_control
	move.w	mouse_keys,d0		|
	and.w	#$0770,d0		|
	ror.w	#4,d0			|Set colour 0 based on the mouse
	move.w	d0,$ffff8240.w		|keys currently held down.

	move.l	#red_raster,a0		|Get 4 words which describe
	movem.l (a0)+,d0-d1		|one raster bar.
	move.l	#raster_data+200,a0	|Find end of raster data.
	move.w	#24,d2			|
draw_raster_data
	movem.l d0-d1,-(a0)		|Fill raster list quickly,
	dbra	d2,draw_raster_data	|from the bottom up.

	move.l	#raster_data,a2 	|Calculate location in the
	move.w	#199,d0 		|raster data of the bottom
	sub.w	mouse_y,d0		|of the mouse pointer.
	and.w	#$00fe,d0		|
	add.w	d0,a2			|
	move.l	#white_raster,a1	|
	movem.w (a1)+,d0-d7/a0		|Get 9 words for large white
	movem.w d0-d7/a0,-(a2)		|raster bar, and put in data.
	
	bsr	update_sprite		|Redraw sprite at mouse co-ords.

	move.b	left_mouse,d0		|
	and.b	right_mouse,d0		|Repeat until both mouse buttons
	beq	loop			|are being held down.

*-------------------------------------------------------------------------*
tidy_up_exit
	bsr	rasters_off		|Disable rasters.

	move.w	#$666,$ffff8240.w	|
	move.w	#$060,$ffff8244.w	|Restore GEM screen colours.

	move.l	loc_mousevec,a0 	|Restore mouse vector before
	move.l	old_mousevec,(a0)	|putting back in relative mode.
	
	pea	relative_mode		|
	move.w	#6,-(a7)		|
	move.w	#25,-(a7)		|
	trap	#14			|
	addq.l	#8,a7			|Return mouse to relative mode.
	
	dc.w	$A000			|Line A routines...
	dc.w	$A009			|Show mouse.

gem_exit
	clr.w	-(a7)			|
	trap	#1			|Exit.
	
* Data storage- most items have two pointers, because I keep forgetting
* what I called them and type them wrongly.  Use either name to refer to
* the data.

* This data is set up by the mouse processing program above, not the
* mouse interrupt/packet handler.

* 'mouse_clicks' should be cleared by your main program once read.
* 'mouse_keys' should only be read, not altered.  These are flags
* switched when a button is pressed or released, and keep a permanent
* record of which mouse buttons are held down.

* 'mouse_coordinates' can not be altered here.	To set the position
* send the keyboard chip the sequence [$0e, $00, X_hi, X_lo, Y_hi, Y_lo]
* one byte at a time, in the same way as the 'interrogate' command [$0d]
* is sent, above.  Do not use the system to send this command whilst the
* rasters are running.

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
x_mouse
mouse_x 	ds.w	1
y_mouse
mouse_y 	ds.w	1
		
mouse_system:
loc_mousevec	ds.l	1
old_mousevec	ds.l	1

mouse_commands:
relative_mode	dc.b	$08		|Relative mode.
		dc.b	$10		|Y-origin at top (Down =+ve).
		dc.b	$07,$00 	|Mouse-click reports off.
		dc.b	$0b,$01,$01	|Mouse threshold = 1, in X & Y
		even

absolute_mode_med
		dc.b	$09,$02,$70,$00,$b5	|Absolute mode, max X.w/Y.w
		dc.b	$0f			|Y-origin at bottom (Up=+ve).
		dc.b	$07,$00 		|No auto-report on clicking.
		dc.b	$0c,$02,$01		|Set mouse step-multipliers.
*						|(1 movement of mouse equals
*						|+2 in X, or +1 in Y).
		dc.b	$0e,$00,$01,$38,$00,$5d	|Set initial X/Y.
		even
		
absolute_mode_low
		dc.b	$09,$01,$30,$00,$b5	|As above, with lower
		dc.b	$0f			|max X.word limit, and
		dc.b	$07,$00 		|X/Y movement multipliers
		dc.b	$0c,$01,$01		|are both 1.
		dc.b	$0e,$00,$00,$98,$00,$5d	|Set initial X/Y.
		even

***************************************************************************
*This is the handler now called by the system keyboard interrupt.

mouse_handler
	move.l	a1,-(a7)		|Save a1 register.
	lea	mouse_buffer,a1 	|Locate buffer (a0 points to data).
	st.b	(a1)+			|Flag occurrence.
	move.b	(a0)+,(a1)+		|Copy button data to buffer.
	move.b	(a0)+,(a1)+		|Now on word boundaryin my buffer,
	move.b	(a0)+,(a1)+		|so copy X-position...
	move.b	(a0)+,(a1)+		|...and...
	move.b	(a0)+,(a1)+		|...Y-position
	move.l	(a7)+,a1		|Restore a1 register.
	rts				|Exit.



mouse_buffer
	ds.b	8			|My packet data buffer.

***************************************************************************
* Dodgy sprite routine.  Stores the location of the previous draw in
* 'old_loc', in order to wipe it with colour 2 before re-drawing it
* in its new position.  It is simply ORed into all bitplanes to draw it.

update_sprite
	tst.w	res			|
	beq	low_res_sprite		|Get the right routine.

med_res_sprite
	move.l	old_loc,a0		|The last place it was drawn.
	move.l	#17,d0			|
med_erase_loop
	move.l	#$0000ffff,(a0)+	|Wipe a 32*18 pixel patch
	move.l	#$0000ffff,(a0)+	|with colour 2.  The sprite
	add.w	#152,a0 		|can't get to the bottom line, so
	dbra	d0,med_erase_loop	|don't worry about wrap.

	move.l	screen_pointer,a0	
	move.w	#181,d0 		|
	sub.w	mouse_y,d0		|Y-origin at bottom, remember?
	mulu	#160,d0 		 |
	add.w	d0,a0			 |
	move.w	mouse_x,d0		 |
	and.w	#$0ff0,d0		 |
	asr.w	#2,d0			 |
	add.w	d0,a0			 |Calculate screen position.
	move.w	mouse_x,d0		|
	and.w	#$000f,d0		|Calculate 0-15 pixel shift.
	move.l	a0,old_loc		 |Store location for erasing.
	
	move.l	#pointer_form,a1	|Locate pointer image.
	move.w	#17,d1			|18 lines in image.
med_draw_loop
	clr.l	d2			|Get image in lower word,
	move.w	(a1)+,d2		|and pixel-shift to the
	ror.l	d0,d2			|right.
	or.w	d2,(a0)+		 |
	or.w	d2,(a0)+		 |Display in colour 3.
	swap	d2			|Take the bit shifted off
	or.w	d2,(a0)+		|the right, and draw that
	or.w	d2,(a0)+		|in the next column.
	add.w	#152,a0 		 |
	dbra	d1,med_draw_loop	 |Next line					 
	rts				|Done.
	
low_res_sprite
	move.l	old_loc,a0		|As above, just remember that
	move.l	#17,d0			|there are more bitplanes to fill.
low_erase_loop
	move.l	#$0000ffff,(a0)+
	clr.l	(a0)+
	move.l	#$0000ffff,(a0)+
	clr.l	(a0)+
	add.w	#144,a0
	dbra	d0,low_erase_loop	

	move.l	screen_pointer,a0
	move.w	#181,d0
	sub.w	mouse_y,d0
	mulu	#160,d0
	add.w	d0,a0
	move.w	mouse_x,d0
	and.w	#$0ff0,d0
	asr.w	#1,d0
	add.w	d0,a0
	move.w	mouse_x,d0
	and.w	#$000f,d0
	move.l	a0,old_loc
	
	move.l	#pointer_form,a1
	move.w	#17,d1
low_draw_loop
	clr.l	d2
	move.w	(a1)+,d2
	ror.l	d0,d2
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	swap	d2
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	or.w	d2,(a0)+
	add.w	#144,a0
	dbra	d1,low_draw_loop						
	rts

screen_pointer	ds.l	1
res		ds.w	1
old_loc 	ds.l	1

pointer_form	dc.w	%0000111100011110	|Finger-bobs mouse
		dc.w	%0001000111110001	|pointer image, in
		dc.w	%0001001111111001	|one bitplane with
		dc.w	%0000111001001110	|no mask.
		dc.w	%0000001111111000
		dc.w	%0110001100011000
		dc.w	%1000111110111000
		dc.w	%0111001111111000
		dc.w	%0000001111111000
		dc.w	%0000000010100000
		dc.w	%0011011011100000
		dc.w	%1011011011100000
		dc.w	%1011011011100010
		dc.w	%0100101111100110
		dc.w	%1111111111101110
		dc.w	%1111111111111100
		dc.w	%1111111111111000
		dc.w	%0011111111110000

***************************************************************************
* Activate the rasters.  Note that system vertical-blank interrupts are
* disabled, so a subroutine is provided to do a 'wait_vbi' instead of
* using the system's 'Vsync'.

rasters_on
	move.l	#red_raster,a0		|
	movem.l (a0)+,d0-d1		|
	move.l	#raster_data+200,a0	|
	move.w	#24,d2			|
init_raster_data
	movem.l d0-d1,-(a0)		|Fill the raster data table with
	dbra	d2,init_raster_data	|bars of red.

	move.w	#$2700,sr		|Interrupts off.

	move.l	$70,v_blank_store	|Store 50Hz Interrupt Vector.
	move.l	$120.w,h_blank_store	|Store Raster vector.	     

	move.b	$fffffa07.w,timer_ab_enable	|Store MFP data that
	move.b	$fffffa0f.w,timer_ab_inserv	|will change.
	move.b	$fffffa13.w,timer_ab_mask	|
	move.b	$fffffa1b.w,timer_b_control	|
	move.b	$fffffa21.w,timer_b_data	|

	move.w	#5,-(sp)		|Disable Timer C (system clock).
	move.w	#26,-(sp)		|It makes rasters twitch every
	trap	#14			|so often.
	addq.l	#4,sp			|JDISINT

	move.l	#vbi_routine,$70	|Install vbi routine.
	move.l	#raster_routine,$120.w	|Install raster routine.
	move.b	#2,$fffffa21		|2 lines per raster.
	ori.b	#1,$fffffa07.w		|This...
	ori.b	#1,$fffffa13.w		|...and this enable rasters.
	clr.b	$fffffa1b.w		|Pause rasters (until vbi).

	move.w	#$2300,sr		|Interrupts on.
	
	rts				|Done.

***************************************************************************
* De-activate rasters and tidy up.

rasters_off 
	move.w	#$2700,sr		|Disable interrupts.

	move.w	#5,-(sp)		|Timer C (system clock).
	move.w	#27,-(sp)		|Enable it.
	trap	#14			|
	addq.l	#4,sp			|JENABINT

	clr.b	$fffffa1b.w		|Freeze TIMER B (rasters).
	move.l	v_blank_store,$70	|Restore 50Hz Interrupt Vector.
	move.l	h_blank_store,$120.w	|Restore Raster vector.        

	move.b	timer_ab_enable,$fffffa07.w	|Restore MFP data that
	move.b	timer_ab_inserv,$fffffa0f.w	|has been changed.
	move.b	timer_ab_mask,$fffffa13.w	|
	move.b	timer_b_control,$fffffa1b.w	|
	move.b	timer_b_data,$fffffa21.w	|

	move.w	#$2300,sr		|Enable interrupts.

	rts				|Done.


*** STORAGE OF INITIAL SYSTEM DATA ***

v_blank_store
	ds.l	1

h_blank_store
	ds.l	1

timer_ab_enable
	ds.b	1

timer_ab_mask
	ds.b	1

timer_ab_inserv
	ds.b	1

timer_b_control
	ds.b	1

timer_b_data
	ds.b	1

	even

***************************************************************************
* Sub-routine to pause, and wait for my vbi interrupt to occur:

wait_vbi
	clr.b	vbi_flag		|Clear vbi flag.
wait_vbi_flag
	tst.b	vbi_flag		|Wait for vbi routine to set
	beq	wait_vbi_flag		|flag byte, to indicate
	rts				|interrupt has occurred.

***************************************************************************
* My new timer-interrupt routines.  Note that a6 is carried from one to
* the next, so should never be used by the main program whilst these are
* running.  Avoid system calls too.  System keyboard interrupts are at
* a higher level than these, and will not be interfered with.

vbi_routine
	clr.b	$fffffa1b.w		|Pause rasters.
	st.b	vbi_flag		|Flags occurrence here.
	move.l	#raster_data,a6 	|Reset raster pointer to first item.
	move.w	(a6)+,$ffff8244.w	|Set colour 2 for first line.
	move.b	#8,$fffffa1b.w		|Rasters on.
	rte				|End of interrupt.

raster_routine
	move.w	(a6)+,$ffff8244.w	|Change a colour at end of line(s).
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	rte				|End of interrupt.



vbi_flag	ds.b	1
		even

***************************************************************************
* Colour lists:

red_raster
	dc.w	$500,$700,$500,$200

white_raster
	dc.w	$333,$444,$555,$666,$777,$666,$555,$444,$333



* Space reserved for raster colour table:

raster_data
	ds.w	100		|100 rasters (first one is set by vbi,
*				|then AFTER every two lines by the
*				|raster interrupt).
	dc.w	$000		|Last raster occurs after last line of
*				|screen, and is never seen unless used
*				|to set colour 0.

