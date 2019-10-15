;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	AUTOINIT.S									;;
;;																		;;
;;																		;;
;;		Author			:	Jrgen Lietzow fr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	26.02.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		.IMPORT	Start0
		.IMPORT	ResetSpooler, DemandBlock
		.IMPORT	OutputChar, InputChar, InputStatus
				
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

		dc.b	"TAcc 1.50"				; version
		dcb.b	10 - 9,0

;	fr den Bildschirmschoner

		dc.w	1						; scSwitch
		dc.w	90						; scTime
		dc.l	_OldKEYBD				; OldKEYBD
		dc.l	_Old200HZ				; Old200HZ
		dc.l	_NewKEYBD				; NewKEYBD
		dc.l	_New200HZ				; New200HZ
		dc.l	_InvertScreen			; InvertScreen
		dcb.w	16,0					; colsav
		dc.w	200						; secCount
		dc.w	-1						; scIsOn
		dc.w	90						; scCount
		dc.w	0						; scFlag

;	fr den Mausbeschleuniger

		dc.l	_OldMOUSE				; OldMOUSE
		dc.w	1						; smSwitch
		dc.w	0						; smKeep
		dc.l	_NewMOUSE				; NewMOUSE
		dc.b	-70, -70, -70, -60, -50, -32, -16,  -8, -3
		dc.b	0						; xList
		dc.b	3,     8,  16,  32,  50,  60,  70,  70, 70

		dc.b	-70, -70, -70, -60, -50, -32, -16,  -8, -3
		dc.b	0						; yList
		dc.b	3,     8,  16,  32,  50,  60,  70,  70, 70

		.EVEN

		dc.w	0						; x
		dc.w	0						; y

;	fr die RAM-Disk

		dc.l	_OldMediach
		dc.l	_NewMediach
		dc.l	_OldRW
		dc.l	_NewRW
		dc.l	_OldBPB
		dc.l	_NewBPB
		
		dc.w	0						; rd_installed
		dc.w	0						; rd_drive
		dc.w	0						; rd_size
		dc.w	0						; rd_locked
		dc.l	0						; rd_maxsec
		dc.l	0						; rd_data
		dc.l	0						; rd_bpb

		dc.l	0						; ph_head
		dc.w	0						; OSVers
		dc.w	20						; secTenth
		dc.w	0						; in200HZ

;	fr den Spooler

		dc.w	0						; inSys_flag

		dc.w	0						; spStatErr
		dc.w	10						; spRate
		dc.w	0						; spOn
		dc.w	0						; spQuick
		dc.l	0						; spNChars
		dc.l	0						; spNBlocks
		dc.l	0						; spLockTime
		dc.w	0						; spDemand
		
		dc.w	0						; spRun
		dc.w	0						; spLocked
		dc.w	0						; spLockCount
		dc.w	0						; spLastType
		dc.l	0						; spLast
		dc.w	0						; spInPos
		dc.w	0						; spOutPos
		dc.l	0						; spOutFree
		dc.l	0						; spFrees
		dc.l	0						; spInBlk
		dc.l	0						; spOutBlk
		dc.l	0						; spBMap
		
		dcb.b	40,0					; spFile
		dcb.b	d_dta_length,0			; spDTA

		dc.w	0						; spGEMDOSFlag
		dc.w	0						; spBconstatFlag
		dc.w	0						; spGDBufPos
		dcb.b	512,0					; spGDBuf

		dc.l	_OldGEMDOS
		dc.l	_OldBIOS
		dc.l	_OldXBIOS
		dc.l	_OldBcostat0
		dc.l	_OldBconout0
	
		dc.l	_NewGEMDOS
		dc.l	_NewBIOS
		dc.l	_NewXBIOS
		dc.l	_NewBcostat0
		dc.l	_NewBconout0
		
		dc.l	ResetSpooler
		dc.l	DemandBlock

; SYSEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RAM-Disk Treiberfunktion: hdv_mediach
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
_OldMediach:
	dc.l		0

_NewMediach:

			move.w		4(sp),d0
			cmp.w		sys+rd_drive,d0
			bne			DoOldMediach
			moveq.l		#0,d0
			rts
			
DoOldMediach:
			move.l		_OldMediach(pc),a0
			jmp			(a0)
			
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RAM-Disk Treiberfunktion: hdv_getbpb
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
_OldBPB:
	dc.l		0

_NewBPB:
			move.w		4(sp),d0
			cmp.w		sys+rd_drive,d0
			bne			DoOldBPB
			move.l		sys+rd_bpb,d0
			rts
			
DoOldBPB:
			move.l		_OldBPB(pc),a0
			jmp			(a0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RAM-Disk Treiberfunktion: hdv_rw
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
_OldRW:
	dc.l		0

_NewRW:
			move.w		rw_drive(sp),d0
			cmp.w		sys+rd_drive(pc),d0
			bne			DoOldRW
			
			lea.l		sys(pc),a2
			moveq.l		#0,d1
			move.w		rw_recno(sp),d1		; negative Sektornummer ?
			bmi			RWErr1
			moveq.l		#0,d2
			move.w		rw_count(sp),d2		; count == 0 ?
			beq			RWErr1
			bmi			RWErr1				; count < 0 ?
			add.l		d1,d2
			cmp.l		rd_maxsec(a2),d2	; Maximale Sektornummer ?
			bgt			RWErr1
			add.l		d1,d1
			lsl.l		#8,d1				; * 512
			
			move.w		rw_flag(sp),d0
			bne			TstWrite
			move.l		rw_buf(sp),a1
			move.l		rd_data(a2),a0
			add.l		d1,a0
			move.l		a1,d0
			beq			RWErr2
			btst.b		#0,d0
			beq			RWQuick
			bra			RWSlow
DoOldRW:
			move.l		_OldRW(pc),a0
			jmp			(a0)
RWErr1:
			moveq.l		#-8,d0			; BIOS-Error SECTOR_NOT_FOUND
			rts
RWErr2:
			moveq.l		#-5,d0			; BIOS-Error BAD_REQUEST
			rts
TstWrite:
			subq.w		#1,d0
			bne			RWErr2
			tst.w		rd_locked(a2)
			bne			RWErr2
			move.l		rw_buf(sp),a0
			move.l		rd_data(a2),a1
			add.l		d1,a1
			move.l		a0,d0
			beq			RWErr2
			btst.b		#0,d0
			beq			RWQuick
RWSlow:
			move.w		rw_count(sp),d0
			bra			RWSEnd
RWSLoop1:
			moveq.l		#63,d1
RWSLoop2:			
			move.b		(a0)+,(a1)+
			move.b		(a0)+,(a1)+
			move.b		(a0)+,(a1)+
			move.b		(a0)+,(a1)+
			dbf			d1,RWSLoop2
RWSEnd:
			dbf			d0,RWSLoop1
			moveq.l		#0,d0
			rts

RWQuick:
			move.w		rw_count(sp),-(sp)
CSLoop:
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,52(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,104(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,156(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,208(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,260(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,312(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,364(a1)
			movem.l		(a0)+,d0-d7/a2-a6
			movem.l		d0-d7/a2-a6,416(a1)
			movem.l		(a0),d0-d7/a2-a4
			movem.l		d0-d7/a2-a4,468(a1)
		
			lea.l		512(a1),a1
			subq.w		#1,(sp)
			bne			CSLoop
			addq.l		#2,sp
		
			moveq.l		#0,d0	
			rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Bildschirmschoner
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
_OldKEYBD:
	dc.l		0

_NewKEYBD:
		tst.w		sys+scSwitch		; Bildschirmschoner ausgeschalten ?
		beq			DoOldKEYBD
		move.w		sys+scTime(pc),sys+scCount	; scTime wieder herunterz„hlen
		tst.w		sys+scIsOn			; wenn Bildschirm an, dann weiter
		bne			DoOldKEYBD
		move.w		#1,sys+scFlag		; Bildschirm anschalten
DoOldKEYBD:
		move.l		_OldKEYBD(pc),-(sp)	; Original routine aufrufen
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Bildschirmschoner + Spooler
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.b		"XBRA"
	dc.b		"TAcc"
_Old200HZ:
	dc.l		0

_New200HZ:
		subq.w		#1,sys+secTenth		; egal was los ist, es wird
		bne			_DoOld200HZ			; nur alle 1/10 Sekunde
										; nachgeschaut
		move.l		a0,-(sp)
		lea.l		sys(pc),a0
		move.w		#20,secTenth(a0)
		
		tst.w		scFlag(a0)			; Bildschim invertieren ?
		bne			ScHere

		tst.w		scSwitch(a0)		; Bildschirmschoner eingeschalten ?
		beq			HZ200Spooler

		subq.w		#1,secCount(a0)		; eine Sekunde vorbei ?
		bne			HZ200Spooler

		move.w		#10,secCount(a0)

		subq.w		#1,scCount(a0)		; Auszeit vorbei ?
		bne			HZ200Spooler

ScHere:
		clr.w		scFlag(a0)			; nicht mehr invertieren
		move.w		scTime(a0),scCount(a0)
		bsr			_InvertScreen
		not.w		scIsOn(a0)

HZ200Spooler:
		tst.w		spOn(a0)			; Spooler an ?
		beq			DoOld200HZ
		tst.w		inSys_flag(a0)		; im Betriebssystem ?
		bne			DoOld200HZ
		tst.l		spNChars(a0)		; Zeichen im Spooler ?
		bne			HZ200GoOut

DoOld200HZ:
		move.l		(sp)+,a0
_DoOld200HZ:
		move.l		_Old200HZ(pc),-(sp)
		rts

HZ200GoOut:
		tst.w		in200HZ(a0)			; Dieser Teil l„uft nicht rekursiv
		bne			DoOld200HZ
		addq.w		#1,in200HZ(a0)
		move.l		(sp)+,a0
		tst.w		_longframe
		beq			HZ200NoTT
		move.w		6(sp),-(sp)		; Da ich keine Spezifikationen zu dem
									; speziellen MC68030-Register habe
									; wird das alte einfach kopiert
HZ200NoTT:
		pea			HZ200Back(pc)
		move.w		#$2000,-(sp)			; Super-Modus
		move.l		_Old200HZ(pc),-(sp)
		rts
HZ200Back:
		movem.l		a0-a2/d0-d3,-(sp)
		jsr			OutputChar(pc)
		movem.l		(sp)+,a0-a2/d0-d3
		clr.w		sys+in200HZ
		rte




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Invertiert den Bildschirm (Super-Modus)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_InvertScreen:
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
_OldMOUSE:
	dc.l		0

_NewMOUSE:
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
		move.l		_OldMOUSE(pc),-(sp)
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
_OldBIOS:
dc.l			0

_NewBIOS:
				tst.w		sys+spDemand
				beq			NBNoDemand
				tst.w		sys+inSys_flag
				bne			NBNoDemand
				jsr			DemandBlock(pc)
NBNoDemand:
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
				bne			BIOSDoOld
				cmp.w		#8,(a0)				; Bcostat
				bne			BVN1
				jsr			_NewBcostat0
				rte
BVN1:		
				cmp.w		#3,(a0)				; Bconout
				bne			BIOSDoOld
				move.l		2(a0),-(sp)			; dev, Zeichen
				jsr			_NewBconout0
				addq.l		#4,sp
				rte
BIOSDoOld:		
				tst.l		sys+spNChars		; Wenn keine Zeichen im
				beq			DoOldBIOS			; Spooler, ist Rest uninteressant
				tst.w		sys+inSys_flag
				bne			DoOldBIOS
				add.w		#1,sys+inSys_flag

				move.l		BIOSStack(pc),a1
				move.l		2(sp),(a1)+
				move.l		a1,BIOSStack
				move.l		#BIOSBack,2(sp)
DoOldBIOS:
				move.l		_OldBIOS(pc),a0
				jmp			(a0)
BIOSBack:
				move.l		BIOSStack(pc),a1
				move.l		-(a1),-(sp)
				move.l		a1,BIOSStack
				sub.w		#1,sys+inSys_flag
				rts


BIOSStack:		dc.l		_BIOSStack
_BIOSStack:		ds.l		20

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neue Bcostat0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
_OldBcostat0:
dc.l			0

_NewBcostat0:
				tst.w		sys+spOn				; Spooler an ?
				beq			_BCostat0
				
				tst.w		sys+inSys_flag	; Wenn vom GEMDOS aufgerufen
				bne			_BCostat0		; Pech gehabt
				add.w		#1,sys+inSys_flag
				jsr			InputStatus(pc)
				sub.w		#1,sys+inSys_flag
				rts
_BCostat0:
				tst.w		sys+spQuick				; Schnelle Ausgabe ?
				bne			BCSQuick
				tst.w		sys+OSVers				; BlitterTOS oder „lter
				beq			BCSStandard
				add.w		#1,sys+inSys_flag
				move.l		_OldBcostat0,a1			; Original aufrufen
				jsr			(a1)
				sub.w		#1,sys+inSys_flag
				rts
BCSStandard:
				add.w		#1,sys+inSys_flag
				bsr			XBCSTrap
				sub.w		#1,sys+inSys_flag		; altes TOS
				rts
BCSQuick:
				add.w		#1,sys+inSys_flag
				moveq.l		#-1,d0					; default OK
				btst		#0,$fa01.w
				beq			NB0OK
				moveq.l		#0,d0					; Busy
NB0OK:
				sub.w		#1,sys+inSys_flag		; neue schnelle Version
				rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	XBcostat0: wird von InputStatus() aufgerufen
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XBcostat0:
				tst.w		sys+spQuick
				bne			BCSQuick
				tst.w		sys+OSVers			; „lter als Blitter TOS ?
				beq			XBCSTrap
				movem.l		d3-d7/a2-a6,-(sp)
				move.l		_OldBcostat0,a0		; Original aufrufen
				jsr			(a0)
				movem.l		(sp)+,d3-d7/a2-a6
				rts
XBCSTrap:
				move.l		a2,-(sp)
				move.l		#$80000,-(sp)	; alter BIOS-Trap
				move.l		#XBCSBack,-(sp)	; hier bleibt zwar die
				move.w		sr,-(sp)		; Parameterbergabe des
				move.l		_OldBIOS,a0		; MC68030 unbercksichtigt,
				jmp			(a0)			; allerdings l„uft ein
											; MC68030 auch nicht mit
XBCSBack:									; alten TOS-Versionen
				addq.l		#4,sp
				move.l		(sp)+,a2
				rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neue Bconout0
;;	Zeichen bei 4(sp)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
_OldBconout0:
dc.l			0

_NewBconout0:
				move.l		4(sp),d0			; Zeichen
				tst.w		sys+spOn			; Spooler an ?
				beq			_BConout0

				add.w		#1,sys+inSys_flag
				jsr			InputChar
				sub.w		#1,sys+inSys_flag
				rts
_BConout0:
				tst.w		sys+spQuick			; Schnelle Ausgabe ?
				bne			BCOQuick
				tst.w		sys+OSVers			; BlitterTOS oder „lter
				beq			BCOStandard
				add.w		#1,sys+inSys_flag
				move.l		d0,-(sp)
				move.l		_OldBconout0,a1		; Original aufrufen
				jsr			(a1)
				sub.w		#1,sys+inSys_flag
				addq.l		#4,sp
				rts
BCOStandard:
				add.w		#1,sys+inSys_flag
				bsr			XBCOTrap
				sub.w		#1,sys+inSys_flag	; altes TOS
				rts
BCOQuick:
				move.l		_hz_200,d1
				add.l		#15*200,d1			; 15 Sekunden time out
BCOQLoop:
				btst		#0,$fa01.w
				beq			BCOQGo
				tst.w		sys+spStatErr		; War Fehler schon mal ?
				bne			BCOQErr
				cmp.l		_hz_200,d1
				bls			BCOQLoop
				move.w		#1,sys+spStatErr	; time out Fehler merken
BCOQErr:
				moveq.l		#0,d0
				rts
BCOQGo:
				clr.w		sys+spStatErr		; Fehler-Flag l”schen
				add.w		#1,sys+inSys_flag
				move.w		sr,d1
				ori.w		#$700,sr			; Interrupts sperren
				move.b		#$f,$8800.w			; Port B w„hlen
				move.b		d0,$8802.w			; Zeichen nach I/O-Register
				move.b		#$e,$8800.w			; Port A w„hlen
				move.b		$8800.w,d2			; Daten lesen

				nop								; fr langsame Drucker

				bclr		#5,d2				; Strobe setzen
				move.b		d2,$8802.w			; setzen
				
				nop								; fr langsame Drucker

				bset		#5,d2				; Strobe wieder l”schen
				move.b		d2,$8802.w			; und setzen
				move.w		d1,sr
				
				moveq.l		#-1,d0
				sub.w		#1,sys+inSys_flag
				rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	XBconout0: wird von OutputChar( char ) aufgerufen
;;	Zeichen in d0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XBconout0:
				tst.w		sys+spQuick
				bne			BCOQGo
				tst.w		sys+OSVers			; „lter als Blitter TOS ?
				beq			XBCOTrap
				movem.l		d3-d7/a2-a6,-(sp)
				move.l		_OldBconout0,a0		; Original aufrufen
				move.l		d0,-(sp)
				jsr			(a0)
				addq.l		#4,sp
				movem.l		(sp)+,d3-d7/a2-a6
				rts
XBCOTrap:
				move.l		a2,-(sp)
				move.l		d0,-(sp)
				move.w		#3,-(sp)			; alter BIOS-Trap
				move.l		#XBCOBack,-(sp)
				move.w		sr,-(sp)
				move.l		_OldBIOS,a0
				jmp			(a0)
XBCOBack:
				addq.l		#6,sp
				move.l		(sp)+,a2
				rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neuer XBIOS-Trap
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
_OldXBIOS:
dc.l			0

_NewXBIOS:
				tst.l		sys+spNChars
				beq			DoOldXBIOS
				tst.w		sys+spDemand
				beq			NXBNoDemand
				tst.w		sys+inSys_flag
				bne			NXBNoDemand
				jsr			DemandBlock(pc)
NXBNoDemand:
				addq.w		#1,sys+inSys_flag
				move.l		XBIOSStack(pc),a1
				move.l		2(sp),(a1)+
				move.l		a1,XBIOSStack
				move.l		#XBIOSBack,2(sp)
DoOldXBIOS:
				move.l		_OldXBIOS(pc),a1
				jmp			(a1)
XBIOSBack:
				move.l		XBIOSStack(pc),a1
				move.l		-(a1),-(sp)
				move.l		a1,XBIOSStack
				subq.w		#1,sys+inSys_flag
				rts

XBIOSStack:		dc.l		_XBIOSStack
_XBIOSStack:	ds.l		20


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Neuer GEMDOS-Trap
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dc.b			"XBRA"
dc.b			"TAcc"
_OldGEMDOS:
dc.l			0

_NewGEMDOS:
				tst.w		sys+spDemand
				beq			NGDNoDemand
				jsr			DemandBlock(pc)
NGDNoDemand:
				lea.l		6(sp),a0
				tst.w		_longframe
				beq			GEMDOSGo
				addq.l		#2,a0
GEMDOSGo:
				btst		#5,(sp)
				bne			GEMDOSVarsOK
				move.l		usp,a0
GEMDOSVarsOK:
				move.w		#1,sys+inSys_flag

											; folgende Funktionen
											; verschwinden fr l„ngere
											; Zeit im Betriebssystem,
											; und kehren evtl. *nicht*
											; zurck !!!
				cmp.w		#75,(a0)			; Pexec
				beq			GEMDOSFirstOld
				cmp.w		#76,(a0)			; Pterm
				beq			GEMDOSFirstOld
				cmp.w		#49,(a0)			; Ptermres
				beq			GEMDOSFirstOld
				cmp.w		#0,(a0)				; Pterm0
				beq			GEMDOSFirstOld
				
				addq.w		#1,sys+spGEMDOSFlag
				move.l		GEMDOSStack(pc),a1
				move.l		2(sp),(a1)+
				move.l		a1,GEMDOSStack
				move.l		#GEMDOSBack,2(sp)
GEMDOSFirstOld:
				move.l		_OldGEMDOS(pc),a1
				jmp			(a1)
GEMDOSBack:
				move.l		GEMDOSStack(pc),a1
				move.l		-(a1),-(sp)
				move.l		a1,GEMDOSStack

				lea.l		sys(pc),a1
				clr.w		inSys_flag(a1)
				clr.w		spGEMDOSFlag(a1)

				move.w		spGDBufPos(a1),d1
				beq			GDB1
				movem.l		a3-a4/d3-d4,-(sp)
				moveq.l		#0,d3
				move.w		d1,d4
				move.l		a1,a3
				clr.w		spGDBufPos(a3)
				lea.l		spGDBuf(a3),a4
GDBLoop:
				moveq.l		#0,d0
				move.b		0(a4,d3.w),d0
				move.w		d0,-(sp)
				move.l		#$30000,-(sp)
				trap		#13
				addq.l		#6,sp
				tst.w		d0
				beq			GDBDone
				addq.w		#1,d3
				cmp.w		d4,d3
				bmi			GDBLoop
GDBDone:
				move.w		d3,d0
				clr.w		spBcostatFlag(a3)
				movem.l		(sp)+,a3-a4/d3-d4
				rts
GDB1:
				tst.w		spBcostatFlag(a1)
				beq			GDB2

				clr.w		spBcostatFlag(a1)
				clr.w		-(sp)
				move.w		#8,-(sp)
				trap		#13
				addq.l		#4,sp
GDB2:
				rts
				
GEMDOSStack:		dc.l		_GEMDOSStack
_GEMDOSStack:		ds.l		20


