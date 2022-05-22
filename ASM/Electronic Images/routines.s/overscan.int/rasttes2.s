;-----------------------------------------------------------------------;
; Interrupt Overscan Routine.(uses approx 46% of the cpu time)!		;
; By Martin Griffiths(Griff of Electronic Images.)				;
;-----------------------------------------------------------------------;

		CLR -(SP)
		PEA $70000
		MOVE.L (SP),-(SP)
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

Start		MOVE #$2700,SR
		LEA my_stack(PC),SP
		MOVE.L #$00000777,$FFFF8240.W
		MOVE.L #$07770777,$FFFF8244.W
		MOVE.L #$07770777,$FFFF8248.W
		MOVE.L #$07770777,$FFFF824C.W
		MOVE.L #$07770777,$FFFF8250.W
		MOVE.L #$07770777,$FFFF8254.W
		MOVE.L #$07770777,$FFFF8258.W
		MOVE.L #$07770345,$FFFF825C.W
setup		LEA $70000,A0
		MOVE #3999,D0
		MOVEQ #-1,D1
clrsc_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clrsc_lp
interrupts	LEA.L old_stuff(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
            MOVE.B $FFFFFA09.W,(A0)+
            MOVE.B $FFFFFA13.W,(A0)+
            MOVE.B $FFFFFA15.W,(A0)+
            MOVE.B $FFFFFA17.W,(A0)+
            MOVE.B $FFFFFA19.W,(A0)+
            MOVE.B $FFFFFA1B.W,(A0)+
            MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
            MOVE.B #1,$FFFFFA07.W
            CLR.B	$FFFFFA09.W
            MOVE.B #1,$FFFFFA13.W
            CLR.B	$FFFFFA15.W
            CLR.B	$FFFFFA21.W
            CLR.B	$FFFFFA1B.W
		BCLR.B #3,$FFFFFA17.W
vbl_on	MOVE.L #vbl,$70.W
		MOVE #$2300,SR

vblp		BTST.B #0,$FFFFFC00.W
		BEQ.S vblp
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE.S vblp

restore	MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
            MOVE.B (A0)+,$FFFFFA09.W
            MOVE.B (A0)+,$FFFFFA13.W
            MOVE.B (A0)+,$FFFFFA15.W
            MOVE.B (A0)+,$FFFFFA17.W
            MOVE.B (A0)+,$FFFFFA19.W
            MOVE.B (A0)+,$FFFFFA1B.W
            MOVE.B (A0)+,$FFFFFA21.W
            MOVE.L (A0)+,$68.W
            MOVE.L (A0)+,$70.W
            MOVE.L (A0)+,$120.W
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

; Routine to print an unsigned word in decimal - D0.L

num_print	MOVE.L log_base(PC),A0
		DIVU #10000,D0
		BSR.S	digi_prin
		ADDQ.L #1,A0
		CLR D0		
		SWAP D0		
		DIVU #1000,D0 	
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0
		SWAP D0
		DIVU #100,D0 
		BSR.S	digi_prin
		ADDQ.L #1,A0
		CLR D0	
		SWAP D0	
		DIVU #10,D0
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0	
		SWAP D0

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

font_data	DC.B $7C,$C6,$C6,$00,$C6,$C6,$7C,$00
		DC.B $18,$18,$18,$00,$18,$18,$18,$00
		DC.B $7C,$06,$06,$7C,$C0,$C0,$7C,$00
		DC.B $7C,$06,$06,$7C,$06,$06,$7C,$00
		DC.B $C6,$C6,$C6,$7C,$06,$06,$06,$00
		DC.B $7C,$C0,$C0,$7C,$06,$06,$7C,$00
		DC.B $7C,$C0,$C0,$7C,$C6,$C6,$7C,$00
		DC.B $7C,$06,$06,$00,$06,$06,$06,$00
		DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00
		DC.B $7C,$C6,$C6,$7C,$06,$06,$7C,$00
log_base	DC.L $70000+(16000)

vbl		MOVE.B #0,$FFFFFA1B.W
		MOVE.B #186,$FFFFFA21.W
            MOVE.L #phbl,$120.W
		MOVE.B #4,$FFFFFA1B.W
		MOVE.L #hblstart,$68.W
		ADDQ #1,vbl_timer
		MOVEM.L D0-D1/A0-A1,-(SP)
		MOVEQ #0,D0
		MOVE lowest(PC),D0
		CMP number(PC),D0
		BLO.S notlow
		MOVE number(PC),lowest
notlow	;bsr num_print
		MOVEM.L (SP)+,D0-D1/A0-A1
		RTE

number	DC.W 65535
lowest	DC.W 65535

phbl		CLR.B $FFFFFA1B.W
		MOVE #$2100,SR
		STOP #$2100
            MOVE.L #startb,$120.W
		MOVE.B #80,$FFFFFA21.W
		MOVE.B #1,$FFFFFA1B.W
hblstart	RTE

intover	MACRO
		MOVE.L A0,USP
		MOVE.W D7,-(SP)
		MOVE #$8207,A0
		MOVEP.W (A0),d7
		SUB #j+34,D7
		NEG D7
		LSR D7,D7
		CLR D7
		MOVE.B d7,$FFFFFA1B.W
		move #$820a,a0
		move.b d7,(a0)
		move.b #2,(a0)
		MOVE.B #19,$FFFFFA21.W
		MOVE.B #1,$FFFFFA1B.W
		move.b #1,$ffff8260.w
		move.b #0,$ffff8260.w
		move.l #endint\@,$120.w
		MOVE.L USP,A0
		MOVE.W (SP)+,D7
		move.b #2,$ffff8260.w
		move.b #0,$ffff8260.w
		RTE
endint\@	
		ENDM

j		SET 94

startb
		REPT 199
		intover
j		SET j+230
		ENDR
		clr.b $fffffa1b.w
		rte

		SECTION BSS

vbl_timer	DS.W 1
old_stuff	DS.L 9
		DS.L 199
my_stack	DS.W 1
		
