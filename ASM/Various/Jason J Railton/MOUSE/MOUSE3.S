***************************************************************************
* Mouse and stable rasters routine Mk3, by Jason J Railton 19/07/96.	  *
*									  *
*		Press both mouse buttons to exit.			  *
*									  *
* Mouse is handled in absolute mode, and rasters are stable except	  *
* for a rare twitch when keyboard keys are pressed and released.  This	  *
* cannot be corrected without loss of system-level keyboard support.	  *
*									  *
*In this demo, mouse Y-origin is at the bottom, not the top of the screen.*
*									  *
***************************************************************************

*   This routine, at the request of Peter Hibbs, provides rasters at lines
* 32 and 170, for palette switching.  If switching the whole palette, it is
* usually best to leave a whole blank line, since it can take a while to
* change all 16 registers.
*   Mouse routines are provided for using ABSOLUTE mode, and extra rasters
* are used to signal when it is OK to interrogate the mouse without messing
* up the screen.  Keyboard response remains, and the chance of hitting a
* key at a time when it will interfere with the rasters is very small.

* The mouse only reports its position when interrogated, but the
* keyboard chip replies some time (approximately 50 scan lines, or a sixth
* of a 50Hz frame) after the interrogation, and pauses the rasters when it
* does.  This means that if the mouse interrogation command is passed
* on the vertical blank interrupt, the response will interfere with any
* rasters triggered in the top few lines of the graphics screen.

* Instead, two rasters are used to mark (using a flag byte) when it is best
* to interrogate the mouse pointer.  Generally, anywhere near the bottom of
* the screen should be alright, as then the mouse packet will come back
* sometime between the last raster and the first raster at line 32.

* Each raster that occurs has its own routine and specific delay.  This
* allows a different event to be programmed for each, without having to
* worry about colour lists.  The only awkward part is that the MFP
* starts counting down to the next raster the instant a raster occurs.
* Therefore changing the delay (MFP data that controls number of lines
* between rasters) on one raster routine will not come into effect until
* after the next raster, so this has to be changed one raster in advance.
 

	move.w	#4,-(a7)		|
	trap	#14			|
	addq.l	#2,a7			|
	move.w	d0,res			|Get screen resolution in d0.

	cmp.w	#2,res			|
	beq	gem_exit		|Quit if hi-res.

	dc.w	$A000			|Line A routines...
	dc.w	$A00A			|hide mouse.

	move.w	#2,-(sp)		|
	trap	#14			|
	addq.l	#2,a7			|
	move.l	d0,screen_pointer	|Get and store the screen address.

	move.l	d0,a0			|Start of screen.
	move.w	#7999,d0		|8000*4 bytes =32000, 1 screen.
clear_screen
	clr.l	(a0)+			|Clear screen one long word
	dbra	d0,clear_screen 	|at a time.

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

wait_mouse_window
	tst.b	mouse_window		|Wait for rasters to signal OK
	beq	wait_mouse_window	|to interrogate mouse.
	
wait_get_mouse
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_get_mouse		|to signal ready to receive.
	move.b	#$0d,$fffffc02.w	|Interrogate mouse command.

wait_report
	tst.b	mouse_buffer		|
	beq	wait_report		|Check my handler has responded.

	bsr	wait_vbi		|Wait for my 50Hz interrupt.


* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

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

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


colour_control
	move.w	mouse_keys,d0		|
	and.w	#$0450,d0		|
	ror.w	#4,d0			|Set colour 1 based on the mouse
	move.w	d0,$ffff8242.w		|keys currently held down.

	bsr	update_sprite		|Redraw sprite at mouse co-ords.

	move.b	left_mouse,d0		|
	and.b	right_mouse,d0		|Repeat until both mouse buttons
	beq	loop			|are being held down.

*-------------------------------------------------------------------------*
tidy_up_exit
	bsr	rasters_off		|Disable rasters.

	move.w	#$666,$ffff8240.w	|
	move.w	#$600,$ffff8242.w	|
	move.w	#$060,$ffff8244.w	|
	move.w	#$000,$ffff8246.w	|Restore GEM screen colours.

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


* Mouse command sequences:
*   These are strings of bytes, in some cases two successive bytes which
* represent a word value as hi,lo bytes (denoted by .w in comments below).
*   You'll probably want mouse origin at the top of the screen as normal,
* so copy one of the ABSOLUTE mode sequences and change the $0f to a $10.
* This simply reverses the Y-axis.  Maximum X & Y limit the mouse from
* (0,0) to (maxX.w,maxY.w).
*   To reset the mouse position, send the command sequence: 
* $0e, $00, X.hi, X.lo, Y.hi, Y.lo  but only use this occaisonally,
* not every interrupt.  Also, this sequence should not be sent via
* the normal system call with which the sequences below are transmitted.
* The routine above ('wait_get_mouse'), which sends a single byte
* to interrogate the mouse position, must be put in a loop and used
* to send the reset sequence one byte at a time.  Trust me, the
* combination of rasters and system keyboard chip communications can
* seriously crash the system.  (See MOUSE2.S from last month for an
* example of resetting the mouse position, at 'reset_mouse' and 
* wait_reset_mouse').

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
		dc.b	$0e,$00,$01,$38,$00,$5d	|Set initial X.w/Y.w.
		even
		
absolute_mode_low
		dc.b	$09,$01,$30,$00,$b5	|As above, with lower
		dc.b	$0f			|max X.word limit, and
		dc.b	$07,$00 		|X/Y movement multipliers
		dc.b	$0c,$01,$01		|are both 1.
		dc.b	$0e,$00,$00,$98,$00,$5d	|Set initial X/Y.
		even

***************************************************************************
*This is the mouse handler now called by the system keyboard chip 
*interrupt when a mouse data packet is returned.

mouse_handler
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
* Activate the rasters.  Note that system vertical-blank interrupts are
* disabled, so a subroutine is provided to do a 'wait_vbi' instead of
* using the system's 'Vsync'.

rasters_on
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
	move.l	#raster_rout_1,$120.w	|Install raster routine.
	move.b	#32,$fffffa21		|32 lines per raster.
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
* My new timer-interrupt routines.

vbi_routine
	clr.b	$fffffa1b.w		|Pause rasters.
	st.b	vbi_flag		|Flags occurrence here.

	move.w	#$666,$ffff8240.w	|Set colour 0 for first line.

	move.l	#raster_rout_1,$120.w	|Re-install first raster routine.
	move.b	#32,$fffffa21		|32 lines before first raster.
	move.b	#8,$fffffa1b.w		|Rasters on.

	rte				|End of interrupt.


* Raster routine for line 32 (this is the first major colour changing
* raster):  
*
*   Note that when this routine is called, the MFP chip will have already
* started counting down from 32 for the next raster.  This raster
* re-directs the vector to the second raster routine, which will occur
* at line 32+32=64.  This is not what we want, but it is unavoidable.
* Thus the second raster routine is a dummy routine, that simply sets up
* the third raster.
*   The delay of 76 set here will only take effect after the next (second)
* raster.  This places the third raster on line 32+32+76=140, and that
* raster is used to signal OK to request a mouse report...  

raster_rout_1
	move.w	#$400,$ffff8240.w	|Change a colour at end of line.

	move.l	#raster_rout_2,$120.w	|Install second raster routine.
	move.b	#76,$fffffa21		|76 lines to follow next raster.
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	rte				|End of interrupt.


* Dummy raster routine, which occurs at line 64:
*
*   This raster routine is a dummy, which simply sets up the third raster
* routine (which signals mouse OK at line 140) and sets the delay after
* that raster to 30 lines.  Thus the fourth (and final) raster will occur
* as required at line 32+32+76+30=170.

raster_rout_2
	move.l	#raster_rout_3,$120.w	|Install third raster routine.
	move.b	#30,$fffffa21		|30 lines to follow next raster.
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	rte				|End of interrupt.


* Raster routine to signal mouse enquiries OK:
*
*   This raster occurs at line 140, and sets a flag byte to indicate
* that it is OK to request a mouse position packet from the keyboard
* chip (with the mouse in ABSOLUTE mode).  This flag byte is cleared
* 30 lines later by the fourth raster routine (installed here).
*   Interrogating the mouse (from the main program) within this time
* window will ensure that the mouse information (returned by interrupt)
* will come back some time between the fourth raster and the bottom of
* the screen, so as not to disturb the raster timings.

raster_rout_3
	st.b	mouse_window		|Signal OK to request mouse packet.	
	move.l	#raster_rout_4,$120.w	|Install fourth raster routine.
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	rte				|End of interrupt.


* The fourth and final raster, which occurs at line 170:
*
*   This is the last raster required.  It does the second colour change
* required at line 170, and also clears the mouse signal byte, to
* indicate that it is now too late to interrogate the keyboard chip
* for mouse position.
*   Rasters are paused after this routine, because no more are required.
* Also, we do not want the MFP chip to start counting down if it is going
* to run out of screen lines (the rasters can roll otherwise).

raster_rout_4
	move.w	#$666,$ffff8240.w	|Change a colour at end of line(s).

	clr.b	mouse_window		|No longer OK for mouse packet.
	bclr	#0,$fffffa0f.w		|Acknowledge done.
	clr.b	$fffffa1b.w		|Pause rasters for rest of display.
	rte				|End of interrupt.


vbi_flag	ds.b	1
		even

mouse_window
		ds.b	1
		even

***************************************************************************
* Dodgy sprite routine;  the sprite is simply ORed into the fiirst bitplane
* to draw it.  However, first is a simple bitmap fade routine which you
* might find interesting.  It ANDs a pattern of four bytes to four
* successive lines of the screen in order to erase individual pixels.  It
* then shifts the pattern to erase a different pixel next time around.
* This fade should work in any screen mode.

* Four bytes, to AND to four successive lines of screen data.  This has
* the effect of deleting one pixel from every 8x4 block of pixels.

fade_mask
	dc.l	$fffffffe


update_sprite
	move.w	#49,d0			|Repeat 50 times (50*4=200 lines)
	move.l	fade_mask,d2		|Get 4 byte fade pattern.
	move.l	screen_pointer,a0	|Locate screen memory.

fade_lines
	move.b	d2,d3			|
	asl	#8,d3			|Duplicate first byte of mask to
	move.b	d2,d3			|fill a whole word.

	move.w	#79,d1			|80 words = 160 bytes = 1 line
fade_loop_1
	and.w	d3,(a0)+		|AND the mask to a whole line (160		
	dbra	d1,fade_loop_1		|bytes), one word at a time.

	ror.l	#8,d2			|Second byte of mask...
	move.b	d2,d3			|
	asl	#8,d3			|
	move.b	d2,d3			|
	move.w	#79,d1			|
fade_loop_2
	and.w	d3,(a0)+		|...is ANDed to the second line
	dbra	d1,fade_loop_2		|of the screen.

	ror.l	#8,d2			|Third byte of mask...
	move.b	d2,d3			|
	asl	#8,d3			|
	move.b	d2,d3			|
	move.w	#79,d1			|
fade_loop_3
	and.w	d3,(a0)+		|...to third line.
	dbra	d1,fade_loop_3		|

	ror.l	#8,d2			|Fourth byte of mask...
	move.b	d2,d3			|
	asl	#8,d3			|
	move.b	d2,d3			|
	move.w	#79,d1			|
fade_loop_4
	and.w	d3,(a0)+		|...to fourth line.
	dbra	d1,fade_loop_4		|

	ror.l	#8,d2			|Back to first byte of mask, and
	dbra	d0,fade_lines		|repeat for whole screen.
	
	swap	d2			|Shift mask right 19 bits; by
	ror.l	#3,d2			|moving the blank bit by an odd 
	move.l	d2,fade_mask		|number, a different bit will be
*					|clear each time the rouine is
*					|called, ensuring that each pixel
*					|on the screen is erased after 32
*					|passes of this routine.


	tst.w	res			|
	beq	low_res_sprite		|Get the right sprite routine.

med_res_sprite
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
	
	move.l	#pointer_form,a1	|Locate pointer image.
	move.w	#17,d1			|18 lines in image.
med_draw_loop
	clr.l	d2			|Get image in lower word,
	move.w	(a1)+,d2		|and pixel-shift to the
	ror.l	d0,d2			|right.
	or.w	d2,(a0)			 |Display in colour 1.
	addq	#4,a0			 |
	swap	d2			|Take the bit shifted offthe right,
	or.w	d2,(a0)			|and draw that in the next column.
	add.w	#156,a0 		 |
	dbra	d1,med_draw_loop	 |Next line					 
	rts				|Done.
	
low_res_sprite
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
	
	move.l	#pointer_form,a1
	move.w	#17,d1
low_draw_loop
	clr.l	d2
	move.w	(a1)+,d2
	ror.l	d0,d2
	or.w	d2,(a0)
	addq	#8,a0
	swap	d2
	or.w	d2,(a0)
	add.w	#152,a0
	dbra	d1,low_draw_loop						
	rts

screen_pointer	ds.l	1
res		ds.w	1

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

