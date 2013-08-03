;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	Dummy.mainloop
	dc.l	Dummy.init
	dc.l	Dummy.rt_init			; 2
	dc.l	Dummy.deinit
	dc.l	dummy				; 4
	dc.l	dummy				; 5
	dc.l	dummy				; 6
	dc.l	0

;- plugin routines ---------------------------------------------------------

Dummy.init:
	rts

Dummy.rt_init:
	rts

Dummy.deinit:
	rts

Dummy.mainloop:
	rts
