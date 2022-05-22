* Keyboard\mouse handler demo

init		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA stack(PC),SP
cls		MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
set_pal	MOVE #$8240,A0
		MOVE.L #$00000013,(A0)+
		MOVE.L #$00250037,(A0)+
		MOVE.L #$01220321,(A0)+
		MOVE.L #$04310542,(A0)+
		MOVE.L #$05550555,(A0)+
		MOVE.L #$05550555,(A0)+
		MOVE.L #$05550555,(A0)+
		MOVE.L #$05550555,(A0)+
		MOVE #$2700,SR
		MOVEq #$15,D0
		BSR write_ikbd
		MOVEq #8,D0
		BSR write_ikbd
		BSR init_sprite
		MOVE.L $70.W,old_vbl
		MOVE.L $118.W,old_key
		MOVE.L #vbl,$70.W
		MOVE.L #key_rout,$118.W
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$40,$FFFFFA09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$40,$FFFFFA15.W
		BCLR #3,$FFFFFA17.W
		MOVE #$2300,SR
		BSR flush

* Main program vbl loop starts here.

vbl_lp	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S wait_vbl
		NOT switch

* Clear old sprites

		LEA old_xys1(PC),A1
		TST switch
		BEQ.S clr_old
		LEA old_xys2(PC),A1
clr_old	MOVE.L log_base(PC),A0
		MOVE.L A1,A6
		MOVEQ #5-1,D7
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
clr_lp	MOVE.L A0,A2
		ADD (A1)+,A2
i		SET 0
		REPT 16
		MOVEM.L D0-D3,i(A2)
i		SET i+160
		ENDR
		DBF D7,clr_lp

* Print up x/y information

		MOVE.L log_base(PC),A0
		MOVEQ #0,D0
		MOVE mousex(PC),D0
		BSR num_print
		MOVE.L log_base(PC),A0
		LEA 24(A0),A0
		MOVEQ #0,D0
		MOVE mousey(PC),D0
		BSR num_print
		
* Draw new Sprites
		
draw_new	LEA xymodbuf(PC),A3
		MOVEM.L $78(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C(A3)
		MOVEM.L $50(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$54(A3)
		MOVEM.L $28(A3),D0-D7/A0-A1
		MOVEM.L D0-D7/A0-A1,$2C(A3)
		MOVEM.L (A3),D0-D7/A0-A1
		MOVEM.L D0-D7/A0-A1,4(A3)
		MOVE mousex(PC),D0
		MOVE mousey(PC),D1
		MOVE D0,(A3)
		MOVE D1,2(A3)
		BSR draw
		MOVE 40(A3),D0
		MOVE 42(A3),D1
		BSR draw
		MOVE 80(A3),D0
		MOVE 82(A3),D1
		BSR draw
		MOVE 120(A3),D0
		MOVE 122(A3),D1
		BSR draw
		MOVE 160(A3),D0
		MOVE 162(A3),D1
		BSR draw
		
		CMP.B #$39,key
		BNE vbl_lp

restore	BSR flush
		MOVE #$2700,SR
		MOVEQ #$8,D0
		BSR write_ikbd
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L old_vbl(PC),$70.W
		MOVE.L old_key(PC),$118.W
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		move #$2300,sr
		CLR -(SP)
		TRAP #1

*************************************

* Keyboard/Mouse handler
* interrupt routine...

key_rout	MOVE #$2500,SR
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0
		BEQ.S end
		BTST #0,D0
		BEQ.S end
key_read	MOVE.B $FFFFFC02.W,D0
		CMP.B #$F8,D0
		BEQ.S start_mouse
		MOVE.B D0,key
end		MOVE (SP)+,D0
endi		RTE

start_mouse	MOVE.L #mouseb1,$118.W
		BRA.S end
mouseb1	MOVE.W D0,-(SP)
		MOVE.B $FFFFFC02.W,D0
		EXT.W D0
		ADD.W D0,mousex
		MOVE.W (SP)+,D0
		MOVE.L #mouseb2,$118.W
		RTE
mouseb2	MOVE.W D0,-(SP)
		MOVE.B $FFFFFC02.W,D0
		EXT.W D0
		ADD.W D0,mousey
		MOVE.W (SP)+,D0
		MOVE.L #key_rout,$118.W
		RTE

*************************************

write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

vbl		ADDQ #1,vbl_timer
		MOVE.L D0,-(SP)
		moveq #$12,d0
		bsr write_ikbd
	
		MOVE #2000,D0
.lp		DBF D0,.lp

		MOVE #$2700,SR
		MOVE #1000,D0
.lp1		DBF D0,.lp1
		moveq #$8,d0
		bsr write_ikbd

		MOVE.L (SP)+,D0
		RTE

* Draw sprite - real time shift rout

draw		LEA sprite1(PC),A0
		MOVE.L log_base(PC),A1
		MOVE D0,D2
		MULU #160,D1
		LSR #1,D0
		AND #$FFF8,D0
		ADD D0,D1
		MOVE D1,(A6)+
		ADDA D1,A1
		CMP #319-16,D2
		BHI clip_sprite
		AND #15,D2
sprite_lp1	REPT 16
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #-1,D1
		MOVE (A0)+,D1
		MOVE (A0)+,D3
		MOVE (A0)+,D4
		MOVE (A0)+,D5
		MOVE (A0)+,D6
		ROR.L D2,D3
		ROR.L D2,D4
		ROR.L D2,D5
		ROR.L D2,D6
		ROR.L D2,D1
		AND D1,(A1)
		OR D3,(A1)+
		AND D1,(A1)
		OR D4,(A1)+
		AND D1,(A1)
		OR D5,(A1)+
		AND D1,(A1)
		OR D6,(A1)+
		SWAP D4
		MOVE D4,D3
		SWAP D6
		MOVE D6,D5
		MOVE.L D1,D4
		SWAP D1
		MOVE D1,D4
		AND.L D4,(A1)
		OR.L D3,(A1)+
		AND.L D4,(A1)
		OR.L D5,(A1)
		LEA 148(A1),A1
		ENDR
		RTS

clip_sprite	AND #15,D2
		REPT 16
		MOVEQ #-1,D3
		MOVE.W (A0)+,D3
		MOVEM.W (A0)+,D4-D7
		LSR.W D2,D4
		LSR.W D2,D5
		LSR.W D2,D6
		LSR.W D2,D7
		LSR.L D2,D3
		AND D3,(A1)
		OR D4,(A1)+
		AND D3,(A1)
		OR D5,(A1)+
		AND D3,(A1)
		OR D6,(A1)+
		AND D3,(A1)
		OR D7,(A1)
		LEA 154(A1),A1
		ENDR
		RTS

* Routine to print an unsigned word
* in decimal.D0.L contains the no.
* to be printed.
* D0-D1/A0-A1 smashed!

num_print	DIVU #10000,D0
		BSR.S	digi_prin
		ADDQ.L #1,A0
		CLR D0
		SWAP D0
		DIVU #1000,D0
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0
		SWAP D0
		DIVU #100,D0
		BSR.S	digi_prin
		ADDQ.L #1,A0
		CLR D0
		SWAP D0
		DIVU #10,D0
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0
		SWAP D0

digi_prin	MOVE D0,D1
		LSL #3,D1
		LEA font_data(PC,D1),A1
		MOVE.B (A1)+,(A0)		
		MOVE.B (A1)+,160(A0)
		MOVE.B (A1)+,320(A0)
		MOVE.B (A1)+,480(A0)
		MOVE.B (A1)+,640(A0)
		MOVE.B (A1)+,800(A0)
		MOVE.B (A1)+,960(A0)
		MOVE.B (A1)+,1120(A0)
		RTS

font_data	DC.L $7CC6C600,$C6C67C00
		DC.L $18181800,$18181800
		DC.L $7C06067C,$C0C07C00
		DC.L $7C06067C,$06067C00
		DC.L $C6C6C67C,$06060600
		DC.L $7CC0C07C,$06067C00
		DC.L $7CC0C07C,$C6C67C00
		DC.L $7C060600,$06060600
		DC.L $7CC6C67C,$C6C67C00
		DC.L $7CC6C67C,$06067C00

init_sprite	LEA sprite(PC),A0
		LEA sprite1(PC),A1
		MOVEQ #15,D7
inilp		MOVEM.W (A0)+,D1-D4
		MOVE D1,D0
		OR D2,D0
		OR D3,D0
		OR D4,D0
		NOT D0
		MOVEM.W D0-D4,(A1)
		LEA 10(A1),A1
		DBF D7,inilp 
		RTS

sprite	INCBIN SPRITE.DAT
sprite1	DS.W 5*16
old_vbl	DC.L 0
old_key	DC.L 0
old_mfp	DC.L 0
log_base	DC.L $70300		
phy_base	DC.L $78000		
switch	DC.W 0
vbl_timer	DC.W 0
old_xys1	DS.W 50
old_xys2	DS.W 50
key		DC.W 0
mousexy	DC.W 0
mousex	DC.W 160
mousey	DC.W 100  
xymodbuf	REPT 60
		DC.W 160
		DC.W 100 
		ENDR
		SECTION BSS
		DS.L 99
stack
				