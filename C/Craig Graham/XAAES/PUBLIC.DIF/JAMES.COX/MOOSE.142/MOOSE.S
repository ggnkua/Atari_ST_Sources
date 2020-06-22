*** Moose XDD Device Driver ***********************************************

	OUTPUT	D:\MOOSE\MOOSE.XDD

	OPT	P=68000

	OPT	AUTOPC


*** Mouse Button Packet Structure *****************************************

* This is the structure of a mouse button packet on the moose device

* This is the ID that states that mouse button data is in the moose buffer:

BUT_PAK		equ	$42


* This structure corresponds to BUT_PAK type of data. BUT_PAK_TYPE is
* actually quite redundant since all moose data packets start with a packet
* type byte:

		rsreset
BUT_PAK_TYPE		rs.b	1
BUT_PAK_STATE		rs.b	1
BUT_PAK_TIME		rs.w	1
BUT_PAK_X		rs.w	1
BUT_PAK_Y		rs.w	1

BUT_PAK_LEN		rs.l	0


*** Moose Initialise Command Structure ************************************

* This structure represents the INIT_COM command which must be sent to
* the moose device in order to activate it.

INIT_COM		equ	$49

		rsreset
INIT_COM_COM		rs.b	1
INIT_COM_PAD		rs.b	1
INIT_COM_IKBD		rs.l	1

INIT_COM_LEN		rs.l	0


*** Equates ***************************************************************

* The moose data buffer size must be divisible by 16:

MD_BUFFER_SIZE	equ	16*64


* The OS variable for the 200hz timer:

SYSTIMER	equ	$4ba


* The OS variable for the VBI list:

SYSVBI	equ	$456


*** Global Variables ******************************************************

		rsreset

* MiNT Kernal info structure:

kerinfo		rs.l	1


* Pointer to the VBI entry for our timer routine:

VBI_timer_entry		rs.l	1


* Pointer to the line-a variables:

linea		rs.l	1


* Pointer to the IKBD structure:

IKBD_table		rs.l	1


* Pointer to the old IKBD moose handler:

old_IKBD_handler	rs.l	1


* A flag to state whether or not a process is using the moose:

moose_inuse		rs.w	1


** Timer Handler Variables ************************************************

* VBI entry:

VBI_entry		rs.l	1


* pointer to the moose data packet (it's actually the click_* fields)

moose_data		rs.l	1


* MOUSE_DATA structure (from the original mousesrv)

click_x		rs.w	1
click_y		rs.w	1
click_state		rs.w	1
click_count		rs.w	1


* moose handler's variables:

timeout		rs.w	1
dc_time		rs.w	1
last_state		rs.w	1
last_time		rs.w	1


** IKBD Handler Variables *************************************************

* Used to store the last button state:

old_buttons		rs.w	1


** MD buffer variables ****************************************************

* Offset in bytes to the head of the moose buffer (read pointer):

head		rs.w	1


* Offset in bytes to the tail of the moose buffer (write pointer):

tail		rs.w	1


* Number of bytes in the md_buffer:

inbuf		rs.w	1


** Device variables *******************************************************

* The currently selected process listening to moose:

rsel		rs.l	1


* Offset to the read end of the moose buffer:

rptr		rs.w	1


* Offset tp the write end of the moose buffer:

wptr		rs.w	1


* Number of bytes used in the moose buffer:

mused		rs.w	1


variable_length		rs.l	0


*** Initialisation ********************************************************

* long main(KERINFO *kerinfo)

main	movem.l	a2-6,-(a7)

	lea	variables(pc),a6

	move.l	24(a7),a2	a2=v:kerinfo

	move.l	a2,kerinfo(a6)


** default double click time in 200ths of a second (40 = 0.2 seconds)

	move.w	#40,dc_time(a6)


** make moose_data point to the click_* variables

	lea	click_x(a6),a0
	move.l	a0,moose_data(a6)


** say hello to the world

	move.l	12(a2),a3	a3=v:dos_tab
	pea	hello(pc)
	move.l	9*4(a3),a0
	jsr	(a0)	print

	clr.w	moose_inuse(a6)	start off being dormant


** get the pointer to the line-a variables

	dc.w	$a000
	move.l	a0,linea(a6)


** install the u:\dev\moose device

	pea	dinfo(pc)
	pea	devname(pc)
	move.w	#$de02,-(a7)	DEV_INSTALL
	movea.l	$130*4(a3),a0
	jsr	(a0)	dcntl
	lea	14(a7),a7

	tst.l	d0	on error: print message
	beq.s	.failed	and return


** return entry points are '.success and '.failed'

.success	pea	success_message(pc)
	movea.l	9*4(a3),a0
	jsr	(a0)	print "it worked!!"

	moveq	#1,d0	return(1) (success)
	bra.s	.return

.failed	pea	failed_message(pc)
	move.l	9*4(a3),a0
	jsr	(a0)	print "aaaarrghh!!"

	moveq	#0,d0	return(0) (failed)

.return	addq.w	#4,a7
	movem.l	(a7)+,a2-6
	rts


*** Timer Handler *********************************************************

timer_handler	movem.l	d0-7/a0-6,-(a7)

	lea	variables(pc),a6

	tst.w	inbuf(a6)
	beq	.no_data


	lea	md_buffer(pc),a5
	move.w	head(a6),d7

	move.l	a5,a4
	add.w	d7,a5


.loop
	move.b	(a5),d0

	cmpi.b	#BUT_PAK,d0	is it a button packet?
	beq	.button_packet

* (if there is some invalid data in the md_buffer, we should flush it out)
	
.loop_end	sub.w	#16,inbuf(a6)
	add.w	#16,d7
	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.done_wrap
	clr.w	d7
.done_wrap
	move.w	d7,head(a6)

	tst.w	inbuf(a6)
	bne	.loop

.return	movem.l	(a7)+,d0-7/a0-6
	rts


** No Data Available ******************************************************

* if no data was available, then maybe the counter has expired...

.no_data	tst.w	timeout(a6)
	beq	.return

	OPT	NOCHKIMM
	move.w	SYSTIMER+2,d0
	OPT	CHKIMM

	sub.w	last_time(a6),d0

	OPT	NOCHKIMM
	move.w	SYSTIMER+2,last_time(a6)
	OPT	CHKIMM

	sub.w	d0,timeout(a6)
	bgt	.return

	bsr	.do_button_packet
	bra	.return


** Interpret a Button Packet **********************************************

.button_packet	moveq	#0,d2
	move.b	BUT_PAK_STATE(a5),d2

	moveq	#0,d1
	move.w	BUT_PAK_TIME(a5),d1

	move.w	BUT_PAK_X(a5),d3
	move.w	BUT_PAK_Y(a5),d4

	tst.w	timeout(a6)
	beq	.done_time

	move.w	d1,d0
	sub.w	last_time(a6),d0

	move.w	d1,last_time(a6)
				
	sub.w	d0,timeout(a6)
	bgt	.done_time

	clr.w	timeout(a6)

	bsr	.do_button_packet
.done_time	

	cmp.w	last_state(a6),d2
	beq	.done_buttons

	move.w	d2,last_state(a6)

	tst.w	timeout(a6)
	beq	.time_out

	cmp.w	click_state(a6),d2
	bne	.done_buttons

	addq.w	#1,click_count(a6)
	add.w	#5,timeout(a6)
	bra	.done_buttons

.time_out	tst.w	d2
	beq	.done_buttons

.new_packet	move.w	d1,last_time(a6)
	move.w	#1,click_count(a6)
	move.w	dc_time(a6),timeout(a6)
	move.w	d2,click_state(a6)		
	move.w	d3,click_x(a6)
	move.w	d4,click_y(a6)

.done_buttons	bra	.loop_end


** An Entire Button Packet Hath Been Prothethed, Mathter ******************

* write the button packet to the moose_buffer. This routine is presently
* fudged - it will only send mouse button information. this should be
* changed so that we can send XaAES other interesting things like 'hey!
* the mouse has entered a rectangle'...

.do_button_packet
	movem.l	d0-7/a0-6,-(a7)

* get the point in the buffer where we place the data

	moveq	#0,d7
	move.w	wptr(a6),d7

	lea	moose_buffer(pc),a1
	add.l	d7,a1

	move.w	click_x(a6),(a1)+
	move.w	click_y(a6),(a1)+
	move.w	click_state(a6),(a1)+
	move.w	click_count(a6),(a1)+


* point the moose_tail to the next slot along

	addq.w	#8,mused(a6)

	addq.w	#8,d7

	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.wrapped
	moveq	#0,d7
.wrapped
	move.w	d7,wptr(a6)


* wake up a listener, if applicable

	tst.l	rsel(a6)
	beq	.return

	move.l	kerinfo(a6),a0
	move.l	96(a0),a0	a0=v:wakeselect

	move.l	rsel(a6),-(a7)
	jsr	(a0)
	addq.w	#4,a7

	clr.l	rsel(a6)

	movem.l	(a7)+,d0-7/a0-6

	clr.w	timeout(a6)
	rts


*** IKBD Handler **********************************************************

IKBD_handler	movem.l	d1-7/a0-6,-(a7)

	lea	variables(pc),a6


* if the buffer is full, just return

	cmpi.w	#MD_BUFFER_SIZE,inbuf(a6)
	beq	.return


* make sure we only interpret mouse data (keyboard and joystick data goes
* through here too)

	move.b	(a0),d0
	andi.b	#$f8,d0
	cmpi.b	#$f8,d0
	bne	.return


** handle the buttons

* convert IKBD button state into AES button state

	moveq	#0,d0	make the buttons AES format
	move.b	(a0),d0
	andi.b	#%11,d0
	lsr.b	#1,d0
	bcc	.done_convert		
	bset	#1,d0		
.done_convert

* are buttons different to what they were last time? if not, don't write
* another button packet (this happens all the time since we also get mouse
* movement packets here)

	cmp.w	old_buttons(a6),d0
	beq	.done_buttons

	move.w	d0,old_buttons(a6)


* write the button packet to the moose device buffer

	bsr	maus_but_write
.done_buttons


** handle the mouse movement

* well, actually we don't... but we could if we wanted to handle mouse
* rectangles here


.return	move.l	old_IKBD_handler(a6),d0
	movem.l	(a7)+,d1-7/a0-6
	move.l	d0,-(a7)
	rts


** Write a Packet of Button Data *********************************** A6 ***

* This writes a button event packet to the moose device. The
* moose x and y position as added in here.

*  in: d0.w=button state for this packet

* packet data format is as per the BUT_PAK structure                        4.w=x at click, 6.w=y at click


maus_but_write	movem.l	d0-7/a0-6,-(a7)

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

	bsr	maus_write

	movem.l	(a7)+,d0-7/a0-6
	rts


*** Generic Moose Write Routine ************************************ A6 ***

* Write data to the md buffer. All packets MUST be of even length.

* This whole weirdy system of writing data is designed to be extensible - 
* the moose button server could be used to handle mouse rectangles and
* a whole bunch of other mouse type things...

*  in:a0=v:data - the first word of which is a dbra counter for the
*        number of words to write

maus_write	tst.w	moose_inuse(a6)	if not in use: do nothing
	beq	.return


* get the point in the buffer where we place the data

	moveq	#0,d7
	move.w	tail(a6),d7

	lea	md_buffer(pc),a1
	add.l	d7,a1

	move.w	(a0)+,d0
.loop

* copy data into the buffer

	move.w	(a0)+,(a1)+
	dbra	d0,.loop


* point the tail to the next slot along

	add.w	#16,d7

	cmpi.w	#MD_BUFFER_SIZE,d7
	bne	.done_wrap
	moveq	#0,d7
.done_wrap
	move.w	d7,tail(a6)

	add.w	#16,inbuf(a6)

.return	rts


*** Device Driver *********************************************************

** Open *******************************************************************

open	lea	variables(pc),a1

* are we already in use?

	tst.w	moose_inuse(a1)
	bne	.eaccdn

* set up our moose vector's variables

	clr.w	tail(a1)
	clr.w	head(a1)
	clr.w	inbuf(a1)

	clr.w	rsel(a1)
	clr.w	rptr(a1)
	clr.w	wptr(a1)
	clr.w	mused(a1)

	OPT	NOCHKIMM
	move.l	SYSVBI,a0
	OPT	CHKIMM
	move.w	#8,d0
.loop	tst.l	(a0)+
	beq	.set_vbi
	dbra	d0,.loop
	bra	.eaccdn

.set_vbi	move.l	#timer_handler,-(a0)
	move.l	a0,VBI_entry(a1)

	move.w	#-1,moose_inuse(a1)

	moveq	#0,d0	
	rts

.eaccdn	moveq	#-36,d0
	rts


** Close ******************************************************************

close	tst.l	4(a7)	is it a valid handle?
	beq	.eihndl

	lea	variables(pc),a1

	move.l	VBI_entry(a1),a0
	clr.l	(a0)

	clr.w	moose_inuse(a1)

	moveq	#0,d0
	rts

.eihndl	moveq	#-1,d0
	rts


** Select *****************************************************************

select	move.w	12(a7),d0	mode

	tst.w	d0
	beq	.ordonly

	cmpi.w	#1,d0
	beq	.owronly

.return0	moveq	#0,d0
	rts

.return1
.owronly	moveq	#1,d0	always ready for writes :)
	rts

.ordonly	lea	variables(pc),a0


* is there data waiting to be read?

	tst.w	mused(a0)
	bne	.return1


* are we already selected?

	tst.l	rsel(a0)
	bne	.collision


* select the caller

	move.l	8(a7),rsel(a0)
	bra.s	.return0

.collision	moveq	#2,d0
	rts


** Unselect ***************************************************************

unselect	lea	variables(pc),a0
	clr.l	rsel(a0)

.return	rts


** Read *******************************************************************

read	movem.l	d2-d5/a2-3,-(a7)

	lea	variables(pc),a3

	move.l	32(a7),a1	a1=v:buf
	move.l	36(a7),d1	d1=bytes to read
	lsr.l	#1,d1	   over 2 for # of words

	moveq	#0,d2	d2=bytes actually read

	lea	moose_buffer(pc),a2

	move.w	#MD_BUFFER_SIZE,d3

	moveq	#0,d4
	move.w	rptr(a3),d4

	move.w	mused(a3),d5

.loop	tst.w	d5
	beq	.return

	tst.l	d1
	beq	.return

	move.w	(a2,d4.w),(a1)+

	addq.w	#2,d4	incriment read pointer
	cmp.w	d4,d3	wrapping if necessery
	bne.s	.done_wrap
	clr.w	d4
.done_wrap
	subq.l	#2,d1	decriment bytes to read
	addq.l	#2,d2	incriment bytes read
	subq.w	#2,d5	decriment bytes in buffer

	bra	.loop

.return	move.w	d4,rptr(a3)
	sub.w	d2,mused(a3)

	move.l	d2,d0	return(d2) (bytes read)
	movem.l	(a7)+,d2-d5/a2-3
	rts


** Write *******************************************************************

* the Moose device can accept commands via write function. each command
* must becontained within a single write and only one command may be
* written at once

write	movem.l	d2-d7/a2-6,-(a7)

	lea	variables(pc),a6

	move.l	52(a7),a1	a1=v:buf
	move.l	56(a7),d1	d1=bytes being written

	cmpi.b	#INIT_COM,(a1)
	bne	.not_init_com
	bsr	init_moose
	bra	.return
.not_init_com
	moveq	#0,d0	bad command - ignored
.return	movem.l	(a7)+,d2-7/a2-6
	rts


** Seek *******************************************************************

lseek	moveq	#0,d0	always at start of file
	rts


** Ioctl ******************************************************************

ioctl	move.w	8(a7),d0	mode

	cmpi.w	#$4601,d0	FIONREAD
	beq	.fionread

	cmpi.w	#$4602,d0	FIONWRITE
	beq	.fionwrite

	cmpi.w	#$4605,d0	FIOEXCEPT
	beq	.fioexcept

	moveq	#-1,d0	anything else isn't alowed
	rts	

.fionread	lea	variables(pc),a1

* calculate the number of bytes ready to read from the moose buffer

	moveq	#0,d0
	move.w	inbuf(a1),d0

.write	move.l	10(a7),a0
	move.l	d0,(a0)	

	moveq	#0,d0
	rts

.fionwrite
.fioexcept	moveq	#0,d0
	bra.s	.write


** Datime *****************************************************************

datime	moveq	#-36,d0	not much point, really :)
	rts



*** Moose Device Command Interpreter **************************************

* All the command interpreters find the command at a1, the size of the
* write in d1 and the global variables on a6. no registers need to be
* saved.


** INIT_COM: Initialise Moose *********************************************

* the INIT_COM command is used to activate the moose device. once active,
* the moose cannot be shut down and will ignore all further INIT_COM
* commands.

* after the command type byte is a pad byte followed by the pointer to the
* IKBD table returned from xbios $22.

init_moose	tst.l	IKBD_table(a6)
	beq	.ok	definitely not installed

	move.l	IKBD_table(a6),a0
	cmpi.l	#IKBD_handler,16(a0)
	beq	.return	already installed
.ok

** get the IKBD table

	move.l	INIT_COM_IKBD(a1),a0
	move.l	a0,IKBD_table(a6)


** patch our moose vector into the IKBD table

	move.l	16(a0),old_IKBD_handler(a6)

	pea	IKBD_handler(pc)
	move.l	(a7)+,16(a0)

.return	moveq	#INIT_COM_LEN,d0
	rts


*** DATA Section **********************************************************

	SECTION DATA

* The device structure:

	even

dinfo	dc.l	devdrv
	dc.w	0,0
	dc.l	0
	dc.l	0,0,0,0

devdrv	dc.l	open
	dc.l	write
	dc.l	read
	dc.l	lseek
	dc.l	ioctl
	dc.l	datime
	dc.l	close
	dc.l	select
	dc.l	unselect
	dc.l	0,0,0


* The device name:

devname	dc.b	'u:\dev\moose',0


* Start-up messages:

hello	dc.b	13,10
	dc.b	'Moose device driver',13,10
	dc.b	'version 1.4.2',13,10
	dc.b	'by James Cox',13,10,10,0

success_message	dc.b	'Installation successful.',13,10,10,0

failed_message	dc.b	'Installation failed.',13,10,10,0


*** BSS Section ***********************************************************

	SECTION BSS
	even

* Space for all of our variables:

variables	ds.b	variable_length


* Space for a moose packet (must be big enough for the largest *_PAK
* structure plus 2 bytes):

moose_packet	ds.b	BUT_PAK_LEN+2


* moose device's buffer:

md_buffer	ds.b	MD_BUFFER_SIZE


* moose buffer: (read by a client application - XaAES)

moose_buffer	ds.b	MD_BUFFER_SIZE


***************************************************************************
