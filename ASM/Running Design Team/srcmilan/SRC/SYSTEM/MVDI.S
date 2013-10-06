
MVDI_MI_MAGIC		equ	$4d49

MVDI_CMD_GETMODE	equ	0
MVDI_CMD_SETMODE	equ	1
MVDI_CMD_GETINFO	equ	2
MVDI_CMD_ALLOCPAGE	equ	3
MVDI_CMD_FREEPAGE	equ	4
MVDI_CMD_FLIPPAGE	equ	5
MVDI_CMD_ALLOCMEM	equ	6
MVDI_CMD_FREEMEN	equ	7
MVDI_CMD_SETADR		equ	8

MVDI_BLK_ERR		equ	0
MVDI_BLK_OK		equ	1
MVDI_BLK_CLEARED	equ	2

MVDI_SCRINFO_OK		equ	1

MVDI_NO_CLUT		equ	0
MVDI_HARD_CLUT		equ	1
MVDI_SOFT_CLUT		equ	2

; screeninfo struktur (mvdi ab 12.1.2000)
MVDI_SCRINFOSIZE	equ	0
MVDI_SCRINFODEVID	equ	4
MVDI_SCRINFONAME	equ	8
MVDI_SCRINFOSCRFLAGS	equ	72
MVDI_SCRINFOFRAMEADR	equ	76
MVDI_SCRINFOSCRWIDTH	equ	80
MVDI_SCRINFOSCRHEIGHT	equ	84
MVDI_SCRINFOVIRTWIDTH	equ	88
MVDI_SCRINFOVIRTHEIGHT	equ	92
MVDI_SCRINFOSCRPLANES	equ	96
MVDI_SCRINFOSCRCOLORS	equ	100
MVDI_SCRINFOLINEWARP	equ	104
MVDI_SCRINFOPLANEWARP	equ	108
MVDI_SCRINFOSCRFORMAT	equ	112
MVDI_SCRINFOSCRCLUT	equ	116
MVDI_SCRINFOREDBITS	equ	120
MVDI_SCRINFOGREENBITS	equ	124
MVDI_SCRINFOBLUEBITS	equ	128
MVDI_SCRINFOALPHABITS	equ	132
MVDI_SCRINFOGENLOCKBITS	equ	136
MVDI_SCRINFOUNUSEDBITS	equ	140
MVDI_SCRINFOBITFLAGS	equ	144
MVDI_SCRINFOMAXMEM	equ	148
MVDI_SCRINFOPAGEMEM	equ	152
MVDI_SCRINFOMAXX	equ	156
MVDI_SCRINFOMAXY	equ	160

MVDI_SCRINFOBYTES	equ	164




		text


; ---------------------------------------------------------
; 14.01.00/vk
; aktuelle physbase abfragen.
; rueckgabe: d0/a0 = zeiger auf physbase
getPhysbase
		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		movea.l	d0,a0
		rts


; ---------------------------------------------------------
; 14.01.00/vk
; aktuelle logbase abfragen.
; rueckgabe: d0/a0 = zeiger auf logbase
getLogbase
		move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		movea.l	d0,a0
		rts


; ---------------------------------------------------------
; 12.01.00/vk
; aktuellen video id (modus) erfragen.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; rueckgabe: d0 = aktuelle video id oder fehler
mvdiSetscreenGetMode

		move.w	#MVDI_CMD_GETMODE,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		pea	templong
		move.l	#-1,-(sp)
		move.w	#5,-(sp)			; setscreen()
		trap	#14
		lea	14(sp),sp		

		lea	templong,a0
		move.l	(a0),d0				; d0 = aktuelle video id

		rts


; ---------------------------------------------------------
; 12.01.00/vk
; neuen video id (grafik modus) setzen.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; d0 = zu setzende video id
; kein rueckgabewert
mvdiSetscreenSetMode

		move.w	#MVDI_CMD_SETMODE,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		andi.l	#$ffff,d0
		move.l	d0,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)			; setscreen()
		trap	#14
		lea	14(sp),sp

		rts


; ---------------------------------------------------------
; 12.01.00/vk
; screeninfo-struktur fuer aktuellen modus (video id) fuellen.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; rueckgabe: siehe mvdisetscreengetinfo()
mvdiSetscreenGetInfoCurrentMode

		moveq	#0,d0
		bsr	mvdiSetscreenGetInfo

		rts


; ---------------------------------------------------------
; 12.01.00/vk
; screeninfo-struktur fuer angegebenen modus (video id) fuellen.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; d0 = modus fuer abfrage (0 = aktueller modus)
; rueckgabe: a0 = pointer auf screeninfo-struktur
mvdiSetscreenGetInfo

		lea	screenInfo,a0
		move.l	a0,-(sp)

		move.l	#MVDI_SCRINFOBYTES,MVDI_SCRINFOSIZE(a0)
		ext.l	d0
		move.l	d0,MVDI_SCRINFODEVID(a0)
		clr.l	MVDI_SCRINFOSCRFLAGS(a0)

		move.w	#MVDI_CMD_GETINFO,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		move.l	a0,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		movea.l	(sp)+,a0

		rts


; ---------------------------------------------------------
; 14.01.00/vk
; speicher auf der grafikkarte fuer zweite bildschirmseite
; wieder freigeben, falls vorher welcher allokiert wurde.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
mvdiSetscreenFreePageIfRequired

		lea	mvdiscapFrame,a0
		tst.l	(a0)
		beq.s	mvdiscfpirOut

		clr.l	(a0)

		lea	ltVideoFreePage,a0
		bsr	logString

		bsr.s	mvdiSetscreenFreePage

mvdiscfpirOut
		rts


; ---------------------------------------------------------
; 14.01.00/vk
; speicher auf der grafikkarte fuer zweite bildschirmseite
; wieder freigeben.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
mvdiSetscreenFreePage

		move.w	#MVDI_CMD_FREEPAGE,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		moveq	#-1,d0
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		rts


; ---------------------------------------------------------
; 14.01.00/vk
; speicher auf der grafikkarte fuer zweite bildschirmseite
; anfordern.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; rueckgabe: d0 = frameadresse
;            a0 = pointer auf frameadresse
mvdiSetscreenAllocPage

		lea	mvdiscapFrame,a0
		clr.l	(a0)
		move.l	a0,-(sp)

		move.w	#MVDI_CMD_ALLOCPAGE,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		move.l	a0,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		movea.l	(sp)+,a0
		move.l	(a0),d0

		rts


; ---------------------------------------------------------
; 14.01.00/vk
; vertauscht die beiden bildschirmseiten.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
mvdiSetscreenFlipPage

		move.w	#MVDI_CMD_FLIPPAGE,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		moveq	#-1,d0
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		rts


; ---------------------------------------------------------
; 15.01.00/vk
; setzt die bildschirmadressen fuer physbase und logbase.
; nur ab treiberversion vom 12.1.2000 verfuegbar.
; a0 = neue logbase
; a1 = neue physbase
mvdiSetscreenSetAdr

		move.w	#MVDI_CMD_SETADR,-(sp)
		move.w	#MVDI_MI_MAGIC,-(sp)
		move.l	a1,-(sp)
		move.l	a0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		rts


; ---------------------------------------------------------
; 15.01.00/vk
; fuellt einen rechteckbereich mit einer farbe.
; d0 = farbwert
; d1 = x1
; d2 = y1
; d3 = x2
; d4 = y2
mvdiSolidrect
		movem.w	d0-d4,-(sp)
		bsr	mvdiHardSolidrect	; hardwareroutine aufrufen
		tst.l	d0			; konnte in hardware ausgefuehrt werden?
		bpl.s	mvdisrPreOut		; ja -> raus

		movem.w	(sp)+,d0-d4
		bsr	mvdiSoftSolidrect
		bsr	binToHexPrintLine	; todo
		bra.s	mvdisrOut
mvdisrPreOut
		movem.w	(sp)+,d0-d4
mvdisrOut
		rts


; ---------------------------------------------------------
; 16.01.00/vk
; fuellt einen rechteckbereich mit einem monochromen pattern.
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4 = fgcolor
; d5 = bgcolor
; a6 = zeiger auf patterndata (arraydaten und arraygroesse)
mvdiPatternrect
		movem.l	d0-d5/a6,-(sp)
		bsr	mvdiHardPatternrect	; hardwareroutine aufrufen
		tst.l	d0			; konnte in hardware ausgefuehrt werden?
		bpl.s	mvdiprPreOut		; ja -> raus

		movem.l	(sp)+,d0-d5/a6
		bsr	mvdiSoftPatternrect
		bsr	binToHexPrintLine	; todo
		bra.s	mvdiprOut
mvdiprPreOut
		movem.l	(sp)+,d0-d5/a6
mvdiprOut
		rts





		data








		bss


; fuer mvdisetscreengetinfo() notwendige struktur
screenInfo	ds.b	MVDI_SCRINFOBYTES

; fuer mvdiSetscreenAllocPage erforderlich
mvdiscapFrame	ds.l	1
