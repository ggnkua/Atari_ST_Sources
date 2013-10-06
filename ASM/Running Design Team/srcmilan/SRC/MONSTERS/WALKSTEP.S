; ok, 07.07.00/vk


WALKSTEP		equ	0



		text


; ---------------------------------------------------------
; 25.06.00/vk
; bewegt das monster um einen laufschritt in richtung der
; aktuell festgelegten/gespeicherten laufrichtung.
; a2 = gegner
; rettet alle register.
monsterWalkOneStep

		movem.l	d0-d7/a0-a6,-(sp)

		move.b	#0,MONWALKINGTYPE(a2)

		move.w	monSpeed,d3			; laufgeschwindigkeit (positiv) fuer monster holen

		tst.w	MONWALKDIR(a2)			; laufrichtung
		beq.s	mwosItsForward			; vorwaerts? ja -> dann ueberspringen
		neg.w	d3				; andernfalls laufgeschwindigkeit negieren
mwosItsForward	add.w	MONSECMLDIST(a2),d3		; bisherige distanz auf dieser ml linie hinzuaddieren
		bpl.s	mwosNoFallShortOf		; anfang unterschritten? nein -> verzweigen

	; monster hat den anfang einer linie der monline unterschritten (fall short of)

		tst.b	MONWALKINGTYPE(a2)
		beq.s	mwosfsoNoDirChange

		clr.w	MONSECMLDIST(a2)		; auf gleicher linie wieder vorwaerts -> distanz auf null
		clr.w	MONWALKDIR(a2)			; laufrichtung vorwaerts
		bra	mwosCalcPositionAndOut		; position berechnen und raus

mwosfsoNoDirChange

		bsr	monsterSetToPreviousLine	; auf vorherige linie (bzw. in neuen sektor) setzen
		bra	mwosCalcPositionAndOut		; position berechnen und raus

mwosNoFallShortOf

		bsr	monsterCalcMonLine
		
		move.w	MONSECMLLINE(a2),d2
		mulu.w	#MLDEFBYTES,d2
		ext.l	d3
		move.l	MLDEFLENGTH(a4,d2.l),d4
		cmp.l	d4,d3
		blt.s	mwosIsOnLine

	; monster hat das ende einer linie der monline ueberschritten (pass over)

		tst.b	MONWALKINGTYPE(a2)
		beq.s	mwospoNoDirChange

		move.w	d4,MONSECMLDIST(a2)		; entfernung auf maximalwert der linie der ml
		move.w	#1,MONWALKDIR(a2)		; laufrichtung auf rueckwaerts setzen
		bra.s	mwosCalcPositionAndOut

mwospoNoDirChange

		bsr	monsterSetToNextLine
		bra.s	mwosCalcPositionAndOut

mwosIsOnLine
		move.w	d3,MONSECMLDIST(a2)

mwosCalcPositionAndOut

		bsr	monsterCalcExactPosition

mwosOut
		movem.l	(sp)+,d0-d7/a0-a6
		rts


; ---------------------------------------------------------
; 27.06.00/vk
; a2 = monster
; rettet alle register
monsterSetToPreviousLine

		movem.l	d0-a6,-(sp)

		bsr	monsterCalcMonLine		; rueckg.: a3 = struktur monlines des sektors
							;          a4 = erste mldef der monline des monsters

		move.w	MONSECMLLINE(a2),d7		; linienindex holen
		subq.w	#1,d7				; wollen versuchen, eins zu erniedrigen
		bpl.s	mstplSimplyPreviousLine		; nicht negativ, dann geht's noch -> verzweigen

		move.w	MONSECML(a2),d6
		mulu.w	#MLBYTES,d6
		move.w	MLFROMSECTOR(a3,d6.l),d2	; auf diesen sektor kam die monline
		cmp.w	MONSEC(a2),d2			; mit aktueller sektornummer des monsters vergleichen
		bne.s	mstplMustChangeSector		; ungleich -> anfangspunkt in neuem sektor suchen

		clr.w	MONWALKDIR(a2)			; laufrichtung wieder vorwaerts setzen
		clr.w	MONSECMLDIST(a2)		; position auf linienanfang
		bra.s	mstplOut

mstplMustChangeSector
		move.l	MLDEFX(a4),d0			; uebergangs-x-koordinate
		move.l	MLDEFY(a4),d1			; uebergangs-y-koordinate
		bsr	monsterSetToNewSector		; d0/d1: x/y, d2: sektor
		bra.s	mstnlOut

mstplSimplyPreviousLine
		move.w	#1,MONWALKDIR(a2)		; laufrichtung rueckwaerts
		move.w	d7,MONSECMLLINE(a2)		; auf diese linie der mldef

		mulu.w	#MLDEFBYTES,d7
		move.l	MLDEFLENGTH(a4,d7.l),d7
		move.w	d7,MONSECMLDIST(a2)		; auf diese entfernung auf der linie der mldef setzen

mstplOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 27.06.00/vk
; a2 = monster
; rettet alle register
monsterSetToNextLine

		movem.l	d0-a6,-(sp)

		bsr	monsterCalcMonLine		; rueckg.: a3 = struktur monlines des sektors
							;          a4 = erste mldef der monline des monsters

		move.w	MONSECMLLINE(a2),d7		; linienindex holen
		addq.w	#1,d7				; wollen versuchen, eins zu erhoehen
		mulu.w	#MLDEFBYTES,d7
		tst.l	MLDEFLENGTH(a4,d7.l)		; laenge dieser neu (geplanten) linie null?
		bne.s	mstnlSimplyNextLine		; nein -> dann linie gueltig und kann gesetzt werden

		move.w	MONSECML(a2),d6
		mulu.w	#MLBYTES,d6
		move.w	MLTOSECTOR(a3,d6.l),d2		; in diesen sektor geht die monline ueber
		cmp.w	MONSEC(a2),d2			; mit aktueller sektornummer des monsters vergleichen
		bne.s	mstnlMustChangeSector		; ungleich -> anfangspunkt in neuem sektor suchen

		move.w	#1,MONWALKDIR(a2)		; laufrichtung rueckwaerts setzen
		move.l	MLDEFLENGTH-MLDEFBYTES(a4,d7.l),d0
		move.w	d0,MONSECMLDIST(a2)		; position auf linienende
		bra.s	mstnlOut

mstnlMustChangeSector
		move.l	MLDEFX(a4,d7.l),d0		; uebergangs-x-koordinate
		move.l	MLDEFY(a4,d7.l),d1		; uebergangs-y-koordinate
		bsr	monsterSetToNewSector		; d0/d1: x/y, d2: sektor
		bra.s	mstnlOut

mstnlSimplyNextLine
		clr.w	MONWALKDIR(a2)
		addq.w	#1,MONSECMLLINE(a2)
		clr.w	MONSECMLDIST(a2)

mstnlOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 28.06.00/vk
; setzt das monster auf die monline des sektors, die den
; punkt x/y besitzt.
; d0 = neu_x
; d1 = neu_y
; d2 = sektor
; a2 = monster
monsterSetToNewSector

		movea.l	levelPtr,a6
		movea.l	LEVSECSTART(a6,d2.w*4),a3
		adda.l	a6,a3

		movea.l	SECMONLINE(a3),a3
		adda.l	a6,a3				; a3 = struktur monlines des (neuen) sektors

		moveq	#0,d3				; indexierung ml
mstnsMlLoop
		tst.l	(a3)				; noch eine ml definiert?
		bmi.s	mstnsOut			; nein -> dann raus: position des monsters bleibt unveraendert

		move.l	MLDEFPTR(a3),a4			; mldef holen
		cmp.l	MLDEFX(a4),d0			; anfangspunkt vergleichen
		bne.s	mstnsmlNotSame
		cmp.l	MLDEFY(a4),d1
		beq.s	mstnsSetToBegin			; punkt identisch -> auf anfang der mldef setzen
mstnsmlNotSame
		moveq	#0,d4
mstnsMldefLoop	move.l	MLDEFLENGTH(a4),d5		; laenge der linie der ml holen
		bne.s	mstnsMldefSkip			; wenn ungleich null, dann weiter das ende suchen

		cmp.l	MLDEFX(a4),d0
		bne.s	mstnsMlSkip
		cmp.l	MLDEFY(a4),d1
		beq.s	mstnsSetToEnd
		bra.s	mstnsMlSkip
mstnsMldefSkip
		adda.l	#MLDEFBYTES,a4
		addq.w	#1,d4
		bra.s	mstnsMldefLoop

mstnsMlSkip
		addq.l	#MLBYTES,a3
		addq.w	#1,d3
		bra.s	mstnsMlLoop

mstnsSetToBegin
		move.w	d2,MONSEC(a2)			; neuer sektor des monsters
		move.w	d3,MONSECML(a2)			; index der ml
		clr.w	MONSECMLLINE(a2)		; erste linie der ml
		clr.w	MONSECMLDIST(a2)		; auf begin der linie
		clr.w	MONWALKDIR(a2)			; laufrichtung vorwaerts
		bra.s	mstnsOut

mstnsSetToEnd
		move.w	d2,MONSEC(a2)			; neuer sektor des monsters
		move.w	d3,MONSECML(a2)			; index der ml
		move.w	d4,MONSECMLLINE(a2)		; auf letzte linie der ml
		move.w	d5,MONSECMLDIST(a2)		; auf ende der linie
		move.w	#1,MONWALKDIR(a2)		; laufrichtung rueckwaerts

mstnsOut
		rts


; ---------------------------------------------------------
; 25.06.00/vk
; gibt die aktuelle monline zurueck, auf der sich
; das monster befindet.
; a2 = monster
; rueckgabe: a3 = pointer auf monlines des sektors
;            a4 = pointer auf mldef der aktuellen monline
; rettet alle register
monsterCalcMonLine

		movem.l	d1/a6,-(sp)

		movea.l	levelPtr,a6
		move.w	MONSEC(a2),d1
		movea.l	LEVSECSTART(a6,d1.w*4),a3
		adda.l	a6,a3

		movea.l	SECMONLINE(a3),a3
		adda.l	a6,a3				; a3 = struktur monlines des sektors

		move.w	MONSECML(a2),d1
		mulu.w	#MLBYTES,d1
		movea.l	MLDEFPTR(a3,d1.l),a4
		adda.l	a6,a4				; a4 = erste mldef der monline des monsters

		movem.l	(sp)+,d1/a6

		rts


; ---------------------------------------------------------
; 25.06.00/vk
; berechnet aus den variablen (aktuelle monline, distanz auf
; monline etc.) die tatsaechlichen werte fuer die dspline.
; grafik-/texturdaten sowie h2 werden hier nicht gesetzt.
; a2 = monster (bleibt unveraendert)
monsterCalcExactPosition

		bsr.s	monsterCalcMonLine		; rueckgabe: a4 = aktuelle mldef

		move.w	MONSECMLLINE(a2),d2
		mulu.w	#MLDEFBYTES,d2
		adda.l	d2,a4

		move.l	MLDEFX(a4),d5			; x
		move.l	MLDEFY(a4),d6			; y

		move.w	MLDEFALPHA(a4),d3		; alpha
		add.w	d3,d3				; im level im bereich [0..255] definiert, brauchen 512 als vollwinkel
		move.w	d3,d4

		lea	sinus512TabX,a3
		lsl.w	#4,d3
		fmove.x	(a3,d3.w),fp0			; sinus
		addi.w	#$80,d4
		andi.w	#$1ff,d4
		lsl.w	#4,d4
		fmove.x	(a3,d4.w),fp1			; cosinus
		
		fmove.w	MONSECMLDIST(a2),fp2
		fmul.x	fp2,fp0
		fmul.x	fp2,fp1
		fmove.l	fp0,d4
		fmove.l	fp1,d3
		add.l	d3,d5
		add.l	d4,d6
		move.l	d5,MONLINE(a2)
		move.l	d6,MONLINE+4(a2)

		move.w	MLDEFALPHA(a4),d1		; alpha
		tst.w	MONWALKDIR(a2)
		beq.s	mcepNoTurn
		addi.b	#$80,d1
mcepNoTurn	move.b	d1,MONLINE+15(a2)		; normw
		move.w	MLDEFSH(a4),MONLINE+10(a2)	; neues h1

		rts

