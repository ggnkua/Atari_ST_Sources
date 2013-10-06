
; struktur solidrectdata
SOLIDRECTX1		equ	0
SOLIDRECTY1		equ	2
SOLIDRECTX2		equ	4
SOLIDRECTY2		equ	6
SOLIDRECTFGCOLOR	equ	8
SOLIDRECTBGCOLOR	equ	12
SOLIDRECTMODE		equ	16

; struktur patternrectdata
PATTERNRECTX1		equ	0
PATTERNRECTY1		equ	2
PATTERNRECTX2		equ	4
PATTERNRECTY2		equ	6
PATTERNRECTFGCOLOR	equ	8
PATTERNRECTBGCOLOR	equ	12
PATTERNRECTMODE		equ	16
PATTERNRECTPATPTR	equ	18
PATTERNRECTPATMSK	equ	22



		text


; ---------------------------------------------------------
; 15.01.00/vk
; fuellt einen rechteckbereich mit einer farbe.
; hardwareroutine auf der grafikkarte.
; d0 = farbwert
; d1 = x1
; d2 = y1
; d3 = x2
; d4 = y2
mvdiHardSolidrect 

		lea	solidrectData,a0
		move.l	d0,SOLIDRECTFGCOLOR(a0)
		move.w	d1,SOLIDRECTX1(a0)
		move.w	d2,SOLIDRECTY1(a0)
		move.w	d3,SOLIDRECTX2(a0)
		move.w	d4,SOLIDRECTY2(a0)
		clr.w	SOLIDRECTMODE(a0)
		move.l	#$00010001,d0			; draw_solidrect
		movea.l	lineaParPtr,a1
		movea.l	vdiDispatcher,a6
		jsr	(a6)

		rts


; ---------------------------------------------------------
; 16.01.00/vk
; fuellt einen rechteckbereich mit einem monochromen pattern.
; hardwareroutine auf der grafikkarte.
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = fgcolor
; d5 = bgcolor
; a6 = zeiger auf patterndata (arraydaten und arraygroesse)
mvdiHardPatternrect
		lea	patternrectData,a0
		move.w	d0,PATTERNRECTX1(a0)
		move.w	d1,PATTERNRECTY1(a0)
		move.w	d2,PATTERNRECTX2(a0)
		move.w	d3,PATTERNRECTY2(a0)
		move.l	d4,PATTERNRECTFGCOLOR(a0)
		move.l	d5,PATTERNRECTBGCOLOR(a0)
		clr.w	PATTERNRECTMODE(a0)
		move.l	PATTERNDATAARRAY(a6),PATTERNRECTPATPTR(a0)
		move.w	PATTERNDATAMASK(a6),PATTERNRECTPATMSK(a0)
		move.l	#$00020001,d0					; draw_patternrect
		movea.l	lineaParPtr,a1
		movea.l	vdiDispatcher,a6
		jsr	(a6)

		rts







		data



		bss


solidrectData	ds.w	4
		ds.l	2
		ds.w	1

patternrectData	ds.w	4
		ds.l	2
		ds.w	1
		ds.l	1
		ds.w	1
