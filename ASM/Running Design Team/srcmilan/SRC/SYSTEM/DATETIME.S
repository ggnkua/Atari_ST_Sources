

		text


; ---------------------------------------------------------
; konvertiert die aktuelle zeit ins ascii-format
; nach a0 im format hh:mm:ss
; a0 = pointer auf 8 bytes
time2ascii
		movem.l	d0-d7/a1-a6,-(sp)

		move.l	a0,-(sp)

	; zeit holen

		move.w	#44,-(sp)
		trap	#1
		addq.l	#2,sp

		movea.l	(sp)+,a0

	; stunden umwandeln

		move.w	d0,d1
		rol.w	#5,d1
		andi.l	#%00011111,d1
		moveq.w	#10,d4
		divu.w	d4,d1
		move.w	#$30,d2
		add.w	d2,d1
		move.b	d1,(a0)+
		swap	d1
		add.w	d2,d1
		move.b	d1,(a0)+
		move.b	#":",d3
		move.b	d3,(a0)+

	; minuten umwandeln

		move.w	d0,d1
		lsr.w	#5,d1
		move.l	#%00111111,d5
		and.l	d5,d1
		divu.w	d4,d1
		add.w	d2,d1
		move.b	d1,(a0)+
		swap	d1
		add.w	d2,d1
		move.b	d1,(a0)+
		move.b	d3,(a0)+

	; sekunden umwandeln

		add.w	d0,d0
		and.l	d5,d0
		divu.w	d4,d0
		add.w	d2,d0
		move.b	d0,(a0)+
		swap	d0
		add.w	d2,d0
		move.b	d0,(a0)+

		movem.l	(sp)+,d0-d7/a1-a6

		rts


; ---------------------------------------------------------
; konvertiert das aktuelle datum ins ascii-format
; nach a0 im format dd.mm.yyyy
; a0 = pointer auf 10 bytes
date2ascii
		movem.l	d0-d7/a1-a6,-(sp)

		move.l	a0,-(sp)

	; datum holen

		move.w	#42,-(sp)
		trap	#1
		addq.l	#2,sp

		movea.l	(sp)+,a0

	; tag umwandeln

		move.w	d0,d1
		andi.l	#%00011111,d1
		moveq.w	#10,d4
		divu.w	d4,d1
		move.w	#$30,d2
		add.w	d2,d1
		move.b	d1,(a0)+
		swap	d1
		add.w	d2,d1
		move.b	d1,(a0)+
		move.b	#".",d3
		move.b	d3,(a0)+

	; monat umwandeln

		move.w	d0,d1
		lsr.w	#5,d1
		andi.l	#%00001111,d1
		divu.w	d4,d1
		add.w	d2,d1
		move.b	d1,(a0)+
		swap	d1
		add.w	d2,d1
		move.b	d1,(a0)+
		move.b	d3,(a0)+

	; jahr umwandeln

		moveq	#9,d1
		lsr.w	d1,d0
		andi.l	#%01111111,d0
		addi.l	#1980,d0
		divu.w	#1000,d0
		add.w	d2,d0
		move.b	d0,(a0)+
		clr.w	d0
		swap	d0
		divu.w	#100,d0
		add.w	d2,d0
		move.b	d0,(a0)+
		clr.w	d0
		swap	d0
		divu.w	#10,d0
		add.w	d2,d0
		move.b	d0,(a0)+
		swap	d0
		add.w	d2,d0
		move.b	d0,(a0)+

		movem.l	(sp)+,d0-d7/a1-a6

		rts



		data


datestring	dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	" ",0
		even

timestring	dc.b	0,0,0,0,0,0,0,0
		dc.b	"  ",0
		even



		bss
 