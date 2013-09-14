; rootsect.s

;------------------------------------------------------------------------
;									:
; Hard Disk Root Sector							:
; Initiates boot from a hard disk partition, contains hard disk 	:
; read-sector subroutine for use by partition's	boot code.		:
;									:
; Copyright 1986, 1987, 1988, 1989, 1990 Atari Corp.			:
; All Rights Reserved							:
;									:
; Jul-24-1989	ml.	Modified this for TT.				:
;			New ROMs will pass the following to this	:
;			root sector:					:
;			d3.l = $444d4172 ("DMAr") to indicate the XBIOS	:
;				call for DMAread exists.		:
;			d4.w = boot unit # (iff d3.l = "DMAr")		:
;			d5.w = user-preference (ignore for now!!)	:
;			d7.b = ACSI device # in upper 3 bits		:
;				(should ignore d7.b if d4.w is valid)	:
; Feb-05-1990	ml.	Modified to reflect the latest boot spec. which	:
;			includes booting UNIX on the TT.		:
;			Removed code that handles MSDOS root sector.	:
;			Handled user-preference as stated in latest	:
;			TT boot spec.					:
; Feb-14-1990	ml.	If a user-preference is passed in through d5 	:
;			but no entry matches it, just quit.  Maybe the	:
;			preference is for another kind of device.	:
; Jul-25-1990	ml.	Modified handling of user-preference code, so	:
;			that bits 1 & 2 of byte 0 of a partition entry	:
;			do not participate in the comparison.  (This 	:
;			lifts the assumption that they have to be 0.)	:
;									:
;------------------------------------------------------------------------


;---- Hardware registers:
diskctl		equ	$ffff8604	; (W) disk controller data access
fifo		equ	$ffff8606	; (W) DMA mode control
dmahigh		equ	$ffff8609	; (B) DMA base high
dmamid		equ	$ffff860b	; (B) DMA base medium
dmalow		equ	$ffff860d	; (B) DMA base low
gpip		equ	$fffffa01	; (B) bit 5 is DMA interrupt line

;---- OS locations:
flock		equ	$43e		; (W) DMA chip lock variable
_bootdev	equ	$446		; (W) boot device number
_hz_200		equ	$4ba		; (L) 200 hz timer tick
_drvbits	equ	$4c2		; (L) logical drive map
_dskbufp	equ	$4c6		; (L) -> 1K disk buffer
_sysbase	equ	$4f2		; (L) -> OS header

;--- Magic numbers:
bootmagic	equ	$1234		; executable boot sector checksum
DMAr		equ	$444d4172	; DMAread() 


;+
;  Root Sector
;
;  First branch (+0) goes to partition booter;
;  Second branch (+2) goes to disk read routine.
;  Bfat (+6) is a flag for size of FAT entries
;
;-
_rootstart::
base:	bra.s	rootboot	; boot some partition
	bra	dmaread		; read sectors


;+
;  rootboot - locate a bootable partition and boot from it
;
;    - If the [ALT] key is down, just exit;
;    - Search for bootable partition in sector image;
;    - If none, just return;
;    - Otherwise, load partition's boot sector into upper half
;      of the 1K buffer, checksum it, and execute it if it
;      checks out;
;    - Adjust D7 on return so the DMA bus will not lock up.
;
;-
rootboot:			; if this code fails, there's no C:
	bclr.b	#2,_drvbits+3	; so, clobber 'C' bit in _drvbits
	move.w	#0,_bootdev	; initialise bootdev to be A:
	movem.l	d3/d5,-(sp)	; save d3 and d5
	move.w	#-1,-(sp)	; get state of the shift keys
	move.w	#$0b,-(sp)	; d0 = Kbshift()
	trap	#13
	addq.w	#4,sp		; clean-up stack
	btst	#3,d0		; is [ALT] down?
	bne.s	rb_r		; (yes, just return)

	moveq	#3,d0		; d0 = partition count
	moveq	#$00f8,d1	; d1 = mask for boot value
	lea	base+$1c6(pc),a0 ; a0 -> first partition entry
	cmpi.l	#DMAr,d3	; does DMAread() exist?
	beq.s	rb_0		; if it does, d4 = physical unit number
	moveq	#-1,d4		; else d4 = -1 => no DMAread in ROM
	moveq	#$80,d2		; d2 = old boot value
	bra.s	rb_1		; and boot the old way

rb_0:	move.b	d5,d2		; else, is there a user preference?
	beq.s	rb_5		; if not, boot the first bootable partition
rb_1:	btst.b	#0,(a0)		; does partition exist?
	beq.s	rb_2		; if not, try next partition slot
	and.b	d1,(a0)		; mask off irrelevant bits
	cmp.b	(a0),d2		; p_flg matches boot value?
	beq.s	rb_3		; (yes --- boot the partition)
rb_2:	adda.w	#12,a0		; bump to next partition entry
	dbra	d0,rb_1		; (no --- look for other partitions)
	bra.s	rb_r		; boot value search fails, return to ROMs
				; boot the first bootable partition
rb_5:	btst.b	#0,(a0)		; does partition exist?
	beq.s	rb_6		; if not, try next partition slot
	and.b	d1,(a0)		; partition has a non-zero boot value?
	bne.s	rb_3		; (yes --- boot the partition)
rb_6:	adda.w	#12,a0		; (no --- bump to next partition entry)
	dbra	d0,rb_5		; look for other partitions
				; if none is bootable, return to ROMs

;+
;  Return to BIOS boot routine:
;    - hack D7 so BIOS never does any more reads
;      (so the DMA bus will not lock up).
;
;  Modified 18-Feb-1988 by AKP to hack D7 (and stop looking on the DMA bus)
;  ONLY on 11/20-derived ROMs.  Newer ROMs have this bug fixed.
;-
rb_r:	addq.w	#$08,sp		; clean up stack
rb_bs:	move.l	_sysbase,a0	; get the system header address
	move.l	$18(a0),d0	; d0.l = MMDDYYYY of ROM date
	swap	d0		; d0.l = YYYYMMDD of ROM date
	cmp.l	#$19870422,d0	; does this version of ROM need bootstop?
	bcc.s	dontstop	; nope, if OS is built on or after 4/22/87
	move.w	#$100-$20,d7	; prevent any other boot sector loads
dontstop:
	rts			; no bootable partitions


;+
;  Handle bootable partition:
;    - read its boot sector;
;    - checksum it;
;    - if it is executable, call it.
;-
rb_3:	move.l	4(a0),d6	; d6 = sector number
	moveq	#1,d5		; d5 = sector count = 1
	lea	base+$200(pc),a4 ; a4 -> upper half of 1K buffer
	bsr.s	dmaread		; read partition's boot sector
	tst.w	d0		; successful?
	bne.s	rb_r		; (punt on failure)

	move.l	a4,a0		; a0 -> buffer to checksum
	move.w	#$0ff,d1	; checksum $100 words
	moveq	#0,d0		; initialise checksum = 0
rb_4:	add.w	(a0)+,d0	; add (next) word
	dbra	d1,rb_4		; (loop for every word)
	cmp.w	#bootmagic,d0	; is the sector executable?
	bne.s	rb_r		; (no --- return to OS)
	lea	dmaread(pc),a3	; a3 -> disk read routine
	lea	rb_bs(pc),a5	; a5 -> bootstop code
	movem.l	(sp)+,d3/d5	; restore d3 and d5
	jmp	(a4)		; yes --- jump there


;+
;  dmaread - read sectors from hard disk
;	Passed:	d4.w = physical unit number (if DMAread() is in ROM)
;			or -1 (if DMAread() is not in ROM)
;		d5.w = sector count
;		d6.l = sector number
;		d7.b = ddd00000 ('ddd' is the ACSI device number, 0..7)
;		a4.l -> buffer address
;
;    Returns:	EQ: success
;		NE: read failed;
;
;    Uses:	a5-a6/d0-d1 for dmaread here
;		a0-a2/d0-d2 for DMAread in ROM
;-
dmaread:
	tst.w	d4		; DMAread exists in ROM?
	bmi.s	dmr_0		; if not, use dmaread() in this root sector
	move.w	d4,-(sp)	; pdev
	move.l	a4,-(sp)	; buf
	move.w	d5,-(sp)	; count
	move.l	d6,-(sp)	; sectnum
	move.w	#$2a,-(sp)	; DMAread(sectnum, count, buf, pdev)
	trap	#14
	adda.w	#$0e,sp		; clean up stack
	bra	ww_w		; done

dmr_0:	st	flock		; lock DMA chip (against vblank)
	move.l	_hz_200,d0	; delay for 1/200th..1/100th of a second
	addq.l	#2,d0		; d0 = target time
dmr_dl:	cmp.l	_hz_200,d0	; target time passed?
	bcc.s	dmr_dl		; (not yet)

	move.w	#dmahigh,a6	; a6 -> base of DMA address registers
	movem.l	d6/a4,-(sp)	; stuff sect# & addr onto stack for access
	move.b	7(sp),4(a6)	; load dmalow,	(do not change the order)
	move.b	6(sp),2(a6)	;      dmamid,  (of loading these.)
	move.b	5(sp),(a6)	;  and dmahigh.

	lea	dmr_st(pc),a6	; a6 -> command frame table
	move.b	1(sp),1(a6)	; write high,
	move.b	2(sp),5(a6)	;	mid,
	move.b	3(sp),9(a6)	;	and low sector bytes in table
	move.b	d5,$d(a6)	; write sector count in table
	addq.w	#$8,sp		; (cleanup stack)

	move.w	#fifo,a6	; a6 -> DMA control register
	move.w	#diskctl,a5	; a5 -> DMA data register

	move.w	#$198,(a6)	; toggle R/W, leave in Read state
	move.w	#$098,(a6)
	move.w	d5,(a5)		; write sector count register

	move.w	#$088,(a6)	; select dma bus (not SCR)

	moveq	#0,d0		; clear d0
	move.b	d7,d0		; setup d0.L with devno+command
	or.b	#$08,d0		; d0.b = devno<<5 .OR. "READ" command bits
	swap	d0
	move.w	#$08a,d0
	bsr.s	wcbyte		; d0.L = xxxxxxxxDDD01000xxxxxxx010001010

	lea	dmr_st(pc),a0	; a0 -> bytestream for commands
	moveq	#3,d2
dmr_1:	move.l	(a0)+,d0	; get next command byte
	bsr.s	wcbyte		; write it
	dbra	d2,dmr_1

	move.l	#$0000000a,(a5)	; write byte 5 (controlByte = $00)
	move.l	#400,d1		; timeout = 2.0 sec
	bsr.s	wwait		; wait for completion

	move.w	#$08a,(a6)	; select status reg
	move.w	(a5),d0		; get return code from DMA device
	and.w	#$00ff,d0	; strip crufty bits
	beq.s	dmr_r		; (return if OK)

;--- reset DMA, return status
dmr_q:	moveq	#-1,d0		; return -1 (error)
dmr_r:	move.w	#$080,(a6)	; cleanup DMA chip for floppy driver
	sf	flock		; unlock DMA chip
ww_w:	rts			; return


;--- bytes in the command packet:
dmr_st:		dc.l	$0000008a	; byte 1 (devno = 0, blockno = 0)
		dc.l	$0000008a	; byte 2 (blockno = 0)
		dc.l	$0000008a	; byte 3 (blockno = 0)
		dc.l	$0001008a	; byte 4 (count = 1)


;+
;  wcbyte - write ACSI command byte, wait for IRQ
;    Passed:	D0.L = command byte and FIFO control
;			bits 16..23 = command byte,
;			bits 0..7 = FIFO control bits
;		a5 -> $ff8604
;
;    Returns:	NE on failure (timeout) to the CALLER'S CALLER
;		EQ on successful ACK
;
;    Uses:	d1
;
;-
wcbyte:	move.l	d0,(a5)		; write WDC, WDL [due to jwt]
	moveq	#10,d1		; wait 1/20th second
wwait:	add.l	_hz_200,d1	; d1 = time to quit at...
ww_1:	btst.b	#5,gpip		; disk done?
	beq.s	ww_w		; (yes, return)
	cmp.l	_hz_200,d1	; timeout?
	bcc.s	ww_1		; (not yet -- wait some more...)
	addq.w	#4,sp		; pop the return address
	bra.s	dmr_q		; handle error

_rootend::

    bss
;+
;  Hard disk partition information
;
;-
format_info:	ds.b	12	; formatting information
hd_size:	ds.l	1	; hd_siz
part0:		ds.b	12	; partition 0
part1:		ds.b	12	; partition 1
part2:		ds.b	12	; partition 2
part3:		ds.b	12	; partition 3
bsl_st:		ds.l	1	; bad sector list start
bsl_cnt:	ds.l	1	; bad sector list count
checksum:	ds.w	1	; (reserved for sector chksum)

