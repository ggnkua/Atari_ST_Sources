		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#4,d1			; Bufferl„nge < 4
		blt.s	raus			; Raus!
		
		lea.l	magic1(pc),a4
		clr.l	d4
		move.w	(a1),d4
		cmp.w	(a4),d4
		beq.s	weiter
		lea.l	magic2(pc),a4
		cmp.w	(a4),d4
		bne.s	raus
weiter:
		clr.l	d4
		move.b	2(a1),d4
		cmp.b	#$2a,d4
		bne.s	raus
		
		move.l	#2,d0
		lea.l	ext(pc),a4
		move.l	(a4),(a3)

raus:	rts
*********
ext:	dc.b	"TIF JTF",0
magic1:	dc.b	$49,$49
magic2:	dc.b	$4d,$4d
; TIF: Tag Image File-Format