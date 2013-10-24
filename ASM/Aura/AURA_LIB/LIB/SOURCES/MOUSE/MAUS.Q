; //////////////////////////////////////////////////////////////////////////
; Maus-	und	Tastaturroutines. Joystick nicht implementiert.
; Abfrage einmal pro VBL (bzw. frame), um Interruptinvasion zu verhindern.
; Dank an <tIn> fÅr den VBL-Tip.

; SÑmtliche	erhaltenen Werte werden	im Parameterblock im PRG abgelegt, auf die
; (dreckige) Programmierung sei dank, aus dem Hauptprogramm direkt zugegriffen
; werden kann.

; Eventuell treten ab und zu Bugs auf. Ich bin zu faul zum suchen und Åber-
; haupt ist eh immer der User schuld !!!

; Coded	21./22.6.1993 by Jochen	Knaus, BDC (Gurke ?) of	AURA.
; PC-relativiert und gePMODed:	28.6.1994.
; VBL-Maus: 17.8.1994.
; VBL-Debugging: 19.8.1994
; Alle Erweiterungen (DESTALL;STOP;GO) noch nicht getestet.
; //////////////////////////////////////////////////////////////////////////

PMOD			EQU		0					; 0 = Binaerfile

		IFEQ	PMOD
				MC68030						; Kaum zu glauben...
				ORG		0
				MODUL	"F:\LIB\MOUSE.INC"
				OPT		O-,D-

base:			bra.w	install_mouse		; Mausroutinen installieren
				bra.w	destall_mouse		; Mausroutine destallieren
				bra.w	stop_mouse			; Mausbewegung stoppen
				bra.w	go_mouse			; Mausbewegung wieder an
				bra.w	vbl_mouse			; Mausabfragen

scancode:		DC.B 	0		; Scancode der letzten gedrÅckten Taste
m_buttons:		DC.B 	0		; { Mausknîpfe
m_x:			DC.W 	0		; | rel. Mauskoordinate vertikal
m_y:			DC.W 	0		; }			"		  horizontal
mx_rel:			DC.W	0		; { relative x/y
my_rel:			DC.W	0		; }
mausm:			DC.W 	-1		; MauspaketzÑhler
m_x_rel:		DC.W	0		; { alte absolute Koords.
m_y_rel:		DC.W	0		; }
saves:			DS.B	6		; Sicherung
clippbox:		DS.W	4		; Clippbox fÅr absolute Koordinate

				DC.B	'PMOD'
				DC.B	'Mausroutinen...',0
				DC.B	'BDCannibal/AURA',0
				DC.B	'069308940129'
				DC.B	'20tm------------'	; 68020, Acia, MFP
		ENDIF

; Mausroutine fÅr den VBL, Errechnen absolute Koordinate und 
vbl_mouse:		movem.l	d0-d1/a2-a3,-(sp)
				lea		hi_acia(pc),a2	; Checken, ob Debugger ACIA-Irq gekillt
				cmpa.l	$118.w,a2		; hat.
				beq.s	okokok
				illegal
okokok:			lea		base(pc),a2
				lea		clippbox+8(pc),a3

				move.l	m_x_rel(pc),d0
				clr.l	(m_x_rel-base)(a2)
				move.l	d0,(mx_rel-base)(a2)
				move.l	m_x(pc),d1
				add.w	d0,d1			; my += rel_y

				cmp.w	-(a3),d1		; Unten raus ?
				ble.s	ni_un_aus
				move.w	(a3),d1
ni_un_aus:		cmp.w	-(a3),d1		; Oben raus ?
				bge.s	ni_ob_aus
				move.w	(a3),d1

ni_ob_aus:		swap	d0
				swap	d1
				add.w	d0,d1			; mx += rel_x

				cmp.w	-(a3),d0		; Rechts raus ?
				ble.s	ni_re_aus
				move.w	(a3),d0
ni_re_aus:		cmp.w	-(a3),d0		; Links raus ?
				bge.s	ni_li_aus
				move.w	(a3),d0

ni_li_aus:		moveq	#$08,d0			; Relative Mauskoordinatenpaket von
				bsr.w	send_ikbd		; der ACIA bestellen (mit Rechnung)

				movem.l	(sp)+,d0-d1/a2-a3
				rts

; +------------------------------------------------------------------------+
; |	Initialisierung	des	Tastaturprozessors und Installierung der eigenen   |
; |	IKBD-Interruptroutine.												   |
; |	MFP	Einstellungen werden erhalten !									   |
; | Paras:		d0-d3.w	- Maximaler Mausbereich							   |
; |				d4-d5.w - Absolute Mausstartkoordinate					   |
; +------------------------------------------------------------------------+
install_mouse:	move	sr,-(sp)
				movem.l	d0-d7/a1-a6,-(SP)	; Eigenen Mausinterrupt	instal.

				lea		base(pc),a2			; Startkoordinaten setzen.
				movem.w	d0-d3,(clippbox-base)(a2)
				movem.w	d4-d5,(m_x-base)(a2)

				moveq	#$13,D0				; IKBD Sendungen abflauen
				bsr		send_ikbd

				move	#$2700,sr
				movec	vbr,a1
				lea		saves(pc),a0		; VerÑndernde Hardwarregister
				move.l	$118(a1),(a0)+		; vor Sintflut schÅtzen.
				move.b	$fffffa09.w,(a0)+
				move.b	$fffffa15.w,(a0)+
				move.b	$fffffa17.w,(a0)+

				lea		hi_acia(pc),a2
				move.l	a2,$0118(a1)		; MFP-Interruptvektor fÅr MIDI/Maus

				bset	#6,$FFFFFA09.w		; Interrupt im MFP enablen
				bset	#6,$FFFFFA15.w 		; uns MFP-Masken sind auch out !
				bclr	#3,$FFFFFA17.w		; Automatic-End	of Interrupt

				lea		ins_ikbd(PC),A0		; IKBD-Init-Block
				bsr		send_ikbd_str		; IKBD Datenblock Åbertragen.

				lea		scancode(pc),a0		; return(Blockadresse)
				movem.l	(sp)+,d0-d7/a1-a6
				move	(sp)+,sr
				rts							; Status zurÅck.

; +--------------------------------------------------------------------------+
; | Destalliert Maus.														 |
; +--------------------------------------------------------------------------+
destall_mouse:	movem.l	d0-a6,-(sp)
				move	sr,-(sp)
				move	#$2700,sr

				lea		saves(pc),a0
				move.l	(a0)+,$118.w
				move.b	(a0)+,$fffffa09.w
				move.b	(a0)+,$fffffa15.w
				move.b	(a0)+,$fffffa17.w

				movem.l	d0-a6,-(sp)
				move	(sp)+,sr
				rts							; Flags wieder holen.

stop_mouse:		move.l	d0,-(sp)			; MAUS AUS.
				moveq	#$12,d0				; Maus abschalten.
				bsr		send_ikbd
				move.l	(sp)+,d0
				rts

go_mouse:		move.l	d0,-(sp)			; MAUS AN.
				moveq	#$08,d0				; Meldung der rel. Koords.: Maus
				bsr		send_ikbd			; wieder anschalten.
				move.l	(sp)+,d0
				rts

; Installierungsdatenpaket fÅr den Tastaturprozessor.
ins_ikbd:		DC.W	3-1
				DC.B	$1A		; Joystick abkapseln
				DC.B	$10		; Ursprung Y-Koordinaten oben.
				DC.B	$08
				EVEN

; Datenstring an Tastaturprozessor schicken.
; Parameterblockpointer	in a0.l
; Parameterblock:		   0.w - LÑnge in Bytes	- 1
send_ikbd_str:	movem.w	D0/D7,-(SP)		; Datenstring an Tast.proz.	schicken

				move.w	(A0)+,D7		; Anzahl Parameter -1
init_ikbd:		move.b	(A0)+,D0		; Data holen
				bsr.s	send_ikbd		; senden
				dbra	D7,init_ikbd

				movem.w	(SP)+,D0/D7
				rts

; Schickt Byte an Tastaturprozessor.
; Datenbyte	in d0.b.
send_ikbd:		btst	#1,$FFFFFC00.w	; IKBR empfÑngnisbereit	?
				beq.s	send_ikbd

				move.b	D0,$FFFFFC02.w	; Byte senden !
rts:			rts

; Eigener Tastaturinterrupt. Abfrage Tastatur/Maus und opt.	Joystick.
hi_acia:		movem.l	d0-d1/a2,-(sp)

				move.b	$fffffc00.w,d1	; öberhaupt ACIA-Irq und Sendung ?
				btst	#7,d1
				beq.s	_rte			; Bit 7: Irq-Request
				btst	#0,d1			; Bit 0: Receive Buffer voll
				beq.s	_rte

				move.b	$fffffc02.w,d1	; Datenbyte
				lea		base(pc),a2

				move.w	mausm(pc),d0	; Noch Mauspaket unterwegs ?
				bge.s	get_rest

				cmpi.b	#$f8,d1
				blt.s	_scancode
				cmpi.b	#$fb,d1
				bgt.s	_scancode

				andi.b	#$03,d1
				move.b	d1,(m_buttons-base)(a2)
				clr.w	(mausm-base)(a2)
				bra.s	_rte

; Reste des Koordinatenpakets holen.
get_rest:		ext.w	d1					; Relative Koord. 16 Bit.
				add.w	d1,((m_x_rel-base).w,a2,d0.w*2)
				addq.w	#1,d0
				move.w	d0,(mausm-base)(a2)
				subq.w	#2,d0
				blt.s	_rte
				neg.w	(mausm-base)(a2)	; < 0

				moveq	#$12,d0				; Maussendungen stoppen
				bsr.w	send_ikbd

_rte:			movem.l	(sp)+,d0-d1/a2		; Abflug mit SpÅlung.
				rte

_ovrrun:		illegal
				move.b	$fffffc02.w,d1
				bra.s	_rte
_scancode:		move.b	d1,(scancode-base)(a2)
				bra.s	_rte