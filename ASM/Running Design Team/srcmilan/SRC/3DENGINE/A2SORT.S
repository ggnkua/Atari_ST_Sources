

		text


; ---------------------------------------------------------
; 21.04.00/vk
; sortiert die in a2calclines als sichtbar eingetragenen
; linien von hinten nach vorne.
; a2linex1 etc. muss bereits gesetzt sein.
c3pA2SortLines
		move.w	a2NbCalcLines,d7		; anzahl linien
		subq.w	#2,d7				; sind mindestens zwei linien vorhanden?
		bmi.s	c3pa2slOut			; nein -> dann auch nichts zu sortieren und raus

		lea	a2CalcLinesPtr,a5		; pointerarray holen
c3pa2slLoop
		lea	4(a5),a6

		movea.l	(a5)+,a0			; erste vergleichslinie holen
		move.w	d7,d6
c3pa2slInnerLoop
		movea.l	(a6)+,a1			; zweite linie

		movem.l	d6-d7/a0-a1/a5-a6,-(sp)
		bsr.s	c3pa2slInFrontOrBehind		; linien in a0/a1
		movem.l	(sp)+,d6-d7/a0-a1/a5-a6

		tst.w	d0
		bne.s	c3pa2slNoChange

		movea.l	-4(a5),a0			; pointer auf a2lines vertauschen
		move.l	-4(a6),-4(a5)
		move.l	a0,-4(a6)

c3pa2slNoChange
		dbra	d6,c3pa2slInnerLoop
		dbra	d7,c3pa2slLoop

c3pa2slOut
		rts


; ---------------------------------------------------------
; 21.04.00/vk
; a0 = zeiger auf a2-liniendaten in a2calclines (1. linie)
; a1 = zeiger auf a2-liniendaten in a2calclines (2. linie)
; rueckgabe: d0 = 0 (a0 vor a1), 1 = (a0 hinter h1)
c3pa2slInFrontOrBehind

		move.l	A2LINEX1(a0),d0
		add.l	A2LINEX2(a0),d0
		asr.l	#1,d0

		move.l	A2LINEX1(a1),d1
		add.l	A2LINEX2(a1),d1
		asr.l	#1,d1

		cmp.l	d0,d1
		bgt	c3pa2slifobInFront
		bra	c3pa2slifobBehind




		bsr.s	c3pa2slifobLeftOrRight			; d0: 0 = links von p0/p1, 1 = rechts von p0/p1, -1 = links/rechts
		tst.w	d0
		bmi.s	c3pa2slifobChangeLines
		beq.s	c3pa2slifobLeft

c3pa2slifobRight
		tst.w	A2LINEDY(a0)
		bpl.s	c3pa2slifobInFront			; a0 ist dann vor a1 zu zeichnen
		bra.s	c3pa2slifobBehind

c3pa2slifobLeft
		tst.w	A2LINEDY(a0)
		bpl.s	c3pa2slifobBehind			; a0 ist dann hinter a1 zu zeichnen
		bra.s	c3pa2slifobInFront

c3pa2slifobChangeLines

		exg	a0,a1
		bsr.s	c3pa2slifobLeftOrRight
		tst.w	d0
		beq.s	c3pa2slifobLeft2

c3pa2slifobRight2
		tst.w	A2LINEDY(a0)
		bpl.s	c3pa2slifobInFront			; a0 ist dann vor a1 zu zeichnen
		bra.s	c3pa2slifobBehind

c3pa2slifobLeft2
		tst.w	A2LINEDY(a0)
		bpl.s	c3pa2slifobBehind			; a0 ist dann hinter a1 zu zeichnen
		bra.s	c3pa2slifobInFront


c3pa2slifobBehind
		moveq	#1,d0
		bra.s	c3pa2slifobOut

c3pa2slifobInFront
		moveq	#0,d0

c3pa2slifobOut
		rts


; ---------------------------------------------------------
; a0 = a2line 1
; a1 = a2line 2
; rueckgabe: d0: 0 = a1 links von a0, 1 = a1 rechts von a0, -1 = a1 links/rechts von a0
c3pa2slifobLeftOrRight

		move.l	A2LINEDX(a0),d0
		move.l	A2LINEDY(a0),d1

		move.l	A2LINEX1(a1),d2
		move.l	A2LINEY1(a1),d3
		move.l	A2LINEX2(a1),d4
		move.l	A2LINEY2(a1),d5
		sub.l	A2LINEX1(a0),d2
		sub.l	A2LINEY1(a0),d3
		sub.l	A2LINEX1(a0),d4
		sub.l	A2LINEY1(a0),d5

		muls.w	d0,d3
		muls.w	d1,d2

		muls.w	d0,d5
		muls.w	d1,d4

		cmp.l	d3,d2
		bgt.s	c3pa2slifoblorRightTurn
		blt.s	c3pa2slifoblorLeftTurn

		cmp.l	d5,d4
		bgt.s	c3pa2slifoblorItsRight
		blt.s	c3pa2slifoblorItsLeft

		bra.s	c3pa2slifoblorItsRight		; egal was, fall duerfte gar nicht auftreten

c3pa2slifoblorRightTurn

		cmp.l	d5,d4
		blt.s	c3pa2slifoblorItsBoth
		bra.s	c3pa2slifoblorItsRight

c3pa2slifoblorLeftTurn

		cmp.l	d5,d4
		bgt.s	c3pa2slifoblorItsBoth
;		bra.s	c3pa2slifoblorItsLeft


c3pa2slifoblorItsLeft
		moveq	#0,d0
		bra.s	c3pa2slifoblorOut

c3pa2slifoblorItsRight
		moveq	#1,d0
		bra.s	c3pa2slifoblorOut

c3pa2slifoblorItsBoth
		moveq	#-1,d0

c3pa2slifoblorOut
		rts





		data





		bss