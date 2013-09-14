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
;-

.include	"defs.h"
.include	"sysvar.h"
.include	"mfp.h"
.include	"iderr.h"
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
.0:	moveq	#15,d0		; d0 = (# of longs to read / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
.1:	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
	move.l	(a1),(a0)+	; read data from bus
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
.0:	moveq	#15,d0		; d0 = (# longs to write / 8) - 1
	lea	IDEDR,a1	; a1 -> data bus
.1:	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	move.l	(a0)+,(a1)	; write data to bus
	dbra	d0,.1		;  repeat until all done
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
; gparmfc() - get the current drive parameters for the C code
;
; gparmfc(addcyl, addhd, addspt, buf)
; char *addcyl;		$4(sp).l	/* the address of #cyl */
; char *addhd;		$8(sp).l	/* the address of #hd */
; char *addspt;		$c(sp).l 	/* the address of #spt */
; char *buf;		$10(sp).l	/* the address of the date buffer */
; 
; returns: put the values of #cyl, #hd, #spt into the given addresses 
;-
	.globl _gparmfc
_gparmfc:
	move.l $10(sp),-(sp); push the buffer address into the stack
	bsr	   _gcparm		;
	adda   #4,sp		; clean up stack
	move.l $4(sp),a0	; a0 -> data buffer
	move.w d0,(a0)		; move the #cyl into its addr
	move.l $8(sp),a0	; a0 -> data buffer
	move.w d1,(a0)		; move the #hd into its addr
	move.l $c(sp),a0	; a0 -> data buffer
	move.w d2,(a0)		; move the #spt into its addr
	rts



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


.if	!DRIVER

;+
; recal() - moves the R/W heads from anywhere on the disk to cylinder 0.
;
; recal(pdev)
; WORD	pdev;	$4(sp).w
;-
	.globl	_recal
_recal:	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; write drive #
	move.b	#0,IDEDOR	; enable interrupt
	move.b	#RECAL,IDECR	; write command code
	bra	w4int		; go wait for interrupt


;+
; verify() - functions similarly to read() except that no data is
;	     transferred to the host.
;-
	.globl	_verify
_verify:
	move.w	$e(sp),d0	; d0.w = physical unit #
	move.l	4(sp),d1	; d1.l = starting logical sector #
	bsr	set_dhcs	; set drive#, head#, cylinder# and sector#
	move.l	$a(sp),a0	; a0 -> buffer to write from
	move.b	9(sp),IDESC	; set sector count
	move.b	#0,IDEDOR	; enable interrupt
	move.b	#VERIFY,IDECR	; set command code
.0:	bsr	w4int		; wait for interrupt
	bne.s	.1		; if has error, return
	tst.b	IDESC		; more to verify?
	bne.s	.0		; if so, continue
	moveq	#0,d0		; everything's fine
.1:	rts


;+
; fmtunt() - formats a unit
;	   - always formats sectors as good ones.
;	   - interleave 1:1.
;
; fmtunt(pdev)
; WORD	pdev;	4(sp).w
;-
	.globl	_fmtunt
_fmtunt:
	move.l	d3,-(sp)	; save d3
	move.w	8(sp),-(sp)	; set selected unit to the appropiate
	bsr	setmode		;  mode and get drive parameters in d1-d3
	addq	#2,sp		; clean up stack
	tst.w	d0		; setmode() ok?
	bne	.5		; if not, return
				; else fill format data
	bsr	clrsbuf		; clear scratch buffer
	moveq	#1,d0		; d0 = sector # (starts with sector 1)
	lea	sbuf,a1		; a1 -> _identify() data buffer
.0:	move.b	d0,(a1)+	; set sector #
	clr.b	(a1)+		; format sector good
	addq.b	#1,d0		; next sector #
	cmp.b	d0,d3		; all sector # set?
	bcc.s	.0		; if not, continue
				; format unit
	move.w	8(sp),d3	; d3.w = physical unit #
	andi.b	#7,d3		; mask off flags (if any)
	lsl.b	#4,d3		; shift physical unit # into place
	move.b	d3,IDESDH	; set physical unit #
	subq.w	#1,d1		; dbra likes one less
	subq.w	#1,d2		; dbra likes one less
	move.w	d2,d3		; d3 = # heads - 1
	lea	sbuf,a0		; a0 -> format data
.1:	move.w	d3,d2		; reinitialize head number for next cylinder
.2:	movem.l	d1-d2/a0,-(sp)	; save cylinder and head count
	bsr	_fmttrk		; format track of current cylinder and head
	bne.s	.4		; if fail, return
.3:	movem.l	(sp)+,d1-d2/a0	; restore cylinder and head count
	dbra	d2,.2		; for all heads
	dbra	d1,.1		; for all cylinders
	moveq	#0,d0		; everything's fine
	bra.s	.5		; and return
.4:	adda.l	#12,sp		; else clean up stack
.5:	move.l	(sp)+,d3	; restore d3
	rts



;+
; setmode() - set the unit to its default mode and return the default
;		drive parameters.
;
; setmode(pdev)
; WORD	pdev;	$4(sp).w
;
; Returns:
;	d0.w = 0	if successful
;	     = non-0	if failed
;	d1.w = # of default cylinders
;	d2.w = # of default heads
;	d3.w = # of default sectors per track
;
; Comments:
;	This routine distinguishes the Conner drives from other vendors'
; because Conner saves their default values in a reserved area. (Sigh)
; Furthermore, since the default parameters are not stored on the Conner 
; CP2024 (20Mb) drives at all, they are being hardwired into the code. 
; (I know, it's terrible!)
;-
setmode:
	pea	sbuf		; scratch buffer
	move.w	8(sp),-(sp)	; physical unit #
	bsr	_identify	; identify(pdev, buf)
	addq.w	#6,sp		; clean up stack
	tst.w	d0		; successful?
	bne	smend		; if not, return
				; else 
	lea	sbuf,a1		; a1 -> data buffer
	move.l	#sbuf+MDLNUM,-(sp)
	pea	conner
	move.w	#6,-(sp)
	bsr	strcmp		; compare model# with "Conner"
	adda	#10,sp		; clean up stack
	tst.w	d0		; is unit a Conner drive?
	bne.s	other		; if not, handle the normal way
				; else
	move.l	#sbuf+CONMDL,-(sp)
	pea	cp2024
	move.w	#6,-(sp)
	bsr	strcmp		; compare model# with "CP2024"
	adda	#10,sp		; clean up stack
	tst.w	d0		; is unit the CP2024 (Kato 20Mb)?
	bne.s	nkato		; if not, parms at reserved area
				; else return default values of CP2024
	move.w	#CP20NCYL,d1	; d1.w = # of cylinders
	move.w	#CP20NHEAD,d2	; d2.w = # of heads
	move.w	#CP20NSPT,d3	; d3.w = # of spt
	bra.s	smend		; no need to init parm, just return

				; for other Conner drives
nkato:	move.w	CPNCYL(a1),d1	; get parameters at Conner
	moveq	#0,d2		;   reserved location
	move.b	CPNHEAD(a1),d2
	moveq	#0,d3
	move.b	CPNSPT(a1),d3
	bra.s	sminit		; go do initparm

other:	move.w	NCYL(a1),d1	; d1.w = # of cylinders
	move.w	NHEAD(a1),d2	; d2.w = # of heads
	move.w	NSPT(a1),d3	; d3.w = # of sectors per track

sminit:	movem.l	d1-d3,-(sp)	; save drive parameters
	move.w	d3,-(sp)	; sectors per track
	move.w	d2,-(sp)	; # of heads
	move.w	20(sp),-(sp)	; physical unit #
	bsr	_initparm	; set drive to default mode
	addq.w	#6,sp		; clean up stack
	movem.l	(sp)+,d1-d3	; restore drive parameters

smend:	rts


;+
; clrsbuf() - clear the scratch buffer
;-
clrsbuf:
	movem.l	d0/a0,-(sp)	; save d0 and a0
	lea	sbuf,a0		; a0 -> scratch buffer
	move.w	#127,d0		; d0 = counter
.0:	clr.l	(a0)+		; clear 4 bytes
	dbra	d0,.0		; repeat until done
	movem.l	(sp)+,d0/a0	; restore d0 and a0
	rts


;+
; fmttrk() - formats a track with format data provided.
;
; Passed:
;	d1.w = cylinder #
;	d2.w = head #
;	a0.l -> format data
;-
	.globl	_fmttrk
_fmttrk:
	andi.b	#$f0,IDESDH	; erase previous head #
	or.b	d2,IDESDH	; set new head #
	move.b	d1,IDECL	; set cylinder low
	lsr.w	#8,d1		; d0.b = cylinder high
	move.b	d1,IDECH	; set cylinder high
	move.b	#0,IDEDOR	; enable interrupt

	tst.b	_useblit	; use BLiTTER?
	beq.s	.0		; if not, no need to init it
	moveq	#1,d0		; write through BLiTTER
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#FMTTRK,IDECR	; set command code
.1:	btst.b	#DRQ,IDEASR	; DRQ?
	beq.s	.1		; if not, wait longer

	bsr	wrtbuf		; write format data to sector buffer
	bra	w4int


;+
; seek() - initiates a seek to the track and selects the head 
;	   specified in the Task File.
;
; seek(pdev, head, cyl)
; WORD	pdev;	$4(sp).w
; WORD	head;	$6(sp).w
; WORD	cyl;	$8(sp).w
;-
	.globl	_seek
_seek:	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags
	lsl.b	#4,d0		; shift unit # to place
	or.b	7(sp),d0	; b4 of d0 = drive #; b3-b0 of d0 = head #;
	move.b	d0,IDESDH	; set drive and head #
	move.b	#0,IDEDOR	; enable interrupt
	move.b	9(sp),IDECL	; set cylinder low
	move.b	8(sp),IDECH	; set cylinder high
	move.b	#SEEK,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; diag() - performs the internal diagnostic tests implemented by 
;	   the drive.
;-
	.globl	_diag
_diag:	move.b	#0,IDEDOR	; enable interrupt
	move.b	#DIAG,IDECR	; set command code
	bra	w4int


;+
; initparm() - enables the host to set the head switch and cylinder
;	       increment points for multiple sector operations.
;
; initparm(pdev, head, spt)
; WORD 	pdev;	4(sp).w
; WORD	head;	6(sp).w
; WORD	spt;	8(sp).w
;-
	.globl	_initparm
_initparm:
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags
	lsl.w	#4,d0		; shift it into place
	move.b	d0,IDESDH	; set physical unit #
	move.w	6(sp),d0	; d0 = # of heads
	subq.b	#1,d0		; maximum head #
	or.b	d0,IDESDH	; set head #
	move.b	9(sp),IDESC	; set sectors per track
	move.b	#0,IDEDOR	; enable interrupt
	move.b	#INITPARM,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; rsbuf() - allows the Host to read the current contents of the
;	    drive's sector buffer.
;
; rsbuf(pdev, buf)
; WORD	pdev;	4(sp).w
; BYTE	*buf;	6(sp).l
;-
	.globl	_rsbuf
_rsbuf:	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.w	#4,d0		; shift it into place
	move.b	d0,IDESDH	; set physical unit #
	move.l	6(sp),a0	; a0 -> buffer
	move.w	#256,d1

	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, don't use it
	moveq	#0,d0		; it's a read
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#0,IDEDOR	; enable interrupt
	move.b	#RSBUF,IDECR	; set command code
	bsr	w4int		; go wait for interrupt
	tst.w	d0		; successful?
	bmi.s	.1		; if timed-out, return
	btst	#DRQ,d0		; DRQ?
	beq.s	.1		; if not, return with error

	bsr	readbuf		; read data
	moveq	#0,d0		; everything is fine
.1:	rts 


;+
; wsbuf() - allows the Host to overwrite the contents of the drive's
;	    sector buffer.
;
; wsbuf(pdev, buf)
; WORD	pdev;	4(sp).w
; BYTE	*buf;	6(sp).l
;-
	.globl	_wsbuf
_wsbuf:	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.w	#4,d0		; shift it into place
 	move.b	d0,IDESDH	; set physical unit #
	move.l	6(sp),a0	; a0 -> buffer
	move.w	#256,d0		; d0 = word count

	tst.b	_useblit	; BLiTTER exists?
	beq.s	.0		; if not, don't use it
	moveq	#0,d0		; it's a read
	bsr	initblit	; initialize the BLiTTER

.0:	move.b	#WSBUF,IDECR	; set command code
.1:	btst	#DRQ,IDESR	; DRQ?
	beq.s	.1		; if not, wait some more

	bsr	wrtbuf		; write data
	moveq	#0,d0		; everything is fine
	rts


;+
; standby() - set drive to Standby mode
;
; standby(pdev)
; WORD	pdev;	4(sp).w		; physical unit #
;-
	.globl	_standby
_standby:
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#STANDBY,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; active() - set drive to Active mode
;
; active(pdev)
; WORD	pdev;	4(sp).w		; physical unit #
;-
	.globl	_active
_active:
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#ACTIVE,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; sbwto() - set drive to Standby mode with timeout counter (in 5s increments)
;
; sbwto(pdev, timeout)
; WORD	pdev;		4(sp).w		; physical unit #
; WORD	timeout;	6(sp).w
;-
	.globl	_sbwto
_sbwto:	
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	7(sp),IDESC	; set timeout counter
	move.b	#SBWTO,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; ssc() - set sector count wrt current mode of drive
;
; ssc(pdev)
; WORD	pdev;	4(sp).w		; physical unit #
;-
	.globl	_ssc
_ssc:	
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#SSC,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; sbres() - set drive to Standby mode.
;	  - drive will not wake up until reset is sent to drive
;
; sbres(pdev)
; WORD	pdev;	4(sp).w		; physical unit #
;-
	.globl	_sbres
_sbres:	
	move.w	4(sp),d0	; d0 = physical unit #
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#SBRES,IDECR	; set command code
	bra	w4int		; go wait for interrupt


;+
; slave() - test if the slave drive exists
;
; Returns: 0 - if slave does not exist
;	   1 - if slave exists
;-
	.globl	_slave
_slave:	moveq	#0,d0		; assume slave does NOT exist
	bset.b	#4,IDESDH	; set drive bit to 1 (slave)
	btst.b	#DRDY,IDESR	; is slave ready?
	beq.s	.0		; if not, no slave
	moveq	#1,d0		; else, slave exists
.0:	rts


;+
; _iderdy() - test if the IDE drive is ready
;
; Passed:
;	d0.b = IDE drive unit #
;
; Returns: 0 - if drive is NOT ready
;	   1 - if drive is ready
;-
	.globl	_iderdy
_iderdy:
	andi.b	#7,d0		; mask off flags (if any)
	lsl.b	#4,d0		; shift unit # to place
	move.b	d0,IDESDH	; set drive #
	move.b	#$50,d1		; ready status
	move.l	#IDERDY,d0	; set up timer
	add.l	_hz_200,d0
ir0:	cmp.b	IDEASR,d1	; is drive ready and not busy?
	beq.b	ir1		; if so, return with drive ready
	cmp.l	_hz_200,d0	; time-out yet?
	bcc.b	ir0		; if not, wait longer
	moveq	#0,d0		; else return drive NOT ready
	rts
ir1:	moveq	#1,d0		; else, drive is ready
	rts


.data
sbuf:	dcb.b	512,0		; scratch buffer

.endif	;!DRIVER


