; Coo, these are the best dotty waves I have ever seen
; programmed by Griff, of course (who else could do it?!)

		SECTION TEXT

		CLR.W -(SP)
		PEA $FFFFFFFF.W
		PEA $FFFFFFFF.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	

		LEA table1(PC),A0
		BSR doubleit
		LEA table2(PC),A0
		BSR doubleit

; Combine Sinus tables to create x/y co-ords.
; unoptimised as yet...

Calc_points	LEA table1(PC),A1
		LEA 2048(A1),A2
		LEA table2(PC),A3
		LEA 2048(A3),A4
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE #$3ff,D4
		MOVE xapart1(PC),addxapart1+2
		MOVE yapart1(PC),addyapart1+2
		MOVE xapart2(PC),addxapart2+2
		MOVE yapart2(PC),addyapart2+2
		MOVEM.W xy_pos1(PC),D0-D1
		ADD xinc1(pc),D0
		ADD yinc1(pc),D1
		AND D4,D0
		AND D4,D1
		MOVEM D0-D1,xy_pos1
		ADD.W D0,A1
		ADD.W D1,A2
		MOVEM.W xy_pos2(PC),D0-D1
		ADD xinc2(PC),D0
		ADD yinc2(PC),D1
		AND D4,D0
		AND D4,D1
		MOVEM.W D0-D1,xy_pos2
		ADD.W D0,A3
		ADD.W D1,A4
		MOVEQ #4-1,D7
calc_lp	
addxapart1	ADD #0,D5
addyapart1	ADD #0,D6
		AND D4,D5
		AND D4,D6
		MOVE (A1,D5),D0
		MOVE (A2,D6),D1
addxapart2	ADD #0,D2
addyapart2	ADD #0,D3
		AND D4,D2
		AND D4,D3
		ADD.W (A3,D2),D0
		ADD.W (A4,D3),D1
		DBF D7,calc_lp

doubleit	MOVE #511,D2	
doubloop	MOVE.W (A0)+,D0
		MOVE.W 1024-2(A0),D1
		MOVE.W D0,1024-2(A0)
		MOVE.W D1,2048-2(A0)
		MOVE.W D1,3072-2(A0)
		DBF D2,doubloop
		RTS

table1		INCBIN TABLE1.WF
		DS.W 2048
table2		INCBIN TABLE2.WF
		DS.W 2048
databits	
no_dots 	EQU 4
xapart1		DC.W $0
yapart1		DC.W $0
xinc1		DC.W $0
yinc1		DC.W $0
xapart2		DC.W $0
yapart2		DC.W $0
xinc2		DC.W $0
yinc2		DC.W $0
xy_pos1		DS.L no_dots
xy_pos2		DS.L no_dots
