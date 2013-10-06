


		text


; ---------------------------------------------------------
; 09.07.00/vk
; gibt einen zufallswert zwischen 0 und 255 zurueck.
; rettet alle register.
; rueckgabe: d1.w = zufallszahl [0..255]
getChance256
		move.l	a0,-(sp)
		lea	chance256TabPos,a0
		move.w	(a0),d1
		addq.b	#1,d1
		andi.w	#$ff,d1
		move.w	d1,(a0)
		lea	chance256Tab,a0
		move.b	(a0,d1.w),d1			; d1 im op1 als 16 bit angesprochen, spaeter dann nur lowbyte belegt (hibyte war bereits null)
		movea.l	(sp)+,a0

		rts





		data

chance256TabPos	dc.w	0
chance256Tab	include	"src\tables\chance.s"


