screen		EQU $F0000			; screen address.

		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; ensure lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		LEA my_stack,SP

set_ints	MOVE #$2700,SR
		bsr flush
		MOVE.B #$12,$FFFFFC02.W		; kill mouse
		LEA old_mfp+32,A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save all vectors
        	MOVE.B $FFFFFA1F.W,(A0)+	; that we change
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
	        MOVE.B #$21,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #$21,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W		; clear em out
		CLR.B $FFFFFA1B.W



; Little demo which scrolls the screen vertically to oblivion!
		
wait_key	CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		bsr flush
		MOVE.B #$8,$FFFFFC02.W
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W	; restore mfp
        	MOVE.B (A0)+,$FFFFFA15.W
	        MOVE.B (A0)+,$FFFFFA19.W
            	MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W		; and vects
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)			; see ya!
		TRAP #1
flush		rts

log_base	DC.L screen
sc_x		DC.W 8
sc_x1		DC.W 0
vbl_timer	DC.W 0

		SECTION BSS

old_mfp		DS.L 30			; saved mfp vects etc
		DS.L 249
my_stack	DS.L 2			; our own stack..

	