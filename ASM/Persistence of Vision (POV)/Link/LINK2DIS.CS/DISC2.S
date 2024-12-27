	dc.l	0
	dc.l	32034
total:	dc.l	45426	Linkfile length
;
; Filenames follow on from here (padded with zeros and file no. follows)
;
FILENAMES:	
	dc.b	'3.PI1',0,0,0,0,0,0,0,0,0,0,0
	dc.b	0

	dc.b	'4.PI1',0,0,0,0,0,0,0,0,0,0,0
	dc.b	1

ENDFILE:	dc.w	0
	even

FILES	equ	2
