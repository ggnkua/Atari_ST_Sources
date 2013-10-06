
			rsreset
SSCODE			rs.w	1
SSMESSAGE		rs.l	1
SSBYTES			rs.w	1


; moegliche fehlercodes fuer sscode
SSNOCOOKIEJAR		equ	0
SSNOVDICOOKIE		equ	1
SSNOCURRENTDEVICEID	equ	2
SSNOTENOUGHMEMORY	equ	3
SSFILEOPENERROR		equ	4
SSFILEREADERROR		equ	5
SSFILEWRITEERROR	equ	6
SSFILECLOSEERROR	equ	7
SSFILECREATEERROR	equ	8




		text


; ---------------------------------------------------------
; 29.07.00/vk
; einen nicht behebbaren fehler am bildschirm anzeigen
; und system anhalten.
stopSystem
		move.l	screen_1,ssScreen		; todo

	; bildschirmaufloesung auf 640x480x65536 schalten, dazu eigene routine verwenden

		move.w	#$1013,-(sp)
		move.w	#5,-(sp)
		move.l	#-1,d0
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp

		move.w	#640*2,lineoffset

	; hintergrundgrafik laden, dazu wieder eigene routine verwenden

		clr.w	-(sp)
		pea	fileStopSystem
		move.w	#61,-(sp)			; _fopen()
		trap	#1
		addq.l	#8,sp
		move.w	d0,d4				; handle zwischenspeichern

		move.l	ssScreen,-(sp)
		move.l	#614400,-(sp)
		move.w	d4,-(sp)			; handle
		move.w	#63,-(sp)			; _fread()
		trap	#1
		lea	12(sp),sp
		
		move.w	d4,-(sp)			; handle
		move.w	#62,-(sp)			; _fclose()
		trap	#1
		addq.l	#4,sp

		lea	errorDescTxt,a0			; allgemeine fehlerbenachrichtung schreiben
		movea.l	ssScreen,a6
		adda.l	#640*2*405+8*2,a6
		bsr	paintText

	; allgemeiner hinweis zu entsprechendem fehlercode

		lea	stopSystemData,a0		; struktur fuer fehlerdaten
		move.w	SSCODE(a0),d0			; fehlercode holen
		lea	stopSystemText,a0		; pointer aller nachrichten
		movea.l	(a0,d0.w*4),a0			; korrekte nachricht holen
		movea.l	ssScreen,a6
		adda.l	#640*2*425+8*2,a6
		bsr	paintText

	; zusaetzlicher hinweis des jeweiligen fehlercodes

		lea	stopSystemData,a0
		move.w	SSCODE(a0),d0
		lea	stopSystemMessage,a1
		move.w	(a1,d0.w*2),d0
		bmi.s	ssMessageSkip
		movea.l	ssScreen,a6
		adda.l	#640*2*425+8*2+10*640*2,a6
		mulu	#640*2*10,d0
		adda.l	d0,a6
		movea.l	SSMESSAGE(a0),a0
		bsr	paintText
ssMessageSkip

	; bildschirm zur anzeige bringen

		bsr	swapScreens

		IFEQ STOPSYSTEMRESUME
ssLoop		nop
		bra.s	ssLoop
		ELSE
ssWait		tst.b	keytable+$39
		beq.s	ssWait
		move.w	videoID,d0		
		bsr	setScreenNoEngineReset
		rts
		ENDC




		data


; hintergrundgrafik
fileStopSystem	dc.b	"data\pictures\stopsyst.rbf",0
		even


; pointer auf die hinweismeldungen der verschiedenen codes
stopSystemText		dc.l	sst000
			dc.l	sst001
			dc.l	sst002
			dc.l	sst003
			dc.l	sst004
			dc.l	sst005
			dc.l	sst006
			dc.l	sst007
			dc.l	sst008

; anzahl der linie, die bei einer zusaetzlichen meldung zu ueberspringen sind (-1 = keine meldung)
stopSystemMessage	dc.w	-1
			dc.w	-1
			dc.w	-1
			dc.w	-1
			dc.w	2
			dc.w	1
			dc.w	1
			dc.w	1
			dc.w	1

			IFEQ LANGUAGE
sst000			dc.b	"the cookie jar could not be found on your system. This cookie jar must",13
			dc.b	"exists to switch between different video resolutions.",0
sst001			dc.b	"the VDI cookie could not be found in the cookie jar. This is",13
			dc.b	"neccessary to use the low level functions of the graphic device driver.",0
sst002			dc.b	"the device id of the current screen resolution could not be determined.",0
sst003			dc.b	"there is not enough memory available for running to go on.",13
			dc.b	"see file .\running.log for details.",0
sst004			dc.b	"The following file could not be opened:",0
sst005			dc.b	"From the following file could not be read:",0
sst006			dc.b	"To the following file could not be written:",0
sst007			dc.b	"The following file could not be closed:",0
sst008			dc.b	"the following file could not be created:",0
			ELSE
sst000			dc.b	"der cookie jar konnte auf ihren system nicht gefunden werden. er ist not-",13
			dc.b	"wendig um zwischen verschiedenen bildschirmaufloesungen zu wechseln.",0
sst001			dc.b	"der vdi cookie konnte nicht gefunden werden. er muss vorhanden sein, um die",13
			dc.b	"hardware-routinen des grafik-treibers ansprechen zu koennen.",0
sst002			dc.b	"die device id der aktuellen bildschirmaufloesung konnte nicht bestimmt werden",0
sst003			dc.b	"es ist nicht genuegend speicher vorhanden. siehe die datei .\running.log",13
			dc.b	"fuer einzelheiten.",0
sst004			dc.b	"die folgende datei konnte nicht geoeffnet werden. eventuell ist die datei",13
			dc.b	"versehentlich geloescht worden:",0
sst005			dc.b	"aus der folgenden datei konnte nicht fehlerfrei gelesen werden:",0
sst006			dc.b	"in die folgende datei konnte nicht fehlerfrei geschrieben werden:",0
sst007			dc.b	"die folgende datei konnte nicht geschlossen werden:",0
sst008			dc.b	"die folgende datei konnte nicht erstellt werden. eventuell ist kein",13
			dc.b	"speicherplatz mehr frei oder das dateisystem schreibgeschuetzt.",0
			ENDC
			even

			IFEQ LANGUAGE
errorDescTxt		dc.b	"reason for system halt:",0
			ELSE
errorDescTxt		dc.b	"das system wurde aus folgendem grund angehalten:",0
			ENDC
			even



		bss


stopSystemData	ds.b	SSBYTES

ssScreen	ds.l	1
