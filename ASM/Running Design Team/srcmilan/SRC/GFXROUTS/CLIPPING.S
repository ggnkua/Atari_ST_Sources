
		rsreset
CLIPPINGMAXX	rs.w	1
CLIPPINGMAXY	rs.w	1
CLIPPINGBYTES	rs.w	1



		text


; ---------------------------------------------------------
; lineWithClipping
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = lineoffset
; d7 = color
; a0 = screenadresse
; clippingData muss gesetzt sein

lineWithClipping

		lea	clippingData,a1

		cmp.w	d0,d2
		beq	lwcClipVertical
		cmp.w	d1,d3
		beq	lwcClipHorizontal

lwcNormalLine

	; window code fuer punkt 1 nach d5

		moveq	#0,d5

		move.w	d0,d5			; xmin
		add.l	d5,d5
		move.w	CLIPPINGMAXX(a1),d5	; xmax
		sub.w	d0,d5
		add.l	d5,d5
		move.w	d1,d5			; ymin
		add.l	d5,d5
		move.w	CLIPPINGMAXY(a1),d5	; ymax
		sub.w	d1,d5
		add.l	d5,d5
		swap	d5

	; window code fuer punkt 2 nach d6

		moveq	#0,d6

		move.w	d2,d6			; xmin
		add.l	d6,d6
		move.w	CLIPPINGMAXX(a1),d6	; xmax
		sub.w	d2,d6
		add.l	d6,d6
		move.w	d3,d6			; ymin
		add.l	d6,d6
		move.w	CLIPPINGMAXY(a1),d6	; ymax
		sub.w	d3,d6
		add.l	d6,d6
		swap	d6

		movea.w	d4,a3			; lineoffset
		move.w	d7,a4			; color

		move.w	d6,d7
		and.w	d5,d7
		bne	lwcOut			; linie nicht sichtbar

lwcClippingNow

	; bits:
	; 0 = oben
	; 1 = unten
	; 2 = rechts
	; 3 = links

	; clipping fuer punkt 1

		tst.w	d5			; muss geclippt werden?
		beq	lwccnPoint2

		btst	#3,d5
		beq.s	lwccnP1LeftOk

		move.w	d2,d4		; x2
		sub.w	d0,d4		; d4 = dx
		move.w	d3,d7		; y2
		sub.w	d1,d7		; d7 = dy

		move.w	d2,d0
		muls	d7,d0
		divs	d4,d0

		move.w	d3,d1
		sub.w	d0,d1
		moveq	#0,d0
lwccnP1LeftOk

		btst	#2,d5
		beq.s	lwccnP1RightOk

		move.w	d3,d7
		sub.w	d1,d7		; dy
		move.w	d0,d4
		sub.w	d2,d4		; dx

		move.w	CLIPPINGMAXX(a1),d0
		sub.w	d2,d0
		muls	d7,d0
		divs	d4,d0

		move.w	d3,d1
		sub.w	d0,d1
		move.w	CLIPPINGMAXX(a1),d0
lwccnP1RightOk

		btst	#1,d5
		beq.s	lwccnP1DownOk
		tst.w	d1
		bpl.s	lwccnP1DownOk

		move.w	d3,d7
		sub.w	d1,d7		; dy
		move.w	d2,d4
		sub.w	d0,d4		; dx

		neg.w	d1
		muls	d4,d1
		divs	d7,d1

		add.w	d1,d0
		moveq	#0,d1
lwccnP1DownOk

		btst	#0,d5
		beq.s	lwccnP1UpOk
		cmp.w	CLIPPINGMAXY(a1),d1
		blt.s	lwccnP1UpOk

		move.w	d1,d7
		sub.w	d3,d7		; dy
		move.w	d2,d4
		sub.w	d0,d4		; dx

		sub.w	CLIPPINGMAXY(a1),d1
		muls	d4,d1
		divs	d7,d1

		add.w	d1,d0
		move.w	CLIPPINGMAXY(a1),d1
lwccnP1UpOk

	; window code fuer punkt 1 nach d5 (neu berechnen)

		moveq	#0,d5

		move.w	d0,d5			; xmin
		add.l	d5,d5
		move.w	CLIPPINGMAXX(a1),d5	; xmax
		sub.w	d0,d5
		add.l	d5,d5
		move.w	d1,d5			; ymin
		add.l	d5,d5
		move.w	CLIPPINGMAXY(a1),d5	; ymax
		sub.w	d1,d5
		add.l	d5,d5
		swap	d5

		and.w	d6,d5
		bne	lwcOut			; linie nicht sichtbar

lwccnPoint2

	; clipping fuer punkt 2

		tst.w	d6			; muss geclippt werden?
		beq	lwcClipDone		; nein, ueberspringen und zeichnen...

		btst	#3,d6
		beq.s	lwccnP2LeftOk

		move.w	d1,d7
		sub.w	d3,d7		; dy
		move.w	d0,d4
		sub.w	d2,d4		; dx

		move.w	d0,d2
		muls	d7,d2
		divs	d4,d2

		move.w	d1,d3
		sub.w	d2,d3
		moveq	#0,d2
lwccnP2LeftOk

		btst	#2,d6
		beq.s	lwccnP2RightOk

		move.w	d1,d7
		sub.w	d3,d7		; dy
		move.w	d2,d4
		sub.w	d0,d4		; dx

		move.w	CLIPPINGMAXX(a1),d2
		sub.w	d0,d2
		muls	d7,d2
		divs	d4,d2

		move.w	d1,d3
		sub.w	d2,d3
		move.w	CLIPPINGMAXX(a1),d2
lwccnP2RightOk

		btst	#1,d6
		beq.s	lwccnP2UpOk

		move.w	d1,d7
		sub.w	d3,d7
		move.w	d2,d4
		sub.w	d0,d4

		move.w	d1,d3
		muls	d4,d3
		divs	d7,d3

		move.w	d0,d2
		add.w	d3,d2
		moveq	#0,d3

		tst.w	d2
		bmi.s	lwcOut			; clipping failed -> linie nicht sichtbar
		cmp.w	CLIPPINGMAXX(a1),d2
		bgt.s	lwcOut
		bra.s	lwcClipDone
lwccnP2UpOk

		btst	#0,d6
		beq.s	lwccnP2DownOk

		move.w	d3,d7
		sub.w	d1,d7
		move.w	d0,d4
		sub.w	d2,d4

		sub.w	CLIPPINGMAXY(a1),d3
		muls	d4,d3
		divs	d7,d3

		add.w	d3,d2
		move.w	CLIPPINGMAXY(a1),d3

		tst.w	d2
		bmi.s	lwcOut			; clipping failed -> linie nicht sichtbar
		cmp.w	CLIPPINGMAXX(a1),d2
		bgt.s	lwcOut
lwccnP2DownOk

lwcClipDone
		move.w	a3,d4
		move.w	a4,d7

		bsr	drawLine
		rts

lwcOut
		move.w	a3,d4
		move.w	a4,d7

		rts



lwcClipVertical

	; gleiche x-koordinaten

		tst.w	d0			; linie links draussen?
		bmi	lwccOut			; ja -> raus
		cmp.w	CLIPPINGMAXX(a1),d0	; linie rechts draussen?
		bgt	lwccOut			; ja -> raus

		cmp.w	d1,d3			; verlaeuft linie von unten nach oben (d3 ist groesser)?
		bgt.s	lwccvUp			; ja -> dann ueberspringen
		exg	d1,d3

lwccvUp		tst.w	d3			; hoehere koordinate zu tief?
		bmi	lwccOut			; ja -> raus
		cmp.w	CLIPPINGMAXY(a1),d3	; zu hoch?
		ble.s	lwccvP1Ok		; nein -> normal weiter
		move.w	CLIPPINGMAXY(a1),d3	; andernfalls auf maximalwert setzen
lwccvP1Ok
		cmp.w	CLIPPINGMAXY(a1),d1	; untere koordinate zu hoch?
		bgt.s	lwccOut
		tst.w	d1
		bpl.s	lwccClipDone
		moveq	#0,d1
		bra.s	lwccClipDone

lwcClipHorizontal

	; gleiche y-koordinaten

		tst.w	d1			; linie unten draussen?
		bmi	lwccOut			; ja -> raus
		cmp.w	CLIPPINGMAXY(a1),d1	; linie oben draussen?
		bgt	lwccOut			; ja -> raus

		cmp.w	d0,d2			; verlaeuft linie von links nach rechts (d2 ist groesser)?
		bgt.s	lwcchRight		; ja -> dann ueberspringen
		exg	d0,d2
lwcchRight
		tst.w	d2			; rechte koordinate links draussen?
		bmi	lwccOut			; ja -> raus
		cmp.w	CLIPPINGMAXX(a1),d2	; zu weit links?
		ble.s	lwcchP1Ok		; nein -> normal weiter
		move.w	CLIPPINGMAXX(a1),d2	; andernfalls auf maximalwert setzen
lwcchP1Ok
		cmp.w	CLIPPINGMAXX(a1),d0	; linke koordinate zu weit rechts draussen?
		bgt.s	lwccOut
		tst.w	d0
		bpl.s	lwccClipDone
		moveq	#0,d0

lwccClipDone
		bsr	drawLine
lwccOut
		rts



		data




		bss


clippingData	ds.b	CLIPPINGBYTES