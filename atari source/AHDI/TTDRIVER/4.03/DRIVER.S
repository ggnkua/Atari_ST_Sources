; Apr 04 1991 v4.03'

;------------------------------------------------------------------------
;									:
;	AHDI Hard Disk Driver for the Atari ST and TT			:
;	Copyright 1985,1986,1987,1988,1989,1990,1991 Atari Corp.	:
;	All Rights Reserved						:
;									:
;------------------------------------------------------------------------


;+
; Conditional Assembly Switches
;-
ospool		equ	1		; increase size of OS pool for ROM


;
;+
; Edit History
;
;
; 22-May-1989	ml	Started this from ahdi 3.00
;			Files created for this driver:
;			ACSI.S	    Low-level driver for ACSI.
;			CMDBLK.S    Builds packets for command blocks.
;			DOIT.S	    Sends packets out to SCSI or ACSI.
;			DRIVER.S    This file.
;			SCSI.S	    Low-level driver for SCSI.
;
; 25-May-1989	ml	Eliminated pread(), use _ahdi_rw() in physical mode
;			instead.
;
; 06-Jun-1989	ml	Created INSTALL.S for driver installation.
;
; 11-Jul-1989	ml	Rwabs() now handles DMA to fast RAM on ACSI side
;			also.  If no extra RAM was reserved for fast RAM
;			transferred, _dskbufp is used for the transfer.
;			(This is going to be really slow!!!)
;
; 19-Jul-1989	ml	If there is cache on CPU, Rwabs() reads will
;			flush both the I and D cache.
;
; 06-Sept-1989	ml	Use _FRB (in the cookie jar) for fast RAM transfer,
;			assuming _FRB WILL be there if there is fast RAM on
;			the machine.
;
; 20-Feb-1990	ml 3.64	Fixed bug in return code when doing ACSI odd transfer.
;			When successful, 0 should be returned.
;
; 02-Mar-1990	ml 3.65	Took out wait loop for SCSI 0 to be ready.
;			(In install.s)
;
; 05-Mar-1990	ml 3.66	Added more checks for I/O to ACSI and SCSI non-
;			accessible memory.  _FRB will be used if it exists.
;			If _FRB doesn't exist, _dskbuf will used (which
;			means I/O could be "really" slow).  (_do_rw())
;
;			_FRB is being looked for when it's needed for the
;			first time, not at boot time.  (Applications can
;			add the _FRB when they are executed.)
;
; 08-Mar-1990	ml	Added SCFRDMA flag in defs.h to make SCSI DMA to 
;			fast RAM conditional assembly.
;			(driver.s modified)
;
; 15-Mar-1990	ml	Added DEBUG flag in defs.h to make debugging code
;			conditional assembly.
;
; 09-Apr-1990	ml 3.67	Added a "read" from WDL after toggling the ACSI DMA
;			chip to point the MMU to the correct direction.
;			(acsi.s modified)
;
; 10-Apr-1990	ml	Put up banner at beginning and end of loading driver
;			(requested by jwt), instead of just at the end.
;			(Printing of banner moved to install.s)
;
; 17-Apr-1990	ml	Added ODMA flag in defs.h to make the klutch of 
;			making byte counter bigger than # bytes requested
;			when receiving data from SCSI conditional assembly.
;			(scsi.s modified)
;
; 20-Apr-1990	ml	Added RDWDL flag in defs.h to make the "extra read"
;			added on 09-Apr-1990 conditional assembly.  (When
;			writing to ACSI, first 32 bytes are always FF's!!
;			Wondering why...)
;			(acsi.s modified)
;
; 30-Jul-1990	ml 4.00	Final for TT release. 
;			(Vectored-interrupts code not included)
;
; 31-Jul-1990	ml 	Vectored-interrupt code included.
;
; 29-Oct-1990	ml 4.01	BUG!!!  Getcookie() module provided by AKP has a
;			variable declared in the bss.  This bss will be
;			clobbered when the driver adds GEMDOS buffers and
;			OS pool.  When getcookie() was called, and access 
;			the bss, it clobbered whatever was using its space
;			at the time.
;			Fixed in cookie.s by changing moving the variable
;			from the bss to the text segment.
;			(cookie.s modified)
;
; 26-Nov-1990	ml 4.02	BUG!!  From 3.00 through 4.01, when Rwabs() is called
;			in raw mode, it ignored media change completely.
;			This created problems with cartridge swapping on the 
;			removable drives.  If Getbpb(), on a logical drive 
;			that has not been accessed on the previous cartridge,
;			is called right after a cartridge swap, Getbpb() will
;			call Rwabs() in raw mode to read the partition map of
;			the physical unit concerned.  This Rwabs() call will
;			get the media change error from the controller and 
;			ignores it without setting any mcflg of the physical
;			unit.  Now when Mediach(), on a logical drive that was
;			accessed on the previous cartridge, is called, the 
;			driver will return media not change!
;			In version 4.02, Rwabs() still does not return media
;			change error when called in raw mode, but will 
;			remember it  by setting the mcflgs of the physical 
;			unit concerned to maybe changed.
;
; 02-Apr-1991	ml 4.03	BUG!!  At boot time, 
;				move.l	#(i_sasi1-i_sasi),tokeep 
;			is used to find number of bytes of code to keep.  
;			In pre-4.00 AHDI, this works just fine because both 
;			i_sasi1 and i_sasi are in the same file.  But, since 
;			3.00, i_sasi1 has been moved to the file INSTALL.S, 
;			thus external.  Madmac did not complain that the 
;			expression #(i_sasi1-i_sasi) is not valid anymore.  
;			Instead it assembles the code as
;				move.l	#i_sasi1,tokeep
;			This is bad, because it depends of where the driver 
;			is being loaded, the driver may end up hogging large
;			amount of memory that it is not using.  This is now
;			fixed by calculating the amount at run time.
;				move.l	#i_sasi1,tokeep 
;				subi.l	#i_sasi,tokeep
;			(driver.s modified)
;
; 04-Apr-1991	ml	Some SCSI drives will recalibrate every so often.
;			While recalibrating, the drive still accepts the
;			command block, but delays the transfer of data to 
;			after the recalibration.  So, timeout for the data
;			transfer should include the amount of time spent 
;			on recalibration.  The worst case we know of is
;			the Fujisu drives which takes 4 seconds.  So, the 
;			default for recalibration time is set to 4 seconds.
;			(driver.s, scsi.s modified)
;			
;-


.include	"defs.h"
.include	"error.h"
.include	"sysvar.h"
.include	"68030.s"


.extern _untrdy
.extern _rqsense
.extern _hread
.extern _hwrite
.extern _xtdread
.extern _xtdwrt

.extern	i_sasi1
.extern	_getcookie

;
;+
; Entry points:
;
;	+0   GEMDOS entry point (double-click, or \AUTO folder on floppy)
;	+4   Boot entry point (from driver file off of C:)
;	+8   Reserved for future use
;	+$C  $F0AD magic number
;	+$E  version number
;	+$12 # chunks of ospool to add
;	+$14 # of sqnpart entries that follows
;	+$16 first sqnpart entry
;
; if bootloaded, d0 = # bytes allocated by boot code.
;-
i_sasi:	bra	gboot			; GEMDOS entry-point
	bra	iboot			; Boot entry-point
	bra	iboot			; (unused, reserved)


;+
;  Patchable variables
;-
magicnum:	dc.w	$f0ad		; wasn't here in previous releases
vernum:		dc.w	$0403		; version number
numchunks:	dc.w	128		; # chunks of ospool to add
		.globl	defbigsect
defbigsect:	dc.w	512		; default size of a big sector
numsqnpart:	dc.w	MAXACSI		; number of sqnpart entries to follow
		.globl	defsqnpart
defsqnpart:	dcb.b	MAXACSI,1	; default # drives for rmvbl ACSI unit

; They're NEW!! Introduced in this version:
numsqcnpart:	dc.w	MAXSCSI		; number of sqcnpart entries to follow
		.globl	defsqcnpart
defsqcnpart:	dcb.b	MAXSCSI,1	; default # drives for rmvbl SCSI unit
		.globl	scxltmout	
scxltmout:	dc.l	12001		; SCSI long-timeout (>1 min)
		.globl	slwsclto	
slwsclto:	dc.l	5000		; SCSI stunit() long-timeout (>25s)
		.globl	slwscsto	
slwscsto:	dc.l	42		; SCSI stunit() short-timeout (>205ms)
		.globl	scltmout	
scltmout:	dc.l	201		; SCSI long-timeout (>1000 ms)
		.globl	scstmout	
scstmout:	dc.l	101		; SCSI short-timeout (>500 ms)
		.globl	rcaltm	
rcaltm:		dc.l	801		; time for drive recalibration (>4s)
.even


;+
; GEMDOS entry;
;   find amount of memory availble and store in d0.l
;-
gboot:	movea.l	4(sp),a2		; a2 -> basepage
	move.l	4(a2),d0		; d0 = available memory
	sub.l	(a2),d0			;    = p_hitpa - p_lowtpa - basepage
	sub.l	#$0100,d0
	bra	i_sasi1			; (continue with normal initialization)


;+
;  Boot entry;
;    set "bootloaded", record base address from boot loader, 
;    and continue with normal boot process.
;-
iboot:	st	bootloaded		; boot entry-point, set flag
	sub.l	#$1c,d0			; memory available -= file header
	move.l	a2,baseaddr		; install base address
					; a2 = beginning addr of this block
	bra	i_sasi1			; (continue with normal initialization)


;
;+
; Driver State
;-
		dc.b	13,'AHDI : Apr 04 1991 v4.03'
		dc.b	13,10,$bd,'Atari Corp.'
		dc.b	' 1985, 1986, 1987, 1988, 1989, 1990, 1991'
		dc.b	13,10,0,$1A
.even

;*****  Beginning Of Published Variables  *****

		.globl	puns
puns:		dc.w	0		; # of physical units on user's system

dummy1:		dcb.b	2,-1		; dummy pun entries for A and B
		.globl	pun
pun:		dcb.b	MAXUNITS,0	; physical unit table
.even

dummy2:		dcb.l	2,0		; dummy start entries for A and B
		.globl	start
start:		dcb.l	MAXUNITS,0	; partition start table

		.globl	cookie		; *** DON'T CHANGE ***
cookie:		dc.l	$41484449	; cookie = 'AHDI'

		.globl	cookptr
cookptr:	dc.l	0		; pointer to cookie

versn:		dc.w	$0403		; version number: MMmm

		.globl	maxssz
maxssz:		dc.w	512		; maximum sector size allowed

spndown:	dc.l	0		; time limit to spin down unit 0
					; applicable to Stacy ONLY

		.globl	numacsi
numacsi:	dc.w	0		; number of ACSI drives

		dcb.w	29,0		; reserved for future use

;*****  End Of Published Variables  *****

	.globl	mcflgs
mcflgs:	dcb.b	MAXUNITS,2		; media change flag table
	.globl	xst
xst:	dcb.b	MAXUNITS,1		; drive existence flag table
bpbs:	dcb.b	BPBLEN,0		; a bpb 
serno:	dcb.b	MAXUNITS*SERLEN,0	; serial number table
	.globl	sratio
sratio:	dcb.b	MAXUNITS,1		; log sect size : phys sect size tbl
fatsum:	dcb.b	MAXUNITS*FATLEN,0	; FAT checksum table
fatst:	dcb.w	MAXUNITS,0		; starting sector # of last FAT
fatend:	dcb.w	MAXUNITS,0		; ending sector # of last FAT

		.globl	bootloaded
bootloaded:	dc.w	0		; nonzero if loaded from boot sector
		.globl	memalloc
memalloc:	dc.l	0		; total memory available if bootloaded
baseaddr:	dc.l	0		; -> base addr of .PRG file
tokeep:		dc.l	0		; amount memory to keep

		.globl	cpun
cpun:		dc.w	0		; current physical unit
		.globl	npart
npart:		dc.w	0		; number of partitions found
bfat:		dc.w	0		; 0: 12-bit FAT; 1: 16-bit FAT

strec:		dc.l	0		; starting sector to read/write
endrec:		dc.l	0		; last sector to read/write
stbuf:		dc.l	0		; starting address of buffer
		.globl	embscsi
embscsi:	dc.b	0		; 1: embedded SCSI drive

frbbuf:		dc.l	0		; pointer to _FRB

_retries:	dc.w	NRETRIES	; number of retries to do
retrycnt:	dc.w	1		; retry counter

		.globl	o_bpb
o_bpb:		dc.l	1		; old bpb vector
		.globl	o_rw
o_rw:		dc.l	1		; old rwabs vector
		.globl	o_mediach
o_mediach:	dc.l	1		; old media change vector

		.globl	sendata
sendata:	dcb.b	32,0		; buffer for sense data

lastmdctm:	dc.l	0		; time media change was last called
		.globl	pbuf
pbuf:		dc.l	0		; ptr to start of root sector image
fsiz:		dc.w	0		; FAT size in sectors
fatrec:		dc.w	0		; 2nd FAT starting sector
		.globl	sizr
sizr:		dc.w	1		; ratio of log : phys sector size
cstart:		dc.l	0		; current dev's starting sector
temp:		dc.l	0		; temporary storage
		.globl	savssp
savssp:		dc.l	1		; (saved SSP)
		.globl	_cachexst
_cachexst:	dc.b	0		; 0: no cache	1: with cache
		.globl	ext
ext:		dc.b	0		; if =0, not processing ext partition
		.globl	extrt
extrt:		dc.l	0		; starting sector of ext DOS partition
		.globl	extvol
extvol:		dc.l	0		; offset wrt ext DOS partition
pbpb:		dc.w	0		; partition # for dev
.even


;
;+
; Front End
;-

;+
;  Return pointer to BPB (or NULL)
;
;    Synopsis:	LONG hbpb(dev)
;		WORD dev;	4(sp).w
;-
	.globl	hbpb
hbpb:	move.w	4(sp),d0		; d0 = devno
	clr	d1			; d1 = 0, physical op not possible
	movea.l	o_bpb,a0		; a0 -> pass-through vector
	lea	_sasi_bpb(pc),a1	; a1 -> our handler
	bra.s	check_dev		; do it


;+
;  Read or write logical sectors
;
;    Synopsis:	LONG hrw(rw, buf, count, recno, dev)
;		WORD rw;	$4(sp).w
;		char *buf;	$6(sp).l
;		WORD count;	$a(sp).w
;		WORD recno;	$c(sp).w
;		WORD dev;	$e(sp).w
;-
	.globl	hrw
hrw:	move.w	$e(sp),d0		; d0 = devno
	move.w	4(sp),d1		; d1 includes physical device flag
	movea.l	o_rw,a0			; a0 -> pass-through vector
	lea	_sasi_rw(pc),a1		; a1 -> our handler
	bra.s	check_dev		; do it


;+
;  Check for media change
;
;    Synopsis:	LONG hmediach(dev)
;		WORD dev;	4(sp).w
;-
	.globl	hmediach
hmediach:
	move.w	4(sp),d0		; d0 = devno
	clr	d1			; physical operation not possible
	movea.l	o_mediach,a0		; a0 -> pass-through vector
	lea	_sasi_mediach(pc),a1	; a1 -> our handler


;+
;  check_dev - use handler, or pass vector through
;
;  Passed:	d0.w = device#
;		d1, bit 3  1=physical operation
;		a0 ->  old handler
;		a1 ->  new handler
;		a5 ->  $0000 (zero-page ptr)
;
;  Jumps-to:	(a1) if dev in range for this handler
;		(a0) otherwise
;-
check_dev:
	subq	#2,d0			; lowest device is 2 (unit 0 or C:)
	bmi.s	chkd_f			; if lower, not one of ours

	btst	#3,d1			; is this a physical unit operation?
	beq.s	chkd_a			; if not set, go to chkd_a

	cmp.w	numacsi,d0		; a valid ACSI unit?
	blt.s	chkd_s			; if so, it's one of ours

	sub.w	#MAXACSI,d0		; a SCSI unit number?
	bmi.s	chkd_f			; if lower, not one of ours

	move.w	puns,d1			; d1.w = number of valid SCSI units
	sub.w	numacsi,d1		;      = total num - num ACSI
	cmp.w	d1,d0			; a valid SCSI unit?
	bge.s	chkd_f			; if higher, not one of ours
	bra.s	chkd_s			; else it IS one of of ours

chkd_a:	lea	pun,a2			; pointer to pun map
	tst.b	0(a2,d0.w)		; must be positive for a real unit
	bmi.s	chkd_f
chkd_s:	movea.l	a1,a0			; yes -- follow success vector
chkd_f:	jmp	(a0)			; do it


;
;+
; Medium-Level Driver
;-

;+
; Return BPB for logical device
;
; Synopsis:	LONG _sasi_bpb(dev)
;		WORD dev;	$4(sp).w
;
; Returns:	NULL, or a pointer to the BPB buffer
;
; 10-21-88	ml.	I am not making a special case for non-removable
;			hard disk, because if a program uses Allan's
;			program to force a media change, the program 
;			should be getting the "Real" AND "New" BPB.
;			(The old (v1.7 and before) AHDI only index into
;			the bpbs table and return the pointer, without
;			actually go and read the boot sector of the dev.)
;-
_sasi_bpb:
	subq.w	#2,4(sp)		; dev # excluding drv A and B
	move.w	4(sp),d1		; d1 = device number
	lea	pun,a0			; a0 -> pun table
	adda.w	d1,a0			; a0 -> pun @ dev's entry
	moveq	#0,d2			; coerce byte to word
	move.b	(a0),d2			; d2.w = pun that dev belongs to
	move.w	d2,cpun			; cpun = pun(dev)

	lea	xst,a1			; a1 -> drive existence table
	tst.b	(a1,d1.w)		; does drive exist?
	bne.s	bpbgo			; if it does, go on normally
					; else, see if it really doesn't exist
	movem.l	d1/a0,-(sp)		; save registers
	move.w	d2,-(sp)		; physical unit number
	bsr	_untrdy			; verify by doing test unit ready
	addq.l	#2,sp			; cleanup stack
	movem.l	(sp)+,d1/a0		; restore registers
	tst.w	d0			; return good status?
	beq	badbpb			; if yes, ie. medium has not changed
					; therefore, dev still doesn't exist
	moveq	#1,d0			; else medium may have changed
	bsr	s_mc_xst		; set mcflgs and xst flags to 1's
					; and go try to get BPB
bpbgo:	move.l	_dskbufp,pbuf		; pbuf -> 2nd half of 1K disk buf
	add.l	#512,pbuf

bpb00:	move.l	a0,-(sp)		; save ptr to pun(dev)
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	clr.w	-(sp)			; from sector 0
	move.w	#1,-(sp)		; read in 1 sector
	move.l	pbuf,-(sp)		; buffer to read into
	move.w	#$a,-(sp)		; in phys mode/ignore media change
	bsr	_ahdi_rw		; ahdi_rw($a, pbuf, 1, 0, cpun)
	adda	#12,sp
	movea.l	(sp)+,a0		; restore ptr to pun(dev)
	tst	d0			; read successful?
	beq.s	bpb0			; if yes, go on normally
					; else call up error handler
bpberr:	move.l	a0,-(sp)		; save ptr to pun(dev)
	move.w	8(sp),d1		; a0 = drive # excluding A: and B:
	bsr	critic			; call up critical error handler
	move.l	(sp)+,a0		; restore ptr to pun(dev)
	cmpi.l	#CRITRETRY,d0		; retry?
	beq.s	bpb00			; if so, go and try again
	bra	badbpb			; else return no BPB

bpb0:	move.w	cpun,d2			; d2 = physical unit number of dev
	move.w	#0,pbpb			; pbpb = partition # dev corresponds
bpb1:	cmp.b	-(a0),d2		; pun that dev belongs to == (a0)?
	bne.s	bpb2
	addq.w	#1,pbpb
	bra.s	bpb1

bpb2:	move.w	#MAXNPART,d1		; do #MAXNPART times
	movea.l	pbuf,a0			; a0 -> beginning of root sector
	cmpi.w	#SIG,DOSSIG(a0)		; is root sector in DOS format?
	bne.s	bpb3			; if not, assume it's in GEMDOS format
	bsr	dosbpb			; else, handle it the DOS way
	bra.s	bpb4			; else, go get the bpb
bpb3:	move.w	#1,bfat			; 16 bit FAT always for GEMDOS
	bsr	gembpb			; handle it the GEMDOS way
bpb4:	tst.w	d0			; successful?
	beq.s	bpbnf			; if =0, no valid BPB found
	bpl.s	bpb5			; if +ive, valid BPB found
	bra.s	badbpb			; else no BPB found
					; partition not found
bpbnf:	lea	xst,a0			; a0 -> drive existence table
	move.w	4(sp),d0		; d0 = dev number
	clr.b	(a0,d0.w)		; dev definitely does not exist
	lea	mcflgs,a0		; a0 -> mcflgs table
	move.b	#2,(a0,d0.w)		; set as medium has changed
	bra.s	badbpb			; can't find such a partition

bpb5:	move.l	d1,-(sp)		; start_sector
	move.w	8(sp),-(sp)		; dev number
	bsr	getbpb			; getbpb(dev, start_sector)
	addq.l	#6,sp			; clean up stack
	tst.l	d0			; getbpb successful?
	bpl.s	retbpb			; if so, return ptr to bpb
badbpb:	moveq	#0,d0			; return no bpb found
retbpb:	rts


;
;+
; dosbpb - find the DOS partition that corresponds to the requested
;	   logical drive
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Assumed:
;	pbpbs = partition being looked for
;
; Returns:
;	d0.b = 0		if partition not found
;	     = negative #	some kind of error
;	     = positive #	system indicator of the partition
;	d1.l = starting sector of the partition (if it is found)
;-
dosbpb:	adda.w	#DOSPM,a0		; a0 -> partition map
dbpb0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fdpart			; find a partition
	tst.b	d0			; found any?
	beq.s	dbpba			; not a valid partition
	cmpi.b	#5,d0			; extended partition?
	bne.s	dbpb1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
dbpbx:	bsr	fdnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	dbpba			; no logical drive found
	bmi.s	dbpb2			; error returned
	cmpi.b	#5,d0			; extended volume?
	beq.s	dbpbx			; if so, go find next logical drive
dbpb1:	subq.w	#1,pbpb			; partition that we want?
	bpl.s	dbpb3			; if not, continue the search
dbpb2:	addq.l	#8,sp			; else clean up stack
	move.w	#0,bfat			; assume partition has 12-bit fat
	cmpi.b	#1,d0			; 12-bit fat?
	beq.s	dbpb22			; if so, return
	move.w	#1,bfat			; else bflag = 1 for 16-bit fat
dbpb22:	bra.s	dbpbr			; and return
dbpb3:	tst.b	ext			; clun is in ext partition?
	bne.s	dbpbx			; if so, go find next ext vol
dbpba:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#16,a0			; index to next entry in pmap
	dbra	d1,dbpb0
	moveq	#0,d0			; partition not found!
dbpbr:	rts

	
;+
; fdpart - find a DOS partition.
;
; Passed:
;	a0 = address to partition entry
;
; Returns:
;	d0.b = 0		partition is not valid
;	     = positive	#	partition is a valid partition
;	       (this is the system indicator of the partition)
;	d1.l = starting sector # of a valid partition (if d0.b = 1 or 4)
;	     = starting sector # of extended partition (if d0.b = 5)
;-
	.globl	fdpart
fdpart:	tst.l	12(a0)			; partition's size?
	beq.s	fdp0			; if =0, not valid

	move.b	4(a0),d0		; d0 = system indicator
	beq.s	fdpr			; if =0, not valid

	cmpi.b	#4,d0			; if =4, valid
	beq.s	fdp1

	cmpi.b	#1,d0			; if =1, valid
	beq.s	fdp1

	cmpi.b	#5,d0			; if =5, valid
	beq.s	fdp1

fdp0:	moveq	#0,d0			; else, not valid
	bra.s	fdpr

fdp1:	move.l	8(a0),d1		; d1.l = swapped starting sector #
	ror.w	#8,d1			; swap hi and lo byte of high word
	swap	d1			; swap hi and lo word
	ror.w	#8,d1			; swap hi and lo byte of low word
fdpr:	rts


;+
; fdnxt - find a logical drive in the extended DOS partition
;
; Passed:
;	d0.b = (= 5 if a new extended volume was found)
;	       (= 0 if nxtdrv was successful for last logical drive found)
;	d1.l = starting sector # of this extended volume
;	d2.b = count down for logical drive entries (if d0.b != 5)
;	a0.l = address of partition entry to be checked (if d0.b != 5)
;
; Assumes:
;	cpun = current physical unit #
;	extrt = starting sector # of extended DOS partition
;	extvol = offset from start of extended DOS partition (in sectors)
;
; Returns:
;	d0.b = 0		no logical drive found
;	     = positive #	valid logical drive found
;	       (this is the system indicator of the logical drive)
;	     = negative #	error occured
;	d1.l = starting sector # of the logical drive (if d0.b = 1 or 4)
;	     = starting sector # of next extended volume (if d0.b = 5)
;-
	.globl	fdnxt
fdnxt:	cmpi.b	#5,d0		; new extended volume found?
	bne.s	fdnxt0		; if not, search for one
	move.l	d1,-(sp)	; from beginning of extended volume
	move.w	cpun,-(sp)	; physical unit number
	addq.w	#2,(sp)		; unit # including A: and B:
	move.w	#-1,-(sp)	; using a long sector number
	move.w	#1,-(sp)	; read in 1 sector
	move.l	_dskbufp,-(sp)	; buffer to read into
	move.w	#$a,-(sp)	; read in physical mode/ignore media change
	bsr	_ahdi_rw	; ahdi_rw($a, buf, 1, -1, cpun, lsectno)
	adda	#16,sp		; cleanup stack
	tst.w	d0		; read successful?
	bne	fdnxtr		; if not, return
	
	movea.l	_dskbufp,a0	; else, 
	cmpi.w	#SIG,DOSSIG(a0)	; boot record valid?
	bne.s	fdnxtr		; if not, return no drive found
				; (d0 already set by ahdi_rw)
	adda.w	#DOSPM-16,a0	; a0 -> 1st entry in log drive map
	move.w	#MAXNPART+1,d2	; d2 = count for # of log drive entries

fdnxt0:	subq.w	#1,d2		; more entries to search?
	bmi.s	fdnxt1		; if not, return

	adda	#16,a0		; a0 -> entry to be examined
	tst.l	12(a0)		; partition size's?
	beq.s	fdnxt0		; if =0, not valid

	move.b	4(a0),d0	; d0 = system indicator
	beq.s	fdnxt0		; if =0, not valid

	move.l	8(a0),d1	; d1.l = logical start sector of drv or vol
	beq.s	fdnxt0		; if =0, not valid
	ror.w	#8,d1		; swap hi and lo byte of high word
	swap	d1		; swap hi and lo word
	ror.w	#8,d1		; swap hi and lo byte of low word

	cmpi.b	#4,d0		; if =4,
	beq.s	fdnxt2		; valid logical drive found

	cmpi.b	#1,d0		; if =1,
	beq.s	fdnxt2		; valid logical drive found

	cmpi.b	#5,d0		; if =5, valid ptr to next ext volume
	bne.s	fdnxt0		; else, not valid
	move.l	d1, extvol	; offset of ext vol from start of ext DOS
	bra.s	fdnxt3

fdnxt1:	moveq	#0,d0		; return no drive found
	bra.s	fdnxtr

fdnxt2:	add.l	extvol,d1	; d1 = start sector wrt beginning of ext DOS
fdnxt3:	add.l	extrt,d1	; d1 = start sector wrt beginning of disk
fdnxtr:	rts


;
;+
; gembpb - find the GEMDOS partition that corresponds to the requested
;	   logical drive.
; Passed:
;	a0 = buffer address for root sector
;	d1 = number of entries in partition map
;
; Assumed:
;	pbpbs = partition being looked for
;
; Returns:
;	d0.b = 0		if partition not found
;	     = negative #	some kind of error
;	     = positive #	system indicator of the partition
;	d1.l = starting sector of the partition (if it is found)
;-
gembpb:	adda.w	#HDSIZ,a0		; a0 -> hard disk size
	tst.l	(a0)+			; size? (a0 -> start of pmap)
	beq.s	gbpb4			; if =0, no drive will exist
gbpb0:	movem.l	d1/a0,-(sp)		; save count and offset
	sf	ext			; not dealing with ext partition
	bsr	fgpart			; find partitions
	tst.b	d0			; found any?
	beq.s	gbpba			; not a valid partition
	cmpi.b	#'X',d0			; extended partition?
	bne.s	gbpb1			; if not, it's a regular partition
	st	ext			; else, it's an extended partition
	move.l	#0,extvol		; offset from start of partition = 0
	move.l	d1,extrt		; starting sector # of ext partition
gbpbx:	bsr	fgnxt			; find next logical drive
	tst.b	d0			; found any?
	beq.s	gbpba			; no logical drive found
	bmi.s	gbpb2			; error returned
	cmpi.b	#'X',d0			; extended volume?
	beq.s	gbpbx			; if so, go find next logical drive
gbpb1:	subq.w	#1,pbpb			; partition that we want?
	bpl.s	gbpb3			; if not, continue the search
gbpb2:	addq.l	#8,sp			; else BINGO!  Clean up stack
	bra.s	gbpbr			; and return
gbpb3:	tst.b	ext			; clun is in ext partition?
	bne.s	gbpbx			; if so, go find next ext vol
gbpba:	movem.l	(sp)+,d1/a0		; restore count and offset
	adda	#12,a0			; index to next entry in pmap
	dbra	d1,gbpb0
gbpb4:	moveq	#0,d0			; partition not found!
gbpbr:	rts


;+
; fgpart - find a GEMDOS partition.
;
; Passed:
;	a0 = address to partition entry
;
; Returns:
;	d0.b = 0		partition is not valid
;	     = positive	#	partition is a valid partition
;	       (this is the first byte in p_id of the partition)
;	d1.l = starting sector # of a valid partition (if d0.b = 'G' or 'B')
;	     = starting sector # of extended partition (if d0.b = 'X')
;-
	.globl	fgpart
fgpart:	tst.b	(a0)			; check the valid partition flag
	beq.s	fgp2			; if =0, not valid

	tst.l	8(a0)			; partition's size?
	beq.s	fgp2			; if =0, not valid

	cmpi.b	#'G',1(a0)		; must find GEM as type
	bne.s	fgp0			; for REGULAR partition
	cmpi.b	#'E',2(a0)		; (ie., partition < 16Mb)
	bne.s	fgp0
	cmpi.b	#'M',3(a0)
	beq.s	fgp3

fgp0:	cmpi.b	#'B',1(a0)		; must find BGM as type
	bne.s	fgp1			; for BIG partition
	cmpi.b	#'G',2(a0)		; (ie., partition >= 16Mb)
	bne.s	fgp1
	cmpi.b	#'M',3(a0)
	beq.s	fgp3

fgp1:	cmpi.b	#'X',1(a0)		; or find XGM as type
	bne.s	fgp2			; for EXTENDED GEMDOS 
	cmpi.b	#'G',2(a0)		; partition
	bne.s	fgp2			; (ie., partition with
	cmpi.b	#'M',3(a0)		;  a linked list of
	beq.s	fgp3			;  logical drives)

fgp2:	moveq	#0,d0			; else, not valid
	bra.s	fgpr

fgp3:	move.l	4(a0),d1		; d1.l = starting sector #
	move.b	1(a0),d0		; d0.b = first byte of p_id
fgpr:	rts


;+
; fgnxt - find a logical drive in the extended GEMDOS partition
;
; Passed:
;	d0.b = (= 'X' if a new extended volume was found)
;	       (= 0 if nxtdrv was successful for last logical drive found)
;	d1.l = starting sector # of this extended volume
;	d2.b = count down for logical drive entries (if d0.b != 'X')
;	a0.l = address of partition entry to be checked (if d0.b != 'X')
;
; Assumes:
;	cpun = current physical unit #
;	extrt = starting sector # of extended GEMDOS partition
;	extvol = offset from start of extended GEMDOS partition (in sectors)
;
; Returns:
;	d0.b = 0		no logical drive found
;	     = positive #	valid logical drive found
;	       (this is the first byte of p_id of the logical drive)
;	     = negative #	error occured
;	d1.l = starting sector # of the logical drive (if d0.b = 'G' or 'B')
;	     = starting sector # of next extended volume (if d0.b = 'X')
;-
	.globl	fgnxt
fgnxt:	cmpi.b	#'X',d0		; new extended volume found?
	bne.s	fgnxt0		; if not, search for one
	move.l	d1,-(sp)	; from beginning of extended volume
	move.w	cpun,-(sp)	; physical unit number
	addq.w	#2,(sp)		; unit # including A: and B:
	move.w	#-1,-(sp)	; using a long sector number
	move.w	#1,-(sp)	; read in 1 sector
	move.l	_dskbufp,-(sp)	; buffer to read into
	move.w	#$a,-(sp)	; read in physical mode/ignore media change
	bsr	_ahdi_rw	; ahdi_rw($a, buf, 1, -1, cpun, lsectno)
	adda	#16,sp		; cleanup stack
	tst.w	d0		; read successful?
	bne	fgnxtr		; if not, return error

	movea.l	_dskbufp,a0	; a0 -> partition map
	adda.w	#HDSIZ+4-12,a0	; a0 -> 1st entry in log drive map
	move.w	#MAXNPART+1,d2	; d2 = count for # of log drive entries

fgnxt0:	subq.w	#1,d2		; more entries to search?
	bmi.s	fgnxt3		; if not, return

	adda	#12,a0		; a0 -> entry to be examined
	tst.l	8(a0)		; partition size's?
	beq.s	fgnxt0		; if =0, not valid.  Try next entry

	tst.b	(a0)		; check the valid partition flag
	beq.s	fgnxt0		; if =0, not valid.  Try next entry

	move.l	4(a0),d1	; d1.l = logical start sector of drv or vol

	cmpi.b	#'G',1(a0)	; must find GEM as type
	bne.s	fgnxt1		; for REGULAR partition
	cmpi.b	#'E',2(a0)	; (ie., partition < 16Mb)
	bne.s	fgnxt1
	cmpi.b	#'M',3(a0)
	beq.s	fgnxt4

fgnxt1:	cmpi.b	#'B',1(a0)	; must find BGM as type
	bne.s	fgnxt2		; for BIG partition
	cmpi.b	#'G',2(a0)	; (ie., partition >= 16Mb)
	bne.s	fgnxt2
	cmpi.b	#'M',3(a0)
	beq.s	fgnxt4

fgnxt2:	cmpi.b	#'X',1(a0)	; or find XGM as type
	bne.s	fgnxt3		; for EXTENDED GEMDOS 
	cmpi.b	#'G',2(a0)	; partition
	bne.s	fgnxt3		; (ie., partition with
	cmpi.b	#'M',3(a0)	;  a linked list of
	bne.s	fgnxt0		;  logical drives)

	move.l	d1, extvol	; offset of ext vol from start of ext GEMDOS
	bra.s	fgnxt5

fgnxt3:	moveq	#0,d0		; return no drive found
	bra.s	fgnxtr

fgnxt4:	add.l	extvol,d1	; d1 = start sector wrt beginning of ext DOS
fgnxt5:	add.l	extrt,d1	; d1 = start sector wrt beginning of disk
	move.b	1(a0),d0	; d0.b = first byte of p_id
fgnxtr:	rts


;
;+
; getbpb(dev, sectorno)
; WORD dev;		4(sp).w
; LONG sectorno;	6(sp).l
;
; Assume -
;    cpun contains physical unit number of dev
;-
getbpb:	move.l	$6(sp),-(sp)	; sector # of boot sector
	move.w	cpun,-(sp)	; physical unit
	addq.w	#2,(sp)		; unit # including A: and B:
	move.w	#-1,-(sp)	; using a long sector number
	move.w	#1,-(sp)	; 1 sector
	move.l	_dskbufp,-(sp)	; buffer
	move.w	#$a,-(sp)	; read in physical mode/ignore media change
	bsr	_ahdi_rw	; ahdi_rw(8, buf, 1, -1, cpun, lsectno)
	adda	#16,sp		; clean up stack
	tst.w	d0		; successful?
	beq.s	getb0		; if so, go on normally
				; else let user retry
getb9:	move.w	4(sp),d1	; d1 = drive # excluding A: and B:
	bsr	critic
	cmpi.l	#CRITRETRY,d0	; retry?
	bne	getb7		; if not, return
	bra.s	getbpb		; else read again

getb0:	movea.l	_dskbufp,a0	; a0 -> boot sector image
	movea.l	#bpbs,a2	; a2 -> bpb

	move.w	#$0b,d0
	bsr	getlhw
	cmp.w	maxssz,d0	; is sector size too big?
	bhi	getb7		; if it is, can't handle it
	move.w	d0,(a2)+	; =byt/sec
	beq	getb7		; if =0, bad data
	move.w	d0,d1
	divu	#512,d0		; d0.b = ratio log : phys sector size
	move.w	d0,sizr		; save the ratio

	clr.w	d0
	move.b	$d(a0),d0
	move.w	d0,(a2)+	; = #sectors/cluster
	beq	getb7		; if =0, bad data

	mulu	d1,d0
	move	d0,(a2)+	; = #bytes/cluster

	move	#$11,d0
	bsr	getlhw		; number of directory entries
	tst	d0		; num o' entries ?= 0
	beq	getb7		; if so, bad data
 	mulu	#32,d0		; size of each entry
	divu	d1,d0		; number of sectors required
	move.l	d0,d1
	swap	d1
	tst	d1
	beq.s	getb1
	addq	#1,d0		; round up
getb1:	move	d0,(a2)+	; =rdlen
	move	d0,d2

	move	#$16,d0
	bsr	getlhw
	move	d0,(a2)+	; =FATsize
	beq	getb7		; if =0, bad data
	move	d0,d1
	move	d0,fsiz		; save FAT size

	move	#$e,d0
	bsr	getlhw		; number of reserved sectors
	add	d1,d0
	move	d0,(a2)+	; =2nd FAT start
	move	d0,fatrec	; save 2nd FAT start 

	add	d1,d0		; plus size of second fat
	add	d2,d0		; plus rdlen
	move	d0,(a2)+	; = data start
	move	d0,d2		; save start of data

	move	#$13,d0
	bsr	getlhw		; number of sectors on media
	sub	d2,d0		; subtract # used by FATs,dir,boot
	beq	getb7		; if =0, bad data
	clr.l	d1
	move	d0,d1
	clr	d0
	move.b	$d(a0),d0	; number of sectors/cluster
	divu	d0,d1		; rounding down
	move	d1,(a2)+	; =number of clusters
	move	bfat,(a2)	; =flags, 12 or 16 bit fats

	move.w	sizr,d2		; d2 = current sector size ratio
	lea	sratio,a1	; a1 -> sector size ratio table
	move.w	4(sp),d0	; d0 = drive number
	move.b	d2,(a1,d0.w)	; update sector size ratio in table

	btst.b	#6,cpun+1	; is unit removable?
	beq	getb6		; if not, can skip the fat checksum

	lea	serno,a1	; a1 -> table of serial #s
	mulu.w	#SERLEN,d0	; dev# * SERLEN to index into table
	adda.l	d0,a1		; a1 -> serial # of dev
	move.w	#SERLEN-1,d1	; length of serial # - 1
getb2:	move.b	$8(a0,d1.w),(a1,d1.w)	; update serial # of dev
	dbra	d1,getb2

	lea	fatsum,a2	; a2 -> FAT check sum table
	move.w	4(sp),d0	; d0 = dev number
	mulu	#FATLEN,d0	; d0*FATLEN = to index into table
	adda.l	d0,a2		; a2 -> FAT check sum tbl of dev

	move.w	fatrec,d0	; d0 = log starting sector of 2nd FAT
	mulu	d2,d0		; (in 512-byte sectors)
	movea.l	$6(sp),a1	; a1 = starting sector of drive
	adda.l	d0,a1		; a1 = phys starting sector of 2nd FAT

	move.w	fsiz,d1		; d1 = # FAT sectors to read
	subq.l	#1,d1		;    = FAT size - 1

getb3:	move.w	sizr,d2		; d2 = count per FAT sector
	subq.w	#1,d2
 	clr.l	temp		; initialize the sum
getb4:	movem.l	d1-d2/a0-a2,-(sp)	; save registers
	move.l	a1,-(sp)	; from sector a1
	move.w	cpun,-(sp)	; physical unit
	addq.w	#2,(sp)		; unit # including A: and B:
	move.w	#-1,-(sp)	; using a long sector number
	move.w	#1,-(sp)	; read 1 phys sector
	move.l	a0,-(sp)	; buffer (in _dskbufp)
	move.w	#$a,-(sp)	; read in physical mode/ignore media change
	bsr	_ahdi_rw	; ahdi_rw($a, buf, 1, -1, cpun, lsecno)
	adda	#16,sp		; clean up stack
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers
	tst.w	d0		; read successful?
	beq	getb5		; if so, go on normally
				; else let user retry
getba:	movem.l	d1-d2/a0-a2,-(sp)	; save registers
	move.w	24(sp),d1	; d1 = drive # excluding A: and B:
	bsr	critic		; critical error handler
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers
	cmpi.l	#CRITRETRY,d0	; retry?
	beq.s	getb4		; if so, try again
	bra	getb7		; else return

getb5:	bsr	bsum		; add up values in the sector
	addq	#1,a1		; get ready for next sector
	dbra	d2,getb4	; until one logical FAT sector is done

	bsr	csum		; find the checksum
	move.b	d0,(a2)+	; update checksum for this FAT sector
	dbra	d1,getb3	; until all sectors are checked

getb6:	move.w	$4(sp),d0	; d0 = dev number
	lea	mcflgs,a0	; load address of mcflgs table
	clr.b	(a0,d0.w)	; clear mcflg for dev

	lea	xst,a0		; a0 -> drive existence table
	move.b	#2,(a0,d0.w)	; dev definitely exists

	lea	fatst,a0	; a0 -> FAT start sector table
	asl.w	#1,d0		; offset = dev# * 2 (tbl of words)
	move	fatrec,(a0,d0.w); update FAT starting sect#

	lea	fatend,a0	; a0 -> FAT end sector table
	move.w	fatrec,d1	; d1 = fatend(dev)
	add.w	fsiz,d1		;    = fatrec + fsiz - 1
	subq.w	#1,d1	
	move.w	d1,(a0,d0.w)	; fatend(dev) = fatrec + fsiz - 1

	lea	start,a0	; a0 -> beginning of start table
	asl.w	#1,d0		; offset = dev# * 2 * 2 (tbl of longs)
	move.l	$6(sp),(a0,d0.w); update starting sect# of dev

	move.l	#bpbs,d0	; no errors, return ptr to BPB
	bra.s	getb8		; return

getb7:	moveq	#-1,d0		; error
getb8:	rts


;+
; WORD getlhw(d0=offset)
; returns word (low,high) from 0(D0,A0)
;-
	.globl	getlhw
getlhw:	move	d1,-(sp)	; preserve d1
	move.b	1(a0,d0.w),d1
	lsl.w	#8,d1
	move.b	0(a0,d0.w),d1
	move	d1,d0
	move	(sp)+,d1
	rts


;+
; bsum
;
; Passed:
;	a0 = starting address of buffer to be summed
;	temp.l = current sum
;
; Function:
;  	- sum up 512 bytes of a buffer 4 bytes at a time
;	- save the sum in temp.l
;
; Algorithm for check summing the FAT:
;	- add up bytes in the buffer 4 bytes at a time	(in bsum)
;	- if the sum is non-zero, XOR the high word 	(in csum)
;	  with the low word of the 4-byte result
;	- now take this 2-byte result, and XOR its high	(in csum)
;	  byte with its low byte to get the final 1-byte
;	  result
;-
bsum:	movem.l	d1/a0,-(sp)		; save d1, a0
	move.l	temp,d0			; d0 = current sum
	move	#127,d1			; count
bsum0:	add.l	(a0)+,d0		; add 4 bytes to sum
	dbra	d1,bsum0		; until all bytes are added
	move.l	d0,temp			; temp.l = new sum
	movem.l	(sp)+,d1/a0		; restore d1, a0
	rts


;+
; csum
; (a) XOR the high word with the low word of temp.l
; (b) then XOR the high byte with the low byte of result of (a)
;
; Returns:
;	d0.b = checksum
;-
csum:	move.w	temp+2,d0		; d0.w = low word of result
	eor.w	d0,temp			; exclusive-or low and high word
	move.b	temp+1,d0		; d0.b = low byte of xor-ed result
	eor.b	d0,temp			; exclusive-or low and high byte
	move.b	temp,d0
	rts				; d0.b = checksum


;
;+
;  Read/Write sectors
;
;    Synopsis:	_ahdi_rw(rw, buf, count, recno, dev, lrecno)
;		WORD rw		4(sp).w		; non-zero -> write
;		char *buf	6(sp).l
;		WORD count	$a(sp).w
;		WORD recno	$c(sp).w
;		WORD dev	$e(sp).w
;		LONG lrecno	$10(sp).l	; optional
;-

; stack frame offsets
xrw	equ	8
xbuf	equ	10
xcount	equ	14
xrecno	equ	16
xdev	equ	18
xlrecno	equ	20

	.globl	_sasi_rw
	.globl	_ahdi_rw
_sasi_rw:
_ahdi_rw:
	link	a6,#0			; create a frame pointer
	subq.w	#2,xdev(a6)		; drive # excluding A: and B:

	move.w	xdev(a6),d0		; d0 = device number
	btst.b	#3,xrw+1(a6)		; is this a physical operation?
	beq.s	getcpun			; if not, find physical unit number
	move.w	d0,cpun			; else, dev# passed is phys unit #
	move.w	#1,sizr			; sector size ratio = 1
	bra	ahrw1			; go start the r/w
getcpun:				; map log -> phys unit number
	lea	pun,a0			; a0 -> pun table
	move.b	(a0,d0.w),cpun+1	; cpun = pun of dev
	
	lea	sratio,a0		; a0 -> sector size ratio table
	move.b	(a0,d0.w),sizr+1	; sizr = current sector size ratio
					;	 (coerced to word)
	lea	start,a0		; a0 -> start table
	move.w	d0,d1			; d1 = drive #
	add.w	d1,d1			; d1*2*2 (index into tbl of longs)
	add.w	d1,d1
	move.l	(a0,d1.w),cstart	; cstart = dev starting sector

	btst.b	#1,xrw+1(a6)		; ignore media change?
	bne	ahrw1			; if yes, go ahead and do r/w
					; else check for media change
	lea	mcflgs,a0		; a0 -> mcflgs of drive
	move.b	(a0,d0.w),d0		; d0 = mcflg of dev
	beq	ahrw1			; if media not changed, go do r/w

	cmpi.b	#2,d0			; is media definitely changed?
	beq	retmc			; if yes, return media has changed
					; else, check if media has changed
					; try to read dev's boot sector
chkmc:	move.l	cstart,-(sp)		; dev starting sector
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	move.w	#-1,-(sp)		; using a long sector number
	move.w	#1,-(sp)		; 1 sector
	move.l	_dskbufp,-(sp)		; buffer
	move.w	#$a,-(sp)		; phys mode and no media change error
	bsr	_ahdi_rw		; ahdi_rw($a, buf, 1, -1, cpun, sectno)
	adda	#16,sp			; clean up stack
	tst.w	d0			; read successful?
	beq.s	chkser			; yes, go check serial number

	move.w	xdev(a6),d1		; device number
	bsr	critic			; call critical error handler
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq.s	chkmc			; if yes, go back and try it
	bra	ahrw7			; else return

chkser:	lea	serno,a1		; a1 -> serial #s table
	move.w	xdev(a6),d0		; d0 = dev number
	mulu.w	#SERLEN,d0		; *SERLEN for index into table
	adda.l	d0,a1			; a1 -> serial # of dev

	move.l	_dskbufp,a2		; a2 -> boot sector
	addq.w	#8,a2			; a2 -> serial # in boot sector
 	move.w	#SERLEN-1,d0		; d0 = count for comparison
cmpser:	cmpm.b	(a2)+,(a1)+		; serial # read ?= serial # recorded
	bne	ismc			; if not, media has changed
	dbra	d0,cmpser		; compare next byte of serial #
					; serial # hasn't changed, try FAT
	move.w	xdev(a6),d0		; d0 = dev number
	lea	fatsum,a1		; a1 -> fat checksum table
	move.w	#FATLEN,d1		; d1.w = index into table
	mulu	d0,d1
	adda.l	d1,a1			; a1 -> fat checksum of dev

	add.w	d0,d0			; d0*2 = index into table of words
	lea	fatst,a2		; a2 -> FAT start table
	move.w	(a2,d0.w),fatrec	; fatrec = fatst(dev)

	lea	fatend,a2		; a2 -> FAT end table
	move.w	(a2,d0.w),d1		; d1 = counter to scan FAT table
	sub.w	fatrec,d1		;    = fatend(dev) - fatst(dev)

	movea.l	cstart,a2		; a2 = start sector of dev
	move.w	fatrec,d2		; d2 = fatst(dev)
	mulu	sizr,d2			; d2 = fatst(dev) in 512-byte sector
	adda.l	d2,a2			; a2 = phys start sector of 2nd FAT

	movea.l	_dskbufp,a0		; a0 -> dskbuf
cmpfat:	move.w	sizr,d2			; d2 = # reads per FAT sector
	subq.w	#1,d2			; d2 - 1 = counter
	clr.l	temp			; initialize sum
cfat0:	movem.l	d1-d2/a0-a2,-(sp)	; save d1, d2, a0, a1, a2
					; try to read this FAT sector
	move.l	a2,-(sp)		; at sector a2
	move.w	cpun,-(sp)		; physical unit number
	addq.w	#2,(sp)			; unit # including A: and B:
	move.w	#-1,-(sp)		; using a long sector number
	move.w	#1,-(sp)		; 1 sector
	move.l	a0,-(sp)		; buffer
	move.w	#$a,-(sp)		; phys mode and no media change error
	bsr	_ahdi_rw		; ahdi_rw($a, buf, 1, -1, cpun, sectno)
	adda	#16,sp			; clean up stack
	movem.l	(sp)+,d1-d2/a0-a2	; restore d1, d2, a0, a1, a2
	tst.w	d0			; read successful?
	beq.s	chkfat			; if yes, go check sum FAT sectors
					; else assume it's read error
	movem.l	d1-d2/a0-a2,-(sp)	; save registers d1, d2, a0, a2
	move.w	xdev(a6),d1		; drive number
	bsr	critic
	movem.l	(sp)+,d1-d2/a0-a2	; restore registers d1, d2, a0, a2
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq.s	cfat0			; if yes, go back and try it
	bra	ahrw7			; else return

chkfat:	bsr	bsum			; if ok, sum the sector
	addq	#1,a2			; ready for try next sector
	dbra	d2,cfat0		; until one FAT sector is summed

	bsr	csum			; find the checksum
	cmp.b	(a1)+,d0		; checksum recorded ?= checksum found
	bne	ismc			; if not, media has changed
	dbra	d1,cmpfat		; until all sectors are checked

	lea	mcflgs,a0		; a0 -> mcflgs table
	adda.w	xdev(a6),a0		; a0 -> mcflg of drive
	clr.b	(a0)			; clear mcflg for dev

ahrw1:	tst.w	xcount(a6)		; any sector to r/w?
	beq	ahrw6			; if =0, done

	cmpi.w	#-1,xrecno(a6)		; does recno = -1?
	bne.s	ahrw2			; if not, we have a word record #
	movea.l	xlrecno(a6),a1		; a1.l = start record #
	bra.s	ahrw3
ahrw2:	moveq	#0,d0			; coerce to long
	move.w	xrecno(a6),d0		; d0.l = recno
	movea.l	d0,a1			; a1.l = start record #

ahrw3:	move.l	a1,strec		; save first sector to r/w
	move.l	a1,d1			; d1.l = starting sector to r/w
	moveq	#0,d2			; coerce to long
	move.w	xcount(a6),d2		; d2.l = #sectors to r/w
	adda.l	d2,a1			; a1.l = last sector to r/w
	subq.l	#1,a1			;      = first sector + count - 1
	move.l	a1,endrec		; save last sector to r/w
	move.l	xbuf(a6),stbuf		; save starting buffer address

	btst.b	#3,xrw+1(a6)		; physical operation?
	bne.s	ahrw4			; if so, ready to r/w
					; else log -> phys sector mapping
	mulu	sizr,d1			; d1.l	= phys start sector to r/w
	add.l	cstart,d1		;	= dev start sect + sect #
	mulu	sizr,d2			; d2.l = # phys 512-byte sects to r/w

ahrw4:	move.w	xdev(a6),-(sp)		; device # (excluding A: and B:)
	move.l	d1,-(sp)		; starting sector
	move.l	d2,-(sp)		; count (in sectors)
	move.l	xbuf(a6),-(sp)		; buffer
	move.w	xrw(a6),-(sp)		; read write flag
	bsr	_do_rw			; do the read or write
	adda	#16,sp			; clean up stack
	tst.l	d0			; successful?
	beq.s	chkwr			; if so, go on to wrap up

	cmpi.l	#E_CHNG,d0		; media change detected?
	bne	ahrw7			; if not, give up
	btst.b	#3,xrw+1(a6)		; is this a physical operation?
	bne	ahrw7			; if so, return media change error
	bra	chkmc			; and go check if media has changed 
					; check if wrote to boot sector
chkwr:	move.w	xrw(a6),d0		; d0 = r/w and flags word
	btst	#0,d0			; read or write?
	beq	ahrw6			; if read, done
	btst.b	#6,cpun+1		; is drive removable?
	beq	ahrw6			; if not, done
	btst	#3,d0			; was it a physical operation?
	bne	ahrw6			; if it was, done
	tst.l	strec			; wrote to boot sector?
	bne.s	wrfat			; if not, check if wrote to FATs
	lea	mcflgs,a0		; else, a0 -> mcflgs table
	adda.w	xdev(a6),a0		; a0 -> dev's mcflg
	move.b	#2,(a0)			; assume medium has changed
					; check if wrote to FATs
wrfat:	lea	fatend,a0		; a0 -> fatend table
	move.w	xdev(a6),d0		; d0 = device number
	add.w	d0,d0			; d0*2 = index into table of words
	moveq	#0,d1			; coerce to long
	move.w	(a0,d0.w),d1		; d1 = last sector of last FAT
	cmp.l	strec,d1		; wrote beyond the last FAT?
	blt	ahrw6			; if so, done

	lea	fatst,a0		; a0 -> fatst table
	moveq	#0,d2			; coerce to long
	move.w	(a0,d0.w),d2		; d2 = first sector of last FAT
	cmp.l	endrec,d2		; wrote before the last FAT?
	bgt	ahrw6			; if so, done
					; else update FAT sector checksums
	move.l	stbuf,a0		; a0 -> buffer w/ written data
	lea	fatsum,a1		; a1 -> start of fatsum table
	move.w	xdev(a6),d0		; d0 = dev number
	mulu.w	#FATLEN,d0		; d0 = offset to dev's FAT chksum
	adda.l	d0,a1			; a1 -> dev's first FAT chksum
	move.l	strec,d0		; d0 = first sector wrote to
	sub.l	d2,d0			; d0 = strec - start(last FAT)
	beq.s	wrfat2			; if strec = start(last FAT), 
					;     no adjustments needed
 	blt.s	wrfat1			; if strec < start(last FAT)
					;     begin from start(last FAT)
	move.l	strec,d2		; else begin from strec
	adda.l	d0,a1			; a1 -> fatsum to be updated
	bra.s	wrfat2

wrfat1:	neg.l	d0			; d0 = index into stbuf
	asl.l	#8,d0			;    = (start(last FAT) - strec)*512
	add.l	d0,d0
	adda.l	d0,a0			; a0 -> addr of buf for update

wrfat2:	cmp.l	endrec,d1		; if end(last FAT) <= endrec
	ble.s	wrfat3			;     stop at end(last FAT)
	move.l	endrec,d1		; else stop at endrec

wrfat3:	sub	d2,d1			; d1 = # sectors to be processed
wrfat4:	move.w	sizr,d2			; d2 = # phys sect per log sect
	subq.w	#1,d2			; dbra likes one less
	clr.l	temp			; initialize sum
wrfat5:	bsr	bsum			; sum up one 512-byte sector
	adda.l	#512,a0			; point to next 512 bytes
	dbra	d2,wrfat5		; until one logical sector is done
	bsr	csum			; obtain checksum
	move.b	d0,(a1)+		; record new fat checksum
	dbra	d1,wrfat4		; do until all are updated

ahrw6:	clr.l	d0			; got here with no errors!
	bra.s	ahrw7

ismc:	lea	mcflgs,a0		; a0 -> mcflgs table
	adda.w	xdev(a6),a0		; a0 -> dev's mcflg
	move.b	#2,(a0)			; set mcflg for dev to has changed
	lea	xst,a0			; a0 -> drive existence table
	adda.w	xdev(a6),a0		; a0 -> xst flag of dev
	move.b	#2,(a0)			; assume dev exists
retmc:	move.l	#E_CHNG,d0		; yes, return media change error

ahrw7:	btst.b	#0,xrw+1(a6)		; read or write?
	bne.s	ahrwd			; if write, done
	tst.b	_cachexst		; does a cache exist?
	beq.s	ahrwd			; if not, done
					; else dump the cache
	move.l	d0,-(sp)		; save the status
	move	sr,-(sp)		; go to IPL 7
	ori	#$700,sr		; no interrupts right now kudasai
	movecacrd0			; d0 = (cache control register)
	ori.w	#$808,d0		; dump both the D and I cache
	moved0cacr			; update cache control register
	move	(sp)+,sr		; restore interrupt state
	move.l	(sp)+,d0		; restore the return value

ahrwd:	unlk	a6
	rts


;+
; smove() - Copy unaligned sectors (this is *supposed* to be slow!)
;
; Passed:
;	d0 = # of sectors to be moved
;	d1 = size of operation	(0 - byte; 2 - long;)
;	a2 -> source buffer
;	a1 -> dest buffer
;
; Trashes: d0, a1, a2
;-
smove:	move.w	d1,-(sp)		; save size of operation
	neg.w	d1			; d0 = count
	addi.w	#9,d1			;    = (# sectors * 512) >> op size
	asl.w	d1,d0			;
	subq.w	#1,d0			; dbra likes one less
	move.w	(sp)+,d1		; restore operation size
	bne.s	smove2			; if non-zero, use move longs

smove1:	move.b	(a2)+,(a1)+
	dbra	d0,smove1
	rts

smove2:	move.l	(a2)+,(a1)+
	dbra	d0,smove2
	rts


;
;+
; _do_rw - called to read/write no more than 128K to an even boundary
;
; Passed:
;	rw	4(sp).w		; non-zero -> write
;	buf	6(sp).l
;	count	$a(sp).l	; in # phys (512-byte) sectors
;	recno	$e(sp).l	; physical starting sector for r/w
;	dev	$12(sp).w	; log dev # exluding A: and B:
;
; Assumes:
;	cpun = current physical unit to r/w
;	if in logical mode, cstart = physical starting sector # of curr dev
;
; Mar-05-1990 ml.
;	All I/O to ACSI and SCSI non-accessible memory will be done by
; using the fast ram buffer (if there is one) or the diskbuf as an inter-
; mediate stop for the transfer.
;
; ACSI accessible memory:	$00000000 -> $003fffff
;				$ff000000 -> $ff3fffff
; SCSI non-accessible 
; memory on the TT:		$c0000000 -> $fcffffff
;				$fe000000 -> $feffffff
;
; Mar-07-1990 ml.
;	Do not have to take care of cases when Rwabs() is supplied with
; a buffer that would cross different kinds of memory.
; ("It's deadly!" said AKP. :) )
;-
yrw	equ	$8
ybuf	equ	$a
ycount	equ	$e
yrecno	equ	$12
ydev	equ	$16

; Memory that ACSI _can_ DMA to
STDUAL	equ	$003fffff	; upper limit of ST dual-purpose RAM
STCMPIL	equ	$ff000000	; lower limit of ST compatible image
STCMPIH	equ	$ff3fffff	; upper limit of ST compatible image

; Memory that SCSI _cannot_ DMA to (non-DW)
A32D16L	equ	$c0000000	; lower limit of A32:D16 Memory/Peripherals
A32D16H	equ	$fcffffff	; upper limit of A32:D16 Memory/Peripherals 
VA24D16	equ	$fe000000	; lower limit of VMEbus A24:D16
VA16D16	equ	$feffffff	; upper limit of VMEbus	A16:D16

; Cookies
_FRB	equ	$5f465242		; _FRB

_do_rw:	link	a6,#0			; create a frame pointer
	move.l	ycount(a6),d2		; d2.l = # sectors requested to r/w
 	movea.l	ybuf(a6),a1		; a1.l = buffer addr to r/w
	btst.b	#3,cpun+1		; talking SCSI?
	bne	scrw0			; if yes, go for it
					; else talk ACSI
	cmp.l	#MAXACSECTS,d2		; more than one ACSI DMAful?
	bls.s	acrw1			; if not, ready to r/w
	move.l	#MAXACSECTS,d2		; else r/w only one ACSI DMAful

acrw1:	btst.b	#0,ybuf+3(a6)		; buffer on odd boundary?
	bne.s	itrw0			; if so, do intermediate transfer

	cmpa.l	#STDUAL,a1		; buf within ACSI accessible memory?
	bls	rw1			; if so, go ahead with the I/O
	cmpa.l	#STCMPIL,a1		; else, do intermediate transfer
	bcs.s	itrw0
	cmpa.l	#STCMPIH,a1
	bls	rw1
					; doing intermediate transfer
itrw0:	moveq	#0,d1			; assume moving 1 byte at a time
	btst.b	#0,ybuf+3(a6)		; odd boundary?
	bne.s	itrw1			; if so, assumption ok
	moveq	#2,d1			; else move 1 long at a time

itrw1:	tst.l	frbbuf			; is there a fast RAM buffer?
	bne.s	itrw2			; if there is one, use it
					; else look for _FRB
	move.l	d1,-(sp)		; save d1
	move.l	#frbbuf,-(sp)		; pointer to fast RAM buffer
	move.l	#_FRB,-(sp)		; looking for cookie _FRB
	bsr	_getcookie		; 
	addq.w	#8,sp			; clean up stack
	move.l	(sp)+,d1		; restore d1
	tst.w	d0			; found _FRB?
	bne.s	itrw2			; if so, use it
					; else use dskbuf
	movea.l	_dskbufp,a1		; a1 -> dskbuf
	cmpi.w	#2,d2			; can only do 2 at a time tops
	bls.s	itrw3
	move.w	#2,d2
	bra.s	itrw3

itrw2:	movea.l	frbbuf,a1		; use the Fast RAM Buffer
	cmpi.w	#RAMRSV,d2		; can only do RAMRSV at a time tops
	bls.s	itrw3
	move.w	#RAMRSV,d2

itrw3:	btst.b	#0,yrw+1(a6)		; is this a read?
	beq.s	rw1			; if so, go fill buffer from disk
					; else fill buffer here
	move.l	a1,-(sp)		; preserve a1 = dest
	movea.l	ybuf(a6),a2		; a2 = source
	move.w	d2,d0			; # sectors to be moved
	bsr	smove			; move sectors from a2 to a1
	movea.l	(sp)+,a1		; restore a1.l = dest
	bra.s	rw1			; go do the r/w

scrw0:	cmpi.l	#MAXSCSECTS,d2		; more than one SCSI DMAful?
	bls.s	scrw1			; if not, ready to r/w
	move.l	#MAXSCSECTS,d2		; r/w only one SCSI DMAful?

scrw1:	

.if	SCDMA				; if doing SCSI DMA
.if	!SCFRDMA			; if no SCSI DMA to fast RAM
	cmpi.b	#$01,ybuf(a6)		; is destination buffer in fast RAM?
	beq	itrw0			; if so, do intermediate transfer
.endif	;!SCFRDMA

	cmpa.l	#A32D16L,a1		; buf in SCSI non-accessible
	bcs.s	rw1			;  memory?
	cmpa.l	#A32D16H,a1		; if so, do intermediate transfer
	bls	itrw0			; else, go ahead with the I/O
	cmpa.l	#VA24D16,a1
	bcs.s	rw1
	cmpa.l	#VA16D16,a1
	bls	itrw0
.endif	;SCDMA

	bra.s	rw1

rw0:	movea.l	ybuf(a6),a1		; a1 = buffer address for r/w
rw1:	move.w	_retries,retrycnt	; setup retry counter

	btst.b	#2,yrw+1(a6)		; are retries disabled?
	beq.s	rw2			; no, act normally
	move.w	#0,retrycnt		; yes, so set retrycnt to zero

rw2:	movem.l	d1-d2/a1,-(sp)		; preserve d1, d2 and a1
	move.w	cpun,-(sp)		; dev.w
	move.l	a1,-(sp)		; buf.l
	move.w	d2,-(sp)		; count.w
	move.l	yrecno(a6),-(sp)	; sect.L
	cmpi.l	#MAXACSECTS,d2		; more than hr/w can handle?
	bhi.s	rw4			; if so, use extended call (SCSI only)
	btst.b	#0,yrw+1(a6)		; read or write?
	bne.s	rw3			; (write)
	bsr	_hread			; read sectors
	bra.s	rw6
rw3:	bsr	_hwrite			; write sectors
	bra.s	rw6
rw4:	btst.b	#0,yrw+1(a6)		; read or write?
	bne.s	rw5			; (write)
	bsr	_xtdread		; read sectors
	bra.s	rw6
rw5:	bsr	_xtdwrt			; write sectors
rw6:	adda	#12,sp			; (cleanup stack)
	movem.l	(sp)+,d1-d2/a1		; restore d1, d2 and a1
	tst.l	d0			; errors?
	beq	rwf			; no error --> successful
	bmi.s	rw9			; timed out --> retry

	movem.l	d1-d2/a1,-(sp)		; preserve d1, d2 and a1
	bsr	errcode			; find error code
	movem.l	(sp)+,d1-d2/a1		; restore d1, d2 and a1

	cmpi.b	#MDMCHGD,d0		; media change detected?
	bne.s	rw7			; if not, fine
					; else record media may be changed
	move.b	#1,d0			; d0.b = 1 (may be changed)
	bsr	s_mc_xst		; set mcflgs and xst flags for all dev

	btst.b	#1,yrw+1(a6)		; ignore media change?
	bne	rw2			; if so, retry operation
	move.l	#E_CHNG,d0		; else return media change
	bra	rwr
	
rw7:	cmpi.b	#WRTPRTD,d0		; write on write-protected media?
	bne.s	rw8			; if not, fine
	move.l	#EWRPRO,d0		; else return write-protection error
	bra.s	rwa

rw8:	cmpi.b	#DRVNRDY,d0		; drive not ready?
	bne.s	rw9			; if not, fine
	move.l	#EDRVNR,d0		; else return drive not ready
	bra.s	rwa

rw9:	subq.w	#1,retrycnt		; drop retry count and retry
	bpl	rw2

	move.l	#EREADF,d0		; read error code
	btst.b	#0,yrw+1(a6)		; is it a write?
	beq.s	rwa			; (read)
	move.l	#EWRITF,d0		; write error code

rwa:	btst.b	#3,yrw+1(a6)		; is this a physical operation?
	bne	rwr			; if so, exit
					; else call critical error handler
	movem.l	d1-d2/a1,-(sp)		; preserve d1, d2 and a1
	move.w	ydev(a6),d1		; d1 = drive number
rwe:	bsr	critic
	movem.l	(sp)+,d1-d2/a1		; restore d1, d2 and a1
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq	rw2			; if yes, go retry
	bra.s	rwr			; else, head home

rwf:	lea	rw0,a0			; exec of next r/w starts at rw1
	cmpa.l	ybuf(a6),a1		; was alternate buffer used?
	beq.s	rw10			; if not, go on to next r/w
					; else take care of transfer
	lea	itrw3,a0		; exec of next r/w starts at itrw3
	btst.b	#0,yrw+1(a6)		; was it a write?
	bne.s	rw10			; if it was, go on to next write
					; else move data to supplied buffer
	move.l	a1,-(sp)		; save address of alternate buffer
	movea.l	a1,a2			; a2 = address of alternate buffer
	movea.l	ybuf(a6),a1		; a1 = address of supplied buffer
	move.w	d2,d0			; d0 = # of sectors to move
	bsr	smove			; move data from alt buf to sup buf
	move.l	(sp)+,a1		; restore address of alternate buffer

rw10:	sub.l	d2,ycount(a6)		; ycount(a6) = # sects left to be done
	beq.s	rwd			; if no more left, done
					; else get ready for next r/w
	add.l	d2,yrecno(a6)		; yrecno(a6) = next starting sector
	move.l	d2,d0			; d0 = # bytes done
	asl.l	#8,d0			;    = # sectors done * 512
	add.l	d0,d0			; 
	add.l	d0,ybuf(a6)		; buf += (sectors_done * sector size)
	cmp.l	ycount(a6),d2		; amount to r/w > amount doable?
	bls.s	rw11			; if so, r/w amount doable
	move.l	ycount(a6),d2		; else r/w all of it
rw11:	jmp	(a0)			; go on to next r/w

rwd:	moveq	#0,d0			; got here with no errors!
rwr:	unlk	a6			; head home
	rts


;
;+
; Check for media change on hard disk
; Synopsis:	_sasi_mediach(dev)
;		WORD dev;		4(sp).w
;
; Returns:	0L - media definitely has not changed
;		1L - media _may_ have changed
;		2L - media definitely has changed
;
; Uses:		d0, d1, a0, a1
;
; Comments:
; Apr-4-1989	ml.	Add in grace period between _sasi_mediach()s.
;			If _sasi_mediach() was called less than 1 s
;			(200 _hz_200 clock ticks) ago, and medium was 
;			not changed then, assume medium still has not 
;			changed.
;-
_sasi_mediach:
	subq.w	#2,4(sp)		; dev # excluding drv A and B
	move.w	4(sp),d1		; d1 = current drive
	lea	mcflgs,a0		; a0 = pointer to mcflgs
	moveq	#0,d0			; d0 = mcflg for current drive
	move.b	(a0,d1.w),d0	
	tst.b	d0			; has medium changed?
	bne.s	decided			; if yes or maybe, return result
					; else verify that it has not
	move.l	lastmdctm,d2		; time media change was last called
	cmp.l	_hz_200,d2		; while (_hz_200 <= lastmdctm)
	bcc.s	decided			;	assume medium not changed

	lea	pun,a1			; ptr to beginning of pun table
	move.b	(a1,d1.w),cpun+1	; cpun = pun current drive belongs to

	btst.b	#6,cpun+1		; is pun removable?
	beq.s	notchngd		; if not, medium has not changed

	move.w	cpun,-(sp)		; physical unit number
	bsr	_untrdy			; verify by doing test unit ready
	addq.l	#2,sp
	move.l	_hz_200,lastmdctm	; update time for last _sasi_mediach()
	addi.l	#200,lastmdctm		; 
	tst.w	d0			; return good status?
	beq.s	notchngd		; if yes, return medium not changed
	moveq	#1,d0			; else return medium may have changed
	bsr	s_mc_xst		; set mcflgs and xst flags to 1's
	bra.s	decided
notchngd:
	moveq	#0,d0			; return medium has not changed
decided:
	rts


;+
; s_mc_xst - set mcflgs and drive existence flags 
;	     for drives belonging to the current
;	     physical unit to value passed
;
; Passed:	d0.b - value to set to
;-
s_mc_xst:
	movem.l	d1-d2/a0-a2,-(sp) ; save registers
	lea	pun,a0		; a0 -> pun table
	lea	mcflgs,a1	; a1 -> mcflgs table
	lea	xst,a2		; a2 -> drive existence table
	move.w	cpun,d1		; d1 = current physical unit #
	moveq	#0,d2		; d2 = logical drive #; index into tables
set0:	btst.b	#7,(a0,d2.w)	; a valid logical drive?
	bne.s	setr		; if not, done
	cmp.b	(a0,d2.w),d1	; else, does it belong to this physical unit?
	bne.s	set1		; if not, move on to next logical drive
	move.b	d0,(a1,d2.w)	; else change its mcflg to value passed
	move.b	d0,(a2,d2.w)	; and change its xst to value passed
set1:	addq.w	#1,d2		; try next one in forward direction
	cmp.w	#MAXUNITS,d2	; all units checked?
	blt.s	set0		; if not, go on
setr:	movem.l	(sp)+,d1-d2/a0-a2 ; else restore registers
	rts			; and return


;
;+
; Resident Installer
;-
	.globl	i_sasi6
i_sasi6:
;+
; 02-Apr-1991	ml.	The following is illegal, because i_sasi1 is 
;			external.
;	move.l	#(i_sasi1-i_sasi),tokeep ; at least keep this much
;-
	move.l	#i_sasi1,tokeep ; tokeep = amount of code to be kept
	subi.l	#i_sasi,tokeep
	cmpi.w	#512,maxssz	; maxssz > 512 bytes?
	bls.s	nboot1		; if not, don't need to replace GEMDOS buffers
				; else check if there is enough memory for
chkmem:	bsr	chklstmem	;   new GEMDOS buffer lists
	tst.l	d0		; enough?
	bpl.s	okbig		; if so, build the list
	move.w	defbigsect,d0	; d0 = minimum big sector
	cmp.w	maxssz,d0	; is maxssz >= minimum big sector?
	bcc.s	regsect		; if so, give up
	move.w	d0,maxssz	; else try minimum big sector
	bra.s	chkmem
regsect:
	move.w	#512,maxssz	; will not handle big sectors
	bra.s	nboot1

okbig:	move.l	d1,tokeep	; update amount of memory to be kept
	lea	i_sasi1,a0	; a0 -> beginning of new buffer lists
	moveq	#3,d1		; d1 = count = 4 buffers - 1
	bsr	list_init	; initialize the buffer list
	clr.l	(a0,d0.w)	; cut 1 list of 4 buffers to 2 lists of 2
	move.l	a0,_bufl	; _bufl[0] -> 1st new buffer list
	add.l	d0,d0		; d0 = offset to beginning of 2nd buffer list
	adda.l	d0,a0		; a0 = head of 2nd buffer list
	move.l  a0,_bufl+4	; _bufl[1] -> 2nd new buffer list

nboot1:	bsr	pool_install	; attempt to install more OS pool
	add.l	d0,tokeep	; update amount of memory to be kept

;	clr.l	frbbuf		; assume no _FRB
;	move.l	#frbbuf,-(sp)	; pointer to fast RAM buffer
;	move.l	#$5f465242,-(sp)    ; cookie "_FRB"
;	bsr	_getcookie	; try to find _FRB in cookie jar
;	addq.w	#8,sp		; clean up stack

	move.l	_hz_200,lastmdctm	; initialize media change time
	tst.w	bootloaded	; if bootloaded, then already in super mode
	bne.s	nboot2		; (already there)
	move.l	savssp,-(sp)	; become a mild mannered user process
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq.w	#6,sp

;+
; Terminate and stay resident;
; installed driver under GEMDOS.
;-
	move.l	tokeep,d0	; compute value for Ptermres()
	add.l	#$0100,d0	; for basepage
	move.l	d0,-(sp)	; save D0
	pea	msg_nbl(pc)	; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	(sp)+,d0
	move.w	#0,-(sp)	; exit code
	move.l	d0,-(sp)
	move.w	#$31,-(sp)	; terminate and stay resident
	trap	#1		; should never come back...
	illegal


;+
;  Return to TOS ROMs
;    - set default boot device to C:
;    - Print silly message
;    - Mshrink() memory that was alloc'd to us
;    - set magic# in D7 for TOS ROMs
;    - RTS back to ROMs
;-
nboot2:	move.l	tokeep,d0	; compute value for Mshrink
	add.l	#$1c,d0		; for file header
	move.l	d0,-(sp)	; save D0
	pea	msg_bl(pc)	; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack

	move.w	d4,d1		; physical unit # in d4.w?
	bpl.s	bd0		; if so, good
				; else it's in hi 3 bits of d7.b
	move.b	d7,d1		; d1.b = physical unit # boot loaded from
	lsr.b	#5,d1		;      = xxx00000 >> 5
bd0:	lea	pun,a0		; a0 -> pun table
	moveq	#0,d2		; d2 = boot dev
bd1:	move.b	(a0,d2.w),d0	; d0.b = unit #
	andi.b	#$0f,d0		; mask out flags
	cmp.b	d0,d1		; d2 belongs to physical unit booted from?
	beq.s	bd2		; if yes, set (d2) as boot device
	addq.w	#1,d2		; else try next logical unit
	bra.s	bd1
bd2:	addq.w	#2,d2		; offset for drive A and B
	move.w	d2,_bootdev	; set default boot device to (d2)

	move.l	baseaddr,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; Mshrink(...)
	trap	#1
	adda	#12,sp		; (cleanup stack)

	move.w	_bootdev,-(sp)	; set boot dev as default drive
	move.w	#$e,-(sp)	; Dsetdrv(_bootdev)
	trap	#1
	addq.w	#4,sp		; cleanup stack

	move.l	#rootpath,-(sp)	; set root as current directory
	move.w	#$3b,-(sp)	; Dsetpath('\')
	trap	#1
	addq.w	#6,sp		; cleanup stack
;
;	move.l	_sysbase,a0	; get the system header address
;	move.l	$18(a0),d0	; d0.l = MMDDYYYY of ROM date
;	swap	d0		; d0.l = YYYYMMDD of ROM date
;	cmp.l	#CHKDATE,d0	; does this version of ROM need bootstop?
;	bcs.s	stopall		; yup, if OS is built before 4/22/87
;	move.b	puns+1,d7	; else prevent processed units from booting
;	subq.b	#1,d7		; unit # = # of units - 1
;	lsl.b	#5,d7
;	rts			; return to TOS ROMs
;
; Stop ANY subsequent boot after the hard disk boot -- FOR NOW!!
;

stopall:
	move.b	#$100-$20,d7	; prevent any other unit from booting
	rts			; return to TOS ROMs

rootpath:
	dc.b	'\\',0
msg_bl:
	dc.b	'BOOTLOADED',13,10,0
msg_nbl:
	dc.b	'NOT Bootloaded',13,10,0
.even


;+
; list_init - Initialize a GEMDOS buffer list (BCBs are contiguous)
;
; Passed:
; 	a0.l = head of buffer list			(not changed)
;	d0.l = size of each BCB (including data block)	(not changed)
;	d1.w = count
;	     = number of buffers to be installed to the list - 1
;
; Uses:
;	d1, a1
;-
list_init:
	move.l	a0,-(sp)	; save head of buffer list
lin0:	movea.l	a0,a1		; a1 -> next BCB
	adda.l	d0,a1		;    -> curr BCB + size of BCB
	move.l	a1,(a0)		; b_link -> next BCB
	move.w	#-1,4(a0)	; b_neg1 = -1
	adda.w	#BCBLEN,a0	; a0 -> BCB data block
	move.l	a0,-4(a0)	; b_bufr -> b_space
	movea.l	a1,a0
	dbra	d1,lin0
	suba.l	d0,a0		; a0 -> last BCB
	clr.l	(a0)		; lastBCB.b_link = NULL
	move.l	(sp)+,a0	; restore head of buffer list
	rts


;+
; chklstmem - check if enough memory is allocated to replace GEMDOS
;		buffer lists
;
; Returns:
;	d0.l = size of each BCB (including data block)
;	     or -1 if not enough memory is allocated
;	d1.l = new amount of memory to be kept if enough is allocated
;
; Uses:
;	d0, d1
;-
chklstmem:
	moveq	#BCBLEN,d0	; d0.l = size of each BCB (inc. data block)
	add.w	maxssz,d0	;      = BCB header len + data block size
	move.l	d0,d1		; d1.l = d0.l * 4 
	lsl.l	#2,d1		;      = total size of buffer lists
	add.l	tokeep,d1	; d1.l = size needed
	cmp.l	memalloc,d1	; enough memory allocated?
	bls.s	chk0		; if so return
	moveq	#-1,d0		; else return error
chk0:	rts


;
;+
; critic - call up the critical error handler.
;
; Passed:
;	d0.w = error code
;	d1.w = drive # excluding A: and B:
;
; Uses:
;	d0, d1, a0
;
; Returns:
;	d0.l = whatever returned by the critical handler
;		(magic RETRY code or something)
;-
critic:	addq.w	#2,d1			; drive # including A: and B:
	move.w	d1,-(sp)		; drive #
	move.w	d0,-(sp)		; error code
	movea.l	etv_critic,a0		; a0 = address of error handler
	jsr	(a0)			; critic_handler(error, drive)
	addq.l	#4,sp			; clean up stack
	rts				; return


;+
; errcode - find error code for previous Check Condition Status
;
; Assumed:
;	cpun = current physical unit number
;
; Returns:
;	d0.b = error code	(aka additional sense code)
;
; Sep-13-1989	ml.	For non-extended request sense, ask for 0 byte.
;			(0 is default to return 4 bytes.)
;-
	.globl	errcode
errcode:
	moveq	#22,d1			; assume requesting extended sense
	move.w	cpun,d0			; d0 = physical unit number
	btst	#3,d0			; a SCSI unit?
	bne.s	err0			; if so, ready to request
	andi.w	#07,d0			; else mask off other flags
	btst.b	d0,embscsi		; an embedded SCSI unit using ACSI?
	bne.s	err0			; if so, request extended sense
	moveq	#0,d1			; else request non-extended sense
err0:	lea	sendata,a0		; a0 -> sense data buffer
	movem.l	d1/a0,-(sp)		; save data len and buffer address
	move.l	a0,-(sp)		; sense data buffer
	move.w	d1,-(sp)		; data length (in bytes)
	move.w	d0,-(sp)		; physical unit number
	bsr	_rqsense		; find out error code
	addq.l	#8,sp			; clean up stack
	movem.l	(sp)+,d1/a0		; restore d1 and a0
	tst.w	d0			; successful?
	beq.s	err1			; if not, return
	moveq	#-1,d0			; error occurred
	rts
err1:	cmpi.w	#4,d1			; extended or non-extended?
	bgt.s	err2			; if extended, go get code
	move.b	(a0),d0			; else byte 0 = error code
	andi.b	#$7f,d0			; mask off valid bit
	rts
err2:	move.b	12(a0),d0		; else byte 12 = error code
	rts


;
;+
; OS Pool Expansion
;-

.if ospool
;+
;  Wire more pool into various ROM releases.
;
;    Passed:	nothing
;    Returns:	D0 = #bytes extra used
;-
pool_install:
	move.l	_sysbase,a3		; a3 -> base of OS

; make sure we're in ROM,
; then get address of RAM location to patch:

	cmp.l	#$800000,a3		; better be ROM
	blt	notrom
	lea	pool_tab(pc),a0		; a0 -> table to match
pi_lp:	move.l	(a0)+,d1		; d1 = date to match
	beq	badrom			; (forget it, end of list)
	move.l	(a0)+,a2		; a2 -> _root address for that date
	cmp.l	$18(a3),d1		; match dates?
	bne.s	pi_lp			; (no -- try again)

	move.w	numchunks,d0		; d0 = amount of BSS to be used
	mulu	#chunksiz,d0		;    = # chunks * size of a chunk
	move.l	d0,d1			; d1 = total memory needed
	add.l	tokeep,d1		;    = already keeping + extra OS pool
	cmp.l	memalloc,d1		; enough is allocated?
	bgt.s	bdrom2			; if not, don't add any
					; else install more OS pool
	movea.l	#i_sasi+2,a0		; a0 -> base of first buffer
	adda.l	tokeep,a0		;    = start of file + already keeping
	move.l	a0,-(sp)		; save base of first buffer
	move.w	numchunks,d1		; d0 = count-1
	subq.w	#1,d1
pin_1:	lea	chunksiz(a0),a1		; a1 -> next buffer
	move.l	a1,(a0)			; buffer -> next one
	move.w	#chunkno,-2(a0)		; install chunksiz
	move.l	a1,a0			; a0 -> next buffer
	dbra	d1,pin_1		; (do some more)

	sub.w	#chunksiz,a0		; a0 -> last block
	move.l	chunkno*4(a2),(a0)	; last block -> first in root
	move.l	(sp)+,chunkno*4(a2) 	; root -> first of ours
	rts				; return OK

;+
;  Print warning messages
;  about bogus versions of the
;  operating system.  Assume that
;  every OS past 1-May-1986 has the
;  pool fix installed.
;
;-
ok_date	=	%0000110010100001	; 1-May-1986
notrom:	lea	m_notrom(pc),a0		; ram-based system (5/29!)
	bra.s	bdrom1
badrom:	lea	m_badrom(pc),a0		; illegal ROM system
bdrom1:	cmp.w	#ok_date,$1e(a3)	; if ok_date <= os_dosdate(a3) 
	bcc	bdrom2			; then don't print anything

	move.l	a0,-(sp)		; print nasty message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

; print msg and wait for RETURN
	pea	keymsg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

bdrom3:	move.w	#2,-(sp)		; wait for [RETURN]
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	cmp.w	#13,d0
	bne	bdrom3

bdrom2:	moveq	#0,d0			; 0 extra bytes used
	rts

keymsg:	dc.b	'Hard disk driver not loaded; hit RETURN',13,10
	dc.b	'key to continue:',13,10
	dc.b	0

m_notrom:
	dc.b	'*** WARNING ***',13,10,7
	dc.b	'This hard disk driver may not work with',13,10,7
	dc.b	'a disk-based version of TOS; files on',13,10,7
	dc.b	'your hard disk may be damaged.',13,10,7
	dc.b	13,10,7
	dc.b	0

m_badrom:
	dc.b	'*** WARNING ***',13,10,7
	dc.b	'You are using an unofficial ROM release',13,10,7
	dc.b	'of the operating system.  This driver',13,10,7
	dc.b	'may not work correctly with it.  Files',13,10,7
	dc.b	'on your hard disk may be damaged.',13,10,7
	dc.b	13,10,7
	dc.b	0
	even


;+
;  Table of ROM release dates / _root addresses
;  update these for new ROM releases that need the patch.
;
;-
pool_tab:
	dc.l	$11201985,$56fa		; USA and UK, 20-Nov-1985
	dc.l	$02061986,$56fa		; Germany, 6-Feb-1986
	dc.l	$04241986,$56fa		; France, 24-Apr-1986
	dc.l	0			; end of list

.endif


