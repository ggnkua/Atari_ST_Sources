* -------------------------------------------------- *
*
*		XFORMDO.LIB Version 1.2
*
*	   geschrieben von Michael Maier 1991
*
* -------------------------------------------------- *

* -------------------------------------------------- *
* Modul: XFORMS.Q
* Version: 1.1
* Datum: 14.9.1991
* -------------------------------------------------- *

	PATH	include 	kann geÑndert werden!

**************************************************************************
*
* Include-Anweisungen
*
**************************************************************************
	include types.i
	include gem.i
	include xobjects.i
	include xform.i

**************************************************************************
*
* Konstanten
*
**************************************************************************
BEG_UPDATE	EQU	$0001
END_UPDATE	EQU	$0000
BEG_MCTRL	EQU	$0003
END_MCTRL	EQU	$0002

**************************************************************************
*
* Fly-Objekt suchen und ggf. ein/ausschalten
* ------------------------------------------
*
* IN	A0.l	Zeiger auf Baum
*	A1.l	Zeiger auf DINFO
*
**************************************************************************
	LOCAL
find_fly:
	move.l	A0,-(SP)	; Register retten

.loop:

	lea	ob_size(A0),A0	; nÑchstes Objekt
	move.w	ob_type(A0),D0	;
	cmp.w	#G_FLY,D0	; Fly-Objekt?
	bne	.nofly		; nein
	move.w	ob_state(A0),D0 ;
	bclr	#3,D0		;
	tst.w	di_flag(A1)	; Hintergrund gespeichert?
	bne	.yes		; ja -> Fly-Objekt anwÑhlbar
	bset	#3,D0		; nein -> Fly-Objekt nicht anwÑhlbar

.yes:
	move.w	D0,ob_state(A0) ; neuer Status
	bra	.ende		; und zurÅck

.nofly:
	move.w	ob_flags(A0),D0 ; letztes Objekt?
	and.w	#LASTOB,D0	;
	beq	.loop		; nein -> weiter suchen
.ende:
	move.l	(SP)+,A0	;
	rts			;

**************************************************************************
*
* Dialog îffnen
* VOID open_dia(OBJECT *tree, DINFO *info, BOOLEAN flag)
* =>	A0.l	Zeiger auf Baum
*	A1.l	Zeiger auf DINFO-Struktur
*	D0.w	Flag: TRUE = Mauskoordinaten als Ursprung
*
**************************************************************************
	LOCAL
	GLOBL	open_dia
open_dia:
	movem.l #CREGS,-(SP)		; Register retten

	IFD	DR
	move.l	60(SP),A0
	move.l	64(SP),A1
	move.w	68(SP),D0
	ENDIF

	lea	basis,A4		; Basisregister
	link	A6,#-fd_size		; lokale Variabeln
	move.l	SP,A5			; Zeiger auf MFDB

	clr.l	fd_addr(A5)		; Quelle = Ziel

	move.w	D0,D7				; Kontrolle Åbernehmen
	move.w	#BEG_UPDATE,gl_intin(A4)	; BEG_UPDATE
	move.l	#wind_update,D0 		;
	bsr	aes				;
	move.w	#BEG_MCTRL,gl_intin(A4) 	; BEG_MCTRL
	move.l	#wind_update,D0 		;
	bsr	aes				;

	tst.w	D7			; Flag testen
	beq	.nokoord		; keine neuen Koordinaten

	move.l	#graf_mkstate,D0	;
	bsr	aes			; Koordinaten besorgen
	move.w	gl_intout+2(A4),D1	; x
	move.w	gl_intout+4(A4),D2	; y

	move.w	ob_width(A0),D0 	; Breite / 2
	lsr.w	#1,D0			;
	sub.w	D0,D1			; x-Koordinate

	cmp.w	#6,D1			; linker Rand ok?
	bgt	.linksok
	move.w	#6,D1			; nein -> linker Rand = 6

.linksok:

	move.w	ob_height(A0),D0	; Hîhe / 2
	lsr.w	#1,D0			;
	sub.w	D0,D2			; y-Koordinate

	clr.w	gl_intin(A4)		; Arbeitsfenster vom GEM
	move.w	#4,gl_intin+2(A4)	; WORKXYWH
	move.l	#wind_get,D0		;
	bsr	aes			;
	move.w	gl_intout+4(A4),D4	;
	add.w	#6,D4			;
	cmp.w	D4,D2			; obere Rand ok?
	bgt	.obenok 		; ja
	move.w	D4,D2			; nein -> oberer Rand = 6

.obenok:

	move.w	D1,D3			; x-Koordinate
	add.w	ob_width(A0),D3 	; + Breite
	add.w	#5,D3			; + Rand
	cmp.w	gl_max_w(A4),D3 	; rechter Rand ok?
	ble	.rechtsok		; ja

	sub.w	gl_max_w(A4),D3 	; Differenz bilden
	sub.w	D3,D1			; diese von x-Koordinate abziehen

.rechtsok:

	move.w	D2,D3			; y-Koordinate
	add.w	ob_height(A0),D3	; + Breite
	add.w	#5,D3			; + Rand
	cmp.w	gl_max_h(A4),D3 	; unterer Rand ok?
	ble	.untenok		; ja

	sub.w	gl_max_h(A4),D3 	; Differenz bilden
	sub.w	D3,D2			; diese von y-Koordinate abziehen

.untenok:

	move.w	D1,ob_x(A0)		; Koordinaten eintragen
	move.w	D2,ob_y(A0)		;

.nokoord:

	move.l	ob_x(A0),gl_ptsin(A4)		; Clipbereich
	move.l	ob_x(A0),D0
	add.l	ob_width(A0),D0 		; gegenÅberliegende Punkte
	move.l	D0,gl_ptsin+4(A4)		;

	move.w	#1,gl_intin(A4) 		; Clippen ein
	move.l	#$00810002,gl_contrl(A4)	; Contrl-Werte...
	move.l	#$00000001,gl_contrl+4(A4)	;
	clr.w	gl_contrl+8(A4) 		;
	bsr	vdi				; vs_clip

	move.w	ob_width(A0),D0 	; Breite
	cmp.w	gl_max_w(A6),D0 	; Breite des Bildschirms
	blt	.konventionell

	addq	#5,D0			; + 5 wegen OUTLINED

	addq.w	#7,D0			;
	addq.w	#7,D0			;
	addq.w	#1,D0			; + 15
	lsr.w	#4,D0			; durch 16
	move.w	D0,fd_wdwidth(A1)	; Breite in Wîrtern
	move.w	D0,D1			;
	lsl.w	#4,D1			; * 16
	move.w	D1,fd_w(A1)		; = Breite in Pixel
	move.w	ob_height(A0),D7	; Hîhe
	addq	#5,D0			; + 10 wegen OUTLINED
	move.w	D7,fd_h(A1)		; eintragen
	add.w	D0,D0			; Breite in Bytes
	ext.l	D0			;
	ext.l	D7			; alles Long
	mulu	D0,D7			; Breite mal Hîhe
	mulu	gl_planes(A4),D7	; mal Anzahl der Ebenen +
	move.l	D7,di_length(A1)	; LÑnge merken
	movem.l A0/A1,-(SP)		;
	move.l	#-1,-(SP)		;
	move.w	#$48,-(SP)		;
	trap	#GEMDOS 		; wieviel ist frei?
	
	sub.l	D7,D0			;
	sub.l	#8*1024,D0		;
	bmi	.error			; zu wenig!

	move.l	D7,2(SP)		; LÑnge
	trap	#GEMDOS 		; Malloc
	bra	.gÑhn			;

.error:

	clr.l	D0			; Fehler!

.gÑhn:
	addq.l	#6,SP			;
	movem.l (SP)+,A0/A1		;
	move.w	#$0001,di_flag(A1)	; TRUE eintragen
	move.l	D0,fd_addr(A1)		; Adresse eintragen
	bne	.auto			; kein Fehler -> weiter

.konventionell:

	clr.w	di_flag(A1)		; sonst -> konventionell
	clr.w	gl_intin(A4)		; FMD_START
	move.l	ob_x(A0),D0		;
	sub.l	#$00030003,D0		;
	move.l	D0,gl_intin+10(A4)	; 1. Punkt
	move.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		;
	move.l	D0,gl_intin+14(A4)	; 2. Punkt

	move.l	#form_dial,D0		;
	bsr	aes			; Bereich reservieren
	bra	.zeichnen		; und Zeichnen
	
.auto:
	move.w	#256,gl_intin(A4)	;
	move.l	#graf_mouse,D0		;
	bsr	aes			; Maus aus
	
	move.w	gl_vhandle(A4),gl_contrl+12(A4)      ; VDI-Handle eintragen
	move.w	#$0003,gl_intin(A4)	; VerknÅpfung
	move.l	A5,gl_contrl+14(A4)	; Quelle
	move.l	A1,gl_contrl+18(A4)	; Ziel

	clr.w	fd_stand(A1)			; 0 gerÑteabhÑngig
	move.w	gl_planes(A4),fd_nplanes(A1)	; Ebenen

	move.l	ob_x(A0),D0		;
	sub.l	#$00030003,D0		; wegen OUTLINED!
	move.l	D0,gl_ptsin(A4) 	; 1. Punkt der Quelle
	add.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		; 
	move.l	D0,gl_ptsin+4(A4)	; 2. Punkt der Quelle
	clr.l	gl_ptsin+8(A4)		; 1. Punkt des Ziels
	move.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		;
	move.l	D0,gl_ptsin+12(A4)	; 2. Punkt des Ziels

	move.w	#$0003,gl_intin(A4)	; E = Q
	bsr	vro_cpyfm		; kopieren

	move.w	#257,gl_intin(A4)	;
	move.l	#graf_mouse,D0		;
	bsr	aes			; Maus ein

.zeichnen:
	bsr	find_fly		; Fliegendes Objekt ein/ausschalten

	clr.w	gl_intin(A4)		; Start beim 1. Objekt
	move.w	#$0008,gl_intin+2(A4)	; Tiefe
	clr.l	gl_intin+4(A4)		;
	move.l	gl_max_w(A4),gl_intin+8(A4)		;
	move.l	A0,gl_addrin(A4)	; Zeiger auf Baum
	move.l	#objc_draw,D0		;
	bsr	aes			; und zeichnen

.ende:

	unlk	A6			; lokaler Bereich
	movem.l (SP)+,#CREGS		; Register
	rts				; und zurÅck

**************************************************************************
*
* Dialog schlieûen
* VOID clse_dia(OBJECT *tree, DINFO *info)
* =>	A0.l	Zeiger auf Baum
*	A1.l	Zeiger auf DINFO-Struktur
*
**************************************************************************
	LOCAL
	GLOBL	clse_dia
clse_dia:
	movem.l #CREGS,-(SP)		; Register retten

	IFD	DR
	move.l	60(SP),A0
	move.l	64(SP),A1
	move.w	68(SP),D0
	ENDIF
	
	lea	basis,A4		; Basis
	link	A6,#-fd_size		; lokale Variabeln
	move.l	SP,A5			; Zeiger auf MFDB
	clr.l	fd_addr(A5)		; Ziel

	tst.w	di_flag(A1)		; Restauration?
	bne	.auto			;

	move.w	#$0003,gl_intin(A4)	; FMD_FINISH
	move.l	ob_x(A0),D0		;
	sub.l	#$00030003,D0		;
	move.l	D0,gl_intin+10(A4)	; 1. Punkt
	move.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		;
	move.l	D0,gl_intin+14(A4)	; 2. Punkt
	move.l	#form_dial,D0		;
	bsr	aes			; Bereich freigeben
	bra	.ende			; und zurÅck

.auto:

	move.w	#256,gl_intin(A4)	;
	move.l	#graf_mouse,D0		;
	bsr	aes			; Maus aus
	
	clr.w	gl_intin(A4)			; Clippen aus
	move.l	#$00810002,gl_contrl(A4)	; Contrl-Werte...
	move.l	#$00000001,gl_contrl+4(A4)	;
	clr.w	gl_contrl+8(A4) 		;
	bsr	vdi				; vs_clip

	move.w	gl_vhandle(A4),gl_contrl+12(A4) ; VDI-Handle eintragen
	move.l	A5,gl_contrl+18(A4)		; Ziel
	move.l	A1,gl_contrl+14(A4)		; Quelle
	move.w	#$0003,gl_intin(A4)		; VerknÅpfung

	clr.l	gl_ptsin(A4)		; 1. Punkt der Quelle
	move.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		;

	move.l	D0,gl_ptsin+4(A4)	; 2. Punkt der Quelle
	move.l	ob_x(A0),D0		;

	sub.l	#$00030003,D0		; wegen OUTLINED!
	move.l	D0,gl_ptsin+8(A4)	; 1. Punkt des Ziels
	add.l	ob_width(A0),D0 	;
	add.l	#$00050005,D0		; 

	move.l	D0,gl_ptsin+12(A4)	; 2. Punkt des Ziels

	bsr	vro_cpyfm		; kopieren
	move.w	#257,gl_intin(A4)	;
	move.l	#graf_mouse,D0		;
	bsr	aes			; Maus ein

	move.l	fd_addr(A1),-(SP)	;
	move.w	#$49,-(SP)		; Mfree
	trap	#GEMDOS 		;
	addq.l	#6,SP			;

.ende:

	move.w	#END_UPDATE,gl_intin(A4)	; Kontrolle abgeben
	move.l	#wind_update,D0 		;
	bsr	aes				;
	move.w	#END_MCTRL,gl_intin(A4) 	; END_MCTRL
	move.l	#wind_update,D0 		;
	bsr	aes				;

	unlk	A6			; lokaler Bereich
	movem.l (SP)+,#CREGS		; Register
	rts				; und zurÅck

**************************************************************************
*
* VDI-Aufrufe
*
**************************************************************************
vro_cpyfm:
	move.l	#$006D0004,gl_contrl(A4)	; Contrl-Werte...
	move.l	#$00000001,gl_contrl+4(A4)	;
	clr.w	gl_contrl+8(A4) 		;
	bra	vdi				; und aufrufen

**************************************************************************
*
* AES-Aufrufe
*
**************************************************************************
objc_draw	EQU	$2A060101
form_dial	EQU	$33090100
form_center	EQU	$36000501
graf_mkstate	EQU	$4F000500
graf_mouse	EQU	$4E010101
wind_update	EQU	$6B010100
wind_get	EQU	$68020500
	END
