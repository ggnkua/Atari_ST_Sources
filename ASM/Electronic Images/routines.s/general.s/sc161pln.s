* MESSAGE SCROLLER By Griff
* (C) OCTOBER 1989

Setup		DC.W $A00A
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
clrscreen	MOVE.L log_base(PC),A0
		MOVE.L A0,D0
		LSR #8,D0
		MOVE.L D0,$FF8200
		MOVEQ #0,D0
		MOVE #3999,D1
clrloop	MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,clrloop

Scroll_mess	MOVE $468,D3
wait_vbl	CMP $468,D3
		BEQ.S wait_vbl
		LEA scr_point(PC),A1
		MOVE.L (A1)+,A0
		MOVE (A1),D5
		TST D5
		BNE.S pos_ok
		ADDQ.L #1,A0
		MOVEQ #16,D5
pos_ok	SUBQ #step,D5
		MOVE D5,(A1)
		MOVE.L A0,-(A1)
		CLR D0
		MOVE.B (A0),D0
		BEQ end			0 = end of mess 
		SUB.B #32,D0
		LSL #5,D0               get character addr
		LEA fontbuf(PC),A1         
		ADDA.W D0,A1            got addr
l_scroll	MOVE.L log_base(PC),A0
		MOVEQ #15,D0
		MOVEQ #step,D4
line_lp	REPT 19
		MOVE.L A0,A3
		ADDQ.L #8,A0
		MOVE.L (A0),D1
		MOVE (A3),D1
		ROL.L D4,D1
		MOVE D1,(A3)
		ENDR
		MOVE (A1)+,D1
		LSR D5,D1
		MOVE (A0),D2
		LSL D4,D2
		OR D1,D2
		MOVE D2,(A0)
		ADDQ.L #8,A0
		DBF D0,line_lp
		BRA Scroll_mess
end		CLR -(SP)
		TRAP #1

step		EQU 4
scr_point	DC.L message
pix_pos	DC.W 16
log_base	DC.L $78000
message	DC.B "HELLO EVERYBODY!!!!!!!!!! ER.... A SCROLLER? PERHAPS??!  ",0
		EVEN
fontbuf	INCBIN STANDARD.FN1
