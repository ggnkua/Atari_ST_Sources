
FINAL			equ	1
LANGUAGE		equ	1		; 0 = englisch, 1 = deutsch

CHEATS1FLAG		equ	1		; welche cheatcodes werden benutzt?
CHEATS2FLAG		equ	0
CHEATS3FLAG		equ	0
CHEATS4FLAG		equ	0


USEVIDEOSCREENINRAM	equ	0
STOPSYSTEMRESUME	equ	0


TILESDIMENSION		equ	256		; 256 oder 512
NBOFTILES		equ	14


LEVELMAXBYTES		equ	350000



; ---------------------------------------------------------
		text
; ---------------------------------------------------------


		move.l	4(sp),a0	; zeiger auf basepage
		lea	stackUSP,sp	; stackpointer setzen
		move.l	#$100,d0	; laenge der basepage
		add.l	$c(a0),d0	; laenge text
		add.l	$14(a0),d0	; laenge data
		add.l	$1c(a0),d0	; laenge bss
		move.l	d0,-(sp)
		move.l	a0,-(sp)	; adresse basepage
		clr.w	-(sp)
		move.w	#$4a,-(sp)	; mshrink
		trap	#1
		lea	12(sp),sp

		IFEQ FINAL
		move.w	debugDrive,-(sp)
		move.w	#14,-(sp)
		trap	#1
		addq.l	#4,sp
		pea	debugPath
		move.w	#59,-(sp)
		trap	#1
		addq.l	#6,sp
		ENDC

		jsr	main

		clr.w	-(sp)		; return-wert des programms
		trap	#1


; ---------------------------------------------------------

main
		lea	ltRunningStart,a0
		bsr	logString

		bsr	installSystem

		bsr	game

		bsr	restoreSystem

		lea	ltRunningEnd,a0
		bsr	logString

		rts


; ---------------------------------------------------------
; game
; ---------------------------------------------------------
game
		bsr	clearBackground

		bsr	loadLevel
		jsr	installLevel

		bsr	initWeaponCounterFile
		bsr	initWeaponConsoleFile
		bsr	initConsoleItemsFile

		jsr	init3dEngine

		bsr	initLaptop
		bsr	laptopDrawOffscreen

gameLoop

	; (1) tastatursteuerung

		bsr	keyHit

	; (2) interne verwaltung

		jsr	skyEffect				; himmelseffekt

		bsr	findVisibleMonsters
		bsr	animateMonsters

		bsr	animateDoors
		bsr	animateLifts

		bsr	animateItems				; gegenstands- und schalteranimationen

		bsr	moveIt
		bsr	testPosition
		bsr	testActionFields			; tuer-/liftsteuerung (aktionen durch spieler)

		bsr	calcActivatedItemTimelimit		; zeitlimits bei aktivierten gegenstaenden anpassen (.\src\things\calctime.s)

	; (3) 3d-berechnung

		jsr	dspSendAll
		jsr	calc3dPicture

	; (4) zeichenroutinen

		bsr	drawBackgroundIfRequired		; hintergrund bei bedarf neu zeichnen

		bsr	isFullscreenMap				; karte im fullscreen-modus aktiv?
		tst.w	d0
		bne.s	mDrawSkip3dWindow

		jsr	paint3dPicture
		IFNE USEVIDEOSCREENINRAM
		bsr	copy3dPictureToGraphicCard		
		ENDC	
;		bsr	draw3dBorderMainIfRequired
		jsr	drawFramesPerSecondIfRequired		; .\src\3dengine\fps.s
mDrawSkip3dWindow

		bsr	drawMap
		bsr	drawLaptop				; .\src\laptop\main.s
		bsr	drawConsole
		jsr	drawMessages

		jsr	calcVblTimes				; todo: vbltime1000 (.\src\3dengine\fps.s)

		bsr	weaponKeyHit

		IFEQ FINAL
		bsr	drawPlayerPosition
;		bsr	audioSystemDebug
		ENDC

		bsr	swapScreens

		lea	keytable,a0
		tst.b	$1(a0)
		beq	gameLoop

		bra	gameOut		

gameOut
		jsr	a2Deinstall				; evtl. speicher fuer a2 wieder freigeben

		rts


; ---------------------------------------------------------
; ---------------------------------------------------------


		include "src\debug.s"

		include	"src\gfxrouts\3dborder.s"	; rahmen um 3d fenster
		include	"src\gfxrouts\3dbmain.s"	; steuerungsroutinen fuer rahmen des hauptfensters
		include	"src\gfxrouts\backgrnd.s"
		include	"src\gfxrouts\bitblt.s"		; bitmaps/texturen im speicher kopieren
		include	"src\gfxrouts\bitmpdef.s"	; definition aller benutzten bitmaps
		include	"src\gfxrouts\clipping.s"
		include	"src\gfxrouts\drawcirc.s"	; zeichnen von kreisen
		include	"src\gfxrouts\drawline.s"
		include	"src\gfxrouts\drawtext.s"
		include	"src\gfxrouts\painttxt.s"
		include	"src\gfxrouts\screens.s"
		include "src\gfxrouts\zoomblck.s"

		include	"src\audio\audiosys.s"
		include	"src\audio\datastru.s"		; definition der datenstrukturen
		include	"src\audio\debug.s"		; nur zum debugging notwendige routinen
		include	"src\audio\initsam.s"		; samples zum abspielen eintragen
		include	"src\audio\inpoltab.s"		; tabellen mit offsets fuer samplezugriffe der untersch. speedindizes
		include	"src\audio\keyhit.s"		; abfrageroutinen zu einstellungen des audio systems
		include	"src\audio\samples.s"		; definition interner samples
		include	"src\audio\voltable.s"		; lautstaerketabellen

		include	"src\system\aesvdi.s"
		include	"src\system\copy3dgc.s"		; kopiert das 3d fenster in den speicher der graphikkarte
		include	"src\system\datetime.s"
		include "src\system\fileio.s"
		include	"src\system\install.s"
		include	"src\system\keyhit.s"		; abfrageroutine fuer die wichtigsten systemereignisse
		include	"src\system\keyirq.s"
		include	"src\system\linea.s"
		include	"src\system\logfile.s"
		include	"src\system\memory.s"
		include	"src\system\mvdi.s"
		include	"src\system\mvdihard.s"
		include	"src\system\mvdisoft.s"
		include	"src\system\audio.s"
		include	"src\system\screensh.s"
		include "src\system\stopsyst.s"
		include	"src\system\string.s"
		include	"src\system\vbl.s"
		include "src\system\video.s"

		include	"src\tables\getchanc.s"		; zufallszahlen-"berechnung"

		include	"src\monsters\animmons.s"	; hauptroutine zur animation inkl. grafikanimierung
		include	"src\monsters\datastru.s"	; datenstrukturen/konstanten
		include	"src\monsters\findvism.s"
		include	"src\monsters\monshoot.s"	; schiesssteuerung und -animierung der gegner
		include	"src\monsters\settextu.s"	; setzen/aufbau der grafikdaten/animationsphasen
		include	"src\monsters\walkstep.s"

		include	"src\console\datastru.s"	; datenstruktur fuer console
		include	"src\console\draw.s"		; zeichenroutinen
		include	"src\console\geiger.s"		; alle routinen zum geigerzaehler
		include	"src\console\init.s"		; initialisierung der console
		include	"src\console\itemctrl.s"	; steuerung der items (tastatursteuerung/-auswahl)
		include	"src\console\items.s"
		include	"src\console\alttab.s"		; scrollen der gegenstaende (vgl. windows) - muss nach items.s eingebunden werden
		include	"src\console\paint.s"
		include	"src\console\scanner.s"		; alle routinen zum ultrascanner
		include	"src\console\wpcons.s"		; waffenstandsanzeige (waffenikone)
		include	"src\console\wpcount.s"		; waffenstandsanzeige (munitionszahlen)

		include	"src\laptop\border.s"		; routinen fuer rahmen um laptop-textfeld
		include	"src\laptop\cheatcod.s"		; definition/routinen zu den cheatcodes
		include	"src\laptop\codes.s"		; verschluesselte ascii-zeichen fuer laptop-eingabe
		include	"src\laptop\commands.s"		; implementierung der kommandozeilenbefehle
		include	"src\laptop\cursor.s"		; routinen zum setzen und zeichnen des cursors
		include	"src\laptop\datastru.s"		; datenstrukturen fuer laptop-modus
		include	"src\laptop\fonts.s"		; schriftarten fuer 320er und 640er modi
		include	"src\laptop\main.s"		; hauptsteuerungsroutinen
		include	"src\laptop\keyhit.s"		; tastatureingaben im spielmodus
		include	"src\laptop\laptop.s"		; hauptsaechlich zeichenroutinen zum laptop
		include	"src\laptop\shiftrow.s"		; textfeldzeilen verschieben
		include	"src\laptop\textctrl.s"		; steuerung von textein- und ausgaben

		include	"src\map\control.s"
		include	"src\map\draw.s"		; allgemeine routinen zum zeichnen
		include	"src\map\extra.s"		; maptyp extra
		include	"src\map\isfullmp.s"
		include	"src\map\overlay.s"		; maptyp overlay
		include	"src\map\revolcon.s"		; inhalt: routinen zur drehbaren karte
		include	"src\map\standcon.s"		; inhalt: routinen zur standardkarte (horiz./vert.)
		include	"src\map\standard.s"		; maptyp standard

		include	"src\weapon\keyhit.s"		; tastatureingaben
		include	"src\weapon\setweapn.s"		; setzen einer waffe

		include	"src\things\allarray.s"		; definition aller gegenstaende (datenstruktur)
		include	"src\things\calctime.s"		; zeitlimits von aktivierten gegenstaenden herunterzaehlen
		include	"src\things\const.s"		; konstanten zur gegenstandsverwaltung
		include	"src\things\genrouts.s"		; allgemeine abfrageroutinen rund um die gegenstandsverwaltung
		include	"src\things\routs.s"		; routinen fuer gegenstaende/aktionen
		include	"src\things\wpnstrin.s"		; austausch der aktuellen weapon-bezeichnungen

		include	"src\install.s"			; level installieren
		include	"src\level.s"
		include	"src\levfiles.s"		; struktur aller episoden und level
		include	"src\loadlevf.s"		; einladen der weiteren leveldateien

		include	"src\animdoor.s"		; tuer- und liftanimation
		include	"src\animitem.s"		; gegenstands- und schalteranimation

		include	"src\moveit.s"			; tastaturabfragen zur bewegungssteuerung
		include	"src\testpos.s"			; neu berechnete positition testen/korrigieren
		include	"src\testactf.s"		; aktionsfelder (tueren, lifte, hintergrundgeraeusche)

		include	"src\3dengine\colortbl.s"	; farbtabellen setzen und entfernen
		include	"src\3dengine\creattab.s"
		include "src\3dengine\dsp56001.s"	; 3d algorithmus nur mit wandtexturierung
		include	"src\3dengine\a2.s"		; 3d algorithmus mit volltexturierung
		include	"src\3dengine\a2init.s"		; (de-)initialisierungsroutinen zum a2
		include	"src\3dengine\a2insert.s"	; linien in strahlenbuffer eintragen
		include	"src\3dengine\a2sort.s"		; sortiertalgorithmen fuer a2
		include	"src\3dengine\dspcomm.s"
		include	"src\3dengine\install.s"	; level/game installieren
		include	"src\3dengine\main.s"		; hauptsteuerungroutine
		include "src\3dengine\paint.s"
		include	"src\3dengine\fps.s"
		include	"src\3dengine\skyeffec.s"	; routinen fuer die himmelseffekte

		include	"src\message.s"
		include	"src\terminal.s"

		include "src\playdata.s"
		include	"src\ldsvarea.s"

		include	"src\bin2asci.s"


; ---------------------------------------------------------


		data


		IFEQ FINAL
debugDrive	dc.w	4
debugPath	dc.b	"\running.040",0
		even		
		ENDC


; ---------------------------------------------------------


		bss


level		ds.b	LEVELMAXBYTES

tilesGfxPtrArray
		ds.l	NBOFTILES

		ds.b	16384		; stackgroesse
stack		ds.b	8
		ds.b	128
stackUSP	ds.b	8


dmaSpeechFlag	ds.w	1
