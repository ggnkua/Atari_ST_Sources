		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		lea.l	ext(pc),a4		; Extension nach a4 laden
		cmp.l	(a4)+,(a2)+		; vergleichen
		bne.s	raus			; stimmt nicht -> raus
		
		; da nur die Extension verglichen werden kann
		moveq	#1,d0			; Vielleicht erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"CMP",0
; CMP: Atari Public Painter Monochrom