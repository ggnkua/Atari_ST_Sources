
; achtung: die maximalwerte (laptopgroesse, fontgroesse) in .\datastru.s eintragen (abhaengigkeiten beachten)

; struktur laptopFontData
LFGFXPTR		equ	0			; adresse der grafikdaten
LFDELTAX		equ	4			; durchschnittliche breite der buchstaben
LFDELTAY		equ	6			; hoehe der buchstaben
LFLETTERWIDTHPTR	equ	8			; tabelle mit breitenangaben
LFLETTERGFXOFFSETPTR	equ	12			; tabelle mit texturoffsets
LFASCIICONVERTPTR	equ	16			; umsetztabelle ascii -> letter
LFLINEOFFSET		equ	20			; lineoffset fuer fontgrafik
LFCURSOR		equ	22			; code fuer cursor (letter, nicht ascii)
LFMINX			equ	24
LFMAXX			equ	26
LFMINY			equ	28
LFMAXY			equ	30
LFBACKCOLOR		equ	32


		text


; ---------------------------------------------------------
; 26.12.99/vk
; setzt die schriftart tahoma
; rettet alle verwendeten register
setLaptopFontTahoma
		movem.l	a0-a1,-(sp)
		lea	laptop,a0
		lea	laptopFontDataTahoma,a1
		move.l	a1,LAPTOPFONTDATAPTR(a0)
		bsr.s	initLaptopFont
		movem.l	(sp)+,a0-a1
		rts


; ---------------------------------------------------------
; 26.12.99/vk
; initialisiert den aktuellen font
; rettet alle verwendeten register
initLaptopFont
		movem.l	d5-d7/a0/a5-a6,-(sp)
		lea	laptop,a0
		movea.l	LAPTOPFONTDATAPTR(a0),a0
		movea.l	LFLETTERWIDTHPTR(a0),a5			; tabelle mit breitenangaben
		movea.l	LFLETTERGFXOFFSETPTR(a0),a6		; tabelle mit texturoffsets
		moveq	#128-1,d7
		moveq	#0,d6
ilfLoop		move.w	d6,(a6)+
		move.w	(a5)+,d5
		add.w	d5,d5
		add.w	d5,d6
		dbra	d7,ilfLoop
		movem.l	(sp)+,d5-d7/a0/a5-a6
		rts


; ---------------------------------------------------------
; 01.02.00/vk
; berechnet die breite (in buchstaben und pixeln) des
; uebergebenen strings fuer den aktuellen font.
; a0 = zeiger auf string
; rueckgabe: d0 = breite in buchstaben
;            d1 = breite in pixeln
; rettet alle register.
laptopCalcStringWidth

		movem.l	d2/a0-a2,-(sp)

		lea	laptop,a2
		movea.l	LAPTOPFONTDATAPTR(a2),a2
		movea.l	LFLETTERWIDTHPTR(a2),a1
		movea.l	LFASCIICONVERTPTR(a2),a2

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
lcswLoop	
		move.b	(a0)+,d2
		beq.s	lcswOut
		addq.w	#1,d0
		move.w	(a2,d2.w*2),d2
		add.w	(a1,d2.w*2),d1
		bra.s	lcswLoop
lcswOut
		movem.l	(sp)+,d2/a0-a2
		rts





		data


; ---------------------------------------------------------
; schriftart: tahoma
lfTahomaGfx	incbin	"include\fonts\tahoma.rbf"
		even

lfTahomaWidth	dc.w	6,6,6,6,6,4,6,6,3,4,6,3,9,6,6,6,6,5,5,4,6,6,9,6,6,5			; kleinbuchstaben
		dc.w	7,7,7,8,6,6,7,7,5,5,7,6,9,7,8,7,8,7,6,6,7,7,10,7,7,6			; grossbuchstaben
		dc.w	6,5,5,6,6,6,6,6,6,6,3,3,3,3,4,7,8,3,7,8,6,3,5,6,6,12,8			; sonderzeichen i
		dc.w	5,4,4,6,6,4,6,5,8,8,6,6,7,7,4,9,6					; sonderzeichen ii

lfTahomaGfxOffset
		ds.w	128

lfTahomaAsciiConvert
		dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1				; 0 - 15
		dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1				; 16 - 31
		dc.w	95,73,74,68,76,77,78,69,80,81,72,70,62,66,64,79				; 32 - 47
		dc.w	52,53,54,55,56,57,58,59,60,61,65,63,87,82,88,83				; 48 - 63
		dc.w	94,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40				; 64 - 79
		dc.w	41,42,43,44,45,46,47,48,49,50,51,89,84,90,85,66				; 80 - 95
		dc.w	-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14					; 96 - 111
		dc.w	15,16,17,18,19,20,21,22,23,24,25,91,93,92,71,-1				; 112 - 127

laptopFontDataTahoma
		dc.l	lfTahomaGfx
		dc.w	6
		dc.w	10
		dc.l	lfTahomaWidth
		dc.l	lfTahomaGfxOffset
		dc.l	lfTahomaAsciiConvert
		dc.w	1164
		dc.w	26
		dc.w	32
		dc.w	50
		dc.w	3
		dc.w	25
		dc.w	%0010000100000100
