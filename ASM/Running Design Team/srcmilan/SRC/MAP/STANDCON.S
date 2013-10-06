

		text


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet den inhalt der standardkarte (horiz./vert.)
; a0 = screenadresse (linke obere ecke der karte)
; clippingdata
drawMapContentStandard

		lea	playerThings,a1			; waende ueberspringen, wenn der spieler grosse oder kleine karte nicht besitzt
		move.l	#PTHGBYTES*TPLAN,d0
		move.l	#PTHGBYTES*TSMALLPLAN,d1
		tst.w	PTHGFLAG(a1,d0.l)
		bne.s	dmcsHasAtLeastOnePlan
		tst.w	PTHGFLAG(a1,d1.l)
		beq	dmcsSectorsOk

dmcsHasAtLeastOnePlan
		moveq	#0,d7
		movea.l	levelPtr,a6
dmcsLoop
		move.l	LEVSECSTART(a6,d7.w*4),d0
		bmi.s	dmcsSectorsOk		
		movea.l	d0,a1
		adda.l	a6,a1				; a1 = pointer auf sektor

		tst.w	playerThings+PTHGBYTES*TPLAN+PTHGFLAG		; gesamtkarte vorhanden
		beq.s	dmcsNoPlan					; nein -> dann weiter
		tst.w	playerThings+PTHGBYTES*TPLAN+PTHGACTFLAG	; auch aktiviert?
		bne.s	dmcsDoSector					; ja -> dann zeichnen
		bsr	dmDrawMapActivationText				; andernfalls hinweis zur aktivierung
dmcsNoPlan
		tst.w	playerThings+PTHGBYTES*TSMALLPLAN+PTHGFLAG
		beq.s	dmcsSkipSector
		tst.w	playerThings+PTHGBYTES*TSMALLPLAN+PTHGACTFLAG
		bne.s	dmcsDoSectorIfWalked
		bsr	dmDrawMapActivationText
		bra.s	dmcsSkipSector

dmcsDoSectorIfWalked
		movea.l	LEVINITDATA(a6),a5		; sektor nicht zeichnen, wenn noch nicht betreten
		adda.l	a6,a5
		movea.l	INITVISSECPTR(a5),a5
		adda.l	a6,a5
		btst	#0,(a5,d7.w)
		beq.s	dmcsSkipSector

dmcsDoSector
		movem.l	d7/a0/a6,-(sp)
		bsr.s	dmcsWalls			; waende des sektors zeichnen
		movem.l	(sp)+,d7/a0/a6

dmcsSkipSector
		addq.w	#1,d7
		bra.s	dmcsLoop
dmcsSectorsOk

		bsr	dmcsMonsters
		bsr	dmcsPlayer

dmcsOut
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet die waende des sektors
; parameter siehe drawmapcontentstandard.
; a1 = sektor
; a6 = level
dmcsWalls
		movem.l	a0-a1/a6,-(sp)

		movea.l	SECLINES(a1),a2
		adda.l	a6,a2
		move.l	(a2)+,d5			; d5 = anzahl linien
							; a2 = linien
		movea.l	SECPOINTS(a1),a3
		adda.l	a6,a3
		addq.l	#4,a3				; a3 = punkte

		bsr.s	dmcsDrawLines

		movem.l	(sp)+,a0-a1/a6
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet aus den original leveldaten
; d5 = anzahl linien
; a0 = screen
; a2 = linien
; a3 = punkte
dmcsDrawLines
		subq.w	#1,d5
		bmi	dmcsdlOut

		moveq	#0,d4
		move.w	lineoffset,d4
		lea	mapData,a4
		movea.l	playerDataPtr,a5
		lea	mapColors,a6

dmcsdlLoop
		movem.l	d4-d5/a0/a2-a6,-(sp)

		move.w	2(a2),d5
		move.w	6(a2),d6
		movem.l	(a3,d5.w),d0/d5
		movem.l	(a3,d6.w),d2/d6

		sub.l	MAPDATAMX(a4),d0
		sub.l	MAPDATAMX(a4),d2
		sub.l	MAPDATAMY(a4),d5
		sub.l	MAPDATAMY(a4),d6

		move.w	PDMAPZOOM(a5),d7
		divs.w	d7,d0
		divs.w	d7,d2
		divs.w	d7,d5
		divs.w	d7,d6

		add.w	MAPDATAWIDTHHALF(a4),d0
		add.w	MAPDATAWIDTHHALF(a4),d2
		add.w	MAPDATAHEIGHTHALF(a4),d5
		add.w	MAPDATAHEIGHTHALF(a4),d6

		move.w	MAPDATAHEIGHT(a4),d1
		move.w	d1,d3
		sub.w	d5,d1
		sub.w	d6,d3

		move.b	14(a2),d7		; bits 15..8 von line_flag_2
		andi.w	#%00001100,d7
		move.l	(a6,d7.w),d7		; farbe holen

		bsr	lineWithClipping

		movem.l	(sp)+,d4-d5/a0/a2-a6
		lea	20(a2),a2

		dbra	d5,dmcsdlLoop
dmcsdlOut
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet die spielfigur.
; parameter siehe drawmapcontentstandard.
dmcsPlayer
		move.l	a0,-(sp)
		lea	drawFigureData,a4
		movea.l	playerDataPtr,a1
		move.l	PDSX(a1),DRAWFIGUREX(a4)
		move.l	PDSY(a1),DRAWFIGUREY(a4)
		move.w	PDALPHA(a1),DRAWFIGUREANGLE(a4)
		move.w	#$ffff,DRAWFIGURECOLOR(a4)
		move.w	#FIGURELENGTHSTANDARD,DRAWFIGURELENGTH(a4)
		bsr	drawFigure
		movea.l	(sp)+,a0

		rts


; ---------------------------------------------------------
; 18.06.00/vk
; zeichnet die monster.
; parameter siehe drawmapcontentstandard.
dmcsMonsters
		tst.w	playerThings+PTHGBYTES*TMONDETECTOR+PTHGFLAG
		beq.s	dmcsmOut
		tst.w	playerThings+PTHGBYTES*TMONDETECTOR+PTHGACTFLAG
		beq.s	dmcsmOut

		move.w	monBufferNb,d7
		bmi.s	dmcsmOut
		movea.l	monBufferPtr,a1
dmcsmLoop
		movea.l	(a1)+,a2
		movem.l	d7/a0-a1,-(sp)

		lea	drawFigureData,a4
		move.l	MONLINE(a2),DRAWFIGUREX(a4)
		move.l	MONLINE+4(a2),DRAWFIGUREY(a4)
		moveq	#0,d0
		move.b	MONLINE+15(a2),d0
		add.w	d0,d0
		move.w	d0,DRAWFIGUREANGLE(a4)
		move.w	#$07ff,DRAWFIGURECOLOR(a4)
		move.w	#FIGURELENGTHSTANDARD,DRAWFIGURELENGTH(a4)
		bsr	drawFigure

		movem.l	(sp)+,d7/a0-a1
		dbra	d7,dmcsmLoop
dmcsmOut
		rts


; ---------------------------------------------------------
; rettet alle register
dmDrawMapActivationText

		move.l	a0,-(sp)
		lea	dmActivatePlanTxt,a0
		bsr	installMessage
		movea.l	(sp)+,a0

		rts


; ---------------------------------------------------------
; rettet alle register
dmDrawMDetectorActivationText

		move.l	a0,-(sp)
		lea	dmActivateMDetectorTxt,a0
		bsr	installMessage
		movea.l	(sp)+,a0

		rts




		data

			IFEQ LANGUAGE
dmActivatePlanTxt	dc.b	"BEFORE USING THE MAP IT MUST BE ACTIVATED FIRST",0
dmActivateMDetectorTxt	dc.b	"ACTIVATE YOUR MONSTER DETECTOR",0
			ELSE
dmActivatePlanTxt	dc.b	"KARTE MUSS VOR VERWENDUNG ZUERST AKTIVIERT WERDEN",0
dmActivateMDetectorTxt	dc.b	"AKTIVIERE DIE GEGNERANZEIGE FšR DIE KARTE",0
			ENDC
			even

