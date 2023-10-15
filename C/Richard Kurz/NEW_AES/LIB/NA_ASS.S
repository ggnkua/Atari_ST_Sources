; NA_ASS.S
;
; Libary fÅr die neuen AES-Funktionen ab AES 3.31 MultiTOS 1.0
; 
; (c) MÑrz 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
; Fido 2:241/7232.5
; Vertrieb nur durch das TOS-Magazin

export CallAes

CallAes:
	movem.l	d0-a6,-(sp)
	move.l	#200,d0
	move.l	a0,d1
	trap #2
	movem.l	(sp)+,d0-a6
	rts