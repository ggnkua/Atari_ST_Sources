		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#3,d1			; Bufferl„nge < 3
		blt.s	raus			; Raus!
		
		lea.l	magic(pc),a4
		cmp.w	(a4)+,(a1)+
		bne.s	raus
		cmp.b	#$48,(a1)
		beq.s	weiter
		cmp.b	#$4d,(a1)
		bne.s	raus
weiter:

		move.l	#2,d0			; erkannt
		lea.l	ext(pc),a4		; extension
		move.l	(a4),(a3)		; eintragen

raus:	rts
*********
ext:	dc.b	"RLE",0
magic:	dc.b	$1b,$47
; RLE: Compuserve VIDTEX-Format