
fm_tree		equ	0	Tree address
fm_objc		equ	4	Current object (for objc_edit)
fm_char		equ	6	Current character position

	basepage
	graf_mouse	#0

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* A built-in resource MUST use rsrc_obfix. It converts the X/Y/W/H
* object values from character to pixel. Normally rsc_load does this
* automatically

	lea	rsc_data(pc),a3
	moveq	#0,d3
	move.l	a3,a0
rsc_lp	move.l	a0,-(sp)
	rsrc_obfix	a3,d3
	move.l	(sp)+,a0
	btst	#5,ob_flags+1(a0)
	bne.s	set_fm
	addq.w	#1,d3
	add.w	#ob_sizeof,a0
	bra.s	rsc_lp			until LASTOB

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* This are just variables which I use to keep data safe in

set_fm	lea	rsc_data(pc),a0
	lea	fm_data(pc),a5
	move.l	a0,fm_tree(a5)
	clr.w	fm_objc(a5)		The current editable object
	clr.w	fm_char(a5)		The cursor position

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* First centre the form which returns it's X/Y/W/H

	form_center	fm_tree(a5)
	movem.w	int_out+2(a6),d0-d3

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Using these values get the AES to work out what size the window must
* be to surround the form. This is the crucial part, as if the window
* is too small there will be all sorts of problems.

	wind_calc	#0,#%1011,d0,d1,d2,d3
	movem.w	int_out+2(a6),d4-d7

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Now create the window, which returns it's handle

	wind_create	#%1011,d4,d5,d6,d7
	move.w	int_out(a6),d3	

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Set the window parameters ie Move,Close & Title

	wind_set.w	d3,#1,#%1011

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Add the window title

	lea	w_title(pc),a0
	wind_set.l	d3,#2,a0

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* At last open the window. All the above is much simpler in Basic

	wind_open	d3,d4,d5,d6,d7

	SECTION DATA
w_title	dc.b	' Non-Modal RSC ',0
	even
	SECTION TEXT

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Ready for event_multi loop. We want window messages,button & keyboard
* events to be reported. Button is left, 1 click

set_up	lea	events(pc),a3
	move.w	#%10011,ev_multiflg(a3)
	move.w	#1,ev_clicks(a3)
	move.w	#1,ev_bmask(a3)
	move.w	#1,ev_bstate(a3)

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* This is the hub of the programme. Wait here for an AES event, decide
* which it is, do it and come back, except if the window is closed 

evnt_lp	evnt_multi
	cmpi	#$01,d0
	beq	keyboard
	cmpi	#$02,d0
	beq	button
	cmpi	#$10,d0
	beq	message
	bra	evnt_lp
	
*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* This is a messy bit so the notes are spread throughout it

* AES has reported a keyboard event. As this form must be non-modal
* I run form_keybd from here by passing it the key passed by AES. In a
* full programme there are bound to be others waiting for key events

* It returns the same key but also an object number

keyboard	move.w	int_out+10(a6),d0
	form_keybd	fm_tree(a5),fm_objc(a5),d0,fm_objc(a5)
	movem.w	int_out+2(a6),d3-d4

* Compare the current object number with the returned one.
* If they are the same we have anything OTHER than an Up/Down arrow
* key, TAB/shift+TAB or Return key so go to the routine 'ky_char' below

	cmp.w	fm_objc(a5),d3
	beq	ky_char

* 'tst.w' prevents the cursor appearing when the prog is first run
* Thereafter it clears the cursor off the old editable object

	tst.w	fm_objc(a5)
	beq.s	ob_nxt
	objc_edit	fm_tree(a5),fm_objc(a5),d4,fm_char(a5),#3

* Check for the Return key (object 5), go to that routine if yes
 
ob_nxt	cmpi	#5,d3
	beq	fm_exit

* OK so the Up/Down arrow or TAB or shift+TAB has been pressed which
* means change editable object. Function 1 puts the cursor on the new
* object at the end of any text and returns the cursor position.
* Save that, then back to event_multi
 
	move.w	d3,fm_objc(a5)
	objc_edit	fm_tree(a5),fm_objc(a5),d4,fm_char(a5),#1
	move.w	int_out+2(a6),fm_char(a5)
	bra	evnt_lp

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Form_keybd has sent a character or Left/Right arrow key, Esc, Backspace
* or Delete. AES validates it using objc_edit_2 so no duff ones will
* get through. Enter the character or move the cursor as appropriate.
* Afterwards the new character position is reported which must be saved
* Then as usual, back to event_multi

ky_char	objc_edit	fm_tree(a5),fm_objc(a5),d4,fm_char(a5),#2
	move.w	int_out+2(a6),fm_char(a5)
	bra	evnt_lp

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* Form_keybd reports Return key pressed so gets it's X/Y/W/H using
* objc_offset ready for the redraw routine
* Note: If the exit button is clicked on, it also comes here
* APOLOGIES Objc_change should change an object's status flags and
*	redraw it but for some reason it would not. I fiddle round this
*	by clearing it and then doing an ordinary redraw anyway.
* Then back to event_multi
 
fm_exit	move.w	d3,fm_objc(a5)		Preserve exit object number
	objc_offset	fm_tree(a5),fm_objc(a5)
	movem.w	int_out+2(a6),d0-d1	X/Y -	returned by objc_offset

	movea.l	fm_tree(a5),a0	
	move.w	fm_objc(a5),d4		Retrieve object number
	mulu	#ob_sizeof,d4		Calculate offset to object data
	movem.w	20(a0,d4.w),d2-d3	W/H -	from resource data 
* FIDDLE
	bclr	#0,ob_state+1(a0,d4.w)		Clear SELECTED flag
	objc_draw	fm_tree(a5),fm_objc(a5),#0,d0,d1,d2,d3

	clr.w	fm_objc(a5)	Make the editable object variable NULL
	bra	evnt_lp

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* AES reports a button event and passes the X/Y of the mouse.
* Check for a object, if yes, is it the exit one? if yes, then
* clear the cursor & deactivate the form.
* If the wrong (or no) object is found go back to event_multi
   
button	movem.w	int_out+2(a6),d0-d1		Mouse X/Y in d0/d1
	objc_find	fm_tree(a5),#0,#2,d0,d1
	move.w	int_out(a6),d3
	cmpi	#5,d3
	bne	evnt_lp
	tst.w	fm_objc(a5)	Safety! No active editable object  ABORT
	beq	evnt_lp
	objc_edit	fm_tree(a5),fm_objc(a5),#0,fm_char(a5),#3
	bra	fm_exit		Goto the Return key routine

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* This bit sorts out which window message AES has returned together
* with other info. In the following (a3) has the message number,
* 6(a3) it's handle, & 8(a3),10(a3),12(a3),14(a3) it's X/Y/W/H

message	lea	events+ev_mesag(pc),a3		Set message buffer.
	cmpi	#20,(a3)
	beq	w_draw
	cmpi	#22,(a3)
	beq	w_close
	cmpi	#28,(a3)
	beq	w_move
	bra	evnt_lp

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* AES has redrawn the window so get the First rectangle, which will in fact
* be it's Work area which will be the same size as the object. For
* simplicity this routine assumes no other windows exist so it redraws
* itself in full. d4/d5/d6/d7 are the X/Y/W/H values

w_draw	wind_get	6(a3),#11
	movem.w	int_out+2(a6),d4-d7
	objc_draw	fm_tree(a5),#0,#2,d4,d5,d6,d7
	bra	evnt_lp

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* This simply closes & deletes the window and quits the programme

w_close	wind_close	6(a3)
	wind_delete	6(a3)
	bra	quit_prg

*=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
* AES reports window moved and gives it's new X/Y/W/H
* Set these (wind_set function 5) then get the new Work area of the
* window. Need it's X/Y as the X/Y of object_0 MUST be set to the
* same co-ordinates to keep the form tidy for AES.

w_move	wind_set4	6(a3),#5,8(a3),10(a3),12(a3),14(a3)
	wind_get	6(a3),#4
	movem.w	int_out+2(a6),d0-d1
	movea.l	fm_tree(a5),a0
	movem.w	d0-d1,16(a0)		Set Form x/y to match window
	bra	evnt_lp

ob_flags	equ	8
ob_state	equ	10
ob_sizeof	equ	24

G_BOX		equ	20
G_BUTTON	equ	26
G_STRING	equ	28
G_FTEXT		equ	29
G_FBOXTEXT	equ	30

NONE		equ	0
SELECTABLE	equ	1
DEFAULT		equ	2
EXIT		equ	4
EDITABLE	equ	8
LASTOB		equ	$20

NORMAL		equ	0

ted_color	equ	%0001000110000001

object	macro	next,head,tail,type,flags,state,ospec,x,y,w,h
	dc.w	\1,\2,\3
	dc.w	\4,\5,\6
	dc.l	\7
	dc.w	\8,\9,\A,\B
	endm

	SECTION	DATA
rsc_data
	object	0,1,5,G_BOX,NONE,NORMAL,1,0,0,30,8
	object	2,-1,-1,G_STRING,NONE,NORMAL,datetx,1,1,14,1
	object	3,-1,-1,G_STRING,NONE,NORMAL,timetx,1,3,14,1
	object	4,-1,-1,G_FTEXT,EDITABLE,NORMAL,date_ted,16,1,12,1
	object	5,-1,-1,G_FTEXT,EDITABLE,NORMAL,time_ted,16,3,10,1
	object	0,-1,-1,G_BUTTON,SELECTABLE!DEFAULT!EXIT!LASTOB,NORMAL,exit_tx,8,5,14,2

datetx	dc.b	'Enter the Date',0
timetx	dc.b	'Enter the Time',0
exit_tx	dc.b	'Set Time/Date',0
	even
time_text	dc.b	'@nnnnn',0
time_temp	dc.b	'__:__:__',0
time_valid	dc.b	'999999',0
	even
time_ted	dc.l	time_text,time_temp,time_valid
		dc.w	3,0,0,ted_color,0,0,7,9

date_text	dc.b	'@_______',0
date_temp	dc.b	'__/__/____',0
date_valid	dc.b	'99999999',0
	even
date_ted	dc.l	date_text,date_temp,date_valid
		dc.w	3,0,0,ted_color,0,0,9,11
	SECTION BSS
fm_data	ds.w	6

	SECTION TEXT
	quit_prg
	end

