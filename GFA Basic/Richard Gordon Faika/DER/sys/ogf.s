		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#3,d1			; Bufferl„nge < 3
		blt.s	raus			; Raus!

		lea.l	magic1(pc),a4	; magic nach a4 laden
		move.l	a1,a5
		cmp.w	(a4)+,(a5)+
		bne.s	raus
		cmp.b	(a4)+,(a5)+
		bne.s	raus
		
		lea.l	magic2(pc),a4	; magic nach a4 laden
		cmp.w	(a4)+,(a1)+
		bne.s	raus
		cmp.b	(a4)+,(a1)+
		bne.s	raus

		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"OGF",0
magic1:	dc.b	$4f,$56,$49
magic2:	dc.b	$56,$4f,$49
; OGF: Overhage Graphic-Format