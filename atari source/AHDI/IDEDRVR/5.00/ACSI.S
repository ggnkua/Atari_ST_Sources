;+
; Edit History
;
; May-22-89	ml.	Started this with AHDI 3.00.
; Aug-21-89	ml.	Added format code.  It's seperated because it waits
;			forever for command completion.
; Sep-08-89	ml.	Added a 1 microsec delay (rstdelay()) after each 
;			access to the DMA chip which may reset the chip.
; Sep-13-89	ml.	If need to execute a command more than once to
;			get all bytes into RAM, use the original allocation
;			length for subsequent calls.
; Oct-06-89	ml.	Added start/stop unit code.  It's seperated because
;			it needs longer timeouts.
; Nov-08-89	ml.	Added a delay in _rcvacsi() when looping to do more
;			than one _sblkacsi().
; Nov-27-89	ml.	Added .even after declaring control.
; Dec-05-89	ml.	Flushing of D cache before reading status byte.
; Apr-09-90	ml.	Added a "read" from WDL to actually "set" the bit
;			for the new MMU chip.  It's a bug in the chip.  
;			Temporary only.
; Apr-20-90	ml.	Made the "read" added on Apr-09-90 conditional
;			assembly.  RDWDL flag defined in defs.h.
; Sep-24-91	ml.	Added the _slwacsi flag to indicate whether we
;			are talking to a slow ACSI device.  If so, extra
;			delay is necessary to wait for the device to
;			response.
; Oct-07-91	ml.	Instead of using "lsr" to check if transfer is
;			a multiple of 16 in _rcvacsi(), use "andi".
; Dec-03-91	ml.	BIG OOPS: at qd0, the label 'sdelay' was wrong so
;			that the add of _hz_200 to d0 was INSIDE the loop!
;			(just like in dmaread.s)  It is now fixed.
;-


.include	"defs.h"
.include	"sysvar.h"
.include	"68030.s"


;+
;  Hardware definitions for ACSI
;-
WDC		equ	$ffff8604
WDL		equ	$ffff8606
WDCWDL		equ	WDC		; used for long writes
XWDL		equ	WDL-WDC		; offset from wdc to wdl

DMAHI		equ	$ffff8609
DMAMID		equ	DMAHI+2
DMALOW		equ	DMAMID+2
GPIP		equ	$fffffa01


;+
;  Tunable (delay) values for ACSI
;-
ACLTMOUT	equ	600		; long-timeout (3 S)
ACSTMOUT	equ	20		; short-timeout (100 mS)
SLWACLTO	equ	5000		; long-timeout (25 S) for slow ACSI
SLWACSTO	equ	42		; short-timeout (205 mS) for slow ACSI


;+
; Declarations
;-
lastacstm:	dc.l	0		; controller last accessed time
control:	dc.b	0		; flag for sending control byte
		.globl	_slwacsi
_slwacsi:	dc.b	0		; assume not doing slow ACSI
.even

.extern		_cmdblk


;+
; LONG _qdone() - Wait for command byte handshake
; LONG _fdone() - Wait for operation complete
; Passed:	nothing
;
; Returns:	EQ: no timeout
;		MI: timeout condition
;
; Uses:		D0
;
;-

.if	!DRIVER
_slwfdone:				; fdone for slow response
	move.l	#SLWACLTO,d0
	bra.s	qd0
.endif

_fdone:	move.l	#ACLTMOUT,d0
	bra.s	qd0

.if	!DRIVER
_slwqdone:				; qdone for slow response
	moveq	#SLWACSTO,d0	
	bra.s	qd0
.endif

_qdone:	moveq	#ACSTMOUT,d0

qd0:	tst.b	_slwacsi		; talking to slow ACSI device?
	beq.s	qd1			; if not, go wait for interrupt
					; else
	move.l	d0,-(sp)		; save timeout value
	moveq	#2,d0			; busy-wait delay for slow ACSI
	add.l	_hz_200,d0		; minimum 20 microsec.
sdelay:	cmp.l	_hz_200,d0
	bge.s	sdelay
	move.l	(sp)+,d0		; restore timeout value

qd1:	add.l	_hz_200,d0
qd2:	cmp.l	_hz_200,d0		; timeout?
	bcs.s	qdq			; (i give up, return NE)
	btst	#5,GPIP			; interrupt?
	bne.s	qd2			; (not yet)

	moveq	#0,d0			; return EQ (no timeout)
	rts

qdq:	moveq	#-1,d0
	rts


;+
; Wait for end of SASI command
;
; Passed:	d1 value to be written to wdl
;
; Returns:	EQ: success (error code in D0.W)
;		MI: timeout (-1 in D0.W)
;		NE: failure (SASI error code in D0.W)
;
; Uses:		d0
;
; Comments: (12/05/89)
;	The flushing of D cache is necessary per Jim Tittsler.  For
; detail, refer to mail sent by jwt on 12/04/89 about ACSI DMA.
;-
.if	!DRIVER
	.globl	_cachexst
_cachexst:	dc.b	0

_slwendcmd:
	bsr	_slwfdone		; wait for operation complete
	bra.s	end0
.else
	.extern	_cachexst
.endif

_endcmd:
	bsr	_fdone			; wait for operation complete
end0:	bmi.s	endce			; (timed-out, so complain)

cmdcmp:	tst.b	_cachexst		; '030 cache exists
	beq.s	end1			; if not, fine
					; else, dump D cache
	move.w	sr,-(sp)		; go to IPL 7
	ori.w	#$700,sr		; no interrupts right now kudasai
	movecacrd0			; d0 = (cache control register)
	ori.w	#$800,d0		; dump the D cache
	moved0cacr			; update cache control register
	move.w	(sp)+,sr		; restore interrupt state

end1:	move.w	d1,WDL
	move.w	WDC,d0			; get the result
	and.w	#$00ff,d0		; (clean it up), if non-zero should
					; do a ReadSense command to learn more
endce:	move.l	_hz_200,lastacstm	; update controller last accessed time
	addq.l	#2,lastacstm		; lastacstm = _hz_200 + 2;
	rts				


;+
;  Unlock DMA chip and return completion status;
;-
_hdone:	move.w	#$80,WDL	; Landon's code seems to presume we put 
				;  $80 there
	clr	flock		; NOW, signal that we are done
	rts


;+
; delay()
;	5 - 10ms kludge delay for message byte sent back by controller.
;-
_delay:	move.l	d0,-(sp)		; preserve d0
	move.l	lastacstm,d0		; d0 = controller last accessed time
wait:	cmp.l	_hz_200,d0		; while (_hz_200 <= lastacstm)
	bcc.s	wait			;	wait()
	move.l	(sp)+,d0		; restore d0
	rts


;+
; smplacsi() - send a simple ACSI command (ie. no DMA involved)
;
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_smplacsi
_smplacsi:
	st	flock			; lock FIFO
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip
	andi.w	#7,d0			; mask off the flags to get unit num
	moveq	#0,d1			; no DMA
	bsr	sblkacsi		; send command block
	bra	_hdone			; cleanup after IRQ


;+
; rcvacsi() - send a ACSI command which receives data back.
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;
; Comments:
;	This routine assumes that if you are transferring more than 512
; bytes, the transfer length must be a multiple of 16 bytes.  It also 
; assumes the allocation length byte is always at byte 4 in the command
; block. (Therefore, it won't work with Receive Diagnostic ($1c) if data
; length is not a multiple of 16 bytes.  But Receive Diagnostic has never
; been used.)
;	The transfer length in register D1 MUST be greater than 0.
;-
	.globl	_rcvacsi
_rcvacsi:
	st	flock			; lock FIFO
	move.w	d3,-(sp)		; preserve d3
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$190,XWDL(a1)	;WDL	; toggle DMA chip for "receive"
	bsr	rstdelay		; delay
	move.w	#$090,XWDL(a1)	;WDL
	bsr	rstdelay		; delay

.if	RDWDL
	tst.w	XWDL(a1)		; to point MMU to correct direction
.endif	;RDWDL

	bsr	setacnt			; set DMA count

	andi.w	#7,d0			; mask off the flags to get unit num
					; find # times need to send it
	cmpi.l	#512,d1			; transferring < 512 bytes?
	bcs.s	.0			; if so, go find # times to send
	moveq	#0,d1			; else assume it's 16*n, send once
	bra.s	.4

.0:	move.w	d1,d3			; d3 = transfer length
	cmpi.w	#16,d1			; transferring < 16 bytes?
	bcs.s	.1			; if so, find # times to make 16 bytes

	andi.w	#$0f,d1			; else, is it multiple of 16 bytes?
	beq.s	.4			; if so, just do once (d1.w = 0)
	moveq	#1,d1			; else, need to do twice
	bra.s	.4

.1:	moveq	#16,d1			; find # times to make 16 bytes
	divu	d3,d1			; d1.w = 16 / transfer length
	subq.w	#1,d1			; dbra likes one less

.2:	swap	d1			; d1.w = remainder
	tst.w	d1			; any remainder?
	bne.s	.3			; if yes, go add one to the quotient
	swap	d1			; if no, # times to send = quotient
	bra.s	.4

.3:	swap	d1			; d1.w	= # times to send command
	addq.w	#1,d1			;	= quotient + 1

.4:	lea	_cmdblk,a0		; a0 = address of command block
.5:	movem.l	d0-d2/a0,-(sp)		; save d0 through d2 and a0
	moveq	#0,d1			; direction of DMA is IN
	bsr	_delay			; delay if necessary
	bsr	sblkacsi		; send the command block
	tst.w	d0			; successful?
	bne.s	.7			; if not, quit
	movem.l	(sp)+,d0-d2/a0		; else restore d0 through d2 and a0
	dbra	d1,.6			; done yet?
	moveq	#0,d0			; command block sent successfully
	bra.s	raend			; phone home...

.6:	moveq	#-1,d0			; unit number already in command block
	move.b	d3,4(a0)		; modify transfer length
	bra.s	.5			; send it enough times

.7:	adda	#16,sp			; cleanup stack
raend:	move.w	(sp)+,d3		; restore d3
	bra	_hdone			; cleanup after IRQ


;+
; wrtacsi() - send an ACSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_wrtacsi
_wrtacsi:
	st	flock			; lock FIFO
	bsr	_delay
	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$90,XWDL(a1)	;WDL	; toggle DMA chip for "send"
	bsr	rstdelay		; delay 
	move.w	#$190,XWDL(a1)	;WDL
	bsr	rstdelay		; delay

.if	RDWDL
	tst.w	XWDL(a1)		; to point MMU to correct direction
.endif	;RDWDL

	bsr	setacnt			; set DMA count
	
	andi.w	#7,d0			; mask off the flags to get unit num
	move.l	#$0100,d1		; d1 = direction of DMA is OUT
	bsr	sblkacsi		; send the command block

waend:	bra	_hdone			; cleanup after IRQ


;+
; sblkacsi() - set DMA pointer and count and send command block
;
; Passed:
;	d0.w = physical unit number
;	d1.l = direction of DMA ($0000 for IN or $0100 for OUT)
;	d2.w = command length (NCMD or LCMD)
;	a1.l = pointer to DMA chip
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if timeout
;
; Trashes:
;	d0, d1, d2, a2
;-
sblkacsi:
	move.b	#$88,d1			; next byte is the opcode
	move.w	d1,XWDL(a1)	;WDL

	move.b	#$8a,d1			; following bytes are operands
	lea	_cmdblk,a2		; a2 = address of command block

	tst.w	d0			; is unit # already in command block
	bmi.s	.0			; if yes, just send command block
					; else integrate unit # into cmd blk
	lsl.b	#5,d0			; shift unit number into place
	or.b	d0,(a2)			; first command byte = unit # | opcode
					; control byte is sent seperately
.0:	subq.w	#2,d2			; and dbra likes one less 
.1:	swap	d1			; d1.hw = operand
	move.b	(a2)+,d1		; d1.lw = tells controller next byte
	swap	d1			;	  is an operand
	move.l	d1,(a1)		;WDCWDL
	bsr	_qdone
	bmi.s	sbaend			; if timeout, returns
	dbra	d2,.1			; else send rest of command block

	move.w	d1,XWDL(a1)	;WDL	; else get ready to send control byte
	move.b	#0,d1			; signal sending control byte
	swap	d1			; d1.hw = operand
	move.b	(a2),d1			; d1.lw = tells controller it's end
	swap	d1			;	  of command
	move.l	d1,(a1)			; send it

	move.b	#$8a,d1			; d1 = wdl value
	bsr	_endcmd			; wait for command completion
sbaend: rts				; heading home


;+
; setadma() - set the ACSI DMA pointer
;
; Passed:
;	a0.l = buffer address
;-
setadma:
	move.l	a0,-(sp)		; move it on stack
	move.b	3(sp),DMALOW		; set low-byte of address
	move.b	2(sp),DMAMID		; set mid-byte of address
	move.b	1(sp),DMAHI		; set high-byte of address
	addq.l	#4,sp			; clean up stack
	rts


;+
; setacnt() - set the ACSI DMA counter
;
; Passed:
;	d1.l = count (in bytes)
;	a1.l = pointer to DMA chip
;-
setacnt:
	cmpi.l	#512,d1			; transferring more than 512 bytes?
	bhi.s	.0			; if so, find transfer len in blocks
	move.w	#$01,(a1)	;WDC	; else set DMA count to 1 block
	bra.s	sacend
.0:	move.l	d1,-(sp)		; save transfer length (in bytes)
	lsr.l	#8,d1			; find transfer length (in blocks)
	lsr.l	#1,d1			; d1 >>= 9 = transfer len (in blocks)
	move.w	d1,(a1)		;WDC	; set DMA count
	move.l	(sp)+,d1		; restore transfer length (in bytes)
sacend:	rts



.if	!DRIVER				; not to be included in driver

;+
; fmtacsi() - format an ACSI unit
;
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_fmtacsi
	.extern	_cmdblk
_fmtacsi:
	st	flock			; lock FIFO
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip
	andi.w	#7,d0			; mask off the flags to get unit num
	moveq	#0,d1			; clear d1
	move.b	#$88,d1			; next byte is the opcode
	move.w	d1,XWDL(a1)	;WDL

	move.b	#$8a,d1			; following bytes are operands
	lea	_cmdblk,a2		; a2 = address of command block
					; integrate unit # into cmd blk
	lsl.w	#5,d0			; shift unit number into place
	or.b	d0,(a2)			; first command byte = unit # | opcode
					; control byte is sent seperately
	subq.w	#2,d2			; and dbra likes one less 
.0:	swap	d1			; d1.hw = operand
	move.b	(a2)+,d1		; d1.lw = tells controller next byte
	swap	d1			;	  is an operand
	move.l	d1,(a1)		;WDCWDL
	bsr	_qdone
	beq.s	.1			; if successful, go on
	rts				; else it timed-out, returns
.1:	dbra	d2,.0			; send rest of command block

	move.w	d1,XWDL(a1)	;WDL	; else get ready to send control byte
	move.b	#0,d1			; signal sending control byte
	swap	d1			; d1.hw = operand
	move.b	(a2),d1			; d1.lw = tells controller it's end
	swap	d1			;	  of command
	move.l	d1,(a1)			; send it

	move.b	#$8a,d1			; d1 = wdl value
.2:	btst	#5,GPIP			; wait forever for command completion
	bne.s	.2
	bsr	cmdcmp			; command completed
	bra	_hdone			; cleanup after IRQ


;+
; stacsi() - start/stop an ACSI unit
;
;	d0.w = physical unit number
;	d2.w = command length (NCMD or LCMD)
;-
	.globl	_stacsi
	.extern	_cmdblk
_stacsi:
	st	flock			; lock FIFO
	bsr	_delay			; delay if necessary
	movea.l	#WDC,a1			; a1 = pointer to DMA chip
	andi.w	#7,d0			; mask off the flags to get unit num
	moveq	#0,d1			; clear d1
	move.b	#$88,d1			; next byte is the opcode
	move.w	d1,XWDL(a1)	;WDL

	move.b	#$8a,d1			; following bytes are operands
	lea	_cmdblk,a2		; a2 = address of command block
					; integrate unit # into cmd blk
	lsl.w	#5,d0			; shift unit number into place
	or.b	d0,(a2)			; first command byte = unit # | opcode
					; control byte is sent seperately
	subq.w	#2,d2			; and dbra likes one less 
.0:	swap	d1			; d1.hw = operand
	move.b	(a2)+,d1		; d1.lw = tells controller next byte
	swap	d1			;	  is an operand
	move.l	d1,(a1)		;WDCWDL
	bsr	_slwqdone		; needs a longer short timeout
	beq.s	.1			; if successful, go on
	rts				; else it timed-out, returns
.1:	dbra	d2,.0			; send rest of command block

	move.w	d1,XWDL(a1)	;WDL	; else get ready to send control byte
	move.b	#0,d1			; signal sending control byte
	swap	d1			; d1.hw = operand
	move.b	(a2),d1			; d1.lw = tells controller it's end
	swap	d1			;	  of command
	move.l	d1,(a1)			; send it

	move.b	#$8a,d1			; d1 = wdl value
	bsr	_slwendcmd		; wait for command completion
	bra	_hdone			; cleanup after IRQ

.endif	;!DRIVER


;+
; Rstdelay()
;	After talking to the DMA chip in a way that may reset it, 
; we need a 8 8Mhz clocks (ie. 1 microsec) delay, before we can
; talk to the chip again.
;-
rstdelay:
	tst.b	GPIP			; delay for 1 microsec
	tst.b	GPIP			; this amounts to 16 16Mhz clocks
	tst.b	GPIP
	tst.b	GPIP
	rts

