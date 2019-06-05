;
;		Header for DSP-XBIOS-Library
;
;		Sound- and DSP-IO functions for Lattice C
;		Version 5.52 and lower.  By P. Hills
;		 

		CSECT	text
		XDEF	IsDspDrv
		XDEF	_Dsp_DoBlock,_Dsp_BlkHandshake,_Dsp_BlkUnpacked
		XDEF	_Dsp_InStream,_Dsp_OutStream,_Dsp_IOStream
		XDEF	_Dsp_RemoveInterrupts,_Dsp_GetWordSize
		XDEF 	_Dsp_Lock,_Dsp_Unlock
		XDEF	_Dsp_Available,_Dsp_Reserve,_Dsp_LoadProg,_Dsp_ExecProg,_Dsp_ExecBoot
		XDEF	_Dsp_LodToBinary,_Dsp_TriggerHC,_Dsp_RequestUniqueAbility
		XDEF	_Dsp_GetProgAbility,_Dsp_FlushSubroutines,_Dsp_LoadSubroutine
		XDEF	_Dsp_InqSubrAbility,_Dsp_RunSubroutine
		XDEF	_Dsp_Hf0,_Dsp_Hf1,_Dsp_Hf2,_Dsp_Hf3
		XDEF	_Dsp_BlkWords,_Dsp_BlkBytes,_Dsp_HStat
		XDEF	_Dsp_OutStat,_Dsp_InStat
		XDEF 	_Dsp_SetVectors,_Dsp_MultBlock

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

;This temporary address stores the return address to get back to 'C'.
RetAddr	dc.l	1

;  This is the macro xbios call section
		MACRO
		XBios	num
		move.l	(sp)+,temp			;Remember the return address.
		move.w	#(96+num),-(sp)		;Push function number on stack.
		trap	#14					;Call XBIOS function.
		addq.w	#2,sp				;Remove function number from stack.
		move.l	temp,-(sp)			;Restore return address to stack.
		rts							;Return to 'C'.
		ENDM

; This routine checks that the function calls are available.
IsDspDrv
		bsr			_Dsp_GetWordSize	;Use GetWordSize as test function.
		cmp.w		#96+GETWORDSIZE,d0	;See if d0 has been set.
		bne.s		ok					;If it has, all is fine,
		moveq		#0,d0				;Else function not available.
ok		rts


_Dsp_DoBlock
		XBios		DOBLOCK

_Dsp_BlkHandshake
		XBios		BLKHANDSHAKE

_Dsp_BlkUnpacked
		XBios		BLKUNPACKED

_Dsp_InStream
		XBios		INSTREAM

_Dsp_OutStream
		XBios		OUTSTREAM
		
_Dsp_IOStream
		XBios		IOSTREAM

_Dsp_RemoveInterrupts
		XBios		REMOVEINTERRUPTS

_Dsp_GetWordSize
		XBios		GETWORDSIZE

_Dsp_Lock
		XBios		LOCK

_Dsp_Unlock
		XBios		UNLOCK

_Dsp_Available
		XBios		AVAILABLE

_Dsp_Reserve
		XBios		RESERVE

_Dsp_LoadProg
		XBios		LOADPROG

_Dsp_ExecProg
		XBios		EXECPROG

_Dsp_ExecBoot
		XBios		EXECBOOT

_Dsp_LodToBinary
		XBios		LODTOBINARY

_Dsp_TriggerHC
		XBios		TRIGGERHC

_Dsp_RequestUniqueAbility
		XBios		REQUESTUNIQUEABILITY

_Dsp_GetProgAbility
		XBios		GETPROGABILITY

_Dsp_FlushSubroutines
		XBios		FLUSHSUBROUTINES

_Dsp_LoadSubroutine
		XBios		LOADSUBROUTINE

_Dsp_InqSubrAbility
		XBios		INQSUBRABILITY

_Dsp_RunSubroutine
		XBios		RUNSUBROUTINE

_Dsp_Hf0
		XBios		HF0

_Dsp_Hf1
		XBios		HF1

_Dsp_Hf2
		XBios		HF2	

_Dsp_Hf3
		XBios		HF3	

_Dsp_BlkWords
		XBios		BLKWORDS

_Dsp_BlkBytes
		XBios		BLKBYTES

_Dsp_HStat
		XBios		HSTAT

_Dsp_OutStat
		bsr			_Dsp_HStat
		rts

_Dsp_InStat
		bsr			_Dsp_HStat
		rts

_Dsp_SetVectors	
		XBios		SETVECTORS

_Dsp_MultBlock
		XBios		MULTBLOCK

;;;;;;;;;;;  DSP sound functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	XDEF	_Locksnd,_Unlocksnd,_Soundcmd,_Setbuffer,_Setsndmode
	XDEF	_Settrack,_Setmontrack,_Setinterrupt,_Buffoper,_Dsptristate
	XDEF	_Gpio,_Devconnect,_Sndstatus,_Buffptr
	

_Locksnd
		XBios		LOCKSND

_Unlocksnd
		XBios		UNLOCKSND

_Soundcmd
		XBios		SOUNDCMD

_Setbuffer
		XBios		SETBUFFER

_Setsndmode
		XBios		SETSNDMODE

_Settrack
		XBios		SETTRACK

_Setmontrack
		XBios		SETMONTRACK

_Setinterrupt
		XBios		SETINTERRUPT

_Buffoper
		XBios		BUFFOPER

_Dsptristate
		XBios		DSPTRISTATE

_Gpio
		XBios		GPIO

_Devconnect
		XBios		DEVCONNECT

_Sndstatus
		XBios		SNDSTATUS

_Buffptr
		XBios		BUFFPTR

		END
