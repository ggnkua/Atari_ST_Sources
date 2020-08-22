;
;   VDI_SW - S/W-VDI-Treiber
;   -------------------------------
;

.globl	inst_vdi,hor_rez,ver_rez,hor_byte

Trap_02 	equ	$88			; Adresse des Trap 2 - Vektors
Trap_14 	equ	$B8			; Adresse des Trap 14 - Vektors

sshiftmd	equ	$44C		; Schattenregister fÅr Shift-Modus
_vblqueue	equ	$456		; 200Hz-ZÑhler
_hz_200 	equ	$4BA		; Zeiger auf VBL-Schlange
_cookie 	equ	$5A0		; Zeiger auf Cookie-Jar
_longframe	equ	$59E		; 0=68000 / #0=68010/20/30

HiRes		equ	  2			; Shift-Modus fÅr Groûbildschirm

BIOS		equ	 13			; BIOS-Aufrufe:
Setexc		equ	  5			; Vektoren tauschen

GEMDOS		equ	  1			; GEMDOS-Aufrufe:
Pterm0		equ	  0			; Programm beenden
Cconout 	equ	$02			; Schreibe Zeichen nach Standard-Output
Cconws		equ	$09			; Schreibe String nach Standard-Output
Super		equ	$20			; Supervisormodus erfragen/setzen
Ptermres	equ	$31			; Programm resident beenden

XBIOS		equ	14			; XBIOS-Aufrufe:
Physbase	equ	 2			; Bildschirmadresse efragen
Getrez		equ	 4			; Bidschirm-Auflîsung erfragen
Setscreen	equ	 5			; Bildschirm-Parameter setzen
Kbdvbase	equ	34			; Zeiger auf Tastaturvektoren holen

VDI			equ	$73			; Kennung fÅr VDI-Funktionen bei TRAP #2
v_opnwk 	equ	  1			; Open Workstation ( VDI 1 )
v_clswk 	equ	  2			; Close Workstation

Bildspeicher	equ	$C00000 ; Adresse VGA-Videospeicher

	.TEXT
inst_vdi:
	movem.l	d0-d7/a0-a6,-(sp)

	clr.l	-(SP)					; USP -> SSP, alten SSP zurÅckliefern
	move.w	#Super, -(SP)			; Supervisormodus setzen
	trap	#GEMDOS 				; Åber GEMDOS-Aufruf
	lea	6(SP), SP					; Stack aufrÑumen

	move.l	D0, -(SP)				; alten USP merken
	move.w	#Super, -(SP)			; RÅckschaltung vorbereiten

	move.l	Trap_02, Old_Trap_02	; alten VDI-Vektor merken
	move.l	#New_Trap_02, Trap_02	; neuen VDI-Dispatcher installieren

	move.l	Trap_14, Old_Trap_14	; alten XBIOS-Vektor merken
	move.l	#New_Trap_14, Trap_14	; neuen XBIOS-Dispatcher installieren

	move.b	#HiRes, sshiftmd		; Shiftmodus 2 : 1 Farb-Plane

	trap	#GEMDOS 				; Supervisormodus beenden
	lea		6(SP), SP				; Stack aufrÑumen

	move.w	#-1, -(SP)				; Auflîsung nicht verÑndern
	move.l	#-1, -(SP)				; Physbase  nicht verÑndern
	pea		Bildspeicher			; Logbase auf neuen Bildschirmspeicher
	move.w	#Setscreen, -(SP)		; Bildschirm-Parameter
	trap	#XBIOS					; neu setzen
	lea		12(SP), SP				; Stack aufrÑumen

	dc.w	$A000					; Zeiger auf LineA-Variablen holen

	move.l	A0, LineA_Vec			; LineA-Vektor merken
	movea.l 8(A1), A1				; Zeiger auf System-Font bilden
	move.l	$4C(A1), -$16(A0)		; Zeiger auf Systemzeichensatzdaten
	move.w	$26(A1), -$12(A0)		; ASCII-Wert des letztn Zeichens im Satz
	move.w	$24(A1), -$10(A0)		; ASCII-Wert des ersten Zeichens im Satz
	move.w	$50(A1), -$0E(A0)		; Breite der Fontdaten (Image) in Bytes
	move.l	$48(A1), -$0A(A0)		; Zeiger auf Zeichensatz-Offset-Tabelle

	moveq	#0, D2					; D2 lîschen
	move.l	D2, D3					; D3 lîschen
	move.w	hor_rez, D2				; letzte Pixelspalte
	move.w	D2, -$2B4(A0)			; Infos, die man bei v_openwk erhÑlt
	move.w	ver_rez, D3				; letzte Pixelzeile
	move.w	D3, -$2B4+2(A0) 		; Infos, die man bei v_openwk erhÑlt
	move.w	#2, -$2B4+78(A0)		; -"-
	addq.w	#1, D2					; Breite = Pixelspalte + 1
	addq.w	#1, D3					; Hîhe = Zeile + 1
	move.w	D2, -$0C(A0)			; Bildschirmbreite in Pixel
	move.w	D3, -$04(A0)			; Bildschirmhîhe in Pixel

	move.w	$52(A1), D0				; Hîhe des Systemzeichensatz
	move.w	D0, -$2E(A0)			; Zeichenhîhe

	move.w	hor_byte, D1			; 
	move.w	D1, $2(A0)				; Bytes pro Bildschirmzeile
	
	mulu	D0, D1					; Zeichenhîhe * Bytes pro Zeile
	move.w	D1, -$28(A0)			; Charakterzeilenbreite in Bytes

	divu	D0, D3					; Bildschirmhîhe / Zeichenhîhe 
	subq.w	#1, D3					; letzte Zeichenspalte
	move.w	D3, -$2A(A0)			; maximale Cursor-Zeilenposition

	divu	$34(A1), D2				; Bildschirmbreite / Zeichenbreite
	subq.w	#1, D2					; letzte Zeichenzeile
	move.w	D2, -$2C(A0)			; maximale Cursor-Spaltenposition

	move.l	#Bildspeicher, -$22(A0) ; aktuelle Adresse der Cursorposition
	move.w	#0, -$1E(A0)			; Bildschirmanfang
	move.l	#0, -$1C(A0)			; X- und Y-Position des Cursors
	move.w	hor_byte, -$02(A0)		; Bytes pro Pixelzeile
	move.w	#1, (A0)				; Bit-Planes
	movem.l	(sp)+,d0-d7/a0-a6
	rts								; Unterprogramm beenden


New_Trap_02:
	movem.l A0-A1, -(SP)			; A0 und A1 retten
	cmp.w	#VDI, D0				; Kennung fÅr VDI-Funktion ?
	bne.b	Use_Old 				; nein -> alte Routine verwenden

	movea.l D1, A0					; Zeiger auf Parameterblock
	movea.l (A0), A1				; Zeiger auf Contrl-Array
	cmpi.w	#v_opnwk, (A1)			; Open Workstation ?
	beq.b	New_VDI 				; ja -> eigene Routine verwenden

Use_Old:
	movem.l (SP)+, A0-A1			; A0 und A1 wiederherstellen
	move.l	Old_Trap_02(PC), -(SP)	; Adresse der alten Funktion auf Stack
	rts								; und anspringen

New_VDI:
	movea.l 4(A0), A1				; Zeiger auf Intin-Array
	cmpi.w	#9, (A1)				; 
	bgt.b	Use_Old 				; 

	pea	Nach_VDI_1					; Routine nach normaler Funktion ausfÅhr
	move.w	12(SP), -(SP)			; Status fÅr diese Routine
	ori.w	#$2000, (SP)			; Supervisormodus im Status setzen
	move.l	Old_Trap_02(PC), -(SP)	; Sprungadresse fÅr normale Funktion
	rts								; normale Funktion ausfÅhren

Nach_VDI_1:
	movea.l 12(A0), A1				; Zeiger auf Intout-Array
	move.w	hor_rez, (A1)			; 
	move.w	ver_rez, 2(A1)			; 
	move.w	#2, 78(A1)				;

	movea.l LineA_Vec(PC), A0		; Zeiger auf LineA-Variablen
	move.w	hor_rez, -$2B4(A0)		; letzte Pixelspalte
	move.w	ver_rez, -$2B2(A0)		; letzte Pixelzeile

	movem.l (SP)+, A0-A1			; A0 und A1 wiederherstellen
	rte								; Ende TRAP #2

New_Trap_14:
	move	USP, A0 				; Bei Aufruf aus dem USER-Modus
	btst	#5, (SP)				; Supervisormode bei Aufruf?
	beq.b	_Next					; Nein, also weiter ->

	movea.l SP, A0					; SSP verwenden
	addq.l	#6, A0					; + Len (Returnadresse & Status)
	tst		_longframe				; ist es ein 68010 oder hîher?
	beq.b	_Next					; nee
	addq.l	#2, A0					; Beim TT o.Ñ. 1 Wort mehr auf Stack

_Next:
	cmpi.w	#Physbase, (A0) 	; Funktion Physbase ?
	beq.b	New_Physbase		; eigene Routine verwenden
	cmpi.w	#Getrez, (A0)		; Funktion Getrez ?
	beq.b	New_Getrez			; eigene Routine verwenden
	cmpi.w	#Setscreen, (A0)	; Funktion Setscreen ?
	beq.b	New_Setscreen		; eigene Routine verwenden
	movea.l Old_Trap_14(PC), A0	; sonst alte XBIOS-Routine
	jmp	(A0)					; benutzen

New_Physbase:
	move.l	#Bildspeicher, D0	; Bildschirmadresse zurÅckgeben
	rte
	
New_Getrez:
	moveq	#2, D0				; High Resolution
	rte

New_Setscreen:
	move.w	#-1, 10(A0)			; Auflîsung nicht Ñndern
	move.l	#-1, 6(A0)			; Physbase nicht Ñndern
	move.l	Old_Trap_14(PC), A0	; ggf. Logbase Ñndern
	jmp	(A0)
	
	.EVEN
	
hor_rez:    dc.w    1279
ver_rez:    dc.w    959
hor_byte:   dc.w    160

Old_Trap_02:	dc.l	0
Old_Trap_14:	dc.l	0
LineA_Vec:		dc.l	0
