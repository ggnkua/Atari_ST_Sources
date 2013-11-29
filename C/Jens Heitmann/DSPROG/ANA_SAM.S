; Count sample differences with a greater difference than 128
;

export check_sam

; ---------------------
; | Check Sample-type |
; ---------------------
check_sam:
				movem.l	D3-D4,-(SP)

				move.b	(A0)+,D2
				ext.w		D2
				subq.l	#2,D0

				moveq		#0,D1
				
check_lp:
				move.b	(A0)+,D3
				ext.w		D3
				move		D3,D4
				
				sub			D2,D3
				btst		#15,D3
				beq.s		no_neg
				neg			D3
no_neg:	cmpi		#128,D3
				blt.s		no_more
				addq.l	#1,D1
no_more:move		D4,D2
				subq.l	#1,D0
				bpl.s		check_lp
				
				movem.l	(SP)+,D3-D4
				move.l	D1,D0
				rts