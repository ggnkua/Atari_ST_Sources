
; konstanten koennen nur bei weiteren anpassungen des selbstmodifizierenden codes geaendert werden
P3PPIXELINDBRAEXP	equ	3
P3PPIXELINDBRAMASK	equ	%111
P3PPIXELINDBRA		equ	8



		text


; ---------------------------------------------------------
; 02.07.00/vk
; zeichnet den kompletten inhalt des 3d fensters.
; keine abfrage der fullscreen-map mehr notwendig, da bereits
; vorher abgefragt.
; selbstmodifizierender programmcode (c) 1999 - 2000 volker konrad
paint3dPicture
		movea.l	playerDataPtr,a6
		lea	c3p,a5

	; offset fuer 3d fenster im gesamtscreen berechnen

		move.w	C3PHEIGHTMAX(a5),d1
		sub.w	C3PHEIGHT(a5),d1
		lsr.w	#1,d1
		mulu	lineoffset,d1

		move.w	C3PWIDTHMAX(a5),d2
		sub.w	C3PWIDTH(a5),d2
		tst.w	doubleScan
		beq.s	p3pNoDouble
		add.w	d2,d2
p3pNoDouble	ext.l	d2
		add.l	d2,d1
		move.l	d1,screen3dOffset

		ifeq USEVIDEOSCREENINRAM
		movea.l	screen_1,a1
		else
		movea.l	screenInRam,a1
		endc

		adda.l	d1,a1
		move.l	a1,screen3d			; variable muss bei jedem bilddurchlauf berechnet werden
							; -> weitere abhaengigkeiten

		tst.w	c3pErrorFlag			; fehler in der 3d berechnung?
		bne	p3pOut				; ja -> raus

		bsr	p3pText
		movea.l	screen3d,a1
		bsr	p3pFloor
		movea.l	screen3d,a1
		bsr	p3pMasked

p3pOut
		rts




; ---------------------------------------------------------
; 09.07.00/vk
; zeichnen der (normalen) wandtexturen.
; a1 = screen3d
p3pText
		lea	c3pPictureText,a0
		move.w	c3pWidth,d0
		subq.w	#1,d0			; schleifenzaehler (anzahl strahlen)

		lea	truecolorTab,a3

	; d0 = schleifenzaehler (spalten)
	; a0 = c3pPictureText
	; a1 = screen3d
	; a3 = truecolorTab

p3pTextLoop
		move.w	(a0)+,d1		; anzahl zu zeichnender pixel (linienhoehe)
		bmi	p3ptNextRay		; wenn negativ, dann ab zum naechsten strahl

		movea.l	a1,a2			; screenadresse
		adda.l	(a0)+,a2		; y-offset screenadresse (strahlenweise)
		movea.l	(a0)+,a4		; texturptr
		move.l	(a0)+,d4		; zoomfaktor (hi=vorkomma, low=nachkomma)
		move.l	(a0)+,d5		; zoomoffset (low)
		movea.l	a3,a5			; truecolorTab
		adda.l	(a0)+,a5		; welche farbtabelle?

		move.w	d1,d2			; wievielfaches von 8?
		lsr.w	#P3PPIXELINDBRAEXP,d2
		beq	p3ptNoOptimize		; weniger pixel zu zeichnen -> einf. schleife

		andi.w	#P3PPIXELINDBRAMASK,d1	; fuer den rest (einf. schleife)
		subq.w	#1,d2

		add.w	d4,d5
		swap	d5			; anfangsnachkomma -> hi
		swap	d4			; vor-/nachkomma vertauschen

	; schleife mit x wdh.

p3ptScan
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		addx.l	d4,d5
p3pModTD00	move.w	(a5,d7.w*2),(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT00
p3pModTD01	move.w  (a5,d7.w*2),-320(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT01
p3pModTD02	move.w  (a5,d7.w*2),-640(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT02
p3pModTD03	move.w  (a5,d7.w*2),-960(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT03
p3pModTD04	move.w  (a5,d7.w*2),-1280(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT04
p3pModTD05	move.w  (a5,d7.w*2),-1600(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT05
p3pModTD06	move.w  (a5,d7.w*2),-1920(a2)
                move.w  (a4,d5.w*2),d7
		addx.l	d4,d5
p3pModT06
p3pModTD07	move.w  (a5,d7.w*2),-2240(a2)

p3pModT07	lea	-2560(a2),a2
		dbra	d2,p3ptScan

	; schleife fuer restl. pixel

p3ptScanRest
		move.w	(a4,d5.w*2),d7
		addx.l	d4,d5
p3pModTD08	move.w	(a5,d7.w*2),(a2)
p3pModT08	lea	-320(a2),a2
		dbra	d1,p3ptScanRest

		bra	p3pTextLoop

p3ptNoOptimize
		add.w	d4,d5
		swap	d5
		swap	d4
p3ptnoLoop
		move.w	(a4,d5.w*2),d7
		addx.l	d4,d5
p3pModTD09	move.w	(a5,d7.w*2),(a2)
p3pModT09	lea	-320(a2),a2
		dbra	d1,p3ptnoLoop

		bra	p3pTextLoop

p3ptNextRay
p3pModTD10	addq.l	#2,a1

		ifeq C3PDEBUGONLY1RAY
		dbra	d0,p3pTextLoop
		endc

p3ptOut
		rts


; ---------------------------------------------------------
; 09.07.00/vk
; boden- und deckentexturen.
; a1 = screen3d
p3pFloor
		lea	c3pPictureFloor,a0
		move.w	c3pWidth,d0
		subq.w	#1,d0			; schleifenzaehler (anzahl strahlen)

		movea.l	floorColorPtr,a3

p3pFloorLoop
		move.w	(a0)+,d1		; anzahl zu zeichnender pixel (linienhoehe)
		bmi	p3pfNextRay		; wenn negativ, dann ab zum naechsten strahl

		movea.l	a1,a2			; screenadresse
		adda.l	(a0)+,a2		; y-offset screenadresse (strahlenweise)
		move.w	(a0)+,d7		; d7 = farbindex
		move.l	(a3,d7.w*4),d7		; d7 = farbwert (.l ist immer schneller als .w)

		move.w	d1,d2			; wievielfaches von 8?
		lsr.w	#P3PPIXELINDBRAEXP,d2
		beq	p3pfNoOptimize		; weniger pixel zu zeichnen -> einf. schleife

		andi.w	#P3PPIXELINDBRAMASK,d1	; fuer den rest (einf. schleife)
		subq.w	#1,d2

	; schleife mit x wdh.

p3pfScan
p3pModFD00	move.w	d7,(a2)
p3pModF00
p3pModFD01	move.w	d7,-320(a2)
p3pModF01
p3pModFD02	move.w	d7,-320(a2)
p3pModF02
p3pModFD03	move.w	d7,-320(a2)
p3pModF03
p3pModFD04	move.w	d7,-320(a2)
p3pModF04
p3pModFD05	move.w	d7,-320(a2)
p3pModF05
p3pModFD06	move.w	d7,-320(a2)
p3pModF06
p3pModFD07	move.w	d7,-320(a2)
p3pModF07	lea	-8*320(a2),a2
		dbra	d2,p3pfScan

	; schleife fuer restl. pixel

p3pfScanRest
p3pModFD08	move.w	d7,(a2)
p3pModF08	lea	-320(a2),a2
		dbra	d1,p3pfScanRest
		bra	p3pFloorLoop

p3pfNoOptimize
p3pfnoLoop
p3pModFD09	move.w	d7,(a2)
p3pModF09	lea	-320(a2),a2
		dbra	d1,p3pfnoLoop

		bra	p3pFloorLoop

p3pfNextRay
p3pModFD10	addq.l	#2,a1

		IFEQ C3PDEBUGONLY1RAY
		dbra	d0,p3pFloorLoop
		ENDC
p3pfOut
		rts


; ---------------------------------------------------------
; 09.07.00/vk
; maskierte texturen.
; a1 = screen3d
p3pMasked
		lea	c3pPictureMasked,a0
		move.w	c3pWidth,d0
		subq.w	#1,d0			; schleifenzaehler (anzahl strahlen)

		lea	truecolorTab,a3

	; d0 = schleifenzaehler (spalten)
	; a0 = c3pPictureMasked
	; a1 = screen3d
	; a3 = truecolorTab
	; a6 = tilesGfx

p3pMaskedLoop
		move.w	(a0)+,d1		; anzahl zu zeichnender pixel (linienhoehe)
		bmi	p3pmNextRay		; wenn negativ, dann ab zum naechsten strahl

		movea.l	a1,a2			; screenadresse
		adda.l	(a0)+,a2		; y-offset screenadresse (strahlenweise)
		movea.l	(a0)+,a4
		move.l	(a0)+,d4		; zoomfaktor (hi=vorkomma, low=nachkomma)
		move.l	(a0)+,d5		; zoomoffset (low)
		movea.l	a3,a5			; truecolorTab
		adda.l	(a0)+,a5		; welche farbtabelle?

		move.w	d1,d2			; wievielfaches von 8?
		lsr.w	#P3PPIXELINDBRAEXP,d2
		beq	p3pmNoOptimize		; weniger pixel zu zeichnen -> einf. schleife

		andi.w	#P3PPIXELINDBRAMASK,d1	; fuer den rest (einf. schleife)
		subq.w	#1,d2

		add.w	d4,d5
		swap	d5			; anfangsnachkomma -> hi
		swap	d4			; vor-/nachkomma vertauschen

	; schleife mit x wdh.

p3pmScan
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip00

p3pModMD00	move.w	(a5,d7.w*2),(a2)
p3pmSkip00	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip01
p3pModM00
p3pModMD01	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip01	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip02
p3pModM01
p3pModMD02	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip02	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip03
p3pModM02
p3pModMD03	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip03	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip04
p3pModM03
p3pModMD04	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip04	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip05
p3pModM04
p3pModMD05	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip05	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip06
p3pModM05
p3pModMD06	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip06	addx.l	d4,d5
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3pmSkip07
p3pModM06
p3pModMD07	move.w	(a5,d7.w*2),-320(a2)
p3pmSkip07	addx.l	d4,d5

p3pModM07	lea	-2560(a2),a2
		dbra	d2,p3pmScan

	; schleife fuer restl. pixel

p3pmScanRest
		move.w	(a4,d5.w*2),d7
		beq.s	p3pmSkip08
p3pModMD08	move.w	(a5,d7.w*2),(a2)
p3pmSkip08	addx.l	d4,d5
p3pModM08	lea	-320(a2),a2
		dbra	d1,p3pmScanRest

		bra	p3pMaskedLoop

p3pmNoOptimize
		add.w	d4,d5
		swap	d5
		swap	d4
p3pmNoLoop
		move.w	(a4,d5.w*2),d7
		beq.s	p3pmSkip09
p3pModMD09	move.w	(a5,d7.w*2),(a2)
p3pmSkip09	addx.l	d4,d5
p3pModM09	lea	-320(a2),a2
		dbra	d1,p3pmNoLoop

		bra	p3pMaskedLoop

p3pmNextRay
p3pModMD10	addq.l	#2,a1

		ifeq C3PDEBUGONLY1RAY
		dbra	d0,p3pMaskedLoop
		endc

p3pmOut
		rts


; ---------------------------------------------------------
; 09.07.00/vk
; transparente maskierte texturen.
; a1 = screen3d
p3pTransparend
		lea	c3pPictureMasked,a0	; todo
		move.w	c3pWidth,d0
		subq.w	#1,d0			; schleifenzaehler (anzahl strahlen)

		lea	truecolorTab,a3

	; d0 = schleifenzaehler (spalten)
	; a0 = c3pPictureTransparend
	; a1 = screen3d
	; a3 = truecolorTab
	; a6 = tilesGfx

p3pTransparendLoop
		move.w	(a0)+,d1		; anzahl zu zeichnender pixel (linienhoehe)
		bmi	p3prNextRay		; wenn negativ, dann ab zum naechsten strahl

		movea.l	a1,a2			; screenadresse
		adda.l	(a0)+,a2		; y-offset screenadresse (strahlenweise)
		movea.l	(a0)+,a4		; texturptr
		move.l	(a0)+,d4		; zoomfaktor (hi=vorkomma, low=nachkomma)
		move.l	(a0)+,d5		; zoomoffset (low)
		movea.l	a3,a5			; truecolorTab
		adda.l	(a0)+,a5		; welche farbtabelle?

		move.l	#%01111011111011110111101111101111,d3

		move.w	d1,d2			; wievielfaches von 8?
		lsr.w	#P3PPIXELINDBRAEXP,d2
		beq	p3prNoOptimize		; weniger pixel zu zeichnen -> einf. schleife

		andi.w	#P3PPIXELINDBRAMASK,d1	; fuer den rest (einf. schleife)
		subq.w	#1,d2

		add.w	d4,d5
		swap	d5			; anfangsnachkomma -> hi
		swap	d4			; vor-/nachkomma vertauschen

	; schleife mit x wdh.

p3prScan
		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip00
p3pModRD00	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModRD01	move.w	(a2),d6			; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD02	lsr.w	#1,d6
p3pModRD03	lsr.w	#1,d7
p3pModRD04	and.w	d3,d6
p3pModRD05	and.w	d3,d7
p3pModRD06	add.w	d6,d7
p3pModRD07	move.w	d7,(a2)
		move.b	(sp)+,ccr
p3prSkip00	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip01
p3pModRD08	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR00
p3pModRD09	move.w	-1280(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD10	lsr.w	#1,d6
p3pModRD11	lsr.w	#1,d7
p3pModRD12	and.w	d3,d6
p3pModRD13	and.w	d3,d7
p3pModRD14	add.w	d6,d7
p3pModR01
p3pModRD15	move.w	d7,-1280(a2)
		move.b	(sp)+,ccr
p3prSkip01	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip02
p3pModRD16	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR02
p3pModRD17	move.w	-1280*2(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD18	lsr.w	#1,d6
p3pModRD19	lsr.w	#1,d7
p3pModRD20	and.w	d3,d6
p3pModRD21	and.w	d3,d7
p3pModRD22	add.w	d6,d7
p3pModR03
p3pModRD23	move.w	d7,-1280*2(a2)
		move.b	(sp)+,ccr
p3prSkip02	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip03
p3pModRD24	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR04
p3pModRD25	move.w	-1280*3(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD26	lsr.w	#1,d6
p3pModRD27	lsr.w	#1,d7
p3pModRD28	and.w	d3,d6
p3pModRD29	and.w	d3,d7
p3pModRD30	add.w	d6,d7
p3pModR05
p3pModRD31	move.w	d7,-1280*3(a2)
		move.b	(sp)+,ccr
p3prSkip03	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip04
p3pModRD32	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR06
p3pModRD33	move.w	-1280*4(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD34	lsr.w	#1,d6
p3pModRD35	lsr.w	#1,d7
p3pModRD36	and.w	d3,d6
p3pModRD37	and.w	d3,d7
p3pModRD38	add.w	d6,d7
p3pModR07
p3pModRD39	move.w	d7,-1280*4(a2)
		move.b	(sp)+,ccr
p3prSkip04	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip05
p3pModRD40	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR08
p3pModRD41	move.w	-1280*5(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD42	lsr.w	#1,d6
p3pModRD43	lsr.w	#1,d7
p3pModRD44	and.w	d3,d6
p3pModRD45	and.w	d3,d7
p3pModRD46	add.w	d6,d7
p3pModR09
p3pModRD47	move.w	d7,-1280*5(a2)
		move.b	(sp)+,ccr
p3prSkip05	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip06
p3pModRD48	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR10
p3pModRD49	move.w	-1280*6(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD50	lsr.w	#1,d6
p3pModRD51	lsr.w	#1,d7
p3pModRD52	and.w	d3,d6
p3pModRD53	and.w	d3,d7
p3pModRD54	add.w	d6,d7
p3pModR11
p3pModRD55	move.w	d7,-1280*6(a2)
		move.b	(sp)+,ccr
p3prSkip06	addx.l	d4,d5

		move.w	(a4,d5.w*2),d7		; farbindex (aus tilesGfx)
		beq.s	p3prSkip07
p3pModRD56	move.w	(a5,d7.w*2),d7		; zielfarbwert
p3pModR12
p3pModRD57	move.w	-1280*7(a2),d6		; quellfarbwert
		move.b	ccr,-(sp)
p3pModRD58	lsr.w	#1,d6
p3pModRD59	lsr.w	#1,d7
p3pModRD60	and.w	d3,d6
p3pModRD61	and.w	d3,d7
p3pModRD62	add.w	d6,d7
p3pModR13
p3pModRD63	move.w	d7,-1280*7(a2)
		move.b	(sp)+,ccr
p3prSkip07	addx.l	d4,d5

p3pModR14	lea	-1280*8(a2),a2
		dbra	d2,p3prScan

	; schleife fuer restl. pixel

p3prScanRest
		move.w	(a4,d5.w*2),d7
		beq.s	p3prSkip08
p3pModRD64	move.w	(a5,d7.w*2),d7
p3pModRD65	move.w	(a2),d6
		move.b	ccr,-(sp)
p3pModRD66	lsr.w	#1,d6
p3pModRD67	lsr.w	#1,d7
p3pModRD68	and.w	d3,d6
p3pModRD69	and.w	d3,d7
p3pModRD70	add.w	d6,d7
p3pModRD71	move.w	d7,(a2)
		move.b	(sp)+,ccr
p3prSkip08	addx.l	d4,d5
p3pModR15	lea	-1280(a2),a2
		dbra	d1,p3prScanRest

		bra	p3pTransparendLoop

p3prNoOptimize
		add.w	d4,d5
		swap	d5
		swap	d4
p3prNoLoop
		move.w	(a4,d5.w*2),d7
		beq.s	p3prSkip09
p3pModRD72	move.w	(a5,d7.w*2),d7
p3pModRD73	move.w	(a2),d6
		move.b	ccr,-(sp)
p3pModRD74	lsr.w	#1,d6
p3pModRD75	lsr.w	#1,d7
p3pModRD76	and.w	d3,d6
p3pModRD77	and.w	d3,d7
p3pModRD78	add.w	d6,d7
p3pModRD79	move.w	d7,(a2)
		move.b	(sp)+,ccr
p3prSkip09	addx.l	d4,d5
p3pModR16	lea	-1280(a2),a2
		dbra	d1,p3prNoLoop

		bra	p3pTransparendLoop

p3prNextRay
p3pModRD80	addq.l	#2,a1

		ifeq C3PDEBUGONLY1RAY
		dbra	d0,p3pTransparendLoop
		endc

p3prOut
		rts


; ---------------------------------------------------------
; modifiziert die codeadressen fuer die jeweilige
; hardwareaufloesung. wird immer bei aufloesungswechsel
; mitaufgerufen.
modifyPaintCodeAddresses

		lea	p3pModTab,a0
		move.w	lineoffset,d6
		move.w	p3pModTabNb,d7
mpcaLoop	movea.l	(a0),a1
		move.w	6(a0),d0
		muls.w	d6,d0
		move.w	d0,(a1)
		addq.l	#8,a0
		dbra	d7,mpcaLoop

		jsr	clearCache

		rts


; ---------------------------------------------------------
; modifiziert die codeadressen fuer den doubleScan-Modus
modifyPaintCodeAddressesDoubleScan

		lea	p3pModDTab,a0
		move.w	p3pModDTabNb,d7
mpcadsLoop	movea.l	(a0)+,a1
		move.w	(a0),d4		; bitposition
		bmi.s	mpcadsSkipBit
		move.w	2(a0),d5	; setzen oder loeschen?
		tst.w	doubleScan
		bne.s	mpcadsDouble
		bchg	#0,d5
mpcadsDouble	tst.w	d5
		beq.s	mpcadsClear
mpcadsSet	bset	d4,(a1)
		bra.s	mpcadsSkipBit
mpcadsClear	bclr	d4,(a1)
mpcadsSkipBit	addq.l	#4,a0
		dbra	d7,mpcadsLoop

		jsr	clearCache

		rts





		data

; diese codeadressen sind zu modifizieren fuer die jeweilige hardwareaufloesung (faktor nebenstehend)
p3pModTabNb	dc.w	47-1
p3pModTab	dc.l	p3pModT00+4,-1
		dc.l	p3pModT01+4,-2
		dc.l	p3pModT02+4,-3
		dc.l	p3pModT03+4,-4
		dc.l	p3pModT04+4,-5
		dc.l	p3pModT05+4,-6
		dc.l	p3pModT06+4,-7
		dc.l	p3pModT07+2,-8
		dc.l	p3pModT08+2,-1
		dc.l	p3pModT09+2,-1
		dc.l	p3pModF00+2,-1
		dc.l	p3pModF01+2,-2
		dc.l	p3pModF02+2,-3
		dc.l	p3pModF03+2,-4
		dc.l	p3pModF04+2,-5
		dc.l	p3pModF05+2,-6
		dc.l	p3pModF06+2,-7
		dc.l	p3pModF07+2,-8
		dc.l	p3pModF08+2,-1
		dc.l	p3pModF09+2,-1
		dc.l	p3pModM00+4,-1
		dc.l	p3pModM01+4,-2
		dc.l	p3pModM02+4,-3
		dc.l	p3pModM03+4,-4
		dc.l	p3pModM04+4,-5
		dc.l	p3pModM05+4,-6
		dc.l	p3pModM06+4,-7
		dc.l	p3pModM07+2,-8
		dc.l	p3pModM08+2,-1
		dc.l	p3pModM09+2,-1
		dc.l	p3pModR00+2,-1
		dc.l	p3pModR01+2,-1
		dc.l	p3pModR02+2,-2
		dc.l	p3pModR03+2,-2
		dc.l	p3pModR04+2,-3
		dc.l	p3pModR05+2,-3
		dc.l	p3pModR06+2,-4
		dc.l	p3pModR07+2,-4
		dc.l	p3pModR08+2,-5
		dc.l	p3pModR09+2,-5
		dc.l	p3pModR10+2,-6
		dc.l	p3pModR11+2,-6
		dc.l	p3pModR12+2,-7
		dc.l	p3pModR13+2,-7
		dc.l	p3pModR14+2,-8
		dc.l	p3pModR15+2,-1
		dc.l	p3pModR16+2,-1

; diese codeaddressen sind zu modifizieren fuer doubleScan modus
p3pModDTabNb	dc.w	168-1
p3pModDTab	dc.l	p3pModTD00
		dc.w	4,0
		dc.l	p3pModTD01
		dc.w	4,0
		dc.l	p3pModTD02
		dc.w	4,0
		dc.l	p3pModTD03
		dc.w	4,0
		dc.l	p3pModTD04
		dc.w	4,0
		dc.l	p3pModTD05
		dc.w	4,0
		dc.l	p3pModTD06
		dc.w	4,0
		dc.l	p3pModTD07
		dc.w	4,0
		dc.l	p3pModTD08
		dc.w	4,0
		dc.l	p3pModTD09
		dc.w	4,0
		dc.l	p3pModTD10
		dc.w	2,0
		dc.l	p3pModTD10
		dc.w	3,1
		dc.l	p3pModFD00
		dc.w	4,0
		dc.l	p3pModFD01
		dc.w	4,0
		dc.l	p3pModFD02
		dc.w	4,0
		dc.l	p3pModFD03
		dc.w	4,0
		dc.l	p3pModFD04
		dc.w	4,0
		dc.l	p3pModFD05
		dc.w	4,0
		dc.l	p3pModFD06
		dc.w	4,0
		dc.l	p3pModFD07
		dc.w	4,0
		dc.l	p3pModFD08
		dc.w	4,0
		dc.l	p3pModFD09
		dc.w	4,0
		dc.l	p3pModFD10
		dc.w	2,0
		dc.l	p3pModFD10
		dc.w	3,1
		dc.l	p3pModMD00
		dc.w	4,0
		dc.l	p3pModMD01
		dc.w	4,0
		dc.l	p3pModMD02
		dc.w	4,0
		dc.l	p3pModMD03
		dc.w	4,0
		dc.l	p3pModMD04
		dc.w	4,0
		dc.l	p3pModMD05
		dc.w	4,0
		dc.l	p3pModMD06
		dc.w	4,0
		dc.l	p3pModMD07
		dc.w	4,0
		dc.l	p3pModMD08
		dc.w	4,0
		dc.l	p3pModMD09
		dc.w	4,0
		dc.l	p3pModMD10
		dc.w	2,0
		dc.l	p3pModMD10
		dc.w	3,1
		dc.l	p3pModRD00
		dc.w	4,0
		dc.l	p3pModRD01
		dc.w	4,0
		dc.l	p3pModRD02+1
		dc.w	6,0
		dc.l	p3pModRD02+1
		dc.w	7,1
		dc.l	p3pModRD03+1
		dc.w	6,0
		dc.l	p3pModRD03+1
		dc.w	7,1
		dc.l	p3pModRD04+1
		dc.w	6,0
		dc.l	p3pModRD04+1
		dc.w	7,1
		dc.l	p3pModRD05+1
		dc.w	6,0
		dc.l	p3pModRD05+1
		dc.w	7,1
		dc.l	p3pModRD06+1
		dc.w	6,0
		dc.l	p3pModRD06+1
		dc.w	7,1
		dc.l	p3pModRD07
		dc.w	4,0
		dc.l	p3pModRD08
		dc.w	4,0
		dc.l	p3pModRD09
		dc.w	4,0
		dc.l	p3pModRD10+1
		dc.w	6,0
		dc.l	p3pModRD10+1
		dc.w	7,1
		dc.l	p3pModRD11+1
		dc.w	6,0
		dc.l	p3pModRD11+1
		dc.w	7,1
		dc.l	p3pModRD12+1
		dc.w	6,0
		dc.l	p3pModRD12+1
		dc.w	7,1
		dc.l	p3pModRD13+1
		dc.w	6,0
		dc.l	p3pModRD13+1
		dc.w	7,1
		dc.l	p3pModRD14+1
		dc.w	6,0
		dc.l	p3pModRD14+1
		dc.w	7,1
		dc.l	p3pModRD15
		dc.w	4,0
		dc.l	p3pModRD16
		dc.w	4,0
		dc.l	p3pModRD17
		dc.w	4,0
		dc.l	p3pModRD18+1
		dc.w	6,0
		dc.l	p3pModRD18+1
		dc.w	7,1
		dc.l	p3pModRD19+1
		dc.w	6,0
		dc.l	p3pModRD19+1
		dc.w	7,1
		dc.l	p3pModRD20+1
		dc.w	6,0
		dc.l	p3pModRD20+1
		dc.w	7,1
		dc.l	p3pModRD21+1
		dc.w	6,0
		dc.l	p3pModRD21+1
		dc.w	7,1
		dc.l	p3pModRD22+1
		dc.w	6,0
		dc.l	p3pModRD22+1
		dc.w	7,1
		dc.l	p3pModRD23
		dc.w	4,0
		dc.l	p3pModRD24
		dc.w	4,0
		dc.l	p3pModRD25
		dc.w	4,0
		dc.l	p3pModRD26+1
		dc.w	6,0
		dc.l	p3pModRD26+1
		dc.w	7,1
		dc.l	p3pModRD27+1
		dc.w	6,0
		dc.l	p3pModRD27+1
		dc.w	7,1
		dc.l	p3pModRD28+1
		dc.w	6,0
		dc.l	p3pModRD28+1
		dc.w	7,1
		dc.l	p3pModRD29+1
		dc.w	6,0
		dc.l	p3pModRD29+1
		dc.w	7,1
		dc.l	p3pModRD30+1
		dc.w	6,0
		dc.l	p3pModRD30+1
		dc.w	7,1
		dc.l	p3pModRD31
		dc.w	4,0
		dc.l	p3pModRD32
		dc.w	4,0
		dc.l	p3pModRD33
		dc.w	4,0
		dc.l	p3pModRD34+1
		dc.w	6,0
		dc.l	p3pModRD34+1
		dc.w	7,1
		dc.l	p3pModRD35+1
		dc.w	6,0
		dc.l	p3pModRD35+1
		dc.w	7,1
		dc.l	p3pModRD36+1
		dc.w	6,0
		dc.l	p3pModRD36+1
		dc.w	7,1
		dc.l	p3pModRD37+1
		dc.w	6,0
		dc.l	p3pModRD37+1
		dc.w	7,1
		dc.l	p3pModRD38+1
		dc.w	6,0
		dc.l	p3pModRD38+1
		dc.w	7,1
		dc.l	p3pModRD39
		dc.w	4,0
		dc.l	p3pModRD40
		dc.w	4,0
		dc.l	p3pModRD41
		dc.w	4,0
		dc.l	p3pModRD42+1
		dc.w	6,0
		dc.l	p3pModRD42+1
		dc.w	7,1
		dc.l	p3pModRD43+1
		dc.w	6,0
		dc.l	p3pModRD43+1
		dc.w	7,1
		dc.l	p3pModRD44+1
		dc.w	6,0
		dc.l	p3pModRD44+1
		dc.w	7,1
		dc.l	p3pModRD45+1
		dc.w	6,0
		dc.l	p3pModRD45+1
		dc.w	7,1
		dc.l	p3pModRD46+1
		dc.w	6,0
		dc.l	p3pModRD46+1
		dc.w	7,1
		dc.l	p3pModRD47
		dc.w	4,0
		dc.l	p3pModRD48
		dc.w	4,0
		dc.l	p3pModRD49
		dc.w	4,0
		dc.l	p3pModRD50+1
		dc.w	6,0
		dc.l	p3pModRD50+1
		dc.w	7,1
		dc.l	p3pModRD51+1
		dc.w	6,0
		dc.l	p3pModRD51+1
		dc.w	7,1
		dc.l	p3pModRD52+1
		dc.w	6,0
		dc.l	p3pModRD52+1
		dc.w	7,1
		dc.l	p3pModRD53+1
		dc.w	6,0
		dc.l	p3pModRD53+1
		dc.w	7,1
		dc.l	p3pModRD54+1
		dc.w	6,0
		dc.l	p3pModRD54+1
		dc.w	7,1
		dc.l	p3pModRD55
		dc.w	4,0
		dc.l	p3pModRD56
		dc.w	4,0
		dc.l	p3pModRD57
		dc.w	4,0
		dc.l	p3pModRD58+1
		dc.w	6,0
		dc.l	p3pModRD58+1
		dc.w	7,1
		dc.l	p3pModRD59+1
		dc.w	6,0
		dc.l	p3pModRD59+1
		dc.w	7,1
		dc.l	p3pModRD60+1
		dc.w	6,0
		dc.l	p3pModRD60+1
		dc.w	7,1
		dc.l	p3pModRD61+1
		dc.w	6,0
		dc.l	p3pModRD61+1
		dc.w	7,1
		dc.l	p3pModRD62+1
		dc.w	6,0
		dc.l	p3pModRD62+1
		dc.w	7,1
		dc.l	p3pModRD63
		dc.w	4,0
		dc.l	p3pModRD64
		dc.w	4,0
		dc.l	p3pModRD65
		dc.w	4,0
		dc.l	p3pModRD66+1
		dc.w	6,0
		dc.l	p3pModRD66+1
		dc.w	7,1
		dc.l	p3pModRD67+1
		dc.w	6,0
		dc.l	p3pModRD67+1
		dc.w	7,1
		dc.l	p3pModRD68+1
		dc.w	6,0
		dc.l	p3pModRD68+1
		dc.w	7,1
		dc.l	p3pModRD69+1
		dc.w	6,0
		dc.l	p3pModRD69+1
		dc.w	7,1
		dc.l	p3pModRD70+1
		dc.w	6,0
		dc.l	p3pModRD70+1
		dc.w	7,1
		dc.l	p3pModRD71
		dc.w	4,0
		dc.l	p3pModRD72
		dc.w	4,0
		dc.l	p3pModRD73
		dc.w	4,0
		dc.l	p3pModRD74+1
		dc.w	6,0
		dc.l	p3pModRD74+1
		dc.w	7,1
		dc.l	p3pModRD75+1
		dc.w	6,0
		dc.l	p3pModRD75+1
		dc.w	7,1
		dc.l	p3pModRD76+1
		dc.w	6,0
		dc.l	p3pModRD76+1
		dc.w	7,1
		dc.l	p3pModRD77+1
		dc.w	6,0
		dc.l	p3pModRD77+1
		dc.w	7,1
		dc.l	p3pModRD78+1
		dc.w	6,0
		dc.l	p3pModRD78+1
		dc.w	7,1
		dc.l	p3pModRD79
		dc.w	4,0
		dc.l	p3pModRD80
		dc.w	2,0
		dc.l	p3pModRD80
		dc.w	3,1





		bss

