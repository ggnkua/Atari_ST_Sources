*	Feb 3, 87  edit for madmac
*	Nov 14, 86  Run at least 2 seconds to debounce to mono connector
*	Escape key to avoid the test
*	Put up a display for the monochrome monitor:
*	crosshatch pattern, lines are 2 bit wide.
*	Reverse screen every 2 seconds.

	.text
	.extern hires

hires:	moveq	#15,d0
	movea.l	#hiresi,a2
	bsr	initint

*	Prompt operator to connect monitor
*	movea.l	#monomsg,a5
*	bsr	dsptst

*	Save current resolution and color
	move.b	v_shf_mod,d0
	andi.b	#$3,d0
	move.b	d0,resmod
	move.w	palette,d0
	andi.w	#$777,d0
	move.w	d0,colsav

*	See if monitor is connected

monotst:
*	btst	#7,mfp+gpip	;test monomon
* NEW 23MAR92 : RWS --- 
	move.b	SPConfig,d0	; NOTE: SIDE EFFECTS OF BANGING THIS!!
	andi.b	#$c0,d0		;get VV bits
	cmp.b	#$00,d0
* ---
	beq.s	go_hi
	bsr	constat
	tst	d0
	beq.s	monotst

	bsr	conin
	cmpi.b	#esc,d0
	bne.s	monotst	
	rts			;quit without doing anything

go_hi:	move.w	#bgrnd,palette	;if already mono and previous error,
*				;need to restore screen

*****************************************
*	Got a monochrome connection	*
*	Interrupt routine will set up hi-res mode
*	Write crosshatch pattern, lines are 2 pixels wide
	movea.l	#$20000,a0
	move.b	#2,v_bas_h
	clr.b	v_bas_m

*	Write one line (so borders will be smooth)
	moveq	#39,d0
mono0:	move.w	#$0,(a0)+
	dbra	d0,mono0

*	Write 2 scan lines of vertical bars
mono1:	moveq	#79,d0		;# of words across, 40 words/line
mono2:	move.w	#$6666,(a0)+
	dbra	d0,mono2

*	Write 2 scan lines of solid (horizontal bars)
	moveq	#79,d0
mono3:	move.w	#0,(a0)+
	dbra	d0,mono3

	cmpa.l	#$28000,a0
	blt	mono1

*	Wait for signal to return
	move.l	$70,-(a7)	;get current vblank and save it
	move.l	#vbhires,$70	;replace with blink routine
	move.l	#120,templ.w
	move	#$2200,sr	;blink screen
mono4:	cmp.l	#1,templ.w	;wait 2 seconds to get good connection
	bne.s	mono4
	cmp.b	#2,resmod	;previous res = hi?
	bne.s	mono5		;br no

	bsr	conin		;if using hires, wait for key
	move	#$2700,sr
	move.b	#scrmemh,v_bas_h ; flip back to normal display
	bne.s	nrmres

mono5:	btst	#7,mfp+gpip	;if using RGB, wait for disconnect
	beq.s	mono5
	move	#$2700,sr	;don't let mono int's happen now
	bsr	wait
	move.b	resmod,v_shf_mod	;restore resolution
	move.b	#scrmemh,v_bas_h	;restore screen address
	
*********************************
*	Return to menu		*

nrmres:	move.l	(a7)+,$70	;restore vblank vector
	move.l	#monomon,$13c	;restore monon interrupt vector
	btst	#mlttst,consol	;is this the only test?
	bne.s	nrmrs0		;br no, save screen until key pressed
	bset	#7,consol	;yes, don't wait for key, print menu

nrmrs0:	move.w	colsav,palette
	move	#$2400,sr
	rts
*
*********************************

*	Vblank handler to reverse screen
vbhires:
	move	d0,-(a7)
	clr.b	lcount
	sub.l	#1,templ.w
	bne.s	vbhrs
	move	palette,d0
	eor	#1,d0
	move	d0,palette
	move.l	#120,templ.w	;reverse every 2 secs.
vbhrs:	move	(a7)+,d0
	rte

	.data

monomsg: dc.b	'Connect monochrome monitor',cr,lf,eot
discon:	dc.b	'Disconnect monochrome monitor',cr,lf,eot
hrkmsg:	dc.b	'Press any key to return to menu',cr,lf,eot

