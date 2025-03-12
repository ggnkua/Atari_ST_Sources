IsDspDrv:
	move.w	#500,drvr_start		;rev 1-2
	bsr		DspGetWordSize
	cmp.w		#500+GETWORDSIZE,d0
	bne.s		.ok
	move.w	#96,drvr_start		;rev 3-4
	bsr		DspGetWordSize
	cmp.w		#96+GETWORDSIZE,d0
	bne.s		.ok
.no:	moveq		#0,d0
.ok:	rts

drvr_start:		ds.w	1

DspFlushSubroutines:
	move.l	a2,-(sp)
	CALLDRVR	#FLUSHSUBROUTINES
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspRemoveInterrupts:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#REMOVEINTERRUPTS
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspAvailable:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#AVAILABLE
	lea		10(sp),sp
	move.l	(sp)+,a2
	rts

DspReserve:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	CALLDRVR	#RESERVE
	lea		10(sp),sp
	move.l	(sp)+,a2
	rts

DspExecProg:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#EXECPROG
	lea		12(sp),sp
	move.l	(sp)+,a2
	rts

DspBlkWords:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BLKWORDS
	lea		18(sp),sp
	move.l	(sp)+,a2
	rts

DspGetWordSize:
	move.l	a2,-(sp)
	CALLDRVR	#GETWORDSIZE
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts
