; Example Dma load code - Vbl interrupt loader version!!
; Concept (C) 1990 Martin Griffiths(Griff of Electronic Images).
; Tis a tad slow but who gives a shit.

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		BSR flush
clearscreen	LEA $78000,A0
		MOVE #1999,D0
.cls		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,.cls
		MOVE #$2700,SR
		LEA old_vects(PC),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+		
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+		
		MOVE.B $FFFFFA15.W,(A0)+		
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #vbl,$70.W
		MOVE.L #key,$118.W
		BSET.B #6,$FFFFFA09.W
		BSET.B #6,$FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		MOVEQ #50,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		LEA $78000,A0
		BSR Do_load
Exit		MOVE #$2700,SR
		BSET.B #3,$FFFFFA17.W
		LEA old_vects(PC),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$118.W
		MOVE.B (A0)+,$FFFFFA07.W		
		MOVE.B (A0)+,$FFFFFA09.W		
		MOVE.B (A0)+,$FFFFFA13.W		
		MOVE.B (A0)+,$FFFFFA15.W		
		MOVE #$2300,SR
		BSR flush
		CLR.W -(SP)
		TRAP #1

old_vects	DS.L 4

key		MOVE #$2500,SR
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0
		BEQ.S end
		BTST #0,D0
		BEQ.S end
key_read	MOVE.B $FFFFFC02.W,D0
		MOVE.B D0,ckey
end		MOVE (SP)+,D0
		RTE

ckey		DC.W 0

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

;-----------------------------------------------------------------------;
; Fast DMA Load routine  By Griff December 1990.(Vbl version)		;
; This loader doesnt use the WD1772 read multiple sector command.     	;
;-----------------------------------------------------------------------;

sect_ptr	EQU 10

Do_load		MOVE #12,commandflag
		BSR seldrive
		BSR seektrack
		CLR commandflag
.stillreading	CMP #12,commandflag
		BNE.S .stillreading
		RTS

commandflag	DC.W 12

vbl		MOVE.W D0,-(SP)
		MOVE commandflag(PC),D0
		JSR commandtable(PC,D0)
		MOVE.W (SP)+,D0
		RTE
commandtable	BRA.W setread
		BRA.W waitendread
		BRA.W waitendseek
		RTS

; Set WD1772 to read 1 sector into memory. 

setread		MOVE.B load_addr+3(PC),$FFFF860D.W
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
		MOVE #4,commandflag	; Set vbl to wait for read
		RTS

; Test to see if we have finished read.

waitendread	BTST.B #5,$FFFFFA01.W
		BNE.S notendread
		MOVE #$80,$FFFF8606.W
		MOVE $FFFF8604.W,D0
		BTST #3,D0
		BNE setread
		BTST #4,D0
		BNE setread
		BTST #5,D0
		BNE setread
		ADD.L #512,load_addr
		ADDQ #1,sector
		SUBQ #1,no_sects
		BEQ.S endread
		CMP #sect_ptr,sector
		BGT.S step_in
		BRA setread
notendread	RTS

; Finished read so set vbl to do nothing

endread		MOVE #12,commandflag
		RTS

; Set WD1772 to step in a track.

step_in		MOVE #$80,$FFFF8606.W
		MOVE #64+16+8+3,$FFFF8604.W
		MOVE #8,commandflag	; Set vbl to wait for end of seek
		RTS

; Test to see if the seek is finished.

waitendseek	BTST.B #5,$FFFFFA01.W
		BNE.S notendseek
		MOVE #1,sector
		BRA setread
notendseek	RTS

; Select current drive/side

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

; Place read/write head on the track in 'track'.

seektrack	MOVE #$86,$FFFF8606.W
		MOVE track(PC),$FFFF8604.W
		MOVE #$80,$FFFF8606.W
		MOVE #16+4+3,$FFFF8604.W
.fdcwait	BTST.B #5,$FFFFFA01.W
		BNE.S .fdcwait
		RTS

side		DC.W 0
track		DC.W 0
sector		DC.W 1
no_sects	DC.W 50
load_addr	DC.L $78000
