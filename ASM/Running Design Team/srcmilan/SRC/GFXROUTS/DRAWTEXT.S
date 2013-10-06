
DRAWTEXTHEIGHT		equ	10


			rsreset
FONTDATAFLAGS		rs.w	1
FONTDATAWIDTH		rs.w	1
FONTDATAHEIGHT		rs.w	1
FONTDATAMASKGFX		rs.l	1
FONTDATAMASKLINEOFFSET	rs.w	1
FONTDATACOLORGFX	rs.l	1
FONTDATACOLORLINEOFFSET	rs.w	1
FONTDATAGFXOFFSET	rs.l	1
FONTDATACOUNTER		rs.w	1		; counter auf -1 setzen, falls nicht verwendet
FONTDATACOUNTERMAX	rs.w	1


		text


; ---------------------------------------------------------
; 02.06.00/vk
; zeichnet eine zeichenkette in den screen/speicher mit der
; standardschriftart (Rot: 8x8).
; a0 = auszugebende zeichenkette
; a6 = screenadresse
drawTextRed8x8
		move.l	a1,-(sp)
		lea	fontDataRed8x8,a1
		bsr	drawText
		movea.l	(sp)+,a1
		rts


; ---------------------------------------------------------
; 01.06.00/vk
; zeichnet eine zeichenkette in den screen/speicher.
; a0 = auszugebende zeichenkette
; a1 = fontdata
; a6 = screenadresse
; rettet alle register
drawText
		movem.l	d0-a6,-(sp)

		movea.l	a6,a5				; anfangsadresse speichern
dtLoop
		move.b	(a0)+,d7			; naechstes zeichen holen
		beq.s	dtOut				; ende erreicht?
		cmpi.b	#13,d7				; zeilenumbruch?
		bne.s	dtNoNewLine

		move.w	lineoffset,d7
		mulu.w	#DRAWTEXTHEIGHT,d7
		movea.l	a5,a6
		adda.l	d7,a6
		movea.l	a6,a5
		bra.s	dtLoop
dtNoNewLine
		movem.l	a0/a5-a6,-(sp)
		bsr.s	dtOneLetter
		movem.l	(sp)+,a0/a5-a6

		move.w	FONTDATAWIDTH(a1),d7		; breite eines buchstabens
		add.w	d7,d7				; verdoppeln (16 bit farbtiefe)
		adda.w	d7,a6				; auf vorherige screenadresse addieren
		bra.s	dtLoop				; ab zum naechsten buchstaben
dtOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 02.06.00/vk
; zeichnet einen einzelnen buchstaben.
; d7.b = asciicode
; a1 = fontdata
; a6 = screenadresse
; rueckgabe: a1 unveraendert
dtOneLetter
		movea.l	FONTDATAGFXOFFSET(a1),a2
		andi.w	#$00ff,d7
		move.w	(a2,d7.w*2),d6			; gfxoffset fuer aktuellen buchstaben
		bmi.s	dtolOut				; negativ -> buchstaben kann nicht gezeichnet werden

		movea.l	FONTDATAMASKGFX(a1),a2
		adda.w	d6,a2

		movea.l	FONTDATACOLORGFX(a1),a3
		bsr.s	fontDataAddCounter
		add.w	d0,d0
		adda.w	d0,a3

		move.w	lineoffset,d7

		move.w	FONTDATAWIDTH(a1),d4
		move.w	FONTDATAHEIGHT(a1),d5
		subq.w	#1,d4
		subq.w	#1,d5
dtolLoop1	move.w	d4,d6
		movea.l	a6,a5
dtolLoop2	
		tst.w	(a2,d6.w*2)
		beq.s	dtolSkipPixel

		move.w	(a3,d6.w*2),d3
		move.w	d3,(a5,d6.w*2)
dtolSkipPixel
		dbra	d6,dtolLoop2
		adda.w	FONTDATAMASKLINEOFFSET(a1),a2
		adda.w	FONTDATACOLORLINEOFFSET(a1),a3
		adda.w	d7,a6
		dbra	d5,dtolLoop1

dtolOut
		rts


; ---------------------------------------------------------
; 02.06.00/vk
; erhoeht den fontdatacounter und gibt den aktuellen wert
; in d0 zurueck.
; a1 = fontdata
; rueckgabe: d0 = counterwert
;            a1 unveraendert
; rettet alle register
fontDataAddCounter
		move.w	FONTDATACOUNTER(a1),d0
		bmi.s	fdacNoCounter
		addq.w	#1,d0
		cmp.w	FONTDATACOUNTERMAX(a1),d0
		blt.s	fdacOk
		moveq	#0,d0
fdacOk		move.w	d0,FONTDATACOUNTER(a1)
		bra.s	fdacOut
fdacNoCounter	moveq	#0,d0
fdacOut		rts




		data


fontDataRed8x8		dc.w	0
			dc.w	8,8
			dc.l	fdred8x8MaskGfx
			dc.w	63*8*2
			dc.l	fdred8x8ColorGfx
			dc.w	20*8*2
			dc.l	fdred8x8GfxOffset
			dc.w	0
			dc.w	152

fdred8x8MaskGfx		incbin	"include\fonts\message.rbf"
fdred8x8ColorGfx	incbin	"include\fonts\f8col20.rbf"
fdred8x8GfxOffset	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,656,672,816,688,704,720,-1,752,768,912,896,944,976,960,736
			dc.w	464,480,496,512,528,544,560,576,592,608,848,832,624,784,640,800
			dc.w	-1,0,16,32,48,64,80,96,112,128,144,160,176,192,208,224
			dc.w	240,256,272,288,304,320,336,352,368,384,400,-1,880,-1,-1,992
			dc.w	-1,0,16,32,48,64,80,96,112,128,144,160,176,192,208,224
			dc.w	240,256,272,288,304,320,336,352,368,384,400,-1,864,-1,928,-1
			dc.w	-1,448,-1,-1,416,-1,-1,-1,-1,-1,-1,-1,-1,-1,416,-1
			dc.w	-1,-1,-1,-1,432,-1,-1,-1,-1,432,448,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1



		bss




