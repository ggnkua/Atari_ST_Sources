		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#2,d1			; Bufferl„nge < 2
		blt.s	raus			; Raus!
		
		cmp.b	#$50,(a1)+
		bne.s	raus
		cmp.b	#$31,(a1)
		blt.s	raus
		cmp.b	#$37,(a1)
		bhi.s	raus

		move.l	#2,d0			; erkannt
		lea.l	ext(pc),a4		; extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4)+,(a3)+
		move.l	(a4)+,(a3)+
		move.l	(a4),(a3)

raus:	rts
*********
ext:	dc.b	"PNM PBM PGM PPM",0
; PPM: PBMPlus Picture-Format