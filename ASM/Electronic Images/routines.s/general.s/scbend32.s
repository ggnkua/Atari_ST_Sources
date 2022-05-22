* 32*32 4 plane byte bender
* movep trick - 23% processor time!

Quck_scrl	CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA my_stack(PC),SP
		MOVE #$2700,SR
Init_font	LEA $78000,A1
		LEA font(PC),A3
		MOVEQ #1,D4
		MOVEQ #29,D7
chr_lp	MOVE.L A3,A0
		MOVEQ #3,D6
by_lp		MOVEQ #31,D5
li_lp		MOVEP.L 0(A0),D0
		MOVE.L D0,(A1)+
		LEA 16(A0),A0
		DBF D5,li_lp
		LEA -512(A0),A0
		ADD.W D4,A0
		EOR #6,D4
		DBF D6,by_lp
		LEA 512(A3),A3
		DBF D7,chr_lp
		LEA font(PC),A0
		LEA $78000,A1
		MOVE #3999,D7
cpyback_lp	MOVE.L (A1)+,(A0)+
		DBF D7,cpyback_lp
clear_scr	MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cl_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cl_lp

ints		MOVE.L $70.W,old_vbl
		MOVE.L #vbl,$70.W
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+	
		MOVE.B $FFFFFA09.W,(A0)+	
		MOVE.B $FFFFFA13.W,(A0)+	
		MOVE.B $FFFFFA15.W,(A0)+	
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		MOVE.B #$12,$FFFFFC02.W
		MOVE #$2300,SR
		
* Main program loop

vb_lp		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		not $ffff8240.w
		MOVE vbl_timer(PC),D0
wait_vb	CMP vbl_timer(PC),D0
		BEQ.S wait_vb
		not $ffff8240.w
		
* This is the byte bend code

scroll32	MOVE.L scr_point(PC),A2
		MOVE scrx(PC),D0
		ADDQ #1,D0
		CMP #5,D0
		BLO.S not_next
		LEA char_ptrs+4(PC),A0
		MOVEM.L (A0)+,D0-D7/A1/A3
		MOVEM.L D0-D7/A1/A3,-44(A0)
		CLR D1
		MOVE.B (A2)+,D1
		ADD D1,D1
		ADD D1,D1
		LEA char_tab(PC),A4
		MOVE.L (A4,D1),-(A0)
		TST.B 11(A2)
		BNE.S not_wrap
		LEA text(PC),A2
not_wrap	MOVE.L A2,scr_point
		MOVEQ #1,D0
not_next	MOVE D0,scrx
plot		MOVE.L log_base(PC),A0
		LEA adda(PC),A3
		LEA add_tab(PC),A5
		ADD (A5)+,A0
		LEA char_ptrs(PC),A2
		MOVE.L (A2)+,A1
		MOVE D0,D2
		NEG D0
		ADDQ #5,D0
		MOVE D0,-(SP)
		SUBQ #1,D2
		LSL #7,D2
		ADD.W D2,A1
firstc_lp	MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(A0)
		MOVEP.L D1,160(A0)
		MOVEP.L D2,320(A0)
		MOVEP.L D3,480(A0)
		MOVEP.L D4,640(A0)
		MOVEP.L D5,800(A0)
		MOVEP.L D6,960(A0)
		MOVEP.L D7,1120(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,1280(A0)
		MOVEP.L D1,1440(A0)
		MOVEP.L D2,1600(A0)
		MOVEP.L D3,1760(A0)
		MOVEP.L D4,1920(A0)
		MOVEP.L D5,2080(A0)
		MOVEP.L D6,2240(A0)
		MOVEP.L D7,2400(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,2560(A0)
		MOVEP.L D1,2720(A0)
		MOVEP.L D2,2880(A0)
		MOVEP.L D3,3040(A0)
		MOVEP.L D4,3200(A0)
		MOVEP.L D5,3360(A0)
		MOVEP.L D6,3520(A0)
		MOVEP.L D7,3680(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,3840(A0)
		MOVEP.L D1,4000(A0)
		MOVEP.L D2,4160(A0)
		MOVEP.L D3,4320(A0)
		MOVEP.L D4,4480(A0)
		MOVEP.L D5,4640(A0)
		MOVEP.L D6,4800(A0)
		MOVEP.L D7,4960(A0)
		ADDA (A3)+,A0
		ADDA (A5)+,A0
		SUBQ #1,(SP)
		BNE firstc_lp
main_bit	MOVE #9,(SP)
main_chrlp	MOVE.L (A2)+,A1
		REPT 4
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(A0)
		MOVEP.L D1,160(A0)
		MOVEP.L D2,320(A0)
		MOVEP.L D3,480(A0)
		MOVEP.L D4,640(A0)
		MOVEP.L D5,800(A0)
		MOVEP.L D6,960(A0)
		MOVEP.L D7,1120(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,1280(A0)
		MOVEP.L D1,1440(A0)
		MOVEP.L D2,1600(A0)
		MOVEP.L D3,1760(A0)
		MOVEP.L D4,1920(A0)
		MOVEP.L D5,2080(A0)
		MOVEP.L D6,2240(A0)
		MOVEP.L D7,2400(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,2560(A0)
		MOVEP.L D1,2720(A0)
		MOVEP.L D2,2880(A0)
		MOVEP.L D3,3040(A0)
		MOVEP.L D4,3200(A0)
		MOVEP.L D5,3360(A0)
		MOVEP.L D6,3520(A0)
		MOVEP.L D7,3680(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,3840(A0)
		MOVEP.L D1,4000(A0)
		MOVEP.L D2,4160(A0)
		MOVEP.L D3,4320(A0)
		MOVEP.L D4,4480(A0)
		MOVEP.L D5,4640(A0)
		MOVEP.L D6,4800(A0)
		MOVEP.L D7,4960(A0)
		ADDA (A3)+,A0
		ADDA (A5)+,A0
		ENDR
		SUBQ #1,(SP)
		BNE main_chrlp
		MOVE.L (A2)+,A1
		MOVE scrx(PC),D0
		SUBQ #1,D0
		BEQ end_scr
		MOVE D0,(SP)
endc_lp	MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,(A0)
		MOVEP.L D1,160(A0)
		MOVEP.L D2,320(A0)
		MOVEP.L D3,480(A0)
		MOVEP.L D4,640(A0)
		MOVEP.L D5,800(A0)
		MOVEP.L D6,960(A0)
		MOVEP.L D7,1120(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,1280(A0)
		MOVEP.L D1,1440(A0)
		MOVEP.L D2,1600(A0)
		MOVEP.L D3,1760(A0)
		MOVEP.L D4,1920(A0)
		MOVEP.L D5,2080(A0)
		MOVEP.L D6,2240(A0)
		MOVEP.L D7,2400(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,2560(A0)
		MOVEP.L D1,2720(A0)
		MOVEP.L D2,2880(A0)
		MOVEP.L D3,3040(A0)
		MOVEP.L D4,3200(A0)
		MOVEP.L D5,3360(A0)
		MOVEP.L D6,3520(A0)
		MOVEP.L D7,3680(A0)
		MOVEM.L (A1)+,D0-D7
		MOVEP.L D0,3840(A0)
		MOVEP.L D1,4000(A0)
		MOVEP.L D2,4160(A0)
		MOVEP.L D3,4320(A0)
		MOVEP.L D4,4480(A0)
		MOVEP.L D5,4640(A0)
		MOVEP.L D6,4800(A0)
		MOVEP.L D7,4960(A0)
		ADDA (A3)+,A0
		ADDA (A5)+,A0
		SUBQ #1,(SP)
		BNE endc_lp 
end_scr	LEA 2(SP),SP

		BTST #0,$FFFFFC00.W
		BEQ vb_lp
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE vb_lp
		MOVE #$2700,SR
		MOVE.B #$08,$FFFFFC02.W
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W	
		MOVE.B (A0)+,$FFFFFA09.W	
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L old_vbl(PC),$70.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

vbl		ADDQ #1,vbl_timer
		RTE
		
char_tab	REPT 46
		DC.L font+1024
		ENDR
		DC.L font+0
		REPT 16
		DC.L font+1024
		ENDR
i		SET 512
		REPT 29
		DC.L font+i
i		SET i+512
		ENDR
old_vbl	DC.L 0
old_mfp	DS.L 2
log_base	DC.L $70300
phy_base	DC.L $78000
vbl_timer	DC.W 0
scr_point	DC.L text
scrx		DC.W 1
char_ptrs	REPT 11
		DC.L font+1024
		ENDR
adda		DC.L $00010007,$00010007,$00010007,$00010007,$00010007
		DC.L $00010007,$00010007,$00010007,$00010007,$00010007
		DC.L $00010007,$00010007,$00010007,$00010007,$00010007
		DC.L $00010007,$00010007,$00010007,$00010007,$00010007
add_tab	INCBIN BYTEWAVE.DAT
text		DC.B "        HELLO EVERYONE!!! MY FIRST BYTE BENDER........FAST HUH?................           ",0
		EVEN
		DS.L 99
my_stack	DS.L 1	
font		INCBIN SPROG32.FNT
