****************************************************************
* Download system - ST transmitter V1.00

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

	move.l	#'SX01',d0		Send I.D.
	bsr	DL_Send_Long
	move.l	#Code_Start,d0		Send Load address.
	bsr	DL_Send_Long
	move.l	#Code_Length,d0		Send code length.
	bsr	DL_Send_Long
	move.l	#Exec_Addr,d0		Send Execution address.
	bsr	DL_Send_Long

* Download code.

	lea	DL_Code_Start(pc),a0
	move.l	#Code_Length,d0
	move.l	#256,d1

DL_Loop_2
	sub.l	d1,d0
	bls.s	DL_Download_Last

	move.w	d1,d2
	subq.w	#1,d2

	swap	d7
	move.b	(a0)+,d7		Get byte to download.
	swap	d7

DL_Loop_1
	movep.l	d7,0(a5)		Output byte and set STROBE high.
	swap	d7
	move.b	(a0)+,d7		Get byte to download.
	swap	d7
;	nop
;	nop
	nop
	move.b	d6,(a4)			Set STROBE low.
	dbra	d2,DL_Loop_1

	subq.l	#1,a0
	bra.s	DL_Loop_2

DL_Download_Last
	add.w	d1,d0
	subq.w	#1,d0

	swap	d7
	move.b	(a0)+,d7		Get byte to download.
	swap	d7
DL_Loop_3
	movep.l	d7,0(a5)		Output byte and set STROBE high.
	swap	d7
	move.b	(a0)+,d7		Get byte to download.
	swap	d7
;	nop
;	nop
	nop
	move.b	d6,(a4)			Set STROBE low.
	dbra	d0,DL_Loop_3

* Download complete.

	move.w	(sp)+,sr

	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr.s	DL_En_IKBD		Enable IKBD data sending.

	clr.w	-(sp)			Exit prog.
	trap	#1



****************************************************************
* Set up download link.

DL_Set_Up_Link
	lea	$ffff8800.w,a5		PSG registers.
	lea	2(a5),a4

	move.b	#7,(a5)			Set Port A and B for output.
	move.b	#%11111111,(a4)

	move.l	#$0f000e00,d7
	move.b	#14,(a5)		Read Port A for STROBE.
	move.b	(a5),d7
	move.b	d7,d6
	bset	#5,d7			D7: Output byte and STROBE high.
	bclr	#5,d6			D6: STROBE low.
	rts



****************************************************************
* Send byte.
* Enter:
*	D0.B: Byte to be sent.

DL_Send_Byte
	swap	d7
	move.b	d0,d7
	swap	d7
	movep.l	d7,0(a5)		Output byte and set STROBE high.
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a4)			Set STROBE low.
	rts



****************************************************************
* Send long-word.
* Enter:
*	D0.L: Long-word to be sent.

DL_Send_Long
	rol.l	#8,d0
	bsr.s	DL_Send_Byte
	rol.l	#8,d0
	bsr.s	DL_Send_Byte
	rol.l	#8,d0
	bsr.s	DL_Send_Byte
	rol.l	#8,d0
	bsr.s	DL_Send_Byte
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
DL_Dis_IKBD_Str	dc.b	$13		Disable IKBD output.


		ds.l	64		Too much space for stack.
DL_Stack



****************************************************************
* All code following DL_Code_Start will be downloaded.

DL_Code_Start
