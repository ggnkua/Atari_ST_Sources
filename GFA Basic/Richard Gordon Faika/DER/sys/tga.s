		move.l	4(sp),a1		; Bufferadresse
		move.l	8(sp),d1		; Bufferl„nge
		move.l	12(sp),a2		; Extension
		move.l	16(sp),d2		; Dateil„nge
		move.l	20(sp),a3		; fr Rckgabe wahre Extension
*********
		moveq	#0,d0			; nicht erkannt vorbelegen
		
		cmp.l	#16,d1			; Bufferl„nge < 16
		blt.s	raus			; Raus!

		clr.l	d3
		move.b	2(a1),d3		; das 2te byte bitte
		andi.b	#$7f,d3			; and 127
		cmp.b	#3,d3			; gr”sser 3
		bhi.s	raus			; raus
		cmp.b	#0,d3			; negative
		blt.s	raus			; raus
		
		clr.l	d3
		move.b	16(a1),d3		; im 16ten Byte steht die
		cmp.b	#$8,d3			; Farbtiefe.
		beq.s	weiter			; 8,16,24, oder 32 Bit sind
		cmp.b	#$10,d3			; m”glich
		beq.s	weiter
		cmp.b	#$18,d3
		beq.s	weiter
		cmp.b	#$20,d3
		bne.s	raus
		
weiter:
		move.l	#2,d0
		lea.l	ext(pc),a4
		move.l	(a4),(a3)

raus:	rts
*********
ext:	dc.b	"TGA",0
; TGA: Targa Bitmap-Format