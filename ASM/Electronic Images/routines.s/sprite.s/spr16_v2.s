; 16*16 Sprite Rout. (with mouse movement to test it)

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
		ENDC

mans_start	MOVE #$2700,SR
		LEA stack(PC),SP
		MOVE.L log_base(PC),A0
		BSR cls
		MOVE.L phy_base(PC),A0
		BSR cls
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$15,D0
		BSR write_ikbd
		MOVE #9,D0
		BSR write_ikbd
		MOVE #1,D0
		BSR write_ikbd
		MOVE #$3F,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #199,D0
		BSR write_ikbd
set_mouse	MOVEQ #$E,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #160,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #100,D0
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
		MOVE #$D,D0
		BSR write_ikbd

		MOVE #$2300,SR
		BSR flush

; Main program vbl loop starts here.

vbl_lp		BSR Swap_Screens
		NOT $FFFF8240.W
		BSR Wait_Vbl
		NOT $FFFF8240.W
		BSR Clear_Old
		BSR Print_XYinfo
		BSR Draw_Sprites

		CMP.B #$39,key
		BNE vbl_lp

restore		BSR flush
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

; Clear Screen -> A0

cls		MOVE #1999,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		RTS
	
; Swap those screens!

Swap_Screens	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Wait for 1 Vbl.

Wait_Vbl	MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S .wait_vbl
		RTS

; Clear Old Sprites.

Clear_Old	LEA old_xys1(PC),A1
		TST switch
		BEQ.S clr_old
		LEA old_xys2(PC),A1
clr_old		MOVE.L log_base(PC),A0
		MOVE.L A1,A6
		MOVEQ #12-1,D7
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
clr_lp		MOVE.L A0,A2
		ADD (A1)+,A2
i		SET 0
		REPT 8
		MOVEM.L D0-D3,i(A2)
		MOVEM.L D0-D3,i+160(A2)
i		SET i+320
		ENDR
		DBF D7,clr_lp
		RTS

; Draw new Sprites
		
Draw_Sprites	LEA xymodbuf(PC),A3
		MOVEM.L $78+($28*6)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*6)(A3)
		MOVEM.L $78+($28*5)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*5)(A3)
		MOVEM.L $78+($28*4)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*4)(A3)
		MOVEM.L $78+($28*3)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*3)(A3)
		MOVEM.L $78+($28*2)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*2)(A3)
		MOVEM.L $78+($28*1)(A3),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+($28*1)(A3)
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
i		SET 0
		REPT 12
		MOVE i(A3),D0
		MOVE i+2(A3),D1
		BSR draw
i		SET i+24
		ENDR
		RTS

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
		MOVEQ #-1,D6
		LSR.W D2,D6
		MOVE.W D6,D7
		SWAP D6
		MOVE.W D7,D6

		MOVE.L D6,D7
		NOT.L D7

sprite_lp1	REPT 16
		LEA (A1),A2
		MOVEQ #-1,D3
		MOVE (A0)+,D3
		MOVEM.L (A0)+,D4-D5
		ROR.L D2,D3
		ROR.L D2,D4
		ROR.L D2,D5
		AND.W D3,(A1)+
		AND.W D3,(A1)+
		AND.W D3,(A1)+
		SWAP D3
		AND.L D3,(A1)+
		AND.W D3,(A1)+
		AND.W D3,(A1)+
		AND.W D3,(A1)+

		MOVE.L D4,D0		; write START chunk
		MOVE.L D5,D1
		AND.L D6,D0
		AND.L D6,D1
		AND.L D7,D4		; write END chunk
		AND.L D7,D5
		SWAP D4
		SWAP D5
		OR.L D0,(A2)+
		OR.L D1,(A2)+
		OR.L D4,(A2)+
		OR.L D5,(A2)+
		LEA 160-16(A1),A1
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

; Print up x/y information

Print_XYinfo	MOVE.L log_base(PC),A0
		MOVEQ #0,D0
		MOVE mousex(PC),D0
		BSR num_print
		MOVE.L log_base(PC),A0
		LEA 24(A0),A0
		MOVEQ #0,D0
		MOVE mousey(PC),D0
		BSR num_print
		RTS

; Routine to print an unsigned word in decimal.D0.L contains the no.
; to be printed. D0-D1/A0-A1 are smashed! 

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
		CMP.B #$F7,D0
		BEQ.S start_mouse
		MOVE.B D0,key
end		MOVE (SP)+,D0
endi		BCLR #6,$FFFFFA11.W
		RTE

start_mouse	MOVE.L #mouseb1,$118.W
		BRA.S end
mouseb1		MOVE.L #mouseb2,$118.W
		MOVE.B $FFFFFC02.W,mousex-1
		BRA.S endi
mouseb2		MOVE.L #mouseb3,$118.W
		MOVE.B $FFFFFC02.W,mousex
		BRA.S endi
mouseb3		MOVE.L #mouseb4,$118.W
		MOVE.B $FFFFFC02.W,mousex+1
		BRA.S endi
mouseb4		MOVE.L #mouseb5,$118.W
		MOVE.B $FFFFFC02.W,mousex+2
		BRA.S endi
mouseb5		MOVE.L #key_rout,$118.W
		MOVE.B $FFFFFC02.W,mousex+3
		BRA.S endi

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

; The vbl sends command to the ikbd to make it report the mouse xy.

vbl		MOVE D0,-(SP)
		ADDQ #1,vbl_timer
		MOVE #$D,D0
		BSR write_ikbd
		MOVE (SP)+,D0
		RTE


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

pal		DC.L $00000013
		DC.L $00250037
		DC.L $01220321
		DC.L $04310542
		DC.L $05550555
		DC.L $05550555
		DC.L $05550555
		DC.L $05550555

sprite		dc.l	$07E00000,$00000000,$1C3803C0,$00000000,$300C0FF0 
		dc.l	$00000000,$63961FE8,$00080000,$46B23F4C,$000E0000 
		dc.l	$CD723E8C,$001F0000,$9AB57D4E,$001F0000,$95757A8E 
		dc.l	$001F0000,$9AED751E,$003F0000,$85C97A3E,$007F0000 
		dc.l	$CF9A307C,$00FF0000,$5F3220FC,$07FE0000,$60E41FF8 
		dc.l	$1FFE0000,$33880FF0,$0FFC0000,$1C3003C0,$0FF80000 
		dc.l	$03C00000,$07E00000 


sprite1		DS.W 5*16
old_vbl		DC.L 0
old_key		DC.L 0
old_mfp		DC.L 0
log_base	DC.L $F0300		
phy_base	DC.L $F8000		
switch		DC.W 0
vbl_timer	DC.W 0
old_xys1	DS.W 50
old_xys2	DS.W 50
key		DC.W 0
mousexy		DC.W 0
mousex		DC.W 160
mousey		DC.W 100  
xymodbuf	REPT 100
		DC.W 160,100,160,100
		ENDR
		SECTION BSS
		DS.L 199
stack		DS.L 2
				