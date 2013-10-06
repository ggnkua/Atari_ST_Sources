

		text


; ---------------------------------------------------------
; 24.07.00/vk
; beantwortet, ob der spieler einen gewissen gegenstand
; in besitzt (d. h. bereits aufgenommen) hat oder nicht.
; d0.w = gegenstand
; rueckgabe: d0.w = 0 (nein), 1 = (ja)
; rettet alle register
hasPlayerThing	move.l	a0,-(sp)
		lea	playerThings,a0
		mulu.w	#PTHGBYTES,d0
		move.w	PTHGFLAG(a0,d0.w),d0
		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 24.07.00/vk
; beantwortet, ob der spieler einen gewissen gegenstand
; aktiviert hat oder nicht.
; d0.w = gegenstand
; rueckgabe: d0.w = 0 (nein bzw. nicht in besitz), 1 = (ja)
; rettet alle register
hasPlayerThingActivated
		move.l	a0,-(sp)
		lea	playerThings,a0
		mulu.w	#PTHGBYTES,d0
		move.w	PTHGACTFLAG(a0,d0.w),d0
		movea.l	(sp)+,a0
		rts


