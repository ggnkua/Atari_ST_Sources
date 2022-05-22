* Boot sector reader and saver.
* Fast DMA Load routine.
* By Griff December 1989.
* This loader doesnt use the WD1772
* read multiple sector command. 

sect_ptr	EQU 9

Dmaload	BSR super
		LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		BSR set_ints
		BSR seldrive
		BSR seektrack
		BSR read_sects
		CLR track
		BSR seektrack
		BSR deselect
		BSR res_ints
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		LEA buffer(PC),A5
		MOVE.L #512,D7
		BSR Save_file
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
		MOVE #$7,(A1)
		BSR fdcwait
		MOVEQ #-1,D7
wait1		DBF D7,wait1
		MOVE #$86,(A0)
		MOVE track(PC),(A1)
		MOVE #$80,(A0)
		MOVE #$1f,(A1)
		BSR fdcwait
		RTS

* Read sectors into memory. 

read_sects	LEA load_addr+4(PC),A3
		MOVE.B -(A3),$FFFF860D
		MOVE.B -(A3),$FFFF860B
		MOVE.B -(A3),$FFFF8609
		MOVE sect_no(PC),D3
		MOVEQ #sect_ptr,D4
		MOVE no_sects(PC),D7
		MOVE #$90,(A0)
		MOVE #$190,(A0)
read_lp	MOVE #$90,(A0)
		MOVE #$01,(A1)
		MOVE #$84,(A0)
		MOVE D3,(A1)
		MOVE #$80,(A0)
		MOVE #$88,(A1)
fdcwait1	BTST.B #5,(A2)
		BNE.S fdcwait1
read_done	ADDQ #1,D3
		CMP D4,D3
		BGT.S step_in
		DBF D7,read_lp
		RTS
step_in	MOVE #$80,(A0)
		MOVE #$5A,(A1)
fdcstep1	BTST.B #5,(A2)
		BNE.S fdcstep1
		MOVEQ #1,D3
		DBF D7,read_lp
		RTS

* Wait for FDC
 	
fdcwait	MOVE.L #$40000,D7
fdcwait_lp	BTST.B #5,(A2)
		BEQ.S wait_done
		SUBQ.L #1,D7
		BNE.S fdcwait_lp
wait_done	RTS

* Save a file of D7 bytes,
* Filename at A4 at address A5.

Save_file	MOVE #0,-(SP)
		PEA filename(PC)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
write		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		LEA 12(SP),SP
close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		RTS

filename	DC.B "BOOT.DAT",0
		EVEN
load_addr	DC.L buffer	
track		DC.W 0
sect_no	DC.W 1
side		DC.W 0
no_sects	DC.W 1
buffer