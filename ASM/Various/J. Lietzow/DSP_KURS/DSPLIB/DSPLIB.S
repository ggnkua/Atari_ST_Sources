;
;
;		Header for DSP-XBIOS-Library (rev. 3 and rev. 4)
;
;		Sound- and DSP-IO functions
;
;		with Turbo/Pure C parameter passing (d0-d2/a0-a1)
;
;		Last update: 28.09.93			by J. Lietzow
;

	.EXPORT	IsDspDrv			;+
	.EXPORT	Dsp_DoBlock,Dsp_BlkHandshake,Dsp_BlkUnpacked
	.EXPORT	Dsp_InStream,Dsp_OutStream,Dsp_IOStream
	.EXPORT	Dsp_RemoveInterrupts,Dsp_GetWordSize
	.EXPORT Dsp_Lock,Dsp_Unlock,_dsp_locked
	.EXPORT	Dsp_Available,Dsp_Reserve,Dsp_LoadProg,Dsp_ExecProg,Dsp_ExecBoot
	.EXPORT	Dsp_LodToBinary,Dsp_TriggerHC,Dsp_RequestUniqueAbility
	.EXPORT	Dsp_GetProgAbility,Dsp_FlushSubroutines,Dsp_LoadSubroutine
	.EXPORT	Dsp_InqSubrAbility,Dsp_RunSubroutine
	.EXPORT	Dsp_Hf0,Dsp_Hf1,Dsp_Hf2,Dsp_Hf3
	.EXPORT	Dsp_BlkWords,Dsp_BlkBytes,Dsp_HStat
	.EXPORT	Dsp_OutStat,Dsp_InStat
	.EXPORT Dsp_SetVectors, Dsp_MultBlock ; ???

DOBLOCK					equ		0
BLKHANDSHAKE			equ		1
BLKUNPACKED				equ		2
INSTREAM				equ		3
OUTSTREAM				equ		4
IOSTREAM				equ		5
REMOVEINTERRUPTS		equ		6
GETWORDSIZE				equ		7
LOCK					equ		8
UNLOCK					equ		9
AVAILABLE				equ		10
RESERVE					equ		11
LOADPROG				equ		12
EXECPROG				equ		13
EXECBOOT				equ		14
LODTOBINARY				equ		15
TRIGGERHC				equ		16
REQUESTUNIQUEABILITY	equ		17
GETPROGABILITY			equ		18
FLUSHSUBROUTINES		equ		19
LOADSUBROUTINE			equ		20
INQSUBRABILITY			equ		21
RUNSUBROUTINE			equ		22
HF0						equ		23
HF1						equ		24
HF2						equ		25
HF3						equ		26
BLKWORDS				equ		27
BLKBYTES				equ		28
HSTAT					equ		29
SETVECTORS				equ		30
MULTBLOCK				equ		31

; sound functions 

LOCKSND					equ		32
UNLOCKSND				equ		33
SOUNDCMD				equ		34
SETBUFFER				equ		35
SETSNDMODE				equ		36
SETTRACK				equ		37
SETMONTRACK				equ		38
SETINTERRUPT			equ		39
BUFFOPER				equ		40
DSPTRISTATE				equ		41
GPIO					equ		42
DEVCONNECT				equ		43
SNDSTATUS				equ		44
BUFFPTR					equ		45

MACRO	CALLDRVR num
	move.w	#(96+num),-(sp)
	trap	#14
ENDM

	.TEXT


MODULE	drvr_start:

		ds.w	1

ENDMOD

MODULE	IsDspDrv:

		bsr			Dsp_GetWordSize
		cmp.w		#96+GETWORDSIZE,d0
		bne.s		ok
		moveq		#0,d0
ok:		rts

ENDMOD


MODULE	Dsp_DoBlock:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		a1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	DOBLOCK
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_BlkHandshake:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		a1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	BLKHANDSHAKE
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_BlkUnpacked:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		a1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	BLKUNPACKED
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_InStream:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	INSTREAM
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_OutStream:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	OUTSTREAM
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_IOStream:

		move.l		a2,-(sp)
		move.l		8(sp),-(sp)
		move.l		d2,-(sp)
		move.l		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	IOSTREAM
		lea			26(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_RemoveInterrupts:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	REMOVEINTERRUPTS
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_GetWordSize:

		move.l		a2,-(sp)
		CALLDRVR	GETWORDSIZE
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD


MODULE	Dsp_Lock:

		move.l		a2,-(sp)
		CALLDRVR	LOCK
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Unlock:

		move.l		a2,-(sp)
		CALLDRVR	UNLOCK
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Available:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	AVAILABLE
		lea			10(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Reserve:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		d0,-(sp)
		CALLDRVR	RESERVE
		lea			10(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_LoadProg:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.w		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	LOADPROG
		lea			12(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_ExecProg:

		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	EXECPROG
		lea			12(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_ExecBoot:

		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	EXECBOOT
		lea			12(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_LodToBinary:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	LODTOBINARY
		lea			10(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_TriggerHC:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	TRIGGERHC
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_RequestUniqueAbility:

		move.l		a2,-(sp)
		CALLDRVR	REQUESTUNIQUEABILITY
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_GetProgAbility:

		move.l		a2,-(sp)
		CALLDRVR	GETPROGABILITY
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_FlushSubroutines:

		move.l		a2,-(sp)
		CALLDRVR	FLUSHSUBROUTINES
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_LoadSubroutine:

		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	LOADSUBROUTINE
		lea			12(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_InqSubrAbility:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	INQSUBRABILITY
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_RunSubroutine:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	RUNSUBROUTINE
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Hf0:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	HF0
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Hf1:

		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	HF1
		addq.w		#4,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Hf2:

		move.l		a2,-(sp)
		CALLDRVR	HF2
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_Hf3:

		move.l		a2,-(sp)
		CALLDRVR	HF3
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_BlkWords:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		a1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	BLKWORDS
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_BlkBytes:

		move.l		a2,-(sp)
		move.l		d1,-(sp)
		move.l		a1,-(sp)
		move.l		d0,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	BLKBYTES
		lea			18(sp),sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_HStat:

		move.l		a2,-(sp)
		CALLDRVR	HSTAT
		addq.w		#2,sp
		move.l		(sp)+,a2
		rts

ENDMOD

MODULE	Dsp_OutStat:

		bsr			Dsp_HStat
		lsr.w		#1,d0
		subx.w		d1,d1
		neg.w		d1
		lsr.w		#1,d0
		and.w		#6,d0
		or.w		d1,d0
		rts

ENDMOD

MODULE	Dsp_InStat:

		bsr			Dsp_HStat
		lsr.w		#2,d0
		subx.w		d1,d1
		neg.w		d1
		and.w		#6,d0
		or.w		d1,d0
		rts

ENDMOD

MODULE	Dsp_SetVectors:

		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	SETVECTORS
		lea.l		10(sp),sp
		move.l		(sp)+,a2
		rts
	
ENDMOD

MODULE	Dsp_MultBlock:
	
		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		move.l		d1,-(sp)
		move.l		d0,-(sp)
		CALLDRVR	MULTBLOCK
		lea.l		16(sp),sp
		move.l		(sp)+,a2
		rts		

ENDMOD

;;;;;;;;;;;  DSP sound functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.EXPORT	locksnd, unlocksnd, soundcmd, setbuffer, setsndmode
	.EXPORT settrack, setmontrack, setinterrupt, buffoper, dsptristate
	.EXPORT gpio, devconnect, sndstatus, buffptr
	

MODULE	locksnd:
		move.l		a2,-(sp)
		CALLDRVR	LOCKSND
		addq.l		#2,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	unlocksnd:
		move.l		a2,-(sp)
		CALLDRVR	UNLOCKSND
		addq.l		#2,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	soundcmd:
		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SOUNDCMD
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	setbuffer:
		move.l		a2,-(sp)
		move.l		a1,-(sp)
		move.l		a0,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SETBUFFER
		lea.l		12(sp),sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	setsndmode:
		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SETSNDMODE
		addq.l		#4,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	settrack:
		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SETTRACK
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	setmontrack:
		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SETMONTRACK
		addq.l		#4,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	setinterrupt:
		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SETINTERRUPT
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	buffoper:
		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	BUFFOPER
		addq.l		#4,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	dsptristate:
		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	DSPTRISTATE
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	gpio:
		move.l		a2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	GPIO
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	devconnect:
		move.l		a2,-(sp)
		move.l		8(sp),-(sp)
		move.w		d2,-(sp)
		move.w		d1,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	DEVCONNECT
		lea.l		12(sp),sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	sndstatus:
		move.l		a2,-(sp)
		move.w		d0,-(sp)
		CALLDRVR	SNDSTATUS
		addq.l		#4,sp
		move.l		(sp)+,a2
		rts
ENDMOD


MODULE	buffptr:
		move.l		a2,-(sp)
		move.l		a0,-(sp)
		CALLDRVR	BUFFPTR
		addq.l		#6,sp
		move.l		(sp)+,a2
		rts
ENDMOD


	.END
