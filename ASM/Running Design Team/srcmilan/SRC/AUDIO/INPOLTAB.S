


		text


; ----------------------------------------------------------
; 21.09.00/vk
; berechnet die 25 verschiedenen offset tabellen zum
; zugriff auf die samplewerte fuer die speedindizes.
; wird einmalig aufgerufen zum erzeugen der tabellen.
; rettet alle register.
calcInterpolatedOffsetTables

		movem.l	d0-a6,-(sp)

		lea	interpolatedOffsetTables,a0
		lea	audioBufferPlayLengthTable,a2
		moveq	#24,d0
ciotLoop	moveq	#24,d1
		sub.w	d0,d1
		movea.l	(a0)+,a1
		bsr.s	calcCurrentInterpolatedOffsetTable
		addq.l	#4,a2
		dbra	d0,ciotLoop

		movem.l	(sp)+,d0-a6
		rts


; ----------------------------------------------------------
; 17.09.00/vk
; berechnet die aktuelle interpolated offset-tabelle.
; d1 = speedindex im bereich [0,..,24]: 0 = 25 kHz, 24 = 6.25 kHz
; a1 = pointer auf tabelle
; a2 = array, das die gesamtgroessen jeweils aufnimmt
; rettet alle register (ausser fpx).
calcCurrentInterpolatedOffsetTable

; index 0: 1,0
; index 12: 0,5
; index 24: 0,25
; formel: y = (1/1152) * x^2 - (5/96) * x + 1

		movem.l	d0-a6,-(sp)

		fmove.w	d1,fp1
		fmul.x	fp1,fp1
		fdiv.w	#1152,fp1

		fmove.w	d1,fp0
		fmul.w	#5,fp0
		fdiv.w	#96,fp0
		fsub.x	fp0,fp1

		fadd.w	#1,fp1				; fp1 = einzelner offsetvalue (25 kHz: 1.0, 12.5 kHz: 0.5, 6.25 kHz: 0.25)

		fmove.w	#0,fp0
		move.w	#AUDIOBUFFERPLAYLENGTH-1,d7
cciotLoop	fmove.w	fp0,(a1)+
		fadd.x	fp1,fp0
		dbra	d7,cciotLoop		

		fmove.l	fp0,(a2)			; gesamtanzahl abzuspielender samples ebenfalls noch merken

		movem.l	(sp)+,d0-a6
		rts




		data


interpolatedOffsetTables
		dc.l	io00
		dc.l	io01
		dc.l	io02
		dc.l	io03
		dc.l	io04
		dc.l	io05
		dc.l	io06
		dc.l	io07
		dc.l	io08
		dc.l	io09
		dc.l	io10
		dc.l	io11
		dc.l	io12
		dc.l	io13
		dc.l	io14
		dc.l	io15
		dc.l	io16
		dc.l	io17
		dc.l	io18
		dc.l	io19
		dc.l	io20
		dc.l	io21
		dc.l	io22
		dc.l	io23
		dc.l	io24




		bss


; tabelle mit den laengen bei unterschiedlichen speedindizes
audioBufferPlayLengthTable
		ds.l	25


; einzelne offset tabellen
io00		ds.w	AUDIOBUFFERPLAYLENGTH
io01		ds.w	AUDIOBUFFERPLAYLENGTH
io02		ds.w	AUDIOBUFFERPLAYLENGTH
io03		ds.w	AUDIOBUFFERPLAYLENGTH
io04		ds.w	AUDIOBUFFERPLAYLENGTH
io05		ds.w	AUDIOBUFFERPLAYLENGTH
io06		ds.w	AUDIOBUFFERPLAYLENGTH
io07		ds.w	AUDIOBUFFERPLAYLENGTH
io08		ds.w	AUDIOBUFFERPLAYLENGTH
io09		ds.w	AUDIOBUFFERPLAYLENGTH
io10		ds.w	AUDIOBUFFERPLAYLENGTH
io11		ds.w	AUDIOBUFFERPLAYLENGTH
io12		ds.w	AUDIOBUFFERPLAYLENGTH
io13		ds.w	AUDIOBUFFERPLAYLENGTH
io14		ds.w	AUDIOBUFFERPLAYLENGTH
io15		ds.w	AUDIOBUFFERPLAYLENGTH
io16		ds.w	AUDIOBUFFERPLAYLENGTH
io17		ds.w	AUDIOBUFFERPLAYLENGTH
io18		ds.w	AUDIOBUFFERPLAYLENGTH
io19		ds.w	AUDIOBUFFERPLAYLENGTH
io20		ds.w	AUDIOBUFFERPLAYLENGTH
io21		ds.w	AUDIOBUFFERPLAYLENGTH
io22		ds.w	AUDIOBUFFERPLAYLENGTH
io23		ds.w	AUDIOBUFFERPLAYLENGTH
io24		ds.w	AUDIOBUFFERPLAYLENGTH

