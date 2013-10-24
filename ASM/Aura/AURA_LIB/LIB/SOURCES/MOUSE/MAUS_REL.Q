; //////////////////////////////////////////////////////////////////////////
; Maus-	und	Tastaturroutines. Joystick nicht implementiert.
; Abfrage einmal pro VBL (bzw. frame), um Interruptinvasion zu verhindern.
; Dank an <tIn> fÅr den VBL-Tip !

; SÑmtliche	erhaltenen Werte werden	im Parameterblock abgelegt.
; Die Mauskoordinaten werden NICHT im Interrupt	geclippt, sie mÅssen vor dem
; Zeichnen geclippt	werden (schneller, da nur einmal pro VBL).

; Eventuell treten ab und zu Bugs auf. Ich bin zu faul zum suchen und Åber-
; haupt ist eh immer der User schuld !!!

; Coded	21./22.6.1993 by Jochen	Knaus, BDC (Gurke ?) of	AURA.
; PC-relativiert und gePMODed:	28.6.1994.
; VBL-Maus: 17.8.1994.
; Alle Erweiterungen (DESTALL;STOP;GO) noch nicht getestet.
; //////////////////////////////////////////////////////////////////////////

PMOD			EQU		0					; 0 = Binaerfile

TR_X			EQU		3					; Triggerschwelle x
TR_Y			EQU		3					; Triggerschwelle y

		IFEQ	PMOD
				MC68030						; Kaum zu glauben...
				ORG		0
				MODUL	"F:\LIB\MOUSE.INC"
				OPT		O-,D-

				bra.w	install_mouse		; Mausroutinen installieren
				bra.w	destall_mouse		; Mausroutine destallieren
				bra.w	stop_mouse			; Mausbewegung stoppen
				bra.w	go_mouse			; Mausbewegung wieder an
				bra.w	vbl_mouse			; Mausabfragen

scancode:		DC.B 0			; Scancode der letzten gedrÅckten Taste
m_buttons:		DC.B 0			; Mausknîpfe
m_y:			DC.W 0			; rel. Mauskoordinate vertikal	 {
m_x:			DC.W 0			;			"		  horizontal  }
mausm:			DC.W -2			; MauspaketzÑhler
saves:			DS.B 6			; Sicherung

				DC.B	'PMOD'
				DC.B	'Mausroutinen...',0
				DC.B	'BDCannibal/AURA',0
				DC.B	'069306940110'
				DC.B	'20tm------------'	; 68020, Acia, MFP
		ENDIF

vbl_mouse:		move.l	d0,-(sp)			; Maus relativ an.
				moveq	#$08,d0
				bsr.w	send_ikbd
				move.l	(sp)+,d0
				rts

; +------------------------------------------------------------------------+
; |	Initialisierung	des	Tastaturprozessors und Installierung der eigenen   |
; |	IKBD-Interruptroutine.												   |
; |	MFP	Einstellungen werden erhalten !									   |
; +------------------------------------------------------------------------+
install_mouse:	move	sr,-(sp)
				movem.l	D0-d7/a1-A6,-(SP)	; Eigenen Mausinterrupt	instal.

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
				rts							; Status mir zurÅck.

; +--------------------------------------------------------------------------+
; | Destalliert Maus.														 |
; +--------------------------------------------------------------------------+
destall_mouse:	movem.l	d0-a6,-(sp)
				move	sr,-(sp)

				lea		saves(pc),a0
				move.l	(a0)+,$118.w
				move.b	(a0)+,$fffffa09.w
				move.b	(a0)+,$fffffa15.w
				move.b	(a0)+,$fffffa17.w

				movem.l	d0-a6,-(sp)
				rtr							; Flags wieder holen.

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
ins_ikbd:		DC.W 6-1		; 2-Bytes Befehlsequenz.
				DC.B $1A		; Joystick abkapseln
				DC.B $10		; Ursprung Y-Koordinaten oben.
				DC.B $08		; relative Mausposition	melden.
				DC.B $0b,TR_X,TR_Y	; Triggerschwelle

; Datenstring an Tastaturprozessor schicken.
; Parameterblockpointer	in a0.l
; Parameterblock:		   0.w - LÑnge in Bytes	- 1
send_ikbd_str:	movem.l	D0/D7-A0,-(SP)	; Datenstring an Tast.proz.	schicken

				move.w	(A0)+,D7		; Anzahl Parameter -1
init_ikbd:		move.b	(A0)+,D0		; Data holen
				bsr.s	send_ikbd		; senden
				dbra	D7,init_ikbd

				movem.l	(SP)+,D0/D7-A0
				rts

; Schickt Byte an Tastaturprozessor.
; Datenbyte	in d0.b.
send_ikbd:		btst	#1,$FFFFFC00.w	; IKBR empfÑngnisbereit	?
				beq.s	send_ikbd

				move.b	D0,$FFFFFC02.w	; Byte senden !
rts:			rts

; Eigener Tastaturinterrupt. Abfrage Tastatur/Maus und opt.	Joystick.
hi_acia:		;		move	#$2500,sr
				movem.l	d0/a0-a1,-(sp)
				lea		$fffffc00.w,a0	; Keyb.	ACIA Control

				move.b	(a0),d0			; Status holen
				andi.b	#%10000001,d0	; Interrupt und Rec.Buffer voll?
				beq.s	_rte			; nein,	BYE

				lea		mausm(pc),a1
				move.w	(a1),d0			; Mauspaket	noch nicht vollstÑndig ?
				bmi.s	no_m_paket		; garkein Mauspaket...

				lea		(m_y.w,pc,d0.w),a0	; Maus-	x- oder	y-Koordinate
				move.b	$fffffc02.w,D0	; relative Koordinate holen
				ext.w	d0				; auf Wort erweitern
				add.w	d0,(a0)			; und auf absolut Koord. addieren
				subq.w	#2,(a1)			; nÑchste Koord. oder Ende.
				bge.s	_rte

				moveq	#$13,d0			; ACIA knebeln.
				bsr.w	send_ikbd
				bra.s	_rte

no_m_paket:		clr.w	d0
				move.b	2(a0),d0		; Byte von ACIA	abzwacken

				cmp.w	#$f8,D0			; Tastenklick oder Kontrollbyte	?
				bge.s	con_byte		; Kontrolls	zw.	$f6	und	$ff
; $f6=Speicher lesen / $f7 = absolute Mauspos. unmîglich !

				move.b	D0,-6(a1)		; GedrÅckte	Taste sichern (Scancode)

				subq.b	#1,d0
				bne.s	_rte
				illegal

chk_joy:								; Joystickabfrage noch einbauen
_rte:			movem.l	(SP)+,D0/A0-a1	; Abflug mit SpÅlung.
;				bclr	#6,$fffffa11.w
				rte

con_byte:		cmp.w	#$fb,D0			; Mauskontroll $f8<=kon<=$fb
				bgt.s	chk_joy			; Joystick war's wohl !

				andi.b	#3,D0			; Buttonstatus isolieren
				move.b	D0,-5(a1)		; und sichern
				move.w	#2,(a1)			; rx/ry	werden noch	erwartet !
				bra.s	_rte			; genormtes	Ende !
