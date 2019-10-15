;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 2/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							TOSACC.ACC									;;
;;																		;;
;;		M O D U L E		:	_TOSACC.S									;;
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

	.EXPORT	NewGEM, _NewGEM, GEMSwitch, _GEMSwitches
	.EXPORT ColdBoot, Reset


	.IMPORT OldGEM, _GemParBlk
	.IMPORT ObjcEdit, FormCenter
	.IMPORT	FormDo, FormAlert, 
	.IMPORT	ExpandObjs, ReduceObjs
	.IMPORT xobFlag	

		_AES			equ		200
		SysGEM			equ		$88

		_objc_draw		equ		42
		_objc_edit		equ		46
		_objc_change	equ		47
		_form_do		equ		50
		_form_dial		equ		51
		_form_alert		equ		52
		_form_center	equ		54
		_form_keybd		equ		55
		_form_button	equ		56
		


	.OFFSET		0
								; Aufbau des GemParBlk
control:	ds.l	1
global:		ds.l	1
intin:		ds.l	1
intout:		ds.l	1
adrin:		ds.l	1
adrout:		ds.l	1


	.TEXT
	
_NewGEM:
		move.l		d1,GemParBlk		; wird nur einmal ben”tigt, um
		rte								; die Adresse des eigenen
										; GEM-Parameterblock zu ermitteln

NewGEM:									; Neuer GEM-Trap
		cmp.w		#_AES,d0			; AES ?
		beq			IsAES
DoOldGEM:
		move.l		OldGEM,a0
		jmp			(a0)				; Aufruf des alten Trap #2
IsAES:
		tst.w		GEMSwitch			; hiermit ist es m”glich, auch die
		bmi			DoOldGEM			; Original-Funktionen aufrufen
										; zu K”nnen
		move.l		d1,a1				; GEM-Parameterblock des
		move.l		control(a1),a0		; Aufrufers
		moveq.l		#-_objc_draw,d2
		add.w		(a0),d2				; Nummer der AES-Funktion
		bmi			DoOldGEM			; minus kleinster zu Suchenden
		cmp.w		#_form_button-_objc_draw,d2
		bgt			DoOldGEM
		lea.l		_GEMSwitches,a0		; Ist diese AES-Funktion
		tst.b		0(a0,d2.w)			; eingeschaltet ?
		beq			DoOldGEM

GoOn:									; In User-Modus schalten
		move.l		2(sp),d1			; Rcksprung sichern
		move.l		#BackInUsr,2(sp)	; Neuer Rcksprung
		rte
BackInUsr:								; Im user mode
		move.w		sr,d0
		move.l		d1,-(sp)
		move.w		d0,-(sp)			; Rcksprung und sr auf Stack
		movem.l		a2-a6,-(sp)
		move.l		GemParBlk,a3		; Unser GEM-Parameterblock
		move.l		a1,a2				; GEM-PB des Aufrufers retten
		move.l		global(a3),-(sp)	; Unser Global-Pointer retten
		move.l		global(a2),global(a3) ; und den des Aufrufers eintragen

		move.l		intin(a2),a4
		move.l		adrin(a2),a5
		move.l		intout(a2),a6
		move.w		(a4),d0				; den ersten intin-Parameter
										; nach d0

		add.w		d2,d2				; Adresse der neuen AES-Funktion
		add.w		d2,d2				; ermitteln
		lea.l		_GEMList-*-2(PC),a0
		move.l		0(a0,d2.w),a0
		jsr			(a0)				; die neue Assembler AES-Funktion

GoBack:
		move.l		(sp)+,global(a3)	; Unser Global-Pointer zurck-
										; schreiben
		movem.l		(sp)+,a2-a6
		rtr

_GEMList:
		dc.l		IsObjcXObj			; objc_draw
		dc.l		_DoOldGEM
		dc.l		_DoOldGEM
		dc.l		_DoOldGEM
		dc.l		IsObjcEdit			; objc_edit
		dc.l		IsObjcXObj			; objc_change
		dc.l		_DoOldGEM
		dc.l		_DoOldGEM
		dc.l		IsFormDo			; form_do
		dc.l		IsFormDial			; form_dial
		dc.l		IsFormAlert			; form_alert
		dc.l		_DoOldGEM
		dc.l		_DoOldGEM			; form_center
		dc.l		IsObjcXObj			; form_keybd
		dc.l		IsObjcXObj			; form_button


_DoOldGEM:
		subq.w		#1,GEMSwitch
		move.w		#_AES,d0
		move.l		a2,d1
		trap		#2
		addq.w		#1,GEMSwitch
		rts

IsObjcXObj:
		move.l		(a5),a0
		tst.w		xobFlag
		bne			OXOGo
		jsr			ExpandObjs
		move.w		#_AES,d0
		move.l		a2,d1
		subq.w		#1,GEMSwitch
		trap		#2
		addq.w		#1,GEMSwitch
		move.w		(a4),d0
		move.l		(a5),a0
		jsr			ReduceObjs
		rts
OXOGo:
		move.w		#_AES,d0
		move.l		a2,d1
		subq.w		#1,GEMSwitch
		trap		#2
		addq.w		#1,GEMSwitch
		rts		
IsObjcEdit:
		move.l		a4,a1
		move.w		(a1)+,d0
		move.w		(a1)+,d1
		move.w		(a1)+,-(sp)
		move.w		(a1)+,d2
		move.l		(a2),a0
		move.l		sp,a1
		jsr			ObjcEdit
		move.w		d0,(a6)+
		move.w		(sp)+,(a6)
		rts

IsFormDo:
		move.l		(a5),a0
		jsr			FormDo
		move.w		d0,(a6)
		rts

IsFormDial:
		cmp.w		#1,d0						; Grow
		beq			FDEnd
		cmp.w		#2,d0						; Shrink
		beq			FDEnd

		move.w		#_AES,d0
		move.l		a2,d1
		subq.w		#1,GEMSwitch
		trap		#2
		addq.w		#1,GEMSwitch
		rts
FDEnd:
		move.w		#1,(a6)
		rts

IsFormAlert:
		move.l		(a5),a0
		jsr			FormAlert
		move.w		d0,(a6)
		rts

; IsFormCenter:
;		move.l		(a5),a0
;		lea.l		2(a6),a1
;		jsr			FormCenter		
;		rts


;	Muž im Supermodus gestartet werden

ColdBoot:
		clr.l		$420				; memvalid
		clr.l		$426				; resvalid
Reset:
		move.l		$0,sp
		move.l		$4,a0
		jmp			(a0)




	.BSS

	.EVEN

GemParBlk:		ds.l		1
_GEMSwitches:	ds.b		_form_button - _objc_draw + 1
	.EVEN
	
GEMSwitch:		ds.w		1

	.EVEN
	
