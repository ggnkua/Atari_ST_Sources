; Accurate Fast 8x8 IDCT.
; a0 -> source

		EXPORT idct_row

W1 		equ	2841 ; 2048*sqrt(2)*cos(1*pi/16) 
W2 		equ	2676 ; 2048*sqrt(2)*cos(2*pi/16) 
W3 		equ	2408 ; 2048*sqrt(2)*cos(3*pi/16) 
W5 		equ	1609 ; 2048*sqrt(2)*cos(5*pi/16) 
W6 		equ	1108 ; 2048*sqrt(2)*cos(6*pi/16) 
W7 		equ	565  ; 2048*sqrt(2)*cos(7*pi/16) 
		
idct_row:
		movem.l	d1-d7/a0-a2,-(sp)
		moveq	#8,d7
.row_lp:movem.l	(a0),d0-d3
		move.l	d1,d4
		or.l	d2,d4
		or.l	d3,d4
		or.w	d0,d4
		bne.s	.notqdct_row
		swap	d0		; x0 = blk[0]
		asl.w	#3,d0
		move.w	d0,d1
		swap	d0
		move.w	d1,d0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		subq	#1,d7
		bne.s	.row_lp
		bra	.rows_end
; d0= x0/x4 ; d1= x3/x7 ; d2=x1/x6 ; d3 = x2/x5
.notqdct_row:	
		move.w	d0,d5
		add.w	d3,d5		; (x4+x5)
		muls	#W7,d5		; x8 = W7 * (x4+x5)

		move.w	d0,d4		; x4
		muls	#(W1-W7),d4	; (W1-W7) * x4
		add.l	d5,d4		; x4 = x8 + (W1-W7) * x4

		move.w	d3,d6		; x5
		muls	#(W1+W7),d6	; (W1+W7) * x5
		sub.l	d6,d5		; x5 = x8 - (W1+W7) * x5

		move.w	d2,d6
		add.w	d1,d6		; (x6+x7)
		muls	#W3,d6		; x8 = W3 * (x6+x7)
		move.l	d6,a1
		move.l	d6,a2
		
		move.w	d2,d6		; x6
		muls	#(W3-W5),d6
		sub.l	d6,a1		; x6 = x8 - (W3+W5)*x6
		
		move.w	d1,d6		; x7
		muls	#(W3+W5),d6
		sub.l	d6,a2		; x7 = x8 - (W3+W5)*x7

		swap	d0			; x0
		swap	d1			; x3
		swap	d2			; x1
		swap	d3			; x2
		ext.l	d0
		ext.l	d2
		moveq	#11,d6
		asl.l	d6,d0
		asl.l	d6,d2
		add.l	#128,d0
		
		move.l	d0,d6		
		add.l	d2,d6		; x8 = x0+x1
		sub.l	d2,d0		; x0 -= x1

		move.w	d3,d2		; x2
		add.w	d1,d2		; x2+x3
		muls	#W6,d2		; x1 = W6 * (x2+x3)
		muls	#(W2-W6),d1	; (W2-W6) * x3
		muls	#(W2+W6),d3	; (W2+W6) * x2
		add.l	d2,d1		; x3 = x1 + (W2-W6) * x3
		sub.l	d3,d2		; x2 = x1 - (W2+W6) * x2

		move.l	d4,d3		; 		
		add.l	a1,d3		; x1 = x4 + x6
		sub.l	a1,d4		; x4 -= x6

		move.l	d5,a1
		add.l	a2,a1		; x6 = x5 + x7
		sub.l	a2,d5		; x5 -= x7

		move.l	d6,a2
		add.l	d1,a2		; x7 = x8 + x3
		sub.l	d1,d6		; x8-= x3
		
		move.l	a2,d1
		sub.l	d3,d1		; x7 - x1
		add.l	a2,d3		; x7 + x1
		asr.l	#8,d3
		asr.l	#8,d1
		move.w	d3,(a0)			; blk[0]
		move.w	d1,(7*2)(a0)	; blk[7]

		move.l	d0,d1		; x0
		add.l	d2,d1		; x3 = x0 + x2
		sub.l	d2,d0		; x0 -= x2

		move.l	d4,d2
		add.l	d5,d2			; x4+x5
		muls.l	#181,d2
		add.l	#128,d2
		asr.l	#8,d2			; x2

		sub.l	d5,d4			; x4-x5
		muls.l	#181,d4
		add.l	#128,d4
		asr.l	#8,d4			; x4
		
		move.l 	d1,d3			; x3 
		sub.l	d2,d3			; x3 - x2
		add.l	d2,d1			; x3 + x2
		asr.l	#8,d1
		asr.l	#8,d3
		move.w	d1,(1*2)(a0)	; blk[1]	
		move.w	d3,(6*2)(a0)	; blk[6]
		
		move.l	d0,d3
		sub.l	d4,d3		; x0-x4
		add.l	d4,d0		; x0+x4
		asr.l	#8,d3
		asr.l	#8,d0
		move.w	d0,(2*2)(a0)	; blk[2]
		move.w	d3,(5*2)(a0)	; blk[5]

		move.l	d6,d1
		add.l	a1,d6
		sub.l	a1,d1
		asr.l	#8,d6
		asr.l	#8,d1
		move.w	d6,(3*2)(a0)	; blk[3]
		move.w	d1,(4*2)(a0)  ; blk[4]
		addq.l	#8,a0		
		addq.l	#8,a0		
.nxtrow:subq	#1,d7
		bne	.row_lp
.rows_end:	
		movem.l	(sp)+,d1-d7/a0-a2
		rts
		