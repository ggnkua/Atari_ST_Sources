


		text


; ---------------------------------------------------------
; tastatureingaben waehrend des spiels am laptop taetigen
; (z. B. groessenaenderungen)
laptopKeyHit
		lea	keyoverlay,a0
		lea	keytable,a1

		move.w	KOLAPTOPINPUTMODE(a0),d0	; texteingabemodus fuer laptop?
		tst.b	(a1,d0.w)
		beq.s	lkhNoInputMode
		movem.l	a0-a1,-(sp)
		bsr	laptopInputModeControl
		movem.l	(sp)+,a0-a1
lkhNoInputMode

		move.w	KOLAPTOPONOFF(a0),d0
		tst.b	(a1,d0.w)			; wird laptop ein- oder ausgeschaltet?
		beq.s	lkhNoOnOff			; nein -> ueberspringen
		movem.l	a0-a1,-(sp)
		bsr	laptopOnOff
		movem.l	(sp)+,a0-a1
lkhNoOnOff

		tst.w	laptopFlag			; laptop jetzt aktiv?
		beq.s	lkhOut				; nein -> dann keine weiteren eingaben moeglich

		move.w	KOCOMPRESSLAPTOP(a0),d0
		tst.b	(a1,d0.w)
		beq.s	lkhNoCompress
		movem.l	a0-a1,-(sp)
		bsr	compressLaptop
		movem.l	(sp)+,a0-a1
lkhNoCompress
		move.w	KOEXPANDLAPTOP(a0),d0
		tst.b	(a1,d0.w)
		beq.s	lkhNoExpand
		movem.l	a0-a1,-(sp)
		bsr	expandLaptop
		movem.l	(sp)+,a0-a1
lkhNoExpand

lkhOut
		rts


; ---------------------------------------------------------
; 01.06.00/vk
laptopInputModeControl

		lea	laptop,a0
		lea	laptopFlag,a1
		move.w	LAPTOPX(a0),-(sp)		; aktuelle breite und hoehe zwischenspeichern
		move.w	LAPTOPY(a0),-(sp)
		move.w	(a1),-(sp)			; laptopflag zwischenspeichern

		clr.w	(a1)				; laptop ausschalten ...
		bsr	laptopShowBig			; ... damit er jetzt ganz gross aufgemacht werden kann
		bsr	laptopInputMode			; hauptroutine fuer laptopeingaben aufrufen

		lea	laptop,a0
		lea	laptopFlag,a1
		move.w	(sp)+,(a1)			; vorherigen zustand wiederherstellen
		move.w	(sp)+,LAPTOPY(a0)
		move.w	(sp)+,LAPTOPX(a0)
		bsr	laptopCalcDimensions		; todo: verschiebung der textzeilen/cursorposition

		bsr	setFlagToClearBackground	; falls laptop deaktiviert, zur sicherheit hintergrund loeschen

		rts


; ---------------------------------------------------------
; 22.05.00/vk
; laptopanzeige ein- und ausschalten.
; a1 = tastaturstatus
laptopOnOff	clr.b	(a1,d0.w)
		lea	laptopFlag,a0			; .\ldsvarea.s
		move.w	(a0),d0
		beq.s	looSwitchOn
looSwitchOff	moveq	#0,d0
		bsr	setFlagToClearBackground	; .\gfxrouts\backgrnd.s
		bra.s	looSwitchOk
looSwitchOn	moveq	#1,d0
looSwitchOk	move.w	d0,(a0)
		rts


; ---------------------------------------------------------
; laptop anzeigefeld verkleinern
; a0 = keyboard overlay
; a1 = tastaturstatus
compressLaptop
		lea	laptop,a5
		move.w	LAPTOPX(a5),d0			; aktuelle breite und hoehe holen
		move.w	LAPTOPY(a5),d1

		moveq	#1,d2				; um diese werte wollen wir aendern
		moveq	#1,d3

		move.w	KOCOMPRESSEXPANDLAPTOPY(a0),d4	
		tst.b	(a1,d4.w)
		beq.s	clXOk
		clr.w	d2
clXOk		move.w	KOCOMPRESSEXPANDLAPTOPX(a0),d4
		tst.b	(a1,d4.w)
		beq.s	clYOk
		clr.w	d3
clYOk		sub.w	d2,d0				; wenn x richtung zu veraendern, dann ist d2 = 1
		sub.w	d3,d1				; wenn y richtung zu veraendern, dann ist d3 = 1

		movea.l	LAPTOPFONTDATAPTR(a5),a6	; anzeigefeld darf nicht zu klein werden
		move.w	LFMINX(a6),d4
		move.w	LFMINY(a6),d5

		cmp.w	d4,d0
		bge.s	clWidthOk
		move.w	d4,d0
clWidthOk	cmp.w	d5,d1
		bge.s	clHeightOk
		move.w	d5,d1
		moveq	#0,d3				; dann auch dy wieder auf null setzen
clHeightOk	

		tst.w	d3				; soll das anzeigefeld tatsaechlich verkleinert (in y richtung)
		beq.s	clNoShift			; werden, dann vorher den inhalt um eine zeile nach
		bsr	laptopShiftUpOneRow		; oben verschieben...
clNoShift

		move.w	d0,LAPTOPX(a5)			; ...bevor die neue groesse gesetzt wird
		move.w	d1,LAPTOPY(a5)

		bsr	laptopCalcDimensions		; todo: verschiebung der textzeilen/cursorposition

		bsr	setFlagToClearBackground

		rts


; ---------------------------------------------------------
; laptop anzeigefeld (textfeld) vergroessern
; a0 = keyboard overlay
; a1 = tastaturstatus
expandLaptop
		lea	laptop,a5
		move.w	LAPTOPX(a5),d0				; aktuelle groessen in buchstaben
		move.w	LAPTOPY(a5),d1				; ... und zeilen

		moveq	#1,d2					; um diese offsets wollen wir (anfangs) aendern
		moveq	#1,d3

		move.w	KOCOMPRESSEXPANDLAPTOPY(a0),d4
		tst.b	(a1,d4.w)
		beq.s	elXOk
		clr.w	d2
elXOk		move.w	KOCOMPRESSEXPANDLAPTOPX(a0),d4
		tst.b	(a1,d4.w)
		beq.s	elYOk
		clr.w	d3
elYOk		add.w	d2,d0
		add.w	d3,d1

		movea.l	LAPTOPFONTDATAPTR(a5),a6
		move.w	LFMAXX(a6),d4
		move.w	LFMAXY(a6),d5

		cmp.w	d4,d0
		bls.s	elWidthOk
		move.w	d4,d0
elWidthOk	cmp.w	d5,d1
		bls.s	elHeightOk
		move.w	d5,d1
		moveq	#0,d3
elHeightOk	

		move.w	d0,LAPTOPX(a5)
		move.w	d1,LAPTOPY(a5)

		move.w	d3,-(sp)
		bsr	laptopCalcDimensions		; neue dimensionen berechnen, bevor andere routinen ablaufen
		move.w	(sp)+,d3
		beq.s	elNoShift
		bsr	laptopShiftDownOneRow		; inhalt um eine zeile nach unten verschieben...
elNoShift
		move.w	#1,clearBackgroundFlag
				
		rts



