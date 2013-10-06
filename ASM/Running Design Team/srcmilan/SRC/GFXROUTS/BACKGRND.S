
; moegliche hintergruende (konstanten)
BACKGROUNDSIMPLE	equ	0		; einfaches strukturmuster ueber hardware (grafikkarte)
BACKGROUNDTEXTURE	equ	1		; gekachelte textur

; einstellungen fuer running
BACKGROUNDMODESTANDARD	equ	BACKGROUNDSIMPLE
BACKGROUNDMODEMAP	equ	BACKGROUNDSIMPLE


CBTILEDIMENSION		equ	64
CBTILEDIMENSIONBITS	equ	6
CBTILEDIMENSIONMASK	equ	%111111


; struktur patterndata
PATTERNDATAARRAY	equ	0		; zeiger auf array mit patterndaten (16 bit werte)
PATTERNDATAMASK		equ	4		; arraygroesse (in 16 bit werten) minus 1
PATTERNDATABYTES	equ	6



		text


; ---------------------------------------------------------
; 04.01.00/vk
; zeichnet - falls notwendig - den hintergrund des logischen screens.
drawBackgroundIfRequired

	; allgemeines flag zum loeschen beider screens abarbeiten

		lea	clearBackgroundFlag,a3
		tst.w	(a3)				; muessen hintergruende neu gezeichnet werden?
		beq.s	dbirNoGeneralFlag		; nein -> normal weiter

		clr.w	(a3)				; flag wieder loeschen

		movea.l	screenData1Ptr,a0		; .\src\system\video.s
		movea.l	screenData2Ptr,a1
		move.w	#1,SCREENDATACLEARFLAG(a0)	; das flag zum loeschen bei beiden
		move.w	#1,SCREENDATACLEARFLAG(a1)	; screens setzen
dbirNoGeneralFlag

	; den logischen screen nun ggf. loeschen

		movea.l	screenData1Ptr,a0
		tst.w	SCREENDATACLEARFLAG(a0)
		beq.s	dbirNoScreenFlag

		clr.w	SCREENDATACLEARFLAG(a0)

		moveq	#BACKGROUNDMODESTANDARD,d0	; d0 = modus
		bsr.s	drawBackground			; und hintergrund tatsaechlich neu zeichnen (auf logischem screen)

		move.w	#1,d3dbmFlag			; rahmen der 3d fenster-umrandung neu zeichnen (todo?)
		bra.s	dbirOut

dbirNoScreenFlag

	; wenn keine flags gesetzt sind, muss der screen nicht doch geloescht werden, weil maps o. ae. angezeigt werden?

		tst.w	mapFlag				; kartenmodus aktiv?
		beq.s	dbirNoMap			; nein -> normal weiter
		move.w	mapMode,d0
		cmpi.w	#MAPMAIN,d0			; grosse karte aktiv?
		bne.s	dbirNoMap			; nein -> normal weiter
		moveq	#BACKGROUNDMODESTANDARD,d0
		bsr.s	drawBackground
		bra.s	dbirOut
dbirNoMap
		nop
dbirOut
		rts


; ---------------------------------------------------------
; 16.01.00/vk
; zeichnet den hintergrund des screens im angegebenen modus
; neu in den logischen screen.
; d0 = modus (siehe konstantendefinition am dateianfang)
drawBackground
		cmpi.w	#BACKGROUNDSIMPLE,d0
		bne.s	dbNoSimple
		bsr.s	drawBackgroundSimple
		bra.s	dbOut
dbNoSimple
		cmpi.w	#BACKGROUNDTEXTURE,d0
		bne.s	dbNoTexture
		bsr.s	drawBackgroundTexture
		bra.s	dbOut
dbNoTexture
		nop
dbOut
		rts


; ---------------------------------------------------------
; 02.06.00/vk
; setzt das flag zum loeschen beider screens.
; rettet alle register
setFlagToClearBackground
		move.w	#1,clearBackgroundFlag
		rts


; ---------------------------------------------------------
; 21.05.00/vk
; zeichnet den hintergrund des screens mit einfachem
; strukturmuster ueber hardwareroutinen der grafikkarte
drawBackgroundSimple

		movea.l	screenData1Ptr,a0			; datenstruktur fuer logischen screen holen
		move.w	SCREENDATAYOFFSET(a0),d1		; offset innerhalb des videoram holen

		moveq	#0,d0
		move.w	width,d2
		move.w	height,d3
		add.w	d1,d3
		subq.w	#1,d2
		subq.w	#1,d3
;		move.w	#%1100011000011000,d4
;		move.w	#%0111101111101111,d5
		move.w	#%0001100011100011,d4
		moveq	#0,d5
		lea	patternStandard,a6
		bsr	mvdiPatternrect

		rts
		

; ---------------------------------------------------------
; 04.01.00/vk
; todo
drawBackgroundTexture

		rts


; ---------------------------------------------------------
; zeichnet ein kachelmuster auf den gesamten screen
clearBackground
;		tst.w	mapFlag
;		bne.s	cbNoMap
;		bsr	clearMessages
cbNoMap
;		tst.w	consoleFlag
		; todo		

		lea	backgroundGfx+128,a5
		movea.l	screen_1,a6

		move.w	width,d0
		move.w	height,d1

		bsr	clearBackgroundWindow

		rts


; ---------------------------------------------------------
; zeichnet ein kachelmuster in das akt. 3d fenster
clearBackground3dWindow
;		tst.w	mapFlag
;		bne.s	cb3wNoMap
;		bsr	clearMessages
cb3wNoMap
;		tst.w	consoleFlag
		; todo		

		lea	backgroundGfx+128,a5
		movea.l	screen_1,a6

		move.w	c3pWidth,d0
		move.w	c3pHeight,d1

		bsr	clearBackgroundWindow

		rts


; d0 = width
; d1 = height
; a5 = background
; a6 = screen
clearBackgroundWindow
		move.w	d0,d2
		lsr.w	#CBTILEDIMENSIONBITS,d2		; 64 pixel kachelbreite
		andi.w	#CBTILEDIMENSIONMASK,d0
		
		moveq	#0,d3				; zaehler y-zeile
		subq.w	#1,d1
cbYLoop

	; berechne y-zeile kachel

		move.w	d3,d4
		ext.l	d4
		lsl.l	#CBTILEDIMENSIONBITS+1,d4
		movea.l	a5,a4
		adda.l	d4,a4

		move.w	d2,d4
		beq.s	cbylNoFullTile
		subq.w	#1,d4
		movea.l	a6,a2
cbylFullLoop
		move.w	#CBTILEDIMENSION-1,d5
		movea.l	a4,a3
cbylflXLoop	move.w	(a3)+,(a2)+
		dbra	d5,cbylflXLoop

		dbra	d4,cbylFullLoop

cbylNoFullTile
		move.w	d0,d4
		beq.s	cbylSkip
		subq.w	#1,d4
cbylRestLoop	move.w	(a4)+,(a2)+
		dbra	d4,cbylRestLoop

cbylSkip
		addq.w	#1,d3
		andi.w	#CBTILEDIMENSIONMASK,d3

		adda.w	lineoffset,a6

		dbra	d1,cbYLoop


		rts






		data


backgroundGfx	incbin	"include\tpi\back_002.tpi"


; standardhintergrund
patternStandard	dc.l	ptnstdArray
		dc.w	4-1
ptnstdArray	dc.w	$4444,$1111,$8888,$2222


		bss




