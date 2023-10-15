;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 2/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG									;;
;;																		;;
;;		M O D U L E		:	AUTOTACC.S									;;
;;																		;;
;;																		;;
;;		Author			:	Jrgen Lietzow fr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	16.12.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.EXPORT __text, __data, __bss


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	AES				equ		200
	_form_do		equ		50
	_form_alert		equ		52
	_objc_edit		equ		46
	colorptr		equ		$45a
	colregs			equ		$ffff8240

	_p_cookies	 	equ		$5a0

	_resvalid		equ		$426
	_resvector		equ		$42a
	RESMAGIC		equ		$31415926


	SysGEM			equ		$88
	SysGEMDOS		equ		$84
	SysBIOS			equ		$B4
	SysXBIOS		equ		$B8
	Sys200HZ		equ		$114
	SysVSYNC		equ		$70
	SysKEYBD		equ		$118

	MAX_COOKIES		equ		64

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Struktur der Base page
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

TpaStart:
		ds.l 1
TpaEnd:
		ds.l 1
TextSegStart:
		ds.l 1
TextSegSize:
		ds.l 1
DataSegStart:
		ds.l 1
DataSegSize:
		ds.l 1
BssSegStart:
		ds.l 1
BssSegSize:
		ds.l 1
DtaPtr:
		ds.l 1
PntPrcPtr:
		ds.l 1
Reserved0:
		ds.l 1
EnvStrPtr:
		ds.l 1
Reserved1:
		ds.b 7
CurDrv:
		ds.b 1
Reserved2:
		ds.l 18
CmdLine:
		ds.b 128
BasePageSize:
		ds	 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	TOS-Accessory System Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.OFFSET 0

SYS:
version:		ds.b	10

;	fr den Bildschirmschoner

scSwitch:		ds.w	1
scTime:			ds.w	1
OldKEYBD:		ds.l	1
Old200HZ:		ds.l	1
NewKEYBD:		ds.l	1
New200HZ:		ds.l	1
InvertScreen:	ds.l	1
colsav:			ds.w	16
secCount:		ds.w	1
scIsOn:			ds.w	1
scCount:		ds.w	1
scFlag:			ds.w	1

;	fr den Mausbeschleuniger

OldMOUSE:		ds.l	1
smSwitch:		ds.w	1
smKeep:			ds.w	1
NewMOUSE:		ds.l	1
				ds.b	9
xList:			ds.b	1
				ds.b	9
				ds.b	9
yList:			ds.b	1
				ds.b	9
	.EVEN
x:				ds.w	1
y:				ds.w	1

SYSEND:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.BSS

__bss:		ds.l	1


		.DATA

__data:		dc.l	0


		.TEXT

__text:
Start:
		bra		Start0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Daten der System-Struktur
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sys:

		dc.b	"TAcc 1.30"				; version
		dcb.b	10 - 9,0

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
		move.w		sys+scTime-*-2(pc), sys+scCount	; scTime wieder herunterz„hlen
		tst.w		sys+scIsOn			; wenn Bildschirm an, dann weiter
		bne			DoOldKEYBD
		move.w		#1,sys+scFlag		; Bildschirm anschalten
DoOldKEYBD:
		move.l		_OldKEYBD-*-2(pc),-(sp)	; Original routine aufrufen
		rts


	dc.b		"XBRA"
	dc.b		"TAcc"
_Old200HZ:
	dc.l		0

_New200HZ:
		tst.w		sys+scFlag
		bne			ScHere

		tst.w		sys+scSwitch		; Bildschirmschoner eingeschalten ?
		beq			DoOld200HZ

		subq.w		#1,sys+secCount		; eine Sekunde vorbei ?
		bne			DoOld200HZ

		move.w		#200,sys+secCount

		subq.w		#1,sys+scCount		; Auszeit vorbei ?
		bne			DoOld200HZ
										; also ausschalten
;		tst.w		sys+scIsOn			; Bildschirm ausgeschalten ?
;		beq			DoOld200HZ

ScHere:
		clr.w		sys+scFlag
		move.w		sys+scTime-*-2(pc),sys+scCount
		bsr			_InvertScreen
		not.w		sys+scIsOn

DoOld200HZ:
		move.l		_Old200HZ-*-2(pc),-(sp)
		rts

_InvertScreen:
		movem.l		a0-a1/d0-d1,-(sp)
		moveq.l		#7,d0
		move.l		#colregs,a0
		lea.l		sys+colsav,a1

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
		lea.l		sys-*-2(pc),a2
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
		move.l		_OldMOUSE-*-2(pc),-(sp)
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


vecsav:		dc.l		0
valsav:		dc.l		0

reshand:
			clr.l		_p_cookies
			move.l		vecsav,_resvector
			move.l		valsav,_resvalid
			jmp			(a6)

Cookies:
		ds.l		MAX_COOKIES*8


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Initialisierung
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.TEXT

Install:

; Bildschirmschoner

		move.l		SysKEYBD,_OldKEYBD
		move.l		Sys200HZ,_Old200HZ

		move.l		#_NewKEYBD,SysKEYBD
		move.l		#_New200HZ,Sys200HZ

; Mausbeschleuniger kann wegen kb_mousevec (neu initialisiert bei
; GEM-Initialisierung) nicht aus dem AUTO-Ordner gestartet werden

		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	*GetCookie( long name );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetCookie:
		move.l		_p_cookies,a0
		move.l		a0,d1
		beq			RetCookie
LookCookie:
		move.l		(a0),d1
		beq			NoCookie
		cmp.l		d1,d0
		beq			RetCookie
		addq.l		#8,a0
		bra			LookCookie
NoCookie:
		sub.l		a0,a0
RetCookie:
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Install cookie jar
;;
;;				d0, d1:	Neues Cookie
;;	Rckgabe:	d0: 0 == OK
;;				d1: L„nge der Cookie-Liste
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InstCook:
			movem.l		d3-d5,-(sp)
			move.l		d0,d3
			move.l		d1,d4

			jsr			GetCookie
			move.l		a0,d0
			bne			ICExistErr

			move.l		_p_cookies,a0
			move.l		a0,d0
			beq			NewCookie

			moveq.l		#-1,d1
ICLoop:
			addq.l		#1,d1
			move.l		(a0),d0
			beq			ICEndC
			addq.l		#8,a0
			bra			ICLoop
ICEndC:
			cmp.l		4(a0),d1
			bge			ICExt
			move.l		(a0),8(a0)
			move.l		4(a0),12(a0)
			move.l		d3,(a0)+
			move.l		d4,(a0)+
			moveq.l		#0,d1
			bra			ICOK
ICExt:
			cmp.l		#MAX_COOKIES,d1
			bge			ICLenErr
			move.l		d1,d5
			move.l		_p_cookies,a1
			lea.l		Cookies,a0
			move.l		a0,_p_cookies
			bra			ICLoop1End
ICLoop1:
			move.l		(a1)+,(a0)+
			move.l		(a1)+,(a0)+
ICLoop1End:
			dbf			d5,ICLoop1

			move.l		d3,(a0)+
			move.l		d4,(a0)+
			clr.l		(a0)+
			addq.l		#8,d1
			move.l		d1,(a0)+
			lsl.l		#3,d1
			bra			ICOK

NewCookie:
			move.l		_resvalid,valsav
			move.l		_resvector,vecsav
			move.l		#reshand,_resvector
			move.l		#RESMAGIC,_resvalid

			lea.l		Cookies,a0
			move.l		a0,_p_cookies
			move.l		d3,(a0)+
			move.l		d4,(a0)+
			clr.l		(a0)+
			move.l		#8,(a0)
			moveq.l		#8*8,d1
ICOK:
			moveq.l		#0,d0
ICEnd:
			movem.l		(sp)+,d3-d5
			rts
ICLenErr:
			moveq.l		#1*4,d0
			bra			ICEnd
ICExistErr:
			moveq.l		#2*4,d0
			bra			ICEnd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Programm Start
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Start0:
        move.l		a0,d0
        beq			Start1
        move.w		3*4,d0
        bra			exit
Start1:
		move.l		4(sp),a3	; Base page pointer
		move.l		a3,_BasPag


; Programmgr”že ermitteln (incl. Stack)

		move.l		TextSegSize(a3),a0
		add.l		DataSegSize(a3),a0
		add.l		BssSegSize(a3),a0
		add.w		#BasePageSize,a0
		move.l		a0,_PgmSize

; Stack auf Long-Grenze setzen

		move.l		a3,d0
		add.l		a0,d0
		and.b		#$FC,d0
		move.l		d0,a7

; Speicher oberhalb Stack freigeben

		move.l		a0,-(sp)
		move.l		a3,-(sp)
		move.w		#0,-(sp)
		move.w		#74,-(sp)
		trap		#1
		lea.l		12(sp),sp

; In Super-Modus schalten

		clr.l		-(sp)
		move.w		#32,-(sp)
		trap		#1
		addq.l		#6,sp

		movem.l		d3/a4,-(sp)
		move.l		d0,a4

		move.l		#'TAcc',d0
		bsr			GetCookie
		move.l		a0,d0
		beq			NotInstalled
		move.w		#2*4,d0
		bra			exit

NotInstalled:

		move.l		#'TAcc',d0
		move.l		#sys,d1
		bsr			InstCook
		move.w		d0,d3
		move.l		d1,-(sp)
		bne			exit
		bsr			Install
		move.w		d3,d0

exit:
		move.w		d0,d3
		move.l		a4,-(sp)
		move.w		#32,-(sp)
		trap		#1							; Super
		addq.l		#6,sp

		lea.l		MesList,a0
		move.l		0(a0,d3.w),-(sp)
		move.w		#9,-(sp)					; Cconws
		trap		#1
		addq.l		#6,sp

		move.w		d3,d0
		move.l		(sp)+,d1
		movem.l		(sp)+,d3/a4
		move.w		d0,-(sp)
		beq			ExitRes

		move.w		#76,-(sp)
		trap		#1

ExitRes:
		move.l		#Cookies,d0
		add.l		d1,d0
		sub.l		a3,d0
		move.l		d0,-(sp)
		move.w		#49,-(sp)
		trap		#1


;	Pointer to base page

_BasPag:
		ds.l	1

;	Program size

_PgmSize:
		ds.l	1


	.DATA

m0:		dc.b	13, 10
		dc.b	"*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*", 13, 10
		dc.b	"*                                     *", 13, 10
		dc.b	"*   TOS - Accessory                   *", 13, 10
		dc.b	"*   ===============                   *", 13, 10
		dc.b	"*                                     *", 13, 10
		dc.b	"*   Residenter Programmteil           *", 13, 10
		dc.b	"*   installiert !                     *", 13, 10
		dc.b	"*                                     *", 13, 10
		dc.b	"*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*", 13, 10
		dc.b	0

m1:		dc.b	"!!!!!!!! Zu viele Cookies !!!!!!!!!", 13, 10, 13, 10
		dc.b	"TOS-Accessory Programmteil wurde", 13, 10
		dc.b	"nicht installiert !", 13, 10
		dc.b	"=====", 13, 10,
		dcb.b	10, 7
		dc.b	0

m2:		dc.b	"TOS-Accessory Programmteil", 13, 10, 13, 10
		dc.b	"ist bereits permanent installiert !", 13, 10
		dcb.b	10, 7
		dc.b	0

m3:		dc.b	"TOS-Accessory Programmteil darf nicht", 13, 10
		dc.b	"als Accessory gestartet werden !", 13, 10
		dcb.b	10, 7
		dc.b	0

		.EVEN

MesList:	dc.l		m0, m1, m2, m3

