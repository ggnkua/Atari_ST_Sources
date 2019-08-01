
;*************************************************************************

;PROGRAMMING TUTORIAL FILE FOR STAMPEDE NOVEMBER 1990.
;Complied by Stew.

;this requires a full working version of Devpac or compatible to run
;set tab setting to 8 for best editing

;first lets assign some variables using the EQUate function.

lowres	equ	0
medres	equ	1
hires	equ	2

screen1	equ	$70000
screen2	equ	$78000

;now the code begins. the entire program has been split up
;into routines which are called using BSR (branch to subroutine)
;and the routine is finished using RTS (return from subroutine)

codego	bsr	supermode	;allow access to the hardware
	dc.w	$a00a		;turn off mouse
	bsr	setpalette	;program palette set here
	bsr	setscreen	;set the screen mode
	bsr	waitvbl

mainloop
	bsr	flip		;adjust screen pointers
	bsr	waitvbl		;wait for vertical blank
	move.w	#$0700,$ffff8240
	bsr	clearscreen	;erase screen data
	move.w	#$0777,$ffff8240
	bsr	sprite
	clr.w	$ffff8240

	bsr	readkey		;till done
	cmp.b	#" ",d0		;space pressed ?
	bne.s	mainloop	;no, loop

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

readkey
	move.w	#$00ff,-(sp)
	move.w	#$0006,-(sp)	;function 6-readkey
	trap	#1		;wait for a key
	addq.w	#4,sp		;return key in d0
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

;this routine simply waits for the vertical blank to occur. this
;simply makes the graphic updates smoother.  try removing this to
;see what happens!

waitvbl
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts

;this routine simply sets up the new screen addresses and then flips
;the screen pointer addresses.

flip	move.l	visscreen,d0
	move.l	currentscreen,visscreen
	move.l	d0,currentscreen

	move.w	#-1,-(sp)
	move.l	visscreen,-(sp)
	move.l	currentscreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts

;this routine is very simple. it simply clears the screen using
;a loop. note: 200 lines are cleared of 160 bytes each.

clearscreen
	move.l	currentscreen,a0
	moveq	#0,d0
	move.w	#200-1,d7
sf	rept	40
	move.l	d0,(a0)+
	endr
	dbra	d7,sf
	rts

;display sprite at d0,d1 (x,y)

sprite
	addq.w	#1,xpos
	addq.w	#1,ypos
	and.w	#$007f,xpos
	and.w	#$007f,ypos

	move.w	xpos,d0
	move.w	ypos,d1
	mulu.w	#160,d1
	move.l	currentscreen,a1
	add.w	d1,a1
	move.w	d0,d6
	lsr.w	#1,d0
	and.w	#$fff8,d0
	add.w	d0,a1
	and.w	#$000f,d6
	moveq	#16-1,d7
	lea	spritedata,a0

;a0=data  a1=screen  d6=shifts  d7=loop

drawit	moveq	#0,d0
	move.w	(a0)+,d0
	ror.l	d6,d0
	or.w	d0,(a1)
	swap	d0
	or.w	d0,8(a1)
	lea	160(a1),a1
	dbra	d7,drawit
	rts

**************************************************************************

xpos	dc.w	0
ypos	dc.w	0

;graphics data

spritedata
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

;reserved space for variables

visscreen	
	dc.l	screen1

currentscreen
	dc.l	screen2

savesp	dc.l	0

mypal	dc.w	$007,$777,$000,$777,$000,$000,$000,$000
	dc.w	$707,$770,$000,$000,$000,$000,$000,$777

gempal	dc.w	$001,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
