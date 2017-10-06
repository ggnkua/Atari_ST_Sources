*** Moose Server **********************************************************

	OUTPUT	D:\XAAES\MOOSE\143\MOUSESRV.TOS

	OPT	P=68000,AUTOPC,CHKIMM,NODEBUG


* The moose data buffer size must be an even number of bytes long:

MD_BUFFER_SIZE	equ	16*64


*** Variable Block Equates ************************************************

		rsreset

* the XaAES moose data pipe file handle

moose_cmd_pipe_handle	rs.w	1


* The file handle of a read only file opened to moose:

moose_fh		rs.w	1


* The fselect version of the moose_fh:

moose_read_desc		rs.l	1


variables_length	rs.l	0


*** Moose Initialise Command Structure ************************************

* This structure represents the INIT_COM command which must be sent to
* the moose device in order to activate it.

INIT_COM		equ	'MI'

		rsreset
		rs.w	1
INIT_COM_IKBD		rs.l	1

INIT_COM_LEN		rs.l	0


** Moose Double Click Time Structure **************************************

* This structure represents an 'alter double click time' packet.

* DCLK_COM_TIME is the number of 200hz clicks for the double click time.
* As an indication, the default dc_time is 40 (0.2 seconds).

DCLK_COM		equ	'MD'

		rsreset
		rs.w	1	prefix
DCLK_COM_TIME		rs.w	1

DCLK_COM_LEN		rs.l	0


*** Initialisation ********************************************************

	SECTION TEXT

init

* setup up our variables register (a6), get our basepage address and
* set our stack up

	lea	variables(pc),a6
	move.l	4(a7),a5	a5=v:our basepage
	lea	stack(pc),a7


* shrink our memory space

	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$100,d0	d0.l = our length in bytes

	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.l	#$4a0000,-(a7)
	trap	#1	shrink our memory block
	lea	12(a7),a7


* set all of the signals to SIG_IGN (1)

	move.l	#1,a3
	moveq	#0,d3

	moveq	#31,d4

.loop	bsr	.install
	addq.w	#1,d3
	dbra	d4,.loop


* install the special cases: SIGPIPE and SIGTERM

	lea	sigterm(pc),a3
	moveq	#13,d3	SIGPIPE
	bsr	.install

	lea	sigterm(pc),a3
	moveq	#15,d3	SIGTERM
	bsr	.install

	bra	.sig_cont

* local procedure to do the dirty work

.install	move.l	a3,-(a7)
	move.w	d3,-(a7)
	move.w	#$112,-(a7)
	trap	#1
	addq.w	#8,a7
	rts
.sig_cont

* print a nice hello message :)

	pea	startup_message(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7


* open the moose.XA pipe for writing only

	move.w	#1,-(a7)
	pea	moose_cmd_pipe(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	tst.l	d0
	blt	no_moose_pipe
	move.w	d0,moose_cmd_pipe_handle(a6)


* open a read/write handle to the moose device

	move.w	#2,-(a7)
	pea	moose_devname(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.w	#8,a7


* store the file handle

	move.w	d0,moose_fh(a6)


* on error, quit

	tst.l	d0
	blt	no_moose_device


* setup the moose_read_desc variable

	moveq	#0,d1
	bset	d0,d1
	move.l	d1,moose_read_desc(a6)


* send the activation command to moose

	move.w	#$22,-(a7)	get v:IKBD table
	trap	#14
	addq.w	#2,a7

	lea	moose_buffer(pc),a0
	move.w	#INIT_COM,(a0)
	move.l	d0,INIT_COM_IKBD(a0)

	move.l	a0,-(a7)
	move.l	#INIT_COM_LEN,-(a7)
	move.w	moose_fh(a6),-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7

* on error, quit

	tst.l	d0
	ble	no_moose_device


* set the double click value to something sensible (0.2 seconds)
* which will also allow Moose to send button reports

	move.w	#DCLK_COM,(a0)
	move.w	#40,DCLK_COM_TIME(a0)
	
	move.l	a0,-(a7)
	move.l	#DCLK_COM_LEN,-(a7)
	move.w	moose_fh(a6),-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7

* on error, quit

	tst.l	d0
	ble	no_moose_device


*** Main Loop *************************************************************	

	lea	fselect_desc(pc),a5

main_loop

** use Fselect to monitor all the read descriptors we want to listen to

	move.l	moose_read_desc(a6),(a5)

* do the Fselect

	clr.l	-(a7)
	clr.l	-(a7)
	move.l	a5,-(a7)
	move.l	#$11d0000,-(a7)
	trap	#1
	lea	16(a7),a7

* read a buffers worth of moose data

	move.l	a5,-(a7)
	move.l	#MD_BUFFER_SIZE,-(a7)
	move.w	moose_fh(a6),-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7	

	pea	but_message(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

* strip out prefix's (this routine works only because we know that an
* XaAES version that stiff uses MOUSESRV doesn't request rectangle events :)

	move.l	a5,a4
	move.l	a5,a3
	move.l	d0,d4
	lsr.l	#1,d4
	subq.w	#1,d4
	blt	.whats_happening
	moveq	#0,d0
.loop	addq.w	#2,a3
	move.l	(a3)+,(a4)+
	move.l	(a3)+,(a4)+
	addq.l	#8,d0
	dbra	d4,.loop


* write the data out to XaAES

	move.l	a5,-(a7)
	move.l	d0,-(a7)
	move.w	moose_cmd_pipe_handle(a6),-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7

.whats_happening
	bra	main_loop


*** Quit *********************************************************** A6 ***
	
** the error handling - setup d7 to be the exit code

no_moose_pipe	moveq	#-1,d7
	pea	no_moose_pipe_message(pc)
	bra	print_quit

no_moose_device	moveq	#-2,d7
	pea	no_moose_device_message(pc)
	bra	print_quit

broken_moose	moveq	#-3,d7
	pea	broken_moose_message
	bra	print_quit

broken_xaaes	moveq	#-4,d7
	pea	broken_xaaes_message


* print the exit error message

print_quit	move.w	#9,-(a7)	print some message
	trap	#1
	addq.l	#6,a7

	bra.s	shutdown


** clean exit entry point is 'quit'

quit	moveq	#0,d7


* shut down closes files, removes devices etc...

shutdown

* close the channels to XaAES and the moose device

	tst.w	moose_cmd_pipe_handle(a6)
	beq	.done_cmd_pipe

	move.w	moose_cmd_pipe_handle(a6),-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.w	#4,a7
.done_cmd_pipe

	tst.w	moose_fh(a6)
	beq	.done_moose

	move.w	moose_fh(a6),-(a6)
	move.w	#$3e,-(a7)
	trap	#1
	addq.w	#4,a7
.done_moose
	

* d7.w should be our exit code by this point

terminate	move.w	d7,-(a7)
	move.w	#$4c,-(a7)	and die... :)
	trap	#1


*** Signal Handler ********************************************************

sigterm

* use Psigreturn to tidy MiNT's stack up

	move.w	#$11a,-(a7)
	trap	#1
	addq.w	#2,a7

	lea	variables(pc),a6

	bra	quit


*** DATA Section **********************************************************

	SECTION DATA

* the names of the moose command pipe and moose device respectively

moose_cmd_pipe	dc.b	'u:\pipe\mouse.XA',0


* our startup 'hello!' message

startup_message	dc.b	13,10,'  XaAES Moose Server'
	dc.b	13,10,'  version 1.4.3'
	dc.b	13,10,'  by James Cox'
	dc.b	13,10,10,0


* the error messages

no_moose_pipe_message
	dc.b	"moosesrv: can't open mouse.XA",13,10,0

no_moose_device_message
	dc.b	"moosesrv: can't open moose device",13,10,0

broken_moose_message
	dc.b	"moosesrv: moose device read error",13,10,0

broken_xaaes_message
	dc.b	"moosesrv: can't write to XaAES",13,10,0

but_message
	dc.b	"got button fselect",13,10,0	

* filename of the moose device

moose_devname	dc.b	'u:\dev\moose',0


*** BSS Section ***********************************************************

	SECTION BSS
	even

* a stack
	ds.w	4096
stack

* our variables block

variables	ds.b	variables_length


* working space for Fselect()

fselect_desc	ds.l	1


* A buffer to hold data from the moose device:

moose_buffer	ds.b	MD_BUFFER_SIZE


***************************************************************************
