* 32*32 scroller using 2 two screen
* trick - 12% processor time(!)

Quck_scrl	CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

* Convert the font to a suitable form
* to allow fast blitting...
		
Convertfont	LEA font(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #(32000/8)-1,D0
cpytosc_lp	MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,cpytosc_lp
		LEA font(PC),A0
		MOVE.L log_base(PC),A1
		MOVEQ #32,D2
i		SET 0
ac_lp		MOVEQ #31,D1
onec_lp	MOVEP.L (A1),D0
		MOVE.L D0,(A0)+
		MOVEP.L 1(A1),D0
		MOVE.L D0,128-4(A0)
		MOVEP.L 8(A1),D0
		MOVE.L D0,256-4(A0)
		MOVEP.L 9(A1),D0
		MOVE.L D0,384-4(A0)
		LEA 16(A1),A1
		DBF D1,onec_lp
		LEA 384(A0),A0
		DBF D2,ac_lp

* Clear the screen

clear_scr	MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cl_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cl_lp

* Vbl loop

vb_lp		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE $468.W,D0
wait_vb	CMP $468.W,D0
		BEQ.S wait_vb
scroll32	MOVE.L log_base(PC),A0
		REPT 32
		ADDQ.L #8,A0
		MOVEM.L (A0)+,D0-D7/A2-A6
		MOVEM.L D0-D7/A2-A6,-60(A0)
		MOVEM.L (A0)+,D0-D7/A2-A6
		MOVEM.L D0-D7/A2-A6,-60(A0)
		MOVEM.L (A0)+,D0-D7/A2-A5
		MOVEM.L D0-D7/A2-A5,-56(A0)
		ENDR
		MOVE.L scr_point(PC),A3
		MOVE scrx(PC),D0
		ADD #128,D0
		CMP #4*128,D0
		BLO.S not_next
		ADDQ.L #1,A3
		MOVE.B 1(A3),D0
		BNE.S not_wrap
		LEA text(PC),A3
not_wrap	MOVE.L A3,scr_point
		MOVEQ #0,D0
not_next	MOVE D0,scrx
		CLR D1
		MOVE.B (A3)+,D1
		ADD D1,D1
		ADD D1,D1
		LEA char_tab(PC),A1
		MOVE.L (A1,D1),A0
		MOVE.L log_base(PC),A1
		ADDA.W D0,A0
		LEA 128(A0),A2
		CMP #3*128,D0
		BNE.S plot_end
case_4	CLR D0
		MOVE.B (A3),D0
		ADD D0,D0
		ADD D0,D0
		LEA char_tab(PC),A2
		MOVE.L (A2,D0),A2
i		SET 152
plot_end	REPT 4
		MOVEM.L (A0)+,D0-D7
		MOVEP.L D0,i(A1)
		MOVEP.L D1,i+160(A1)
		MOVEP.L D2,i+320(A1)
		MOVEP.L D3,i+480(A1)
		MOVEP.L D4,i+640(A1)
		MOVEP.L D5,i+800(A1)
		MOVEP.L D6,i+960(A1)
		MOVEP.L D7,i+1120(A1)
		MOVEM.L (A2)+,D0-D7
		MOVEP.L D0,i+1(A1)
		MOVEP.L D1,i+161(A1)
		MOVEP.L D2,i+321(A1)
		MOVEP.L D3,i+481(A1)
		MOVEP.L D4,i+641(A1)
		MOVEP.L D5,i+801(A1)
		MOVEP.L D6,i+961(A1)
		MOVEP.L D7,i+1121(A1)
i		SET i+1280
		ENDR

end_scr	MOVE.L #$600FF,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		TST D0
		BEQ vb_lp
		CLR -(SP)
		TRAP #1

char_tab	rept 46
		DC.L font+1024
		endr
		DC.L font+0
		rept 16
		DC.L font+1024
		endr
		DC.L font+512
		DC.L font+1024
		DC.L font+1536
		DC.L font+2048
		DC.L font+2560
		DC.L font+3072
		DC.L font+(10752/3)
		DC.L font+(12288/3)
		DC.L font+(13824/3)
		DC.L font+(15360/3)
		DC.L font+(16896/3)
		DC.L font+(18432/3)
		DC.L font+(19968/3)
		DC.L font+(21504/3)
		DC.L font+(23040/3)
		DC.L font+(24576/3)
		DC.L font+(26112/3)
		DC.L font+(27648/3)
		DC.L font+(29184/3)
		DC.L font+(30720/3)
		DC.L font+(32256/3)
		DC.L font+(33792/3)
		DC.L font+(35328/3)
		DC.L font+(36864/3)
		DC.L font+(38400/3)
		DC.L font+(39936/3)
		DC.L font+(41472/3)
log_base	DC.L $70300
phy_base	DC.L $78000
scr_point	DC.L text
scrx		DC.W 0
text		DC.B "           THIS SCROLL ROUTINE IS THE FASTEST HUMANLY POSSIBLE ON AN ST...........              ",0
		EVEN
font		INCBIN SPROG32.FNT
