;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	AUTOTACC.S									;;
;;																		;;
;;																		;;
;;		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				;;
;;																		;;
;;		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				;;
;;																		;;
;;		Last Update		:	26.02.91 (JL)								;;
;;																		;;
;;																		;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.IMPORT main
		.IMPORT _BasPag, _PgmSize
		
		.EXPORT Start0
		.EXPORT physstart
		.EXPORT InstCookie, GetCookie, Cookies, GetTopHead


		.INCLUDE	"..\transfer.inc"


		.TEXT

Cookies:

; Ab Hier wird der Programmcode evtl. durch die Cookie-Liste
; Åberschrieben.
; Also zuerst den Programmcode nach phystop kopieren und dann erst
; das Cookie installieren

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Ende: residenter Programmcode
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Start: Programmcode oberhalb _phystop
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Dieser Teil ist PC-relativ geschrieben, da dieser Teil in den Bereich
; oberhalb von phystop kopiert wird
; (wird durch einen Reset dann nicht gelîscht)

	ALIGN	4
	
physstart:
				dc.l		0				; dummy
				dc.l		'TAcc'			; magic
_our_cookie:	dc.w		0				; 1 == Cookie-Liste gehîrt uns
_drive_on:		dc.w		0				; 1 == RAM-Disk installiert
_drive:			dc.w		0				; Laufwerksnummer
_resvec_sav:	dc.l		0				; resvec_sav
_resmag_sav:	dc.l		0				; resmag_sav
_hd_size:		dc.w		0				; hd_size
_hd_bpb:		dcb.b		b_bpb_size, 0	; hd_bpb
_hd_maxsec:		dc.l		0				; hd_maxsec

_resCodeLen:	dc.l		_DataStart-physstart

; Unsere Resetfunktion
;
;	lîscht evtl den Cookiepointer
;	erzeugt eine AusfÅhrbare Speicherseite
;	setzt evtl die Laufwerksparameter zurÅck

ResHand:
				lea.l		_our_cookie(pc),a0
				tst.w		(a0)+
				beq			RHKeepCookie
				clr.l		_p_cookies			; evtl Cookie-Zeiger lîschen
RHKeepCookie:
				tst.w		(a0)+				; _drive_on
				beq			RHNoDrive
				move.l		_drvbits,d0			; evtl Laufwerk zurÅcksetzen
				moveq.l		#0,d1
				move.w		(a0),d1
				bclr		d1,d0
				beq			RHNoDrive
				move.l		d0,_drvbits
				
RHNoDrive:
				addq.l		#2,a0
				move.l		(a0)+,_resvector	; alte Resetfunktion
				move.l		(a0)+,_resvalid		; setzen


				move.l		_phystop,d0			; Platz fÅr Speicherseite
				lea.l		$40000,a0			; suchen
RHLoop1:
				lea.l		1024(a0),a0
				cmp.l		a0,d0
				blt			RHNoSpace
				cmp.l		#_pagemagic,(a0)
				bne			RHSpaceFound
				cmp.l		#'TAcc',14(a0)
				bne			RHLoop1

RHSpaceFound:				
				move.l		#_pagemagic,(a0)	; Speicherseite einrichten
				move.l		a0,4(a0)
				move.w		#$4ef9,8(a0)		; Opcode fÅr jmp $XXXXXXXX
				lea			MemPageCode(pc),a1
				move.l		a1,10(a0)
				move.l		#'TAcc',14(a0)
				moveq.l		#126,d0
				moveq.l		#0,d1
RHLoop2:
				add.w		(a0)+,d1
				add.w		(a0)+,d1
				dbf.w		d0,RHLoop2
				add.w		(a0)+,d1
				move.w		#_pagemagsum,d0
				sub.w		d1,d0
				move.w		d0,(a0)
				
				cmp.w		#$9BCD,(a6)		; zurÅck zum Betriebssystem
                beq		   	TOSError
                jmp			(a6)
TOSError:		jmp			$24(a6)


; Wenn kein Platz fÅr eine Speicherseite gefunden, dann Kaltstart

RHNoSpace:
				clr.l		_memvalid
				clr.l		_resvalid

				move.l		$0,sp
				move.l		$4,a0
				jmp			(a0)


; Hierhin springt die Speicherseite
; eine neue Getbpb-Funktion wird misbraucht um den physstart-Zeiger
; zurÅckzuliefern

MemPageCode:
				movem.l		d0-a6,-(sp)
				lea.l		_OldGetbpb1(pc),a0
				move.l		SysGetbpb,(a0)
				lea.l		_NewGetbpb1(pc),a0
				move.l		a0,SysGetbpb

				pea			bootMes(pc)
				move.w		#9,-(sp)
				trap		#1
				addq.l		#6,sp

				movem.l		(sp)+,d0-a6
				rts


bootMes:		dc.b		13, 10, "AUTOTACC resident ", 13, 10, 0

		.EVEN

; Åber Getbpb eingehÑngt von Speicherseite
; liefert bei richtiger ParameterÅbergabe einen Zeiger auf den Header
; oberhalb von phystop
; NatÅrlich nur, wenn vor letztem Reset initialisiert
; hat also mit <<Getbpb>> nichts zu tun

dc.b			"XBRA"
dc.b			"TAcc"
_OldGetbpb1:
dc.l			0

_NewGetbpb1:
				cmp.w		#'TA',4(sp)
				bne			DoOldGbpb
				lea			physstart(pc),a0
				move.l		a0,d0
				rts
DoOldGbpb:		
				move.l		_OldGetbpb1(pc),-(sp)
				rts

	ALIGN	4

_DataStart:
				
; Hier beginnen die eigentlichen Daten oberhalb phystop
; (je nach RAM-Disk-Grîûe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Ende: Daten oberhalb _phystop
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

; Programmgrîûe ermitteln (incl. Stack)

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
;;	Hilfsfunktionen mit Turbo/Pure C ParameterÅbergabe Konvention
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
;;	Die Liste wird, falls nîtig, an den residenten Programmcode
;;	angehÑngt, und die LÑnge muû bei Ptermres berÅcksichtigt werden
;;	Wenn Return-Code != 0, muû noch _p_cookies bei Reset auf NULL
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
			
			lea.l		Cookies,a0
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
			lea.l		Cookies,a0
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
			lsl.l		#3,d5				; GesammtlÑnge in Bytes

ICOK:
			move.l		d0,-(sp)
			move.w		#32,-(sp)			; User-Modus
			trap		#1
			addq.l		#6,sp
			move.l		d5,d0
			movem.l		(sp)+,a2/d3-d5
			rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	TOP_HEAD *GetTopHead( void );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetTopHead:
			move.l		a2,-(sp)
			move.w		#'TA',-(sp)
			move.w		#7,-(sp)
			trap		#13
			addq.l		#4,sp
			move.l		(sp)+,a2
			
			move.l		d0,a0
			rts
						
			move.l		#'TAcc',-(sp)
			moveq.l		#0,d0
			trap		#9
			
			sub.l		a0,a0
			cmp.l		#'TAcc',d0
			bne			GTHEnd
			move.l		(sp),a0
GTHEnd:			
			rts

