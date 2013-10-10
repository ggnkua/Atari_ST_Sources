****************************************************************
* Download system - ST receiver version 1.01


Reloc_Addr	equ	$500
Load_Addr	equ	$10000



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
	move.w	#3,-(sp)		;Count.
	clr.w	-(sp)			;Side.
	clr.w	-(sp)			;Track.
	move.w	#2,-(sp)		;Sector.
	clr.w	-(sp)			;Drive A.
	clr.l	-(sp)
	pea	Load_Addr
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp

	moveq	#(50*2)-1,d7		;Wait for floppy drive to stop.
.floppy_wait
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	dbf	d7,.floppy_wait

	move.w	#$2700,sr
	jmp	Load_Addr			Execute downloader.


Downloader_Length	equ	*-Downloader

	ifne	Downloader_Length>(512-2-$1e)
Downloader will not fit on boot sector
	endc


	end
