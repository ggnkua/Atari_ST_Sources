	.title	'AHDI Atari Hard Disk Driver 9.00'

;------------------------------------------------------------------------
;									:
;	AHDI Hard Disk Driver for the Atari ST				:
;	Copyright 1985,1986,1987 Atari Corp.				:
;	All Rights Reserved						:
;									:
;------------------------------------------------------------------------


;----------------
;
;  Conditional Assembly Switches
;
sermsg		equ	0		; for timeout messages
sahdxc		equ	0		; simple atari hard disk command
format		equ	1		; include format code
ospool		equ	1		; increase size of OS pool for ROM


;---
;   Default drive size,
;   exactly one of the following:
;
s20mb		equ	1		; 20 Mb drive
s10mb		equ	0		; 10 Mb drive


	.subttl	'Edit History'

;------------------------------------------------------------------------
;									:
; 23-Jan-1987 lmd	Converted to MADMAC, added configurable pool	:
;    version 9.00	setup, cleaned up several years of source-code	:
;			abuse.  Fixed the date-probe problem in the OS	:
;			version-check code.				:
;									:
;---------------- Ancient History:					:
;									:
;  9-Apr-1985 lmd	Hacked it up.  "Gee, it seems to work ..."	:
; 14-Apr-1985 lmd	linked with BIOS (***FOR NOW***)		:
; 20-Apr-1985 lmd	hacked for WD controller (now, wired...)	:
; 24-Jun-1985 jwt	hacked for Adaptec, new kludge board		:
; 01-Jul-1985 jwt	seems to work, add more formatting and more	:
;			 detailed error reporting			:
; 22-Jul-1985 jwt	change timing of wdc/wdl at start of command,	:
;			 added extra move.w $8a,wdl to change A1	:
; 23-Jul-1985 jwt	use a move.l instruction for all wdc/wdl write	:
;			 pairs since it changes A1 quickly enough that	:
;			 the (old) DMA chip does not incorrectly	:
;			 generate two chip selects			:
; 26-Sep-1985 jwt v0.05	support multiple ACSI devices			:
;			separate timeouts for command packet and	:
;			 operation					:
; 01-Oct-1985 jwt v0.06	added some AUXout serial debug messages		:
;			was responding to one more drive than was there	:
; 07-Oct-1985 jwt v0.07	added support for multiple partitions/drive	:
; 11-Oct-1985 jwt v0.08 added delay loop after pread for completion	:
;			 byte						:
; 19-Oct-1985 jwt v0.09	remove format and simple commands from resident :
;			 part						:
;			conditional assembly for default size		:
;			added count parameter to pread			:
; 22-Oct-1985 jwt v0.10	make certain qdone returns d0=-1 on timeout	:
;			add bits to read/write flag for:		:
;			 retry disable (bit 2)				:
;			 physical unit operation (bit 3)		:
;			add pun_ptr to TOS global variables		:
; 24-Oct-1985 jwt v0.11	add critical error call on errors		:
; 30-Jan-1986 lmd v0.12	increase OS pool by 128 chunks for ROM release	:
;			 of 11/20/85					:
;	      jwt	stay resident if any physical units found	:
;			 rather than if any GEM partitions found	:
; 05-Feb-1986 jwt	call critical error handler on errors unless	:
;			 no-retry bit is set				:
;			conditional assembly format code		:
;			remove transfer only to even byte boundary	:
;			 restriction					:
;			remove transfer less than 128K restriction	:
;			check for 0 length transfer			:
; 06-Feb-1986 jwt v0.13	use register based accesses for wdc and wdl	:
; 25-Mar-1986 lmd v0.14 Enforce .0005 (200th) sec delay between		:
;			successive calls to _do_rw().  SCSI adapter	:
;			board eat's the controller's completion byte,	:
;			so we have to delay for it.			:
; 24-Apr-1986 lmd v1.1	Hack pool_install code to increase pool for	:
;			other ROM releases of the system.		:
; 24-Apr-1986 lmd v1.4	Print nasty messages for old disk-based and	:
;			unauthorized ROM-based systems.			:
;									:
;------------------------------------------------------------------------

	.subttl	'Equates and Declarations'

etv_critic	equ	$404		; critical error handoff vector
flock		equ	$43e		; FIFO lock variable
_bootdev	equ	$446		; default boot device
_hz_200		equ	$4ba		; system 200hz timer
hdv_init	equ	$46a		; hdv_init()
hdv_bpb		equ	$472		; hdv_bpb(dev)
hdv_rw		equ	$476		; hdv_rw(rw, buf, count, recno, dev)
hdv_boot	equ	$47a		; hdv_boot()
hdv_mediach	equ	$47e		; hdv_mediach(dev)
_drvbits	equ	$4c2		; block device bitVector
_dskbufp	equ	$4c6		; pointer to common disk buffer
pun_ptr		equ	$516		; pointer to physical unit table

maxunits	equ	16		; maximum number of units
nretries	equ	3		; #retries-1

MAXSECTORS	equ	254		; maximum number of sectors at one gulp

EWRITF		equ	-10		; GEMDOS error codes
EREADF		equ	-11
CRITRETRY	equ	$00010000	; "retry" return code

_sysbase	= $4f2			; -> base of OS
chunksiz	= 66			; #bytes/chunk
chunkno		= 4			; chunk# (4 16-byte chunks)

	.subttl	'Entry Points'

;----------------
;
;  Entry points:
;
;	+0   GEMDOS entry point (double-click, or \AUTO folder on floppy)
;	+4   Boot entry point (from driver file off of C:)
;	+8   Reserved for future use
;	+$C  $F0AD magic number
;	+$E  # chunks to add to pool
;
i_sasi:	bra.w	i_sasi1			; GEMDOS entry-point
	bra.w	iboot			; Boot entry-point
	bra.w	iboot			; (unused, reserved)


;----------------
;
;  Patchable (?) variables
;
YAMagicNumber:	dc.w	$f0ad		; wasn't here in previous releases
Version:	dc.w	$0900		; version number
numchunks:	dc.w	128		; #chunks in pool
bootloaded:	dc.w	0		; nonzero if loaded from boot sector
baseaddr:	dc.l	0		; -> base addr of .PRG file



;----------------
;
;  Boot entry;
;    set "bootloaded", record base address from boot loader,
;    and continue with normal boot process.
;
iboot:	st	bootloaded		; boot entry-point, set flag
	move.l	a2,baseaddr		; install base address
	bra	i_sasi1			; (continue with normal initialization)

	.subttl	'Front End'

;----------------
;
;  Return pointer to BPB (or NULL)
;
;    Synopsis:	LONG hbpb(dev)
;		    WORD dev;
;
hbpb:	.cargs .dev.w
	move.w	.dev(sp),d0		; d0 = devno
	clr	d1			; d1 = 0, physical op not possible
	move.l	o_bpb,a0		; a0 -> pass-through vector
	lea	_sasi_bpb(pc),a1	; a1 -> our handler
	bra	check_dev		; do it



;----------------
;
;  Read or write logical sectors
;
;    Synopsis:	LONG rw(rw, buf, count, recno, dev)
;		    WORD rw;
;		    char *buf;
;		    WORD count;
;		    WORD recno;
;		    WORD dev;
;
hrw:	.cargs	.rw.w, .buf.l, .count.w, .recno.w, .dev.w
	move.w	.dev(sp),d0		; d0 = devno
	move.w	.rw(sp),d1		; d1 includes physical device flag
	move.l	o_rw,a0			; a0 -> pass-through vector
	lea	_sasi_rw(pc),a1		; a1 -> our handler
	bra	check_dev		; do it



;----------------
;
;  Check for media change
;
;    Synopsis:	LONG mediach(dev)
;		    WORD dev;
;
hmediach: .cargs .dev.w
	move.w	.dev(sp),d0		; d0 = devno
	clr	d1			; physical operation not possible
	move.l	o_mediach,a0		; a0 -> pass-through vector
	lea	_sasi_mediach(pc),a1	; a1 -> our handler


;----------------
;
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
;
check_dev:
	btst	#3,d1			; is this a physical unit operation?
	beq.s	.phys			; (yes, use raw number)

	subq	#2,d0			; lowest device is C:
	bmi.s	.fail			; not one of ours

	cmp	puns,d0
	bge.s	.fail
	bra.s	.succ

.phys:	lea	pun,a2			; pointer to pun map
	tst.b	(a2,d0.w)		; must be positive for a real unit
	bmi.s	.fail
.succ:	move.l	a1,a0			; yes -- follow success vector
.fail:	jmp	(a0)			; do it



	.subttl	'Medium Level Driver'

;----------------
;
;  Initialize SASI device
;
;    Passed:	nothing
;    Returns:	d0 < 0: error
;		d0 ==0: success
;
_sasi_init:
	clr.l	d0
	rts


;----------------
;
;  Return BPB for logical device
;
;    Synopsis:	LONG _sasi_bpb(dev)
;		    WORD dev;
;
;    Returns:	NULL, or a pointer to the BPB buffer
;
;-
_sasi_bpb: .cargs .dev.w
	move.w	.dev(sp),d0		; get device number
	mulu.w	#BPBLEN,d0
	add.l	#bpbs,d0
	rts

	.eject

;----------------
;
;  Read/Write sectors
;
;    Synopsis:	_ahdi_rw(rw, buf, count, recno, dev)
;		    WORD rw;
;		    char *buf;
;		    WORD count;
;		    WORD recno;
;		    WORD dev;
;
; Passed:	dev	$e(sp).W
;		recno	$c(sp).W
;		count	$a(sp).W
;		buf	6(sp).L
;		rw	4(sp).W		; non-zero -> write
;
_sasi_rw:
_ahdi_rw: .cargs #8, .rw, .buf.l, .count, .recno, .dev
	link	a6,#0			; create a frame pointer

.1:	move.w	.count(a6),d2		; is there anything to be done?
	beq	.6			; no, so done with no errors

	move.l	.buf(a6),d1		; if all goes well, this is our buffer

	cmpi.w	#MAXSECTORS,d2		; more than one DMAfull?
	ble	.2
	move.w	#MAXSECTORS,d2		; yes, so only do this many this time

.2:	btst	#0,.buf+3(a6)		; an odd boundary?
	beq	.4			; no, so do normally

	cmpi.w	#2,d2			; can only do 2 at a time tops this way
	ble	.3
	move.w	#2,d2

.3:	move.l	_dskbufp,d1		; use the bios buffer for this transfer

	btst	#0,.rw+1(a6)		; is this a write?
	beq	.4			; no, so go fill buffer from disk

	movea.l	d1,a1			; dest
	movea.l	.buf(a6),a2		; source
	bsr	smove			; move d2 sectors from a2 to a1

.4:	move.w	d2,-(sp)		; preserve count this time

	move.w	.dev(a6),-(sp)
	move.w	.recno(a6),-(sp)
	move.w	d2,-(sp)		; count
	move.l	d1,-(sp)		; buffer
	move.w	.rw(a6),-(sp)
	bsr	_do_rw
	adda.w	#12,sp

	move.w	(sp)+,d2		; restore count for this op

	tst.l	d0			; any errors there?
	bne	.7			; yes, so give up

	btst	#0,.buf+3(a6)		; if odd boundary
	beq	.5
	btst	#0,.rw+1(a6)		; and a read
	bne	.5

	movea.l	.buf(a6),a1		; we must move dskbuf to desired dest
	movea.l	_dskbufp,a2
	bsr	smove

.5:	move.w	d2,d0			; number we did
	ext.l	d0
	asl.l	#8,d0			; *512
	asl.l	#1,d0
	add.l	d0,.buf(a6)		; buf += (sectors_done * sector size)
	add.w	d2,.recno(a6)
	sub.w	d2,.count(a6)
	bne	.1

.6:	clr.l	d0			; got here with no errors!
.7:	unlk	a6
	rts

;----------------
;
;  Copy unaligned sectors
;  (this is *supposed* to be slow!)
;
;    Passed:	d2.w	= # of sectors (known to be 1 or 2)
;		a2	-> source sector
;		a1	-> dest buffer (oddly aligned)
;
smove:	move.w	d2,d0			; d0 = (d2 * 512) - 1
	asl.w	#8,d0
	asl.w	#1,d0
	subq.w	#1,d0
.1:	move.b	(a2)+,(a1)+
	dbra	d0,.1
	rts

	.eject
;+
; _do_rw - called to read/write no more than 128K to an even boundary
;
; Passed:	dev	$e(sp).W
;		recno	$c(sp).W
;		count	$a(sp).W
;		buf	6(sp).L
;		rw	4(sp).W		; non-zero -> write
;
;-
_do_rw:
	move.w	d3,-(sp)		; preserve d3

.0:	move.w	_retries,retrycnt	; setup retry counter

	move.w	6(sp),d3
	btst	#2,d3			; are retries disabled?
	beq	.1			; no, act normally
	move.w	#0,retrycnt		; yes, so set retrycnt to zero

;
; read sector(s),
; delay .0005 to .001 seconds between driver calls
;
.1:
	move.l	lastrwtm,d0
.8:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastrwtm)
	bcc	.8			;	just_wait;
	move.l	_hz_200,d0		; lastrwtm = _hz_200 + 1;
	addq.l	#1,d0
	move.l	d0,lastrwtm

	lea	2(sp),a1		; frame pointer
	moveq	#0,d0			; coerce word to long, unsigned
	move.w	$c(a1),d0		; sect.L
	move.w	4(a1),d3		; rw

	btst	#3,d3			; physical unit operation
	beq	.2			; no, so do log->phys mapping

	move	$0e(a1),d2		; get unit number
	subq	#2,d2			; subtract drive C offset
	bra	.3			; and use that as the physical unit

.2:	clr	d2			; coerce byte to word
	move.w	$e(a1),d1		; get device
	lea	pun,a2
	move.b	0(a2,d1.w),d2		; get physical unit number
.3:	move.w	d2,-(sp)		; dev
	move.l	6(a1),-(sp)		; buf
	move.w	$a(a1),-(sp)		; count

	btst	#3,d3			; physical operation?
	bne	.4			; yes, so no offset

	asl.w	#2,d1			; *4 to get index into long array
	lea	start,a2
	add.l	0(a2,d1.w),d0		; adjust sector number

.4:	move.l	d0,-(sp)		; sect
	btst	#0,d3			; read or write?
	bne	.5			; (write)
	bsr	_hread			; read sectors
	bra	.6
.5:	bsr	_hwrite			; write sectors
.6:	add.w	#12,sp			; (cleanup stack)
	tst.l	d0			; errors?
	beq	.r			; no -- success
	subq.w	#1,retrycnt		; drop retry count and retry
	bpl	.1

	move	6(sp),d1		; get r/w and flags word
	move.l	#EREADF,d0		; read error code
	btst	#0,d1
	beq	.7
	move.l	#EWRITF,d0		; write error code

.7:	btst	#2,d1			; is this a "raw" operation?
	bne	.r			; yes, so no critical error handler

	move.w	$10(sp),-(sp)		; unit number
	move.w	d0,-(sp)		; error code (as a word, sic)
	movea.l	etv_critic,a0
	jsr	(a0)
	addq	#4,sp
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq	.0

.r:	move.w	(sp)+,d3		; remember to restore d3
	rts


;----------------
;
;  Check for media change on hard disk
;   (this never happens)
;
;    synopsis:	_sasi_mediach(dev)
;		    WORD dev;
;
;    Returns:	0L (always)
;
;-
_sasi_mediach:
	clr.l	d0
	rts


	.subttl	'Low-Level Driver'

;----------------
;
;  Hardware definitions
;
wdc		equ	$ffff8604
wdl		equ	$ffff8606
wdcwdl		equ	wdc		; used for long writes
xwdl		equ	wdl-wdc		; offset from wdc to wdl

dmahi		equ	$ffff8609
dmamid		equ	dmahi+2
dmalow		equ	dmamid+2
gpip		equ	$fffffa01


;----------------
;
;  Tunable (delay) values
;
ltimeout		equ	450000		; long-timeout (3 S)
stimeout		equ	15000		; short-timeout (100 mS)


;----------------
;
;  LONG _qdone() - Wait for command byte handshake
;  LONG _fdone() - Wait for operation complete
;
;  Passed:	nothing
;
;  Returns:	EQ: no timeout
;		MI: timeout condition
;
;  Uses:		D0
;
;    Each pass through the loop takes 6.75 uS
;
_fdone:	move.l	#ltimeout,tocount	; setup for long timeout
	bra.s	qd1

_qdone:	move.l	#stimeout,tocount	; setup for short timeout
qd1:	subq.l	#1,tocount		; drop timeout count
	bmi.s	.quit			; (I give up, return NE)
	btst	#5,gpip			; interrupt?
	bne.s	qd1			; (not yet)
	moveq	#0,d0			; return EQ (no timeout)
	rts
.quit:	moveq	#-1,d0			; return NE (timeout)
	rts


;----------------
;
;  Wait for end of SASI command
;
;  Passed:	d0 value to be written to wdl
;
;  Returns:	EQ: success (error code in D0.W)
;		MI: timeout
;		NE: failure (SASI error code in D0.W)
;
;  Uses:	d0,d1
;
_endcmd:
	move	d0,d1			; preserve wdl value
	bsr	_fdone			; wait for operation complete
	bmi.s	.end			; (timed-out, so complain)
	move.w	d1,wdl			; write controller register
	NOP				; [magic delay]
	move.w	wdc,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should
.end:	rts				;  do a ReadSense command to learn more


;----------------
;
;  _hread(sectno, count, buf, dev)
;    LONG sectno;	 4(sp)
;    WORD count;	 8(sp)
;    LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
;    WORD dev;		$e(sp)
;
; Returns:	-1 on timeout
;		0 on success
;		nonzero on error
;
;-
_hread:	.cargs .sectno.l .count.w .buf.l .dev.w
	lea	wdc.w,a0		; a0 -> DMA chip
	st	flock			; lock FIFO

	move	#$88,xwdl(a0)
	clr.l	d0
	move.w	.dev(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$0008008a,d0		; 08 wdc, 8a wdl
	move.l	d0,(a0)			; wdcwdl [long write]

	move.l	.buf(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq	#4,sp

	bsr	_setss			; set sector and size
	bmi	_hto			; (punt on failure)

	move.w	#$190,xwdl(a0)		; toggle R/W to reset chip
	NOP				; magic delay
	move.w	#$90,xwdl(a0)		; select sector count register
	NOP				; magic delay
	move.w	8(sp),(a0) ;wdc		; write sector count to DMA chip
	NOP				; magic delay
	move.w	#$8a,xwdl(a0)		; ??? select bus again ???
	NOP				; magic delay
	move.l	#$00000000,(a0)		; write control byte, 0 wdc 0 wdl

	move.w	#$8a,d0			; ???
	bsr	_endcmd
	bra	_hdone			; cleanup after IRQ


;----------------
;
;  _hwrite(sectno, count, buf, dev)
;    LONG sectno;	 4(sp)
;    WORD count;	 8(sp)
;    LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
;    WORD dev;		$e(sp)
;
;-
_hwrite: .cargs .sectno.l .count.w .buf.l .dev.w
	lea	wdc.w,a0		; a0 -> DMA chip
	st	flock			; set lock variable

	move.l	.buf(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq	#4,sp

	move.w	#$88,xwdl(a0)
	clr.l	d0
	move.w	.dev(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$000a008a,d0		; 0a wdc 8a wdl
	move.l	d0,(a0)			; wdcwdl

	bsr	_setss
	bmi	_hto

	move.w	#$90,xwdl(a0)		; toggle R/W to reset chip
	NOP
	move.w	#$190,xwdl(a0)		; select sector count register
	NOP
	move.w	8(sp),(a0) ;wdc		; sector count for DMA chip's benefit
	NOP
	move.w	#$18a,xwdl(a0)		; ???
	NOP
	move.l	#$00000100,(a0)		; wdcwdl

	move.w	#$18a,d0
	bsr	_endcmd
	bra	_hdone			; cleanup after IRQ


;----------------
;
;  Set DMA address
;
;    _setdma(addr)
;	LONG addr;
;
_setdma:
	move.b	7(sp),dmalow
	move.b	6(sp),dmamid
	move.b	5(sp),dmahi
	rts


;----------------
;
;  Set sector number and number of sectors
;
_setss:	move.w	#$8a,xwdl(a0)

	bsr	_qdone			; wait for controller to take command
	bmi	setsse

	move.b	9(sp),d0		; construct sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) ; wdcwdl	; write MSB sector# + devno
	bsr	_qdone
	bmi	setsse

	move.b	10(sp),d0		; write MidSB sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) ; wdcwdl
	bsr	_qdone
	bmi	setsse

	move.b	11(sp),d0		; write LSB sector#
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) ; wdcwdl
	bsr	_qdone
	bmi	setsse

	move.w	12(sp),d0		; write sector count
	swap	d0
	move.w	#$008a,d0
	move.l	d0,(a0) ; wdcwdl
	bsr	_qdone

setsse:	rts


;----------------
;
;  Handle command timeout;
;  Unlock DMA chip and return completion status;
;
_hto:	moveq	#-1,d0		; indicate timeout
_hdone:	move.w	#$80,wdl	; Landon's code seems to presume we
	nop			;  put this back to $80
	tst.w	wdc
	clr	flock		; NOW, signal that we are done
	rts

	.subttl	'Resident Installer'
;----------------
;
;
isasi5:	bsr	pool_install	; attempt to install more OS pool
	move.l	d0,-(sp)	; preserve the number of bytes we need

	tst.w	bootloaded	; if bootloaded, then already in super mode
	bne	nboot1		; (already there)
	move.l	savssp,-(sp)	; become a mild mannered user process
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq	#6,sp

nboot1:	move.l	(sp)+,d0	; compute value for Ptermres() or Mshrink
	add.l	#((i_sasi1-i_sasi)+$0100),d0

	tst.w	bootloaded	; exit to GEMDOS?
	beq	nboot2		; (yes -- not boot loaded)

;----------------
;
;  Return to TOS ROMs
;    o  set default boot device to C:
;    o  Print silly message
;    o  Mshrink() memory that was alloc'd to us
;    o  set magic# in D7 for TOS ROMs
;    o  RTS back to ROMs
;
	move.l	d0,-(sp)		; save D0
	pea	msg_loaded(pc)		; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	move.l	(sp)+,d0

	move.w	#2,_bootdev		; set default boot device to C:
	move.l	d0,-(sp)
	move.l	baseaddr,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)		; Mshrink(...)
	trap	#1
	add.w	#12,sp			; (cleanup stack)


exec_os		equ	$4fe

;----------------
;
;  Bring up the AES:
;    do autoexec;
;    construct an enviroment string;
;    create a basepage for the AES;
;    exec the AES.
;
st_1:
	bsr	_auto			; do auto-exec
	pea	orig_env		; push address of enviroment string
	pea	nullenv(pc)		; no arguments
	pea	nullenv(pc)		; null shell name (in ROM, after all)
	move.w	#5,-(sp)		; createPSP flavor of exec
	move.w	#$4b,-(sp)		; exec function#
	trap	#1			; get pointer to PSP
	add.w	#14,sp			; (clean up cruft)
	move.l	d0,a0			; a0 -> PSP
	move.l	exec_os,8(a0)		; stuff saddr of GEM in PSP

	move.l	a0,-(sp)		; push addr of PSP
	pea	nullenv(pc)		; null filename
	move.w	#4,-(sp)		; just-go

st_x:	move.w	#$4b,-(sp)		; function = exec
	trap	#1			; do it
	add.w	#14,sp			; cleanup stack

;---
;   When startup fails (or if the exec returns,
;   which "cannot happen") then fake a system reset:
;
	move.l	4,a0			; get RESET vector
	jmp	(a0)			; ... then fake a RESET



;---
;   Default enviroment string
;
orig_env:
	dc.b	"PATH=",0		; default pathname
	dc.b	"C:\\",0		; is the boot device
	dc.b	0			; terminate env string


gemname: dc.b	"GEM.PRG"		; desktop name
nullenv: dc.b	0,0			; null string (and enviroment)
	even


;---
;   Auto path for hard disks (C:)
;
autopath:	dc.b	'C:\\AUTO\\'
autofile:	dc.b	'*.PRG',0
		dc.w	$1234,$5678,$9abc,$def0
	even

	.subttl	'\\AUTO Folder Execution'
;----------------
;
;  _auto	exec auto-startup files in the appropriate subdirectory
;  _auto1	exec (with filename args)
;
;    Passed:	a0 -> full filespec (pathname)
;		a1 -> filename part of filespec
;
;    Returns:	nothing
;
;    Uses:	everything
;
_auto:	lea	autopath(pc),a0		; -> path
	lea	autofile(pc),a1		; -> filename

_auto1:	move.l	(sp)+,autoret		; copy return addr (used by execlr)
	move.l	sp,origstk		; (save original stack)
	move.l	a0,pathname		; setup filename/pathname ptrs
	move.l	a1,filename

	lea	nullenv(pc),a3		; a0 -> \0\0
	move.l	a3,-(sp)		; null enviroment
	move.l	a3,-(sp)		; null command tail
	move.l	a3,-(sp)		; null shell name
	move.w	#5,-(sp)		; Create-PSP subfunction
	move.w	#$4b,-(sp)		; exec function#
	trap	#1			; do DOS call
	add.w	#16,sp

	move.l	d0,a0			; a0 -> PSP
	move.l	#fauto,8(a0)		; initial PC -> autoexec prog

	move.l	a3,-(sp)		; null enviroment
	move.l	d0,-(sp)		; -> PSP
	move.l	a3,-(sp)		; null shell name
	move.w	#4,-(sp)		; just-go
	move.w	#$4b,-(sp)		; function = exec
	trap	#1			; do it
	add.w	#16,sp			; cleanup stack & goodbye
autoq:	move.l	autoret,-(sp)
	rts



;----------------
;
;  fauto	Pexec()'d by _auto to do autostartup
;
;    Passed:	pathname -> path part of filespec
;		filename -> file part of filespec
;
fauto:
	move.w	#2,-(sp)		; Dsetdrv(2)
	move.w	#$e,-(sp)
	trap	#1
	addq	#4,sp

	clr.l	-(sp)			; get into super mode
	move.w	#$20,-(sp)
	trap	#1
	addq	#6,sp			; cleanup
	move.l	d0,a4			; a4 -> saved super stack

;---
;   free up some memory:
;
	move.l	4(a7),a5		; a5 -> base page
	lea	$100(a5),sp		; sp -> new, safer addr
	move.l	#$100,-(sp)		; keep $100 (just the basepage)
	move.l	a5,-(sp)		; -> start of mem to keep
	clr.w	-(sp)			; junk word
	move.w	#$4a,-(sp)		; setblock(...)
	trap	#1
	addq	#6,sp
	tst.w	d0
	bne	au_dn			; punt on error

	move.w	#$0007,-(sp)		; find r/o+hidden+system files
	move.l	pathname,-(sp)		; -> filename (on input)
	move.w	#$4e,-(sp)		; searchFirst

	moveq	#8,d7			; d7 = cleanup amount
au1:	pea	autodma			; setup DTA (for search)
	move.w	#$1a,-(sp)
	trap	#1
	addq	#6,sp

	trap	#1			; search first/search next
	add.w	d7,sp			; cleanup stack
	tst.w	d0			; test for match
	bne	au_dn			; (no match -- quit)

;--- construct filename from path and the name we just found:
	move.l	pathname,a0		; copy pathname
	move.l	filename,a2		; a2 -> end+1 of pathname
	lea	autoname,a1
au3:	move.b	(a0)+,(a1)+		; copy path part of name
	cmp.l	a0,a2			; finished?
	bne	au3			; (no)
	lea	autodma+30,a0		; copy fname to end of pathname
au2:	move.b	(a0)+,(a1)+
	bne	au2

	pea	nullenv(pc)		; null enviroment
	pea	nullenv(pc)		; no command tail
	pea	autoname		; -> file to exec
	clr.w	-(sp)			; load-and-go
	move.w	#$4b,-(sp)		; exec(...)
	trap	#1
	add.w	#16,sp

	moveq	#2,d7			; reset cleanup amount
	move.w	#$4f,-(sp)		; searchNext
	bra	au1

;---
;   The first GEMDOS process can never terminate.
;   This is not a good feature.
;   Kludge around it -- re-initialize the stack
;   and return to the guy who called us to begin with.
;
au_dn:	move.l	origstk,sp		; restore original stack
	move.l	autoret,-(sp)		; get return addr
	rts				; just jump there ...


;--- "bss" for auto-exec:
autoret:	dc.l	0		; -> _auto's caller (yeccch)
pathname:	dc.l	0		; -> filespec's pathname
filename:	dc.l	0		; -> filename part of path
origstk:	dc.l	0		; =  original supervisor stack
autodma:	dcb.b	44,0		; 44 bytes for directory search
autoname:	dcb.b	32,0		; 32 bytes for path+filename
	even


msg_loaded:
	dc.b	'----------------------',13,10
	dc.b	'Atari Hard Disk Driver',13,10
	dc.b	'16-Jun-1986       AHDI',13,10
	dc.b	'----------------------',13,10
	dc.b	0
    even

;
;  Terminate and stay resident;
;  installed driver under GEMDOS.
;
nboot2:	move.w	#0,-(sp)	; exit code
	move.l	d0,-(sp)
	move.w	#$31,-(sp)	; terminate and stay resident
	trap	#1		; should never come back...
	illegal


	.subttl	'OS Pool Expansion'

    .if ospool
;----------------
;
;  Wire more pool into various ROM releases.
;
;    Passed:	nothing
;    Returns:	D0 = #bytes extra used
;
;
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
	bne	pi_lp			; (no -- try again)

	lea	poolbuf+2,a0		; a0 -> base of first buffer
	move.w	numchunks,d0		; d0 = count-1
	subq.w	#1,d0
pin_1:	lea	chunksiz(a0),a1		; a1 -> next buffer
	move.l	a1,(a0)			; buffer -> next one
	move.w	#chunkno,-2(a0)		; install chunksiz
	move.l	a1,a0			; a0 -> next buffer
	dbra	d0,pin_1		; (do some more)

	sub.w	#chunksiz,a0		; a0 -> last block
	move.l	chunkno*4(a2),(a0)	; last block -> first in root
	move.l	#poolbuf+2,chunkno*4(a2) ; root -> first of ours
	move.w	numchunks,d0		; d0 = numchunks * chunksiz
	mulu	#chunksiz,d0		;    = amount of BSS we used
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
	addq	#6,sp

; print msg and wait for RETURN
	pea	keymsg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

bdrom3:	move.w	#2,-(sp)		; wait for [RETURN]
	move.w	#2,-(sp)
	trap	#13
	addq	#4,sp
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
	dc.l	0
    .endif


	.subttl	'Driver State'
BPBLEN	equ	18
_puns:
puns:	dc.w	0

_pun:
pun:	dcb.b	maxunits,0
_partstart:
start:	dcb.l	maxunits,0
bpbs:	dcb.b	maxunits*18,0

lastrwtm:	dc.l	0		; ``_hz_200 + 1'' at last _do_rw()
tocount:	dc.l	1		; timeout counter
retrycnt:	dc.w	1		; retry counter
_retries:	dc.w	nretries	; number of retries to do

o_init:		dc.l	1
o_bpb:		dc.l	1
o_rw:		dc.l	1
o_mediach:	dc.l	1

 .if ospool
poolbuf:	dc.w	0
 .endif

	.subttl	'Driver Installation'

;----------------
;
;  Driver Installation
;
i_sasi1:
	tst.w	bootloaded		; if boot-loaded, don't Super()
	bne	nboot3
	clr.l	-(sp)			; it's a bird...
	move.w	#$20,-(sp)		;    ... it's a plane ...
	trap	#1			;      ... no, its:
	addq	#6,sp			; SOOUPERUSER!
	move.l	d0,savssp		; "Faster than a prefetched opcode..."

nboot3:	move	#maxunits-1,d1
	moveq	#-1,d0			; a bad pun
	lea	pun,a0
i_sasi2: move.b	d0,(a0)+
	dbra	d1,i_sasi2

	move	#2,clun			; current logical unit number
	move.l	#4,cdbit		; current drive bit
	move	#0,cpun			; current physical unit number
	move	#0,installed		; none installed yet
	move	#0,puns			; no physical units found

i_sasi3:
	move.w	cpun,-(sp)		; pread(sectno, cnt, buf, physunit)
	move.l	#pbuf,-(sp)
	move.w	#1,-(sp)		; 1 sector
	move.l	#0,-(sp)		; sectno = 0
	bsr	pread			; try to read root sector
	adda	#12,sp

	tst.w	d0
	bne	i_sasi4			; no controller/disk of that ACSI unit

	addq	#1,puns			; found a physical unit

	bsr	ppu

	addq	#1,cpun
	cmpi	#8,cpun
	bne	i_sasi3

i_sasi4: tst	puns			; any drives found?
	beq	isase			; nope, so just terminate

	clr.l	a5			; zeropage ptr
	move.l	hdv_bpb(a5),o_bpb	; save old vectors
	move.l	hdv_rw(a5),o_rw
	move.l	hdv_mediach(a5),o_mediach

	move.l	#hbpb,hdv_bpb(a5)	; install our new ones
	move.l	#hrw,hdv_rw(a5)
	move.l	#hmediach,hdv_mediach(a5)
	move.l	#_puns,pun_ptr(a5)

	bra	isasi5		; must get back into resident part

isase:	tst.w	bootloaded	; if bootloaded, free block and punt
	bne	isaseb
	move.l	savssp,-(sp)	; become a mild mannered user process
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq	#6,sp

	move.w	#-1,-(sp)	; exit code
	move.w	#$4C,-(sp)	; terminate
	trap	#1		; should never come back...
	illegal

;
;  Couldn't install driver, return to boot code
;
isaseb:	move.l	baseaddr,-(sp)	; Mfree(baseaddr)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.b	#$100-$20,d7	; return to TOS ROMs
	rts


	.subttl	'Partition Support'
;----------------
;
;  pread(sectno, cnt, buf, physunit)
;    LONG sectno;
;    BYTE *buf; (word aligned)
;    WORD cnt,physunit;
;
;    Passed:	dev.w		$a(a0)	$e(sp)
;		&buf.l		$6(a0)	$a(sp)
;		cnt.w		$4(a0)	$8(sp)
;		sectno.l	$0(a0)	$4(sp)
;
;    Returns:	-1 if we could not read it (may not exist)
;
_pread:
pread:	move	_retries,retrycnt
pread1:	lea	4(sp),a0		; frame pointer
	move.w	$a(a0),-(sp)		; push physical unit number
	move.l	$6(a0),-(sp)		; buffer address
	move.w	$4(a0),-(sp)		; number to read
	move.l	(a0),-(sp)		; sector number
	bsr	_hread
	adda	#12,sp
	tst	d0
	beq	pread9			; no problems
	bmi	pread8			; timeout, does not exist
	subq	#1,retrycnt		; read error, try try again
	bpl	pread1
pread8:	moveq	#-1,d0
	rts

pread9:	move	#$8000,d0		; delay for completion byte
preada:	subq	#1,d0
	bne	preada
	clr.l	d0			; flag no errors
	rts


	.eject
;----------------
;
;  Partition physical unit
;
ppu:	move	#0,npart		; number of partitions we have found
	movea.l	#pbuf+hd_siz,a0
	tst.l	(a0)+
	beq	ppu3			; if 0, must not be valid

	moveq	#4-1,d1			; maximum number of partitions/unit
ppu1:	movem.l	d1/a0,-(sp)
	tst.b	(a0)+			; check the valid partition flag
	beq	ppu2			; if 0, not a valid parition

	addq	#1,npart		; number of partitions this unit

	cmpi.b	#'G',(a0)+		; must find GEM as type
	bne	ppu2
	cmpi.b	#'E',(a0)+
	bne	ppu2
	cmpi.b	#'M',(a0)+
	bne	ppu2

	tst.l	4(a0)			; is the size 0?
	beq	ppu2			; then not a valid partition

	move.l	(a0),-(sp)		; save start sector

	bsr	nxtdrv

	move.l	(sp)+,d1		; recall start sector

	tst	d0			; valid unit?
	bmi	ppu2

	movem.l	d1/a0-a1,-(sp)

	move.l	d1,-(sp)		; getbpb(partition_start)
	bsr	getbpb			; build bpb and put it in place
	addq	#4,sp

	movem.l	(sp)+,d1/a0-a1

	tst	d0
	bne	ppu2

	move.w	cpun,d0
	move.b	d0,(a0)

	move.l	d1,(a1)			; start of partition

	addq	#1,clun
	addq	#1,installed		; actually installed a hard disk

ppu2:	movem.l	(sp)+,d1/a0
	adda	#12,a0
	dbra	d1,ppu1

	tst	npart			; did we find any?
	bne	ppu9

ppu3:	bsr	nxtdrv			; no valid partitions found, assume
	move	cpun,d0			;  whole thing is one big GEM disk
	move.b	d0,(a0)
	move.w	#0,(a1)			; starts at 0
	lea	thebpb,a1
	move	#BPBLEN-1,d0
ppu4:	move.b	(a1)+,(a2)+
	dbra	d0,ppu4

	addq	#1,clun
	addq	#1,installed

ppu9:	rts


	.eject
;+
; nxtdrv	(of clun, cdbit)
;	returns d0 = clun, or negative if error
;		a0 -> pun(clun)
;		a1 -> start(clun)
;		a2 -> bpbs(clun)
;-

nxtdrv:	cmpi	#maxunits,clun		; have we already hit maximum?
	bge	nxtd9			; yes, so signal error

	move.l	cdbit,d1		; get the next bit to turn on
	move.l	_drvbits,d0		; tell TOS we have the drive
	or.l	d1,d0
	move.l	d0,_drvbits

	asl.l	#1,d1
	move.l	d1,cdbit
	move	clun,d0
	lea	pun,a0
	adda	d0,a0
	lea	start,a1
	move	d0,d1
	asl	#2,d1			; *4 for index into table of longs
	adda	d1,a1
	lea	bpbs,a2
	move	d0,d1
	mulu	#BPBLEN,d1
	adda	d1,a2
	rts

nxtd9:	moveq	#-1,d0
	rts

	.eject
;+
; getbpb(sectorno)
; LONG sectorno;
;-

getbpb:	move.l	a2,-(sp)

	move.w	cpun,-(sp)		; try to read this partition's
	move.l	#lbuf,-(sp)		; boot sector
	move.w	#1,-(sp)		; number of sectors
	move.l	16(sp),-(sp)		; sectorno
	bsr	pread			; pread(sectno, cnt, buf, physunit)
	adda	#12,sp

	movea.l	(sp)+,a2

	tst	d0			; any trouble reading?
	bmi	getb9			; bummer

	lea	lbuf,a3			; pointer to boot sector

	move	#$0b,d0
	bsr	getlhw
	move	d0,(a2)+		; =byt/sec
	move	d0,d1

	clr.w	d0
	move.b	$d(a3),d0
	move	d0,(a2)+		; =sec/cluster

	mulu	d1,d0
	move	d0,(a2)+		; =byt/cluster

	move	#$11,d0
	bsr	getlhw			; number of directory entries
	mulu	#32,d0			; size of each entry
	divu	d1,d0			; number of sectors required
	move.l	d0,d1
	swap	d1
	tst	d1
	beq	getb1
	addq	#1,d0			; round up
getb1:	move	d0,(a2)+		; =rdlen
	move	d0,d2

	move	#$16,d0
	bsr	getlhw
	move	d0,(a2)+		; =FATsize
	move	d0,d1

	move	#$e,d0
	bsr	getlhw			; number of reserved sectors
	add	d1,d0
	move	d0,(a2)+		; =2nd FAT start

	add	d1,d0			; plus size of second fat
	add	d2,d0			; plus rdlen
	move	d0,(a2)+		; = data start
	move	d0,d2			; save start of data

	move	#$13,d0
	bsr	getlhw			; number of sectors on media
	sub	d2,d0			; subtract number used by FATs,dir,boot
	clr.l	d1
	move	d0,d1
	clr	d0
	move.b	$d(a3),d0		; number of sectors/cluster
	divu	d0,d1			; rounding down
	move	d1,(a2)+		; =number of clusters
	move	#1,(a2)			; =flags, 16 bit fats
	clr.l	d0			; no errors
getb9:	rts


;+
; WORD getlhw(d0=offset)
; returns word (low,high) from 0(D0,A3)
;-

getlhw:	move	d1,-(sp)		; preserve d1
	move.b	1(a3,d0.w),d1
	lsl.w	#8,d1
	move.b	0(a3,d0.w),d1
	move	d1,d0
	move	(sp)+,d1
	rts

	.subttl	'Format Hard Disk'
    .if format


;----------------
;
;  Parameter Block
;
acfmt:	dc.b	4	; format command + devno (upper 3 bits)
	dc.b	0	; (unused)
	dc.b	0	; (unused) data pattern
ac_in:	dc.b	0,0	; interleave factor MSB, LSB
	dc.b	0	; reserved
	.EVEN


;----------------
;
;  _doformat - format hard disk
;
;    Synopsis:	LONG _doformat(dev, interlv)
;		WORD dev;			4(sp).W
;		WORD interlv;			6(sp).W
;

_doformat:
	move.w	4(sp),d0		; set dev#
	lsl.b	#5,d0			; up 5 bits, fill in 0s
	or.b	#4,d0			; OR-in with FORMAT command
	move.b	d0,acfmt		; stuff into command frame
	move.b	6(sp),ac_in		; set interleave
	move.b	7(sp),ac_in+1

	lea	acfmt(pc),a0		; pick up pointer to the command block
	clr.w	d0
	st	flock			; lock FIFO
	move.w	#$88,wdl
	move.b	(a0)+,d0		; get the command byte
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdc			; byte wdc 8a wdl

	moveq	#(5-1),d1		; write remaining 5 bytes of command
fmt1:	bsr	_qdone
	bmi	_hto
	move.b	(a0)+,d0		; next byte of command
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl
	dbra	d1,fmt1

fmt2:	btst	#5,gpip			; wait (forever) for completion
	bne	fmt2
	move.w	wdc,d0			; get the status
	andi.w	#$00FF,d0		; only low byte is significant
	bra	_hdone			; cleanup after IRQ

	.subttl	'Set Format Parameters'

;----------------
;
;  _mode_set - set hard disk format parameters
;
;    Synopsis:	LONG _mode_set(dev, parms)
;		WORD dev;			4(sp).W
;		char *parms;			6(sp).L
;
_mode_set:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq	#4,sp

;---
;   write command and dev#
;
	move.w	#$88,wdl
	move.w	4(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$0015008a,d0		; write dev# + ModeSelect + FIFO bits
	move.l	d0,wdcwdl		; mdsel+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 1
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 2
	bsr	_qdone
	bmi	wdx

	move.l	#$0000008a,wdcwdl	; byte 3
	bsr	_qdone
	bmi	wdx

	move.l	#$0016008a,wdcwdl	; 22 bytes of parameters (byte 4)
	bsr	_qdone
	bmi	wdx

	move.w	#$90,wdl		; reset the DMA chip
	nop
	move.w	#$190,wdl
	nop
	move.w	#$01,wdc		; 1 sector of DMA (actually less)
	nop
	move.w	#$18a,wdl
	nop
	move.l	#$00000100,wdcwdl	; byte 5 (control byte)
	move.w	#$18a,d0		; wdl value
	bsr	_endcmd			; wait for command completion
wdx:	bra	_hdone

  .endif	; format

	.eject
  .if sahdxc
;+
; LONG _dosahdxc( dev, addr ) BYTE *addr;
;	do a simple (no DMA) ahdx command
;-
_dosahdxc: movea.l 6(sp),a0		; pick up pointer to the command block
	clr.w	d0
	st	flock			; lock FIFO
	move.w	#$88,wdl
	move	4(sp),d0		; get the unit number
	lsl	#5,d0			; shift it into place
	or.b	(a0)+,d0		; or in the command byte
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl		; send it to the controller

	moveq	#(5-1),d1		; write remaining 5 bytes of command
dosac1:	bsr	_qdone
	bmi	_hto
	move.b	(a0)+,d0		; next byte of command
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl
	dbra	d1,dosac1

	bsr	_fdone			; wait for the command to complete
	bmi	_hto

	move.w	wdc,d0			; get the status
	andi.w	#$00FF,d0		; only low byte is significant

	bra	_hdone			; cleanup after IRQ

  .endif	; sahdxc


	.subttl	'Prototype BPBs'
  .if s10mb
;+
; BPB for 10MB drive
;-
thebpb:	dc.w	512			; #bytes/sector
	dc.w	2			; #sectors/cluster
	dc.w	1024			; #bytes/cluster
	dc.w	16			; rdlen (256 root files) (in sectors)
	dc.w	41			; FATsiz (10300 FAT entries) (sectors)
	dc.w	42			; 2nd FAT start
	dc.w	99			; data start (in sectors)
	dc.w	10300			; #clusters (approximate here)
	dc.w	1			; flags (16-bit FATs)
  .endif

  .if s20mb
;+
; BPB for 20MB drive
;-
thebpb:	dc.w	512			; #bytes/sector
	dc.w	2			; #sectors/cluster
	dc.w	1024			; #bytes/cluster
	dc.w	32			; rdlen (512 root files) (in sectors)
	dc.w	81			; FATsiz (20736 FAT entries) (sectors)
	dc.w	82			; 2nd FAT start
	dc.w	195			; data start (in sectors)
	dc.w	20710			; #clusters (approximate here)
	dc.w	1			; flags (16-bit FATs)
  .endif

  .if sahdxc

actur:	dc.b	0,0,0,0,0,0		; atari command: test unit ready

  .endif	; sahdxc


	.even

	bss
savssp:	ds.l	1			; (saved SSP)
clun:	ds.w	1
cpun:	ds.w	1
cdbit:	ds.l	1
npart:	ds.w	1			; number of partitions found this pun
installed: ds.w	1			; number hard disk partitions installed

hd_siz	equ	$1c2			; offset into pbuf for partition info
pbuf:	ds.b	512
lbuf:	ds.b	512

	end
