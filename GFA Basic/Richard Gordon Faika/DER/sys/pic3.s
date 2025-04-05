		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#512,d1			; Bufferl„nge < 512
		blt.s	raus			; Raus!
		
		add		#$200,a1
		move.l	a1,d3
		sub		#$200,d2
		cmp		d2,d3
		bne.s	raus

		move.l	#2,d0			; erkannt
		lea.l	ext(pc),a4		; extension
		move.l	(a4),(a3)		; eintragen

raus:	rts
*********
ext:	dc.b	"PIC",0
; PIC: Mac-PICT2-Format