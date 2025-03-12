****************************************************************
* Download system - ST receiver version 1.00


Reloc_Addr	equ	$200



* Set Exec_Type as follows:
*	0 for execution from desktop.
*	1 for execution from auto folder.
*	2 for execution from boot sector.

Exec_Type	equ	2


	ifne	Exec_Type=0
	output	a:\download.prg
	endc

	ifne	Exec_Type=1
	output	a:\auto\download.prg
	endc


PSG		equ	$ffff8800
MFP_GPIP	equ	$fffffa01
MFP_DDR		equ	$fffffa05
Palette0	equ	$ffff8240

floprd		equ	8		XBIOS Read sector.
flopwr		equ	9		XBIOS Write sector.
conws		equ	9		GEMDOS Print string.



****************************************************************
* Place the downloader on a boot sector.

	ifne	Exec_Type=2

Make_Boot_Sector
	move.w	#1,-(sp)			Read 1 sector.
	move.w	#0,-(sp)			Side 1.
	move.w	#0,-(sp)			Track 0.
	move.w	#1,-(sp)			Sector 1.
	move.w	#0,-(sp)			Drive A.
	clr.l	-(sp)
	pea	Boot_Sector_Buffer
	move.w	#floprd,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.w	d0
	bne	Read_Error

	lea	Downloader(pc),a0
	lea	Boot_Sector_Buffer,a1
	move.w	#$601c,(a1)			Place a BRA.S to start
	lea	$1e(a1),a1			of boot code.
	move.w	#512-2-$1e-1,d7
.Loop_1	move.b	(a0)+,(a1)+			Copy boot code into boot
	dbra	d7,.Loop_1			sector.

	lea	Boot_Sector_Buffer,a0		Calculate checksum.
	move.w	#(510/2)-1,d7
	clr.w	d0
.Loop_2	add.w	(a0)+,d0
	dbra	d7,.Loop_2

	move.w	#$1234,d1
	sub.w	d0,d1
	move.w	d1,(a0)				Set checksum.

	move.w	#1,-(sp)			Write 1 sector.
	move.w	#0,-(sp)			Side 1.
	move.w	#0,-(sp)			Track 0.
	move.w	#1,-(sp)			Sector 1.
	move.w	#0,-(sp)			Drive A.
	clr.l	-(sp)
	pea	Boot_Sector_Buffer
	move.w	#flopwr,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.w	d0
	bne	Write_Error

Exit
	clr.w	-(sp)
	trap	#1


Read_Error
	lea	Read_Error_String(pc),a0
	bra.s	Error_Exit

Write_Error
	lea	Write_Error_String(pc),a0

Error_Exit
	pea	(a0)
	move.w	#conws,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	Exit


Boot_Sector_Buffer
	ds.b	512


Read_Error_String
	dc.b	'Unable to read boot sector!',0

Write_Error_String
	dc.b	'Unable to write boot sector!',0

	even

	endc



****************************************************************
* Downloader.

	opt	p+			MUST be relocatable code.

* Regs used:
*	A6: PSG registers.
*	A5: PSG registers.
*	A4: BUSY line port address.
*	A3: Palette 0 register address.
*	D7: Bit number for BUSY line.

Downloader
	ifne	Exec_Type<2
	clr.l	-(sp)				Enter supervisor mode.
	move.w	#$20,-(sp)
	trap	#1
	endc

	move.w	#$2700,sr
	lea	Downloader_1(pc),a0		Relocate downloader.
	lea	Reloc_Addr,a1
	move.w	#Downloader_1_Length-1,d7
.Reloc_Loop
	move.b	(a0)+,(a1)+
	dbra	d7,.Reloc_Loop

	jmp	Reloc_Addr			Execute downloader.



Downloader_1

Re_Entry_Addr
	move.w	#$2700,sr
	lea	R_Stack(pc),sp

	lea	Re_Entry_Addr(pc),a0	Set TRAP #0 for downloader re-entry.
	move.l	a0,$80.w

	lea	PSG.w,a6		A6 and A5 point to PSG registers.
	lea	2(a6),a5

	move.b	#7,(a6)			Set port A for output and port B
	move.b	#%01111111,(a5)		for input.

	move.b	MFP_DDR.w,d0		Set BUSY line for input.
	and.b	#%11111110,d0
	move.b	d0,MFP_DDR.w

	lea	MFP_GPIP.w,a4		A4 holds BUSY line port address.
	moveq	#0,d7			D7 holds bit number for BUSY line.

	lea	Palette0.w,a3

* Enter downloader.

	move.b	#15,(a6)		Select PSG register for port B.
	move.w	#$070,(a3)		Set screen green.

Wait_Header
	bsr	Get_Byte		Wait for 4 byte header.
Bad_Header
	cmp.b	#'S',d0
	bne.s	Wait_Header
	bsr	Get_Byte
	cmp.b	#'X',d0
	bne.s	Bad_Header
	bsr	Get_Byte
	cmp.b	#'0',d0
	bne.s	Bad_Header
	bsr	Get_Byte
	cmp.b	#'1',d0
	bne.s	Bad_Header

* Receive download info.

	bsr	Get_Long_Word		Receive download address.
	move.l	Long_Word(pc),a0
	bsr	Get_Long_Word		Receive download length.
	move.l	Long_Word(pc),d1
	bsr	Get_Long_Word		Receive execution address.
	move.l	Long_Word(pc),a1

* Receive data.

	move.l	#$07400077,d4		Colours.
	move.l	#256,d2			Block length.

Download_Loop_R2
	move.w	d4,(a3)			Change screen colour.
	swap	d4

	sub.l	d2,d1
	bls.s	Receive_Last

	move.w	d2,d3
	subq.w	#1,d3
Download_Loop_R1
	btst	d7,(a4)			Wait for BUSY line to go high.
	beq.s	Download_Loop_R1
	move.b	(a6),(a0)+		Get byte from printer port.
	dbra	d3,Download_Loop_R1

	bra.s	Download_Loop_R2

Receive_Last
	add.l	d2,d1
	subq.w	#1,d1
Download_Loop_R3
	btst	d7,(a4)			Wait for BUSY line to go high.
	beq.s	Download_Loop_R3
	move.b	(a6),(a0)+		Get byte from printer port.
	dbra	d1,Download_Loop_R3

* Downloading complete.

	move.w	#$070,(a3)		Set screen green.

	jmp	(a1)			Execute code.



* Receive a byte into D0.

Get_Byte
	btst	d7,(a4)			Wait for BUSY line to go high.
	beq.s	Get_Byte

	move.b	(a6),d0			Get byte from printer port.
	rts


* Receive a long word (Note: A2 and D6 are brown dogs).

Get_Long_Word
	lea	Long_Word(pc),a2
	bsr.s	Get_Byte_M
	bsr.s	Get_Byte_M
	bsr.s	Get_Byte_M
	lsr.l	#5,d6			Wait 18 clock cycles.
Get_Byte_M
	btst	d7,(a4)			Wait for BUSY line to go high.
	beq.s	Get_Byte_M

	move.b	(a6),(a2)+		Get byte from printer port.
	rts



****************************************************************

	ifne	Exec_Type<2

Long_Word
	ds.l	1			Big fat long word gets dumped here.

	ds.l	100			Loads of stack space.
R_Stack

	elseif


Long_Word
	ds.l	1

R_Stack	equ	*+16			Only a small stack is needed when
*					creating a boot sector.


Downloader_Length	equ	*-Downloader

	ifne	Downloader_Length>(512-2-$1e)
Downloader will not fit on boot sector
	endc

	endc


Downloader_1_Length	equ	*-Downloader_1


	end
