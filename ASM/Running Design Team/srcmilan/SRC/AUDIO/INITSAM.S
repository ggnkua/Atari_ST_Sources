

		text


; ----------------------------------------------------------
; 30.09.00/VK
; aktiviert das sample (index d0) mit den eigenschaften
; - volle lautstaerke (keine anpassung zur spielerposition o. ae.)
; - nicht geloopt
; - doppeltes abspielen ist moeglich
; d0 = sampleindex
; rettet alle register
initSimpleSam
		movem.l	d0-d5/a0-a1,-(sp)
		move	sr,-(sp)
		move.w	#$2300,sr			; interrupts z. zt. nicht zulassen

		bsr	audioGetNextFreeSampleSlot	; rueckgabe in a0 ist der (freie) sample-slot
		bsr	audioGetSampleStructure		; rueckgabe in a1 ist die richtige sample-struktur

		moveq	#0,d0				; loopflag
		moveq	#0,d1				; playerpositionflag
		moveq	#0,d4				; lautstaerkeindex links
		moveq	#0,d5				; lautstaerkeindex rechts
		bsr.s	initSamSetSample		; und setzen

		move	(sp)+,sr
		movem.l	(sp)+,d0-d5/a0-a1
		rts


; ---------------------------------------------------------
; 30.09.00/vk
; initialisiert den sampleslot mit dem uebergebenen sample
; d0 = loopflag (0 oder 1)
; d1 = volumeflag (0 oder 1: muss nach spielerposition angepasst werden)
; d2 = x (falls volumeflag=1)
; d3 = y (falls volumeflag=1)
; d4 = lautstaerkeindex links
; d5 = lautstaerkeindex rechts
; a0 = pointer auf sampleslot, in den eingetragen werden soll
; a1 = pointer auf samplestruktur (sample, das eingetragen werden soll)
; rettet alle nicht uebergebenen register
initSamSetSample

		tst.w	SAMPLEMODE(a1)				; todo: modo vs. stereo
		bmi.s	isssOut					; sampleeintrag nicht gueltig -> sofort raus

		move.l	SAMPLELENGTH(a1),SDLENGTH(a0)
		move.l	SAMPLEADDRESSLEFT(a1),SDADDRESSLEFT(a0)
		move.l	SAMPLEADDRESSRIGHT(a1),SDADDRESSRIGHT(a0)
		clr.l	SDOFFSET(a0)
		move.w	d0,SDLOOPFLAG(a0)

		move.w	SAMPLESPEEDINDEX(a1),SDSPEEDINDEX(a0)

		move.w	d1,SDPLAYERPOSITIONFLAG(a0)		; flag, ob lautst. nach position angepasst werden muss, setzen
		beq.s	isssNoPlayerPosition			; keine staendige anpassung notwendig

		move.l	d2,SDPLAYERPOSITIONX(a0)		; x-position eintragen
		move.l	d3,SDPLAYERPOSITIONY(a0)		; dito y
		clr.w	SDVOLUMECOUNTER(a0)			; beim naechsten (entspricht dem ersten) durchgang wird neu berechnet
isssNoPlayerPosition

		lea	volumeTables,a4
		move.w	d4,SDVOLUMELEFT(a0)
		move.w	d5,SDVOLUMERIGHT(a0)
		move.l	(a4,d4.w*4),SDVOLUMETABLELEFT(a0)
		move.l	(a4,d5.w*4),SDVOLUMETABLERIGHT(a0)

isssOut
		rts


; ----------------------------------------------------------
; 30.01.00/VK
; bestimmt den sampleslot zum abspielen des naechsten samples.
; rueckgabe: a0 = zeiger auf freien sampledata-slot
; rettet alle register.
audioGetNextFreeSampleSlot

		movem.l	d1-d3/a1,-(sp)

	; ist einer der standard-slots frei (nicht music, nicht speech)?

		lea	sampleDataPtr+2*4,a1
		moveq	#AUDIOSYSSAMPLESPERCHANNEL-2-1,d2
agnfsLoop	movea.l	(a1)+,a0			; pointer auf sampledata (slot)
		tst.l	SDLENGTH(a0)			; slot frei?
		beq.s	agnfsFoundFree			; ja -> dann verzweigen
		dbra	d2,agnfsLoop			; loop ueber alle verbleibenden slots

	; ist evtl. noch der music-slot oder speech-slot frei?

		lea	sampleDataPtr,a1
		movea.l	4(a1),a0			; adresse des zweiten slots holen
		tst.l	SDLENGTH(a0)			; noch frei?
		beq.s	agnfsFoundFree			; ja -> dann raus
		movea.l	(a1),a0				; adresse des ersten slots holen
		tst.l	SDLENGTH(a0)			; noch frei?
		beq.s	agnfsFoundFree			; ja -> dann raus

	; dann das kuerzeste der uebrigen samples heraussuchen

		addq.l	#8,a1				; pointer zeigt jetzt wieder auf dritten slot
		move.l	#$7fffffff,d1			; zu vergleichende laenge
		moveq	#AUDIOSYSSAMPLESPERCHANNEL-2-1,d2
agnfsLoop2	movea.l	(a1)+,a0
		cmp.l	SDLENGTH(a0),d1
		blt.s	agnfsSkip			; nicht kuerzer -> verzweigen
		move.l	SDLENGTH(a0),d1			; neuer vergleichswert
		move.l	a0,d3				; adresse dieses slots merken
agnfsSkip	dbra	d2,agnfsLoop2
		movea.l	d3,a0

agnfsFoundFree
		movem.l	(sp)+,d1-d3/a1
		rts


; ---------------------------------------------------------
; 30.01.00/vk
; gibt in a1 den korrekten pointer auf die sample-struktur zurueck.
; d0 = samplenummer (positiv oder negativ)
; rueckgabe: d0 = samplenummer (nur noch positiv)
;            a1 = zeiger auf sample-struktur
; rettet alle register.
audioGetSampleStructure

	; welches sample: intern (-128,-127,...) oder extern (0,1,2,...)

; todo		lea	levelSamples,a1
		lea	samples,a1
		tst.w	d0				; samplenummer (index) testen
		bpl.s	agssItsExtern			; positiv -> dann externen pointer in a1 belassen
		addi.w	#128,d0				; andernfalls samplenummer wieder positiv machen
		lea	samples,a1			; und korrekten pointer auf interne samples setzen
agssItsExtern
		movea.l	(a1,d0.w*4),a1			; adresse der sample-struktur

		rts


