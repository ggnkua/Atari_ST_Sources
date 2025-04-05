		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#7,d1			; Bufferl„nge < 7
		blt.s	raus			; Raus!
		
		moveq	#6,d3
		lea.l	magic(pc),a4
loop:
		cmp.b	(a4)+,(a1)+
		bne.s	raus
		dbf		d3,loop
		
		moveq	#2,d0			; ganz sicher erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"CAL",0
magic:	dc.b	"rpelcnt"
; CAL: CALS Defense Log.