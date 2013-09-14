* rootsect.s
* $Header$

*------------------------------------------------------------------------
*									:
*	Hard Disk Root Sector						:
*	Initiates boot from a hard disk partition, contains		:
*	hard disk read-sector subroutine for use by partition's		:
*	boot code.							:
*									:
*	Copyright 1986 Atari Corp.					:
*	All Rights Reserved						:
*									:
*------------------------------------------------------------------------

* $Log$


*---- Hardware registers:
diskctl		equ	$ffff8604	; (W) disk controller data access
fifo		equ	$ffff8606	; (W) DMA mode control
dmahigh		equ	$ffff8609	; (B) DMA base high
dmamid		equ	$ffff860b	; (B) DMA base medium
dmalow		equ	$ffff860d	; (B) DMA base low
gpip		equ	$fffffa01	; (B) bit 5 is DMA interrupt line

*---- OS locations:
flock		equ	$43e	; (W) DMA chip lock variable
_bootdev	equ	$446	; (W) boot device number
_hz_200		equ	$4ba	; (L) 200 hz timer tick
_dskbufp	equ	$4c6	; (L) -> 1K disk buffer
_sysbase	equ	$4f2	; (L) -> OS header

*--- Magic numbers:
bootmagic	equ	$1234	; executable boot sectors checksum to $1234


*+
*  Root Sector
*
*  First branch (+0) goes to partition booter;
*  Second branch (+2) goes to disk read routine.
*  Bfat (+6) is a flag for size of FAT entries
*
*-
_rootstart::
base:	bra.s	rootboot	; boot some partition
	bra	dmaread		; read sectors

*+
*  bfat - bit 0 if set: 12-bit FAT
*	  bit 2 if set: 16-bit FAT
*	  bit 7 if set: cluster number is odd
*-
bfat:	dc.b	0		; $01: 12-bit FAT
	.even			; $04: 16-bit FAT

*+
*  rootboot - locate a bootable partition and boot from it
*
*    - If the [ALT] key is down, just exit;
*    - Search for bootable partition in sector image;
*    - If none, just return;
*    - Otherwise, load partition's boot sector into upper half
*      of the 1K buffer, checksum it, and execute it if it
*      checks out;
*    - Adjust D7 on return so the DMA bus will not lock up.
*
*-
rootboot:
	bclr.b	#2,$4c2+3	; if this code fails, there's no C:
				; so, clobber 'C' bit in _drvbits
	move.w	#-1,-(sp)	; don't set shift mode
	move.w	#$0b,-(sp)	; D0 = Kbshift()
	trap	#13		;
	addq	#4,sp		;
	btst	#3,d0		; is [ALT] down?
	bne.s	sb		; (yes, goto set boot)

	moveq	#3,d0		; d0 = partition count
	lea	bfat(pc),a1	; get addr of bfat
	lea	base(pc),a0	; get addr of last two bytes
	add.w	#$200-2,a0
	cmpi.w	#$55aa,(a0)	; is this a MSDOS master boot record?
	bne.s	st_rb		; if not, assume it's an ST root sector
				; get addr of first partition
	sub.w	#64,a0		; (64 = size of structures after part0 - 2)
irb_1:	move.b	4(a0),(a1)	; flag for size of FAT entries
	cmpi.b	#$80,(a0)	; boot inicator set?
	beq	irb_2		; (yes --- boot the partition)
	adda.w	#16,a0		; bump to next partition entry
	dbra	d0,irb_1	; (no --- look for other partitions)
	bra.s	rb_r		; back to OS
				; get addr of first partition
st_rb:	sub.w	#56,a0		; (56 = size of structures after part0 - 2)
	move.b	#$04,(a1)	; always 16-bit FAT
rb_1:	and.b	#$81,(a0)	; keep only P_EXISTS and P_BOOTBIT
	cmp.b	#$81,(a0)	; both bits set?
	beq	rb_2		; (yes --- boot the partition)
	add.w	#12,a0		; bump to next partition entry
	dbra	d0,rb_1		; (no --- look for other partitions)
	bra.s	rb_r		; back to OS

*+
*  Return to BIOS boot routine:
*    - hack D7 so BIOS never does any more reads
*      (so the DMA bus will not lock up).
*
*  Modified 18-Feb-1988 by AKP to hack D7 (and stop looking on the DMA bus)
*  ONLY on 11/20-derived ROMs.  Newer ROMs have this bug fixed.
*
*  Modified 04-May-1988 by ML to reset default boot device back to A:
*  if [ALT] key is held during boot process.
*-

sb:	move.w	#0,_bootdev	; set default boot device to A: (devno=0)
rb_r:	move.l	_sysbase,a0	; get the system header address
	move.l	$18(a0),d0	; d0.l = MMDDYYYY of ROM date
	swap	d0		; d0.l = YYYYMMDD of ROM date
	cmp.l	#$19870422,d0	; does this version of ROM need bootstop?
	bcc.s	dontstop	; nope, if OS is built on or after 4/22/87
	move.w	#$100-$20,d7	; prevent any other boot sector loads
dontstop:
	rts			; no bootable partitions


*
*  Handle bootable partition:
*    - read its boot sector;
*    - checksum it;
*    - if it is executable, call it.
*
irb_2:	move.l	8(a0),d6	; d6 = sector number
	ror.w	#8,d6		; 8086 sector # -> 68000 sector #
	swap	d6
	ror.w	#8,d6
	bra.s	irb_3		; go read boot sector
rb_2:	move.l	4(a0),d6	; d6 = sector number
irb_3:	moveq	#1,d5		; d5 = sector count = 1
	lea	base(pc),a4	; a4 -> upper half of 1K buffer
	add.w	#$200,a4
	bsr.s	dmaread		; read partition's boot sector
	bne.s	rb_r		; (punt on failure)

	move.l	a4,a0		; a0 -> buffer to checksum
	move.w	#$0ff,d1	; checksum $100 words
	moveq	#0,d0		; checksum = 0
rb_3:	add.w	(a0)+,d0	; add (next) word
	dbra	d1,rb_3		; (loop for every word)
	cmp.w	#bootmagic,d0	; is the sector executable?
	bne.s	rb_r		; (no --- return to OS)
	lea	dmaread(pc),a3	; a3 -> disk read routine
	jmp	(a4)		; yes --- jump there


*+
*  dmaread - read sectors from hard disk
*    Passed:	D7.B = ddd00000 ('ddd' is the ACSI device number, 0..7)
*		D6.L = sector number
*		D5.W = sector count
*		A4  -> buffer address
*
*    Returns:	EQ: success
*		NE: read failed;
*
*    Uses:	A5-A6/D0-D1
*
*-
dmaread:
	st	flock		; lock DMA chip (against vblank)

	move.l	_hz_200,d0	; delay for 1/200th..1/100th of a second
	addq.l	#2,d0		; d0 = target time
dmr_dl:	cmp.l	_hz_200,d0	; target time passed?
	bcc	dmr_dl		; (not yet)

	move.w	#dmahigh,a6	; a6 -> base of DMA address registers
	move.l	A4,-(sp)	; stuff addr onto stack for handy access
	move.b	3(sp),4(a6)	; load dmalow,
	move.b	2(sp),2(a6)	;	dmamid,
	move.b	1(sp),(a6)	;	and dmahigh.
	tst.l	(sp)+

	lea	dmr_st(pc),a6	; a5 -> command frame table
	move.l	d6,-(sp)	; stuff sector# onto stack for handy access
	move.b	1(sp),1(a6)	; write high,
	move.b	2(sp),5(a6)	;	mid,
	move.b	3(sp),9(a6)	;	and low sector bytes in table
	move.b	d5,$d(a6)	; write sector count in table
	tst.l	(sp)+		; (cleanup stack)

	move.w	#fifo,a6	; a6 -> DMA control register
	move.w	#diskctl,a5	; a5 -> DMA data register

	move.w	#$098,(a6)	; toggle R/W, leave in Read state
	move.w	#$198,(a6)
	move.w	#$098,(a6)
	move.w	d5,(a5)		; write sector count register

	move.w	#$088,(a6)	; select dma bus (not SCR)

	move.b	d7,d0		; setup d0.L with devno+command
	or.b	#$08,d0		; d0.b = devno<<5 .OR. "READ" command bits
	swap	d0
	move.w	#$08a,d0
	bsr	wcbyte		; d0.L = xxxxxxxxDDD01000xxxxxxx010001010

	lea	dmr_st(pc),a0	; a0 -> bytestream for commands
	move.l	(a0)+,d0	; get next command byte
	bsr.s	wcbyte		; write it
	move.l	(a0)+,d0	; get next command byte
	bsr.s	wcbyte		; write it
	move.l	(a0)+,d0	; get next command byte
	bsr.s	wcbyte		; write it
	move.l	(a0)+,d0	; get next command byte
	bsr.s	wcbyte		; write it

	move.l	#$0000000a,(a5)	; write byte 5 (controlByte = $00)
	move.w	#400,d1		; timeout = 2.0 sec
	bsr	wwait		; wait for completion

	move.w	#$08a,(a6)	; select status reg
	move.w	(a5),d0		; get return code from DMA device
	and.w	#$00ff,d0	; strip crufty bits
	beq.s	dmr_r		; (return if OK)

*--- reset DMA, return status
dmr_q:	moveq	#-1,d0		; return -1 (error)
dmr_r:	move.w	#$080,(a6)	; cleanup DMA chip for floppy driver
	tst.b	d0		; (test for NE on return)
	sf	flock		; unlock DMA chip
ww_w:	rts			; return


*--- bytes in the command packet:
dmr_st:		dc.l	$0000008a	; byte 1 (devno = 0, blockno = 0)
		dc.l	$0000008a	; byte 2 (blockno = 0)
		dc.l	$0000008a	; byte 3 (blockno = 0)
		dc.l	$0001008a	; byte 4 (count = 1)


*+
*  wcbyte - write ACSI command byte, wait for IRQ
*    Passed:	D0.L = command byte and FIFO control
*			bits 16..23 = command byte,
*			bits 0..7 = FIFO control bits
*		a5 -> $ff8604
*
*    Returns:	NE on failure (timeout) to the CALLER'S CALLER
*		EQ on successful ACK
*
*    Uses:	d1
*
*-
wcbyte:	move.l	d0,(a5)		; write WDC, WDL [due to jwt]
	moveq	#10,d1		; wait 1/20th second
wwait:	add.l	_hz_200,d1	; d1 = time to quit at...
ww_1:	btst.b	#5,gpip		; disk done?
	beq.s	ww_w		; (yes, return)
	cmp.l	_hz_200,d1	; timeout?
	bne.s	ww_1		; (not yet -- wait some more...)
	tst.l	(sp)+		; pop return address
	bra.s	dmr_q		; handle error

_rootend::

    bss
*+
*  Hard disk partition information
*
*-
format_info:	ds.b	12	; formatting information
hd_size:	ds.l	1	; hd_siz
part0:		ds.b	12	; partition 0
part1:		ds.b	12	; partition 1
part2:		ds.b	12	; partition 2
part3:		ds.b	12	; partition 3
bsl_st:		ds.l	1	; bad sector list start
bsl_cnt:	ds.l	1	; bad sector list count
checksum:	ds.w	1	; (reserved for sector chksum)

