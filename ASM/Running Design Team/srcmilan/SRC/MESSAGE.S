

; modus fuer nachrichtenanzeige
MSGMODESCREEN		equ	0			; anzeige in der linken oberen ecke des screens
MSGMODELAPTOP		equ	1			; anzeige innerhalb des laptops

NBOFMESSAGES		equ	3			; anzahl gleichzeitig dargestellbarer nachrichten
MESSAGETIME1000		equ	5000			; dauer der anzeige in msek.

MESSAGEHEIGHT		equ	11

; struktur messages
			rsreset
MESSAGEPTR		rs.l	1
MESSAGEORIGINALPTR	rs.l	1
MESSAGETIME		rs.w	1
MESSAGECLEARFLAG	rs.w	1
MESSAGEINSTALLFLAG	rs.w	1
MESSAGELENGTH		rs.w	1
MESSAGEBYTES		rs.w	1



		text


; ---------------------------------------------------------
; 10.06.00/vk
; routine zum zeichnen der nachrichten bei jedem bildaufbau.
; wird von der spiel-hauptroutine aufgerufen.
drawMessages
		move.w	messageMode,d0		; nachrichtenmodus holen

		cmpi.w	#MSGMODESCREEN,d0	; anzeige im screen?
		bne.s	dmNoScreen		; nein -> weiter
		bsr	drawMessagesOnScreen	; neuzeichnen aller nachrichten im screen aufrufen inkl. calcTime()
		bra.s	dmsgOut
dmNoScreen
		cmpi.w	#MSGMODELAPTOP,d0	; anzeige im laptop?
		bne.s	dmNoLaptop		; nein -> weiter
		bsr	messagePaintOnLaptop	; neu hinzugekommene nachrichten auf dem laptop ausgeben		
		bsr	messageClearOnLaptop	; es muessen nachrichten evtl. nur noch geloescht werden -> routine aufrufen
		bsr	messageCalcTime		; verbleibende anzeigedauern berechnen, evtl. flags zum loeschen einzelner nachrichtenplaetze setzen
		bra.s	dmsgOut
dmNoLaptop
		nop
dmsgOut
		rts


; ---------------------------------------------------------
; 02.06.00/vk
; nachrichten am oberen bildschirmrand zeichnen
drawMessagesOnScreen

		moveq	#NBOFMESSAGES-1,d0	; anzahl nachrichten
		lea	fontDataRed8x8,a1	; variablenfeld fuer verwendete schriftart holen
		lea	messages,a2		; struktur nachrichten holen

		movea.l	screen_1,a6		; screenadresse links oben
		move.w	lineoffset,d2

		move.w	messageScreenXOffset,d3
		bpl.s	dmosPos			; wenn xoffset negativ, dann einfach
		adda.w	d2,a6			; eine zeile addieren, da spaeter dann von dieser subtrahiert wird
dmosPos		muls.w	FONTDATAWIDTH(a1),d3
		lsl.l	#1,d3
		adda.l	d3,a6			; a6 bzgl. xoffset korrigieren		

		move.w	d2,d3
		mulu.w	messageScreenYOffset,d3	; yoffset fuer erste nachricht ...
		adda.l	d3,a6			; ... auf anfangsadresse addieren

		mulu.w	#MESSAGEHEIGHT,d2	; abstand zweier zeilen vorberechnen
dmosLoop
		moveq	#0,d3
		movem.l	d0/d2/a1-a2/a6,-(sp)	; register sichern
		move.l	MESSAGEPTR(a2),d1	; pointer auf zu zeichnende nachricht
		beq.s	dmosSkip		; vorhanden? nein -> dann ueberspringen und auch keinen zwischenabstand addieren

		tst.w	messageScreenXOffset
		bpl.s	dmosNoRight

		move.w	FONTDATAWIDTH(a1),d3
		mulu.w	MESSAGELENGTH(a2),d3
		lsl.l	#1,d3
		suba.l	d3,a6
dmosNoRight
		
		movea.l	d1,a0
		jsr	drawText		; a0 = textpointer, a6 = screenpointer

		move.w	MESSAGETIME(a2),d3	; zeitangaben in noch anzuzeigenden msek. holen
		sub.w	vblTime1000,d3		; zeitangaben in msek., verstrichene zeit abziehen
		bpl.s	dmosStillPaint		; noch zeit uebrig? ja -> weiter
		moveq	#0,d3
		clr.l	MESSAGEPTR(a2)		; textpointer loeschen
		jsr	setFlagToClearBackground
dmosStillPaint	move.w	d3,MESSAGETIME(a2)	; neue zeit eintragen

		move.l	d2,d3
dmosSkip
		movem.l	(sp)+,d0/d2/a1-a2/a6
		adda.l	d3,a6

		lea	MESSAGEBYTES(a2),a2
		dbra	d0,dmosLoop

		rts


; ---------------------------------------------------------
; 02.01.00/vk
; neu hinzugekommene nachrichten neu auf dem laptop ausgeben,
; dabei ggf. den laptop zur anzeige bringen.
messagePaintOnLaptop

		moveq	#NBOFMESSAGES-1,d0	; anzahl nachrichten/nachrichtenplaetze
		lea	messages,a1		; daten aller nachrichten
mpolLoop
		tst.w	MESSAGEINSTALLFLAG(a1)	; muss diese nachricht neu angezeigt werden?
		beq.s	mpolSkip		; nein -> dann diese ueberspringen

		clr.w	MESSAGEINSTALLFLAG(a1)	; flag wieder loeschen

		movem.l	d0/a1,-(sp)		; es muss (mindestens) eine nachricht angezeigt werden, also
		bsr	laptopShowSmall		; laptop mit kleinem anzeigefeld ggf. zur anzeige bringen...
		movem.l	(sp)+,d0/a1

		move.l	MESSAGEPTR(a1),d1	; pointer auf zu zeichnende nachricht
		beq.s	mpolSkip		; gueltig? nein -> dann ueberspringen

		movea.l	d1,a0
		bsr	laptopAppendSingleLine	; nachricht als einzeilige nachricht hinzufuegen
mpolSkip
		lea	MESSAGEBYTES(a1),a1
		dbra	d0,mpolLoop

		rts


; ---------------------------------------------------------
; 02.01.00/vk
; loescht angezeigte/alte messages auf dem laptop
; wieder heraus.
messageClearOnLaptop

		moveq	#NBOFMESSAGES-1,d0
		lea	messages,a1
mcolLoop
		tst.w	MESSAGECLEARFLAG(a1)
		beq.s	mcolSkip

		clr.w	MESSAGECLEARFLAG(a1)

		movea.l	MESSAGEORIGINALPTR(a1),a0
		movem.l	d0/a1,-(sp)
		bsr	laptopFindString
		movem.l	(sp)+,d0/a1
		tst.w	d6
		bmi.s	mcolSkip
		bsr	laptopClearSingleLine

mcolSkip
		lea	MESSAGEBYTES(a1),a1
		dbra	d0,mcolLoop
		rts


; ---------------------------------------------------------
; 02.01.00/vk
; berechnet die verbleibende zeit der anzeigedauer
; aller nachrichten. muss eine nachricht nicht mehr angezeigt
; werden, dann wird messageclrflag() gesetzt.
; rettet alle register.
messageCalcTime
		movem.l	d0-d2/a0,-(sp)
		lea	messages,a0
		move.w	#NBOFMESSAGES-1,d0
		move.w	vblTime1000,d2		; verstrichene msek. seit letztem bildaufbau holen
mctLoop
		move.w	MESSAGETIME(a0),d1	; zeitangabe in noch anzuzeigenden msek. holen
		sub.w	d2,d1			; verstrichene msek. abziehen
		bpl.s	mctStillToDraw		; noch zeit uebrig? ja -> weiter
		clr.l	MESSAGEPTR(a0)		; textpointer loeschen
		moveq	#0,d1			; zeit loeschen
		move.w	#1,MESSAGECLEARFLAG(a0)	; flag zum loeschen der nachricht/des nachrichtenplatzes setzen
mctStillToDraw	move.w	d1,MESSAGETIME(a0)

		dbra	d0,mctLoop
		movem.l	(sp)+,d0-d2/a0

		rts


; ---------------------------------------------------------
; 02.06.00/vk
; nachricht zur anzeige eintragen. diese routine wird von
; vielen anderen programmroutinen zur anzeige von nachrichten
; aufgerufen.
; a0 = string
; rettet alle register
installMessage
		movem.l	d0-a6,-(sp)

		move.w	messageMode,d0
		cmpi.w	#MSGMODESCREEN,d0	; anzeige im screen?
		bne.s	imNoScreen		; nein -> weiter
		bsr.s	installMessageScreen
		bra.s	imOut
imNoScreen
		cmpi.w	#MSGMODELAPTOP,d0	; anzeige im laptop?
		bne.s	imNoLaptop		; nein -> weiter
		bsr.s	installMessageLaptop
		bra.s	imOut
imNoLaptop
		nop
imOut
		movem.l	(sp)+,d0-a6
		rts


; --------------------------------------------
; 02.06.00/vk
; nachricht zur anzeige im screen eintragen.
; a0 = string
installMessageScreen

		bsr	findMessage				; wird diese nachricht in a0 gerade schon angezeigt?
		tst.w	d0					; -1 = nein, 0,1,... index
		bmi.s	imsMessageNotFound			; nein -> dann verzweigen

		lea	messages,a1				; nachrichtenstruktur (beginn)
		mulu.w	#MESSAGEBYTES,d0			; ausgehend vom index das offset derjenigen nachricht berechnen
		move.w	#MESSAGETIME1000,MESSAGETIME(a1,d0.w)	; zeit dieser nachricht neu setzen
		bra.s	imsOut

imsMessageNotFound
		bsr	findFreeMessageBuffer			; freien bufferplatz suchen
		tst.w	d0					; noch einer frei?
		bpl.s	imsFoundFree

		bsr	findShortestMessage			; ein nachrichtenplatz wird ueberschrieben ...
		jsr	setFlagToClearBackground		; ... also muss hintergrund geloescht werden
imsFoundFree
		lea	messages,a1
		mulu.w	#MESSAGEBYTES,d0
		move.l	d0,d1

		move.l	a0,MESSAGEPTR(a1,d1.w)
		move.w	#MESSAGETIME1000,MESSAGETIME(a1,d1.w)
		bsr	calcStringLength
		move.w	d0,MESSAGELENGTH(a1,d1.w)
imsOut
		jsr	setFlagToClearBackground		; nachrichtenslots werden evtl. verschoben, also immer loeschen
		rts


; --------------------------------------------
; 02.01.00/vk
; nachricht zur anzeige im laptop eintragen.
; a0 = string
installMessageLaptop

		bsr.s	findMessage
		tst.w	d0
		bmi.s	imlMessageNotFound

		lea	messages,a1
		mulu.w	#MESSAGEBYTES,d0
		move.w	#MESSAGETIME1000,MESSAGETIME(a1,d0.w)	; soll wieder die volle zeit angezeigt werden

		bsr	laptopFindString			; nachricht innerhalb des laptops suchen
		tst.w	d6					; existiert nachricht noch?
		bpl.s	imlNoUpdate				; ja -> dann nicht neu zeichnen
		move.w	#1,MESSAGEINSTALLFLAG(a1)		; nachricht neu auf laptop ausgeben
imlNoUpdate	bra.s	imlOut

imlMessageNotFound
		bsr.s	findFreeMessageBuffer
		tst.w	d0
		bpl.s	imlFoundFree

		bsr	findShortestMessage
		lea	messages,a1
		mulu.w	#MESSAGEBYTES,d0

		move.l	a0,MESSAGEPTR(a1,d0.w)
		move.w	#1,MESSAGEINSTALLFLAG(a1,d0.w)
		move.w	#1,MESSAGECLEARFLAG(a1,d0.w)
		move.w	#MESSAGETIME1000,MESSAGETIME(a1,d0.w)
		bra.s	imlOut

imlFoundFree
		lea	messages,a1
		mulu.w	#MESSAGEBYTES,d0

		move.l	a0,MESSAGEPTR(a1,d0.w)
		move.l	a0,MESSAGEORIGINALPTR(a1,d0.w)
		move.w	#1,MESSAGEINSTALLFLAG(a1,d0.w)
		clr.w	MESSAGECLEARFLAG(a1,d0.w)
		move.w	#MESSAGETIME1000,MESSAGETIME(a1,d0.w)
imlOut
		rts


; ---------------------------------------------------------
; 01.06.00/vk
; bestimmt den index (0,1,...) der nachricht, falls existend.
; gibt -1 zurueck, falls die nachricht noch nicht existiert.
; a0 = nachricht
; rueckgabe: d0 = index 0,1,... oder -1 (nicht gefunden)
; rettet alle register
findMessage
		movem.l	d7/a1,-(sp)
		moveq	#NBOFMESSAGES-1,d7			; anzahl nachrichtenplaetze
		lea	messages,a1				; nachrichtendaten
fmLoop		cmpa.l	MESSAGEPTR(a1),a0			; eingetragenen pointer mit neuem vergleichen
		beq.s	fmMessageFound				; gleich/gefunden -> verzweigen 
		lea	MESSAGEBYTES(a1),a1			; update fuer naechsten nachrichtenplatz
		dbra	d7,fmLoop				; fuer alle nachrichtenplaetze
		moveq	#-1,d0
		bra.s	fmsgOut
fmMessageFound
		moveq	#NBOFMESSAGES-1,d0
		sub.w	d7,d0
fmsgOut
		movem.l	(sp)+,d7/a1
		rts


; ---------------------------------------------------------
; 01.06.00/vk
; bestimmt den ersten freien index fuer eine nachricht.
; rueckgabe: d0 = index 0,1,... oder -1 (keine buffer/index frei)
; rettet alle register
findFreeMessageBuffer
		movem.l	d7/a1,-(sp)
		lea	messages,a1
		moveq	#NBOFMESSAGES-1,d7
ffmbLoop	tst.l	MESSAGEPTR(a1)
		beq.s	ffmbFoundFree
		lea	MESSAGEBYTES(a1),a1
		dbra	d7,ffmbLoop
		moveq	#-1,d0
		bra.s	ffmbOut
ffmbFoundFree
		moveq	#NBOFMESSAGES-1,d0
		sub.w	d7,d0
ffmbOut
		movem.l	(sp)+,d7/a1
		rts


; ---------------------------------------------------------
; 01.06.00/vk
; bestimmt den index (0,1,...) der message, die noch
; die kuerzeste zeit angezeit wird.
; rueckgabe: d0 = index 0,1,...
; rettet alle register
findShortestMessage
		movem.l	d5-d7/a1,-(sp)
		lea	messages,a1
		moveq	#NBOFMESSAGES-1,d7
		move.w	d7,d0
		move.w	#$7fff,d6
fsmLoop		cmp.w	MESSAGETIME(a1),d6
		blt.s	fsmSkip
		move.w	MESSAGETIME(a1),d6
		move.w	d7,d5
fsmSkip		lea	MESSAGEBYTES(a1),a1
		dbra	d7,fsmLoop
		sub.w	d5,d0
		movem.l	(sp)+,d5-d7/a1
		rts


; ---------------------------------------------------------
; 05.06.00/vk
; berechnet die laenge eines strings (ohne abschl. null-terminator)
; a0 = string
; rueckgabe: d0.w = laenge
; rettet alle register
calcStringLength
		move.l	a0,-(sp)
		moveq	#0,d0
cslLoop		tst.b	(a0)+
		beq.s	cslOut
		addq.w	#1,d0
		bra.s	cslLoop
cslOut		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 01.06.00/vk
; loescht alle anzuzeigenden nachrichten aus dem internen buffer heraus.
; rettet alle register.
clearMessages
		movem.l	d0/a1,-(sp)
		moveq	#NBOFMESSAGES-1,d0
		lea	messages,a1
clmLoop		clr.l	MESSAGEPTR(a1)
		clr.w	MESSAGEINSTALLFLAG(a1)
		clr.w	MESSAGECLEARFLAG(a1)
		lea	MESSAGEBYTES(a1),a1
		dbra	d0,clmLoop
		movem.l	(sp)+,d0/a1
		rts


; ---------------------------------------------------------
; 05.06.00/vk
; setzt die offset zur anzeige von nachrichten innerhalb des screens
; d0 = xoffset in buchstaben (pos. = von links/neg. = von rechts)
; d1 = yoffset in zeilen (nur pos. werte zulaessig)
; rettet alle register
setMessageScreenOffsets

		movem.l	d0-a6,-(sp)
		move.w	d0,messageScreenXOffset
		move.w	d1,messageScreenYOffset
		jsr	setFlagToClearBackground
		movem.l	(sp)+,d0-a6
		rts




		data


; modus
messageMode	dc.w	MSGMODESCREEN

; offsets bei anzeige im screen (werden durch setMessageScreenOffsets() gesetzt)
messageScreenXOffset	dc.w	-1
messageScreenYOffset	dc.w	5


; messages
msgRunModeOff	dc.b	"RUN MODE OFF",0
msgRunModeOn	dc.b	"RUN MODE ON",0
msgPrimaryNot	dc.b	"PRIMARY MISSION NOT COMPLETED",0
msgSecondaryNot	dc.b	"SECONDARY MISSION NOT COMPLETED",0

msgSwitchToFull	dc.b	"SWITCH TO FULL CONSOLE MODE",0
msgNoFuel	dc.b	"NO FUEL AVAILABLE",0

		even



		bss

messages	ds.b	MESSAGEBYTES*NBOFMESSAGES
		even
