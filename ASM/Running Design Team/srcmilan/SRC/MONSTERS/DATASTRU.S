
; maximal gleichzeitig animinier- und sichtbare gegner
MONANIMATEDMAX		equ	192


; zeitangaben (in msek.) pro animationsphase
MONWALKTIME1000		equ	200
MONHITTIME1000		equ	400
MONDIEDTIME1000		equ	200
MONSHOOTTIME1000	equ	200

; bitaufteilung im array c3pmonstersaddflags
;MONADDFLAGRIGHT	equ	0-7
;MONADDFLAGLEFT		equ	8-15
MONADDFLAGTRANSBIT	equ	29
MONADDFLAGMIRRORBIT	equ	30

; bitaufteilung im feld monshoottype
MONSHOOTSINCEHITBIT	equ	1
MONSHOOTINACTRADONLYBIT	equ	2
MONSHOOTINFORWONLYBIT	equ	3
MONSHOOTHASBEENHITBIT	equ	4


		text



		data

; zwischenspeicher fuer animierte/sichtbare gegner
monBufferNb	dc.w	0
monBufferPtr	dc.l	monBuffer

monSpeed	dc.w	0

		bss


monBuffer	ds.l	MONANIMATEDMAX

