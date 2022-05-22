; Coo, these are the best dotty waves I have ever seen
; programmed by Griff, of course (who else could do it?!)

		SECTION TEXT

		CLR.W -(SP)
		PEA $FFFFFFFF.W
		PEA $FFFFFFFF.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	

; The REAL code starts here

		MOVE #$2700,SR
		LEA stack,SP
		LEA $70300,A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		LEA table1(PC),A0
		BSR doubleit
		LEA table2(PC),A0
		BSR doubleit

gen_masks	LEA plot_masks,A0
		MOVEQ #19,D0
		MOVE #$8000,D1
		MOVEQ #0,D2
masklp	REPT 16
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		ROR #1,D1
		ENDR
		ADDQ.W #8,D2
		DBF D0,masklp
		MOVEQ #1,D0
		BSR music+28
		MOVE.L #$00000777,$FFFF8240.W
		MOVE.W #$777,$FFFF8248.W
		MOVE #$2300,SR

; Main program loop

vbl_lp	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		not $ffff8240.w
		MOVE vbl_timer(PC),D7
wait_vb1	CMP vbl_timer(PC),D7
		BEQ.S wait_vb1
		not $ffff8240.w
clear_old	MOVE.L log_base(PC),A0
		LEA 16000-1280(A0),A0
		MOVEQ #0,D1
		NOT switch
		BEQ clear_em2
clear_em1	REPT 700
		MOVE.W D1,0(A0)
		ENDR
		BRA Calc_points
clear_em2	REPT 700
		MOVE.W D1,0(A0)
		ENDR

; Combine Sinus tables to create x/y co-ords.
; unoptimised as yet...

Calc_points	LEA table1(PC),A1
		LEA 2048(A1),A2
		LEA table2(PC),A3
		LEA 2048(A3),A4
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE #$3ff,D4
		MOVE xapart1(PC),addxapart1+2
		MOVE yapart1(PC),addyapart1+2
		MOVE xapart2(PC),addxapart2+2
		MOVE yapart2(PC),addyapart2+2
		MOVEM.W xy_pos1(PC),D0-D1
		ADD xinc1(pc),D0
		ADD yinc1(pc),D1
		AND D4,D0
		AND D4,D1
		MOVEM D0-D1,xy_pos1
		ADD.W D0,A1
		ADD.W D1,A2
		MOVEM.W xy_pos2(PC),D0-D1
		ADD xinc2(PC),D0
		ADD yinc2(PC),D1
		AND D4,D0
		AND D4,D1
		MOVEM.W D0-D1,xy_pos2
		ADD.W D0,A3
		ADD.W D1,A4
		MOVE.L log_base(PC),A6
		LEA 16000-1280(A6),A6
		LEA clear_em1+2(PC),A0
		TST switch
		BNE.S not1
		LEA clear_em2+2(PC),A0
not1		LEA plot_masks+640(PC),A5
		MOVE #700-1,D7
calc_lp	
addxapart1	ADD #0,D5
addyapart1	ADD #0,D6
		AND D4,D5
		AND D4,D6
		MOVE (A1,D5),D0
		MOVE (A2,D6),D1
addxapart2	ADD #0,D2
addyapart2	ADD #0,D3
		AND D4,D2
		AND D4,D3
		ADD.W (A3,D2),D0
		ADD.W (A4,D3),D1
		MOVE.L (A5,D0),D0
		ADD D0,D1
		SWAP D0
		MOVE.W D1,(A0)
		OR D0,(A6,D1.W)
		ADDQ.W #4,A0
		DBF D7,calc_lp

		LEA addtable(PC),A2
		MOVE.L log_base(PC),A0
		LEA (192*160)(A0),A0
		MOVEQ #0,D0
		MOVE xapart1(PC),D0
		BSR num_print
		MOVE yapart1(PC),D0
		BSR num_print
		MOVE xinc1(PC),D0
		BSR num_print
		MOVE yinc1(PC),D0
		BSR num_print

		MOVE xapart2(PC),D0
		BSR num_print
		MOVE yapart2(PC),D0
		BSR num_print
		MOVE xinc2(PC),D0
		BSR num_print
		MOVE yinc2(PC),D0
		BSR num_print

test_key	BTST.B #0,$FFFFFC00.W
		BEQ vbl_lp
		MOVE.B $FFFFFC02.W,D0

		CMP.B #$48,D0
		BNE.S notua
		ADDQ #2,yapart1
		BRA vbl_lp
notua		CMP.B #$50,D0
		BNE.S notda
		SUBQ #2,yapart1
		BRA vbl_lp
notda		CMP.B #$4D,D0
		BNE.S notra
		ADDQ #2,xapart1
		BRA vbl_lp
notra		CMP.B #$4B,D0
		BNE.S notla
		SUBQ #2,xapart1
		BRA vbl_lp
notla		CMP.B #$63,D0
		BNE.S notxi1
		SUBQ #2,xinc1
		BRA vbl_lp
notxi1	CMP.B #$64,D0
		BNE.S notxi2
		ADDQ #2,xinc1
		BRA vbl_lp
notxi2	CMP.B #$65,D0
		BNE.S notxi3
		SUBQ #2,yinc1
		BRA vbl_lp
notxi3	CMP.B #$66,D0
		BNE.S notxi4
		ADDQ #2,yinc1
		BRA vbl_lp
notxi4	CMP.B #$68,D0
		BNE.S notua2
		ADDQ #2,yapart2
		BRA vbl_lp
notua2	CMP.B #$6E,D0
		BNE.S notda2
		SUBQ #2,yapart2
		BRA vbl_lp
notda2	CMP.B #$6C,D0
		BNE.S notra2
		ADDQ #2,xapart2
		BRA vbl_lp
notra2	CMP.B #$6A,D0
		BNE.S notla2
		SUBQ #2,xapart2
		BRA vbl_lp
notla2	CMP.B #$4A,D0
		BNE.S notxi12
		SUBQ #2,xinc2
		BRA vbl_lp
notxi12	CMP.B #$4E,D0
		BNE.S notxi22
		ADDQ #2,xinc2
		BRA vbl_lp
notxi22	CMP.B #$70,D0
		BNE.S notxi32
		SUBQ #2,yinc2
		BRA vbl_lp
notxi32	CMP.B #$71,D0
		BNE.S notxi42
		ADDQ #2,yinc2
		BRA vbl_lp
notxi42	CMP.B #$1C,D0
		BNE.S nores
		CLR D0
		MOVE D0,xinc1
		MOVE D0,yinc1
		MOVE D0,xinc2
		MOVE D0,yinc2
		MOVE D0,xapart1
		MOVE D0,yapart1
		MOVE D0,xapart2
		MOVE D0,yapart2
		BRA vbl_lp
nores		CMP.B #$39,D0
		BNE vbl_lp

; Demo exited - Restore mfp/vbl etc

		MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		MOVEQ #0,D0
		BSR music+28
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

; Our very own VBL interrupt

my_vbl	BSR music+28+6
		ADDQ #1,vbl_timer
		RTE
doubleit	MOVE #511,D2	
doubloop	MOVE.W (A0)+,D0
		MOVE.W 1024-2(A0),D1
		MOVE.W D0,1024-2(A0)
		MOVE.W D1,2048-2(A0)
		MOVE.W D1,3072-2(A0)
		DBF D2,doubloop
		RTS
* Hex number printer

num_print	MOVE.W D0,D1
		LSR #8,D1
		LSR #4,D1
		AND #15,D1
		BSR.S	digi_prin
		MOVE.W D0,D1
		LSR #8,D1
		AND #15,D1
		BSR.S	digi_prin
		MOVE.W D0,D1
		LSR #4,D1
		AND #15,D1
		BSR.S	digi_prin
		MOVE.W D0,D1
		AND #15,D1

* Print a single digit at A0
* D1/A1 smashed.

digi_prin	LSL #3,D1
		LEA font_data(PC,D1),A1
		MOVE.B (A1)+,(A0)		
		MOVE.B (A1)+,160(A0)
		MOVE.B (A1)+,320(A0)
		MOVE.B (A1)+,480(A0)
		MOVE.B (A1)+,640(A0)
		MOVE.B (A1)+,800(A0)
		MOVE.B (A1)+,960(A0)
		ADD (A2)+,A0
		RTS

addtable	DC.w 1,7,1,8,7,1,7,8,1,7,1,8,7,1,7,9,7,1,7,8,1,7,1,8,7,1,7,8,1,7,1,7,1,7
		EVEN

font_data	dc.b	%11111110
		dc.b	%11000010
		dc.b	%10100010
		dc.b	%10010010
		dc.b	%10001110
		dc.b	%10000110
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00001000
		dc.b	%00011000
		dc.b	%00011000
		dc.b	%00011000
		dc.b	%00011000
		dc.b	%00000000
	
		dc.b	%11111110
		dc.b	%10000010
		dc.b	%00000010
		dc.b	%11111110
		dc.b	%10000000
		dc.b	%10000000
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%11111100
		dc.b	%00000100
		dc.b	%00000100
		dc.b	%11111100
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%11111100
		dc.b	%10000100
		dc.b	%10000100
		dc.b	%11111111
		dc.b	%00001100
		dc.b	%00001100
		dc.b	%00001100
		dc.b	%00000000
	
		dc.b	%11111110
		dc.b	%10000000
		dc.b	%10000000
		dc.b	%11111110
		dc.b	%00000110 
		dc.b	%10000110
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%11111110
		dc.b	%10000000
		dc.b	%10000000
		dc.b	%11111110
		dc.b	%10000110
		dc.b	%10000110
		dc.b	%11111110
		dc.b	%00000000
		
		dc.b	%11111110
		dc.b	%00000010
		dc.b	%00000010
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%00000000
	
		dc.b	%01111100
		dc.b	%01000100
		dc.b	%01000100
		dc.b	%11111110
		dc.b	%10000110
		dc.b	%10000110
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%11111110
		dc.b	%10000010
		dc.b	%10000010
		dc.b	%11111110
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%00000110
		dc.b	%00000000

		dc.b	%01111110
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%11111111
		dc.b	%11000001
		dc.b	%11000001
		dc.b	%11000001
		dc.b	%00000000

		dc.b	%01111110
		dc.b	%01000010
		dc.b	%01000010
		dc.b	%11111111
		dc.b	%11000001
		dc.b	%11000001
		dc.b	%11111111
		dc.b	%00000000
	
		dc.b	%11111111
		dc.b	%10000001
		dc.b	%10000000
		dc.b	%11000000
		dc.b	%11000000
		dc.b	%11000001
		dc.b	%11111111
		dc.b	%00000000
	
		dc.b	%11111110
		dc.b	%10000001
		dc.b	%10000001
		dc.b	%11000001
		dc.b	%11000001
		dc.b	%11000001
		dc.b	%11111110
		dc.b	%00000000
	
		dc.b	%11111111
		dc.b	%10000000
		dc.b	%10000000
		dc.b	%11111111
		dc.b	%11000000
		dc.b	%11000000
		dc.b	%11111111
		dc.b	%00000000
	
		dc.b	%11111111
		dc.b	%10000000
		dc.b	%10000000
		dc.b	%11111111
		dc.b	%11000000
		dc.b	%11000000
		dc.b	%11000000
		dc.b	%00000000

		SECTION DATA

log_base	DC.L $170300
phy_base	DC.L $178000
switch		DS.W 1
vbl_timer	DS.W 1
table1		INCBIN TABLE1.WF
		DS.W 2048
table2		INCBIN TABLE2.WF
		DS.W 2048
music
		INCBIN DOCDOTS.CZI
databits	
no_dots 	EQU 700
xapart1		DC.W $0
yapart1		DC.W $0
xinc1		DC.W $0
yinc1		DC.W $0
xapart2		DC.W $0
yapart2		DC.W $0
xinc2		DC.W $0
yinc2		DC.W $0

		SECTION BSS

xy_pos1		DS.L no_dots
xy_pos2		DS.L no_dots
plot_masks	DS.L 320
old_mfp		DS.L 4
		DS.L 149
stack		DS.L 1
