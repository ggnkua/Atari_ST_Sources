*** Moose XDD Device Driver ***********************************************

have_wheels equ 0

** Preliminaries **********************************************************

;	OUTPUT	moose.xdd

;	OPT	P=68000,AUTOPC,NODEBUG
;	OPT	P=68000,NODEBUG,CHKIMM

*** Equates ***************************************************************

* This is the upper bound placed on the double click time (1 second).
* This is to prevent stupid values being passed - really high values
* (even 1 second, actually) are bad since even a single click won't be
* reported until dc_time has expired.

MAX_DC_TIME	equ	200

* The OS variable for the 200hz timer:

SYSTIMER	equ	$4ba


* The OS variable for the VBI list:

SYSVBI	equ	$456


* The OS variable for the number of entries in the VBI list:

SYSNVBI	equ	$454


*** Moose Data Structures *************************************************

* These structures are the ones that are Fread() from the device. Once
* you have assertained (by Fselect()) that there is information to read,
* you should read 1 word which is the command prefix (eg, MOOSE_BUTTON).
* This tells you what type of structure to read from the device next.

* The structures below don't include the prefix word - it is added by
* Moose at the time of writing the report.
** HR: but they should include this! Done.

** Moose event Report Structure ******************************************

* This structure is the MOUSE_DATA structure in XaAES. It is essentially
* identical (in fact, the XaAES structure need not be altered)


MOOSE_BUTTON		equ	'XB'
MOOSE_MOVEMENT		equ 'XM'
MOOSE_WHEEL			equ 'XW'

		offset
MOOSE_L:			ds.w	1	; HR: record length: Read this amount, otherwise
MOOSE_PREF:			ds.w	1	; loose sync
MOOSE_BUTTON_X:		ds.w	1
MOOSE_BUTTON_Y:		ds.w	1
MOOSE_BUTTON_STATE:	ds.w	1
MOOSE_BUTTON_COUNT:	ds.w	1
MOOSE_DEBUG:		ds.l	1

MOOSE_LEN:			ds.l	0	; HR: made generic

FS_BUFFER_SIZE	equ 16*MOOSE_LEN

*** Moose Commands ********************************************************

* The first word of each structure is a prefix denoting which command
* will follow. However, the entire command MUST be Fwrite()en as a single
* block, otherwise Moose won't know what you're talking about.


** Moose Rectangle Command Structure **************************************

* This structure is used to tell Moose to add or remove a rectnagle from
* its watch list. This structure is presently unused and is provisional.
* HR: This is removed. Rectangles are not the concern of the moose
*     Instead the moose now reports the movement of the mouse once
*     every VBI when the mouse has moved.
*     Rectangles belong to AES, and its there that they must be handled.


** Moose Double Click Time Structure **************************************

* This structure represents an 'alter double click time' packet.

* DCLK_COM_TIME is the number of 200hz clicks for the double click time.
* As an indication, the default dc_time is 40 (0.2 seconds).

DCLK_COM 	equ	'MD'

	offset
				ds.w	1	; prefix
DCLK_COM_TIME:	ds.w	1
DCLK_COM_LEN:	ds.l	0


** Moose Initialise Command Structure *************************************

* This structure represents the INIT_COM command which must be sent to
* the moose device in order to activate it.

INIT_COM	equ	'MI'

	offset
		ds.w	1	; prefix
INIT_COM_IKBD:	ds.l	1

INIT_COM_LEN:	ds.l	0

VECS_COM	equ 'MV'
	offset
		ds.w	1	; prefix
VEC_MOT:	ds.l	1
VEC_BUT:	ds.l	1
VEC_TIM:	ds.l	1
VEC_WHL:	ds.l	1

VECS_COM_LEN: ds.l	0


***************************************************************************

*** Internal Structures **************************************************

* Internally, the Moose holds a buffer of interesting things called
* 'md_buffer'. For example, if the mouse buttons change states, that is
* put in the md_buffer because it's interesting :).

* HR: the whole lot can be speeded up by using pointers in stead of indices
*     in the circular buffers.

** Mouse Button Packet Structure *****************************************

* This is the ID that states that mouse button data is in the moose buffer:

BUT_PAK		equ	'B'
WHL_PAK		equ 'W'
* VBUT_PAK	equ 'V'
* VMOV_PAK	equ 'M'
* VWHL_PAK	equ 'W'

* This structure corresponds to WHL_PAK type of data

		offset
WHL_PAK_L:	ds.w	1
WHL_PAK_TYPE:	ds.b	1
WHL_PAK_WHEEL:	ds.b	1
WHL_PAK_CLICKS:	ds.w	1
WHL_PAK_X:	ds.w	1
WHL_PAK_Y:	ds.w	1
WHL_PAK_DBG:	ds.l	1

WHL_PAK_LEN:	ds.l	0


* This structure corresponds to BUT_PAK type of data. 

		offset
BUT_PAK_L:	ds.w	1		; HR: record length
BUT_PAK_TYPE:	ds.b	1		;     make these equ's true and exact
BUT_PAK_STATE:	ds.b	1
BUT_PAK_TIME:	ds.w	1
BUT_PAK_X:	ds.w	1
BUT_PAK_Y:	ds.w	1
BUT_PAK_DBG:	ds.l	1

BUT_PAK_LEN:	ds.l	0
PAK equ BUT_PAK_LEN

* This is the structure of a mouse button packet on the moose device.

		offset
VBUT_PAK_L:	ds.w	1		; HR: record length
VBUT_PAK_TYPE:	ds.b	1		;     make these equ's true and exact
VBUT_PAK_STATE:	ds.b	1
VBUT_PAK_TIME:	ds.w	1

VBUT_PAK_LEN:	ds.l	0

VPAK equ VBUT_PAK_LEN

MD_BUFFER_SIZE	equ	16*PAK

*** Global Variables ******************************************************

		offset

* MiNT Kernal info structure:

kerinfo:	ds.l	1


* Pointer to the VBI entry for our timer routine:

VBI_timer_entry:
		ds.l	1


* A flag to state whether or not a process is using the moose:

moose_inuse:	ds.w	1


** Timer Handler Variables ************************************************

* VBI entry:

VBI_entry:	ds.l	1


* MOUSE_DATA structure working variables

click_x:	ds.w	1
click_y:	ds.w	1
click_state:	ds.w	1
click_count:	ds.w	1


* Moose handler's variables:

timeout:	ds.w	1
dc_time:	ds.w	1
last_state:	ds.w	1
last_time:	ds.w	1
halve:		ds.w	1


** IKBD Handler Variables *************************************************

* Used to store the last button state:

old_buttons:	ds.w	1


** MD buffer variables ****************************************************

* Pointer to the head of the moose buffer (read pointer):

head:		ds.l	1

* Pointer to the tail & the end of the moose buffer (write pointer):

tail:		ds.l	1
md_end:		ds.l	1

* Number of bytes in the md_buffer:
* HR: not used as any kind of index. just a counter.

inbuf:		ds.w	1


** Device variables *******************************************************

* The currently selected process listening to moose:
wake:		ds.w	1
rsel:		ds.l	1


* Offset to the read end of the moose buffer:

rptr:		ds.w	1


* Offset to the write end of the moose buffer:

wptr:		ds.w	1


* Number of bytes used in the moose buffer:

mused:		ds.w	1

* data needed for the mouse movement detection

old_x:		ds.w	1
old_y:		ds.w	1
sample_x:	ds.w	1
sample_y:	ds.w	1


variable_length:
		ds.l	0

		text
*** Initialisation ********************************************************

* long main(KERINFO *kerinfo)

main:
	movem.l	d2-d7/a2-a6,-(a7)

	lea	variables(pc),a6

** Store the pointer to the KERINFO structure

	move.l	48(a7),a2			; a2 = v:kerinfo
	move.l	a2,kerinfo(a6)

** Clear the double click time to prevent mouse button reporting

	clr.w	dc_time(a6)
	clr.w	moose_inuse(a6)		;	Start off being dormant
	clr.w	old_x(a6)			; HR
	clr.w	old_y(a6)

** Say hello to the world

	move.l	12(a2),a3			; a3 = v:dos_tab
	pea	hello(pc)
	move.l	9*4(a3),a0
	jsr	(a0)				; Print

** Install the u:\dev\moose device

	pea	dinfo(pc)
	pea	devname(pc)
	move.w	#$de02,-(a7)			; DEV_INSTALL
	movea.l	$130*4(a3),a0
	jsr	(a0)				; dcntl
	lea	14(a7),a7			; (Tidy the print as well)
	tst.l	d0				; On error: print message
	beq.s	.failed				; and return

** Return entry points are '.success and '.failed'

.success:
	pea	success_message(pc)
	movea.l	9*4(a3),a0
	jsr	(a0)				; print "it worked!!"
	moveq	#1,d0				; return(1) (success)
	bra.s	.return
.failed:
	pea	failed_message(pc)
	move.l	9*4(a3),a0
	jsr	(a0)				; print "aaaarrghh!!"
	moveq	#0,d0				; return(0) (failed)
.return:
	addq.w	#4,a7				; (Tidy the print)
	movem.l	(a7)+,d2-d7/a2-a6
	rts


*** DATA Section **********************************************************

	data

* The device name:

devname:
	dc.b	'u:\dev\moose',0


* Start-up messages:

hello:
	dc.b	13,10
.if have_wheels
	dc.b	'whlmoose: Mouse device driver with wheel support',13,10
.else
	dc.b	'vmoose: Mouse device driver',13,10
.endif
	dc.b	'Version 3.0 by Henk Robbers; based on',13,10
	dc.b	'm³³se by James Cox, Craig Graham & Johan Klockars',13,10,10,0

success_message:
	dc.b	'Installation successful.',13,10,10,0

failed_message:
	dc.b	'Installation failed.',13,10,10,0


*** BSS Section ***********************************************************

	bss
	even

* Space for all of our variables:

variables:
	ds.b	variable_length


* Moose device's buffer:

md_buffer:
	ds.b	MD_BUFFER_SIZE


* Moose buffer: (read by a client application - XaAES)

moose_buffer:
	ds.b	FS_BUFFER_SIZE

*** Device Driver *********************************************************

	text


** Open *******************************************************************

open:
	lea	variables(pc),a1

* Are we already in use?

	tst.w	moose_inuse(a1)
	bne	.eaccdn

* Set up our moose vector's variables

	move.l	#md_buffer,tail(a1)
	move.l	tail(a1),head(a1)
	move.l	#md_buffer+MD_BUFFER_SIZE,md_end(a1)

	clr.w	halve(a1)
	clr.w	inbuf(a1)

	clr.l	rsel(a1)		; HR: .l 
	clr.w	rptr(a1)
	clr.w	wptr(a1)
	clr.w	mused(a1)

	move.l	SYSVBI,a0
	move.w	SYSNVBI,d0

	addq.w	#4,a0			; Skip VDI's VBI
	subq.w	#2,d0			; -1 for dbra, -1 for above
	blt	.eaccdn
.loop:
	tst.l	(a0)+
	beq	.set_vbi
	dbra	d0,.loop
	bra	.eaccdn

.set_vbi:
	move.l	# timer_handler,-(a0)
	move.l	a0,VBI_entry(a1)

	move.w	#-1,moose_inuse(a1)

	clr.w	dc_time(a1)

	moveq	#0,d0	
	rts


* Don't like this at all - we should allocate a new VBI list
* instead of returning an error. !!TODO!!

.eaccdn:
	moveq	#-36,d0
	rts


** Close ******************************************************************

close:
	tst.l	4(a7)			; Is it a valid handle?
	beq	.eihndl
	lea	variables(pc),a1
	move.l	VBI_entry(a1),a0
	clr.l	(a0)
	clr.w	moose_inuse(a1)
	clr.w	dc_time(a1)
	moveq	#0,d0
	rts

.eihndl:
	moveq	#-1,d0
	rts


** Select *****************************************************************

select:
	move.w	12(a7),d0		; Mode
	beq	.ordonly

	subq.w	#1,d0
	beq	.owronly

.return0:
	moveq	#0,d0
	rts

.return1:
.owronly:
	moveq	#1,d0			; Always ready for writes :)
	rts

.ordonly:
	lea	variables(pc),a0

	tst.w	mused(a0)		; Is there data waiting to be read?
	bne	.return1

	tst.l	rsel(a0)		; Are we already selected?
	bne	.collision

	move.l	8(a7),rsel(a0)	; Select the caller
	bra.s	.return0

.collision:
	moveq	#2,d0
	rts


** Unselect ***************************************************************

unselect:
	lea	variables(pc),a0
	clr.l	rsel(a0)

.return:
	rts


** Read *******************************************************************
*  HR: This method is not changed: (Only a few optimizations)
*		because it is basicly character based.
*      Reading must be as flexible as possible, because reading is not supposed to know
*      particularities of what is written.
*  Writing is different. If you always write fixed length packets, there is no need to
*      do be scrupulous; do it as fast as possible.

read:
	movem.l	d2-d3/a1-a3,-(a7)

	lea	variables(pc),a3

	move.l	28(a7),a1			; a1 = v:buf

	moveq	#0,d0				; d0 = bytes actually read
	lea 	moose_buffer(pc),a2
	move.w	rptr(a3),d2
	move.w	mused(a3),d3

	move.l	32(a7),d1			; d1 = bytes to read
	beq .return
.loop:
	tst.w	d3
	beq 	.return

	move.w	(a2,d2.w),(a1)+

	addq.w	#2,d2				; Increment read pointer
	cmpi.w	# FS_BUFFER_SIZE,d2		; Wrapping if necessery
	bne.s	.done_wrap
	clr.w	d2
.done_wrap:

	addq.l	#2,d0				; Increment bytes read
	subq.w	#2,d3				; Decrement bytes in buffer
	subq.l	#2,d1				; Decrement bytes to read
	bne	.loop

.return:
	move.w	d2,rptr(a3)
	sub.w	d0,mused(a3)

* Return(d0) (bytes read)
	movem.l	(a7)+,d2-d3/a1-a3
	rts


** Write ******************************************************************

* The Moose device can accept commands via write function. Each command
* must becontained within a single write and only one command may be
* written at once

write:
	movem.l	d2-d7/a2-a6,-(a7)

	lea	variables(pc),a6

	move.l	52(a7),a0			; a0 = v:buf
	move.l	56(a7),d0			; d0 = bytes being written

	bsr	handle_commands

	movem.l	(a7)+,d2-d7/a2-a6
	rts


** Seek *******************************************************************

lseek:
	moveq	#0,d0				; Always at start of file
	rts


** Ioctl ******************************************************************

ioctl:
	move.w	8(a7),d0			; Mode

	cmpi.w	#$4601,d0			; FIONREAD
	beq	.fionread

	cmpi.w	#$4602,d0			; FIONWRITE
	beq	.fionwrite

	cmpi.w	#$4605,d0			; FIOEXCEPT
	beq	.fioexcept

	moveq	#-1,d0				; Nothing else is allowed
	rts	

.fionread:
	lea	variables(pc),a1

* Calculate the number of bytes ready to read from the moose buffer

	moveq	#0,d0
	move.w	mused(a1),d0		; !!!! was inbuf !!!!!

.write:
	move.l	10(a7),a0
	move.l	d0,(a0)	

	moveq	#0,d0
	rts

.fionwrite:
.fioexcept:
	moveq	#0,d0
	bra.s	.write


** Datime *****************************************************************

datime:
	moveq	#-36,d0			; Not much point, really :)
	rts

*** Generic Write Routine ****************************************** A6 ***

* Write data to the listening process. All packets MUST be of even length.

* This whole weird system of writing data is designed to be extensible.

*  in: a0 = v:data - the first word of which is a exact counter for the
*           number of words to write

* The buffer is a full multiple of MOOSE_LEN bytes.
* No need for check wrapping every byte.
gen_write:
	tst.w	moose_inuse(a6)		; If not in use: do nothing
	beq	.return
	movem.l	d0/d7/a0-a1,-(a7)

	move.w	wptr(a6),d7		; Get the point in the buffer where we place the data
	cmp.w	rptr(a6),d7
	bne 	.l1
	moveq	#0,d7
	move.w	d7,wptr(a6)
	move.w	d7,rptr(a6)
	move.w	d7,mused(a6)
.l1:
	lea	moose_buffer(pc),a1
	adda.w	d7,a1

*	move.w	(a0),d0			; HR: length included in record and made exact no of bytes
	moveq	# MOOSE_LEN-1,d0
.loop:
	move.b	(a0)+,(a1)+		; Copy over a byte of moose data into the buffer
	dbra	d0,.loop

	move.w	rptr(a6),-4(a1)	; debug
	move.w	wptr(a6),-2(a1)

	moveq	# MOOSE_LEN,d0
	add.w	d0,mused(a6)		; Point the moose_tail to the next slot along
	add.w	d0,d7
	cmpi.w	# FS_BUFFER_SIZE,d7
	bne 	.done_wrap
	moveq	#0,d7
.done_wrap:
	move.w	d7,wptr(a6)

	st	wake(a6)

*	HR: moved wakeup to timer_handler

	movem.l	(a7)+,d0/d7/a0-a1	; HR: push --> pull 
.return:
	rts


*** DATA Section **********************************************************

	data
	even

* The device structure:


dinfo:
	dc.l	devdrv
	dc.w	0,0
	dc.l	0
	dc.l	0,0,0,0

devdrv:
	dc.l	open
	dc.l	write
	dc.l	read
	dc.l	lseek
	dc.l	ioctl
	dc.l	datime
	dc.l	close
	dc.l	select
	dc.l	unselect
	dc.l	0,0,0

	bss
a0a1:
	ds.l	2

	text
** These are exchanged VDI change vectors ****************************************************
motv:
	move.l	a0,a0a1
	lea 	variables(pc),a0
	move	d0,sample_x(a0)
	move	d1,sample_y(a0)
	move.l	a0a1,a0
	rts

butv:
	movem.l	a0-a1,a0a1
	lea 	variables(pc),a0
	move.l	tail(a0),a1
	cmpa.l	head(a0),a1
	bne 	.b1
	lea 	md_buffer,a1		; head equals tail :: buffer empty: reset
	move.l	a1,head(a0)
	move.l	a1,tail(a0)
.b1:
	move.w	# BUT_PAK_LEN,(a1)+	; HR: made exact
	move.b	# BUT_PAK,(a1)+

	move.b	d0,(a1)+

	move.w	SYSTIMER+2,(a1)+
	move.w	sample_x(a0),(a1)+
	move.w	sample_y(a0),(a1)+
	cmpa.l	md_end(a0),a1
	bne 	.done_wrap
	lea 	md_buffer(pc),a1
.done_wrap:
	move.l	a1,tail(a0)
	add.w	# PAK,inbuf(a0)
	movem.l	a0a1,a0-a1
	rts

.if have_wheels
whlv:
	movem.l	a0-a1,a0a1
	lea 	variables(pc),a0
	move.l	tail(a0),a1
	cmpa.l	head(a0),a1
	bne 	.b1
	lea 	md_buffer,a1		; head equals tail :: buffer empty: reset
	move.l	a1,head(a0)
	move.l	a1,tail(a0)
.b1:
	move.w	# WHL_PAK_LEN,(a1)+	; HR: made exact
	move.b	# WHL_PAK,(a1)+

	move.b	d0,(a1)+
	move.w	d1,(a1)+

	move.w	sample_x(a0),(a1)+
	move.w	sample_y(a0),(a1)+
	cmpa.l	md_end(a0),a1
	bne 	.done_wrap
	lea 	md_buffer(pc),a1
.done_wrap:
	move.l	a1,tail(a0)
	add.w	# PAK,inbuf(a0)
	movem.l	a0a1,a0-a1
	rts
.endif

timv:
	rts

** Command Interpreter ****************************************************

* This is called by the write function of the device driver and acts as a
* top level call.

* All the command interpreters find the command at A0, the size of the
* write in D0 and the global variables on A6. No registers need to be
* saved although on return, D0.L should hold the size of the write for
* success (leave it as it is), or 0 for an error.

handle_commands:
	cmpi.w	# INIT_COM,(a0)
	beq	init_moose

	cmpi.w	# DCLK_COM,(a0)
	beq	dclk_command

	moveq	#0,d0		; Bad command - ignored
	rts


** INIT_COM: Initialise Moose *********************************************

* The INIT_COM command is used to activate the moose device. Once active,
* the moose cannot be shut down and will ignore all further INIT_COM
* commands unless it needs reinstalling (eg: after the VDI opens a physical
* screen workstation).

init_moose:

** Put the VDI_VEC in the buffer
	lea	moose_buffer(pc),a2
	move.w	# VECS_COM,(a2)+
	move.l	# motv,(a2)+	
	move.l	# butv,(a2)+
	move.l	# timv,(a2)+
.if have_wheels
	move.l	# whlv,(a2)+
.else
	move.l	# 0,(a2)+
.endif
	move.w	# VECS_COM_LEN,mused(a6)
	rts


** DCLK_COM: Change Double Click Time Command *****************************

* This command allows XaAES to change the double click time.
* If you set the dc_time to 0, then that will prevent the Moose from
* sending any more button packets (if there are packets pending, they
* can still be read, i.e., Moose will not flush the mouse data.

* There is an upper bound placed on the dc_time. It may not be longer
* than MAX_DC_TIME (defined in MOOSE.I). If you try to set it to more than
* MAX_DC_TIME, then it is 'clipped' to MAX_DC_TIME.

dclk_command:
	move.w	DCLK_COM_TIME(a0),d1
	cmpi.w	# MAX_DC_TIME,d1
	ble.s	.okay
	move.w	# MAX_DC_TIME,d1
.okay:
	move.w	d1,dc_time(a6)
	rts

*** Timer Handler *********************************************************

* The timer handler's job is to check for data in the md_buffer and
* interpret it. The data will be low level stuff from the IKBD handler.

* This is where low level mouse button events are converted into AES
* level mouse button events, i.e, it joins up mouse button events of the
* same type into double click events etc.

* HR: Mouse movement events are created whenever the mouse position has
*     changed.

* JC:
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

* HR: made all branching forward. (except of course when a branch is needed to repeat
*     some code. ;-)

timer_handler:
	movem.l	d0/a6,-(a7)
	lea	variables(pc),a6

*	HR: first off all, see if the mouse has moved, then write simply 1 mouse_movement packet
*       Question: do we need to detect movement every 14 miliseconds (70Hz) ?
*		Lets halve that frequency:
*		(or better, cut in quarts) or in 8th's or tens????
divide equ 4
*       No visible change, so that's good enough.
	move.w	halve(a6),d0
	addq.w	#1,d0
	cmp.w	#divide,d0
	bne	.not_yet
	clr.w	d0
.not_yet:
	move.w	d0,halve(a6)
	bne	.no_xy

*  if zeroized d0, check.
	move.w	sample_x(a6),d0
	cmp.w	old_x(a6),d0
	bne 	.a_move
	move.w  sample_y(a6),d0
	cmp.w	old_y(a6),d0
	beq 	.no_xy

.a_move:
	movem.l	d1-d4/a5,-(a7)
	bsr 	.do_move_packet
	tst.w	inbuf(a6)	; Check if there is some data in the md_buffer
	bne	.after_xy
	movem.l	(a7)+,d1-d4/a5
	bra 	.no_data

.no_xy:
	tst.w	inbuf(a6)	; Check if there is some data in the md_buffer
	bne	.go_on

** No Data Available ******************************************************

* The timeout variable is normally 0. This means that nothing is presently
* happening. Only when you press one of the mouse buttons does it change
* (in .button_packet) where upon it is set to the double click time out
* value. If any other mouse button packets arrive here during that time,
* they are added together to make a multiple click packet. Once the
* timeout expires, an XaAES mouse packet is sent.

.no_data:
	tst.w	timeout(a6)			; If the counter is already 0, then we timeout out some time ago,
	beq	.returnx			; i.e., it hasn't just happened
	move.w	SYSTIMER+2,d0			; Find out how long it's been since last we were here
	sub.w	last_time(a6),d0		; (current_time - last_time)
	move.w	SYSTIMER+2,last_time(a6)	; Update the last_time variable to be the current time
	sub.w	d0,timeout(a6)			; Update our timeout variable - if this suddenly goes <=0, then we
	bgt	.returnx			; have timed out, otherwise we keep on ticking.
	bsr	.do_button_packet		; We timeout - write the button packet to XaAES
	bra	.returnx

.go_on:
	movem.l	d1-d4/a5,-(a7)

.after_xy:
	lea	md_buffer(pc),a5		; Interpret said data...
	move.l	head(a6),a5

.loop:	; loop around interpreting data until there we've done the lot
	move.b	BUT_PAK_TYPE(a5),d0		; (we're dealing with a circular list of PAK byte entries)

.if have_wheels
	cmpi.b	# WHL_PAK,d0
	bne	.loopb
	jsr	.do_wheel_packet
	bra .done_buttons
.loopb:
.endif
	cmpi.b	# BUT_PAK,d0			; Is it a button packet?
	bne .done_buttons 			; .loop_end

** Interpret a Button Packet **********************************************
* This is the really complicated bit :).

.button_packet:
	moveq	#0,d2				; Setup D2=button state, D1=time of the event and D3,D4 are the x,y
	move.b	BUT_PAK_STATE(a5),d2		; co-ordinates of the click
	moveq	#0,d1
	move.w	BUT_PAK_TIME(a5),d1
	move.w	BUT_PAK_X(a5),d3
	move.w	BUT_PAK_Y(a5),d4
	tst.w	timeout(a6)			; If the timeout == 0, then we timed out some time ago so we have to
	beq	.done_time			; start a new XaAES button packet
	move.w	d1,d0				; Update the timeout and last_time variables
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

.done_time:
	cmp.w	last_state(a6),d2		; If the button state from the packet is the same as the last one,
	beq	.done_buttons			; then we've nothing to do
	move.w	d2,last_state(a6)
	tst.w	timeout(a6)			; If the time out is non-zero, we are in the middle of handling an XaAES
	beq	.new_packet			; button packet. Otherwise, we aren't so we need to build a new packet
	cmp.w	click_state(a6),d2		; If this button packet contains a click of a different type to the
	bne	.done_buttons			; XaAES button packet we have, then we drop it. No quick L/R clicking

* If the button is of the same type as the XaAES button packet,
* increment the button count. We add a little bit of time to the timeout
* to make triple clicking + a little easier for the user :)
* (remember that the timeout is in 1/200ths of a second)

	addq.w	#1,click_count(a6)
	add.w	#5,timeout(a6)
	bra	.done_buttons

.new_packet:			; Build a new packet - but only for clicks, we don't start a new packet
*	tst.w	d2		; if no buttons are pressed
*	beq	.done_buttons  ; HR: but we want button up events. So since vdi vectors are used we can simply pass them.

	move.w	d1,last_time(a6)
	move.w	#1,click_count(a6)
	move.w	dc_time(a6),timeout(a6)
	move.w	d2,click_state(a6)		
	move.w	d3,click_x(a6)
	move.w	d4,click_y(a6)

.done_buttons:


* If there is data in the md_buffer that we don't understand, we simply
* skip it (we don't need any fancy flushing after all :)
* Record that we've read this packet of data and move A5 along to the
* next packet (wrapping around if necessery)

.loop_end:
	lea	PAK(a5),a5
	cmpa.l	md_end(a6),a5
	bne	.done_wrap
	lea	md_buffer(pc),a5
.done_wrap:
	move.l	a5,head(a6)
	sub.w	# PAK,inbuf(a6)	; Check if there's anything left to do, looping around if there is
	bne	.loop
	lea 	md_buffer(pc),a5
	move.l	a5,head(a6)		; Nothing left: reset buffer
	move.l	a5,tail(a6)
.return:
	movem.l	(a7)+,d1-d4/a5

.returnx:

	tst.b	wake(a6)		; written something
	beq	.retm
	tst.l	rsel(a6)		; Wake up a listener, if applicable
	beq	.retm			; HR: jump to movem

	move.l	kerinfo(a6),a0
	move.l	96(a0),a0		; a0 = v:wakeselect

	movem.l	d1-d2/a2,-(a7)
	move.l	rsel(a6),-(a7)
	jsr	(a0)
	addq.w	#4,a7
	movem.l	(a7)+,d1-d2/a2

	clr.l	rsel(a6)
	sf	wake(a6)

.retm:
	movem.l	(a7)+,d0/a6
	rts


** An Entire Button Packet Hath Been Prothethed, Mathter ******************
** HR: :-) I can withtle too!

* This routine will send mouse packets to XaAES. It uses a generic write
* routine that can be used by other Moose sub-systems.

.do_button_packet:
	move.l	a0,-(a7)
* Create a buffer on the stack big enough for the button report and
* fill that buffer

* HR: a little bit faster

	lea	-MOOSE_LEN(a7),a7
	move.l	a7,a0

	move.w	# MOOSE_LEN,(a0)+
	move.w	# MOOSE_BUTTON,(a0)+
	move.w	click_x(a6),(a0)+
	move.w	click_y(a6),(a0)+
	move.w	click_state(a6),(a0)+
	move.w	click_count(a6),(a0)+

* Write it
	move.l	a7,a0
	bsr	gen_write

* Tidy the stack

	lea	MOOSE_LEN(a7),a7	

* Clear the timeout value to signify that we're ready to start building
* another report

	clr.w	timeout(a6)

	move.l	(a7)+,a0
	rts

* HR
* This routine will send wheel packets to XaAES. It uses a generic write
* routine that can be used by other Moose sub-systems.

.if have_wheels
.do_wheel_packet:
	move.l	a0,-(a7)
	lea	-MOOSE_LEN(a7),a7
	move.l	a7,a0

	move.w	# MOOSE_LEN,(a0)+		; OK
	move.w	# MOOSE_WHEEL,(a0)+
	move.w	sample_x(a6),(a0)+
	move.w	sample_y(a6),(a0)+
	moveq	#0,d0
	move.b	WHL_PAK_WHEEL(a5),d0
	move.w	d0,(a0)+
	move.w	WHL_PAK_CLICKS(a5),(a0)+

	move.l	a7,a0
	bsr	gen_write

	lea	MOOSE_LEN(a7),a7	
	move.l	(a7)+,a0
	rts
.endif

* HR
* This routine will send movement packets to XaAES. It uses a generic write
* routine that can be used by other Moose sub-systems.

.do_move_packet:
	move.l	a0,-(a7)
	lea	-MOOSE_LEN(a7),a7
	move.l	a7,a0

	move.w	# MOOSE_LEN,(a0)+		; OK
	move.w	# MOOSE_MOVEMENT,(a0)+
	move.w	sample_x(a6),d0
	move.w	d0,(a0)+
	move.w	d0,old_x(a6)
	move.w	sample_y(a6),d0
	move.w	d0,(a0)+
	move.w	d0,old_y(a6)

* HR: I am not yet sure about this.
*     If this is the last state detected, it should be OK.
	move.w	click_state(a6),(a0)+

	clr.w	(a0)+

	move.l	a7,a0
	bsr	gen_write

	lea	MOOSE_LEN(a7),a7	
	move.l	(a7)+,a0
	rts
