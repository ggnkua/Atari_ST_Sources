;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	AUTOINIT.S									;;
;;																		;;
;;																		;;
;;		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	27.04.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		.IMPORT	Start0
		.IMPORT	ResetSpooler
				
		.EXPORT __text, __data, __bss
		.EXPORT sys
		.EXPORT _BasPag, _PgmSize
		.EXPORT XBcostat0, XBconout0
		.INCLUDE	"..\transfer.inc"

		.BSS

__bss:

;	Pointer to base page

_BasPag:
		ds.l	1

;	Program size

_PgmSize:
		ds.l	1


		.DATA

__data:		dc.l	0
		

		.TEXT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Start: residenter Programmcode
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__text:
Start:
		jmp		Start0(pc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Daten der System-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys:
		dc.b	"TAcc 1.60", 0				; version

; Memory

		dc.w	64				; nxtKbSiz
		dc.w	1				; nxtRecSiz


; RAM-Disk

		dc.w	1				; rdNxtOn
		dc.w	14				; rdNxtDrv
		dcb.b	128,0			; rdFname
		dcb.b	40,0			; rdParams
		dc.w	0				; rdExecFlag

; save screen

		dc.w	1				; scSwitch
		dc.w	90				; scTime

; mouse speeder

		dc.w	1				; smSwitch
		dc.w	0				; smKeep
		dc.b	-70, -70, -70, -60, -50, -32, -16,  -8, -3
		dc.b	0						; xList
		dc.b	3,     8,  16,  32,  50,  60,  70,  70, 70
		dc.b	-70, -70, -70, -60, -50, -32, -16,  -8, -3
		dc.b	0						; yList
		dc.b	3,     8,  16,  32,  50,  60,  70,  70, 70

; printer spooler

		dc.l	10				; spRate
		dc.w	0				; spOn
		dc.w	1				; spQuick

; timer

		dc.l	0				; tiTime
		dc.w	0				; tiFlag

; disk cache info

		dc.w	0				; ciOn
		dc.l	3				; ciDelay
		dcb.w	16,0			; ciDrvTypes

taccinf_end:

		dc.b	"A:\TOSACC.INF",0,0,0			; saveFile 16

		dc.w	0				; confInstalled

		dc.w	0				; confActiv


		dc.l	0				; resMem
		dc.w	0				; OSVers
		dc.w	0				; subprFlag
		dc.w	20				; secTenth
		dc.l	0				; tsecCount

		dc.w	0				; hz200Flag
		dc.w	0				; ahdiFlag
		dc.w	0				; kbSiz
		dc.w	0				; blkSiz
		dc.w	0				; recSiz
		dc.w	0				; absRecSiz
		
		dc.l	0				; copyBlk
		dc.l	0				; blkArr
		dc.w	0				; blkNum
		dc.l	0				; blkFrees
		
		
		dc.w	0				; blkFreeNum
		dc.w	0				; ciBlkNum
		dc.w	0				; rdBlkNum
		dc.w	0				; spBlkNum
		
		
; screen saver

		dcb.w	16,0			; colsav
		dc.l	0				; scOutTime
		dc.w	-1				; scIsOn
		dc.w	0				; scFlag

		dc.l	InvertScreen	; InvertScreen

; mouse speeder

		dc.w	0				; x
		dc.w	0				; y
		
; RAM-Disk

		dc.w	1				; rdOn
		dc.w	14				; rdDrv
		dc.l	0				; rdMaxRec
		dcb.b	b_bpb_size,0	; rdBpb
		dc.l	0				; rdRecPtrs
		dc.w	0				; rdDirty

; printer spooler

		dc.l	0				; spNchars
		dc.l	0				; spTChars

		dc.w	0				; spRun
		dc.w	0				; spInPos
		dc.w	0				; spOutPos
		dc.l	0				; spInBlk
		dc.l	0				; spOutBlk

		dc.l	ResetSpooler	; ResetSpooler

; Cache

		dc.w	0				; ciDirty
		dc.w	0				; ciDelayOff
		dc.l	0				; ciOutTime
		dcb.b	ri_length,0		; ciNewest


		dcb.b	ri_length,0		; ciOldest
		dc.l	0				; ciPuninfo

		dc.l	0				; ciLogrd

		dc.l	0				; ciPhrd
		dc.l	0				; ciLogwrt
		dc.l	0				; ciPhwrt

		dc.l	0				; ciFixederr
		
		dc.l	0				; ciFatalerr
		
		dc.l	0				; ciRetSav
		dcb.b	16*di_length,0
		
		
		dc.l	7				; _ciState
		
		
		
		
		
		
		
		dc.l	ciFlush			; _ciFlush
		dc.l	ciClear			; _ciClear
		
		dc.l	ciDrState		; _ciDrState
		dc.l	ciDrSet			; ciDrSet
		
		
; system vectors



		dc.l	OldMediach		; OldMediach
		dc.l	NewMediach		; NewMediach

		dc.l	OldRW			; RW
		dc.l	NewRW			; 

		dc.l	OldBPB			; BPB
		dc.l	NewBPB			; 

		dc.l	0 ; OldGEMDOS		; GEMDOS
		dc.l	0 ; NewGEMDOS		; 

		dc.l	OldBIOS			; BIOS
		dc.l	NewBIOS			; 

		dc.l	OldXBIOS		; XBIOS
		dc.l	NewXBIOS		; 

		dc.l	OldBcostat0		; Bcostat0
		dc.l	NewBcostat0		; 

		dc.l	OldBconout0		; Bconout0
		dc.l	NewBconout0		; 

		dc.l	Old200HZ		; 200HZ
		dc.l	New200HZ		; 

; set in TOSACC

		dc.l	OldKEYBD		; KEYBD
		dc.l	NewKEYBD		; 

		dc.l	OldMOUSE		; MOUSE
		dc.l	NewMOUSE		; 

sys_length:

/*
		.EXPORT __NewRW, __NewBPB, __NewMediach, ciFlush, _InputChar
__NewMediach:
		movem.l		d3-d7/a2-a6,-(sp)
		move.w		11*4(sp),-(sp)
		bsr			NewMediach
		addq.l		#2,sp
		movem.l		(sp)+,d3-d7/a2-a6
		rts
__NewBPB:
		movem.l		d3-d7/a2-a6,-(sp)
		move.w		11*4(sp),-(sp)
		bsr			NewBPB
		addq.l		#2,sp
		movem.l		(sp)+,d3-d7/a2-a6
		rts
__NewRW:
		movem.l		d3-d7/a2-a6,-(sp)

		lea.l		11*4+16(sp),a0
		move.l		-(a0),-(sp)
		move.l		-(a0),-(sp)
		move.l		-(a0),-(sp)
		move.l		-(a0),-(sp)
		bsr			NewRW
		lea.l		16(sp),sp
		movem.l		(sp)+,d3-d7/a2-a6
		rts

_InputChar:
		movem.l		d3-d7/a2-a6,-(sp)
		bsr			InputChar
		movem.l		(sp)+,d3-d7/a2-a6
		rts
*/		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	CopyRec  a0: dest, a1: src, d0: recsiz
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyRec:
		movem.l		d3-d7/a2-a6,-(sp)
		bsr			_CopyRec
		movem.l		(sp)+,d3-d7/a2-a6
		rts
		
_CopyRec:
		move.l		a0,d1
		add.l		a1,d1
		lsr.w		#1,d1
		bcs			CRSlow
CRQuick:
		move.w		d0,-(sp)
CRQuickLoop:
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,52(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,104(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,156(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,208(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,260(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,312(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,364(a0)
		movem.l		(a1)+,d0-d7/a2-a6
		movem.l		d0-d7/a2-a6,416(a0)
		movem.l		(a1)+,d0-d7/a2-a4
		movem.l		d0-d7/a2-a4,468(a0)
	
		lea.l		512(a0),a0
		subq.w		#1,(sp)
		bne			CRQuickLoop					; recSiz
		addq.l		#2,sp
		rts
CRSlow:
		subq.w		#1,d0
CRSLoop1:
		moveq.l		#63,d1
CRSLoop2:
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		move.b		(a1)+,(a0)+
		dbf			d1,CRSLoop2
		dbf			d0,CRSLoop1
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	CopyCheck( void *dest, void *src, int recsiz );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyCheck:

		movem.l		d3-d7/a2-a6,-(sp)
		bsr			_CopyCheck
		movem.l		(sp)+,d3-d7/a2-a6
		rts
		
_CopyCheck:
		move.l		a0,d1
		add.l		a1,d1
		lsr.w		#1,d1
		bcs			CCSlow

CCQuick:
		move.w		d0,-(sp)
		moveq.l		#0,d0

CCQuickLoop1:
		moveq.l		#10,d1
CCQuickLoop:
		movem.l		(a1)+,d2-d7/a2-a6
		add.l		d2,d0
		add.l		d3,d0
		add.l		d4,d0
		add.l		d5,d0
		add.l		d6,d0
		add.l		d7,d0
		add.l		a2,d0
		add.l		a3,d0
		add.l		a4,d0
		add.l		a5,d0
		add.l		a6,d0
		movem.l		d2-d7/a2-a6,(a0)
		lea.l		11*4(a0),a0
		dbf			d1,CCQuickLoop

		movem.l		(a1)+,d2-d7/a2
		add.l		d2,d0
		add.l		d3,d0
		add.l		d4,d0
		add.l		d5,d0
		add.l		d6,d0
		add.l		d7,d0
		add.l		a2,d0
		movem.l		d2-d7/a2,(a0)
		lea.l		7*4(a0),a0
	
		subq.w		#1,(sp)
		bne			CCQuickLoop1
		addq.l		#2,sp
		rts
CCSlow:
		move.w		a0,d1
		lsr.w		#1,d1
		bcs			A0Slow
		move.l		a0,-(sp)
		bra			CCSGo
A0Slow:
		move.l		a1,-(sp)
CCSGo:
		move.w		d0,-(sp)
		bsr			CRSlow
		move.w		(sp)+,d0
		move.l		(sp)+,a0
		bsr			_CheckSum
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	CheckSum : a0: sector, d0: recsiz  return: d0: checksum
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckSum:
		movem.l		d3-d7/a2-a6,-(sp)
		bsr			_CheckSum
		movem.l		(sp)+,d3-d7/a2-a6
		rts
_CheckSum:
		move.w		d0,-(sp)
		moveq.l		#0,d0

CSLoop1:
		moveq.l		#10,d1
CSLoop:
		movem.l		(a0)+,d2-d7/a2-a6
		add.l		d2,d0
		add.l		d3,d0
		add.l		d4,d0
		add.l		d5,d0
		add.l		d6,d0
		add.l		d7,d0
		add.l		a2,d0
		add.l		a3,d0
		add.l		a4,d0
		add.l		a5,d0
		add.l		a6,d0
		dbf			d1,CSLoop

		movem.l		(a0)+,d2-d7/a2
		add.l		d2,d0
		add.l		d3,d0
		add.l		d4,d0
		add.l		d5,d0
		add.l		d6,d0
		add.l		d7,d0
		add.l		a2,d0
	
		subq.w		#1,(sp)
		bne			CSLoop1
		addq.l		#2,sp
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RECINF	*GetRecInf( RECINF *start, long recno );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetRecInf:
		lea.l		diFirst(a3),a0
_GetRecInf:
		move.l		riNext(a0),a1		
		move.l		riNext(a1),a1		
		move.l		riNext(a1),a1		
		move.l		riNext(a1),a1		
		move.l		riNext(a1),a1
		
		cmp.l		riRecno(a1),d0
		ble			GRIFnd
		
		move.l		riNext(a1),a0
		move.l		riNext(a0),a0
		move.l		riNext(a0),a0
		move.l		riNext(a0),a0
		move.l		riNext(a0),a0
		
		cmp.l		riRecno(a0),d0
		bgt			_GetRecInf
		
		move.l		a1,a0
GRIFnd:		
		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d0
		ble			GRIDone
		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d0
		ble			GRIDone
		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d0
		ble			GRIDone
		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d0
		ble			GRIDone
		move.l		riNext(a0),a0
GRIDone:
		rts		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	WritePhys( RECINF *ri )
;;
;;	a2		: sys
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WritePhys:

		addq.l		#1,ciPhwrt(a2)
		tst.w		ahdiFlag(a2)
		beq			WPSmall
		cmp.l		#$7fff,riRecno(a0)
		ble			WPSmall
		move.l		riRecno(a0),-(sp)
		move.w		riDrv(a0),-(sp)
		move.l		#$1ffff,-(sp)
		lea.l		ri_length(a0),a0
		move.l		a0,-(sp)
		move.w		#1,-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		16(sp),sp
		rts
WPSmall:
		move.w		riDrv(a0),-(sp)
		move.w		riRecno+2(a0),-(sp)
		move.w		#1,-(sp)
		lea.l		ri_length(a0),a0
		move.l		a0,-(sp)
		move.w		#1,-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		12(sp),sp
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	ReadPhys( RECINF *ri )
;;
;;	a2		: sys
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadPhys:

		tst.w		ahdiFlag(a2)
		addq.l		#1,ciPhrd(a2)
		beq			RPSmall
		cmp.l		#$7fff,riRecno(a0)
		ble			RPSmall
		move.l		riRecno(a0),-(sp)
		move.w		riDrv(a0),-(sp)
		move.l		#$1ffff,-(sp)
		lea.l		ri_length(a0),a0
		move.l		a0,-(sp)
		clr.w		-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		16(sp),sp
		rts
RPSmall:
		move.w		riDrv(a0),-(sp)
		move.w		riRecno+2(a0),-(sp)
		move.w		#1,-(sp)
		lea.l		ri_length(a0),a0
		move.l		a0,-(sp)
		clr.w		-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		12(sp),sp
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	UpdateOne( RECINF *ri )
;;
;;	a2		: sys
;;	a3		: DRIVEINF
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateOne:
		lea.l		di(a2),a3
		move.w		riDrv(a0),d0
		lsl.w		#7,d0
		add.w		d0,a3						; di
		
_UpdateOne:

		move.l		riNext(a0),a6
		move.l		riRecno(a0),d0
		addq.l		#1,d0
		cmp.l		riRecno(a6),d0
		bne			UpdateOOne					; Update One
		tst.w		riDirty(a6)
		beq			UpdateOOne
UpdateTwo:
		subq.w		#2,diDirty(a3)
		clr.w		riDirty(a0)
		clr.w		riDirty(a6)
		move.w		diRecSiz(a3),d0
		movem.l		a0/a2-a3/a6,-(sp)
		lea.l		ri_length(a0),a1
		move.l		copyBlk(a2),a0
		bsr			_CopyCheck
		movem.l		(sp)+,a1-a3/a6				; !! a0 > a1 !!
		cmp.w		riCheckSum(a1),d0
		beq			UOCheck1OK
		
		move.l		a1,a0
		bsr			DoChkErr
		move.w		#1,riDirty(a0)
		move.w		#1,riDirty(a6)
		addq.w		#2,diDirty(a3)
		bra			UpdateOOne
UOCheck1OK:
		move.w		diRecSiz(a3),d0
		movem.l		a1-a3/a6,-(sp)
		lea.l		ri_length(a6),a1
		bsr			_CopyCheck
		movem.l		(sp)+,a0/a2-a3/a6			; !! a1 > a0  !!
		cmp.w		riCheckSum(a6),d0
		beq			UOCheck2OK
		
		bsr			DoChkErr
		move.w		#1,riDirty(a0)
		move.w		#1,riDirty(a6)
		addq.w		#2,diDirty(a3)
		bra			UpdateOOne
UOCheck2OK:

		movem.l		a0/a2-a3,-(sp)

		addq.l		#2,ciPhwrt(a2)
		tst.w		ahdiFlag(a2)
		beq			UOWPSmall
		cmp.l		#$7fff,riRecno(a0)
		ble			UOWPSmall
		move.l		riRecno(a0),-(sp)
		move.w		riDrv(a0),-(sp)
		move.l		#$2ffff,-(sp)
		move.l		copyBlk(a2),-(sp)
		move.w		#1,-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		16(sp),sp
		bra			UO2End
UOWPSmall:
		move.w		riDrv(a0),-(sp)
		move.w		riRecno+2(a0),-(sp)
		move.w		#2,-(sp)
		move.l		copyBlk(a2),-(sp)
		move.w		#1,-(sp)
		move.l		OldRW(pc),a0
		jsr			(a0)
		lea.l		12(sp),sp
UO2End:
		movem.l		(sp)+,a0/a2-a3
		tst.w		d0
		beq			UO2Return
		addq.l		#1,ciFatalerr(a2)
		move.l		riNext(a0),a6
		move.w		#1,riDirty(a0)
		move.w		#1,riDirty(a6)
		addq.w		#2,diDirty(a3)
		bra			UpdateOOne
UO2Return:

		rts



UpdateOOne:

		subq.w		#1,diDirty(a3)
		clr.w		riDirty(a0)
		move.w		diRecSiz(a3),d0
		movem.l		a0/a2-a3,-(sp)
		lea.l		ri_length(a0),a0
		bsr			_CheckSum
		movem.l		(sp)+,a0/a2-a3
		cmp.w		riCheckSum(a0),d0
		beq			UOCheckOK
		
		bra			DoChkErr					; does not come back
UOCheckOK:
		movem.l		a0/a2-a3,-(sp)
		jsr			WritePhys
		movem.l		(sp)+,a0/a2-a3
		tst.w		d0
		beq			UOReturn
		addq.l		#1,ciFatalerr(a2)
UOReturn:
		rts


DoChkErr:

		addq.l		#1,ciFatalerr(a2)
UOAgain:
		movem.l		d1-a6,-(sp)
		move.l		$404,a1							; etv_critic
		move.w		riDrv(a0),-(sp)					; drive
		move.l		#-10,-(sp)						; write fault
		jsr			(a1)
		addq.l		#6,sp
		movem.l		(sp)+,d1-a6
		cmp.l		#$10000,d0
		beq			UOAgain
		
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	void *GetFreeBlk( void )
;;
;;	a2		: sys
;;	a3		: DRIVEINF
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_GetFreeBlk:
		cmp.w		#1,ciBlkNum(a2)
		bgt			GFBNoAware
		cmp.w		#1,blkFreeNum(a2)
		bgt			GFBBlkFree
		tst.w		rdDirty(a2)
		beq			GFBRetErr
		bsr			FreeRdRecs
		cmp.w		#1,blkFreeNum(a2)
		bgt			GFBBlkFree
GFBRetErr:
		sub.l		a0,a0
		rts
GFBNoAware:
		move.w		blkFreeNum(a2),d0
		bne			GFBBlkFree
		tst.w		rdDirty(a2)
		beq			GFBRecBlk
		bsr			FreeRdRecs
		move.w		blkFreeNum(a2),d0
		beq			GFBRecBlk
GFBBlkFree:
		move.l		blkFrees(a2),a0
		move.l		(a0),blkFrees(a2)
		subq.w		#1,blkFreeNum(a2)
		rts

GFBRecBlk:
		move.l		ciOldest+riNewer(a2),a0
		tst.w		riDirty(a0)
		beq			GFBNoWrite
		move.l		a3,-(sp)
		bsr			UpdateOne
		move.l		(sp)+,a3
GFBNoWrite:
		move.l		riNewer(a0),a5				; link Newer/Older
		move.l		riOlder(a0),a6
		move.l		a5,riNewer(a6)
		move.l		a6,riOlder(a5)
		
		move.l		riNext(a0),a5				; link Next/Last
		move.l		riLast(a0),a6
		move.l		a5,riNext(a6)
		move.l		a6,riLast(a5)
		subq.w		#1,ciBlkNum(a2)
		
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RECINF *GetFreeRec( void )
;;
;;	a2		: sys
;;	a3		: DRIVEINF
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetFreeRec:
		tst.w		blkFreeNum(a2)
		bne			GFRFnd
GFRTakeOld:
		tst.w		rdDirty(a2)
		beq			GFRNoRdDirty
		bsr			FreeRdRecs
		tst.w		blkFreeNum(a2)
		bne			GFRFnd
GFRNoRdDirty:
		move.l		ciOldest+riNewer(a2),a0				; ri
		tst.w		riDirty(a0)
		beq			GFRNoWrite
		movem.l		a3-a4/d3-d6,-(sp)
		bsr			UpdateOne
		movem.l		(sp)+,a3-a4/d3-d6
GFRNoWrite:
		cmp.l		a0,a4						; is our new one just the
		bne			GFRNWOK						; next bigger one
		move.l		riNext(a4),a4
GFRNWOK:
		lea.l		ciOldest(a2),a1
		move.l		riNewer(a0),a6				; link Newer/Older
		move.l		a1,riOlder(a6)
		move.l		a6,riNewer(a1)
		
		move.l		riNext(a0),a6				; link Next/Last
		move.l		riLast(a0),a1
		move.l		a6,riNext(a1)
		move.l		a1,riLast(a6)
		subq.w		#1,ciBlkNum(a2)				; might be now -1
		rts
GFRFnd:
		subq.w		#1,blkFreeNum(a2)
		move.l		blkFrees(a2),a0
		move.l		riNext(a0),blkFrees(a2)
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	ClearDrive
;;
;;	d0.l	: first
;;	d1.l	: last
;;	a2		: sys
;;	a3		: DRIVEINF	
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearDrive:

		lea.l		diFirst(a3),a0
		bsr			_GetRecInf
		add.l		d0,d1
_ClearDrive:
		cmp.l		riRecno(a0),d1
		ble			CDDone
		moveq.l		#0,d0					; count
		move.l		a0,a1
CDLoop:
		addq.w		#1,d0
		
		move.l		riOlder(a0),a6			; Link Older/Newer
		move.l		riNewer(a0),riNewer(a6)				
		move.l		riNewer(a0),a6
		move.l		riOlder(a0),riOlder(a6)
		
		tst.w		riDirty(a0)
		beq			CDNoDirty
		subq.w		#1,diDirty(a3)
CDNoDirty:

		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d1
		bgt			CDLoop

		add.w		d0,blkFreeNum(a2)
		sub.w		d0,ciBlkNum(a2)

		move.l		blkFrees(a2),a5
		move.l		a1,blkFrees(a2)
		move.l		riLast(a1),a1
		
		move.l		riLast(a0),a6
		move.l		a5,riNext(a6)

		move.l		a1,riLast(a0)
		move.l		a0,riNext(a1)
		
CDDone:
		rts
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	UpdateDrive
;;
;;	d0.l	: first
;;	d1.l	: last
;;	a2		: sys
;;	a3		: DRIVEINF	
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateDrive:
		add.l		d0,d1
		lea.l		diFirst(a3),a0
		bsr			GetRecInf
_UpdateDrive:
		cmp.l		riRecno(a0),d1
		ble			UDDone
		moveq.l		#0,d0					; count
		move.l		a0,a1
UDLoop:
		tst.w		riDirty(a0)
		beq			UDNoDirty
		move.l		d1,-(sp)
		bsr			_UpdateOne
		move.l		(sp)+,d1
UDNoDirty:
		move.l		riNext(a0),a0
		cmp.l		riRecno(a0),d1
		bgt			UDLoop
UDDone:
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	UpdateCache
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateCache:
		lea.l		sys(pc),a2
		addq.w		#1,subprFlag(a2)
		lea.l		di(a2),a3
		move.l		tsecCount(a2),d0
		add.l		ciDelay(a2),d0
		move.l		d0,ciTimeOut(a2)
		moveq.l		#15,d2
UCLoop:
		tst.w		diDirty(a3)
		beq			UCNext
		move.l		diFirst+riNext(a3),a0
		move.l		#$7ffffffe,d1
		move.w		d2,-(sp)
		bsr			_UpdateDrive
		move.w		(sp)+,d2
		clr.w		diDirty(a3)
UCNext:
		clr.w		diFirstWrt(a3)
		add.l		#di_length,a3
		dbf			d2,UCLoop
		clr.w		ciDirty(a2)
		move.l		tsecCount(a2),d1
		add.l		ciDelay(a2),d1
		move.l		d1,ciTimeOut(a2)
		subq.w		#1,subprFlag(a2)
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	ClearCache
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearCache:
		lea.l		sys(pc),a2
		addq.w		#1,subprFlag(a2)
		lea.l		di(a2),a3
		move.l		tsecCount(a2),d0
		add.l		ciDelay(a2),d0
		move.l		d0,ciTimeOut(a2)
		lea.l		di(a2),a3
		moveq.l		#15,d2
CCLoop:
		move.l		#$7ffffffe,d1
		move.l		diFirst+riNext(a3),a0
		bsr			_ClearDrive
		move.w		#1,diValid(a3)
		clr.w		diKnown(a3)
		add.l		#di_length,a3
		dbf			d2,CCLoop
		
		move.l		tsecCount(a2),d0
		add.l		ciDelay(a2),d0
		move.l		d0,ciTimeOut(a2)
		subq.w		#1,subprFlag(a2)
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RAM-Disk Treiberfunktion: hdv_mediach
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
OldMediach:
	dc.l		0

NewMediach:

			move.w		4(sp),d0
			bmi			DoOldMediach		; negative Laufwerksnummer ?
			cmp.w		sys+rdDrv(pc),d0
			bne			NMTstKnown
			tst.w		sys+rdOn
			beq			NMTstKnown
			moveq.l		#0,d0				; RAM-Disk
			rts
NMTstKnown:
			cmp.w		#15,d0				; Laufwerk grîûer 15 ?
			bgt			DoOldMediach
			addq.w		#1,sys+subprFlag
			lea			sys+di+diKnown(pc),a0	; Laufwerk dem Cache
												; bekannt ?
			lsl.w		#7,d0
			add.w		d0,a0
			tst.w		(a0)
			bne			_DoOldMediach			; if known, do old one
			move.w		4(sp),-(sp)
			move.l		OldMediach(pc),a0
			jsr			(a0)
			addq.l		#2,sp
			tst.w		d0						; if not media changed
			beq			NMGetBpb				; get BPB
			subq.w		#1,sys+subprFlag
			rts
NMGetBpb:
			move.w		4(sp),-(sp)
			bsr			NewBPB
			addq.l		#2,sp
			tst.l		d0
			beq			NMRetErr
			moveq.l		#0,d0
			subq.w		#1,sys+subprFlag
			rts
NMRetErr:
			moveq.l		#2,d0				; Wenn nicht bekannt, dann
			subq.w		#1,sys+subprFlag
			rts								; Medienwechsel vortÑuschen.
_DoOldMediach:
			subq.w		#1,sys+subprFlag
DoOldMediach:
			move.l		OldMediach(pc),a0
			jmp			(a0)
			
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RAM-Disk and cache hdv_getbpb
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
OldBPB:
	dc.l		0

NewBPB:
			move.w		4(sp),d1			; drive number
			bmi			DoOldBPB			; negative drive number ?
			lea.l		sys(pc),a2
			tst.w		rdOn(a2)			; RAM-disk on ?
			beq			BPBNoRD
			cmp.w		rdDrv(a2),d1
			bne			BPBNoRD
			lea.l		rdBpb(a2),a0		; RAM-Disk BPB
			move.l		a0,d0
			rts
BPBNoRD:
			cmp.w		#16,d1				; drive number >= 16 ?
			bge			DoOldBPB
			addq.w		#1,subprFlag(a2)
			move.w		d1,-(sp)
			move.l		OldBPB(pc),a0
			jsr			(a0)				; Do old Getbpb
			addq.l		#2,sp
			lea.l		sys(pc),a2
			move.l		d0,a0				; *bpb
			lea.l		di(a2),a3
			move.w		4(sp),d3
			move.w		d3,d0
			lsl.w		#7,d0
			add.w		d0,a3				; &di[drv]
			tst.w		diValid(a3)
			beq			NGBGo
			tst.w		diKnown(a3)
			beq			NGBGo
			tst.w		diRead(a3)
			beq			NGBGo
			tst.w		diDirty(a3)
			beq			NGBClear
			move.l		#$7ffffffe,d1
			move.l		a0,-(sp)
			move.l		diFirst+riNext(a3),a0
			bsr			_UpdateDrive
			move.l		(sp)+,a0
NGBClear:
			move.l		#$7ffffffe,d1
			move.l		a0,-(sp)
			move.l		diFirst+riNext(a3),a0
			bsr			_ClearDrive
			move.l		(sp)+,a0
			clr.w		diDirty(a3)
			clr.w		diFirstWrt(a3)
NGBGo:
			move.l		a0,d0
			bne			NGBpbOK			; if no BPB turn off drive cache
			clr.w		diKnown(a3)
			clr.w		diValid(a3)
			subq.w		#1,subprFlag(a2)
			rts
NGBpbOK:
			move.w		#1,diKnown(a3)		; this drive is now known
			move.l		a0,diBpb(a3)
			move.w		b_numcl(a0),d1		; calculate sectors per drive
			mulu		b_clsiz(a0),d1
			moveq.l		#0,d2
			move.w		b_datrec(a0),d2
			add.l		d2,d1
			move.l		d1,diRecNum(a3)
			move.w		b_recsiz(a0),d1		; save number of 512 byte
			moveq.l		#9,d2			 	; blocks per sector
			lsr.w		d2,d1
			move.w		d1,diRecSiz(a3)
			cmp.w		recSiz(a2),d1		; if sector size bigger than
			bgt			NBRetErr			; supported, turn off drv cache
			move.w		#1,diValid(a3)
			subq.w		#1,subprFlag(a2)
			rts
NBRetErr:
			clr.w		diValid(a3)
			subq.w		#1,subprFlag(a2)
			rts
_DoOldBPB:
			subq.w		#1,subprFlag(a2)
DoOldBPB:
			move.l		OldBPB(pc),a0
			jmp			(a0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Treiberfunktion: hdv_rw
;;
;;	a2		: sys
;;	a3		: DRIVEINF
;;	a4		: RECINF
;;	d3.w	: drive
;;	d4.l	: recno
;;	d5.l	: count
;;	d6.l	: recno + count
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
OldRW:
	dc.l		0

NewRW:
			lea.l		sys(pc),a2
			tst.w		subprFlag(a2)		; Rekusive Aufrufe nicht
			bne			RetRekursiv			; erlaubt
			move.w		#1,subprFlag(a2)	; Sub prozess sperren
			
			tst.w		ahdiFlag(a2)		; AHDI 3.0 kompatibel?
			beq			NoPhysMode
			btst.b		#3,rwFlag+1(sp)
			beq			NoPhysMode			; Physikalischer Modus
			
			bsr			UpdateCache			; Alles updaten
			bsr			ClearCache			; alles rausschmeiûen
			
			lea.l		16(sp),a0
			move.l		-(a0),-(sp)
			move.l		-(a0),-(sp)
			move.l		-(a0),-(sp)
			move.l		-(a0),-(sp)
			
			move.l		OldRW(pc),a0		; Original Aufrufen
			jsr			(a0)
			lea.l		16(sp),sp
			clr.w		sys+subprFlag		; Sub prozess freigeben
			rts								; verlassen mit original
											; RÅckgabewert
NoPhysMode:
			move.l		rwBuf(sp),d2		; Buffer == NULL ?
			beq			DoOldRW
			move.w		rwDrv(sp),d3		; drv < 0 ?
			bmi			DoOldRW
			cmp.w		rdDrv(a2),d3		; RAM-Disk Zugriff ?
			bne			DoCache
			tst.w		rdOn(a2)			; RAM-Disk eingeschaltet ?
			bne			DoRamDisk
DoCache:
			cmp.w		#15,d3				; drv > 15 ?
			bgt			DoOldRW

			lea.l		di(a2),a3
			move.w		d3,d0
			lsl.w		#7,d0
			add.w		d0,a3				; DRIVEINF to a3

			btst.b		#0,rwFlag+1(sp)		; Read or write ?
			beq			DCReadGo
			tst.w		diLocked(a3)		; drive write locked ?
			bne			RetLocked
DCReadGo:
			tst.w		ciOn(a2)			; cache global on ?
			beq			DoOldRW
			tst.w		diValid(a3)			; drive params OK ?
			beq			DoOldRW
			tst.w		diKnown(a3)			; drive known via BPB ?
			bne			DiKnown

			movem.l		a2/a3/d3,-(sp)
			move.w		d3,-(sp)
			move.l		OldMediach(pc),a0
			jsr			(a0)
			addq.l		#2,sp
			movem.l		(sp)+,a2/a3/d3
			tst.w		d0
			bne			RetUnknown
			
			movem.l		a2/a3/d3,-(sp)
			move.w		d3,-(sp)
			bsr			NewBPB
			addq.l		#2,sp
			movem.l		(sp)+,a2/a3/d3
			tst.w		diValid(a3)			; drive params OK ?
			beq			DoOldRW
			tst.w		diKnown(a3)			; drive known via BPB ?
			beq			RetUnknown
			
DiKnown:
			tst.w		diRead(a3)			; drive user set on ?
			beq			DoOldRW
			
			moveq.l		#0,d4				; get AHDI 3.0 recno
			move.w		rwRecno(sp),d4
			bpl			RecnoOK
			cmp.w		#-1,d4
			bne			RecnoOK
			tst.w		ahdiFlag(a2)
			beq			DoOldRW				; #-1 without AHDI 3.0 !!!!
			move.l		rwLrecno(sp),d4
			bmi			DoOldRW
RecnoOK:
			moveq.l		#0,d5
			move.w		rwCount(sp),d5		; recno count
			bmi			DoOldRW				; count < 0 ?
			beq			DoOldRW				; count == 0 ?
			move.l		d5,d6				; get first sector without
			add.l		d4,d6				; access
			move.l		d4,d0				; recno
			bsr			GetRecInf
			move.l		a0,a4				; RECINF
			btst.b		#0,rwFlag+1(sp)		; read/write ?
			beq			CacheRead
CacheWrite:
			cmp.l		diRecNum(a3),d6		; do all sectors to access
			ble			WRNOK				; really exist?

			bsr			ClearCache			; not very likely to happen
			bra			DoOldRW
WRNOK:			
			cmp.w		#1,d5				; count == 1 ?
			bne			CWMore

WriteCacheOne:
			addq.l		#1,ciLogwrt(a2)		; one sector logical written
			cmp.l		riRecno(a4),d4		; is it in the cache?
			beq			WCOFnd
			bsr			GetFreeRec			; add one buffer to cache
			addq.w		#1,ciBlkNum(a2)
			move.w		d3,riDrv(a0)
			clr.w		riDirty(a0)
			move.l		d4,riRecno(a0)
			
			move.l		riLast(a4),a1

			move.l		a0,riNext(a1)			; link First/Last
			move.l		a0,riLast(a4)
			move.l		a1,riLast(a0)
			move.l		a4,riNext(a0)
			
			move.l		a0,a4
			bra			WCOGo
WCOFnd:
			move.l		riOlder(a4),a0			; link out Older/Newer
			move.l		riNewer(a4),a1
			move.l		a1,riNewer(a0)
			move.l		a0,riOlder(a1)
WCOGo:
			move.l		ciNewest+riOlder(a2),riOlder(a4) ; link Older/Newer
			lea.l		ciNewest(a2),a0
			move.l		a0,riNewer(a4)
			move.l		riOlder(a4),a0
			move.l		a4,riNewer(a0)
			move.l		a4,ciNewest+riOlder(a2)

			lea.l		ri_length(a4),a0			; copy buffer to cache
			move.l		rwBuf(sp),a1
			move.w		diRecSiz(a3),d0
			movem.l		a2-a4,-(sp)
			bsr			_CopyCheck
			movem.l		(sp)+,a2-a4
			
			move.w		d0,riCheckSum(a4)			; save check sum
			move.w		diWrite(a3),riDirty(a4)		; do we write cache ?
			bne			WCOCache
WCOPhys:
			move.l		a4,a0
			movem.l		a2-a4,-(sp)
			bsr			WritePhys
			movem.l		(sp)+,a2-a4
			tst.w		d0					; write error ?
			beq			RWDone
WCOErr:
			move.l		d0,-(sp)			; not very likely to happen
			move.l		riRecno(a4),d0
			moveq.l		#1,d1
			bsr			ClearDrive			; riDirty(a4) has to be zero
			move.l		(sp)+,d0
			bra			RWDone
WCOCache:
			tst.w		diFirstWrt(a3)		; first write access since
			bne			WCOCache1			; last time out ?

			clr.w		riDirty(a4)
			move.l		a4,a0
			movem.l		a2-a4,-(sp)
			bsr			WritePhys
			movem.l		(sp)+,a2-a4
			tst.w		d0					; write error ?
			bne			WCOErr
			addq.w		#1,diFirstWrt(a3)
			bra			RWDone
WCOCache1:
			addq.w		#1,diDirty(a3)
			move.w		#1,ciDirty(a2)
			moveq.l		#0,d0
			bra			RWDone
									
; write more than one sector

CWMore:
			move.l		a4,a0
			move.l		d6,d1
			bsr			_ClearDrive
			bra			DoOldRW			

CacheRead:
			cmp.l		diRecNum(a3),d6		; do all sectors to acces
			ble			RRNOK				; really exist?

			bsr			UpdateCache
			bsr			ClearCache
			bra			DoOldRW
RRNOK:
			movem.l		a2-a4/d3-d6,-(sp)
			move.w		d3,-(sp)
			move.l		OldMediach(pc),a0	; if media changed
			jsr			(a0)				; read always physikal
			addq.l		#2,sp
			movem.l		(sp)+,a2-a4/d3-d6
			tst.w		d0
			beq			NotChanged

; even if a media changed, we update all. Seems to be kritical but
; works fine

			tst.w		ciDirty(a2)
			beq			DoOldRW
			bsr			UpdateCache
			bra			DoOldRW
NotChanged:
			cmp.w		#1,d5				; count == 1 ?
			bne			CRMore
ReadCacheOne:
			addq.l		#1,ciLogrd(a2)		; one sector logical read
			cmp.l		riRecno(a4),d4		; is it in the cache?
			beq			RCOFnd
			bsr			GetFreeRec			; add one buffer to cache
			addq.w		#1,ciBlkNum(a2)
			move.w		d3,riDrv(a0)
			clr.w		riDirty(a0)
			move.l		d4,riRecno(a0)
			
			move.l		riLast(a4),a1

			move.l		a0,riNext(a1)			; link First/Last
			move.l		a0,riLast(a4)
			move.l		a1,riLast(a0)
			move.l		a4,riNext(a0)
			
			move.l		a0,a4
RCOPhys:
			move.l		ciNewest+riOlder(a2),riOlder(a4) ; link Older/Newer
			lea.l		ciNewest(a2),a0
			move.l		a0,riNewer(a4)
			move.l		riOlder(a4),a0
			move.l		a4,riNewer(a0)
			move.l		a4,ciNewest+riOlder(a2)
_RCOPhys:
			movem.l		a2-a4/d6,-(sp)
			move.l		a4,a0
			bsr			ReadPhys
			movem.l		(sp)+,a2-a4/d6
			tst.w		d0
			bne			RCOErr

			move.l		rwBuf(sp),a0
			lea.l		ri_length(a4),a1
			move.w		diRecSiz(a3),d0
			movem.l		a2/a4,-(sp)
			bsr			_CopyCheck
			movem.l		(sp)+,a2/a4
			move.w		d0,riCheckSum(a4)
			moveq.l		#0,d0
			bra			RWDone
RCOFnd:
			move.l		riOlder(a4),a0			; link out Older/Newer
			move.l		riNewer(a4),a1
			move.l		a1,riNewer(a0)
			move.l		a0,riOlder(a1)

			move.l		ciNewest+riOlder(a2),riOlder(a4) ; link Older/Newer
			lea.l		ciNewest(a2),a0
			move.l		a0,riNewer(a4)
			move.l		riOlder(a4),a0
			move.l		a4,riNewer(a0)
			move.l		a4,ciNewest+riOlder(a2)

			move.l		rwBuf(sp),a0
			lea.l		ri_length(a4),a1
			move.w		diRecSiz(a3),d0
			movem.l		a2-a4/d6,-(sp)
			bsr			_CopyCheck
			movem.l		(sp)+,a2-a4/d6
			cmp.w		riCheckSum(a4),d0
			bne			_RCOErr

			moveq.l		#0,d0
			bra			RWDone
_RCOErr:
			moveq.l		#-11,d0
RCOErr:
			move.l		d0,-(sp)
			move.l		a4,a0
			move.l		d6,d1
			bsr			_ClearDrive
			move.l		(sp)+,d0
			bra			RWDone

; read cache more than one sector

CRMore:
			tst.w		diDirty(a3)
			beq			DoOldRW
			move.l		a4,a0
			move.l		d6,d1
			bsr			_UpdateDrive
			bra			DoOldRW

DoOldRW:
			move.l		(sp),ciRetSav(a2)
			move.l		#DORWBack,(sp)
			move.l		OldRW(pc),a0
			jmp			(a0)
DORWBack:
			lea.l		sys(pc),a2
			move.l		ciRetSav(a2),-(sp)
RWDone:
			move.l		tsecCount(a2),d2
			add.l		ciDelay(a2),d2
			move.l		d2,ciTimeOut(a2)
			clr.w		subprFlag(a2)
			rts
RetUnknown:
			moveq.l		#-14,d0				; media chanche detect
			bra			RWDone
RetLocked:
			moveq.l		#-13,d0				; write on write-protected
			bra			RWDone
RetRekursiv:
			moveq.l		#-1,d0				; general error	
			move.l		tsecCount(a2),d2
			add.l		ciDelay(a2),d2
			move.l		d2,ciTimeOut(a2)
			rts
RetNotFnd:
			moveq.l		#-8,d0				; sector not found
			bra			RWDone
RetIllegal:
			moveq.l		#-5,d0				; bad request
			bra			RWDone
RetWrtErr:
			moveq.l		#-10,d0				; write fault
			bra			RWDone



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	FreeRdRecs:
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FreeRdRecs:
			move.l		rdRecPtrs(a2),a0		; first dat rec
			move.w		rdBpb+b_fatrec(a2),d0
			lsl.w		#2,d0
			move.l		a0,a1
			add.w		d0,a0
			move.l		(a0),a0					; cluster pointer 
			addq.l		#4,a0
			move.w		rdBpb+b_datrec(a2),d0
			lsl.w		#2,d0
			add.w		d0,a1
			move.w		rdBpb+b_numcl(a2),d0
			subq.w		#1,d0
			
FRRDo:			
			move.l		blkFrees(a2),a6
			moveq.l		#0,d1
FRRLoop:		
			tst.w		(a0)+
			bne			FRR1
			tst.l		(a1)
			beq			_FRR1
			move.l		(a1),a5
			move.l		a6,(a5)
			move.l		a5,a6
			addq.w		#1,d1
			clr.l		(a1)
_FRR1:
			tst.l		4(a1)
			beq			FRR1
			move.l		4(a1),a5
			move.l		a6,(a5)
			move.l		a5,a6
			addq.w		#1,d1
			clr.l		4(a1)
FRR1:
			addq.l		#8,a1
			dbf			d0,FRRLoop
			
			add.w		d1,blkFreeNum(a2)
			sub.w		d1,rdBlkNum(a2)
			move.l		a6,blkFrees(a2)
			clr.w		rdDirty(a2)
			rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Treiberfunktion: hdv_rw-RAM-Disk
;;
;;	*d2.l	: rwBuffer
;;	*d3.w	: rwDrv
;;	d4.l	: rwRecno
;;	d5.l	: rwCount
;;	a1		: rwBuffer
;;	*a2		: sys
;;	a3		: rdRecPtrs
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoRamDisk:
			lea.l		di(a2),a3
			move.w		d3,d0
			lsl.w		#7,d0
			add.w		d0,a3				; DRIVEINF to a3

			tst.w		diLocked(a3)		; drive write locked ?
			bne			RetLocked
			moveq.l		#0,d4				; Startsektor bestimmen
			move.w		rwRecno(sp),d4
			bpl			RDRecnoOK
			cmp.w		#-1,d4
			bne			RDRecnoOK
			tst.w		ahdiFlag(a2)
			beq			RetNotFnd			; #-1 ohne AHDI 3.0 !!!!
			move.l		rwLrecno(sp),d4
			bmi			RetNotFnd
RDRecnoOK:
			moveq.l		#0,d5
			move.w		rwCount(sp),d5		; Sektoranzahl
			bmi			RetIllegal
			beq			RetIllegal
			move.l		d5,d6				; erster Sektor, der nicht
			add.l		d4,d6				; mehr bearbeitet wird

			cmp.l		rdMaxRec(a2),d6		; Maximale Sektornummer ?
			bgt			RetNotFnd
			
			move.l		rdRecPtrs(a2),a3	; Sector list
			
			btst.b		#0,rwFlag+1(sp)		; Schreiben oder Lesen ?
			bne			RDWrite


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Treiberfunktion: hdv_rw-RAM-Disk Read
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RDRead:
			move.l		rwBuf(sp),a0
			move.l		d4,d0
			lsl.l		#2,d0
			add.l		d0,a3
			move.l		a3,-(sp)			; rdRecPtrs
			move.w		recSiz(a2),-(sp)
			move.w		d5,-(sp)			; rwCount
RDRLoop:
			move.w		2(sp),d0			; recSiz
			move.l		4(sp),a3
			addq.l		#4,4(sp)
			move.l		(a3)+,d1
			bne			RDRExist
			move.l		sys+rdRecPtrs,a1	; copy first Sector (empty)
			move.l		(a1),d1
RDRExist:
			move.l		d1,a1
			bsr			_CopyRec
			subq.w		#1,(sp)
			bne			RDRLoop
			addq.l		#8,sp
			moveq.l		#0,d0
			lea.l		sys(pc),a2
			bra			RWDone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Treiberfunktion: hdv_rw-RAM-Disk Write
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RDWrite:
			move.l		rwBuf(sp),a1
			move.l		d4,d0
			lsl.l		#2,d0
			add.l		d0,a3
RDWLoop:
			move.l		d4,d0
			beq			RDWIgnore
			sub.w		rdBpb+b_fatrec(a2),d0	; recno of first FAT
			bpl			RDWDo
RDWIgnore:
			move.w		rdBpb+b_recsiz(a2),d0
			add.w		d0,a1
			addq.l		#4,a3
			bra			RDWEnd
RDWDo:
			move.l		(a3)+,d0
			bne			RDWExist
			movem.l		d4/d6/a1,-(sp)
			bsr			_GetFreeBlk
			movem.l		(sp)+,d4/d6/a1
			move.l		a0,d0
			beq			RetWrtErr
			move.l		d0,-4(a3)
			addq.w		#1,rdBlkNum(a2)
RDWExist:
			move.l		d0,a0
			move.w		recSiz(a2),d0			; recSiz
			movem.l		d4/d6/a2-a3,-(sp)
			bsr			_CopyRec
			movem.l		(sp)+,d4/d6/a2-a3
RDWEnd:
			addq.w		#1,d4
			cmp.w		d6,d4
			blt			RDWLoop
			moveq.l		#0,d0
			addq.w		#1,rdDirty(a2)
			bra			RWDone
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	ciState( int status );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	void	ciFlush( void );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ciFlush:
		movem.l		d3-d7/a2-a6,-(sp)
		lea.l		sys(pc),a2
		bsr			UpdateCache
		movem.l		(sp)+,d3-d7/a2-a6
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	void	ciClear( void );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ciClear:
		movem.l		d3-d7/a2-a6,-(sp)
		lea.l		sys(pc),a2
		bsr			ClearCache
		movem.l		(sp)+,d3-d7/a2-a6
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	ciDrState( int drv );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ciDrState:
		movem.l		d3-d7/a2-a6,-(sp)
		lea.l		sys(pc),a2
		addq.w		#1,subprFlag(a2)
		lea.l		di(a2),a3
		lsl.w		#7,d0
		add.w		d0,a3
		moveq.l		#0,d0
		tst.w		diRead(a3)
		beq			cC1
		bset		#0,d0
cC1:
		tst.w		diWrite(a3)
		beq			cC2
		bset		#1,d0
cC2:
		tst.w		diLocked(a3)
		beq			cC3
		bset		#2,d0
cC3:
		tst.w		diKnown(a3)
		beq			cC4
		bset		#3,d0
cC4:
		tst.w		diValid(a3)
		beq			cC5
		bset		#4,d0
cC5:
		subq.w		#1,sys+subprFlag
		movem.l		(sp)+,d3-d7/a2-a6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	int	ciDrSet( int drv, int state );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ciDrSet:
		movem.l		d3-d7/a2-a6,-(sp)
		lea.l		sys(pc),a2
		addq.w		#1,subprFlag(a2)
		lea.l		di(a2),a3
		lsl.w		#7,d0
		add.w		d0,a3
		and.w		#%111,d1
		btst		#0,d1
		bne			cDSNext
		bclr		#1,d1
cDSNext:
		btst		#0,d1
		bne			cDS1
		movem.l		d1/a2-a3,-(sp)
		move.l		#0,d0
		move.l		#$7ffffffd,a1
		bsr			UpdateDrive
		movem.l		(sp)+,d1/a2-a3
		movem.l		d1/a2-a3,-(sp)
		move.l		#0,d0
		move.l		#$7ffffffd,a1
		bsr			ClearDrive
		movem.l		(sp)+,d1/a2-a3
		clr.w		diRead(a3)
		clr.w		diWrite(a3)
		bra			cDS2
cDS1:
		movem.l		d1/a2-a3,-(sp)
		move.l		#0,d0
		move.l		#$7ffffffd,a1
		bsr			UpdateDrive
		movem.l		(sp)+,d1/a2-a3
		move.w		#1,diRead(a3)
cDS2:
		btst		#1,d1
		beq			cDS3		
		move.w		#1,diRead(a3)
		move.w		#1,diWrite(a3)
		bra			cDS4
cDS3:
		movem.l		d1/a2-a3,-(sp)
		move.l		#0,d0
		move.l		#$7ffffffd,a1
		bsr			UpdateDrive
		movem.l		(sp)+,d1/a2-a3
		clr.w		diWrite(a3)
cDS4:
		btst		#2,d1
		beq			cDS5
		move.w		#1,diLocked(a3)
		bra			cDSDone
cDS5:
		clr.w		diLocked(a3)
cDSDone:
		subq.w		#1,sys+subprFlag
		movem.l		(sp)+,d3-d7/a2-a6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Bildschirmschoner
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
OldKEYBD:
	dc.l		0

NewKEYBD:
		tst.w		sys+scSwitch		; Bildschirmschoner ausgeschalten ?
		beq			DoOldKEYBD

		move.l		d0,-(sp)
		moveq.l		#0,d0
		move.w		sys+scTime,d0
		mulu		#10,d0
		add.l		sys+tsecCount,d0
		move.l		d0,sys+scOutTime
		move.l		(sp)+,d0
		tst.w		sys+scIsOn			; wenn Bildschirm an, dann weiter
		bne			DoOldKEYBD
		move.w		#1,sys+scFlag		; Bildschirm anschalten
DoOldKEYBD:
		move.l		OldKEYBD(pc),-(sp)	; Original routine aufrufen
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neuer HZ200 Vektor
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
Old200HZ:
	dc.l		0

New200HZ:
		subq.w		#1,sys+secTenth		; egal was los ist, es wird
		bne			_DoOld200HZ			; nur alle 1/10 Sekunde
										; nachgeschaut
		move.l		a2,-(sp)
		move.l		d0,-(sp)
		lea.l		sys(pc),a2
		move.w		#20,secTenth(a2)
		
		addq.l		#1,tsecCount(a2)	; 1/10 sekunden zÑhler
		move.l		tsecCount(a2),d0
		
		tst.w		scFlag(a2)			; Bildschim invertieren ?
		bne			ScHere

		tst.w		scSwitch(a2)		; Bildschirmschoner eingeschalten ?
		beq			HZ200Spooler
		
		cmp.l		scOutTime(a2),d0	; Bildschirm jetzt invertieren ?
		blt			HZ200Spooler
		
		move.l		d1,-(sp)
		moveq.l		#0,d1
		move.w		scTime(a2),d1
		mulu		#10,d1
		add.l		d0,d1
		move.l		d1,scOutTime(a2)
		move.l		(sp)+,d1

ScHere:
		clr.w		scFlag(a2)			; nicht mehr invertieren
		bsr			InvertScreen
		not.w		scIsOn(a2)

HZ200Spooler:
		tst.w		hz200Flag(a2)		; dieser Teil arbeitet nicht
		bne			DoOld200HZ			; rekursiv
		tst.w		subprFlag(a2)
		bne			DoOld200HZ
		
		tst.w		spOn(a2)			; Spooler an ?
		beq			HZ200Cache
		tst.l		spNChars(a2)		; Zeichen im Spooler ?
		bne			HZ200GoOut
HZ200Cache:
		cmp.l		ciTimeOut(a2),d0
		blt			DoOld200HZ
		add.l		ciDelay(a2),d0
		move.l		d0,ciTimeOut(a2)
		tst.w		ciDirty(a2)
		bne			HZ200GoOut
DoOld200HZ:
		move.l		(sp)+,d0
		move.l		(sp)+,a2
_DoOld200HZ:
		move.l		Old200HZ(pc),-(sp)
		rts

HZ200GoOut:






		addq.w		#1,hz200Flag(a2) ; sperre weitere HZ200 Interrupts
		move.l		(sp)+,d0
		move.l		(sp)+,a2
		tst.w		_longframe
		beq			HZ200NoTT
		move.w		6(sp),-(sp)		; Da ich keine Spezifikationen zu dem
									; speziellen MC68030-Register habe
									; wird das alte einfach kopiert
HZ200NoTT:
		sub.l		#46,$4a2			; fÅr BIOS Dispatcher
		pea			HZ200Back(pc)
		move.w		#$2000,-(sp)			; Super-Modus
		move.l		Old200HZ(pc),-(sp)
		rts
HZ200Back:
		movem.l		d0-a6,-(sp)
		lea.l		sys(pc),a2
		
		tst.w		spOn(a2)			; Spooler an ?
		beq			NoSpWork
		tst.l		spNChars(a2)		; Zeichen im Spooler ?
		beq			NoSpWork
		bsr			_OutputChar
NoSpWork:
		tst.w		ciDirty(a2)
		beq			NoCaWork
		bsr			UpdateCache
NoCaWork:
		add.l		#46,$4a2				; BIOS Dispatcher
		movem.l		(sp)+,d0-a6
		clr.w		sys+hz200Flag			; HZ200 Interrupt freigeben
		rte




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Invertiert den Bildschirm (Super-Modus)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InvertScreen:
		movem.l		a0-a1/d0-d1,-(sp)
		moveq.l		#7,d0
		move.l		#colregs,a0
		lea.l		(sys+colsav)(pc),a1

ISLoop:
		move.l		(a0)+,d1
		not.l		d1
		move.l		d1,(a1)+
		dbf			d0,ISLoop

		move.l		#sys+colsav,colorptr
		movem.l		(sp)+,a0-a1/d0-d1
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Mausbeschleuniger
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	dc.b		"XBRA"
	dc.b		"TAcc"
OldMOUSE:
	dc.l		0

NewMOUSE:
		move.l		a2,-(sp)
		lea.l		sys(pc),a2
		cmp.b		#$f8,(a0)
		bcs			DoOldMOUSE
		cmp.b		#$fc,(a0)
		bcc			DoOldMOUSE
		tst.w		smSwitch(a2)
		beq			DoOldMOUSE
		move.w		d0,-(sp)
		move.w		d1,-(sp)
		move.l		a1,-(sp)

		addq.l		#1,a0
		lea.l		xList(a2),a1
		move.w		x(a2),d1
		move.b		(a0),d0			; x
		bsr			_Move
		move.b		d0,(a0)+
		move.w		d1,x(a2)

		lea.l		yList(a2),a1
		move.w		y(a2),d1
		move.b		(a0),d0
		bsr			_Move
		move.b		d0,(a0)
		move.w		d1,y(a2)
		subq.l		#2,a0

		move.l		(sp)+,a1
		move.w		(sp)+,d1
		move.w		(sp)+,d0
DoOldMOUSE:
		move.l		(sp)+,a2
		move.l		OldMOUSE(pc),-(sp)
		rts

_Move:
		bne			Offset
		tst.w		smKeep
		beq			NoKeep
		clr.w		d1
NoKeep:
		rts
Offset:
		bmi			Negativ
		subq.b		#1,d0
		bne			Bigger
		addq.w		#1,d1
		cmp.w		#1,d1			*
		bgt			MovePos
		rts
MovePos:
		addq.b		#1,d0
		clr.w		d1
		rts
Bigger:
		cmp.b		#9,d0
		ble			OffOK
		move.b		#9,d0
OffOK:
		clr.w		d1
		ext.w		d0
		move.b		0(a1,d0.w),d0
		rts
Negativ:
		addq.b		#1,d0
		bne			Lower
		subq.w		#1,d1
		cmp.w		#-1,d1		*
		blt			MoveNeg
		rts
Lower:
		cmp.b		#-9,d0
		bge			OffOK
		move.b		#-9,d0
		bra			OffOK

MoveNeg:
		subq.b		#1,d0
		clr.w		d1
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neuer BIOS-Trap
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
OldBIOS:
dc.l			0

NewBIOS:
				tst.w		sys+spOn
				beq			DoOldBIOS
				lea.l		6(sp),a0
				tst.w		_longframe
				beq			BIOSGo
				addq.l		#2,a0
BIOSGo:
				btst		#5,(sp)
				bne			BIOSVarsOK
				move.l		usp,a0
BIOSVarsOK:
				tst.w		2(a0)				; Null device ?
				bne			DoOldBIOS
				cmp.w		#8,(a0)				; Bcostat
				bne			BVN1
				movem.l		a2-a6/d2-d7,-(sp)
				jsr			NewBcostat0
				movem.l		(sp)+,a2-a6/d2-d7
				rte
BVN1:		
				cmp.w		#3,(a0)				; Bconout
				bne			DoOldBIOS
				movem.l		a2-a6/d2-d7,-(sp)
				move.l		2(a0),-(sp)			; dev, Zeichen
				jsr			NewBconout0
				addq.l		#4,sp
				movem.l		(sp)+,a2-a6/d2-d7
				rte
DoOldBIOS:
				move.l		OldBIOS(pc),a0
				jmp			(a0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neue Bcostat0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
OldBcostat0:
dc.l			0

NewBcostat0:
				tst.w		sys+spOn				; Spooler an ?
				beq			_BCostat0
				jsr			InputStatus(pc)
				rts
_BCostat0:
				tst.w		sys+spQuick				; Schnelle Ausgabe ?
				bne			BCSQuick
				clr.w		-(sp)
				move.l		OldBcostat0(pc),a1		; Original aufrufen
				jsr			(a1)
				addq.l		#2,sp
				rts
BCSQuick:
				moveq.l		#-1,d0					; default OK
				btst		#0,$fa01.w
				beq			NB0OK
				moveq.l		#0,d0					; Busy
NB0OK:
				rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neue Bconout0
;;	Zeichen bei 4(sp)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
OldBconout0:
dc.l			0

NewBconout0:
				move.l		4(sp),d0			; Zeichen
				tst.w		sys+spOn			; Spooler an ?
				beq			_BConout0
				jsr			InputChar
				rts
_BConout0:
				addq.l		#1,sys+spTChars
				tst.w		sys+spQuick			; Schnelle Ausgabe ?
				bne			BCOQuick
				move.l		d0,-(sp)
				move.l		OldBconout0(pc),a1	; Original aufrufen
				jsr			(a1)
				addq.l		#4,sp
				rts
BCOQuick:
				move.l		_hz_200,d1
				add.l		#15*200,d1			; 15 Sekunden time out
BCOQLoop:
				btst		#0,$fa01.w
				beq			BCOQGo
				tst.w		sys+spRun			; War Fehler schon mal ?
				bne			BCOQErr
				cmp.l		_hz_200,d1
				bls			BCOQLoop
				move.w		#1,sys+spRun		; time out Fehler merken
BCOQErr:
				moveq.l		#0,d0
				rts
BCOQGo:
				clr.w		sys+spRun			; Fehler-Flag lîschen
				move.w		sr,d1
				ori.w		#$700,sr			; Interrupts sperren
				move.b		#$f,$8800.w			; Port B wÑhlen
				move.b		d0,$8802.w			; Zeichen nach I/O-Register
				move.b		#$e,$8800.w			; Port A wÑhlen
				move.b		$8800.w,d2			; Daten lesen

				nop								; fÅr langsame Drucker

				bclr		#5,d2				; Strobe setzen
				move.b		d2,$8802.w			; setzen
				
				nop								; fÅr langsame Drucker

				bset		#5,d2				; Strobe wieder lîschen
				move.b		d2,$8802.w			; und setzen
				move.w		d1,sr
				
				moveq.l		#-1,d0
				rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	InputStatus( void );
;;	ERROR	0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InputStatus:
		lea.l		sys(pc),a2
_InputStatus:
		addq.w		#1,subprFlag(a2)
		tst.l		spNChars(a2)
		bne			ISGoOn
		clr.w		spRun(a2)
		move.w		#4,spInPos(a2)
		move.w		#4,spOutPos(a2)
		bra			SpRetOK
ISGoOn:
		tst.w		spRun(a2)
		bne			SpRetOK

		move.w		spInPos(a2),d1
		cmp.w		blkSiz(a2),d1			; end of block ?
		blt			SpRetOK
		
		bsr			_GetFreeBlk
		move.l		a0,d0
		beq			SpRetErr
		addq.w		#1,spBlkNum(a2)
		move.l		spInBlk(a2),a1
		move.l		a0,(a1)
		move.w		#4,spInPos(a2)
		move.l		a0,spInBlk(a2)
		clr.l		(a0)
		bra			SpRetOK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	InputChar( int c );
;;	ERROR	0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InputChar:
		lea.l		sys(pc),a2
		addq.w		#1,subprFlag(a2)
		tst.w		spRun(a2)
		bne			SpRetErr

		moveq.l		#127,d1
		add.l		d1,d1
		add.l		tsecCount(a2),d1			; time out is 15 seconds
		move.w		d0,-(sp)
		move.l		d1,-(sp)
ICLoop:
		bsr			_InputStatus
		bne			ICOK
		bsr			_OutputChar
		move.l		(sp),d1
		cmp.l		tsecCount(a2),d1
		bgt			ICLoop
		addq.w		#1,spRun(a2)
		bra			_SpRetErr
ICOK:
		tst.w		spRun(a2)
		bne			_SpRetErr
		addq.l		#4,sp
		move.w		(sp)+,d0
		move.l		spInBlk(a2),a0
		move.w		spInPos(a2),d1
		move.b		d0,0(a0,d1.w)
		addq.l		#1,spNChars(a2)
		addq.w		#1,d1
		move.w		d1,spInPos(a2)
SpRetOK:
		subq.w		#1,subprFlag(a2)
		moveq.l		#-1,d0
		rts
_SpRetErr:
		addq.l		#6,sp
SpRetErr:
		subq.w		#1,subprFlag(a2)
		moveq.l		#0,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	void	OutputChar( void )
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_OutputChar:
		move.l		_hz_200,d3
		add.l		spRate(a2),d3
		move.l		spOutBlk(a2),a3
		move.w		spOutPos(a2),d4
OCLoop:
		cmp.l		_hz_200,d3
		ble			OCOK
		movem.l		d3-d4/a2-a3,-(sp)
		bsr			_BCostat0
		movem.l		(sp)+,d3-d4/a2-a3
		tst.w		d0
		beq			OCLoop
		tst.l		spNChars(a2)
		beq			OCOK
		moveq.l		#0,d0
		move.b		0(a3,d4.w),d0
		subq.l		#1,spNChars(a2)
		addq.w		#1,d4
		movem.l		d3-d4/a2-a3,-(sp)
		jsr			_BConout0
		movem.l		(sp)+,d3-d4/a2-a3
		cmp.w		blkSiz(a2),d4
		bne			OCLoop
		tst.l		(a3)
		beq			OCOK
		move.l		(a3),spOutBlk(a2)
		moveq.l		#4,d4
		move.l		blkFrees(a2),a0
		move.l		a0,(a3)
		move.l		a3,blkFrees(a2)
		move.l		spOutBlk(a2),a3
		addq.w		#1,blkFreeNum(a2)
		subq.w		#1,spBlkNum(a2)
		bra			OCLoop
OCOK:
		move.w		d4,spOutPos(a2)
		rts

		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neuer XBIOS-Trap
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
OldXBIOS:
dc.l			0

NewXBIOS:
				tst.w		sys+ciDirty
				beq			DoOldXBIOS
				lea.l		6(sp),a1
				tst.w		_longframe
				beq			XBIOSGo
				addq.l		#2,a1
XBIOSGo:
				btst		#5,(sp)
				bne			XBIOSVarsOK
				move.l		usp,a1
XBIOSVarsOK:
				move.w		(a1),d1
				cmp.w		#8,d1
				beq			DoUpDate
				cmp.w		#9,d1
				beq			DoUpDate
				cmp.w		#10,d1
				beq			DoUpDate
				cmp.w		#19,d1
				beq			DoUpDate
				cmp.w		#42,d1
				beq			DoUpDate
				cmp.w		#43,d1
				bne			DoOldXBIOS
DoUpDate:
				movem.l		d3-d7/a2-a6,-(sp)
				bsr			UpdateCache
				movem.l		(sp)+,d3-d7/a2-a6
DoOldXBIOS:
				move.l		OldXBIOS(pc),a1
				jmp			(a1)

