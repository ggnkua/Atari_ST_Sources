* Full overscan rout.
* Original version by Griff Nov 1989.
* NOW STE(!!) Compatible!
* Final update: Sept 1990 -  tweeked a bit!!

Full_scrn	CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #$2700,SR
		LEA my_stack,SP
		MOVE #$8240,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		MOVE.L #$180000,D5
		MOVE.L D5,A1
set_scrn	LSR #8,D5
		MOVE.L D5,$FFFF8200.W
Copy_pic	LEA pic+34,A0
		LEA 160(A1),A1
		MOVE #269,D1
cpy_lp1		MOVEQ #39,D0
cpy_lp2		MOVE.L (A0),(A1)+
		MOVE.L (A0)+,156(A1)
		DBF D0,cpy_lp2 
		CMP #70,D1
		BNE.S nl
		LEA pic+34,A0
nl		LEA 70(A1),A1
		DBF D1,cpy_lp1 
set_ints	JSR flush
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
	        MOVE.B $FFFFFA15.W,(A0)+
        	MOVE.B $FFFFFA19.W,(A0)+
	        MOVE.B $FFFFFA1F.W,(A0)+
        	MOVE.B #$20,$FFFFFA07.W
	        MOVE.B #0,$FFFFFA09.W
	        MOVE.B #$20,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L $68.W,old_phbl
		MOVE.L $70.W,old_vbl
		MOVE.L $134.W,old_tmra
		MOVE.L #overscan,$134.W
		MOVE.L #first_vbl,$70.W
		MOVE.L #phbl,$68.W
		STOP #$2300

wait_key	CMP.B #$39,$FFFFFC02.W
		BNE.S wait_key

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		JSR flush
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W
	        MOVE.B (A0)+,$FFFFFA15.W
        	MOVE.B (A0)+,$FFFFFA19.W
	        MOVE.B (A0)+,$FFFFFA1F.W
		BSET.B #3,$FFFFFA17.W
		MOVE.L old_phbl,$68.W 
		MOVE.L old_vbl,$70.W
		MOVE.L old_tmra,$134.W 
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

vbl_timer	DS.W 1
old_vbl		DS.L 1
old_tmra	DS.L 1
old_phbl	DS.L 1
old_mfp		DS.L 4

* The Full Overscan routine!

first_vbl	MOVE.L #vbl,$70.W
		ADDQ #1,vbl_timer
		RTE
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		MOVE.L #overscan,$134.W
		ADDQ #1,vbl_timer
		MOVEM.L D0-D7,-(SP) 
		MOVEM.L pic+2,D0-D7
		MOVEM.L D0-D7,$ffff8240.w
		MOVEM.L (SP)+,D0-D7
		RTE


overscan	MOVE #$2100,SR			top border synchronisation
		STOP #$2100				
		MOVEM.L D0-D7/A0-A1,-(SP)
		MOVE #$2700,SR
		CLR.B $FFFFFA19.W
		DCB.W 59,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 16,$4E71
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
syncloop	MOVE.B (A0),D1
		BEQ.S	syncloop
		MOVEQ #22,D2
		SUB D1,D2
		LSL D2,D1
		MOVEQ	#25,d1
delayloop1	DBF D1,delayloop1
		NOP

* Overscan both sides of main screen

lineloop	REPT 228
		DCB.W 9,$4E71	
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 87,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		ENDR
BOT_BORD	DCB.W 5,$4E71
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		MOVE.B #2,$ffff820a.w
		DCB.W 83,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w

		REPT 35
		DCB.W 9,$4E71	
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 87,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		ENDR

		MOVEM.L (SP)+,D0-D7/A0-A1
phbl		RTE

* Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

pic		INCBIN g:\old.s\ovrscan.dst\tile.PI1
		SECTION BSS
		DS.L 249
my_stack	DS.L 1
		
