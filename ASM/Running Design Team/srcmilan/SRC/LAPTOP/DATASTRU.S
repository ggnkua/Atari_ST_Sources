
LAPTOPMAXX		equ	50		; maximale breite in buchstaben (bezogen auf alle fonts)
LAPTOPMAXY		equ	25		; maximale hoehe in zeilen

LAPTOPFONTMAXX		equ	6		; maximale breite/hoehe in pixeln pro buchstabe (bezogen auf alle fonts)
LAPTOPFONTMAXY		equ	10

LAPTOPPOSX		equ	32		; position des laptop screens auf dem bildschirm
LAPTOPPOSY		equ	16

; struktur laptop
LAPTOPSCREENOFFSET	equ	0		; adresse fuer laptop (relativ) zu screen_1 (bzw. screen_2)
LAPTOPLINEOFFSET	equ	4		; aktuelles lineoffset zum zeichnen des fonts (entweder screen- oder bufferbezogen)
LAPTOPLINEOFFSETMEMORY	equ	6		; lineoffset, wenn im memory gezeichnet wird
LAPTOPX			equ	8		; aktuelle breite in buchstaben
LAPTOPY			equ	10		; aktuelle hoehe in zeilen
LAPTOPWIDTH		equ	12		; breite in pixeln
LAPTOPHEIGHT		equ	14		; hoehe in pixeln
LAPTOPCURSORX		equ	16		; position (in buchstaben) des cursors
LAPTOPCURSOROFFSETX	equ	18		; position (in pixel) des cursors
LAPTOPCURSORY		equ	20		; zeilennummer des cursors
LAPTOPTEXTPTR		equ	22		; pointer auf pointer auf jeweilige zeilen
LAPTOPSCREENMEMORY	equ	26		; offscreen memory buffer zum zeichnen
LAPTOPFONTDATAPTR	equ	30		; pointer auf fontdaten
LAPTOPPOSITIONX		equ	34		; position des anzeigefeldes relativ zum screenanfang in pixeln (x)
LAPTOPPOSITIONY		equ	36		; entspr. y
LAPTOPQUITFLAG		equ	38		; flag zum beenden des laptops (eingabeaufforderung)
LAPTOPBYTES		equ	40


		text



		data



		bss


; datenstruktur fuer laptopvariablen
laptop			ds.b	LAPTOPBYTES

; datenstruktur textfeld (asciiarray)/von laptop aus wird hierauf verwiesen
laptopTextPtr		ds.l	LAPTOPMAXY			; maximal y textzeilen
laptopText		ds.b	LAPTOPMAXX*LAPTOPMAXY		; screenbuffer (ascii-zeichen)

; textfeld (grafik) in der maximal moeglichen ausdehnung
laptopScreenMemory	ds.w	LAPTOPMAXX*LAPTOPFONTMAXX*LAPTOPMAXY*LAPTOPFONTMAXY
