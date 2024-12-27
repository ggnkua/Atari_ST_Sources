****************************************************************
* Download system - ST receiver version 1.01


Reloc_Addr	equ	$500


PSG		equ	$ffff8800
MFP_GPIP	equ	$fffffa01
MFP_DDR		equ	$fffffa05
Palette0	equ	$ffff8240

floprd		equ	8		XBIOS Read sector.
flopwr		equ	9		XBIOS Write sector.
conws		equ	9		GEMDOS Print string.


start
	move.w	#3,-(sp)		;Count.
	clr.w	-(sp)			;Side.
	clr.w	-(sp)			;Track.
	move.w	#2,-(sp)		;Sector.
	clr.w	-(sp)			;Drive A.
	clr.l	-(sp)
	pea	Downloader(pc)
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp

	clr.w	-(sp)
	trap	#1


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
	move.w	#$2700,sr
	bsr	TitlePage

	lea	Downloader_1(pc),a0		Relocate downloader.
	lea	Reloc_Addr,a1
	move.w	#Downloader_1_Length-1,d7
.Reloc_Loop
	move.b	(a0)+,(a1)+
	dbra	d7,.Reloc_Loop

	jmp	Reloc_Addr			Execute downloader.



Downloader_1
	move.w	#$2700,sr
	lea	R_Stack(pc),sp

	lea	Error(pc),a0
	lea	$8.w,a1
.set_errs
	move.l	a0,(a1)+
	cmp.l	#$60,a1
	blt.s	.set_errs

	lea	Downloader_1(pc),a0
.set_vecs
	move.l	a0,(a1)+
	cmp.l	#$140,a1
	blt.s	.set_vecs

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
	clr.w	(a3)			Set screen green.

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

	move.l	a1,d0
	beq	Downloader_1
	jmp	(a1)			Execute code.



* Trap #0 - downloader re-entry.

Re_Entry_Addr
	move.b	#15,PSG.w		Select PSG register for port B.
	cmp.b	#$81,PSG.w
	beq	Downloader_1
	rte



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


Error
	move.w	#$2700,sr
	lea	R_Stack(pc),sp
	lea	Palette0,a0
.loop
	move.w	#$100,(a0)
	move.w	#$200,(a0)
	move.w	#$300,(a0)
	move.w	#$400,(a0)
	move.w	#$500,(a0)
	move.w	#$600,(a0)
	move.w	#$700,(a0)
	REPT	5
	dbt	d0,*
	ENDR
	TRAP	#0
	move.w	#$600,(a0)
	move.w	#$500,(a0)
	move.w	#$400,(a0)
	move.w	#$300,(a0)
	move.w	#$200,(a0)
	move.w	#$100,(a0)
	clr.w	(a0)
	REPT	4
	dbt	d0,*
	ENDR
	TRAP	#0
	bra.s	.loop


****************************************************************

Long_Word
	ds.l	1

	ds.b	64
R_Stack					;Only a small stack is needed when
					;creating a boot sector.

Downloader_1_Length	equ	*-Downloader_1

TitlePage
	lea	$ffff8240.w,a0
	clr.w	(a0)+
	move.w	#$fff,(a0)

	bsr	calc_ram
	bsr	calc_free

	move.l	$44e.w,a1
	move.w	#(160*100/4)-1,d0
.clear_page
	clr.l	(a1)+
	dbf	d0,.clear_page

	lea	text(pc),a0
	move.l	$44e.w,a1
	lea	font(pc),a2
	move.l	a1,a3
.char
	move.b	(a0)+,d0
	bmi.s	.done
	cmp.b	#10,d0
	beq.s	.next_line
	cmp.b	#13,d0
	beq.s	.start_line
	bsr	show_char
	bra.s	.char
.done
	rts

.next_line
	lea	(8*160)(a3),a3
.start_line
	move.l	a3,a1
	bra.s	.char


calc_ram
	moveq	#0,d7
	lea	ram_txt(pc),a0
	move.l	$42e.w,d0
	moveq	#10,d1
	lsr.l	d1,d0
	divu	#1000,d0
	bsr.s	.digit
	swap	d0
	ext.l	d0
	divu	#100,d0
	bsr.s	.digit
	swap	d0
	ext.l	d0
	divu	#10,d0
	bsr.s	.digit
	swap	d0
	bsr.s	.digit
	move.b	#'K',(a0)
	rts
.digit
	tst.b	d7
	bne.s	.show
	tst.w	d0
	beq.s	.zero
.show
	st	d7
	add.b	#'0',d0
	move.b	d0,(a0)+
.zero
	rts


calc_free
	moveq	#0,d7
	lea	free_txt(pc),a0
	move.w	#$500+Downloader_1_Length,d0
	REPT	3
	rol.w	#4,d0
	bsr.s	.digit
	ENDR
	rol.w	#4,d0
.digit
	move.w	d0,d1
	and.w	#$f,d1
	tst.b	d7
	bne.s	.show
	tst.w	d1
	beq.s	.zero
.show
	st	d7
	cmp.b	#10,d1
	blt.s	.dec
	addq.b	#7,d1
.dec
	add.b	#'0',d1
	move.b	d1,(a0)+
.zero
	rts


show_char
	sub.b	#32,d0
	and.w	#$00ff,d0
	mulu	#5,d0
	lea	(a2,d0.w),a4
OFF	set	0
	REPT	5
	move.b	(a4)+,OFF(a1)
OFF	set	OFF+160
	ENDR
	addq.w	#1,a1
	move.w	a1,d0
	and.w	#1,d0
	bne.s	.no_bump
	addq.w	#6,a1
.no_bump
	rts


text
	dc.b	'WIDGET DOWNLOADER',13,10,10
	dc.b	'VERSION 2.1',13,10
	dc.b	'(C) 1992/1995',13,10
	dc.b	'LEO SKIRENKO',13,10
	dc.b	'PHILIP WATTS',13,10
	dc.b	'MARK SHERDLEY-DAVIES',13,10
	dc.b	10,10
	dc.b	'RAM = '
ram_txt
	dc.b	'     ',13,10
	dc.b	'WORKSPACE = $500 TO $'
free_txt
	dc.b	'    ',13,10
	dc.b	-1
	even

font	incbin	"FONT.DAT"

de	even

Downloader_Length	equ	*-Downloader
