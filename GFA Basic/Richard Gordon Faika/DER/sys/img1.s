		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#20,d1			; Bufferl„nge < 20
		blt.s	raus			; Raus!
		
		cmp.w	#1,(a1)			; Byte 0 = 0 und Byte 1= 1
		bne.s	weiter

		moveq	#1,d0			; vielleicht erkannt

		lea.l	ext(pc),a4
		cmp.l	(a2)+,(a4)+		; Extensions
		bne.s	weiter			; vergleichen
		bra.s	ja
		
weiter:
		lea.l	magic(pc),a4
		add		#16,a1
		cmp.l	(a4)+,(a1)+
		bne.s	raus
		
ja:
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"IMG",0
magic:	dc.b	"XIMG"
;GEM Image File Format