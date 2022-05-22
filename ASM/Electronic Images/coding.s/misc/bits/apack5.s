;------------------------------------------------------------------------
;   Guazzo Coding Implementation  
;
; 
;     Copyright Feb. 1993
;              
;     Gordon V. Cormack  Feb. 1993
;     University of Waterloo
;     cormack@uwaterloo.ca
;
;     All rights reserved.
; 
;     The algorithms herein are the property of Gordon V. Cormack.
; 
;     68000 Code implementation by Martin Griffiths July 1993.
;------------------------------------------------------------------------
; At the moment the major speed problem is with the 64bit divide
; New 64bit divide now is 4* faster -> 1-1500 cycles
; But not much hope of getting it much faster.
; on an 030 this divide takes about 70!!!!
; Packs/Depacks about 800bytes per second (at 16mhz)

letsgo		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

.pack		LEA data+34,A0
		LEA data+34+(200*160),A1
		LEA packed_data,A2
		BSR arith_pack
		MOVE.L inbytes(PC),D0
		MOVE.L outbytes(PC),D1

.depack		MOVE.W #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A1
		LEA packed_data,A0
		BSR arith_depack
		MOVE.W #1,-(SP)
		TRAP #1
		ADDQ.L #2,SP

		CLR -(SP)
		TRAP #1

;------------------------------------------------------------------------
; Pack.
; A0 -> data to pack.  A1 -> end of data
; A2 -> destination space for packed data.
;------------------------------------------------------------------------

arith_pack	MOVEM.L A0/A2,-(SP)
		BSR init_vars
pack_lp		MOVEQ #0,D0
		MOVE.B (A0)+,D0		; c
		MOVE.B D0,D6		; duplicate c
		LEA index_tab(PC),A5

		MOVEQ #8,D7
i_lp		MOVE.W (A5)+,D1		; index = (1<<i)-1
		MOVE.W D0,D2
		LSR.W D7,D2		; c >> (8-i)
		ADD.W D2,D1		;          + (c >> (8-i))

		MOVE.W D1,-(SP)
		MOVE.L max(PC),D2	; max
		MOVE.L min(PC),D3
		SUB.L D3,D2		; max-min
		SUBQ.L #1,D2		; (max-min-1)
		MOVE.L (A4,D1.W*4),D3	;  one[index]
		MOVE.L (A3,D1.W*4),D1	; zero[index]
		ADD.L D1,D3		; zero[index] + one[index]
		MULS.L	D1,D1:D2	; D1D2 = D1.L*D2.L
		DIVS.L	D3,D1:D2	; d1D2 / D3
		ADD.L min(PC),D2
		MOVE.W (SP)+,D1

		CMP.L min(PC),D2	; (min == mid) ?
		BNE.S .noincmid
		ADDQ.L #1,D2		; mid ++
.noincmid	MOVE.L max(PC),D3	
		SUBQ.L #1,D3		; max - 1
		CMP.L D2,D3		; mid == (max-1)?
		BNE.S .notdecmid
		SUBQ.L #1,D2		; mid --
.notdecmid	ADD.B D6,D6
		BCC.S .cse2
.cse1		MOVE.L D2,min		; min = mid
		ADDQ.L #1,(A4,D1.W*4)	; one[index]++
		BRA.S .cseend
.cse2		MOVE.L D2,max		; max = mid
		ADDQ.L #1,(A3,D1.W*4)	; zero[index]++
.cseend		MOVE.L D2,mid

.while		MOVE.L max(PC),D2
		SUB.L min(PC),D2	; (max-min)
		CMP.L #256,D2		
		BHS.S .endwhile		;
		SUBQ.L #1,max
		MOVE.L min(PC),D2
		SWAP D2
		MOVE.B D2,(A2)+
		SWAP D2
		LSL.L #8,D2
		AND.L #$FFFF00,D2
		MOVE.L D2,min
		MOVE.L max(PC),D3
		LSL.L #8,D3
		AND.L #$FFFF00,D3

		CMP.L D3,D2
		BLO.S .ok
		MOVE.L #$1000000,D3
.ok		
		MOVE.L D3,max
		BRA.S .while
.endwhile
		SUBQ #1,D7
		BNE i_lp

		CMP.L A1,A0
		BNE pack_lp
		MOVE.L max(PC),D0
		SUBQ.L #1,D0
		MOVE.L D0,min		; min = max-1
		SWAP D0
		MOVE.B D0,(A2)+
		ROL.L #8,D0
		MOVE.B D0,(A2)+
		ROL.L #8,D0
		MOVE.B D0,(A2)+
		MOVEM.L (SP)+,A1/A3
		SUB.L A1,A0
		SUB.L A3,A2
		MOVE.L A0,inbytes
		MOVE.L A2,outbytes
		
		RTS

;------------------------------------------------------------------------
; Depack
; A0 -> data to depack
; A1 -> destination for depacked data
;------------------------------------------------------------------------

arith_depack	MOVEM.L A0/A1,-(SP)
		BSR init_vars
		MOVEQ #0,D0
		MOVE.B (A0)+,D0
		LSL.L #8,D0
		MOVE.B (A0)+,D0
		LSL.L #8,D0
		MOVE.B (A0)+,D0
		MOVE.L D0,val
		BRA cont_depack
depack_lp	MOVEQ #0,D0		; c=0
		LEA index_tab(PC),A5
		MOVEQ #7,D7
.i_lp		MOVE.W (A5)+,D1		; index = (1<<i)-1
		ADD.W D0,D1		;          + c 
		MOVE.W D1,-(SP)
		MOVE.L max(PC),D2	; max
		MOVE.L min(PC),D3
		SUB.L D3,D2		; max-min
		SUBQ.L #1,D2		; (max-min-1)
		MOVE.L (A4,D1.W*4),D3	;  one[index]
		MOVE.L (A3,D1.W*4),D1	; zero[index]
		ADD.L D1,D3		; zero[index] + one[index]
		MULS.L	D1,D1:D2	; D1D2 = D1.L*D2.L
		DIVS.L	D3,D1:D2	; d1D2 / D3
		ADD.L min(PC),D2
		MOVE.W (SP)+,D1
		CMP.L min(PC),D2	; (min == mid) ?
		BNE.S .noincmid
		ADDQ.L #1,D2		; mid ++
.noincmid	MOVE.L max(PC),D3	
		SUBQ.L #1,D3		; max - 1
		CMP.L D2,D3		; mid == (max-1)?
		BNE.S .notdecmid
		SUBQ.L #1,D2		; mid --
.notdecmid	CMP.L val(PC),D2
		BHI.S .cse2
.cse1		MOVEQ #1,D3		; bit =1
		MOVE.L D2,min		; min = mid
		ADDQ.L #1,(A4,D1.W*4)	; one[index]++
		BRA.S .cseend
.cse2		MOVEQ #0,D3		; bit =0
		MOVE.L D2,max		; max = mid
		ADDQ.L #1,(A3,D1.W*4)	; zero[index]++
.cseend		MOVE.L D2,mid
		ADD.B D0,D0		; c = c+c
		ADD.B D3,D0		;        +bit
.while		MOVE.L max(PC),D2
		SUB.L min(PC),D2	; (max-min)
		CMP.L #256,D2		
		BHS.S .endwhile		;
		SUBQ.L #1,max
		MOVE.L val(PC),D2
		LSL.L #8,D2
		AND.L #$FFFF00,D2
		MOVE.B (A0)+,D2
		MOVE.L D2,val
		MOVE.L min(PC),D2
		LSL.L #8,D2
		AND.L #$FFFF00,D2
		MOVE.L D2,min
		MOVE.L max(PC),D3
		LSL.L #8,D3
		AND.L #$FFFF00,D3
		CMP.L D3,D2
		BLO.S .ok
		MOVE.L #$1000000,D3
.ok		MOVE.L D3,max
		BRA.S .while
.endwhile	DBF D7,.i_lp
		MOVE.B D0,(A1)+
cont_depack	MOVE.L max(PC),D3
		SUBQ.L #1,D3		; (max-1)
		CMP.L val(PC),D3	; val==(max-1)
		BNE depack_lp
		MOVEM.L (SP)+,A2/A3
		SUB.L A2,A0
		SUB.L A3,A1
		MOVE.L A0,inbytes
		MOVE.L A1,outbytes
		RTS

; Initialise variables/tables

init_vars	CLR.L min
		CLR.L mid
		MOVE.L #$1000000,max
		LEA zero(PC),A3
		LEA one(PC),A4
		MOVE.L A3,A5
		MOVE.L A4,A6
		MOVEQ #1,D1
		MOVE.W #256-1,D0
.lp		MOVE.L D1,(A5)+
		MOVE.L D1,(A6)+
		DBF D0,.lp
		RTS

val		DC.L 0
min		DC.L 0
mid		DC.L 0
max		DC.L 0
zero		DS.L 256
one		DS.L 256
inbytes		DC.L 0
outbytes	DC.L 0
index_tab	DC.W 0,1,3,7,15,31,63,127

data		INCBIN NEOPIC_M.PI2
enddata
packed_data