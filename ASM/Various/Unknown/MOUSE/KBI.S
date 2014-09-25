**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**

**	Key-Board Interrupt ( This Interrupt does NOT surport MIDI! )

**	This file contains EVERY thing you need for keyboard control
**	At the start of your program flush the keyboard buffer and flush it
**	again at the end of your program. If you don't you will probibly
**	find that you keep geting bus errors and halt states when you exit
**	the program.
**	Note: Even if your machine will take abuse from the keyboard other
**	ST's, especially older one's will certinaly crash.

**	As stated above the keyboard interrupt in this file has no surport
**	for MIDI, Any attempt by an external source to send MIDI data will
**	cause a bus error, and then a halt state. You have been warned....

**	Right a quik word about how the keyboard returns data, this is
**	important info, unless you like trying to guess it!

**	When in mouse mode:

**	first data byte is the mouse packet header, the bottom two bits of
**	this are the mouse buttons. 0=not pressed 1=pressed
**	bit 1 is left     bit 0 is right

**	the next data byte is the mouse x coordinate, this is a signed byte
**	make sure you add this value to the mouse coordinates in the
**	interrupt itself or the mouse crawls along!

**	the next data byte is the mouse y coordinate, and follows the same
**	rules as the x coordinate.

**	When in joystick mode:

**	first databyte is the joystick packet header this is only ever the
**	value $FD. no bits of it are important ( i think! ).

**	next data byte is the data for joystick 0 ( the one in the mouse-
**	port ). It has the following bit arrangement:-

**	bit	7  6  5  4  3  2  1  0
**		f           r  l  d  u

**	where	f=fire  r=right  l=left  d=down  u=up
**		0=not pressed    1=pressed

**	next data byte is the data for joystick 1 ( your normal one ! )
**	this is same as above.

**	NOTE:	the two joysticks are handling in the SAME packet and not
**		seperate ones, it took me 3 hours to work this out!
**		but it wasn't my fault, 'cause someone told me they were
**		returned in seperate packets. Lucky for me i'm good at
**		guess work or i'd still be trying to get it to work!

**	And finally:
**
**	this routine is set up to put data from port 0
**	( the mouse/joystick ) one into the secound joystick.
**	this is because most people leave a joystick in one port and
**	the mouse in the other.
**	don't piss people of by making them un-plug the mouse!!

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**

start	move.l	sp,oldusp
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,oldssp

	bsr	save
	bsr	set

	bsr	flush
	move.b	#8,d0
	bsr	setkeyboard

	bsr	init

	bsr	restoresys

	move.b	#8,d0
	bsr	setkeyboard

	move.l	oldssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	oldusp,sp

	clr.w	-(sp)
	trap	#1

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
init
	move.l	phy,a0
	move.l	#(20*220)-1,d0

.loop	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d0,.loop

	move	mousex,d0
	move	mousey,d1
	move	d0,oldx
	move	d1,oldy
	bsr	savescreen

	move	#1,drawmse
	move	#1,mouseon

	bsr	loop
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
loop	bsr	waitvbi

	tst.b	keytab+$39
	beq	loop

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**	subroutines
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
save	move.l	$70.w,oldvbi
	move.l	$118.w,oldkbi

	move.b	$FFFFFA17.w,vecmode		store vector mode

	move.l	$FFFF8200.w,oldscr
	move.b	$FFFF8260.w,oldrez+1

	move	#$8240,a0
	lea	oldpal,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	rts

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
restoresys
	bsr	waitvbi

	move.w	#$2700,sr

	move	#$8209,a0
	moveq	#0,d0

	move.b	(a0),d0
.sync	cmp.b	(a0),d0
	beq.s	.sync
	move.b	(a0),d0
	neg.b	d0
	rol.b	d0,d0

	move.b	oldrez+1,$FFFF8260.w

	lea	oldpal,a0
	move	#$8240,a1

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	oldscr,$FFFF8200.w

	move.l	oldvbi,$70.w
	move.l	oldkbi,$118.w

	move.b	vecmode,$FFFFFA17.w		restore vector mode

	bsr	flush

	move.w	#$2300,sr
	rts

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
set	move	#37,-(sp)
	trap	#14
	addq	#2,sp

	move	#$2700,sr

	move	#$8209,a0
	moveq	#0,d0

	move.b	(a0),d0
.sync	cmp.b	(a0),d0
	beq.s	.sync
	move.b	(a0),d0
	neg.b	d0
	rol.b	d0,d0

	clr.b	$FFFF8260.w

	move.l	#screen,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,phy

	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w

	lea	pal,a0
	move	#$8240,a1

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	#vbi,$70.w
	move.l	#kbi,$118.w

	and.b	#$F7,$FFFFFA17.w	make sure in AEI mode
	move	#$2300,sr
	rts

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
waitvbi	move	#-1,vflag
.wvbi	tst	vflag
	bmi.s	.wvbi
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
flush	lea	$FFFFFC00.w,a0
.flush	move.b	2(a0),d0
	btst	#0,(a0)
	bne.s	.flush
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
setkeyboard
.wait	btst	#1,$fffffc00.w
	beq	.wait
	move.b	d0,$FFFFFC02.w
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  The Vbi

vbi	movem.l	d0-a6,-(sp)
	lea	pal,a0
	move	#$8240,a1

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr	vflag

domouse	tst.w	mouseon
	beq	.nodrawmouse

	tst	drawmse
	beq	.nodrawmouse

	bsr	deleteoldmouse

	move	mousex,d0
	move	mousey,d1
	move	d0,oldx
	move	d1,oldy

	bsr	savescreen

	move	oldx,d0
	move	oldy,d1

	moveq	#1,d2
	lea	mouse,a0
	move.l	phy,a1
	bsr	go_16

	clr.w	drawmse

.nodrawmouse

	movem.l	(sp)+,d0-a6
	rte

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
deleteoldmouse

	move.l	phy,a0

	move.w	oldx,d0
	andi.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0

	moveq	#0,d0
	move.w	oldy,d0
	move.l	d0,d1
	lsl.l	#7,d0
	lsl.l	#5,d1
	add.l	d0,a0
	add.l	d1,a0

	lea	restore,a1

	rept	16
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	144(a0),a0
	endr

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
savescreen

	move.l	phy,a0

	andi.w	#$FFF0,d0
	lsr.w	#1,d0
	add.w	d0,a0

	andi.l	#$FFFF,d1
	move.l	d1,d0
	lsl.l	#7,d0
	lsl.l	#5,d1
	add.l	d0,a0
	add.l	d1,a0

	lea	restore,a1

	rept	16
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	144(a0),a0
	endr

	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
** 16*16 sprites with rotation and clipping
** d0=x
** d1=y
** d2=sprite number
** a0=sprite address  (you set it.)
** a1=logic screen    (you set it.)

go_16
	cmpi.w	#-15,d1			check to see if sprite is visable
	blt	no_draw
	cmpi.w	#199,d1
	bgt	no_draw
	cmpi.w	#-15,d0
	blt	no_draw
	cmpi.w	#319,d0
	bgt	no_draw

	movem.l	d0-7/a0-6,-(sp)

	move.w	d2,d3
	mulu	#160,d3
	add.w	d3,a0			offset sprite data

	cmpi.w	#0,d1			check to see if sprite at top of 
					;screen
	beq	no_offset		goto this routine only if at bottom
	blt	y_clipp_0		this routine clipps the top off
	cmpi.w	#184,d1
	bgt	y_clipp_200		clipp of the bottom of sprite
	mulu.w	#160,d1
	add.w	d1,a1			offset screen pointer
no_offset
	moveq.w	#$f,d6
	bra	do_x

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
y_clipp_0
	neg.w	d1		make number positive
	move.w	d1,d2
	moveq.w	#$10,d3		normaly draw 16 lines
	sub.w	d1,d3		but we can only see so many
	subq.w	#1,d3		-1 for the dbra

	move.w	d3,d6		set lines to draw

	mulu	#10,d1
	add.w	d1,a0		offset spr_data pointer
				;(so we draw the bottom bit)
	bra	do_x
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
y_clipp_200
	move.w	d1,d3		d1=y coordinate
	move.w	#200,d4
	sub.w	d3,d4		now we know how many lines to draw
	subq	#1,d4		'cause of dbf
	move.w	d4,d6		set the lines to draw reg
	mulu.w	#160,d1		and offset screen pointer
	add.w	d1,a1
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
do_x	cmpi.w	#0,d0		if x is lower than 0 it needs clipping
	blt	x_neg
	cmpi.w	#304,d0		if x is greater than 304 it needs clipping
	bhi	x_right

	move.w	d0,d3
	andi.w	#$FFF0,d3	clr bottom nibble
	cmp.w	d0,d3		if the numbers are equal no need to rol.l
	beq	x_on_boundry

	move.w	d0,d4
	sub.w	d3,d4
	cmpi.w	#8,d4		if higher 8 we rotate the sprite to the
				; instead of to the right
	bhi	rot_left
	move.w	d4,d5
	lsr.w	#1,d3		divide by 2
	add.w	d3,a1		offset the screen
	move.l	a1,a2
	add.l	#8,a2		a2 points the next 16 pixel boundary
	bsr	dr_16_r
	movem.l	(sp)+,d0-7/a0-6
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
x_on_boundry
	lsr.w	#1,d0		divide by 2
	add.w	d0,a1		offset screen

b_draw	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3	spr_data
	move.w	(a0)+,d4	spr_mask
	and.w	d4,(a1)		slap sprite on a boundary
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)+
	lea	152(a1),a1
	dbra	d6,b_draw	the loop!!!
	movem.l	(sp)+,d0-7/a0-6
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
** d3 = sprite x coordinate with bottom nibble cut off

rot_left

	add.w	#16,d3		add 16 'cause we're coming from left to
				;right
	move.w	d3,d4
	sub.w	d0,d3		find out how far to rotate
	move.w	d3,d5		how far to rotae
	lsr	#1,d4		turns x coordinate into screen offset
	add.w	d4,a1
	move.l	a1,a2		the other pointer used by the routine
	sub.l	#8,a2
	bsr	dr_16
	movem.l	(sp)+,d0-7/a0-6
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
** d0=x coordinate (unaltered)
** d1 was the y coordinate but thats been taken care of
** d2 was the sprite number but we've done that
** d6=number of lines to draw (returned by the y coord handler)
** a0=sprite data pointer
** a1=screen pointer (y offseted)
x_neg
	neg.w	d0	make number positive(this is how far to rotate)
	move.w	d0,d5

** and now to rotate the dam thing!

x_clipp_it_off_left
	clr.l	d0		clear regs
	clr.l	d1
	clr.l	d2
	clr.l	d3
	moveq.l	#-1,d4
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3	sprite data
	move.w	(a0)+,d4	sprite mask
	rol.l	d5,d0
	rol.l	d5,d1
	rol.l	d5,d2
	rol.l	d5,d3		shift sprite data
	rol.l	d5,d4		shift mask data
	and.w	d4,(a1)		mask it
	or.w	d0,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d1,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d2,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d3,(a1)+	draw it
	lea	152(a1),a1
	dbra	d6,x_clipp_it_off_left
	movem.l	(sp)+,d0-7/a0-6
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
** d0=x coordinate (unaltered)
** d1 was the y coordinate but thats been taken care of
** d2 was the sprite number but we've done that
** d6=number of lines to draw (returned by the y coord handler)
** a0=sprite data pointer
** a1=sprite mask data
** a1=screen pointer (y offseted)
x_right
	move.w	d0,d1
	and.w	#$fff0,d1
	sub.w	d1,d0		find out how far to rotate
	move.w	d0,d5
	add.w	#160-8,a1	offset screen (draw at right side)

** and now to rotate the dam thing!

x_clipp_it_off_right
	clr.l	d0		clear regs
	clr.l	d1
	clr.l	d2
	clr.l	d3
	moveq.l	#-1,d4
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3	sprite data
	move.w	(a0)+,d4	sprite mask
	ror.l	d5,d0
	ror.l	d5,d1
	ror.l	d5,d2
	ror.l	d5,d3		shift sprite data
	ror.l	d5,d4		shift mask data
	and.w	d4,(a1)		mask it
	or.w	d0,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d1,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d2,(a1)+	draw it
	and.w	d4,(a1)		mask it
	or.w	d3,(a1)+	draw it
	lea	152(a1),a1
	dbra	d6,x_clipp_it_off_right
	movem.l	(sp)+,d0-7/a0-6
	rts

**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
no_draw	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
* a0=spr_data  a1=spr_mask  a1=screen  a2=screen-8
* d5=how far to rotate  d6=lines to draw
* this code rotates the sprites to the left!!!

dr_16	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		clear the regs for use
	move.l	#$ffffffff,d4	if you fuck around with this instruction
;				the sprite cuts holes in the screen
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3	sprite data
	move.w	(a0)+,d4	mask data
	move.b	#0,ccr		set the codion codes to 0
	rol.l	d5,d0
	rol.l	d5,d1
	rol.l	d5,d2
	rol.l	d5,d3		rotate data
	rol.l	d5,d4		rotate mask
	and.w	d4,(a1)
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)+	here we should have drawn 1/2 the sprite
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4		swap the regs
	move.b	#0,ccr		clear the condion code flags
	and.w	d4,(a2)
	or.w	d0,(a2)+
	and.w	d4,(a2)
	or.w	d1,(a2)+
	and.w	d4,(a2)
	or.w	d2,(a2)+
	and.w	d4,(a2)
	or.w	d3,(a2)+	here we should have drawn the other 1/2
	lea	152(a1),a1
	lea	152(a2),a2
	dbra	d6,dr_16
	rts
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
* a0=spr_data  a1=spr_mask  a1=screen  a2=screen+8
* d5=how far to rotate  d6=lines to draw
* this code rotates the sprites to the right!!!

dr_16_r	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3		clear the regs for use
	move.l	#$ffffffff,d4
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3	sprite data
	move.w	(a0)+,d4	mask data
	move.b	#0,ccr		set the codion codes to 0
	ror.l	d5,d0
	ror.l	d5,d1
	ror.l	d5,d2
	ror.l	d5,d3		rotate data
	ror.l	d5,d4		rotate mask
	and.w	d4,(a1)
	or.w	d0,(a1)+
	and.w	d4,(a1)
	or.w	d1,(a1)+
	and.w	d4,(a1)
	or.w	d2,(a1)+
	and.w	d4,(a1)
	or.w	d3,(a1)+	here we should have drawn 1/2 the sprite
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4		swap the regs
	move.b	#0,ccr		clear the condion code flags
	and.w	d4,(a2)
	or.w	d0,(a2)+
	and.w	d4,(a2)
	or.w	d1,(a2)+
	and.w	d4,(a2)
	or.w	d2,(a2)+
	and.w	d4,(a2)
	or.w	d3,(a2)+	here we should have drawn the other 1/2
	lea	152(a1),a1
	lea	152(a2),a2
	dbra	d6,dr_16_r
	rts
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  Kbi
kbi	move	#$2400,sr
	movem.l	d0-1,-(sp)

	move.b	$fffffc00.w,d0	get control byte
	btst	#7,d0
	beq.s	again
	btst	#0,d0		Any data?
	beq.s	again		if not return



	moveq	#0,d0
	move.b	$fffffc02.w,d0	Get byte
;				Check if the byte is a keypress 
;				or a packet header
	cmpi.b	#$fd,d0		start of Joystick Packet?
	beq.s	setjoy

	move	d0,d1
	and	#$f8,d1
	cmpi.b	#$f8,d1		start of Mouse Packet?
	beq	is_mouse

	bra.s	is_key		Must be a key then


again	movem.l	(sp)+,d0-d1
*	bclr	#6,$fffffa11.w
	rte
	
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  Keyboard Handler
is_key	move.l	a0,-(sp)
	btst	#7,d0		Key press or release?
	beq.s	kp		Key press
	lea	keytab(pc),a0
	bclr	#7,d0
	move.b	#0,(a0,d0)
	move.l	(sp)+,a0
	movem.l	(sp)+,d0-d1
*	bclr	#6,$fffffa11.w
	rte

kp	move.b	d0,scancode
	lea	keytab,a0
	move.b	#1,(a0,d0)
	move.l	(sp)+,a0
	movem.l	(sp)+,d0-d1
*	bclr	#6,$fffffa11.w
	rte

**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  Joystick Handler
setjoy	move.l	#getjoy0,$118.w
	movem.l	(sp)+,d0-d1
*	bclr	#6,$fffffa11.w
	rte

getjoy0	move	#$2400,sr
	move.b	$fffffc02.w,joy2+1
	move.l	#getjoy1,$118.w
*	bclr	#6,$fffffa11.w
	rte

getjoy1	move	#$2400,sr
	move.b	$fffffc02.w,joy1+1
	move.l	#kbi,$118.w
*	bclr	#6,$fffffa11.w
	rte
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
**  Mouse Handler

is_mouse
	and	#3,d0			mask off buttons
	move	d0,mouseb		store buttons

	move.l	#waitx,$118.w		get xcoordinate next 'rupt

	movem.l	(sp)+,d0-d1		pop regs
*	bclr	#6,$fffffa11.w		acknowledge 'rupt
	rte

waitx	move	#$2400,sr
	move.b	$fffffc02.w,moffx+1	store xcoordinate
	move.l	#waity,$118.w		get ycoordinate next 'rupt
*	bclr	#6,$fffffa11.w		acknowledge 'rupt
	rte

waity	move	#$2400,sr
	movem.l	d0-d1,-(sp)		push regs
	move.b	$fffffc02.w,moffy+1	store y offset

	move	mousex,d0
	move	moffx,d1
	ext	d1
	add	d1,d0

	cmp	mouseXmin,d0
	bge.s	mouse_max
	move	mouseXmin,d0
mouse_max
	cmp	mouseXmax,d0
	ble.s	setmouse_x
	move	mouseXmax,d0

setmouse_x
	move	d0,mousex

	move	mousey,d0
	move	moffy,d1
	ext	d1
	add	d1,d0

	cmp	mouseYmin,d0
	bge	mousey_max
	move	mouseYmin,d0
mousey_max
	cmp	mouseYmax,d0
	ble.s	setmouse_y
	move	mouseYmax,d0

setmouse_y
	move	d0,mousey
	move	#1,drawmse

	move.l	#kbi,$118.w

	movem.l	(sp)+,d0-d1
*	bclr	#6,$fffffa11.w
	rte

mflag		dc.w	0
mdat		dc.w	0

joyflag		dc.w	0

mouseXmin	dc.w	0
mouseYmin	dc.w	0
mouseXmax	dc.w	319
mouseYmax	dc.w	199

moffx		dc.w	0
moffy		dc.w	0

mousex		dc.w	151
mousey		dc.w	91
mouseb		dc.w	0
drawmse		dc.w	0
mouseon		dc.w	0

scancode	ds.w	1
keytab		ds.b	128
joy1		ds.w	1
joy2		ds.w	1

oldx		dc.w	0
oldy		dc.w	0


**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	section data
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
pal		dc.w	$000,$111,$222,$333,$444,$555,$666,$777
		dc.w	$500,$700,$710,$730,$750,$770,$227,$007

mouse		incbin	d:\mouse.spr


**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
	section bss
**--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--++--**
oldusp	ds.l	1
oldssp	ds.l	1

oldrez	ds.w	1
oldpal	ds.w	16
oldscr	ds.l	1

oldkbi	ds.l	1
oldvbi	ds.l	1

vecmode	ds.w	1

ojoy1	ds.w	1
ojoy2	ds.w	1

vflag	ds.w	1

phy	ds.l	1
restore	ds.b	16*16
screen	ds.b	(274*160)+256



