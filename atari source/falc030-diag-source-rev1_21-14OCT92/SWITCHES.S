*------------------------------------------------
* Switches.s - display setting of config switches
*		and STe joystick movements.
*	By Roy Stedman @ Atari : 19DEC91 
*------------------------------------------------
* 06JAN92 : RWS : Added STe joysticks & cut data size

* STe JOYSTICK TEST REMOVED AND NOT TESTED : 07JAN92 : RWS
* DUE TO LACK OF TEST ITEMS (ie : none around here)
* FIRE BUTTONS WORK, NO TEST OF DIGITAL PORTS

* NOTE: THERE ARE TWO SETS OF CONFIGURATION SWITCHES

* THE ONLY SAFE WAY TO ACCESS $FF9200 ON ALL STE, MEGA STE
* AND TT IS TO DO A WORD READ OF THAT LOCATION!

* SP config switches vvmm rdbs
* vv = monitor type, mm = memory type, r = rom speed, 
* d = DRAM speed, b = video bus width, s = # of simms

* ST config switch format is : dfqX XXXX
* d = sound dma, f = slow floppy, q = quad floppy, X = unused

	.text

Switches:
 	bsr	clearsc		; Clear Screen, Setup & etc..
	lea	SwTemplMsg,a5	; Draw template
	bsr	dspinv

*- Show ST switches
	lea	STSwMsg,a5
	bsr	dspmsg
	lea	SWMsg,a5
	bsr	dspmsg
	move.w	STConfig,d0	; Read config reg.
	ror.w	#8,d0		; swap bytes
	bsr	Dbyte

*- Show SP switches
	lea	SPSwMsg,a5
	bsr	dspmsg
*	lea	SWMsg,a5	; uncomment back in if SWMsg Moves!
*	bsr	dspmsg		; RWS : 06JAN92
	move.b	SPConfig,d0	; Read config reg.
	bsr	Dbyte

*- Show fire buttons
*	bsr	Joystick	

        bsr     uconin		; Wait for upcase char
        cmpi.b  #esc,d0		; if esc, exit, else restart 
        bne.s   Switches
	rts

	
* Display bits in lower byte of d0
Dbyte:
	movem.l	d0-d1/a5,-(sp)
	move.w	#7,d1		; Display bits 1..8
	bra	Dloop
Dnibble:
	movem.l	d0-d1/a5,-(sp)
	move.w	#3,d1
	bra	Dloop
Dbit:
	movem.l	d0-d1/a5,-(sp)
	clr.w	d1
Dloop:
	ror.b	#1,d0	
	bcs	.DOne
*DZero:
	lea	SwOffMsg,a5
	bsr	dspmsg
	bra.s	.DlEnd
.DOne:
	lea	SwOnMsg,a5
	bsr	dspmsg
.DlEnd:
	dbra	d1,Dloop
	movem.l	(sp)+,d0-d1/a5
	rts


*-------------------------------------
* display STe joystick switches
*Joystick:
*	lea	JoyTemplMsg,a5
*	bsr	dspmsg
*	move.b	JoyReg1,d0
*	ror.l	#8,d0
*	move.b	JoyReg2,d0
*	move.w	STConfig,d1
*	move.w	#3,d2		; sticks 0-3 (4 total)
*JSticks:
*	lea	JoyMsg,a5	; print ' JOY '
*	bsr	dspmsg
*	move.w	#3,d3		; show number (0 .. 3)
*	sub.w	d2,d3
*	exg	d3,d1
*	bsr	dspdec		; d1 = dec nibble to display
*	bsr	dsptab
*	exg	d1,d3		; swap fire bits back
*	rol.w	#4,d0		; start w/Joy0 & increment
*	bsr	Dnibble	
*	exg	d0,d1		; swap for fire bit
*	bsr	Dbit
*	exg	d0,d1		; swap back
*	ror.w	#1,d1		; next fire bit
*	bsr	crlf
*	dbra	d2,JSticks
	rts

*-------------------------------------
	.data	
	.even


* Display Template:  XX Switches #:	 0  1  2  3  4  5  6  7
* XX is SP or ST	1 = ON		------------------------
*			0 = OFF	         0  1  0  0  1  1  0  1 

* STe Joystick Status:	 Up Dn Lt Rt Fire	

*		Joy0	 1  0  1  0  1
*		Joy1	 0  0  0  0  0
*		Joy2     1  1  1  1  1
*		Joy3 	 0  1  0  1  0

SwTemplMsg:	dc.b	cr,lf
		dc.b	invtog,'Configuration Switch Settings',invtog
		dc.b	cr,lf,cr,lf 
		dc.b	eot
STSwMsg:	
		dc.b	'ST ',eot
SPSwMsg:
		dc.b	cr,lf,cr,lf
		dc.b	'SP '	
*		dc.b	eot 	*** RWS : 06JAN92 : PUT BACK IN IF SWMsg moves (& add code to display it)
SWMsg:
		dc.b	'Switches #:',tab,' 0  1  2  3  4  5  6  7',cr,lf
		dc.b	'     1 = ON   ',tab,'------------------------',cr,lf
		dc.b	'     0 = OFF  ',tab,eot

SwOnMsg:	dc.b	' 1 ',eot
SwOffMsg:	dc.b	' 0 ',eot

*JoyTemplMsg:	dc.b	cr,lf,cr,lf
*		dc.b	'STe Joysticks:      Up Dn Lt Rt Fire',cr,lf,cr,lf,eot
*JoyMsg:		dc.b	tab,tab,'Joy',eot

