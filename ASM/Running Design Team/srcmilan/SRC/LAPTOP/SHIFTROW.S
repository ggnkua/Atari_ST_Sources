

		text


; ---------------------------------------------------------
; 21.01.00/vk
; verschiebt alle angezeigten zeilen um eine zeile nach
; oben. als unterste zeile wird ein leerzeile eingefuegt.
; es werden sowohl die grafik als auch die ascii-zeichen
; (ueber pointer) verschoben.
; rettet alle register.
laptopShiftUpOneRow

		movem.l	d0-a6,-(sp)
		bsr.s	laptopShiftUpOneRowAscii
		bsr.s	laptopShiftUpOneRowGraphic
		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 29.12.99/vk
; verschiebt die textzeilen um eins nach oben und
; loescht die unterste zeile heraus
laptopShiftUpOneRowAscii

		lea	laptop,a5
		movea.l	LAPTOPTEXTPTR(a5),a0		; array der textpointer
		move.w	LAPTOPY(a5),d0			; aktuelle hoehe des laptops
		subq.w	#1+1,d0
		bmi.s	lsuoraTextPtrSkip
		movea.l	(a0),a1				; pointer merken
lsuoraLoop	move.l	4(a0),(a0)+
		dbra	d0,lsuoraLoop
		move.l	a1,(a0)
lsuoraTextPtrSkip

		movea.l	(a0),a1
		move.b	#-1,(a1)

		rts


; ---------------------------------------------------------
; 29.12.99/vk
; verschiebt die grafikzeilen (offscreen memory) um eine
; textzeile nach oben
laptopShiftUpOneRowGraphic

		bsr	laptopDrawOffscreen		; todo: routine durch geschicktes bitblt (videoram)
							; oder vergleichbare routine (ram) ersetzen
		
		rts


; ---------------------------------------------------------
; 29.12.99/vk
; verschiebt die offscreen-grafik um eine zeile nach unten,
; loescht die grafik der obersten zeile und verschiebt
; ebenso die textbytes (damit angezeigte grafik und
; interne speicherung uebereinstimmend bleiben).
; rettet alle register.
laptopShiftDownOneRow

		movem.l	d0-a6,-(sp)
		bsr.s	laptopShiftDownOneRowAscii
		bsr.s	laptopShiftDownOneRowGraphic
		movem.l	(sp)+,d0-a6

		rts


; ---------------------------------------------------------
; 29.12.99/vk
; verschiebt die textzeilen um eins nach oben und
; loescht die unterste zeile heraus
laptopShiftDownOneRowAscii

		lea	laptop,a5
		movea.l	LAPTOPTEXTPTR(a5),a0		; array der textpointer
		move.w	LAPTOPY(a5),d0			; aktuelle hoehe des laptops
		subq.w	#1+1,d0
		bmi.s	lsdoraTextPtrSkip
		lea	4(a0,d0.w*4),a0
		movea.l	(a0),a2
lsdoraLoop	movea.l	a0,a1
		move.l	-(a0),(a1)
		dbra	d0,lsdoraLoop
		move.l	a2,(a0)
lsdoraTextPtrSkip

		movea.l	(a0),a1
		move.b	#-1,(a1)

		rts


; ---------------------------------------------------------
; 29.12.99/vk
; verschiebt die grafikzeilen (offscreen memory) um eine
; textzeile nach oben
laptopShiftDownOneRowGraphic

		bsr	laptopDrawOffscreen		; todo: routine durch geschicktes bitblt (videoram)
							; oder vergleichbare routine (ram) ersetzen
		
		rts


