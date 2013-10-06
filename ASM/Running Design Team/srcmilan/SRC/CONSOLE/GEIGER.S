
GEIGEROFFSETTOMIDX	equ	51			; x-offset von linkem rand zu mittelpunkt (start des zeigers)
GEIGEROFFSETTOMIDY	equ	71			; y-offset von oberem rand zu mittelpunkt


GEIGERSTARTPOSX		equ	-120			; pos. (von links) oder neg. (von rechts)
GEIGERSTARTPOSY		equ	280			; ebenfalls pos. od. neg. moeglich
GEIGERSTARTRADIUS	equ	65
GEIGERSTARTMINALPHA	equ	$b8
GEIGERSTARTMAXALPHA	equ	$40
GEIGERSTARTCOLOR	equ	%0011100011100111


			rsreset
GEIGERPOSX		rs.w	1
GEIGERPOSY		rs.w	1
GEIGERABSPOSX		rs.w	1
GEIGERABSPOSY		rs.w	1
GEIGERRADIUS		rs.w	1
GEIGERMIDX		rs.w	1
GEIGERMIDY		rs.w	1
GEIGERMINALPHA		rs.w	1
GEIGERMAXALPHA		rs.w	1
GEIGERCURRENTPOS	rs.w	1
GEIGERTOREACHREALPOS	rs.w	1
GEIGERCOLOR		rs.w	1
GEIGERZUCKENCOUNTER	rs.w	1
GEIGERZUCKENMAX		rs.w	1
GEIGERBYTES		rs.w	1



		text


; ---------------------------------------------------------
; 12.08.00/vk
drawGeigerIfRequired

		lea	playerThings+PTHGBYTES*TGEIGERCOUNTER,a0

		tst.w	PTHGFLAG(a0)
		beq.s	dgirOut
		tst.w	PTHGACTFLAG(a0)
		beq.s	dgirOut

		bsr.s	drawGeiger
dgirOut
		rts


; ---------------------------------------------------------
; 12.08.00/vk
drawGeiger
		lea	geiger,a0
		bsr	dgDrawBackground			; hintergrundgrafik zeichnen
		bsr	dgCalcLine				; zu zeichnenden ausschlag berechnen
		bsr	dgDrawLine				; berechneten ausschlag zeichnen

		bsr	setFlagToClearBackground

		rts


; ---------------------------------------------------------
; 12.08.00/vk
; a0 = geiger
dgCalcLine

	; neue zu erreichende position berechnen

		moveq	#0,d0					; anfangs ausschlag auf null setzen
		movea.l	playerDataPtr,a6
		move.l	PDCURRENTSFPTR(a6),d1			; aktuelles sector field holen
		beq.s	dgclValueOk
		movea.l	d1,a1

		moveq	#0,d1
		move.b	SFNEEDACT(a1),d1			; welcher gegenstand muss hierin aktiviert sein?
		beq.s	dgclValueOk
		cmpi.w	#TRADSUIT,d1				; ist es der strahlenschutzanzug?
		bne.s	dgclValueOk

		move.w	SFNEEDSTRENGTH(a1),d0
		addq.w	#1,d0
		lsl.w	#4,d0					; faktor 16
dgclValueOk
		move.w	d0,GEIGERTOREACHREALPOS(a0)

	; mit aktueller position vergleichen und evtl. neuen radioakt. ausschlag erzeugen

		move.w	GEIGERCURRENTPOS(a0),d2
		move.w	d2,d3
		sub.w	d0,d3
		bpl.s	dgclDiff2Ok
		neg.w	d3
dgclDiff2Ok

		move.w	vblTime1000,d1
		lsr.w	#4,d1
		bne.s	dgclDiffOk
		moveq	#1,d1
dgclDiffOk	cmp.w	d3,d1
		blt.s	dgclDiff3Ok
		move.w	d3,d1
dgclDiff3Ok

		cmp.w	d0,d2					; wahre zielposition schon erreicht?
		beq.s	dgclCreateAusschlag			; ja -> dann extra ausschlag generieren
		bgt.s	dgclDiffSub

		add.w	d1,d2
		bra.s	dgclCurrentOk
dgclDiffSub
		sub.w	d1,d2
		bra.s	dgclCurrentOk

dgclCreateAusschlag
		move.w	GEIGERZUCKENCOUNTER(a0),d0
		add.w	vblTime1000,d0
		cmp.w	GEIGERZUCKENMAX(a0),d0
		blt.s	dgclcaZuckenOk

		moveq	#0,d0

		bsr	getChance256
		lsl.w	#2,d1
		move.w	d1,GEIGERZUCKENMAX(a0)

		bsr	getChance256				; out: d1.w zwischen 0 und 255
		lsr.w	#4,d1
		add.w	d1,d2
dgclcaZuckenOk
		move.w	d0,GEIGERZUCKENCOUNTER(a0)

dgclCurrentOk

	; d2 ist jetzt die zu zeichnende linie

		move.w	d2,GEIGERCURRENTPOS(a0)

		rts


; ---------------------------------------------------------
; 12.08.00/vk
; a0 = geiger
dgDrawLine
		move.l	a0,-(sp)

		move.w	GEIGERCURRENTPOS(a0),d1
		move.w	GEIGERMINALPHA(a0),d0
		sub.w	d1,d0
		cmp.w	GEIGERMAXALPHA(a0),d0
		bgt.s	dgdlAlphaOk
		move.w	GEIGERMAXALPHA(a0),d0
dgdlAlphaOk	move.w	d0,d1

		lea	sinus512TabX,a3
		add.w	d0,d0
		fmove.x	(a3,d0.w*8),fp0			; sinus
		addi.w	#$80,d1
		andi.w	#$1ff,d1
		add.w	d1,d1
		fmove.x	(a3,d1.w*8),fp1			; cosinus

		fmove.w	GEIGERRADIUS(a0),fp2
		fmul.x	fp2,fp0
		fmul.x	fp2,fp1

		move.w	GEIGERMIDX(a0),d0
		move.w	GEIGERMIDY(a0),d1
		fmove.w	fp1,d2
		fmove.w	fp0,d4
		add.w	d0,d2
		move.w	d1,d3
		sub.w	d4,d3
		moveq	#0,d4
		move.w	lineoffset,d4
		move.w	GEIGERCOLOR(a0),d7
		movea.l	screen_1,a0
		bsr	drawLine

		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 12.08.00/vk
; a0 = geiger
dgDrawBackground

		move.l	a0,-(sp)

		move.w	GEIGERPOSX(a0),d6
		move.w	GEIGERPOSY(a0),d7
		movea.l	screen_1,a0
		lea	bmpCGeigBack,a2
		bsr	bitBlt

		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 12.08.00/vk
; initialisiert den geigerzaehler nach (!) einem aufloesungswechsel neu.
; rettet alle register.
geigerResetFields
		movem.l	d0-a6,-(sp)

		lea	geiger,a0

		move.w	GEIGERPOSX(a0),d0
		bpl.s	grfxOk
		move.w	width,d0
		add.w	GEIGERPOSX(a0),d0
grfxOk		move.w	d0,GEIGERABSPOSX(a0)

		move.w	GEIGERPOSY(a0),d1
		bpl.s	grfyOk
		move.w	height,d1
		add.w	GEIGERPOSY(a0),d1
grfyOk		move.w	d1,GEIGERABSPOSY(a0)

		addi.w	#GEIGEROFFSETTOMIDX,d0
		addi.w	#GEIGEROFFSETTOMIDY,d1
		move.w	d0,GEIGERMIDX(a0)
		move.w	d1,GEIGERMIDY(a0)

		movem.l	(sp)+,d0-a6
		rts









		data



		bss



geiger		ds.b	GEIGERBYTES