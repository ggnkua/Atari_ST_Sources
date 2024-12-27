	dc.l	0
	dc.l	830
total:	dc.l	25190	Linkfile length
;
; Filenames follow on from here (padded with zeros and file no. follows)
;
FILENAMES:	
	dc.b	'1.PI1',0,0,0,0,0,0,0,0,0,0,0
	dc.b	0

	dc.b	'1.PIC',0,0,0,0,0,0,0,0,0,0,0
	dc.b	1

ENDFILE:	dc.w	0
	even

FILES	equ	2
