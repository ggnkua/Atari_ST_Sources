

		text


; ---------------------------------------------------------
; traegt den index der farbtabelle in den stack ein und
; erzeugt ggf. die neue tabelle
; d0 = farbtabellennummer (0..7)
setColortable
		tst.w	d0
		bmi.s	scOut
		cmpi.w	#7,d0
		bgt.s	scOut

		bsr.s	scMakeEntry
scOut
		rts


; ---------------------------------------------------------
; loescht den index der farbtabelle aus den stack und
; erzeugt ggf. eine neue tabelle
; d0 = farbtabellennummer (0..7)
deleteColortable
		tst.w	d0
		bmi.s	dcOut
		cmpi.w	#7,d0
		bgt.s	dcOut

		bsr.s	scDeleteEntry
dcOut
		rts

;---
; d0 = einzutragende farbtabelle
scMakeEntry
		movem.l	d1/a0-a1,-(sp)
		lea	setColortableStack,a0
		lea	setColortableStackPos,a1

	; schaue in einem ersten schritt nach, ob die farbtabelle schon einmal existiert
	; ja -> dann nichts aendern ...
	; (kompromiss zum underground -> dunkel)

		move.w	(a1),d1
		cmpi.w	#SETCOLORTABLESTACKMAX-1,d1
		bgt.s	scmeOut				; kein platz mehr

		subq.w	#1,d1
		bmi.s	scmeOk				; keine eintraege vorhanden -> einfach "anhaengen"
scmeLoop	cmp.w	(a0,d1.w*2),d0
		beq.s	scmeOut
		dbra	d1,scmeLoop

scmeOk
		move.w	(a1),d1
		move.w	d0,(a0,d1.w*2)			; ans ende anhaengen
		moveq	#1,d1
		add.w	d1,(a1)
		bsr.s	calcCurrentColortable

scmeOut
		movem.l	(sp)+,d1/a0-a1
		rts

;---
; d0 = zu loeschende farbtabelle
scDeleteEntry
		movem.l	d2/a0-a1,-(sp)
		lea	setColortableStack,a0		; zeiger stack
		lea	setColortableStackPos,a1	; anzahl
		move.w	(a1),d1				; anzahl holen
		move.w	d1,d2
scdeLoop
		subq.w	#1,d1
		bmi.s	scdeNotFound		; noch eintraege vorhanden?
		cmp.w	(a0,d1.w*2),d0		; vergleichen
		bne.s	scdeLoop		; bis gefunden
scdeFound
		addq.w	#1,d1			; alle bisherigen eintraege
		cmp.w	d2,d1			; verschieben
		beq.s	scdeMoveOk
		move.w	(a0,d1.w*2),-2(a0,d1.w*2)
		bra.s	scdeFound
scdeMoveOk
		subq.w	#1,d2			; anzahl erniedrigen
		move.w	d2,(a1)			; und zurueckschreiben
		bsr.s	calcCurrentColortable
		bra.s	scdeOut			; und raus

scdeNotFound					; todo (ignorieren)
		nop
scdeOut
		movem.l	(sp)+,d2/a0-a1
		rts


; ---------------------------------------------------------
; berechnet die aktuell sichtbare farbtabelle und setzt
; die aktuellen boden-/deckenfarben
; register muessen gerettet werden
calcCurrentColortable

		movem.l	d0-a6,-(sp)

		bsr.s	cccGetWithPriority
		bsr.s	calcColortable

		bsr.s	cccGetWithPriority
		movea.l	levelPtr,a0
		movea.l	LEVBODEN(a0),a1
		adda.l	a0,a1
		move.l	(a1,d0.w*4),a1
		adda.l	a0,a1
		move.l	a1,floorColorPtr

		movem.l	(sp)+,d0-a6
		rts


; index der aktuell sichtbaren farbtabelle berechnen
; rueckgabe: d0 = index
cccGetWithPriority		
		lea	setColortableStack,a0
		move.w	setColortableStackPos,d2	; stackgroesse
		beq.s	cccgwpOut			; kein eintrag -> raus
		move.w	-2(a0,d2.w*2),d0		; letzten eintrag holen
		lea	colortablePriority,a2		; prioritaetenlisten
		lea	(a2,d0.w*2),a1			; und auf d0-te spalte voreinstellen
cccgwpLoop
		subq.w	#1,d2
		bmi.s	cccgwpOut			; noch eintraege vorhanden?
		move.w	(a0,d2.w*2),d1			; eintrag holen
		lsl.w	#4,d1				; auf entspr. zeilenoffset bringen
		tst.w	(a1,d1.w)			; prioritaet vorhanden?
		beq.s	cccgwpLoop			; nein -> naechster eintrag
		move.w	(a0,d2.w*2),d0			; ansonsten diese farbtabelle nehmen
		lea	(a2,d0.w*2),a1			; und damit weitervergleichen
		bra.s	cccgwpLoop
cccgwpOut
		rts


; ---------------------------------------------------------
; berechnet eine farbtabelle
; d0 = index
calcColortable
		tst.w	d0
		bmi.s	ccOut
		cmpi.w	#7,d0
		bgt.s	ccOut

		lea	truecolorTabsRouts,a0
		move.l	(a0,d0.w*4),d0
		beq.s	ccOut
		movea.l	d0,a0
		jsr	(a0)		
ccOut
		rts





		data


; prioritaet der farbtabellen (fuer cccGetWithPriority)
colortablePriority
		dc.w	0,0,0,0,0,0,0,0
		dc.w	1,0,0,1,1,0,0,0
		dc.w	1,0,1,1,1,0,0,0
		dc.w	1,0,0,0,0,0,0,0
		dc.w	1,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0



		bss

; zeiger auf aktuelle boden-/deckenfarben
floorColorPtr	ds.l	1