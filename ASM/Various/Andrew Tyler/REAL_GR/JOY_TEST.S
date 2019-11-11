* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 joy_test.s                           *
* A routine to test the ikbd joystick function                *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* The joystick is interrogated and our own packet handler used to
* grab the data packet containing the FIRE bit (7) and the position
* bits (0-2) which is saved in the variable joy_data.

	opt	d+
	bra main
	include	systm_03.s	the important subroutines
	even	
main		
* Set up joystick for standard reporting. 
	bsr	init_joy	set up our packet handler
	bsr	joy_off		end automatic reporting
	bsr	mse_off		turn off the mouse		
main1	
	clr.w	joy_data	
	bsr	rd_joy		read joystick 
	move.w	joy_data,d0	here's the result
	move	d0,d1		save it
	andi.w	#$f0,d0		fire pressed  ?
	bne	fire_press 	yes
	andi.w	#$f,d1		what direction is the stick?
	beq	joy_out		no direction
	cmp.w	#1,d1		up?
	beq	up		yes
	cmp.w	#2,d1		down?
	beq	down		yes
	cmp.w	#4,d1		left?
	beq	left		yes
	cmp.w	#8,d1		right?
	beq	right		yes
	bra	diagonal	only possibility left
* Use the VT52 subroutines for messages 
up	pea	up_text		pointer to text
	move.w	#9,-(sp)	VT52 emulator
	trap	#1		GEM call
	addq.l	#6,sp		tidy
	bra	joy_out
down	pea	down_text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	joy_out
left	pea	left_text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	joy_out
right	pea	right_text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	joy_out
diagonal:
	pea	diag_text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	joy_out
fire_press:
	pea	fire
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
joy_out	clr.w	joy_data
	bra	main1

*	SECTION BSS

gem_joy		ds.l	1
joy_data	ds.w	1
gem_mse		ds.l	1
mse_click	ds.w	1
mouse_dx	ds.w	1
mouse_dy	ds.w	1
*	SECTION DATA
* Here are the messages to be printed. The number 27 is the ESCAPE 
* code. In low res.Text can be positioned at any row (0 to 24)
* or column (0 to 39) but the number 32 must be added. Text must end in 0.
up_text	dc.b	27,"E"		clear screen
	dc.b	27,"Y",33,50	type at row 1 (+32) and column 18 (+32)
	dc.b	"up"		the word "up"
	dc.b	0		end of text
down_text:
	dc.b	27,"E"
	dc.b	27,"Y",56,50
	dc.b	"down"
	dc.b	0
left_text:
	dc.b	27,"E"
	dc.b	27,"Y",44,32
	dc.b	"left"
	dc.b	0
right_text:
	dc.b	27,"E"
	dc.b	27,"Y",44,62
	dc.b	"right"
	dc.b	0
fire	dc.b	27,"E"
	dc.b	27,"Y",44,50
	dc.b	"FIRE"
	dc.b	0
diag_text:
	dc.b	27,"E"
	dc.b	27,"Y",44,50
	dc.b	"diagonal"
	dc.b	0
	END

