*********************************************************
*							*
* A window demonstration				*
*							*
* Swirling colours in a gem window.			*
*							*
*********************************************************

	include	releasem.s	release unused memory
	include	getpar.s	find where the parameters are kept
	move.l	a0,parbuf	save it
	bra	main

	include	gemmacro.i	this one is supplied with devpac
	include	shrtones.s
	include	window.s
	include	gem.s

wtype	equ	%100100101011	sizebox, info, move, full, close and name
windowname	dc.b	'True Colours',0

main	move	#-1,-(sp)
	@xbios	$58,4
	and	#$7,d0
	cmp	#4,d0
	bne	not_tc

	move	#32,xstart	window start position
	move	#50,ystart
	move	#190,xwidth	window size
	move	#80,ywidth
	bsr	@createwindow

	menu_register ap_id,#applname	; set the name of the application

wait	evnt_multi #%110010,#1,#1,#1,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#msgbuf,#40	;get message and button events
	btst.b	#4,int_out+1
	bne	msgevent
msgready	btst.b	#5,int_out+1
	bne	timerevent
timerready	btst.b	#1,int_out+1
	bne	buttonevent
	bra	wait
		
msgevent	move	msgbuf,d0
	cmp	#20,d0	is it an update event?
	beq	redraw
	cmp	#22,d0	was the close box pressed?
	beq	exit
	cmp	#27,d0
	beq	sized
	cmp	#28,d0	was the window moved?
	beq	moved
	cmp	#23,d0	was the full button pressed
	beq	full
	cmp	#21,d0	was the window topped?
	beq	topped
	cmp	#33,d0	was it bottomed?
	beq	bottomed
	bra	msgready	it was something unimportant
		
buttonevent	bra	wait	nothing of importance was clicked on
	
timerevent	bsr	update
	bra	timerready

exit	bsr	@exitwindow
	bra	@quit

redraw	bsr	update
	bra	msgready
	
moved	lea	msgbuf,a0
	bsr	@moveit
	bra	msgready
		
sized	lea	msgbuf,a0
	bsr	@resizewindow
	bra	msgready
	
bottomed	lea	msgbuf,a0
	bsr	@bottomwindow
	bra	msgready
	
topped	lea	msgbuf,a0
	bsr	@topwindow
	bra	msgready

full	bra	msgready
		
update	wind_update #1
	@xbios	3,2
	move.l	d0,a1
	move	colour,d0
	move	d0,d2
	swap	d0
	move	d2,d0
	move	xwidth,d1
	lsr	#1,d1
	add	#2,d1
	add	d1,colour

	movem.l	d0/a1,-(sp)
	wind_get w_handle,#11
	tst.w	int_out+6
	bne	.next
	tst.w	int_out+8
	beq	.out
		
.next	movem.l	(sp)+,d0/a1
	move.l	a1,a0
	move	int_out+2,d2
	bge	.notneg
	add	d2,int_out+6
	move	#0,int_out+2
	bra	.x2ok
.notneg	add	int_out+6,d2
	sub	screenxmax,d2
	ble	.x2ok
	sub	d2,int_out+6
	ble	.dontdraw
.x2ok	move	int_out+4,d2
	add	int_out+8,d2
	sub	screenymax,d2
	ble	.y2ok
	sub	d2,int_out+8
	ble	.dontdraw
.y2ok	move	int_out+2,d1
	lsl	#1,d1
	ext.l	d1
	add.l	d1,a0
	move	int_out+4,d2
	move	screenxmax,d5
	add	#1,d5
	add	d5,d5
	mulu	d5,d2
	add.l	d2,a0
	move	int_out+6,d4
	lsr	#1,d4
	sub	#1,d4
	move	int_out+8,d2
	sub	#1,d2
	move	screenxmax,d5
	add	#1,d5
	add	d5,d5
	move	d5,d3
	move	d4,d1
	addq	#1,d1
	lsl	#2,d1
	sub	d1,d3
	bsr	newline
.dontdraw	movem.l	d0/a1,-(sp)
		
	wind_get w_handle,#12
	tst.w	int_out+6
	bne	.next
	tst.w	int_out+8
	bne	.next
.out	movem.l	(sp)+,d0/a1
	wind_update #0
	rts

newline	move	d4,d1
dopix	move.l	d0,(a0)+
	add.l	#$10001,d0
	dbra	d1,dopix
pixready	add.l	d3,a0
	dbra	d2,newline
	rts
		
not_tc	form_alert #1,#alerttext
	bra	@quit


colour	dc.w	$40d3
applname	dc.b	'  True Colours',0
alerttext	dc.b	'[1][ True Colour only][oooh]',0

	include	aeslib.s	supplied with devpac
	include	vdilib.s	supplied with devpac
		
	section bss

msgbuf	ds.w	20
parbuf	ds.l	1
