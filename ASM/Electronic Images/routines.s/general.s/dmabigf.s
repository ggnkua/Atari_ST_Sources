;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; 12 Sector DMA format Routine!! (e.g 12*512 bytes per track!!!)	;
; By Martin Griffiths May 1991.(Griff of The Inner Circle)		;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

letsgo		MOVE.L #200000,D0
.lp		SUBQ.L #1,D0
		BNE.S .lp
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1					; super
		ADDQ.L #6,SP
		BSR set_ints				; iniit ints
		BSR set_scrn
		MOVE.L log_base(PC),A0
		MOVE.W #0,track
		MOVE.W #0,side
		MOVEQ #10-1,D7
		BSR read_tracks
		BSR res_ints				; restore ints
		CLR -(SP)		
		TRAP #1					; see ya

; Read D7 tracks.
; A0 -> address to load into.
				
read_tracks	MOVE.L A0,load_addr
		LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		BSR seldrive
		BSR seektrack
.track_lp	MOVE.W D7,-(SP)
		BSR Read_track
		MOVE.L load_addr(PC),A3
		LEA read_buffer(PC),A4
.srch		;CMP.B #$A1,(A4)+
		;BNE.S .srch
		;CMP.B #$A1,(A4)
		;BNE.S .srch
		MOVE #(512*12)/4-1,D0
.trans_lp	MOVE.B (A4)+,(A3)+
		MOVE.B (A4)+,(A3)+
		MOVE.B (A4)+,(A3)+
		MOVE.B (A4)+,(A3)+
		DBF D0,.trans_lp
		BSR step_in
		MOVE.W (SP)+,D7
		DBF D7,.track_lp
		BSR deselect
		RTS

; Write D7 tracks. 
; A0 -> address of data to save.

write_tracks	LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		BSR seldrive
		BSR seektrack
.track_lp	MOVE.W D7,-(SP)
		BSR Write_track
		BSR step_in
		MOVE.W (SP)+,D7
		DBF D7,.track_lp
		BSR deselect
		RTS

; Initialize interrupts.

set_ints	MOVE.W #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,(a0)+
		MOVE.L #new_vbl,$70.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.W #$2300,SR
		BSR flush
		RTS
; Restore old interrupts.

res_ints	MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		BSR flush
		RTS

set_scrn	MOVE.L #screen+256,D0
		CLR.B D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

old_stuff	ds.l 5
new_vbl		RTE

; Select current drive/side
; d0 - 2 drive a, d0 - 4 drive b

seldrive	MOVEQ #2,D0
		OR side(PC),D0
		EOR.B #7,D0
select		MOVE.B #$E,$FFFF8800.W
		MOVE.B $FFFF8800.W,D1
		AND.B #$F8,D1
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W
		RTS

; Deselect current drive e.g turn motor off!

deselect	MOVE #$80,(A0)
wait		MOVE (A1),D0
		BTST #7,D0
		BNE.S wait
		MOVEQ #7,D0
		BRA select

; Place read/write head on the track in 'track'.

seektrack	MOVE #$80,(A0)
		MOVE #$07,(A1)
		BSR fdcwait
		MOVE #$86,(A0)
		MOVE track(PC),(A1)
		MOVE #$80,(A0)
		MOVE #%00010001,(A1)
		BSR fdcwait
		RTS

; Write (format) track.

Write_track	LEA data_ptr(PC),A3
		MOVE.L #write_buffer,(A3)+
		MOVE.B -(A3),$FFFF860D.w
		MOVE.B -(A3),$FFFF860B.w
		MOVE.B -(A3),$FFFF8609.w
		MOVE #$190,(A0)
		MOVE #$90,(A0)
		MOVE #$190,(A0)
		MULU #1234,D0
		MOVE #$0E,(A1)
		MULU #1234,D0
		MOVE #$180,(A0)
		MULU #1234,D0
		MOVE #%11110000,(A1)
		MULU #1234,D0
fdcwait1	BTST.B #5,(A2)
		BNE.S fdcwait1
		RTS

; Read track. (note the fdc dos no error checking!!)

Read_track	LEA data_ptr(PC),A3
		MOVE.L #read_buffer,(A3)+
		MOVE.B -(A3),$FFFF860D.w
		MOVE.B -(A3),$FFFF860B.w
		MOVE.B -(A3),$FFFF8609.w
		MOVE #$90,(A0)
		MOVE #$190,(A0)
		MOVE #$90,(A0)
		MULU #1234,D0
		MOVE #$0E,(A1)
		MULU #1234,D0
		MOVE #$180,(A0)
		MULU #1234,D0
		MOVE #%11100000,(A1)
		MULU #1234,D0
.fdcwait1	BTST.B #5,(A2)
		BNE.S .fdcwait1
		RTS

; Step_in a track

step_in		MOVE #$80,(A0)
		MOVE #$58,(A1)
fdcstep1	BTST.B #5,(A2)
		BNE.S fdcstep1
		RTS

; Wait for FDC
 	
fdcwait		MOVE.L D7,-(SP)
		MOVE.L #$50000,D7
fdcwait_lp	BTST.B #5,(A2)
		BEQ.S wait_done
		SUBQ.L #1,D7
		BNE.S fdcwait_lp
wait_done	MOVE.L (SP)+,D7
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

log_base	DC.L 0

track		DC.W 0
side		DC.W 0
data_ptr	DC.L 0
load_addr	DC.L 0

write_buffer	DCB.B 12,0
		DCB.B 3,$F5
		SECTION BSS
		DS.B 12*512
read_buffer	DS.B 8000
screen		DS.B 256
		DS.B 32000
