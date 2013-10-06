
* a sample GEM program supplied with Devpac

* Source code Copyright (C) 1988,1992 HiSoft. All rights reserved.
* No part of this source may be reproduced, transmitted,
* transcribed, or stored in a retrieval system, or translated
* in any form or by any means without the prior written
* permission of HiSoft.

* HiSoft makes no representations or warranties with respect
* to the contents hereof and specifically disclaims any
* implied warranties or merchantability or fitness for any
* particular purpose.

* feel free to use any or all of the object code

* If you cannot assemble this exactly as supplied, tell us.
* If the object doesn't run after you have made any changes,
* please do not tell us, as you're on your own once you
* start messing with it!

* this is mainly to show the calling sequence for GEM
* from assembler - the program itself doesn't do much

* last changed:6.8.92
* updated to use Devpac3 style names & options

	opt	XDEBUG		dump long labels for debugging

	include	gemmacro.i

* the program proper
start	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	appl_init
	move.w	d0,ap_id		store the application id

	graf_handle
	move.w	d0,current_handle	Desktop's VDI handle

* start by opening a virtual workstation
	lea	intin,a0
	moveq	#10-1,d0		-1 for DBF
.fill	move.w	#1,(a0)+		most params are 1
	dbf	d0,.fill
	move.w	#2,(a0)+		use RC system

	v_opnvwk			open it

* set the mouse to an arrow
	graf_mouse	#0		arrow please

* we want to open a window, so find the usable size of the screen
	wind_get	#0,#4		work area of Desktop

* the type of the window
wtype	equ %000000101111		title, close, full, move, size

* the size lies in int_out(1..4), so calculate the window size
	movem.w	int_out+2,d0-d3
	wind_calc	#wtype,#1,d0,d1,d2,d3	want work area

* now remember its offsets
	move.w int_out+2,xstart
	move.w int_out+4,ystart
	move.w int_out+6,xwidth
	move.w int_out+8,ywidth

* and create the window
	movem.w	int_out+2,d0-d3
	wind_create	#wtype,d0,d1,d2,d3
	move.w	d0,w_handle		save the handle (error checks?)

* now set its title
	move.l	#windowname,int_in+4
	wind_set	w_handle,#2	title string

* now actually show it by opening
	movem.w	xstart,d0-d3
	add.w	#10,d0			x start
	add.w	#10,d1			y start
	sub.w	#20,d2			width
	sub.w	#20,d3			height
	wind_open	w_handle,d0,d1,d2,d3

	bsr	recalcwindow
	bsr	setupmode

* the main loop of the application
* the only interesting events are messages
waitforevent
	evnt_mesag	#messagebuf
	lea	messagebuf,a0
	move.w	(a0),d0			message type
	cmp.w	#20,d0
	beq	updateit			if Redraw
	cmp.w	#22,d0
	beq	quit			if Close button
	cmp.w	#23,d0
	beq	fullit			if Full button
	cmp.w	#27,d0
	beq	sizeit			if re-size required
	cmp.w	#28,d0
	beq	moveit			if window moved

* nothing I'm interested in so try again
	bra	waitforevent

* move the window around the screen
moveit	move.w	6(a0),d0
	cmp.w	w_handle,d0
	bne	waitforevent		if not my window then don't
changedwindow
	move.w	8(a0),int_in+4		new x pos
	move.w	10(a0),int_in+6		new y pos
	move.w	12(a0),d0
	cmp.w	#40,d0
	bcc.s	.wok
	moveq	#40,d0			can't be too narrow
.wok	move.w	d0,int_in+8		width
	move.w	14(a0),d0
	cmp.w	#50,d0
	bcc.s	.hok
	moveq	#50,d0			can't be too thin either
.hok	move.w	d0,int_in+10		height

	wind_set	w_handle,#5

	movem.w	xwidth,d4-d5		old size
	bsr	recalcwindow
	cmp.w	xwidth,d4
	bcs	waitforevent
	cmp.w	ywidth,d5
	bcs	waitforevent
	bne.s	forceupdate
	cmp.w	xwidth,d4
	beq	waitforevent		not if exactly the same
* if the new size is smaller in both dimensions than the old size
* then an update event will not be posted, so the re-draw will
* have to be done manually
forceupdate
	bsr	drawwindow		draw it
	bra	waitforevent		and carry on

* re-size the window
sizeit	move.w	6(a0),d0
	cmp.w	w_handle,d0
	bne	waitforevent		if not my window
	bra	changedwindow

* there's an update
updateit
	move.w	6(a0),d0
	cmp.w	w_handle,d0
	bne	waitforevent		if not my window
* there are two ways of doing updates:
* (a) to support overlapping windows
* this takes a lot of code, and is very slow and tricky
* (b) to ignore the possibility of overlapping windows
* this takes little code and is easy
* Here method (b) is used! (method (a) is needed if you have a Desk
* menu or multi-windows in your program - this doesn't have either
* -that's my excuse and I'm sticking to it!)

* start by clipping the rectangle
	movem.w	8(a0),d0-d3		the rectangle
	add.w	d0,d2
	add.w	d1,d3
	vs_clip	#1,d0,d1,d2,d3		clipping on

	bsr	drawwindow			draw the window
	bra	waitforevent

* the full button has been clicked
* this puts up an alert box
fullit	form_alert	#1,#myalert
	bra	waitforevent

* to go away various things have to be tidied up
* starting with closing the window
quit	wind_close	w_handle	close it
	wind_delete	w_handle	and delete it

* then closing the virtual workstation
	v_clsvwk			close it

	appl_exit			tell GEM I've finished

* now quit to the desktop
	clr.w	-(a7)			status code
	move.w	#$4c,-(a7)		P_TERM
	trap	#1			and go away

* calculate the work area of the window
recalcwindow
	wind_get	w_handle,#4	get work area
	movem.w	int_out+2,d0-d3
	movem.w	d0-d3,xstart
	rts

* this draws the picture in the window
* which is an oval on top of a rectangle

* before drawing anywhere you have to hide the mouse
drawwindow
	v_hide_c			hide the mouse
	vsf_interior	#2		pattern

	movem.w	xstart,d0-d3		AES rectangle
	add.w	d0,d2
	subq.w	#1,d2
	add.w	d1,d3
	subq.w	#1,d3			convert to VDI
	vr_recfl	d0,d1,d2,d3	filled rectangle
* the oval has to be drawn in the user defined pattern
	vsf_interior	#4

	movem.w xstart,d0-d3
	asr.w	#1,d2			half width
	asr.w	#1,d3			half height
	add.w	d2,d0			x centre
	add.w	d3,d1			y centre
	v_ellipse	d0,d1,d2,d3

* we have finished drawing so get the mouse back
	v_show_c	#0		show the mouse
	rts

* this prepares the drawing mode etc
setupmode
	move.l	#intin,a0
	move.w 	#%0000100101000000,(a0)+
	move.w	#%0000100101000000,(a0)+
	move.w	#%0000111101000000,(a0)+
	move.w	#%0000100101000000,(a0)+
	move.w	#%0000100101000000,(a0)+
	move.w	#%0000000000000000,(a0)+
	move.w	#%0110010011011100,(a0)+
	move.w	#%1000101010001000,(a0)+
	move.w	#%1100101011001000,(a0)+
	move.w	#%0010101010001000,(a0)+
	move.w	#%1100010010001000,(a0)+
	REPT	16-11
	clr.w	(a0)+
	ENDR
	move.w	#16,contrl3		single plane
	vsf_updat			set user defined fill style
	vsf_color	#1
	rts

	SECTION	DATA

* all C strings must end in a null
windowname dc.b ' An Example GEM Program by HiSoft ',0

myalert dc.b "[1][This is written in 68000|assembler using HiSoft's|"
	dc.b 'Devpac Version 3][ OK ]',0

* global constants
	SECTION	BSS

* these have to remain together
xstart	ds.w 1
ystart	ds.w 1
xwidth	ds.w 1
ywidth	ds.w 1

w_handle	ds.w 1
ws_handle	ds.w 1
ap_id		ds.w 1
messagebuf	ds.b 16

	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)


* if not linking then include the run-times

	IFEQ	__LK
	include	aeslib.s
	include	vdilib.s
	ENDC
