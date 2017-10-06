*** Timer Handler *********************************************************

	SECTION TEXT


* The timer handler's job is to check for data in the md_buffer and
* interpret it. The data will be low level stuff from the IKBD handler.

* This is where low level mouse button events are converted into AES
* level mouse button events, i.e, it joins up mouse button events of the
* same type into double click events etc.

* NOTE: This code _could_ be modified slightly so that it takes
* advantage of the fact that it is being called on an interrupt with a
* fixed time interval between each call (at present, it will work perfectly
* even if the time between calling this routine is massively variable,
* except for the fact that it MUST be called when the timeout variable
* expires...)

* I have chosen not to make these modifications because
* 1) it is really easy to make huge changes to the architecture of the
* Moose server this way, and
* 2) it works, so I'd rather not bugger about with it too much :).


timer_handler
	movem.l	d0/a6,-(a7)
	lea	variables(pc),a6

** Check if there is some data in the md_buffer

	tst.w	inbuf(a6)
	beq	.no_data

	movem.l	d1-d4/d7/a5,-(a7)

** Interpret said data...

	lea	md_buffer(pc),a5
	move.w	head(a6),d7

** loop around interpreting data until there we've done the lot

.loop

* Make A5 point to the start of the data
* (we're dealing with a circular list of 16 byte entries)

	add.w	d7,a5

	move.b	(a5),d0

* If this is a button packet, go off and handle it

	cmpi.b	#BUT_PAK,d0			Is it a button packet?
	beq	.button_packet


* If there is data in the md_buffer that we don't understand, we simply
* skip it (we don't need any fancy flushing after all :)

* Record that we've read this packet of data and move A5 along to the
* next packet (wrapping around if necessery)
	
.loop_end
	sub.w	d7,a5				Point back to start
	add.w	#16,d7
	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.done_wrap
	clr.w	d7
.done_wrap
	move.w	d7,head(a6)


* Check if there's anything left to do, looping around if there is

	sub.w	#16,inbuf(a6)
	bne	.loop

.return
	movem.l	(a7)+,d1-4/d7/a5
.returnx
	movem.l	(a7)+,d0/a6
	rts


** No Data Available ******************************************************

* The timeout variable is normally 0. This means that nothing is presently
* happening. Only when you press one of the mouse buttons does it change
* (in .button_packet) where upon it is set to the double click time out
* value. If any other mouse button packets arrive here during that time,
* they are added together to make a multiple click packet. Once the
* timeout expires, an XaAES mouse packet is sent.

.no_data

* If the counter is already 0, then we timeout out some time ago,
* i.e., it hasn't just happened

	tst.w	timeout(a6)
	beq	.returnx


* Find out how long it's been since last we were here
* (current_time - last_time)

	OPT	NOCHKIMM
	move.w	SYSTIMER+2,d0
	OPT	CHKIMM

	sub.w	last_time(a6),d0


* Update the last_time variable to be the current time

	OPT	NOCHKIMM
	move.w	SYSTIMER+2,last_time(a6)
	OPT	CHKIMM


* Update our timeout varible - if this suddenly goes <=0, then we
* have timed out, otherwise we keep on ticking.

	sub.w	d0,timeout(a6)
	bgt	.returnx


* We timeout - write the button packet to XaAES

	bsr	.do_button_packet
	bra	.returnx


** Interpret a Button Packet **********************************************

* This is the really complicated bit :).

.button_packet

* Setup D2=button state, D1=time of the event and D3,D4 are the x,y
* co-ordinates of the click

	moveq	#0,d2
	move.b	BUT_PAK_STATE(a5),d2

	moveq	#0,d1
	move.w	BUT_PAK_TIME(a5),d1

	move.w	BUT_PAK_X(a5),d3
	move.w	BUT_PAK_Y(a5),d4


* If the timeout == 0, then we timed out some time ago so we have to
* start a new XaAES button packet

	tst.w	timeout(a6)
	beq	.done_time


* Update the timeout and last_time variables

	move.w	d1,d0
	sub.w	last_time(a6),d0

	move.w	d1,last_time(a6)

* If the timeout goes <=0 then we write out the XaAES button packet we were
* handling (there is not timeout without a button packet) but the new
* button packet (the reason why we're executing .button_packet :) will
* NOT be a part of it - the current button packet will form an entirely
* new XaAES button packet

* But if we haven't timeout out, then this current button packet can
* be lumped into the current XaAES button packet
				
	sub.w	d0,timeout(a6)
	bgt	.done_time

	bsr	.do_button_packet


* Now we drop through to handle a brand new button packet, just as if
* the timeout was 0 at the start of this routine

.done_time	

* If the button state from the packet is the same as the last one,
* then we've nothing to do

	cmp.w	last_state(a6),d2
	beq	.done_buttons

	move.w	d2,last_state(a6)


* If the time out is non-zero, we are in the middle of handling an XaAES
* button packet. Otherwise, we aren't so we need to build a new packet

	tst.w	timeout(a6)
	beq	.new_packet


* If this button packet contains a click of a different type to the
* XaAES button packet we have, then we drop it. this sounds drastic,
* but think about it - when are we going to have the user clicking
* alternate buttons at double click speed (a new version of
* Decathlon with mouse button waggling :)

	cmp.w	click_state(a6),d2
	bne	.done_buttons

* If the button is of the same type as the XaAES button packet,
* increment the button count. We add a little bit of time to the timeout
* to make triple clicking + a little easier for the user :)
* (remember that the timeout is in 1/200ths of a second)

	addq.w	#1,click_count(a6)
	add.w	#5,timeout(a6)
	bra	.done_buttons


* Build a new packet - but only for clicks, we don't start a new packet
* if no buttons are pressed

.new_packet
	tst.w	d2
	beq	.done_buttons

	move.w	d1,last_time(a6)
	move.w	#1,click_count(a6)
	move.w	dc_time(a6),timeout(a6)
	move.w	d2,click_state(a6)		
	move.w	d3,click_x(a6)
	move.w	d4,click_y(a6)

.done_buttons
	bra	.loop_end


** An Entire Button Packet Hath Been Prothethed, Mathter ******************

* This routine will send button packets to XaAES. It uses a generic write
* routine that can be used by other Moose sub-systems to send rectangle
* reports etc.

.do_button_packet
	move.l	a0,-(a7)

* Create a buffer on the stack big enough for the button report and
* fill that buffer (the first word of the structure is the number of
* words following (-1 for dbra), the report that gets written starts
* at the 2nd word)

	lea	-(MOOSE_BUTTON_LEN+4)(a7),a7
	move.l	a7,a0

	move.w	#(MOOSE_BUTTON_LEN/2),(a0)
	move.w	#MOOSE_BUTTON,2(a0)
	move.w	click_x(a6),MOOSE_BUTTON_X+4(a0)
	move.w	click_y(a6),MOOSE_BUTTON_Y+4(a0)
	move.w	click_state(a6),MOOSE_BUTTON_STATE+4(a0)
	move.w	click_count(a6),MOOSE_BUTTON_COUNT+4(a0)

* Write it
	bsr	gen_write

* Tidy the stack

	lea	(MOOSE_BUTTON_LEN+4)(a7),a7	


* Clear the timeout value to signify that we're ready to start building
* another report

	clr.w	timeout(a6)

	move.l	(a7)+,a0
	rts


***************************************************************************
