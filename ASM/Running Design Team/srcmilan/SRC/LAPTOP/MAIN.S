

		text


drawLaptop
		bsr	laptopKeyHit			; laptopsteuerung

		tst.w	laptopFlag			; soll laptop (jetzt) angezeigt?
		beq.s	dlNotVisible			; nein -> dann auch nicht zeichnen

		bsr	laptopDrawCursor
		bsr	laptopCopyToVideoRam
		bsr	laptopDrawBorder

dlNotVisible
		rts


; ---------------------------------------------------------
; 02.01.00/vk
; bringt den laptop im kleinen modus zur anzeige, dabei
; werden alle angezeigten nachrichten geloescht.
; ist der laptop bereits sichtbar, erfolgt keine aenderung.
laptopShowSmall
		lea	laptopFlag,a0			; flag, ob laptop aktiviert ist
		tst.w	(a0)				; bereits aktiviert?
		bne.s	lssOut				; ja -> dann nichts machen

		move.w	#1,(a0)				; laptop (flag) auf aktiviert setzen

		lea	laptop,a0
		movea.l	LAPTOPFONTDATAPTR(a0),a1
		move.w	LFMAXX(a1),d0			; minimale dimensionen holen...
		move.w	LFMINY(a1),d1
		bsr	laptopSetDimensions		; ...und setzen
		bsr	laptopDrawOffscreen		; offscreen (ram oder video-ram) neu zeichnen
lssOut
		rts


; ---------------------------------------------------------
; 07.01.00/vk
; bringt den laptop im grossen modus zur anzeige, dabei
; werden alle angezeigten nachrichten geloescht.
; ist der laptop bereits sichtbar, erfolgt keine aenderung.
laptopShowBig
		lea	laptopFlag,a0			; flag, ob laptop aktiviert ist
		tst.w	(a0)				; bereits aktiviert?
		bne.s	lsbOut				; ja -> dann nichts machen

		move.w	#1,(a0)				; laptop (flag) auf aktiviert setzen

		lea	laptop,a0
		movea.l	LAPTOPFONTDATAPTR(a0),a1
		move.w	LFMAXX(a1),d0			; maximale dimensionen holen...
		move.w	LFMAXY(a1),d1
		bsr	laptopSetDimensions		; ...und setzen
		bsr	laptopDrawOffscreen		; offscreen (ram oder video-ram) neu zeichnen
lsbOut
		rts


; ---------------------------------------------------------
; 22.01.00/vk
; hauptroutine fuer texteingaben im laptop.
; laptopflag darf nicht geaendert werden.
laptopInputMode
		bsr	copyScreenPhysToLog
		bsr	darkenLogicalScreen

		bsr	laptopDrawOffscreen
		bsr	laptopDrawCursor
		bsr	laptopCopyToVideoRam
		bsr	laptopDrawBorder

		bsr	swapScreens
		bsr	restoreKeyboardIrq

		bsr	laptopInputModeSingleLine

		bsr	installKeyboardIrq
		bsr	swapScreens
		bsr	copyScreenPhysToLog

		rts