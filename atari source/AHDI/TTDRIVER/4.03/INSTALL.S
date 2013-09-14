;+
; 06-Jun-1989	ml	Created this.
;
; 19-Jul-1989	ml	Added in check for existence of SCSI on system.
;			If SCSI doesn't exist, don't look for SCSI drives.
;			This enable a TT bootable cartridge bootable on an
;			ST also.
;
;			Added in check for existence of cache on CPU.
;			If cache doesn't exist, don't need to flush them
;			in Rwabs() reads.
;
; 31-Jul-1990	ml	Added code to initialize vectored-interrupts.
;-

.include	"defs.h"
.include	"error.h"
.include	"sysvar.h"
.include	"scsi.h"
.include	"68030.s"

;+
; External routines
;-
.extern	_ahdi_rw, _inquiry, resetscsi, _untrdy
.extern	fdnxt, fdpart, fgnxt, fgpart, getlhw, errcode

;+
; External variables
;-
.extern	cookie,	cookptr, defbigsect, defsqnpart, defsqcnpart, maxssz, npart
.extern	ext, extrt, extvol, memalloc, savssp, bootloaded, pbuf, sendata
.extern	hbpb, hmediach, hrw, o_bpb, o_mediach, o_rw
.extern	sizr, sratio, xst, mcflgs, embscsi, cpun, pun, puns, numacsi
.extern _cachexst

.extern phase_changed, dmac_int

;+
; External labels
;-
.extern	i_sasi6

.if	VI			; if vectored-interrupts desired
.extern	scsi_isr
.extern	dmac_isr
.endif	;VI


scsixst:	dc.b	0	; 0: if SCSI doesn't exist
.even

;
;+
; Driver Installation
;-
	.globl	i_sasi1
i_sasi1:
	move.l	d0,memalloc		; record amount of memory available
	pea	msg_load(pc)		; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp			; clean up stack
	tst.w	bootloaded		; if boot-loaded, don't Super()
	bne.s	chkcache		;  and go check for cache
	clr.l	-(sp)			; it's a bird...
	move.w	#$20,-(sp)		;    ... it's a plane ...
	trap	#1			;      ... no, its:
	addq.l	#6,sp			; SOOUPERUSER!
	move.l	d0,savssp		; "Faster than a prefetched opcode..."

chkcache:
	sf	_cachexst		; assume no cache on CPU
	movea.l	IINS,a0			; save orig illegal instn. vector
	move.l	#ncache,IINS		; install our vector
	movea.l	sp,a1			; save stack pointer
	movecacrd0			; does a cache exist?
	st	_cachexst		; cache exists
ncache:	move.l	a0,IINS			; restore orig illegal instn. vector
	move.l	a1,sp			; restore stack pointer

	move	#MAXUNITS-1,d1
	moveq	#-1,d0			; a bad pun
	lea	pun,a0
ipun:	move.b	d0,(a0)+		; initialize all puns to be bad
	dbra	d1,ipun

	move.w	#SCSIUNT,maxunt		; maxunt = highest SCSI unit #
	moveq	#0,d0			; clear d0
	move.w	d0,clun			; cur log unit# excluding A: & B:
	move.l	#4,cdbit		; current drive bit
	move.w	d0,puns			; no physical units found yet
	move.w	d0,numacsi		; no ACSI units found yet
	move.w	defbigsect,maxssz	; initialize maximum sector size
	move.l	_dskbufp,pbuf		; pbuf = buffer address of
	add.l	#512,pbuf		;	 root sector image

chkscsi:				; check if SCSI exists
	sf	scsixst			; assume it doesn't
	movea.l	BERR,a0			; save original bus error vector
	move.l	#nscsi,BERR		; install our own vector
	movea.l	sp,a1			; save current stack pointer
	move.b	bSCSI,d0		; try to access the SCSI bus
	st	scsixst			; if successful, SCSI exists
nscsi:	move.l	a0,BERR			; restore original bus error vector
	move.l	a1,sp			; restore stack pointer

	tst.b	scsixst			; does SCSI exist?
	beq	i_sasi4			; if not, scan for ACSI drives
	bsr	resetscsi		; else reset the SCSI bus
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

;+
; Aug-15-89 ml.	Added in waiting loop of 10 sec to allow time for SCSI 
;		unit 0 to spin up, when booting from floppy.  
; Mar-02-90 ml. Toke out wait loop.
;-
;					; wait for drive to be ready
;	movea.l	#_hz_200,a3		; a3.l -> hz_200 clock
;	move.l	(a3),d3			; d3.l = expiration time
;	adda.l	#2000,d3		; wait at most 10 sec
;.0:	move.w	#8,-(sp)		; is SCSI unit #0 ready yet?
;	bsr	_untrdy
;	addq.l	#2,sp			; clean up stack
;	tst.w	d0			; ready?
;	beq.s	.1			; if so, start driver code
;	cmp.l	(a3),d3			; pass expiration time?
;	bcc.s	.0			; if not, wait longer
					; else, start driver code anyway
.1:	move.w	#8,cpun			; current physical unit is SCSI 0

i_sasi3:
	moveq	#1,d3			; try twice if necessary
tryinq:	movea.l	#sendata,a0		; a0 = address of sense data buffer
	clr.l	(a0)			; fill first 4 bytes with 0
	move.l	a0,-(sp)		; buffer for data inquired
	move.w	#16,-(sp)		; only want 1st 16 bytes of data
	move.w	cpun,-(sp)		; current physical unit
	bsr	_inquiry		; inquiry(physunit, len, buf)
	addq.l	#8,sp			; clean up stack
	tst.w	d0			; was inquiry() successful?
	bmi	i_sasi4			; if timeout, end of chain
	dbeq	d3,tryinq		; else try again
	bne.s	tryread			; if not successful, try reading it
					; else if successful
	movea.l	#sendata,a0		; a0 = address of sense data
	tst.b	(a0)			; is unit a hard drive?
	bne	i_sasi4			; if not, end of chain
	btst.b	#3,cpun+1		; a SCSI unit?
	bne.s	chkrmb			; if so, check if it's removable
	move.w	cpun,d1			; else it's ACSI, d1 = physical unit #
	andi.w	#7,d1			; mask off flags
	bset.b	d1,embscsi		; mark ACSI unit as embedded scsi

chkrmb:	btst.b	#7,1(a0)		; removable drive?
	beq.s	tryread			; if not, go try read device
	bset.b	#6,cpun+1		; else mark unit as removable

tryread:
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
	btst.b	#6,cpun+1		; was drive removable?
	beq.s	i_sasi4			; if not, not a valid unit, return
	
found1:	addq.w	#1,puns			; else found a physical unit
	btst.b	#3,cpun+1		; SCSI or ACSI?
	bne.s	fscsi			; if bit set, it's SCSI
	addq.w	#1,numacsi		; else increment count for ACSI
fscsi:	bsr	ppu			; find out how it is partitioned
	tst.w	d0			; ppu successful?
	beq.s	nxtpun			; go on normally
					; else find out what's wrong
	cmpi.w	#E_CHNG,d0		; media changed?
	beq	i_sasi3			; if so, retry this unit
					; else try next physical unit
nxtpun:	andi.w	#$0f,cpun		; keep physical unit # + SCSI flag
	addq.w	#1,cpun			; next physical unit
	move.w	cpun,d0
	cmp.w	maxunt,d0		; last one yet?
	bls	i_sasi3			; if not, continue

i_sasi4:
	cmpi.w	#SCSIUNT,maxunt		; else, ACSI drives scanned yet?
	bne.s	i_sasi5			; if so, done
	move.w	#0,cpun			; else start to scan for ACSI drives
	move.w	#ACSIUNT,maxunt		; maxunt = highest ACSI unit #
	bra	i_sasi3

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
	bne.s	ppu1			; if not, assume it's in ST format
	bsr	dosppu			; else, handle it the DOS way
	bra.s	ppu2
ppu1:	bsr	gemppu
ppu2:	tst.w	d0			; successful?
	bne.s	ppud			; if not, return

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
					; else see if it's removable
	btst.b	#6,cpun+1		; is cpun removable?
	beq.s	ppud			; if not, done
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
nxtdrv:	cmpi	#MAXUNITS,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

	move.l	d1,-(sp)		; logical sector 0 of clun
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	move.w	#-1,-(sp)		; using a long sector number
	move.w	#1,-(sp)		; 1 sector
	move.l	#sbuf,-(sp)		; buffer address
	move.w	#$a,-(sp)		; read in physical mode
	bsr	_ahdi_rw		; ahdi_rw()
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
nxtd00:	divu	#512,d0			; d0 = sector size ratio
	move.w	d0,sizr			; sizr = sector size ratio
	bra.s	nxtd2			; go on

nxtd0:	cmpi	#MAXUNITS,clun		; have we already hit maximum?
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
; Messages to be put up at load time
;-
msg_load:
	dc.b	'Loading...',13,10
	dc.b	'-----------------------',13,10
	dc.b	'Atari Hard Disk Driver',13,10
	dc.b	'AHDI v4.03 Apr 04 1991',13,10
	dc.b	'-----------------------',13,10

.if	DEBUG
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

	bss
clun:	ds.w	1			; current logical unit
cdbit:	ds.l	1			; current drive bit
sbuf:	ds.b	512			; temporary buffer for i/o
rdret:	ds.w	1			; return code from read
maxunt:	ds.w	1			; # physical units to scan
	end

