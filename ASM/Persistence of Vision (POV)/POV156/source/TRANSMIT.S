**********************************************************************
* Widget Download system - ST transmit (Version 3.00)                *
**********************************************************************

	OPT	c+			; Case sensitive.


WAKEUP_DELAY	equ	100000
NORMAL_DELAY	equ	34		;32=Falcon 030 @ 16Mhz
					; 2=ST @ 8Mhz
INFO_DELAY	equ	100


DL_Counter	equr	d7


DL_Start
	lea	DL_Stack(pc),sp
	bsr	DL_Dis_IKBD		Disable IKBD data sending.

	clr.l	-(sp)			Go to supervisor mode.
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)

	move.w	sr,-(sp)
	move.w	#$2700,sr		Disable interrupts.

	bsr	DL_Set_Up_Link		Set up download link.

* Send download header.

	move.l	#WAKEUP_DELAY,d0
	bsr	SetDelay
	move.b	#$81,d0
	bsr	SetPort

	move.l	#INFO_DELAY,d0
	bsr	SetDelay
	move.l	#Code_Start,d0		Send Load address.
	bsr	SendLong
	move.l	#Code_Length,d0 	Send code length.
	bsr	SendLong
	move.l	#Exec_Addr,d0		Send Execution address.
	bsr	SendLong

	move.l	#WAKEUP_DELAY,d0
	bsr	SetDelay
	bsr	DoDelay

* Download code.
	move.l	#NORMAL_DELAY,d0
	bsr	SetDelay

	lea	DL_Code_Start(pc),a0
	move.l	#Code_Length,d6
DL_Loop
	move.b	(a0)+,d0
	bsr	SendByte

	subq.l	#1,d6
	bne.s	DL_Loop


* Download complete.

	moveq	#0,d0
	bsr	SetPort

	move.w	(sp)+,sr

	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	DL_En_IKBD		Enable IKBD data sending.

	clr.w	-(sp)			Exit prog.
	trap	#1



****************************************************************
* Set up download link.

DL_Set_Up_Link
	lea	$ffff8800.w,a5		PSG registers.
	lea	2(a5),a4

	move.b	#7,(a5) 		Set port B for output.
	move.b	#%11111111,(a4)

	move.b	#15,(a5)
	clr.b	DL_Counter
	rts



****************************************************************
* Send byte.
* Enter:
*	D0.B: Byte to be sent.

SendByte
	move.b	d0,d2
	and.b	#$f0,d0
	or.b	DL_Counter,d0
	bsr	SetPort

	addq.b	#1,DL_Counter
	and.b	#15,DL_Counter

	move.b	d2,d0
	lsl.b	#4,d0
	or.b	DL_Counter,d0
	bsr	SetPort

	addq.b	#1,DL_Counter
	and.b	#15,DL_Counter
	rts


SetPort
	move.b	d0,(a4)

DoDelay
	move.l	Delay,d1
.loop
	subq.l	#1,d1
	bne.s	.loop
	rts


SetDelay
	move.l	d0,Delay
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

Delay		ds.l	1

DL_En_IKBD_Str	dc.b	$11		Enable IKBD output.
DL_Dis_IKBD_Str dc.b	$13		Disable IKBD output.


		ds.l	1024
DL_Stack



****************************************************************
* All code following DL_Code_Start will be downloaded.

DL_Code_Start
