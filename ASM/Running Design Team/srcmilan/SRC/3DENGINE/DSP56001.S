
C3PDEBUGONLY1RAY	equ	0

; 3d engine konstanten
C3PMAXX			equ	1024
C3PMAXY			equ	768

C3PMAXHEIGHT		equ	8192
C3PMAXHEIGHTBIT		equ	13

; puffer fuer aktuell berechneten strahl
C3PRAYBUFFERMAX		equ	60

C3PRBH1			equ	0
C3PRBH2			equ	2
C3PRBXIND		equ	4
C3PRBYIND		equ	6
C3PRBZOOM		equ	8
C3PRBTEXT		equ	12
C3PRBDISTANCEX		equ	14
C3PRBXYOFFSET		equ	26
C3PRBFLAGS		equ	28
C3PRBYMASK		equ	30

C3PRAYBUFFERBYTES	equ	32

; puffer fuer stack beim eintragen der linien
C3PMENSTACKMAX		equ	30

C3PMENSTACKH1		equ	0
C3PMENSTACKH2		equ	2
C3PMENSTACKYIND		equ	4

C3PMENSTACKBYTES	equ	6

; anzahl moeglicher punkte/linien/tueren/etc.
C3PPOINTSMAX		equ	192
C3PLINESMAX		equ	192
C3PMONSTERSMAX		equ	32
C3PDOORSMAX		equ	32
C3PTHINGSMAX		equ	48
C3PSWITCHESMAX		equ	24

; aktuell zu bearbeitende linie
C3PCURRENTDISTANCEX	equ	0
C3PCURRENTDISTANCE	equ	12
C3PCURRENTCHEIGHT	equ	16
C3PCURRENTXYOFFSET	equ	20
C3PCURRENTZOOM		equ	22
C3PCURRENTH1		equ	26
C3PCURRENTH1ORIGINAL	equ	28
C3PCURRENTH2		equ	30
C3PCURRENTH2ORIGINAL	equ	32
C3PCURRENTTEXT		equ	34
C3PCURRENTXIND		equ	36
C3PCURRENTYIND		equ	38
C3PCURRENTFLAGS		equ	40
C3PCURRENTYMASK		equ	42		; bei erweiterung -> makeEntry anpassen (kopieren der zu bearbeitenden linie)

C3PCURRENTBYTES		equ	44

C3PFLOORFLAG		equ	0
C3PMASKEDFLAG		equ	1
C3PLIGHTFLAG		equ	2
C3PTRANSPARENCEFLAG	equ	3

; bitpositionen im flag
C3PBACKSIDEFLAG		equ	0
C3PEXGFLAG		equ	1
C3PSTEILEFLAG		equ	2

; variablenstruktur
C3PWIDTH		equ	0
C3PHEIGHTLONG		equ	2
C3PHEIGHT		equ	4
C3PHEIGHTHALFLONG	equ	6
C3PHEIGHTHALF		equ	8
C3PHEIGHTFORDBRALONG	equ	10
C3PHEIGHTFORDBRA	equ	12
C3PWIDTHMIN		equ	14
C3PWIDTHMAX		equ	16
C3PHEIGHTMIN		equ	18
C3PHEIGHTMAX		equ	20
C3PSH			equ	22
C3PSKYTEXT		equ	24
C3PSKYZOOM		equ	26
C3PSKYZOOMX		equ	30
C3PSKYXYOFFSET		equ	42
C3PSKYMASK		equ	44
C3PRAYCOUNTER		equ	46

; anzahl maskierbarer texturen
C3PMASKEDTEXTMAX	equ	64

; anzahl fertig berechneter texturstreifen
; anzahl bytes pro texturstreifen
C3PTEXTMAX		equ	5000

C3PTEXTDBRA		equ	0
C3PTEXTYOFFSET		equ	2
C3PTEXTGFXPTR		equ	6
C3PTEXTZOOM		equ	10
C3PTEXTZOOMOFFSET	equ	14
C3PTEXTLIGHTOFFSET	equ	18

C3PTEXTBYTES		equ	22

; anzahl fertig berechneter bodenstreifen
; anzahl bytes pro bodenstreifen
C3PFLOORMAX		equ	5000

C3PFLOORDBRA		equ	0
C3PFLOORYOFFSET		equ	2
C3PFLOORCOLORINDEX	equ	6

C3PFLOORBYTES		equ	8

; anzahl fertig berechneter maskierter texturstreifen
; anzahl bytes pro maskiertem texturstreifen
C3PMASKEDMAX		equ	5000

C3PMASKEDDBRA		equ	0
C3PMASKEDYOFFSET	equ	2
C3PMASKEDGFXPTR		equ	6
C3PMASKEDZOOM		equ	10
C3PMASKEDZOOMOFFSET	equ	14
C3PMASKEDLIGHTOFFSET	equ	18

C3PMASKEDBYTES		equ	22

; anzahl fertig berechneter transparent maskierter texturstreifen
; anzahl bytes pro transparent maskiertem texturstreifen
C3PTRANSMAX		equ	5000
			rsreset
C3PTRANSBRA		rs.w	1
C3PTRANSYOFFSET		rs.l	1
C3PTRANSGFXPTR		rs.l	1
C3PTRANSZOOM		rs.l	1
C3PTRANSZOOMOFFSET	rs.l	1
C3PTRANSLIGHTOFFSET	rs.l	1

C3PTRANSBYTES		rs.w	1



		text


; -------------------------------------------------------------------
; schneller zugriff auf spielerdaten
c3pQuickAccess
		movea.l	playerDataPtr,a5
		move.w	PDSH(a5),d0
		lsr.w	#1,d0
		move.w	d0,c3pSH

		rts


; -------------------------------------------------------------------
; variablen und pointer zuruecksetzen
c3pDeletePicture

		move.l	#c3pPictureText,c3pPictureTextPtr
		move.l	#c3pPictureFloor,c3pPictureFloorPtr
		move.l	#c3pPictureMasked,c3pPictureMaskedPtr
		move.l	#c3pPictureTrans,c3pPictureTransPtr

		rts


; -------------------------------------------------------------------
; x/y-koordinaten shiften und rotieren
c3pShiftAndRotate

		move.l	playerDataPtr,a0
		fmove.l	PDSX(a0),fp0		; koordinaten des spielers
		fmove.l	PDSY(a0),fp1		; x- und y-koordinaten in fp-register

		lea	sinus512TabX,a1
		move.w	#512,d4
		sub.w	PDALPHA(a0),d4		; bereich PDALPHA ist 0..511
		andi.w	#$1ff,d4
		add.w	d4,d4
		fmove.x	(a1,d4.w*8),fp2		; tabellenwerte liegen an 16 byte-grenzen (sinus)
		addi.w	#$80*2,d4
		andi.w	#$3ff,d4
		fmove.x	(a1,d4.w*8),fp3		; cosinus

		move.w	c3pNbPoints,d7
		lea	c3pPoints,a0
		lea	c3pCalcPts,a1
		bsr.s	c3psarNow

		move.w	c3pNbMonsters,d7
		lea	c3pPointsMonsters,a0
		lea	c3pCalcPtsMonsters,a1
		bsr.s	c3psarNow

		move.w	c3pNbDoors,d7
		lsl.w	#2,d7			; 1 tuer = 4 koordinatenwerte
		lea	c3pPointsDoors,a0
		lea	c3pCalcPtsDoors,a1
		bsr.s	c3psarNow

		move.w	c3pNbThings,d7
		lea	c3pPointsThings,a0
		lea	c3pCalcPtsThings,a1
		bsr.s	c3psarNow

		move.w	c3pNbSwitches,d7
		add.w	d7,d7			; 1 schalter = 2 koordinatenwerte
		lea	c3pPointsSwitches,a0
		lea	c3pCalcPtsSwitches,a1
		bsr.s	c3psarNow

		rts


; fp0 = sx
; fp1 = sy
; fp2 = sin
; fp3 = cos
; d7.w = anzahl koordinatenpaare
; a0 = original koordinaten
; a1 = berechnete koordinaten

; shiftet und rotiert die original-koordinaten von a0 nach a1

c3psarNow
		tst.w	d7
		beq.s	c3psarnOut
		subq.w	#1,d7
c3psarnLoop
		fmove.l	(a0)+,fp4
		fmove.l	(a0)+,fp5
		fsub.x	fp0,fp4
		fsub.x	fp1,fp5
		fmove.x	fp4,fp6
		fmove.x	fp5,fp7
		fmul.x	fp3,fp4
		fmul.x	fp2,fp5
		fmul.x	fp2,fp6
		fmul.x	fp3,fp7
		fsub.x	fp5,fp4
		fadd.x	fp6,fp7
		fmove.l	fp4,(a1)+
		fmove.l	fp7,(a1)+

		dbra	d7,c3psarnLoop
c3psarnOut
		rts


; -------------------------------------------------------------------
; gegenstaende aus der punktangabe in planar in den raum setzen
c3pPlaceThings
		move.w	c3pNbThings,d7
		beq.s	c3pptOut
		subq.w	#1,d7

		lea	c3pCalcPtsThings,a0
		lea	c3pCalcPtsTThings,a1
		lea	c3pLinesThings,a2
c3pptLoop
		move.l	(a0)+,d0		; x
		move.l	(a0)+,d1		; y
		move.l	d1,d3

		moveq	#0,d2
		move.w	4*4(a2),d2		; laenge ([31..16] von line_flag_3)
		lsl.l	#3,d2			; * 16 (fuer DSPGENAUIGKEIT), / 2 (fuer halbe seiten) --> * 8

		move.l	d0,(a1)+		; x-wert bleibt konstant
		add.l	d2,d1
		move.l	d1,(a1)+		; y-wert fuer punkt 1

		move.l	d0,(a1)+		; x-wert bleibt konstant
		sub.l	d2,d3
		move.l	d3,(a1)+		; y-wert fuer punkt 2 

		lea	5*4(a2),a2
		dbra	d7,c3pptLoop

c3pptOut
		rts


; -------------------------------------------------------------------
; 15.09.00/vk
; gegner aus der punktangabe planar in den raum setzen.
; aus jedem der standpunkte werden zwei punkte erzeugt, die dann
; miteinander "verbunden" die linie fuer das monster darstellen.
; bereitet das monster ggf. zum spiegelverkehrten zeichnen vor.
c3pPlaceMonsters
		move.w	c3pNbMonsters,d7		; anzahl vorhandener gegner holen
		beq.s	c3ppmOut			; keine vorhanden -> raus
		subq.w	#1,d7				; fuer dbra

		lea	c3pCalcPtsMonsters,a0		; hier liegen die rotierten standpunkte der monster
		lea	c3pCalcPtsMMonsters,a1		; hier werden die zwei neuen koordinatenpaare (planar im raum) abgelegt
		lea	c3pLinesMonsters,a2		; hier sind die point-offsets und lineflags abgelegt
		lea	c3pMonstersAddFlags,a3	

c3ppmLoop
		move.l	(a0)+,d0			; x
		move.l	(a0)+,d1			; y
		move.l	d1,d3

		move.l	(a3)+,d5			; breite (links/rechts), killed und turn flag

		btst	#MONADDFLAGTRANSBIT,d5		; muss textur transparent gezeichnet werden?
		beq.s	c3ppmlNoTrans			; nein -> verzweigen
		bset	#24-24,4(a2)			; bit 24 von point_2 setzen
c3ppmlNoTrans

		move.w	d5,d4
		andi.l	#$ff,d4				; breite (links) maximal 255 pixel
		lsl.w	#4,d4				; mit dsp-genauigkeit (16) multiplizieren (op. kann .w sein)

		move.w	d5,d2
		andi.l	#$ff00,d2			; breite (rechts) maximal 255 pixel
		lsr.w	#4,d2				; mit dsp-genauigkeit multiplizieren (op. kann .w sein)

		btst	#MONADDFLAGMIRRORBIT,d5		; muss textur spiegelverkehrt gezeichnet werden?
		beq.s	c3ppmlNoMirror
		neg.l	d4				; beide y-offsets fuer die y-koordinaten umdrehen
		neg.l	d2		
		move.b	#$80,12+3(a2)			; normw auf $80 setzen
c3ppmlNoMirror
		add.l	d4,d1				; y-offsets jetzt auf y-(mittelpunkts)-koordinate addieren/subtrahieren
		sub.l	d2,d3

		move.l	d0,(a1)+			; neue zwei koordinatenpaare abspeichern
		move.l	d1,(a1)+
		move.l	d0,(a1)+
		move.l	d3,(a1)+

		lea	20(a2),a2			; c3plinesmonsters auf naechstes monster setzen
		dbra	d7,c3ppmLoop 			; schleife ueber alle monster

c3ppmOut
		rts


; -------------------------------------------------------------------
; linien in partitionen aufteilen, ggf. entfernen
c3pMakePartitions

		lea	c3pCalcLines1,a4	; neue partition #1
		lea	c3pCalcLines2,a5	; neue partition #2

		move.l	#$7fffffff,a6		; max. schussweite setzen

	; zu addierendes winkeloffset berechnen
		move.w	#512,d2			; vollwinkel
		movea.l	playerDataPtr,a0
		sub.w	PDALPHA(a0),d2
		lsr.w	#1,d2			; skaliere auf bereich 0..255
						; belegt dann nur bits 0..7, andere bits werden ignoriert (.b-operation)

		moveq	#0,d0			; anzahl linien in partition #1
		moveq	#0,d1			; anzahl linien in partition #2

		lea	c3pCalcPts,a0
		lea	c3pLines,a2
		move.w	c3pNbLines,d7
		bsr.s	c3pmpNow

		lea	c3pLinesMonsters,a2
		move.w	c3pNbMonsters,d7
		bsr.s	c3pmpNow

		lea	c3pLinesDoors,a2
		move.w	c3pNbDoors,d7
		lsl.w	#2,d7
		bsr.s	c3pmpNow

		lea	c3pLinesThings,a2
		move.w	c3pNbThings,d7
		bsr.s	c3pmpNow

		lea	c3pLinesSwitches,a2
		move.w	c3pNbSwitches,d7
		bsr.s	c3pmpNow

		move.w	d0,c3pNbCalcLines1
		move.w	d1,c3pNbCalcLines2

		rts


; d0 = anzahl linien in partition #1
; d1 = anzahl linien in partition #2
; d2 = winkeloffset
; d7 = anzahl linien
; a0 = koordinaten
; a2 = linien
; a4 = partition #1
; a5 = partition #2
; a6 = max. schussweite


;         y      45 grad
;         |     /          #1
;         |    /
;         |   /
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
; 0 = #1/#3
; 1 = #1/#4
; 2 = #2/#3
; 3 = #2/#4

c3pmpNow
		tst.w	d7			; linien vorhanden?
		beq	c3pmpnOut		; nein, dann raus
		subq.w	#1,d7			; fuer dbra subtrahieren
c3pmpnLoop
		move.w	2(a2),d5		; point_1
		move.w	4+2(a2),d4		; point_2
		move.l	(a0,d4.w),d3		; x2
		move.l	4(a0,d4.w),d4		; y2
		move.l	4(a0,d5.w),d6		; y1
		move.l	(a0,d5.w),d5		; x1

		;tst.l	d5			; entfaellt, da vorheriges move.l
		bmi.s	c3pmpnX1Neg

c3pmpnX1Pos
		; x1 ist positiv (sektor 1)
		tst.l	d6
		bmi.s	c3pmpnP1In2
c3pmpnP1In1
		tst.l	d3
		bmi.s	c3pmpnP1In1X2Neg
c3pmpnP1In1X2Pos
		tst.l	d4
		bmi	c3pmpnPartition3
		bra	c3pmpnSector1
c3pmpnP1In1X2Neg
		tst.l	d4
		bpl.s	c3pmpnCase1
		bra.s	c3pmpnCase0
c3pmpnP1In2
		tst.l	d3
		bmi.s	c3pmpnP1In2X2Neg
c3pmpnP1In2X2Pos
		tst.l	d4
		bmi	c3pmpnSector2
		bra	c3pmpnPartition3
c3pmpnP1In2X2Neg
		tst.l	d4
		bpl.s	c3pmpnCase3
		bra.s	c3pmpnCase2

c3pmpnX1Neg
		tst.l	d6
		bpl.s	c3pmpnP1In4
c3pmpnP1In3
		tst.l	d3
		bmi	c3pmpnSkip
c3pmpnP1In3X2Pos
		tst.l	d4
		bmi.s	c3pmpnCase2
		bra.s	c3pmpnCase0
c3pmpnP1In4
		tst.l	d3
		bmi	c3pmpnSkip
c3pmpnP1In4X2Pos
		tst.l	d4
		bmi.s	c3pmpnCase3
		bra.s	c3pmpnCase1

; #1/#3
c3pmpnCase0
		tst.l	d5
		bmi.s	c3pmpnC0P1In3
c3pmpnC0P1In1
		cmp.l	d5,d6
		blt	c3pmpnPartition3
		cmp.l	d3,d4
		bgt	c3pmpnSkip
		bra	c3pmpnPartition3
c3pmpnC0P1In3
		cmp.l	d3,d4
		blt	c3pmpnPartition3
		cmp.l	d5,d6
		bgt	c3pmpnSkip
		bra	c3pmpnPartition3

; #1/#4
c3pmpnCase1
		tst.l	d5
		bmi.s	c3pmpnC1P1In4
c3pmpnC1P1In1
		cmp.l	d5,d6
		bgt	c3pmpnSkip
		bra.s	c3pmpnPartition1
c3pmpnC1P1In4
		cmp.l	d3,d4
		bgt	c3pmpnSkip
		bra.s	c3pmpnPartition1

; #2/#3
c3pmpnCase2
		tst.l	d5
		bmi.s	c3pmpnC2P1In3
c3pmpnC2P1In2
		neg.l	d6
		cmp.l	d5,d6
		bgt	c3pmpnSkip
		bra.s	c3pmpnPartition2
c3pmpnC2P1In3
		neg.l	d4
		cmp.l	d3,d4
		bgt	c3pmpnSkip
		bra.s	c3pmpnPartition2

; #2/#4
c3pmpnCase3
		tst.l	d5
		bmi.s	c3pmpnC3P1In4
c3pmpnC3P1In2
		neg.l	d6
		cmp.l	d5,d6
		blt.s	c3pmpnPartition3
		neg.l	d3
		cmp.l	d3,d4
		blt.s	c3pmpnSkip
		bra.s	c3pmpnPartition3
c3pmpnC3P1In4
		neg.l	d4
		cmp.l	d3,d4
		blt.s	c3pmpnPartition3
		neg.l	d5
		cmp.l	d5,d6
		blt.s	c3pmpnSkip
		bra.s	c3pmpnPartition3

c3pmpnSector1
		; p1 und p2 sind in sektor #1
		; nur dann beruecksichtigen, wenn mindestens ein punkt in partition #1
		cmp.l	d3,d4
		ble.s	c3pmpnPartition1
		cmp.l	d5,d6
		bgt.s	c3pmpnSkip

c3pmpnPartition1
		; linie ist sichtbar, jetzt eintragen
		move.l	(a2)+,(a4)+
		move.l	(a2)+,(a4)+
		move.l	(a2)+,(a4)+
		move.l	(a2)+,(a4)+
		add.b	d2,-1(a4)		; winkeloffset
		move.l	(a2)+,(a4)+
		addq.w	#1,d0
		bra.s	c3pmpnLineOk

c3pmpnSector2
		; p1 und p2 sind in sektor #2
		; nur dann beruecksichtigen, wenn mindestens ein punkt in partition #2
		neg.l	d4
		cmp.l	d3,d4
		ble.s	c3pmpnPartition2
		neg.l	d6
		cmp.l	d5,d6
		bgt.s	c3pmpnSkip

c3pmpnPartition2
		; p1 und p2 sind in partition #2
		move.l	(a2)+,(a5)+
		move.l	(a2)+,(a5)+
		move.l	(a2)+,(a5)+
		move.l	(a2)+,(a5)+
		add.b	d2,-1(a5)		; winkeloffset
		move.l	(a2)+,(a5)+
		addq.w	#1,d1
		bra.s	c3pmpnLineOk

c3pmpnPartition3
		; p1 und p2 sind in sektor #1/#2 bzw. umgekehrt
		move.l	(a2)+,d3
		move.l	d3,(a4)+
		move.l	d3,(a5)+
		move.l	(a2)+,d3
		move.l	d3,(a4)+
		move.l	d3,(a5)+
		move.l	(a2)+,d3
		move.l	d3,(a4)+
		move.l	d3,(a5)+
		move.l	(a2)+,d3
		add.b	d2,d3
		move.l	d3,(a4)+
		move.l	d3,(a5)+
		move.l	(a2)+,d3
		move.l	d3,(a4)+
		move.l	d3,(a5)+
		moveq.w	#1,d3
		add.w	d3,d0
		add.w	d3,d1
		bra.s	c3pmpnLineOk
c3pmpnSkip
		lea	20(a2),a2
c3pmpnLineOk
		dbra	d7,c3pmpnLoop
c3pmpnOut
		rts


; -------------------------------------------------------------------
; kollisionsroutine
c3pCollision
		clr.w	c3pErrorFlag
		clr.w	c3pRayCounter

		lea	c3pCurrent,a1
		lea	c3pCalcPts,a2
		lea	c3pTangensTabX,a3
		lea	c3pAngleTab,a4

		move.w	c3pWidth,d7
		lsr.w	#1,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
c3pcLoop1
		move.w	d7,-(sp)
		addq.w	#1,c3pRayCounter
		move.w	c3pNbCalcLines1,d0
		lea	c3pCalcLines1,a0
		bsr	c3pcNow
		bsr	c3pMakeRayEntry
		move.w	(sp)+,d7
		IFEQ C3PDEBUGONLY1RAY
		dbra	d7,c3pcLoop1
		ENDC

		move.w	(sp)+,d7		; schleifenzaehler

		IFNE C3PDEBUGONLY1RAY
		rts
		ENDC
c3pcLoop2
		move.w	d7,-(sp)
		addq.w	#1,c3pRayCounter
		move.w	c3pNbCalcLines2,d0
		lea	c3pCalcLines2,a0
		bsr	c3pcNow
		bsr	c3pMakeRayEntry
		move.w	(sp)+,d7
		dbra	d7,c3pcLoop2

		rts


; d0.w = c3pNbCalcLinesX
; a0 = c3pCalcLinesX
; a1 = c3pCurrent
; a2 = c3pCalcPts
; a3 = c3pTangensTabX
; a4 = c3pAngleTab

c3pcNow
		fmove.x	(a3)+,fp1			; tangens
		clr.w	c3pNbRayBuffer

		subq.w	#1,d0
		bmi	c3pcnOut

		move.l	#c3pRayBuffer,c3pRayBufferPtr

c3pcnLoop
		clr.w	c3pFlag			; flags fuer algorithmus loeschen
		clr.w	C3PCURRENTFLAGS(a1)	; flags fuer akt. linie loeschen

		lea	5*4(a0),a0		; c3pCalcLinesX schon auf naechste linie setzen

	; zuerst feststellen, welche seite der textur ueberhaupt getroffen
	; wird bzw. ob diese seite sichtbar ist oder nicht

		move.l	-5*4+3*4(a0),d4		; line_flag_2
		move.l	d4,d3			; in d4 weiterhin merken, mit d3 arbeiten
						; d3[7..0] = angle
		ext.w	d3
		move.b	(a4),d5			; angle
		ext.w	d5
		sub.w	d5,d3
		bpl.s	c3pcnAnglePos
		neg.w	d3
c3pcnAnglePos
		cmpi.w	#$40,d3
		ble.s	c3pcnHitFront
c3pcnHitBack
		bset	#C3PBACKSIDEFLAG,c3pFlag
		btst	#9,d4				; rueckseite sichtbar oder nicht?
		bne.s	c3pcnLineVisible
		bra	c3pcnSkip
c3pcnHitFront
		btst	#8,d4				; vorderseite sichtbar?
		bne.s	c3pcnLineVisible
		bra	c3pcnSkip

c3pcnLineVisible

	; d0 = dbra
	; fp1.x = tangens

	; die seite, die der strahl trifft, ist sichtbar

		move.w	-5*4+2(a0),d4		; koordinatenindex
		move.w	-5*4+1*4+2(a0),d6	; koordinatenindex
		move.l	(a2,d4.w),d3		; x1
		move.l	4(a2,d4.w),d4		; y1
		move.l	(a2,d6.w),d5		; x2
		move.l	4(a2,d6.w),d6		; y2

		cmp.l	d3,d5			; algorithmus beschraenkt auf nach rechts verlaufende linien
		bge.s	c3pcnNoChanging

	; punkte muessen vertauscht werden

		exg.l	d3,d5
		exg.l	d4,d6
		bset	#C3PEXGFLAG,c3pFlag
c3pcnNoChanging

	;         y1 * dx - x1 * dy
	;   xs = -------------------
	;           tan * dx - dy

		move.l	d5,a5		; x2 sichern
		move.l	d6,a6		; y2 sichern

		sub.l	d3,d5		; dx (ist also n. V. immer positiv)
		sub.l	d4,d6		; dy (kann sowohl positiv als auch negativ sein)

		fmove.l	d3,fp3		; x1
		fmove.l	d4,fp4		; y1
		fmove.l	d5,fp5		; dx

		fmul.x	fp5,fp4		; fp4 = dx * y1
		fmul.l	d6,fp3		; fp3 = dy * x1
		fsub.x	fp3,fp4		; fp4 = zaehler
		fmul.x	fp1,fp5		; fp5 = tan * dx
		fsub.l	d6,fp5		; fp5 = nenner
		fdiv.x	fp5,fp4		; fp4 = xs

		fmove.l	fp4,d7
 		fmove.x	fp4,C3PCURRENTDISTANCEX(a1)	; entfernung merken
		move.l	d7,C3PCURRENTDISTANCE(a1)
		cmpi.l	#8,d7
		blt	c3pcnSkip			; raus, wenn linie zu nah oder hinter spieler
;		bmi	c3pcnSkip
;		beq	c3pcnSkip

	; flache oder steile linie? dazu muessen dx und dy positiv sein (cmp.l)

		move.l	d6,d2		; dy (kann jetzt eben pos. oder neg. sein)
		bpl.s	c3pcnDyPos
		neg.l	d2
c3pcnDyPos	cmp.l	d5,d2		; dx ist immer positiv
		bge.s	c3pcnSteileLine

	; fp1 = tangens
	; fp4 = xs
	; d0 = dbra
	; d3 = x1
	; d4 = y1
	; d5 = dx
	; d6 = dy
	; d7 = xs
	; a0 = c3pCalcLinesX
	; a2 = c3pCalcPts
	; a3 = c3pTangensTabX
	; a4 = c3pAngleTab
	; a5 = x2
	; a6 = y2

c3pcnFlacheLine
		cmp.l	d3,d7		; x1 < xs (!)
		blt	c3pcnSkip
		move.l	a5,d2
		cmp.l	d2,d7		; xs < x2 (!)
		bgt	c3pcnSkip

		btst	#C3PEXGFLAG,c3pFlag
		beq.s	c3pcnflNoExg
c3pcnflExg
		move.l	d2,d1
		sub.l	d7,d1		; d1 = x2 - xs
		bra.s	c3pcnflExgOk
c3pcnflNoExg
		sub.l	d3,d7		; d1 = xs - x1
		move.l	d7,d1
c3pcnflExgOk

	; laenge der linie

		move.w	-5*4+4*4(a0),d2		; d2 = line_flag_3[31..16]
		IFEQ TILESDIMENSION-512
		add.w	d2,d2
		ENDC
		mulu.w	d1,d2			; d2 = d1 * laenge
		divu.w	d5,d2			; d2 = ( d1 * laenge ) / dx

		moveq	#0,d1
		move.b	-5*4+2*4(a0),d1		; and_maske
		IFEQ TILESDIMENSION-512
		add.w	d1,d1
		bset	#0,d1
		ENDC
		and.w	d1,d2			; d2 = xind
		move.w	d2,C3PCURRENTXIND(a1)
		bra.s	c3pcnLineOk


c3pcnSteileLine
		fmove.x	fp4,fp2		; fp2 = xs
		fmul.x	fp1,fp2		; fp1 = ys ( = tan * xs )
		fmove.l	fp2,d2		; d2 = ys

		move.l	a6,d7		; y2
		cmp.l	d7,d4
		bgt.s	c3pcnslLineDown		

c3pcnslLineUp

	; nach vor. ist y1 < y2

		cmp.l	d4,d2		; y1 < ys (!)
		blt	c3pcnSkip
		cmp.l	d7,d2		; ys < y2 (!)
		bgt	c3pcnSkip
		bra.s	c3pcnslLineOk

c3pcnslLineDown

	; nach vor. ist y2 < y1

		cmp.l	d4,d2		; y1 > ys (!)
		bgt	c3pcnSkip
		cmp.l	d7,d2		; ys > y2 (!)
		blt	c3pcnSkip

c3pcnslLineOk
		btst	#C3PEXGFLAG,c3pFlag
		beq.s	c3pcnslNoExg
c3pcnslExg
		move.l	d7,d1		; y2
		sub.l	d2,d1		; d1 = y2 - ys (pos. od. neg.)
		bra.s	c3pcnslExgOk
c3pcnslNoExg
		move.l	d2,d1		; ys
		sub.l	d4,d1		; d1 = ys - y1 (pos. od. neg.)
c3pcnslExgOk

	; laenge der linie

		move.w	-5*4+4*4(a0),d2		; d2 = line_flag_3[31..16]
		IFEQ TILESDIMENSION-512
		add.w	d2,d2
		ENDC
		muls.w	d1,d2
		divs.w	d6,d2

		moveq	#0,d1
		move.b	-5*4+2*4(a0),d1		; and_maske
		IFEQ TILESDIMENSION-512
		add.w	d1,d1
		bset	#0,d1
		ENDC
		and.w	d1,d2			; d2 = xind
		move.w	d2,C3PCURRENTXIND(a1)

c3pcnLineOk

	; fp1 = tangens
	; fp4 = xs
	; d0 = dbra
	; d2 = xind
	; d3 = x1
	; d4 = y1
	; d5 = dx
	; d6 = dy
	; a0 = c3pCalcLinesX
	; a2 = c3pCalcPts
	; a3 = c3pTangensTabX
	; a4 = c3pAngleTab
	; a5 = x2
	; a6 = y2

	; ---------------------------------------
	; calc_height
	; ---------------------------------------

		fmove.x	c3pPerspectiveValueX,fp2
		fdiv.x	fp4,fp2				; fp2 = pers / xs

	; fp2 entspricht der hoehe in pixeln, die fuer die volle hoehe
	; gezeichnet werden muesste

	; ---------------------------------------
	; calc_zoom
	; ---------------------------------------

		IFEQ TILESDIMENSION-256
		fmove.l	#C3PMAXHEIGHT*65536,fp3		; 65536 -> zoomfaktor in vor-/nachkomma unterteilt
		ELSE
		fmove.l	#C3PMAXHEIGHT*65536*2,fp3	; 65536*2 -> zoomfaktor in vor-/nachkomma unterteilt
		ENDC
		fdiv.x	fp2,fp3
		fmove.l	fp3,C3PCURRENTZOOM(a1)

	; ---------------------------------------
	; calc_xyoffset_ymask
	; ---------------------------------------

		move.w	-5*4+4*4+2(a0),C3PCURRENTXYOFFSET(a1)

		moveq	#0,d5
		move.b	-5*4(a0),d5			; ymask
		move.w	d5,C3PCURRENTYMASK(a1)		; ... und eintragen

	; ---------------------------------------
	; calc_h1_h2			
	; ---------------------------------------

		fmove.x	fp2,fp5			; cheight kopieren
		fdiv.w	#C3PMAXHEIGHT,fp5	; fp5 = cheight / C3PMAXHEIGHT  (wird mehrmals benoetigt)
		fmove.x	fp5,fp3
		fmul.w	c3pSH,fp3		; fp3 = cheight * ( sh / C3PMAXHEIGHT )
		lea	c3p,a5		
		move.w	C3PHEIGHTHALF(a5),d6
		ext.l	d6
		fmove.l	fp3,d7
		sub.l	d7,d6			; d6 ist die bildschirmhoehe fuer sh=0

		fmove.x	fp5,fp3
		fmul.w	-5*4+2*4+2(a0),fp3	; fp3 = cheight * ( h1 / C3PMAXHEIGHT )
		fmove.l	fp3,d5
		moveq	#0,d7
		add.l	d6,d5
		bpl.s	c3pcnH1Ok
		move.w	d5,d7			; yind vorbereiten
		neg.w	d7			; muss positiv natuerlich sein
		moveq	#0,d5			; neue hoehe h1 -> auf null setzen
		bra.s	c3pcnH1Set		; koennen naechsten vergleich ueberspringen
c3pcnH1Ok	cmp.l	C3PHEIGHTFORDBRALONG(a5),d5
		bgt	c3pcnSkip
c3pcnH1Set	move.w	d7,C3PCURRENTYIND(a1)
		move.w	d5,C3PCURRENTH1(a1)
		move.w	d5,C3PCURRENTH1ORIGINAL(a1)

		fmove.x	fp5,fp3
		move.w	-5*4+3*4(a0),d5			; h2
		addq.w	#1,d5
		fmul.w	d5,fp3				; fp3 = cheight * ( h2 / C3PMAXHEIGHT )
		fmove.l	fp3,d5
		add.l	d6,d5
		subq.l	#1,d5
		bmi	c3pcnSkip			; wenn h2 negativ, dann auch h1 und die linie ist somit nicht sichtbar
		cmp.w	C3PHEIGHT(a5),d5		; h2 > height ?
		blt.s	c3pcnH2Ok			; nein, dann weiter
		move.w	C3PHEIGHTFORDBRA(a5),d5		; ansonsten fuer h2 maximalen wert setzen
c3pcnH2Ok	move.w	d5,C3PCURRENTH2(a1)
		move.w	d5,C3PCURRENTH2ORIGINAL(a1)

	; ---------------------------------------
	; calc_text
	; ---------------------------------------

		btst	#C3PBACKSIDEFLAG,c3pFlag
		beq.s	c3pcnTextFrontside

	; ---------------------------------------
	; rueckseite der textur ist getroffen worden

		clr.w	d5
		move.b	-5*4+2*4+1(a0),d5		; line_flag_1[23..16]
		lsr.w	#4,d5
		move.w	d5,C3PCURRENTTEXT(a1)		; texturnummer oder farbindex

		move.w	-5*4+3*4+2(a0),d1		; [15..0] von line_flag_2
		btst	#13,d1				; rueckseite texturiert wie vorderseite?
		bne.s	c3pcnTextFrontside		; ja -> dann wie vorderseite behandeln (wird spiegelverkehrt)

	; normalfall fuer rueckseite - es kann nur boden oder decke sein

		clr.w	C3PCURRENTYMASK(a1)		; boden oder decke kann nicht in y-richtung maskiert sein

		btst	#10,d1				; #10 von line_flag_2
		beq.s	c3pcnbsNoFloor

	; die rueckseite wird zu boden...

		bset	#C3PFLOORFLAG,C3PCURRENTFLAGS(a1)
		clr.w	C3PCURRENTH1(a1)		; boden beginnt bei 0
		bsr	c3pMakeEntry			; eintragen
		bra	c3pcnSkip			; und raus...
c3pcnbsNoFloor

		btst	#11,d1				; #11 von line_flag_2
		beq	c3pcnSkip

	; die rueckseite wird zu decke...

		move.w	C3PHEIGHTFORDBRA(a5),C3PCURRENTH2(a1)	; decke endet oben
		bset	#C3PFLOORFLAG,C3PCURRENTFLAGS(a1)
		bsr	c3pMakeEntry
		bra	c3pcnSkip				; und raus...
		
	; ---------------------------------------

c3pcnTextFrontside

	; ---------------------------------------
	; vorderseite der textur ist getroffen worden

		move.w	-5*4+2*4(a0),d5		; line_flag_1[31..16]
		andi.w	#$000f,d5		; brauchen nur bits 19..16
		move.w	d5,C3PCURRENTTEXT(a1)	; texturnummer

	; die textur ist also von der vorderseite getroffen, der texturindex ist erstellt

	; muss die textur maskiert werden, so das entsprechende flag setzen,
	; ebenso mit dem attribut lightshading			

		move.w	-5*4+3*4+2(a0),d1		; [15..0] von line_flag_2
		btst	#14,d1
		beq.s	c3pcnNotMasked
		bset	#C3PMASKEDFLAG,C3PCURRENTFLAGS(a1)
c3pcnNotMasked
		btst	#15,d1
		beq.s	c3pcnNoLight
		bset	#C3PLIGHTFLAG,C3PCURRENTFLAGS(a1)
c3pcnNoLight
		btst	#0,-5*4+1*4(a0)			; point_2, bit 24
		beq.s	c3pcnNoTransparence
		bset	#C3PTRANSPARENCEFLAG,C3PCURRENTFLAGS(a1)
c3pcnNoTransparence

	; diese textur jetzt eintragen...

		bsr	c3pMakeEntry

		clr.w	C3PCURRENTYMASK(a1)	; boden oder/und decke/himmel koennen nicht gekachelt werden

	; ist unterhalb der textur boden, dann diesen ebenfalls eintragen...

		btst	#10,d1			; bit #10 von line_flag_2
		beq.s	c3pcnNoFloor

		move.w	C3PCURRENTH1ORIGINAL(a1),d2
		subq.w	#1,d2
		bmi.s	c3pcnNoFloor

		clr.w	C3PCURRENTH1(a1)
		move.w	d2,C3PCURRENTH2(a1)
		moveq	#0,d2
		move.b	-5*4+1(a0),d2
		move.w	d2,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)		; nur flag fuer boden setzen, alle anderen loeschen
		bsr	c3pMakeEntry
c3pcnNoFloor

	; ist oberhalb der textur decke, dann diese ebenfalls eintragen...

		btst	#11,d1			; bit #11 von line_flag_2
		beq	c3pcnNoCeiling

		lea	c3p,a5
		move.w	C3PCURRENTH2ORIGINAL(a1),d2
		addq.w	#1,d2
		move.w	C3PHEIGHTFORDBRA(a5),d3
		cmp.w	d3,d2
		bgt.s	c3pcnNoCeiling
		move.w	d2,C3PCURRENTH1(a1)
		move.w	d3,C3PCURRENTH2(a1)

		btst	#12,d1
		beq.s	c3pcnOnlyCeiling

		move.w	C3PSKYTEXT(a5),C3PCURRENTTEXT(a1)
		move.l	C3PSKYZOOM(a5),C3PCURRENTZOOM(a1)
		move.w	C3PSKYXYOFFSET(a5),C3PCURRENTXYOFFSET(a1)
		sub.w	C3PHEIGHTHALF(a5),d2
		move.w	d2,C3PCURRENTYIND(a1)

		move.w	skyMoveCounter,d2
		add.w	C3PRAYCOUNTER(a5),d2
		movea.l	playerDataPtr,a6
		sub.w	PDALPHA(a6),d2
		fmove.w	d2,fp0
		fmul.x	C3PSKYZOOMX(a5),fp0
		fmove.w	fp0,d2
		and.w	C3PSKYMASK(a5),d2
		move.w	d2,C3PCURRENTXIND(a1)

		clr.w	C3PCURRENTFLAGS(a1)			; alle flags loeschen, v. a. nicht maskiert und abgedunkelt
		bsr	c3pMakeEntry
		bra.s	c3pcnNoCeiling

c3pcnOnlyCeiling
		moveq	#0,d2
		move.b	-5*4+1*4+1(a0),d2
		move.w	d2,C3PCURRENTTEXT(a1)
		move.b	#%00000001,C3PCURRENTFLAGS(a1)		; nur flag fuer boden setzen, alle anderen loeschen
		bsr	c3pMakeEntry
c3pcnNoCeiling

c3pcnSkip
		dbra	d0,c3pcnLoop

c3pcnOut
		addq.l	#1,a4			; angle
                    
		rts


; ---------------------------------------------------------
; linien in strahlbuffer eintragen
c3pMakeEntry

	; belegte register
	; fp1 = tangens
	; fp4 = xs (entfernung)
	; d0 = dbra
	; d1 = line_flag_2[15..0]
	; a0 = c3pCalcLinesX
	; a1 = c3pCurrent
	; a2 = c3pCalcPts
	; a3 = c3pTangensTabX
	; a4 = c3pAngleTab

		move.l	a4,-(sp)		; register retten, kann dadurch benutzt werden (stack)
		movea.l	c3pRayBufferPtr,a6	; in a6 kommen neue linien hinzu

	; (1) linie erstmalig eintragen, wird dabei ggf. gekuerzt

		lea	c3pmenStack,a4		; stack initialisieren (auf anfang setzen)
		clr.w	c3pmenNbStackLines
		bsr	c3pmeNow		; die neue linie in einem ersten schritt eintragen (wird ggf. gekuerzt)

	; (2) aufgebauten stack abarbeiten

c3pmeStackLoop
		subq.w	#1,c3pmenNbStackLines	; ist eine linie im stack eingetragen?
		bmi.s	c3pmeStackOk		; nein -> dann raus

		lea	-C3PMENSTACKBYTES(a4),a4		; a4 auf letzten eintrag setzen

		move.w	C3PMENSTACKH1(a4),C3PCURRENTH1(a1)	; ... und werte auslesen
		move.w	C3PMENSTACKH2(a4),C3PCURRENTH2(a1)
		move.w	C3PMENSTACKYIND(a4),C3PCURRENTYIND(a1)
		bsr	c3pmeNow				; linie eintragen, stack kann sich ggf. weiter erhoehen
		bra.s	c3pmeStackLoop
c3pmeStackOk

		move.l	a6,c3pRayBufferPtr	; pointer zurueckschreiben
		move.l	(sp)+,a4

		rts


c3pmeNow
		lea	c3pRayBuffer,a5		; zeiger auf eingetragene linien (raybuffer)
		move.w	C3PCURRENTH1(a1),d5
		move.w	C3PCURRENTH2(a1),d6
		move.w	c3pNbRayBuffer,d7	; wieviel linien sind schon fuer den strahl eingetragen?
		beq	c3pmenInsertNow		; keine -> dann neue linie einfach eintragen

		subq.w	#1,d7			; fuer dbra (anzahl bereits eingetragener linien)

c3pmenLoop

	; d5 = C3PCURRENTH1(a1)    -> beachten!
	; d6 = C3PCURRENTH2(a1)

		move.w	C3PRBH1(a5),d3
		bmi	c3pmenSkip		; eingetragene textur ist nicht gueltig -> ueberspringen
		move.w	C3PRBH2(a5),d4
		cmp.w	d3,d6			; neue oberkante tiefer als eingetragene unterkante?
		blt	c3pmenSkip		; keine ueberschneidung mit bereits eingetragener -> ueberspringen
		cmp.w	d4,d5			; neue unterkante hoeher als eingetragene oberkante?
		bgt	c3pmenSkip		; keine ueberschneidung mit bereits eingetragener -> ueberspringen

		fcmp.x	C3PRBDISTANCEX(a5),fp4
		fbogt	c3pmenBack				; neue entfernung weiter weg als eingetragene -> neue dahinter eintragen
		fbolt	c3pmenFront				; neue entfernung naeher dran als eingetragene -> neue davor eintragen
c3pmenSameDist	btst	#C3PFLOORFLAG,C3PCURRENTFLAGS(a1)	; entfernung gleich. ist neue linie boden?
		bne	c3pmenBack				; ja -> dann neuen boden dahinter eintragen

c3pmenFront
		btst	#C3PMASKEDFLAG,C3PCURRENTFLAGS(a1)	; wenn neue linie maskiert werden muss
		bne	c3pmenSkip				; dann die dahinter immer zeichnen -> skip

		btst	#C3PFLOORFLAG,C3PRBFLAGS(a5)		; ist eingetragene linie boden?
		bne	c3pmenfAnyInFrontOfFloor		; ja -> routine fuer "irgendwas" vor "boden"


;  |  |   |
; || ||  ||  |  ||  |  || || |     d6 d4
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d5 d3
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5			; neue unterkante niedriger/gleich als eingetrage unterkante?
		bls.s	c3pmenfC14		; ja -> fall 1 oder 4
c3pmenfC23
		cmp.w	d4,d6			; neue oberkante hoeher/gleich als eingetragene oberkante?
		bge.s	c3pmenfC3		; ja -> fall 3
c3pmenfC2
		move.w	d6,d2			; hintere textur teilen
		addq.w	#1,d2			; oberkante neue/vordere textur + 1
		move.w	d2,(a6)+		; h1
		move.l	C3PRBH2(a5),(a6)+	; h2 und xind
		move.l	C3PRBYIND(a5),(a6)+	; yind und zoom[hi]
		sub.w	d3,d2
		add.w	d2,-4(a6)		; yind noch abaendern
		move.l	C3PRBZOOM+2(a5),(a6)+	; zoom[low] und text
		move.l	C3PRBDISTANCEX(a5),(a6)+
		move.l	C3PRBDISTANCEX+4(a5),(a6)+
		move.l	C3PRBDISTANCEX+8(a5),(a6)+
		move.l	C3PRBXYOFFSET(a5),(a6)+	; xyoffset und flags
		move.w	C3PRBYMASK(a5),(a6)+	; ymask
		move.w	d5,d2			; unteren teil der hinteren
		subq.w	#1,d2			; textur noch oben abschneiden (h2)
		move.w	d2,C3PRBH2(a5)
		addq.w	#1,c3pNbRayBuffer		
		bra	c3pmenSkip		; current kann so bleiben (voll sichtbar)
c3pmenfC3
		move.w	d5,d2
		subq.w	#1,d2
		move.w	d2,C3PRBH2(a5)		; hintere textur nur in der hoehe beschraenken
		bra	c3pmenSkip

c3pmenfC14
		cmp.w	d4,d6
		bge.s	c3pmenfC4
c3pmenfC1
		move.w	d6,d2			; currentH2
		addq.w	#1,d2
		move.w	d2,C3PRBH1(a5)
		sub.w	d3,d2
		add.w	d2,C3PRBYIND(a5)
		bra	c3pmenSkip
c3pmenfC4
		move.w	#-1,C3PRBH1(a5)		; hintere textur nicht mehr sichtbar
		bra	c3pmenSkip


c3pmenfAnyInFrontOfFloor

;  |  |   |
; || ||  ||  |  ||  |  || || |     d6 d4
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d5 d3
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5
		bls.s	c3pmenfafC14
c3pmenfafC23
		cmp.w	d4,d6
		bge.s	c3pmenfafC3
c3pmenfafC2
		move.w	d6,d2			; hintere textur teilen
		addq.w	#1,d2
		move.w	d2,(a6)+		; h1
		move.l	C3PRBH2(a5),(a6)+	; h2 und xind
		move.l	C3PRBYIND(a5),(a6)+	; yind und zoom[hi]
		move.l	C3PRBZOOM+2(a5),(a6)+	; zoom[low] und text
		move.l	C3PRBDISTANCEX(a5),(a6)+
		move.l	C3PRBDISTANCEX+4(a5),(a6)+
		move.l	C3PRBDISTANCEX+8(a5),(a6)+
		move.l	C3PRBXYOFFSET(a5),(a6)+	; xyoffset und flags
		move.w	C3PRBYMASK(a5),(a6)+	; ymask
		move.w	d5,d2			; unteren teil der hinteren
		subq.w	#1,d2			; textur noch oben abschneiden (h2)
		move.w	d2,C3PRBH2(a5)
		addq.w	#1,c3pNbRayBuffer		
		bra	c3pmenSkip		; current kann so bleiben (voll sichtbar)
c3pmenfafC3
		move.w	d5,d2
		subq.w	#1,d2
		move.w	d2,C3PRBH2(a5)		; hintere textur nur in der hoehe beschraenken
		bra	c3pmenSkip

c3pmenfafC14
		cmp.w	d4,d6
		bge.s	c3pmenfafC4
c3pmenfafC1
		move.w	d6,d2			; currentH2
		addq.w	#1,d2
		move.w	d2,C3PRBH1(a5)
		bra	c3pmenSkip
c3pmenfafC4
		move.w	#-1,C3PRBH1(a5)		; hintere textur nicht mehr sichtbar
		bra	c3pmenSkip



c3pmenBack
		btst	#C3PMASKEDFLAG,C3PRBFLAGS(a5)	; wenn bish. linie maskiert werden muss
		bne	c3pmenSkip			; dann diese ignorieren -> skip

		btst	#C3PFLOORFLAG,C3PCURRENTFLAGS(a1)
		bne.s	c3pmenbFloorBehindAny

;  |  |   |
; || ||  ||  |  ||  |  || || |     d4 d6
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d3 d5
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5
		bge.s	c3pmenbC14
c3pmenbC23
		cmp.w	d4,d6
		bls.s	c3pmenbC3
c3pmenbC2
		move.w	d4,d2			; hintere textur teilen und in stack eintragen
		addq.w	#1,d2
		move.w	d2,(a4)+		; h1
		move.w	d6,(a4)+		; h2
		move.w	C3PCURRENTYIND(a1),(a4)	; yind
		sub.w	d5,d2
		add.w	d2,(a4)+		; und yind noch korrigieren
		addq.w	#1,c3pmenNbStackLines

		move.w	d3,d6
		subq.w	#1,d6			; textur noch oben abschneiden (h2)
		bra	c3pmenSkip
c3pmenbC3
		move.w	d3,d6
		subq.w	#1,d6
		bra	c3pmenSkip

c3pmenbC14
		cmp.w	d4,d6
		ble	c3pmenOut		; current nicht sichtbar -> raus
c3pmenbC1
		move.w	d7,-(sp)
		move.w	d5,d7			; c3pcurrenth1 zwischenspeichern
		move.w	d4,d5			; rbH2
		addq.w	#1,d5			; neues c3pcurrenth1
		move.w	d5,d2
		sub.w	d7,d2
		add.w	d2,C3PCURRENTYIND(a1)
		move.w	(sp)+,d7
		bra.s	c3pmenSkip


c3pmenbFloorBehindAny

;  |  |   |
; || ||  ||  |  ||  |  || || |     d4 d6
; || ||  ||  || ||  || || || ||     | | 
; || ||  ||  || ||  |  || |  ||    d3 d5
; |       |   |  |
;
; 1a 1b   2  3a 3b  4a 4b 4c 4d

		cmp.w	d3,d5
		bge.s	c3pmenbfaC14
c3pmenbfaC23
		cmp.w	d4,d6
		bls.s	c3pmenbfaC3
c3pmenbfaC2
		move.w	d4,d2			; hintere textur teilen und in stack eintragen
		addq.w	#1,d2
		move.w	d2,(a4)+		; h1
		move.w	d6,(a4)+		; h2
		move.w	C3PCURRENTYIND(a1),(a4)	; yind
		sub.w	d5,d2
		add.w	d2,(a4)+		; und yind noch korrigieren
		addq.w	#1,c3pmenNbStackLines

		move.w	d3,d6
		subq.w	#1,d6			; textur noch oben abschneiden (h2)
		move.w	d6,C3PCURRENTH2(a1)
		bra	c3pmenSkip		; current kann so bleiben (voll sichtbar)
c3pmenbfaC3
		move.w	d3,d6
		subq.w	#1,d6
		move.w	d6,C3PCURRENTH2(a1)	; hintere textur nur in der hoehe beschraenken
		bra	c3pmenSkip

c3pmenbfaC14
		cmp.w	d4,d6
		ble.s	c3pmenOut		; current nicht sichtbar -> raus
c3pmenbfaC1
		move.w	d4,d5			; rbH2
		addq.w	#1,d5
		bra	c3pmenSkip


c3pmenSkip
		lea	C3PRAYBUFFERBYTES(a5),a5
		dbra	d7,c3pmenLoop		

c3pmenInsertNow
		move.w	d5,(a6)+			; c3pcurrenth1
		move.w	d6,(a6)+			; c3pcurrenth2
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

		addq.w	#1,c3pNbRayBuffer		

c3pmenOut
		rts



; ---------------------------------------------------------
; 09.07.00/vk
; aktuellen strahl in bildpuffer uebernehmen, dabei
; anpassungen vornehmen und vorberechnungen zum spaeteren
; zeichnen durchfuehren.
c3pMakeRayEntry

	; belegte, nicht verfuegbare register
	; a1 = c3pCurrent
	; a2 = c3pCalcPts
	; a3 = c3pTangensTabX
	; a4 = c3pAngleTab

		movem.l	a1-a4,-(sp)

		movea.l	c3pPictureTextPtr,a0
		movea.l	c3pPictureFloorPtr,a1
		movea.l	c3pPictureMaskedPtr,a5

		lea	tilesGfxPtrArray,a2		; array mit anfangsadressen der texturkacheln
		lea	c3pmreLightAddresses,a3		; fertig multiplizierte offsets
		lea	c3pRayBuffer,a6			; diese linien eintragen

		move.w	c3pNbRayBuffer,d7
		beq	c3pmreWriteEnd

		subq.w	#1,d7

		move.w	lineoffset,d5
		move.w	c3pHeightForDbra,d6

	; d5 = lineoffset
	; d6 = c3pHeightForDbra
	; d7 = dbra

c3pmreLoop
		move.w	C3PRBH1(a6),d0		; h1
		bmi	c3pmreSkip		; negativ -> linie unsichtbar (geloescht)

		move.w	C3PRBH2(a6),d1		; h2
		sub.w	d0,d1
		bmi	c3pmreSkip		; todo -> sicherheitsverzweig kann man weglassen

		btst	#C3PFLOORFLAG,C3PRBFLAGS(a6)
		bne	c3pmreFloor
		btst	#C3PMASKEDFLAG,C3PRBFLAGS(a6)
		bne	c3pmreMasked

		move.w	C3PRBYMASK(a6),d3	; muss textur in y-richtung gekachelt werden?
		bne	c3pmreYMask		; ja -> eigene angepasste routine

c3pmreStandardTile
		move.w	d1,C3PTEXTDBRA(a0)	; anzahl zu zeichnender pixel (fuer dbra)

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1			; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PTEXTYOFFSET(a0)

		moveq	#0,d0
		moveq	#0,d1
		move.w	C3PRBXYOFFSET(a6),d0

		move.w	C3PRBXIND(a6),d1	; tilesdimension=256 -> bereich [0..255], =512 -> bereich [0..511]
		lsl.w	#8,d1
		IFEQ TILESDIMENSION-512
		move.l	d0,d2
		clr.b	d2
		add.l	d2,d0
		add.l	d0,d0
		add.l	d1,d1
		ENDC
		add.l	d1,d0
		add.l	d0,d0
		move.w	C3PRBTEXT(a6),d2
		andi.w	#$000f,d2			; todo
		add.l	(a2,d2.w*4),d0
		move.l	d0,C3PTEXTGFXPTR(a0)

		move.l	C3PRBZOOM(a6),d0
		move.l	d0,C3PTEXTZOOM(a0)
		fmove.l	d0,fp0
		fmul.w	C3PRBYIND(a6),fp0
		fmove.l	fp0,C3PTEXTZOOMOFFSET(a0)

		btst	#C3PLIGHTFLAG,C3PRBFLAGS(a6)
		beq.s	c3pmreNoLight
		fmove.x	C3PRBDISTANCEX(a6),fp0
		fmove.l	fp0,d0
		moveq	#10,d1
		lsr.l	d1,d0
		cmpi.l	#8,d0
		blt.s	c3pmreDistOk
		moveq	#7,d0
c3pmreDistOk	move.l	(a3,d0.w*4),C3PTEXTLIGHTOFFSET(a0)
		bra.s	c3pmreLightOk
c3pmreNoLight	clr.l	C3PTEXTLIGHTOFFSET(a0)

c3pmreLightOk
		lea	C3PTEXTBYTES(a0),a0
		bra	c3pmreSkip


c3pmreYMask
		lea	c3pmreymBuffer,a4	; zwischenspeicher fuer h1/height/yind

		addq.w	#1,d3			; ymask (war mit -1 im datenformat gespeichert)
		fmove.w	d3,fp0			; fp0 = kachelgroesse (gesamtpixel)
		fdiv.l	C3PRBZOOM(a6),fp0	; fp0 = groesse einer kachel in bildschirmkoordinaten ( / 65536 )
		fmul.l	#65536,fp0		; jetzt ohne verzerrenden faktor
		fmove.w	fp0,d4			; d4.w = groesse einer kachel in bildschirmkoordinaten

		move.w	C3PRBYIND(a6),d2
c3pmreymYLoop	sub.w	d4,d2
		bpl.s	c3pmreymYLoop
		add.w	d4,d2			; d2 entspricht yind im bereich 0..ymask

		move.w	d4,d3			; kachelgroesse in bildschirmkoordinaten retten
		sub.w	d2,d4			; von der ersten kachel sind noch d4 pixel zu zeichnen
		sub.w	d4,d1			; pixel von der gesamthoehe abziehen
		subq.w	#1,d1
		bmi	c3pmrePreStandardTile	; weniger zu zeichnen als jetzt berechnet -> standardroutine
		beq	c3pmrePreStandardTile	; gleichviel -> ebenso die standardroutine verwenden

	; es sind also jetzt mindestens zwei kachelteile zu zeichnen

		move.w	d0,(a4)+		; h1
		move.w	d4,(a4)+		; height
		move.w	d2,(a4)+		; yind

		add.w	d4,d0
		addq.w	#1,d0

		move.w	d3,d2			; d3 = kachelgroesse
		subq.w	#1,d2			; d2 = kachelgroesse - 1 (fuer dbra)
c3pmreymCalcLoop
		move.w	d0,(a4)+		; h1
		sub.w	d3,d1			; pixel von verbleibender gesamthoehe abziehen
		bmi.s	c3pmreymCalcEnd
		beq.s	c3pmreymCalcEnd
		move.w	d2,(a4)+		; height
		clr.w	(a4)+			; yind
		add.w	d3,d0
		bra.s	c3pmreymCalcLoop

c3pmreymCalcEnd
		add.w	d1,d3
		move.w	d3,(a4)+		; height
		clr.w	(a4)+			; yind

		move.w	#-1,(a4)+

	; bevor die kacheln nun erzeugt werden, bestimmte konstanten (z. b. texturoffset)
	; vorberechnen

		moveq	#0,d1
		moveq	#0,d2
		move.w	C3PRBXYOFFSET(a6),d2
		move.w	C3PRBXIND(a6),d1
		lsl.w	#8,d1
		add.l	d1,d2
		add.l	d2,d2
		move.w	C3PRBTEXT(a6),d1
		add.l	(a2,d1.w*4),d2		; c3ptextgfxoffset

		move.l	C3PRBZOOM(a6),d3	; c3ptextzoom
		fmove.l	d3,fp0			; vorbereiten fuer fpu-multiplikation

		btst	#C3PLIGHTFLAG,C3PRBFLAGS(a6)
		beq.s	c3pmreymNoLight
		fmove.x	C3PRBDISTANCEX(a6),fp0
		fmove.l	fp0,d0
		moveq	#10,d1
		lsr.l	d1,d0
		cmpi.l	#8,d0
		blt.s	c3pmreymDistOk
		moveq	#7,d0
c3pmreymDistOk	move.l	(a3,d0.w*4),d4		; c3ptextlightoffset
		bra.s	c3pmreymLightOk
c3pmreymNoLight	moveq	#0,d4
c3pmreymLightOk

		lea	c3pmreymBuffer,a4
c3pmreymBufferLoop
		move.w	(a4)+,d0		; h1
		bmi	c3pmreSkip		; alle bearbeitet -> beenden (ende schreiben)
		move.w	(a4)+,C3PTEXTDBRA(a0)

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1			; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PTEXTYOFFSET(a0)

		move.l	d2,C3PTEXTGFXPTR(a0)

		move.l	d3,C3PTEXTZOOM(a0)
		fmove.x	fp0,fp1
		fmul.w	(a4)+,fp1
		fmove.l	fp1,C3PTEXTZOOMOFFSET(a0)

		move.l	d4,C3PTEXTLIGHTOFFSET(a0)

		lea	C3PTEXTBYTES(a0),a0
		bra	c3pmreymBufferLoop

c3pmrePreStandardTile
		add.w	d4,d1
		addq.w	#1,d1
		move.w	d2,C3PRBYIND(a6)
		bra	c3pmreStandardTile


c3pmreFloor
		move.w	d1,C3PFLOORDBRA(a1)		

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1			; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PFLOORYOFFSET(a1)
		move.w	C3PRBTEXT(a6),C3PFLOORCOLORINDEX(a1)

		lea	C3PFLOORBYTES(a1),a1

		bra.s	c3pmreSkip


c3pmreMasked
		move.w	d1,C3PMASKEDDBRA(a5)		; anzahl zu zeichnender pixel (fuer dbra)

		move.w	d6,d1
		sub.w	d0,d1
		mulu	d5,d1				; todo -> mulu durch tabellenzugriff ersetzen
		move.l	d1,C3PMASKEDYOFFSET(a5)

		moveq	#0,d0
		moveq	#0,d1
		move.w	C3PRBXYOFFSET(a6),d0
		move.w	C3PRBXIND(a6),d1
		lsl.w	#8,d1

		IFEQ TILESDIMENSION-512
		move.l	d0,d2
		clr.b	d2
		add.l	d2,d0
		add.l	d0,d0
		add.l	d1,d1
		ENDC

		add.l	d1,d0
		add.l	d0,d0
		move.w	C3PRBTEXT(a6),d2
		add.l	(a2,d2.w*4),d0
		move.l	d0,C3PMASKEDGFXPTR(a5)

		move.l	C3PRBZOOM(a6),d0
		move.l	d0,C3PMASKEDZOOM(a5)
		fmove.l	d0,fp0
		fmul.w	C3PRBYIND(a6),fp0
		fmove.l	fp0,C3PMASKEDZOOMOFFSET(a5)

		btst	#C3PLIGHTFLAG,C3PRBFLAGS(a6)
		beq.s	c3pmremNoLight
		fmove.x	C3PRBDISTANCEX(a6),fp0
		fmove.l	fp0,d0
		moveq	#10,d1
		lsr.l	d1,d0
		cmpi.l	#8,d0
		blt.s	c3pmremDistOk
		moveq	#7,d0
c3pmremDistOk	move.l	(a3,d0.w*4),C3PMASKEDLIGHTOFFSET(a5)
		bra.s	c3pmremLightOk
c3pmremNoLight	clr.l	C3PMASKEDLIGHTOFFSET(a5)

c3pmremLightOk
		lea	C3PMASKEDBYTES(a5),a5


c3pmreSkip
		lea	C3PRAYBUFFERBYTES(a6),a6
		dbra	d7,c3pmreLoop

c3pmreWriteEnd
		moveq	#-1,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.w	d0,(a5)+

		move.l	a0,c3pPictureTextPtr
		move.l	a1,c3pPictureFloorPtr
		move.l	a5,c3pPictureMaskedPtr

		movem.l	(sp)+,a1-a4

		rts




; ---------------------------------------------------------
; 3d engine initialisieren
; fenstergroesse wird auf aktuelle aufloesung gestellt
; (evtl. wird noch platz fuer die console gelassen)
init3dEngine
		lea	fileIO,a6
		move.l	#fileSinus512XTab,FILENAME(a6)
		move.l	#sinus512TabX,FILEBUFFER(a6)
		move.l	#8192,FILEBYTES(a6)
		bsr	loadFile

		lea	fileIO,a6
		move.l	#fileAlpha1024BTab,FILENAME(a6)
		move.l	#c3pAngleTabFull,FILEBUFFER(a6)
		move.l	#C3PMAXX,FILEBYTES(a6)
		bsr	loadFile

		move.l	#fileTangens1024XTab,FILENAME(a6)
		move.l	#c3pTangensTabXFull,FILEBUFFER(a6)
		move.l	#C3PMAXX*12,FILEBYTES(a6)
		bsr	loadFile


		move.w	width,d0
		move.w	height,d1
		bsr	reset3dEngine

		rts


; ---------------------------------------------------------
; 3d engine zuruecksetzen (teil von init3dEngine)
; d0 = 3d fensterbreite
; d1 = 3d fensterhoehe
reset3dEngine
		move.w	doubleScan,d5
		move.w	#40,d7
		lsr.w	d5,d7
		move.w	d7,c3pWidthMin
		move.w	#30,c3pHeightMin

		move.w	width,d6
		lsr.w	d5,d6
		move.w	d6,c3pWidthMax			; maximale fenstergroesse bei aktueller hardwareaufloesung
		move.w	height,d7
		move.w	d7,c3pHeightMax			; setzen. bei der maximalen hoehe

		cmp.w	d6,d0				; mit maximaler breite vergleichen
		blt.s	r3eWidthOk
		move.w	d6,d0
r3eWidthOk	cmp.w	d7,d1
		blt.s	r3eHeightOk
		move.w	d7,d1
r3eHeightOk

		move.w	d0,c3pWidth			; 3d fenstergroesse wie
		move.w	d1,c3pHeight			; uebergeben jetzt setzen
		move.w	d1,d2
		lsr.w	#1,d2
		move.w	d2,c3pHeightHalf		; werte fuer
		subq.w	#1,d1				; schnellen zugriff
		move.w	d1,c3pHeightForDbra		; vorberechnen

	; -------------------------------------------------
	; perspektivenkonstante

		move.l	#144000000/2,d7
		lsl.l	d5,d7				; bei doubleScan verdoppeln
		fmove.l	d7,fp0
		fdiv.w	#1024,fp0
		fmul.w	c3pWidth,fp0
		fmove.l	fp0,c3pPerspectiveValue
		fmove.x	fp0,c3pPerspectiveValueX

		fmove.l	#C3PMAXHEIGHT*65536,fp1		; diese konstante wird nur fuer a2 benoetigt
		fdiv.x	fp0,fp1
		fmove.x	fp1,c3pa2ZoomMultiplicator

	; -------------------------------------------------
	; skalieren auf tatsaechliche 3d-fenster-groesse

		move.w	c3pWidth,d7
		subq.w	#1,d7
		fmove.w	d7,fp7
		moveq	#0,d6
		lea	c3pAngleTabFull,a0
		lea	c3pAngleTab,a1
		lea	c3pTangensTabXFull,a2
		lea	c3pTangensTabX,a3
r3eScaleLoop

	; z. B.  v = 1023 * ( d6[0..319] / fp7[319] ) 

		fmove.w	#1023,fp0
		fmul.w	d6,fp0
		fdiv.x	fp7,fp0
		fmove.w	fp0,d0			; d0 = v

		move.b	(a0,d0.w),(a1)+		; angle

		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d1
		add.w	d1,d1
		add.w	d1,d1
		fmove.x	(a2,d1.w),fp0
		fmove.x	fp0,(a3)+		; tangens
		
		addq.w	#1,d6

		dbra	d7,r3eScaleLoop

	; -------------------------------------------------
	; sky parameter festlegen

		movea.l	levelPtr,a6
		movea.l	LEVINITDATA(a6),a0
		adda.l	a6,a0

		lea	c3p,a1
		move.w	INITSKYTEXTNB+2(a0),C3PSKYTEXT(a1)
		move.w	INITSKYXYOFFSET+2(a0),C3PSKYXYOFFSET(a1)
		move.w	INITSKYMASK+2(a0),d5
		IFEQ TILESDIMENSION-512
		add.w	d5,d5
		bset	#0,d5
		ENDC
		move.w	d5,C3PSKYMASK(a1)

		fmove.l	#100*65536,fp0
		fdiv.w	C3PHEIGHTHALF(a1),fp0
		fmove.l	fp0,C3PSKYZOOM(a1)
		move.w	doubleScan,d5
		move.l	#65536,d6
		lsr.l	d5,d6
		fdiv.l	d6,fp0
		fmove.x	fp0,C3PSKYZOOMX(a1)

	; -------------------------------------------------
	; lineoffset multiplizieren

		move.w	lineoffset,d0
		moveq	#0,d6
		lea	lineoffsetMulus,a0
		move.w	#C3PMAXY-1,d7
r3eLoffsetLoop	move.w	d0,d1
		mulu	d6,d1
		move.l	d1,(a0)+
		addq.w	#1,d6
		dbra	d7,r3eLoffsetLoop


		rts




		data


c3p
c3pWidth		ds.w	1
c3pHeightLong		dc.w	0
c3pHeight		ds.w	1
c3pHeightHalfLong	dc.w	0
c3pHeightHalf		ds.w	1
c3pHeightForDbraLong	dc.w	0
c3pHeightForDbra	ds.w	1
c3pWidthMin		ds.w	1
c3pWidthMax		ds.w	1
c3pHeightMin		ds.w	1
c3pHeightMax		ds.w	1
c3pSH			ds.w	1
c3pSkyText		ds.w	1
c3pSkyZoom		ds.l	1
c3pSkyZoomX		ds.b	12
c3pSkyXYOffset		ds.w	1
c3pSkyMask		ds.w	1
c3pRayCounter		ds.w	1

c3pPerspectiveValue	ds.l	1		; 90.000.000 bei 640x400
c3pPerspectiveValueX	ds.b	12

; variablen zu koordinaten/linien
c3pNbPoints		dc.w	8		; anzahl an (norm.) punkten
c3pNbMonsters		dc.w	0
c3pNbDoors		dc.w	0
c3pNbThings		dc.w	0
c3pNbSwitches		dc.w	0

c3pNbLines		dc.w	8		; anzahl an (norm.) linien

c3pNbCalcLines1		dc.w	0
c3pNbCalcLines2		dc.w	0

c3pFlag			dc.w	0
c3pErrorFlag		dc.w	0


c3pVersionString	dc.b	"Running 3D 68040 Engine (C) 1999-2000 RDT Volker Konrad",13,10,0	; todo
			even

; maximale schussweite
c3pShootDistMax		dc.l	0

; speicher fuer aktuelle linie
c3pCurrent		ds.b	12
			ds.l	1
			ds.l	1
			ds.w	1
			ds.l	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1
			ds.w	1

; multiplikatoren fuer texturadresse
c3pmreTexturAddresses	dc.l	$00000000
			dc.l	$00020000
			dc.l	$00040000
			dc.l	$00060000
			dc.l	$00080000
			dc.l	$000a0000
			dc.l	$000c0000
			dc.l	$000e0000
			dc.l	$00100000
			dc.l	$00120000
			dc.l	$00140000
			dc.l	$00160000
			dc.l	$00180000
			dc.l	$001a0000
			dc.l	$001c0000
			dc.l	$001e0000

; multiplikatoren fuer lighttable offsets
c3pmreLightAddresses	dc.l	$00000000
			dc.l	$00010000
			dc.l	$00020000
			dc.l	$00030000
			dc.l	$00040000
			dc.l	$00050000
			dc.l	$00060000
			dc.l	$00070000

; benoetigte dateien
fileSinus512XTab	dc.b	"data\bin\sin512x.tab",0
fileAlpha1024BTab	dc.b	"data\bin\alp1024b.tab",0
fileTangens1024XTab	dc.b	"data\bin\tan1024x.tab",0
			even

;	point_1

;		15...0: koordinatenindex punkt 1 (faktor 8) (0..65535)
;		23..16: bodenfarbindex (0..255)
;		31..24: text_and_maske (y-richtung) (0..255)

;	point_2

;		15...0: koordinatenindex punkt 2 (faktor 8) (0..65535)
;		23..16: deckenfarbindex (0..255)
;                   24: transparence_texture (1 = true)

;	line_flag_1:

;		15...0:	h1 (0..65536)
;		19..16:	texture_nr_front (0..15) (texturnummer vorderseite)
;		23..20: texture_nr_back (0..15) (texturnummer rueckseite)			
;               31..24: text_and_maske (0..255)

;	line_flag_2:

;		 7...0: normw (0..255)
;		     8: visi_front (1 = vorderseite sichtbar)
;		     9: visi_back (1 = rueckseite sichtbar)
;		    10: oben_decke (1 = true)
;		    11: unten_decke (1 = true)
;		    12: decke_ist_himmel (1 = true)
;		    13: backside ist normale textur (1 = true)
;		    14:	masked_texture (1 = textur muž maskiert werden)
;			(z.b. monster, gegner, gitterst„be ...)
;		    15: lightshading on/off
;		31..16: h2 (0..65536)

;	line_flag_3:

;		 7...0: y_offset (0..255) 
;		15...8: x_offset (0..255) 
;		31..16: text_width (0..65536)

; x/y-koordinaten (werden durch algorithmus nicht veraendert)
c3pPoints		ds.l	C3PPOINTSMAX*2
c3pPointsMonsters	ds.l	C3PMONSTERSMAX*2
c3pPointsDoors		ds.l	C3PDOORSMAX*2*4
c3pPointsThings		ds.l	C3PTHINGSMAX*2
c3pPointsSwitches	ds.l	C3PSWITCHESMAX*2

; liniendaten
c3pLines		ds.l	C3PLINESMAX*5
c3pLinesMonsters	ds.l	C3PMONSTERSMAX*5
c3pLinesDoors		ds.l	C3PDOORSMAX*5*4
c3pLinesThings		ds.l	C3PTHINGSMAX*5
c3pLinesSwitches	ds.l	C3PSWITCHESMAX*5

; gedrehte/verschobene x/y-koordinaten (werden durch algorithmus erzeugt)
c3pCalcPts		ds.l	C3PPOINTSMAX*2
c3pCalcPtsMonsters	ds.l	C3PMONSTERSMAX*2
c3pCalcPtsMMonsters	ds.l	C3PMONSTERSMAX*2*2
c3pCalcPtsDoors		ds.l	C3PDOORSMAX*2*4
c3pCalcPtsThings	ds.l	C3PTHINGSMAX*2
c3pCalcPtsTThings	ds.l	C3PTHINGSMAX*2*2
c3pCalcPtsSwitches	ds.l	C3PSWITCHESMAX*2*2

; angepasste liniendaten/bereiche
c3pCalcLines1		ds.l	C3PLINESMAX*5
			ds.l	C3PMONSTERSMAX*5
			ds.l	C3PDOORSMAX*5*4
			ds.l	C3PTHINGSMAX*5
			ds.l	C3PSWITCHESMAX*5
c3pCalcLines2		ds.l	C3PLINESMAX*5
			ds.l	C3PMONSTERSMAX*5
			ds.l	C3PDOORSMAX*5*4
			ds.l	C3PTHINGSMAX*5
			ds.l	C3PSWITCHESMAX*5

c3pAngleTab		ds.b	C3PMAXX
c3pTangensTabX		ds.b	C3PMAXX*12  		; (fp extended format)
c3pAngleTabFull		ds.b	C3PMAXX
c3pTangensTabXFull	ds.b	C3PMAXX*12

c3pMonstersAddFlags	ds.l	C3PMONSTERSMAX

; sinustabelle zum rotieren der koordinaten
sinus512TabX		ds.b	512*16			; (werte an 16 byte-grenzen)

; multiplizierte lineoffsets
lineoffsetMulus		ds.l	C3PMAXY

; puffer fuer aktuellen strahl
c3pNbRayBuffer		ds.w	1
c3pRayBufferPtr		ds.l	1
c3pRayBuffer		ds.b	C3PRAYBUFFERMAX*C3PRAYBUFFERBYTES

; puffer fuer stack zum eintragen einer gesplittenen aktuellen linie
c3pmenNbStackLines	ds.w	1
c3pmenStack		ds.b	C3PMENSTACKBYTES*C3PMENSTACKMAX

; zwischenspeicher fuer h1/height/yind einer in y-richtung maskierten linien (kachel)
c3pmreymBuffer		ds.w	128*3
			ds.w	1

; fertig berechnete bilddaten (spezielles format)
c3pPictureTextPtr	ds.l	1
c3pPictureFloorPtr	ds.l	1
c3pPictureMaskedPtr	ds.l	1
c3pPictureTransPtr	ds.l	1
c3pPictureText		ds.b	C3PTEXTMAX*C3PTEXTBYTES+C3PMAXX
c3pPictureFloor		ds.b	C3PFLOORMAX*C3PFLOORBYTES+C3PMAXX
c3pPictureMasked	ds.b	C3PMASKEDMAX*C3PMASKEDBYTES+C3PMAXX
c3pPictureTrans		ds.b	C3PTRANSMAX*C3PTRANSBYTES+C3PMAXX
