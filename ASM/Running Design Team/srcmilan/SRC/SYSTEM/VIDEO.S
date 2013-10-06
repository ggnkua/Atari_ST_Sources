
VDIDRIVERVERSION	equ	0
VDISUBCOOKIE		equ	2
VDIDRIVERFLAGS		equ	6
VDIDISPATCHERADDRESS	equ	10

VIDEOID			equ	0
VIDEOALLOWED		equ	2
VIDEOBYTES		equ	4

; videodef-struktur (_VDI)
;VDEFNAME		equ	0
;VDEFDEVID		equ	64
;VDEFPLANES		equ	66
;VDEFVISIBLE		equ	68
;VDEFVIRTUAL		equ	72
;VDEFFLAGS		equ	76
;VDEFHORIZ		equ	78
;VDEFVERT		equ	84
;VDEFVIDADR		equ	90
;VDEFRES		equ	94

; struktur screendatax
SCREENDATAADDRESS	equ	0			; adresse des screens auf der grafikkarte
SCREENDATAYOFFSET	equ	4			; offset (in zeilen), um ersten bildschirmzeile anzusprechen (kann neg. sein)
SCREENDATACLEARFLAG	equ	6			; flag, ob screen geloescht werden muss
SCREENDATABORDERFLAG	equ	8			; flag, ob rahmen (border) neu gezeichnet werden muss
SCREENDATABYTES		equ	10			; laenge der datenstruktur

 
		text

; ---------------------------------------------------------
; videotreiber initialisieren, cookie abfragen,
; umschalten auf anfangsaufloesung 640x480
installVideo
		lea	ltVideoStart,a0
		bsr	logString

		bsr	readVDICookie			; _VDI Cookie auslesen

	; hole deviceid der aktuellen aufloesung (in der running gestartet wurde)

		bsr	mvdiSetscreenGetMode		; aktuellen modus erfragen
		move.w	d0,ivCurrentDeviceID		; device id speichern

	; anfang des videospeichers holen

		bsr	getPhysbase
		move.l	a0,physbase			; aktuelle physbase speichern

		bsr	binToHex
		lea	ltVideoXBiosPhysbaseM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltVideoXBiosPhysbase,a0
		bsr	logString

		bsr	getLogbase
		move.l	a0,logbase			; aktuelle physbase speichern

		bsr	binToHex
		lea	ltVideoXBiosLogbaseM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltVideoXBiosLogbase,a0
		bsr	logString

	; aufloesungswechsel durchfuehren, alle weiteren abhaengigkeiten bearbeiten (3d engine ...)
	; (aufloesung zu programmstart)

		clr.w	d0				; auf geringsten aufloesungsindex setzen
		bsr	setScreenAndReset3dEngine

	; bildschirm von weiss auf schwarz faden

		move.l	#$ffff,d0			; zuerst auf weiss setzen
		bsr	clearScreenWithColor		; hardware routine verwenden

		ifne FINAL
		move.w	#100,d7
		bsr	multipleVSync
		endc

		moveq	#31,d1				; 32 helligkeitsstufen
ivFadeLoop	move.w	d1,-(sp)
		move.w	d1,d0
		lsl.w	#5,d0
		add.w	d1,d0
		lsl.w	#6,d0
		add.w	d1,d0
		andi.l	#$0000ffff,d0
		bsr	clearScreenWithColor
		moveq	#2,d7
		bsr	multipleVSync
		move.w	(sp)+,d1
		dbra	d1,ivFadeLoop

		ifne USEVIDEOSCREENINRAM

	; fuer den screen im ram (hauptspeicher, nicht auf der grafikkarte) die maximale
	; groesse ermitteln und speicher allokieren

		move.w	#%0011,d0			; bevorzugt tt-ram
		move.l	videoModeMaxBytes,d1
		bsr	allocateMemory
		tst.l	d0
		bne.s	ivNoMemoryError

		lea	ltVideoScreenInRamError,a0	; keinen speicher mehr bekommen
		bsr	logString			; fehler protokollieren

		lea	stopSystemData,a0
		move.w	#SSNOTENOUGHMEMORY,SSCODE(a0)
		bsr	stopSystem			; und system anhalten

ivNoMemoryError
		move.l	d0,screenInRam

		endc

ivOut
		lea	ltVideoEnd,a0
		bsr	logString

		rts
		

; ---------------------------------------------------------
; videosystem auf vorherige aufloesung, in der running
; gestartet wurde, umschalten
restoreVideo
		lea	ltVideoReset,a0
		bsr	logString

		move.w	ivCurrentDeviceID,d0
		bsr	setScreenNoEngineReset

		rts


; ---------------------------------------------------------
; aufloesungswechsel durchfuehren
; inkl. zuruecksetzen der 3d engine und aller weiteren
; notwendigen parameter (z. B. codemodifikation)
; d0.w = index lt. videoModes (positiv)
; falls d0.w negativ, dann gilt:
; d1.w = video id
setScreenAndReset3dEngine

		tst.w	d0
		bpl.s	ssIndex
		move.w	d1,d0
		bra.s	ssOk
ssIndex
		lea	videoModes,a0			; hole video id ueber indexwert (tabelle)
		mulu	#VIDEOBYTES,d0
		move.w	VIDEOID(a0,d0.w),d0
ssOk
		bsr.s	setScreenNoEngineReset		; aufloesung wechseln ohne 3d engine zu resetten

		bsr	mvdiSetscreenGetMode		; aktuellen modus jetzt nochmals erfragen
		bsr	binToHex
		move.l	4(a0),ltVideoCurrentIDM
		lea	ltVideoCurrentID,a0
		bsr	logString

		move.w	width,d0
		move.w	height,d1
		bsr	reset3dEngine			; achtung: d0/d1 als parameter werden uebergeben
		bsr	calcVblFactor		
		bsr	modifyPaintCodeAddresses
		bsr	laptopCalcScreenOffset
		bsr	scannerResetFields		; .\src\console\scanner.s
		bsr	geigerResetFields		; .\src\console\geiger.s
		bsr	consoleResetFields		; .\src\console\init.s

		rts

                                                                                                                                      
; ---------------------------------------------------------
; 14.01.00/vk
; aufloesungswechsel durchfuehren, kein zuruecksetzen
; der 3d engine, also nur reiner aufloesungswechsel.
; es wird eine speicher fuer eine zweite bildschirmseite
; ebenfalls mitangefordert. screen_1 und screen_2
; werden korrekt gesetzt. der bildschirm wird schwarz
; ausgefuellt.
; d0.w = video id
setScreenNoEngineReset

		move.w	d0,-(sp)
		bsr	binToHex
		lea	ltVideoSettingToM,a1
		move.b	4(a0),(a1)
		move.b	5(a0),1(a1)
		move.b	6(a0),2(a1)
		move.b	7(a0),3(a1)
		lea	ltVideoSettingTo,a0
		bsr	logString
		move.w	(sp)+,d0

		move.w	d0,ssnerModeToSet

	; evtl. vorher allokierten speicher auf der grafikkarte freigeben

		bsr	mvdiSetscreenFreePageIfRequired

	; aufloesung physikalisch mit _setscreen setzen

		bsr	mvdiSetscreenSetMode

	; screeninfo-struktur erfragen und interne running variable setzen (bildschirmgroesse etc.)

		bsr	mvdiSetscreenGetInfoCurrentMode

		moveq	#MVDI_SCRINFO_OK,d0
		cmp.l	MVDI_SCRINFOSCRFLAGS(a0),d0	; strukturdaten gueltig?
		beq.s	ssnerScrInfoOk			; ja -> normal weiter

		move.w	ssnerModeToSet,d0
		bsr	mvdiSetscreenSetMode
		bsr	mvdiSetscreenGetInfoCurrentMode

		moveq	#MVDI_SCRINFO_OK,d0
		cmp.l	MVDI_SCRINFOSCRFLAGS(a0),d0	; strukturdaten gueltig?
		beq.s	ssnerScrInfoOk			; ja -> normal weiter

		lea	ltVideoScrInfoError,a0
		bsr	logString
		bra	ssnerOut			; todo: stopsystem() waere eigentlich besser, da sonst bestimmt absturz

ssnerScrInfoOk
		move.w	MVDI_SCRINFODEVID+2(a0),videoID
		move.w	MVDI_SCRINFOSCRWIDTH+2(a0),d0	; width
		move.w	MVDI_SCRINFOSCRHEIGHT+2(a0),d1	; height

		move.w	d0,width			; setze variablen fuer breite und hoehe
		move.w	d1,height
		add.w	d0,d0
		move.w	d0,lineoffset			; setze variable fuer lineoffset

		move.w	MVDI_SCRINFOSCRPLANES+2(a0),bpp

		move.l	MVDI_SCRINFOFRAMEADR(a0),d0
		bsr	binToHex
		lea	ltVideoFrameBufferM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltVideoFrameBuffer,a0
		bsr	logString

	; bildschirm schwarz fuellen

		bsr	clearScreen			; evtl. hardware routine verwenden

	; variablen fuer erste bildschirmseite setzen

		bsr	getPhysbase
		bsr	setScreen2			; arg. a0: screen_2 wird physikalischer screen

		move.l	a0,d0
		bsr	binToHex
		lea	ltVideoFirstPageM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltVideoFirstPage,a0
		bsr	logString

	; variablen fuer zweite bildschirmseite setzen, u. a. speicher fuer zweite bildschirmseite anfordern

		bsr	mvdiSetscreenAllocPage		; danach neuen speicher wieder anfordern
		tst.l	d0
		beq.s	ssnerAllocPageFailed

		movea.l	d0,a0
		bsr	setScreen1			; arg. a0: screen_1 wird logischer screen

		bsr	binToHex			; erhaltene speicheradresse protokollieren
		lea	ltVideoAllocPageM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltVideoAllocPage,a0
		bsr	logString
		
		bra.s	ssnerapOk

ssnerAllocPageFailed

		lea	ltVideoAllocPageFailed,a0	; speicheranforderung fuer 2. seite fehlgeschlagen
		bsr	logString			; also protokollieren 

		movea.l	screen_2,a0
		bsr	setScreen1			; und als 2. seite ebenfalls die erste verwenden
ssnerapOk
		bsr	setScreenCheckIntegrity

ssnerOut

		rts

                                                                                                                                      
; ---------------------------------------------------------
; cookie _VDI auslesen, brauchen adresse des
; funktionsdispatchers
readVDICookie
		move.l	$5a0.w,d0			; cookie-jar (anscheinend auch auf dem milan)
		beq	rvcNoCookieJar			; keiner da

		movea.l	d0,a0				; adresse in adressregister
rvcLoop		move.l	0(a0),d0			; naechsten cookie holen
		beq	rvcNoVDICookie			; ende schon erreicht
		cmpi.l	#"_VDI",d0			; cookie gefunden?
		beq.s	rvcFound			; ja -> verzweigen
		addq.l	#8,a0				; zeiger auf naechsten cookie setzen
		bra.s	rvcLoop				; und von vorne

rvcFound
		move.l	4(a0),a0			; cookie-wert
		move.l	a0,vdiStructurePtr
		move.l	VDIDISPATCHERADDRESS(a0),vdiDispatcher

		move.l	a0,-(sp)
		move.l	VDIDRIVERVERSION(a0),d0
		bsr	binToHex
		move.l	(a0),ltVideoDriverVersionM
		move.l	4(a0),ltVideoDriverVersionM+4
		lea	ltVideoDriverVersion,a0
		bsr	logString
		move.l	(sp)+,a0

		move.l	VDIDRIVERFLAGS(a0),d0
		bsr	binToHex
		move.l	(a0),ltVideoDriverFlagsM
		move.l	4(a0),ltVideoDriverFlagsM+4
		lea	ltVideoDriverFlags,a0
		bsr	logString

		rts


rvcNoCookieJar
		lea	ltVideoNoCookieJar,a0
		bsr	logString

		lea	stopSystemData,a0
		move.w	#SSNOCOOKIEJAR,SSCODE(a0)
		bsr	stopSystem
		rts

rvcNoVDICookie
		lea	ltVideoNoVDICookie,a0
		bsr	logString

		lea	stopSystemData,a0
		move.w	#SSNOVDICOOKIE,SSCODE(a0)
		bsr	stopSystem
		rts


; ---------------------------------------------------------
; 22.01.00/vk
swapScreens
		bsr	swapMe				; vertauschte adressen werden zum naechsten vsync aktiv
		bsr	vsync				; vsync abwarten
		rts


; ---------------------------------------------------------
; 15.01.00/vk
; signal der videosynchronisation abwarten.
; rettet alle register
vsync		movem.l	d0-d2/a0-a2,-(sp)
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


; ---------------------------------------------------------
; 16.01.00/vk
; vertauscht logischen und physikalischen bildschirm
swapMe
		lea	screen_1,a6			; (a6) = logischer, 4(a6) = physikalischer bildschirm
		movea.l	(a6),a0
		move.l	4(a6),(a6)
		move.l	a0,4(a6)

		lea	screenData1Ptr,a6
		movea.l	(a6),a0
		movea.l	4(a6),a1
		move.w	SCREENDATAYOFFSET(a0),d0
		move.w	SCREENDATAYOFFSET(a1),d1
		neg.w	d0
		neg.w	d1
		move.w	d1,SCREENDATAYOFFSET(a0)
		move.w	d0,SCREENDATAYOFFSET(a1)
		move.l	a1,(a6)
		move.l	a0,4(a6)

		bsr	mvdiSetscreenFlipPage
		
		rts


; ---------------------------------------------------------
; signal fuer videosynchronisation d7-mal abwarten
; d7.w = anzahl abzuwartender vbls
multipleVSync
		bsr.s	vsync
		dbra	d7,multipleVSync
		rts


; ---------------------------------------------------------
; loescht den kompletten (logischen) screen
clearScreen

		clr.l	d0
		bsr	clearScreenWithColor
		rts


; ---------------------------------------------------------
; loescht den kompletten (logischen) screen
; d0.w = farbwert
clearScreenWithColor

		andi.l	#$0000ffff,d0
		clr.w	d1			; x1
		clr.w	d2			; y1
		move.w	width,d3
		move.w	height,d4
		subq.w	#1,d3			; x2
		subq.w	#1,d4			; y2
		bsr	mvdiSolidrect
		rts


; ---------------------------------------------------------
; zeichnet auf dem kompletten (logischen) screen
; ein pattern
;clearScreenWithPatternX

		lea	patternrectData,a0
		move.w	width,d2
		move.w	height,d3
		subq.w	#1,d2
		subq.w	#1,d3
		clr.w	PATTERNRECTX1(a0)
		clr.w	PATTERNRECTY1(a0)
		move.w	d2,PATTERNRECTX2(a0)
		move.w	d3,PATTERNRECTY2(a0)
		move.l	#$00007bef,PATTERNRECTFGCOLOR(a0)
		clr.l	PATTERNRECTBGCOLOR(a0)
		clr.w	PATTERNRECTMODE(a0)
		move.l	#ptnstdArray,PATTERNRECTPATPTR(a0)
		move.w	#3,PATTERNRECTPATMSK(a0)
		move.l	#$00020001,d0		; draw_patternrect
		movea.l	lineaParPtr,a1
		movea.l	vdiDispatcher,a6
		jsr	(a6)

		rts


; ---------------------------------------------------------
; 16.01.00/vk
; setzt die adresse des logischen screens.
; a0 = adresse
; rettet alle register
setScreen1
		movem.l	a0-a1,-(sp)

		move.l	a0,screen_1

		movea.l	screenData1Ptr,a1
		move.l	a0,SCREENDATAADDRESS(a1)	; adresse setzen
		clr.w	SCREENDATAYOFFSET(a1)		; (0,0) ist erster punkt
		clr.w	SCREENDATACLEARFLAG(a1)
		clr.w	SCREENDATABORDERFLAG(a1)

		movem.l	(sp)+,a0-a1

		rts


; ---------------------------------------------------------
; 16.01.00/vk
; setzt die adresse des physikalischen screens.
; a0 = adresse
; rettet alle register.
setScreen2
		movem.l	a0-a1,-(sp)

		move.l	a0,screen_2

		movea.l	screenData2Ptr,a1
		move.l	a0,SCREENDATAADDRESS(a1)
		clr.w	SCREENDATAYOFFSET(a1)
		clr.w	SCREENDATACLEARFLAG(a1)
		clr.w	SCREENDATABORDERFLAG(a1)

		movem.l	(sp)+,a0-a1

		rts


; ---------------------------------------------------------
; 16.01.00/vk
; berechnet einige interne variablen, wenn beide screenadressen
; gesetzt sind. muss genau dann aufgerufen werden, wenn sich die
; aufloesung geaendert hat und beide screenadressen bereits
; gesetzt sind. greift auf lineoffset zu.
; rettet alle register.
setScreenCheckIntegrity

		movem.l	d0/a0-a1,-(sp)

		movea.l	screenData1Ptr,a0
		movea.l	screenData2Ptr,a1

	; yoffset

		move.l	SCREENDATAADDRESS(a0),d0		; adresse des log. screens holen
		sub.l	SCREENDATAADDRESS(a1),d0		; adresse des phys. screens abziehen
		divs.w	lineoffset,d0

		clr.w	SCREENDATAYOFFSET(a1)
		move.w	d0,SCREENDATAYOFFSET(a0)

		movem.l	(sp)+,d0/a0-a1

		rts




		data


; tabelle mit den von running unterstuetzten videomodi (-1 = nicht unterstuetzt)
			dc.w	-1,0
videoModes		;dc.w	$1003,0		; 640x400x65536
			dc.w	$1013,0		; 640x480x65536
			dc.w	$1023,0		; 800x608x65536
			dc.w	$1033,0		; 1024x768x65536
			dc.w	-1,0
videoModeMaxBytes	dc.l	1024*768*2
videoModeMaxWidth	dc.w	1024
videoModeMaxHeight	dc.w	768

; aktuelle einstellungen der videokarte
screen_1		dc.l	0			; logischer screen
screen_2		dc.l	0			; physikalischer screen
screen3d		dc.l	0			; aktuelle screenadresse fuer 3d fenster
screen3dOffset		dc.l	0			; relatives offset zum screenanfang
			ifne USEVIDEOSCREENINRAM
screenInRam		dc.l	0
			endc

lineoffset		dc.w	0			; offset fuer eine grafikzeile
width			dc.w	0			; aufloesung in x-richtung
height			dc.w	0			; aufloesung in y-richtung
bpp			dc.w	0			; bits per pixel (bpp)
videoID			dc.w	0			; aktuelle video id

screenData1Ptr		dc.l	screenData1
screenData2Ptr		dc.l	screenData2





		bss

; physikalischer beginn des video ram
physbase		ds.l	1
logbase			ds.l	1

; temporaerer speicher
templong		ds.l	1

ssnerModeToSet		ds.w	1

; aufloesung, zu der nach spielende zurueckzukehren ist
ivCurrentDeviceID	ds.w	1

vdiStructurePtr		ds.l	1
vdiDispatcher		ds.l	1

; aktuelle daten der beiden bildschirme
screenData1		ds.b	SCREENDATABYTES
screenData2		ds.b	SCREENDATABYTES

