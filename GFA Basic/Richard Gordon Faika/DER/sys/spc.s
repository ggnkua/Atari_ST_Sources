		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#12,d1			; Bufferl„nge < 12
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4
		cmp.w	(a4)+,(a1)+
		beq.s	komp
		
		subq	#2,a1
		moveq	#2,d4
loop:
		cmp.l	#00,(a1)+
		bne.s	raus
		dbf		d4,loop
		bra.s	unk

komp:
		move.l	#2,d0
		lea.l	ext1(pc),a4
		move.l	(a4),(a3)
		rts
		
unk:
		move.l	#2,d0
		lea.l	ext2(pc),a4
		move.l	(a4),(a3)

raus:	rts
*********
ext1:	dc.b	"SPC",0
ext2:	dc.b	"SPU",0
magic:	dc.b	$53,$50
; SPC: Atari Spectrum 512