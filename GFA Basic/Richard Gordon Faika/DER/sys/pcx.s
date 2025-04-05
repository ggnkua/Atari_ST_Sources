		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#3,d1			; Bufferl„nge < 3
		blt.s	raus			; Raus!
		
		cmp.b	#$0a,(a1)+
		bne.s	raus
		move.b	(a1),d4
		cmp.b	#$00,d4
		beq.s	weiter
		cmp.b	#$02,d4
		beq.s	weiter
		cmp.b	#$03,d4
		beq.s	weiter
		cmp.b	#$05,d4
		beq.s	weiter
		bra.s	raus
weiter:
		addq	#1,a1
		cmp.b	#$02,(a1)
		bhi.s	raus
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4),(a3)
		
raus:	rts
*********
ext:	dc.b	"PCX PCC",0
; PCX: ZSoft Paintbrush