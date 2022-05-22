* Normal 32*32 scroller which takes
* only about 22% processor time.

Quck_scrl	DC.W $A00A
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA my_stack(PC),SP
Pre_shift	LEA font(PC),A0
		LEA buf(PC),A1
		LEA $78000,A6
		MOVEQ #0,D0
		MOVEQ #28,D3
charshft_lp	LEA (A6),A2
		MOVEQ #31,D1
cpy1_lp	MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L (A0)+,(A2)+
		MOVE.L (A0)+,(A2)+
		MOVE.L (A0)+,(A2)+
		MOVE.L (A0)+,(A2)+
		DBF D1,cpy1_lp
		LEA (A6),A2
		MOVEQ #63,D1
cpy2_lp	MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		DBF D1,cpy2_lp
shift8	LEA (A6),A2
		MOVEQ #31,D1
shift_lp	MOVEP.L 1(A2),D2
		MOVEP.L D2,(A2)
		MOVEP.L 8(A2),D2
		MOVEP.L D2,1(A2)
		MOVEP.L 9(A2),D2
		MOVEP.L D2,8(A2)
		MOVEP.L 16(A2),D2
		MOVEP.L D2,9(A2)
		MOVEP.L 17(A2),D2
		MOVEP.L D2,16(A2)
		MOVEP.L D0,17(A2)
		LEA 24(A2),A2
		DBF D1,shift_lp
		LEA (A6),A2
		MOVEQ #63,D1
cpy3_lp	MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		DBF D1,cpy3_lp
		DBF D3,charshft_lp

clear_scr	MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cl_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cl_lp
		MOVE.L $70.W,old_vbl
		MOVE.L #vbl,$70.W

vb_lp		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE vbl_timer(PC),D0
wait_vb	CMP vbl_timer(PC),D0
		BEQ.S wait_vb
		CLR offset
		NOT switch
		BEQ.S print_chars
		MOVE #768,offset
print_chars	MOVE.L scrlp(PC),A0
		LEA char_tab(PC),A1
		MOVE.L log_base(PC),A3
		LEA offset(PC),A4
		
first_char	MOVE scrx(PC),D0
		CMP #4,D0
		BNE.S which_clip
		LEA 1(A0),A0
		TST.B 11(A0)
		BNE.S no_wrap
		LEA text(PC),A0
no_wrap	MOVE.L A0,scrlp		
		MOVEQ #0,D0
		MOVE D0,scrx
which_clip	CLR D1
		MOVE.B (A0)+,D1
		ADD D1,D1
		ADD D1,D1
		MOVE.L (A1,D1),A2
		ADD (A4),A2
		CMP #2,D0
		BGE first_2
first_1	MOVEM.L 8(A2),D0-D3
		MOVEM.L D0-D3,(A3)
		MOVEM.L 32(A2),D0-D3
		MOVEM.L D0-D3,160(A3)
		MOVEM.L 56(A2),D0-D3
		MOVEM.L D0-D3,320(A3)
		MOVEM.L 80(A2),D0-D3
		MOVEM.L D0-D3,480(A3)
		MOVEM.L 104(A2),D0-D3
		MOVEM.L D0-D3,640(A3)
		MOVEM.L 128(A2),D0-D3
		MOVEM.L D0-D3,800(A3)
		MOVEM.L 152(A2),D0-D3
		MOVEM.L D0-D3,960(A3)
		MOVEM.L 176(A2),D0-D3
		MOVEM.L D0-D3,1120(A3)
		MOVEM.L 200(A2),D0-D3
		MOVEM.L D0-D3,1280(A3)
		MOVEM.L 224(A2),D0-D3
		MOVEM.L D0-D3,1440(A3)
		MOVEM.L 248(A2),D0-D3
		MOVEM.L D0-D3,1600(A3)
		MOVEM.L 272(A2),D0-D3
		MOVEM.L D0-D3,1760(A3)
		MOVEM.L 296(A2),D0-D3
		MOVEM.L D0-D3,1920(A3)
		MOVEM.L 320(A2),D0-D3
		MOVEM.L D0-D3,2080(A3)
		MOVEM.L 344(A2),D0-D3
		MOVEM.L D0-D3,2240(A3)
		MOVEM.L 368(A2),D0-D3
		MOVEM.L D0-D3,2400(A3)
		MOVEM.L 392(A2),D0-D3
		MOVEM.L D0-D3,2560(A3)
		MOVEM.L 416(A2),D0-D3
		MOVEM.L D0-D3,2720(A3)
		MOVEM.L 440(A2),D0-D3
		MOVEM.L D0-D3,2880(A3)
		MOVEM.L 464(A2),D0-D3
		MOVEM.L D0-D3,3040(A3)
		MOVEM.L 488(A2),D0-D3
		MOVEM.L D0-D3,3200(A3)
		MOVEM.L 512(A2),D0-D3
		MOVEM.L D0-D3,3360(A3)
		MOVEM.L 536(A2),D0-D3
		MOVEM.L D0-D3,3520(A3)
		MOVEM.L 560(A2),D0-D3
		MOVEM.L D0-D3,3680(A3)
		MOVEM.L 584(A2),D0-D3
		MOVEM.L D0-D3,3840(A3)
		MOVEM.L 608(A2),D0-D3
		MOVEM.L D0-D3,4000(A3)
		MOVEM.L 632(A2),D0-D3
		MOVEM.L D0-D3,4160(A3)
		MOVEM.L 656(A2),D0-D3
		MOVEM.L D0-D3,4320(A3)
		MOVEM.L 680(A2),D0-D3
		MOVEM.L D0-D3,4480(A3)
		MOVEM.L 704(A2),D0-D3
		MOVEM.L D0-D3,4640(A3)
		MOVEM.L 728(A2),D0-D3
		MOVEM.L D0-D3,4800(A3)
		MOVEM.L 752(A2),D0-D3
		MOVEM.L D0-D3,4960(A3)
		LEA 8(A3),A3
		BRA main_chars
first_2	MOVEM.L 16(A2),D0-D1
		MOVEM.L D0-D1,(A3)
		MOVEM.L 40(A2),D0-D1
		MOVEM.L D0-D1,160(A3)
		MOVEM.L 64(A2),D0-D1
		MOVEM.L D0-D1,320(A3)
		MOVEM.L 88(A2),D0-D1
		MOVEM.L D0-D1,480(A3)
		MOVEM.L 112(A2),D0-D1
		MOVEM.L D0-D1,640(A3)
		MOVEM.L 136(A2),D0-D1
		MOVEM.L D0-D1,800(A3)
		MOVEM.L 160(A2),D0-D1
		MOVEM.L D0-D1,960(A3)
		MOVEM.L 184(A2),D0-D1
		MOVEM.L D0-D1,1120(A3)
		MOVEM.L 208(A2),D0-D1
		MOVEM.L D0-D1,1280(A3)
		MOVEM.L 232(A2),D0-D1
		MOVEM.L D0-D1,1440(A3)
		MOVEM.L 256(A2),D0-D1
		MOVEM.L D0-D1,1600(A3)
		MOVEM.L 280(A2),D0-D1
		MOVEM.L D0-D1,1760(A3)
		MOVEM.L 304(A2),D0-D1
		MOVEM.L D0-D1,1920(A3)
		MOVEM.L 328(A2),D0-D1
		MOVEM.L D0-D1,2080(A3)
		MOVEM.L 352(A2),D0-D1
		MOVEM.L D0-D1,2240(A3)
		MOVEM.L 376(A2),D0-D1
		MOVEM.L D0-D1,2400(A3)
		MOVEM.L 400(A2),D0-D1
		MOVEM.L D0-D1,2560(A3)
		MOVEM.L 424(A2),D0-D1
		MOVEM.L D0-D1,2720(A3)
		MOVEM.L 448(A2),D0-D1
		MOVEM.L D0-D1,2880(A3)
		MOVEM.L 472(A2),D0-D1
		MOVEM.L D0-D1,3040(A3)
		MOVEM.L 496(A2),D0-D1
		MOVEM.L D0-D1,3200(A3)
		MOVEM.L 520(A2),D0-D1
		MOVEM.L D0-D1,3360(A3)
		MOVEM.L 544(A2),D0-D1
		MOVEM.L D0-D1,3520(A3)
		MOVEM.L 568(A2),D0-D1
		MOVEM.L D0-D1,3680(A3)
		MOVEM.L 592(A2),D0-D1
		MOVEM.L D0-D1,3840(A3)
		MOVEM.L 616(A2),D0-D1
		MOVEM.L D0-D1,4000(A3)
		MOVEM.L 640(A2),D0-D1
		MOVEM.L D0-D1,4160(A3)
		MOVEM.L 664(A2),D0-D1
		MOVEM.L D0-D1,4320(A3)
		MOVEM.L 688(A2),D0-D1
		MOVEM.L D0-D1,4480(A3)
		MOVEM.L 712(A2),D0-D1
		MOVEM.L D0-D1,4640(A3)
		MOVEM.L 736(A2),D0-D1
		MOVEM.L D0-D1,4800(A3)
		MOVEM.L 760(A2),D0-D1
		MOVEM.L D0-D1,4960(A3)

main_chars	MOVEQ #8,D7
chars_lp	CLR D1
		MOVE.B (A0)+,D1
		ADD D1,D1
		ADD D1,D1
		MOVE.L (A1,D1),A2
		ADD (A4),A2
		REPT 32
		MOVEM.L (A2)+,D0-D5
		OR.L D0,(A3)+
		OR.L D1,(A3)+
		MOVEM.L D2-D5,(A3)
		LEA 152(A3),A3
		ENDR
		LEA -5104(A3),A3
		DBF D7,chars_lp
last_char	CLR D1
		MOVE.B (A0)+,D1
		ADD D1,D1
		ADD D1,D1
		MOVE.L (A1,D1),A2
		ADD (A4),A2
		MOVE scrx(PC),D0
		ADDQ #1,scrx
		CMP #1,D0
		BLE last_2
i		SET 0
last_1	REPT 32
		MOVEM.L i(A2),D0-D3
		OR.L D0,(A3)+
		OR.L D1,(A3)+
		MOVE.L D2,(A3)+
		MOVE.L D3,(A3)+
i		SET i+24
		LEA 144(A3),A3
		ENDR
		BRA end_scr
i		SET 0
last_2	REPT 32
		MOVEM.L i(A2),D0-D1
		OR.L D0,(A3)+
		OR.L D1,(A3)+
i		SET i+24
		LEA 152(A3),A3
		ENDR
end_scr	MOVE.L #$600FF,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		TST D0
		BEQ vb_lp
		MOVE.L old_vbl(PC),$70.W
		CLR -(SP)
		TRAP #1

vbl		ADDQ #1,vbl_timer
		RTE

char_tab	DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+0
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+3072
		DC.L buf+1536
		DC.L buf+3072
		DC.L buf+4608
		DC.L buf+6144
		DC.L buf+7680
		DC.L buf+9216
		DC.L buf+10752
		DC.L buf+12288
		DC.L buf+13824
		DC.L buf+15360
		DC.L buf+16896
		DC.L buf+18432
		DC.L buf+19968
		DC.L buf+21504
		DC.L buf+23040
		DC.L buf+24576
		DC.L buf+26112
		DC.L buf+27648
		DC.L buf+29184
		DC.L buf+30720
		DC.L buf+32256
		DC.L buf+33792
		DC.L buf+35328
		DC.L buf+36864
		DC.L buf+38400
		DC.L buf+39936
		DC.L buf+41472
log_base	DC.L $70300
phy_base	DC.L $78000
switch	DC.W 0
old_vbl	DC.L 0
vbl_timer	DC.W 0
offset	DC.W 0
scrlp		DC.L text
scrx		DC.W 1
text		DC.B "        	   THIS ROUT IS CRAP IT TAKES ABOUT TWENTY TWO PERCENT OF THE PROCESSOR TIME...          ",0
		EVEN
		DS.L 99
my_stack	DS.L 1	
font		INCBIN SPROG32.FNT
buf