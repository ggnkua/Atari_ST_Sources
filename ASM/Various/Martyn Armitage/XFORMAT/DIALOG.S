*****************************************
* Routine name	: DIALOG		*
* Function	: Display and control	*
* dialog boxes on the screen		*
* ------------------------------------- *
* Programmer	: Martyn Armitage	*
* Produces	: P.I.C.		*
* Written	: 12/12/1987		*
* Updated	: 12/06/1989		*
*****************************************

* put a dialog box onto the screen and control the input
* returns with the exit button in 'UPDATE_INDEX'
* pass tree address in a0.l
* pass index of editable text in d0.w
* if no editable text then d0.w must hold 0
dialog_box	bsr.s	do_dialog		do box
		bsr.s	get_dial_action		get input
		bsr	close_dialog		close box
		move.w	update_index(a6),d0	exit button
		rts

* put dialog box on screen
* pass tree address in a0.l
* pass index of editable text in d0.w
* if no editable text then d0.w must hold 0
* to put an uncentred box on the screen set up x y coords in
* dialog tree and dial_coords, dialog_y and call 'do_dialog1'
do_dialog	bsr.s	dialog_centre
do_dialog1	bsr.s	dialog_resv
		move.w	start_ob(a6),d0		start object
		move.w	depth(a6),d1		depth to draw
		bsr.s	draw_object
		rts

* center the dialog box
dialog_centre	move.l	a0,d_temp_address(a6)	save tree addr
		move.w	d0,edit_text_index(a6)	save index
		move.l	a0,addr_in(a6)
		gem	FORM_CENTER
		movem.l	int_out+2(a6),d0-d1	get coords
		movem.l	d0-d1,dial_coords(a6)	save them
		rts

*reserve memory for dialog box
dialog_resv	clr.w	int_in(a6)
		movem.l	d0-d1,int_in+2(a6)	pass coords
		movem.l	d0-d1,int_in+10(a6)	ditto
		gem	FORM_DIAL
		rts

* draw the dialog box
* pass start object index in d0.w and depth (no of objects) in d1.w
draw_object	movem.w	d0-d1,int_in(a6)	start object and depth
		movem.l	dial_coords(a6),d0-d1	get coords
		movem.l	d0-d1,int_in+4(a6)	pass them
		move.l	d_temp_address(a6),addr_in(a6)	tree address
		gem	OBJC_DRAW
		rts

* get user action from dialog box
get_dial_action	move.w	edit_text_index(a6),int_in(a6)	editable text
		move.l	d_temp_address(a6),addr_in(a6)	tree address
		gem	FORM_DO
		move.w	d0,update_index(a6)	store exit button/object
		rts

* close the dialog box
close_dialog	move.w	update_index(a6),d0		object to update
		clr.w	d1			normal status
		move.w	d1,d2			no redraw
		bsr.s	update_dialog		reset exit button
		move.w	#3,int_in(a6)		release dialog memory
		movem.l	dial_coords(a6),d0-d1	get coords
		movem.l	d0-d1,int_in+2(a6)	pass them
		movem.l	d0-d1,int_in+10(a6)	ditto
		gem	FORM_DIAL
		move.l	#99,start_ob(a6)	reset start/depth

* redraw the screen to remove dialog boxes, file selector etc
* uses event_multi to remove 'redraw' screen message
* all registers preserved
remove_dial	movem.l	d0-d7/a0-a6,-(sp)	save reg's
		bsr	wait_event		wait for an event
		bsr	redraw			redraw window(s)
		movem.l	(sp)+,d0-d7/a0-a6	get reg's back
remove_dial_2	rts				all done

* normalise the exit button
reset_dial_exit	move.w	update_index(a6),d0	get index
		clr.w	d1			new status (0=normal)
		move.w	#1,d2			redraw
		bsr.s	update_dialog		update it
		rts

* redraw the dialog box
redraw_dialog	bsr.s	reset_dial_exit		reset exit button
		clr.w	int_in(a6)
		move.w	#2,int_in+2(a6)
		movem.l	dial_coords(a6),d0-d1	dialog coords
		movem.l	d0-d1,int_in+4(a6)	pass them
		move.l	d_temp_address(a6),addr_in(a6)
		gem	OBJC_DRAW
		rts

* update the dialog box
* pass object index in d0.w new status in d1.w no redraw/redraw in d2.w
update_dialog	move.w	d0,int_in(a6)		index of obj to change
		clr.w	int_in+2(a6)		always 0
		move.w	d1,int_in+12(a6)	new status
		move.w	d2,int_in+14(a6)	no draw/ redraw
		movem.l	dial_coords(a6),d0-d1
		movem.l	d0-d1,int_in+4(a6)
		move.l	d_temp_address(a6),addr_in(a6)
		gem	OBJC_CHANGE
		rts

