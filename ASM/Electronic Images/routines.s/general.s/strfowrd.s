* Starfield towards you!
* (C) OCT-DEC 1989 Martin Griffiths. 
* Setup various bits and pieces

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		PEA $FFFFFFFF.W
		PEA $FFFFFFFF.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE #$2700,SR
		LEA stack(PC),SP				;local stack
		MOVE.L $70.W,old_vbl
		MOVE.L #my_vbl,$70.W
		MOVE.B #$12,$FFFFFC02.W
clear		MOVE.L log_base(PC),A0
		MOVE #7999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
Set_cols	LEA colours(PC),A0
		LEA old_cols(PC),A1
		LEA $FFFF8240.W,A2
		MOVEQ #7,D0
col_lp	MOVE.L (A2),(A1)+
		MOVE.L (A0)+,(A2)+
		DBF D0,col_lp
Random_gen	LEA seed(PC),A2
		LEA stars(PC),A3
		MOVE #no_strs-1,D4
f_rand_x	BSR Rand
		DIVU #320,D0
		SWAP D0
		SUB #160,D0
		ASL.L	#8,D0			
		MOVE D0,(A3)+
f_rand_y	BSR Rand
		DIVU #200,D0
		SWAP D0
		SUB #100,D0
		ASL.L	#8,D0			
		MOVE D0,(A3)+
		BSR Rand
		AND #$3F,D0
		ADD #192,D0
		MOVE D0,(A3)+
		DBF D4,f_rand_x
Mul_160_crt	LEA mul_160(PC),A0			;create *160 table
		MOVEQ #0,D0
		MOVE #199,D1
mul_lp	MOVE D0,(A0)+
		ADD #160,D0
		DBF D1,mul_lp

gen_masks	LEA plot_masks(PC),A0
		MOVEQ #19,D0
		MOVE #$8000,D1
		MOVEQ #0,D2
masklp	REPT 16
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		ROR #1,D1
		ENDR
		ADDQ.L #8,D2
		DBF D0,masklp
		MOVE #$2300,SR

* This is the main program loop

Star_frame	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S wait_vbl
clear_stars	MOVE.L D1,A0		logbase
		LEA old_pos1(PC),A2	assume case 1
		NOT switch
		BNE.S case_1
case_2	LEA old_pos2(PC),A2	no its case 2!
case_1	MOVE.L A2,A3
		MOVE #no_strs-1,D7	no of stars
		MOVEQ #0,D1
clrstar_lp	MOVE (A2)+,D0
		MOVE.L D1,(A0,D0)
		DBF D7,clrstar_lp

Plot_stars	LEA stars(PC),A1		star co-ords
		LEA mul_160(PC),A4	mul 160 table
		LEA plot_masks(PC),A5	point masks
		MOVE #$FFF0,D6		mask
		MOVE #160,D4		x offset
		MOVE #100,D5		y offset
		MOVE #no_strs-1,D7	no of stars
star_lp	MOVE (A1)+,D0
		MOVE (A1)+,D1
		MOVE (A1),D2
		SUBQ #3,D2			z-3
		MOVE D2,(A1)+
		EXT.L D0			extend sign
		EXT.L D1			ready for divide
		DIVS D2,D0			x/z(perspect)
		DIVS D2,D1			y/z(perspect)
		ADD D4,D0			add offsets
		ADD D5,D1			
		CMP #319,D0			check if
		BHI.S Star_off		star is off
		CMP #199,D1			screen
		BLO.S Plot_star
Star_off	LEA seed(PC),A2		random seed
		MOVE #256,-(A1)		off,then
rand_y	MOVEQ #0,D0			generate new
		MOVE (A2),D0		random positions
		ROL #1,D0
		EOR #54341,D0
		SUBQ #1,D0
		MOVE D0,(A2)
		DIVU #100,D0
		SWAP D0
		SUB #50,D0
		BEQ.S rand_y
		ASL.L	#8,D0
		MOVE D0,-(A1)
rand_x	MOVEQ #0,D0
		MOVE (A2),D0
		ROL #1,D0
		EOR #54341,D0
		SUBQ #1,D0		
		MOVE D0,(A2)
		DIVU #160,D0	
		SWAP D0
		SUB #80,D0
		BEQ.S rand_x
		ASL.L	#8,D0			x*256
		MOVE D0,-(A1)
		ADDQ.L #6,A1
		BRA next_star
Plot_star	ADD D0,D0
		ADD D0,D0
		MOVE.L (A5,D0),D0
		ADD D1,D1
		ADD (A4,D1),D0
		MOVE.L A0,A2
		ADDA.W D0,A2
		MOVE D0,(A3)+		store pos
getmask	SWAP D0
		MOVE D0,D1
		NOT D0
		ASR #2,D2			6right,4left!
		AND D6,D2
		BLE.S col1
		JMP col0(PC,D2)
col0		AND D0,(A2)+
		AND D0,(A2)+
		DBF D7,star_lp
		BRA starsd
		DS.W 2
col1		OR D1,(A2)+
		DBF D7,star_lp
		BRA starsd
		DS.W 3
col2		OR D1,2(A2)
		DBF D7,star_lp
		BRA starsd
		DS.W 2
col3		OR D1,(A2)+
		OR D1,(A2)+
next_star	DBF D7,star_lp		do all points

starsd	CMP.B #$39,$FFFFFC02.W
		BNE Star_frame		

Exit		LEA old_cols(PC),A0
		LEA $FFFF8240.W,A1
		MOVEQ #7,D0
res_lp	MOVE.L (A0)+,(A1)+
		DBF D0,res_lp
		MOVE.L old_vbl(PC),$70.W
		MOVE.B #$8,$FFFFFC02.W
		CLR -(SP)
		TRAP #1			
my_vbl	ADDQ #1,vbl_timer
		RTE

Rand		MOVEQ #0,D0
		MOVE (A2),D0
		ROL #1,D0
		EOR #54341,D0
		SUBQ #1,D0		
		MOVE D0,(A2)
		RTS

no_strs	EQU 260
seed		DC.W $9653
log_base 	DC.L $70300
phy_base 	DC.L $78000
switch	DS.W 1
vbl_timer	DS.W 1
stars 	DS.W no_strs*3
old_pos1	DS.W no_strs
old_pos2	DS.W no_strs
colours	DC.W $000,$777,$555,$333,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000
		SECTION BSS
mul_160	DS.W 200
old_cols	DS.W 16
old_vbl	DS.L 1
plot_masks	DS.L 320
		DS.L 149
stack		
