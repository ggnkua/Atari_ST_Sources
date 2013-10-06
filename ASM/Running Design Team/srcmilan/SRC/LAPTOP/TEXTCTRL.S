
; struktur laptopinputdata
				rsreset
LAPTOPINPUTBUFFERPTR		rs.l	1			; zeiger auf buffer
LAPTOPINPUTBUFFERLENGTH		rs.w	1			; aktuelle laenge des eingabebuffers
LAPTOPINPUTBUFFERPOS		rs.w	1			; position zum schreiben im buffer
LAPTOPINPUTSIGNPTR		rs.l	1			; zeiger auf string am zeilenanfang
LAPTOPINPUTSIGNLENGTH		rs.w	1			; laenge ohne abschliessendes nullzeichen
LAPTOPINPUTARG0			rs.l	1
LAPTOPINPUTARG1			rs.l	1
LAPTOPINPUTARG2			rs.l	1
LAPTOPINPUTARG3			rs.l	1
LAPTOPINPUTARG4			rs.l	1
LAPTOPINPUTARG5			rs.l	1
LAPTOPINPUTARG6			rs.l	1
LAPTOPINPUTARG7			rs.l	1
LAPTOPINPUTARG8			rs.l	1
LAPTOPINPUTARG9			rs.l	1



		text


; ---------------------------------------------------------
; 23.01.00/vk
; eine einzelne zeile kann eingegeben werden und
; wird ausgefuehrt.
laptopInputModeSingleLine

		lea	laptop,a0
		clr.w	LAPTOPQUITFLAG(a0)			; flag zum beenden anfangs loeschen

		bsr	laptopInitInputBuffer			; eingabebuffer zuruecksetzen

		bsr	laptopPrintUpdateInputBuffer
		bsr	laptopDrawOffscreen

limslCharLoop
		bsr	vsync					; auf rasterstrahl warten
		bsr	calcVblTimes				; vbltime muss berechnet werden

		bsr	laptopDrawCursor			; cursor im offscreen-memory zeichnen
		bsr	laptopCopyToPhysicalVideoRam		; offscreen-memory in physische video-ram kopieren

		lea	laptop,a0				; muss laptop beendet
		tst.w	LAPTOPQUITFLAG(a0)			; werden?
		bne.s	limslOut				; ja -> dann einfach raus

		bsr	getCharGemdos				; zeichen ueber gemdos holen (ohne zu warten)
		tst.w	d2					; war zeichen im buffer?
		beq.s	limslCharLoop				; nein -> dann loopen zum anfang

		tst.w	d0					; ascii-zeichen vorhanden?
		beq.s	limslCharLoop

		cmpi.b	#13,d0					; return gedrueckt?
		beq.s	limslReturn

		cmpi.b	#8,d0					; backspace gedrueckt?
		beq.s	limslBackspace

		cmpi.b	#" ",d0					; ascii-zeichen vor " "?
		blt.s	limslCharLoop				; ja -> dann nicht gueltig und zum naechsten zeichen

		bsr	laptopPutCharToBuffer			; zeichen eintragen
		bra.s	limslCharOk

limslBackspace
		bsr	laptopDeleteCharFromBuffer
		bra.s	limslCharOk

limslReturn
		bsr	laptopShiftUpOneRow
		bsr	laptopParseInputLine
		bsr	laptopExecuteCommand
		bsr	laptopInitInputBuffer			; eingabebuffer zuruecksetzen

limslCharOk
		bsr	laptopPrintUpdateInputBuffer
		bsr	laptopDrawOffscreen
		
		bra.s	limslCharLoop

limslOut
		bsr	laptopClearLastLine
		bsr	laptopSetCursorLastLine
		bsr	laptopDrawOffscreen

		bsr	setFlagToClearBackground		; .\gfxrouts\backgrnd.s

		rts


; ---------------------------------------------------------
; 01.02.00/vk
; fuehrt das uebergebene kommando aus.
laptopExecuteCommand

		lea	laptopInputData,a2
		movea.l	LAPTOPINPUTARG0(a2),a0
		tst.b	(a0)
		beq.s	lecOut

		bsr	laptopCryptString

		lea	laptopCommands,a2
lecLoop		move.l	(a2)+,d0				; pointer auf naechstes laptop kommando
		beq.s	lecNoCommandFound			; listenende erreicht? ja -> dann verzweigen
		movea.l	d0,a1					; a1 = (aktuelles) laptopCommand
		movea.l	LAPTOPCOMMANDARG0PTR(a1),a1		; a1 = verschl. kommandostring

		bsr	laptopCompareStrings
		tst.w	d0
		bne.s	lecLoop

	; kommando gefunden

		movea.l	-4(a2),a1				; pointer auf vorherige laptopcommand-struktur holen
		move.l	LAPTOPCOMMANDROUTINEPTR(a1),d0
		beq.s	lecOut

		movea.l	d0,a6
		jsr	(a6)
		bra.s	lecOut

lecNoCommandFound

	; kommando nicht gefunden

		lea	laptopCommandNotFoundTxt,a0
		bsr	laptopAppendLines

lecOut
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; vergleicht zwei nullterminierte strings.
; a0 = string1
; a1 = string2
; rueckgabe: d0 = 0 (gleichheit), <>0 (ungleichheit)
; rettet alle register.
laptopCompareStrings

		movem.l	d1/a0-a1,-(sp)
lcsLoop
		move.b	(a0)+,d0
		move.b	(a1)+,d1
		beq.s	lcsReachedEnd
		tst.b	d0
		beq.s	lcsReachedEnd
		cmp.b	d0,d1
		beq.s	lcsLoop

		bra.s	lcsDifference

lcsReachedEnd
		add.b	d0,d1
		beq.s	lcsSame				; ja, dann gleichheit
lcsDifference
		moveq	#-1,d0
		bra.s	lcsOut
lcsSame
		moveq	#0,d0

lcsOut
		movem.l	(sp)+,d1/a0-a1
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; argument parser des input buffers. die einzelnen argumente
; werden der struktur laptopinputdata (als kopie) eingefuegt.
laptopParseInputLine

		lea	laptopInputData,a0
		movea.l	LAPTOPINPUTBUFFERPTR(a0),a6
		adda.w	LAPTOPINPUTSIGNLENGTH(a0),a6
		lea	LAPTOPINPUTARG0(a0),a1
		
		moveq	#10-1,d7			; maximal 10 argumente
lpilLoop
		movea.l	(a1)+,a2

	; a0 = laptopinputdata
	; a1 = pointer auf pointer auf argx
	; a2 = pointer auf argx
	; a6 = aktuelle position im laptopinputbuffer

		move.b	(a6),d0				; ersten zeichen (wieder) holen
		beq.s	lpilNoArgument
		bmi.s	lpilNoArgument

lpilFindBeginLoop
		move.b	(a6),d0
		beq.s	lpilNoArgument
		bmi.s	lpilNoArgument
		cmpi.b	#" ",d0
		bne.s	lpilFoundBegin
		addq.l	#1,a6
		bra.s	lpilFindBeginLoop
lpilFoundBegin

lpilFindEndLoop
		move.b	(a6),d0
		move.b	d0,(a2)
		beq.s	lpilFoundEnd
		bmi.s	lpilFoundEnd
		cmpi.b	#" ",d0
		beq.s	lpilFoundEnd
		addq.l	#1,a2
		addq.l	#1,a6
		bra.s	lpilFindEndLoop
lpilFoundEnd
		clr.b	(a2)
		bra.s	lpilNextArg

lpilNoArgument
		clr.b	(a2)

lpilNextArg

		dbra	d7,lpilLoop			; loop ueber maximal 10 argumente
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; schreibt den inputbuffer in die aktuelle eingabezeile des
; laptops (textfeld), keine weitere aenderungen.
laptopPrintUpdateInputBuffer

		lea	laptopInputData,a0
		movea.l	LAPTOPINPUTBUFFERPTR(a0),a0
		bsr	laptopPrintToSingleLine
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; gibt eine einzeilige nachricht auf dem laptop aus. es erfolgt
; ein zeilenumbruch inkl. hochschieben der textzeilen.
; diese routine ist als einzige aufzurufen, wenn eine
; einzeilige mitteilung ausgegeben werden soll.
; a0 = pointer auf string
; rettet alle register.
laptopAppendSingleLine

		movem.l	d0-a6,-(sp)
		bsr	laptopPrintToSingleLine
		bsr	laptopShiftUpOneRow
		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 01.02.00/vk
; gibt eine nachricht auf dem laptop aus. es erfolgt ggf. ein
; umbruch in die naechste zeile inkl. hochschieben der
; textzeilen.
; diese routine ist als einzige aufzurufen, wenn ein
; beliebig langer string ausgegeben werden soll.
; a0 = pointer auf string
; rettet alle register.
laptopAppendLines

		movem.l	d0-a6,-(sp)

		movea.l	a0,a2					; string kopieren (retten)
lalLoop
		bsr	laptopFindStringForLine
		tst.w	d0					; nichts mehr gefunden?
		beq.s	lalOut					; ja -> dann raus

		movea.l	a1,a0
		bsr	laptopAppendSingleLine

		adda.w	d0,a2
		movea.l	a2,a0
		bra.s	lalLoop

lalOut
		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 06.02.00/vk
; findet vom anfang des uebergebenen strings den teilstring
; heraus, der im laptop in eine zeile passt.
; a0 = string (nullterminiert)
; rueckgabe: d0 = laenge des teilstrings (ohne 0-zeichen)
;            a1 = teilstring (nullterminiert/kopie)
; rettet alle register.
laptopFindStringForLine

		movem.l	d1-d7/a0/a2-a6,-(sp)

		lea	lfsflBuffer,a1
		lea	laptop,a2
		move.w	LAPTOPX(a2),d4				; d4 = breite in buchstaben
		move.w	LAPTOPWIDTH(a2),d5			; d5 = breite in pixel
		movea.l	LAPTOPFONTDATAPTR(a2),a3
		movea.l	LFASCIICONVERTPTR(a3),a4		; a4 = ascii-konvertierung
		movea.l	LFLETTERWIDTHPTR(a3),a5			; a5 = tabelle mit buchstabenbreiten

		moveq	#0,d0					; bisherige berechnete laenge
		moveq	#0,d1					; bisherige berechnete breite in pixel
		moveq	#1,d6					; skip-spaces-flag am anfang setzen
		moveq	#-1,d7					; position des letzten leerzeichens in gefundenen string
lfsflLoop
		moveq	#0,d2
		move.b	(a0)+,d2				; naechstes ascii-zeichen holen
		beq.s	lfsflfzDivOk				; ende erreicht -> verzweigen
		tst.w	d6					; anfangsflag fuer spaces noch gesetzt?
		beq.s	lfsflNoSpace				; nein -> dann verzweigen
		cmpi.b	#" ",d2					; ist es tatsaechlich noch ein space-zeichen
		bne.s	lfsflNoSpace				; nein -> dann verzweigen
		addq.w	#1,d0					; es ist ein space-zeichen. berechnete laenge addieren
		bra.s	lfsflLoop				; und ab zum naechsten
lfsflNoSpace
		moveq	#0,d6					; skip-spaces-flag beim ersten nicht space loeschen

		addq.w	#1,d0					; berechnete laenge um eins erhoehen

		cmpi.b	#13,d2
		beq.s	lfsflfzDivOk

		cmpi.b	#" ",d2
		bne.s	lfsflNoSpace2
		move.w	d0,d7
lfsflNoSpace2

		move.w	(a4,d2.w*2),d3				; ascii ./. interner font-letter-index
		move.w	(a5,d3.w*2),d3				; breite in pixel holen
		add.w	d3,d1					; berechnete breite in pixel addieren

		cmp.w	d4,d0					; sind die maximalwerte ueberschritten?
		bgt.s	lfsflFoundMax
		cmp.w	d5,d1
		bgt.s	lfsflFoundMax
		
		move.b	d2,(a1)+				; andernfalls kann buchstabe hinzugefuegt werden
		bra.s	lfsflLoop				; und mit naechstem buchstaben von vorne

lfsflFoundMax
		subq.w	#1,d0					; fuer den zuviel addierten buchstaben
		sub.w	d3,d1					; die werte wieder korrigieren
lfsflFoundZero
		cmpi.b	#" ",d2					; war das letzte zeichen gerade ein leerzeichen?
		beq.s	lfsflfzDivOk				; ja -> dann kann zeile hier getrennt werden

		tst.w	d7					; war zwischendrin ein leerzeichen?
		bmi.s	lfsflfzDivOk				; nein -> dann muessen wir hier trennen

		move.w	d7,d0
		lea	lfsflBuffer,a1
		clr.b	(a1,d0.w)
		bra.s	lfsflOut

lfsflfzDivOk
		clr.b	(a1)					; ende-zeichen setzen
		lea	lfsflBuffer,a1				; fuer rueckgabewert wieder setzen
lfsflOut
		movem.l	(sp)+,d1-d7/a0/a2-a6
		rts


; ---------------------------------------------------------
; 03.02.00/vk
; loescht die letzte zeile aus dem laptop heraus,
; sowohl von den ascii zeichen aus auch von der grafik (offscreen) her.
; rettet alle register.
laptopClearLastLine
		movem.l	d6/a0,-(sp)
		lea	laptop,a0
		move.w	LAPTOPY(a0),d6
		subq.w	#1,d6
		bsr.s	laptopClearSingleLine
		movem.l	(sp)+,d6/a0
		rts


; ---------------------------------------------------------
; 02.01.00/vk
; loescht die angegebene zeile aus dem laptop heraus,
; sowohl von den ascii zeichen aus auch von der grafik (offscreen) her.
; d6.w = zeilennummer
; rettet alle register.
laptopClearSingleLine

		movem.l	d0-a6,-(sp)
		bsr	laptopClearAsciiTextOneRow
		bsr	laptopDrawOffscreen		; todo (nur eine zeile muss neu gezeichnet werden)
		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 02.01.00/vk
; gibt einen string in der aktuellen zeile des laptops
; aus. es werden nur soviele buchstaben uebernommen, wie in
; die aktuelle zeile passen. es erfolgt kein zeilenumbruch o. ae.
; a0 = pointer auf string
laptopPrintToSingleLine

		lea	laptop,a6			; laptopdaten
		move.w	LAPTOPCURSORY(a6),d7		; zeilennummer des cursors holen
		movea.l	LAPTOPTEXTPTR(a6),a5		; array der textpointer holen
		movea.l	(a5,d7.w*4),a4			; a4 = text der aktuellen zeile

		move.w	LAPTOPX(a6),d6			; aktuelle breite in buchstaben
		subq.w	#1,d6				; fuer dbra
lptslCopyLoop	move.b	(a0)+,d0			; aktueller buchstabe (ascii)
		bne.s	lptslcNormal			; ende nicht erreicht -> normal weiter (ueberspringen)
		move.b	#-1,(a4)			; endemarkierung schreiben
		bra.s	lptslCopySkip			; und programmteil beenden
lptslcNormal	move.b	d0,(a4)+			; aktuellen buchstaben uebernehmen
		dbra	d6,lptslCopyLoop		; bis alle buchstabenpositionen der zeile abgearbeitet sind
lptslCopySkip
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; initialisiert den eingabebuffer fuer die eingabe einer textzeile.
; muss vor jeder neuen eingabe einer zeile aufgerufen werden
; (sowie bei groessenanderungen des laptops).
laptopInitInputBuffer

		lea	laptopInputData,a1
		movea.l	LAPTOPINPUTSIGNPTR(a1),a0
		bsr	laptopCalcStringWidth		; rueckgabe: d0 = breite in buchst., d1 = breite in pixel

		moveq	#3,d0
		moveq	#18,d1
		lea	laptop,a2
		move.w	d0,LAPTOPCURSORX(a2)		; position in buchstaben
		move.w	d1,LAPTOPCURSOROFFSETX(a2)	; position in pixeln (offset/relativ)

		move.w	LAPTOPINPUTSIGNLENGTH(a1),d2
		move.w	d2,LAPTOPINPUTBUFFERPOS(a1)
		move.w	LAPTOPX(a2),LAPTOPINPUTBUFFERLENGTH(a1)

		subq.w	#1,d2
		movea.l	LAPTOPINPUTSIGNPTR(a1),a3
		movea.l	LAPTOPINPUTBUFFERPTR(a1),a4
liibLoop	move.b	(a3)+,(a4)+
		dbra	d2,liibLoop
		clr.b	(a4)

		rts


; ---------------------------------------------------------
; 01.02.00/vk
; fuegt ein ascii-zeichen in den textbuffer (eingabebuffer) ein.
; d0 = ascii-zeichen
; rueckgabe: d0 = 0 (erfolgreich), -1 (buffer voll)
; alle register werden gerettet
laptopPutCharToBuffer

		movem.l	d1-d4/a0-a4,-(sp)

		lea	laptopInputData,a1
		movea.l	LAPTOPINPUTBUFFERPTR(a1),a0
		move.w	LAPTOPINPUTBUFFERPOS(a1),d1
		cmp.w	LAPTOPINPUTBUFFERLENGTH(a1),d1
		bge.s	lpctbNoInsert

	; d0 = ascii-code
	; d1 = laptopinputbufferpos
	; a0 = laptopinputbuffer
	; a1 = laptopinputdata

		lea	laptop,a4				; laptopdaten
		movea.l	LAPTOPFONTDATAPTR(a4),a2
		movea.l	LFASCIICONVERTPTR(a2),a3

		move.w	d0,d4

		bsr	laptopCalcStringWidth			; laenge des bisherigen strings berechnen
		move.w	d1,d3					; pixelbreite nach d3

		andi.w	#$00ff,d4
		move.w	(a3,d4.w*2),d2				; d2 = interner fontindex fuer ascii-code
		movea.l	LFLETTERWIDTHPTR(a2),a3
		move.w	(a3,d2.w*2),d0				; d0 = breite des buchstabens
		add.w	d0,d3
		add.w	LFDELTAX(a2),d3				; breite des cursors noch addieren
		cmp.w	LAPTOPWIDTH(a4),d3
		bgt.s	lpctbNoInsert

		addq.w	#1,LAPTOPCURSORX(a4)
		add.w	d0,LAPTOPCURSOROFFSETX(a4)

		move.w	LAPTOPINPUTBUFFERPOS(a1),d1
		move.b	d4,(a0,d1.w)
		clr.b	1(a0,d1.w)
		addq.w	#1,d1
		move.w	d1,LAPTOPINPUTBUFFERPOS(a1)
		moveq	#0,d0
		bra.s	lpctbOut
lpctbNoInsert
		moveq	#-1,d0
lpctbOut
		movem.l	(sp)+,d1-d4/a0-a4
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; loescht das letzte zeichen aus dem textbuffer heraus.
; rueckgabe: d0 = 0 (ok), -1 = kein zeichen zum loeschen vorhanden
; alle register werden gerettet.
laptopDeleteCharFromBuffer

		movem.l	d1/a0-a1,-(sp)

		lea	laptopInputData,a0
		movea.l	LAPTOPINPUTBUFFERPTR(a0),a1
		move.w	LAPTOPINPUTBUFFERPOS(a0),d0
		cmp.w	LAPTOPINPUTSIGNLENGTH(a0),d0
		beq.s	ldcfbNoDelete
		
		clr.b	-1(a1,d0.w)
		subq.w	#1,d0
		move.w	d0,LAPTOPINPUTBUFFERPOS(a0)

		movea.l	a1,a0
		bsr	laptopCalcStringWidth			; rueckgabe in d0-d1
		lea	laptop,a0
		move.w	d0,LAPTOPCURSORX(a0)
		move.w	d1,LAPTOPCURSOROFFSETX(a0)

		moveq	#0,d0
		bra.s	ldcfbOut
ldcfbNoDelete
		moveq	#-1,d0
ldcfbOut
		movem.l	(sp)+,d1/a0-a1
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; findet den string a0 im anzeigefeld des laptops und
; gibt die gefundene zeilennummer zurueck.
; a0 = string
; rueckgabe: d6.w = zeilennummer (oder -1, falls nicht gefunden)
laptopFindString

		lea	laptop,a5
		move.w	LAPTOPX(a5),d6				; aktuelle anzahl spalten
		subq.w	#1,d6
		move.w	LAPTOPY(a5),d7				; aktuelle anzahl zeilen
		subq.w	#1,d7
		movea.l	LAPTOPTEXTPTR(a5),a6			; zeiger auf textzeilenzeiger

		move.b	(a0),d5					; erstes zeichen des strings holen

	; d5 = erstes zeichen des strings
	; d6 = spaltenanzahl (-1)
	; d7 = zeilenanzahl (-1)
	; a0 = string
	; a5 = laptop
	; a6 = array der textzeilenpointer

lfsLoop
		movea.l	a0,a1					; gesuchten string nach a1
		movea.l	(a6)+,a2				; naechste textzeile nach a2
		cmp.b	(a2),d5					; stimmt erstes zeichen ueberein?
		bne.s	lfsSkip					; nein -> dann gleich auf zur naechsten zeile

		move.w	d6,d4					; spaltenanzahl (-1) nach d4
lfsCompareLoop	move.b	(a1)+,d0				; zeichen aus string holen
		beq.s	lfsEndOfChar				; keine zeichen mehr vorhanden, string also gefunden
		move.b	(a2)+,d1				; zeichen aus laptopzeile holen
		bmi.s	lfsEndOfChar				; kein zeichen mehr vorhanden
		cmp.b	d0,d1
		bne.s	lfsSkip					; unterschiede in zeichen gefunden -> zur naechsten zeile
		dbra	d4,lfsCompareLoop			; loop ueber die maximale anzeigebreite
lfsEndOfChar
		move.w	LAPTOPY(a5),d6
		subq.w	#1,d6
		sub.w	d7,d6
		bra.s	lfsOut
lfsSkip
		dbra	d7,lfsLoop				; loop ueber alle zeilen des textfeldes

		moveq	#-1,d6					; flag fuer nicht gefunden setzen
lfsOut
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; verschluesselt einen string.
; a0 = zu verschluesselnder string
; rettet alle register.
laptopCryptString
		movem.l	d0-d2/a0,-(sp)
		move.b	#LAPTOPCODENUMBER,d0
lcrsLoop	move.b	(a0),d1
		beq.s	lcrsOut
		move.b	d0,d2
		sub.b	d1,d2
		move.b	d2,(a0)+
		bra.s	lcrsLoop
lcrsOut
		movem.l	(sp)+,d0-d2/a0
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; entschluesselt einen string.
; a0 = zu entschluesselnder string
; rettet alle register.
laptopDecryptString
		movem.l	d0-d2/a0,-(sp)
		move.b	#LAPTOPCODENUMBER,d0
ldsLoop		move.b	(a0),d1
		beq.s	ldsOut
		move.b	d0,d2
		sub.b	d1,d2
		move.b	d2,(a0)+
		bra.s	ldsLoop
ldsOut
		movem.l	(sp)+,d0-d2/a0
		rts






		data


; laptopinputbufferdata
laptopInputData	dc.l	liBuffer
		dc.w	0
		dc.w	0
		dc.l	liSign
		dc.w	3
		dc.l	liArg0
		dc.l	liArg1
		dc.l	liArg2
		dc.l	liArg3
		dc.l	liArg4
		dc.l	liArg5
		dc.l	liArg6
		dc.l	liArg7
		dc.l	liArg8
		dc.l	liArg9

liBuffer	ds.b	LAPTOPMAXX
		dc.b	0
liArg0		ds.b	LAPTOPMAXX+1
liArg1		ds.b	LAPTOPMAXX+1
liArg2		ds.b	LAPTOPMAXX+1
liArg3		ds.b	LAPTOPMAXX+1
liArg4		ds.b	LAPTOPMAXX+1
liArg5		ds.b	LAPTOPMAXX+1
liArg6		ds.b	LAPTOPMAXX+1
liArg7		ds.b	LAPTOPMAXX+1
liArg8		ds.b	LAPTOPMAXX+1
liArg9		ds.b	LAPTOPMAXX+1
		even

liSign		dc.b	"C:>",0
		even

lfsflBuffer	ds.b	LAPTOPMAXX+1
		even