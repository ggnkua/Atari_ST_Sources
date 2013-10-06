; ok, 07.07.00/vk


; initiliasierungswerte fuer scanner (werden bei levelinitialisierung gesetzt)
SCANNERSTARTPOSX		equ	-70
SCANNERSTARTPOSY		equ	80
SCANNERSTARTRADIUS		equ	50
SCANNERSTARTRANGE		equ	4096
SCANNERSTARTNBOFCIRCLES		equ	4
SCANNERSTARTMONMAXDISTANCE	equ	$3000

SCANNERCIRCLEFACTORBITS	equ	4
SCANNERCIRCLECOLOR1	equ	%0000011111100000		; farbwert 1 fuer scannerkreis
SCANNERCIRCLECOLOR2	equ	%1111100000000000		; farbwert 2 fuer scannerkreis

SCANNERCOSYSTEMCOLORX	equ	%0000000111100000		; farbe der x-achse
SCANNERCOSYSTEMCOLORY	equ	%0000000111100111		; farbe der y-achse
SCANNERCOSYSTEMCOLORC	equ	%0000000011100000		; farbe der kreise

SCANNERMONCOLORSTANDARD	equ	%1100011100011000		; monsterfarbe standard
SCANNERMONCOLORHIT	equ	%0111101111100000		; monsterfarbe bei status "getroffen"
SCANNERMONCOLORSHOOT	equ	%1111100000000000		; monsterfarbe bei status "schiessen"
SCANNERMONCOLORDEAD	equ	%0001100011100111		; monsterfarbe bei status "sterben/gestorben"

			rsreset
SCANNERPOSX		rs.w	1
SCANNERPOSY		rs.w	1
SCANNERRADIUS		rs.w	1
SCANNERRANGE		rs.w	1
SCANNERMIDX		rs.w	1
SCANNERMIDY		rs.w	1
SCANNERMIDADDRESSOFFSET	rs.l	1
SCANNERCIRCLEPOS	rs.w	1
SCANNERCIRCLEMAX	rs.w	1
SCANNERCIRCLECOLOREXG	rs.w	1
SCANNERCOSYSTEMDX	rs.w	1
SCANNERCOSYSTEMDY	rs.w	1
SCANNERNBOFCIRCLES	rs.w	1
SCANNERMONMAXDISTANCE	rs.w	1
SCANNERBYTES		rs.w	1



		text


; ---------------------------------------------------------
; 08.08.00/vk
drawScannerIfRequired

		lea	playerThings+PTHGBYTES*TSCANNER,a0

		tst.w	PTHGFLAG(a0)
		beq.s	dsirOut
		tst.w	PTHGACTFLAG(a0)
		beq.s	dsirOut

		bsr.s	drawScanner
dsirOut
		rts


; ---------------------------------------------------------
; 10.06.00/vk
drawScanner
		lea	scanner,a0
		bsr	dsDrawCoordinateSystem
		bsr	dsDrawBackground
		bsr	dsDrawMonsters
		bsr	dsDrawCircle

		bsr	setFlagToClearBackground

		rts


; ---------------------------------------------------------
; 11.06.00/vk
; initialisiert den scanner nach (!) einem aufloesungswechsel neu.
; rettet alle register.
scannerResetFields
		movem.l	d0-a6,-(sp)
		lea	scanner,a0
		bsr.s	dsCalcTemporaryFields
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 10.06.00/vk
; berechnet einige temporaere variablen (mittelpunkt etc.).
; routine muss nach jedem aufloesungswechsel aufgerufen werden.
; a0 = scanner (bleibt unveraendert)
dsCalcTemporaryFields

		bsr.s	dsctfPositionAndScreenAddress
		bsr.s	dsctfCircleAnimation
		bsr.s	dsctfCoordinateSystem
		bsr.s	dsctfMonsters
		rts


; ---------------------------------------------------------
; 11.06.00/vk
; a0 = scanner (bleibt unveraendert)
dsctfPositionAndScreenAddress

		suba.l	a1,a1
		move.w	lineoffset,d7

		moveq	#0,d2
		moveq	#0,d3

		move.w	SCANNERPOSX(a0),d0
		bpl.s	dsctfXPos
		adda.w	d7,a1
		adda.w	d7,a1
		move.w	width,d2
dsctfXPos	add.w	d0,d2
		move.w	d2,SCANNERMIDX(a0)
		add.w	d0,d0
		adda.w	d0,a1

		move.w	SCANNERPOSY(a0),d0
		bpl.s	dsctfYPos
		move.w	height,d1
		move.w	d1,d3
		mulu.w	d7,d1
		adda.l	d1,a1
dsctfYPos	add.w	d0,d3
		move.w	d3,SCANNERMIDY(a0)
		muls.w	d7,d0
		adda.l	d0,a1

		move.l	a1,SCANNERMIDADDRESSOFFSET(a0)

		rts


; ---------------------------------------------------------
; 11.06.00/vk
; berechnet den maximale animationsposition,
; berechnet den positionswert der animation, bei der der farbwechsel durchzufuehren ist.
; alle werte abhaengig vom aktuellen radius (in pixeln).
; a0 = scanner (bleibt unveraendert)
dsctfCircleAnimation

		clr.w	SCANNERCIRCLEPOS(a0)
		move.w	SCANNERRADIUS(a0),d0
		lsl.w	#SCANNERCIRCLEFACTORBITS,d0
		subq.w	#1,d0
		move.w	d0,SCANNERCIRCLEMAX(a0)

		ext.l	d0
		divu.w	#10,d0
		lsl.w	#3,d0
		move.w	d0,SCANNERCIRCLECOLOREXG(a0)

		rts


; ---------------------------------------------------------
; 11.06.00/vk
; berechnet die groesse (den radius) des x/y-koordinatensystems.
; alle werte abhaengig vom aktuellen radius (in pixeln).
; a0 = scanner (bleibt unveraendert)
dsctfCoordinateSystem

		move.w	SCANNERRADIUS(a0),d0
		lsr.w	#3,d0
		mulu.w	#9,d0
		move.w	d0,SCANNERCOSYSTEMDX(a0)
		move.w	d0,SCANNERCOSYSTEMDY(a0)

		rts


; ---------------------------------------------------------
; 02.07.00/vk
; initialisiert die variablen zur anzeige der monster.
; a0 = scanner (bleibt unveraendert)
dsctfMonsters
		move.w	#SCANNERSTARTMONMAXDISTANCE,SCANNERMONMAXDISTANCE(a0)

		rts


; ---------------------------------------------------------
; 11.06.00/vk
; zeichnet das koordinatensystem in den screen.
; a0 = scanner (bleibt unveraendert)
dsDrawCoordinateSystem

	; kreise

		move.w	SCANNERNBOFCIRCLES(a0),d0
		beq.s	dsdcsNoCircles

		moveq	#0,d3
		move.w	SCANNERRADIUS(a0),d3

		divu.w	d0,d3				; d3 ist jetzt der abstand zwischen den kreisen
		move.w	d3,d1				; d1 ist der aktuell gezeichnete radius
		subq.w	#1,d0				; counter fuer dbra anpassen
dsdcsCirclesLoop
		move.w	#SCANNERCOSYSTEMCOLORC,d4
		movea.l	screen_1,a1
		adda.l	SCANNERMIDADDRESSOFFSET(a0),a1
		bsr	drawCircle
		add.w	d3,d1
		dbra	d0,dsdcsCirclesLoop
dsdcsNoCircles

	; x-achse

		move.l	a0,-(sp)
		move.w	SCANNERMIDX(a0),d0
		move.w	SCANNERMIDY(a0),d1
		move.w	SCANNERCOSYSTEMDX(a0),d3
		move.w	d0,d2
		sub.w	d3,d0
		add.w	d3,d2
		move.w	d1,d3
		move.w	lineoffset,d4
		ext.l	d4
		move.w	#SCANNERCOSYSTEMCOLORX,d7
		movea.l	screen_1,a0
		bsr	drawLine
		movea.l	(sp)+,a0

	; y-achse

		move.l	a0,-(sp)
		move.w	SCANNERMIDX(a0),d0
		move.w	SCANNERMIDY(a0),d1
		move.w	SCANNERCOSYSTEMDY(a0),d2
		move.w	d1,d3
		sub.w	d2,d1
		add.w	d2,d3
		move.w	d0,d2
		move.w	lineoffset,d4
		ext.l	d4
		move.w	#SCANNERCOSYSTEMCOLORY,d7
		movea.l	screen_1,a0
		bsr	drawLine
		movea.l	(sp)+,a0

		rts


; ---------------------------------------------------------
; 12.06.00/vk
; zeichnet ein hintergrundbild fuer den scanner
; a0 = scanner (bleibt unveraendert)
dsDrawBackground

		movea.l	screen_1,a6
		adda.l	SCANNERMIDADDRESSOFFSET(a0),a6

		lea	bmpCScanBack,a2
		suba.w	BITMAPWIDTH(a2),a6			; ( width / 2 ) * 2
		move.w	lineoffset,d7				; lineoffset des screens
		move.w	BITMAPHEIGHT(a2),d1
		lsr.w	#1,d1
		mulu.w	d7,d1
		suba.l	d1,a6

		movea.l	BITMAPGFXPTR(a2),a1
		move.w	BITMAPWIDTH(a2),d4
		move.w	BITMAPHEIGHT(a2),d5
		subq.w	#1,d4
		subq.w	#1,d5
		move.w	BITMAPLINEOFFSET(a2),d6

dsdbLoopY	movea.l	a6,a4
		movea.l	a1,a3
		move.w	d4,d3
dsdbLoopX	move.w	(a4)+,d1
		move.w	(a3)+,d0
		beq.s	dsdbSkipPixel
		lsr.w	#1,d0
		lsr.w	#1,d1
		andi.w	#%0111101111101111,d0
		andi.w	#%0111101111101111,d1
		add.w	d0,d1
		move.w	d1,-2(a4)
dsdbSkipPixel	dbra	d3,dsdbLoopX
		adda.w	d6,a1
		adda.w	d7,a6
		dbra	d5,dsdbLoopY

		rts


; ---------------------------------------------------------
; 02.07.00/vk
; zeichnet die monsters in das scannerfeld
; a0 = scanner (bleibt unveraendert)
dsDrawMonsters
		move.l	a0,-(sp)

		move.w	monBufferNb,d7
		bmi.s	dsdmOut

		lea	c3pCalcPtsMonsters,a1
		movea.l	monBufferPtr,a2

		fmove.w	SCANNERRADIUS(a0),fp0
		fdiv.w	SCANNERMONMAXDISTANCE(a0),fp0

		movea.l	playerDataPtr,a3
		move.w	#$40*2,d6
		move.w	PDALPHA(a3),d6
		addi.w	#$40*2+$80*2,d6
		andi.w	#$1ff,d6
dsdmLoop
		movea.l	(a2)+,a3

		fmove.l	(a1)+,fp3			; im dsp sind x und y "vertauscht"
		fmove.l	(a1)+,fp2
		fmul.x	fp0,fp2
		fmul.x	fp0,fp3
		fmove.l	fp2,d0
		fmove.l	fp3,d1
		neg.l	d0
		neg.l	d1

		bsr.s	dsdmDrawSingleMonster

		dbra	d7,dsdmLoop
dsdmOut
		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 02.07.00/vk
; zeichnet das monster in den scannerbereich
; d0 = x (in pixelangaben)
; d1 = y (in pixelangaben)
; d6 = alphaoffset
; a0 = scanner
; a3 = monster
; belegt: d7/a1-a2
dsdmDrawSingleMonster

		move.l	d0,d2
		bpl.s	dsdmdsmXOk
		neg.l	d2
dsdmdsmXOk	move.l	d1,d3
		bpl.s	dsdmdsmYOk
		neg.l	d3
dsdmdsmYOk	
		move.w	SCANNERRADIUS(a0),d4
		ext.l	d4
		cmp.l	d4,d2
		bgt.s	dsdmdsmOut
		cmp.l	d4,d3
		bgt.s	dsdmdsmOut

		movem.l	d6-d7/a0-a2,-(sp)

		movea.l	screen_1,a1
		adda.l	SCANNERMIDADDRESSOFFSET(a0),a1
		movea.l	a1,a0

		lea	drawFigureData,a6
		move.l	d0,DRAWFIGUREX(a6)
		move.l	d1,DRAWFIGUREY(a6)

		move.w	#$100,d3
		moveq	#0,d4
		move.b	MONLINE+12+3(a3),d4
		sub.w	d4,d3
		add.w	d3,d3
		add.w	d6,d3
		
		move.w	d3,DRAWFIGUREANGLE(a6)
		move.w	#3,DRAWFIGURELENGTH(a6)

		move.w	#SCANNERMONCOLORSTANDARD,d6		; d6 mit standardfarbwert vorbelegen
		tst.w	MONADIED(a3)
		bne.s	dsdmdsmIsDiing
		tst.w	MONASHOOT(a3)
		bne.s	dsdmdsmIsShoot
		tst.w	MONAHIT(a3)
		bne.s	dsdmdsmIsHit
		bra.s	dsdmdsmColorOk
dsdmdsmIsDiing	move.w	#SCANNERMONCOLORDEAD,d6
		bra.s	dsdmdsmColorOk
dsdmdsmIsShoot	move.w	#SCANNERMONCOLORSHOOT,d6
		bra.s	dsdmdsmColorOk
dsdmdsmIsHit	move.w	#SCANNERMONCOLORHIT,d6
dsdmdsmColorOk	move.w	d6,DRAWFIGURECOLOR(a6)

		bsr.s	drawFigurePixel

		movem.l	(sp)+,d6-d7/a0-a2
dsdmdsmOut
		rts


; ---------------------------------------------------------
; 02.07.00/vk
; zeichnet eine spielfigur (auf pixelbasis des screens)
; a0 = screen
; drawfiguredata
drawFigurePixel
		bsr.s	drawFigurePixelCalcVariables
dfpLoop
		move.w	(a4)+,d0
		move.w	(a4)+,d1
		move.w	(a4),d2
		move.w	2(a4),d3
		movem.l	d4-d5/d7/a0/a4,-(sp)
		bsr	drawLine
		movem.l	(sp)+,d4-d5/d7/a0/a4

		dbra	d5,dfpLoop

		rts


; ---------------------------------------------------------
; 02.07.00/vk
; zeichnet eine spielfigur (auf pixelbasis des screens)
; a0 = screen
; drawfiguredata
drawFigurePixelWithClipping

		bsr.s	drawFigurePixelCalcVariables
dfpwcLoop
		move.w	(a4)+,d0
		move.w	(a4)+,d1
		move.w	(a4),d2
		move.w	2(a4),d3
		movem.l	d4-d5/d7/a0/a4,-(sp)
		bsr	lineWithClipping
		movem.l	(sp)+,d4-d5/d7/a0/a4

		dbra	d5,dfpwcLoop

		rts


; ---------------------------------------------------------
; 12.08.00/vk
drawFigurePixelCalcVariables

		lea	drawFigureBuffer,a4	; hier werden die drei koordinaten zwischengespeichert
		lea	sinus512TabX,a5		; 16-byte-grenzen
		lea	drawFigureData,a6
		move.l	DRAWFIGUREX(a6),d6	; sx
		move.l	DRAWFIGUREY(a6),d7	; sy

		fmove.w	DRAWFIGURELENGTH(a6),fp2

		move.w	#$100*2,d0
		sub.w	DRAWFIGUREANGLE(a6),d0
		bsr	dfpCalcPoint
		addi.w	#$68*2,d0
		bsr	dfpCalcPoint
		addi.w	#$30*2,d0
		bsr	dfpCalcPoint

		lea	drawFigureBuffer,a4
		move.w	(a4),12(a4)
		move.w	2(a4),14(a4)

		moveq	#2,d5
		moveq	#0,d4
		move.w	lineoffset,d4		; bleibt konstant
		move.w	DRAWFIGURECOLOR(a6),d7	; farbwert (bleibt konstant)

		rts


; ---------------------------------------------------------
; 17.06.00/vk
; berechnet eine koordinate einer zu zeichnenden spielfigur
; d0 = alpha
; d6 = sx
; d7 = sy
; fp2 = FIGURELENGTH
; a0 = screen
; a4 = drawFigureBuffer
; a5 = sinus512TabX
dfpCalcPoint
		move.w	#$200,d1		; vollwinkel
		sub.w	d0,d1
		andi.w	#$1ff,d1

		lsl.w	#4,d1			; sinus/cosinus an 16-byte-grenzen
		fmove.x	(a5,d1.w),fp5		; sinus
		addi.w	#$40*2*16,d1
		andi.w	#$1fff,d1
		fmove.x	(a5,d1.w),fp4		; cosinus

		fmul.x	fp2,fp4
		fmul.x	fp2,fp5
		fadd.l	d6,fp4
		fadd.l	d7,fp5
		fmove.w	fp4,(a4)+
		fmove.w	fp5,(a4)+

		rts


; ---------------------------------------------------------
; 11.06.00/vk
; der animationscounter wird mit faktor ? gefuehrt.
; a0 = scanner (bleibt unveraendert)
dsDrawCircle
		move.l	a0,-(sp)

		move.w	vblTime1000,d0
		lsr.w	#2,d0
		bne.s	dsdcVblOk
		moveq	#1,d0
dsdcVblOk
		move.w	SCANNERCIRCLEPOS(a0),d1
		add.w	d0,d1
		cmp.w	SCANNERCIRCLEMAX(a0),d1
		blt.s	dsdcAnimOk
		clr.w	d1
dsdcAnimOk	move.w	d1,SCANNERCIRCLEPOS(a0)

		move.w	#SCANNERCIRCLECOLOR1,d4
		cmp.w	SCANNERCIRCLECOLOREXG(a0),d1
		blt.s	dsdcColorOk
		move.w	#SCANNERCIRCLECOLOR2,d4
dsdcColorOk
		lsr.w	#SCANNERCIRCLEFACTORBITS,d1
		movea.l	screen_1,a1
		adda.l	SCANNERMIDADDRESSOFFSET(a0),a1
		bsr	drawCircle

		movea.l	(sp)+,a0
		rts





		data




		bss


scanner		ds.b	SCANNERBYTES
