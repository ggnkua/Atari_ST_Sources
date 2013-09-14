;+
; Edit History
;
; May-17-89	ml.	Started this with jwt's SCSI code.
; Aug-21-89	ml.	Added format code.
; Nov-17-89	ml.	Only add 8 to byte count on DMA reads, not writes.
; Dec-04-89	ml.	Always hand-shake last 8 bytes of data when writing
;			to disk because of hardware counter handling.
;			Added w4cntout().
;			(refer to comments at _wrtscsi())
; Jan-23-90	ml.	Undid modifications done on Dec-04-89.
;			(refer to comments at _wrtscsi())
; Jul-31-90	ml.	Modified to handle vectored-interrupts in addition
;			to polling. (in form of conditional assembly)
; Apr-04-91	ml.	Added recalibration time to timeout for transfer of
;			data. (in w4int() and w4dreq())
;-


.include	"defs.h"
.include	"sysvar.h"
.include	"mfp.h"
.include	"scsi.h"
.include	"68030.s"

;+
; Command length
;-
NCMD	equ	6		; length of short command (in bytes)


.if	VI			; if vectored-interrupts desired
dmac_int:	dc.b	0	; flag for DMAC interrupts
phase_changed:	dc.b	0	; flag for SCSI phase changes
.endif	;VI


.if	!DRIVER			; not to be included in driver
scxltmout:	dc.l	12001	; SCSI extra long-timeout (>1 min)
slwsclto:	dc.l	5000	; SCSI long-timeout (>25 S) for stunit()
slwscsto:	dc.l	42	; SCSI short-timeout (>205 mS) for stunit()
scltmout:	dc.l	201	; SCSI long-timeout (>1000 ms)
scstmout:	dc.l	101	; SCSI short-timeout (>500 ms)
rcaltm:		dc.l	801	; time for drive recalibration (>4s)
.even
.else	;!DRIVER
.extern	scxltmout, slwsclto, slwscsto, scltmout, scstmout, rcaltm
.endif	;!DRIVER


;+
; smplscsi() - send a simple SCSI command (ie. no DMA involved)
;
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_smplscsi
_smplscsi:
	andi.w	#7,d0			; mask off the flags to get unit num
	bsr	sblkscsi		; send command block
	bpl.s	.0			; if successful, wait for status
	rts				; else return
.0:	bra	w4stat			; waiting for status byte


;+
; rcvscsi() - send a SCSI command which receives data back.
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;
; Comments:
;	The code that checks whether there is data left in the residue
; register does not work for some transfers of less than 4 bytes to a
; non-longword aligned address.  
;-
	.globl	_rcvscsi
_rcvscsi:
.if	!SCDMA				; if not doing DMA
	move.l	a0,-(sp)		; save buffer address
.endif	;SCDMA
	andi.w	#7,d0			; mask off the flags to get unit num

.if	SCDMA				; if doing DMA
.if	ODMA				; and using Old DMA controller
	addq.l	#8,d1			; add 8 because of hardware bug
.endif	;ODMA
.endif	;SCDMA

	move.w	d2,-(sp)		; save the command length
	bsr	sblkscsi		; send command block
	move.w	(sp)+,d2		; restore the command length
.if	!SCDMA				; if not doing DMA
	move.l	(sp)+,a0		; restore buffer address
.endif	;SCDMA
	tst.w	d0			; successful?
	bmi	rsend			; if not successful, return

	move.b	#0,SCSIICR		; deassert the data bus
	move.b	#1,SCSITCR		; set data in phase
	move.b	SCSIREI,d0		; clear potential interrupt

.if	SCDMA
					; Set up the DMAC for data transfer
	move.b	#2,SCSIMR		; enable DMA mode
	move.b	#0,SCSIDIR		; start the DMA receive
	move.w	#DMAIN,SDMACTL		; set the DMAC direction to IN
	move.w	#DMAIN+DMAENA,SDMACTL	; turn on DMAC

	bsr	setscstmout		; set up a short timeout
	cmpi.w	#NCMD,d2		; is this a long command?
	beq.s	.0			; if not, just go on
	bsr	setscxltmout		; else, set up an extra long timeout
.0:	bsr	w4int			; wait for interrupts
	tst.w	d0			; successful?
	bne.s	rsend			; if error, returns
	bsr	w4stat			; wait for status byte
	tst.w	d0			; successful?
	bne.s	rsend			; if error, returns
	move.l	d0,-(sp)		; else save returned status

	move	sr,-(sp)		; go to IPL 7
	ori	#$700,sr		; no interrupts right now kudasai
	movecacrd0			; d0 = (cache control register)
	ori.w	#$808,d0		; dump both the D and I cache
	moved0cacr			; update cache control register
	move	(sp)+,sr		; restore interrupt state

	move.b	bSDMAPTR+6,d0		; see if this was an odd transfer
	andi.w	#3,d0			; (ie, not multiple of 4)
	beq.s	.2			; no, nice and even (and easy)

	movea.l	#bSDMAPTR,a1		; a1 -> DMA address
	movep.l	(0,a1),d0		; d0 = current value of DMA pointer
	move.l	d0,d1			; d1 = current value of DMA pointer

	andi.w	#3,d0			; # bytes left in residue register
	andi.w	#$FFFF-3,d1		; where does data go to?
	movea.l	d1,a0			; a0 -> where rest of data should go
	move.l	SDMARES,d1		; get the residue
	subq.w	#1,d0			; dbra likes one less than count
.1:	rol.l	#8,d1			; tranfer residue to buffer
	move.b	d1,(a0)+
	dbra	d0,.1

.2:	move.l	(sp)+,d0		; recall the status byte

.else	;SCDMA
	movea.l	a0,a1			; a1 -> buffer to read into
	movea.l	#bSCSI,a2		; a2 -> 5380
.3:	bsr	setscstmout
	bsr	w4dreq			; wait for REQ for data to come
	bmi.s	rsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data in phase?
	beq	w4stat			; no, go get status
	move.b	(a2),(a1)+		; read the data byte
	bsr	doack
	bra.s	.3			; do next byte
.endif	;SCDMA
rsend:	rts


;+
; wrtscsi() - send a SCSI command which will write data to the target
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;
; Comments: 
; 12/04/89 ml
;	Bus error occurs when doing a write to the disk that ends at top
; of memory.  The DMA counter is decremented when the bytes are written 
; from the ping pong buffers to the device, not when bytes are grapped 
; from RAM to the ping pong buffers.  Well, AFTER the last 8 bytes are 
; read into the ping pong buffers and BEFORE they are written to the 
; device, the chip will attempt to read the NEXT 8 bytes into the ping 
; pong buffers which results in a bus error because it will be reading 
; pass top of memory.  To get around this HARDWARE BUG, the code will 
; ALWAYS handshake the last 8 bytes over instead of DMAing them.
;
; 01/23/90 ml
;	A. Pratt said he's willing to move the screen down and sacrifice
; 16 bytes of memory.  So, code added on 12/04/89 is commented out.
;-
	.globl	_wrtscsi
_wrtscsi:
	andi.w	#7,d0			; mask off the flags to get unit num

.if	!SCDMA
	move.l	a0,-(sp)		; save beginning buffer address
.endif	;!SCDMA

.0:	move.w	d2,-(sp)		; save command length
	bsr	sblkscsi		; send command block
	move.w	(sp)+,d2		; restore command length
.if	!SCDMA
	move.l	(sp)+,a0		; a0 = where DMA ends
.endif	;!SCDMA
	tst.w	d0			; successful?
	bpl.s	.1			; if successful, go on
	rts				; else return

.1:	move.b	#0,SCSITCR		; set data out phase
	move.b	SCSIREI,d0		; clear potential interrupt

.if	SCDMA
					; Set up the DMAC for data transfer
	move.b	#2,SCSIMR		; enable DMA mode
	move.b	#0,SCSIDS		; start the DMA send
	move.w	#DMAOUT,SDMACTL		; set the DMAC direction
	move.w	#DMAOUT+DMAENA,SDMACTL	; turn on DMAC

	bsr	setscstmout		; set up a short timeout
	cmpi.w	#NCMD,d2		; is this a long command?
	beq.s	.2			; if not, just go on
	bsr	setscxltmout		; set up an extra long timeout
.2:	bsr	w4int			; wait for interrupts
	tst.w	d0
	bne.s	wsend			; if failed, return
	bsr	w4stat			; wait for status byte

.else	;SCDMA
					; hand shake the rest over the bus
	movea.l	a0,a1			; a1 -> buffer to write from
	movea.l	#bSCSI,a2		; a2 -> 5380
.3:	bsr	setscstmout
	bsr	w4dreq			; wait for REQ for data to come
	bmi.s	wsend			; if timed out, returns
	btst	#3,5*REGSTEP(a2)	; still in data out phase?
	beq	w4stat			; no, go get status
	move.b	(a1)+,(a2)		; write the data byte
	bsr	doack
	bra.s	.3			; do next byte
.endif	;SCDMA
wsend:	rts



;+
; sblkscsi() - set DMA pointer and count and send command block
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;
; Returns:
;	d0.l =  0 if successful
;	d0.l = -1 if timeout
;-
	.extern	_cmdblk
sblkscsi:
	movem.l	d1-d2/a0,-(sp)		; preserve d1, d2 and a0
	move.w	d0,-(sp)		; physical unit #
	bsr	selscsi			; select the unit
	addq.l	#2,sp			; clean up stack
	movem.l	(sp)+,d1-d2/a0		; restore d1, d2 and a0
	tst.w	d0			; selection successful?
	bmi.s	sbsend			; if timed out, return
					; else proceed
.if	SCDMA
	move.l	a0,d0			; d0 = buffer address
	movea.l	#bSDMAPTR,a1		; a1 -> DMA address
	movep.l	d0,(0,a1)		; set DMA pointer

	movea.l	#bSDMACNT,a1		; a1 -> DMA count
	movep.l	d1,(0,a1)		; set DMA count
.endif	;SCDMA

	move.b	#2,SCSITCR		; assert C/D
	move.b	#1,SCSIICR		; assert data bus

	bsr	setscstmout		; set up timeout for sending cmdblk
	lea	_cmdblk,a1		; a1 -> command block
	subq.w	#1,d2			; dbra likes one less
.0:	move.b	(a1)+,d0		; d0.b = byte to be sent
	bsr	hshake			; write that byte
	tst.w	d0
	bmi.s	sbsend			; if timed-out, returns
	dbra	d2,.0			; until whole command block is sent
	moveq	#0,d0			; all operations successful
sbsend: rts				; heading home


;+
; BOOLEAN selscsi(SCSIUnit) 
; WORD SCSIUnit;
;-
selscsi:
	bsr	setscstmout		; set up a short timeout
.0:	btst	#6,SCSICR		; STILL busy from last time?
	beq.s	.1			; if not, it's available
	cmp.l	(a0),d1			; timeout?
	bhi.s	.0			; not yet, wait some more
	bra.s	.3			; else, return error

.1:	move.b	#0,SCSITCR		; data out phase
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
	nop				; 2 deskew delays
	nop

	bsr	setscstmout		; set up for timeout
.2:	btst	#6,SCSICR		; wait for bus to be busy
	bne.s	.4
	cmp.l	(a0),d1
	bhi.s	.2

.3:	moveq	#-1,d0			; time out
	bra.s	.5
	
.4:	clr.w	d0			; selection successful
.5:	move.b	#$0,SCSIICR		; clear SEL and data bus assertion
	rts


*+
* VOID resetscsi();
*-
	.globl	resetscsi
resetscsi:
	move.b	#$80,SCSIICR	; assert RST
	bsr	setscstmout	; wait (at least) 250 ms
.0:	cmp.l	(a0),d1
	bhi.s	.0
	move.b	#$00,SCSIICR
	bsr	setscltmout	; wait (at least) 1000 ms
.1:	cmp.l	(a0),d1
	bhi.s	.1
	rts


;+
; w4int - wait for interrupts from 5380 or DMAC during DMA tranfers
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	d0.l = returned status or timeout error
;
; Comments:
;	When 5380 is interrupted, it indicates a change of data to
; status phase (i.e., DMA is done), or ...
;	When DMAC is interrupted, it indicates either DMA count is
; zero, or there is an internal bus error.
;-
w4int:	
	add.l	rcaltm,d1		; add time for recalibration
.0:	
.if	VI
	tst.b	phase_changed		; phase changed?
.else	;VI
	btst	#GPIP2SCSI,GPIP2	; wait for 5380 to interrupt
.endif	;VI

	bne.s	.3			; active HIGH
	cmp.l	(a0),d1			; time's up yet?
	bls.s	.4			; if not, wait some more

.if	VI
	tst.b	dmac_int		; DMAC interrupted?
	bne.s	.1			; if so, check out why
.else	;VI
	btst	#5,GPIP2		; or for DMAC to interrupt
	beq.s	.1			; active LOW
.endif	;VI

	cmp.l	(a0),d1			; time's up yet?
	bhi.s	.0			; if not, wait some more
					; timed-out
.4:	bsr	resetscsi		; reset the SCSI bus
	moveq	#-1,d0			; else, return timeout
	bra.s	w4iend

.1:	move.w	SDMACTL,d0		; get the DMAC status
	andi.l	#$80,d0			; check for bus err/ignore cntout ints

.if	VI
	bne.s	.2			; if bus error reset bus
	sf	dmac_int		; else clear dmac interrupt flag
	bra.s	.0			; and wait some more
.else	;VI
	beq.s	.0			; if fine, wait for interrupts again
.endif	;VI

.2:	move.w	d0,-(sp)		; save the returned status
	bsr	resetscsi		; reset the SCSI bus
	move.w	(sp)+,d0		; d0 = return code

.if	VI
	sf	dmac_int		; clear dmac interrupt flag
.endif	;VI

	bra.s	w4iend			; returns
.3:	
.if	VI
	sf.b	phase_changed		; clear phase change flag
	move.b	SCSICR,d0		; d0 = SCSI control register
	andi.b	#$1c,d0			; mask off irrelevant bits
	cmpi.b	#$c,d0			; data phase -> status phase?
	bne.s	.0			; if not, wait some more
.endif	;VI

	moveq	#0,d0			; DMA is successful
	move.b	SCSIREI,d1		; clear potential interrupt
	move.w	#DMADIS,SDMACTL		; disable DMA
	move.b	#0,SCSIMR		; disable DMA mode
	move.b	#0,SCSIICR		; make sure data bus is not asserted
w4iend:	rts


;+
; w4stat - wait for status byte and message byte.
;
; Returns:
;	d0.l = returned status or timeout error
;-
w4stat:	bsr	setscstmout		; set up time-out for REQ and ACK
	move.b	#3,SCSITCR		; status in phase
	move.b	SCSIREI,d0		; clear potential interrupt

	bsr	w4req			; wait for status byte
	bmi.s	w4send			; if timed-out, returns
gstat:	moveq	#0,d0			; clear d0
	move.b	SCSIDB,d0		; get the status byte
	move.l	d0,-(sp)		; save the status byte
	bsr	setscstmout		; set up time-out for REQ and ACK
	bsr	doack			; signal that status byte is here
	tst.w	d0			; timed-out?
	beq.s	.1			; if not, wait for message byte

.0:	addq.l	#4,sp			; else clean up stack
	bra.s	w4send			; and return

.1:	bsr	setscstmout		; set up timeout for REQ and ACK
	bsr	w4req			; wait for message byte
	bmi.s	.0			; if timed-out, returns

	move.b	SCSIDB,d0		; get and ignore message byte
	bsr	doack			; signal that message byte is here
	tst.w	d0			; timed-out?
	bmi.s	.0			; if so, return timeout

.if	DEBUG
	move.l	#_hz_200,a0		; For debugging SEA177N - 
	moveq	#4,d1			;   add a delay after receiving 
	add.l	(a0),d1			;   message byte
.2:	cmp.l	(a0),d1
	bhi.s	.2
.endif	;DEBUG

	move.l	(sp)+,d0		; recall the status byte
w4send:	rts


;+
; w4dreq() - wait for REQ to come during hand shake of data bytes
; w4req() - wait for REQ to come during hand shake of non-data bytes
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
w4dreq:	add.l	rcaltm,d1		; add time for recalibration
w4req:
.0:	btst	#5,SCSICR		; waiting for REQ to come
	bne.s	.1			; if REQ comes, done
	cmp.l	(a0),d1			; time's up?
	bhi.s	.0			; if not, wait some more
	moveq	#-1,d0			; else, returns timed out
	bra.s	w4rend
.1:	moveq	#0,d0			; returns successful
w4rend:	rts


;+
; doack() - assert ACK
;
; Passed:
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
doack:	ori.b	#$11,SCSIICR		; assert ACK (and data bus)
.0:	btst	#5,SCSICR		; wait for REQ to go away
	beq.s	.1			; if REQ goes away, done
	cmp.l	(a0),d1			; time's up?
	bhi.s	.0			; if not, wait some more
	moveq	#-1,d0			; else returns timed out
	bra.s	doaend
.1:	moveq	#0,d0			; returns successful
doaend:	andi.b	#$ef,SCSIICR		; clear ACK
	rts


;+
; hshake() - hand shake a byte over to the controller
;
; Passed:
;	d0.b = byte to be handed over
;	d1.l = expiration time
;	a0.l = address of _hz_200
;
; Returns:
;	Whatever w4req() or doack() returns, which is:
;		 0 - if successful
;		-1 - times out
;-
hshake:	move.w	d0,-(sp)		; preserve d0.w
	bsr	w4req			; wait for REQ to come
	bmi.s	hsend			; if timed out, returns
	move.b	1(sp),SCSIDB		; write a byte out to data bus
	bsr	doack			; assert ACK
hsend:	addq.l	#2,sp			; clean up stack
	rts


;+
; setscstmout - set up a timeout count for the SCSI for SCSTMOUT long
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
	.globl	setscstmout
setscstmout:
	movea.l	#_hz_200,a0		; a0 -> 200 hz clock
	move.l	scstmout,d1		; d0 = scstmout _hz_200 clicks
	add.l	(a0),d1			; d0 = curr time + # clicks to wait
	rts


;+
; setscltmout - set up a timeout count for the SCSI for SCLTMOUT long
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
	.globl	setscltmout
setscltmout:
	movea.l	#_hz_200,a0		; a0 -> 200 hz clock
	move.l	scltmout,d1		; d0 = scltmout _hz_200 clicks
	add.l	(a0),d1			; d0 = curr time + # clicks to wait
	rts


;+
; setscxltmout - set up a timeout count for the SCSI for SCXLTMOUT long
;
; Returns:
;	a0.l = address of _hz_200 clock
;	d1.l = expiration time
;-
	.globl	setscxltmout
setscxltmout:
	movea.l	#_hz_200,a0		; a0 -> 200 hz clock
	move.l	scxltmout,d1		; d0 = scxltmout _hz_200 clicks
	add.l	(a0),d1			; d0 = curr time + # clicks to wait
	rts



.if	!DRIVER				; not to be included in driver

;+
; fmtscsi() - format a SCSI unit
;
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_fmtscsi
_fmtscsi:
	andi.w	#7,d0			; mask off the flags to get unit num
	bsr	sblkscsi		; send command block
	bpl.s	.0			; if successful, wait for status byte
	rts				; else return
.0:	move.b	#3,SCSITCR		; status in phase
	move.b	SCSIREI,d0		; clear potential interrupt
.1:	btst	#5,SCSICR		; wait forever for REQ to 


.if	DEBUG

	bne.s	.3			; For debugging purpose - 
	move.l	#_hz_200,a0		;    add a delay in this "tight" 
	moveq	#2,d1			;    loop to slow down SCSI chip 
	add.l	(a0),d1			;    accessing.
.2:	cmp.l	(a0),d1
	bhi.s	.2
	bra.s	.1

.else	;DEBUG

	beq.s	.1			;   come

.endif	;DEBUG

.3:	bra	gstat			; when REQ comes, get status byte

.endif	;!DRIVER


.if	VI
;+
; scsi_isr - interrupt service routine for SCSI phase changes
;-
	.globl	scsi_isr
scsi_isr:
	movem.l	d0-d1,-(sp)		; save d0 and d1
	move.b	SCSIDSR,d0		; read DMA status register
	move.b	d0,d1			; d0 and d1 contains DMA status
	andi.b	#$10,d0			; interrupt coming from IRQ
	beq.s	scsiend			; if not, not interested
	andi.b	#$2c,d1			; else mask off irrelevant bits
	cmpi.b	#$1f,d1			; if status > 0x1f
	bhi.s	scsiend			;   ignore parity error interrupt
	btst.l	#$3,d1			; phase match bit cleared?
	bne.s	scsiend			; if not, not interested
					; else it's a phase mismatch interrupt
	st	phase_changed		; set flag to indicate phase changes
scsiend:
	movem.l	(sp)+,d0-d1		; restore d0 and d1
	move.b	#$7f,ISRA2		; clear GPIP2SCSI in-service bit
	rte



;+
; dmac_isr - interrupt service routine for DMAC
;	It means we are either a cntout zero or internal bus error.
;-
	.globl	dmac_isr
dmac_isr:
	st	dmac_int		; indicate DMAC was interrupted
	move.b	#$7f,ISRB2		; clear GPIP25 in-service bit 
	rte

.endif	;VI

