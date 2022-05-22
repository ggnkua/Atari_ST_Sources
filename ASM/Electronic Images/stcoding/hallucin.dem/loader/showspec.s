; Spectrum .SPU Piccy shower.

letsgo		CLR -(SP)
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
		BSR Copy_pic			; copy piccy to screeb

set_ints	MOVE #$2700,SR
		BSR flush			; flush IKBD
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
	        MOVE.B #0,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #0,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		MOVE.L #vbl,$70.W
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE #$2300,SR

; Little demo which scrolls the screen vertically to oblivion!
		
wait_key	BSR wait_vbl			; obvious!
		MOVE.L log_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
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

; Wait for one vbl
; (d0 destroyed)

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear palette
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		LEA pal,A0
		MOVE #$8240,A1
		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR

		ADDQ #1,vbl_timer
		MOVEQ #0,D0
		MOVE #$8209,A0
waits		MOVE.B (A0),D0
		BEQ.S	waits
		MOVEQ #10,D1
		SUB.B D0,D1
		LSL.B D1,D0
		MOVEQ #34,D0
delay_lp	DBF D0,delay_lp
		NOP
		MOVE #$C4,D1
		LEA pal+32,A3
		MOVE #$8240,A4

dopal		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		NOP
		NOP
		DBF D1,dopal
		NOP
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		LEA -$4A60(A3),A4
		NOP
		NOP
		NOP	 
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
evbl:		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE


; Copy the piccy to the screen.

Copy_pic	LEA pic(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #1999,D1
cpy_lp1		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D1,cpy_lp1 
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

log_base	DC.L $F0000
vbl_timer	DC.W 0

		SECTION DATA

pic		INCBIN B:\HARDWOO3.SPU
pal		EQU pic+32000

		SECTION BSS

old_mfp		DS.L 30			; saved mfp vects etc
		DS.L 249
my_stack	DS.L 2			; our own stack..

 