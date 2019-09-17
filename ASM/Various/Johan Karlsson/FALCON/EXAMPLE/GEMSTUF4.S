*********************************************************
*							*
* A very short window demonstration using a rsrc file	*
*							*
*********************************************************

	include	releasem.s	release unused memory
	include	getpar.s	find where the parameters sent to the program are

	move.l	a0,parbuf	save the address

	bra	main

	include	gemmacro.i	this one is supplied with devpac
	include	shrtones.s
	include	window.s
	include	winevent.s
	include	gem.s
		

wtype	equ	%01011	info, move, full, close and name
windowname	dc.b	'hello world',0

main	move.l	#rsrcfile,a0
	bsr	@loadrsrc
	move.l	a0,rsrcadr
	bra	@dowindowevents	this routine will take care of all the common events

buttonevent	cmp	#1,d0	was my button pressed?
	beq	button1	yes!
	rts

button1	form_alert alertbutton,#alerttext
	rts
		
closeevent	bsr	@exitwindow
	rsrc_free
	bra	@quit

rsrcfile	dc.b	'gemstuf.rsc',0
		
	even
alertbutton	dc.w	1
alerttext	dc.b	'[2][You have not saved anything|are you sure you want to quit?][    Yes    ]',0
buttontext	dc.b	'a button',0

	include	aeslib.s	supplied with devpac
	include	vdilib.s	supplied with devpac
		
	section bss
		
parbuf	ds.l	1
rsrcadr	ds.l	1
