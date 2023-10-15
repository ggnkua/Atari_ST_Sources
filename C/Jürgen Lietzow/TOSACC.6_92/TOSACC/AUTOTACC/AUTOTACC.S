;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	AUTOTACC.S									;;
;;																		;;
;;																		;;
;;		Author			:	Jrgen Lietzow fr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	27.04.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.IMPORT main
		.IMPORT _BasPag, _PgmSize, _ResStart
		
		.EXPORT Start0
		.EXPORT InstCookie, GetCookie


		.INCLUDE	"..\transfer.inc"


		.TEXT


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Programm Start
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Start0:
        move.l		a0,d0			; Als Accessory gestartet ?
        beq			Start1
        move.w		#1,d0
        bra			exit
Start1:
		move.l		4(sp),a3		; Base page pointer
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
		move.w		#74,-(sp)				; Mshrink
		trap		#1
		lea.l		12(sp),sp


		jsr			main(pc)
		
exit:

		move.w		d0,-(sp)
		move.w		#76,-(sp)			; Pterm
		trap		#1		
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Hilfsfunktionen mit Turbo/Pure C Parameterbergabe Konvention
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	*GetCookie( long name );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetCookie:
			movem.l		d3/a2/a6,-(sp)
			move.l		d0,d3
			clr.l		-(sp)
			move.w		#32,-(sp)				; Super
			trap		#1
			addq.l		#6,sp
			
			move.l		_p_cookies,a6
			move.l		a6,d1
			beq			RetCookie
LookCookie:
			move.l		(a6),d1
			beq			NoCookie
			cmp.l		d1,d3
			beq			RetCookie
			addq.l		#8,a6
			bra			LookCookie
NoCookie:
			sub.l		a6,a6
RetCookie:
			move.l		d0,-(sp)
			move.w		#32,-(sp)					; Super
			trap		#1
			addq.l		#6,sp
			move.l		a6,a0
			movem.l		(sp)+,d3/a2/a6
			rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	long	InstCookie( long c_name, long c_cook )
;;
;;	Die Liste wird, falls n”tig, an den residenten Programmcode
;;	angeh„ngt, und die L„nge muž bei Ptermres bercksichtigt werden
;;	Wenn Return-Code != 0, muž noch _p_cookies bei Reset auf NULL
;;	gesetzt werden
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InstCookie:
			movem.l		a2/d3-d5,-(sp)
			move.l		d0,d3
			move.l		d1,d4

			clr.l		-(sp)
			move.w		#32,-(sp)				; Super-Modus
			trap		#1
			addq.l		#6,sp					; User-Stack bleibt in d0

			move.l		_p_cookies,a0
			move.l		a0,d1
			bne			ICGo
			
			lea.l		_ResStart,a0
			move.l		a0,_p_cookies
			moveq.l		#0,d5
			bra			NewCookie
ICGo:
			moveq.l		#-1,d2
ICLoop:
			addq.l		#1,d2
			move.l		(a0),d1
			beq			ICEndC
			addq.l		#8,a0
			bra			ICLoop
ICEndC:
			cmp.l		4(a0),d2			; Slots frei ?
			bge			ICExt
			move.l		(a0),8(a0)			; Um eine Stelle verschieben
			move.l		4(a0),12(a0)
			move.l		d3,(a0)+
			move.l		d4,(a0)+
			moveq.l		#0,d5
			bra			ICOK
ICExt:
			move.l		d2,d5				; Anzahl bisheriger Cookies
			move.l		_p_cookies,a1
			lea.l		_ResStart,a0
			move.l		a0,_p_cookies
			bra			ICLoop1End
ICLoop1:
			move.l		(a1)+,(a0)+			; alte Cookies kopieren
			move.l		(a1)+,(a0)+
ICLoop1End:
			dbf			d2,ICLoop1
NewCookie:
			move.l		d3,(a0)+			; unser Cookie
			move.l		d4,(a0)+
			clr.l		(a0)+				; Null-Cookie mit
			addq.l		#8,d5
			move.l		d5,(a0)+			; Slot-Anzahl
			lsl.l		#3,d5				; Gesammtl„nge in Bytes

ICOK:
			move.l		d0,-(sp)
			move.w		#32,-(sp)			; User-Modus
			trap		#1
			addq.l		#6,sp
			move.l		d5,d0
			movem.l		(sp)+,a2/d3-d5
			rts
			
