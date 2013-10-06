

		text


; ---------------------------------------------------------
; 21.05.00/vk
; wandelt eine 16 bit hexadezimalzahl ins ascii-format um.
; d0 = 16 bit hexadezimalzahl
; a0 = zeiger auf 6 bytes array
; rueckgabe: a0 = gefuelltes ascii array mit 0-zeichen terminierung
; rettet alle register
bin2Ascii16
		movem.l	d1/a0,-(sp)

		moveq	#$30,d1
		andi.l	#$0000ffff,d0
		divu.w	#10000,d0
		add.b	d1,d0
		move.b	d0,(a0)+

		swap	d0
		andi.l	#$0000ffff,d0
		divu.w	#1000,d0
		add.b	d1,d0
		move.b	d0,(a0)+

		swap	d0
		andi.l	#$0000ffff,d0
		divu.w	#100,d0
		add.b	d1,d0
		move.b	d0,(a0)+

		swap	d0
		andi.l	#$0000ffff,d0
		divu.w	#10,d0
		add.b	d1,d0
		move.b	d0,(a0)+

		swap	d0
		add.b	d1,d0
		move.b	d0,(a0)+

		clr.b	(a0)

		movem.l	(sp)+,d1/a0
		rts



b2aAsciiArray	dc.b	0,0,0,0,0,0

