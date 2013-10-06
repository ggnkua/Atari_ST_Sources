

		text


; ---------------------------------------------------------
; 22.01.00/vk
copyScreenLogToPhys

		movea.l	screen_1,a0
		movea.l	screen_2,a1
		bsr.s	copyScreen

		rts


; ---------------------------------------------------------
; 22.01.00/vk
copyScreenPhysToLog

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		bsr.s	copyScreen

		rts


; ---------------------------------------------------------
; 22.01.00/vk
; a0 = quellebildschirm
; a1 = zielbildschirm
; rettet alle register.
copyScreen
		movem.l	d0-d3/a0-a3,-(sp)

		move.w	width,d0
		subq.w	#1,d0
		move.w	height,d1
		subq.w	#1,d1

		move.w	lineoffset,d3

cscrLoop1	move.w	d0,d2
		movea.l	a0,a2
		movea.l	a1,a3
cscrLoop2	move.w	(a2)+,(a3)+
		dbra	d2,cscrLoop2
		adda.w	d3,a0
		adda.w	d3,a1
		dbra	d1,cscrLoop1

		movem.l	(sp)+,d0-d3/a0-a3

		rts


; ---------------------------------------------------------
; 22.01.00/vk
darkenLogicalScreen
		movea.l	screen_1,a0
		bsr.s	darkenScreen
		rts


; ---------------------------------------------------------
; 22.01.00/vk
darkenPhysicalScreen
		movea.l	screen_2,a0
		bsr.s	darkenScreen
		rts


; ---------------------------------------------------------
; 22.01.00/vk
; a0 = screenadresse
darkenScreen
		move.w	width,d0
		lsr.w	#1,d0
		subq.w	#1,d0
		move.w	height,d1
		subq.w	#1,d1

		move.w	lineoffset,d3
		moveq	#0,d4
		moveq	#4,d5

dsLoop1		move.w	d0,d2
		movea.l	a0,a1
		adda.w	d4,a1
dsLoop2		clr.w	(a1)
		adda.w	d5,a1
		dbra	d2,dsLoop2
		bchg	#1,d4
		adda.w	d3,a0
		dbra	d1,dsLoop1

		rts




		data


