
; --------------
; maximale blockgroesse
ZBMAXBLOCKX		equ	1280
ZBMAXBLOCKY		equ	1024

; --------------
; zugriff auf zbData
ZBSOURCEADDRESS		equ	0
ZBSOURCEDX		equ	4
ZBSOURCEDY		equ	6
ZBSOURCELINEOFFSET	equ	8
ZBDESTADDRESS		equ	10
ZBDESTDX		equ	14
ZBDESTDY		equ	16
ZBDESTLINEOFFSET	equ	18



		text


; ----------------------------------------------------------
; parameterblock zbData muss gefuellt sein
; ----------------------------------------------------------
zoomBlock
		lea	zbData,a0

		move.l	#0,d0
		move.l	#0,d1
		move.w	ZBSOURCEDX(a0),d0
		move.w	ZBSOURCEDY(a0),d1
		move.w	ZBDESTDX(a0),d6
		move.w	ZBDESTDY(a0),d7

		cmp.w	d0,d6
		bne.s	zbNoOriginalSize
		cmp.w	d1,d7
		beq	zbOriginalSize

zbNoOriginalSize

	; bestimme x-zoom := SOURCEDX / DESTDX

		swap	d0
		fmove.l	d0,fp0
		fdiv.l	d6,fp0
		fmove.l	fp0,d0

		swap	d0			; hi = nachkomma, low = vorkomma

	; bestimme y-zoom := SOURCEDY / DESTDY

		swap	d1
		fmove.l	d1,fp0
		fdiv.l	d7,fp0
		fmove.l	fp0,d1

		swap	d1			; hi = nachkomma, low = vorkomma

	; x-offsets vorberechnen

		subq.w	#1,d6			; anzahl zu zeichnender spalten
		move.w	d6,d2			; sichern fuer spaeter
		move.l	#0,d5			; zeilenposition
		lea	zbXLines,a2
		movea.l	a2,a1
zbLoopPreCalcX
		move.w	d5,(a2)+		
		addx.l	d0,d5
		dbra	d6,zbLoopPreCalcX

	; y-offsets vorberechnen

		subq.w	#1,d7			; anzahl zu zeichnender zeilen
		move.w	d7,d3			; sichern fuer spaeter
		move.l	#0,d6			; zeilenposition
		lea	zbYLines,a3
		movea.l	a3,a2
zbLoopPreCalcY
		move.w	d6,(a3)+		
		addx.l	d1,d6
		dbra	d7,zbLoopPreCalcY

	; d0 = xzoom
	; d1 = yzoom
	; d2 = dx - 1
	; d3 = dy - 1
	; a0 = dataarray
	; a1 = zbXLines
	; a2 = zbYLines

		move.w	ZBSOURCELINEOFFSET(a0),d4
		move.w	ZBDESTLINEOFFSET(a0),d5
		move.l	ZBSOURCEADDRESS(a0),a3
		move.l	ZBDESTADDRESS(a0),a4

zbLoopY
		move.w	(a2)+,d6
		mulu	d4,d6
		movea.l	a3,a5
		adda.l	d6,a5			; quellzeile
		move.w	d2,d0			; anzahl pixel - 1
		movea.l	a1,a0			; zbXLines
		movea.l	a4,a6
zbLoopX
		move.w	(a0)+,d6
		move.w	(a5,d6.w*2),(a6)+
		dbra	d0,zbLoopX

		adda.w	d5,a4			; lineoffset (ziel) addieren

		dbra	d3,zbLoopY

		rts

; d0 = dx
; d1 = dy
; a0 = dataarray
zbOriginalSize

		move.w	ZBSOURCELINEOFFSET(a0),d2
		move.w	ZBDESTLINEOFFSET(a0),d3
		move.l	ZBSOURCEADDRESS(a0),a1
		move.l	ZBDESTADDRESS(a0),a2

zbosLoopY
		movea.l	a1,a3
		movea.l	a2,a4
		move.w	d0,d4
zbosLoopX
		move.w	(a3)+,(a4)+
		dbra	d4,zbosLoopX

		adda.w	d2,a1
		adda.w	d3,a2

		dbra	d1,zbosLoopY

		rts



		bss


zbData		ds.l	1	; adresse originalblock
		ds.w	2	; breite/hoehe originalblock
		ds.w	1	; lineoffset originalblock

		ds.l	1	; adresse zielbereich
		ds.w	2	; breite/hoehe zielbereich
		ds.w	1	; lineoffset zielbereich

zbXLines	ds.w	ZBMAXBLOCKX	; zu zeichnende spalten (temp. berechnet)
zbYLines	ds.w	ZBMAXBLOCKY	; zu zeichnende zeilen (temp. berechnet)
