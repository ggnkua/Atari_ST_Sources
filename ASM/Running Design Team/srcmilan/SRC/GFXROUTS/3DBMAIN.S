


		text


; ---------------------------------------------------------
; 20.05.00/vk
; steuerungsroutine zum zeichnen des rahmens und das
; 3d fenster. diese routine wird pro haupt-programmschleife
; einmal aufgerufen. es wird gezeichnet, wenn
; d3dbmflag ungleich 0 ist. das zeichnen setzt die
; variable auf 0. durch clearbackground() wird die variable
; ggf. gesetzt.
draw3dBorderMainIfRequired

		lea	d3dbmFlag,a0
		tst.w	(a0)			; neuzeichnen erforderlich?
; todo		beq.s	d3dbmirOut		; nein -> routine beenden
		clr.w	(a0)			; flag setzen, beim naechsten durchlauf ist (i. d. R.) kein neuzeichnen notwendig

		bsr.s	draw3dBorderMain	; rahmen zeichnen, falls genuegend platz vorhanden
d3dbmirOut
		rts


; ---------------------------------------------------------
; 10.01.00/vk
; zeichnet um das 3d fenster (hauptansicht) eine 3d border,
; ist nicht genuegend randbereich vorhanden, in den die 3d border gezeichnet werden
; kann, so wird keine 3d border gezeichnet.
; die position der 3d border innerhalb des screens wird
; hier separat berechnet/bestimmt.
draw3dBorderMain

		moveq	#0,d7
		tst.w	doubleScan
		beq.s	d3dbmNoDoubleScan
		moveq	#1,d7
d3dbmNoDoubleScan

		lea	c3p,a5
		move.w	C3PWIDTH(a5),d2
		lsl.w	d7,d2				; d2 = breite des hauptfensters in pixeln
		move.w	C3PHEIGHT(a5),d3		; d3 = hoehe der hauptfensters in pixeln

		move.w	width,d0
		sub.w	d2,d0
		lsr.w	#1,d0				; d0 = x-position des hauptfensters

		move.w	height,d1
		sub.w	d3,d1
		lsr.w	#1,d1				; d1 = y-position des hauptfensters

		move.w	d0,d4				; zwischenspeichern, wert wird im positiven fall (zeichnen) benoetigt

		lea	border3dMain,a2
		bsr	border3dCalcSpace		; ist genuegend platz "aussenrum" zum zeichnen
		tst.w	d0				; der 3d border vorhanden?
		bmi.s	d3dbmOut			; nein -> raus

		movea.l	screen_1,a0			; in diesen screen zeichnen
		lea	border3dMain,a1			; diese 3d border zeichnen
		move.w	d4,d0				; x (y, dx, dy sind bereits in den korrekten registern)
		bsr	draw3dBorder			; und rahmen endgueltig zeichnen
d3dbmOut
		rts



		data


d3dbmFlag	dc.w	0			; 0 = kein neuzeichnen erforderlich
						; 1 = neuzeichnen erforderlich
