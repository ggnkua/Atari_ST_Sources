flock		equ	$43e		; FIFO lock variable
_hz_200		equ	$4ba		; system 200hz timer

SHIP		equ	0		; flag to stop ACSI unit 0
UNSHIP		equ	1		; flag to restart ACSI unit 0

wdc		equ	$ffff8604
wdl		equ	$ffff8606
wdcwdl		equ	wdc		; used for long writes
xwdl		equ	wdl-wdc		; offset from wdc to wdl

dmahi		equ	$ffff8609
dmamid		equ	dmahi+2
dmalow		equ	dmamid+2
gpip		equ	$fffffa01

slwstmout	equ	42		; short-timeout (205 mS) for slow ACSI
slwltmout	equ	2000		; long-timeout (30 S) for slow ACSI


main:	move.l	#0,-(sp)	; NULL
	move.w	#$20,-(sp)	; Super(0L)
	trap	#1
	addq.w	#6,sp		; cleanup stack
	move.l	d0,savssp	; save stack pointer
	move.w	#SHIP,-(sp)	; stop the unit
	move.w	#0,-(sp)	; ACSI unit 0
	bsr	_stunit		; stunit(physunit, SHIP)
	addq.w	#4,sp		; clean up stack
	move.w	#UNSHIP,-(sp)	; stop the unit
	move.w	#0,-(sp)	; ACSI unit 0
	bsr	_stunit		; stunit(physunit, UNSHIP)
	addq.w	#4,sp		; clean up stack
	move.l	savssp,-(sp)	; saved stack pointer
	move.w	#$20,-(sp)	; Super(savssp)
	trap	#1
	addq.w	#6,sp		; cleanup stack
	move.w	#0,-(sp)	; Pterm0
	trap	#1
	illegal			; should never come back

savssp:	dc.l	0

;----------------
;
; LONG _qdone() - Wait for command byte handshake
; LONG _fdone() - Wait for operation complete
; Passed:	nothing
;
; Returns:	EQ: no timeout
;		MI: timeout condition
;
; Uses:		D0
;
;
;-
_slwfdone:				; fdone for slow ACSI devices
	move.l	#slwltmout,d0		; wait 30 seconds
	bra.s	qd1

_slwqdone:				; qdone for slow ACSI devices
	moveq	#slwstmout,d0		; wait 200 milliseconds

qd1:	add.l	_hz_200,d0
qd2:	cmp.l	_hz_200,d0		; timeout?
	bcs.s	qdq			; (i give up, return NE)
	btst	#5,gpip			; interrupt?
	bne.s	qd2			; (not yet)

	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	moveq	#-1,d0
	rts


;----------------
;
; Wait for end of SASI command
;
; Passed:	d0 value to be written to wdl
;
; Returns:	EQ: success (error code in D0.W)
;		MI: timeout (-1 in D0.W)
;		NE: failure (SASI error code in D0.W)
;
; Uses:		d0,d1
;-
_slwendcmd:
	move	d0,d1			; preserve wdl value
	bsr	_slwfdone		; wait for operation complete

end1:	bmi.s	endce			; (timed-out, so complain)

	move.w	d1,wdl
	move.w	wdc,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should
					; do a ReadSense command to learn more
endce:	move.l	_hz_200,lastacstm	; update controller last accessed time
	addq.l	#2,lastacstm		; lastacstm = _hz_200 + 2;
	rts				


;+
;  Handle command timeout;
;  Unlock DMA chip and return completion status;
;-
_hto:	moveq	#-1,d0		; indicate timeout
_hdone:	move.w	#$80,wdl	; Landon's code seems to presume we
	tst.w	wdc
	sf	flock		; NOW, signal that we are done
	rts


lastacstm:	dc.l	0

;+
; delay()
;	5 - 10ms kludge delay for message byte sent back by controller.
;-
_delay:	move.l	lastacstm,d0		; d0 = controller last accessed time
wait:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastacstm)
	bcc.s	wait			;	wait()
	rts

;----------------
;
;  stunit - Start/Stop unit
;
;    Synopsis:	LONG stunit(dev, flag)
;		WORD dev;		4(sp).W
;		WORD flag;		6(sp).W
;
;    Uses:  d0, d1, and a0
;-
stcmd:	dc.b	$1b	; start/stop command + devno (upper 3 bits)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
	dc.b	0	; (unused)
	dc.b	0	; bit 0 = to flag start or stop unit
	dc.b	0	; (unused)
.even

_stunit:
	bsr	_delay
	move.w	4(sp),d0		; set dev#
	lsl.b	#5,d0			; up 5 bits, fill in 0s
	lea	stcmd,a0		; pick up pointer to the command block
	or.b	d0,(a0)			; stuff dev # into command frame
	move.b	7(sp),4(a0)		; stuff flag into command frame
	moveq	#0,d0			; clear d0
	st	flock			; lock FIFO
	move.w	#$88,wdl
	move.b	(a0)+,d0		; get the command byte
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl		; byte wdc 8a wdl
	
	moveq	#(5-1),d1		; write next 5 bytes of command
st1:	bsr	_slwqdone
	bmi	_hto
	move.b	(a0)+,d0		; next byte of command
	swap	d0
	move.w	#$8a,d0
	move.l	d0,wdcwdl		; byte wdc 8a wdl
	dbra	d1,st1
	bsr	_slwendcmd		; wait for command completion
	moveq	#2,d1			; /* ~ 5 millisecond delay */
	add.l	_hz_200,d1		; /* for slow acsi devices */
.0:	cmp.l	_hz_200,d1		;
	bcc.s	.0			;
	bra	_hdone			; cleanup after IRQ

