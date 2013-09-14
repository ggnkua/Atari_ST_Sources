* bahdi.s - use for testing to return bad blocks.

*------------------------------------------------------------------------
*									:
*	ST SASI/AHDI hard disk driver					:
*	Copyright 1985 Atari Corp.					:
*									:
*----									:

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

tocount:	dc.l	1
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



* *B*A*D* * * * * * * * * * * * * * * * * * * * * * * * * * 

badblk0		equ	$283e		; bad block start sector 0
badblk1		equ	$c91e		; bad block start sector 1
badblk2		equ	$c856		; bad block start sector 2

badroot		equ	$ffffff		; bad root sector
baddeft		equ	$ffffff		; bad defect sector
badboot		equ	$ffffff		; bad boot sector
badfat1		equ	$ffffff		; bad number 1 FAT
badfat2		equ	$ffffff		; bad number 2 FAT
badrdir		equ	$ffffff		; bad root directory
badsec0		equ	$283f		; rogue bad sector 0 (D: of 5 Mb)
badsec1		equ	$c92c		; rogue bad sector 1 (G: of 16 Mb)
badsec2		equ	$c8de		; rogue bad sector 2 (H: of 1.3 Mb)
badwrit		equ	$ffffff		; bad write sector

badmin		equ	$ffffff		; bad sector range minimum
badmax		equ	$ffffff		; bad sector range maximum

	move.w	8(sp),d0
	cmpi.w	#1,d0
	beq	ootka
	move.l	4(sp),d0
	andi.l	#$001fffff,d0
	cmpi.l	#badblk0,d0
	beq	baad
	cmpi.l	#badblk1,d0
	beq	baad
	cmpi.l	#badblk2,d0
	beq	baad
	bra	good

ootka:	move.l	4(sp),d0
	andi.l	#$001fffff,d0
	cmpi.l	#badroot,d0
	beq	baad
	cmpi.l	#baddeft,d0
	beq	baad
	cmpi.l	#badboot,d0
	beq	baad
	cmpi.l	#badfat1,d0
	beq	baad
	cmpi.l	#badfat2,d0
	beq	baad
	cmpi.l	#badrdir,d0
	beq	baad
	cmpi.l	#badsec0,d0
	beq	baad
	cmpi.l	#badsec1,d0
	beq	baad
	cmpi.l	#badsec2,d0
	beq	baad

	cmpi.l	#badmin,d0
	blt	good
	cmpi.l	#badmax,d0
	bgt	good

baad:	move.w	#$02,d0
	move.w	#$80,wdl
	tst.w	d0
	clr	flock
	rts
good:

* *B*A*D* * * * * * * * * * * * * * * * * * * * * * * * * * 



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

	move.l	4(sp),d0
	andi.l	#$001fffff,d0
	cmpi.l	#badwrit,d0
	bne	okidata
	move.w	#$02,d0
	move.w	#$80,wdl
	tst.w	d0
	clr	flock
	rts
okidata:

	move.w	#$88,xwdl(a0)
	move.l	$a(sp),-(sp)		; set DMA address
	bsr	_setdma
	addq	#4,sp

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


* page 
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


* page 
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
	move.l	d0,wdcwdl		; mdsense+dev wdc 8a wdl (byte 0)
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


*
*---------------
*
*  LONG _rq_sense() - get non-extended sense data from target
*  LONG _rq_xsense() - get extended sense data from target
*
*  Passed:
*	WORD physunit#;			4(sp).W		$6(sp).w
*	char data[];			6(sp).L		$8(sp).l
*
*  Returns:
*	    0 : OK
*	non-0 : ERROR
*
	.globl	_rq_sense
	.globl	_rq_xsense
_rq_sense:
	moveq	#3,d2			; do it 4 times
	move.w	#0,-(sp)		; request 4 bytes of sense data
	bra.s	rq0
_rq_xsense:
	moveq	#0,d2			; do it one time
	move.w	#16,-(sp)		; request 16 bytes of sense data
rq0:	movea.l	#wdc,a0
	st	flock			; lock FIFO
	move.l	8(sp),-(sp)		; -> sense data buffer address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp

 	move.w	#$190,xwdl(a0)	;wdl	; reset the DMA chip
	move.w	#$90,xwdl(a0)	;wdl
	move.w	#$01,(a0)	;wdc	; 1 sector of DMA (actually less)

	moveq	#0,d0
rq1:	move.l	_hz_200,d1		; kludge delay
	addq.l	#2,d1
rq2:	cmp.l	_hz_200,d1
	bcc.s	rq2
	move.w	#$88,xwdl(a0)	;wdl
	move.w	6(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$0003008a,d0		; write dev#+Request Sense+FIFO bits
	move.l	d0,(a0)		;wdcwdl	; rqsense+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi.s	wdq1

	move.l	#$8a,d1			; byte to be sent
	move.l	d1,(a0)		;wdcwdl	; byte 1
	bsr	_qdone
	bmi.s	wdq1

	move.l	d1,(a0)		;wdcwdl	; byte 2
	bsr	_qdone
	bmi.s	wdq1

	move.l	d1,(a0)		;wdcwdl	; byte 3
	bsr	_qdone
	bmi.s	wdq1

	move.w	(sp),d0			; # bytes of sense data requested
	swap	d0
	or.l	d1,d0
	move.l	d0,(a0)		;wdcwdl	; byte 4
	bsr	_qdone
	bmi.s	wdq1

	move.w	#$8a,xwdl(a0)	;wdl
	move.l	#0,(a0)		;wdcwdl	; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
	tst.w	d0
	bmi.s	wdq1
	dbra	d2,rq1			; go back until done
wdq1:	addq.l	#2,sp			; clean up stack
	bra	_hdone


;
;----------------
;
;  _inquiry - get device-specific parameters
;
;    Synopsis:	LONG _inquiry(physunit#, parms)
;		WORD physunit#;			4(sp).W
;		char *parms;			6(sp).L
;
; Old driver uses these two lines which do NOT do 
; "d0 = (dev << 5) << 16" because the hi word of
; D0 before the swap (lo word after) is garbage.
;	lsl.b	#5,d0
;	swap	d0
;-

	.globl	_inquiry

_inquiry:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp
	movea.l	#wdc,a0			; pointer to DMA chip
; write command and phyunit#
	move.w	#$88,xwdl(a0)	;wdl
	move.w	4(sp),d0		; d0 = (physunit# << 5) << 16
	moveq	#21,d1
	lsl.l	d1,d0			
	or.l	#$0012008a,d0		; write physunit# + Inquiry + FIFO bits
	move.l	d0,(a0)		;wdcwdl	; inquiry+physunit# wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	inq

	move.l	#$8a,d1			; d1 = byte to be sent
	move.l	d1,(a0)		;wdcwdl	; byte 1
	bsr	_qdone
	bmi	inq

	move.l	d1,(a0)		;wdcwdl	; byte 2
	bsr	_qdone
	bmi	inq

	move.l	d1,(a0)		;wdcwdl	; byte 3
	bsr	_qdone
	bmi	inq

	move.l	#$0010008a,(a0)	;wdcwdl	; 16 byte of parameters (byte 4)
	bsr	_qdone
	bmi	inq

	move.w	#$190,xwdl(a0)	;wdl	; reset the DMA chip
	move.w	#$90,xwdl(a0)	;wdl
	move.w	#$01,(a0)	;wdc	; 1 sector of DMA (actually less)
	move.w	#$8a,xwdl(a0)	;wdl
	move.l	#0,(a0)		;wdcwdl	; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
inq:	bra	_hdone



