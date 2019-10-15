;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 10/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	Erweiterte form_do()-Funktion als Accessory	;;
;;							XDIAL.ACC									;;
;;																		;;
;;		M O D U L E		:	_XDIAL.S									;;
;;																		;;
;;																		;;
;;		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				;;
;;																		;;
;;		Last Update		:	28.08.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
; FÅr Modul XDIAL.C

	.EXPORT	NewGEM
	

; Von Modul XDIAL.C

	.IMPORT FormDo, OldGEM, isOn


		_AES		equ		200
		_form_do	equ		50
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

NewGEM:
		move.l		d1,GemParBlk		; Installiert nach erstem Aufruf
		move.l		#_NewGEM,SysGEM		; _NewGEM, und merkt sich
		rte								; eigenen GemParBlk

_NewGEM:								; Neuer GEM-Trap
		tst.w		isOn				; xdialog eingeschaltet ?
		beq			DoOldGEM
		
		cmp.w		#_AES,d0			; AES ?
		beq			IsAES
DoOldGEM:
		move.l		OldGEM,a0
		jmp			(a0)				; Aufruf des alten Trap #2
IsAES:
		move.l		d1,a1
		move.l		control(a1),a0
		cmp.w		#_form_do,(a0)		; form_do ?
		bne			DoOldGEM
IsFormDo:		
		move.l		2(sp),a0			; RÅcksprung sichern
		move.l		#BackInUsr,2(sp)	; Neuer RÅcksprung
		rte
BackInUsr:								; Im user mode
		move.w		sr,d0
		move.l		a0,-(sp)
		move.w		d0,-(sp)			; RÅcksprung und sr auf Stack
		move.l		a1,-(sp)
		move.l		GemParBlk,a0		; Unser global-Feld in das des
		move.l		global(a0),-(sp)	; Aufrufers Ñndern
		move.l		a0,-(sp)			;
		move.l		global(a1),global(a0)
		
		move.l		intin(a1),a0		; Parameter fÅr FormDo holen
		move.w		(a0),d0				; d0 -> startob
		move.l		adrin(a1),a0
		move.l		(a0),a0				; a0 -> tree

		jsr			FormDo				; FormDo aufrufen

		move.l		(sp)+,a1			; GemParBlk
		move.l		(sp)+,global(a1)	; unser global-Feld zurÅcksetzen
		move.l		(sp)+,a0			; GemParBlk des Aufrufers
		move.l		intout(a0),a0
		move.w		d0,(a0)				; RÅckgabewert nach intout[0]
		rtr								; RÅcksprung mit Setzen der
										; Flags


	.BSS
	
GemParBlk:		ds.l		1