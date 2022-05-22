;----------------------------------------------------------------------
;                       Phenomena ENIGMA demo.
;
; 'The Big Bouncing Sphere made from 800 dots (X,Y,Z translation)'
; ST/STE conversion by Griff of Electronic Images. (The Inner Circle)
;----------------------------------------------------------------------

		OPT O+,OW-

no_points	EQU 968
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
		MOVE.B #0,$FFFF8E21.W

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp

		ENDC

		LEA stack,sp
		BSR MakeBigMatLook
		BSR Init_Crds
		BSR makexoffs
		IFNE demo
		JSR $508
		ENDC
		BSR Initscreens
		BSR set_ints
		BSR WaitVbl
		BSR WaitVbl
		BSR FadeInFloor
		BSR WaitVbl
		MOVE #(no_points/44)-1,D7
.startvbl_loop	MOVE.W D7,-(SP)
		BSR Swap_Screens
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_Bounce
		BSR Calc_N_Draw
		ADD.W #4,obj
		MOVE.W (SP)+,D7
		DBF D7,.startvbl_loop

		MOVE #750,-(SP)
.mainvbl_loop	
		BSR Swap_Screens
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_Bounce
		BSR Calc_N_Draw
		SUBQ #1,(SP)
		BNE.S .mainvbl_loop
		ADDQ.L #2,SP

		MOVE #(no_points/44)-1,D7
.endvbl_loop	MOVE.W D7,-(SP)
		SUB.W #4,obj
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
		MOVE.B #$FF,$FFFF8E21.W
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
oldbase		DS.L 1
oldres		DS.W 1

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
		MOVE.L D0,bnce_sclog
		BSR cls
		ADD.L #42240,D0
		MOVE.L D0,(A1)+
		MOVE.L D0,bnce_scphy
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

MakeBigMatLook	LEA bigtable,A0
		MOVEQ #-127,D0
		MOVE.W #256-1,D7
.lp1		MOVEQ #-127,D1
		MOVEQ #64-1,D6
.lp2		
		REPT 4
		MOVE.W D0,D2
		MULS D1,D2
		ASR.L #7,D2
		MOVE.W D2,(A0)+
		MULS #160,D2
		MOVE.W D2,(A0)+
		ADDQ #1,D1
		ENDR
		DBF D6,.lp2
		ADDQ #1,D0
		DBF D7,.lp1
		RTS

; Convert X,Y,Z co-ords to addr' for matrix lookup.

Init_Crds	LEA XYZ_spCRDS(PC),A0
		LEA XYZ_spCRDSADDR(PC),A1
		LEA bigtable+($7F80*4),A2	; big MAT lookup
		MOVE.W #no_points-1,D3
.lp		MOVEM.W (A0)+,D0-D2
		EXT.L D0
		EXT.L D1
		EXT.L D2
		ASL.L #2,D0
		ASL.L #2,D1
		ASL.L #2,D2
		ADD.L A2,D0
		ADD.L A2,D1
		ADD.L A2,D2
		MOVE.L D0,(A1)+
		MOVE.L D1,(A1)+
		MOVE.L D2,(A1)+
		DBF D3,.lp
		RTS

; Make Xoffs table!

makexoffs	MOVE.L #xoffs+65536,D0
		CLR.W D0
		MOVE.L D0,A0
		MOVE.L A0,xoffs_ptr
		MOVEQ #10-1,D0
		MOVE.W #153,D1
.lp1		
		REPT 8
		MOVE.B D1,(A0)+
		ENDR
		SUBQ.B #1,D1
		REPT 8
		MOVE.B D1,(A0)+
		ENDR
		SUBQ.B #7,D1
		DBF D0,.lp1
		ADD.L #65536-320,A0
		MOVEQ #10-1,D0
.lp2		
		REPT 8
		MOVE.B D1,(A0)+
		ENDR
		SUBQ.B #1,D1
		REPT 8
		MOVE.B D1,(A0)+
		ENDR
		SUBQ.B #7,D1
		DBF D0,.lp2
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

; Floor fade routines.

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
		LEA 16080(A0),A0
saveold1	RTS
		DS.L (no_points/2)+70

Clear_Old2	MOVE.L bnce_scphy(PC),A0
		LEA 16080(A0),A0
saveold2	RTS
		DS.L (no_points/2)+70
savecode	MOVE.B D0,2(A0)

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
		MOVEM.W (A2),D5-D7		; X,Y,Z angles
		ADDQ.W #6,D5	
		ADDQ.W #2,D6			; do the rotation
		ADDQ.W #4,D7
		CMP.W #$168*2,D5
		BLT.S .noresX
		SUB.W #$168*2,D5
.noresX		CMP.W #$168*2,D6
		BLT.S .noresY			; stop overflows..
		SUB.W #$168*2,D6
.noresY		CMP.W #$168*2,D7
		BLT.S .noresZ
		SUB.W #$168*2,D7
.noresZ		MOVEM.W	D5-D7,(A2)		; restore
		LEA sin128_tab(PC),A0		; -> sin table
		LEA $B4(A0),A2			; -> cosine
		MOVE (A0,D5),D0			sin(xd)
		MOVE (A2,D5),D1			cos(xd)
		MOVE (A0,D6),D2			sin(yd)
		MOVE (A2,D6),D3			cos(yd)
		MOVE (A0,D7),D4			sin(zd)
		MOVE (A2,D7),D5			cos(zd)
		LEA smmat_tmp(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		ASR.L #7,D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		ASR.L #7,D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A3,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6
		MOVE D6,(A1)+
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6
		MOVE D6,(A1)+
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6
		NEG D6				-cosz*sinx
		MOVE D6,(A1)+
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6
		NEG D6				-siny*cosz
		MOVE D6,(A1)+
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6
		MOVE D6,(A1)+
* Matrix(3,2) sinz 
		MOVE.W D4,D6
		ADD.W D6,D6
		ADD.W D6,D6
		MOVE D6,(A1)+
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ASR.L #7,D6
		ADD.W D6,D6
		ADD.W D6,D6			siny*(sinz*cosx)
		MOVE D6,(A1)+
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2
		ASR.L #7,D2
		ADD.W D2,D2
		ADD.W D2,D2 
		MOVE D2,(A1)+
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ASR.L #7,D5
		ADD.W D5,D5
		ADD.W D5,D5		cosz*cosx
		MOVE D5,(A1)+

		LEA smmat_tmp(PC),A5
		LEA .MO4_1+2(PC),A6
		MOVEM.W	(A5)+,D0-D2
		MOVE.W D0,.MO1_1-.MO4_1(A6)
		MOVE.W D0,.MO2_1-.MO4_1(A6)
		MOVE.W D0,.MO3_1-.MO4_1(A6)
		MOVE.W D0,.MO4_1-.MO4_1(A6)
		MOVE.W D0,.MO5_1-.MO4_1(A6)
		MOVE.W D0,.MO6_1-.MO4_1(A6)
		MOVE.W D0,.MO7_1-.MO4_1(A6)
		MOVE.W D0,.MO8_1-.MO4_1(A6)
		MOVE.W D0,.MO9_1-.MO4_1(A6)
		MOVE.W D0,.MO10_1-.MO4_1(A6)
		MOVE.W D0,.MO11_1-.MO4_1(A6)
		MOVE.W D1,.MO1_2-.MO4_1(A6)
		MOVE.W D1,.MO2_2-.MO4_1(A6)
		MOVE.W D1,.MO3_2-.MO4_1(A6)
		MOVE.W D1,.MO4_2-.MO4_1(A6)
		MOVE.W D1,.MO5_2-.MO4_1(A6)
		MOVE.W D1,.MO6_2-.MO4_1(A6)
		MOVE.W D1,.MO7_2-.MO4_1(A6)
		MOVE.W D1,.MO8_2-.MO4_1(A6)
		MOVE.W D1,.MO9_2-.MO4_1(A6)
		MOVE.W D1,.MO10_2-.MO4_1(A6)
		MOVE.W D1,.MO11_2-.MO4_1(A6)
		MOVE.W D2,.MO1_3-.MO4_1(A6)
		MOVE.W D2,.MO2_3-.MO4_1(A6)
		MOVE.W D2,.MO3_3-.MO4_1(A6)
		MOVE.W D2,.MO4_3-.MO4_1(A6)
		MOVE.W D2,.MO5_3-.MO4_1(A6)
		MOVE.W D2,.MO6_3-.MO4_1(A6)
		MOVE.W D2,.MO7_3-.MO4_1(A6)
		MOVE.W D2,.MO8_3-.MO4_1(A6)
		MOVE.W D2,.MO9_3-.MO4_1(A6)
		MOVE.W D2,.MO10_3-.MO4_1(A6)
		MOVE.W D2,.MO11_3-.MO4_1(A6)
		MOVEM.W	(A5)+,D0-D2
		MOVE.W D0,.MO1_4-.MO4_1(A6)
		MOVE.W D0,.MO2_4-.MO4_1(A6)
		MOVE.W D0,.MO3_4-.MO4_1(A6)
		MOVE.W D0,.MO4_4-.MO4_1(A6)
		MOVE.W D0,.MO5_4-.MO4_1(A6)
		MOVE.W D0,.MO6_4-.MO4_1(A6)
		MOVE.W D0,.MO7_4-.MO4_1(A6)
		MOVE.W D0,.MO8_4-.MO4_1(A6)
		MOVE.W D0,.MO9_4-.MO4_1(A6)
		MOVE.W D0,.MO10_4-.MO4_1(A6)
		MOVE.W D0,.MO11_4-.MO4_1(A6)
		MOVE.W D1,.MO1_5-.MO4_1(A6)
		MOVE.W D1,.MO2_5-.MO4_1(A6)
		MOVE.W D1,.MO3_5-.MO4_1(A6)
		MOVE.W D1,.MO4_5-.MO4_1(A6)
		MOVE.W D1,.MO5_5-.MO4_1(A6)
		MOVE.W D1,.MO6_5-.MO4_1(A6)
		MOVE.W D1,.MO7_5-.MO4_1(A6)
		MOVE.W D1,.MO8_5-.MO4_1(A6)
		MOVE.W D1,.MO9_5-.MO4_1(A6)
		MOVE.W D1,.MO10_5-.MO4_1(A6)
		MOVE.W D1,.MO11_5-.MO4_1(A6)
		MOVE.W D2,.MO1_6-.MO4_1(A6)
		MOVE.W D2,.MO2_6-.MO4_1(A6)
		MOVE.W D2,.MO3_6-.MO4_1(A6)
		MOVE.W D2,.MO4_6-.MO4_1(A6)
		MOVE.W D2,.MO5_6-.MO4_1(A6)
		MOVE.W D2,.MO6_6-.MO4_1(A6)
		MOVE.W D2,.MO7_6-.MO4_1(A6)
		MOVE.W D2,.MO8_6-.MO4_1(A6)
		MOVE.W D2,.MO9_6-.MO4_1(A6)
		MOVE.W D2,.MO10_6-.MO4_1(A6)
		MOVE.W D2,.MO11_6-.MO4_1(A6)

		MOVEM.W	(A5)+,D0-D2
		ADDQ #2,D0
		ADDQ #2,D1
		ADDQ #2,D2
		MOVE.W D0,.MO1_7-.MO4_1(A6)
		MOVE.W D0,.MO2_7-.MO4_1(A6)
		MOVE.W D0,.MO3_7-.MO4_1(A6)
		MOVE.W D0,.MO4_7-.MO4_1(A6)
		MOVE.W D0,.MO5_7-.MO4_1(A6)
		MOVE.W D0,.MO6_7-.MO4_1(A6)
		MOVE.W D0,.MO7_7-.MO4_1(A6)
		MOVE.W D0,.MO8_7-.MO4_1(A6)
		MOVE.W D0,.MO9_7-.MO4_1(A6)
		MOVE.W D0,.MO10_7-.MO4_1(A6)
		MOVE.W D0,.MO11_7-.MO4_1(A6)
		MOVE.W D1,.MO1_8-.MO4_1(A6)
		MOVE.W D1,.MO2_8-.MO4_1(A6)
		MOVE.W D1,.MO3_8-.MO4_1(A6)
		MOVE.W D1,.MO4_8-.MO4_1(A6)
		MOVE.W D1,.MO5_8-.MO4_1(A6)
		MOVE.W D1,.MO6_8-.MO4_1(A6)
		MOVE.W D1,.MO7_8-.MO4_1(A6)
		MOVE.W D1,.MO8_8-.MO4_1(A6)
		MOVE.W D1,.MO9_8-.MO4_1(A6)
		MOVE.W D1,.MO10_8-.MO4_1(A6)
		MOVE.W D1,.MO11_8-.MO4_1(A6)
		MOVE.W D2,.MO1_9-.MO4_1(A6)
		MOVE.W D2,.MO2_9-.MO4_1(A6)
		MOVE.W D2,.MO3_9-.MO4_1(A6)
		MOVE.W D2,.MO4_9-.MO4_1(A6)
		MOVE.W D2,.MO5_9-.MO4_1(A6)
		MOVE.W D2,.MO6_9-.MO4_1(A6)
		MOVE.W D2,.MO7_9-.MO4_1(A6)
		MOVE.W D2,.MO8_9-.MO4_1(A6)
		MOVE.W D2,.MO9_9-.MO4_1(A6)
		MOVE.W D2,.MO10_9-.MO4_1(A6)
		MOVE.W D2,.MO11_9-.MO4_1(A6)

		LEA obj(PC),A1
		MOVE (A1)+,D7
		SUBQ #1,D7
		BMI .doneplot
		MOVE.L xoffs_ptr(PC),D3
		MOVE.L bnce_sclog(PC),A6
		LEA saveold1(PC),A0
		TST.W frame_switch
		BEQ.S .cse2
		MOVE.L bnce_scphy(PC),A6
		LEA saveold2(PC),A0
.cse2		MOVE.L savecode(PC),D4
		LEA 16080(A6),A6
		MOVEQ #0,D6

plotpoint	macro
		move.l d3,a5
		move.b (a5),d6
	        add.w d6,d4			;16
        	move.l  d4,(a0)+		;12
		bset.b d3,(a6,d4.w)		;16
		endm

.trans_lp	MOVEM.L	(A1)+,A2/A3/A4
.MO1_1		MOVE.W $C(A2),D5
.MO1_2		ADD.W -$4C(A3),D5
.MO1_3		ADD.W -$64(A4),D5
		BLT.S .miss1
.MO1_4		MOVE.W -$75(A2),D3
.MO1_5		ADD.W $1C(A3),D3
.MO1_6		ADD.W -$27(A4),D3
.MO1_7		MOVE.W $2C(A2),D4
.MO1_8		ADD.W $60(A3),D4
.MO1_9		ADD.W -$44(A4),D4
		plotpoint
.miss1		MOVEM.L	(A1)+,A2/A3/A4
.MO2_1		MOVE.W $C(A2),D5
.MO2_2		ADD.W -$4C(A3),D5
.MO2_3		ADD.W -$64(A4),D5
		BLT.S .miss2
.MO2_4		MOVE.W -$75(A2),D3
.MO2_5		ADD.W $1C(A3),D3
.MO2_6		ADD.W -$27(A4),D3
.MO2_7		MOVE.W $2C(A2),D4
.MO2_8		ADD.W $60(A3),D4
.MO2_9		ADD.W -$44(A4),D4
		plotpoint
.miss2		MOVEM.L	(A1)+,A2/A3/A4
.MO3_1		MOVE.W $C(A2),D5
.MO3_2		ADD.W -$4C(A3),D5
.MO3_3		ADD.W -$64(A4),D5
		BLT.S .miss3
.MO3_4		MOVE.W -$75(A2),D3
.MO3_5		ADD.W $1C(A3),D3
.MO3_6		ADD.W -$27(A4),D3
.MO3_7		MOVE.W $2C(A2),D4
.MO3_8		ADD.W $60(A3),D4
.MO3_9		ADD.W -$44(A4),D4
		plotpoint
.miss3		MOVEM.L	(A1)+,A2/A3/A4
.MO4_1		MOVE.W $C(A2),D5
.MO4_2		ADD.W -$4C(A3),D5
.MO4_3		ADD.W -$64(A4),D5
		BLT.S .miss4
.MO4_4		MOVE.W -$75(A2),D3
.MO4_5		ADD.W $1C(A3),D3
.MO4_6		ADD.W -$27(A4),D3
.MO4_7		MOVE.W $2C(A2),D4
.MO4_8		ADD.W $60(A3),D4
.MO4_9		ADD.W -$44(A4),D4
		plotpoint
.miss4		MOVEM.L	(A1)+,A2/A3/A4
.MO5_1		MOVE.W $C(A2),D5
.MO5_2		ADD.W -$4C(A3),D5
.MO5_3		ADD.W -$64(A4),D5
		BLT.S .miss5
.MO5_4		MOVE.W -$75(A2),D3
.MO5_5		ADD.W $1C(A3),D3
.MO5_6		ADD.W -$27(A4),D3
.MO5_7		MOVE.W $2C(A2),D4
.MO5_8		ADD.W $60(A3),D4
.MO5_9		ADD.W -$44(A4),D4
		plotpoint
.miss5		MOVEM.L	(A1)+,A2/A3/A4
.MO6_1		MOVE.W $C(A2),D5
.MO6_2		ADD.W -$4C(A3),D5
.MO6_3		ADD.W -$64(A4),D5
		BLT.S .miss6
.MO6_4		MOVE.W -$75(A2),D3
.MO6_5		ADD.W $1C(A3),D3
.MO6_6		ADD.W -$27(A4),D3
.MO6_7		MOVE.W $2C(A2),D4
.MO6_8		ADD.W $60(A3),D4
.MO6_9		ADD.W -$44(A4),D4
		plotpoint
.miss6		MOVEM.L	(A1)+,A2/A3/A4
.MO7_1		MOVE.W $C(A2),D5
.MO7_2		ADD.W -$4C(A3),D5
.MO7_3		ADD.W -$64(A4),D5
		BLT.S .miss7
.MO7_4		MOVE.W -$75(A2),D3
.MO7_5		ADD.W $1C(A3),D3
.MO7_6		ADD.W -$27(A4),D3
.MO7_7		MOVE.W $2C(A2),D4
.MO7_8		ADD.W $60(A3),D4
.MO7_9		ADD.W -$44(A4),D4
		plotpoint
.miss7		MOVEM.L	(A1)+,A2/A3/A4
.MO8_1		MOVE.W $C(A2),D5
.MO8_2		ADD.W -$4C(A3),D5
.MO8_3		ADD.W -$64(A4),D5
		BLT.S .miss8
.MO8_4		MOVE.W -$75(A2),D3
.MO8_5		ADD.W $1C(A3),D3
.MO8_6		ADD.W -$27(A4),D3
.MO8_7		MOVE.W $2C(A2),D4
.MO8_8		ADD.W $60(A3),D4
.MO8_9		ADD.W -$44(A4),D4
		plotpoint
.miss8		MOVEM.L	(A1)+,A2/A3/A4
.MO9_1		MOVE.W $C(A2),D5
.MO9_2		ADD.W -$4C(A3),D5
.MO9_3		ADD.W -$64(A4),D5
		BLT.S .miss9
.MO9_4		MOVE.W -$75(A2),D3
.MO9_5		ADD.W $1C(A3),D3
.MO9_6		ADD.W -$27(A4),D3
.MO9_7		MOVE.W $2C(A2),D4
.MO9_8		ADD.W $60(A3),D4
.MO9_9		ADD.W -$44(A4),D4
		plotpoint
.miss9		MOVEM.L	(A1)+,A2/A3/A4
.MO10_1		MOVE.W $C(A2),D5
.MO10_2		ADD.W -$4C(A3),D5
.MO10_3		ADD.W -$64(A4),D5
		BLT.S .miss10
.MO10_4		MOVE.W -$75(A2),D3
.MO10_5		ADD.W $1C(A3),D3
.MO10_6		ADD.W -$27(A4),D3
.MO10_7		MOVE.W $2C(A2),D4
.MO10_8		ADD.W $60(A3),D4
.MO10_9		ADD.W -$44(A4),D4
		plotpoint
.miss10		MOVEM.L	(A1)+,A2/A3/A4
.MO11_1		MOVE.W $C(A2),D5
.MO11_2		ADD.W -$4C(A3),D5
.MO11_3		ADD.W -$64(A4),D5
		BLT.S .miss11
.MO11_4		MOVE.W -$75(A2),D3
.MO11_5		ADD.W $1C(A3),D3
.MO11_6		ADD.W -$27(A4),D3
.MO11_7		MOVE.W $2C(A2),D4
.MO11_8		ADD.W $60(A3),D4
.MO11_9		ADD.W -$44(A4),D4
		plotpoint
.miss11		DBF D7,.trans_lp
		MOVE.W #$4E75,(A0)+
.doneplot	RTS

XYZ_spCRDS	include sphre968.pod

xoffs_ptr	DC.L 0
bnce_sclog	DC.L 0
bnce_scphy	DC.L 0
bnce_ptr	DC.W 90
bnce_tab	INCBIN SPH_BNCE.DAT
sin128_tab	INCBIN SIN128.TAB
smmat_tmp	DS.W 9
xyz_ang		DC.W 90,270,180*3

		SECTION BSS

obj		DS.W 1
XYZ_spCRDSADDR	DS.L no_points*3
xoffs		DS.B 65536
		DS.B 65536
bigtable	DS.L 16384*4
screens		DS.B 256
		DS.B 42240
		DS.B 42240
		DS.L 199
stack		DS.L 2

