	.EXPORT	IsDspDrv			;+
	.EXPORT	DspDoBlock,DspBlkHandShake,DspBlkUnpacked
	.EXPORT	DspInStream,Dsp_OutStream,DspIOStream
	.EXPORT	DspRemoveInterrupts,DspGetWordSize,DspLock,DspUnlock
	.EXPORT	DspAvailable,DspReserve,DspLoadProg,DspExecProg,DspExecBoot
	.EXPORT	DspLodToBinary,DspTriggerHC,DspRequestUniqueAbility
	.EXPORT	DspGetProgAbility,DspFlushSubroutines,DspLoadSubroutine
	.EXPORT	DspInqSubrAbility,DspRunSubroutine
	.EXPORT	DspHf0,DspHf1,DspHf2,DspHf3
	.EXPORT	DspBlkWords,DspBlkBytes,DspHStat
	.EXPORT	DspOutStat,DspInStat


DOBLOCK	equ	0
BLKHANDSHAKE	equ	1
BLKUNPACKED	equ	2
INSTREAM	equ	3
OUTSTREAM	equ	4
IOSTREAM	equ	5
REMOVEINTERRUPTS	equ	6
GETWORDSIZE	equ	7
LOCK	equ	8
UNLOCK	equ	9
AVAILABLE	equ	10
RESERVE	equ	11
LOADPROG	equ	12
EXECPROG	equ	13
EXECBOOT	equ	14
LODTOBINARY	equ	15
TRIGGERHC	equ	16
REQUESTUNIQUEABILITY	equ	17
GETPROGABILITY	equ	18
FLUSHSUBROUTINES	equ	19
LOADSUBROUTINE	equ	20
INQSUBRABILITY	equ	21
RUNSUBROUTINE	equ	22
HF0	equ	23
HF1	equ	24
HF2	equ	25
HF3	equ	26
BLKWORDS	equ	27
BLKBYTES	equ	28
HSTAT	equ	29
SETVECTOR	equ	30
 
    MACRO   CALLDRVR	opcode
	moveq	opcode,d0
	add.w	drvr_start(pc),d0
	move.w	d0,-(sp)
	trap	#14
	ENDM

	TEXT

IsDspDrv:
	move.w	#500,drvr_start		;rev 1-2
	bsr	DspGetWordSize
	cmp.w	#500+GETWORDSIZE,d0
	bne 	ok
	move.w	#96,drvr_start		;rev 3-4
	bsr	DspGetWordSize
	cmp.w	#96+GETWORDSIZE,d0
	bne 	ok
no:	moveq	#0,d0
ok:	rts

drvr_start:	ds.w	1

DspDoBlock:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#DOBLOCK
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspBlkHandShake:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BLKHANDSHAKE
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspBlkUnpacked:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BLKUNPACKED
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspInStream:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#INSTREAM
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

Dsp_OutStream:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#OUTSTREAM
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspIOStream:
	move.l	a2,-(sp)
	move.l	8(sp),-(sp)
	move.l	d2,-(sp)
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#IOSTREAM
	lea	26(sp),sp
	move.l	(sp)+,a2
	rts

DspRemoveInterrupts:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#REMOVEINTERRUPTS
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspGetWordSize:
	move.l	a2,-(sp)
	CALLDRVR	#GETWORDSIZE
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspLock:
	move.l	a2,-(sp)
	CALLDRVR	#LOCK
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspUnlock:
	move.l	a2,-(sp)
	CALLDRVR	#UNLOCK
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspAvailable:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#AVAILABLE
	lea	10(sp),sp
	move.l	(sp)+,a2
	rts

DspReserve:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#RESERVE
	addq.w	#6,sp
	move.l	(sp)+,a2
	rts

DspLoadProg:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#LOADPROG
	addq.w	#8,sp
	move.l	(sp)+,a2
	rts

DspExecProg:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#EXECPROG
	lea	12(sp),sp
	move.l	(sp)+,a2
	rts

DspExecBoot:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#EXECBOOT
	lea	12(sp),sp
	move.l	(sp)+,a2
	rts

DspLodToBinary:
	move.l	a2,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#LODTOBINARY
	lea	10(sp),sp
	move.l	(sp)+,a2
	rts

DspTriggerHC:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#TRIGGERHC
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspRequestUniqueAbility:
	move.l	a2,-(sp)
	CALLDRVR	#REQUESTUNIQUEABILITY
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspGetProgAbility:
	move.l	a2,-(sp)
	CALLDRVR	#GETPROGABILITY
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspFlushSubroutines:
	move.l	a2,-(sp)
	CALLDRVR	#FLUSHSUBROUTINES
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspLoadSubroutine:
	move.l	a2,-(sp)
	move.w	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#LOADSUBROUTINE
	lea	12(sp),sp
	move.l	(sp)+,a2
	rts

DspInqSubrAbility:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#INQSUBRABILITY
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspRunSubroutine:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#RUNSUBROUTINE
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspHf0:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#HF0
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspHf1:
	move.l	a2,-(sp)
	move.w	d0,-(sp)
	CALLDRVR	#HF1
	addq.w	#4,sp
	move.l	(sp)+,a2
	rts

DspHf2:
	move.l	a2,-(sp)
	CALLDRVR	#HF2
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspHf3:
	move.l	a2,-(sp)
	CALLDRVR	#HF3
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspBlkWords:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BLKWORDS
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspBlkBytes:
	move.l	a2,-(sp)
	move.l	d1,-(sp)
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	CALLDRVR	#BLKBYTES
	lea	18(sp),sp
	move.l	(sp)+,a2
	rts

DspHStat:
	move.l	a2,-(sp)
	CALLDRVR	#HSTAT
	addq.w	#2,sp
	move.l	(sp)+,a2
	rts

DspOutStat:
	bsr	DspHStat
	lsr.w	#1,d0
	subx.w	d1,d1
	neg.w	d1
	lsr.w	#1,d0
	and.w	#6,d0
	or.w	d1,d0
	rts

DspInStat:
	bsr	DspHStat
	lsr.w	#2,d0
	subx.w	d1,d1
	neg.w	d1
	and.w	#6,d0
	or.w	d1,d0
	rts

	END
