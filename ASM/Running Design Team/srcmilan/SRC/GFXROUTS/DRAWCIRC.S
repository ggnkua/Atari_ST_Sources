

		text


; ---------------------------------------------------------
; 10.06.00/vk
; zeichnet einen kreis/vollkreis
; d1 = radius
; d4 = farbe
; a1 = screenadresse mittelpunkt
; rettet alle register
drawCircle
		movem.l	d0-a6,-(sp)

		moveq	#0,d0
		move.w	d1,d2
		subq.w	#1,d2

dcLoop
		tst.w	d2
		bpl.s	dcSecondCase
		subq.w	#1,d1
		add.w	d1,d2
		add.w	d1,d2
dcSecondCase
		move.w	d0,d3
		add.w	d3,d3

		move.w	d1,d5
		mulu.w	lineoffset,d5

		movea.l	a1,a0
		suba.w	d3,a0
		suba.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		adda.w	d3,a0
		suba.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		suba.w	d3,a0
		adda.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		adda.w	d3,a0
		adda.l	d5,a0
		move.w	d4,(a0)

		move.w	d1,d3
		add.w	d3,d3

		move.w	d0,d5
		mulu.w	lineoffset,d5

		movea.l	a1,a0
		suba.w	d3,a0
		suba.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		adda.w	d3,a0
		suba.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		suba.w	d3,a0
		adda.l	d5,a0
		move.w	d4,(a0)

		movea.l	a1,a0
		adda.w	d3,a0
		adda.l	d5,a0
		move.w	d4,(a0)

		sub.w	d0,d2
		sub.w	d0,d2
		subq.w	#1,d2
		addq.w	#1,d0
		cmp.w	d1,d0
		ble.s	dcLoop

		movem.l	(sp)+,d0-a6

		rts


