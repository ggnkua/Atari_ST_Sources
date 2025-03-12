* STORM Development Extension (Part I) - INTERPRETER VERSION 0.4(Beta)
*
* WRITTEN BY NEIL HALLIDAY 1995
* (C)1995 STORM Developments.
* 
* FULL VERSION!

*
* USAGE:
*
* Padup..	x=padup(port)..		Read STE powerpad (up)
* Paddown..	x=paddown(port)..	Read STE powerpad (down)
* Padleft..	x=padleft(port)..	Read STE powerpad (left)
* Padright..	x=padright(port)..	Read STE powerpad (right)
* Padpause..	x=padpause(port)..	Read STE powerpad (pause)
* Padafire..	x=padafire(port)..	Read STE powerpad (firea)
* Padbfire..	x=padbfire(port)..	Read STE powerpad (fireb)
* Padcfire..	x=padcfire(port)..	Read STE powerpad (firec)
* Padoption..	x=padoption(port)..	Read STE powerpad (option)
* Padbutton..	x=padbutton(port)..	Read STE powerpad extra buttons 
*					returns 16bit value to be read
*
*
* Hardpixel..	hard pixel num..	Set STE Hardpixel offset
* Hardscreen..	hardscreen addr..	Set STE Hardscroll screen address
* Hardlinewid..	hardlinewid num..	Set STE Overlength line width
* Hardreset..	hardreset..		Reset from an STE hardscroll
* Hardscroll..	
*     scrn,xpos,ypos,width,height,mode 	Set STE Hardware map
*
*
*
* csticks on..	csticks on..		Turn on Centronics input
* csticks off..	csticks off..		Turn off Centronics input
*
* cstick up..	x=cstick up(port)..	Read Centronics port (up)
* cstick down..	x=cstick down(port)..	Read Centronics port (down)
* cstick left..	x=cstick left(port)..	Read Centronics port (left)
* cstick right.	x=cstick right(port)..	Read Centronics port (right)
* cstick fire..	x=cstick fire(port)..	Read Centronics port (fire)
*
*
* Screensaveron physic..		Enable screen saver
* Screensaveroff..			Disable screen saver
* Set clock..	setclock time..		Set screen saver activation time
*					
*
* auxout..	auxout val..		Send some data to the AUX port
* auxstat..	x=auxstat..		Get status of AUX port
* auxset..	auxset val,val..	Set the RS232 port

* blitfcopy..	blitfcopy srce,dest..	Copy a full screen using blitter  
*
*
	bra	init
	dc.b	128
	
tokens:

	dc.b	"hardscreen",128		; Hardscreen
	dc.b	"pad up",129			; Pad up
	dc.b	"hardlinewid",130		; Hardlinewid
	dc.b	"pad down",131			; Pad down
	dc.b	"hardpixel",132			; Hardpixel
	dc.b	"pad left",133			; Pad left
	dc.b	"auxout",134			; Auxout
	dc.b	"pad right",135			; Pad right
	dc.b	"hardreset",136			; Hardreset	
	dc.b	"pad pause",137			; Pad pause
	dc.b	"csticks on",138		; Csticks on
	dc.b	"pad afire",139			; Pad afire
	dc.b	"csticks off",140		; Csticks off
	dc.b	"pad bfire",141			; Pad bfire
	dc.b	"screensaver on",142		; Screensaver on					
	dc.b	"pad cfire",143			; Pad cfire
	dc.b	"screensaver off",144		; Screensaver off
	dc.b	"pad option",145		; Pad option
	dc.b	"set clock",146			; Set clock
	dc.b	"pad button",147		; Pad button
	dc.b	"hardscroll",148		; hardscroll
	dc.b	"cstick up",149			; C up
	dc.b	"auxset",150			; Auxset			
	dc.b	"cstick down",151		; C down
	dc.b	"bfcopy",152			; Blit fcopy
	dc.b	"cstick left",153		; C left
	dc.b	"nrh",154
	dc.b	"cstick right",155		; C right
	dc.b	"nrh",156
	dc.b	"cstick fire",157		; C fire
	dc.b	"nrh",158
	dc.b	"auxstat",159			; Auxstat
	dc.b	0
	even
	
jump:	dc.w	32 
	dc.l	hardscreen
	dc.l	padup
	dc.l	hardlinewid
	dc.l	paddown
	dc.l	hardpixel
	dc.l	padleft
	dc.l	auxout
	dc.l	padright
	dc.l	hardreset
	dc.l	padpause
	dc.l	cstickson
	dc.l	padafire
	dc.l	csticksoff
	dc.l	padbfire
	dc.l	screensaveron
	dc.l	padcfire
	dc.l	screensaveroff
	dc.l	padoption
	dc.l	setclock
	dc.l	padbutton
	dc.l	hscroll
	dc.l	cup
	dc.l	auxset
	dc.l	cdown
	dc.l	bfcopy
	dc.l	cleft
	dc.l	dummy
	dc.l	cright
	dc.l	dummy
	dc.l	cfire
	dc.l	dummy
	dc.l	auxstat

message:


	dc.b	10,$15,"** V0.4(beta) STORM Development Extension (Part  I) (c)STORM '95 **",$12,0
	dc.b	10,$15,"** V0.4(beta) STORM Development Extension (Part  I) (c)STORM '95 **",$12,0
	dc.b	0
	even
	
system:	dc.l	0
	
return:	dc.l	0
	
init:	
	lea	exit,a0
	lea	coldst,a1
	rts
	
coldst:
	move.l	a0,system
	lea 	message,a0
	lea	warm,a1
	lea	tokens,a2
	lea	jump,a3
	
warm:	rts

dummy:	rts


**     COMMAND:	HARDSCREEN
**  	SYNTAX:	HARDSCREEN addr
**
** DESCRIPTION:	Set STE hardware scroll screen address

hardscreen:
	
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax
	
	bsr	getint			;
	move.l	d3,d0			; Set screen address for next VBL
	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,$ff8203		; Middle byte
	lsr.l	#8,d0
	move.b	d0,$ff8201		; High byte
	move.b	d1,$ff820d		; Low byte
	
	move.l	return,a0		; Return to STOS
	jmp	(a0)
	




**     COMMAND:	PADUP
**  	SYNTAX:	x=PADUP(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is up.
**		Values returned are TRUE/FALSE (-1/0)

padup:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.w  $ff9202,d1		; Read 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#8,d1			; Port A up?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#12,d1			; Port B up?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)


**     COMMAND:	HARDLINEWID
**  	SYNTAX:	HARDLINEWID wid
**
** DESCRIPTION:	Set the overlength line width for the STE
**		hardware scroll

hardlinewid:
	
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax
	
	bsr	getint			; Get linewid
	move.b	d3,$ff820f		; Set line width
	
	move.l	return,a0		; Back to STOS
	jmp	(a0)



**     COMMAND:	PADDOWN
**  	SYNTAX:	x=PADDOWN(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is down.
**		Values returned are TRUE/FALSE (-1/0)

paddown:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.w  $ff9202,d1		; Read 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#9,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#13,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	HARDPIXEL
**  	SYNTAX:	HARDPIXEL xpos
**
** DESCRIPTION:	Set the scroll position for the hardscroll

hardpixel:
	
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax
	
	bsr	getint			; Get pixel offset
	move.b	d3,$ff8265		; Set pixel offset
	
	move.l	return,a0		; Back to STOS
	jmp	(a0)



**     COMMAND:	PADLEFT
**  	SYNTAX:	x=PADLEFT(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is left.
**		Values returned are TRUE/FALSE (-1/0)

padleft:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.w  $ff9202,d1		; Read 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#10,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#14,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)


**     COMMAND:	AUXOUT
**  	SYNTAX:	AUXOUT val
**
** DESCRIPTION:	Send a value to the AUX port
**		


auxout:	move.l	(a7)+,return		; Save return
	cmp	#1,d0
	bne	syntax
	
	bsr	getint			; Ypos
	move.w	d3,-(sp)
	move.w	#1,-(sp)		; Bconout
	move.w	#3,-(sp)
	trap	#13
	lea	6(sp),sp
	
	move.l	return,a0		; Load return
	jmp	(a0)
	even
	

**     COMMAND:	PADRIGHT
**  	SYNTAX:	x=PADRIGHT(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is right.
**		Values returned are TRUE/FALSE (-1/0)

padright:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.w  $ff9202,d1		; Read 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#11,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#15,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	HARDRESET
**  	SYNTAX: HARDRESET
**
** DESCRIPTION:	Reset the STE hardware after a Hardscrolling session

hardreset:
	move.l	(a7)+,return		; Save return
	move.b	#0,$ff8265		; Set pixel offset to 0
	move.b	#0,$ff820f		; Set line width to 0
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it	
	


**     COMMAND:	PADPAUSE
**  	SYNTAX:	x=PADPAUSE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is pause.
**		Values returned are TRUE/FALSE (-1/0)

padpause:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.b  $ff9201,d1		; Read fire return 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#0,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#2,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	CSTICKS ON
**  	SYNTAX:	CSTICKS ON
**
** DESCRIPTION:	Turn on the centronics interface, for I/O

cstickson:
	move.l	(a7)+,return		; Save return

	move.b	#7,$ff8800		; Write PSG 7
	move.b	#0,$ff8802		; 
	
	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it	
	


**     COMMAND:	PADAFIRE
**  	SYNTAX:	x=PADAFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is firea.
**		Values returned are TRUE/FALSE (-1/0)

padafire:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11101110,$ff9202	; Set Directions
	move.b  $ff9201,d1		; Read fire return 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#3,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)




**     COMMAND:	CSTICKS OFF
**  	SYNTAX:	CSTICKS OFF
**
** DESCRIPTION:	Turn off the centronics interface, for I/O

csticksoff:
	move.l	(a7)+,return		; Save return

	move.b	#7,$ff8800		; Write PSG 7
	move.b	#254,$ff8802		; 

	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it	





**     COMMAND:	PADBFIRE
**  	SYNTAX:	x=PADBFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is fireb.
**		Values returned are TRUE/FALSE (-1/0)

padbfire:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%11011101,$ff9202	; Set Directions
	move.b  $ff9201,d1		; Read fire return 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#3,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	SCREENSAVER ON
**  	SYNTAX:	SCREENSAVER ON physic 
**
** DESCRIPTION:	Turn the screen saver on

screensaveron:

	move.l	(a7)+,return		; Save return
	
	cmp	#1,d0
	bne	syntax
	
	bsr	getint
	move.l	d3,scraddr		; Save screen address
	
	move.l	#0,scount		; Reset counter
	move.b	$fffffc02,oldkey	; Save first key value

	move.l	#saver,$4ea		; Install vbl
		
	move.l	return,a0		; Load return
	jmp	(a0)
	
	
saver:
	move.b	$fffffc02,d1		; Get new input
	cmp.b	oldkey,d1		; Check new keyboard input
	beq	.next			; No change
	move.l	#0,scount		; Reset counter
	move.b	d1,oldkey		; Save keyboard input
	rts				; Return
	
.next	add.l	#1,scount		; Increase count
	move.l	stimer,d0		; Load activation counter 
	cmp.l	scount,d0		; Is the counter the same?
	beq	.save			; Yes save the screen
	rts				; Return			


** The screen saver routine

.save:	
	move.l	#0,$4ea			; Turn off interupt
	move.l	#.sav,$4ea		; Install saver vbl
					; processing should continue


.sav	lea	buffer,a0
	move.l	scraddr,a1		; Copy top of screen

	REPT	40
	move.l	(a1)+,(a0)+
	ENDR	

	move.l	scraddr,a0		; Screen address
	add.l	#160,a0			; Scanline 1 please
	move.l	scraddr,a1

	move.w	#0,d0
.lp	REPT	40			; Copy a scanline
	move.l	(a0)+,(a1)+		; Copy data up a scanline		
	ENDR
	addi.w	#1,d0			; Increase d0
	cmpi.w	#199,d0
	bne	.lp

	lea	buffer,a0
	move.l	scraddr,a1		; Copy top of screen to bottom
	add.l	#31840,a1
	REPT	40
	move.l	(a0)+,(a1)+
	ENDR	
	

	move.b	$ffffc02,d1		; Get key input
	cmp.b	oldkey,d1
	bne	.end			; Not same, end
	move.b	d1,oldkey		; Save again

	rts
		

.end	move.l	#0,$4ea
	move.l	#0,scount		; Reset counter
	move.w	#23,d0			; Screencopy back to physic
	trap	#5
	move.l	#saver,$4ea		; Re-install vbl
	rts
	
scraddr:ds.l	1			; Space for screen address
scount:	ds.l	1			; Space for counter
stimer:	ds.l	1			; Space for wait time
wid:	ds.w	1
hig:	ds.w	1
buffer	ds.b	160			; Space for 1 scanline

oldkey:	ds.b	1			; Space for last keypress
	even	




**     COMMAND:	PADCFIRE
**  	SYNTAX:	x=PADCFIRE(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is firec.
**		Values returned are TRUE/FALSE (-1/0)

padcfire:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%10111011,$ff9202	; Set Directions
	move.b  $ff9201,d1		; Read fire return 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#3,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	SCREENSAVER OFF
**  	SYNTAX:	x=SCREENSAVER OFF
**
** DESCRIPTION:	Turn the screen saver on

screensaveroff:

	move.l	(a7)+,return		; Save return
	move.l	#0,$4ea			; Remove VBL
	move.l	return,a0		; Load return
	jmp	(a0)			
	


**     COMMAND:	PADOPTION
**  	SYNTAX:	x=PADOPTION(n)
**
** DESCRIPTION:	Returns if the pad in STE Analogue port N is option.
**		Values returned are TRUE/FALSE (-1/0)

padoption:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	clr.w	d1			; Clear d1
	move.w  #%01110111,$ff9202	; Set Directions
	move.b  $ff9201,d1		; Read fire return 
	
	cmpi.b	#1,d0			; Port B?
	beq	.portb
	
	btst	#1,d1			; Port A?
	beq	.yes
	
	bra	.no			; No!
	
	
.portb:	btst	#3,d1			; Port B?
	beq	.yes
	
	bra	.no			; No!
	
.yes:	move.l	#-1,d3			; Return True
	bra	.exit
	
.no:	move.l	#0,d3			; Return false
.exit:	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)



**     COMMAND:	SET CLOCK
**  	SYNTAX:	SET CLOCK n
**
** DESCRIPTION:	Set the time in seconds of the screen saver

setclock:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax
	
	bsr	getint
	move.l	d3,d0			; Time in seconds
	
	mulu	#50,d0			; Time in vbls
	
	move.l	d0,stimer		; Store it
	
	move.l	return,a0		; Load return
	jmp	(a0)


**     COMMAND:	PADBUTTON
**  	SYNTAX:	x=PADBUTTON(n)
**
** DESCRIPTION: Returns a 16 bit vector containing values for all 
*		the extra buttons of the powerpad (functionkeys).
*		Layout of value returned..
*
*  Bitnumber.. 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
*  
*  Key:..	.  .  .  .  *  #  9  8  7  6  5  4  3  2  1  0


padbutton:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter
	bne 	syntax			; No.. Error
	
	bsr	getint			
	move.b	d3,d0			; Get port number

	move.b	#8,d1			; Set values for reading
	move.b	#9,d2			; port A.
	move.b	#10,d3
	move.b	#11,d4
	
	cmp.b	#1,d0			; Port B?
	bne	.no			; No, direct read
	
** Adjust values for reading port B

	add.b	#4,d1			; Adjust values ready
	add.b	#4,d2			; For reading port B
	add.b	#4,d3
	add.b	#4,d4

.no	clr.w	d6			; Erase space for end value

** Read.. *,7,4,1

	clr.w	d0			; Clear value
	move.w  #%11011101,$ff9202	; Set read mode
	move.w  $ff9202,d0		; Read Values

.star	btst	d1,d0			; *?
	bne	.7
	bset	#11,d6			; "*" is pressed
.7	btst	d2,d0			; 7?
	bne	.4
	bset	#7,d6			; "7" is pressed
.4	btst	d3,d0			; 4?
	bne	.1
	bset	#4,d6			; "4" is pressed
.1	btst	d4,d0			; 1?
	bne	.0
	bset	#1,d6			; "1" is pressed	


** Read.. 0,8,5,2

.0	clr.w	d0			; Clear d0
	move.w	#%10111011,$ff9202	; Set read mode
	move.w	$ff9202,d0		; Read values
	
	btst	d1,d0			; 0?
	bne	.8
	bset	#0,d6			; "0" is pressed
.8	btst	d2,d0			; 8?
	bne	.5			
	bset	#8,d6			; "8" is pressed
.5	btst	d3,d0			; 5?
	bne	.2		
	bset	#5,d6			; "5" is pressed
.2	btst	d4,d0			; 2?
	bne	.hash			
	bset	#2,d6			; "2" is pressed


** Read.. #,9,6,3
	
.hash	clr.w	d0			; Clear d0
	move.w	#%01110111,$ff9202	; Set read mode
	move.w	$ff9202,d0		; Read values

	btst	d1,d0			; 0?
	bne	.9
	bset	#10,d6			; "#" is pressed
.9	btst	d2,d0			; 9?
	bne	.6			
	bset	#9,d6			; "9" is pressed
.6	btst	d3,d0			; 6?
	bne	.3		
	bset	#6,d6			; "6" is pressed
.3	btst	d4,d0			; 3?
	bne	.exit			
	bset	#3,d6			; "3" is pressed
		
.exit:	move.w	d6,d3			; Return false
	move.w	#0,d2			; Expect an integer
	move.l	return,a0		; Return
	jmp	(a0)




**     COMMAND: HARD SCROLL
**  	SYNTAX:	HARD SCROLL screen,xpos,ypos,xwid,yheight,mode
**
** DESCRIPTION: Sets up and looks after the running of the STE hardware
** 		scrolling functions.  Will automatically calculate
**		line widths and offsets from the parameters passed

hscroll:move.l	(a7)+,return		; Save return
	cmp	#6,d0			; 6 Parameters?
	bne	syntax
	bsr	getint			; Mode
	move.w	d3,.mode
	bsr	getint			; Height in pixels
	move.l	d3,.ytmp
	bsr	getint			; Width in pixels
	move.l	d3,.xtmp
	bsr	getint			; Ypos
	move.w	d3,.ypos
	bsr	getint			; Xpos
	move.w	d3,.xpos
	bsr	getint			; Screen address
	move.l	d3,.scrn
	
.check:	cmpi.w	#0,.mode		; Turn off interupt?
	beq	.off
	cmpi.w	#1,.mode		; Turn on interupt?
	beq	.on
	bra	.vbl			; Not recognisable, exit
		
.off:	move.l	#0,$4d2			; Turn off
	bra	.out
.on:	move.l	.xtmp,d0		; Convert Xmax to words
	sub.l	#320,d0			; Get rid of the first 320 pixels 
	divu	#2,d0			; Number of bytes over 
	move.l	d0,.ymax		; Store offset to next scanline			
	add.l	#160,.ymax		; Add a complete scanline to it
	divu	#2,d0			; Number of words over
	move.b	d0,.xm			; 
	move.b	#0,.pixl		; Set initial scroll value

;.out:	move.l	return,a0		; Load return
;	jmp	(a0)			; Jump to it

** STE Hardscroll interupt

.vbl:	move.b	.pixl,$ff8265		; Set pixel offset
	move.w	.xpos,d0		; Load xposition
	move.w	.ypos,d1		; Load yposition
	move.l	.scrn,a0		; Load screen

	move.b	.pixl,d2
	move.b	.xm,d3			; Get overlength width
	cmpi.b	#0,d2			; Are we on 16 boundary?
	beq	.cont			; Yes, line width is fine
	sub.b	#4,d3			; Adjust line width	
.cont:	move.b	d3,$ff820f		; Set line width
	ext.l	d1			; Extend d1 to a long word
	move.l	.ymax,d4		; Load number of bytes to next line
	mulu	d4,d1			; Ypositon in bytes
	add.l	d1,a0			; Add Yposition to screen 
	move.w	d0,d2			; Make a copy
	ext.l	d0			; Extend d0 to a long word
	divu	#16,d0			; Number of 16 blocks to skip
	mulu	#8,d0			; Number of bytes
	add.l	d0,a0			; Add Xoffset to screen
	
	move.l	a0,d0			; Set screen address for next VBL
	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,$ff8203		; Middle byte
	lsr.l	#8,d0
	move.b	d0,$ff8201		; High byte
	move.b	d1,$ff820d		; Low byte

	andi.w	#%0000000000001111,d2	; Mask data
	move.b	d2,.pixl		; Store pixel offset

.out:	move.l	return,a0		; Load return
	jmp	(a0)			; Jump to it

.pixl	ds.b	1			; Pixel offset
.xm	ds.b	1			; Overlength line width
	even
.mode	ds.w	1			; Space for mode
.xpos	ds.w	1			; Space for co-ords
.ypos	ds.w	1		
.xtmp	ds.l	1			; Overlength Width in words
.ytmp	ds.l	1
.ymax	ds.l	1			; Overlength Height in bytes
.scrn	ds.l	1			; Space for screen
	
	

**     COMMAND:	C UP
**  	SYNTAX:	x=C UP(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is in the up position


cup:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get port/stick number
	move.w	d3,d1			; port/stick number

	clr.l	d0
	
	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu.w	#4,d1			; Multiply port to find correct
					; test bit
		
	btst	d1,d0			; Test bit d1 of d0
	bne	.no			; If bit is 0 then stick is up

	move.l	#-1,d3			; True
	bra	.exit
		
.no	move.l	#0,d3			; Send d3 as false
	
.exit	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)




**     COMMAND:	AUXSET
**  	SYNTAX:	AUXSET baud,handshake
**
** DESCRIPTION:	Set the RS232 port's speed and handshake method

auxset:	move.l	(a7)+,return
	bsr	getint
	move.l	d3,d1		; Handshake
	bsr	getint
	move.l	d3,d0		; Baud
	
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	d1,-(sp)	; Handshake
	move.w	d0,-(sp)	; Baud
	move.w	#15,-(sp)
	trap	#14
	lea	14(sp),sp
	
	move.l	return,a0
	jmp	(a0)



**     COMMAND:	C DOWN
**  	SYNTAX:	x=C DOWN(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is in the down position


cdown:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get port/stick number
	move.b	d3,d1			; port/stick number

	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu	#4,d1			; Multiply port to find correct
					; test bit
	add	#1,d1			; Adjust bit for down
		
	btst	d1,d0			; Test bit d1 of d0
	beq	.yes			; If bit is 0 then stick is down
	
.no	move.w	#0,d3			; Send d3 as false
	bra	.exit
	
.yes	move.l	#-1,d3			; Send d3 as true
.exit	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)



**     COMMAND: BLITFCOPY
**      SYNTAX: BLITFCOPY source,destination
** DESCRIPTION: Copy an entire screen using the blitter chip.

bfcopy:	move.l	(a7)+,return		; Save return
	cmp	#2,d0
	bne	syntax
	
	bsr	getint			; Destination screen
	move.l	d3,a1
	
	bsr	getint			; Source screen
	move.l	d3,a0
	
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; 160 byte x counter
	move.w	#200,$ff8a38		; 200 scanline y counter
	move.w	#$ffff,$ff8a28		; End mask (Left)
	move.w	#$ffff,$ff8a2a		; End mask (Middle)
	move.w	#$ffff,$ff8a2c		; End mask (Right)
	move.b	#2,$ff8a3a		; Blitter Halftone Operation
					; (Blit Hop)
	move.b	#3,$ff8a3b		; Blitter Operation (Blit Op)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Execute blitter operation
	
	move.l	return,a0		; Restore return
	jmp	(a0)			; Jump to it 



**     COMMAND:	C LEFT
**  	SYNTAX:	x=C LEFT(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is in the left position


cleft:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get port/stick number
	move.b	d3,d1			; port/stick number

	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu	#4,d1			; Multiply port to find correct
					; test bit
	add	#2,d1			; Adjust bit for left
		
	btst	d1,d0			; Test bit d1 of d0
	beq	.yes			; If bit is 0 then stick is left
	
.no	move.w	#0,d3			; Send d3 as false
	bra	.exit
	
.yes	move.l	#-1,d3			; Send d3 as true
.exit	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)




**     COMMAND:	C RIGHT
**  	SYNTAX:	x=C RIGHT(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is in the right position


cright:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get port/stick number
	move.b	d3,d1			; port/stick number

	move.b	#15,$ff8800		; Select PSG 15 - port B I/O
	move.b	$ff8800,d0		; Read port into d0

	mulu	#4,d1			; Multiply port to find correct
					; test bit
	add	#3,d1			; Adjust bit for right
		
	btst	d1,d0			; Test bit d1 of d0
	beq	.yes			; If bit is 0 then stick is right
	
.no	move.w	#0,d3			; Send d3 as false
	bra	.exit
	
.yes	move.l	#-1,d3			; Send d3 as true
.exit	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)





**     COMMAND:	C FIRE
**  	SYNTAX:	x=C FIRE(n)
**
** DESCRIPTION:	Return if the joystick n, on the CENTRONICS/PRINTER
**		port is having fire pressed


cfire:	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 parameter?
	bne	syntax			; No, syntax error
	
	bsr	getint			; Get port/stick number
	move.b	d3,d1			; port/stick number
	
	cmp.b	#1,d1			; Stick 1
	beq	.stick1
	
.stick0	move.b	#14,$ff8800		; Select PSG 14 - port A I/O
	move.b	$ff8800,d0		; Read port into d0

	btst	#5,d0			; Fire?
	beq	.yes			; Yes 
	bra	.no			; No

.stick1	move.b	$fffa01,d0		; Read MFP GP I/O

	btst	#0,d0			; Fire?
	beq	.yes			; Yes 


.no	move.l	#0,d3			; Send d3 as false
	bra	.exit
	
.yes	move.l	#-1,d3			; Send d3 as true
.exit	move.w	#0,d2			; Expect integer
	move.l	return,a0		; Load return
	jmp	(a0)
	
	
	
**     COMMAND:	AUXSTAT
**  	SYNTAX:	x=AUXSTAT
**
** DESCRIPTION:	Return if any data wait in AUX buffer

auxstat:
	move.l	(a7)+,return		; Save return
	move.w	#1,-(sp)		; Bconstat
	move.w	#1,-(sp)
	trap	#13
	lea	4(sp),sp
	move.l	d0,d3
	move.w	#0,d2			; Tell STOS to expect a number
	move.l	return,a0		; Load return
	jmp	(a0)


**** STOS SUPPORT ROUTINES ****

** Convert a STOS string to a GEM/TOS string.. adds null pointer
** to the end of the string

conv2tos: 
	movem.l	a1-a2,-(a7)		; Save registers
	move.l	d3,a1
	move.w	(a1)+,d2		; Get length of string
	move.w	d2,d1			; Save in d1
	move.l	d3,a2
strl1:	move.b	(a1)+,(a2)+		; Create space for chr$(0)
	dbra	d2,strl1		; Loop through string
	move.w	#0,(a2)+		; Copy 0 to end
	movem.l	(a7)+,a1-a2		; Restore registers
	rts


** Get a string argument

getstring:

	move.l	(a7)+,a0		; Save return
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is the argument a string?
	bpl	illegal			; No!
	jmp	(a0)			; Return from routine


** Get an integer argument
	
getint:

	move.l	(a7)+,a0		; Save return
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is it an integer?
	bne	typemis			; No, type mismatch
	jmp	(a0)			; Return


* Errors

notdone:

	moveq	#0,d0			; Error 0 (Not done)
	bra.s	error

syntax:

	moveq	#12,d0			; Error 12 (Syntax error)
	bra.s	error

typemis:

	moveq	#19,d0			; Error 19 (Type Mismatch)
	bra.s	error

illegal:

	moveq	#13,d0			; Error 13 (Illegal function call)
	
error:

	move.l	system(pc),a0
	move.l	$14(a0),a0
	jmp	(a0)

exit	equ	*

