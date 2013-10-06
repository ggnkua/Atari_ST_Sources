

		text


; ---------------------------------------------------------
; 03.02.00/vk
; kopiert den quellstring an die position im zielstring
; bis der quellstring zu ende ist. das nullzeichen in (a1)
; wird neu gesetzt.
; a0 = quellstring
; a1 = zielstring (zielposition)
; rueckgabe: a1 = position im zielstring nach einfuegen des quellstrings
; rettet alle register.
stringCopy
		movem.l	d0/a0,-(sp)
strcLoop	move.b	(a0)+,d0
		beq.s	strcOut
		move.b	d0,(a1)+
		bra.s	strcLoop
strcOut		clr.b	(a1)
		movem.l	(sp)+,d0/a0
		rts