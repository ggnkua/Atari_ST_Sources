		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#4,d1			; Bufferl„nge < 4
		blt.s	raus			; Raus!

		lea.l	magic1(pc),a4	; magic nach a4 laden
		move.l	a1,a5
		cmp.l	(a4)+,(a5)+
		beq.s	ja
		
		lea.l	magic2(pc),a4
		cmp.l	(a4)+,(a1)+
		bne.s	raus
		
ja:		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4),(a3)		; eintragen
		
raus:	rts
*********
ext:	dc.b	"MSP",0
magic1:	dc.b	$4c,$69,$6e,$53
magic2:	dc.b	$44,$61,$6e,$4d
; MSP: Microsoft Paint