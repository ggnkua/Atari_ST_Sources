; NA_ASS.S
; Librairie pour les nouveaux appels AES >= 3.30
; 
; Janvier 1993 par Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
; 
; Adaptation par Claude ATTARD pour ST Mag - Mars 94

export CallAes

CallAes:
	movem.l	d0-a6,-(sp)
	move.l	#200,d0
	move.l	a0,d1
	trap #2
	movem.l	(sp)+,d0-a6
	rts
