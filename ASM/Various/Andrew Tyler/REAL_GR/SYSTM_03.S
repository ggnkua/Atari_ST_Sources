* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 systm_03.s                                   *
* Joystick and mouse routines                                         *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* End automatic reporting from the joystick
joy_off	pea	joyoff_str		pointer the instruction string
	move.w	#0,-(sp)		1 less than length of string
	move.w	#25,-(sp)		function ikbdws
	trap	#14			xbios
	addq.l	#8,sp			tidy
	rts

* Interrogate the joystick		
rd_joy	pea	rdjoy_str		ditto
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
	 		
* Turn the mouse off
mse_off	pea	mseoff_str		ditto
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

* Set up the mouse for reporting in relative mode i.e. position change
mse_rel
	pea	relmse_str		ditto
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

* Intercept GEM joystick routine with our own 
init_joy:
	move.w	#34,-(sp)	find the table of vectors
	trap	#14		using xbios call kbvbase: address in d0
	addq.l	#2,sp		tidy stack
	move.l	d0,a0		base pointer
	move.l	24(a0),gem_joy	hijack GEM vector
	lea	joy_handle,a1
	move.l	a1,24(a0)	substitute mine
	rts			and sneak off

* This is my joystick data packet handler. Now when an interrupt occurs
* my handler will be activated with a0 pointing to the data packet.
joy_handle:
	clr.w	d0
	move.b	1(a0),d0	
	move.w	d0,joy_data	the second data byte has the info
	rts			

* When I've finished, put back the GEM handler as if nothing happened
joy_term:
	move.w	#34,-(sp)	call xbios kbvbase
	trap	#14		
	addq.l	#2,sp		tidy
	move.l	d0,a0		base pointer
	move.l	gem_joy,a1	dust off GEM's
	move.l	a1,24(a0)	and return it
	rts			before I'm spotted


* Intercept the mouse packet handler with our own
init_mse:
	move.w	#34,-(sp)	find the table of vectors
	trap	#14		using xbios call kbvbase: address in d0
	addq.l	#2,sp		tidy stack
	move.l	d0,a0		base pointer
	move.l	16(a0),gem_mse	hijack GEM vector
	lea	mse_handle,a1
	move.l	a1,16(a0)	substitute mine
	rts			and sneak off
* This is my mouse data packet handler. Now when an interrupt occurs
* my handler will be activated with a0 pointing to the data packet.
mse_handle:
	clr.w	d0
	move.b	(a0)+,d0	1st byte is the header
	move.w	d0,mse_click	save it
	move.b	(a0)+,d0	next byte is
	move.w	d0,mouse_dx	the x displacement relative to last position
	move.b	(a0),d0		last byte is
	move.w	d0,mouse_dy	ditto y
	rts				

* When I've finished, put back the GEM handler as if nothing happened
mse_term:
	move.w	#34,-(sp)	call xbios kbvbase
	trap	#14		
	addq.l	#2,sp		tidy
	move.l	d0,a0		base pointer
	move.l	gem_mse,a1	dust off GEM's
	move.l	a1,24(a0)	and return it
	rts			before I'm spotted

* The strings to be sent to the ikbd are just the command numbers
* Each string is 1 byte long
mseoff_str	dc.b	$12	turn off the mouse
joyoff_str	dc.b	$15	turn off default automatic joystick reporting
rdjoy_str	dc.b	$16	interrogate the joystick	
relmse_str	dc.b	$08	put the mouse in relative mode automatic report
