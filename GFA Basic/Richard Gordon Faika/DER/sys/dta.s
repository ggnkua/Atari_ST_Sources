		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#15,d1			; BufferlÑnge < 15
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		addq	#2,a1			; das 2te byte bitte
		cmp.l	(a4)+,(a1)+		; vergleichen
		bne.s	raus			; stimmt nicht -> raus
		addq	#8,a1			; das 14te byte bitte
		cmp.b	#$ff,(a1)+
		bne.s	raus
		cmp.b	#$00,(a1)
		bne.s	raus
		
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"DTA",0
magic:	dc.b	$47,$12,$6d,$b0
; DTA: Zeiss BIVAS-Format