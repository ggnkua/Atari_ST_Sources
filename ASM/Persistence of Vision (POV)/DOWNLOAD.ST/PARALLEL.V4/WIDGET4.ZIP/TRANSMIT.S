**********************************************************************
* Widget Download system - ST transmit                               *
**********************************************************************

	OPT	c+			; Case sensitive.


VER_MAJOR	equ	4
VER_MINOR	equ	0

STACK_SIZE	equ	1024

PSG_SELECT	equ	$ffff8800
PSG_READ	equ	$ffff8800
PSG_WRITE	equ	$ffff8802

GPIP		equ	$fffffa01


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

	move.b	#$81,d0			;Send 'wake-up' byte.
	bsr	SendByte

	move.l	#"DATA",d0		;This is a memory transfer.
	bsr	SendLong

	move.l	#Code_Start,d0		Send Load address.
	bsr	SendLong
	move.l	#Code_Length,d0 	Send code length.
	bsr	SendLong
	move.l	#Exec_Addr,d0		Send Execution address.
	bsr	SendLong

* Download code.
	lea	DL_Code_Start(pc),a0
	move.l	#Code_Length,d6
DL_Loop
	move.b	(a0)+,d0
	bsr	SendByte

	subq.l	#1,d6
	bne.s	DL_Loop


* Download complete.

	moveq	#0,d0			;Send zero end byte.
	bsr	SendByte

	move.w	(sp)+,sr

	move.w	#32,-(sp)		;User mode.
	trap	#1
	addq.l	#6,sp

	bsr	DL_En_IKBD		Enable IKBD data sending.

	clr.w	-(sp)			Exit prog.
	trap	#1



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


		ds.b	STACK_SIZE
DL_Stack



****************************************************************
* All code following DL_Code_Start will be downloaded.

DL_Code_Start
