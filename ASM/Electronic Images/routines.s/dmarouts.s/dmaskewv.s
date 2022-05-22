* DMA Skewed format routine. By Griff December 1989.
* Skewed format is not as fast as the 11 sector trick...

Dmaformat	BSR super
		LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		LEA skew_tab(PC),A6
		BSR set_ints
		BSR seldrive
		BSR seektrack
track_lp	clr side
		bsr seldrive
		MOVE track(PC),D0
		MOVE.B D0,t1
		MOVE.B (A6)+,t1+2
		MOVE.B D0,t2
		MOVE.B (A6)+,t2+2
		MOVE.B D0,t3
		MOVE.B (A6)+,t3+2
		MOVE.B D0,t4
		MOVE.B (A6)+,t4+2
		MOVE.B D0,t5
		MOVE.B (A6)+,t5+2
		MOVE.B D0,t6
		MOVE.B (A6)+,t6+2
		MOVE.B D0,t7
		MOVE.B (A6)+,t7+2
		MOVE.B D0,t8
		MOVE.B (A6)+,t8+2
		MOVE.B D0,t9
		MOVE.B (A6)+,t9+2
		MOVE.B D0,t10
		MOVE.B (A6)+,t10+2
		BSR Write_track
		move #1,side
		bsr seldrive
		BSR Write_track

		BSR step_in
		ADDQ #1,track
		CMP #82,track
		BNE track_lp
		BSR deselect
		BSR res_ints
		BSR user
		CLR -(SP)
		TRAP #1

* Initialize interrupts.

set_ints	MOVE.L $70.W,old_vbl
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
		MOVE.B -(A3),$FFFF860D.w
		MOVE.B -(A3),$FFFF860B.w
		MOVE.B -(A3),$FFFF8609.w
		MOVE #$190,(A0)
		MOVE #$90,(A0)
		MOVE #$190,(A0)
		BSR waitA
		MOVE #$0E,(A1)
		BSR waitA
		MOVE #$180,(A0)
		BSR waitA
		MOVE #$f0,(A1)
		BSR waitA
fdcwait1	BTST.B #5,(A2)
		BNE.S fdcwait1
		RTS

waitA		MOVEQ #32,D0
a		DBF D0,a
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

track		DC.W 0
side		DC.W 0
data		DC.L track_data

track_data	DCB.B 60,$4E
sect1		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FE
t1		DC.B 0
		DC.B 0
		DC.B 1
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect2		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t2		DC.B 0
		DC.B 0
		DC.B 2
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect3		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t3		DC.B 0
		DC.B 0
		DC.B 3
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect4		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t4		DC.B 0
		DC.B 0
		DC.B 4
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect5		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t5		DC.B 0
		DC.B 0
		DC.B 5
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E

sect6		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t6		DC.B 0
		DC.B 0
		DC.B 6
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect7		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t7		DC.B 0
		DC.B 0
		DC.B 7
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect8		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t8		DC.B 0
		DC.B 0
		DC.B 8
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect9		DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t9		DC.B 0
		DC.B 0
		DC.B 9
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
sect10	DCB.B 12,0
		DCB.B $3,$F5
		DC.B $FE
t10		DC.B 0
		DC.B 0
		DC.B 10
		DC.B 2
		DC.B $F7
		DCB.B 28,$4E
		DCB.B 12,0
		DCB.B 3,$F5
		DC.B $FB
		DCB.B 512,$E5
		DC.B $F7
		DCB.B 40,$4E
		DCB.B 60,$4E

skew_tab	rept 82
		DC.B 1,8,5,2,9,6,3,10,7,4
		endr