; ****************************************
; *      F a s t l o a d e r  V3.0       *
; *        von Carsten Reinhardt         *
; *        fr TOS-Versionen vom         *
; *         6.2.86 und 22.4.87           *
; *    Abgeleitet aus der Version 2.0    *
; *        von Michael Bernards          *
; *    fr Markt & Technik Verlag AG     *
; *          Redaktion 68oooer           *
; *                                      *
; * Last Update: 02/08/87 21:00          *
; ****************************************

start:	move.l $04(a7),a5		; Speicherbedarf berechnen:
	move.l $0c(a5),d6		; L„nge des Text-Segments
	add.l $14(a5),d6		; L„nge des Data-Segments
	add.l $1c(a5),d6		; L„nge des BSS-Segments
	add.l #$2000,d6			; L„nge des Puffer-Bereichs
	move.l d6,length		; ...und sichern
	cmp #$7c14,$7a1c		; Prfen, ob TOS im RAM
	bne rom				; Nein -> ROM-TOS 
	move #$7c10,$7a1c		; RAM patchen
	bra ready			; Zur Textausgabe
rom:	pea copy			; Adr. d. Kopier-Rout. auf Stack
	move #$26,-(a7)			; Funktion SUPEXEC
	trap #14			; XBIOS aufrufen
	addq.l #6,a7			; Stack-Korrektur
	cmp.l #$02061986,$fc0018	; TOS-Datum auf 6.2.86 prfen
	beq patch1			; Ja -> Normales TOS patchen
	cmp.l #$04221987,$fc0018	; TOS-Datum auf 22.4.87 prfen
	beq patch2			; Ja -> Blitter-TOS patchen
	bra wrong			; Nein -> Fehlermeldung
cont:	pea vektor			; Routine zum Vektor umlegen 
	move #$26,-(a7)			; Funktion SUPEXEC
	trap #14			; XBIOS aufrufen
	addq.l #6,a7			; Stack-Korrektur
ready:	pea text			; Adr. des Textes auf Stack
	move #$09,-(a7)  		; Funktion PRINT LINE
	trap #1				; GEMDOS aufrufen
	addq.l #6,a7			; Stack-Korrektur
	clr -(a7)			; Keine Fehlermeldung
	move.l length,-(a7)		; soviel Bytes schtzen
	move #$31,-(a7)			; Funktion KEEP PROCESS
	trap #1				; GEMDOS aufrufen

length:	dc.l 0				; Speicher fr Programml„nge

					; Fehlermeldung ausgeben + Exit
wrong:	move.b #$0d,c_ret		; NULL-Byte durch CR ersetzen
	pea text			; Adr. des Textes auf Stack
	move #$09,-(a7)			; Funktion PRINT LINE
	trap #1				; GEMDOS aufrufen
	addq.l #6,a7			; Stack-Korrektur
	move #7,-(a7)			; Funktion CON IN WITHOUT ECHO
	trap #1				; GEMDOS aufrufen
	addq.l #2,a7			; Stack-Korrektur
	clr -(a7)			; Funktion TERM
	trap #1				; GEMDOS aufrufen

					; Text-Konstanten
text:	dc.b $1b,$45,$0a,$20,$1b,$70
	dc.b "Fastloader V3.0 von Carsten Reinhardt "
	dc.b "/ M. Bernards fr 68oooer-Magazin"
	dc.b $1b,$71,$0d,$0a
c_ret:	dc.b $00
	dc.b $20,$07,$07
	dc.b "Kein ROM- oder Blitter-TOS !! Fastloader kann nicht "
	dc.b "installiert werden!"
	dc.b $0d,$0a,$00
	even

					; Kopieren von 8 KB ROM-Code
					; ins RAM
copy:	lea $fc0000,a0			; Start ATARI ROM-TOS
	lea buffer,a1			; Start Kopierpuffer
	move #$800,d0			; 2048 Durchl„ufe -> 8 KByte
c_loop:	move.l (a0)+,(a1)+		; Schaufel, schaufel, ...
	dbra d0,c_loop			; D0>=0 -> Zurck in die Schleife
	rts				; Zurck zum Hauptprogramm

					; Eigentliche Patch-Routinen:
					; Relozieren der absoluten ROM-
					; Adressen und Ausschalten des
					; Verify
					; 1. Normales TOS
patch1:	lea offset1,a0			; Adresse der Offset-Tabelle
p1_la1:	tst.l (a0)			; schon fertig ?
	beq p1_la2			; Ja -> Schleife verlassen
	move.l (a0)+,a1			; Tabellenwert in A1
	add.l #buffer,a1		; dazu Adresse RAM-Code
	sub.l #$fc0000,(a1)		; und betreffendes Langwort
	add.l #buffer,(a1)		;                relozieren
	bra p1_la1			; ...und von vorne
p1_la2:	move.l #$1b8f,a0		; Offset fr Seek + Verify-Bef.
	add.l #buffer,a0		; plus Adresse RAM-Code
	move.b #$10,(a0)		; Befehl durch Seek-only ersetzen
	bra cont			; Zurck zum Hauptprogramm
					; 2. Blitter-TOS
patch2:	lea offset2,a0			; Adresse der Offset-Tabelle
p2_la1:	tst.l (a0)			; schon fertig ?
	beq p2_la2			; Ja -> Schleife verlassen
	move.l (a0)+,a1			; Tabellenwert in A1
	add.l #buffer,a1		; dazu Adresse RAM-Code
	sub.l #$fc0000,(a1)		; und betreffendes Langwort
	add.l #buffer,(a1)		;                relozieren
	bra p2_la1			; ...und von vorne
p2_la2:	move.l #$1d8f,a0		; Offset fr Seek + Verify-Bef.
	add.l #buffer,a0		; plus Adresse RAM-Code
	move.b #$10,(a0)		; Befehl durch Seek-only ersetzen
	move #$ffff,flag		; Flag fr Blitter-TOS setzen
	bra cont			; Zurck zum Hauptprogramm

offset1:dc.l $1232			; Offset-Tabelle der absoluten
	dc.l $1260			; ROM - "jsr's"
	dc.l $1296			; im Normalen TOS
	dc.l $13c8
	dc.l $0

offset2:dc.l $1416			; Offset-Tabelle der absoluten
	dc.l $1444			; ROM - "jsr's"
	dc.l $147a			; im Blitter-TOS
	dc.l $15ac
	dc.l $0
					; Routine zum Vektor "umbiegen"
vektor:	move.l $476,save1		; Original retten
	move.l #new_v,$476		; Eigenen Vektor einsetzen
	rts				; Zurck zum Hauptprogramm

					; Neuer Einsprungpunkt
new_v:	tst flag			; Flag prfen 
	beq new_1			; Normales ROM-TOS
	cmp #2,$0e(a7)			; prfen ob Lese-Operation
	bmi buffer+$12b6		; Ja   -> Patch anspringen
	bra no_read			; Nein -> Alten Vektor anspr.
new_1:	cmp #2,$0e(a7)			; prfen ob Lese-Operation
	bmi buffer+$10d2		; Ja   -> Patch anspringen
no_read:move.l save1,a0			; Nein -> Alten Vektor laden
	jmp (a0)			;         und anspringen


flag:	dc.w 0                          ; Flag fr Blitter-TOS
save1:	dc.l 0				; Speicher fr Original-Vektor
buffer:					; Speicher fr RAM-Code
