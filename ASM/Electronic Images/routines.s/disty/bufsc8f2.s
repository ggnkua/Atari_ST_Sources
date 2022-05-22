; 16*13 1 plane Disting scroller (C) Martin Griffiths Sept 1990.

		OPT O+,OW-

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

Start		MOVE #$2700,SR
		LEA stack,SP
		MOVE.L #$f8000,D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #switch,$B0.W
		MOVE.W #$700,$FFFF8240+2
		MOVE.W #$700,$FFFF8240+16
		MOVE #$2300,SR
wait		BTST.B #0,$FFFFFC00.W
		BEQ wait
		CMP.B #$39,$FFFFFC02.W
		BNE wait
		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

log_base	DS.L 1
		DS.L 1
vbl_timer	DS.W 1
tempsp		DC.L 0

switch		BCHG #13,(SP)
		RTE

my_vbl		MOVEM.L D0-D5/A0/A2-A3,-(SP)
		MOVE #1600,D0
A		DBF D0,A
		NOT.W $FFFF8240.W
		BSR Bufscrl8
		NOT.W $FFFF8240.W

		MOVEM.L (SP)+,D0-D5/A0/A2-A3
		ADDQ #1,vbl_timer
		RTE

;-----------------------------------------------------------------------;
; 8*8 Buffer Scroller Routine.... takes hardly any cpu time...		;
;-----------------------------------------------------------------------;

b8scrlspeed	EQU 2

b8nolines	EQU 8
b8linewid	EQU 84
b8bufsize	EQU b8nolines*b8linewid

Bufscrl8	MOVE.L b8sc_scr_point(PC),A0	;curr text ptr
		MOVE.L b8sc_which_buf(PC),A3	;curr pix buffer ptr
		MOVE b8sc_scx(PC),D2		;pixel offset
		LEA b8bufsize*b8scrlspeed(A3),A3 ;skip 2 buffers(2 pix step)	
		ADDQ #b8scrlspeed,D2		;add 2(2 pixel step)
		CMP #16,D2			;end of chunk?
		BNE.S .pos_ok			;no then skip
		ADDQ.W #2,b8sc_scrlpos		;onto next chunk 
		CMP #b8linewid/2,b8sc_scrlpos	;in pix buffer.
		BNE.S .nowrapscr		;reached end of buffer?		
		CLR b8sc_scrlpos		;if yes reset buffer position
.nowrapscr	LEA b8sc_scbuffer,A3		;reset pixel chunk offset
		MOVEQ #0,D2			;+ pix position
		ADDQ.L #2,A0			;after 32 pixs,next letter...
.pos_ok		TST.B 1(A0)	
		BNE.S .notwrap			;end of text?
		LEA b8sc_text(PC),A0		;yes restart text
.notwrap	MOVE D2,b8sc_scx		;otherwise restore
		MOVE.L A3,b8sc_which_buf
		MOVE.L A0,b8sc_scr_point
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1
		LEA font32(PC),A0  		;character addr    
		LEA (A0),A2
		SUB.B #32,D0			;normalise asci char
		SUB.B #32,D1			
		LSL #3,D0              		;*64 font offset
		LSL #3,D1              		
		ADDA.W D0,A0
		ADDA.W D1,A2
		ADD b8sc_scrlpos(PC),A3
		MOVEQ #b8nolines-1,D0
.addin		MOVEQ #0,D3
		MOVE.B (A0)+,D3
		LSL #8,D3 
		MOVE.B (A2)+,D3 
		ROL.L D2,D3
		MOVE.W D3,-2(A3)
		MOVE.W D3,(b8linewid/2)-2(A3)
		SWAP D3
		OR.W D3,-4(A3)
		OR.W D3,(b8linewid/2)-4(A3)
		SWAP D3
i		SET 0
		REPT b8scrlspeed-1
i		SET i+b8bufsize
		ROL.L #1,D3
		MOVE.W D3,-2+i(A3)
		MOVE.W D3,(b8linewid/2)-2+i(A3)
		SWAP D3
		OR.W D3,-4+i(A3)
		OR.W D3,(b8linewid/2)-4+i(A3)
		ENDR
		LEA b8linewid(A3),A3
		DBF D0,.addin

copy_buf	MOVE.L log_base(PC),A0	screen base
		ADDQ.L #6,A0
		MOVE.L b8sc_which_buf(pc),A2
		ADD b8sc_scrlpos(PC),A2
		MOVEQ #b8nolines-1,D0
.copy_lp	MOVE.L (A2)+,(A0)
		MOVE.L (A2)+,16(A0)
		MOVE.L (A2)+,32(A0)
		MOVE.L (A2)+,48(A0)
		MOVE.L (A2)+,64(A0)
		MOVE.L (A2)+,80(A0)
		MOVE.L (A2)+,96(A0)
		MOVE.L (A2)+,112(A0)
		MOVE.L (A2)+,128(A0)
		MOVE.L (A2)+,144(A0)
		LEA b8linewid-40(A2),A2
		LEA 160(A0),A0
		DBF D0,.copy_lp
		RTS

b8sc_scr_point	DC.L b8sc_text
b8sc_which_buf	DC.L b8sc_scbuffer
b8sc_scx	DC.W 0
b8sc_scrlpos	DC.W 0
b8sc_finbarr	DC.W 0
b8sc_text	dc.b "  TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0,0
		EVEN

font32		
smllfont	dc.l	$00000000,$00000000,$10101010,$10001000,$00240000 
		dc.l	$00000000,$24247E24,$7E242400,$107C907C,$127C1000 
		dc.l	$00440810,$20440000,$18241828,$45827D00,$00100000 
		dc.l	$00000000,$04081010,$10080400,$20100808,$08102000 
		dc.l	$004428FE,$28440000,$0010107C,$10100000,$00000000 
		dc.l	$00001020,$0000007C,$00000000,$00000000,$00001000 
		dc.l	$00020408,$10204000,$7C868A92,$A2C27C00,$10301010 
		dc.l	$10107C00,$7C82027C,$8080FE00,$7C82021C,$02827C00 
		dc.l	$0C142444,$84FE0400,$FC8080FC,$02827C00,$7C8280FC 
		dc.l	$82827C00,$FE820408,$10101000,$7C82827C,$82827C00 
		dc.l	$7C82827E,$02027C00,$00001000,$10000000,$00001000 
		dc.l	$10200000,$08102040,$20100800,$00007C00,$7C000000 
		dc.l	$20100804,$08102000,$7C82020C,$10001000,$7C829EA2 
		dc.l	$9C807E00,$7C8282FE,$82828200,$FC8282FC,$8282FC00 
		dc.l	$7C828080,$80827C00,$FC828282,$8282FC00,$FE8080F8 
		dc.l	$8080FE00,$FE8080F8,$80808000,$7E80808E,$82827C00 
		dc.l	$828282FE,$82828200,$7C101010,$10107C00,$02020202 
		dc.l	$02827C00,$828488F0,$88848200,$80808080,$8080FE00 
		dc.l	$82C6AA92,$82828200,$82C2A292,$8A868200,$7C828282 
		dc.l	$82827C00,$FC8282FC,$80808000,$7C828282,$8A847A00 
		dc.l	$FC8282FC,$88848200,$7C82807C,$02827C00,$FE101010 
		dc.l	$10101000,$82828282,$82827C00,$82828282,$44281000 
		dc.l	$82828292,$AAC68200,$82442810,$28448200,$82824428 
		dc.l	$10101000,$FE040810,$2040FE00,$1C101010,$10101C00 
		dc.l	$80402010,$08040200,$38080808,$08083800,$10284482 
		dc.l	$00000000,$00000000,$0000FE00,$00100000,$00000000 
		dc.l	$00007804,$7C847800,$8080F884,$8484F800,$00007880 
		dc.l	$80807800,$04047C84,$84847C00,$00007884,$F8807800 
		dc.l	$0C103810,$10101000,$00007884,$847C0478,$8080F884 
		dc.l	$84848400,$10003010,$10103800,$08000808,$08080830 
		dc.l	$808890E0,$90888400,$30101010,$10103800,$0000EC92 
		dc.l	$92828200,$0000F884,$84848400,$00007884,$84847800 
		dc.l	$0000F884,$8484F880,$00007C84,$84847C04,$0000F884 
		dc.l	$80808000,$00007880,$78047800,$10107C10,$10100C00 
		dc.l	$00008484,$84847C00,$00008282,$44281000,$00008282 
		dc.l	$82542800,$00008448,$30488400,$00008484,$847C0478 
		dc.l	$00007C08,$10207C00,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 

		SECTION BSS
		DS.W 2
b8sc_scbuffer	REPT 16
		DS.B b8bufsize
		ENDR
		DS.W 2

old_mfp		DS.L 8
		DS.L 129
stack		DS.L 1
