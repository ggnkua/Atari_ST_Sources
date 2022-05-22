* DMA Fast format routine using
* the 11 sector trick.
* By Griff December 1989.

Dmaformat	LEA my_stack(PC),SP
		PEA text(PC)
		MOVE #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		BSR super
		BSR set_ints
		LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		BSR seldrive
		BSR seektrack
form_lp	MOVE track(PC),D0
		BSR num_print
		MOVE track(PC),D0
		MOVE.B D0,t0
		MOVE.B D0,t1
		MOVE.B D0,t2
		MOVE.B D0,t3
		MOVE.B D0,t4
		MOVE.B D0,t5
		MOVE.B D0,t6
		MOVE.B D0,t7
		MOVE.B D0,t8
		MOVE.B D0,t9
		MOVE.B D0,t10
		BSR Write_track
		ADDQ #1,track
		CMP #80,track
		BEQ end_form
		BSR step_in
		BRA form_lp
end_form	CLR track
		BSR seektrack
		BSR deselect
		BSR res_ints
 		BSR user
		CLR -(SP)
		TRAP #1

* Initialize interrupts.

set_ints	MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,log_base
		MOVE.L $70.W,old_vbl
		MOVE.L #new_vbl,$70.W
		RTS

* Restore old interrupts.

res_ints	MOVE.L old_vbl(PC),$70.W
		RTS

old_sp	DC.L 0
old_vbl	DC.L 0
new_vbl	RTE

* Enter Supervisor mode

super		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,old_sp
		RTS

* Restore User mode

user		MOVE.L old_sp(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		RTS

* Select current drive/side
* d0 - 2 drive a
* d0 - 4 drive b

seldrive	MOVEQ #2,D0
		OR side(PC),D0
		EOR.B #7,D0
select	MOVE.B #$E,$FFFF8800.W
		MOVE.B $FFFF8800.W,D1
		AND.B #$F8,D1
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W
		RTS

* Deselect current drive
* e.g turn motor off!

deselect	MOVE #$80,(A0)
wait		MOVE (A1),D0
		BTST #7,D0
		BNE.S wait
		MOVEQ #7,D0
		BRA select

* Place read/write head on the
* track in 'track'.

seektrack	MOVE #$80,(A0)
		MOVE #$07,(A1)
		BSR fdcwait
		MOVE #$86,(A0)
		MOVE track(PC),(A1)
		MOVE #$80,(A0)
		MOVE #$1F,(A1)
		BSR fdcwait
		RTS

* Write (format) track.

Write_track	LEA data+4(PC),A3
		MOVE.B -(A3),$FFFF860D
		MOVE.B -(A3),$FFFF860B
		MOVE.B -(A3),$FFFF8609
		MOVE #$190,(A0)
		MOVE #$90,(A0)
		MOVE #$190,(A0)
		MOVE #$0E,(A1)
		MOVE #$180,(A0)
		MOVE #$F8,(A1)
fdcwait1	BTST.B #5,(A2)
		BNE.S fdcwait1
		RTS

* Step_in a track

step_in	MOVE #$80,(A0)
		MOVE #$58,(A1)
fdcstep1	BTST.B #5,(A2)
		BNE.S fdcstep1
		RTS

* Wait for FDC
 	
fdcwait	MOVE.L #$40000,D7
fdcwait_lp	BTST.B #5,(A2)
		BEQ.S wait_done
		SUBQ.L #1,D7
		BNE.S fdcwait_lp
wait_done	RTS

* Routine to print an unsigned word
* in decimal.D0.L contains the no.
* to be printed.

num_print	MOVEM.L D0-D1/A0-A1,-(SP)
		MOVE.L log_base(PC),A0
		LEA 2560+80(A0),A0
		DIVU #10,D0
		BSR.S	digi_prin
		ADDQ.L #1,A0	
		CLR D0		
		SWAP D0
		BSR.S	digi_prin
		MOVEM.L (SP)+,D0-D1/A0-A1
		RTS

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

font_data	DC.W $7CC6,$C600,$C6C6,$7C00
		DC.W $1818,$1800,$1818,$1800
		DC.W $7C06,$067C,$C0C0,$7C00
		DC.W $7C06,$067C,$0606,$7C00
		DC.W $C6C6,$C67C,$0606,$0600
		DC.W $7CC0,$C07C,$0606,$7C00
		DC.W $7CC0,$C07C,$C6C6,$7C00
		DC.W $7C06,$0600,$0606,$0600
		DC.W $7CC6,$C67C,$C6C6,$7C00
		DC.W $7CC6,$C67C,$0606,$7C00

log_base	DC.L 0
track		DC.W 0
side		DC.W 0
data		DC.L track_data
text		DC.B 27,69,"  DMA Fast Formatter by Griff Dec 1989",0
		EVEN

track_data	DCB.B $20,$4E
sector11	DCB.B $08,$00
		DCB.B $02,$F5
		DCB.B $01,$FE
t0		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$0B
		DCB.B $01,$02
		DCB.B $01,$F7 
		DCB.B $18,$4E

sector1	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t1		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$01
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector2	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t2		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$02
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector3	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t3		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$03
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector4	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t4		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$04
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector5	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t5		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$05
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector6	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t6		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$06
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector7	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t7		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$07
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector8	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t8		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$08
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector9	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t9		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$09
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E

sector10	DCB.B $08,$00
		DCB.B $03,$F5
		DCB.B $01,$FE
t10		DCB.B $01,$00
		DCB.B $01,$00
		DCB.B $01,$0A
		DCB.B $01,$02
		DCB.B $01,$F7
		DCB.B $16,$4E
		DCB.B $0C,$00
		DCB.B $03,$F5
		DCB.B $01,$FB
		DCB.B $200,$E5
		DCB.B $01,$F7
		DCB.B $18,$4E
		DCB.B 400,$4E
		DS.L 99
my_stack