
export st_convert

; -------------------------
; | Convert song ST<->STE |
; ------------------------- 
st_convert:
				move.l	A0,D1
				btst		#0,D1
				beq.s		st_conv
				
				eor.b		#0x80,(A0)+
				subq.l	#1,D0

st_conv:
				subq.l	#1,D0
				
				cmp.l		#3,D0
				ble.s		chr_lp
				 
				move.l	D0,D1
				lsr.l		#2,D1
				and.l		#3,D0
				
				subq.l	#1,D1				
long_lp:				
				eor.l		#0x80808080,(A0)+
				subq.l	#1,D1
				bpl.s		long_lp

chr_lp:
				eor.b		#0x80,(A0)+
				subq.l	#1,D0
				bpl.s		chr_lp				
				rts
				