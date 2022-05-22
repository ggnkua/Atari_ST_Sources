; Gfa basic relocator.
; lpoke routine+30,address of program to relocate
; call routine

routine		BRA.S Relocator
start_addr	DC.L 0
Relocator	MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE.L start_addr(PC),A0
		MOVE.L 2(A0),D0
		ADD.L $6(A0),D0
		ADD.L $E(A0),D0
		LEA $1C(A0),A0
		MOVE.L A0,A1
		MOVE.L A0,A2
		MOVE.L A0,D1
		ADD.L D0,A1
		MOVE.L (A1)+,D0
		ADD.L D0,A2
		ADD.L D1,(A2)
		MOVEQ #0,D0
rel_lp		MOVE.B (A1)+,D0
		BEQ.S rel_done
		CMP.B #1,D0
		BEQ.S rel_1
		ADD.L D0,A2
		ADD.L D1,(A2)
		BRA.S rel_lp
rel_1		LEA $FE(A2),A2
		BRA.S rel_lp
rel_done	MOVEM.L (SP)+,D0-D7/A0-A6
		RTS
