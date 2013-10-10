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

	lea	(PSG_SELECT).w,a5
	lea	(PSG_WRITE).w,a4
	lea	(GPIP).w,a3

	move.b	#7,(a5)			;Select mixer I/O control.
	move.b	#%11111111,(a4)		;Set port B to output.

	moveq	#0,d1
.loop
	move.b	#15,(a5)		;Select I/O port B.
	move.b	d0,(a4)

	move.b	#14,(a5)
	move.b	(a4),d2
	and.b	#%11011111,d2
	or.b	#2,d2
	or.b	d1,d2
	move.b	d2,(a4)

	move.w	d0,-(sp)
	move.w	d1,-(sp)
	bsr	show_hex

	moveq	#13,d0
	bsr	show_char
	moveq	#10,d0
	bsr	show_char

	move.w	(sp)+,d1
	move.w	(sp)+,d0
	addq.b	#1,d0
	eor.b	#%00100000,d1

	bra	.loop

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


show_char
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts


show_hex
	ror.w	#8,d0
	moveq	#2-1,d1
.loop
	rol.w	#4,d0
	move.w	d0,-(sp)

	and.w	#$000f,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	ble.s	.decimal
	add.b	#('A'-'9'-1),d0
.decimal
	bsr	show_char

	move.w	(sp)+,d0
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
