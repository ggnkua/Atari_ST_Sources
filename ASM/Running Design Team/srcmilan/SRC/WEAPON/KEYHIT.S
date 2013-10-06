


		text


; ---------------------------------------------------------
; 12.07.00/vk
; tastatureingaben zur waffensteuerung
; rettet alle register
weaponKeyHit
		movem.l	d0-a6,-(sp)

		lea	keyoverlay,a0
		lea	keytable,a1

		moveq	#9,d1
wkhLoop
		move.w	KOSELECTWEAPON0(a0,d1.w*2),d0
		tst.b	(a1,d0.w)
		beq.s	wkhNoSelectWeapon
		movem.l	d1/a0-a1,-(sp)
		clr.b	(a1,d0.w)				; tastendruck loeschen
		move.w	d1,d0
		bsr	setNewWeapon				; .\src\weapon\setweapn.s
		movem.l	(sp)+,d1/a0-a1
wkhNoSelectWeapon
		dbra	d1,wkhLoop

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------