;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		;;
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
;;		Last Update		:	28.08.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Von Modul XDIAL.C
	
	.EXPORT	NewGEM, _NewGEM
	
	
; Fr Modul XDIAL.C
	
	.IMPORT FormDo, FormAlert, OldGEM, xdSwitch, xaSwitch, _GemParBlk
	.IMPORT ObjcEdit

		_AES		equ		200
		_form_do	equ		50
		_form_alert	equ		52
		_objc_edit	equ		46
		lframe		equ		$59e
		SysGEM		equ		$88
		SysVSYNC	equ		$70
		SysFRCLOCK	equ		$466
		
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
		move.l		d1,GemParBlk
		rte
		
NewGEM:								; Neuer GEM-Trap
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
		tst.w		xdSwitch
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




	.TEXT

; von Module SCSAVER.C
		
	.IMPORT		scTime, scSwitch, OldKEYBD, Old200HZ

; fr Module SCSAVER.C

	.EXPORT		NewKEYBD, New200HZ

NewKEYBD:
		move.w		scTime, scCount
		tst.w		scIsOn
		bne			DoOldKEYBD
		move.w		#1,scIsOn
		cmp.w		#1,scSwitch
		beq			ScIsBlack
ScInvert:
		move.w		#$ffff,$ffff8240
		bra			DoOldKEYBD
ScIsBlack:
		bclr		#0,$ffff820a
DoOldKEYBD:
		move.l		OldKEYBD,-(sp)
		rts


New200HZ:
		tst.w		scIsOn
		bne			ScIsOn
ScIsOff:
		cmp.w		#1,scSwitch
		bne			ScIsOn

CheckVSYNC:
		subq.w		#1,vsyncCount
		bne			DoOld200HZ
		move.w		#3,vsyncCount
		tst.w		lframe
		beq			NoTT1
		move.w		6(sp),-(sp)
NoTT1:
		pea			HZ200Back1
		move.w		sr,-(sp)
DoOld200HZ:
		move.l		Old200HZ,-(sp)
		rts
HZ200Back1:
		move.l		SysVSYNC,-(sp)
		rts
ScIsOn:
		subq.w		#1,secCount
		bne			DoOld200HZ
		move.w		#200,secCount
		tst.w		scSwitch
		beq			DoOld200HZ
		subq.w		#1,scCount
		bne			DoOld200HZ
		cmp.w		#1,scSwitch
		beq			MakeBlack
		move.w		scTime,scCount
		bchg.b		#0,$ffff8241
		clr.w		scIsOn
		bra			DoOld200HZ
MakeBlack:
		btst.b		#0,$ffff820a
		bne			DoOld200HZ
		tst.w		lframe
		beq			NoTT2
		move.w		6(sp),-(sp)
NoTT2:
		pea			HZ200Back2
		move.w		#$2000,-(sp)
		move.l		Old200HZ,-(sp)
		rts
HZ200Back2:
		move.l		d0,-(sp)
		move.l		SysFRCLOCK,d0
WaitVSYNC:
		cmp.l		SysFRCLOCK,d0
		beq			WaitVSYNC
		bset		#0,$ffff820a
		clr.w		scIsOn
		move.l		(sp)+,d0
		rte
		
	.DATA

vsyncCount:		dc.w		3
secCount:		dc.w		200
scIsOn:			dc.w		1
scCount:		dc.w		90


	.TEXT

; von Module SETMOUSE.C

	.IMPORT		OldMOUSE, smSwitch, smKeep

; fr Module SETMOUSE.C

	.EXPORT		NewMOUSE, xList, yList
	
NewMOUSE:

		cmp.b		#$f8,(a0)
		bcs			DoOldMOUSE
		cmp.b		#$fc,(a0)
		bcc			DoOldMOUSE
		tst.w		smSwitch
		beq			DoOldMOUSE
		move.w		d0,-(sp)
		move.w		d1,-(sp)
		move.l		a1,-(sp)
		
		addq.l		#1,a0
		lea.l		xList,a1
		move.w		x,d1
		move.b		(a0),d0			; x
		bsr			Move
		move.b		d0,(a0)+
		move.w		d1,x

		lea.l		yList,a1
		move.w		y,d1
		move.b		(a0),d0
		bsr			Move
		move.b		d0,(a0)
		move.w		d1,y
		subq.l		#2,a0
		
		move.l		(sp)+,a1
		move.w		(sp)+,d1
		move.w		(sp)+,d0
DoOldMOUSE:
		move.l		OldMOUSE,-(sp)
		rts

Move:	
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

		.DATA
		
		/*			2,     3,   4,   5,   6,   7,  8,  9, 10 */

		dc.b		-70, -70, -70, -60, -50, -40, -25, -12, -5
xList:	dc.b		0
		dc.b		5,     12,   25,  40,  50,  60, 70, 70, 70
		
		dc.b		-70, -70, -70, -60, -50, -40, -25, -12, -5
yList:	dc.b		0
		dc.b		5,     12,   25,  40,  50,  60, 70, 70, 70

		.EVEN
x:
		dc.w		0
y:
		dc.w		0
		
