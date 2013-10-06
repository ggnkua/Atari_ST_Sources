
DEBUGA2			equ	1

; struktur fuer liniendaten
			rsreset
A2LINEDATAPTR		rs.l	1			; pointer auf liniendaten (5 long werte)
A2LINEY1DXMX1DY		rs.l	1			; zaehler fuer xs bei entfernungsberechnung (y1 * dx - x1 * dy)
A2LINEDX		rs.l	1
A2LINEDY		rs.l	1
A2LINENORMW		rs.w	1
A2LINERAYINDEX1		rs.w	1
A2LINERAYINDEX2		rs.w	1
A2LINENBRAYSDBRA	rs.w	1
A2LINERAYOFFSET		rs.w	1
A2LINEX1		rs.l	1
A2LINEY1		rs.l	1
A2LINEX2		rs.l	1
A2LINEY2		rs.l	1
A2LINEEXCHANGEFLAG	rs.w	1			; flag, ob koordinatenpaar vertauscht
A2LINEBACKSIDEFLAG	rs.w	1			; flag, ob rueckseite der textur gerade sichtbar ist
A2LINEBYTES		rs.w	1

; struktur a2raybufferv/h
			rsreset
A2RAYBUFFER		rs.l	1			; zeiger auf den gesamtbuffer
A2RAYBUFFERPTR		rs.l	1			; zeiger auf array an zeigern auf strahlbuffer
A2RAYBUFFERNBPTR	rs.l	1			; zeiger auf array der groessen pro strahlbuffer

A2RAYBUFFERVMAX		equ	60			; maximale anzahl an strahleintraegen pro vertikalen strahl

; struktur fuer eintrag in a2raybufferv
			rsreset
A2RBVH1			rs.w	1
A2RBVH2			rs.w	1
A2RBVXIND		rs.w	1
A2RBVYIND		rs.w	1
A2RBVZOOM		rs.l	1
A2RBVTEXT		rs.w	1
A2RBVDISTANCEX		rs.b	12
A2RBVXYOFFSET		rs.w	1
A2RBVFLAGS		rs.w	1
A2RBVYMASK		rs.w	1
A2RAYBUFFERVBYTES	rs.w	1

A2RAYBUFFERHMAX		equ	100			; maximale anzahl an strahleintraegen pro horizontalen strahl




		text


; ---------------------------------------------------------
; 16.04.00/vk
; loescht ein evtl. bisher berechnetes bild, d. h. die eintraege
; saemtlicher strahlenbuffer heraus.
; beruecksichtigt dabei nur die aktuelle breite (in strahlen) des
; bildes, nicht die maximal moegliche breite (in strahlen). dadurch
; wird das array schneller geloescht (d. h. nur die werte, die auch
; benoetigt werden).
c3pA2DeletePicture

		movea.l	a2RayBufferVPtr,a0		; pointer auf bufferv-daten
		movea.l	A2RAYBUFFERNBPTR(a0),a0		; pointer auf array der eintragsanzahlen
		move.w	c3pWidth,d0			; aktuelle breite in strahlen
		subq.w	#1,d0				; minus 1 fuer dbra
c3pa2dpVLoop	clr.w	(a0)+				; anzahl an strahleintraegen loeschen
		dbra	d0,c3pa2dpVLoop			; ueber alle sichtbaren strahlen

		rts


; ---------------------------------------------------------
; 06.01.00/vk
; alle linien partitionieren (fuer a2 gibt es nur eine
; partition) und ggf. entfernen.
c3pA2MakePartition

		movea.l	playerDataPtr,a0
		move.w	#512,d2			; vollwinkel
		sub.w	PDALPHA(a0),d2
		lsr.w	#1,d2			; d2 = zu addierendes winkeloffset (skaliere auf bereich 0..255, andere bits werden ignoriert)

		moveq	#0,d0			; anzahl sichtbarer linien
		move.l	#$7fffffff,d1		; max. schussweite setzen
		lea	c3pCalcPts,a0
		lea	a2CalcLines,a4		; hier werden die sichtbaren linien eingetragen
		lea	a2CalcLinesPtr,a5	; hier werden die pointer auf die sichtbaren linien eingetragen

		lea	c3pLines,a2
		move.w	c3pNbLines,d7
		bsr.s	c3pa2mpNow

		lea	c3pLinesMonsters,a2
		move.w	c3pNbMonsters,d7
; todo		bsr.s	c3pa2mpNow

		lea	c3pLinesDoors,a2
		move.w	c3pNbDoors,d7
		lsl.w	#2,d7
		bsr.s	c3pa2mpNow

		lea	c3pLinesThings,a2
		move.w	c3pNbThings,d7
; todo		bsr.s	c3pa2mpNow

		lea	c3pLinesSwitches,a2
		move.w	c3pNbSwitches,d7
; todo		bsr.s	c3pa2mpNow

		move.w	d0,a2NbCalcLines

		rts


; d0 = anzahl sichtbarer linien
; d1 = max. schussweite
; d2 = winkeloffset
; d7 = anzahl jetzt zu bearbeitender linien
; a0 = koordinaten (punkte)
; a2 = jetzt zu bearbeitende linien
; a4 = array der sichtbaren linien (partition)
; a5 = pointer auf sichtbare linien (wird fuer die sortierung benoetigt, spaeter wird nur noch hierueber zugegriffen)

;         y      45 grad
;         |     /          #1
;         |    /
;         |   /                               partition = partition #1 + partition #2 + partition #3
;   #4    |  /    partition #1
;         | /
;         |/               <-------\
; --------0------------------- x   |-- partition #3
;         |\               <-------/
;         | \
;   #3    |  \    partition #2
;         |   \
;         |    \
;         |     \          #2

; faelle:
; 0 = #1/#3 (quadranten)
; 1 = #1/#4
; 2 = #2/#3
; 3 = #2/#4

c3pa2mpNow
		tst.w	d7			; zu bearbeitende linien vorhanden?
		beq	c3pa2mpnOut		; nein -> dann raus
		subq.w	#1,d7			; fuer dbra subtrahieren
c3pa2mpnLoop
		move.w	2(a2),d5		; point_1
		move.w	4+2(a2),d4		; point_2
		move.l	(a0,d4.w),d3		; x2
		move.l	4(a0,d4.w),d4		; y2
		move.l	4(a0,d5.w),d6		; y1
		move.l	(a0,d5.w),d5		; x1

		;tst.l	d5			; entfaellt, da vorheriges move.l
		bmi.s	c3pa2mpnX1Neg

c3pa2mpnX1Pos
		; x1 ist positiv
		tst.l	d6
		bmi.s	c3pa2mpnP1In2
c3pa2mpnP1In1
		tst.l	d3
		bmi.s	c3pa2mpnP1In1X2Neg
c3pa2mpnP1In1X2Pos
		tst.l	d4
		bmi	c3pa2mpnPartition3
		bra	c3pa2mpnSector1
c3pa2mpnP1In1X2Neg
		tst.l	d4
		bpl.s	c3pa2mpnCase1
		bra.s	c3pa2mpnCase0
c3pa2mpnP1In2
		tst.l	d3
		bmi.s	c3pa2mpnP1In2X2Neg
c3pa2mpnP1In2X2Pos
		tst.l	d4
		bmi	c3pa2mpnSector2
		bra	c3pa2mpnPartition3
c3pa2mpnP1In2X2Neg
		tst.l	d4
		bpl.s	c3pa2mpnCase3
		bra.s	c3pa2mpnCase2

c3pa2mpnX1Neg
		tst.l	d6
		bpl.s	c3pa2mpnP1In4
c3pa2mpnP1In3
		tst.l	d3
		bmi	c3pa2mpnSkip
c3pa2mpnP1In3X2Pos
		tst.l	d4
		bmi.s	c3pa2mpnCase2
		bra.s	c3pa2mpnCase0
c3pa2mpnP1In4
		tst.l	d3
		bmi	c3pa2mpnSkip
c3pa2mpnP1In4X2Pos
		tst.l	d4
		bmi.s	c3pa2mpnCase3
		bra.s	c3pa2mpnCase1

; #1/#3
c3pa2mpnCase0
		tst.l	d5
		bmi.s	c3pa2mpnC0P1In3
c3pa2mpnC0P1In1
		cmp.l	d5,d6
		blt	c3pa2mpnPartition3
		cmp.l	d3,d4
		bgt	c3pa2mpnSkip
		bra	c3pa2mpnPartition3
c3pa2mpnC0P1In3
		cmp.l	d3,d4
		blt	c3pa2mpnPartition3
		cmp.l	d5,d6
		bgt	c3pa2mpnSkip
		bra	c3pa2mpnPartition3

; #1/#4
c3pa2mpnCase1
		tst.l	d5
		bmi.s	c3pa2mpnC1P1In4
c3pa2mpnC1P1In1
		cmp.l	d5,d6
		bgt	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible
c3pa2mpnC1P1In4
		cmp.l	d3,d4
		bgt	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible

; #2/#3
c3pa2mpnCase2
		tst.l	d5
		bmi.s	c3pa2mpnC2P1In3
c3pa2mpnC2P1In2
		neg.l	d6
		cmp.l	d5,d6
		bgt	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible
c3pa2mpnC2P1In3
		neg.l	d4
		cmp.l	d3,d4
		bgt	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible

; #2/#4
c3pa2mpnCase3
		tst.l	d5
		bmi.s	c3pa2mpnC3P1In4
c3pa2mpnC3P1In2
		neg.l	d6
		cmp.l	d5,d6
		blt.s	c3pa2mpnPartition3
		neg.l	d3
		cmp.l	d3,d4
		blt.s	c3pa2mpnSkip
		bra.s	c3pa2mpnPartition3
c3pa2mpnC3P1In4
		neg.l	d4
		cmp.l	d3,d4
		blt.s	c3pa2mpnPartition3
		neg.l	d5
		cmp.l	d5,d6
		blt.s	c3pa2mpnSkip
		bra.s	c3pa2mpnPartition3

c3pa2mpnSector1
		; p1 und p2 sind in sektor #1
		; nur dann beruecksichtigen, wenn mindestens ein punkt in partition #1
		cmp.l	d3,d4
		ble.s	c3pa2mpnLineVisible
		cmp.l	d5,d6
		bgt.s	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible

c3pa2mpnSector2
		; p1 und p2 sind in sektor #2
		; nur dann beruecksichtigen, wenn mindestens ein punkt in partition #2
		neg.l	d4
		cmp.l	d3,d4
		ble.s	c3pa2mpnLineVisible
		neg.l	d6
		cmp.l	d5,d6
		bgt.s	c3pa2mpnSkip
		bra.s	c3pa2mpnLineVisible

c3pa2mpnPartition3
		; p1 und p2 sind in sektor #1/#2 bzw. umgekehrt
		nop

c3pa2mpnLineVisible
		; linie ist sichtbar, jetzt eintragen
		move.l	a2,A2LINEDATAPTR(a4)		; pointer auf liniendaten eintragen
		move.w	14(a2),d3
		add.b	d2,d3
		andi.w	#$00ff,d3
		move.w	d3,A2LINENORMW(a4)

		move.l	a4,(a5)+			; pointer auf linie in array eintragen

		addq.w	#1,d0				; anzahl linien um eins erhoehen
		lea	A2LINEBYTES(a4),a4		; und offset fuer naechten linieneintrag addieren

c3pa2mpnSkip
		lea	20(a2),a2
c3pa2mpnNextLine
		dbra	d7,c3pa2mpnLoop
c3pa2mpnOut
		rts


; ---------------------------------------------------------
; 06.02.00/vk
; berechnet fuer alle im sichtfeld (partition) eingetragenen
; linien verschiedene werte:
;   a2lineexchangeflag
;   a2linex1/x2/y1/y2 (evtl. getauscht, wenn flag gesetzt)
;   a2linedx/dy
;   a2linerayindex1/2
;   a2linenbraysdbra
;   a2linerayoffset (1 oder -1)
; erleichtert den zugriff auf die koordinaten.
; setzt das flag und vertauscht ggf. das koordinatenpaar.
;c3pA2CalcDXYRayIndex
;
;		move.w	a2NbCalcLines,d7		; wieviel linien sind jetzt definitiv im sichtbaren bereicht?
;		beq	c3pa2cdriOut			; keine vorhanden -> raus
;		subq.w	#1,d7				; fuer dbra
;
;		lea	a2CalcLines,a0			; array aller in der partition befindlichen linien
;		lea	c3pCalcPts,a1			; geshiftete/rotierte punkte (koordinaten)
;c3pa2cdriLoop
;		movea.l	A2LINEDATAPTR(a0),a2		; a2 = definition der linie (5 * 4 langworte)
;		move.w	2(a2),d2			; point_1
;		move.w	4+2(a2),d3			; point_2
;		move.l	(a1,d2.w),d0			; x1
;		move.l	4(a1,d2.w),d1			; y1
;		move.l	(a1,d3.w),d2			; x2
;		move.l	4(a1,d3.w),d3			; y2
;
;		moveq	#0,d4
;		cmp.l	d0,d2				; x1 < x2
;		blt.s	c3pa2cdriNoExg
;		exg	d0,d2
;		exg	d1,d3
;		moveq	#1,d4
;c3pa2cdriNoExg	move.w	d4,A2LINEEXCHANGEFLAG(a0)
;		move.l	d0,A2LINEX1(a0)
;		move.l	d1,A2LINEY1(a0)
;		move.l	d2,A2LINEX2(a0)
;		move.l	d3,A2LINEY2(a0)
;
;		sub.l	d0,d2
;		sub.l	d1,d3
;		move.l	d2,A2LINEDX(a0)
;		move.l	d3,A2LINEDY(a0)
;
;		bsr.s	c3pa2cdriCalcRayIndex
;		move.w	d0,A2LINERAYINDEX1(a0)
;
;		move.l	A2LINEX2(a0),d0
;		move.l	A2LINEY2(a0),d1
;		bsr.s	c3pa2cdriCalcRayIndex
;		move.w	d0,A2LINERAYINDEX2(a0)
;
;		moveq	#1,d1
;		sub.w	A2LINERAYINDEX1(a0),d0
;		bpl.s	c3pa2cdriNoNeg
;		neg.w	d0
;		moveq	#-1,d1
;c3pa2cdriNoNeg	move.w	d0,A2LINENBRAYSDBRA(a0)
;		move.w	d1,A2LINERAYOFFSET(a0)
;
;		adda.w	#A2LINEBYTES,a0
;		dbra	d7,c3pa2cdriLoop
;c3pa2cdriOut
;		rts


; ---------------------------------------------------------
; 16.04.00/vk
;         y      0
;         |     /
;         |    /
;         |   /  
;         |  /   
;         | /
;         |/               
; --------0---------------- x
;         |\               
;         | \
;         |  \    
;         |   \
;         |    \
;         |     \(c3pwidth-1)
; berechnet den strahlenindex des uebergabepunktes.
; d0 = x
; d1 = y
; rueckgabe: d0 = rayindex im bereich [0..(c3pwidth-1)]
; rettet alle register.
c3pa2cdriCalcRayIndex

		movem.l	d1-d2,-(sp)

		tst.l	d0
		bmi.s	c3pa2cdricriXNeg
		tst.l	d1
		bmi.s	c3pa2cdricriXPosYNeg

		cmp.l	d0,d1
		bgt.s	c3pa2cdricriFirstIndex		; strahlenindex ist 0

		bra.s	c3pa2cdricriCalcMain

c3pa2cdricriXPosYNeg

		move.l	d1,d2
		neg.l	d2
		cmp.l	d0,d2
		bgt.s	c3pa2cdricriLastIndex		; strahlenindex ist (c3pwidth-1)		

		bra.s	c3pa2cdricriCalcMain

c3pa2cdricriXNeg
		tst.l	d1				; x ist negativ, y auch?
		bmi.s	c3pa2cdricriLastIndex		; ja -> verzweigen
		bra.s	c3pa2cdricriFirstIndex

c3pa2cdricriCalcMain
		bsr	c3pa2cdriCalcRayIndexMain
		bra.s	c3pa2cdricriOut

c3pa2cdricriFirstIndex
		moveq	#0,d0				; rayindex muss 0 sein
		bra.s	c3pa2cdricriOut			; und raus...

c3pa2cdricriLastIndex
		move.w	c3pWidth,d0			; rayindex ist der letzt-
		subq.w	#1,d0				; moegliche index

c3pa2cdricriOut
		movem.l	(sp)+,d1-d2
 		rts


; ---------------------------------------------------------
; 07.05.00/vk
; berechnet fuer alle im sichtfeld (partition) eingetragenen
; linien verschiedene werte:
;   a2lineexchangeflag
;   a2linex1/x2/y1/y2 (evtl. getauscht, wenn flag gesetzt)
;   a2linedx/dy
;   a2linerayindex1/2
;   a2linenbraysdbra
;   a2linerayoffset (1 oder -1)
; erleichtert den zugriff auf die koordinaten.
; setzt das flag und vertauscht ggf. das koordinatenpaar.
c3pA2CalcDXYRayIndex

		move.w	a2NbCalcLines,d7		; wieviel linien sind jetzt definitiv im sichtbaren bereicht?
		beq	c3pa2cdriOut			; keine vorhanden -> raus
		subq.w	#1,d7				; fuer dbra

		lea	a2CalcLines,a0			; array aller in der partition befindlichen linien
		lea	c3pCalcPts,a1			; geshiftete/rotierte punkte (koordinaten)
c3pa2cdriLoop
		movea.l	A2LINEDATAPTR(a0),a2		; a2 = definition der linie (5 * 4 langworte)
		move.w	2(a2),d2			; point_1
		move.w	4+2(a2),d3			; point_2
		move.l	(a1,d2.w),d0			; x1
		move.l	4(a1,d2.w),d1			; y1
		move.l	(a1,d3.w),d2			; x2
		move.l	4(a1,d3.w),d3			; y2

		moveq	#0,d4
		cmp.l	d0,d2				; x1 < x2
		blt.s	c3pa2cdriNoExg
		exg	d0,d2
		exg	d1,d3
		moveq	#1,d4
c3pa2cdriNoExg	move.w	d4,A2LINEEXCHANGEFLAG(a0)
		move.l	d0,A2LINEX1(a0)
		move.l	d1,A2LINEY1(a0)
		move.l	d2,A2LINEX2(a0)
		move.l	d3,A2LINEY2(a0)

		sub.l	d0,d2
		sub.l	d1,d3
		move.l	d2,A2LINEDX(a0)
		move.l	d3,A2LINEDY(a0)

		bsr	c3pa2cdriCalcRayIndex
		move.w	d0,A2LINERAYINDEX1(a0)

		move.l	A2LINEX2(a0),d0
		move.l	A2LINEY2(a0),d1
		bsr	c3pa2cdriCalcRayIndex
		move.w	d0,A2LINERAYINDEX2(a0)

		move.w	c3pWidth,d1
		move.w	d1,d2
		move.w	d1,d3
		subq.w	#1,d3			; d3 = c3pwidth - 1
		move.w	d1,d4
		add.w	d4,d4			; d4 = 2 * c3pwidth
		lsr.w	#1,d1
		add.w	d1,d2			; d2 = c3pwidth + 1/2 * c3pwidth
		neg.w	d1			; d1 = - 1/2 * c3pwidth

		tst.w	d0
		bmi.s	c3pa2cdriP2LeftOut
		cmp.w	d3,d0
		bgt.s	c3pa2cdriP2RightOut

c3pa2cdriP2Ok
		move.w	A2LINERAYINDEX1(a0),d0
		bmi.s	c3pa2cdriP1LeftOut
		cmp.w	d3,d0
		bgt.s	c3pa2cdriP1RightOut
		bra.s	c3pa2cdriP12Ok

c3pa2cdriP1LeftOut
		sub.w	A2LINERAYINDEX2(a0),d0
		bpl.s	c3pa2cdriP1loOk
		neg.w	d0
c3pa2cdriP1loOk	cmp.w	d4,d0
		bgt.s	c3pa2cdriP1loSetP1Max
		clr.w	A2LINERAYINDEX1(a0)
		bra.s	c3pa2cdriP12Ok
c3pa2cdriP1loSetP1Max
		move.w	d3,A2LINERAYINDEX1(a0)
		bra.s	c3pa2cdriP12Ok

c3pa2cdriP1RightOut
		clr.w	A2LINERAYINDEX1(a0)
		bra.s	c3pa2cdriP12Ok

		sub.w	A2LINERAYINDEX2(a0),d0
		bpl.s	c3pa2cdriP1roOk
		neg.w	d0
c3pa2cdriP1roOk	cmp.w	d4,d0
		bgt.s	c3pa2cdriP1roSetP1Max
		clr.w	A2LINERAYINDEX1(a0)
		bra.s	c3pa2cdriP12Ok
c3pa2cdriP1roSetP1Max
		move.w	d3,A2LINERAYINDEX1(a0)
		bra.s	c3pa2cdriP12Ok


c3pa2cdriP2LeftOut
		sub.w	A2LINERAYINDEX1(a0),d0
		bpl.s	c3pa2cdriP2loOk
		neg.w	d0
c3pa2cdriP2loOk	cmp.w	d4,d0
		bgt.s	c3pa2cdriP2loSetP2Max
		clr.w	A2LINERAYINDEX2(a0)
		bra.s	c3pa2cdriP12Ok
c3pa2cdriP2loSetP2Max
		move.w	d3,A2LINERAYINDEX2(a0)
		bra.s	c3pa2cdriP12Ok

c3pa2cdriP2RightOut
		sub.w	A2LINERAYINDEX1(a0),d0
		bpl.s	c3pa2cdriP2roOk
		neg.w	d0
c3pa2cdriP2roOk	cmp.w	d4,d0
		bgt.s	c3pa2cdriP2roSetP2Max
		clr.w	A2LINERAYINDEX2(a0)
		bra.s	c3pa2cdriP12Ok
c3pa2cdriP2roSetP2Max
		move.w	d3,A2LINERAYINDEX2(a0)
		;bra.s	c3pa2cdriP12Ok

c3pa2cdriP12Ok

		moveq	#1,d1
		move.w	A2LINERAYINDEX2(a0),d0
		sub.w	A2LINERAYINDEX1(a0),d0
		bpl.s	c3pa2cdriNoNeg
		neg.w	d0
		moveq	#-1,d1
c3pa2cdriNoNeg	move.w	d0,A2LINENBRAYSDBRA(a0)
		move.w	d1,A2LINERAYOFFSET(a0)

		adda.w	#A2LINEBYTES,a0
		dbra	d7,c3pa2cdriLoop
c3pa2cdriOut
		rts


; ---------------------------------------------------------
; 07.05.00/vk
;                      y      0
;                      |     /
;                      |    /
;                      |   /  
;                      |  /   
;                      | /
; -1,5*c3pwidth-1      |/               
;              --------0---------------- x
;  2,5*c3pwidth-1      |\               
;                      | \
;                      |  \    
;                      |   \
;                      |    \
;                      |     \(c3pwidth-1)
; berechnet den strahlenindex des uebergabepunktes.
; d0 = x
; d1 = y
; rueckgabe: d0 = rayindex
; rettet alle register.
c3pa2cdriCalcRayIndexNotClipped

		movem.l	d1-d2,-(sp)

		tst.l	d0
		bmi.s	c3pa2cdricrincXNeg

c3pa2cdricrincXPos
		tst.l	d1
		bmi.s	c3pa2cdricrincXPosYNeg

c3pa2cdricrincXYPos
		cmp.l	d0,d1
		bgt.s	c3pa2cdricrincXYPosNoChange
		exg	d0,d1
		bsr.s	c3pa2cdriCalcRayIndexMain
		neg.w	d0
		bra.s	c3pa2cdricrincOut
c3pa2cdricrincXYPosNoChange
		bsr.s	c3pa2cdriCalcRayIndexMain
		bra.s	c3pa2cdricrincOut

c3pa2cdricrincXPosYNeg
		neg.l	d1
		cmp.l	d0,d1
		bgt.s	c3pa2cdricrincXYPosNoChange
		exg	d0,d1
		bsr.s	c3pa2cdriCalcRayIndexMain
		neg.w	d0
		bra.s	c3pa2cdricrincOut
c3pa2cdricrincXPosYNegNoChange
		bsr.s	c3pa2cdriCalcRayIndexMain
		move.w	c3pWidth,d1
		subq.w	#1,d1
		add.w	d1,d0
		bra.s	c3pa2cdricrincOut

c3pa2cdricrincXNeg
		neg.l	d0
		tst.l	d1
		bmi.s	c3pa2cdricrincXNegYNeg

c3pa2cdricrincXNegYPos
		cmp.l	d0,d1
		bgt.s	c3pa2cdricrincXNegYPosNoChange
		move.w	c3pWidth,d1
		neg.w	d1
		add.w	d1,d0
		bra.s	c3pa2cdricrincOut
c3pa2cdricrincXNegYPosNoChange
		bsr.s	c3pa2cdriCalcRayIndexMain
		move.w	c3pWidth,d1
		neg.w	d1
		sub.w	d0,d1
		move.w	d1,d0
		bra.s	c3pa2cdricrincOut

c3pa2cdricrincXNegYNeg
		neg.l	d1
		cmp.l	d0,d1
		bgt.s	c3pa2cdricrincXNegYPosNoChange
		move.w	c3pWidth,d1
		add.w	d1,d1
		sub.w	d0,d1
		move.w	d1,d0
		bra.s	c3pa2cdricrincOut
c3pa2cdricrincXNegYNegNoChange
		bsr.s	c3pa2cdriCalcRayIndexMain
		move.w	c3pWidth,d1
		add.w	d1,d1
		add.w	d1,d0
;		bra.s	c3pa2cdricrincOut

c3pa2cdricrincOut
		movem.l	(sp)+,d1-d2
 		rts


; ---------------------------------------------------------
; 16.04.00/vk
; berechnet den strahlenindex des uebergabepunktes.
; die koordinaten muessen bereits im 90-grad-blickwinkel sein.
; d0 = x
; d1 = y (x/y muss zwingend zwischen -45 und 45 grad sein)
; rueckgabe: d0 = rayindex (zwischen 0 und c3pwidth-1)
; rettet alle register (ausser fp-registern).
c3pa2cdriCalcRayIndexMain

		movem.l	d7/a0,-(sp)

		fmove.l	d1,fp0
		fdiv.l	d0,fp0				; fp0 = dy/dx = tan(alpha)

	; nach voraussetzung gilt jetzt: -1 <= fp0 <= 1 (90-grad-blickwinkel)

	; tabellen-sortierung (tangens): 1,...,0,...,-1

		lea	c3pTangensTabX,a0
		move.w	c3pWidth,d7			; z. B. d7 = 320
		subq.w	#1,d7				; z. B. d7 = 319
		move.w	d7,d0				; d7 als schleifenzaehler, in d0 kopiert
c3pa2cdricrimLoop
		fmove.x	(a0)+,fp1			; naechsten tangens-tabelleneintrag nach fp1
		fcmp.x	fp1,fp0				; mit zielwert fp0 vergleichen
		fbge	c3pa2cdricrimFound		; zielwert (fp0) groesser, dann index gefunden
		dbra	d7,c3pa2cdricrimLoop

c3pa2cdricrimFound
		sub.w	d7,d0
c3pa2cdricrimOut
		movem.l	(sp)+,d7/a0
		rts


; ---------------------------------------------------------
; 20.04.00/vk
c3pA2Collision
		move.w	a2NbCalcLines,d7		; anzahl sichtbarer linien holen
		beq.s	c3pa2cOut			; keine sichtbar -> dann raus
		subq.w	#1,d7				; fuer dbra

		lea	a2CalcLinesPtr,a1		; array von a2line-pointern nach a1
		lea	c3pTangensTabX,a2		
c3pa2cLoop
		movea.l	(a1)+,a0			; pointer auf naechste a2line nach a0

		movem.l	d7/a1-a2,-(sp)

		bsr.s	c3pa2cCalcSide
		tst.w	d0
		beq.s	c3pa2cSkipLine

		bsr	c3pa2cCalcDistanceArray
		bsr	c3pa2cCalcH1H2Array
		bsr	c3pa2cCalcYIndArray
		bsr	c3pa2cCalcXIndArray
		bsr	c3pa2cCalcParameters
		bsr	c3pa2cInsertLine		; .\a2insert.s

c3pa2cSkipLine
		movem.l	(sp)+,d7/a1-a2
		dbra	d7,c3pa2cLoop			; loop ueber alle eingetragenen linien

c3pa2cOut

		move.w	#1,clearBackgroundFlag		; todo

		rts


; ---------------------------------------------------------
; 21.04.00/vk
; berechnet, ob die aktuelle linie in a0 gerade sichtbar ist
; oder nicht.
; achtung: rayindexx ist der index des strahls, keine winkelangabe.
; diese wird erst berechnet und ist dann aus [0,255], normw aus [0,255].
; setzt a2linebacksideflag korrekt, falls getroffene seite sichtbar ist.
; a0 = zeiger auf aktuelle a2line
; a2 = tangenstabelle
; rueckgabe: d0 = 0 (nicht sichtbar), 1 (sichtbar)
c3pa2cCalcSide
		lea	c3pAngleTab,a3

		move.w	A2LINERAYINDEX1(a0),d4		; index des strahls des linienanfangs holen
		move.b	(a3,d4.w),d5
		ext.w	d5				; d5.w = winkelangabe fuer linienanfang

		move.w	A2LINERAYINDEX1(a0),d4
		move.b	(a3,d4.w),d4
		ext.w	d4
		add.w	d4,d5
		asr.w	#1,d5

	; d5 ist die winkelangabe fuer einen (beliebigen) strahl, der die linie trifft.

		movea.l	A2LINEDATAPTR(a0),a1
		move.l	3*4(a1),d3			; lineflag_2

		move.w	A2LINENORMW(a0),d4		; d4 (normw) aus [0,255]
		ext.w	d4
		sub.w	d5,d4
		bpl.s	c3pa2ccsAnglePos
		neg.w	d4
c3pa2ccsAnglePos
		cmpi.w	#$40,d4
		bgt.s	c3pa2ccsBackHit

c3pa2ccsFrontHit
		btst	#8,d3				; ist vorderseite der textur sichtbar?
		beq.s	c3pa2ccsInvisible
		moveq	#1,d0
		clr.w	A2LINEBACKSIDEFLAG(a0)
		bra.s	c3pa2ccsOut

c3pa2ccsBackHit
		btst	#9,d3
		beq.s	c3pa2ccsInvisible
		moveq	#1,d0
		move.w	d0,A2LINEBACKSIDEFLAG(a0)
		bra.s	c3pa2ccsOut

c3pa2ccsInvisible
		moveq	#0,d0

c3pa2ccsOut
		rts


; ---------------------------------------------------------
; 21.04.00/vk
; berechnet das temporaere array, das die entfernungen der
; strahlen aufnimmt, die die aktuelle linie treffen.
; a0 = zeiger auf aktuelle a2line
; a2 = zeiger auf tangens-array (.x-format)
; rettet alle register (ausser fp-registern).
c3pa2cCalcDistanceArray

		movem.l	d5-d7/a2/a6,-(sp)

	; zaehler berechnen

		fmove.l	A2LINEDX(a0),fp0		; fp0 = dx
		fmove.l	A2LINEDY(a0),fp1		; fp1 = dy
		fmove.x	fp0,fp2
		fmove.x	fp1,fp3
		fmul.l	A2LINEY1(a0),fp2		; fp2 = y1 * dx
		fmul.l	A2LINEX1(a0),fp3		; fp3 = dy * x1
		fsub.x	fp3,fp2				; fp2 = y1 * dx - x1 * dy (entspricht zaehler)

		moveq	#12,d5				; offset fuer tangensarray
		tst.w	A2LINERAYOFFSET(a0)		; ist entweder 1 oder -1
		bpl.s	c3pa2cdaOffsetOk
		moveq	#-12,d5				; offset fuer tangensarray negieren
c3pa2cdaOffsetOk

		move.w	A2LINERAYINDEX1(a0),d6
		move.w	d6,d7
		add.w	d6,d6
		add.w	d7,d6
		add.w	d6,d6
		add.w	d6,d6				; multiplikation mit 12
		adda.w	d6,a2				; erster eintrag in tangensarray, auf den zugegriffen wird
		
	;         y1 * dx - x1 * dy
	;   xs = -------------------			( fp0 = dx, fp1 = dy, fp2 = zaehler )
	;           tan * dx - dy

		lea	a2DistanceArray,a5		; temp. array, das die ergebnisse aufnimmt
		lea	a2DistanceYArray,a6
		move.w	A2LINENBRAYSDBRA(a0),d7		; schleifenzaehler
c3pa2cdaLoop
		fmove.x	fp0,fp3				; fp3 = dx
		fmove.x	(a2),fp5			; fp5 = tan
		fmove.x	fp2,fp4				; zaehler kopieren
		fmul.x	fp5,fp3				; fp3 = tan * dx
		fsub.x	fp1,fp3				; fp3 = tan * dx - dy
		fdiv.x	fp3,fp4				; fp4 = xs

		fmove.x	fp4,(a5)+			; entfernung (xs) in array eintragen
		fmul.x	fp5,fp4
		fmove.x	fp4,(a6)+			; entfernung (ys) in array eintragen

		adda.w	d5,a2				; auf naechsten eintrag in tangensarray setzen
		dbra	d7,c3pa2cdaLoop

		movem.l	(sp)+,d5-d7/a2/a6
		rts


; ---------------------------------------------------------
; 21.04.00/vk
; berechnet die beiden arrays, die die werte fuer h1 und h2
; der aktuellen linie aufnehmen. die werte von h1 und h2 werden
; nicht gegenueber dem bildschirmfenster geclippt, eine anpassung
; der werte fuer yind erfolgt (hier) nicht.
; a0 = zeiger auf aktuelle a2line
c3pa2cCalcH1H2Array

		movea.l	A2LINEDATAPTR(a0),a1
		lea	c3p,a5
		lea	a2DistanceArray,a6

	; h1 und h2 fuer anfangskoordinate berechnen

		fmove.x	(a6),fp7
		bsr	c3pa2cCalcRealH1H2
		move.l	d6,d4
		move.l	d7,d5

	; h1 und h2 fuer endkoordinate berechnen

		move.w	A2LINENBRAYSDBRA(a0),d2
		mulu.w	#12,d2
		fmove.x	(a6,d2.w),fp7
		bsr	c3pa2cCalcRealH1H2

	; linie fuer h1 berechnen

		move.w	A2LINENBRAYSDBRA(a0),d0
		move.w	d4,d1
		move.w	d6,d2
		lea	a2YLineH1Array,a4
		bsr	c3pa2cCalcYCoordinateLine

	; linie fuer h2 berechnen

		move.w	A2LINENBRAYSDBRA(a0),d0
		move.w	d5,d1
		move.w	d7,d2
		lea	a2YLineH2Array,a4
		bsr	c3pa2cCalcYCoordinateLine

		rts


; ---------------------------------------------------------
; 21.04.00/vk
; berechnet die werte h1 und h2 fuer eine uebergebene entfernung,
; ohne die berechneten werte gegen den sichtbaren bildschirm
; (clippingfenster) zu schneiden/clippen.
; fp7 = entfernung
; a1 = 5-long datenfeld der linie
; a5 = c3p
; rueckgabe: d6 = h1
;            d7 = h2
; rettet alle register (ausser fp-registern).
c3pa2cCalcRealH1H2

		move.l	d5,-(sp)

		fmove.x	c3pPerspectiveValueX,fp5
		fdiv.x	fp7,fp5				; fp5 = pixelhoehe, die fuer die volle hoehe gezeichnet werden muesste

		fdiv.w	#C3PMAXHEIGHT,fp5		; fp5 = cheight / C3PMAXHEIGHT
		fmove.x	fp5,fp3				; wert wird mehrmals benoetigt
		fmul.w	C3PSH(a5),fp3			; fp3 = cheight * ( sh / C3PMAXHEIGHT )
		move.w	C3PHEIGHTHALF(a5),d5
		ext.l	d5
		fmove.l	fp3,d7
		sub.l	d7,d5				; d5 ist die bildschirmhoehe fuer sh=0

		fmove.x	fp5,fp3
		fmul.w	2*4+2(a1),fp3			; fp3 = cheight * ( h1 / C3PMAXHEIGHT )
		fmove.l	fp3,d6
		add.l	d5,d6

		move.w	3*4(a1),d7			; h2
		addq.w	#1,d7
		fmul.w	d7,fp5				; fp5 = cheight * ( h2 / C3PMAXHEIGHT )
		fmove.l	fp5,d7
		add.l	d5,d7
		subq.l	#1,d7

		cmp.w	d6,d7				; todo -> muss vergleich gemacht werden?
		bgt.s	c3pa2ccrh1h2Ok
		move.w	d6,d7				; h2 >= h1 muss gewaehrleistet sein
c3pa2ccrh1h2Ok

		move.l	(sp)+,d5
		rts


; ---------------------------------------------------------
; 21.04.00/vk
; berechnet die y-koordinaten einer linie.
; algorithmusidee: bresenham, inkl. abaenderung fuer
; spezielle dsp56001-zwecke.
; d0 = breite der linie (-1 fuer dbra)
; d1 = y1
; d2 = y2
; a4 = freies array, das gefuellt werden soll
; rettet alle register.
c3pa2cCalcYCoordinateLine

		movem.l	d0-d3/d6-d7/a4,-(sp)

		moveq	#1,d7				; offset erstmal auf positiv setzen
		sub.w	d1,d2				; dy
		bpl.s	c3pa2ccyclNoChange
		neg.w	d2				; dy wieder positiv
		moveq	#-1,d7				; offset auf negativ setzen
c3pa2ccyclNoChange
		cmp.w	d0,d2				; dx mit dy vergleichen
		bge.s	c3pa2ccyclSteep			; steile linie -> anderer code noetig

c3pa2ccyclFlat
		move.w	d2,d6				; d6 = dy
		sub.w	d0,d6				; d6 = dy - dx
		add.w	d6,d6				; inc2 = 2 * ( dy - dx )
		add.w	d2,d2				; inc1 = 2 * dy

		move.w	d2,d3
		sub.w	d0,d2				; g = 2 * dy - dx

c3pa2ccyclfLoop
		move.w	d1,(a4)+
		tst.w	d2				; g testen
		bmi.s	c3pa2ccyclfMin
		beq.s	c3pa2ccyclfMin
		add.w	d7,d1
		add.w	d6,d2				; g = g + inc2
		dbra	d0,c3pa2ccyclfLoop
		bra.s	c3pa2ccyclOut
c3pa2ccyclfMin
		add.w	d3,d2
		dbra	d0,c3pa2ccyclfLoop
		bra.s	c3pa2ccyclOut

c3pa2ccyclSteep
		move.w	d0,d6				; d6 = dx
		sub.w	d2,d6				; d6 = dx - dy
		add.w	d6,d6				; inc2 = 2 * ( dx - dy )
		add.w	d0,d0				; inc1 = 2 * dx

		move.w	d0,d3
		sub.w	d2,d0				; g = 2 * dx - dy

		move.w	d1,(a4)+			; ersten wert anfang bereits eintragen ...
c3pa2ccyclsLoop
		add.w	d7,d1
		tst.w	d0
		bmi.s	c3pa2ccyclsMin
		beq.s	c3pa2ccyclsMin
		move.w	d1,(a4)+			; ... sowie bei jeder veraenderung
		add.w	d6,d0
		dbra	d2,c3pa2ccyclsLoop
		bra.s	c3pa2ccyclOut
c3pa2ccyclsMin
		add.w	d3,d0
		dbra	d2,c3pa2ccyclsLoop

c3pa2ccyclOut
		movem.l	(sp)+,d0-d3/d6-d7/a4
		rts


; ---------------------------------------------------------
; 21.04.00/vk
; clippt die arrays von h1 bzw. h2 zu dem bildschirmfenster
; und erstellt dabei das yind-array.
; die linie wird fuer einen strahl unsichtbar, falls
; h1 auf einen negativen wert gesetzt wird.
; a0 = zeiger auf aktuelle linie.
c3pa2cCalcYIndArray

		lea	a2YLineH1Array,a4
		lea	a2YLineH2Array,a5
		lea	a2YIndArray,a6

		lea	c3p,a3
		move.l	C3PHEIGHTFORDBRALONG(a3),d5
		move.w	C3PHEIGHT(a3),d6

		move.w	A2LINENBRAYSDBRA(a0),d7
c3pa2ccyiaLoop
		moveq	#0,d3				; yind vorbereiten
		move.w	(a4),d4				; h1
		bpl.s	c3pa2ccyiaH1Ok
		move.w	d4,d3
		neg.w	d3
		moveq	#0,d4
		bra.s	c3pa2ccyiaH1Set
c3pa2ccyiaH1Ok	cmp.w	d5,d4
		bgt.s	c3pa2ccyiaNotVisible
c3pa2ccyiaH1Set	move.w	d4,(a4)				; h1 zurueckschreiben
		move.w	d3,(a6)				; yind neu schreiben

		move.w	(a5),d4				; h2
		bmi.s	c3pa2ccyiaNotVisible
		cmp.w	d6,d4
		blt.s	c3pa2ccyiaH2Ok
		move.w	d5,d4
c3pa2ccyiaH2Ok	move.w	d4,(a5)				; h2 zurueckschreiben
		bra.s	c3pa2ccyiaOk

c3pa2ccyiaNotVisible
		move.w	#-1,(a4)			; h1 negativ, d. h. auf ungueltig setzen

c3pa2ccyiaOk
		addq.l	#2,a4
		addq.l	#2,a5
		addq.l	#2,a6
		dbra	d7,c3pa2ccyiaLoop

		rts


; ---------------------------------------------------------
; 25.04.00/vk
; a0 = zeiger auf aktuelle linie
c3pa2cCalcXIndArray

		lea	a2DistanceYArray,a3
		movea.l	A2LINEDATAPTR(a0),a4
		lea	a2DistanceArray,a5
		lea	a2XIndArray,a6
		moveq	#0,d5
		move.b	2*4(a4),d5			; and_mask
		move.w	A2LINENBRAYSDBRA(a0),d7
		
		move.l	A2LINEDX(a0),d0
		neg.l	d0
		move.l	A2LINEDY(a0),d1
		bpl.s	c3pa2ccxiaDyOk
		neg.l	d1
c3pa2ccxiaDyOk	cmp.l	d0,d1
		blt.s	c3pa2ccxiaUseX


c3pa2ccxiaUseY
		fmove.l	A2LINEY1(a0),fp1

		fmove.w	4*4(a4),fp3			; fp3 = laenge
		fdiv.l	A2LINEDY(a0),fp3		; fp3 = laenge / dy    (fp3 > 0 oder fp3 < 0)
c3pa2ccxiauyLoop
		fmove.x	(a3)+,fp0
		fsub.x	fp1,fp0
		fmul.x	fp3,fp0
		fmove.w	fp0,(a6)
		and.w	d5,(a6)+

		dbra	d7,c3pa2ccxiauyLoop
		bra.s	c3pa2ccxiaOut


c3pa2ccxiaUseX
		fmove.l	A2LINEX1(a0),fp1

		fmove.w	4*4(a4),fp3			; fp3 = laenge
		fdiv.l	A2LINEDX(a0),fp3		; fp3 = laenge / dx
c3pa2ccxiauxLoop
		fmove.x	(a5)+,fp0
		fsub.x	fp1,fp0				; fp0 = xs - x1
		fmul.x	fp3,fp0
		fmove.w	fp0,(a6)
		and.w	d5,(a6)+

		dbra	d7,c3pa2ccxiauxLoop

c3pa2ccxiaOut
		rts


; ---------------------------------------------------------
; 16.02.00/vk
; berechnet fuer c3pcurrent verschiedene noch benoetigte
; parameter wie offsets, ymask etc.
; a0 = zeiger auf aktuelle a2line
c3pa2cCalcParameters

		movea.l	A2LINEDATAPTR(a0),a1
		lea	c3pCurrent,a2

		clr.w	C3PCURRENTFLAGS(a2)			; todo

		move.w	4*4+2(a1),C3PCURRENTXYOFFSET(a2)	; xyoffset

		moveq	#0,d0
		move.b	(a1),d0					; ymask
		move.w	d0,C3PCURRENTYMASK(a2)

c3pa2ccpOut
		rts


; ---------------------------------------------------------
; 12.02.00/vk
; traegt eine linie in the vertikalen strahlenbuffer ein. loescht dabei
; nicht sichtbare teilbereiche der linie/anderer linien heraus.
; nach voraussetzung des algorithmus wird die linie vor (!) den bereits
; vorhandenen eingetragen (linien sind entlang der x-achse sortiert).
; d0 = strahlindex
; d5 = h1
; d6 = h2
; a1 = c3pcurrent
; benutzt: d1-d4/d7/a5-a6
c3pa2MakeVEntry
		movea.l	a2RayBufferVPtr,a5
		movea.l	A2RAYBUFFERNBPTR(a5),a6
		movea.l	A2RAYBUFFERPTR(a5),a5
		movea.l	(a5,d0.w*4),a5			; a5 = aktueller strahlbuffer
		move.w	(a6,d0.w*2),d2			; d2 = anzahl bisheriger eintraege
		move.w	d2,d7
		movea.l	a5,a6
		mulu.w	#A2RAYBUFFERVBYTES,d2
		adda.l	d2,a6				; a6 = naechster freier eintrag im aktuellen strahlbuffer (wird neu gesetzt)

		tst.w	d7				; wieviel linien sind schon fuer aktuellen strahl eingetragen?
		beq	c3pa2meInsertHere		; kein -> dann neue linie einfach eintragen

		cmpi.w	#A2RAYBUFFERVMAX,d7		; maximalanzahl an eintraegen bereits erreicht?
		bge	c3pa2meOut			; ja -> dann sofort raus

		move.w	d7,d1
		subq.w	#1,d1				; fuer dbra (ueber alle bereits eingetragenen linien)

c3pa2meLoop

	; d0 = strahlindex
	; d1 = schleifenzaehler fuer alle linien (fuer dbra)
	; d5 = neues h1, wird innerhalb der schleife angepasst
	; d6 = neues h2, wird innerhalb der schleife angepasst
	; d7 = anzahl linien (nicht um 1 verringert), muss konstant bleiben
	; a1 = c3pcurrent
	; a5 = aktueller strahlbuffer
	; a6 = naechster freier eintrag im aktuellen strahlbuffer

		move.w	A2RBVH1(a5),d3			; untere kante der (bereits) eingetragenen textur holen
		bmi	c3pa2meSkip			; eingetragene textur ist nicht gueltig -> ueberspringen
		move.w	A2RBVH2(a5),d4			; obere kante der (bereits) eingetragenen textur holen
		cmp.w	d3,d6				; neue oberkante tiefer als eingetragene unterkante?
		blt	c3pa2meSkip			; keine ueberschneidung mit bereits eingetragener -> ueberspringen
		cmp.w	d4,d5				; neue unterkante hoeher als eingetragene oberkante?
		bgt	c3pa2meSkip			; keine ueberschneidung mit bereits eingetragener -> ueberspringen

	; die neue linie muss nach algorithmus-voraussetzung vor allen bereits eingetragenen sein

		btst	#C3PMASKEDFLAG,C3PCURRENTFLAGS(a1)	; wenn neue linie maskiert werden muss
		bne	c3pa2meSkip				; dann die dahinter immer zeichnen -> ueberspringen

		btst	#C3PFLOORFLAG,A2RBVFLAGS(a5)		; ist (bereits) eingetragene linie boden?
		bne	c3pa2meAnyInFrontOfFloor		; ja -> routine fuer "irgendwas" vor "boden"


;  |  |   |
; || ||  ||  |  ||  |  || || |     d6 d4
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d5 d3
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5				; neue unterkante niedriger/gleich als eingetrage unterkante?
		bls.s	c3pa2meC14			; ja -> fall 1 oder 4
c3pa2meC23
		cmp.w	d4,d6				; neue oberkante hoeher/gleich als eingetragene oberkante?
		bge.s	c3pa2meC3			; ja -> fall 3
c3pa2meC2
		move.w	d6,d2				; hintere textur teilen
		addq.w	#1,d2				; oberkante neue/vordere textur + 1
		move.w	d2,(a6)+			; h1
		move.l	A2RBVH2(a5),(a6)+		; h2 und xind
		move.l	A2RBVYIND(a5),(a6)+		; yind und zoom[hi]
		sub.w	d3,d2
		add.w	d2,-4(a6)			; yind noch abaendern
		move.l	A2RBVZOOM+2(a5),(a6)+		; zoom[low] und text
		move.l	A2RBVDISTANCEX(a5),(a6)+
		move.l	A2RBVDISTANCEX+4(a5),(a6)+
		move.l	A2RBVDISTANCEX+8(a5),(a6)+
		move.l	A2RBVXYOFFSET(a5),(a6)+		; xyoffset und flags
		move.w	A2RBVYMASK(a5),(a6)+		; ymask
		move.w	d5,d2				; unteren teil der hinteren
		subq.w	#1,d2				; textur noch oben abschneiden (h2)
		move.w	d2,A2RBVH2(a5)
		addq.w	#1,d7
		bra	c3pa2meSkip			; current kann so bleiben (voll sichtbar)
c3pa2meC3
		move.w	d5,d2
		subq.w	#1,d2
		move.w	d2,A2RBVH2(a5)			; hintere textur nur in der hoehe beschraenken
		bra	c3pa2meSkip

c3pa2meC14
		cmp.w	d4,d6
		bge.s	c3pa2meC4
c3pa2meC1
		move.w	d6,d2				; currentH2
		addq.w	#1,d2
		move.w	d2,A2RBVH1(a5)
		sub.w	d3,d2
		add.w	d2,A2RBVYIND(a5)
		bra	c3pa2meSkip
c3pa2meC4
		move.w	#-1,A2RBVH1(a5)			; hintere textur nicht mehr sichtbar
		bra	c3pa2meSkip



c3pa2meAnyInFrontOfFloor

;  |  |   |
; || ||  ||  |  ||  |  || || |     d6 d4
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d5 d3
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5
		bls.s	c3pa2meafC14
c3pa2meafC23
		cmp.w	d4,d6
		bge.s	c3pa2meafC3
c3pa2meafC2
		move.w	d6,d2				; hintere textur teilen
		addq.w	#1,d2
		move.w	d2,(a6)+			; h1
		move.l	A2RBVH2(a5),(a6)+		; h2 und xind
		move.l	A2RBVYIND(a5),(a6)+		; yind und zoom[hi]
		move.l	A2RBVZOOM+2(a5),(a6)+		; zoom[low] und text
		move.l	A2RBVDISTANCEX(a5),(a6)+
		move.l	A2RBVDISTANCEX+4(a5),(a6)+
		move.l	A2RBVDISTANCEX+8(a5),(a6)+
		move.l	A2RBVXYOFFSET(a5),(a6)+		; xyoffset und flags
		move.w	A2RBVYMASK(a5),(a6)+		; ymask
		move.w	d5,d2				; unteren teil der hinteren
		subq.w	#1,d2				; textur noch oben abschneiden (h2)
		move.w	d2,A2RBVH2(a5)
		addq.w	#1,d7	
		bra	c3pa2meSkip			; current kann so bleiben (voll sichtbar)
c3pa2meafC3
		move.w	d5,d2
		subq.w	#1,d2
		move.w	d2,A2RBVH2(a5)			; hintere textur nur in der hoehe beschraenken
		bra	c3pa2meSkip

c3pa2meafC14
		cmp.w	d4,d6
		bge.s	c3pa2meafC4
c3pa2meafC1
		move.w	d6,d2				; currentH2
		addq.w	#1,d2
		move.w	d2,A2RBVH1(a5)
		bra	c3pa2meSkip
c3pa2meafC4
		move.w	#-1,A2RBVH1(a5)			; hintere textur nicht mehr sichtbar
		;bra	c3pa2meSkip


c3pa2meSkip
		lea	A2RAYBUFFERVBYTES(a5),a5
		dbra	d1,c3pa2meLoop		

c3pa2meInsertHere
		move.w	d5,(a6)+				; c3pcurrenth1
		move.w	d6,(a6)+				; c3pcurrenth2
		move.w	C3PCURRENTXIND(a1),(a6)+
		move.w	C3PCURRENTYIND(a1),(a6)+
		move.l	C3PCURRENTZOOM(a1),(a6)+
		move.w	C3PCURRENTTEXT(a1),(a6)+
		move.l	C3PCURRENTDISTANCEX(a1),(a6)+
		move.l	C3PCURRENTDISTANCEX+4(a1),(a6)+
		move.l	C3PCURRENTDISTANCEX+8(a1),(a6)+
		move.w	C3PCURRENTXYOFFSET(a1),(a6)+
		move.w	C3PCURRENTFLAGS(a1),(a6)+
		move.w	C3PCURRENTYMASK(a1),(a6)+

		movea.l	a2RayBufferVPtr,a5
		movea.l	A2RAYBUFFERNBPTR(a5),a6
		addq.w	#1,d7
		move.w	d7,(a6,d0.w*2)

c3pa2meOut
		rts


; ---------------------------------------------------------
; 23.04.00/vk
; saemtliche strahleneintraege in die bildpuffer uebernehmen
; und dabei anpassen.
c3pA2MakeRayEntries

		lea	c3pPictureText,a0
		lea	c3pPictureFloor,a1
		lea	c3pPictureMasked,a2

		lea	c3pmreTexturAddresses,a3	; fertig multiplizierte offsets

		movea.l	a2RayBufferVPtr,a4
		movea.l	A2RAYBUFFERNBPTR(a4),a6		; array mit anzahl strahleintraegen pro strahl
		movea.l	A2RAYBUFFERPTR(a4),a4

		move.w	lineoffset,d5
		move.w	c3pHeightForDbra,d6

		move.w	c3pWidth,d0
		subq.w	#1,d0

c3pa2mreLoopAll

	; d0 = schleifencounter
	; d5 = lineoffset
	; d6 = c3pheightfordbra
	; a0 = c3pPictureText
	; a1 = c3pPictureFloor
	; a2 = c3pPictureMasked
	; a3 = c3pmreTexturAddresses
	; a4 = a2raybufferptr (array von pointer auf strahlbuffer)
	; a6 = a2raybuffernbptr (array von eintragsdimensionen)

		move.w	(a6)+,d7			; anzahl an eintraegen
		movea.l	(a4)+,a5			; diesen strahl bearbeiten

		movem.l	d0/a4/a6,-(sp)
		lea	c3pmreLightAddresses,a4		; fertig mulitplizierte offsets
		bsr	c3pA2MakeRayEntry
		movem.l	(sp)+,d0/a4/a6

		dbra	d0,c3pa2mreLoopAll

		rts


; ---------------------------------------------------------
; 24.04.00/vk
; eintraege eines strahls in die bildpuffer uebernehmen
; und dabei mit berechnungen anpassen.
; d5 = lineoffset
; d6 = c3pHeightForDbra
; d7 = anzahl eintraege des aktuellen strahls (noch nicht fuer dbra aufbereitet)
; a0 = c3pPictureTextPtr
; a1 = c3pPictureFloorPtr
; a2 = c3pPictureMaskedPtr
; a3 = c3pmreTexturAddresses
; a4 = c3pmreLightAddresses
; a5 = aktuell zu bearbeitender strahl (mit eintraegen)
c3pA2MakeRayEntry
		subq.w	#1,d7				; linien vorhanden?
		bmi	c3pa2mreWriteEnd		; nein -> dann schon endmarkierung schreiben

c3pa2mreLoop
		move.w	A2RBVH1(a5),d0			; h1
		bmi	c3pa2mreSkip			; negativ -> linie unsichtbar (geloescht)

		move.w	A2RBVH2(a5),d1			; h2
		sub.w	d0,d1
		bmi	c3pa2mreSkip			; todo -> sicherheitsverzweig kann man weglassen

		btst	#C3PFLOORFLAG,A2RBVFLAGS(a5)
		bne	c3pa2mreFloor
		btst	#C3PMASKEDFLAG,A2RBVFLAGS(a5)
		bne	c3pa2mreMasked

		move.w	A2RBVYMASK(a5),d3		; muss textur in y-richtung gekachelt werden?
; todo		bne	c3pa2mreYMask			; ja -> eigene angepasste routine

c3pa2mreStandardTile
		move.w	d1,C3PTEXTDBRA(a0)		; anzahl zu zeichnender pixel (fuer dbra)

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1				; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PTEXTYOFFSET(a0)

		moveq	#0,d0
		moveq	#0,d1
		move.w	A2RBVXYOFFSET(a5),d0
		move.w	A2RBVXIND(a5),d1
		lsl.w	#8,d1
		add.l	d1,d0
		add.l	d0,d0
		move.w	A2RBVTEXT(a5),d2
		andi.w	#$000f,d2			; todo
		add.l	(a3,d2.w*4),d0
		move.l	d0,C3PTEXTGFXPTR(a0)

		move.l	A2RBVZOOM(a5),d0
		move.l	d0,C3PTEXTZOOM(a0)
		fmove.l	d0,fp0
		fmul.w	A2RBVYIND(a5),fp0
		fmove.l	fp0,C3PTEXTZOOMOFFSET(a0)

		btst	#C3PLIGHTFLAG,A2RBVFLAGS(a5)
		beq.s	c3pa2mreNoLight
		fmove.x	A2RBVDISTANCEX(a5),fp0
		fmove.l	fp0,d0
		moveq	#10,d1				; todo -> weniger lsr, dafuer mehr andi
		lsr.l	d1,d0
		cmpi.w	#8,d0
		blt.s	c3pa2mreDistOk
		moveq	#7,d0
c3pa2mreDistOk	move.l	(a4,d0.w*4),C3PTEXTLIGHTOFFSET(a0)
		bra.s	c3pa2mreLightOk
c3pa2mreNoLight	clr.l	C3PTEXTLIGHTOFFSET(a0)

c3pa2mreLightOk
		lea	C3PTEXTBYTES(a0),a0
		bra	c3pa2mreSkip


c3pa2mreYMask
;		lea	c3pmreymBuffer,a4	; zwischenspeicher fuer h1/height/yind
;
;		addq.w	#1,d3			; ymask (war mit -1 im datenformat gespeichert)
;		fmove.w	d3,fp0			; fp0 = kachelgroesse (gesamtpixel)
;		fdiv.l	C3PRBZOOM(a6),fp0	; fp0 = groesse einer kachel in bildschirmkoordinaten ( / 65536 )
;		fmul.l	#65536,fp0		; jetzt ohne verzerrenden faktor
;		fmove.w	fp0,d4			; d4.w = groesse einer kachel in bildschirmkoordinaten
;
;		move.w	C3PRBYIND(a6),d2
;c3pmreymYLoop	sub.w	d4,d2
;		bpl.s	c3pmreymYLoop
;		add.w	d4,d2			; d2 entspricht yind im bereich 0..ymask
;
;		move.w	d4,d3			; kachelgroesse in bildschirmkoordinaten retten
;		sub.w	d2,d4			; von der ersten kachel sind noch d4 pixel zu zeichnen
;		sub.w	d4,d1			; pixel von der gesamthoehe abziehen
;		subq.w	#1,d1
;		bmi	c3pmrePreStandardTile	; weniger zu zeichnen als jetzt berechnet -> standardroutine
;		beq	c3pmrePreStandardTile	; gleichviel -> ebenso die standardroutine verwenden
;
;	; es sind also jetzt mindestens zwei kachelteile zu zeichnen
;
;		move.w	d0,(a4)+		; h1
;		move.w	d4,(a4)+		; height
;		move.w	d2,(a4)+		; yind
;
;		add.w	d4,d0
;		addq.w	#1,d0
;
;		move.w	d3,d2			; d3 = kachelgroesse
;		subq.w	#1,d2			; d2 = kachelgroesse - 1 (fuer dbra)
;c3pmreymCalcLoop
;		move.w	d0,(a4)+		; h1
;		sub.w	d3,d1			; pixel von verbleibender gesamthoehe abziehen
;		bmi.s	c3pmreymCalcEnd
;		beq.s	c3pmreymCalcEnd
;		move.w	d2,(a4)+		; height
;		clr.w	(a4)+			; yind
;		add.w	d3,d0
;		bra.s	c3pmreymCalcLoop
;
;c3pmreymCalcEnd
;		add.w	d1,d3
;		move.w	d3,(a4)+		; height
;		clr.w	(a4)+			; yind
;
;		move.w	#-1,(a4)+
;
;	; bevor die kacheln nun erzeugt werden, bestimmte konstanten (z. b. texturoffset)
;	; vorberechnen
;
;		moveq	#0,d1
;		moveq	#0,d2
;		move.w	C3PRBXYOFFSET(a6),d2
;		move.w	C3PRBXIND(a6),d1
;		lsl.w	#8,d1
;		add.l	d1,d2
;		add.l	d2,d2
;		move.w	C3PRBTEXT(a6),d1
;		add.l	(a2,d1.w*4),d2		; c3ptextgfxoffset
;
;		move.l	C3PRBZOOM(a6),d3	; c3ptextzoom
;		fmove.l	d3,fp0			; vorbereiten fuer fpu-multiplikation
;
;		btst	#C3PLIGHTFLAG,C3PRBFLAGS(a6)
;		beq.s	c3pmreymNoLight
;		fmove.x	C3PRBDISTANCEX(a6),fp0
;		fmove.l	fp0,d0
;		moveq	#10,d1
;		lsr.l	d1,d0
;		cmpi.l	#8,d0
;		blt.s	c3pmreymDistOk
;		moveq	#7,d0
;c3pmreymDistOk	move.l	(a3,d0.w*4),d4		; c3ptextlightoffset
;		bra.s	c3pmreymLightOk
;c3pmreymNoLight	moveq	#0,d4
;c3pmreymLightOk
;
;		lea	c3pmreymBuffer,a4
;c3pmreymBufferLoop
;		move.w	(a4)+,d0		; h1
;		bmi	c3pmreSkip		; alle bearbeitet -> beenden (ende schreiben)
;		move.w	(a4)+,C3PTEXTDBRA(a0)
;
;		move.w	d6,d1
;		sub.w	d0,d1
;		mulu	d5,d1			; todo -> mulu durch tabellenzugriff ersetzen
;		move.l	d1,C3PTEXTYOFFSET(a0)
;
;		move.l	d2,C3PTEXTGFXPTR(a0)
;
;		move.l	d3,C3PTEXTZOOM(a0)
;		fmove.x	fp0,fp1
;		fmul.w	(a4)+,fp1
;		fmove.l	fp1,C3PTEXTZOOMOFFSET(a0)
;
;		move.l	d4,C3PTEXTLIGHTOFFSET(a0)
;
;		lea	C3PTEXTBYTES(a0),a0
;		bra	c3pmreymBufferLoop
;
;c3pmrePreStandardTile
;		add.w	d4,d1
;		addq.w	#1,d1
;		move.w	d2,C3PRBYIND(a6)
;		bra	c3pmreStandardTile


c3pa2mreFloor
		move.w	d1,C3PFLOORDBRA(a1)		

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1				; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PFLOORYOFFSET(a1)

		move.w	A2RBVTEXT(a5),C3PFLOORCOLORINDEX(a1)

		lea	C3PFLOORBYTES(a1),a1
		bra.s	c3pa2mreSkip


c3pa2mreMasked
		move.w	d1,C3PMASKEDDBRA(a2)		; anzahl zu zeichnender pixel (fuer dbra)

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1				; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PMASKEDYOFFSET(a2)

		moveq	#0,d0
		moveq	#0,d1
		move.w	A2RBVXYOFFSET(a5),d0
		move.w	A2RBVXIND(a5),d1
		lsl.w	#8,d1
		add.l	d1,d0
		add.l	d0,d0
		move.w	A2RBVTEXT(a5),d2
		add.l	(a3,d2.w*4),d0
		move.l	d0,C3PMASKEDGFXPTR(a2)

		move.l	A2RBVZOOM(a5),d0
		move.l	d0,C3PMASKEDZOOM(a2)
		fmove.l	d0,fp0
		fmul.w	A2RBVYIND(a5),fp0
		fmove.l	fp0,C3PMASKEDZOOMOFFSET(a2)

		btst	#C3PLIGHTFLAG,A2RBVFLAGS(a5)
		beq.s	c3pa2mremNoLight
		fmove.x	A2RBVDISTANCEX(a5),fp0
		fmove.l	fp0,d0
		moveq	#10,d1
		lsr.l	d1,d0
		cmpi.l	#8,d0
		blt.s	c3pa2mremDistOk
		moveq	#7,d0
c3pa2mremDistOk	move.l	(a3,d0.w*4),C3PMASKEDLIGHTOFFSET(a2)
		bra.s	c3pa2mremLightOk
c3pa2mremNoLight
		clr.l	C3PMASKEDLIGHTOFFSET(a2)

c3pa2mremLightOk
		lea	C3PMASKEDBYTES(a2),a2


c3pa2mreSkip
		lea	A2RAYBUFFERVBYTES(a5),a5
		dbra	d7,c3pa2mreLoop

c3pa2mreWriteEnd
		moveq	#-1,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.w	d0,(a2)+

		rts










		data


a2NbCalcLines		dc.w	0



		bss


a2CalcLinesPtr		ds.l	C3PLINESMAX
			ds.l	C3PMONSTERSMAX
			ds.l	C3PDOORSMAX*4
			ds.l	C3PTHINGSMAX
			ds.l	C3PSWITCHESMAX

a2CalcLines		ds.b	C3PLINESMAX*A2LINEBYTES
			ds.b	C3PMONSTERSMAX*A2LINEBYTES
			ds.b	C3PDOORSMAX*4*A2LINEBYTES
			ds.b	C3PTHINGSMAX*A2LINEBYTES
			ds.b	C3PSWITCHESMAX*A2LINEBYTES

a2YLineH1Array		ds.w	C3PMAXX			; temp. array, das die hoehen h1 der aktuellen linie aufnimmt
a2YLineH2Array		ds.w	C3PMAXX			; temp. array, das die hoehen h2 der aktuellen linie aufnimmt
a2DistanceArray		ds.b	12*C3PMAXX		; temp. array, das die entfernungen der aktuellen linie aufnimmt
a2DistanceYArray	ds.b	12*C3PMAXX		; temp. array, das die y2-entfernungen der aktuellen linie aufnimmt
a2XIndArray		ds.w	C3PMAXX			; temp. array, das die xoffsets der textur aufnimmt
a2YIndArray		ds.w	C3PMAXX			; temp. array, das die yind-werte der strahlen aufnimmt
			ds.b	65536			; todo

c3pa2ZoomMultiplicator	ds.b	12

a2RayBufferVPtr		ds.l	1
a2CurrentRayBufferV	ds.l	1

