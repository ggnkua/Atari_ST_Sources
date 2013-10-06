
; todo: zeichenroutinen auf video-ram optieren/uebertragen

BORDER3DUPPER		equ	0
BORDER3DLOWER		equ	4
BORDER3DLEFT		equ	8
BORDER3DRIGHT		equ	12
BORDER3DUPPERLEFT	equ	16
BORDER3DUPPERRIGHT	equ	20
BORDER3DLOWERLEFT	equ	24
BORDER3DLOWERRIGHT	equ	28
BORDER3DNEEDFREEUPPER	equ	32
BORDER3DNEEDFREELOWER	equ	34
BORDER3DNEEDFREELEFT	equ	36
BORDER3DNEEDFREERIGHT	equ	38
BORDER3DISFREEUPPER	equ	40
BORDER3DISFREELOWER	equ	42
BORDER3DISFREELEFT	equ	44
BORDER3DISFREERIGHT	equ	46
BORDER3DSCREENWIDTH	equ	48
BORDER3DSCREENHEIGHT	equ	50

; struktur 3dbordergfx<x>
B3DGFXPTR		equ	0
B3DWIDTH		equ	4
B3DHEIGHT		equ	6
B3DDELTAX		equ	8
B3DDELTAY		equ	10
B3DLINEOFFSET		equ	12
B3DINVIDEORAMFLAG	equ	14
B3DINVIDEORAMX		equ	16
B3DINVIDEORAMY		equ	18


		text


; ---------------------------------------------------------
; 02.01.00/vk
; zeichnet einen rahmen um das 3d fenster.
draw3dBorder
		bsr	d3dbCalcBorderSpace		; berechne den platz, der fuer die border zur verfuegung steht
		bsr	d3dbIsEnoughSpaceForBorder	; ist genug platz fuer zu zeichnenden rahmen vorhanden?
		tst.w	d0
		bmi.s	d3dbOut				; nein -> dann raus

		bsr	d3dbUpper
		bsr	d3dbLower
		bsr	d3dbLeft
		bsr	d3dbRight

		bsr	d3dbUpperLeft
		bsr	d3dbUpperRight
		bsr	d3dbLowerLeft
		bsr	d3dbLowerRight
d3dbOut
		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbUpper
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENWIDTH(a1),d7
		movea.l	BORDER3DUPPER(a1),a1
		move.w	B3DHEIGHT(a1),d0
		mulu.w	lineoffset,d0
		suba.l	d0,a0

d3dbuLoop
		sub.w	B3DWIDTH(a1),d7
		bmi.s	d3dbuOut

		movem.l	d7/a0-a1,-(sp)
		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBlt
		movem.l	(sp)+,d7/a0-a1

		move.w	B3DWIDTH(a1),d6
		add.w	d6,d6
		adda.w	d6,a0

		bra.s	d3dbuLoop
d3dbuOut
		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbLower
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENHEIGHT(a1),d0
		mulu.w	lineoffset,d0
		adda.l	d0,a0

		move.w	BORDER3DSCREENWIDTH(a1),d7
		movea.l	BORDER3DLOWER(a1),a1
d3dblLoop
		sub.w	B3DWIDTH(a1),d7
		bmi.s	d3dblOut

		movem.l	d7/a0-a1,-(sp)
		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBlt
		movem.l	(sp)+,d7/a0-a1

		move.w	B3DWIDTH(a1),d6
		add.w	d6,d6
		adda.w	d6,a0

		bra.s	d3dblLoop
d3dblOut
		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbLeft
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENHEIGHT(a1),d7
		movea.l	BORDER3DLEFT(a1),a1
		move.w	B3DWIDTH(a1),d0
		add.w	d0,d0
		suba.w	d0,a0

d3dblfLoop
		sub.w	B3DHEIGHT(a1),d7
		bmi.s	d3dblfOut

		movem.l	d7/a0-a1,-(sp)
		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBlt
		movem.l	(sp)+,d7/a0-a1

		move.w	B3DHEIGHT(a1),d6
		mulu.w	lineoffset,d6
		adda.l	d6,a0

		bra.s	d3dblfLoop
d3dblfOut
		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbRight
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENHEIGHT(a1),d7
		move.w	BORDER3DSCREENWIDTH(a1),d0
		add.w	d0,d0
		adda.w	d0,a0

		movea.l	BORDER3DRIGHT(a1),a1

d3dbrLoop
		sub.w	B3DHEIGHT(a1),d7
		bmi.s	d3dbrOut

		movem.l	d7/a0-a1,-(sp)
		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBlt
		movem.l	(sp)+,d7/a0-a1

		move.w	B3DHEIGHT(a1),d6
		mulu.w	lineoffset,d6
		adda.l	d6,a0

		bra.s	d3dbrLoop
d3dbrOut
		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbUpperLeft
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		movea.l	BORDER3DUPPERLEFT(a1),a1
		move.w	B3DDELTAX(a1),d0
		add.w	d0,d0
		suba.w	d0,a0
		move.w	B3DDELTAY(a1),d0
		mulu.w	lineoffset,d0
		suba.l	d0,a0

		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBltMasked

		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbUpperRight
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENWIDTH(a1),d0
		add.w	d0,d0
		adda.w	d0,a0

		movea.l	BORDER3DUPPERRIGHT(a1),a1
		move.w	B3DWIDTH(a1),d0
		sub.w	B3DDELTAX(a1),d0
		add.w	d0,d0
		suba.w	d0,a0
		move.w	B3DDELTAY(a1),d0
		mulu.w	lineoffset,d0
		suba.l	d0,a0

		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr	d3dbBitBltMasked

		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbLowerLeft
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENHEIGHT(a1),d0
		mulu.w	lineoffset,d0
		adda.l	d0,a0

		movea.l	BORDER3DLOWERLEFT(a1),a1
		move.w	B3DDELTAX(a1),d0
		add.w	d0,d0
		suba.w	d0,a0
		move.w	B3DHEIGHT(a1),d0
		sub.w	B3DDELTAY(a1),d0
		mulu.w	lineoffset,d0
		suba.l	d0,a0

		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr.s	d3dbBitBltMasked

		rts


; ---------------------------------------------------------
; 03.01.00/vk
d3dbLowerRight
		movea.l	screen_1,a0
		adda.l	screen3dOffset,a0

		lea	border3dData,a1
		move.w	BORDER3DSCREENWIDTH(a1),d0
		add.w	d0,d0
		adda.w	d0,a0
		move.w	BORDER3DSCREENHEIGHT(a1),d0
		mulu.w	lineoffset,d0
		adda.l	d0,a0

		movea.l	BORDER3DLOWERRIGHT(a1),a1
		move.w	B3DWIDTH(a1),d0
		sub.w	B3DDELTAX(a1),d0
		add.w	d0,d0
		suba.w	d0,a0
		move.w	B3DHEIGHT(a1),d0
		sub.w	B3DDELTAY(a1),d0
		mulu.w	lineoffset,d0
		suba.l	d0,a0

		move.w	B3DWIDTH(a1),d0
		move.w	B3DHEIGHT(a1),d1
		movea.l	B3DGFXPTR(a1),a1
		bsr.s	d3dbBitBltMasked

		rts


; ---------------------------------------------------------
; 03.01.00/vk
; d0 = breite (noch nicht fuer dbra)
; d1 = hoehe (noch nicht fuer dbra)
; a0 = screenadresse
; a1 = grafikdaten
d3dbBitBlt
		subq.w	#1,d0
		subq.w	#1,d1
d3dbbbLoop1	move.w	d0,d2
		movea.l	a0,a2
d3dbbbLoop2	move.w	(a1)+,(a2)+
		dbra	d2,d3dbbbLoop2
		adda.w	lineoffset,a0
		dbra	d1,d3dbbbLoop1

		rts


; ---------------------------------------------------------
; 03.01.00/vk
; d0 = breite (noch nicht fuer dbra)
; d1 = hoehe (noch nicht fuer dbra)
; a0 = screenadresse
; a1 = grafikdaten
d3dbBitBltMasked
		subq.w	#1,d0
		subq.w	#1,d1
d3dbbbmLoop1	move.w	d0,d2
		movea.l	a0,a2
d3dbbbmLoop2	move.w	(a1)+,d3
		beq.s	d3dbbmSkip
		move.w	d3,(a2)
d3dbbmSkip	addq.l	#2,a2
		dbra	d2,d3dbbbmLoop2
		adda.w	lineoffset,a0
		dbra	d1,d3dbbbmLoop1

		rts


; ---------------------------------------------------------
; 02.01.00/vk
; vergleicht die zur verfuegung stehende rahmenbreite
; mit den zu zeichnenden rahmengrafikdaten.
; d1.w = moegliche rahmenbreite oben
; d2.w = moegliche rahmenbreite unten
; d3.w = moegliche rahmenbreite links
; d4.w = moegliche rahmenbreite rechts
; rueckgabe: d0.w = 0 (platz ist da), -1 (kein platz)
d3dbIsEnoughSpaceForBorder

		lea	border3dData,a0
		cmp.w	BORDER3DNEEDFREEUPPER(a0),d1
		blt.s	d3dbiesfbNoSpace
		cmp.w	BORDER3DNEEDFREELOWER(a0),d2
		blt.s	d3dbiesfbNoSpace
		cmp.w	BORDER3DNEEDFREELEFT(a0),d3
		blt.s	d3dbiesfbNoSpace
		cmp.w	BORDER3DNEEDFREERIGHT(a0),d4
		blt.s	d3dbiesfbNoSpace
		moveq	#0,d0
		bra.s	d3dbiesfbOut
d3dbiesfbNoSpace
		moveq	#-1,d0
d3dbiesfbOut
		rts


; ---------------------------------------------------------
; 02.01.00/vk
; berechnet die maximal moeglichen rahmenbreiten (border)
; der vier fensterseiten.
; moegliche rahmenbreiten werden in 3dborderfree<...> gespeichert.
; rueckgabe: d1.w = moegliche rahmenbreite oben
;            d2.w = moegliche rahmenbreite unten
;            d3.w = moegliche rahmenbreite links
;            d4.w = moegliche rahmenbreite rechts
d3dbCalcBorderSpace

		lea	border3dData,a0
		lea	c3p,a5

		move.w	C3PHEIGHTMAX(a5),d1
		move.w	C3PHEIGHT(a5),d5
		move.w	d5,BORDER3DSCREENHEIGHT(a0)
		sub.w	d5,d1
		lsr.w	#1,d1
		move.w	d1,d2
		move.w	d1,BORDER3DISFREEUPPER(a0)
		move.w	d2,BORDER3DISFREELOWER(a0)

		move.w	C3PWIDTHMAX(a5),d3
		move.w	C3PWIDTH(a5),d5
		sub.w	d5,d3
		lsr.w	#1,d3
		tst.w	doubleScan
		beq.s	d3dbcbsNoDouble
		add.w	d3,d3
		add.w	d5,d5
d3dbcbsNoDouble	move.w	d5,BORDER3DSCREENWIDTH(a0)
		move.w	d3,d4
		move.w	d3,BORDER3DISFREELEFT(a0)
		move.w	d4,BORDER3DISFREERIGHT(a0)

		rts




		data


border3dData	dc.l	border3dGfx0		; oben
		dc.l	border3dGfx1		; unten
		dc.l	border3dGfx2		; links
		dc.l	border3dGfx3		; rechts
		dc.l	border3dGfx4		; links oben
		dc.l	border3dGfx5		; rechts oben
		dc.l	border3dGfx6		; links unten
		dc.l	border3dGfx7		; rechts unten
		dc.w	3,24,12,12
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0,0

border3dGfx0	dc.l	b3dg0			; pointer auf grafik
		dc.w	24,24			; breite und hoehe
		dc.w	0,0
		dc.w	24*2
		dc.w	0,0,0

border3dGfx1	dc.l	b3dg1
		dc.w	24,24
		dc.w	0,0
		dc.w	24*2
		dc.w	0,0,0

border3dGfx2	dc.l	b3dg2
		dc.w	12,4
		dc.w	0,0
		dc.w	12*2
		dc.w	0,0,0

border3dGfx3	dc.l	b3dg3
		dc.w	12,4
		dc.w	0,0
		dc.w	12*2
		dc.w	0,0,0

border3dGfx4	dc.l	b3dg4
		dc.w	14,30
		dc.w	14,24
		dc.w	14*2
		dc.w	0,0,0

border3dGfx5	dc.l	b3dg5
		dc.w	14,30
		dc.w	14,24
		dc.w	14*2
		dc.w	0,0,0

border3dGfx6	dc.l	b3dg6
		dc.w	14,32
		dc.w	14,24
		dc.w	14*2
		dc.w	0,0,0

border3dGfx7	dc.l	b3dg7
		dc.w	24,32
		dc.w	14,24
		dc.w	24*2
		dc.w	0,0,0


b3dg0		incbin	"include\3dborder\3dupper.rbf"
		even
b3dg1		incbin	"include\3dborder\3dlower.rbf"
		even
b3dg2		incbin	"include\3dborder\3dleft.rbf"
		even
b3dg3		incbin	"include\3dborder\3dright.rbf"
		even
b3dg4		incbin	"include\3dborder\3duleft.rbf"
		even
b3dg5		incbin	"include\3dborder\3duright.rbf"
		even
b3dg6		incbin	"include\3dborder\3dlleft.rbf"
		even
b3dg7		incbin	"include\3dborder\3dlright.rbf"
		even


; wenn gesetzt, wird die dimension des 3d fensters in der 3d border angezeigt
drawDimensionsFlag	dc.w	0