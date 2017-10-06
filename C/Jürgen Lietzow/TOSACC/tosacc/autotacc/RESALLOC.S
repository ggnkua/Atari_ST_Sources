;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																		;;
;;																		;;
;;		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/91  <<<<<<<<<<<<<		;;
;;																		;;
;;																		;;
;;		P R O J E C T	:	TOS ACCESSORY Spezial						;;
;;							AUTOTACC.PRG								;;
;;																		;;
;;		M O D U L E		:	RESALLOC.S									;;
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

	.EXPORT			_ResStart
	.EXPORT			GetResMem
	.EXPORT			_xbra_magic
	.EXPORT			resLenTxt
	
	_memvalid		equ		$420		; gltige Speicherkonfiguration ?
	_resvalid		equ		$426		; gltiger Resetvektor ?
	_resvector		equ		$42a		; n„chster Resetvektor !
	RESMAGIC		equ		$31415926	; gltiger Resetvector!

	_pagemagic		equ		$12123456	; gltige Speicherseite Nr.1 !
	_pagemagsum		equ		$5678		; gltige Speicherseite Nr.2 !
	
	_phystop		equ		$42e		; physikalisches Speicherende
	_p_cookies	 	equ		$5a0		; Cookie Zeiger

	SysGetbpb		equ		$472	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Start: Programmcode oberhalb _phystop
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Dieser Teil ist PC-relativ geschrieben, da dieser Teil in den Bereich
; oberhalb von phystop kopiert wird
; (wird durch einen Reset dann nicht gel”scht)

	.TEXT
	
	ALIGN	4
	
_ResStart:
				dc.l		0				; dummy
_our_magic:		dc.l		0				; magic
_our_cookie:	dc.w		0				; 1 == Cookie jar will be
											; cleared on Reset
_resvec_sav:	dc.l		0				; resvec_sav
_resmag_sav:	dc.l		0				; resmag_sav
_retsav:		dc.l		0				; internal use
_page_code:		dc.l		0				; optional appending page function
_res_code:		dc.l		0				; optional appendig reset function
_resDataStart:	dc.l		_DataStart-_ResStart
_resDataSize:	dc.l		0
_resHeadLen:	dc.l		_DataStart-_ResStart
											

; Unsere Resetfunktion
;
;	l”scht evtl den Cookiepointer
;	erzeugt eine Ausfhrbare Speicherseite

ResHand:
				lea.l		_our_cookie(pc),a0
				tst.w		(a0)+
				beq			RHKeepCookie
				clr.l		_p_cookies			; evtl Cookie-Zeiger l”schen
RHKeepCookie:
				move.l		(a0)+,_resvector	; alte Resetfunktion
				move.l		(a0)+,_resvalid		; setzen


				move.l		_phystop,d0			; Platz fr Speicherseite
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
				move.w		#$4ef9,8(a0)		; Opcode fr jmp $XXXXXXXX
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
TstResCode:
				lea.l		_res_code(pc),a0
				tst.l		(a0)
				beq			NoResCode
				move.l		(a0),a0
				lea.l		_retsav(pc),a1
				move.l		a6,(a1)
				lea.l		ResCodeBack(pc),a6
				jmp			(a0)
ResCodeBack:
				lea.l		_retsav(pc),a0
				move.l		(a0),a6
NoResCode:		
				cmp.w		#$9BCD,(a6)		; zurck zum Betriebssystem
                beq		   	TOSError
                jmp			(a6)
TOSError:		jmp			$24(a6)


; Wenn kein Platz fr eine Speicherseite gefunden, dann Kaltstart

RHNoSpace:
				clr.l		_memvalid
				clr.l		_resvalid

				move.l		$0,sp
				move.l		$4,a6
				bra			TstResCode


; Hierhin springt die Speicherseite
; eine neue Getbpb-Funktion wird misbraucht um den physstart-Zeiger
; zurckzuliefern

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
				
				lea.l		_our_cookie(pc),a0
				clr.w		(a0)+
				move.l		_resvector,(a0)+
				move.l		_resvalid,(a0)
				move.l		#RESMAGIC,_resvalid
				lea.l		ResHand(pc),a0
				move.l		a0,_resvector

				lea.l		_page_code(pc),a0
				tst.l		(a0)
				beq			NoPageCode
				move.l		(a0),a0
				jsr			(a0)
NoPageCode:		

				movem.l		(sp)+,d0-a6
				rts


bootMes:		dc.b		13, 10,
resLenTxt:		dc.b		"         Bytes resident memory installed",
				dc.b		13, 10, 0

		.EVEN

; ber Getbpb eingeh„ngt von Speicherseite
; liefert bei richtiger Parameterbergabe einen Zeiger auf den Header
; oberhalb von phystop
; Natrlich nur, wenn vor letztem Reset initialisiert
; hat also mit <<Getbpb>> nichts zu tun

				dc.b			"XBRA"
_xbra_magic:
				dc.l			0
_OldGetbpb1:
dc.l			0

_NewGetbpb1:
				lea.l		_our_magic(pc),a0
				move.w		(a0),d0
				cmp.w		4(sp),d0
				bne			DoOldGbpb
				lea			_ResStart(pc),a0
				move.l		a0,d0
				rts
DoOldGbpb:		
				move.l		_OldGetbpb1(pc),a0
				jmp			(a0)

	ALIGN	4

_DataStart:
				
; Hier beginnen die eigentlichen Daten oberhalb phystop
; (je nach RAM-Disk-Gr”že)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Ende: Daten oberhalb _phystop
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	RES_MEM	*GetResMem( long magic );
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetResMem:

			move.l		a2,-(sp)
			move.l		d0,-(sp)
			move.l		d0,-(sp)
			move.w		#7,-(sp)
			trap		#13
			addq.l		#6,sp
			move.l		d0,a0
			tst.l		d0
			beq			GRMDone
			move.l		(sp),d0
			cmp.l		4(a0),d0
			bne			GRMErr
GRMDone:
			addq.l		#4,sp
			move.l		(sp)+,a2
			rts
GRMErr:
			move.l		(sp)+,a2
			sub.l		a0,a0
			rts