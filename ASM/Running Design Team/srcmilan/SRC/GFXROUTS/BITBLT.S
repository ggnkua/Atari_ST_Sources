
; bitblt
; (1) source:
; a2 = bitmapptr
; (2) destination:
; a0 = screenadresse
; d6 = x
; d7 = y

; bitbltsize
; (1) source:
; a2 = bitmapptr
; d4 = dx (width)
; d5 = dy (height)
; (2) destination:
; a0 = screenadresse
; d6 = x
; d7 = y

; bitbltsizeoffset
; (1) source:
; a2 = bitmapptr
; d2 = xoffset
; d3 = yoffset
; d4 = dx (width)
; d5 = dy (height)
; (2) destination:
; a0 = screenadresse
; d6 = x
; d7 = y


		text


; ---------------------------------------------------------
; 12.06.00/vk
; kopiert einen memoryblock/texturblock der angegebenen
; bitmap in den entsprechenden bereich auf der grafikkarte.
; dabei werden unterschiedliche routinen aufgerufen, je
; nachdem, ob die ausgangsbitmap bereits auf der grafikkarte
; abgelegt ist oder nicht.
; die ausgangsbitmap wird in ihrer vollen groesse kopiert.
; d6 = zielposition x
; d7 = zielposition y
; a0 = screenadresse (screen_1 oder screen_2)
; a2 = pointer auf bitmap struktur
; alle register werden gerettet.
bitBlt
		movem.l	d2-d5,-(sp)
		moveq	#0,d2
		moveq	#0,d3
		move.w	BITMAPWIDTH(a2),d4
		move.w	BITMAPHEIGHT(a2),d5
		bsr.s	bitBltSizeOffset
		movem.l	(sp)+,d2-d5
		rts

		
; ---------------------------------------------------------
; 12.06.00/vk
; kopiert einen memoryblock/texturblock der angegebenen
; bitmap in den entsprechenden bereich auf der grafikkarte.
; dabei werden unterschiedliche routinen aufgerufen, je
; nachdem, ob die ausgangsbitmap bereits auf der grafikkarte
; abgelegt ist oder nicht.
; die quellbitmap wird in der angegebenen dimension kopiert.
; d4 = breite der quellbitmap
; d5 = hoehe der quellbitmap
; d6 = zielposition x
; d7 = zielposition y
; a0 = screenadresse (screen_1 oder screen_2)
; a2 = pointer auf bitmap struktur
; alle register werden gerettet.
bitBltSize
		movem.l	d2-d3,-(sp)
		moveq	#0,d2
		moveq	#0,d3
		bsr.s	bitBltSizeOffset
		movem.l	(sp)+,d2-d3
		rts


; ---------------------------------------------------------
; 12.06.00/vk
; kopiert einen memoryblock/texturblock der angegebenen
; bitmap in den entsprechenden bereich auf der grafikkarte.
; dabei werden unterschiedliche routinen aufgerufen, je
; nachdem, ob die ausgangsbitmap bereits auf der grafikkarte
; abgelegt ist oder nicht.
; die quellbitmap wird in der angegebenen dimension ab der
; angegebenen position (offset) kopiert.
; d2 = xoffset
; d3 = yoffset
; d4 = breite der quellbitmap
; d5 = hoehe der quellbitmap
; d6 = zielposition x
; d7 = zielposition y
; a0 = screenadresse (screen_1 oder screen_2)
; a2 = pointer auf bitmap struktur
; alle register werden gerettet.
bitBltSizeOffset
		tst.w	BITMAPVIDEORAMFLAG(a2)			; liegt bitmap im videoram vor?
		beq.s	bbsoCallRam				; nein -> dann eigene routine fuer ram
		bsr.s	bbsoVideoRam
		bra.s	bbsoOut
bbsoCallRam
		bsr.s	bbsoRam
bbsoOut
		rts


; ---------------------------------------------------------
; 12.06.00/vk
; d2 = xoffset
; d3 = yoffset
; d4 = breite der quellbitmap
; d5 = hoehe der quellbitmap
; d6 = zielposition x
; d7 = zielposition y
; a0 = screenadresse (screen_1 oder screen_2)
; a2 = pointer auf bitmap struktur
; alle register werden gerettet.
bbsoRam
		movem.l	d1-d7/a0-a1/a3-a4,-(sp)

		move.w	lineoffset,d1				; lineoffset des screens
		add.w	d6,d6
		adda.w	d6,a0
		mulu.w	d1,d7
		adda.l	d7,a0

		movea.l	BITMAPGFXPTR(a2),a1
		move.w	BITMAPLINEOFFSET(a2),d6			; lineoffset der bitmap
		add.w	d2,d2
		adda.w	d2,a1
		mulu.w	d6,d3
		adda.l	d3,a1

		subq.w	#1,d4
		bmi.s	bbsorOut
		subq.w	#1,d5
		bmi.s	bbsorOut
bbsorLoopY	movea.l	a0,a4
		movea.l	a1,a3
		move.w	d4,d3
bbsorLoopX	move.w	(a3)+,(a4)+
		dbra	d3,bbsorLoopX
		adda.w	d6,a1
		adda.w	d1,a0
		dbra	d5,bbsorLoopY
		
bbsorOut
		movem.l	(sp)+,d1-d7/a0-a1/a3-a4
		rts

; ---------------------------------------------------------
; 12.06.00/vk - todo
; d2 = xoffset
; d3 = yoffset
; d4 = breite der quellbitmap
; d5 = hoehe der quellbitmap
; d6 = zielposition x
; d7 = zielposition y
; a0 = screenadresse (screen_1 oder screen_2)
; a2 = pointer auf bitmap struktur
; alle register werden gerettet.
bbsoVideoRam
		movem.l	d0-a6,-(sp)

		movem.l	(sp)+,d0-a6
		rts

