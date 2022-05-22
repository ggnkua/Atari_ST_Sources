;-----------------------------------------------------------;
; Griff's sync scroll this is a new version which		;
; takes  7 scanlines.							;
; Should be compaitable with 99% of st's including STE!  	;
;-----------------------------------------------------------;
; 1.The top border is removed with a timer A call.
; 2.Straight after the switch back to 50hz(from the border change)
;   the processor is synced with the screen.
; 3.The following 6 scanlines are used in removing different borders 
;   to get the sync scroll effect.
; 4.The 7 vectors(1 for each scanline) are setup in the vbl, this
;   'programs' how many bytes to be missed.  

		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA my_stack(PC),SP
Copy_pic	LEA pic+34(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #1999,D1
cpy_lp1	MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D1,cpy_lp1 
		BSR SETUPSCROLL

set_ints	MOVE #$2700,SR
		BSR flush
		MOVE.B #$12,$FFFFFC02.W
		LEA old_mfp+32(PC),A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
		MOVE.B $FFFFFA07.W,(A0)+
            MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
            MOVE.B $FFFFFA15.W,(A0)+
            MOVE.B $FFFFFA19.W,(A0)+
            MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
            MOVE.B #$21,$FFFFFA07.W
            MOVE.B #$21,$FFFFFA13.W
            CLR.B $FFFFFA09.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.L #phbl,$68.W
		MOVE.L #vbl,$70.W
		MOVE.L #showithbl,$120.W
		MOVE.L #syncscroll,$134.W
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR

wait_key	CMP.B #$39,$FFFFFC02.W
		BNE.S wait_key

restore	MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
		MOVE.B #$8,$FFFFFC02.W
		MOVE.B (A0)+,$FFFFFA07.W
            MOVE.B (A0)+,$FFFFFA09.W
            MOVE.B (A0)+,$FFFFFA13.W
            MOVE.B (A0)+,$FFFFFA15.W
            MOVE.B (A0)+,$FFFFFA19.W
            MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

; This table contains the various border removal combinations
; for adding 0 bytes,8 bytes,16 bytes etc etc....

ROUT_TAB	DC.L nothing     ;=0
		DC.L length_2    ;=-2
		DC.L length24    ;=+24
		DC.L rightonly   ;=+44
		DC.L wholeline   ;=+70
		DC.L length26    ;=+26
		DC.L length_106  ;=-106!
ROUTS		
m0		DC.B 0,0,0,0,0,0,0
m8		DC.B 6,4,3,0,0,0,0
m16		DC.B 2,1,1,1,1,0,0
m24		DC.B 2,0,0,0,0,0,0
m32		DC.B 6,4,4,1,0,0,0
m40		DC.B 3,1,1,0,0,0,0
m48		DC.B 2,2,0,0,0,0,0
m56		DC.B 6,4,4,2,1,0,0
m64		DC.B 4,1,1,1,0,0,0
m62		DC.B 2,2,2,0,0,0,0
m80		DC.B 6,4,4,2,2,1,0
m88		DC.B 3,3,0,0,0,0,0
m96		DC.B 2,2,2,2,0,0,0
m104		DC.B 6,4,4,4,0,0,0
m112		DC.B 4,3,1,0,0,0,0
m120		DC.B 5,2,4,0,0,0,0
m128		DC.B 6,4,4,2,4,0,0
m136		DC.B 2,4,3,1,0,0,0
m144		DC.B 5,2,2,4,0,0,0
m152		DC.B 6,4,4,4,2,2,0
m160		DC.B 4,4,2,1,1,0,0
m168		DC.B 5,2,4,2,2,0,0
m176		DC.B 3,3,3,3,0,0,0
m184		DC.B 3,4,4,0,0,0,0
m192		DC.B 5,4,5,4,0,0,0
m200		DC.B 3,3,3,3,2,0,0
m208		DC.B 4,4,4,1,0,0,0
m216		DC.B 5,5,4,4,2,0,0
m224		DC.B 3,3,3,3,2,2,0
m232		DC.B 4,4,4,1,2,0,0
m240		DC.B 5,5,4,4,2,2,0
m248		DC.B 4,4,4,3,1,1,1
		even
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #196,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L D0/A0,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE sc_x1(PC),D0
		AND #$FF,D0
		LSR #1,D0
		MULU #7,D0
		LEA LINE_JMPS(PC),A0
		ADDA.W D0,A0
		MOVE.L (A0)+,hl1+2
		MOVE.L (A0)+,hl2+2
		MOVE.L (A0)+,hl3+2
		MOVE.L (A0)+,hl4+2
		MOVE.L (A0)+,hl5+2
		MOVE.L (A0)+,hl6+2
		MOVE.L (A0)+,hl7+2
		MOVEQ #0,D1
		MOVE sc_x(PC),D1
		MOVE D1,sc_x1
		MOVE.L log_base(PC),D0
		ADD.L D1,D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		ADDq #8,sc_x
		MOVEM.L (SP)+,D0/A0
		ADDQ #1,vbl_timer
		RTE

syncscroll	MOVE #$2100,SR
		STOP #$2100
		MOVE #$2700,SR
		CLR.B $FFFFFA19.W
		MOVEM.L D0-D7/A0-A1,-(SP)
		DCB.W 60,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 7,$4E71
		CLR D1
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
syncloop	MOVE.B (A0),D1
		BEQ.S	syncloop
		MOVEQ #10,D2
		SUB D1,D2
		LSL D2,D1
		MOVEQ	#26,d1
delayloop1	DBF D1,delayloop1
		MOVE #$820A,A0
		MOVE #$8260,A1
		MOVEQ #2,D3
		MOVEQ #0,D4
		DCB.W 6,$4E71
hl1		JSR 0
hl2		JSR 0
hl3		JSR 0
hl4		JSR 0
hl5		JSR 0
hl6		JSR 0
hl7		JSR 0
		MOVEM.L pic+2(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A1
phbl		RTE

* Overscan one whole screen line - works on STE.

wholeline	MOVE.B D3,(A1)
		NOP
		MOVE.B D4,(A1)
		DCB.W 88,$4E71
		MOVE.B D4,(A0)
		MOVE.B D3,(A0)
		DCB.W 11,$4e71
		MOVE.B D3,(A1)
		NOP
		MOVE.B D4,(A1)
		DCB.W 6,$4E71
		RTS

* Right border only - works on STE

rightonly	DCB.W	93,$4E71
		MOVE.B D4,(A0)
		MOVE.B D3,(A0)
		DCB.W 22,$4e71
		RTS

* Miss one word -2 bytes   - works on STE

length_2	DCB.W	91,$4E71
		MOVE.B D4,(A0)
		MOVE.B D3,(A0)
		DCB.W 24,$4e71
		RTS
   
* Do nothing              - works on STE!! 

nothing	DCB.W 119,$4E71
		RTS

* 24 bytes extra per line - works on STE

length24	MOVE.B D3,(A1)
		NOP
		MOVE.B D4,(A1)
		DCB.W 87,$4E71
		MOVE.B D4,(A0)
		MOVE.B D3,(A0)
		DCB.W 13,$4E71
		MOVE.B D3,(A1)
		NOP
		MOVE.B D4,(A1)
		DCB.W 5,$4E71
		RTS		

; +24 bytes (ALTERNATIVE! ALTHOUGH IT DOES RESYNC) 
;length24	MOVE.B d3,(A1)
;		nop
;		MOVE.B D4,(A1)
;		dcb.w 86,$4e71
;		MOVE.B d4,(A0)
;		MOVE.B D3,(A0)
;		DCB.W 119-95,$4E71
;		RTS

* +26 bytes 

length26	MOVE.B D3,(A1)
		NOP
		MOVE.B D4,(A1)
		NOP
		NOP
		DCB.W 98,$4E71
		MOVE.B d3,(A1)
		NOP
		MOVE.B D4,(A1)
		DCB.W 9,$4E71
		RTS		

; 26 bytes - alternative! 
;
;length26:	MOVE.B d3,(A1)
;		nop
;		MOVE.B D4,(A1)
;		DCB.W 119-5,$4E71
;		RTS

* -106 bytes 

length_106	DCB.W 40,$4E71
		MOVE.B D3,(a1)
		NOP
		MOVE.B D4,(a1)
		dcb.w 119-45,$4e71
		RTS		

* SETUP HARDWARE SCROLL ROUTS

SETUPSCROLL	LEA ROUTS(PC),A0
		LEA ROUT_TAB(PC),A1
		LEA LINE_JMPS,A2
		MOVEQ #31,D2	
.jlp		MOVEQ #6,D1
.ilp		CLR D0
		MOVE.B (A0)+,D0
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A1,D0),(A2)+
		DBF D1,.ilp
		DBF D2,.jlp
		RTS

LINE_JMPS	DS.L 7*32

showithbl	CLR.B $FFFFFA1B.W
		NOT $FFFF8240.W
		DCB.W 128,$4E71
		NOT $FFFF8240.W
		RTE

* Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

log_base	DC.L $A0000
sc_x		DC.W 0
sc_x1		DC.W 0
vbl_timer	DC.W 0
old_mfp	DS.L 30
		DS.L 199
my_stack	DS.L 1

pic		INCBIN D:\OXYGENE.PI1
