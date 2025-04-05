		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#2,d1			; BufferlÑnge < 2
		blt.s	raus			; Raus!
		
		cmp.b	#$50,(a1)+		; vergleichen
		bne.s	raus			; stimmt nicht? -> raus
		cmp.b	#$c3,(a1)
		bne.s	raus
		
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"CLP",0
; CLP: Windows Clipboard-Format