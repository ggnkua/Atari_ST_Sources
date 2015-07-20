*-------------------------------------------------------------------------------
* SEARCH_SYMBOL: sucht die Symboltabellen nach dem gesuchten Wert ab
*				 (zus„tzlich die Symboltabelle des Resident Symbol Drivers)
* ---> D3.l = Symbolwert
* <--- A0.l = Zeiger auf gefundenen Symbolnamen
* <--- flag.eq = nicht gefunden, flag.ne = gefunden
*
* SEARCH_WITHIN: sucht die Symboltabellen nach dem kleinsten Wert innerhalb
*				 gewisser Grenzen ab
* ---> D0.l = untere Grenze
* ---> D1.l = obere Grenze
* <--- D0.l = neue untere Grenze (gefundener Symbolwert)
* <--- A0.l = Zeiger auf gefundenen Symbolnamen
* <--- flag.eq = nicht gefunden, flag.ne = gefunden
*
* SEARCH_VALUES: sucht die Symboltabelle(n) nach dem gesuchten Symbol ab
* ---> D0.w = Stringl„nge
* ---> A2.l = Zeiger auf Symbolnamen (ohne Stringende)
* <--- D0.w = Stringl„nge-Symbolnamenl„nge
* <--- D3.l = gefundener Symbolwert
* <--- A2.l = Zeiger auf Symbolnamenende+1
* <--- flag.eq = nicht gefunden, flag.ne = gefunden
*
* SYMBOL_LADEN_1: Liest und konvertiert die Symboldatei eines Programms. Diese
*				  Routine darf erst nach dem Setzen der FILE... Variablen auf-
*				  gerufen werden (FILE_TEXT etc.).
*
* SYMBOL_LADEN_2: Liest und konvertiert die Symboldatei PEACEBUG.SYM.
*-------------------------------------------------------------------------------

		.EXPORT		SYMBOL_LADEN_1,SYMBOL_LADEN_2,SEARCH_WITHIN
		.EXPORT		SEARCH_VALUES,SEARCH_SYMBOL
		.EXPORT		SYMBOL_TABLE_1,SYMBOL_TABLE_2,SYMBOL_TABLE_3
		.EXPORT		ANZAHL_SYMBOLE_1,ANZAHL_SYMBOLE_2,ANZAHL_SYMBOLE_3
		.EXPORT		SYMBOL_VALUE,RES_SYMDRIVER

*-------------------------------------------------------------------------------

		.BSS
SYMBOL_TABLE_1: 	ds.l	1					; Programmsymbole
ANZAHL_SYMBOLE_1:	ds.l	1
SYMBOL_TABLE_2: 	ds.l	1					; Konstantentabelle
ANZAHL_SYMBOLE_2:	ds.l	1

RES_SYMDRIVER:		ds.l	1

*---------------

		.DATA
FILE:				dc.b	'PEACEBUG.SYM',0
		.EVEN

SYMBOL_TABLE_3: 	DC.L	SYMBOL_VALUE
ANZAHL_SYMBOLE_3:	dc.l	12
SYMBOL_VALUE:		DC.L	0,0,0,0,0,0,0,0,0,0,0,0	; Werte
SYMBOL_POINTER:		dc.l	SY_BP					; Pointer
					dc.l	SY_BP_K
					DC.L	SY_TEXT
					DC.L	SY_TEXT_K
					dc.l	SY_DATA
					dc.l	SY_DATA_K
					dc.l	SY_BSS
					dc.l	SY_BSS_K
					dc.l	SY_START
					dc.l	SY_START_K
					dc.l	SY_END
					dc.l	SY_END_K
SY_BP:				dc.b	'BP',0
SY_BP_K:			dc.b	'bp',0
SY_TEXT:			dc.b	'TEXT',0				; Strings
SY_TEXT_K:			dc.b	'text',0
SY_DATA:			dc.b	'DATA',0
SY_DATA_K:			dc.b	'data',0
SY_BSS:	 			dc.b	'BSS',0
SY_BSS_K:			dc.b	'bss',0
SY_START:			dc.b	'START',0
SY_START_K:			dc.b	'start',0
SY_END: 			dc.b	'END',0
SY_END_K:			dc.b	'end',0
		.EVEN

*-------------------------------------------------------------------------------

		.TEXT
SEARCH_SYMBOL:	tst.l		d3					; Symbolwert=0?
				beq			rts
				tst.b		SYMBOL_FLAG			; Symbole erlaubt?
				beq			rts
				movem.l		d0-d7/a1-a6,-(sp)
				move.l		ANZAHL_SYMBOLE_1,d2
				movea.l		SYMBOL_TABLE_1,a0
				bsr			SUCHEN				; Symboltabelle 1
				bne.s		.found
				move.l		ANZAHL_SYMBOLE_2,d2
				movea.l		SYMBOL_TABLE_2,a0
				bsr			SUCHEN				; Symboltabelle 2
				bne.s		.found

				move.l		ANZAHL_SYMBOLE_3,d2	; Symboltabelle 3
				movea.l		SYMBOL_TABLE_3,a0
				move.l		d2,d0
				subq.l		#1,d2
.loop:			cmp.l		(a0)+,d3
				dbeq		d2,.loop
				bne.s		.cont
				add.l		d0,d0
				add.l		d0,d0
				move.l		-4(a0,d0.l),a0		; Pointer auf Symbolnamen
				bra.s		.found

.cont:			tst.b		SYMBOL_FLAG			; Symboldriver erlaubt?
				bpl.s		.fail
				tst.l		RES_SYMDRIVER		; Symboldriver installiert?
				beq.s		.fail
				movea.l		RES_SYMDRIVER,a0
				move.l		8(a0),a0
				move.l		d3,d0
				jsr			(a0)				; Symboldriver aufrufen
				tst.l		d0
				bne.s		.fail
				addq.w		#5,a0				; Pointer auf Symbolnamen

.found:			moveq		#-1,d0
				bra.s		.ende
.fail:			moveq		#0,d0
.ende:			movem.l		(sp)+,d0-d7/a1-a6
rts:			rts

*---------------

SUCHEN:			move.l		d2,d0				; keine Symbole?
				beq.s		rts
				subq.l		#1,d2
				add.l		d2,d2
				add.l		d2,d2
				lea			(a0,d2.l),a1		; a1 = letztes Element
				movea.l		a0,a2				; erstes Element testen
				cmp.l		(a2),d3
				beq.s		.found
				blo.s		.fail
				movea.l		a1,a2				; letztes Element testen
				cmp.l		(a2),d3
				beq.s		.found
				bhi.s		.fail
.bisection:		move.l		a1,d2				; mittleres Element bestimmen
				sub.l		a0,d2
				lsr.l		#1,d2
				and.b		#$fc,d2
				tst.l		d2
				beq.s		.fail
				lea			(a0,d2.l),a2
				cmp.l		(a2),d3
				bhi.s		.upper
				beq.s		.found
				movea.l		a2,a1
				bra.s		.bisection
.upper:			movea.l		a2,a0
				bra.s		.bisection

.fail:			moveq		#0,d0
				rts
.found:			add.l		d0,d0
				add.l		d0,d0
				move.l		(a2,d0.l),a0
				moveq		#-1,d0
				rts

*-------------------------------------------------------------------------------

SEARCH_WITHIN:	tst.b		SYMBOL_FLAG			; Symbole erlaubt?
				beq.s		rts
				movem.l		d1-d7/a1-a6,-(sp)
				move.l		ANZAHL_SYMBOLE_1,d2	; Symboltabelle 1
				beq.s		.cont
				movea.l		SYMBOL_TABLE_1,a0
				bra.s		.suchen
.cont:			move.l		ANZAHL_SYMBOLE_2,d2	; Symboltabelle 2
				movea.l		SYMBOL_TABLE_2,a0

.suchen:		move.l		d2,d7
				beq.s		.fail
				subq.l		#1,d2
.loop:			cmp.l		(a0)+,d0			; untere Grenze testen
				bhi.s		.too_low
				cmp.l		-(a0),d1			; obere Grenze testen
				blo.s		.fail
				bra.s		.found
.too_low:		dbra		d2,.loop
				subi.l		#$010000,d2
				bpl.s		.loop
				bra.s		.fail

.found:			move.l		(a0),d0				; Symbolwert
				add.l		d7,d7
				add.l		d7,d7
				movea.l		(a0,d7.l),a0		; Pointer auf Symbolnamen
				moveq		#-1,d7
				bra.s		.ende
.fail:			moveq		#0,d7
.ende:			movem.l		(sp)+,d1-d7/a1-a6
RTS:			rts

*-------------------------------------------------------------------------------

SEARCH_VALUES:	tst.b		SYMBOL_FLAG			; Symbole erlaubt?
				beq.s		RTS
				movem.l		d1-d2/d4-a1/a3-a6,-(sp)
				movea.l		SYMBOL_TABLE_3,a0
				move.l		ANZAHL_SYMBOLE_3,d2
				bsr			SEARCH_VALUE		; Symboltabelle 3
				bne.s		.found
				movea.l		SYMBOL_TABLE_2,a0
				move.l		ANZAHL_SYMBOLE_2,d2
				bsr			SEARCH_VALUE		; Symboltabelle 2
				bne.s		.found
				movea.l		SYMBOL_TABLE_1,a0
				move.l		ANZAHL_SYMBOLE_1,d2
				bsr			SEARCH_VALUE		; Symboltabelle 1
				bne.s		.found

* Leider hat der RSD einen Fehler, er schreibt n„mlich ein Nullbyte
* in den String, ohne es anschliessend wieder zu restaurieren.
				tst.b		SYMBOL_FLAG			; Symboldriver erlaubt?
				bpl.s		.fail
				tst.l		RES_SYMDRIVER		; Symboldriver installiert?
				beq.s		.fail
				movea.l		a2,a3				; Stringende suchen...
				move.w		d0,d1
.search_1:		lea			.table(pc),a4
				move.b		(a3),d2
.search_0:		cmp.b		(a4)+,d2
				beq.s		.end_of_string
				tst.b		(a4)
				bne.s		.search_0
				addq.w		#1,a3
				dbra		d1,.search_1
.end_of_string:	movea.l		a2,a0				; a0 = Stringanfang
				suba.l		a1,a1				; a1 = 0
				movem.l		d0/a2,-(sp)
				movea.l		RES_SYMDRIVER,a2	; a2 = Routinenadresse
				movea.l		12(a2),a2
				move.b		(a3),-(sp)
				clr.b		(a3)				; ---> Fehler des RSD
				jsr			(a2)				; Symboldriver aufrufen
				move.b		(sp)+,(a3)
				tst.l		d0
				movem.l		(sp)+,d0/a2
				bne.s		.fail
				move.l		(a0),d3				; Symbolvalue
				movea.l		a3,a2
				move.l		d1,d0
.found:			moveq		#-1,d1
				bra.s		.ende
.fail:			moveq		#0,d1
.ende:			movem.l		(sp)+,d1-d2/d4-a1/a3-a6
				rts

*---------------

.table:			dc.b		'*','+','/','-','&','|','^','>','<','%','!',',',')',' ',0
		.EVEN

*---------------

SEARCH_VALUE:	move.l		d2,d1				; Anzahl=0?
				beq.s		.fail
				add.l		d1,d1
				add.l		d1,d1
				lea			(a0,d1.l),a0		; a0 = Anfang der Pointer
				subq.l		#1,d2
.loop1:			movea.l		(a0)+,a1			; a1 = Pointer auf Symbolnamen
				move.l		a2,a3				; a3 = gesuchter Symbolname
				move.w		d0,d4				; d0 ist schon L„nge-1...
.loop2:			tst.b		(a1)				; Stringende?
				beq.s		.found
				cmpm.b		(a1)+,(a3)+
				dbne		d4,.loop2
				bne.s		.cont
				tst.b		(a1)
				beq.s		.found
.cont:			dbra		d2,.loop1
				sub.l		#$10000,d2
				bpl.s		.loop1
.fail:			moveq		#0,d1
				rts
.found:			neg.l		d1
				move.l		-4(a0,d1.l),d3		; Symbolvalue
				sub.l		a3,d0				; Stringl„nge
				add.l		a2,d0				; und Stringzeiger
				movea.l		a3,a2				; anpassen
				moveq		#-1,d1
				rts

*-------------------------------------------------------------------------------

SYMBOL_LADEN_1:	movem.l		d0-a5,-(sp)			; Programmsymbole laden
				link		a6,#-28				; Platz fr Header schaffen
				clr.l		ANZAHL_SYMBOLE_1

				moveq		#0,d0
				lea			FILE_NAME,a2
				jsr			FOPEN				; Datei ”ffnen
				bmi			.symbol_fail

				moveq		#28,d3				; Headerl„nge
				move.l		sp,a3
				jsr			FREAD				; Header lesen
				bne			.symbol_fail

				move.l		22(sp),PRG_FLAGS	; Programmflags
				tst.l		14(sp)				; Anzahl Symbole=0?
				beq			.symbol_fail
				add.l		2(sp),d3			; TEXT L„nge
				add.l		6(sp),d3			; DATA L„nge
				jsr			FSEEK				; zur Symboltabelle seeken
				bne			.symbol_fail

				move.l		14(sp),d0			; L„nge Symboltabelle
				add.l		d0,d0
				move.l		d0,-(sp)
				jsr			MALLOC				; Speicher reservieren
				beq			.symbol_fail
				move.l		d0,SYMBOL_TABLE_1	; Adresse Symboltabelle

				move.l		14(sp),d3			; L„nge Symboltabelle
				move.l		d0,a3				; Symboltabelle
				jsr			FREAD				; Symboltabelle lesen
				bne			.symbol_fail

*---------------

				movea.l		a3,a0				; Symbole konvertieren
				movea.l		a3,a1				; ins Zwischenformat 1
				move.l		a0,a2				; [Wert, L„nge, String]
				adda.l		14(sp),a2
				moveq		#0,d3				; Anzahl Symbole

.loop:			movem.l		(a0)+,d0-d1			; Symbolname
				move.w		(a0)+,d2			; Symboltyp
				move.l		(a0)+,d7			; Symbolwert

				moveq		#8,d6				; L„nge DRI
				cmp.b		#$48,d2				; GST?
				bne.s		.its_dri_1
				moveq		#22,d6				; L„nge GST
.its_dri_1:		btst		#14,d2				; Konstante?
				bne.s		.no_symbol
				add.l		FILE_TEXT,d7
				btst		#9,d2				; TEXT-Segment?
				bne.s		.its_text
				btst		#10,d2				; DATA-Segment?
				bne.s		.its_data
				btst		#8,d2				; BSS-Segment?
				beq.s		.no_symbol
				cmp.l		FILE_BSS,d7			; innerhalb BSS-Segment?
				bhs.s		.its_text
				add.l		6(sp),d7			; L„nge DATA-Segment
.its_data:		cmp.l		FILE_DATA,d7		; innerhalb DATA-Segment?
				bhs.s		.its_text
				add.l		2(sp),d7			; L„nge TEXT-Segment
.its_text:		addq.l		#1,d3				; Anzahl Symbole
				move.l		d7,(a1)+			; Symbolwert
				move.w		d6,(a1)+			; Symboll„nge
				move.l		d0,(a1)+			; DRI-String
				move.l		d1,(a1)+
				subq.w		#8,d6
				beq.s		.its_dri_2
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.w		(a0)+,(a1)+
				bra.s		.its_dri_2
.no_symbol:		lea			-8(a0,d6.w),a0
.its_dri_2:		cmpa.l		a2,a0
				blo.s		.loop

				move.l		d3,ANZAHL_SYMBOLE_1
				move.l		d3,-(sp)
				move.l		SYMBOL_TABLE_1,-(sp)
				bsr			SYMBOL_TOGETHER
				bra.s		.ende

.symbol_fail:	move.l		SYMBOL_TABLE_1,-(sp); Symboltabelle freigeben
				jsr			MFREE
				clr.l		SYMBOL_TABLE_1
				clr.l		ANZAHL_SYMBOLE_1
				jsr			FCLOSE				; Datei schliessen
.ende:			unlk		a6
				movem.l		(sp)+,d0-a5
				rts

*-------------------------------------------------------------------------------

SYMBOL_LADEN_2:	movem.l		d0-a5,-(sp)			; PEACEBUG.SYM laden
				link		a6,#-28				; Platz fr lokale Daten
				clr.l		ANZAHL_SYMBOLE_2

				lea			DRIVE_BOOT,a2		; Bootpfad setzen
				jsr			DSETPATH
				bmi			.symbol_fail

				lea			FILE,a2				; PEACEBUG.SYM suchen
				jsr			FSFIRST
				bne			.symbol_fail

				jsr			FGETDTA
				move.l		26(a0),d3			; L„nge der Datei
				move.l		d3,14(sp)

				moveq		#0,d0				; Modus
				lea			30(a0),a2			; Dateiname
				jsr			FOPEN				; Datei ”ffnen
				bmi			.symbol_fail

				add.l		d3,d3
				addq.l		#4,d3				; wegen Begradigung und CR/0
				move.l		d3,-(sp)
				jsr			MALLOC				; Speicher reservieren
				beq			.symbol_fail
				move.l		d0,SYMBOL_TABLE_2	; Adresse Symboltabelle

				move.l		14(sp),d3
				movea.l		d0,a3
				adda.l		d3,a3
				jsr			FREAD				; Symboltabelle lesen
				bne			.symbol_fail

				addq.l		#1,d3				; Adresse begradigen, damit
				bclr		#0,d3				; obere H„lfte an gerader Adresse
				move.l		d3,14(sp)

*---------------

				movea.l		SYMBOL_TABLE_2,a0	; Symbole konvertieren
				lea			(a0,d3.l),a1		; ins Zwischenformat 1
				lea			(a1,d3.l),a2		; [Wert, L„nge, String]

				moveq		#13,d4				; CR
				move.b		d4,(a2)+			; Ende der Datei kennzeichnen
				clr.b		(a2)				; (a2=Ende der Datei)
				moveq		#0,d7				; Anzahl Symbole
.loop:			movea.l		a1,a2

.search_cr:		cmp.b		(a1)+,d4			; Zeilenende suchen
				beq.s		.cr_found
				cmp.b		(a1)+,d4
				beq.s		.cr_found
				cmp.b		(a1)+,d4
				beq.s		.cr_found
				cmp.b		(a1)+,d4
				bne.s		.search_cr
.cr_found:		move.b		(a1),d5				; Ende der Datei?
				beq.s		.eof
				cmp.b		#10,d5				; CR/LF?
				bne.s		.search_cr			; nein, dann weitersuchen
				addq.w		#1,a1				; auf n„chste Zeile
				cmpi.b		#'*',(a2)			; Kommentarzeile?
				beq.s		.loop				; ja, dann n„chste Zeile
				move.l		a1,d0
				sub.l		a2,d0
				subq.w		#3,d0				; Zeilenl„nge
				bmi.s		.loop

				lea			6(a0),a3			; Symbolnamen suchen+kopieren
				moveq		#2,d2				; wegen Begradigung und Zero
				moveq		#32,d5				; d5 = Space
				moveq		#'=',d6
.search_ascii:	move.b		(a2)+,d1			; Zeichen>32 suchen
				cmp.b		d5,d1
				bhi.s		.ascii_found
				dbra		d0,.search_ascii
				bra.s		.loop
.ascii_found:	addq.l		#1,d2				; Zeichen kopieren
				move.b		d1,(a3)+
				cmp.b		d6,d1
				dbeq		d0,.search_ascii
				bne.s		.loop				; Zeilenende?
				clr.b		-(a3)				; Symbolende
				subq.w		#1,d0				; Zeilenl„nge

.search_space:	cmp.b		(a2)+,d5			; Asciicodes<=32 entfernen
				dbls		d0,.search_space
				bhi.s		.loop				; Zeilenende?
				subq.w		#1,a2
				jsr			Interpreter			; und auswerten
				bne.s		.loop
				move.l		d3,(a0)+			; Symbolwert
				and.b		#$FE,d2				; n„chstes Symbol muss auf
				move.w		d2,(a0)+			; gerader Adresse liegen
				adda.w		d2,a0
				addq.l		#1,d7				; Anzahl Symbole
				bra.s		.loop

.eof:			move.l		d7,ANZAHL_SYMBOLE_2
				move.l		d7,-(sp)
				move.l		SYMBOL_TABLE_2,-(sp)
				bsr.s		 SYMBOL_TOGETHER
				bra.s		.ende

.symbol_fail:	move.l		SYMBOL_TABLE_2,-(sp); Symboltabelle freigeben
				jsr			MFREE
				clr.l		SYMBOL_TABLE_2
				clr.l		ANZAHL_SYMBOLE_2
				jsr			FCLOSE				; Datei schliessen
.ende:			jsr			RESTORE_PATH		; Pfad zurcksetzen
				unlk		a6
				movem.l		(sp)+,d0-a5
				rts

*-------------------------------------------------------------------------------

* 4(sp)  = Symboltabelle
* 8(sp)  = Anzahl Symbole
* 26(sp) = L„nge Symboltabelle
SYMBOL_TOGETHER:movea.l		4(sp),a0			; Symbole kovertieren
				movea.l		a0,a1				; ins Zwischenformat 2
				movea.l		a0,a2				; [Wert],[Pointer][String]
				adda.l		26(sp),a2			; [ A1 ],[ A2 ][ A3 ]
				movea.l		a2,a3
				move.l		8(sp),d3
				beq			.fail
				move.l		d3,d0
				add.l		d0,d0
				add.l		d0,d0
				adda.l		d0,a3
				subq.l		#1,d3
.adapt:			move.l		(a0)+,(a1)+			; Wert
				move.w		(a0)+,d0			; Symboll„nge
				move.l		a3,(a2)+			; Pointer
				subq.w		#1,d0
.copy:			move.b		(a0)+,(a3)+			; String
				dbeq		d0,.copy
				beq.s		.zero
				clr.b		(a3)+
				moveq		#0,d0
.zero:			adda.w		d0,a0
				dbra		d3,.adapt
				sub.l		#$10000,d3
				bpl.s		.adapt

				movea.l		4(sp),a0			; Symbole crunchen
				adda.l		26(sp),a0
				movea.l		a1,a2
				move.l		a3,d3
				sub.l		a0,d3
				subq.l		#1,d3
.crunch:		move.b		(a0)+,(a1)+
				dbra		d3,.crunch
				sub.l		#$10000,d3
				bpl.s		.crunch

				move.l		a1,d0				; Pointer anpassen
				sub.l		a0,d0
				move.l		4(sp),a0
				move.l		8(sp),d3
				subq.l		#1,d3
.pointer:		add.l		d0,(a2)+
				dbra		d3,.pointer
				sub.l		#$10000,d3
				bpl.s		.pointer			; ---> [Wert][Pointer][String]

				movea.l		4(sp),a0
				move.l		a1,d3
				sub.l		a0,d3
				move.l		d3,-(sp)
				move.l		8(sp),-(sp)
				jsr			MSHRINK

				move.l		8(sp),d0
				add.l		d0,d0
				add.l		d0,d0
				lea			-4(a0,d0.l),a1
				bsr.s		QUICKSORT
.fail:			jsr			FCLOSE
				rts

*-------------------------------------------------------------------------------

QUICKSORT:		movea.l		a0,a2
				movea.l		a1,a3
				move.l		a1,d7
				sub.l		a0,d7
				lsr.l		#1,d7
				and.b		#$fc,d7
				move.l		(a0,d7.l),d1
.repeat:
.while1:		cmp.l		(a2)+,d1
				bhi.s		.while1
				subq.w		#4,a2
				addq.w		#4,a3
.while2:	 	cmp.l		-(a3),d1
				blo.s		.while2
				cmpa.l		a2,a3
				blo.s		.dont_exchange

				move.l		(a2,d0.l),d7		; austauschen
				move.l		(a3,d0.l),(a2,d0.l)
				move.l		d7,(a3,d0.l)
				move.l		(a2),d7
				move.l		(a3),(a2)+
				move.l		d7,(a3)
				subq.w		#4,a3
				cmpa.l		a2,a3
				bhs.s		.repeat

.dont_exchange:	cmpa.l		a0,a3				; IF ANFANG<Z
				bls.s		.cont1
				move.l		a2,-(sp)
				move.l		a1,-(sp)
				movea.l		a3,a1				; NEUE WERTE
				movea.l		a0,a2				; SETZEN
				bsr.s		QUICKSORT
				movea.l		(sp)+,a1
				movea.l		(sp)+,a2
.cont1:			cmpa.l		a2,a1				; IF A<ENDE
				bls.s		.cont2
				movea.l		a2,a0				; NEUE WERTE
				movea.l		a1,a3				; SETZEN
				bsr.s		QUICKSORT
.cont2: 		rts
