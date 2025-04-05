		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#12,d1			; Bufferl„nge < 12
		blt.s	raus			; Raus!

		cmp.b	#4,1(a1)		; 2tes byte = 4 ?
		bne.s	raus

		lea.l	magic(pc),a4	; magic nach a4 laden
		addq	#2,a1
		moveq	#9,d3			; schleifenz„hler
loop:
		cmp.b	(a4)+,(a1)+		; vergleichen
		bne.s	raus
		dbf		d3,loop			; schliefenende
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"GFA",0
magic:	dc.b	"GFA-BASIC3"
; GFA: GFA-Basic 3.x