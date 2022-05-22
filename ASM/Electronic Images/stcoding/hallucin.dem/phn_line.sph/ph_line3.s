;----------------------------------------------------------------------
;                       Phenomena ENIGMA demo.
;
; 'The Big Bouncing Sphere made from 98, points / 182 LINES!!!!!(25 FPS)
; ST/STE conversion by Griff of Electronic Images. (The Inner Circle)
;----------------------------------------------------------------------

demo		EQU 0				; 0=gem 1=from DMA disk
	
letsgo		
		IFEQ demo
		MOVE.W #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D0,oldres
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp
		ENDC

		BRA.S .go
		DC.B "So you wanna rip my line drawer huh?!!",0
		EVEN
.go		LEA stack,sp
		BSR MakeBigMatLook
		BSR Setupline
		IFNE demo
		JSR $508
		ENDC
		BSR Initscreens
		BSR set_ints
		BSR WaitVbl

.Seq		BSR WaitVbl
		BSR FadeInFloor
		BSR WaitVbl
		MOVE.L #pal,fadein_pal_ptr
		MOVE.L #currpal,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST fadeinflag
		MOVE #400,D7
.vbl_loop1	BSR Do_Update
		DBF D7,.vbl_loop1
		MOVE.L #pal,fadeout_pal_ptr
		MOVE.L #currpal,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST fadeoutflag

		MOVEQ #6,D7
.fade_outlp	BSR Do_Update
		DBF D7,.fade_outlp
		BSR FadeOutFloor
		BSR WaitVbl
		BSR WaitVbl

.exitit		BSR rest_ints		

		IFEQ demo
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W oldres(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR -(SP)
		TRAP #1
oldres		DS.W 1
oldbase		DS.L 1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0

Do_Update	MOVE.W D7,-(SP)
		BSR Swap_Screens
		;MOVE #$300,$ffff8240.W
		BSR WaitVbl
		BSR Clear_Sphere
		BSR Calc_Bounce
		BSR Translate
		BSR Draw_lines
		MOVE (SP)+,D7
		RTS


; General Routs...

; Initialisation interrupts.(saving old)

set_ints	MOVE #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.L $70.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B #1,$FFFFFA07.W	; enable hbl.
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #1,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		CLR.B $FFFFFA1B.W
		BCLR.B #3,$FFFFFA17.W
		LEA my_vbl(pc),A1
		MOVE.L A1,$70.w
		MOVE.W #$2300,SR
		RTS

; Restore old interrupts.

rest_ints	MOVE.W #$2700,sr
		LEA old_stuff(pc),a0
		MOVE.L (a0)+,$70.w
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.W #$2300,sr
		RTS

vbl_timer	DC.W 0
old_stuff	DS.L 10

log_base	DC.L 0
phy_base	DC.L 0
frame_switch	DC.W 0

; Wait for 1 vbl

WaitVbl		MOVE vbl_timer(PC),D0
.wait_vb	CMP vbl_timer(PC),D0
		BEQ.S .wait_vb
		RTS

; Swap LOG/PHYS screen ptrs and set the H/WARE reg.

Swap_Screens	LEA log_base(pc),A0
		MOVEM.L (A0)+,D0-D1
		NOT (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Allocate memory for screens and clear them.

Initscreens	LEA log_base(PC),A1
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		BSR cls
		ADD.L #42240,D0
		MOVE.L D0,(A1)+
		BSR cls
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear screen -> d0
		
cls		MOVE.L D0,A0
		MOVEQ #0,D2
		MOVE #(42240/16)-1,D1
.lp		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		DBF D1,.lp
		RTS

; Initialize line plotting rout.

Setupline	LEA linedat,A0
		LEA linejmps,A2
		LEA pre_linsu,A3
		MOVE.W dor1(PC),A4
		MOVE.W dor2(PC),A5
		LEA pre_lins,A6
		MOVEQ #16-1,D1
.y_lp		MOVEQ #16-1,D0
.x_lp		MOVEQ #0,D3
.s_lp		LEA (A0),A1
		MOVE.L A6,(A2)+
		MOVE.L A3,(A2)+
		MOVEQ #16-1,D4
		SUB.W D1,D4
		MOVEQ #0,D5
.p_lp		MOVEQ #0,D2
		MOVE.W (A1)+,D2
		ROR.L D3,D2

		TST.W D2
		BEQ.S .cont1
		TST.W D5
		BNE.S .nz1
		MOVE.W A4,(A6)+
		MOVE.W D2,(A6)+
		MOVE.W A4,(A3)+
		MOVE.W D2,(A3)+
		BRA.S .cont1
.nz1		MOVE.W D5,D6
		MOVE.W A5,(A6)+
		MOVE.W D2,(A6)+
		MOVE.W D6,(A6)+
		NEG D6
		MOVE.W A5,(A3)+
		MOVE.W D2,(A3)+
		MOVE.W D6,(A3)+
.cont1
		SWAP D2

		TST.W D2
		BEQ.S .cont2
.nz2		MOVE.W D5,D6
		ADDQ #8,D6
		MOVE.W A5,(A6)+
		MOVE.W D2,(A6)+
		MOVE.W D6,(A6)+
		MOVE.W D5,D6
		NEG D6
		ADDQ.W #8,D6
		MOVE.W A5,(A3)+
		MOVE.W D2,(A3)+
		MOVE.W D6,(A3)+
.cont2
		ADD.W #160,D5
		DBF D4,.p_lp
		MOVE.W #$4E75,(A6)+
		MOVE.W #$4E75,(A3)+
		ADDQ #1,D3
		CMP.W #16,D3
		BNE.S .s_lp
		LEA (A1),A0
		DBF D0,.x_lp
		DBF D1,.y_lp
		RTS
dor1		OR.W #1,(A0)
dor2		OR.W #1,30(A0)

; Make the X1*X2 (.B) lookup table.

MakeBigMatLook	LEA bigtable(PC),A0
		MOVEQ #-127,D0
		MOVE.W #256-1,D7
.lp1		MOVEQ #-127,D1
		MOVE.W #128-1,D6
.lp2		
		REPT 2
		MOVE.W D0,D2
		MULS D1,D2
		LSR #7,D2
		MOVE.B D2,(A0)+
		ADDQ #1,D1
		ENDR
		DBF D6,.lp2
		ADDQ #1,D0
		DBF D7,.lp1
		RTS

; Little old vbl.

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.B #199,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		LEA bot_bord(PC),A0
		MOVE.L A0,$120.W
		MOVEM.L currpal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		
		IFNE demo
		JSR $504
		ENDC
		BSR fadein
		BSR fadeout
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

pal		DC.W $000,$300,$500,$500,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

bot_bord	MOVEM.L D0/A0,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D0
.syncb		CMP.B (A0),D0
		BEQ.S .syncb
		MOVE.B (A0),D0
		JMP .noplist-96(PC,D0) 
.noplist	DCB.W 91,$4E71 
		MOVE.B #0,$FFFF820A.W
		MOVE.B #0,$FFFFFA1B.W
		MOVE.L #hbl1,$120.W
		MOVE.B #2,$FFFF820A.W
		MOVE.B #3,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L (SP)+,D0/A0
		RTE

hbl1		MOVE.W currfloorpal(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl2,$120.W
		MOVE.B #1,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl2		MOVE.W currfloorpal+2(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl3,$120.W
		MOVE.B #3,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl3		MOVE.W currfloorpal+4(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl4,$120.W
		MOVE.B #3,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl4		MOVE.W currfloorpal+6(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl5,$120.W
		MOVE.B #5,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl5		MOVE.W currfloorpal+8(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl6,$120.W
		MOVE.B #8,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl6		MOVE.W currfloorpal+10(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl7,$120.W
		MOVE.B #9,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
hbl7		MOVE.W currfloorpal+12(pc),$FFFF8240.W
		CLR.B $FFFFFA1B.W
		RTE

;
; Floor fade routines.
;

FadeInFloor	MOVE.L #destfloorpal,fadein_pal_ptr
		MOVE.L #currfloorpal,fadein_cur_ptr
		MOVE.W #7,fadein_nocols
		ST fadeinflag
.notfaded	BSR WaitVbl
		BSR fadein
		TST.B fadeinflag
		BNE.S .notfaded
		RTS

FadeOutFloor	MOVE.L #destfloorpal,fadeout_pal_ptr
		MOVE.L #currfloorpal,fadeout_cur_ptr
		MOVE.W #7,fadeout_nocols
		ST fadeoutflag
.notfaded	BSR WaitVbl
		BSR fadeout
		TST.B fadeoutflag
		BNE.S .notfaded
		RTS

fadein:		tst.b fadeinflag
		beq.s .endfade
		move.l fadein_pal_ptr(pc),a0
		move.l fadein_cur_ptr(pc),a1
		move.w fadein_tim(pc),d0
		move.w fadein_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		addq #1,d0
		cmp #$9,d0
		bne.s .notendfade
		clr d0
		sf fadeinflag
.notendfade	move.w d0,fadein_tim
.endfade	rts

fadeout:	tst.b fadeoutflag
		beq.s .endfade
		move.l fadeout_pal_ptr(pc),a0
		move.l fadeout_cur_ptr(pc),a1
		moveq #$8,d0
		sub.w fadeout_tim(pc),d0
		move.w fadeout_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		move.w fadeout_tim(pc),d0
		addq #1,d0
		cmp #$9,d0
		bne.s .notendfade
		clr d0
		sf fadeoutflag
.notendfade	move.w d0,fadeout_tim
.endfade	rts

currpal		DS.W 16

calc1		move.w (a0)+,d1
		move.w d1,d2
		and #$007,d1
		mulu d0,d1
		lsr #3,d1
		move.w d1,d3
		move.w d2,d1
		and #$070,d1
		mulu d0,d1
		lsr #3,d1
		and #$070,d1
		or.w d1,d3
		and #$700,d2
		mulu d0,d2
		lsr #3,d2
		and #$700,d2
		or.w d2,d3
		rts

fadein_pal_ptr	dc.l 0
fadein_cur_ptr	dc.l 0
fadein_nocols	dc.w 0
fadein_tim	dc.w 0
fadeinflag:	dc.b 0
	
fadeout_pal_ptr:dc.l 0
fadeout_cur_ptr:dc.l 0
fadeout_nocols	dc.w 0
fadeout_tim	dc.w 0
fadeoutflag:	dc.b 0	

currfloorpal	ds.w 7
destfloorpal	dc.w $001,$002,$003,$004,$005,$006,$007

; Clear the Sphere (2planes...)

Clear_Sphere	LEA bnce_sclog(PC),A0
		TST.W frame_switch
		BEQ.S .cse2
		LEA bnce_scphy(PC),A0
.cse2		MOVE.L (A0),A0
		LEA 32+(16*160)(A0),A0
		MOVEQ #0,D0
i		SET 0
		REPT 200-32
		MOVE.L D0,i(A0)
		MOVE.L D0,i+8(A0)
		MOVE.L D0,i+16(A0)
		MOVE.L D0,i+24(A0)
		MOVE.L D0,i+32(A0)
		MOVE.L D0,i+40(A0)
		MOVE.L D0,i+48(A0)
		MOVE.L D0,i+56(A0)
		MOVE.L D0,i+64(A0)
		MOVE.L D0,i+72(A0)
		MOVE.L D0,i+80(A0)
		MOVE.L D0,i+88(A0)
i		SET i+160
		ENDR
		RTS

Calc_Bounce	LEA bnce_sclog(PC),A0
		TST.W frame_switch
		BEQ.S .cse2
		LEA bnce_scphy(PC),A0
.cse2		LEA bnce_ptr(PC),A1
		MOVE.W (A1),D0
		ADDQ #2,D0
		CMP.W #90,D0
		BNE.S .notres
		CLR.W D0
.notres		MOVE.W D0,(A1)+
		MOVE.L log_base(PC),A2
		ADD (A1,D0),A2
		MOVE.L A2,(A0)
		RTS

; Translate the points

Translate	LEA xyz_ang(PC),A2
		MOVEM.W (A2),D0-D2		; X,Y,Z angles
		SUBQ #1*4,D0
		BGE.S .noresX
		ADD.W #$168*2,D0
.noresX		SUBQ #2*4,D1
		BGE.S .noresY			; stop overflows..
		ADD.W #$168*2,D1
.noresY		SUBQ #2*4,D2
		BGE.S .noresZ
		ADD.W #$168*2,D2
.noresZ		MOVEM.W	D0-D2,(A2)		; restore
		LEA bigtable+$7F7F,A3		; big MAT lookup
		LEA sin128_tab(PC),A4		; -> sin table
		LEA $B4(A4),A5			; -> cosine
		LEA sincostmp(PC),A0
		MOVE.W 0(A5,D0.W),(A0)+		; cos X
		MOVE.W 0(A4,D0.W),(A0)+		; sin X
		MOVE.W 0(A5,D1.W),(A0)+		; cos Y
		MOVE.W 0(A4,D1.W),(A0)+		; sin Y
		MOVE.W 0(A5,D2.W),(A0)+		; cos Z
		MOVE.W 0(A4,D2.W),(A0)+		; sin Z
		LEA -12(A0),A0
		LEA smmat_tmp(PC),A5
		MOVE.W	2(A0),$E(A5)
		NEG.W	2(A0)
		MOVE.W	4(A0),(A5)
		CLR.W	2(A5)
		MOVE.W	(A0),8(A5)
		MOVE.W	6(A0),D0
		MOVE.W	2(A0),D1
		LSL.W	#8,D1
		ADD.W	D0,D1
		MOVE.B	0(A3,D1.W),D0
		EXT.W	D0
		MOVE.W	D0,6(A5)
		MOVE.W	6(A0),D0
		MOVE.W	(A0),D1
		LSL.W	#8,D1
		ADD.W	D0,D1
		MOVE.B	0(A3,D1.W),D0
		EXT.W	D0
		MOVE.W	D0,$C(A5)
		MOVE.W	6(A0),D0
		NEG.W	D0
		MOVE.W	D0,4(A5)
		MOVE.W	4(A0),D0
		MOVE.W	2(A0),D1
		LSL.W	#8,D1
		ADD.W	D0,D1
		MOVE.B	0(A3,D1.W),D0
		EXT.W	D0
		MOVE.W	D0,$A(A5)
		MOVE.W	4(A0),D0
		MOVE.W	(A0),D1
		LSL.W	#8,D1
		ADD.W	D0,D1
		MOVE.B	0(A3,D1.W),D0
		EXT.W	D0
		MOVE.W	D0,$10(A5)
		MOVE.W	8(A0),D0
		LSL.W	#8,D0
		ADD.W	4(A0),D0
		MOVE.B	0(A3,D0.W),D0
		EXT.W	D0
		MOVE.W	D0,(A5)
		MOVE.W	$A(A0),D0
		MULS	4(A0),D0
		NEG.W	D0
		LSR.L	#7,D0
		MOVE.W	D0,2(A5)
		MOVE.W	8(A0),D0
		LSL.W	#8,D0
		ADD.W	6(A5),D0
		MOVE.B	0(A3,D0.W),D0
		EXT.W	D0
		MOVE.W	$A(A0),D1
		LSL.W	#8,D1
		ADD.W	(A0),D1
		MOVE.B	0(A3,D1.W),D1
		EXT.W	D1
		ADD.W	D1,D0
		MOVE.W	8(A0),D2
		LSL.W	#8,D2
		ADD.W	(A0),D2
		MOVE.B	0(A3,D2.W),D2
		EXT.W	D2
		MOVE.W	$A(A0),D3
		LSL.W	#8,D3
		ADD.W	6(A5),D3
		MOVE.B	0(A3,D3.W),D3
		EXT.W	D3
		SUB.W	D3,D2
		MOVE.W	D0,6(A5)
		MOVE.W	D2,8(A5)
		MOVE.W	8(A0),D0
		LSL.W	#8,D0
		ADD.W	$C(A5),D0
		MOVE.B	0(A3,D0.W),D0
		EXT.W	D0
		MOVE.W	$A(A0),D1
		LSL.W	#8,D1
		ADD.W	$E(A5),D1
		MOVE.B	0(A3,D1.W),D1
		EXT.W	D1
		ADD.W	D1,D0
		MOVE.W	8(A0),D2
		LSL.W	#8,D2
		ADD.W	$E(A5),D2
		MOVE.B	0(A3,D2.W),D2
		EXT.W	D2
		MOVE.W	$A(A0),D3
		LSL.W	#8,D3
		ADD.W	$C(A5),D3
		MOVE.B	0(A3,D3.W),D3
		EXT.W	D3
		SUB.W	D3,D2
		MOVE.W	D0,$C(A5)
		MOVE.W	D2,$E(A5)
		LEA .MO4_1+3(PC),A6
		MOVE.B	$D(A5),.MO4_1-.MO4_1(A6)
		MOVE.B	$F(A5),.MO4_2-.MO4_1(A6)
		MOVE.B $11(A5),.MO4_3-.MO4_1(A6)
		MOVE.B	 1(A5),.MO4_4-.MO4_1(A6)
		MOVE.B	 3(A5),.MO4_5-.MO4_1(A6)
		MOVE.B	 5(A5),.MO4_6-.MO4_1(A6)
		MOVE.B	 7(A5),.MO4_7-.MO4_1(A6)
		MOVE.B	 9(A5),.MO4_8-.MO4_1(A6)
		MOVE.B	$B(A5),.MO4_9-.MO4_1(A6)
		LEA translated_crds(PC),A0
		LEA obj(PC),A1
		MOVE #160,A4
		MOVE #100,A5
		MOVE (A1)+,D7
.trans_lp	MOVEM.W	(A1)+,D0-D2
.MO4_4		MOVE.B -$75(A3,D0.W),D3
.MO4_5		ADD.B $1C(A3,D1.W),D3
.MO4_6		ADD.B -$27(A3,D2.W),D3
.MO4_7		MOVE.B $2C(A3,D0.W),D4
.MO4_8		ADD.B $60(A3,D1.W),D4
.MO4_9		ADD.B -$44(A3,D2.W),D4
.MO4_1		MOVE.B $C(A3,D0.W),D5
.MO4_2		ADD.B -$4C(A3,D1.W),D5
.MO4_3		ADD.B -$64(A3,D2.W),D5
		EXT.W D3
		EXT.W D4
		EXT.W D5
		MULS #$3500,D3
		MULS #$3500,D4
		ADD.L D3,D3
		ADD.L D4,D4
		SWAP D3
		SWAP D4
		ADD.W A4,D3
		ADD.W A5,D4
		MOVEM.W D3-D5,(A0)
		ADDQ.L #8,A0
		DBF D7,.trans_lp
		RTS

; Draw Those lines!

Draw_lines	LEA linejmps,A2
		LEA mul160(PC),A3
		LEA bnce_sclog(PC),A4
		TST.W frame_switch
		BEQ.S .cse2
		LEA bnce_scphy(PC),A4
.cse2		MOVE.L (A4),A4
		LEA translated_crds(PC),A5
		LEA line_list(PC),A6
		MOVE.W #182-1,D7
.lp		MOVEM.W (A6)+,D4/d5
		MOVEM.W (A5,D4),D0-D1
		MOVEM.W (A5,D5),D2-D3
		LEA (A4),A1
		TST.W 4(A5,D5)
		BGT.S .ok
		ADDQ.L #2,A1
.ok		BSR Drawline
		DBF D7,.lp
		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line upto 16*16 V Quickly!!!!!!		;
; D0-D3 holds x1,y1/x2,y2 A1 -> screen base. A2-> linetab A3-> *160 tab	;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

Drawline	SUB.W D0,D2			; dx				
		BGE.S .gofordraw		; negative?
		ADD.W D2,D0
		NEG D2
		EXG D1,D3			; draw from LEFT to RIGHT
.gofordraw	MOVE.L A1,A0			; a0-> screen base
		MOVEQ #15,D5			;
		AND.W D0,D5			; x and 15
		SUB.W D5,D0			;
		LSR #1,D0			; x word offset
		SUB.W D1,D3			; dy
		BGE.S .posdy
.negdy		ADD.W D1,D1			; y*2
		ADD.W (A3,D1),D0		; scr offset
		ADD.W D0,A0			; scrbase
		ASL.W #4,D3			; dy*16
		SUB.W D3,D2			; x -- dy (so x+dy!!)
		ASL.W #4,D2
		ADD.W D5,D2
		ASL.W #3,D2
		MOVE.L 4(A2,D2.W),A1
		JMP (A1)
.posdy		ADD.W D1,D1			; y*2
		ADD.W (A3,D1),D0		; scr offset
		ADD.W D0,A0			; scrbase
		ASL.W #4,D3			; dy*16
		ADD.W D3,D2
		ASL.W #4,D2
		ADD.W D5,D2
		ASL.W #3,D2
		MOVE.L (A2,D2.W),A1
		JMP (A1)

linedat		INCBIN D:\hallucin.dem\phn_line.sph\line1616.dat


i		SET 0
mul160		
		REPT 50
		DC.W i,i+160,i+320,i+480
i		SET i+640
		ENDR

i		SET 0
bit_offs	
		rept 20
		dc.w $8000,i
		dc.w $4000,i
		dc.w $2000,i
		dc.w $1000,i
		dc.w $0800,i
		dc.w $0400,i
		dc.w $0200,i
		dc.w $0100,i
		dc.w $0080,i
		dc.w $0040,i
		dc.w $0020,i
		dc.w $0010,i
		dc.w $0008,i
		dc.w $0004,i
		dc.w $0002,i
		dc.w $0001,i
i		set i+8
		endr

;-----------------------------------------------------------------------;
bnce_sclog	DC.L screens+256+16000
bnce_scphy	DC.L screens+256+16000
bnce_ptr	DC.W 44
bnce_tab	INCBIN D:\HALLUCIN.DEM\PHN_LINE.SPH\SPH_BNCE.DAT

sincostmp	DS.W 6
smmat_tmp	DS.W 9
xyz_ang		DS.W 3
obj		dc.w	98-1
		dc.w	$4D00,$1400,$0400,$4D00,$1000,$0C00,$4D00,$0900 
		dc.w	$1200,$4D00,$0000,$1400,$4D00,$F600,$1200,$4D00 
		dc.w	$EF00,$0C00,$4D00,$EB00,$0400,$4D00,$EB00,$FA00 
		dc.w	$4D00,$EF00,$F200,$4D00,$F700,$EC00,$4D00,$0000 
		dc.w	$EB00,$4D00,$0900,$ED00,$4D00,$1000,$F300,$4D00 
		dc.w	$1400,$FC00,$3D00,$3200,$0A00,$3D00,$2800,$2000 
		dc.w	$3D00,$1600,$2E00,$3D00,$0000,$3300,$3D00,$E900 
		dc.w	$2E00,$3D00,$D700,$2000,$3D00,$CD00,$0A00,$3D00 
		dc.w	$CD00,$F300,$3D00,$D800,$DE00,$3D00,$EA00,$D000 
		dc.w	$3D00,$0100,$CC00,$3D00,$1800,$D200,$3D00,$2A00 
		dc.w	$E100,$3D00,$3300,$F600,$2100,$4700,$0F00,$2100 
		dc.w	$3900,$2C00,$2100,$1F00,$4100,$2100,$0000,$4800 
		dc.w	$2100,$E000,$4100,$2100,$C600,$2C00,$2100,$B800 
		dc.w	$0F00,$2100,$B900,$EE00,$2100,$C800,$D100,$2100 
		dc.w	$E200,$BD00,$2100,$0200,$B700,$2100,$2200,$BF00 
		dc.w	$2100,$3B00,$D500,$2100,$4700,$F300,$0000,$4E00 
		dc.w	$1000,$0000,$3F00,$3100,$0000,$2300,$4700,$0000 
		dc.w	$0000,$4F00,$0000,$DC00,$4700,$0000,$C000,$3100 
		dc.w	$0000,$B100,$1000,$0000,$B200,$EC00,$0000,$C200 
		dc.w	$CC00,$0000,$DF00,$B600,$0000,$0200,$B000,$0000 
		dc.w	$2500,$B900,$0000,$4000,$D000,$0000,$4E00,$F200 
		dc.w	$DE00,$4700,$0F00,$DE00,$3900,$2C00,$DE00,$1F00 
		dc.w	$4100,$DE00,$0000,$4800,$DE00,$E000,$4100,$DE00 
		dc.w	$C600,$2C00,$DE00,$B800,$0F00,$DE00,$B900,$EE00 
		dc.w	$DE00,$C800,$D100,$DE00,$E200,$BD00,$DE00,$0200 
		dc.w	$B700,$DE00,$2200,$BF00,$DE00,$3B00,$D500,$DE00 
		dc.w	$4700,$F300,$C200,$3200,$0A00,$C200,$2800,$2000 
		dc.w	$C200,$1600,$2E00,$C200,$0000,$3300,$C200,$E900 
		dc.w	$2E00,$C200,$D700,$2000,$C200,$CD00,$0A00,$C200 
		dc.w	$CD00,$F300,$C200,$D800,$DE00,$C200,$EA00,$D000 
		dc.w	$C200,$0100,$CC00,$C200,$1800,$D200,$C200,$2A00 
		dc.w	$E100,$C200,$3300,$F600,$B200,$1400,$0400,$B200 
		dc.w	$1000,$0C00,$B200,$0900,$1200,$B200,$0000,$1400 
		dc.w	$B200,$F600,$1200,$B200,$EF00,$0C00,$B200,$EB00 
		dc.w	$0400,$B200,$EB00,$FA00,$B200,$EF00,$F200,$B200 
		dc.w	$F700,$EC00,$B200,$0000,$EB00,$B200,$0900,$ED00 
		dc.w	$B200,$1000,$F300,$B200,$1400,$FC00 

line_list	dc.w	$0000,$0008,$0008,$0010,$0010,$0018,$0018,$0020 
		dc.w	$0020,$0028,$0028,$0030,$0030,$0038,$0038,$0040 
		dc.w	$0040,$0048,$0048,$0050,$0050,$0058,$0058,$0060 
		dc.w	$0060,$0068,$0068,$0000,$0070,$0078,$0078,$0080 
		dc.w	$0080,$0088,$0088,$0090,$0090,$0098,$0098,$00A0 
		dc.w	$00A0,$00A8,$00A8,$00B0,$00B0,$00B8,$00B8,$00C0 
		dc.w	$00C0,$00C8,$00C8,$00D0,$00D0,$00D8,$00D8,$0070 
		dc.w	$00E0,$00E8,$00E8,$00F0,$00F0,$00F8,$00F8,$0100 
		dc.w	$0100,$0108,$0108,$0110,$0110,$0118,$0118,$0120 
		dc.w	$0120,$0128,$0128,$0130,$0130,$0138,$0138,$0140 
		dc.w	$0140,$0148,$0148,$00E0,$0150,$0158,$0158,$0160 
		dc.w	$0160,$0168,$0168,$0170,$0170,$0178,$0178,$0180 
		dc.w	$0180,$0188,$0188,$0190,$0190,$0198,$0198,$01A0 
		dc.w	$01A0,$01A8,$01A8,$01B0,$01B0,$01B8,$01B8,$0150 
		dc.w	$01C0,$01C8,$01C8,$01D0,$01D0,$01D8,$01D8,$01E0 
		dc.w	$01E0,$01E8,$01E8,$01F0,$01F0,$01F8,$01F8,$0200 
		dc.w	$0200,$0208,$0208,$0210,$0210,$0218,$0218,$0220 
		dc.w	$0220,$0228,$0228,$01C0,$0230,$0238,$0238,$0240 
		dc.w	$0240,$0248,$0248,$0250,$0250,$0258,$0258,$0260 
		dc.w	$0260,$0268,$0268,$0270,$0270,$0278,$0278,$0280 
		dc.w	$0280,$0288,$0288,$0290,$0290,$0298,$0298,$0230 
		dc.w	$02A0,$02A8,$02A8,$02B0,$02B0,$02B8,$02B8,$02C0 
		dc.w	$02C0,$02C8,$02C8,$02D0,$02D0,$02D8,$02D8,$02E0 
		dc.w	$02E0,$02E8,$02E8,$02F0,$02F0,$02F8,$02F8,$0300 
		dc.w	$0300,$0308,$0308,$02A0,$0000,$0070,$0070,$00E0 
		dc.w	$00E0,$0150,$0150,$01C0,$01C0,$0230,$0230,$02A0 
		dc.w	$0008,$0078,$0078,$00E8,$00E8,$0158,$0158,$01C8 
		dc.w	$01C8,$0238,$0238,$02A8,$0010,$0080,$0080,$00F0 
		dc.w	$00F0,$0160,$0160,$01D0,$01D0,$0240,$0240,$02B0 
		dc.w	$0018,$0088,$0088,$00F8,$00F8,$0168,$0168,$01D8 
		dc.w	$01D8,$0248,$0248,$02B8,$0020,$0090,$0090,$0100 
		dc.w	$0100,$0170,$0170,$01E0,$01E0,$0250,$0250,$02C0 
		dc.w	$0028,$0098,$0098,$0108,$0108,$0178,$0178,$01E8 
		dc.w	$01E8,$0258,$0258,$02C8,$0030,$00A0,$00A0,$0110 
		dc.w	$0110,$0180,$0180,$01F0,$01F0,$0260,$0260,$02D0 
		dc.w	$0038,$00A8,$00A8,$0118,$0118,$0188,$0188,$01F8 
		dc.w	$01F8,$0268,$0268,$02D8,$0040,$00B0,$00B0,$0120 
		dc.w	$0120,$0190,$0190,$0200,$0200,$0270,$0270,$02E0 
		dc.w	$0048,$00B8,$00B8,$0128,$0128,$0198,$0198,$0208 
		dc.w	$0208,$0278,$0278,$02E8,$0050,$00C0,$00C0,$0130 
		dc.w	$0130,$01A0,$01A0,$0210,$0210,$0280,$0280,$02F0 
		dc.w	$0058,$00C8,$00C8,$0138,$0138,$01A8,$01A8,$0218 
		dc.w	$0218,$0288,$0288,$02F8,$0060,$00D0,$00D0,$0140 
		dc.w	$0140,$01B0,$01B0,$0220,$0220,$0290,$0290,$0300 
		dc.w	$0068,$00D8,$00D8,$0148,$0148,$01B8,$01B8,$0228 
		dc.w	$0228,$0298,$0298,$0308 
sin128_tab	INCBIN  D:\HALLUCIN.DEM\PHNPOINT.SPH\SIN128.TAB

		SECTION BSS
translated_crds	DS.W 4*98
bigtable	DS.L 16384
		DS.B 4*160
screens		DS.B 256
		DS.W 42240/2
		DS.W 42240/2
		DS.B 256

		DS.L 349
stack		DS.L 3
linejmps	DS.L 16*16*16*2

pre_lins	DS.B 280000
pre_linsu	DS.B 280000