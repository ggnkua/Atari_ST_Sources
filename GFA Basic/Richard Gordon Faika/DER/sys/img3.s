		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#16,d1			; Bufferl„nge < 16
		blt.s	raus			; Raus!

		lea.l	magic(pc),a4	; magic nach a4 laden
		moveq	#3,d3
loop:
		cmp.b	(a4)+,(a1)+
		bne.s	raus
		dbf		d3,loop
		
		lea.l	magic2(pc),a4
		addq	#8,a1
		moveq	#1,d3
loop2:
		cmp.b	(a4)+,(a1)+
		bne.s	raus
		dbf		d3,loop
		
		moveq	#2,d0			; erkannt
		lea.l	ext(pc),a4		; wahre Extension
		move.l	(a4)+,(a3)+		; eintragen
		move.l	(a4),(a3)
		
raus:	rts
*********
ext:	dc.b	"IMG",0
magic:	dc.b	$47,$12,$6d,$b0
magic2:	dc.b	$00,$00
; IMG: Kontron IBAS-Format