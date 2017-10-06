*** IKBD Handler **********************************************************

	SECTION TEXT


* The IKBD handler is where we gather interesting mouse button information
* and jam it into the md_buffer ready for the VBI timer handler to
* interpret.

IKBD_handler
	move.l	a6,-(a7)

	lea	variables(pc),a6


* If the buffer is full, just return (there's nothing we can do about
* this except get a bigger buffer - but don't worry, I can't see any
* human being making 64 mouse clicks in 1/50th of a second - that's
* 0.3125 milliseconds per click... :)

	cmpi.w	#MD_BUFFER_SIZE,inbuf(a6)
	beq	.return


* Make sure we only interpret relative mouse data (if someone tells the
* IKBD to be strange and report mouse data as absolute, we won't break)

	move.b	(a0),d0
	andi.b	#$f8,d0
	cmpi.b	#$f8,d0
	bne	.return


** Handle the buttons

* Convert IKBD button state into AES button state

	moveq	#0,d0		Make the buttons AES format
	move.b	(a0),d0
	andi.b	#%11,d0
	lsr.b	#1,d0
	bcc	.done_convert
	bset	#1,d0		
.done_convert

* Are buttons different to what they were last time? If not, don't write
* another button packet (this happens all the time since we also get mouse
* movement packets here)

	cmp.w	old_buttons(a6),d0
	beq	.done_buttons

	move.w	d0,old_buttons(a6)


* Write the button packet to the moose device buffer

	bsr	IKBD_but_write
.done_buttons


** Handle the mouse movement

* Well, actually we don't... but we could if we wanted to handle mouse
* rectangles here


.return	move.l	old_IKBD_handler(a6),d0
	move.l	(a7)+,a6
	move.l	d0,-(a7)
	rts


** Write a Packet of Button Data To MD_BUFFER ********************** A6 ***

* This writes a button event packet to the moose device. The
* moose x and y position as added in here.

*  in: d0.w = button state for this packet

* Packet data format is as per the BUT_PAK structure
* 4.w=x at click, 6.w=y at click


IKBD_but_write
	movem.l	a0-a1,-(a7)

	lea	moose_packet(pc),a0

	move.l	linea(a6),a1
	
	move.w	#(BUT_PAK_LEN/2)-1,(a0)

	move.b	#BUT_PAK,BUT_PAK_TYPE+2(a0)
	move.b	d0,BUT_PAK_STATE+2(a0)
	OPT	NOCHKIMM
	move.w	SYSTIMER+2,BUT_PAK_TIME+2(a0)
	OPT	CHKIMM
	move.w	-602(a1),BUT_PAK_X+2(a0)
	move.w	-600(a1),BUT_PAK_Y+2(a0)

	bsr	int_write

	movem.l	(a7)+,a0-a1
	rts


***************************************************************************
