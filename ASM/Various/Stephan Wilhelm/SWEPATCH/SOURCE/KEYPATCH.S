; In den neuen Systemvariablen bootkeymode ($1c0) und bootkey ($1c1)
; wird der Sondertasten-Code und Scancode der Taste,mit der w„hrend
; der Bootphase der Speichertest abgebrochen wurde,abgelegt.
; Dadurch kann mit den Funktiontasten (statt Return) die Bootsequenz
; ge„ndert werden.
; Diese Systemvariablen werden nach der Bootphase gel”scht !
; Das ist notwendig,damit bei einem Warmstart wieder die
; Standard-Bootsequenz verwendet wird.

	org $7fe60500

	move.l	#$00020002,-(sp)
	trap	#13
	addq.l	#4,sp
        lsr.l	#8,d0
	lsr.l	#8,d0
	move.b	d0,$5d1
	move.w	#-1,-(sp)
	move.w	#$b,-(sp)
	trap	#13
	addq.l	#4,sp
	move.b	d0,$5d0
	jmp	$7fe00aca

