		BRA Test

* Routine to draw a line.
* A1 points to two co-ords.D7 col.
* D0-D6/A0/A2-A5 smashed.		

Draw_Line	MOVE.L log_base(PC),A0	screen base
		LEA Col_vect(PC),A5	colour vector
		ADD D7,D7
		ADDA D7,A5
		ADDA (A5),A5
		MOVE.L (A5)+,A3
		MOVE.L (A5)+,A4
		MOVE.L (A1),D0
		CMP 6(A1),D0
		BEQ Horiz_case
		BLT.S coord_ok
		MOVE.L 4(A1),(A1)
		MOVE.L D0,4(A1)
coord_ok	MOVE 2(A1),D1
		MOVE D1,D2
		LSL #2,D1
		ADD D2,D1
		LSL #5,D1
		ADDA D1,A0
Gradient	MOVEQ #0,D5
		MOVE 4(A1),D5
		SUB (A1),D5
		BEQ.S Vert_case
		MOVE 6(A1),D4
		SUB 2(A1),D4
		MOVE D4,D6
		ADDQ #1,D4
		TST D5
		BMI.S neg_grad
		ADDQ #1,D5
accrt_div1	MOVE.L D5,D0
		DIVU D4,D0
		MOVE D0,D5
		SWAP D5
		CLR D0
		DIVU D4,D0
		MOVE D0,D5		
		MOVE.L (A1),D4
		CLR D4
		BRA.S next_line
neg_grad	NEG D5
		ADDQ #1,D5
accrt_div2	MOVE.L D5,D0
		DIVU D4,D0
		MOVE D0,D5
		SWAP D5
		CLR D0
		DIVU D4,D0
		MOVE D0,D5		
		NEG.L D5
* Draw a normal sloped line.
		MOVE.L (A1),D4
		CLR D4
		BRA.S next_line
line_lp	MOVE.L D4,D0
		SWAP D0
		ADD.L D5,D4
		MOVE.L D4,D1
		SWAP D1
		BSR.S Hline
		LEA 160(A0),A0
next_line	DBRA D6,line_lp
		SWAP D4
		MOVE D4,D0
		MOVE 4(A1),D1
		BRA.S Hline

* Vertical line case.

Vert_case	MOVEM 2(A1),D0/D1/D6
		LEA v_write(PC),A2
		MOVE.L (A5)+,(A2)+
		MOVE.L (A5),(A2)
		SUB D0,D6
		MOVE D1,D0
		LSR #1,D0
		AND #$FFF8,D0
		LEA 0(A0,D0),A2
		AND #$F,D1
		MOVE #$8000,D3
		LSR D1,D3
		MOVE D3,D2
		NOT D3
v_write	DS.W 4
		LEA 152(A2),A2
		DBRA D6,v_write
		RTS

* Horizontal line case.

Horiz_case	MOVE D0,D1
		LSL #2,D0
		ADD D1,D0
		LSL #5,D0
		ADDA D0,A0
		MOVE (A1),D0
		MOVE 4(A1),D1
Hline		CMP D0,D1
		BGE.S order_ok
		EXG D0,D1
order_ok	SUB D0,D1
		MOVE D0,D2
		LSR #1,D2
		AND #$FFF8,D2
		LEA 0(A0,D2),A2
		AND #$F,D0
		MOVEQ #-1,D2
		LSR D0,D2
		ADD D1,D0
		SUB #16,D0
		BPL.S multi_chunk
		NOT D0
		MOVEQ #-1,D1
		LSL D0,D1
		AND D1,D2
		MOVE D2,D3
		NOT D3
write_1	JMP (A5)
multi_chunk	MOVE D2,D3
		NOT D3
write_2	JSR (A5)
		ADDQ #1,D0
		MOVE D0,D1
		LSR #2,D0
		BEQ.S miss_main
		AND.B #%11111100,D0
		NEG D0
		JMP miss_main(PC,D0)

chunks_20	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+		
chunks_19	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_18	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_17	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_16	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_15	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_14	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_13	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_12	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_11	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_10	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_9	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_8	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_7	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_6	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_5	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_4	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_3	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_2	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
chunks_1	MOVE.L A3,(A2)+
		MOVE.L A4,(A2)+
miss_main	MOVEQ #-1,D2
		LSR D1,D2
		MOVE D2,D3
		NOT D2
write_3	JMP (A5)

* Specific colour routines.

Col_vect	DC.W col0-*
		DC.W col1-*
		DC.W col2-*
		DC.W col3-*
		DC.W col4-*
		DC.W col5-*
		DC.W col6-*
		DC.W col7-*
		DC.W col8-*
		DC.W col9-*
		DC.W col10-*
		DC.W col11-*
		DC.W col12-*
		DC.W col13-*
		DC.W col14-*
		DC.W col15-*
		
col0		DC.L $00000000,$00000000
		AND D3,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		RTS
col1		DC.L $FFFF0000,$00000000
		OR D2,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		RTS
col2		DC.L $0000FFFF,$00000000
		AND D3,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		RTS
col3		DC.L $FFFFFFFF,$00000000
		OR D2,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		RTS
col4		DC.L $00000000,$FFFF0000
		AND D3,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		RTS
col5		DC.L $FFFF0000,$FFFF0000
		OR D2,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		RTS
col6		DC.L $0000FFFF,$FFFF0000
		AND D3,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		RTS
col7		DC.L $FFFFFFFF,$FFFF0000
		OR D2,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		RTS
col8		DC.L $00000000,$0000FFFF
		AND D3,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		RTS
col9	 	DC.L $FFFF0000,$0000FFFF
		OR D2,(A2)+
		AND D3,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		RTS
col10		DC.L $0000FFFF,$0000FFFF
		AND D3,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		RTS
col11		DC.L $FFFFFFFF,$0000FFFF
		OR D2,(A2)+
		OR D2,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		RTS
col12		DC.L $00000000,$FFFFFFFF
		AND D3,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		RTS
col13		DC.L $FFFF0000,$FFFFFFFF
		OR D2,(A2)+
		AND D3,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		RTS
col14		DC.L $0000FFFF,$FFFFFFFF
		AND D3,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		RTS
col15		DC.L $FFFFFFFF,$FFFFFFFF
		OR D2,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		OR D2,(A2)+
		RTS

log_base	DS.L 1

Test		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		LEA log_base(PC),A0
		MOVE.L D0,(A0)
		LEA tst_coords(PC),A1
lp		MOVEQ #15,D7
		BSR Draw_Line
		ADDQ #1,(A1)
		ADDQ #1,4(A1)
		CMP #320,4(A1)
		BNE.S lp
		MOVE #1,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		CLR -(SP)
		TRAP #1

tst_coords	DC.W 0,0,0,199