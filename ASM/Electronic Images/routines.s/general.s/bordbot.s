* BOTTOM BORDER GET RIDDER.
* By Martin Griffiths (C) AUG 1989
* Using timer A for top border.
* updated MARCH 1990 - bottom bord made STE compatable.
		
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.B $FFFF8260.W
		MOVE #$2700,SR
		LEA stack(PC),SP
		MOVE.L log_base(PC),A0
		MOVE.L A0,D2
		MOVE #11999,D0
		MOVEQ #-1,D1
b_lp		MOVE.L D1,(A0)+
		DBF D0,b_lp
set_scrn	LSR #8,D2
		MOVE.L D2,$FFFF8200.W

interrupts	LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA19.W
		MOVE.B #$1,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #$1,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #hbl_1,$120.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR

wait_key	btst #0,$fffffc00.w
		beq.s wait_key
		move.b $fffffc02.w,d0
		cmp.b #$39,d0
		bne.s wait_key

restore	MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1
		
my_vbl	CLR.B $FFFFFA1B.W
		MOVE.B #199,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L D0-A6,-(SP)
		MOVEQ #0,D0
		MOVE.W here(PC),D0
		BSR num_print
		MOVEM.L (SP)+,D0-A6
		ADDQ #1,vbl_timer
		RTE
; 96 
hbl_1		MOVEM.L D0/A0,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D0
.syncb	CMP.B (A0),D0
		BEQ.S .syncb
		MOVE.B (A0),D0
		JMP noplist-96(PC,D0) 
noplist	DCB.W 91,$4E71 
		MOVE.B #0,$FF820A
		DCB.W 12,$4E71
		MOVE.B #2,$FF820A
		MOVEM.L (SP)+,D0/A0
		RTE
here		DC.W 0

* Routine to print an unsigned word in decimal - D0.L

num_print	MOVE.L log_base(PC),A0
		DIVU #10000,D0	   	no. of 10,000s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0			prepare for divide
		SWAP D0			look at remainder
		DIVU #1000,D0 	   	no. of 1,000s
		BSR.S	digi_prin
		ADDQ.L #7,A0		next screen column
		CLR D0			prepare for divide
		SWAP D0			look at remainder
		DIVU #100,D0 	    	number of 100s
		BSR.S	digi_prin
		ADDQ.L #1,A0		next screen column
		CLR D0			prepare for divide
		SWAP D0			look at remainder
		DIVU #10,D0			number of 10s
		BSR.S	digi_prin
		ADDQ.L #7,A0		next screen column
		CLR D0	 		prepare for divide
		SWAP D0			always print units

* Print a single digit at A0
* D1/A1 smashed.

digi_prin	MOVE D0,D1
		LSL #3,D1
		LEA font_data(PC,D1),A1
		MOVE.B (A1)+,(A0)		
		MOVE.B (A1)+,160(A0)
		MOVE.B (A1)+,320(A0)
		MOVE.B (A1)+,480(A0)
		MOVE.B (A1)+,640(A0)
		MOVE.B (A1)+,800(A0)
		MOVE.B (A1)+,960(A0)
		MOVE.B (A1)+,1120(A0)
		RTS

font_data	DC.B $7C,$C6,$C6,$00,$C6,$C6,$7C,$00	"O"
		DC.B $18,$18,$18,$00,$18,$18,$18,$00	"1"
		DC.B $7C,$06,$06,$7C,$C0,$C0,$7C,$00	"2"
		DC.B $7C,$06,$06,$7C,$06,$06,$7C,$00	"3"
		DC.B $C6,$C6,$C6,$7C,$06,$06,$06,$00	"4"
		DC.B $7C,$C0,$C0,$7C,$06,$06,$7C,$00	"5"
		DC.B $7C,$C0,$C0,$7C,$C6,$C6,$7C,$00	"6"
		DC.B $7C,$06,$06,$00,$06,$06,$06,$00	"7"
		DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	"8"
		DC.B $7C,$C6,$C6,$7C,$06,$06,$7C,$00	"9"
log_base	DC.L $70300
vbl_timer	DS.W 1
		SECTION BSS
old_mfp	DS.L 7
		DS.L 149
stack		DS.L 1
