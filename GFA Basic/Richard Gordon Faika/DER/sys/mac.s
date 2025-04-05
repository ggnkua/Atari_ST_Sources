		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#73,d1			; Bufferl„nge < 73
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		add.l	#65,a1
		cmp.l	(a4)+,(a1)+
		bne.s	raus
		cmp.l	(a4)+,(a1)+
		bne.s	raus
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4),(a3)		; ..
		
raus:	rts
*********
ext:	dc.b	"MAC PNT",0
magic:	dc.b	$50,$4e,$54,$47,$4d,$50,$4e,$54
; MAC: Mac Paint-Format