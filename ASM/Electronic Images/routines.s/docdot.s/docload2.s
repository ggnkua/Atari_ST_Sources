; Coo, these are the best dotty waves I have ever seen
; programmed by Griff, of course (who else could do it?!)

table1		EQU $300000

		SECTION TEXT

		CLR.W -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	

letsgo		LEA stack,SP
		MOVE.L log_base(pc),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		
		BSR movetable

		MOVE.L #$00000777,$FFFF8240.W
		MOVE.W #$777,$FFFF8248.W
		BSR init_ints

; Main program loop

vbl_lp		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		not $ffff8240.w
		MOVE vbl_timer(PC),D7
wait_vb1	CMP vbl_timer(PC),D7
		BEQ.S wait_vb1
		not $ffff8240.w
		BSR clear_old
		BSR Calc_points	

test_key	BTST.B #0,$FFFFFC00.W
		BEQ vbl_lp
		MOVE.B $FFFFFC02.W,D0
nores		CMP.B #$39,D0
		BNE vbl_lp

		BSR rest_ints
		CLR -(SP)
		TRAP #1

init_ints	MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
		RTS

; Restore mfp/vbl etc

rest_ints	MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE #$2300,SR
		RTS
old_mfp		DS.L 5

; Our very own VBL interrupt

my_vbl		ADDQ #1,vbl_timer
		RTE

movetable	LEA table1a,A0
		LEA table1,A1
		MOVE.W #65536/4-1,D0
.lp		MOVE.L (A0)+,(A1)+
		DBF D0,.lp	
		RTS


log_base	DC.L $170300
phy_base	DC.L $178000
switch		DS.W 1
vbl_timer	DS.W 1

clear_old	MOVE.L log_base(PC),A0
		MOVEQ #0,D1
		NOT switch
		BEQ clear_em2
clear_em1	REPT 2000
		MOVE.W D1,0(A0)
		ENDR
		RTS
clear_em2	REPT 2000
		MOVE.W D1,0(A0)
		ENDR
		RTS

; Combine Sinus tables to create x/y co-ords.
; unoptimised as yet...
tablex		DC.W 0,0
Calc_points	LEA table1a,A1
		MOVEQ #0,D3
		MOVEM.W tablex(pc),d3
		ADDQ #4,D3
		MOVEM.W D3,tablex
		MOVE #4*666,D2
		MOVE.L log_base(PC),A6
		LEA clear_em1(PC),A0
		TST switch
		BNE.S not1
		LEA clear_em2(PC),A0
not1	
i		SET 2
		REPT 2000
		ADD.W D2,D3
		MOVEM.W (A1,D3.L),D0/D1
		OR.W D1,(A6,D0)
		MOVE.W D0,i(A0)
i		SET i+4
		ENDR
		RTS

		SECTION DATA

table1a		INCBIN D:\ROUTINES.S\DOCDOT.S\BIGSIN.DAT

		SECTION BSS

		DS.L 199
stack		DS.L 1
