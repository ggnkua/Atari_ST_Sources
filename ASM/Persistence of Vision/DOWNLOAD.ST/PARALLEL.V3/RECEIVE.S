**********************************************************************
* Widget Download system - ST receiver                               *
**********************************************************************

	OPT	c+			; Case sensitive.


VER_MAJOR	equ	3
VER_MINOR	equ	0

STACK_SIZE	equ	1024

PSG		equ	$ffff8800


Counter		equr	d7
Previous	equr	d5
CountMask	equr	d4


	SECTION	TEXT

Start
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,stack_save

	clr.w	$ffff8240.w
	move.w	#$fff,$ffff825e.w
Restart
	move.w	#$2700,sr

	lea	Stack(pc),sp

	lea	Trap0_Handler(pc),a0
	move.l	a0,$80.w

	lea	title_str(pc),a0
	bsr	show_str

	lea	workspace_str(pc),a0
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

	lea	(PSG).w,a4
	lea	2(a4),a5

	move.b	#7,(a4)			;Select mixer I/O control.
	move.b	#%01111111,(a5)		;Set port B to input.

	moveq	#0,Counter
	moveq	#%00001111,CountMask
	move.b	#15,(a4)		;Select I/O port B.

.wake_up
	cmp.b	#$01,$fffffc02.w	;Escape key?
	beq	exit

	move.b	(a4),d0			;Read port B.
	cmp.b	#$81,d0
	bne.s	.wake_up
	move.b	d0,Previous


	bsr	GetLong
	move.l	d0,Address
	bsr	GetLong
	move.l	d0,Length
	bsr	GetLong
	move.l	d0,Execute


	lea	address_str(pc),a0
	bsr	show_str
	move.l	Address,d0
	bsr	show_long

	lea	length_str(pc),a0
	bsr	show_str
	move.l	Length,d0
	bsr	show_long

	lea	execute_str(pc),a0
	bsr	show_str
	move.l	Execute,d0
	bsr	show_long


	move.l	Address,a6
	move.l	Length,d6
.loop
	bsr	GetByte
	move.b	d0,(a6)+
	eor.w	d0,$ffff8240.w
	eor.w	#$007,$ffff8240.w
	subq.l	#1,d6
	bne.s	.loop

	move.l	Execute,d0
	beq	Restart

	move.l	d0,a0
	jsr	(a0)

	bra	Restart

exit
	move.w	#$2300,sr

	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp

	move.l	stack_save,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)
	trap	#1


Trap0_Handler
	move.b	#15,(PSG).w		;Select port B.
	cmp.b	#$81,(PSG).w
	beq	Restart
	rte


Error
	lea	error_str(pc),a0
	bsr	show_str

	lea	Stack(pc),sp
	bra	exit


ReadPort
	cmp.b	(a4),Previous		;Read port B.
	beq.s	ReadPort

	move.b	(a4),d1			;Not all the pins get set at
					;exactly the same time, so we
					;need to read the port again!
	move.b	d1,Previous

	move.b	d1,d2
	and.b	CountMask,d2
	cmp.b	Counter,d2
	bne	Error
	addq.b	#1,Counter
	and.b	CountMask,Counter
	rts


GetByte
	bsr.s	ReadPort
	and.b	#$f0,d1
	move.b	d1,d0

	bsr.s	ReadPort
	lsr.b	#4,d1
	or.b	d1,d0
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

error_str
	dc.b	13,10,10
	dc.b	"Error: Data out of sync!"
	dc.b	13,10,0
	even


	SECTION	BSS

Address		ds.l	1
Length		ds.l	1
Execute		ds.l	1

stack_save	ds.l	1

	ds.b	STACK_SIZE
Stack
