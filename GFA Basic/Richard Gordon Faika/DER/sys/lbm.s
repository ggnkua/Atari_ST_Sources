		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#4,d1			; Bufferl„nge < 4
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		cmp.l	(a4)+,(a1)+
		bne.s	raus
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4)+,(a3)+		; ..
		move.l	(a4),(a3)
		
raus:	rts
*********
ext:	dc.b	"LBM HAM IFF",0
magic:	dc.b	$46,$4f,$52,$4d
; LBM: Amiga IFF-Format