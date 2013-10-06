
SETCOLORTABLESTACKMAX	equ	32



		data


loadSaveAreaStart

loadSaveBytes		dc.l	loadSaveAreaEnd-loadSaveAreaStart

; todo: nicht vergessen: laptop (textfeld)
; audioSystem

; --------------
; wichtige globale flags
doubleScan		dc.w	0
consoleFlag		dc.w	1
clearBackgroundFlag	dc.w	0
cameraviewFlag		dc.w	0
tilesDimension		dc.w	256
quitFlag		dc.w	0
terminalFlag		dc.w	0
laptopFlag		dc.w	0		; 0 = keine anzeige, 1 = wird angezeigt



; todo: dieses flag zeigt an, ob ein speicherbereich allokiert wurde, lieber nicht mit abspeichern...
c3pMode			dc.w	0		; 0 = wie DSP56001, 1 = mit boden- und deckenanzeige


; episoden- und levelnummer
episode			ds.w	1
			ds.w	1

; waffenverwaltung
weaponMode		dc.w	0		; 0 = falcon-konzept mit 4 festen waffen, 1 = neues konzept

; kartenmodi
mapFlag			dc.w	0
mapMode			dc.w	0
mapContentMode		dc.w	0

; farbtabellenverwaltung
setColortableStackPos	ds.w	1
setColortableStack	ds.w	SETCOLORTABLESTACKMAX


; haupt-spielerdaten
playerData		ds.b	PDBYTES

; aufgenommene gegenstaende
playerThings		ds.b	THINGSMAX*PTHGBYTES


loadSaveAreaEnd