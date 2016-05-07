;:ts=10	; tell Z editor tab = 10 spaces

; This module contains a number of routines I use to make the color pallete
; change mid-screen.  In fact I don't change the whole palette, just colors
; 1, 2, and 3.  Also I make sure I have a line of solid color 0 on the
; line where the interrupt occurs.  The result is a very solid display.
; Without this line of 0 I get a flashing raggedy left edge.

; This example was put together partly from the pre-TOS example on BIX
; in ataricorp/long.  It's written for Manx-Aztec C, so you'll have to
; munge it for Megamax or Mark Williams.  Maybe not much for Mad Max, which
; at least uses pretty standard 68000 syntax.

; There are 4 routines you can access externally (they're set up to call
; from C.), and also a total of 4 interrupt handlers.

; pfinit()	sets up our little interrupt system
; pfcleanup()	turns it back off (good idea before using GEM file selector)
; timebon()	tells hardware to generate timer B (horizontal scan) interrupts
; timeboff()	tells hardware not to generate timer B interrupts

; A typical calling sequence from C in low rez might be:

;	vbcmap = my_cmap;	/* display this color map mostly */
;	stripe1.height = 10;	/* 10 lines of menus on top */
;	stripe2.height = 120;	/* 120 lines of normal color palette */
;	stripe3.height = 70;	/* another 70 lines for menu at bottom */
;	/* now set middle stripe's colors to be same as "normal" */
;	stripe2.cmap[0] = my_cmap[1];
;	stripe2.cmap[1] = my_cmap[2];
;	stripe2.cmap[2] = my_cmap[3];
;	pfinit();	/* set up interrupt vectors */
;	timebon();	/* enable timer b interrupts */
;	       ...	/* process user input for a while... */
;	pfcleanup();	/* tear down our interrupt structure */
;		...



	far	data	; tell Manx to use absolute addresses

CMAP    EQU     $FF8240         * hardware color map
DBASELO EQU     $FF8203	  * middle 8 bits of screen address
DBASEHI EQU     $FF8201         * bits 16-23 of screen address

* Some interrupt vector locations
MFPINT  EQU     $40
HCNTINT EQU     MFPINT+$08
HCNTVEC EQU     HCNTINT*4
TIMINT  EQU     MFPINT+$0D
TIMVEC  EQU     TIMINT*4
SYSVEC  EQU     $114
KEYVEC  EQU     $118

VSYNINT EQU     28
VSYNVEC EQU     VSYNINT*4

* 68901 MFP definitions
MFP     EQU     $FFFA01
GPIP    EQU     MFP+$00
AER     EQU     MFP+$02
DDR     EQU     MFP+$04
IERA    EQU     MFP+$06
IERB    EQU     MFP+$08
IPRA    EQU     MFP+$0A
IPRB    EQU     MFP+$0C
ISRA    EQU     MFP+$0E
ISRB    EQU     MFP+$10
IMRA    EQU     MFP+$12
IMRB    EQU     MFP+$14
VR      EQU     MFP+$16
TACR    EQU     MFP+$18
TBCR    EQU     MFP+$1A
TCDCR   EQU     MFP+$1C
TADR    EQU     MFP+$1E
TBDR    EQU     MFP+$20
TCDR    EQU     MFP+$22
TDDR    EQU     MFP+$24
SCR     EQU     MFP+$26
UCR     EQU     MFP+$28
RSR     EQU     MFP+$2A
TSR     EQU     MFP+$2C
UDR     EQU     MFP+$2E

	cseg	; we're in the code segment now

*_pfinit - pfinit()
*	This steals 4 interrupt handlers so can have a relatively stable
*	palette shift mid-screen.   
*
	public _pfinit	; and want to call pfinit() from C
_pfinit	; routine to set up our 4 interrupt handlers.
	move.l	HCNTVEC,_otimerb	;save all of the old
	move.l	VSYNVEC,_ovblank	;interrupt handler
	move.l	SYSVEC,_osysvec		;routines
	move.l	KEYVEC,_okeyvec
	move	SR,_statusreg		;save status register
	ori.w	#$700,SR       		;disable interrupts
	move.l	#jimvblank,VSYNVEC	;Take over vertical blank
	move.l	#jimtimerb,HCNTVEC  	;Take over Timer B/hblank counter
	move.l	#jimsysvec,SYSVEC	;Take over 200Hz system interrupt
	move.l	#jimkeyvec,KEYVEC	;And take over midi/mouse/keybd vector
	move.w	_statusreg,SR		;restore status register
	rts

*_pfcleanup - pfcleanup()
*	This restores the system to the state it was before pfinit().
*	Turns off the timer B interrupt, services any pending 200Hz
*	system interrupts, and then restores the 4 interrupt vectors
*	we stole in pfinit().

	public	_pfcleanup
_pfcleanup
        	move	SR,_statusreg
	bsr	_timeboff
	move.w	#$2600,SR       ; disable interrupts

	;see if have pending sysvec(s) to service

last_sysservice
	tst.w	syscount
	beq	restoremore

	;fake some sys interrupts
	pea	last_here(pc)
	move.w	sr,-(sp)
	;move.w	#$2600,SR       ; disable (real) interrupts
	move.l	_osysvec,-(sp) ; jump through system vector
	rts
last_here	
	;move.w	#$2600,SR       ; disable interrupts
	sub.w	#1,syscount
	bra	last_sysservice


restoremore
	move.l	_ovblank,VSYNVEC	;restore old vector
	move.l	_otimerb,HCNTVEC	;restore old vector
	move.l	_osysvec,SYSVEC
	move.l	_okeyvec,KEYVEC
	move.w	_statusreg,SR		;re-enable interrupts
	rts



*_timebon - timebon()
*    Tell hardware to start generating interrupts on timer B
	public	_timebon
_timebon	
	move.b  #$10,TBCR       * reset Timer B
	move.b  #255,TBDR         * set the number of horiz syncs before int
	move.b  #$08,TBCR       * put Timer B back in event count mode
	bset    #0,IERA         * now enable (counted) horizontal ints
	bset    #0,IMRA
	rts


*_timeboff - timeboff()
*	Tell hardware to stop generating interrupts on timer B

	public	_timeboff
_timeboff
	bclr    #0,IERA
	bclr    #0,IMRA
	rts


*jimsysvec - installed for the 200Hz system timer.  Just increments a count
*	to tell us how many times this interrupt has been recieved.  Jimvblank
*   will then call the old system vector that many times.
jimsysvec	
	add.w	#1,syscount
	rte




*jimvblank - This is a vertical blank handler which does about 3 major things.
*	1.	Increments a counter by one, so I can have a nice 60Hz 
*		clock for my main code.
*	2.	It checks to see if vbcmap is non-zero, and if so, stuffs the 16
*		words vbcmap points to into the hardware color palette.
*		(Essentially this duplicates the Setpalette() BIOS call.
*	3.	Sets colors 1, 2, and 3 to top of frame values, and
*		sets up variables for jimtimerb to handle color shifts
*		further down the screen.
*	4.	Calls the system 200Hz timer interrupt service routine
*		a number of times to make up for stealing that interrupt
*		vector, so we'd have a relatively stable palette shift
*		mid-screen.

jimvblank
	movem.l	a0/a1/d0,-(sp)

	; increment vblank counter
	add.l	#1,_vbcount

	; see if there's a color map to poke...
poke_cmap
	move.l	_vbcmap,d0
	beq	poke3
	move.l	d0,a0
	move.l	#CMAP,a1
	move.w	#7,d0
cccplp	move.l	(a0)+,(a1)+
	dbra	d0,cccplp
	move.l	#0,_vbcmap

poke3
	move.l	_startclist,a0
	move.l	#CMAP+2,a1
	tst.b	7(a0)
	bne	copycolor
	add	#8,a0
copycolor
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.b  #$10,TBCR       * reset Timer B
	move.b  1(a0),TBDR         * set the number of horiz syncs before int
	move.b  #$08,TBCR       * put Timer B back in event count mode
	add	#2,a0
	move.l	a0,_clist	    * save rest of display list for hblank

	;see if have a pending sysvec to service
	move.w	SR,-(sp)	; save priority
	move.w	#$2600,SR       ; disable interrupts
sysservice
	tst.w	syscount
	beq	regvblank


	;fake some sys interrupts
	pea	here(pc)
	move.w	SR,-(sp)
	move.l	_osysvec,-(sp)
	rts
here	
	sub.w	#1,syscount
	bra	sysservice

regvblank
	move.w	(sp)+,SR
	movem.l	(sp)+,a0/a1/d0
	move.l	_ovblank,-(sp)
	rts



*jimtimerb - this routine is only called when timer b is enabled.
*	It stuffs the palette from the clist pointer, and increments that
*   pointer.  Then tells timer b to wait for the height of this stripe
*	before interrupting us again.  (The clist pointer is initialized
*	in the vblank handler.)
jimtimerb 
	move.l	a0,-(sp)
	move.l	_clist,a0
	move.l	(a0)+,CMAP+2
	move.w	(a0)+,CMAP+6
	move.b  #$10,TBCR       * reset Timer B
	move.b  1(a0),TBDR         * set the number of horiz syncs before int
	move.b  #$08,TBCR       * put Timer B back in event count mode
	add	#2,a0
	move.l	a0,_clist
	move.l	(sp)+,a0
	bclr    	#0,ISRA

	rte



*jimkeyvec - all this does is lower the interrupt priority level of the
*	68000, and then jump to the old interrupt routine
jimkeyvec	
	move.w	#$2500,sr
	move.l	_okeyvec,-(sp)
	rts

	dseg

syscount	dc.w	0	;how many times we've had a sys interrupt



*The stripes - these are the horizontal areas of the screen and their
*associated color maps for colors 1-3 (color 0 is unchanged).
*The format for a stripe is:
*	value for color 1
*	value for color 2
*	value for color 3
*	height of stripe

	public _stripe1
	public _stripe2
	public _stripe3
	public _stripe4
	public _stripe5

_stripe1	dc.w	$777,$000,$700,0
_stripe2	dc.w	$004,$007,$141,200
_stripe3	dc.w	$777,$000,$700,255
_stripe4	dc.w	$004,$007,$141,10
_stripe5	dc.w	$777,$000,$700,255

*startclist is a pointer to the first "stripe"
	public _startclist
_startclist
	dc.l	_stripe1
_clist
	dc.l	_stripe1

* here's some miscellanious global data places
	global	_ovblank,4	;where to put the old vblank vector
	global	_otimerb,4	;where to put the old timer b vector
	global	_osysvec,4	;where to put old 200 hz system vector
	global	_okeyvec,4	;old keyboard/midi/mouse vector
	global	_vbcmap,4	;pointer to color map for vblank to poke
	global	_vbcount,4  ;counter incremented once each vblank
	global	_statusreg,2 ;place to save status register (could be on stack...)

	public	_pscreen
