		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#17,d1			; Bufferl„nge < 17
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		moveq	#3,d3			; schleifenz„hler
loop:
		cmp.b	(a4)+,(a1)+		; vergleichen
		bne.s	raus
		dbf		d3,loop			; schleifenende
		
		add		#13,a1
		cmp.b	#$ff,(a1)		; das 17te noch vergleichen
		bne.s	raus
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4)+,(a3)+		; ..
		move.w	(a4)+,(a3)+		; ..
		move.b	(a4),(a3)		; ..
		
raus:	rts
*********
ext:	dc.b	"GM GM2 GM4",0
magic:	dc.b	$ff,$04,$00,$07
; GM: Autologic File-Format