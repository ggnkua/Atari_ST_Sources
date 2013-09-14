* acsc.s
	.include "version.s"

sermsg		equ	0		; for timeout messages
sahdxc		equ	0		; simple atari hard disk command
format		equ	0		; include Format code
mdsense		equ	0		; include Mode Sense code
ospool		equ	0		; increase size of OS pool for ROM
SCSI		equ	1		; include SCSI code
MC68030		equ	1		; running on a '30
VERBOSE		equ	0		; messages out ST MFP port task time
* SCDMA		equ	1		; use DMA for SCSI transfers

  .if MC68030
	.include "68030.s"
  .endif ;MC68030

* default drive size (one and only one of the following)
s10mb		equ	0
s20mb		equ	0
s11mb		equ	1

*------------------------------------------------------------------------
*									:
*	ST SASI/AHDI hard disk driver					:
*	Copyright 1985 Atari Corp.					:
*									:
*----									:

* $Log:	ahdi.s,v $
* Revision 1.6  86/06/13  10:56:37  dyer
* Install boot-load handler code, fix some bugs and minor
* misfeatures in the hard disk access code.
* 
* Revision 1.5  86/04/24  17:18:23  dyer
* Add logs, fix typos, remove garbage.
* 

*----
*  9-Apr-1985 lmd	Hacked it up.  "Gee, it seems to work ..."	:
* 14-Apr-1985 lmd	linked with BIOS (***FOR NOW***)		:
* 20-Apr-1985 lmd	hacked for WD controller (now, wired...)	:
* 24-Jun-1985 jwt	hacked for Adaptec, new kludge board		:
* 01-Jul-1985 jwt	seems to work, add more formatting and more	:
*			 detailed error reporting			:
* 22-Jul-1985 jwt	change timing of wdc/wdl at start of command,	:
*			 added extra move.w $8a,wdl to change A1	:
* 23-Jul-1985 jwt	use a move.l instruction for all wdc/wdl write	:
*			 pairs since it changes A1 quickly enough that	:
*			 the (old) DMA chip does not incorrectly	:
*			 generate two chip selects			:
* 26-Sep-1985 jwt v0.05	support multiple ACSI devices			:
*			separate timeouts for command packet and	:
*			 operation					:
* 01-Oct-1985 jwt v0.06	added some AUXout serial debug messages		:
*			was responding to one more drive than was there	:
* 07-Oct-1985 jwt v0.07	added support for multiple partitions/drive	:
* 11-Oct-1985 jwt v0.08 added delay loop after pread for completion	:
*			 byte						:
* 19-Oct-1985 jwt v0.09	remove format and simple commands from resident :
*			 part						:
*			conditional assembly for default size		:
*			added count parameter to pread			:
* 22-Oct-1985 jwt v0.10	make certain qdone returns d0=-1 on timeout	:
*			add bits to read/write flag for:		:
*			 retry disable (bit 2)				:
*			 physical unit operation (bit 3)		:
*			add pun_ptr to TOS global variables		:
* 24-Oct-1985 jwt v0.11	add critical error call on errors		:
* 30-Jan-1986 lmd v0.12	increase OS pool by 128 chunks for ROM release	:
*			 of 11/20/85					:
*	      jwt	stay resident if any physical units found	:
*			 rather than if any GEM partitions found	:
* 05-Feb-1986 jwt	call critical error handler on errors unless	:
*			 no-retry bit is set				:
*			conditional assembly format code		:
*			remove transfer only to even byte boundary	:
*			 restriction					:
*			remove transfer less than 128K restriction	:
*			check for 0 length transfer			:
* 06-Feb-1986 jwt v0.13	use register based accesses for wdc and wdl	:
* 25-Mar-1986 lmd v0.14 Enforce .0005 (200th) sec delay between		:
*			successive calls to _do_rw().  SCSI adapter	:
*			board eats the controller's completion byte,	:
*			so we have to delay for it.			:
* 24-Apr-1986 lmd v1.1	Hack pool_install code to increase pool for	:
*			other ROM releases of the system.		:
* 24-Apr-1986 lmd v1.4	Print nasty messages for old disk-based and	:
*			unauthorized ROM-based systems.			:
* 23-Jun-1987 lmd v1.5  Fix date-check in nasty-OS-message code; wrong	:
*			offset into the OS header (now $1e).		:
*									:
* 06-Nov-1987 akp v1.7	Added procedure findpackages and call to it.	:
* 10-Nov-1987 akp	Changed source to MADMAC format.		:
*			Removed format flag from top of file.		:
* 24-Nov-1987 akp	Really made v1.7 work.				:
* 19-Feb-1987 ml	Added format and mode sense code for use in 	:
*			HDX  (It's conditional, code will only be	:
*			included for ahdi.prg, and not shdriver.sys).	:
* 23-Feb-1989 jwt	hack in some SCSI 5380 code
*------------------------------------------------------------------------

etv_critic	equ	$404		; critical error handoff vector
phystop		equ	$42e		; physical top of memory
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

 .if ospool
_sysbase	= $4f2			; -> base of OS
numchunks	= 128			; #chunks to add to pool
chunksiz	= 66			; #bytes/chunk
chunkno		= 4			; chunk# (4 16-byte chunks)
 .endif

* ---------------- Installer ----------------
	.globl	i_sasi
i_sasi:	bra.w	i_sasi1			; GEMDOS entry-point
	st	bootloaded		; boot entry-point, set flag
	move.l	a2,baseaddr		; install base address
	bra	i_sasi1			; (continue with normal initialization)

bootloaded:	dc.w	0		; nonzero if loaded from boot sector
baseaddr:	dc.l	0		; -> base addr of .PRG file

	dc.b	'@(#)acsc.s '
  .if !SCDMA
	dc.b	'(ND) '
  .endif ;SCDMA
	dc.b	' '
	VERSION
	dc.b	$0d,$0a,0,$1A
	.even

* page 
* ---------------- Front End ----------------


*+
* LONG hbpb(dev) - return ptr to BPB (or NULL)
*
* Passed:	dev	4(sp).W
*
*-
hbpb:
	move.w	4(sp),d0		; d0 = devno
	clr	d1			; d1 = 0, physical op not possible
	move.l	o_bpb,a0		; a0 -> pass-through vector
	lea	_sasi_bpb(pc),a1	; a1 -> our handler
	bra	check_dev		; do it



*+
* LONG hrw(rw, buf, count, recno, dev)
*
* Passed:	dev	$e(sp).W
*		recno	$c(sp).W
*		count	$a(sp).W
*		buf	6(sp).L
*		rw	4(sp).W
*
*-
hrw:
	move.w	$e(sp),d0		; d0 = devno
	move.w	4(sp),d1		; d1 includes physical device flag
	move.l	o_rw,a0			; a0 -> pass-through vector
	lea	_sasi_rw(pc),a1		; a1 -> our handler
	bra	check_dev		; do it



*+
* LONG hmediach(dev)
*
* Passed:	dev	4(sp).W
*
*-
hmediach:
	move.w	4(sp),d0		; d0 = devno
	clr	d1			; physical operation not possible
	move.l	o_mediach,a0		; a0 -> pass-through vector
	lea	_sasi_mediach(pc),a1	; a1 -> our handler


*+
* check_dev - use handler, or pass vector through
*
* Passed:	d0.w = device#
*		d1, bit 3  1=physical operation
*		a0 ->  old handler
*		a1 ->  new handler
*		a5 ->  $0000 (zero-page ptr)
*
* Jumps-to:	(a1) if dev in range for this handler
*		(a0) otherwise
*
*-
check_dev:
	btst	#3,d1			; is this a physical unit operation?
	beq	chkd_a

;	subq	#2,d0			; lowest device is C
;	bmi	chkd_f			; not one of ours

;	cmp	puns,d0
;	bge	chkd_f
	bra	chkd_s

chkd_a:	lea	pun,a2			; pointer to pun map
	tst.b	0(a2,d0.w)		; must be positive for a real unit
	bmi	chkd_f
chkd_s:	move.l	a1,a0			; yes -- follow success vector
chkd_f:	jmp	(a0)			; do it



* page 
* ---------------- Medium level driver ----------------

*+
* _sasi_init - initialize SASI dev
* Passed:	nothing
* Returns:	d0 < 0: error
*		d0 ==0: success
*-
	.globl	_sasi_init
_sasi_init:
	clr.l	d0
	rts

*+
* _sasi_bpb - return BPB for hard drive
* Synopsis:	LONG _sasi_bpb(dev)
*		WORD dev;
*
* Returns:	NULL, or a pointer to the BPB buffer
*
*-
	.globl	_sasi_bpb
_sasi_bpb:
	move.w	4(sp),d0		; get device number
	mulu.w	#BPBLEN,d0
	add.l	#bpbs,d0
	rts

* page 
*+
* _ahdi_rw - read/write hard sectors
* 	aka _sasi_rw for historical reasons
*
* Synopsis:	_ahdi_rw(rw, buf, count, recno, dev)
*
* Passed:	dev	$e(sp).W
*		recno	$c(sp).W
*		count	$a(sp).W
*		buf	6(sp).L
*		rw	4(sp).W		; non-zero -> write
*
*-

* stack frame offsets
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

ahrw1:	move.w	xcount(a6),d2		; is there anything to be done?
	beq	ahrw6			; no, so done with no errors

  .if SCSI
	move.w	xdev(a6),d1		; get the device number
	move.w	xrw(a6),d3		; see if this is to be a phys op
	btst	#3,d3
	beq.s	.1			; no, logical operation
	cmpi.w	#9,d1			; is it bigger than largest ACSI unit?
	ble.s	ahrw11			; no, so must be phys ACSI
	bra	scrw

.1:	lea	pun,a2
	move.b	0(a2,d1.w),d0		; get logical unit flags
	btst	#6,d0			; is the SCSI bit set?
	bne	scrw			; yes, so a SCSI operation
  .endif ;SCSI
	
ahrw11:	move.l	xbuf(a6),d1		; if all goes well, this is our buffer

	cmpi.w	#MAXSECTORS,d2		; more than one DMAfull?
	ble	ahrw2
	move.w	#MAXSECTORS,d2		; yes, so only do this many this time

ahrw2:	btst	#0,xbuf+3(a6)		; an odd boundary?
	beq	ahrw4			; no, so do normally

	cmpi.w	#2,d2			; can only do 2 at a time tops this way
	ble	ahrw3
	move.w	#2,d2

ahrw3:	move.l	_dskbufp,d1		; use the bios buffer for this transfer

	btst	#0,xrw+1(a6)		; is this a write?
	beq	ahrw4			; no, so go fill buffer from disk

	movea.l	d1,a1			; dest
	movea.l	xbuf(a6),a2		; source
	bsr	smove			; move d2 sectors from a2 to a1

ahrw4:	move.w	d2,-(sp)		; preserve count this time

	move.w	xdev(a6),-(sp)
	move.w	xrecno(a6),-(sp)
	move.w	d2,-(sp)		; count
	move.l	d1,-(sp)		; buffer
	move.w	xrw(a6),-(sp)
	bsr	_do_rw
	adda.w	#12,sp

	move.w	(sp)+,d2		; restore count for this op

	tst.l	d0			; any errors there?
	bne	ahrw7			; yes, so give up

	btst	#0,xbuf+3(a6)		; if odd boundary
	beq	ahrw5
	btst	#0,xrw+1(a6)		; and a read
	bne	ahrw5

	movea.l	xbuf(a6),a1		; we must move dskbuf to desired dest
	movea.l	_dskbufp,a2
	bsr	smove

ahrw5:	move.w	d2,d0			; number we did
	ext.l	d0
	asl.l	#8,d0			; *512
	asl.l	#1,d0
	add.l	d0,xbuf(a6)		; buf += (sectors_done * sector size)
	add.w	d2,xrecno(a6)
	sub.w	d2,xcount(a6)
	bne	ahrw1

ahrw6:	clr.l	d0		; got here with no errors!
ahrw7:
  .if MC68030
	move.l	d0,-(sp)	; save the status
	move	sr,-(sp)
	ori	#$700,sr	; no interrupts right now please

	movecacrd0

	btst	#7,xrw(a6)	; are we supposed to leave I cache alone?
	bne.s	.91		; yes

	ori	#$8,d0		; dump the I cache

.91:	btst	#6,xrw(a6)	; are we supposed to leave D cache alone?
	bne.s	.92		; yes

	ori	#$800,d0	; dump the D cache

.92:	moved0cacr
	move	(sp)+,sr	; restore interrupt state

	move.l	(sp)+,d0	; restore the return value
  .endif ;MC68030
	unlk	a6
	rts

*+
* smove -- move d2.w sectors from a2 to a1
*	d2 is known to be either 1 or 2
*-

smove:	move.w	d2,d0
	asl.w	#8,d0
	asl.w	#1,d0
	subq.w	#1,d0			; dbra likes one less
smove1:	move.b	(a2)+,(a1)+
	dbra	d0,smove1
	rts

* page 
*+
* scrw -- a SCSI disk rwabs()
*-
  .if SCSI
REGBASE	equ	1	; most are on odd part of data bus
REGSTEP	equ	2	; most registers are on word boundaries

; 68901 MFP definitions

MFP	equ	$FFFFFA01

;GPIP	equ	MFP+$00
AER	equ	MFP+$02
DDR	equ	MFP+$04
IERA	equ	MFP+$06
IERB	equ	MFP+$08
IPRA	equ	MFP+$0A
IPRB	equ	MFP+$0C
ISRA	equ	MFP+$0E
ISRB	equ	MFP+$10
IMRA	equ	MFP+$12
IMRB	equ	MFP+$14
VR	equ	MFP+$16
TACR	equ	MFP+$18
TBCR	equ	MFP+$1A
TCDCR	equ	MFP+$1C
TADR	equ	MFP+$1E
TBDR	equ	MFP+$20
TCDR	equ	MFP+$22
TDDR	equ	MFP+$24
SCR	equ	MFP+$26
UCR	equ	MFP+$28
RSR	equ	MFP+$2A
TSR	equ	MFP+$2C
UDR	equ	MFP+$2E

MFP2	equ	$FFFFFA81
GPIP2	equ	MFP2+$00
AER2	equ	MFP2+$02
DDR2	equ	MFP2+$04
IERA2	equ	MFP2+$06
IERB2	equ	MFP2+$08
IPRA2	equ	MFP2+$0A
IPRB2	equ	MFP2+$0C
ISRA2	equ	MFP2+$0E
ISRB2	equ	MFP2+$10
IMRA2	equ	MFP2+$12
IMRB2	equ	MFP2+$14
VR2	equ	MFP2+$16
TACR2	equ	MFP2+$18
TBCR2	equ	MFP2+$1A
TCDCR2	equ	MFP2+$1C
TADR2	equ	MFP2+$1E
TBDR2	equ	MFP2+$20
TCDR2	equ	MFP2+$22
TDDR2	equ	MFP2+$24
SCR2	equ	MFP2+$26
UCR2	equ	MFP2+$28
RSR2	equ	MFP2+$2A
TSR2	equ	MFP2+$2C
UDR2	equ	MFP2+$2E
	
; GPIP2 BIT ASSIGNMENTS
GPIP2SCSI	equ	7	; SCSI xIRQ
GPIP2RTC	equ	6	; RTC IRQ
GPIP25		equ	5	; 
GPIP2CHGL	equ	4	; ChangeLine
GPIP2RI		equ	3	; Ring Indicator (SCC Port B)
GPIP2DBE	equ	2	; DMA Bus Error
LED1		equ	1	; debug LED
LED0		equ	0	; debug LED

; SCSI Interface (NCR 5380) for READ operations
bSCSI	equ	$FFFF8780+REGBASE
SCSIDB	equ	bSCSI+($00*REGSTEP)	; current SCSI data bus
SCSIICR	equ	bSCSI+($01*REGSTEP)	; initiator command register
SCSIMR	equ	bSCSI+($02*REGSTEP)	; mode register
SCSITCR	equ	bSCSI+($03*REGSTEP)	; target command register
SCSICR	equ	bSCSI+($04*REGSTEP)	; current SCSI control register
SCSIDSR	equ	bSCSI+($05*REGSTEP)	; DMA status register
SCSIIDR	equ	bSCSI+($06*REGSTEP)	; input data register
SCSIREI	equ	bSCSI+($07*REGSTEP)	; reset error / interrupt

; SCSI Interface (NCR 5380) for WRITE operations
SCSIODR	equ	bSCSI+($00*REGSTEP)	; output data register
;SCSIICR	bSCSI+($01*REGSTEP)	; initiator command register
;SCSIMR		bSCSI+($02*REGSTEP)	; mode register
;SCSITCR	bSCSI+($03*REGSTEP)	; target command register
SCSIISR	equ	bSCSI+($04*REGSTEP)	; ID select register
SCSIDS	equ	bSCSI+($05*REGSTEP)	; start DMA send
SCSIDTR	equ	bSCSI+($06*REGSTEP)	; start DMS target receive
SCSIDIR	equ	bSCSI+($07*REGSTEP)	; start DMA initiator receive

; SCSI DMA Controller
bSDMAPTR	equ	$FFFF8701
bSDMACNT	equ	$FFFF8709
SDMARES	equ	$FFFF8710
SDMACTL	equ	$FFFF8714	; WORD

DMAOUT	equ	01
DMAIN	equ	00
DMAENA	equ	02
DMADIS	equ	00

SCSIID	equ	6		; our (host) SCSI ID

  .macro w4req
.1\~:	btst	#5,SCSICR		; waiting for REQ to come
	beq.s	.1\~
  .endm

  .macro doack
	ori.b	#$11,SCSIICR		; assert ACK (and data bus)
.1\~:	btst	#5,SCSICR		; wait for REQ to go away
	bne.s	.1\~
	andi.b	#$ef,SCSIICR		; clear ACK
  .endm

  .macro hshake	xbyte
	w4req
	move.b	\xbyte,SCSIDB		; write a byte out to data bus
	doack
  .endm

  .macro w4irq
.1\~:	btst	#5,GPIP
	bne.s	.1\~
  .endm


scrw:	move.w	_retries,retrycnt	; setup retry counter
scrw0:	move.w	xdev(a6),d0	; get the unit number
	btst	#3,xrw+1(a6)	; is this a physical operation?
	beq.s	.0		; no, so go get unit from pun
	subi.w	#10,d0		; subtract number of floppy&ACSI units
	bra.s	.1		; and use that as the unit number

.0:	lea	pun,a2
	move.b	(a2,d0.w),d0	; get the physical unit number
	andi.w	#3,d0		; strip off the flags

.1:	move.w	d0,-(sp)
	bsr	selSCSI		; select the SCSI device
	addq	#2,sp

  .if SCDMA
	move.l	xbuf(a6),d0	; set the DMA source/destination
	move.b	d0,bSDMAPTR+6
	lsr.l	#8,d0
	move.b	d0,bSDMAPTR+4
	lsr.l	#8,d0
	move.b	d0,bSDMAPTR+2
	lsr.l	#8,d0
	move.b	d0,bSDMAPTR

; set up the size of the transfer (in bytes, assume each sector = $0200 bytes)
	clr.l	d0
	move.w	xcount(a6),d0	; get the count of sectors
	move.b	#0,bSDMACNT+6	; lsb of byte cnt always 0
	lsl.l	#1,d0		; *$200/$100
	move.b	d0,bSDMACNT+4
	lsr.l	#8,d0
	move.b	d0,bSDMACNT+2
	lsr.l	#8,d0
	move.b	d0,bSDMACNT
  .endif ;SCDMA

	clr.l	d1
	move.w	xrecno(a6),d1	; get the record number
	cmpi.w	#-1,d1		; is recno==-1
	bne.s	.11		; if not, then use it
	move.l	xlrecno(a6),d1	; if so, then it implies the long form
.11:	btst	#3,xrw+1(a6)	; is it a physical operation?
	bne.s	.15		; yes, so don't change record number
	move.w	xdev(a6),d2	; get the logical unit number again
	lsl.w	#2,d2		; make it a long word index
	lea	start,a2	; and a pointer to the offset table
	add.l	(a2,d2.w),d1	; add the starting offset to specified record
.15:
  .if VERBOSE
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	d1,-(sp)
	bsr	crlf
	move.b	#'R',d0
	btst	#0,xrw+1(a6)
	beq.s	.100
	move.b	#'W',d0
.100:	bsr	putc
	move.w	retrycnt,d0
	bsr	putnib
	move.b	#':',d0
	bsr	putc
	move.w	xcount(a6),d0
	bsr	putwor
	move.b	#'#',d0
	bsr	putc
	move.l	(sp),d0
	bsr	putlon
	move.b	#'@',d0
	bsr	putc
	move.l	xbuf(a6),d0
	bsr	putlon
	move.l	(sp)+,d1
	movem.l	(sp)+,d0-d3/a0-a3
  .endif ;VERBOSE
	move.b	#$28,d0		; SCSI read extended command
	btst	#0,xrw+1(a6)	; read or write?
	beq.s	.16
	move.b	#$2A,d0		; SCSI write extended command
.16:	move.b	#2,SCSITCR	; assert C/D
	move.b	#1,SCSIICR	; assert data bus
	hshake	d0		; write the command     -- 00 --
	hshake	#0		;                       -- 01 --
	move.l	d1,d0		; get the long block number
	rol.l	#8,d0		; send 4 bytes of block number
	hshake	d0		;                       -- 02 --
	rol.l	#8,d0
	hshake	d0		;                       -- 03 --
	rol.l	#8,d0
	hshake	d0		;                       -- 04 --
	rol.l	#8,d0
	hshake	d0		;                       -- 05 --
	hshake	#0		; reserved byte         -- 06 --
	move.w	xcount(a6),d0	; word of count
	rol.w	#8,d0
	hshake	d0		;                       -- 07 --
	rol.w	#8,d0
	hshake	d0		;                       -- 08 --
  .if 0
	bra	.18		; go send the control byte

; send the SCSI command to the device
.0:	move.b	#$08,d0		; SCSI read command
	btst	#0,xrw+1(a6)	; only use lsb here, others reserved
	beq.s	.1
	move.b	#$0a,d0		; SCSI write command
.1:	move.b	#2,bSCSI+(3*REGSTEP)	; assert c/d
	move.b	#1,bSCSI+(1*REGSTEP)	; assert data bus
	hshake	d0		; write the command     -- 00 --
	hshake	#0		; unfortunately rwabs only uses word block num
	move.w	xrecno(a6),d0	; get the specified block number
	lsr.w	#8,d0
	hshake	d0		;                       -- 02 --
	move.w	xrecno(a6),d0
	hshake	d0		;                       -- 03 --
	move.w	xcount(a6),d0
	hshake	d0		;                       -- 04 --
  .endif ;0
.18:	hshake	#0		; control byte always 0 -- 05 -- or -- 09 --

	btst	#0,xrw+1(a6)	; only use lsb here, others reserved
	beq.s	.25

; write
  .if SCDMA
	move.b	#0,SCSITCR		; set data out phase
	move.b	SCSIREI,d0		; clear potential interrupt
	move.b	#2,SCSIMR		; enable DMA mode
	move.b	#0,SCSIDS		; start the DMA send
	move.w	#DMAOUT,SDMACTL		; set the DMAC direction
	move.w	#DMAOUT+DMAENA,SDMACTL	; turn on DMAC
	bra.s	.26
  .else ;SCDMA
	movea.l	#bSCSI,a0		; pointer to the 5380
	move.b	#0,3*REGSTEP(a0)	; set data out phase
	move.b	7*REGSTEP(a0),d0	; clear potential interrupt
	movea.l	xbuf(a6),a1		; buffer pointer

.22:	btst	#5,4*REGSTEP(a0)	; wait for REQ
	beq.s	.22
	btst	#3,5*REGSTEP(a0)	; still in right phase
	beq.s	.3			; no, end of data out phase
	move.b	(a1)+,(a0)		; write the data byte

	bset	#4,1*REGSTEP(a0)	; assert ACK

.23:	btst	#5,4*REGSTEP(a0)	; wait for REQ to go away
	bne.s	.23

	bclr	#4,1*REGSTEP(a0)	; clear ACK
	bra.s	.22
  .endif ;SCDMA

; read
.25:
  .if SCDMA
	move.b	#0,SCSIICR		; deassert the data bus
	move.b	#1,SCSITCR		; set data in phase
	move.b	SCSIREI,d0		; clear potential interrupt
	move.b	#2,SCSIMR		; enable DMA mode
	move.b	#0,SCSIDIR		; start the DMA receive
	move.w	#DMAIN,SDMACTL		; set the DMAC direction
	move.w	#DMAIN+DMAENA,SDMACTL	; turn on DMAC

.26:	btst	#GPIP2SCSI,GPIP2	; wait for 5380 to interrupt
	bne.s	.261			; active HIGH
	btst	#5,GPIP2		; or for DMAC to interrupt
	bne.s	.26			; active LOW
	move.w	SDMACTL,d0		; get the DMA status
	andi.l	#$80,d0			; ignore countout ints
	beq.s	.26
	neg.l	d0
	move.l	d0,-(sp)
	bsr	resetSCSI
	move.l	(sp)+,d0
	bra	.99

.261:	move.b	SCSIREI,d0		; clear potential interrupt

; disable DMA
	move.w	#DMADIS,SDMACTL

	move.b	#0,SCSIMR		; disable DMA mode
	move.b	#0,SCSIICR		; make sure data bus is not asserted
  .else ;SCDMA
	movea.l	#bSCSI,a0		; pointer to the 5380
	move.b	#1,3*REGSTEP(a0)	; set data in phase
	move.b	7*REGSTEP(a0),d0	; clear potential interrupt
	movea.l	xbuf(a6),a1		; buffer pointer

.27:	btst	#5,4*REGSTEP(a0)	; wait for REQ
	beq.s	.27
	btst	#3,5*REGSTEP(a0)	; still in right phase
	beq.s	.3			; no, end of data in phase
	move.b	(a0),(a1)+		; read the data byte

	bset	#4,1*REGSTEP(a0)	; assert ACK

.28:	btst	#5,4*REGSTEP(a0)	; wait for REQ to go away
	bne.s	.28

	bclr	#4,1*REGSTEP(a0)	; clear ACK
	bra.s	.27

  .endif ;SCDMA

.3:	move.b	#3,SCSITCR		; status in phase
	move.b	SCSIREI,d0		; clear potential interrupt

	w4req				; wait for status byte
	clr.w	d0
	move.b	bSCSI,d0
	move.w	d0,-(sp)
	doack

	w4req
	move.b	bSCSI,d0		; get and ignore message byte
	doack

  .if VERBOSE
	move.b	#'^',d0
	bsr	putc
	move.w	(sp),d0
	bsr	putbyt
  .endif ;VERBOSE

	btst	#0,xrw+1(a6)	; only use lsb here, others reserved
	bne.s	.9		; if this was a write, we are done

	move.b	bSDMAPTR+6,d0	; see if this was an odd transfer

	andi.w	#3,d0
	beq.s	.9		; no, nice and even (and easy)

	move.b	bSDMAPTR+0,d0
	lsl.l	#8,d0
	move.b	bSDMAPTR+2,d0
	lsl.l	#8,d0
	move.b	bSDMAPTR+4,d0
	lsl.l	#8,d0
	move.b	bSDMAPTR+6,d0
	move.l	d0,d1
	andi.w	#3,d0

	andi.w	#$FFFF-3,d1	; where does the data go?
	movea.l	d1,a0
	move.l	SDMARES,d1	; get the residue
	subq.w	#1,d0		; dbra likes one less than count
.8:	rol.l	#8,d1
	move.b	d1,(a0)+
	dbra	d0,.8
.9:	clr.l	d0

	move.w	(sp)+,d0	; recall the status byte
	beq.s	.99
	neg.l	d0		; errors are negative numbers
	subq.w	#1,retrycnt	; drop retry count and retry
	bpl	scrw0		; if there are still chances to win

.99:	bra	ahrw7

*+
* VOID resetSCSI();
*-

resetSCSI:
	move.b	#$80,SCSIICR	; assert RST
	movea.l	#_hz_200,a0
	move.l	(a0),d0
	addi.l	#51,d0		; wait (at least) 250 mS
.0:	cmp.l	(a0),d0
	bne.s	.0
	move.b	#$00,SCSIICR
	move.l	(a0),d0
	addi.l	#201,d0		; wait (at least) 1000 mS
.1:	cmp.l	(a0),d0
	bne.s	.1
	rts

*+
* BOOLEAN selSCSI(SCSIUnit) WORD SCSIUnit;
*-

selSCSI:
.0:	btst	#6,SCSICR		; not STILL busy from last time?
	bne.s	.0

	move.b	#0,SCSITCR		; data out phase
	move.b	#0,SCSIISR		; no interrupt from selection
	move.b	#$0c,SCSIICR		; assert BSY and SEL
; set dest SCSI IDs
	clr.w	d0
	move.w	4(sp),d1		; get the SCSI unit desired
	bset	d1,d0			; set the appropriate bit
	move.b	d0,SCSIODR		; (real code would set ours too)

	move.b	#$0d,SCSIICR		; assert BUSY, SEL and data bus

	andi.b	#$FE,SCSIMR		; clear arbitrate bit
	andi.b	#$F7,SCSIICR		; clear BUSY
	nop
	nop

.1:	btst	#6,SCSICR		; wait for bus to be busy
	beq	.1

	move.b	#$0,SCSIICR		; clear SEL and data bus assertion
	clr.w	d0			; note lack of SCSI device timeout
	rts

  .endif ;SCSI

  .if VERBOSE
;
;	putlon - put d0.l as 8 hex digits
;	putwor - put d0.w as 4 hex digits
;	putbyt - put d0.b as 2 hex digits
;	putnib - put 4 lsbs as a hex digit

putlon:	move.l	d0,-(sp)
	swap	d0
	bsr	putwor
	move.l	(sp)+,d0
putwor:	move	d0,-(sp)
	asr	#8,d0
	bsr	putbyt
	move	(sp)+,d0
putbyt:	move	d0,-(sp)
	asr	#4,d0
	bsr	putnib
	move	(sp)+,d0
putnib:	andi.b	#$0f,d0
	addi.b	#'0',d0
	cmpi.b	#'9',d0
	ble	putb2
	addi.b	#7,d0
putc:
putb2:	tst.b	TSR
	bpl.s	putb2
	move.b	d0,UDR
	rts

crlf:	move.l	#crlfmsg,-(sp)
	bsr	puts
	addq	#4,sp
	rts

puts:	movea.l	4(sp),a0
.1:	move.b	(a0)+,d0
	beq.s	.9
	bsr	putc
	bra.s	.1
.9:	rts

crlfmsg: dc.b	13,10,0
	.even
  .endif ;VERBOSE

* page 
*+
* _do_rw - called to read/write no more than 128K to an even boundary
*
* Passed:	dev	$e(sp).W
*		recno	$c(sp).W
*		count	$a(sp).W
*		buf	6(sp).L
*		rw	4(sp).W		; non-zero -> write
*
*-
	.globl	_do_rw
_do_rw:
	move.w	d3,-(sp)		; preserve d3

sasrw0:	move.w	_retries,retrycnt	; setup retry counter

	move.w	6(sp),d3
	btst	#2,d3			; are retries disabled?
	beq	sasrw1			; no, act normally
	move.w	#0,retrycnt		; yes, so set retrycnt to zero

*
* read sector(s),
* delay .0005 to .001 seconds between driver calls
*
sasrw1:
	move.l	lastrwtm,d0
sasrw8:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastrwtm)
	bcc	sasrw8			;	just_wait;
	move.l	_hz_200,d0		; lastrwtm = _hz_200 + 1;
	addq.l	#1,d0
	move.l	d0,lastrwtm

	lea	2(sp),a1		; frame pointer
	moveq	#0,d0			; coerce word to long, unsigned
	move.w	$c(a1),d0		; sect.L
	move.w	4(a1),d3		; rw

	btst	#3,d3			; physical unit operation
	beq	sasrw2			; no, so do log->phys mapping

	move	$0e(a1),d2		; get unit number
	subq	#2,d2			; subtract drive C offset
	bra	sasrw3			; and use that as the physical unit

sasrw2:	clr	d2			; coerce byte to word
	move.w	$e(a1),d1		; get device
	lea	pun,a2
	move.b	0(a2,d1.w),d2		; get physical unit number
sasrw3:	move.w	d2,-(sp)		; dev
	move.l	6(a1),-(sp)		; buf
	move.w	$a(a1),-(sp)		; count

	btst	#3,d3			; physical operation?
	bne	sasrw4			; yes, so no offset

	asl.w	#2,d1			; *4 to get index into long array
	lea	start,a2
	add.l	0(a2,d1.w),d0		; adjust sector number

sasrw4:	move.l	d0,-(sp)		; sect
	btst	#0,d3			; read or write?
	bne	sasrw5			; (write)
	bsr	_hread			; read sectors
	bra	sasrw6
sasrw5:	bsr	_hwrite			; write sectors
sasrw6:	add.w	#12,sp			; (cleanup stack)
	tst.l	d0			; errors?
	beq	sasrwr			; no -- success
	subq.w	#1,retrycnt		; drop retry count and retry
	bpl	sasrw1

	move	6(sp),d1		; get r/w and flags word
	move.l	#EREADF,d0		; read error code
	btst	#0,d1
	beq	sasrw7
	move.l	#EWRITF,d0		; write error code

sasrw7:	btst	#2,d1			; is this a "raw" operation?
	bne	sasrwr			; yes, so no critical error handler

	move.w	$10(sp),-(sp)		; unit number
	move.w	d0,-(sp)		; error code (as a word, sic)
	movea.l	etv_critic,a0
	jsr	(a0)
	addq	#4,sp
	cmpi.l	#CRITRETRY,d0		; is it the magic RETRY code?
	beq	sasrw0

sasrwr:	move.w	(sp)+,d3		; remember to restore d3
	rts

*+
* _sasi_mediach - see if hard disk media has changed (it never does)
* Synopsis:	_sasi_mediach(dev)
*		WORD dev;
*
* Returns:	0L
*
*-
	.globl	_sasi_mediach
_sasi_mediach:
	clr.l	d0
	rts


* page 
* ---------------- Low-level driver ----------------


*----- Hardware:
wdc		equ	$ffff8604
wdl		equ	$ffff8606
wdcwdl		equ	wdc		; used for long writes
xwdl		equ	wdl-wdc		; offset from wdc to wdl

dmahi		equ	$ffff8609
dmamid		equ	dmahi+2
dmalow		equ	dmamid+2
gpip		equ	$fffffa01


*----- Tunable:
ltimeout		equ	450000		; long-timeout (3 S)
stimeout		equ	15000		; short-timeout (100 mS)

*+
* LONG _qdone() - Wait for command byte handshake
* LONG _fdone() - Wait for operation complete
* Passed:	nothing
*
* Returns:	EQ: no timeout
*		MI: timeout condition
*
* Uses:		D0
*
* each pass through the loop takes 6.75 uS
*-
	.if	sermsg

_fdone:	move	d1,-(sp)
	move	#1,d1
	move.l	#ltimeout,tocount
	bra	qd1

_qdone:
	move	d1,-(sp)
	move	#0,d1
	move.l	#stimeout,tocount
qd1:	subq.l	#1,tocount		; drop timeout count
	bmi	qdq			; (i give up, return NE)
	btst	#5,gpip			; interrupt?
	bne	qd1			; (not yet)

	move	(sp)+,d1
	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	nop

	.if	1

	movem.l	d0-d3/a0-a4,-(sp)
	lea	stmsg,a4
	tst	d1
	beq	qdq1
	lea	ltmsg,a4
qdq1:	move.b	(a4)+,d0
	beq	qdq2
	move	d0,-(sp)
	move	#1,-(sp)
	move	#3,-(sp)
	trap	#13
	addq	#6,sp
	bra	qdq1

qdq2:	movem.l	(sp)+,d0-d3/a0-a4

	.endif

	move	(sp)+,d1
	moveq	#-1,d0
	rts

stmsg:	dc.b	'Short timeout',$0d,$0a,0
ltmsg:	dc.b	'Long timeout',$0d,$0a,0
drmsg:	dc.b	$0d,$0a,'Drive ',0
	even

	.endif

	.if	sermsg=0

_fdone:	move.l	#ltimeout,tocount
	bra	qd1

_qdone:
	move.l	#stimeout,tocount
qd1:	subq.l	#1,tocount		; drop timeout count
	bmi	qdq			; (i give up, return NE)
	btst	#5,gpip			; interrupt?
	bne	qd1			; (not yet)

	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	moveq	#-1,d0
	rts

	.endif

*+
* WORD _endcmd()
* Wait for end of SASI command
* Passed:	d0 value to be written to wdl
*
* Returns:	EQ: success (error code in D0.W)
*		MI: timeout
*		NE: failure (SASI error code in D0.W)
*
* Uses:		d0,d1
*-
_endcmd: move	d0,d1			; preserve wdl value

	bsr	_fdone			; wait for operation complete
	bmi	endce			; (timed-out, so complain)

	move.w	d1,wdl
	nop
	move.w	wdc,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should

endce:	rts				;  do a ReadSense command to learn more

*-
* _hread(sectno, count, buf, dev)
* LONG sectno;		 4(sp)
* WORD count;		 8(sp)
* LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
* WORD dev;		$e(sp)
*
* Returns:	-1 on timeout
*		0 on success
*		nonzero on error
*
*-
	.globl	_hread
_hread:
	movea.l	#wdc,a0			; pointer to DMA chip
	st	flock			; lock FIFO

	move	#$88,xwdl(a0)
	clr.l	d0
	move.w	$0e(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$0008008a,d0		; 08 wdc, 8a wdl
	move.l	d0,(a0) ; wdcwdl

	move.l	$a(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq	#4,sp

	bsr	_setss			; set sector and size
	bmi	_hto

	move.w	#$190,xwdl(a0)
	nop
	move.w	#$90,xwdl(a0)
	nop
	move.w	8(sp),(a0) ;wdc		; write sector count to DMA chip
	nop
	move.w	#$8a,xwdl(a0)
	nop
	move.l	#$00000000,(a0) ; wdcwdl; control byte  0 wdc 0 wdl

	move.w	#$8a,d0
	bsr	_endcmd

hrx:	bra	_hdone			; cleanup after IRQ


*-
* _hwrite(sectno, count, buf, dev)
* LONG sectno;		 4(sp)
* WORD count;		 8(sp)
* LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
* WORD dev;		$e(sp)
*
*-
	.globl	_hwrite
_hwrite:
	movea.l	#wdc,a0			; pointer to DMA chip
	st	flock			; lock FIFO

	move.l	$a(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq	#4,sp

	move.w	#$88,xwdl(a0)
	clr.l	d0
	move.w	$0e(sp),d0		; get unit number
	lsl.w	#5,d0
	swap	d0
	ori.l	#$000a008a,d0		; 0a wdc 8a wdl
	move.l	d0,(a0) ; wdcwdl

	bsr	_setss
	bmi	_hto

	move.w	#$90,xwdl(a0)
	nop
	move.w	#$190,xwdl(a0)
	nop
	move.w	8(sp),(a0) ;wdc		; sector count for DMA chip's benefit
	nop
	move.w	#$18a,xwdl(a0)
	nop
	move.l	#$00000100,(a0) ; wdcwdl

	move.w	#$18a,d0
	bsr	_endcmd

hwx:	bra	_hdone			; cleanup after IRQ


*+
* void _setdma(addr)
* LONG addr;
*-
_setdma:
	move.b	7(sp),dmalow
	move.b	6(sp),dmamid
	move.b	5(sp),dmahi
	rts

*+
* WORD _setss  -- set sector number and number of sectors
*-

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

_hto:	moveq	#-1,d0		; indicate timeout
_hdone:	move.w	#$80,wdl	; Landon's code seems to presume we
	nop			;  put this back to $80
	tst.w	wdc
	clr	flock		; NOW, signal that we are done
	rts

isasi5:
  .if ospool
	bsr	pool_install	; attempt to install more OS pool
  .endif
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

*
*  Return to TOS ROMs
*    - set default boot device to C:
*    - Print silly message
*    - Mshrink() memory that was alloc'd to us
*    - set magic# in D7 for TOS ROMs
*    - RTS back to ROMs
*
	move.l	d0,-(sp)	; save D0
	pea	msg_loaded(pc)	; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	move.l	(sp)+,d0

	move.w	#2,_bootdev	; set default boot device to C: (devno=2)
	move.l	d0,-(sp)
	move.l	baseaddr,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; Mshrink(...)
	trap	#1
	add.w	#12,sp		; (cleanup stack)


exec_os		equ	$4fe

*+
*  Bring up the AES:
*    do autoexec;
*    construct an enviroment string;
*    create a basepage for the AES;
*    exec the AES.
*
*-
st_1:
	bsr	findpackages		; find bootable RAM packages
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

*+
* When startup fails (or if the exec returns,
* which "cannot happen") fake a system reset:
*-
	move.l	4,a0			; get RESET vector
	jmp	(a0)			; and do it



*+
* Default enviroment string
*
*-
orig_env:
	dc.b	"PATH=",0		; default pathname
	dc.b	"C:\\",0		; is the boot device
	dc.b	0			; terminate env string


gemname: dc.b	"GEM.PRG"		; desktop name
nullenv: dc.b	0,0			; null string (and enviroment)
	even


*+
*  Auto path for hard disks (C:)
*
*-
autopath:	dc.b	'C:\\AUTO\\'
autofile:	dc.b	'*.PRG',0
		dc.w	$1234,$5678,$9abc,$def0
	even


*+
* _auto - exec auto-startup files in the appropriate subdirectory
* _auto1 - exec (with filename args)
*
* Passed:	a0 -> full filespec (pathname)
*		a1 -> filename part of filespec
*
* Returns:	nothing
*
* Uses:		everything
*-
	.globl	_auto			; for debugging
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



*+
*  fauto - exec'd by _auto to do autostartup
*
*  Passed:	pathname -> path part of filespec
*		filename -> file part of filespec
*
*-
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

*--- free up some memory:
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

*--- construct filename from path and the name we just found:
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

*+
* Search for a package, execute it.
*
*	+---------------+
*	|   $12123456	| base + 0, on a 512-byte boundary
*	|		|
*	+---------------+
*	|   -> base	| base + 4
*	|		|
*	+---------------+
*	|   (code)	| base + 8
*	/		/
*	/		/
*	|		|
*	+---------------+
*			  base + 512
*
*	The entire 512-byte block should word-checksum to $5678.
*
*-
findpackages:
	move.l	phystop,a0		; a0 -> top of memory
fpk_n:	sub.w	#512,a0			; down 512 bytes
	cmp.l	#$400,a0		; bottom of memory?
	beq	fpk_r			; (yes -- punt)
	cmp.l	#$12123456,(a0)		; check magic #
	bne	fpk_n			; (no match, try next one)
	cmp.l	4(a0),a0		; self-pointer?
	bne	fpk_n			; (doesn't point to itself, retry)

	clr.w	d0			; zero checksum reg
	move.l	a0,a1			; a1 -> block to checksum
	move.w	#$ff,d1			; do 256 words
fpk_1:	add.w	(a1)+,d0		; sum a word
	dbra	d1,fpk_1		;	... until we're done
	cmp.w	#$5678,d0		; magic number to exec()?
	bne	fpk_n			; (no, retry)
	move.l	a0,-(sp)		; save our precious package pointer
	jsr	8(a0)			; call package's code
	move.l	(sp)+,a0		; restore A0
	bra	fpk_n			; (do more blocks)

fpk_r:	rts


*+
* The first GEMDOS process can never terminate.
* This is not a good feature.
* Kludge around it -- re-initialize the stack
* and return to the guy who called us to begin with.
*
*-
au_dn:	move.l	origstk,sp		; restore original stack
	move.l	autoret,-(sp)		; get return addr
	rts				; just jump there ...


*--- "bss" for auto-exec:
autoret:	dc.l	0		; -> _auto's caller (yeccch)
pathname:	dc.l	0		; -> filespec's pathname
filename:	dc.l	0		; -> filename part of path
origstk:	dc.l	0		; =  original supervisor stack
autodma:	dcb.b	44,0		; 44 bytes for directory search
autoname:	dcb.b	32,0		; 32 bytes for path+filename
	even


*	move.b	#$100-$20,d7	; return to TOS ROMs
*	rts

msg_loaded:
	dc.b	'Atari ACSI/SCSI Driver'
  .if !SCDMA
	dc.b	' (ND)'
  .endif ;SCDMA
	dc.b	13,10
	dc.b	'  ('
	VERSION
	dc.b	')',13,10
	dc.b	0
    even

*
*  Terminate and stay resident;
*  installed driver under GEMDOS.
*
nboot2:	
	move.l	d0,-(sp)	; save D0
	pea	msg_loaded(pc)	; print announcement
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	move.l	(sp)+,d0

	move.w	#0,-(sp)	; exit code
	move.l	d0,-(sp)
	move.w	#$31,-(sp)	; terminate and stay resident
	trap	#1		; should never come back...
	illegal


* page 
 .if ospool
*+
*  Wire more pool into various ROM releases.
*
*    Passed:	nothing
*    Returns:	D0 = #bytes extra used
*
*-
pool_install:
	move.l	_sysbase,a3		; a3 -> base of OS

* make sure we're in ROM,
* then get address of RAM location to patch:

	cmp.l	#$800000,a3		; better be ROM
	blt	notrom
	lea	pool_tab(pc),a0		; a0 -> table to match
pi_lp:	move.l	(a0)+,d1		; d1 = date to match
	beq	badrom			; (forget it, end of list)
	move.l	(a0)+,a2		; a2 -> _root address for that date
	cmp.l	$18(a3),d1		; match dates?
	bne	pi_lp			; (no -- try again)

	lea	poolbuf+2,a0		; a0 -> base of first buffer
	move.w	#numchunks-1,d0		; d0 = count-1
pin_1:	lea	chunksiz(a0),a1		; a1 -> next buffer
	move.l	a1,(a0)			; buffer -> next one
	move.w	#chunkno,-2(a0)		; install chunksiz
	move.l	a1,a0			; a0 -> next buffer
	dbra	d0,pin_1		; (do some more)

	sub.w	#chunksiz,a0		; a0 -> last block
	move.l	chunkno*4(a2),(a0)	; last block -> first in root
	move.l	#poolbuf+2,chunkno*4(a2) ; root -> first of ours
	move.l	#numchunks*chunksiz,d0	; d0 = amount of BSS used **AKP**
	rts				; return OK

*+
*  Print warning messages
*  about bogus versions of the
*  operating system.  Assume that
*  every OS past 1-May-1986 has the
*  pool fix installed.
*
*-
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

* print msg and wait for RETURN
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


*+
*  Table of ROM release dates / _root addresses
*  update these for new ROM releases that need the patch.
*
*-
pool_tab:
	dc.l	$11201985,$56fa		; USA and UK, 20-Nov-1985
	dc.l	$02061986,$56fa		; Germany, 6-Feb-1986
	dc.l	$04241986,$56fa		; France, 24-Apr-1986
	dc.l	0
 .endif

* page 

BPBLEN	equ	18
	.globl	_puns
_puns:
puns:	dc.w	0

	.globl	_pun
_pun:
pun:	dcb.b	maxunits,0
	.globl	_partstart
_partstart:
start:	dcb.l	maxunits,0
bpbs:	dcb.b	maxunits*18,0

lastrwtm:	dc.l	0		; ``_hz_200 + 1'' at last _do_rw()
tocount:	dc.l	1		; timeout counter
retrycnt:	dc.w	1		; retry counter
	.globl	_retries
_retries:	dc.w	nretries	; number of retries to do

o_init:		dc.l	1
o_bpb:		dc.l	1
o_rw:		dc.l	1
o_mediach:	dc.l	1

 .if ospool
poolbuf:	dc.w	0
 .endif

* page 
* ---------------- Installer ----------------
i_sasi1: nop

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

  .if VERBOSE
	andi.b	#($FF-$1E),IERA	; turn off MFP serial interrupts
	andi.b	#($FF-$1E),IMRA	; turn off MFP serial interrupts

	bsr	crlf
	move.l	#msg_loaded,-(sp)
	bsr	puts
	addq	#4,sp
  .endif ;VERBOSE

  .if SCSI
	bsr	resetSCSI	; reset the SCSI bus
  .endif ;SCSI

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

i_sasi4:
  .if SCSI
; hack in a SCSI partition
	move.w	#1,puns
	move.w	#1,installed
	move.b	#$40,pun+2
	move.l	#2,start+(2*4)
	ori.l	#4,_drvbits

	movea.l	#bpbs+(2*BPBLEN),a2
	lea	thebpb,a1
	move	#BPBLEN-1,d0
.4:	move.b	(a1)+,(a2)+
	dbra	d0,.4

  .endif ;SCSI
	tst	puns			; any drives found?
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

*
*  Couldn't install driver, return to boot code
*
isaseb:	move.l	baseaddr,-(sp)	; Mfree(baseaddr)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.b	#$100-$20,d7	; return to TOS ROMs
	rts


* page 
*+
* pread(sectno, cnt, buf, physunit)
* LONG sectno;
* BYTE *buf; (word aligned)
* WORD cnt,physunit;
*
* Passed:	dev.w		$a(a0)	$e(sp)
*		&buf.l		$6(a0)	$a(sp)
*		cnt.w		$4(a0)	$8(sp)
*		sectno.l	$0(a0)	$4(sp)
*
* Returns:	-1 if we could not read it
*			(may not exist)
*-
	.globl	_pread
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

* page 
*+
* ppu
* Partition physical unit
*
*-
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

* page 
*+
* nxtdrv	(of clun, cdbit)
*	returns d0 = clun, or negative if error
*		a0 -> pun(clun)
*		a1 -> start(clun)
*		a2 -> bpbs(clun)
*-

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

* page 
*+
* getbpb(sectorno)
* LONG sectorno;
*-

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

*+
* WORD getlhw(d0=offset)
* returns word (low,high) from 0(D0,A3)
*-

getlhw:	move	d1,-(sp)		; preserve d1
	move.b	1(a3,d0.w),d1
	lsl.w	#8,d1
	move.b	0(a3,d0.w),d1
	move	d1,d0
	move	(sp)+,d1
	rts

* page 
  .if	format
*+
*  _doformat - format hard disk
*
*    Synopsis:	LONG _doformat(dev, interlv)
*		WORD dev;			4(sp).W
*		WORD interlv;			6(sp).W
*
*-
acfmt:	dc.b	4	; format command + devno (upper 3 bits)
	dc.b	0	; (unused)
	dc.b	0	; (unused) data pattern
ac_in:	dc.b	0,0	; interleave factor MSB, LSB
	dc.b	0	; reserved
    even

	.globl	_doformat
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

* page 
*+
*  _mode_set - set hard disk format parameters
*
*    Synopsis:	LONG _mode_set(dev, parms)
*		WORD dev;			4(sp).W
*		char *parms;			6(sp).L
*
*-
	.globl	_mode_set
_mode_set:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq	#4,sp

* write command and dev#
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

  .endif  ; format

* page 
  
  .if    mdsense
*+
*  _md_sense - get hard disk format parameters
*
*    Synopsis:	LONG _md_sense(dev, parms)
*		WORD dev;			4(sp).W
*		char *parms;			6(sp).L
*
*-
	.globl	_md_sense
_md_sense:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq	#4,sp

* write command and dev#
	move.w	#$88,wdl
	move.w	4(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$001a008a,d0		; write dev# + ModeSense + FIFO bits
	move.l	d0,wdcwdl		; mdsel+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 1
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 2
	bsr	_qdone
	bmi	wdx1

	move.l	#$0000008a,wdcwdl	; byte 3
	bsr	_qdone
	bmi	wdx1

	move.l	#$0016008a,wdcwdl	; 22 bytes of parameters (byte 4)
	bsr	_qdone
	bmi	wdx1

	move.w	#$190,wdl		; reset the DMA chip
	nop
	move.w	#$90,wdl
	nop
	move.w	#$01,wdc		; 1 sector of DMA (actually less)
	nop
	move.w	#$8a,wdl
	nop
	move.l	#0,wdcwdl		; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
wdx1:	bra	_hdone

  .endif  ; mdsense

* page 
  .if	sahdxc
*+
* LONG _dosahdxc( dev, addr ) BYTE *addr;
*	do a simple (no DMA) ahdx command
*-
	.globl	_dosahdxc
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

* page 
  .if s10mb
*+
* BPB for 10MB drive
*-
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

  .if s11mb
*+
* BPB for 11MB Syquest partition
*-
thebpb:	dc.w	512			; #bytes/sector
	dc.w	2			; #sectors/cluster
	dc.w	1024			; #bytes/cluster
	dc.w	17			; rdlen (512 root files) (in sectors)
	dc.w	43			; FATsiz (20736 FAT entries) (sectors)
	dc.w	44			; 2nd FAT start
	dc.w	104			; data start (in sectors)
	dc.w	10837			; #clusters (approximate here)
	dc.w	1			; flags (16-bit FATs)
  .endif

  .if s20mb
*+
* BPB for 20MB drive
*-
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

  .endif ;sahdxc


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
 -> filename part of path
origstk:	dc.l	0		; =  original supervisor stack
autodma:	dcb.b	44,0		; 44
