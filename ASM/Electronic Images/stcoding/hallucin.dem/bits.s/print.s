Print_text	MOVE.L log_base(PC),A2
		LEA font_tab-(32*4)(PC),A3
		MOVE.W (A6)+,D1
		MULU #160,D1
		ADDA D1,A2
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADD.W D1,D1
		ADD.W 2(A3,D1),D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #160,D0
.do1line	MOVE.B (A6)+,D1
		BEQ.S .row_done
		CMP.B #1,D1
		BEQ.S .text_done 
		MOVE D0,D2
		AND #15,D2
		LEA font_buf(PC),A0
		EXT.W D1
		ADD.W D1,D1
		ADD.W D1,D1
		ADD.W (A3,D1),A0
		MOVE.W 2(A3,D1),D6
		MOVE D0,D3
		LSR #1,D3
		AND #$FFF8,D3
		LEA (A2,D3),A1
		MOVEQ #19,D3
.linep_lp	MOVEQ #0,D1
		MOVE (A0)+,D1
		ROR.L D2,D1
		OR.W D1,(A1)
		SWAP D1
		OR.W D1,8(A1)
		MOVEQ #0,D1
		MOVE (A0)+,D1
		ROR.L D2,D1
		OR.W D1,8(A1)
		SWAP D1
		OR.W D1,16(A1)
		LEA $28-4(A0),A0
		LEA 160(A1),A1
		DBRA D3,.linep_lp
		ADD D6,D0
		BRA .do1line
.row_done	LEA 27*160(A2),A2
		BRA .row_lp
.text_done	RTS

font_tab	INCBIN D:\HALLUCIN.DEM\LOADER\ENIG1PL.TAB
font_buf	INCBIN D:\HALLUCIN.DEM\LOADER\ENIG1PL.FNT
