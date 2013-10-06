

		text


; ---------------------------------------------------------
; 11.06.00/vk
; zeichnet eine linie (ohne clipping).
; d0 = x1
; d1 = y1
; d2 = x2
; d3 = y2
; d4.l = screenoffset (lineoffset)
; d7 = color
; a0 = screenadresse
; rettet alle register
drawLine
		movem.l	d4/d7-a0,-(sp)			; todo (optimize)

		cmp.w	d0,d2
		bgt.s	dlNoExchange
		exg	d0,d2
		exg	d1,d3
dlNoExchange
		move.w	d1,d5
		muls.w	d4,d5
		adda.l	d5,a0
		adda.w	d0,a0
		adda.w	d0,a0			; a0 =  anfangsadresse

		sub.w	d0,d2			; dx (immer positiv)
		beq.s	dlVertical
		sub.w	d1,d3			; dy
		bpl.s	dlNoChange
		neg.w	d3			; dy wieder positiv
		neg.l	d4			; lineoffset negieren
dlNoChange

		; dx/dy jetzt positiv

		cmp.w	d2,d3
		bge.s	dlSteep			; steile linie (Fall 2)

dlFlat
		move.w	d3,d1
		sub.w	d2,d1
		add.w	d1,d1			; inc2 = 2 * ( dy - dx )
		add.w	d3,d3			; inc1 = 2 * dy

		move.w	d3,d0
		sub.w	d2,d0			; g = 2 * dy - dx

dlfLoop
		move.w	d7,(a0)+
		tst.w	d0
		bmi.s	dlfMin
		beq.s	dlfMin
		adda.l	d4,a0
		add.w	d1,d0
		dbra	d2,dlfLoop

		movem.l	(sp)+,d4/d7-a0
		rts

dlfMin
		add.w	d3,d0
		dbra	d2,dlfLoop

		movem.l	(sp)+,d4/d7-a0
		rts

dlSteep
		move.w	d2,d1
		sub.w	d3,d1
		add.w	d1,d1			; inc2 = 2 * ( dx - dy )
		add.w	d2,d2			; inc1 = 2 * dx

		move.w	d2,d0
		sub.w	d3,d0			; g = 2 * dx - dy

dlsLoop
		move.w	d7,(a0)
		add.l	d4,a0
		tst.w	d0
		bmi.s	dlsMin
		beq.s	dlsMin
		addq.l	#2,a0
		add.w	d1,d0
		dbra	d3,dlsLoop

		movem.l	(sp)+,d4/d7-a0
		rts

dlsMin
		add.w	d2,d0
		dbra	d3,dlsLoop

		movem.l	(sp)+,d4/d7-a0
		rts


dlVertical
		sub.w	d1,d3
		bpl.s	dlvNoChange
		neg.w	d3
		neg.l	d4
dlvNoChange
		move.w	d7,(a0)
		adda.l	d4,a0
		dbra	d3,dlvNoChange

		movem.l	(sp)+,d4/d7-a0
		rts
