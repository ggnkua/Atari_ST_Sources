
.include	"defs.h"
.include	"sysvar.h"
.include	"mfp.h"
.include	"acsi.h"
.include	"spscsi.h"
.include	"macros.h"
.include	"68030.s"

;+
; Command length
;-
NCMD	equ	6		; length of short command (in bytes)


.if	!DRIVER		    ; not to be included in driver
scxltmout:  dc.l    12001   ; SCSI extra long-timeout (>1 min)
slwsclto:   dc.l    5000    ; SCSI long-timeout (>25 S) for stunit()
slwscsto:   dc.l    42	    ; SCSI short-timeout (>205 mS) for stunit()
scltmout:   dc.l    201	    ; SCSI long-timeout (>1000 ms)
scstmout:   dc.l    101	    ; SCSI short-timeout (>500 ms)
rcaltm:	    dc.l    801	    ; time for drive recalibration (>4s)
.else	;!DRIVER
.extern	scxltmout, slwsclto, slwscsto, scltmout, scstmout, rcaltm
.endif	;!DRIVER

.extern	setadma, setacnt, _hdone
stat:	    dc.w    0		; status byte
flush:	    dc.b    0		; flush flag
.even

;+
; smplspscsi() - send a simple SCSI command (ie. no DMA involved)
;
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.globl	_smplspscsi
_smplspscsi:
	st	flock
	andi.w	#7,d0			; mask off the flags to get unit num
	bsr	sblkspscsi		; send command block
	tst.w	d0			; successful?
	bmi.s	.0			; if not, go clean up
	bsr	w4spstat		; else wait for status
.0:	RSCSI	#SPSCSIREI,d1		; clear potential interrupt
	bra	_hdone			; go clean up



;+
; rcvspscsi() - send a SCSI command which receives data back.
;
; Passed:
;	d0.w = physical unit number
;	d1.l = transfer length (in bytes)
;	d2.w = command length (NCMD or LCMD)
;	a0.l = buffer address
;-
	.extern	_cachexst
	.globl	_rcvspscsi
_rcvspscsi:
	st	flock			; lock FIFO
	andi.w	#7,d0			; mask off the flags to get unit num
	movem.l	d1-d2/a0,-(sp)		; save buffer address and cmd length
	bsr	sblkspscsi		; send command block
	movem.l	(sp)+,d1-d2/a0		; restore buffer address and cmd len
	tst.w	d0			; successful?
	bmi	rspend			; if not successful, return

;+
; Feb-13-1992	Check whether FIFO needs to be flushed.
	sf	flush			; assume no need to flush
	move.l	d1,d0			; d0 = transfer length
	andi.l	#$0f,d0			; multiple of 16?
	beq.s	rdma0			; if so, no need to flush
	st	flush			; else, set flush flag
;-

rdma0:	WSCSI	#0,#SPSCSIICR		; deassert the data bus
	WSCSI	#1,#SPSCSITCR		; set data in phase
	RSCSI	#SPSCSIREI,d0		; clear potential interrupt

.if	SPSCDMA				; Set up the DMAC for data transfer
;	cmpi.l	#512,d1			; transferring >= 512 bytes?
;	bcs	rpio			; if not, do programmed IO
;					; else set up DMA chip for DMA

	WSCSI	#2,#SPSCSIMR		; enable DMA mode
 	movea.l	#WDC,a1			; a1 = pointer to DMA chip
	bsr	setadma			; set DMA pointer
	move.w	#$190,XWDL(a1)	;WDL	; toggle DMA chip for "receive"
	RSTDELAY			; delay
	move.w	#$090,XWDL(a1)	;WDL
	RSTDELAY			; delay
	bsr	setacnt

rdma1:	btst.b	#STA,WDSR		; wait till it's safe to access
	bne.s	rdma1			;  the DMA channel

;	TMOUT	#2,d0			; delay before using DMA channel
;	CNTALL	d0

	WSCSI	#0,#SPSCSIDIR		; start the DMA receive
	move.w	#0,WDL

;+
; Dec-10-1991	ml.	Don't need to have extra long timeout because
;			extended read and write are not supported due
;			to the 8 bit counter in the DMAC.
;
; Feb-13-1992	ml.	Put code back in because DMAC has been modified
;			to have a 14-bit counter.
	moveq	#0,d0			; assume no extra timeout
	cmpi.w	#NCMD,d2		; is this a long command?
	beq.s	rdma2			; if not, just go on
	move.l	scxltmout,d0		; set up an extra long timeout
;-

rdma2:	bsr	w4spint			; wait for interrupts
	tst.w	d0			; successful?
	bne.s	rspend			; if error, returns

;+
; Feb-13-1992	ml.	Added code to use the flush bit on the DMAC.
;			Now, we can do DMA without sending a command
;			multiple times, to write everything from the 
;			FIFO to memory, for transfers of non-multiple
;			of 16 bytes.  Using this flush function requires
;			the buffer provided for the command to be as big 
;			as the closest multiple of 16 to receive all data.
;			
	tst.b	flush			; need to flush FIFO?
	beq.s	rdma3			; if not, proceed	
	move.w	#$0020,WDL		; else flush (Whoosh!)
;-
rdma3:	tst.b	_cachexst		; is there a cache to flush?
	beq.s	rstat			; if not, go get status
	move	sr,-(sp)		; go to IPL 7
	ori	#$700,sr		; no interrupts right now kudasai
	movecacrd0			; d0 = (cache control register)
	ori.w	#$808,d0		; dump both the D and I cache
	moved0cacr			; update cache control register
	move	(sp)+,sr		; restore interrupt state
	bra.s	rstat			; go read status 
.endif	;SPSCDMA

rpio:	movea.l	a0,a1			; a1 -> buffer to read into
rnxtb:	bsr	w4spdreq		; wait for REQ for data to come
	bmi.s	rspend			; if timed out, returns
	RSCSI	#SPSCSIDSR,d0		; still in data in phase?
	btst	#3,d0			
	beq	rstat			; if not, go get status
	RSCSI	#bSPSCSI,d0		; else read the next data byte
	move.b	d0,(a1)+	
	bsr	dospack
	bra.s	rnxtb			; do next byte
rstat:	bsr	w4spstat		; go get status byte
rspend:	RSCSI	#SPSCSIREI,d1		; clear potential interrupt
	bra	_hdone			; go clean up



;+
; wrtspscsi() - send a SCSI command which will write data to the target
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
	.globl	_wrtspscsi
_wrtspscsi:
	st	flock			; lock FIFO
	andi.w	#7,d0			; mask off the flags to get unit num

	movem.l	d1-d2/a0,-(sp)		; save beginning buffer address
	bsr	sblkspscsi		; send command block
	movem.l	(sp)+,d1-d2/a0		; a0 = where DMA ends
	tst.w	d0			; successful?
	bmi	wspend			; if not, go clean up

	WSCSI	#0,#SPSCSITCR		; set data out phase
	RSCSI	#SPSCSIREI,d0		; clear potential interrupt

.if	SPSCDMA
					; Set up the DMAC for data transfer
	cmpi.l	#512,d1			; transferring >= 512 bytes?
	bcs.s	wpio			; if not, do programmed IO
					; else do DMA
	WSCSI	#2,#SPSCSIMR		; enable DMA mode

	movea.l	#WDC,a1			; a1 = pointer to DMA chip

	bsr	setadma			; set DMA pointer
	move.w	#$90,XWDL(a1)	;WDL	; toggle DMA chip for "send"
	RSTDELAY			; delay 
	move.w	#$190,XWDL(a1)	;WDL
	RSTDELAY			; delay
	bsr	setacnt			; set DMA count

wdma0:	btst.b	#STA,WDSR		; wait till it's safe to access
	bne.s	wdma0			;  the DMA channel

;	TMOUT	#2,d0			; delay before using DMA channel
;	CNTALL	d0

	WSCSI	#0,#($100|SPSCSIDS)	; start the DMA send
	move.w	#$100,WDL

;+
; Dec-10-1991	ml.	Don't need to have extra long timeout because
;			extended read and write are not supported due
;			to the 8 bit counter in the DMAC.
;
	moveq	#0,d0			; assume no extra timeout
	cmpi.w	#NCMD,d2		; is this a long command?
	beq.s	wdma1			; if not, just go on
	move.l	scxltmout,d0		; set up an extra long timeout
;-

wdma1:	bsr	w4spint			; wait for interrupts
	tst.w	d0
	beq.s	wstat			; if ok, wait for status byte
	bra.s	wspend			; else return
.endif	;SPSCDMA
					; hand shake data over the bus
wpio:	movea.l	a0,a1			; a1 -> buffer to write from
wnxtb:	bsr	w4spdreq		; wait for REQ for data to come
	bmi.s	wspend			; if timed out, returns
	RSCSI	#SPSCSIDSR,d0
	btst	#3,d0			; still in data out phase?
	beq.s	wstat			; if not, go get status
	moveq	#0,d0
	move.b	(a1)+,d0		; write the next data byte
	WSCSI	d0,#bSPSCSI
	bsr	dospack
	bra.s	wnxtb			; do next byte
wstat:	bsr	w4spstat		; get status byte
wspend:	RSCSI	#SPSCSIREI,d1		; clear potential interrupt
	bra	_hdone			; go clean up



;+
; sblkspscsi() - set DMA pointer and count and send command block
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
sblkspscsi:
	movem.l	d1-d2/a0,-(sp)		; preserve d1, d2 and a0
	move.w	d0,-(sp)		; physical unit #
	bsr	selspscsi		; select the unit
	addq.l	#2,sp			; clean up stack
	movem.l	(sp)+,d1-d2/a0		; restore d1, d2 and a0
	tst.w	d0			; selection successful?
	bmi.s	sbspend			; if timed out, return
					; else proceed
	WSCSI	#2,#SPSCSITCR		; assert C/D
	WSCSI	#1,#SPSCSIICR		; assert data bus

	lea	_cmdblk,a1		; a1 -> command block
	subq.w	#1,d2			; dbra likes one less
sbs0:	bsr	w4spreq			; wait for REQ to come
	bmi.s	sbspend			; if timed out, returns
	move.b	(a1)+,d0		; d0.b = byte to be sent
	WSCSI	d0,#SPSCSIDB		; write a byte out to data bus
	bsr	dospack			; assert ACK
	dbra	d2,sbs0			; until whole command block is sent
	moveq	#0,d0			; all operations successful
sbspend: rts				; heading home


;+
; BOOLEAN selspscsi(SCSIUnit) 
; WORD SCSIUnit;
;-
selspscsi:
	TMOUT	scstmout,d1		; set up a short timeout
	move.w	#SPSCSICR,WDL
.0:	move.w	WDC,d0
	btst	#6,d0			; STILL busy from last time?
	beq.s	.1			; if not, it's available
	CNTDN1	d1,.0			; else if not timed-out, wait longer
	bra	.3			; else, return error

.1:	WSCSI	#0,#SPSCSITCR		; data out phase
	WSCSI	#0,#SPSCSIISR		; no interrupt from selection
	WSCSI	#$0c,#SPSCSIICR		; assert BSY and SEL
; set dest SCSI IDs
	clr.w	d0
	move.w	4(sp),d1		; get the SCSI unit desired
	bset	d1,d0			; set the appropriate bit
	WSCSI	d0,#SPSCSIODR		; (real code would set ours too)

;	WSCSI	#$0d,#SPSCSIICR		; assert BUSY, SEL and data bus
	WSCSI	#$05,#SPSCSIICR		; assert SEL and data bus
	RSCSI	#SPSCSIMR,d0		; read Mode Register
	andi.b	#$fe,d0			; clear arbitrate bit
	move.w	d0,WDC
	RSCSI	#SPSCSIICR,d0		; read Initiator Command Register
	andi.b	#$f7,d0			; clear BUSY
	move.w	d0,WDC
	nop				; 2 deskew delays
	nop

	TMOUT	scstmout,d1		; set up timeout counter
	move.w	#SPSCSICR,WDL
.2:	move.w	WDC,d0			; wait for bus to be busy
	btst	#6,d0
	bne.s	.4

	CNTDN1	d1,.2			; if not timed-out, wait some more

.3:	moveq	#-1,d0			; time out
	bra.s	.5
	
.4:	clr.w	d0			; selection successful
.5:	WSCSI	#0,#SPSCSIICR		; clear SEL and data bus assertion
	rts


;+
; VOID resetspscsi();
;
; Feb-14-1992	ml.	Added code to reset DMAC before talking through
;			it to reset the SCSI bus.  To protect DMAC from
;			locking up, check if it's safe to access it
;			before doing any of the above.
;-
	.globl	resetspscsi
	.extern	setscstmout
	.extern	setscltmout
resetspscsi:
rst0:	btst.b	#STA,WDSR	; wait till it's safe to access
	bne.s	rst0		;  the DMA channel

	move.w	#$190,WDL	; reset DMA chip
	RSTDELAY		; delay
	move.w	#$090,WDL
	RSTDELAY
				; reset SCSI bus
	WSCSI	#$80,#SPSCSIICR	; assert RST
;	TMOUT	scstmout,d1	; wait (at least) 250 ms
;	CNTALL	d1
	bsr	setscstmout	; wait (at least) 250 ms
.0:	cmp.l	(a0),d1
	bhi.s	.0
;	move.w	#0,WDC
	WSCSI	#0,#SPSCSIICR	; clear RST
;	TMOUT	scltmout,d1	; wait (at least) 1000 ms
;	CNTALL	d1
	bsr	setscltmout	; wait (at least) 1000 ms
.1:	cmp.l	(a0),d1
	bhi.s	.1
	rts


;+
; w4spint - wait for interrupts from 5380 or DMAC during DMA tranfers
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
w4spint:
	TMOUT	rcaltm,d1		; set timeout (incl. recalibration)
	add.l	d0,d1
.0:	btst	#5,GPIP			; interrupt?
	beq.s	.1			; active LOW
	CNTDN1	d1,.0			; if there's more time, keep waiting
					; else timed-out
	bsr	resetspscsi		; reset the SCSI bus
	moveq	#-1,d0			; return timeout
	bra.s	w4spiend

.1:	moveq	#0,d0			; DMA is successful
	RSCSI	#SPSCSIREI,d1		; clear potential interrupt
	WSCSI	#0,#SPSCSIMR		; disable DMA mode
	WSCSI	#0,#SPSCSIICR		; make sure data bus is not asserted
w4spiend:
	rts


;+
; w4spstat - wait for status byte and message byte.
;
; Returns:
;	d0.l = returned status or timeout error
;-
w4spstat:
	WSCSI	#3,#SPSCSITCR		; status in phase
	RSCSI	#SPSCSIREI,d0		; clear potential interrupt

	bsr	w4spreq			; wait for status byte
	bmi.s	w4spend			; if timed-out, returns
gspstat:
	RSCSI	#SPSCSIDB,d0		; get the status byte
	andi.w	#$ff,d0
	move.w	d0,stat			; save the status byte
	bsr	dospack			; signal that status byte is here

.1:	bsr	w4spreq			; wait for message byte
	bmi.s	w4spend			; if timed-out, returns

	RSCSI	#SPSCSIDB,d0		; get and ignore message byte
	bsr	dospack			; signal that message byte is here
	move.w	stat,d0			; recall the status byte
w4spend:
	rts				; return


;+
; w4spdreq() - wait for REQ to come during hand shake of data bytes
; w4spreq() - wait for REQ to come during hand shake of non-data bytes
;
; Returns:
;	 0 - if successful
;	-1 - times out
;-
w4spdreq:
	TMOUT	rcaltm,d1		; add time for recalibration
	bra.s	w4req0
w4spreq:
	TMOUT	scstmout,d1		; set up timeout counter
w4req0:	move.w	#SPSCSICR,WDL
.1:	move.w	WDC,d0			; read Control Register
	btst	#5,d0			; waiting for REQ to come
	bne.s	.2			; if REQ comes, done
	CNTDN1	d1,.1			; if there is more time, keep waiting
	moveq	#-1,d0			; else, returns timed out
	bra.s	w4sprend
.2:	moveq	#0,d0			; returns successful
w4sprend:
	rts


;+
; dospack() - assert ACK
;
; Returns:
;	 0 - always successful
;-
dospack:	
	move.l	d1, -(sp)		; save the date in d1
	move.w 	#$ff, d1		; set the time out counter
	RSCSI	#SPSCSIICR,d0		; read Initiator Command Register
	ori.b	#$11,d0			; assert ACK (and data bus)
	move.w	d0,WDC
	move.w 	#SPSCSITCR, WDL	; move the target command register
							; to the DMA mode control register
w4come:
	move.w	WDC, d0			; move the DMA data register to d0
	btst	#3, d0			; waiting for REQ to come 
	bne.s	donespa			; if REQ comes, done
	dbra	d1, w4come		; else check if it is time out, if not, wait for it
							; else give up,
donespa:
	RSCSI	#SPSCSIICR,d0		; read Initiator Command Register
	andi.b	#$ef,d0			; clear ACK
	move.w	d0,WDC
	moveq	#0,d0
	move.l	(sp)+, d1		; restore the d1
	rts

