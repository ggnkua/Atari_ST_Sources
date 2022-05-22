Tester	MOVE #3,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,log_base		
		MOVE.L #60000,D0
tst_lp	MOVE.L D0,D7
		BSR.S num_print
		MOVE.L D7,D0
		DBF D0,tst_lp
		CLR -(SP)
		TRAP #1

* Routine to print an unsigned word
* in decimal.D0.L contains the no.
* to be printed.
* D0-D1/A0-A1 smashed!

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
log_base	DS.L 1