		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; BufferlÑnge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; DateilÑnge
		move.l	20(sp),a3		; fÅr RÅckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#2,d1			; BufferlÑnge < 2
		blt.s	raus			; Raus!
		
		move.b	1(a1),d4
		cmp.b	#3,d4			; byte2 < 3 ?
		bgt.s	raus
		
		move.b	(a1),d5
		cmp.b	#$00,d5			; byte1 = 0 -> unkomprimiert
		beq.s	unk
		
		cmp.b	#$80,d5			; byte1 = $80 -> komprimiert
		beq.s	kompr
		
		rts
		
unk:
		lea.l	ext1(pc),a4
		bra.s	rest
kompr:
		lea.l	ext2(pc),a4
		bra.s	rest2
rest:
		cmp.l	#32034,d2
		beq.s	rest2
		cmp.l	#32066,d2
		bne.s	raus
rest2:
		move.w	(a4),(a3)+
		add		#49,d4
		move.b	d4,(a3)
		move.l	#2,d0
raus:
		rts
*********
ext1:	dc.b	"PI"
ext2:	dc.b	"PC"
; PI?: Atari DEGAS-Format