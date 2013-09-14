;+
; Edit History
;
; Sep-05-90	ml.	Created this for drives on the IDE bus.
;
; Mar-28-91	ml.	Do not use the IDE Sector Count Register 
;			to count down mulitiple sectors read or
;			write.  Some vendors (e.g. Conner and 
;			Seagate) seem to update this register 
;			too early, and every now and then, the
;			last sector of data would remain in the
;			internal sector buffer.  
;			
;			Code in ideread() and idewrite() are modified
;			not to use the IDE Sector Count Register.
;
; Aug-16-91	ml.	W4int() has been modified, in the case of
;			an error occurred, to return value in the 
;			Status register for driver code, and return 
;			value in the Error register for non-driver
;			code.
;
; Oct-10-91	ml.	Special-cased Conner drives for fmtunt() to
;			set drive to appropiate mode.  Added setmode().
;
; Oct-11-91	ml.	Special-cased Conner drives for read and write
;			to get current drive parameters.  Added gcparm().
;
; Mar-03-92	ml.	Added code to test if a drive exist on the IDE bus.
;
; Apr-14-92	ml.	For non-BLiTTER transfers, use move.w instead of
;			move.l, because it's too fast for the drives.
;-

.include	"defs.h"
.include	"sysvar.h"
.include	"mfp.h"
.include	"error.h"
.include	"ide.h"
.include	"blitter.h"

.extern	_useblit

;+
; Wait for status to come back
;-
w4int:	move.l	#D_WORST,d0	; d0 = timeout limit
	add.l	_hz_200,d0	; d0 = expiration time
.0:	btst.b	#5,GPIP		; interrupt?
	beq.s	.1		; if so, out of the loop
	cmp.l	_hz_200,d0	; timeout?
	bhi.s	.0		; if not, wait some more
	moveq	#$ff,d0		; else, return timeout
	bra.s	.3
.1:	moveq	#0,d0		; clear d0
	move.b	IDESR,d0	; d0.b = status returned
	btst	#ERR,d0		; any error?

.if	!DRIVER			; for non-driver code
	beq.s	.2		; if no error, go on
	move.b	IDEER,d0	; else d0.b = error bits
	bra.s	.3		; return with error

.else				; for driver code
	bne.s	.3		; if error, return
.endif	;!DRIVER

.2:	btst	#DRQ,d0		; else DRQ?
	bne.s	.3		; if so, just return
	moveq	#0,d0		; else return OK
.3:	rts			; return status or error code



;+
; ideread() - reads from 1 to 256 sectors as specified in the Task File,
;		beginning at the specified sector.
;	    - sector count equal to 0 requests 256 sectors.
;
; ideread(nhd, nspt, sectnum, count, buf, pdev)
; WORD	nhd;		4(sp).w		; # of data heads on pdev
; WORD	nspt;		6(sp).w		; # of sectors per track
; LONG	sectnum;	8(sp).l		; logical block address
; WORD	count;		$c(sp).w	; # of sectors to read
; BYTE	*buf;		$e(sp).l	; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD	pdev;		$12(sp).w	; physical device number
;-
	.globl	_ideread
_ideread:
	bsr	set_dhcs	; set physical address
	move.l	$e(sp),a0	; a0 -> buffer to read into
	move.b	$d(sp),IDESC	; set sector count

	move.w	$c(sp),d1	; d1.w = # of sectors to read
	subq	#1,d1		; dbra likes one less

	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, don't use it
	moveq	#0,d0		; else it's a read
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#0,IDEDOR	; enable interrupt
	move.b	#READ,IDECR	; set command code
.1:	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.s	.2		; if timed-out, return
	btst	#DRQ,d0		; DRQ?
	beq.s	.2		; if not, return
				; else
	bsr	readbuf		; transfer data
	dbra	d1,.1		; go wait for next interrupt
	moveq	#0,d0		; everything is fine
.2:	rts


;+
; idewrite() - writes from 1 to 256 sectors as specified in the Task File,
;		beginning at the specified sector.
;	     - sector count equal to 0 requests 256 sectors.
;
; idewrite(nhd, nspt, sectnum, count, buf, pdev)
; WORD	nhd;		4(sp).w		; # of data heads on pdev
; WORD	nspt;		6(sp).w		; # of sectors per track
; LONG	sectnum;	8(sp).l		; logical block address
; WORD	count;		$c(sp).w	; # sectors to read
; BYTE	*buf;		$e(sp).l	; $f(sp)=high $10(sp)=mid $11(sp)=low
; WORD	pdev;		$12(sp).w	; physical device number
;-
	.globl	_idewrite
_idewrite:	
	bsr	set_dhcs	; set physical address
	move.l	$e(sp),a0	; a0 -> buffer to write from
	move.b	$d(sp),IDESC	; set sector count

	move.w	$c(sp),d1	; d1.w = # of sectors to read
	subq	#1,d1		; dbra likes one less

	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, don't use it
	moveq	#1,d0		; it's a write
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#0,IDEDOR	; enable interrupt
	move.b	#WRITE,IDECR	; set command code
.1:	btst.b	#DRQ,IDEASR	; DRQ?
	beq.s	.1		; if not, wait longer

.2:	bsr	wrtbuf		; transfer data
	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.s	.3		; if timed-out, return
	btst	#DRQ,d0		; DRQ?
	beq.s	.3		; if not, return
	dbra	d1,.2		; else go transfer data
	moveq	#0,d0		; everything is fine
.3:	rts


;+
; set_dhcs() - convert a logical block address into a physical address.
;	     - set drive #, head #, cylinder # and sector # in task file.
;
; Passed:
;	8(sp).w = nhd = # of data heads
;	$a(sp).w = nspt = # of sectors per track
;	$c(sp).l = logical block address
;	$16(sp).w = physical unit #
;-
set_dhcs:
	move.l	$c(sp),d1	; d1.l = logical block address
	move.w	8(sp),d2	; d2.w = # of data heads
	move.w	$a(sp),d0	; d0.w = # of sectors per track
	mulu	d0,d2		; d2.l = # of sectors per cylinder
				;      = # heads * # of sectors per track
	divu.w	d2,d1		; d1.w = cylinder #
				;      = log block addr / #spc
	move.b	d1,IDECL	; set cylinder low
	lsr.l	#8,d1		; d1.b = cylinder high
	move.b	d1,IDECH	; set cylinder high
	lsr.l	#8,d1		; d1.l = sector # within the cyl
	divu.w	d0,d1		; d1.w = head #
				;      = sector # within cyl / #spt
	move.w	$16(sp),d0	; d0.w = physical unit #
	andi.b	#7,d0		; mask off flags from physical unit #
	lsl.b	#4,d0		; shift unit # to place
	or.b	d0,d1		; or in drive #
;+
	or.b	#$a0,d1
;-
	move.b	d1,IDESDH	; set drive and head #
	swap	d1		; d1.w = sector # (base 0)
	addq.w	#1,d1		;      = sector # + 1 (base 1)
	move.b	d1,IDESN	; set sector #
	rts

;+
; identify() - allows the Host to receive parameter information from
;	       the drive.
;
; identify(pdev, buf)
; WORD	pdev;	4(sp).w		; physical unit #
; BYTE	*buf;	6(sp).l		; buffer to put data
;-
	.globl	_identify
_identify:
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
;+
	or.b	#$a0,d0
;-
	move.b	d0,IDESDH	; set drive #
	move.l	6(sp),a0	; a0 -> buffer

	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, no need to init it
	moveq	#0,d0		; it's a read
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#0,IDEDOR	; enable interrupt
	move.b	#IDENTIFY,IDECR	; set command code
	bsr	w4int		; wait for interrupt
	tst.w	d0		; successful?
	bmi.s	.1		; if timed-out, return
	btst	#DRQ,d0		; DRQ?
	beq.s	.1		; if not, return with error

	bsr	readbuf		; read data
	moveq	#0,d0		; everything is fine
.1:	rts 


;+
; awto() - set drive to Active mode with timeout counter (in 5s increments)
;
; awto(pdev, timeout)
; WORD	pdev;		4(sp).w		; physical unit #
; WORD	timeout;	6(sp).w
;-
	.globl	_awto
_awto:	
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
;+
	or.b	#$a0,d0
;-
	move.b	d0,IDESDH	; set drive #
	move.b	7(sp),IDESC	; set timeout counter
	move.b	#AWTO,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; readbuf() - reads 512 bytes (128 longs) of data from the sector
;		buffer.
;
; Comments:
;	A tower of 8 move.l is used to try to speed up the transfer.
;
; Passed:
;	a0.l = buffer to store data read from sector buffer
;
;	if BLiTTER code
;	a1.l = base address of BLiTTER
;-
readbuf:
	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, do programmed IO
	move.w	#1,YCNT(a1)	; one destination line
	move.b	#$80,BUSY(a1)	; start the BLiTTER
	bsr	restart
	addq.l	#2,DESTADDR(a1)	; advance to next word of destination
	rts
				; Programmed IO
.0:	moveq	#31,d0		; d0 = (# of words to read / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
.1:	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	move.w	(a1),(a0)+	; read data from bus
	dbra	d0,.1		; repeat until all done
	rts


;+
; wrtbuf() - writes 512 bytes (128 longs) of data to sector buffer.
;
; Passed:
;	a0.l = buffer with data to write to sector buffer
;-
wrtbuf:
	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, do programmed IO
	move.w	#1,YCNT(a1)	; one destination line
	move.b	#$80,BUSY(a1)	; start the BLiTTER
	bsr	restart
	addq.l	#2,SRCADDR(a1)	; advance to next word of source
	rts
				; Programmed IO
.0:	moveq	#31,d0		; d0 = (# longs to write / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
.1:	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	move.w	(a0)+,(a1)	; write data to bus
	dbra	d0,.1		;  repeat until all done
	rts


;+
; drvxst() - test if an IDE drive exists
;
; Returns:  0 - if drive does not exist
;	    1 - if drive exists
;-
	.globl	_drvxst
_drvxst:
	move.w	#$5a5a,IDEDR
	move.w	IDEDR,d0
	cmpi.w	#$5a5a,d0
	bne.s	.0
	moveq	#1,d0		; else, drive exists
	rts
.0:	moveq	#0,d0		; drive does not exist
	rts


;+
; initblit() - initialize the BLiTTER chip for 512 bytes I/O transfer
;
; Passed:
;	a0.l = destination address if read; source address if write
;	d0.w = flag to tell whether it's a read or a write
;-
initblit:
	lea	bBLiTTER,a1		; a1 -> BLiTTER register map
	tst.b	d0			; read or write?
	bne.s	ib0			; (write)
	move.l	#IDEDR,SRCADDR(a1)	; source addr = IDE data register
	move.l	a0,DESTADDR(a1)		; destination addr = given buffer
	move.w	#2,DESTXINC(a1)		; words read
	moveq	#0,d0
	move.w	d0,SRCXINC(a1)		; never increment source X
	bra.s	ib1
					; initialize BLiTTER to write to disk
ib0:	move.l	a0,SRCADDR(a1)		; source addr = write buffer
	move.l	#IDEDR,DESTADDR(a1)	; destination addr = IDE data reg
	move.w	#2,SRCXINC(a1)		; words write
	moveq	#0,d0
	move.w	d0,DESTXINC(a1)		; never increment destination X

ib1:	move.w	d0,SRCYINC(a1)		; never increment source Y
	move.w	d0,DESTYINC(a1)		; never increment destination Y
	move.b	d0,SKEW(a1)		; no skew
	moveq	#$ff,d0
	move.l	d0,ENDMASK1(a1)		; change all bits at destination
	move.w	d0,ENDMASK3(a1)		; change all bits at destination
	move.w	#$203,HOP(a1)		; set HOP and OP to source
	move.w	#256,XCNT(a1)		; num of words to transfer
	rts


;+
; restart() - restart the BLiTTER
;
; Passed:
;	a1.l = base address of BLiTTER
;-
restart:
	nop
	tas	BUSY(a1)	; restart BLiTTER and test if busy
	bmi.s	restart		; quit if not busy
	rts


;+
; gcparm() - get current drive parameters
;
; gcparm(buf)
; char	*buf;	$4(sp).l    /* -> data returned by identify() */
;
; Returns:
;	d0.w = # of default cylinders
;	d1.w = # of default heads
;	d2.w = # of default sectors per track
;-
	.globl	_gcparm
_gcparm:
	move.l	4(sp),a0	; a0 -> data buffer
	add.l	#CONMDL,a0	; a0 -> where Conner model number is
	move.l	a0,-(sp)
	pea	cp2024
	move.w	#6,-(sp)
	bsr	strcmp		; compare model# with "CP2024"
	adda	#10,sp		; clean up stack
	tst.w	d0		; is unit the CP2024 (Kato 20Mb)?
	bne.s	gcp0		; if not, handle the normal way
				; else return default values of CP2024
	move.w	#CP20NCYL,d0	; d0.w = # of cylinders
	move.w	#CP20NHEAD,d1	; d1.w = # of heads
	move.w	#CP20NSPT,d2	; d2.w = # of spt
	bra.s	gcpend

gcp0:	move.l	4(sp),a0
	move.w	NCYL(a0),d0	; d0.w = # of cylinders
	move.w	NHEAD(a0),d1	; d1.w = # of heads
	move.w	NSPT(a0),d2	; d2.w = # of sectors per track

gcpend:	rts



conner:	dc.b	"Conner",0
.even
cp2024:	dc.b	"CP2024",0
.even


;+
; strcmp() - compare two strings
;
; Passed:
;	4(sp).w  = n (# of bytes to compare)
;	6(sp).l  = address of first string
;	10(sp).l = address of second string
;
; Returns:
;	d0.w = 0	if first n bytes of the 2 strings are the same
;	     = non-0    otherwise
;-
strcmp:	movem.l	d1/a0-a1,-(sp)	; save registers d1, a0 and a1
	move.w	16(sp),d1	; d1 = byte count
	subq.w	#1,d1		; dbra likes one less
	move.l	18(sp),a0	; a0 -> string 1
	move.l	22(sp),a1	; a1 -> string 2
	moveq	#1,d0		; assume strings are not the same
.0:	cmpm.b	(a0)+,(a1)+	; characters the same?
	bne.s	.1		; if not, return
	dbra	d1,.0		; else compare next character
	moveq	#0,d0		; the strings are the same
.1:	movem.l	(sp)+,d1/a0-a1	; restore registers d1, a0 and a1
	rts


