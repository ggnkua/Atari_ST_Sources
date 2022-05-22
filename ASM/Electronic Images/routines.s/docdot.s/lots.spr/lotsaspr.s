;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;              'Lets see how many sprites we can do!!'			;
;       Coded by Griff of Electronic Images (of The Inner Circle)	;
; (Written just to annoy every other demo crew in the World.)		;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

no_spr		EQU 140

letsgo		CLR.W -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP	

		MOVE #$2700,SR
		LEA stack,SP
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff
		BSR cls
		BSR shift_em
		BSR gentabs
		LEA old_stuff+32,A0
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
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR

; Main program loop
	
vbl_lp		LEA log_base,A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE vbl_timer(PC),D7
wait_vb1	CMP vbl_timer(PC),D7
		BEQ.S wait_vb1

		MOVE.L log_base,A6
		LEA 16006-2400(A6),A6
		LEA oldxys1,A3
		NOT switch
		BEq cse2
		LEA oldxys2,A3
cse2		MOVEQ #0,D0
		REPT no_spr
		MOVE.L A6,A0
		ADD.W (A3)+,A0
		MOVE.l D0,(A0)		
		MOVE.l D0,160(A0)		
		MOVE.l D0,320(A0)		
		MOVE.l D0,480(A0)		
		MOVE.l D0,640(A0)		
		MOVE.l D0,800(A0)		
		MOVE.l D0,960(A0)		
		MOVE.l D0,1120(A0)		
		MOVE.l D0,1280(A0)		
		MOVE.l D0,1440(A0)		
		MOVE.l D0,1600(A0)		
		MOVE.l D0,1760(A0)		
		MOVE.l D0,1920(A0)		
		MOVE.l D0,2080(A0)		
		MOVE.l D0,2240(A0)		
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
		LEA newxys(PC),A6
		MOVE #no_spr-1,D7
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
		MOVE.W D0,(A6)+
		MOVE.W D1,(A6)+
		DBF D7,calc_lp
		bsr plot

test_key	BTST.B #0,$FFFFFC00.W
		BEQ vbl_lp
		MOVE.B $FFFFFC02.W,D0
nores		CMP.B #$39,D0
		BNE vbl_lp
		jmp out
log_base	DC.L $F0000
phy_base	DC.L $F8000
switch		DS.W 1
vbl_timer	DS.W 1
col1		EQU $730
pal		DC.W $000,col1,$000,$000,$000,$000,$000,$000
		DC.W col1,col1,$000,$000,$000,$000,$000,$000

; Plot all the points onto the screen

plot		MOVE.L log_base(PC),A6
		lea sprites(pc),a5
		LEA 16006-2400(A6),A6
		LEA oldxys1(PC),A3
		TST switch
		BEQ Dcse2
		LEA oldxys2(PC),A3
Dcse2		LEA newxys(PC),A0
		LEA plot_masks+640,A4
		rept no_spr
		MOVE (A0)+,D0
		MOVE.L (A4,D0),D0
		ADD (A0)+,D0
		move.l a6,a2
		adda.w d0,a2
		move.w d0,(A3)+
		SWAP D0
		move.l a5,a1
		adda.w d0,a1
		movem.l (a1)+,d0-d7
		or.l d0,(a2) 
		or.l d1,(160*1)(a2) 
		or.l d2,(160*2)(a2) 
		or.l d3,(160*3)(a2) 
		or.l d4,(160*4)(a2) 
		or.l d5,(160*5)(a2) 
		or.l d6,(160*6)(a2) 
		or.l d0,(14*160)(A2) 
		or.l d1,(13*160)(A2)
		or.l d2,(12*160)(A2) 
		or.l d3,(11*160)(A2) 
		or.l d4,(10*160)(A2) 
		or.l d5,(9*160)(A2) 
		or.l d6,(8*160)(A2)
		or.l d7,(7*160)(A2)
		movem.w (a1)+,d0-d3
		or.w d0,(7*160)(A2)
		or.w d1,(7*160)+8(A2)
		or.w d2,(8*160)(A2)
		or.w d3,(8*160)+8(A2)
		or.w d0,(9*160)(A2)
		or.w d1,(9*160)+8(A2)
		endr
		rts


; Demo exited - Restore mfp/vbl etc

out		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

doubleit	MOVE #511,D2	
doubloop	MOVE.W (A0)+,D0
		MOVE.W 1024-2(A0),D1
		MOVE.W D0,1024-2(A0)
		MOVE.W D1,2048-2(A0)
		MOVE.W D1,3072-2(A0)
		DBF D2,doubloop
		RTS

; Our very own VBL interrupt

my_vbl		ADDQ #1,vbl_timer
		RTE

cls		MOVE.L log_base(PC),A0
		MOVE #4095,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		RTS

shift_em	LEA sprites(PC),A0
		LEA preshifts(PC),A1 
		MOVEQ #14,D7
shift_lp	REPT 8
		MOVEM.W (A0)+,D0-D1
		LSR D0
		ROXR D1
		MOVEM.W D0-D1,(A1)
		ADDQ.L #4,A1
		ENDR
		REPT 2
		MOVEM.W (A0)+,D0-D1
		LSR D0
		ROXR D1
		MOVEM.W D0-D1,(A1)
		ADDQ.L #4,A1
		ENDR
		DBF D7,shift_lp
		RTS

gentabs		LEA plot_masks,A0
		MOVEQ #19,D0
		MOVEQ #0,D2
masklp		MOVEQ #0,D1
		REPT 16
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		ADD #40,d1
		ENDR
		ADDQ.L #8,D2
		DBF D0,masklp
		LEA table1(PC),A0
		BSR doubleit
		LEA table2(PC),A0
		BSR doubleit
		RTS

sprites		DC.L %00000111111000000000000000000000
		DC.L %00011111111110000000000000000000
		DC.L %00111111111111000000000000000000
		DC.L %01111111111111100000000000000000
		DC.L %01111111111111100000000000000000
		DC.L %11111111111111110000000000000000
		DC.L %11111111111111110000000000000000
		DC.L %11111111111111110000000000000000

		DC.L %00111000000000000000000000000000
		DC.L %01111100000000000000000000000000

preshifts	DS.L 2*10*15

		SECTION DATA

table1		INCBIN DOCDOT.S\TABLE1.WF
		DS.W 1024
table2		INCBIN DOCDOT.S\TABLE2.WF
		DS.W 1024
	
databits	
xinc1		DC.W -6
yinc1		DC.W 2
xapart1		DC.W 8
yapart1		DC.W 18
xinc2		DC.W 4
yinc2		DC.W 4
xapart2		DC.W 14
yapart2		DC.W 8 

xy_pos1		DS.L 1
xy_pos2		DS.L 1

		SECTION BSS

oldxys1		DS.W no_spr
oldxys2		DS.W no_spr
newxys		DS.L no_spr

plot_masks	DS.L 320
old_stuff	DS.L 20

		DS.L 149
stack		DS.l 1
