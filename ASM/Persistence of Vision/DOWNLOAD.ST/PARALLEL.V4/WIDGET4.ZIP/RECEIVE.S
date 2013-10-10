**********************************************************************
* Widget Download system - ST receiver                               *
**********************************************************************

	OPT	c+			; Case sensitive.


VER_MAJOR	equ	4
VER_MINOR	equ	0

STACK_SIZE	equ	1024

PSG_SELECT	equ	$ffff8800
PSG_READ	equ	$ffff8800
PSG_WRITE	equ	$ffff8802
GPIP		equ	$fffffa01


	SECTION	TEXT

Start
	clr.l	-(sp)			; Supervisor mode.
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,stack_save

Restart
	move.w	#$2700,sr

	lea	Stack(pc),sp

	lea	Trap0_Handler(pc),a0
	move.l	a0,$80.w

	lea	title_str(pc),a0	; Show the title.
	bsr	show_str

	lea	workspace_str(pc),a0	; Show the workspace.
	bsr	show_str
	move.l	#Stack,d0
	bsr	show_long
	moveq	#'-',d0
	bsr	show_char
	move.l	$42e.l,d0
	bsr	show_long

	moveq	#13,d0
	bsr	show_char
	moveq	#10,d0
	bsr	show_char
	moveq	#10,d0
	bsr	show_char

	lea	(PSG_SELECT).w,a5
	lea	(PSG_WRITE).w,a4
	lea	(GPIP).w,a3

	move.b	#7,(a5)			;Select mixer I/O control.
	move.b	#%01111111,(a4)		;Set port B to input.

	move.b	#14,(a5)		;Select Port A.
	move.b	#%00100110,(a4)

.wake_up
	cmp.b	#$01,$fffffc02.w	;Escape key?
	beq	exit

	move.b	#15,(a5)		;Select I/O port B.
	cmp.b	#$81,(a5)		;Read port B.
	bne.s	.wake_up

	bsr	GetByte


	bsr	GetLong			;Get type of transfer.
	cmp.l	#"FILE",d0
	beq	get_file
	cmp.l	#"DATA",d0
	beq	get_data

	bra	Restart

exit
	move.w	#$2300,sr

	move.w	#7,-(sp)		; Wait for a key.
	trap	#1
	addq	#2,sp

	move.l	stack_save,-(sp)	; User mode.
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)
	trap	#1


get_data				; Do a transfer to memory.
	bsr	GetLong			; Get header info.
	move.l	d0,Address
	bsr	GetLong
	move.l	d0,Length
	bsr	GetLong
	move.l	d0,Execute

	lea	address_str(pc),a0	; Show the start address.
	bsr	show_str
	move.l	Address,d0
	bsr	show_long

	lea	length_str(pc),a0	; Show the length.
	bsr	show_str
	move.l	Length,d0
	bsr	show_long

	lea	execute_str(pc),a0	; Show the execute address.
	bsr	show_str
	move.l	Execute,d0
	bsr	show_long

	move.l	Address,a6		; Get the data.
	move.l	Length,d6
	bsr	download

	bsr	GetByte			; Get zero end byte.

	move.l	Execute,d0		; Execute the code, if needed.
	beq	Restart

	move.l	d0,a0
	jsr	(a0)

	bra	Restart			; If just data transfer,
					; wait for the next transfer.


get_file				; Do a transfer to file.
	lea	file_str(pc),a0
	bsr	show_str

	bsr	GetLong			; Get header info.
	move.l	d0,d6
	lea	filename,a6
	clr.b	(a6,d6.w)
	bsr	download		; Get the file name.

	lea	filename(pc),a0		; Show the file name.
	bsr	show_str

	bsr	GetLong			; Get the file size.
	move.l	d0,d7

	lea	file_size(pc),a0	; Show the file size.
	bsr	show_str

	move.l	d7,d0
	bsr	show_long

	bsr	create_file

	move.l	d7,d5			; Download the file in
.chunks					; small chunks so we can
	lea	file_buffer,a6		; get files larger than
	move.l	d5,d6			; available memory.
	cmp.l	#16384,d6
	bls.s	.no_clip
	move.l	#16384,d6
.no_clip
	sub.l	d6,d5
	move.l	d6,d7
	bsr	download		; Get a chunk of data.

	move.l	d7,d6			; Write it to disk.
	bsr	write_file

	tst.l	d5
	bne.s	.chunks

	bsr	GetByte			; Get zero end byte.

	bsr	close_file

	bra	Restart


create_file
	clr.w	-(sp)
	pea	filename(pc)
	move.w	#60,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,handle
	rts


write_file
	pea	file_buffer(pc)
	move.l	d6,-(sp)
	move.w	handle,-(sp)
	move.w	#64,-(sp)
	trap	#1
	lea	12(sp),sp
	rts


close_file
	move.w	handle,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq	#4,sp
	rts


download
	bsr	GetByte
	move.b	d0,(a6)+

	subq.l	#1,d6
	bne.s	download
	rts


Trap0_Handler
	move.b	#15,(PSG_SELECT).w
	cmp.b	#$81,(PSG_READ).w
	beq	Restart
	rte


GetByte
	btst.b	#0,(a3)			; Wait for byte read signal.
	bne.s	GetByte

	move.b	#15,(a5)		; Get the byte.
	move.b	(a5),d0

	move.b	#14,(a5)		; Signal that we've got the byte.
	move.b	#%00000110,(a4)

.wait2
	btst.b	#0,(a3)			; Wait for byte not ready signal.
	beq.s	.wait2

	move.b	#%00100110,(a4)		; Signal that we're done.
	rts


GetLong
	bsr	GetByte
	move.b	d0,d3
	bsr	GetByte
	lsl.l	#8,d3
	move.b	d0,d3
	bsr	GetByte
	lsl.l	#8,d3
	move.b	d0,d3
	bsr	GetByte
	lsl.l	#8,d3
	move.b	d0,d3
	move.l	d3,d0
	rts


show_str
	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts


show_char
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts


show_long
	move.l	d0,-(sp)
	moveq	#'$',d0
	bsr	show_char
	move.l	(sp)+,d0

	moveq	#8-1,d1
.loop
	rol.l	#4,d0
	move.l	d0,-(sp)

	and.w	#$000f,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	ble.s	.decimal
	add.b	#('A'-'9'-1),d0
.decimal
	bsr	show_char

	move.l	(sp)+,d0
	dbf	d1,.loop
	rts


	SECTION	DATA

title_str
	dc.b	27,'E'
	dc.b	'WIDGET DOWNLOADER',13,10

	dc.b	'VERSION '
	dc.b	VER_MAJOR+'0'
	dc.b	'.'
	dc.b	(VER_MINOR/10)+'0'
	dc.b	(VER_MINOR-(VER_MINOR/10))+'0'
	dc.b	13,10

	dc.b	'(C) 1992-1995',13,10
	dc.b	'LEO SKIRENKO',13,10
	dc.b	'PHILIP WATTS',13,10
	dc.b	0

workspace_str
	dc.b	10,'WORKSPACE = '
	dc.b	0
	even

address_str	dc.b	13,10,"Address: ",0
length_str	dc.b	13,10,"Length:  ",0
execute_str	dc.b	13,10,"Execute: ",0

file_str	dc.b	13,10,"File:   ",0
file_size	dc.b	13,10,"Length: ",0

	even


	SECTION	BSS

Address		ds.l	1
Length		ds.l	1
Execute		ds.l	1

handle		ds.w	1
filename	ds.b	80
file_buffer	ds.b	16384

stack_save	ds.l	1

	ds.b	STACK_SIZE
Stack
