

		text


; ---------------------------------------------------------
; 12.07.00/vk
; setzt eine neue waffe fuer den spieler.
; d0 = waffennummer 0..9 (unveraendert)
; rettet alle register
setNewWeapon
		movem.l	d0-a6,-(sp)

		tst.w	d0
		bmi.s	snwOut
		cmpi.w	#9,d0
		bgt.s	snwOut

		movea.l	playerDataPtr,a0

		tst.w	PDPISTOL0(a0,d0.w*2)		; ist die waffe vorhanden?
; todo		bne.s	snwWpPresent			; ja -> verzweigen
; todo		lea	wpNotPresentText,a0		; andernfalls meldung ausgegen und zurueck
; todo		bsr	installMessage
; todo		bra.s	snwOut
snwWpPresent

		tst.w	PDMUN0ANZ(a0,d0.w*2)		; ist noch munition vorhanden?
; todo		bne.s	snwAmmoPresent			; ja -> verzweigen
; todo		lea	wpNoMunText,a0
; todo		bsr	installMessage
; todo		bra.s	snwOut
snwAmmoPresent

		move.w	d0,PDMUNTYPE(a0)		

snwOut
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------




		data

			IFEQ LANGUAGE
wpNotPresentText	dc.b	"weapon not present",0
wpNoMunText		dc.b	"no ammunition for weapon",0
			ELSE
wpNotPresentText	dc.b	"waffe ist nicht vorhanden",0
wpNoMunText		dc.b	"keine munition fuer waffe vorhanden",0
			ENDC
			even
