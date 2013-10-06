


		text


; ---------------------------------------------------------
; 11.06.00/vk
; initialisiert die console mit den standardwerten.
; muss bei jedem aufloesungswechsel aufgerufen werden.
; rettet alle register
consoleResetFields
		movem.l	d0-a6,-(sp)

		lea	console,a0

		moveq	#0,d0
		move.w	#CONSOLESTARTPOSX,d1
		bpl.s	cifXPos
		move.w	width,d0
cifXPos		add.w	d1,d0
		move.w	d0,CONSOLEPOSXRIGHT(a0)

		moveq	#0,d0
		move.w	#CONSOLESTARTPOSY,d1
		bpl.s	cifYPos
		move.w	height,d0
cifYPos		add.w	d1,d0
		move.w	d0,CONSOLEPOSYDOWN(a0)

		movem.l	(sp)+,d0-a6
		rts


