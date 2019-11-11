* STE Controller Port Tester
* Copyright c.1991 Adam Greenwood
* Feel free to change and use this code
* This program displays the current state of all the 
* controller port registers om the screen
* Effects such as inverse video are achieved using VT52 emulation
* ie by writing escape codes to the screen.
* Written with/for Devpac 2

* Constants

* Controller Port Registers

joy_fire	equ	$ff9200		Fire Buttons
joy_udlr	equ	$ff9202		Directions
pad0_x	equ	$ff9210		Paddle 0 X
pad0_y	equ	$ff9212		Paddle 0 Y
pad1_x	equ	$ff9214		Paddle 1 X
pad1_y	equ	$ff9216		Paddle 1 Y
light_x	equ	$ff9220		Light Pen/Gun X
light_y	equ	$ff9222		Light Pen/Gun Y

* start of code

start	move.l	a7,a5
	addq	#4,a7
	move.l	4(a5),a5		get basepage
	move.l	$c(a5),d0		get legth of text segment
	add.l	$14(a5),d0	add length of data segment
	add.l	$1c(a5),d0	add length of uninit BSS
	add.l	#$100,d0		add length of basepage
	move.l	d0,-(a7)		push length to reserve
	move.l	a5,-(a7)		start address to modify
	move.w	#0,-(a7)		zero
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7

	clr.l	-(a7)		set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	lea	stk,a6		save value of old stack
	move.l	d0,(a6)

	move.l	#screen,a0	display main screen
	jsr	prnt_strn		print whole screen as string

	move.l	#reverse,a0	escape code reverse video
	jsr	prnt_strn		write escape code

.loop	move.w	#37,-(a7)		Vsync call
	trap	#1		waits for vblank to 
	addq	#2,a7		synchronise

	move.l	#set_fire,a0	escape code to set cursor
	jsr	prnt_strn		position for fire register
	move.w	joy_fire,d0	value of fire register
	jsr	nib_bin		print nibble in binary
	
	move.l	#set_d3,a0	cursor position for direction
	jsr	prnt_strn		direction
	move.w	joy_udlr,d7	direction register
	move.w	#3,d6		loop 4 times
.print	rol.w	#4,d7		get nibble
	move.b	d7,d0		
	jsr	nib_bin		print nibble in binary
	cmp.w	#0,d6		check for last
	beq.s	.dec		no | on last nibble
	move.w	#$7c,d0		| symbol
	jsr	prnt_char
.dec	dbra	d6,.print

	move.l	#set_0x,a0	position for paddle 0 X
	jsr	prnt_strn
	move.w	pad0_x,d0		value of paddle 0 X reg
	and.w	#$ff,d0		only low byte valid
	jsr	decimal		print as three digit no.

	move.l	#set_0y,a0	position for paddle 0 Y
	jsr	prnt_strn		
	move.w	pad0_y,d0		value of paddle 0 Y reg
	and.w	#$ff,d0		only low byte valid
	jsr	decimal		print as 3 digit no.

	move.l	#set_1x,a0	cursor for paddle 1 X
	jsr	prnt_strn
	move.w	pad1_x,d0		value of paddle 1 X
	and.w	#$ff,d0		low byte only
	jsr	decimal		print

	move.l	#set_1y,a0	cursor pos for pad 1 Y
	jsr	prnt_strn		
	move.w	pad1_y,d0		value of register
	and.w	#$ff,d0		low byte	
	jsr	decimal		print to screen

	move.l	#set_Lx,a0	Light Gun X position
	jsr	prnt_strn		set cursor position
	move.w	light_x,d0	value of light gun X
	and.w	#$3ff,d0		lowest 10 bits
	jsr	decimal		print as 3 digit no.

	move.l	#set_Ly,a0	Y position
	jsr	prnt_strn		set cursor
	move.w	light_y,d0	register value
	and.w	#$3ff,d0		lowest 10 bits only
	jsr	decimal		print to screen

	jsr	get_key		Check for key press
	cmp.w	#0,d0		if no press loop
	beq	.loop
	
	move.l	#normal,a0	Normal video
	jsr	prnt_strn		write escape code
	
	bra	fin

* Routine to print a four bit nibble in binary
* lowest four bits of d0 printed

nib_bin	movem.l	d0-d7/a0-a4,-(a7)
	move.b	d0,d6

	move.w	#3,d7
	rol.b	#5,d6		get bit 3 to bit 0
	
.loop	move.b	d6,d5
	and.b	#1,d5		bit 0
	move.w	#48,d0		ASCII 0
	add.b	d5,d0		add 0 or 1 to ASCII 0
	jsr	prnt_char		print
	rol.b	d6		next bit
	dbra	d7,.loop
	
	movem.l	(a7)+,d0-d7/a0-a4
	rts
	
* Routine to print a word as a three digit decimal
* number. The word must therefore be less than 999
* in: d0 = word to print

decimal	movem.l	d5-d7,-(a7)
	move.w	d0,d7

	ext.l	d7
	divu	#10,d7		divide by 10
	move.l	d7,d6		
	swap	d6		d6 = 1s
	ext.l	d7
	divu	#10,d7		divide again
	move.l	d7,d5		d7 = 100s
	swap	d5		d5 = 10s
	
	add.w	#48,d7		convert to chars
	add.w	#48,d6
	add.w	#48,d5
	move.w	d7,d0		print to screen
	jsr	prnt_char
	move.w	d5,d0
	jsr	prnt_char
	move.w	d6,d0
	jsr	prnt_char
	
	movem.l	(a7)+,d5-d7
	rts

* routine to print a null terminated string to screen
* a0 = address of string

prnt_strn	movem.l	d0-d4/a0-a4,-(a7)

	move.l	a0,-(a7)		address of string
	move.w	#9,-(a7)		print string
	trap	#1
	addq	#6,a7	
	
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* routine to print a character to the screen
* d0.w = character 
	
prnt_char	movem.l	d0-d4/a0-a4,-(a7)

	move.w	d0,-(a7)		character
	move.w	#2,-(a7)		print character
	trap	#1
	addq	#4,a7
	
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* routine to get key press
* returns value in d0.w, 0 = no key

get_key	movem.l	d1-d4/a0-a4,-(a7)

	move.w	#255,-(a7)	read character
	move.w	#6,-(a7)		c_rawio
	trap	#1
	addq	#4,a7
	
	movem.l	(a7)+,d1-d4/a0-a4
	rts

* Return to user mode and exit

fin	lea	stk,a6		get value of original stack
	move.l	(a6),-(a7)
	move.w	#32,-(a7)
	trap	#1		Return to user mode
	addq	#6,a7
	

	move.w	#0,-(a7)
	trap	#1
	addq	#2,a7


	section	BSS

stk	ds.l	1


	section	DATA
	
* The following is all one string, including carriage returns
* etc, which can be printed in one go

screen	dc.b	27,'E',27,'f',' STE Controller Port Display Program',13,10
	dc.b	' Copyright ',189,'1991 A Greenwood',13,10,13,10
	dc.b	' .---------------------------------------.',13,10
	dc.b	' |                      3120             |',13,10
	dc.b	' | $ff9200 Fire Buttons                  |',13,10
	dc.b	' |                                       |',13,10
	dc.b	' |---------------------------------------|',13,10
	dc.b	' |                   UDLR UDLR UDLR UDLR |',13,10
	dc.b	' | $ff9202 Direction                     |',13,10
	dc.b	' |                   Joy3 Joy2 Joy1 Joy0 |',13,10
	dc.b	' |---------------------------------------|',13,10
	dc.b	' | $ff9210 Paddle 0 x                    |',13,10
	dc.b	' | $ff9212 Paddle 0 y                    |',13,10
	dc.b	' |---------------------------------------|',13,10
	dc.b	' | $ff9214 Paddle 1 x                    |',13,10
	dc.b	' | $ff9216 Paddle 1 y                    |',13,10
	dc.b	' |---------------------------------------|',13,10
	dc.b	' | $ff9220 Light Pen x                   |',13,10
	dc.b	' | $ff9222 Light Pen y                   |',13,10
	dc.b	' ',39,'---------------------------------------',39,13,10,0

* The following are the escape code sequences to set 
* the cursor to the correct screen position to print
* the contents of the various registers
* The characters and numbers after the Y are coordinates, 
* but in the form that the VT52 recognises.
* To work out which character to use take coord and add
* 32. This gives ASCII value of character. eg for 3
* use character 35, ie #

set_fire	dc.b	27,'Y%8',0	
set_d3	dc.b	27,'Y)5',0	
set_0x	dc.b	27,'Y,6',0
set_0y	dc.b	27,'Y-6',0
set_1x	dc.b	27,'Y/6',0
set_1y	dc.b	27,'Y06',0
set_Lx	dc.b	27,'Y27',0
set_Ly	dc.b	27,'Y37',0

* Escape code sequences for reverse and normal video

reverse	dc.b	27,'p',0
normal	dc.b	27,'q',0
	
	end