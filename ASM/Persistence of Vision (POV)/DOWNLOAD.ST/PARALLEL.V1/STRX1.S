****************************************************************
* Download system - ST receiver version 1.00

	opt	o+,ow+,ow2-,ow3-

	include	"C:\INCLUDE\SYSTEMEQ.S"


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
	bne.s	Read_Error

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
	bne.s	Write_Error

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

	moveq	#(50*2)-1,d7		; Wait for floppy drive to stop.
.floppy_wait
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	dbf	d7,.floppy_wait

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
	btst.b	#4,GPIP
	beq.s	Re_Entry_Addr

	move.w	#$2700,sr
	lea	R_Stack(pc),sp

	lea	Re_Entry_Addr(pc),a0	Set TRAP #0 for downloader re-entry.
	move.l	a0,$80.w
	IFNE	0
	move.l	a0,$8.w			; Bus error.
	move.l	a0,$c.w			; Address error.
	move.l	a0,$10.w		; Illegal instruction.
	move.l	a0,$18.w		; CHK instruction.
	move.l	a0,$1c.w		; TRAPV instruction.
	move.l	a0,$20.w		; Privilege violation.
	move.l	a0,$24.w		; Trace mode.
	ENDC
	lea	$8.w,a1
	moveq	#8-1,d0
.bombs
	move.l	a0,(a1)+
	dbf	d0,.bombs

	lea	rte_isr(pc),a0
	move.l	a0,$14.w		; Divide by zero.
	lea	$100.w,a1
	moveq	#16-1,d0
.isrs
	move.l	a0,(a1)+
	dbf	d0,.isrs

	lea	new_kbd(pc),a0
	move.l	a0,(KBD_ISR).w

	clr.b	(IERA).w
	clr.b	(IMRA).w
	move.b	#$40,(IERB).w
	move.b	#$40,(IMRB).w
	bclr.b	#3,(VR).w

	lea	PSG.w,a6		A6 and A5 point to PSG registers.
	lea	2(a6),a5

	move.b	#7,(a6)			Set port A for output and port B
	move.b	#%01111111,(a5)		for input.

	move.b	MFP_DDR.w,d0		Set BUSY line for input.
	and.b	#%11111110,d0
	move.b	d0,MFP_DDR.w

	lea	MFP_GPIP.w,a4		A4 holds BUSY line port address.
	moveq	#0,d7			D7 holds bit number for BUSY line.

	lea	(VidBaseHi).w,a0	; Set screen & clear it.
	move.l	$44e.w,a3
	move.l	a3,d0
	lsr.l	#8,d0
	movep.w	d0,(a0)
	clr.w	STEVidBaseLo
	clr.w	STEVidHScroll
	clr.w	STEVidLineWid

	move.w	#(32000/4)-1,d0
.clear
	clr.l	(a3)+
	dbf	d0,.clear

	lea	Picture(pc),a0
	lea	(8*7)-(160*103)(a3),a3
	moveq	#5-1,d0
.loopy
	moveq	#6-1,d1
.loopx
	move.w	(a0)+,(a3)
	addq.w	#8,a3
	dbf	d1,.loopx
	lea	160-(8*6)(a3),a3
	dbf	d0,.loopy

	lea	Palette0.w,a3
	clr.w	(a3)			Set screen black.
	move.w	#$777,2(a3)

* Enter downloader.

	move.b	#15,(a6)		Select PSG register for port B.

Wait_Header
	bsr.s	Get_Byte		Wait for 4 byte header.
Bad_Header
	cmp.b	#'S',d0
	bne.s	Wait_Header
	bsr.s	Get_Byte
	cmp.b	#'X',d0
	bne.s	Bad_Header
	bsr.s	Get_Byte
	cmp.b	#'0',d0
	bne.s	Bad_Header
	bsr.s	Get_Byte
	cmp.b	#'1',d0
	bne.s	Bad_Header

* Receive download info.

	bsr.s	Get_Long_Word		Receive download address.
	move.l	Long_Word(pc),a0
	bsr.s	Get_Long_Word		Receive download length.
	move.l	Long_Word(pc),d1
	bsr.s	Get_Long_Word		Receive execution address.
	move.l	Long_Word(pc),a1

* Receive data.

	moveq	#$30,d4			Colours.
	move.l	#256,d2			Block length.

Download_Loop_R2
	move.w	d4,(a3)			Change screen colour.
	add.w	d4,d4

	sub.l	d2,d1
	bls.s	Receive_Last

	move.w	d2,d3
	subq.w	#1,d3
Download_Loop_R1
	btst	d7,(a4)			Wait for BUSY line to go high.
	beq.s	Download_Loop_R1
	move.b	(a6),d4
	move.b	d4,(a0)+		Get byte from printer port.
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

	clr.w	(a3)			Set screen green.

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


new_kbd
	move.b	KBD_DATA,$34.w
	btst.b	#4,GPIP
	beq.s	new_kbd
rte_isr
	rte


****************************************************************

	ifne	Exec_Type<2

Long_Word
	ds.l	1			Big fat long word gets dumped here.

	ds.l	100			Loads of stack space.
R_Stack

	elseif


Long_Word
	dc.l	0

Picture		incbin	"PICTURE.DAT"

R_Stack	equ	*+16			Only a small stack is needed when
*					creating a boot sector.


Downloader_Length	equ	*-Downloader

	ifne	Downloader_Length>(512-2-$1e)
Downloader will not fit on boot sector
	endc

	endc


Downloader_1_Length	equ	*-Downloader_1


	end
