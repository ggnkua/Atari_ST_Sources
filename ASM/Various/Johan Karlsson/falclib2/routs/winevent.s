*
* WINEVENT.S
*
*	@dowindowevents
*	 For the lazy one. This function waits for events and takes care of
*	 everything but the close button or if someone clicked on an object.
*	 If one of these events occur the program branches to closeevent
*	 or buttonevent. Those subroutines you have to make yourself.
* In	 a0.l=adr. to rsrc
*	 w_handle, ap_id  (These are created automatically if you use @createwindow)
* Out	 buttonevent: d0.w=number of the object pressed
*	 closeevent: nothing
*	 (destroys a lot)
*
* ex.	;create a window;
*	lea rsrc,a0
*	bra @dowindowevents	; it will never return so you may use 'bra'
* buttonevent		; d0.w will contain the object that was pressed
*	cmp #1,d0 	; was it my button?
* 	beq mybutton	; yes!
*	rts		; no!
* closeevent
*	bsr @exitwindow	; close window
*	bra @quit	; quit
*

		include	window.s


@dowindowevents	move.l	a0,.rsrcadr
.again		evnt_multi #%010010,#1,#1,#1,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#.msgbuf,#0	;get message and button events
		btst.b	#4,int_out+1
		bne	.msgevent
.msgready	btst.b	#1,int_out+1
		bne	.buttonevent
		bra	.again

.msgevent	move	.msgbuf,d0
		cmp	#20,d0		is it an update event?
		beq	.redraw
		cmp	#22,d0		was the close box pressed?
		beq	.exit
		cmp	#28,d0		was the window moved?
		beq	.moved
		cmp	#23,d0		was the full button pressed
		beq	.full
		cmp	#21,d0		was the window topped?
		beq	.topped
		cmp	#33,d0		was it bottomed?
		beq	.bottomed
		bra	.msgready	it was something unimportant
		
.buttonevent	move.l	.rsrcadr,a0
		bsr	@button
		tst	d0		did someone press anything?
		bmi	.again		no!
		bsr	buttonevent
		bra	.again
		
.exit		bsr	closeevent
		bra	.msgready
.redraw		move.l	.rsrcadr,a0
		bsr	@updatersrc
		bra	.msgready
.moved		lea	.msgbuf,a0
		bsr	@moveit
		bra	.msgready
.bottomed	lea	.msgbuf,a0
		bsr	@bottomwindow
		bra	.msgready
.topped		lea	.msgbuf,a0
		bsr	@topwindow
		bra	.msgready
.full		bra	.msgready

.msgbuf		ds.w	20
.rsrcadr	ds.l	1
