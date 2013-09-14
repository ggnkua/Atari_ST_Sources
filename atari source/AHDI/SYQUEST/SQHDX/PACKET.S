* ---------------- Low-level driver ----------------
*----- Hardware:
dmactlr		equ	$ffff8604	; address of DMA controller
wdc		equ	$0		; DMA controller port
wdl		equ	$2		; DMA controller
wdcwdl		equ	wdc		; used for long writes

dmahi		equ	$ffff8609	; DMA address - high byte
dmamid		equ	dmahi+2		; 	      - middle byte
dmalow		equ	dmamid+2	;	      - low byte

gpip		equ	$fffffa01


*----- Tunable:
ltimeout	equ	450000		; long-timeout (3 S)
stimeout	equ	15000		; short-timeout (100 mS)

SIXBYTE		equ	4		; length of command - 2
cmdwdl:		dc.w	0		; wdl value for sending command byte
datawdl:	dc.w	0		; wdl value for sending data byte
ctrlwdl:	dc.w	0		; wdl value for sending control byte
cmdblk:		dcb.b	6,0		; command block
ncmd:		dc.b	0		; flag for continous command
.even

*+
* _docmd() - send a given packet to the controller and wait till command
*	     is completed
*	   - there is a 2nd entry point at _scmd if NO DMA is involved
* 
* Synopsis:	WORD _docmd(buf_addr)	/* Entry point for command with DMA */
* 		LONG buf_addr;		4(sp).l
*
*		WORD _scmd()		/* Entry point for command w/o DMA */
*
* Assumed:	d1.w = command block length - 2
*		d2.l - if MSB set = writing to DMA
*		       if MSB not set = reading from DMA
*		     - d2.w = # sectors of DMA involved
*
*-
	.globl	_docmd
	.globl	_shdc
	.globl	_shdc1
_docmd:	st	flock			; lock FIFO (DMA channel)
	move.b	7(sp),dmalow		; else set DMA to point to
	move.b	6(sp),dmamid		;      buffer for transfer
	move.b	5(sp),dmahi
	movea.l	#dmactlr,a0		; a0 = address of DMA controller
	
	moveq	#31,d0			; d0 = bit number to be tested
	bclr.l	d0,d2			; reading from DMA?
	beq	rdma			; if so, go set DMA to read state
					; direction of data flow: ST -> DMA
	move.w	#$188,cmdwdl		; wdl for command byte = $188
	move.w	#$18a,datawdl		; wdl for data byte = $18a
	move.w	#$100,ctrlwdl		; wdl for control byte = $100
	move.w	#$90,wdl(a0)		; reset DMA controller
	move.w	#$190,wdl(a0)		;     and leave in write state
	move.w	d2,wdc(a0)		; # of 512 bytes sectors
	move.w	#$18a,wdl(a0)		; point back to parameter port
	bra	_shdc1			; go on to send command block
					; direction of data flow: DMA -> ST
rdma:	move.w	#$88,cmdwdl		; wdl for command byte = $88
	move.w	#$8a,datawdl		; wdl for data byte = $8a
	move.w	#$00,ctrlwdl		; wdl for control byte = $00
	move.w	#$190,wdl(a0)		; reset DMA controller
	move.w	#$90,wdl(a0)		;     and leave in read state
	move.w	d2,wdc(a0)		; # of 512 bytes sectors
	move.w	#$8a,wdl(a0)		; point back to parameter port
	bra	_shdc1			; go on to send command block

_shdc:	st	flock			; lock FIFO (DMA channel)
	move.w	#$88,cmdwdl		; wdl for command byte = $88
	move.w	#$8a,datawdl		; wdl for data byte = $8a
	move.w	#$8a,ctrlwdl		; wdl for control byte = $8a
	movea.l	#dmactlr,a0		; a0 = address of DMA controller

_shdc1:	lea	cmdblk,a1		; a1 = ptr to command block
	move.w	cmdwdl,wdl(a0)		; sending a command
	clr.w	d0			; clear d0
	move.w	#SIXBYTE,d1		; length of command 
shdc2:	move.b	(a1)+,d0		; d0.b = command byte to be sent
	swap	d0			; hi word of d0.l = command byte
	move.w	datawdl,d0		; d0.w = next byte will be an operand
	move.l	d0,wdcwdl(a0)		; write command to DMA
	bsr	_qdone			; wait a little while
	bmi	dcmd			; if timeout, done with timeout error
	dbra	d1,shdc2		; do until all command bytes are sent
					; now send the control byte
	move.b	(a1),d0			; last byte from command byte
	swap	d0			; hi word of d0.l = command byte
	move.w	ctrlwdl,d0		; d0.w = wdl value for contro byte
	move.l	d0,wdcwdl(a0)		; write to controller
					; wait for command completion
	bsr	_fdone			; wait for operation complete
dlcmd:	move.l	_hz_200,d1		; delay 2 ticks for completion byte
	addq.l	#2,d1
wait:	cmp.l	_hz_200,d1		
	bcc	wait
	tst.w	d0			; was it successful?
	bmi	dcmd			; if timed out, return

	move.w	datawdl,wdl(a0)		; else point back to parameter port
	move.w	wdc(a0),d0		; get the result
	andi.w	#$00ff,d0		; (clean it up), if non-zero should
					; do a ReadSense command to learn more
	bne	dcmd			; if not successful, return

	tst.b	ncmd			; else, another command right after?
	beq	dcmd			; if not, return normally
	tst.w	d0
	rts				; else, return now

dcmd:	move.w	#$80,wdl(a0)		; Landon's code seems to presume we
	nop				;  put this back to $80
	clr	flock			; NOW, signal that we are done
	tst.w	d0			; set condition code to reveal result
	rts



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



*-
* clrcmdblk()
*
* Clear the command block for the driver call
*+
clrcmdblk:
	lea	cmdblk,a0		; a0 = ptr to command block
	move.l	#0,(a0)+
	move.w	#0,(a0)
	rts



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
READ	equ	$8
	.globl	_hread
_hread:	bsr	clrcmdblk		; clear the command block
	lea	cmdblk,a0		; a0 = ptr to command block
	move.w	$e(sp),d0		; get unit number
	lsl.b	#5,d0			; shift it into place
	ori.b	#READ,d0		; dev# + READ command
	move.b	d0,(a0)+		; 1st command byte = dev# + READ
	move.b	$5(sp),(a0)+		; MSB sector#
	move.b	$6(sp),(a0)+		; MidSB sector#
	move.b	$7(sp),(a0)+		; LSB sector#
	move.b	$9(sp),(a0)+		; transfer length (in sectors)
	moveq	#0,d2			; clear d2.l
	move.w	$8(sp),d2		; # sectors to read
	sf	ncmd
	move.l	$a(sp),-(sp)		; buffer to transfer data to
	bsr	_docmd			; just do it
	addq	#4,sp			; cleanup stack
	rts


*-
* _hwrite(sectno, count, buf, dev)
* LONG sectno;		 4(sp)
* WORD count;		 8(sp)
* LONG buf;		$a(sp)	$b=high, $c=mid, $d=low
* WORD dev;		$e(sp)
*
*-
WRITE	equ	$a
	.globl	_hwrite
_hwrite:
	bsr	clrcmdblk		; clear the command block
	lea	cmdblk,a0		; a0 = ptr to command block
	move.w	$e(sp),d0		; get unit number
	lsl.b	#5,d0			; shift it into place
	ori.b	#WRITE,d0		; dev# + WRITE command
	move.b	d0,(a0)+		; 1st command block = dev# + WRITE
	move.b	$5(sp),(a0)+		; MSB sector#
	move.b	$6(sp),(a0)+		; MidSB sector#
	move.b	$7(sp),(a0)+		; LSB sector#
	move.b	$9(sp),(a0)+		; transfer length (in sectors)
	move.w	#31,d1			; bit # to be set
	moveq	#0,d2			; clear d2.l
	bset.l	d1,d2			; set direction bit: ST -> DMA
	move.w	$8(sp),d2		; # sectors to write
	sf	ncmd
	move.l	$a(sp),-(sp)		; buffer to transfer data to
	bsr	_docmd			; just do it
	addq	#4,sp			; cleanup stack
	rts



*+
*  _inquiry - get device-specific parameters
*
*    Synopsis:	LONG _inquiry(physunit#, parms)
*		WORD physunit#;			4(sp).W
*		char *parms;			6(sp).L
*
*-
INQUIRE	equ	$12
	.globl	_inquiry
_inquiry:
	bsr	clrcmdblk		; clear the command block
	lea	cmdblk,a0		; a0 = ptr to command block
	move.w	4(sp),d0		; d0 = physical unit #
	lsl.b	#5,d0			; shift it into place
	ori.b	#INQUIRE,d0		; physunit# + Inquiry command
	move.b	d0,(a0)			; byte 0 = dev# + opcode
	move.b	#$10,4(a0)		; byte 4 = allocation length
	moveq	#1,d2			; 1 sector of dma
	move.l	6(sp),-(sp)		; -> parameter block address
	bsr	_docmd			; just do it
	addq	#4,sp			; cleanup stack
	rts



*+
*  _rq_sense - get sense data from target
*
*    Synopsis:	LONG _rq_sense(physunit#, data)
*		WORD physunit#;			4(sp).W
*		char data[];			6(sp).L
*
*-
RQSENSE	equ	$3
	.globl	_rq_sense
_rq_sense:
	bsr	clrcmdblk		; clear the command block
	lea	cmdblk,a0		; a0 = ptr to command block
	move.w	4(sp),d0		; d0 = (physunit# << 5) << 16
	lsl.b	#5,d0			; shift it into place
	ori.b	#RQSENSE,d0		; physunit# + Request Sense command
	move.b	d0,(a0)			; byte 0 = dev# + opcode
	moveq	#1,d2			; 1 sector of dma
	move.w	d3,-(sp)		; save d3
	st	ncmd			; don't clear flock when return
	move.l	8(sp),-(sp)		; -> parameter block address
	bsr	_docmd			; just do it
	addq	#4,sp			; cleanup stack
	bne	rqsr			; if unsuccessful, return
	move.w	#1,d3			; do the command 2 more times
loop2x:	bsr	_shdc1
	bne	rqsr
	dbra	d3,loop2x
	sf	ncmd			; clear flock when return
	bsr	_shdc1
rqsr:	move.w	(sp)+,d3		; restore d3
	sf	ncmd			; reset flag
	rts



*+
*  testunit - Test Unit Ready
*
*    Synopsis:	LONG testunit(dev)
*		WORD dev;		4(sp).W
*
*-
TSTUNIT	equ	$3
	.globl	testunit
testunit:
	bsr	clrcmdblk		; clear the command block
	lea	cmdblk,a0		; a0 = ptr to command block
	move.w	4(sp),d0		; d0 = (physunit# << 5) << 16
	lsl.b	#5,d0			; shift it into place
	ori.b	#TSTUNIT,d0		; physunit# + Test Unit command
	move.b	d0,(a0)			; byte 0 = dev# + opcode
	sf	ncmd
	bsr	_shdc			; just do it
	rts





