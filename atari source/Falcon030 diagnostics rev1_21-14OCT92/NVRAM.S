	.if !(^^defined NVRAM_I)
NVRAM_I = 1
* RTC Tracking Macros : RWS : 19MAY92
* 09JUL92 : RWS : no longer holds code - go look in rtc.s

	.globl	ProdTestStat

FORCEBIT	=	4	; signals a forced pass
PASSBIT		=	7	; passed if >=
NEEDBIT		=	5	; operator test needs to be done.

NVRAM0	=	14

t_ICT	=	63		; IN CIRCUIT TEST GETS THIS BYTE!!!
t_AGING	=	62
t_RAM	=	NVRAM0
t_RTC	=	NVRAM0+1
t_TIME	=	NVRAM0+2
t_ROM 	=	NVRAM0+3
;t_SERIAL =	NVRAM0+4
t_LAN	=	NVRAM0+4
t_MIDI	=	NVRAM0+5
t_SBLIT	=	NVRAM0+6
;t_LBLIT	=	NVRAM0+8
* - done by burn-in
t_PRT	=	NVRAM0+7
t_DSP	=	NVRAM0+8
t_SCSI	=	NVRAM0+9
t_FLOP	=	NVRAM0+10
t_IDE	=	NVRAM0+11
t_AUDIO	=	NVRAM0+12
t_VIDEO	=	NVRAM0+13
t_KEYBD	=	NVRAM0+14
* - Post-burn & final
t_XBUS	=	NVRAM0+15
* - initial
t_XTRA1	=	NVRAM0+16
t_XTRA2 =	NVRAM0+17
t_XTRA3 =	NVRAM0+18

t_CYCLH = 	NVRAM0+19	; used to count cycles in Burn-In
t_CYCLL = 	NVRAM0+20
t_VERNUM =	NVRAM0+21	; version number of cartrige used for preburn

t_SUITES = 	NVRAM0+24
t_VALID1 =	NVRAM0+26
t_VALID2 =	NVRAM0+27
t_VALID3 =	NVRAM0+28

t_SER1	=	NVRAM0+30
t_SER2	=	NVRAM0+31
t_SER3	=	NVRAM0+32
t_SER4	=	NVRAM0+33
t_LINENUM =	NVRAM0+34
t_REVNUM =	NVRAM0+35

; start of build time. Only if host sets at start - can go in alarm if needed

t_STARTSS =	NVRAM0+36
t_STARTMM =	NVRAM0+37
t_STARTHH =	NVRAM0+38
t_STARTDD =	NVRAM0+39
t_STARTMO =	NVRAM0+40
t_STARTYY =	NVRAM0+41	

* bit definitions for	t_SUITES

t_PREBURN	= 7
t_BURNIN	= 6
t_POSTBURN	= 5
t_INPROCESS	= 4
t_UNITASSY	= 3
t_spare2	= 2
t_spare1	= 1
t_dontuse	= 0

*------------------------------------
* Read 1 NVRAM cell
.macro	READNVRAM regi, value
	move.b	\regi,rtcadd
	nop
	move.b	rtcdat,\value
.endm
*-------------------------------
* Write 1 NVRAM cell
.macro	WRITENVRAM regi, value
	move.b	\regi,rtcadd
	nop
	move.b	\value,rtcdat
.endm
*-------------------------------
* Write Same NVRAM cell - address register not changed.
.macro	WRITESAME regi, value
	move.b	\regi,rtcadd
	nop
	move.b	\value,rtcdat
.endm

*==================================
* IsTested? equ = untested mi = passed, pl = failed
.macro	RTCISTESTED test
	move.b	\test,rtcadd
	nop
	tst.b	rtcdat
.endm

*---------------------------------
* Validate NVRAM
.macro	RTCVALIDATE
	WRITENVRAM #t_VALID1, #$42		; Magic # required for NVRAM to be valid
	WRITENVRAM #t_VALID2, #$52
	WRITENVRAM #t_VALID3, #$53
.endm

*---------------------------------
* IsValid NVRAM?
.macro ISRTCVALID
	READNVRAM #t_VALID1,d7
	cmp.b	#$42,d7
	bne	.\~exit				; leaves CC's alone
	READNVRAM #t_VALID2,d7
	cmp.b	#$52,d7
	bne	.\~exit
	READNVRAM #t_VALID3,d7
	cmp.b	#$53,d7
.\~exit:
.endm

*---------------------------------
* SetPass
.macro	RTCSETPASS test
	move.b	d0,-(sp)
	move.b	\test,d0
	bsr	RTCsetpass
	move.b	(sp)+,d0
.endm

;RTCsetpass:
;	tst.b	ProdTestStat	; if not in a prod test.
;	bmi	.dontset
;	READNVRAM d0,d7
;	bset	#PASSBIT,d7
;	bclr	#NEEDBIT,d7
;	WRITESAME d0,d7
;.dontset:
;	rts

*---------------------------------
* SetNeed - sets needed bit only
.macro	RTCSETNEED test
	READNVRAM	\test,d7
	bset	#NEEDBIT,d7
	WRITESAME \test,d7
.endm

*---------------------------------
* Set forced - NOTE DOESN'T CHECK PROD TEST STAT

.macro	RTCFORCEPASS test
	READNVRAM	\test,d7
	bset	#FORCEBIT,d7
	bclr	#NEEDBIT,d7
	WRITESAME \test,d7
.endm
*---------------------------------
* ClearPass
.macro	RTCCLEARPASS test
	move.b	d0,-(sp)
	move.b	\test,d0
	bsr	RTCclearpass
	move.b	(sp)+,d0
.endm

;RTCclearpass:
;	tst.b	ProdTestStat
;	bmi	.dontset
;	READNVRAM d0,d7
;	bclr	#PASSBIT,d7
;	bclr	#FORCEBIT,d7
;	bset	#NEEDBIT,d7
;	WRITESAME d0,d7
;.dontset:
;	rts

*---------------------------------
* SetFail
.macro	RTCSETFAIL test
	move.b	d0,-(sp)
	move.b	\test,d0
	bsr	RTCsetfail
	move.b	(sp)+,d0
.endm

;RTCsetfail:
;	tst.b	ProdTestStat	; if not in a prod test
;	bmi	.dontset
;	READNVRAM d0,d7
;	andi.b	#$0f,d7		; fix these if more F bits
;	cmp.w	#$f,d7
;	beq	.bypass
;	add.b	#1,d7
;.bypass:
;	bset	#NEEDBIT,d7
;	WRITESAME d0,d7
;.dontset:
;	rts
*---------------------------------
* CLEARBURNCYCLES
.macro	CLEARBURNCYCLES
	WRITENVRAM #t_CYCLH,#$00
	WRITENVRAM #t_CYCLL,#$01
.endm
*---------------------------------
* ADDBURNCYCLE
.macro ADDBURNCYCLE regi
	READNVRAM #t_CYCLH,\regi
	rol.w	#8,\regi
	READNVRAM #t_CYCLL,\regi
	add.w	#1,\regi
	WRITENVRAM #t_CYCLL,\regi
	ror.w	#8,\regi
	WRITENVRAM #t_CYCLH,\regi
.endm
*---------------------------------
* GETBURNCYCLE
.macro GETBURNCYCLE regi
	READNVRAM #t_CYCLH,\regi
	rol.w	#8,\regi
	READNVRAM #t_CYCLL,\regi
.endm
*---------------------------------
* SuiteStat - equ = not all passed
.macro RTCSUITESTAT suite
	READNVRAM #t_SUITES,d7
	btst	\suite,d7
.endm
*---------------------------------
* SetPassedAll
.macro RTCSETSUITEPASS suite
	READNVRAM #t_SUITES,d7
	bset	\suite,d7
	WRITESAME #t_SUITES,d7
.endm 
*---------------------------------
* SetFailedAll
.macro RTCSETSUITEFAIL suite
	READNVRAM #t_SUITES,d7
	bclr	\suite,d7
	WRITESAME #t_SUITES,d7
.endm 

*--------------------------------
* IsOpBold ? does an operator test need to be done?
.macro RTCISNEEDED optest
	tst.b	NoOps
	beq	.\~
	READNVRAM \optest,d7
	btst	#NEEDBIT,d7
.\~:
.endm

*--------------------------------
* ANYOPTESTSNEEDED - adds all need bits of op tests together
* eq = ok to go on
.macro	ANYOPTESTSNEEDED
;	move.b	d6,-(sp)	; NOW! THIS KILLS d6 too
	bsr	AnyOpNeed
;	move.b	(sp)+,d6
.endm
;AnyOpNeed:
;	READNVRAM #t_FLOP,d7
;	andi.b	#NEEDBIT,d7
;	READNVRAM #t_AUDIO,d6
;	andi.b	#NEEDBIT,d6
;	add.b	d6,d7
;	READNVRAM #t_VIDEO,d6
;	andi.b	#NEEDBIT,d6
;	add.b	d6,d7
;	READNVRAM #t_KEYBD,d6
;	andi.b	#NEEDBIT,d6
;	add.b	d6,d7
;	tst.b	d7
;	rts

*-----------
* GetSN
* SetSN
	.endif

