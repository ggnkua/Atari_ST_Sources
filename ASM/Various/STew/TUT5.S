
;*************************************************************************

;TUTORIAL HELP FILE FOR STAMPEDE SEPTEMBER 1990.
;Complied by Stew.

;This requires a full working version of Devpac or compatible to run
;Set tab setting to 8 for best editing

;first lets assign some variables using the EQUate function.

lowres	equ	0
medres	equ	1
hires	equ	2

;now the code begins. the entire program has been split up
;into routines which are called using BSR (branch to subroutine)
;and the routine is finished using RTS (return from subroutine)

codego	bsr	supermode	;allow access to the hardware
	dc.w	$a00a		;turn off mouse
	bsr	setpalette	;program palette set here
	bsr	setscreen	;set the screen mode
	bsr	getscreenbase	;where we will place data
	bsr	exceptions	;this months demonstration
	bsr	message		;display a text message on screen
	bsr	waitkey		;wait for user response
	bsr	oldvectors	;restore exceptions vectors
	bsr	restorepalette	;restore gem palette
	bsr	usermode	;back to user mode
	clr.w	-(sp)		;function 0-terminate program
	trap	#1		;now go back to gem

;before any of the st's hardware registers can be used, we must
;place the 68000 into supervisor mode.
;the super mode instruction effects the status register bit #13.
;note: the trap #1 call with paramater $0020 actually toggles
;  the user mode/super mode status. so calling the routine
;  twice will restore the processor to its previous state.

supermode
	clr.l	-(sp)		;push parameters for supermode
	move.w	#$0020,-(sp)	;onto the stack
	trap	#1		;call the gemdos routine
	addq.w	#6,sp		;correct the stack
	move.l	d0,savesp	;save the old stack value
	rts			;exit the routine

;once the program has been executed, we place the 68000 back
;into usermode ready for the return to gem. this actually
;clears the supervisor mode bit in the status register.

usermode
	move.l	savesp,-(sp)	;push on old stack value
	move.w	#$0020,-(sp)	;function $0020-user mode
	trap	#1		;put 68000 into user mode
	addq.w	#6,sp		;correct stack after the 2 pushes
	rts

;now that the main routines have been executed we tell the
;program to halt and wait for the user to press a key. this
;is done via the trap #1 call.

waitkey
	move.w	#$0001,-(sp)	;function 1-conin
	trap	#1		;wait for a key
	addq.w	#2,sp
	rts

;printing messages using gem is easy, simply pass the
;address of the string you wish to print onto the stack.
;the call the trap #1 routine using funtction 9-print line.
;all the text displayed is shown in color 15 in low resolution mode
;or colour 3 in medium resolution.

message
	move.l	#text,-(sp)	;place address onto stack
	move.w	#$0009,-(sp)	;function 9-print line
	trap	#1		;print the text
	addq.w	#6,sp
	rts

;now we set the screen mode using function 5-trap 14. this also
;allows us to set where the st fetches the data for the screen.

setscreen
	move.w	#lowres,-(sp)	;place mode required on stack
	move.l	#-1,-(sp)	;dont effect screen address
	move.l	#-1,-(sp)	;dont effect screen address
	move.w	#$0005,-(sp)	;function 5-setscreen
	trap	#14		;set the screen resolution
	add.w	#12,sp
	rts

;the following two routines simply set the st's screen
;colours using trap #14, function 6. the colours are
;actually placed into the hardware locations $ffff8240.

setpalette
	move.l	#mypal,-(sp)	;address of palette in memory
	move.w	#$0006,-(sp)	;function 6-setpalette
	trap	#14		;set the palette
	addq.w	#6,sp
	rts

restorepalette
	move.l	#gempal,-(sp)	;address of palette in memory
	move.w	#$0006,-(sp)	;function 6-setpalette
	trap	#14		;set the palette
	addq.w	#6,sp
	rts

;for us to draw anything on the screen we must first located the
;top of the screen in memory. this is done using function 2-
;trap 14. the top of the screen is returned in a long word in
;data register d0. this will vary in different machines as the
;520 st's are located at $78000 and the 1040 st's are at $f8000.

getscreenbase
	move.w	#$0002,-(sp)	;function 2-physbase
	trap	#14		;calculate the address
	addq.w	#2,sp		;correct the stack
	move.l	d0,screenbase	;save the base address for later
	rts

;this is the main part of our demonstration.  the first instruction
;poke into the trap #15 vector at $bc.  when we hit the trap #15
;instuction, the PC and SR are saved on the stack.  the control
;is passed to 'CLEARSCREEN' the address at $bc.  This simply clears
;the screen.
;Next, we save the old vertical blank routine into a variable
;called 'oldaddress'.  this is required for when we wish to
;exit back to desktop.  now we simply poke the address of the
;vertical blank routine into $70 using 'move.l #'.  the interrupt
;routine will now be executed every time the vertical blank
;occurs.

exceptions
	move.l	#clearscreen,$bc	;trap #15 vector
	trap	#15			;clear the screen
	move.l	$70,oldaddress		;save old vbl address
	move.l	#vbl,$70.w		;new address
	rts				;control to main routine

;this routine simple sets back the old vertical blank address
;just before we exit the program.  if this is not restored the
;operating system will not have it's vertical blank routine
;going and will probably crash!

oldvectors
	move.l	oldaddress,$70		;restore VBL address
	rts

;this routine simply clears the screen using a dbra-loop.  the
;routine is actually called from the TRAP #15 command and therefore
;exits with the RTE which pulls the PC and SR which were saved when
;the TRAP #15 was first executed.

clearscreen
	move.l	screenbase,a0		;start of screen
	move.w	#32000-1,d7		;loop for 32000 bytes
fill	move.b	#$aa,(a0)+		;fill wil %10101010
	dbra	d7,fill			;all the screen
	rte				;finish exception

;now comes the vertical blank routine.  this, as explained before,
;is executed every time a VBL occurs (once every time the TV
;redraws the picture).  the routine firstly saves the resgisters
;on the stack as we are interrupting the current program.  modifiying
;the registers without saving them will probably cause a crash.
;the program simply displays bars on the screen and exits
;again with an RTE.

vbl	movem.l	d0-d7/a0-a6,-(sp)	;save registes on stack
	move.w	#5000,d6		;wait till visible
top	dbra	d6,top
	move.w	#$0777,d7		;first color=white
bars	move.w	d7,$ffff8240		;set pallete color
	move.w	#500,d6			;delay for band
delay	dbra	d6,delay
	sub.w	#$111,d7		;count colors $777,$666-$000
	bcc.s	bars			;brach to 'bars' if not done
	movem.l	(sp)+,d0-d7/a0-a6	;restore registers
	rte				;quit exception

**************************************************************************

;reserved space for variables

savesp	dc.l	0	;storage for stack in memory
screenbase
	dc.l	0	;where the top of the screen is located
oldaddress
	dc.l	0

mypal	dc.w	$007,$000,$000,$777,$000,$000,$000,$000
	dc.w	$707,$770,$000,$000,$000,$000,$000,$777

gempal	dc.w	$001,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777

text	dc.b	13,10
	dc.b	"STAMPEDE ST TUTORIAL FILE SEPTEMBER 1990"
	dc.b	13,10
	dc.b	13,10
	dc.b	"               EXCEPTIONS               "
	dc.b	0
	even
