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
;     68000 Code implementation by Martin Griffiths July 1993.
;------------------------------------------------------------------------

		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		LEA data+34,A0
		LEA data+34+(200*160),A1
		LEA packed_data,A2
		BSR arith_pack
		MOVE.L inbytes(PC),D0
		MOVE.L outbytes(PC),D1
		MOVE.W #2,-(SP)
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

arith_pack	CLR.L inbytes
		MOVE.L #3,outbytes
		BSR init_vars
pack_lp		MOVEQ #0,D0
		MOVE.B (A0)+,D0		; c
		MOVE.B D0,D6		; duplicate c
		ADDQ.L #1,inbytes
		LEA index_tab(PC),A5

		MOVEQ #8,D7
i_lp		MOVE.W (A5)+,D1		; index = (1<<i)-1
		MOVE.W D0,D2
		LSR.W D7,D2		; c >> (8-i)
		ADD.W D2,D1		;          + (c >> (8-i))

		ADD.W D1,D1
		ADD.W D1,D1		; *4 for index 

		MOVEM.W D0/D1/D6/D7,-(SP)
		MOVE.L max(PC),D2	; max
		MOVE.L min(PC),D3
		SUB.L D3,D2		; max-min
		SUBQ.L #1,D2		; (max-min-1)
		MOVE.L (A4,D1.W),D5	;  one[index]
		MOVE.L (A3,D1.W),D1	; zero[index]
		ADD.L D1,D5		; zero[index] + one[index]
		BSR mul32		; D6D7 = D1.L*D2.L
		MOVE.L D7,D1
		MOVE.L D6,D2
		MOVE.L D5,D3
		BSR div64		; d6D7 / D5
		MOVE.L D1,D2
		ADD.L min(PC),D2
		MOVEM.W (SP)+,D0/D1/D6/D7

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
		ADDQ.L #1,(A4,D1.W)	; one[index]++
		BRA.S .cseend
.cse2		MOVE.L D2,max		; max = mid
		ADDQ.L #1,(A3,D1.W)	; zero[index]++
.cseend		MOVE.L D2,mid

.while		MOVE.L max(PC),D2
		SUB.L min(PC),D2	; (max-min)
		CMP.L #256,D2		
		BHS.S .endwhile		;
		SUBQ.L #1,max
		MOVE.L min(PC),D2
		SWAP D2
		MOVE.B D2,(A2)+
		ADDQ.L #1,outbytes
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
		MOVE.B min+1(PC),(A2)+
		MOVE.B min+2(PC),(A2)+
		MOVE.B min+3(PC),(A2)+
		
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
		ADD.W D1,D1
		ADD.W D1,D1		; *4 for index 
		MOVEM.W D0/D1/D7,-(SP)
		MOVE.L max(PC),D2	; max
		MOVE.L min(PC),D3
		SUB.L D3,D2		; max-min
		SUBQ.L #1,D2		; (max-min-1)
		MOVE.L (A4,D1.W),D5	;  one[index]
		MOVE.L (A3,D1.W),D1	; zero[index]
		ADD.L D1,D5		; zero[index] + one[index]
		BSR mul32		; D6D7 = D1.L*D2.L
		MOVE.L D7,D1
		MOVE.L D6,D2
		MOVE.L D5,D3
		BSR div64		; d6D7 / D5
		MOVE.L D1,D2
		ADD.L min(PC),D2
		MOVEM.W (SP)+,D0/D1/D7
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
		ADDQ.L #1,(A4,D1.W)	; one[index]++
		BRA.S .cseend
.cse2		MOVEQ #0,D3		; bit =0
		MOVE.L D2,max		; max = mid
		ADDQ.L #1,(A3,D1.W)	; zero[index]++
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

; Unsigned 32 bit multiply.  <500 cycles MAX.  
; Multiply D1 by D2; 64-bit result in D6 & D7.  D6 is MSL and D7 LSL.
; Returns with most significant in D6 and least significant in D7.
; By Ben Griffin 

mul32		move.l	d1,d3
		move.l	d2,d4
		swap	d3
		swap	d4
		move.w	d1,d7
		mulu	d2,d7
		move.w	d3,d6
		mulu	d4,d6
		mulu	d1,d4
		mulu	d2,d3
		add.l	d3,d4
		move.w	d4,d3
		swap	d3
		clr.w	d3
		clr.w	d4
		addx.w	d3,d4
		swap	d4
		add.l	d3,d7
		addx.l	d4,d6
		rts

; 64 bit unsigned division routine
; d2.l:d1.l / d3.l
; d2.l:d1.l - Quotient d6:d5 - Remainder.
; By Martin Griffiths

Div64	  	moveq #0,d4    	; d4:d3
		moveq #0,d6
		moveq #0,d5    	; d6:d5 Rem.
		moveq #63,d0   	; counter
		add.l d1,d1    	; d2:d1 Quot.
		addx.l d2,d2
.div_lp		addx.l d5,d5
		addx.l d6,d6
		sub.l d3,d5
		subx.l d4,d6
		bcc.s .div
		add.l d3,d5
		addx.l d4,d6
.div		eori #$10,ccr
		addx.l d1,d1
		addx.l d2,d2
		dbf d0,.div_lp
		rts

data		INCBIN C:\NEODESK3\NEOPIC_M.PI2
enddata
packed_data
