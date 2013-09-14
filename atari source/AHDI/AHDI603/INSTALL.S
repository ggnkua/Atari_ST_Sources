;+
; 06-Jun-1989	ml	Created this.
;
; 19-Jul-1989	ml	Added in check for existence of SCSI on system.
;			If SCSI doesn't exist, don't look for SCSI drives.
;			This enable a TT bootable cartridge bootable on an
;			ST also.
;
;			Added in check for existence of cache on CPU.
;			If cache doesn't exist, no need to flush them
;			in Rwabs() reads.
;
;
; 15-Aug-1989	ml.	Added in waiting loop of 10 sec to allow time for 
;			SCSI unit 0 to spin up, when booting from floppy.
; 02-Mar-1990	ml. 	Toke out wait loop.
;
;					    ; wait for drive to be ready
;			movea.l	#_hz_200,a3 ; a3.l -> hz_200 clock
;			move.l	(a3),d3	    ; d3.l = expiration time
;			adda.l	#2000,d3    ; wait at most 10 sec
;		    .0: move.w	#8,-(sp)    ; is SCSI unit #0 ready yet?
;			bsr	_untrdy
;			addq.l	#2,sp	    ; clean up stack
;			tst.w	d0	    ; ready?
;			beq.s	.1	    ; if so, start driver code
;			cmp.l	(a3),d3	    ; pass expiration time?
;			bcc.s	.0	    ; if not, wait longer
;		    .1:			    ; else, start driver code anyway
;
;
; 31-Jul-1990	ml	Added code to initialize SCSI vectored-interrupts.
;
; 20-Sep-1990	ml	Added code to check for existence of the IDE bus,
;			and handle drives on the bus if it exists.
;
; 02-Apr-1991	ml	Use pbuf instead of sendata when calling inquiry().
;
; 03-Apr-1991	ml	Since maximum IDE unit # may change depending on the
;			existence of the slave drive, the check for stopping
;			the scan (at i_sasi4) needs to be modified.
;
; 09-Jul-1991	ml	Added code to check for BLiTTER's ability to blit
;			hard drive data.  If BLiTTER cannot blit hard drive
;			data, assume it doesn't exist at all.
;
; 28-Aug-1991	ml	Added code to print message notifying the user if
;			the BLiTTER is used to transfer hard disk data on
;			the IDE bus.
;
; 30-Aug-1991	ml	Scan physical units as specified by how2scan, 
;			acsi2scan, scsi2scan and ide2scan.  (Refer to 
;			comments in driver.s) 
;
; 06-Sep-1991	ml	Added messages to show the progress of the physical
;			units scan.
;
; 13-Sep-1991	ml	Deleted code that takes care of the slave (unit 1.)
;			There will ONLY be IDE unit 0.
;
; 16-Sep-1991	ml	Instead of checking a flag to decide if BLiTTER can 
;			blit hard disk data (comments on 09-Jul-91,) check
;			if driver is running on the ST Book.  If so, BLiTTER
;			should NOT be used for hard disk data transfer.
;
; 18-Sep-1991	ml	Assuming that an IDE drive will boot up in a mode as
;			specified by the parameters returned by the Identify
;			command, there is no need to do the Initparm command
;			at boot time.
;
; 24-Sep-1991	ml	To show info of devices at boot time, _slwacsi has
;			to be set to take care of slow ACSI devices such
;			as the laser printer.
;
; 11-Oct-1991	ml	Instead of extracting the IDE drive parameters from
;			the data returned by identify(), call _gcparm() to
;			have that taken care of.
;
; 22-Oct-1991	ml	Added code to check if messages should be printed.
;
; 16-Jan-1992	ml	At i_sasi4, right after IDE drives are scanned, it
;			should branch to scan_scsi instead of do_scsi.
;
; 03-Mar-1992	ml	Added code to check if an IDE drive exists on the
;			IDE bus before sending it a command.
;-

.include	"defs.h"
.include	"error.h"
.include	"sysvar.h"
.include	"mfp.h"
.include	"acsi.h"
.include	"scsi.h"
.include	"spscsi.h"
.include	"ide.h"
.include	"macros.h"
.include	"68030.s"

;+
; External routines
;-
.extern	_ahdi_rw, _inquiry, resetscsi, _untrdy
.extern	fdnxt, fdpart, fgnxt, fgpart, getlhw, _getcookie
.extern _identify, _gcparm, _drvxst
.extern	resetspscsi

;+
; External variables
;-
.extern	cookie,	cookptr, machine
.extern	defbigsect, defsqnpart, defsqcnpart, maxssz, npart
.extern	ext, extrt, extvol, memalloc, savssp, bootloaded, pbuf
.extern	hbpb, hmediach, hrw, o_bpb, o_mediach, o_rw
.extern	sizr, sratio, xst, mcflgs, embscsi
.extern	cpun, pun, puns, numacsi, numscsi
.extern _cachexst, idedp, _useblit
.extern how2scan, acsi2scan, scsi2scan, ide2scan
.extern	_slwacsi
.extern phase_changed, dmac_int
.extern	_spscsixst

;+
;for debugging
.extern badcombo
;-

;+
; External labels
;-
.extern	i_sasi6

.if	VI		    ; if vectored-interrupts desired
.extern	scsi_isr
.extern	dmac_isr
.endif	;VI


_MCH	equ	$5f4d4348   ; _MCH

scsixst:    dc.b    0	    ; 0: if SCSI bus doesn't exist
acsixst:    dc.b    0	    ; 0: if ACSI bus doesn't exist
	    .globl  idexst
idexst:	    dc.b    0	    ; 0: if IDE bus doesn't exist
.even


;
;+
; Driver Installation
;-
	.globl	i_sasi1
i_sasi1:
	move.l	d0,memalloc		; record amount of memory available
	movea.l	#msg_load,a0
	bsr	prnstr
	tst.w	bootloaded		; if boot-loaded, don't Super()
	bne.s	inqmch			;  and go inquire the kind of machine
	clr.l	-(sp)			; it's a bird...
	move.w	#$20,-(sp)		;    ... it's a plane ...
	trap	#1			;      ... no, its:
	addq.l	#6,sp			; SOOUPERUSER!
	move.l	d0,savssp		; "Faster than a prefetched opcode..."

inqmch:	move.l	#machine,-(sp)		; ptr to machine type
	move.l	#_MCH,-(sp)		; looking for _MCH cookie
	bsr	_getcookie
	addq.w	#8,sp			; clean up stack
					; check existence of cache
	sf	_cachexst		; assume no cache on CPU
	movea.l	IINS,a0			; save orig illegal instn. vector
	move.l	#ncache,IINS		; install our vector
	movea.l	sp,a1			; save stack pointer
	movecacrd0			; does a cache exist?
	st	_cachexst		; cache exists
ncache:	move.l	a0,IINS			; restore orig illegal instn. vector
	move.l	a1,sp			; restore stack pointer

chkide:					; check if IDE bus exists
	sf	idexst			; assume it doesn't
	movea.l	BERR,a1			; save original bus error vector
	move.l	#nide,BERR		; install our own vector
	movea.l	sp,a2			; save current stack pointer
;	move.b	bIDE,d0			; try to access the IDE bus
	move.b	bIDE+$10,d0		; try to access the IDE bus
;+
; Mar 04 1992 - take IDE out of reset (should be done in the ROMs)
;
; Apr 22 1992 - hardware seems to be fixed, so comment this out.
;
; July 14 1992 - location of IDE reset bit has been moved from
;		 bit 6 to bit 7, need to IDE out of reset until 
;		 ROMs is fixed.
;
; July 31 1992 - the ROMs is clearing the reset, so comment this
;		 out (again!)
;
;	movem.l	a0-a2,-(sp)		; save a0, a1 and a2
;	move.w	#$7f,-(sp)		; bit mask to set bit 7 to 0
;	move.w	#29,-(sp)		; offgibit()
;	trap	#14
;	addq.l	#4,sp			; clean up stack
;	movem.l	(sp)+,a0-a2		; restore a0, a1 and a2
;-

;+
; Mar 09 1992 - test if there is an IDE drive attached
;
	TMOUT	#1000,d1		; wait at most 5 seconds
chki0:	cmpi.b	#$50,IDESR		; is drive ready?
	beq.s	chki1
	CNTDN1	d1,chki0
	bra.s	nide			; there is no IDE drive
chki1:	move.b	#$5a,IDESC		; else make sure there is a drive
	move.b	IDESC,d0
	cmpi.b	#$5a,d0			; can we read write the registers
	bne.s	nide			; if not, there is no IDE drive
;-
	st	idexst			; if successful, IDE exists
					; check if BLiTTER exists 
	sf	_useblit		; assume it doesn't
	lea	pio_msg(pc),a0		; assume doing PIO for IDE
	movem.l	a0-a2,-(sp)		; save a0, a1 and a2
	move.w	#-1,-(sp)
	move.w	#64,-(sp)		; blitmode(-1)
	trap	#14
	addq.w	#4,sp			; cleanup stack
	movem.l	(sp)+,a0-a2		; restore a0, a1 and a2
	btst	#1,d0			; does BLiTTER exist?
	beq.s	noblit			; if not, fine, don't use it
	bsr	_stbook			; else
	tst.w	d0			; is driver running on ST Book?
	bne.s	noblit			; if so, don't use BLiTTER
;+
; for Debugging
	tst.b	badcombo		; bad COMBO chip?
	bne.s	noblit			; if so, don't use BLiTTER
;-
	st	_useblit		; else we can use BLiTTER
	lea	blit_msg(pc),a0		; using BLiTTER for I/O
noblit:	movem.l	a1-a2,-(sp)		; save a1 and a2
	bsr	prnstr			; print message regarding IDE I/O
	movem.l	(sp)+,a1-a2		; restore a1 and a2
nide:	move.l	a1,BERR			; restore original bus error vector
	move.l	a2,sp			; restore stack pointer

;+
; For Sparrow
	sf	_spscsixst		; assume we are NOT on a Sparrow
	cmpi.l	#SPARROW,machine	; are we?
	bne.s	chkscsi			; if not, test for regular SCSI
	st	_spscsixst		; else, there is Sparrow SCSI
	sf	scsixst			; but there is no regular SCSI
	sf	acsixst			; and there is no ACSI
	bra.s	chkdone			; done checking
;-

chkscsi:				; check if SCSI bus exists
	sf	scsixst			; assume it doesn't
	movea.l	BERR,a0			; save original bus error vector
	move.l	#nscsi,BERR		; install our own vector
	movea.l	sp,a1			; save current stack pointer
	move.b	bSCSI,d0		; try to access the SCSI bus
	st	scsixst			; if successful, SCSI exists
nscsi:	move.l	a0,BERR			; restore original bus error vector
	move.l	a1,sp			; restore stack pointer

chkacsi:				; check if ACSI bus exists
	sf	acsixst			; assume it doesn't
	movea.l	BERR,a0			; save original bus error vector
	move.l	#nacsi,BERR		; install our own vector
	movea.l	sp,a1			; save current stack pointer
	move.w	WDC,d0			; try to access the ACSI bus
	st	acsixst			; if successful, ACSI exists
nacsi:	move.l	a0,BERR			; restore original bus error vector
	move.l	a1,sp			; restore stack pointer

chkdone:
	move	#MAXLOG-1,d1
	moveq	#-1,d0			; a bad pun
	lea	pun,a0
ipun:	move.b	d0,(a0)+		; initialize all puns to be bad
	dbra	d1,ipun

	moveq	#0,d0			; clear d0
	move.w	d0,clun			; cur log unit# excluding A: & B:
	move.l	#4,cdbit		; current drive bit
	move.w	d0,puns			; no physical units found yet
	move.w	d0,numacsi		; no ACSI units found yet
	move.w	defbigsect,maxssz	; initialize maximum sector size
	move.l	_dskbufp,pbuf		; pbuf = buffer address of
	add.l	#512,pbuf		;	 root sector image

;+
; Scan physical units  (IDE, then SCSI, then ACSI)
;-

	tst.b	idexst			; does the IDE bus exist?
	beq.s	scan_scsi		; if not, go scan SCSI
	tst.b	how2scan		; how to scan?
	beq.s	st_ide			; if default way, start now
	btst.b	#0,ide2scan		; else IDE 0 specified?
	beq.s	scan_scsi		; if not, go scan SCSI	
					; start to scan IDE
st_ide:	movea.l	#idemsg,a0		; print announcement
	bsr	prnstr
	move.w	#$10,cpun		; init cpun to IDE unit 0
	bra	st_scan			; start scan now

scan_scsi:				; start to scan SCSI
	tst.b	_spscsixst		; Sparrow SCSI?
	bne.s	st_sc0			; if so, start scanning
	tst.b	scsixst			; does the SCSI bus exist?
	beq	scan_acsi		; if not, go scan ACSI
st_sc0:	move.w	#7,cpun			; init cpun to SCSI unit 0
	move.b	#0,termscan		; init terminate scan flag
	tst.b	_spscsixst		; Sparrow SCSI?
	beq.s	st_sc1			; if not, it's regular SCSI
	bsr	resetspscsi		; else reset Sparrow SCSI
	bra.s	st_sc2
st_sc1:	bsr	resetscsi		; reset the SCSI bus
st_sc2:
.if	VI				; if vectored-interrupts desired
	andi.b	#$7f,IERA2		; disable interrupt to GPIP2SCSI
	andi.b	#$7f,IERB2		; disable interrupt to GPIP25
	ori.b	#$80,AER2		; GPIP2SCSI active high
	andi.b	#$df,AER2		; GPIP25 active low
	ori.b	#$80,IMRA2		; unmask GPIP2SCSI
	ori.b	#$80,IMRB2		; unmask GPIP25

	move.l	#scsi_isr,-(sp)		; -> to isr for GPIP2SCSI
	move.w	#$5f,-(sp)		; vector # for GPIP2SCSI
	move.w	#$5,-(sp)		; Setexc()
	trap	#13
	addq.w	#8,sp			; clean up stack

	move.l	#dmac_isr,-(sp)		; -> to isr for GPIP25
	move.w	#$57,-(sp)		; vector # for GPIP25
	move.w	#$5,-(sp)		; Setexc()
	trap	#13
	addq.w	#8,sp			; clean up stack

	move.b	SCSIREI,d0		; read status to clear IRQ
	ori.b	#$80,IERA2		; enable interrupts to GPIP2SCSI
	ori.b	#$80,IERB2		; enable interrupts to GPIP25
.endif	;VI
					; start to scan SCSI
	tst.b	how2scan		; how to scan?
	beq.s	st_scsi			; if default way, start now
	tst.b	scsi2scan		; else any SCSI puns specified?
	beq	scan_acsi		; if none, go scan ACSI
					
st_scsi:				; else start to scan SCSI
	movea.l	#scsimsg,a0		; print announcement
	bsr	prnstr

do_scsi:
	move.w	cpun,d0			; d0 = current physical unit #
	addq.w	#1,d0			; d0 = next physical unit #
	move.w	d0,cpun			; update current physical unit #
	cmpi.w	#SCSIUNT,d0		; unit # too high?
	bhi	scan_acsi		; if so, go scan ACSI
	tst.b	how2scan		; else how to scan?
	beq.s	defscsi			; (scan the default way)
					; scan as specified by scsi2scan
	andi.b	#7,d0			; d0 = bit # to test
nxtscsi:
	btst.b	d0,scsi2scan		; scan this unit?
	bne	i_sasi3			; if so, start now
	addq.w	#1,d0			; else, test next bit
	cmpi.w	#MAXSCSI,d0		; tried last available unit already?
	bcc	scan_acsi		; if so, go scan ACSI
	addq.w	#1,cpun			; else try next physical unit
	bra.s	nxtscsi

defscsi:
	tst.b	termscan		; terminate scan?
	beq	i_sasi3			; if not, continue
					; else start to scan ACSI
scan_acsi:
	tst.b	acsixst			; does the ACSI bus exist?
	beq	i_sasi5			; if not, go finish up
	move.w	#-1,cpun		; get ready for ACSI unit 0
	move.b	#0,termscan		; init terminate scan flag
	tst.b	how2scan		; how to scan?
	beq.s	st_acsi			; if default way, start now
	tst.b	acsi2scan		; else any ACSI puns specified?
	beq	i_sasi5			; if none, go finish up

st_acsi:		    		; else start to scan ACSI
	movea.l	#acsimsg,a0		; print announcement
	bsr	prnstr

do_acsi:				; start to scan ACSI
	move.w	cpun,d0			; d0 = current physical unit #
	addq.w	#1,d0			; next physical unit
	move.w	d0,cpun			; update current physical unit #
	cmpi.w	#ACSIUNT,d0		; unit # too high?
	bhi	i_sasi5			; if so, go finish up
	tst.b	how2scan		; else how to scan?
	beq.s	defacsi			; (scan the default way)
					; scan as specified by acsi2scan
	andi.b	#7,d0			; d0 = bit # to test
nxtacsi:
	btst.b	d0,acsi2scan		; scan this unit?
	bne	i_sasi3			; if so, start now
	addq.w	#1,d0			; else, test next bit
	cmpi.w	#MAXACSI,d0		; tried last available unit already?
	bcc	i_sasi5			; if so, go finish up
	addq.w	#1,cpun			; else try next physical unit
	bra.s	nxtacsi

defacsi:
	tst.b	termscan		; terminate scan?
	bne	i_sasi5			; if so, go finish up

i_sasi3:
	moveq	#1,d3			; try twice if necessary
st_scan:
	move.w	d3,-(sp)		; save d3
	move.w	cpun,d0			; d0.b = current device #
	andi.w	#7,d0
	add.b	#'0',d0
	move.b	d0,untnum+7
	movea.l	#untnum,a0		; print current device #
	bsr	prnstr
	move.w	(sp)+,d3		; restore d3

do_inq:	movea.l	pbuf,a0			; a0 = address of sense data buffer
	clr.l	(a0)			; fill first 4 bytes with 0
	move.l	a0,-(sp)		; buffer for data inquired
	btst.b	#4,cpun+1		; is it an IDE unit?
	beq	nonide			; if not, do inquiry()
					; else
ide0:	move.w	cpun,-(sp)		; do identify()
	bsr	_identify
	addq.w	#6,sp			; clean up stack
	tst.w	d0			; successful?
	bne	i_sasi4			; if not, try next drive
					; else, get phys parameters of unit
	movea.l	pbuf,a0			; a0 -> beginning of data buffer
	move.b	#0,EMDL(a0)		; null-terminate model number
	add.l	#MDLNUM,a0		; a0 -> model number
	bsr	prnstr			; print device name

	movea.l	#eos,a0			; terminate message
	bsr	prnstr
	
	move.l	pbuf,-(sp)		; beginning of data buffer
	bsr	_gcparm			; get current drive parameters
	addq.l	#4,sp			; clean up stack	
	lea	idedp,a1		; a1 -> beginning of idedp struct
	move.w	d1,(a1)+		; store # of heads
	move.w	d2,(a1)			; store # of physical sectors/track
	bra	tryread			; try reading from unit

nonide:	st	_slwacsi		; in case cpun is a slow ACSI dev
	move.w	#56,-(sp)		; requesting 56 bytes of data
	move.w	cpun,-(sp)		; current physical unit
	bsr	_inquiry		; inquiry(physunit, len, buf)
	addq.l	#8,sp			; clean up stack
	sf	_slwacsi		; clear flag for slow ACSI
	tst.w	d0			; was inquiry() successful?
	bmi	i_sasi4			; if timed-out, done with this unit
	dbeq	d3,do_inq		; else try inquiry() a 2nd time
	tst.w	d0
	beq.s	inqdone			; if 2nd inquiry() oks, move on

	movea.l	#noid,a0		; else print id unavailable message
	bsr	prnstr
	cmp.w	#CHKSTATUS,d0		; was it a check condition status?
	bne	tryread			; if so, try reading device
	bra	nxtpun			; else, done with this unit

inqdone:
	movea.l	pbuf,a0			; a0 -> beginning of data buffer
	move.b	#0,32(a0)		; null-terminate string
	addq.l	#8,a0
	bsr	prnstr			; print device name
	
	movea.l	#eos,a0			; terminate message
	bsr	prnstr
	
	movea.l	pbuf,a0			; a0 = address of sense data
	move.b	(a0),d0			; d0 = device type
	cmp.b	#$07,d0			; Optical disk?
	beq.s	gdev			; if so, ok
	tst.b	d0			; else hard disk?
	bne	nxtpun			; if not, try next unit
gdev:	btst.b	#3,cpun+1		; a SCSI unit?
	bne.s	chkrmb			; if so, go check if it's removable
	move.w	cpun,d1			; else it's ACSI, d1 = physical unit #
	andi.w	#7,d1			; mask off flags
	bset.b	d1,embscsi		; mark ACSI unit as embedded scsi

chkrmb:	btst.b	#7,1(a0)		; removable drive?
	beq.s	tryread			; if not, go try reading from it
	bset.b	#6,cpun+1		; else mark unit as removable

tryread:				; try reading from current unit
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	clr.w	-(sp)			; sectno = 0; root sector
	move.w	#1,-(sp)		; 1 sector
	move.l	pbuf,-(sp)		; buffer
	move.w	#$a,-(sp)		; read in phys mode/ignore media change
	bsr	_ahdi_rw		; ahdi_rw(0xa, pbuf, 1, 0, cpun)
	adda	#12,sp			; clean up stack
	move.w	d0,rdret		; was read ok?
	beq.s	found1			; if so, found a new drive
	btst.b	#6,cpun+1		; else was drive removable?
	beq.s	endchn			; if not, end of chain
	
found1:	addq.w	#1,puns			; else found a physical unit
	btst.b	#4,cpun+1		; is it an IDE unit?
	bne.s	howppu			; if so, how is it partitioned?
	btst.b	#3,cpun+1		; else is it a SCSI unit?
	beq.s	incacsi			; if not, assume it's an ACSI unit
	addq.w	#1,numscsi		; else increment SCSI count
	bra.s	howppu
incacsi:
	addq.w	#1,numacsi		; else increment ACSI count
howppu:	bsr	ppu			; find out how it is partitioned
	tst.w	d0			; ppu successful?
	beq.s	nxtpun			; go on normally
					; else find out what's wrong
	cmpi.w	#E_CHNG,d0		; media changed?
	beq	i_sasi3			; if so, retry this unit
	bra.s	nxtpun			; else try next physical unit

i_sasi4:
	movea.l	#noresponse,a0		; print the no response message
	bsr	prnstr

endchn:	move.b	#1,termscan		; set terminate scan flag

nxtpun:	andi.w	#$1f,cpun		; keep unit # and drive type flags
	btst.b	#4,cpun+1		; just scanned IDE units?
	bne	scan_scsi		; if so, scan SCSI units
	btst.b	#3,cpun+1		; else, scanning SCSI units?
	bne	do_scsi			; if so, continue
	bra	do_acsi			; else, scan ACSI units

i_sasi5:
	clr.l	a5			; zeropage ptr
	move.l	hdv_bpb(a5),o_bpb
	move.l	hdv_rw(a5),o_rw
	move.l	hdv_mediach(a5),o_mediach

	move.l	#hbpb,hdv_bpb(a5)	; install our new ones
	move.l	#hrw,hdv_rw(a5)
	move.l	#hmediach,hdv_mediach(a5)
	move.l	#puns,pun_ptr(a5)

	move.l	#cookie,cookptr		; initialize cookie pointer
	bra	i_sasi6			; must get back into resident part


;
;+
; Partition physical unit
;-
ppu:	move.w	#0,npart		; no partition found for cpun yet
	btst.b  #6,cpun+1		; is cpun removable?
	beq.s	ppu0			; if not, go on normally
					; else, it's a syquest unit
	tst.w	rdret			; is there a cartridge in there?
	bne.s	squnit			; if not, go reserve #drv letters
					; else find the partitions
ppu0:	moveq	#MAXNPART,d1		; d1 = # partition entries to check
	movea.l	pbuf,a0			; a0 = ptr to root sector image
	cmpi.w	#SIG,DOSSIG(a0)		; is root sector in DOS format?
	bne.s	ppu1			; if not, handle it the ST way
	bsr	dosppu			; else, handle it the DOS way
	bra.s	ppu2
ppu1:	bsr	gemppu
ppu2:	tst.w	d0			; successful?
	bne.s	ppud			; if not, return
					; else see if it's removable
	btst.b	#6,cpun+1		; is cpun removable?
	beq.s	ppud			; if not, done
					; else check default log slot
	move.w	cpun,d1			; d1 = unit #
	btst	#3,d1			; a SCSI unit?
	bne.s	ppu3			; if so, use SCSI's defaults
	lea	defsqnpart,a0		; a0 -> sqnpart for ACSI
	bra.s	ppu4
ppu3:	lea	defsqcnpart,a0		; a0 -> sqnpart for SCSI
ppu4:	andi.w	#07,d1			; d1 = physical unit # (SCSI or ACSI)
	move.b	(a0,d1.w),d1		; d1 = least # of drives requested
	sub.w	npart,d1		; enough drives being set up?
	bls.s	ppud			; if so, done
	bra.s	sq0			; else, set up the rest

squnit:	move.w	cpun,d1			; d1 = unit #
	btst	#3,d1			; a SCSI unit?
	bne.s	ppu5			; if so, use SCSI's defaults
	lea	defsqnpart,a0		; a0 -> sqnpart for ACSI
	bra.s	ppu6
ppu5:	lea	defsqcnpart,a0		; a0 -> sqnpart for SCSI
ppu6:	andi.w	#07,d1			; d1 = physical unit # (SCSI or ACSI)
	move.b	(a0,d1.w),d1		; d1 = least # of drives requested
sq0:	subq.w	#1,d1
ppu7:	move.w	d1,-(sp)		; save count
	bsr	nxtd0
	move.w	(sp)+,d1		; restore count
	tst.w	d0			; a valid unit?
	bmi.s	ppud			; if not, return
	dbra	d1,ppu7
ppud:	rts


;
;+
; dosppu - find the DOS partitions of the drive and set up
;	   appropiate data structures.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Returns:
;	d0 = 0			if no error
;	   = negative #		if error found
;-
dosppu:	adda.w	#DOSPM,a0		; a0 = ptr to partition map
dppu0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fdpart			; find partitions
	tst.b	d0			; found any?
	beq.s	dppua			; not a valid partition
	cmpi.b	#5,d0			; extended partition?
	bne.s	dppu1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
dppux:	bsr	fdnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	dppua			; no logical drive found
	bmi.s	dppu2			; error returned
	cmpi.b	#5,d0			; extended volume?
	beq.s	dppux			; if so, go find next logical drive
dppu1:	movem.l	d1-d2/a0,-(sp)		; save registers
	bsr	nxtdrv			; general set up for clun
	movem.l	(sp)+,d1-d2/a0		; restore registers
	tst.w	d0			; set up successful?
	beq.s	dppu3			; if successful, continue
dppu2:	addq.l	#8,sp			; else clean up stack
	bra.s	dppur			; and return
dppu3:	tst.b	ext			; clun is in ext partition?
	bne.s	dppux			; if so, go find next ext vol
dppua:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#16,a0			; index to next entry in pmap
	dbra	d1,dppu0
	moveq	#0,d0			; get here with no error!
dppur:	rts


;
;+
; gemppu - find the GEMDOS partitions of the drive and set up
;	   appropiate data structures.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Returns:
;	d0 = 0			if no error
;	   = negative #		if error found
;-
gemppu:	adda.w	#HDSIZ,a0		; a0 = ptr to hard disk size
	tst.l	(a0)+			; size? (a0 = ptr to start of pmap)
	beq.s	gppu4			; if =0, no drive will exist
gppu0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fgpart			; find partitions
	tst.b	d0			; found any?
	beq.s	gppua			; not a valid partition
	cmpi.b	#'X',d0			; extended partition?
	bne.s	gppu1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
gppux:	bsr	fgnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	gppua			; no logical drive found
	bmi.s	gppu2			; error returned
	cmpi.b	#'X',d0			; extended volume?
	beq.s	gppux			; if so, go find next logical drive
gppu1:	movem.l	d1-d2/a0,-(sp)		; save registers
	bsr	nxtdrv			; general set up for clun
	movem.l	(sp)+,d1-d2/a0		; restore registers
	tst.w	d0			; set up successful?
	beq.s	gppu3			; if so, continue
gppu2:	addq.l	#8,sp			; else clean up stack
	bra.s	gppur			; and return
gppu3:	tst.b	ext			; clun is in ext partition?
	bne.s	gppux			; if so, go find next ext vol
gppua:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#12,a0			; index to next entry in pmap
	dbra	d1,gppu0
gppu4:	moveq	#0,d0			; get here with no error!
gppur:	rts


;
;+
; nxtdrv	(of clun, cdbit)
;
; Passed:
;	d1.l = starting sector # of clun
; Returns:
;	d0 = 0			if successful
;	   = negative #		if error occurred
;-
nxtdrv:	cmpi	#MAXLOG,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

	move.l	d1,-(sp)		; logical sector 0 of clun
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	move.w	#-1,-(sp)		; using a long sector number
	move.w	#1,-(sp)		; 1 sector
	move.l	#sbuf,-(sp)		; buffer address
	move.w	#$a,-(sp)		; read in physical mode
	bsr	_ahdi_rw		; ahdi_rw(0xa, sbuf, 1, -1, cpun, lsectno)
	adda	#16,sp			; clean up stack
	tst.w	d0			; read successful?
	bne	nxtr			; if not, return with error code

	movea.l	#sbuf,a0		; a0 = addr of boot sector image
	moveq	#$b,d0			; d0 = offset for bytes per sector
	bsr	getlhw
	tst.w	d0			; bytes per sector = 0?
	beq.s	nxtd1			; if so, assume ratio to be 1

	cmp.w	maxssz,d0		; max sect size >= curr sect size?
	bls.s	nxtd00			; if so, continue
	move.w	d0,maxssz		; else max sect size = curr sect size
nxtd00:	moveq	#9,d1			; d0 = sector size ratio
	lsr.w	d1,d0			;    = log sector size / 512
	move.w	d0,sizr			; sizr = sector size ratio
	bra.s	nxtd2			; go on

nxtd0:	cmpi	#MAXLOG,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

nxtd1:	move.w	#1,sizr			; sector size ratio assumes to be 1

nxtd2:	move.l	cdbit,d1		; get the bit to turn on
	move.l	_drvbits,d0		; tell TOS we have the drive
	or.l	d1,d0
	move.l	d0,_drvbits

	asl.l	#1,d1			; put in the next bit to turn on
	move.l	d1,cdbit

	move	clun,d0			; d0 = dev number
	lea	pun,a0			; a0 = ptr to pun table
	move.b	cpun+1,(a0,d0.w)	; clun belongs to cpun

	lea	sratio,a0		; a0 = ptr to sector size ratio table
	move.b	sizr+1,(a0,d0.w)	; save sector ratio of clun

	lea	xst,a0			; a0 = ptr to drive existence table
	move.b	#1,(a0,d0.w)		; clun may exist

	lea	mcflgs,a0		; a0 = ptr to mcflgs table
	move.b	#2,(a0,d0.w)		; clun is definitely changed

	addq.w	#1,clun			; clun = next possible lun
	addq.w	#1,npart		; one more partition found
	moveq	#0,d0			; gets here with no error
	bra.s	nxtr

nxtd9:	moveq	#-1,d0			; error!
nxtr:	rts


;+
; _Stbook() - to find out if driver is being run on the ST Book.
;
; Comments:
;	On the ST Book, the palette registers are only readable.
; So, to determine if the driver is being run on the ST Book, write
; to the palette registers, and then read them back.  If what read
; back isn't the same as what's been written, it IS an ST Book.
; The palette starts at address $ffff8240.
;-
	.globl  _stbook
_stbook:
	moveq	#1,d0		    ; assume it IS an ST Book
	cmpi.l	#STBOOK,machine	    ; is it?
	beq.s	.0		    ; if so, just return
	moveq	#0,d0		    ; else, return that it is NOT
;	move.l  $ffff8242,d2	    ; save palette registers old values
;	move.w  #$0555,$ffff8242    ; write new pattern to 1st register
;	move.w  #$0222,$ffff8244    ; write new pattern to 2nd register
;	moveq   #1,d0		    ; assume it IS an ST Book
;	move.w  $ffff8242,d1	    ; read from 1st palette register
;	and.w   #$0777,d1	    ; mask out useless bits
;	cmp.w   #$0555,d1	    ; value stays the same?
;	bne.s   .0		    ; if not, it IS an ST Book
;	move.w  $ffff8244,d1	    ; read from 2nd palette register
;	and.w   #$0777,d1	    ; mask out useless bits
;	cmp.w   #$0222,d1	    ; value stays the same?
;	bne.s   .0		    ; if not, it IS an ST Book
;	moveq   #0,d0		    ; else, it is NOT an ST Book
;	move.l  d2,$ffff8242	    ; restore palette registers
.0:	rts


;+
; Prnstr() - print the null-terminated string at the given address
;	     to the console
;
; Passed:
;	a0.l -> string to be printed
;-
.extern	silence
	.globl	prnstr
prnstr:	tst.b	silence		    ; print message?
	bne.s	.0		    ; if not, return
	move.l	a0,-(sp)	    ; string to be printed
	move.w	#9,-(sp)	    ; Cconws()
	trap	#1
	addq.l	#6,sp		    ; clean up stack
.0:	rts


;+
; Messages to be put up at load time
;-
blit_msg:
	dc.b	'Using BLiTTER for IDE I/O',13,10,0
.even
pio_msg:
	dc.b	'Doing programmed I/O for IDE',13,10,0
.even
;no_ide:
;	dc.b	'Do not scan for IDE drives',13,10,0
;.even
msg_load:
	dc.b	'Loading...',13,10
	dc.b	'------------------------',13,10
	dc.b	'Atari Hard Disk Driver  ',13,10
	dc.b	'AHDI 6.03 Sep. 18 1992  ',13,10
	dc.b	'------------------------',13,10

.if	DEBUG

.if	SPSCDMA
	dc.b	'Will DO SCSI DMA on SPARROW',13,10
.else
	dc.b	'Will NOT do SCSI DMA on SPARROW',13,10
.endif	;SPSCDMA

.if	SCDMA
	dc.b	'Will DO SCSI DMA if SCSI',13,10
.else
	dc.b	'Will NOT do SCSI DMA',13,10
.endif	;SCDMA

.if	SCFRDMA
	dc.b	'SCSI DMA to Fast RAM',13,10
.else
	dc.b	'NO SCSI DMA to Fast RAM',13,10
.endif	;SCFRDMA

	dc.b	'-----------------------',13,10
.endif	DEBUG

.if	VI
	dc.b	'Interrupts enabled for SCSI DMA',13,10
.endif	;VI

	dc.b	0
.even

idemsg:	dc.b	'IDE devices:',13,10,0
.even
scsimsg:
	dc.b	'SCSI devices:',13,10,0
.even
acsimsg:
	dc.b	'ACSI devices:',13,10,0
.even
untnum:	dc.b	'  Unit 0 - ',0
.even
noresponse:
	dc.b	'Not responding'
eos:	dc.b	13,10,0
.even
noid:	dc.b	'Identification unavailable',13,10,0
.even
	bss
clun:	    ds.w	1		; current logical unit
cdbit:	    ds.l	1		; current drive bit
sbuf:	    ds.b	512		; temporary buffer for i/o
rdret:	    ds.w	1		; return code from read
termscan:   ds.b	1		; # physical units to scan
	end

