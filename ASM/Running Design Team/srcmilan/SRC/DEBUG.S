
PHCOLOR		equ	%1100011000011000
PHSHADINGCOLOR	equ	%0011100111000111


; ---------------------------------------------------------
		text
; ---------------------------------------------------------


; ---------------------------------------------------------
; address.l,-(sp) = 12(a6)
; value.l,-(sp) = 8(a6)
; ---------------------------------------------------------
paintHex
		link	a6,#0

		movea.l	12(a6),a3	; address
		moveq	#7,d4
		move.l	8(a6),d3	; value
phLoop
		rol.l	#4,d3
		move.w	d3,d0
		andi.w	#$000f,d0

		movea.l	a3,a5
		bsr	phNumber

		lea	10(a3),a3

		dbra	d4,phLoop

		unlk	a6

		rts

; d0 = number
; a5 = address
; benutzt d0-d2/a4-a5
phNumber
		movea.l	a5,a4
		suba.w	lineoffset,a4
		move.w	#PHSHADINGCOLOR,-2(a4)
		move.w	#PHSHADINGCOLOR,(a4)
		move.w	#PHSHADINGCOLOR,2(a4)
		move.w	#PHSHADINGCOLOR,4(a4)
		move.w	#PHSHADINGCOLOR,6(a4)
		move.w	#PHSHADINGCOLOR,8(a4)

		move.w	lineoffset,d2
		mulu	#7,d2
		movea.l	a5,a4
		adda.l	d2,a4
		move.w	#PHSHADINGCOLOR,-2(a4)
		move.w	#PHSHADINGCOLOR,(a4)
		move.w	#PHSHADINGCOLOR,2(a4)
		move.w	#PHSHADINGCOLOR,4(a4)
		move.w	#PHSHADINGCOLOR,6(a4)
		move.w	#PHSHADINGCOLOR,8(a4)

		lea	paintHexNumbers,a4
		movea.l	(a4,d0.w*4),a4
		move.w	lineoffset,d2

		moveq	#6,d0		; zeilenanzahl
phnLoopY	moveq	#3,d1		; spaltenanzahl

		move.w	#PHSHADINGCOLOR,-2(a5)

phnLoopX	tst.b	(a4)+
		beq.s	phnBackPixel
		move.w	#PHCOLOR,(a5)
		bra.s	phnSkipPixel
phnBackPixel	move.w	#PHSHADINGCOLOR,(a5)

phnSkipPixel	addq.l	#2,a5
		dbra	d1,phnLoopX

		move.w	#PHSHADINGCOLOR,(a5)

		adda.w	lineoffset,a5
		subq.l	#8,a5
		dbra	d0,phnLoopY

		rts


; ---------------------------------------------------------
; d0.l = hexvalue
; rueckgabe:
; a0.l = pointer auf ascii-ziffern inkl. 0-byte
; ---------------------------------------------------------
binToHex	
		movem.l	d1-d7/a1-a6,-(sp)

		lea	_bthASCII,a0
		movea.l	a0,a1
		moveq	#7,d2
_bthLoop	rol.l	#4,d0
		move.b	d0,d1
		andi.w	#$000f,d1
		cmpi.w	#9,d1
		bgt.s	_bthHex
		addi.b	#$30,d1
		bra.s	_bthOk
_bthHex		addi.b	#$41-10,d1
_bthOk		move.b	d1,(a0)+
		dbra	d2,_bthLoop
_bthOut
		clr.b	(a0)
		movea.l	a1,a0
		movem.l	(sp)+,d1-d7/a1-a6
		rts


; ---------------------------------------------------------
; d0.l = hexvalue
; ---------------------------------------------------------
binToHexPrint
		movem.l	d0-a6,-(sp)

		bsr.s	binToHex

		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		pea	Tspace
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; d0.l = hexvalue
; ---------------------------------------------------------
binToHexPrintLine

		movem.l	d0-a6,-(sp)

		bsr.s	binToHex

		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		pea	TnewLine
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 30.07.00/vk
; gibt die position des spielers auf dem screen aus.
		IFEQ FINAL
DPPOFFSET	equ	200*2048+64
drawPlayerPosition

		movea.l	screen_1,a0
		adda.l	#DPPOFFSET,a0
		move.l	a0,-(sp)
		movea.l	playerDataPtr,a6
		move.l	PDSX(a6),-(sp)
		bsr	paintHex
		addq.l	#8,sp

		movea.l	screen_1,a0
		adda.l	#DPPOFFSET+10*2048,a0
		move.l	a0,-(sp)
		movea.l	playerDataPtr,a6
		move.l	PDSY(a6),-(sp)
		bsr	paintHex
		addq.l	#8,sp

		movea.l	screen_1,a0
		adda.l	#DPPOFFSET+20*2048,a0
		move.l	a0,-(sp)
		movea.l	playerDataPtr,a6
		move.l	PDSH(a6),-(sp)
		bsr	paintHex
		addq.l	#8,sp

		movea.l	screen_1,a0
		adda.l	#DPPOFFSET+30*2048,a0
		move.l	a0,-(sp)
		movea.l	playerDataPtr,a6
		move.w	PDALPHA(a6),d0
		andi.l	#$ffff,d0
		move.l	d0,-(sp)
		bsr	paintHex
		addq.l	#8,sp

		movea.l	screen_1,a0
		adda.l	#DPPOFFSET+40*2048,a0
		move.l	a0,-(sp)
		movea.l	playerDataPtr,a6
		move.w	PDCURRENTSECTOR(a6),d0
		andi.l	#$ffff,d0
		move.l	d0,-(sp)
		bsr	paintHex
		addq.l	#8,sp

		rts

		ENDC



; ---------------------------------------------------------
		data
; ---------------------------------------------------------


_bthASCII	dc.b	0,0,0,0,0,0,0,0,0,0
		even

paintHexNumbers	dc.l	ph0
		dc.l	ph1
		dc.l	ph2
		dc.l	ph3
		dc.l	ph4
		dc.l	ph5
		dc.l	ph6
		dc.l	ph7
		dc.l	ph8
		dc.l	ph9
		dc.l	phA
		dc.l	phB
		dc.l	phC
		dc.l	phD
		dc.l	phE
		dc.l	phF

ph0		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,0

ph1		dc.b	0,0,1,0
		dc.b	0,1,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,1,1,1

ph2		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,0,1,0
		dc.b	0,1,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,1

ph3		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	0,0,0,1
		dc.b	0,1,1,0
		dc.b	0,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,0

ph4		dc.b	0,0,1,0
		dc.b	0,1,1,0
		dc.b	1,0,1,0
		dc.b	1,1,1,1
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0

ph5		dc.b	1,1,1,1
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,0
		dc.b	0,0,0,1
		dc.b	0,0,0,1
		dc.b	1,1,1,0

ph6		dc.b	0,1,1,0
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,0

ph7		dc.b	1,1,1,1
		dc.b	0,0,0,1
		dc.b	0,0,0,1
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0
		dc.b	0,0,1,0

ph8		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,0

ph9		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	0,1,1,1
		dc.b	0,0,0,1
		dc.b	0,0,0,1
		dc.b	0,1,1,0

phA		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,1,1,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1

phB		dc.b	1,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,1,1,0

phC		dc.b	0,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,0,0,1
		dc.b	0,1,1,0

phD		dc.b	1,1,1,0
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,0,0,1
		dc.b	1,1,1,0

phE		dc.b	1,1,1,1
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,0
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,1

phF		dc.b	1,1,1,1
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,1,1,0
		dc.b	1,0,0,0
		dc.b	1,0,0,0
		dc.b	1,0,0,0


TnewLine	dc.b	13,10,0
Tspace		dc.b	" ",0

