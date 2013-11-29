
export convert, vol_calc, check_sam
import o_bytes, total

; -------------------------
; | Convert song ST<->STE |
; ------------------------- 
convert:
				move.l	o_bytes,D1
				move.l	D1,A0
				move.l	total,D0
				
				btst		#0,D1
				beq.s		long_conv
				
				subq.l	#1,D0
cv_lp1:	eor.b		#0x80,(A0)+
				subq.l	#1,D0
				bpl.s		cv_lp1
				rts
				
long_conv:
				addq.l	#3,D0
				lsr.l		#2,D0

cv_lp2:	eor.l		#0x80808080,(A0)+
				subq.l	#1,D0
				bpl.s		cv_lp2
				rts
				
; --------------------
; | Calculate volume |
; --------------------
vol_calc:
				LINK		A6,#-256
				move.l	A7,A1
				add.l		#128,A1
				
				move		#127,D1			; Convertiertabelle berechnen
clc_lp:	move  	D1,D2
				muls		D0,D2
				divs		#100,D2
				
				cmpi		#127,D2
				ble.s		no_th
				move		#127,D2
				bra.s		set_v

no_th:	cmpi		#-128,D2
				bge.s		set_v
				move		#-128,D2
set_v:	move.b	D2,(A1,D1)

				subq		#1,D1
				cmpi		#-129,D1
				bne.s		clc_lp

				
				move.l	o_bytes,A0
				move.l	total,D1
				subq.l	#1,D1

vol_lp:	move.b	(A0),D2					; Lautst„rke setzen
				ext.w		D2
				move.b	(A1,D2),D2
        move.b	D2,(A0)+

				subq.l	#1,D1
				bpl.s		vol_lp
				
				UNLK		A6
				rts

; ---------------------
; | Check Sample-type |
; ---------------------
check_sam:
				movem.l	D3-D4,-(SP)
				
				move.l	o_bytes,A0
				move.l	total,D0

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
										