*+
*  _rq_sense - get sense data from target
*
*    Synopsis:	LONG _rq_sense(physunit#, data)
*		WORD physunit#;			4(sp).W
*		char data[];			6(sp).L
*
*-
	.globl	_rq_sense
_rq_sense:
	st	flock			; lock FIFO
	move.l	6(sp),-(sp)		; -> sense data buffer address
	bsr	_setdma			; set DMA there
	addq.l	#4,sp

 	move.w	#$190,wdl		; reset the DMA chip
	nop
	move.w	#$90,wdl
	nop
	move.w	#$01,wdc		; 1 sector of DMA (actually less)
	nop

	move.w	#$88,wdl
	move.w	4(sp),d0		; d0 = (dev << 5) << 16
	lsl.b	#5,d0
	swap	d0			; in upper word
	or.l	#$0003008a,d0		; write dev#+Request Sense+FIFO bits
	move.l	d0,wdcwdl		; rqsense+dev wdc 8a wdl (byte 0)
	bsr	_qdone
	bmi	wdq1

	move.l	#$0000008a,wdcwdl	; byte 1
	bsr	_qdone
	bmi	wdq1

	move.l	#$0000008a,wdcwdl	; byte 2
	bsr	_qdone
	bmi	wdq1

	move.l	#$0000008a,wdcwdl	; byte 3
	bsr	_qdone
	bmi	wdq1

	move.l	#$0010008a,wdcwdl	; byte 4; return 16 bytes of data
	bsr	_qdone
	bmi	wdq1

	move.w	#$8a,wdl
	nop
	move.l	#0,wdcwdl		; byte 5 (control byte)
	move.w	#$8a,d0			; wdl value
	bsr	_endcmd			; wait for command completion
wdq1:	bra	_hdone

