;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/91  <<<<<<<<<<<<<		;;
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
;;		Last Update		:	26.02.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.EXPORT	NewGEM, _NewGEM, GEMSwitch, _GEMSwitches, _OldGEM
	.EXPORT ColdBoot, Reset


	.IMPORT OldGEM, _GemParBlk
	.IMPORT ObjcEdit, FormCenter
	.IMPORT	FormDo, FormAlert, 
	.IMPORT	ExpandObjs, ReduceObjs
	.IMPORT xobFlag, sys

	.INCLUDE "transfer.inc"

	.TEXT

_NewGEM:
		move.l		d1,GemParBlk		; wird nur einmal ben”tigt, um
		rte								; die Adresse des eigenen
										; GEM-Parameterblock zu ermitteln


dc.b		"XBRA"
dc.b		"TAcc"
_OldGEM:
dc.l		0

NewGEM:
			move.l		sys,a1
			tst.w		spDemand(a1)
			beq			NGVNoDemand
			movem.l		d0-d1/a1,-(sp)
			move.l		_DemandBlock(a1),a0
			jsr			(a0)
			movem.l		(sp)+,d0-d1/a1
NGVNoDemand:			
			cmp.w		#_AES,d0			; AES ?
			beq			IsAES
DoOldGEMVDI:
			move.l		sys,a1
;			bra			DOGVStackOK			; !!!!!!!!!!!!!!!!!!!!!!!
			move.w		#1,inSys_flag(a1)

			btst.b		#5,(sp)				; Aus Super-Modus ?
			beq			DOGVNoSuper

			subq.l		#4,sp
			move.w		4(sp),(sp)			; sr
			move.l		#GEMVDIBack,2(sp)	; neue return-Adresse
			tst.w		_longframe			; MC68030 ?
			beq			DOGVStackOK

			move.w		10(sp),d2			; TT-sr
			move.l		6(sp),8(sp)			; alte return-Adresse
			move.l		d2,6(sp)			; TT-sr
			bra			DOGVStackOK

DOGVNoSuper:
			move.l		usp,a1
			move.l		2(sp),-(a1)
			move.l		a1,usp
			move.l		#GEMVDIBack,2(sp)	; neue return-Adresse
DOGVStackOK:			
			move.l		_OldGEM(pc),a1
			jmp			(a1)
GEMVDIBack:
			move.l		sys,a1
			clr.w		inSys_flag(a1)
			rts
	
IsAES:
		tst.w		GEMSwitch			; hiermit ist es m”glich, auch die
		bmi			DoOldGEMVDI			; Original-Funktionen aufrufen
										; zu K”nnen
		move.l		d1,a1				; GEM-Parameterblock des
		move.l		control(a1),a0		; Aufrufers
		moveq.l		#-_objc_draw,d2
		add.w		(a0),d2				; Nummer der AES-Funktion
		bmi			DoOldGEMVDI			; minus kleinster zu Suchenden
		cmp.w		#_form_button-_objc_draw,d2
		bgt			DoOldGEMVDI
		lea.l		_GEMSwitches,a0		; Ist diese AES-Funktion
		tst.b		0(a0,d2.w)			; eingeschaltet ?
		beq			DoOldGEMVDI

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
		dc.l		0
		dc.l		0
		dc.l		0
		dc.l		IsObjcEdit			; objc_edit
		dc.l		IsObjcXObj			; objc_change
		dc.l		0
		dc.l		0
		dc.l		IsFormDo			; form_do
		dc.l		IsFormDial			; form_dial
		dc.l		IsFormAlert			; form_alert
		dc.l		0
		dc.l		0					; form_center
		dc.l		IsObjcXObj			; form_keybd
		dc.l		IsObjcXObj			; form_button


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
	
