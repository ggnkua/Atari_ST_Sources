		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#3,d1			; Bufferl„nge < 3
		blt.s	raus			; Raus!
		
		cmp.b	#$cd,(a1)+
		bne.s	raus
		cmp.b	#$05,(a1)+
		bhi.s	raus
		cmp.b	#$02,(a1)+
		bhi.s	raus
		subq	#2,a1
		cmp.b	#1,(a1)
		bne.s	raus
		cmp.b	#4,(a1)
		bne.s	raus

		move.l	#2,d0			; erkannt
		lea.l	ext(pc),a4		; extension
		move.l	(a4),(a3)		; eintragen

raus:	rts
*********
ext:	dc.b	"SCR",0
; SCR MS-Word-Grafikformat