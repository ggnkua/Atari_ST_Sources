		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#15,d1			; Bufferl„nge < 15
		blt.s	raus			; Raus!
		
		cmp.b	#$42,(a1)+
		bne.s	raus
		cmp.b	#$4d,(a1)
		bne.s	raus
		add		#13,a1
		cmp.b	#$0c,(a1)
		blt.s	raus
		
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4)+,(a3)+		; ..
		move.l	(a4),(a3)		; ..
		
raus:	rts
*********
ext:	dc.b	"BMP RLE DIP",0
; BMP: Windows (3.x) Bitmap-Format