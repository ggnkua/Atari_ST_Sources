;----------------------------------------------------------------------
;                       Phenomena ENIGMA demo.
;
; 'The Big Bouncing Sphere made from 800 dots (X,Y,Z translation)'
; ST/STE conversion by Griff of Electronic Images. (The Inner Circle)
;----------------------------------------------------------------------

demo		EQU 0				; 0=gem 1=from DMA disk
	
letsgo		
		IFEQ demo
		CLR.W -(sp)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(sp)
		TRAP #14			; lowres
		LEA 12(sp),sp
		CLR.L -(sp)
		MOVE #$20,-(sp)
		TRAP #1				; supervisor mode.
		ADDQ.L #6,SP

		ELSEIF

		ORG $10000

		ENDC

		MOVE.L SP,oldsp
		LEA stack,sp
		BSR MakeBigMatLook
		IFNE demo
		JSR $508
		ENDC
		BSR Init_Crds
		BSR Initscreens
		BSR set_ints
		BSR WaitVbl
		BSR WaitVbl
		BSR FadeInFloor
		BSR WaitVbl
		MOVEQ #20-1,D7
.startvbl_loop	MOVE.W D7,-(SP)
		BSR Swap_Screens
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_Bounce
		BSR Calc_N_Draw
		ADD.W #10,obj
		MOVE.W (SP)+,D7
		DBF D7,.startvbl_loop

		MOVE #750-1,D7
.mainvbl_loop	MOVE.W D7,-(SP)
		BSR Swap_Screens
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_Bounce
		BSR Calc_N_Draw
		MOVE.W (SP)+,D7
		DBF D7,.mainvbl_loop

		MOVEQ #20-1,D7
.endvbl_loop	MOVE.W D7,-(SP)
		SUB.W #10,obj
		BSR Swap_Screens
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_Bounce
		BSR Calc_N_Draw
		MOVE.W (SP)+,D7
		DBF D7,.endvbl_loop
		BSR Swap_Screens
		BSR WaitVbl
		BSR FadeOutFloor
		BSR WaitVbl
		BSR rest_ints		

		IFEQ demo
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		CLR -(SP)
		TRAP #1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0

; General Routs...

; Initialisation interrupts.(saving old)

set_ints	MOVE #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $120.W,(A0)+
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
		LEA SuperUser(PC),A1
		MOVE.L A1,$B0.W
		BSR flush
		MOVE.W #$2300,SR
		RTS
SuperUser	BCHG #13-8,(SP)
		RTE

; Restore old interrupts.

rest_ints	MOVE.W #$2700,sr
		LEA old_stuff(pc),a0
		MOVE.L (a0)+,$70.w
		MOVE.L (a0)+,$B0.w
		MOVE.L (a0)+,$120.w
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		BSR flush
		MOVE.W #$2300,sr
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

vbl_timer	DC.W 0
old_stuff	DS.L 15

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

; Make the X1*X2 (.B) lookup table.

MakeBigMatLook	LEA bigtable(PC),A0
		MOVEQ #-127,D0
		MOVE.W #256-1,D7
.lp1		MOVEQ #-127,D1
		MOVEQ #32-1,D6
.lp2		
		REPT 8
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

; Convert X,Y,Z co-ords to addr' for matrix lookup.

Init_Crds	LEA XYZ_spCRDS(PC),A0
		LEA XYZ_spCRDSADDR(PC),A1
		LEA bigtable+$7F7F,A2	; big MAT lookup
		MOVE.W #800-1,D3
.lp		MOVEM.W (A0)+,D0-D2
		EXT.L D0
		EXT.L D1
		EXT.L D2
		ADD.L A2,D0
		ADD.L A2,D1
		ADD.L A2,D2
		MOVE.L D0,(A1)+
		MOVE.L D1,(A1)+
		MOVE.L D2,(A1)+
		DBF D3,.lp
		RTS

; Little old vbl.

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.B #199,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		LEA bot_bord(PC),A0
		MOVE.L A0,$120.W
		MOVE.L #$00000777,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE
		
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

; Clear those points!

Clear_Old	MOVEQ #0,D0
		TST frame_switch
		BNE Clear_Old2

Clear_Old1	MOVE.L bnce_sclog(PC),A0
saveold1	
		REPT 440
		MOVE.W D0,2(A0)
		ENDR
		RTS

Clear_Old2	MOVE.L bnce_scphy(PC),A0
saveold2	
		REPT 440
		MOVE.W D0,2(A0)
		ENDR
		RTS

Calc_Bounce	LEA bnce_sclog(PC),A0
		TST.W frame_switch
		BEQ.S .cse2
		LEA bnce_scphy(PC),A0
.cse2		LEA bnce_ptr(PC),A1
		MOVE.W (A1),D0
		ADDQ #2,D0
		CMP.W #180,D0
		BNE.S .notres
		CLR.W D0
.notres		MOVE.W D0,(A1)+
		MOVE.L log_base(PC),A2
		ADD (A1,D0),A2
		MOVE.L A2,(A0)
		RTS


; Translate 'n' draw.

Calc_N_Draw	LEA xyz_ang(PC),A2
		MOVEM.W (A2),D0-D2		; X,Y,Z angles
		ADDQ.W #6,D0	
		ADDQ.W #2,D1			; do the rotation
		ADDQ.W #4,D2
		CMP.W #$168*2,D0
		BLT.S .noresX
		SUB.W #$168*2,D0
.noresX		CMP.W #$168*2,D1
		BLT.S .noresY			; stop overflows..
		SUB.W #$168*2,D1
.noresY		CMP.W #$168*2,D2
		BLT.S .noresZ
		SUB.W #$168*2,D2
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

		LEA .MO1_1+3(PC),A6
		MOVE.B	$D(A5),(A6)
		MOVE.B	$F(A5),.MO1_2-.MO1_1(A6)
		MOVE.B $11(A5),.MO1_3-.MO1_1(A6)
		MOVE.B	 1(A5),.MO1_4-.MO1_1(A6)
		MOVE.B	 3(A5),.MO1_5-.MO1_1(A6)
		MOVE.B	 5(A5),.MO1_6-.MO1_1(A6) ; ain't I naughty!
		MOVE.B	 7(A5),.MO1_7-.MO1_1(A6)
		MOVE.B	 9(A5),.MO1_8-.MO1_1(A6)
		MOVE.B	$B(A5),.MO1_9-.MO1_1(A6)

		MOVE.B	$D(A5),.MO2_1-.MO1_1(A6)
		MOVE.B	$F(A5),.MO2_2-.MO1_1(A6)
		MOVE.B $11(A5),.MO2_3-.MO1_1(A6)
		MOVE.B	 1(A5),.MO2_4-.MO1_1(A6)
		MOVE.B	 3(A5),.MO2_5-.MO1_1(A6)
		MOVE.B	 5(A5),.MO2_6-.MO1_1(A6)
		MOVE.B	 7(A5),.MO2_7-.MO1_1(A6)
		MOVE.B	 9(A5),.MO2_8-.MO1_1(A6)
		MOVE.B	$B(A5),.MO2_9-.MO1_1(A6)

		MOVE.B	$D(A5),.MO3_1-.MO1_1(A6)
		MOVE.B	$F(A5),.MO3_2-.MO1_1(A6)
		MOVE.B $11(A5),.MO3_3-.MO1_1(A6)
		MOVE.B	 1(A5),.MO3_4-.MO1_1(A6)
		MOVE.B	 3(A5),.MO3_5-.MO1_1(A6)
		MOVE.B	 5(A5),.MO3_6-.MO1_1(A6)
		MOVE.B	 7(A5),.MO3_7-.MO1_1(A6)
		MOVE.B	 9(A5),.MO3_8-.MO1_1(A6)
		MOVE.B	$B(A5),.MO3_9-.MO1_1(A6)

		MOVE.B	$D(A5),.MO4_1-.MO1_1(A6)
		MOVE.B	$F(A5),.MO4_2-.MO1_1(A6)
		MOVE.B $11(A5),.MO4_3-.MO1_1(A6)
		MOVE.B	 1(A5),.MO4_4-.MO1_1(A6)
		MOVE.B	 3(A5),.MO4_5-.MO1_1(A6)
		MOVE.B	 5(A5),.MO4_6-.MO1_1(A6)
		MOVE.B	 7(A5),.MO4_7-.MO1_1(A6)
		MOVE.B	 9(A5),.MO4_8-.MO1_1(A6)
		MOVE.B	$B(A5),.MO4_9-.MO1_1(A6)

		LEA saveold1(PC),A0
		LEA obj(PC),A1
		MOVE (A1)+,D7
		SUBQ #1,D7
		BMI doneplot
		MOVE.L bnce_sclog(PC),A6
		TST.W frame_switch
		BEQ.S .cse2
		MOVE.L bnce_scphy(PC),A6
		LEA saveold2(PC),A0
.cse2		MOVE.L (A0),D5
		LEA mul160+200(PC),A5
		MOVE.W #$FFF8,D0
		MOVEQ #15,D1

plotpoint	MACRO
		MOVE.W D3,D5
		ASR.W #1,D5
		AND.W D0,D5
		ADD.W D4,D4
		ADD.W 0(A5,D4.W),D5
		MOVE.L D5,(A0)+
		CLR.W D4
		NOT.W D3
		AND D1,D3
		BSET D3,D4
		OR D4,(A6,D5.W)
		ENDM

.plot_lp	MOVEM.L	(A1)+,A2-A4
.MO1_1		MOVE.B 2(A2),D5
.MO1_2		ADD.B 2(A3),D5
.MO1_3		ADD.B 2(A4),D5
		BGE.S .noplot1
.MO1_4		MOVE.B 2(A2),D3
.MO1_5		ADD.B 2(A3),D3
.MO1_6		ADD.B 2(A4),D3
		EXT.W D3
.MO1_7		MOVE.B 2(A2),D4
.MO1_8		ADD.B 2(A3),D4
.MO1_9		ADD.B 2(A4),D4
		EXT.W D4
		plotpoint
.noplot1	MOVEM.L	(A1)+,A2-A4
.MO2_1		MOVE.B 2(A2),D5
.MO2_2		ADD.B 2(A3),D5
.MO2_3		ADD.B 2(A4),D5
		BGE.S .noplot2
.MO2_4		MOVE.B 2(A2),D3
.MO2_5		ADD.B 2(A3),D3
.MO2_6		ADD.B 2(A4),D3
		EXT.W D3
.MO2_7		MOVE.B 2(A2),D4
.MO2_8		ADD.B 2(A3),D4
.MO2_9		ADD.B 2(A4),D4
		EXT.W D4
		plotpoint
.noplot2	MOVEM.L	(A1)+,A2-A4
.MO3_1		MOVE.B 2(A2),D5
.MO3_2		ADD.B 2(A3),D5
.MO3_3		ADD.B 2(A4),D5
		BGE.S .noplot3
.MO3_4		MOVE.B 2(A2),D3
.MO3_5		ADD.B 2(A3),D3
.MO3_6		ADD.B 2(A4),D3
		EXT.W D3
.MO3_7		MOVE.B 2(A2),D4
.MO3_8		ADD.B 2(A3),D4
.MO3_9		ADD.B 2(A4),D4
		EXT.W D4
		plotpoint
.noplot3	MOVEM.L	(A1)+,A2-A4
.MO4_1		MOVE.B 2(A2),D5
.MO4_2		ADD.B 2(A3),D5
.MO4_3		ADD.B 2(A4),D5
		BGE.S .noplot4
.MO4_4		MOVE.B 2(A2),D3
.MO4_5		ADD.B 2(A3),D3
.MO4_6		ADD.B 2(A4),D3
		EXT.W D3
.MO4_7		MOVE.B 2(A2),D4
.MO4_8		ADD.B 2(A3),D4
.MO4_9		ADD.B 2(A4),D4
		EXT.W D4
		plotpoint
.noplot4	DBF D7,.plot_lp
doneplot	RTS

mul160
i		set 80
		rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr


XYZ_spCRDS	INCBIN PNTSPHRE.DAT
bnce_sclog	DC.L screens+256+32000
bnce_scphy	DC.L screens+256+32000
bnce_ptr	DC.W 90
bnce_tab	INCBIN SPH_BNCE.DAT
sin128_tab	INCBIN SIN128.TAB
sincostmp	DS.W 6
smmat_tmp	DS.W 9
xyz_ang		DC.W 0,0,0
		SECTION BSS

obj		DS.W 1
XYZ_spCRDSADDR	DS.L 800*3

bigtable	DS.L 16384
		DS.B 160*16
screens		DS.B 256
		DS.B 42240
		DS.B 42240
		DS.B 160*16
		DS.L 249
stack		DS.L 3

