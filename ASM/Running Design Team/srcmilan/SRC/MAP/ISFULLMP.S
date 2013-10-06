

		text


; ---------------------------------------------------------
; 02.07.00/vk
; beantwortet, ob z. zt. eine karte im fullscreen-modus
; angezeigt wird.
; rueckgabe: d0 = 1 (fullscreen), 0 (nicht aktiv bzw. nicht fullscreen)
; rettet alle register
isFullscreenMap
		movem.l	d1/a0,-(sp)

		moveq	#0,d0

		tst.w	mapFlag				; kartenmodus aktiv?
		beq.s	ifmOut

		lea	maps,a0
		move.w	mapMode,d1
		move.w	(a0,d1.w*2),d1
		cmpi.w	#MAPMAIN,d1
		bne.s	ifmOut

		moveq	#1,d0
ifmOut
		movem.l	(sp)+,d1/a0
		rts