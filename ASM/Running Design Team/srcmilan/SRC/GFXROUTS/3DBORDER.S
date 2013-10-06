
; struktur border3ddata
BORDER3DBITMAPNWPTR	equ	0	; pointer oder (void/nullpointer) bei nichtexistenz
BORDER3DBITMAPNNWPTR	equ	4
BORDER3DBITMAPNPTR	equ	8
BORDER3DBITMAPNNEPTR	equ	12
BORDER3DBITMAPNEPTR	equ	16
BORDER3DBITMAPNEEPTR	equ	20
BORDER3DBITMAPEPTR	equ	24
BORDER3DBITMAPSEEPTR	equ	28
BORDER3DBITMAPSEPTR	equ	32
BORDER3DBITMAPSSEPTR	equ	36
BORDER3DBITMAPSPTR	equ	40
BORDER3DBITMAPSSWPTR	equ	44
BORDER3DBITMAPSWPTR	equ	48
BORDER3DBITMAPSWWPTR	equ	52
BORDER3DBITMAPWPTR	equ	56
BORDER3DBITMAPNWWPTR	equ	60



		text


; ---------------------------------------------------------
; 08.01.00/vk
; zeichnet einen (3d) rahmen um das u. a. fenster herum.
; um das fenster muss genuegend platz zum zeichnen sein,
; es wird nicht mit den bildschirmgrenzen geclippt.
; mit draw3dbordercalcspace() kann z. b. vorher festgestellt
; werden, ob die 3d border vollstaendig sichtbar ist (d. h. ob
; genuegend platz zur anzeige des rahmens existiert).
; a0 = screenadresse (screen_1 oder screen_2)
; a1 = pointer auf datenstruktur border3ddata
; d0 = x (linke obere ecke)
; d1 = y (linke obere ecke)
; d2 = dx (breite in pixel)
; d3 = dy (hoehe in pixel)
draw3dBorder

	; linke obere ecke (nw)
		movea.l	BORDER3DBITMAPNWPTR(a1),a2
		move.w	d0,d6
		sub.w	BITMAPWIDTH(a2),d6
		move.w	d1,d7
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt		

	; oberes rahmenteil (n)
		movea.l	BORDER3DBITMAPNNWPTR(a1),a2
		move.w	BITMAPWIDTH(a2),d4
		beq.s	d3bNoNnw
		move.w	d0,d6
		move.w	d1,d7
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt
d3bNoNnw
		movea.l	BORDER3DBITMAPNNEPTR(a1),a2
		move.w	BITMAPWIDTH(a2),d5
		beq.s	d3bNoNne
		move.w	d0,d6
		add.w	d2,d6
		sub.w	d5,d6
		move.w	d1,d7
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt
d3bNoNne
		move.w	d2,d6				; breite kopieren
		sub.w	d4,d6				; bereits gezeichnete "eck"-teile abziehen
		sub.w	d5,d6
		bmi.s	d3bNoNorthLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen
		beq.s	d3bNoNorthLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen

		move.w	d6,d5				; d5 = breite des noch zu zeichnenden rahmenteils

		movea.l	BORDER3DBITMAPNPTR(a1),a2
		move.w	d0,d6
		add.w	d4,d6				; d6 = x-position
		move.w	d1,d7
		sub.w	BITMAPHEIGHT(a2),d7		; d7 = y-position

		bsr	d3bHorizontalStretch

d3bNoNorthLine

	; rechte obere ecke (ne)
		movea.l	BORDER3DBITMAPNEPTR(a1),a2
		move.w	d0,d6
		add.w	d2,d6
		move.w	d1,d7
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt		

	; rechtes rahmenteil (e)
		movea.l	BORDER3DBITMAPNEEPTR(a1),a2
		move.w	d0,d6
		add.w	d2,d6
		move.w	BITMAPHEIGHT(a2),d4
		beq.s	d3bNoNee
		move.w	d1,d7
		bsr	bitBlt
d3bNoNee
		movea.l	BORDER3DBITMAPSEEPTR(a1),a2
		move.w	d0,d6
		add.w	d2,d6
		move.w	BITMAPHEIGHT(a2),d5
		beq.s	d3bNoSee
		move.w	d1,d7
		add.w	d3,d7
		sub.w	d5,d7
		bsr	bitBlt
d3bNoSee
		move.w	d3,d6				; hoehe kopieren
		sub.w	d4,d6				; bereits gezeichnete "eck"-teile abziehen
		sub.w	d5,d6
		bmi.s	d3bNoEastLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen
		beq.s	d3bNoEastLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen

		move.w	d1,d7
		add.w	d4,d7				; d7 = y-position

		move.w	d6,d4				; d4 = hoehe des noch zu zeichnenden rahmenteils

		movea.l	BORDER3DBITMAPEPTR(a1),a2
		move.w	d0,d6
		add.w	d2,d6				; d6 = x-position

		bsr	d3bVerticalStretch

d3bNoEastLine

	; rechte untere ecke (se)
		movea.l	BORDER3DBITMAPSEPTR(a1),a2
		move.w	d0,d6
		add.w	d2,d6
		move.w	d1,d7
		add.w	d3,d7
		bsr	bitBlt		

	; unteres rahmenteil (s)
		movea.l	BORDER3DBITMAPSSWPTR(a1),a2
		move.w	BITMAPWIDTH(a2),d4
		beq.s	d3bNoSsw
		move.w	d0,d6
		move.w	d1,d7
		add.w	d3,d7
		bsr	bitBlt
d3bNoSsw
		movea.l	BORDER3DBITMAPSSEPTR(a1),a2
		move.w	BITMAPWIDTH(a2),d5
		beq.s	d3bNoSse
		move.w	d0,d6
		add.w	d2,d6
		sub.w	d5,d6
		move.w	d1,d7
		add.w	d3,d7
		bsr	bitBlt
d3bNoSse
		move.w	d2,d6				; breite kopieren
		sub.w	d4,d6				; bereits gezeichnete "eck"-teile abziehen
		sub.w	d5,d6
		bmi.s	d3bNoSouthLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen
		beq.s	d3bNoSouthLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen

		move.w	d6,d5				; d5 = breite des noch zu zeichnenden rahmenteils

		movea.l	BORDER3DBITMAPSPTR(a1),a2
		move.w	d0,d6
		add.w	d4,d6				; d6 = x-position
		move.w	d1,d7
		add.w	d3,d7				; d7 = y-position

		bsr	d3bHorizontalStretch

d3bNoSouthLine

	; linke untere ecke (sw)
		movea.l	BORDER3DBITMAPSWPTR(a1),a2
		move.w	d0,d6
		sub.w	BITMAPWIDTH(a2),d6
		move.w	d1,d7
		add.w	d3,d7
		bsr	bitBlt		

	; linkes rahmenteil (w)
		movea.l	BORDER3DBITMAPNWWPTR(a1),a2
		move.w	d0,d6
		sub.w	BITMAPWIDTH(a2),d6
		move.w	BITMAPHEIGHT(a2),d4
		beq.s	d3bNoNww
		move.w	d1,d7
		bsr	bitBlt
d3bNoNww
		movea.l	BORDER3DBITMAPSWWPTR(a1),a2
		move.w	d0,d6
		sub.w	BITMAPWIDTH(a2),d6
		move.w	BITMAPHEIGHT(a2),d5
		beq.s	d3bNoSww
		move.w	d1,d7
		add.w	d3,d7
		sub.w	d5,d7
		bsr	bitBlt
d3bNoSww
		move.w	d3,d6				; hoehe kopieren
		sub.w	d4,d6				; bereits gezeichnete "eck"-teile abziehen
		sub.w	d5,d6
		bmi.s	d3bNoWestLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen
		beq.s	d3bNoWestLine			; noch rahmenteil vorhanden? nein -> dann ueberspringen

		move.w	d1,d7
		add.w	d4,d7				; d7 = y-position

		move.w	d6,d4				; d4 = hoehe des noch zu zeichnenden rahmenteils

		movea.l	BORDER3DBITMAPWPTR(a1),a2
		move.w	d0,d6
		sub.w	BITMAPWIDTH(a2),d6		; d6 = x-position

		bsr	d3bVerticalStretch

d3bNoWestLine


		rts


; ---------------------------------------------------------
; 09.01.00/vk
; zeichnet die horizontale stretch-bitmap des rahmens.
; d5 = breite des noch zu zeichnenden rahmenteils
; d6 = x-position
; d7 = y-position
; a0 = screenadresse
; a2 = pointer auf stretch-bitmap
; alle register werden gerettet.
d3bHorizontalStretch

		movem.l	d4-d6,-(sp)

		move.w	BITMAPWIDTH(a2),d4		; d4 = breite der stretch-bitmap
d3bhsLoop
		cmp.w	d5,d4				; kann noch eine volle "kachel" gezeichnet werden?
		blt.s	d3bhsFullTile			; ja -> dann verzweigen

		move.w	d5,d4				; noch zu zeichnende breite nach d4
		move.w	BITMAPHEIGHT(a2),d5		; hoehe nach d5 (entspricht der originalhoehe der textur)
		bsr	bitBltSize
		bra.s	d3bhsSkip			; ... und raus
d3bhsFullTile
		bsr	bitBlt
		sub.w	d4,d5
		add.w	d4,d6
		bra.s	d3bhsLoop

d3bhsSkip
		movem.l	(sp)+,d4-d6
		rts


; ---------------------------------------------------------
; 09.01.00/vk
; zeichnet die vertikale stretch-bitmap des rahmens.
; d4 = hoehe des noch zu zeichnenden rahmenteils
; d6 = x-position
; d7 = y-position
; a0 = screenadresse
; a2 = pointer auf stretch-bitmap
; alle register werden gerettet.
d3bVerticalStretch

		movem.l	d4-d7,-(sp)

		move.w	BITMAPHEIGHT(a2),d5		; d5 = hoehe der stretch-bitmap
d3bvsLoop
		cmp.w	d4,d5				; kann noch eine volle "kachel" gezeichnet werden?
		blt.s	d3bvsFullTile			; ja -> dann verzweigen

		move.w	d4,d5				; noch zu zeichnende hoehe nach d4
		move.w	BITMAPWIDTH(a2),d4		; breite nach d4 (entspricht der originalbreite der textur)
		bsr	bitBltSize
		bra.s	d3bvsSkip			; ... und raus
d3bvsFullTile
		bsr	bitBlt
		sub.w	d5,d4
		add.w	d5,d7
		bra.s	d3bvsLoop

d3bvsSkip
		movem.l	(sp)+,d4-d7
		rts


; ---------------------------------------------------------
; 20.05.00/vk
; berechnet, ob genuegend randbereich zum zeichnen der
; angegebenen border vorhanden ist.
; d0 = x (position des inneren fensterbereichs)
; d1 = y
; d2 = dx (breite des innenrahmens)
; d3 = dy (hoehe des innenrahmens)
; a2 = border3d-datenstruktur
; rueckgabe: d0 = 0 (platz vorhanden), -1 (kein platz vorhanden)
; alle register werden gerettet.
border3dCalcSpace

		movem.l	d4/d7/a1/a3-a6,-(sp)

		movea.l	BORDER3DBITMAPNWPTR(a2),a1
		movea.l	BORDER3DBITMAPNNWPTR(a2),a3
		movea.l	BORDER3DBITMAPNPTR(a2),a4
		movea.l	BORDER3DBITMAPNNEPTR(a2),a5
		movea.l	BORDER3DBITMAPNEPTR(a2),a6
		move.w	#BITMAPHEIGHT,d6
		bsr	b3dcsCalcMaximum		; wieviel platz wird oben benoetigt? rueckgabe in d7

		cmp.w	d1,d7				; mit oben zur verfuegung stehenden platz vergleichen
		bgt.s	b3dcsNoSpace			; groesser? ja -> zur "fehlerroutine"

		movea.l	BORDER3DBITMAPSWPTR(a2),a1
		movea.l	BORDER3DBITMAPSSWPTR(a2),a3
		movea.l	BORDER3DBITMAPSPTR(a2),a4
		movea.l	BORDER3DBITMAPSEPTR(a2),a5
		movea.l	BORDER3DBITMAPSEPTR(a2),a6
		bsr	b3dcsCalcMaximum		

		move.w	height,d4
		sub.w	d1,d4
		sub.w	d3,d4
		cmp.w	d4,d7
		bgt.s	b3dcsNoSpace

		movea.l	BORDER3DBITMAPNEPTR(a2),a1
		movea.l	BORDER3DBITMAPNEEPTR(a2),a3
		movea.l	BORDER3DBITMAPEPTR(a2),a4
		movea.l	BORDER3DBITMAPSEEPTR(a2),a5
		movea.l	BORDER3DBITMAPSEPTR(a2),a6
		move.w	#BITMAPWIDTH,d6
		bsr	b3dcsCalcMaximum		

		move.w	width,d4
		sub.w	d0,d4
		sub.w	d2,d4
		cmp.w	d4,d7
		bgt.s	b3dcsNoSpace

		movea.l	BORDER3DBITMAPNWPTR(a2),a1
		movea.l	BORDER3DBITMAPNWWPTR(a2),a3
		movea.l	BORDER3DBITMAPWPTR(a2),a4
		movea.l	BORDER3DBITMAPSWWPTR(a2),a5
		movea.l	BORDER3DBITMAPSWPTR(a2),a6
		bsr	b3dcsCalcMaximum		

		cmp.w	d0,d7
		bgt.s	b3dcsNoSpace

		moveq	#0,d0
		bra.s	b3dcsOut

b3dcsNoSpace
		moveq	#-1,d0
b3dcsOut
		movem.l	(sp)+,d4/d7/a1/a3-a6
		rts


; ---------------------------------------------------------
; 20.05.00/vk
; berechnet fuer die fuenf uebergebenen bitmaps den maximalen
; breiten- oder hoehenwert.
; d6 = offset fuer breite oder hoehe innerhalb der bitmap-struktur
; a1 = bitmap 1
; a3 = bitmap 2
; a4 = bitmap 3
; a5 = bitmap 4
; a6 = bitmap 5
; rueckgabe: d7 = maximaler breiten- oder hoehenwert
; alle register werden gerettet.
b3dcsCalcMaximum

		moveq	#0,d7			; maximum initialisieren
		cmp.w	(a1,d6.w),d7
		bgt.s	b3dcscmNo1
		move.w	(a1,d6.w),d7
b3dcscmNo1	cmp.w	(a3,d6.w),d7
		bgt.s	b3dcscmNo2
		move.w	(a3,d6.w),d7
b3dcscmNo2	cmp.w	(a4,d6.w),d7
		bgt.s	b3dcscmNo3
		move.w	(a4,d6.w),d7
b3dcscmNo3	cmp.w	(a5,d6.w),d7
		bgt.s	b3dcscmNo4
		move.w	(a5,d6.w),d7
b3dcscmNo4	cmp.w	(a6,d6.w),d7
		bgt.s	b3dcscmNo5
		move.w	(a6,d6.w),d7
b3dcscmNo5
		rts




		data


; ---------------------------------------------------------
; definition der umrandung des hauptfensters (main)
border3dMain
		dc.l	bmpMainNw
		dc.l	bmpNull
		dc.l	bmpMainN
		dc.l	bmpNull
		dc.l	bmpMainNe
		dc.l	bmpMainNee
		dc.l	bmpMainE
		dc.l	bmpMainSee
		dc.l	bmpMainSe
		dc.l	bmpMainSse
		dc.l	bmpMainS
		dc.l	bmpNull
		dc.l	bmpMainSw
		dc.l	bmpMainSww
		dc.l	bmpMainW
		dc.l	bmpMainNww


; ---------------------------------------------------------
; definition der umrandung der extra-karte (map)
border3dExtraMap
		dc.l	bmpExtraMapUl		; bitmaps in .\src\gfxrouts\bitmpdef.s definiert
		dc.l	bmpNull
		dc.l	bmpExtraMapUs
		dc.l	bmpNull
		dc.l	bmpExtraMapUr
		dc.l	bmpNull
		dc.l	bmpExtraMapRs
		dc.l	bmpNull
		dc.l	bmpExtraMapDr
		dc.l	bmpNull
		dc.l	bmpExtraMapDs
		dc.l	bmpNull
		dc.l	bmpExtraMapDl
		dc.l	bmpNull
		dc.l	bmpExtraMapLs
		dc.l	bmpNull



