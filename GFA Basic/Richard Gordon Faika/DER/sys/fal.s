		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#12,d1			; BufferlÑnge < 12
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		moveq	#11,d3			; schleifenzÑhler
loop:
		cmp.b	(a4)+,(a1)+		; vergleichen
		bne.s	raus			; stimmt nicht -> raus
		dbf		d3,loop			; schliefenende
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"FAL",0
magic:	dc.b	"F_ALL(V1.00)"
; FAL: Q0 Japan Image File