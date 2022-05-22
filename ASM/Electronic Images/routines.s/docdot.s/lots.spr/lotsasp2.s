		CLR.W -(SP)
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
		LEA $70300,A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
gen_masks	LEA offs,A0
		MOVEQ #19,D0
		MOVEQ #0,D2
masklp	MOVEq #0,D1
		REPT 16
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		add #32,d1
		ENDR
		ADDQ.L #8,D2
		DBF D0,masklp

		LEA sprites,A0
		LEA preshifts,A1 
		MOVEQ #14,D7
shift_lp	REPT 8
		MOVEM.W (A0)+,D0-D1
		LSR D0
		ROXR D1
		MOVEM.W D0-D1,(A1)
		ADDQ.L #4,A1
		ENDR	
		DBF D7,shift_lp

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


		MOVE.W #$000,$FFFF8240.W
		MOVE.W #$777,$FFFF8242.W
		MOVE.W #$777,$FFFF8244.W
		MOVE.W #$777,$FFFF8246.W
		MOVE.W #$777,$FFFF8248.W
		MOVE.W #$777,$FFFF824A.W
		MOVE.W #$777,$FFFF824C.W
		MOVE.W #$777,$FFFF824E.W
		MOVE.W #$777,$FFFF8250.W
		MOVE.W #$777,$FFFF8252.W
		MOVE.W #$777,$FFFF8254.W
		MOVE.W #$777,$FFFF8256.W
		MOVE.W #$777,$FFFF8258.W
		MOVE.W #$777,$FFFF825A.W
		MOVE.W #$777,$FFFF825C.W
		MOVE.W #$777,$FFFF825E.W
		MOVE #$2300,SR

; Combine Sinus tables to create x/y co-ords.

		move #384,-(sp)
		LEA offs+640,A5
		LEA newxys,A6
preloop
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
		MOVE #176-1,D7
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
		ADD d1,D0
		move.l d0,(A6)+
		DBF D7,calc_lp
		subq #1,(sp)
		bne preloop
		addq.w #2,sp
		bra.s vbl_lp
databits	
xinc1		DC.W -6
yinc1		DC.W 2
xapart1	DC.W 8
yapart1	DC.W 18
xinc2		DC.W 4
yinc2		DC.W 4
xapart2	DC.W 14
yapart2	DC.W 8 

xy_pos1	DS.L 1
xy_pos2	DS.L 1

; Main program loop

vbl_lp	LEA log_base,A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		not $ffff8240.w		
		MOVE vbl_timer,D7
wait_vb1	CMP vbl_timer,D7
		BEQ.S wait_vb1
		not $ffff8240.w		

		MOVE.L log_base,A6
		LEA 16006-2400(A6),A6
		LEA oldxys1,A3
		NOT switch
		BEq cse2
		LEA oldxys2,A3
cse2		MOVEQ #0,D0
		REPT 176
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

		bsr plot

test_key	BTST.B #0,$FFFFFC00.W
		BEQ vbl_lp
		MOVE.B $FFFFFC02.W,D0
nores		CMP.B #$39,D0
		BNE vbl_lp
		jmp out

frameno		dc.w 0

plot		MOVE.L log_base(PC),A6
		lea sprites(pc),a5
		LEA 16006-2400(A6),A6
		LEA oldxys1(PC),A3
		TST switch
		BEQ Dcse2
		LEA oldxys2(PC),A3
Dcse2		LEA newxys(PC),A0
		move frameno(pc),d0
		addq #1,d0
		cmp #384,d0
		bne.s notyetsucker
		clr d0
notyetsucker	move d0,frameno
		mulu #176*4,d0
		add.l d0,a0
		rept 176
		move.l a5,a1
		adda.w (a0)+,a1
		move.w (A0)+,D0
		move.l a6,a2
		adda.w d0,a2
		move.w d0,(A3)+
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
		endr
		rts


; Demo exited - Restore mfp/vbl etc

out		MOVE #$2700,SR
		LEA old_mfp(PC),A0
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

my_vbl	ADDQ #1,vbl_timer
		RTE

sprites	DC.L %00000111111000000000000000000000
		DC.L %00011111111110000000000000000000
		DC.L %00111111111111000000000000000000
		DC.L %01111111111111100000000000000000
		DC.L %01111111111111100000000000000000
		DC.L %11111111111111110000000000000000
		DC.L %11111111111111110000000000000000
		DC.L %11111111111111110000000000000000

preshifts	DS.L 2*8*15

		SECTION DATA

log_base	DC.L $70300
phy_base	DC.L $78000
switch	DS.W 1
vbl_timer	DS.W 1
table1	INCBIN A:\DOCDOT.S\TABLE1.WF
		DS.W 1024
table2	INCBIN  A:\DOCDOT.S\TABLE2.WF
		DS.W 1024
	

		SECTION BSS
oldxys1	DS.W 176
oldxys2	DS.W 176
offs		DS.L 320

old_mfp	DS.L 4
		DS.L 149
stack		DS.l 1
newxys
