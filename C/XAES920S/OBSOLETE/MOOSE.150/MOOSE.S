*** Moose XDD Device Driver ***********************************************

** Preliminaries **********************************************************

	OUTPUT	moose.xdd

;	OPT	P=68000,AUTOPC,NODEBUG
	OPT	P=68000,NODEBUG,CHKIMM


* Include all the structures and definitions

	INCLUDE	moose.i


*** Internal Structures **************************************************

* Internally, the Moose holds a buffer of interesting things called
* 'md_buffer'. For example, if the mouse buttons change states, that is
* put in the md_buffer because it's interesting :).

* Other interesting IKBD level things could end up in the md_buffer too
* (visions of the back bone of a screen saver system >:)


** Mouse Button Packet Structure *****************************************

* This is the structure of a mouse button packet on the moose device.

* This is the ID that states that mouse button data is in the moose buffer:

BUT_PAK		equ	'B'


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


* MOUSE_DATA structure working variables

click_x		rs.w	1
click_y		rs.w	1
click_state	rs.w	1
click_count	rs.w	1


* Moose handler's variables:

timeout		rs.w	1
dc_time		rs.w	1
last_state	rs.w	1
last_time	rs.w	1


** IKBD Handler Variables *************************************************

* Used to store the last button state:

old_buttons	rs.w	1


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


* Offset to the write end of the moose buffer:

wptr		rs.w	1


* Number of bytes used in the moose buffer:

mused		rs.w	1


variable_length		rs.l	0


*** Initialisation ********************************************************

* long main(KERINFO *kerinfo)

main	movem.l	d2-7/a2-6,-(a7)

** Get the pointer to the line-a variables (so we can get mouse x,y data)

	dc.w	$a000

	lea	variables(pc),a6

	move.l	a0,linea(a6)


** Store the pointer to the KERINFO structure


	move.l	48(a7),a2			a2 = v:kerinfo

	move.l	a2,kerinfo(a6)


** Clear the double click time to prevent mouse button reporting

	clr.w	dc_time(a6)

	clr.w	moose_inuse(a6)			Start off being dormant


** Say hello to the world

	move.l	12(a2),a3			a3 = v:dos_tab

	pea	hello(pc)
	move.l	9*4(a3),a0
	jsr	(a0)				Print


** Install the u:\dev\moose device

	pea	dinfo(pc)
	pea	devname(pc)
	move.w	#$de02,-(a7)			DEV_INSTALL
	movea.l	$130*4(a3),a0
	jsr	(a0)				dcntl
	lea	14(a7),a7			(Tidy the print as well)

	tst.l	d0				On error: print message
	beq.s	.failed				and return


** Return entry points are '.success and '.failed'

.success
	pea	success_message(pc)
	movea.l	9*4(a3),a0
	jsr	(a0)				print "it worked!!"

	moveq	#1,d0				return(1) (success)
	bra.s	.return

.failed	pea	failed_message(pc)
	move.l	9*4(a3),a0
	jsr	(a0)				print "aaaarrghh!!"

	moveq	#0,d0				return(0) (failed)

.return	addq.w	#4,a7				(Tidy the print)
	movem.l	(a7)+,d2-7/a2-6
	rts


*** DATA Section **********************************************************

	SECTION DATA

* The device name:

devname	dc.b	'u:\dev\moose',0


* Start-up messages:

hello	dc.b	13,10
	dc.b	'M³³se device driver',13,10
	dc.b	'version 1.5.0',13,10
	dc.b	'by James Cox, Diffs by Craig Graham and Johan Klockars',13,10,10,0

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


* Moose device's buffer:

md_buffer	ds.b	MD_BUFFER_SIZE


* Moose buffer: (read by a client application - XaAES)

moose_buffer	ds.b	MD_BUFFER_SIZE


*** Includes **************************************************************

	INCLUDE	devdrv.s

	INCLUDE	command.s

	INCLUDE	ikbd.s

	INCLUDE	timer.s


***************************************************************************
