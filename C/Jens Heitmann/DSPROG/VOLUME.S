
; extern vol_calc(char *o_bytes, long len, int vol)
;                 					 a0, 			 d0,  d1

export vol_calc

; --------------------
; | Calculate volume |
; --------------------
vol_calc:
				LINK		A6,#-256
				move.l	A7,A1
				
				move.l	D0,-(SP)
				
				move		#255,D0			; Convertiertabelle berechnen
clc_lp:	move  	D0,D2
				ext.w		D2
				muls		D1,D2
				divs		#100,D2
				
				cmpi		#127,D2
				ble.s		no_th
				move		#127,D2
				bra.s		set_v

no_th:	cmpi		#-128,D2
				bge.s		set_v
				move		#-128,D2
set_v:	move.b	D2,(A1,D0)
				
				subq		#1,D0
				bpl.s		clc_lp

				move.l	(SP)+,D0

				moveq		#0,D2				
				subq.l	#1,D0
vol_lp:	move.b	(A0),D2					; Lautst„rke setzen
				move.b	(A1,D2),D2
        move.b	D2,(A0)+

				subq.l	#1,D0
				bpl.s		vol_lp
				
				UNLK		A6
				rts

										