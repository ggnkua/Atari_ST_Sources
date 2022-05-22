; 32*32 4 plane buffer scroller (C) Martin Griffiths Sept 1990.
; This takes about 14% cpu time(ish....)

		OPT O+,OW-

no_lines	EQU 32
linewid		EQU 104*4
bufsize		EQU no_lines*linewid 

		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
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
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L $70.W,old_vbl
		MOVE.L #my_vbl,$70.W
		MOVE.W #$8240,A0
		MOVE.W #$000,(A0)+
		MOVE.W #$111,(A0)+
		MOVE.W #$222,(A0)+
		MOVE.W #$333,(A0)+
		MOVE.W #$444,(A0)+
		MOVE.W #$555,(A0)+
		MOVE.W #$666,(A0)+
		MOVE.W #$777,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$000,(A0)+
		MOVE.W #$777,(A0)+
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
		BSET.B #3,$FFFFFA17.W
		MOVE.L old_vbl,$70.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)

; Buffer Scroll Routine By Griff Nov 1991.

		LEA scr_point(PC),A1
		MOVE.L (A1)+,A0			curr text ptr
		MOVE.L (A1)+,A3			curr pix buffer ptr
		MOVE (A1),D6			pixel offset
		LEA bufsize(A3),A3
		ADDQ #4,D6
		AND #15,D6
		BNE.S pos_ok			no then skip
		ADDQ.W #8,scrlpos		onto next chunk 
		CMP #208,scrlpos		in pix buffer.
		BNE.S nowrapscr			reached end of buffer?		
		CLR scrlpos			if yes reset buffer position
nowrapscr	LEA scbuffer,A3			reset pixel chunk offset
		NOT inletswitch			font is 32 wide
		BNE.S pos_ok 			so there are two chunks
		ADDQ.L #1,A0			after 32 pixs,next letter...
pos_ok		MOVEQ #0,D0
		TST.B 1(A0)	
		BNE.S notwrap			end of text?
		LEA text(PC),A0			yes restart text
notwrap		MOVE D6,(A1)			otherwise restore
		MOVE.L A3,-(A1)			
		MOVE.L A0,-(A1)			
		MOVEQ #0,D0
		MOVE.B (A0)+,D0
		SUB.B #32,D0			normalise asci char
		LSL #8,D0
		ADD D0,D0
		LEA fontbuf(PC),A5     		character addr    
		ADDA.W D0,A5
		LEA 8(A5),A6			point to 2nd chunk
		TST inletswitch			are we in 2nd chunk
		BEQ.S norm 			already?
		ADDQ.W #8,A5			if we are then the
		MOVEQ #0,D0			1st chunk of next char
		MOVE.B (A0),D0			must be plotted
		SUB.B #32,D0
		LSL #8,D0
		ADD D0,D0
		LEA fontbuf(PC),A6         
		ADDA.W D0,A6
norm		ADD scrlpos(PC),A3
		MOVEQ #no_lines-1,D1
.lp		MOVEM.W (A6)+,D2-d5
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE.W (A5)+,D2 
		MOVE.W (A5)+,D3 
		MOVE.W (A5)+,D4 
		MOVE.W (A5)+,D5 
		ROL.L D6,D2
		ROL.L D6,D3
		ROL.L D6,D4
		ROL.L D6,D5
		MOVEM.W D2-D5,+200(A3)
		MOVEM.W D2-D5,-8(A3)
		ADDQ.L #8,A5
		ADDQ.L #8,A6
		LEA linewid(A3),A3
		DBF D1,.lp

copy_buf	MOVE.L which_buf(PC),A0
		ADD scrlpos(PC),A0
		MOVE.L log_base(PC),A2	screen base
		LEA 160*160(A2),A2

i		SET 0
j		SET 0
		REPT no_lines
		LEA j(A0),A1
		MOVEM.L (A1)+,D0-D6/A4-A6
		MOVEM.L D0-D6/A4-A6,i(A2)
		MOVEM.L (A1)+,D0-D6/A4-A6
		MOVEM.L D0-D6/A4-A6,i+40(A2)
		MOVEM.L (A1)+,D0-D6/A4-A6
		MOVEM.L D0-D6/A4-A6,i+80(A2)
		MOVEM.L (A1)+,D0-D6/A4-A6
		MOVEM.L D0-D6/A4-A6,i+120(A2)
i		SET i+160
j		SET j+linewid
		ENDR
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

scr_point	DC.L text
which_buf	DC.L scbuffer
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0
text		dc.b " TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0
		EVEN
log_base	DS.L 1
		DS.L 1
vbl_timer	DS.W 1

fontbuf		INCBIN TURBRAIN.DAT
old_mfp		DS.L 4	
old_vbl		DS.L 1

		SECTION BSS
		DS.W 8
scbuffer	REPT 4
		DS.B bufsize
		ENDR
		DS.W 8
		DS.L 129
stack		DS.L 1
