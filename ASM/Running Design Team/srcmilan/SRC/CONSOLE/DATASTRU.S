

CONSOLESTARTPOSX	equ	-30		; positiond der linken ecke (pos. = von links/neg. = von rechts)
CONSOLESTARTPOSY	equ	-10		; dito fuer untere ecke
CONSOLESTARTSTRETCHP1	equ	64		; stretchkonstanten
CONSOLESTARTSTRETCHP2	equ	128
CONSOLESTARTSPACEENERGY	equ	6		; abstandskonstanten
CONSOLESTARTSPACESHIELD	equ	6
CONSOLESTARTSPACEBAG	equ	6



			rsreset
CONSOLEPOSXRIGHT	rs.w	1		; position linker rand
CONSOLEPOSYDOWN		rs.w	1		; position unterer rand
CONSOLESTRETCHP1	rs.w	1
CONSOLESTRETCHP2	rs.w	1
CONSOLESPACEENERGY	rs.w	1
CONSOLESPACESHIELD	rs.w	1
CONSOLESPACEBAG		rs.w	1
CONSOLEBYTES		rs.w	1




		text







		data



		bss


console		ds.b	CONSOLEBYTES

