;-----------------------------------------------------------------------;
;									;
;      Hallucinations 							;
; 	            by Martin Griffiths June 1992			;
;									;
;-----------------------------------------------------------------------;

		OPT O+,OW-

demo		EQU 0

		IFEQ demo
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
		ELSEIF
		ORG $10000
		ENDC

letsgo		MOVE.L SP,oldsp
		LEA my_stack,SP
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		IFNE demo
		JSR $508
		ENDC

		BSR flush
		BSR Initscreens
		MOVE.W #$2700,SR
		LEA oldmfp(PC),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		MOVE.L #ltext_hbl,$120.W
		CLR.B $FFFFFA1B.W
		MOVE.B #1,$FFFFFA07.W
		MOVE.B #0,$fffffa09.W 
		MOVE.B #1,$FFFFFA13.W
		MOVE.B #0,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 
		LEA text(PC),A6
		BSR Print_Text
	
		MOVEQ #100,D7
		BSR Waitd7Vbls


.exit		MOVE #$2700,SR 
		LEA oldmfp(PC),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.W #$2300,SR
		BSR flush
		
		IFEQ demo
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		CLR -(SP)
		TRAP #1
		ENDC
		MOVE.L oldsp(PC),SP
		RTS
oldsp		DS.L 1

oldmfp		DS.L 22

Print_text	MOVE.L phy_base(PC),A2
		MOVE.W (A6)+,D1
		MULU #160,D1
		ADDA D1,A2 
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADDQ.W #8,D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #160,D0
.do1line	MOVE.B (A6)+,D1
		BEQ.S .row_done
		CMP.B #1,D1
		BEQ.S .text_done 
		MOVE D0,D2
		AND #15,D2
		LEA font_buf(PC),A0
		EXT.W D1
		SUB.B #32,D1
		LSL.W #3,D1
		ADD.W D1,A0
		MOVE D0,D3
		LSR #1,D3
		AND #$FFF8,D3
		LEA (A2,D3),A1
		MOVEQ #7,D3
.linep_lp	MOVEQ #0,D1
		MOVE.B (A0)+,D1
		ROR.L D2,D1
		OR.W D1,(A1)
		SWAP D1
		OR.W D1,8(A1)
		LEA 160(A1),A1
		DBRA D3,.linep_lp
		ADDQ #8,D0
		BRA .do1line
.row_done	LEA 8*160(A2),A2
		BRA .row_lp
.text_done	RTS

font_buf	INCBIN D:\GRAPHICS\FONTS__8.RAW\MET_09.FN8

text		DC.W 0
		DC.B "The Amiga Sound Emulator",0
		DC.B " ",0
		DC.B "--- SoundMonitor V2.0 ---",0
		DC.B "COMMANDO ",0
		DC.B "GREEN BERET",0
		DC.B "STORMLORD(?)",0
		DC.B "---   JamCrack V2.0   ---",0
		DC.B "MENTAL RELAPSE",0
		DC.B "COMIC BAKERY",0
		DC.B "--- Pro-Tracker V1.1B ---",0
		DC.B "YANS HIGHSCORE THEME",0
		DC.B "REBELS THEME 1",0
		DC.B "REBELS THEME 2",0
		DC.B "CHIPPY TUNE 1",0
		DC.B "CHIPPY TUNE 2",0
		DC.B " ",1


; Initialise screen.

Initscreens	LEA phy_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)
		BSR clearsc
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

clearsc		MOVE.L D0,A0
		MOVE.W #(32000/16)-1,D1
		MOVEQ #0,D2
.lp		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		DBF D1,.lp
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS


pal	  	dc.w $000,$003,$004,$005,$000,$000,$000,$000,$000
		dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000

; Little old vbl..

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVEM.L pal(PC),D0-D7 
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		;BSR NiceFadeIn
		;BSR NiceFadeOut
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer  	
		RTE 

vbl_timer	DC.W 0
currpal		DS.W 16
phy_base	DS.L 1

WaitD7Vbls	
.wait_lp	BSR WaitVbl
		DBF D7,.wait_lp
		RTS

WaitVbl		MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

ltext_hbl	MOVEM.L A0/D7,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D7
.synca		CMP.B (A0),D7
		BEQ.S .synca
		MOVE.B (A0),D7
		JMP noplist1-96(PC,D7) 
noplist1	REPT 99
		NOP
		ENDR
		MOVE.B #0,$ffff820a.w
		REPT 8
		NOP
		ENDR
		MOVE.B #2,$ffff820a.w
		CLR.B $FFFFFA1B.W
		MOVEM.L (SP)+,A0/D7
		RTE

i		set 0
mulu_160	rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr
	
		SECTION BSS
		DS.L 199
my_stack	DS.L 3
screens		DS.B 256
		DS.B 47000
