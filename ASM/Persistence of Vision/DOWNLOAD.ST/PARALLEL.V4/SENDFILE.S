**********************************************************************
* Widget Download system - ST transmit                               *
**********************************************************************

	OPT	c+			;Case sensitive.


VER_MAJOR	equ	4
VER_MINOR	equ	0

STACK_SIZE	equ	1024

PSG_SELECT	equ	$ffff8800
PSG_READ	equ	$ffff8800
PSG_WRITE	equ	$ffff8802

GPIP		equ	$fffffa01


	SECTION	TEXT

DL_Start
	lea	DL_Stack(pc),sp

	clr.l	-(sp)			Go to supervisor mode.
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)

	lea	DL_Start-128(pc),a0	;Get the filename from
	moveq	#0,d0			;the command line.
	move.b	(a0)+,d0
	clr.b	(a0,d0.w)
	move.l	d0,name_len
	move.l	a0,name_ptr

	bsr	open_file		;Open the file.

	tst.w	handle			;Is the file handle valid?
	bpl.s	.no_error

	lea	error_str(pc),a0
	bsr	show_str

	bsr	wait_for_key
	bra.s	exit
.no_error

	move.w	sr,-(sp)
	move.w	#$2700,sr

	bsr	DL_Set_Up_Link		Set up download link.

	move.b	#$81,d0			;Send 'wake-up' byte.
	bsr	SendByte

	move.l	#"FILE",d0		;This is a file transfer.
	bsr	SendLong


	move.l	name_len,d0		;Send filename length.
	bsr	SendLong

	move.l	name_ptr,a6		;Send filename.
	move.l	name_len,d6
	bsr	download


	bsr	get_file_size		;Get the size of the file.

	move.l	file_size,d0		;Send file size.
	bsr	SendLong

	move.l	file_size,d5
	beq.s	.zero_len
.chunks
	move.l	d5,d6
	cmp.l	#16384,d6
	bls.s	.no_clip
	move.l	#16384,d6
.no_clip
	sub.l	d6,d5

	bsr	read_file

	lea	file_buffer(pc),a6
	bsr	download

	tst.l	d5
	bne.s	.chunks

.zero_len
	moveq	#0,d0			;Send zero end byte.
	bsr	SendByte

	move.w	(sp)+,sr

	bsr	close_file		;Close the file.

exit
	move.w	#32,-(sp)		;User mode.
	trap	#1
	addq	#6,sp


	clr.w	-(sp)			Exit prog.
	trap	#1


download
	move.b	(a6)+,d0
	bsr	SendByte

	subq.l	#1,d6
	bne.s	download
	rts


show_str
	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts


wait_for_key
	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp
	rts


open_file
	clr.w	-(sp)
	pea	(a0)
	move.w	#61,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,handle
	rts


read_file
	pea	file_buffer(pc)
	move.l	d6,-(sp)
	move.w	handle,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	rts


close_file
	move.w	handle,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq	#4,sp
	rts


get_file_size
	move.w	#2,-(sp)
	move.w	handle,-(sp)
	clr.l	-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	move.l	d0,file_size

	clr.w	-(sp)
	move.w	handle,-(sp)
	clr.l	-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	rts


****************************************************************
* Set up download link.

DL_Set_Up_Link
	lea	(PSG_SELECT).w,a5	PSG registers.
	lea	(PSG_WRITE).w,a4
	lea	(GPIP).w,a3

	move.b	#7,(a5) 		Set port B for output.
	move.b	#%11111111,(a4)

	move.b	#14,(a5)
	move.b	#%00100110,(a4)
	rts



****************************************************************
* Send byte.
* Enter:
*	D0.B: Byte to be sent.

SendByte
	move.b	#15,(a5)		;Set port to byte.
	move.b	d0,(a4)

	move.b	#14,(a5)		;Signal that a byte is ready.
	move.b	#%00000110,(a4)

.wait1
	btst.b	#0,(a3)			;Wait for byte read signal.
	bne.s	.wait1

	move.b	#%00100110,(a4)		;Signal that byte is not ready.

.wait2
	btst.b	#0,(a3)			;Wait for done signal.
	beq.s	.wait2
	rts


****************************************************************
* Send long-word.
* Enter:
*	D0.L: Long-word to be sent.

SendLong
	rol.l	#8,d0
	bsr	SendByte
	rol.l	#8,d0
	bsr	SendByte
	rol.l	#8,d0
	bsr	SendByte
	rol.l	#8,d0
	bsr	SendByte
	rts



****************************************************************
* Enable/Disable IKBD data sending.

DL_En_IKBD
	pea	DL_En_IKBD_Str(pc)
	bra.s	DL_Write_IKBD

DL_Dis_IKBD
	pea	DL_Dis_IKBD_Str(pc)

DL_Write_IKBD
	clr.w	-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts



****************************************************************

DL_En_IKBD_Str	dc.b	$11		Enable IKBD output.
DL_Dis_IKBD_Str dc.b	$13		Disable IKBD output.


	SECTION	DATA

error_str	dc.b	"Cannot open file!",13,10,0

	even


	SECTION	BSS

handle		ds.w	1
name_ptr	ds.l	1
name_len	ds.l	1
file_size	ds.l	1

file_buffer	ds.b	16384

	ds.b	STACK_SIZE
DL_Stack
