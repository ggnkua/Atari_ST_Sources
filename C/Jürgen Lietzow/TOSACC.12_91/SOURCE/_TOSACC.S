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

		_AES		equ		200
		_form_do	equ		50
		_form_alert	equ		52
		_objc_edit	equ		46
		SysGEM		equ		$88


	.OFFSET		0
								; Aufbau des GemParBlk
control:	ds.l	1
global:		ds.l	1
intin:		ds.l	1
intout:		ds.l	1
adrin:		ds.l	1
adrout:		ds.l	1


	.TEXT


; Von Modul XDIAL.C

	.EXPORT	NewGEM, _NewGEM


; Fr Modul XDIAL.C

	.IMPORT FormDo, FormAlert, OldGEM, xdSwitch, xaSwitch, _GemParBlk
	.IMPORT ObjcEdit, xedSwitch


_NewGEM:
		move.l		d1,GemParBlk
		rte

NewGEM:									; Neuer GEM-Trap
		cmp.w		#_AES,d0			; AES ?
		beq			IsAES
DoOldGEM:
		move.l		OldGEM,a0
		jmp			(a0)				; Aufruf des alten Trap #2
IsAES:
		move.l		d1,a1
		move.l		control(a1),a0
		move.w		(a0),d2
		cmp.w		#_form_do,d2		; form_do ?
		beq			IsFormDo
		cmp.w		#_form_alert,d2
		beq			IsFormAlert
		cmp.w		#_objc_edit,d2
		bne			DoOldGEM
IsObjcEdit:
		tst.w		xedSwitch
		beq			DoOldGEM
		lea.l		_ObjcEdit,a0
		bra			GoOn
IsFormAlert:
		tst.w		xaSwitch
		beq			DoOldGEM
		lea.l		_FormAlert,a0
		bra			GoOn
IsFormDo:
		tst.w		xdSwitch
		beq			DoOldGEM
		lea.l		_FormDo,a0

GoOn:
		move.l		2(sp),d1			; Rcksprung sichern
		move.l		#BackInUsr,2(sp)	; Neuer Rcksprung
		rte
BackInUsr:								; Im user mode
		move.w		sr,d0
		move.l		d1,-(sp)
		move.w		d0,-(sp)			; Rcksprung und sr auf Stack
		movem.l		a1-a5,-(sp)
		move.l		GemParBlk,a5
		move.l		global(a5),a4
		move.l		global(a1),global(a5)

		move.l		a1,a3
		move.l		adrin(a3),a2
		move.l		intin(a3),a1
		move.w		(a1)+,d0

		jsr			(a0)

		move.l		global(a5),global(a3)
		move.l		a4,global(a5)
		movem.l		(sp)+,a1-a5
		rtr

_FormDo:
		move.l		(a2),a0
		jsr			FormDo
		move.l		intout(a3),a0
		move.w		d0,(a0)
		rts

_FormAlert:

		move.l		(a2),a0
		jsr			FormAlert
		move.l		intout(a3),a0
		move.w		d0,(a0)
		rts

_ObjcEdit:

		move.w		(a1)+,d1
		move.w		(a1)+,-(sp)
		move.w		(a1)+,d2
		move.l		(a2),a0
		move.l		sp,a1
		jsr			ObjcEdit
		move.l		intout(a3),a0
		move.w		d0,(a0)+
		move.w		(sp)+,(a0)
		rts

	.BSS

	.EVEN

GemParBlk:		ds.l		1
