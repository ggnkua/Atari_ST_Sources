; Example Dma load code.(This is a not an interrupt version).

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #-1,$43E.W
		BSR flush
		BSR Do_load
Exit		BSR flush
		MOVE #0,$43E.W
		CLR.W -(SP)
		TRAP #1

old_vects	DS.L 4

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

;-----------------------------------------------------------------------;
; Fast DMA Load routine  By Griff December 1989.			;
; This loader doesnt use the WD1772 read multiple sector command.     	;
;-----------------------------------------------------------------------;

sect_ptr	EQU 10

Do_load		BSR seldrive
		BSR seektrack
		BSR read_sects
		RTS

* Select current drive/side

seldrive	MOVE $446.W,D0
		AND #1,D0
		ADDQ #1,D0
		ADD D0,D0
		OR side(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W
		MOVE.B $FFFF8800.W,D1
		AND.B #$F8,D1
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W
		RTS

* Deselect current drive e.g turn motor off!

deselect	MOVE #$80,$FFFF8606.W
		NOP
wait		BTST #7,$FFFF8604.W
		BNE.S wait
		MOVEQ #7,D0
		BRA select

* Place read/write head on the track in 'track'.

seektrack	MOVE #$86,$FFFF8606.W
		MOVE track(PC),$FFFF8604.W
		MOVE #$80,$FFFF8606.W
		MOVE #16+4+3,$FFFF8604.W
.fdcwait	BTST.B #5,$FFFFFA01.W
		BNE.S .fdcwait
		RTS

* Read sectors into memory. 

read_sects	MOVE.B load_addr+3(PC),$FFFF860D.W
		MOVE.B load_addr+2(PC),$FFFF860B.W
		MOVE.B load_addr+1(PC),$FFFF8609.W
		MOVE #$90,$FFFF8606.W
		MOVE #$190,$FFFF8606.W
		MOVE #$90,$FFFF8606.W
		MOVE #1,$FFFF8604.W
		MOVE #$84,$FFFF8606.W
		MOVE sector(PC),$FFFF8604.W
		MOVE #$80,$FFFF8606.W
		MOVE #$88,$FFFF8604.W
.fdcwait	BTST.B #5,$FFFFFA01.W
		BNE.S .fdcwait
		MOVE #$80,$FFFF8606.W
		MOVE $FFFF8604.W,D0
		BTST #3,D0
		BNE read_sects
		BTST #4,D0
		BNE read_sects
		BTST #5,D0
		BNE read_sects
		ADD.L #512,load_addr
		ADDQ #1,sector
		CMP #sect_ptr,sector
		BGT.S step_in
cont		SUBQ #1,no_sects
		BNE read_sects
		RTS
step_in		MOVE #$80,$FFFF8606.W
		MOVE #64+16+8+3,$FFFF8604.W
.fdcwait	BTST.B #5,$FFFFFA01.W
		BNE.S .fdcwait
		MOVE #1,sector
		BRA.S cont
		RTS

side		DC.W 0
track		DC.W 0
sector		DC.W 1
no_sects	DC.W 40
load_addr	DC.L $80000
