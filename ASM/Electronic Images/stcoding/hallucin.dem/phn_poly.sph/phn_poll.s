;----------------------------------------------------------------------
;                       Phenomena ENIGMA demo.
;
;  'The Big Bouncing Sphere' - made from 50 vertices, 42 POLYGONS!!! 
;
; Updates:-
;  22/08/91
;  YES! The solid sphere rotates and runs in two frames which is cool.
;  (but the Amiga one ran in one frame.... A blitter would be nice.)
;  The only thing that was ripped was the Sphere vertex co-ordinates. 
;
;  23/08/91
;  Now 'LIGHT-SHADED' - I don't know how they did it but adding the Zs
;  and choosing a colour on this Z value seems to give the right effect.
;
; ST/STE Conversion by Griff of Electronic Images. (The Inner Circle)
; Idea/Fast matrixx translation routine by AZATOTH of PHENOMENA. (Amiga)
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

		LEA stack,sp
		BSR MakeBigMatLook
		IFNE demo
		JSR $508
		ENDC
		BSR Initscreens
		BSR set_ints
		BSR WaitVbl
		BSR FadeInFloor
		MOVE.L #pal,fadein_pal_ptr
		MOVE.L #currpal,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST fadeinflag
		MOVE #500,D7
.vbl_loop1	MOVE.W D7,-(SP)
		BSR Do_Update
		MOVE.W (SP)+,D7
		DBF D7,.vbl_loop1
		MOVE.L #pal,fadeout_pal_ptr
		MOVE.L #currpal,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST fadeoutflag

		MOVEQ #6,D7
.fade_outlp	MOVE.W D7,-(SP)
		BSR Do_Update
		MOVE.W (SP)+,D7
		DBF D7,.fade_outlp
		BSR FadeOutFloor
		BSR WaitVbl

		BSR rest_ints		

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
oldbase		DS.L 1
oldres		DS.W 1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0


Do_Update	BSR Swap_Screens
		;MOVE #$300,$ffff8240.W
		BSR WaitVbl
		BSR Clear_Sphere
		BSR Calc_Bounce
		BSR Translate
		BRA Draw_obj

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
		BSR flush
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
		BSR flush
		MOVE.W #$2300,sr
		RTS

; Flush keyboard.

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

vbl_timer	DC.W 0
old_stuff	DS.L 10

log_base	DC.L 0
phy_base	DC.L 0
frame_switch	DC.W 0
i		SET 0
mul160		
		REPT 50
		DC.W i,i+160,i+320,i+480
i		SET i+640
		ENDR

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

MakeBigMatLook	LEA bigtable,A0
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
		BSR fadein
		BSR fadeout

		IFNE demo
		JSR $504
		ENDC
		
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE
pal		DC.W $000,$111,$222,$333,$444,$555,$666,$777
		DC.W $777,$777,$777,$777,$777,$777,$777,$777
currpal		DS.W 16

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
		TST.B fadeinflag
		BNE.S .notfaded
		RTS

FadeOutFloor	MOVE.L #destfloorpal,fadeout_pal_ptr
		MOVE.L #currfloorpal,fadeout_cur_ptr
		MOVE.W #7,fadeout_nocols
		ST fadeoutflag
.notfaded	BSR WaitVbl
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
		

; Clear the Sphere (2planes...)

Clear_Sphere	LEA bnce_sclog(PC),A0
		TST.W frame_switch
		BNE.S .cse2
		LEA bnce_scphy(PC),A0
.cse2		MOVE.L (A0),A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D7
		MOVE.L D7,A1
i		SET 40+(34*160)
		REPT 132
		MOVEM.L D0-D7/A1,i(A0)
		MOVEM.L D0-D7/A1,i+36(A0)
i		SET i+160
		ENDR
		RTS

Calc_Bounce	LEA bnce_sclog(PC),A0
		TST.W frame_switch
		BNE.S .cse2
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
		MOVE.L A2,(A0)			; store for clear..
		MOVE.L A2,framelogbase		; and for this frame.
		RTS
framelogbase	DS.L 1

; Translate the points - using lookup for X1*X2 (8 bit range) hmm...
; Not so accurate as 'REAL' translation but 3 times as fast!!

Translate	LEA xyz_ang(PC),A2
		MOVEM.W (A2),D0-D2		; X,Y,Z angles
		ADDQ #2*4,D0
		CMP.W #$168*2,D0
		BLT.S .noresX
		SUB.W #$168*2,D0
.noresX		ADDQ #1*4,D1
		CMP.W #$168*2,D1
		BLT.S .noresY			; stop overflows..
		SUB.W #$168*2,D1
.noresY		ADDQ #2*4,D2
		CMP.W #$168*2,D2
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
		ADD.W A4,D3
		ADD.W A5,D4
		MOVE.W D3,(A0)+
		MOVE.W D4,(A0)+
		MOVE.W D5,(A0)+
		DBF D7,.trans_lp
		RTS

;-----------------------------------------------------------------------;
bnce_sclog	DC.L screens+256+16000
bnce_scphy	DC.L screens+256+16000
bnce_ptr	DC.W 46
bnce_tab	InCBIN SPH_BNCE.DAT
sin128_tab	INCBIN SIN128.TAB

sincostmp	DS.W 6
smmat_tmp	DS.W 9
xyz_ang		DC.W 8,16,32		
obj		DC.W 50-1
		INCBIN POLYCRDS.DAT

facelist	DC.W 10,40*6,41*6,42*6,43*6,44*6,45*6,46*6,47*6,48*6,49*6
		DC.W 10,09*6,08*6,07*6,06*6,05*6,04*6,03*6,02*6,01*6,00*6
		DC.W 4,01*6,11*6,10*6,00*6
		DC.W 4,02*6,12*6,11*6,01*6
		DC.W 4,03*6,13*6,12*6,02*6
		DC.W 4,04*6,14*6,13*6,03*6
		DC.W 4,05*6,15*6,14*6,04*6
		DC.W 4,06*6,16*6,15*6,05*6
		DC.W 4,07*6,17*6,16*6,06*6
		DC.W 4,08*6,18*6,17*6,07*6
		DC.W 4,09*6,19*6,18*6,08*6
		DC.W 4,00*6,10*6,19*6,09*6

		DC.W 4,11*6,21*6,20*6,10*6
		DC.W 4,12*6,22*6,21*6,11*6
		DC.W 4,13*6,23*6,22*6,12*6
		DC.W 4,14*6,24*6,23*6,13*6
		DC.W 4,15*6,25*6,24*6,14*6
		DC.W 4,16*6,26*6,25*6,15*6
		DC.W 4,17*6,27*6,26*6,16*6
		DC.W 4,18*6,28*6,27*6,17*6
		DC.W 4,19*6,29*6,28*6,18*6
		DC.W 4,10*6,20*6,29*6,19*6

		DC.W 4,21*6,31*6,30*6,20*6
		DC.W 4,22*6,32*6,31*6,21*6
		DC.W 4,23*6,33*6,32*6,22*6
		DC.W 4,24*6,34*6,33*6,23*6
		DC.W 4,25*6,35*6,34*6,24*6
		DC.W 4,26*6,36*6,35*6,25*6
		DC.W 4,27*6,37*6,36*6,26*6
		DC.W 4,28*6,38*6,37*6,27*6
		DC.W 4,29*6,39*6,38*6,28*6
		DC.W 4,20*6,30*6,39*6,29*6

		DC.W 4,31*6,41*6,40*6,30*6
		DC.W 4,32*6,42*6,41*6,31*6
		DC.W 4,33*6,43*6,42*6,32*6
		DC.W 4,34*6,44*6,43*6,33*6
		DC.W 4,35*6,45*6,44*6,34*6
		DC.W 4,36*6,46*6,45*6,35*6
		DC.W 4,37*6,47*6,46*6,36*6
		DC.W 4,38*6,48*6,47*6,37*6
		DC.W 4,39*6,49*6,48*6,38*6
		DC.W 4,30*6,40*6,49*6,39*6

; Draw That Object!!

Draw_obj	LEA facelist(PC),A0			; -> polylist

; A0 -> no. of faces in shape data.

Backface	MOVE.W #42,-(SP)			; no of faces
avfacelp	MOVEM 2(A0),D0/D5/D6/D7			; 1st three vertice ptrs
		MOVEM translated_crds(PC,D0),D1-D2	; x1,y1
		MOVEM translated_crds(PC,D5),D3-D4	; x2,y2
		SUB D3,D1				; (x1-x2)
		SUB D4,D2				; (y1-y2)
		SUB translated_crds(PC,D6),D3   	; (x2-x3)
		SUB translated_crds+2(PC,D6),D4 	; (y2-y3)
		MULS D4,D1				; (x1-x2)*(y2-y3)
		MULS D2,D3				; (y1-y2)*(x2-x3)
		SUB.L D3,D1				; can face be seen?
		BMI notseen		
		MOVE translated_crds+4(PC,D0),D1
		ADD translated_crds+4(PC,D5),D1
		ADD translated_crds+4(PC,D6),D1		; total Z
		ADD translated_crds+4(PC,D7),D1	
		NEG D1
		EXT.L D1
		DIVS #30,d1				; /30(gives nice range)
		BLE.S notseen
		CMP.W #$F,D1
		BLE.S .inrange
		MOVEQ #$F,D1
.inrange	LSL #5,D1				; *32 (smc lookup)
		MOVE.W D1,col
		MOVE (A0)+,d7				; no of vertices
		BSR Draw_poly				; return usp
		MOVE.L USP,A0		
		SUBQ #1,(SP)
		BNE.S avfacelp
		ADDQ.W #2,SP
		RTS
notseen		MOVE.W (A0)+,D7
		ADD D7,D7
		ADD D7,A0
		SUBQ #1,(SP)
		BNE.S avfacelp
		ADDQ.W #2,SP
		RTS
translated_crds	DS.W 3*50
p_space		DS.L 64

;----------------------------- Polyfill --------------------------------;
; D7 vertices -> A0 (list from translated co-ordinates)
; On exit USP points to end of vertice list(ready for next poly...)

Draw_poly	LEA translated_crds(PC),A3
		LEA p_space(PC),A5
		MOVE D7,D4
		ADD D4,D4
		ADD D4,D4
		MOVE.L A5,A1
		ADDA.W D4,A1
		MOVE.L A1,A2
		ADDA.W D4,A2
Init_coords	SUBQ #2,D7
		MOVE (A0)+,D1
		MOVE.L (A3,D1),D5
		MOVE D5,D2
		MOVE.L A1,A4
		MOVE.L D5,(A5)+
		MOVE.L D5,(A1)+
		MOVE.L D5,(A2)+
coord_lp	MOVE (A0)+,D1
		MOVE.L (A3,D1),D3
		CMP D2,D3
		BGE.S .not_top
		MOVE D3,D2
		MOVE.L A1,A4
.not_top	CMP D3,D5
		BGE.S .not_bot
		MOVE D3,D5	
.not_bot	MOVE.L D3,(A5)+
		MOVE.L D3,(A1)+			; duplicate 2 extra times!
		MOVE.L D3,(A2)+			; (to get list either side)
		DBF D7,coord_lp
		MOVE.L A0,USP
		MOVE.L A4,A5			; a4-> left side a5-> right
		SUB D2,D5			; d2 - lowest y  d7 - greatest y
		BEQ poly_done
		MOVE D2,D0			; save min y
CALCS		LEA grad_table+400(PC),A0
; Calc x's down left side of poly
Do_left		MOVE D5,D7
		LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #4,A4
		MOVEM.W (A4),D1-D4		; x1,y1,x2,y2
		SUB D4,D2			; dy
		SUB D3,D1			; dx
		SUB D2,D7			; remaining lines-dy
		ADD D2,D2
		MULS (A0,D2),D1
		ASL.L #3,D1			; frac.w/int.w (*4)
		SWAP D1				; (*4 for hline lookup)
		ADD D2,D2
		ADD D3,D3
		ADD D3,D3
		NEG D2
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADDX.L D1,D3
		ENDR
LEFTJMP		TST D7
		BGT Left_lp
; Calc x's down right side of poly
Do_right	MOVE.W D5,D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM (A5),D1-D4		; x1,y1,x2,y2
		ADDQ #4,A5
		SUB D2,D4			; dy
		SUB D1,D3			; dx
		SUB D4,D5			; remaining lines-dy
		ADD D4,D4
		MULS (A0,D4),D3
		ASL.L #3,D3
		SWAP D3
		ADD D4,D4
		ADD D1,D1
		ADD D1,D1
		NEG D4
		JMP (A2,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADDX.L D3,D1
		ENDR
RIGHTJMP	TST D5
		BGT Right_lp
		LEA x1s(PC),a1		; ptr to left edge co-ord list
		LEA x2s(PC),a2		;   "    right   "          "
		MOVE.L framelogbase(PC),A6
		LEA mul160(PC),A4
		ADD D0,D0
		ADD (A4,D0),A6
		MOVE col(PC),D1
		LEA .chunkmod1(PC),A3
		LEA Colour_SMC(PC),A4
		MOVEM.L (A4,D1),D0-D3/A4-A5
		MOVEM.L D0-D1,(A3)		; NAUGHTY but NICE!!!!!!
		MOVEM.L D0-D1,.chunkmod2-.chunkmod1(A3)
		MOVEM.L A4-A5,.chunkmod3-.chunkmod1(A3)
		LEA ch_vectl(PC),A3		; left mask table
		LEA ch_vectr(PC),A4		; right mask table
		SUBQ #1,D7
.scan_draw_lp	MOVEQ #-4,D0
		MOVEQ #-4,D1
		AND (A1)+,D0			; x1*4
		AND (A2)+,D1			; x2*4
		MOVE.L (A3,D0),D0		; left mask.W  \ offset.W
		MOVE.L (A4,D1),D1		; right mask.W \ offset.W
		ADD D0,D1			; -ve difference!
		BLT.S .bigcase			; same chunk?
		BNE .next_line			;; one chunk case...
		ADD.W D0,D0			;;
		MOVE.L A6,A0			;;
		ADDA.W D0,A0 			;; -> chunk
		AND.L D1,D0			;;
		SWAP D0				;;
		MOVE.W D0,D4			;;
		NOT.W D4			;;
.chunkmod1	OR.W D0,(A0)+			;;
		OR.W D0,(A0)+			;; mask it to
		OR.W D0,(A0)+			;; the screen.
		AND.W D1,(A0)+			;;
		LEA 160(A6),A6			; next screen line
		DBF D7,.scan_draw_lp	
		BRA.S poly_done			
.bigcase	ADD.W D0,D0			; over more than on
		MOVE.L A6,A0			; chunk
		ADDA.W D0,A0 			; -> left of hline
		SWAP D0
		MOVE.W D0,D4
		NOT.W D4
.chunkmod2	OR D0,(A0)+
		OR D0,(A0)+			; mask first word
		AND.W D4,(A0)+			; (self modifyed)
		AND.W D4,(A0)+
		JMP .miss_main+4(PC,D1)		; jump back thru list
		REPT 19
		MOVE.L D2,(A0)+			; solid colour
		MOVE.L D3,(A0)+			; (middle of hline)
		ENDR
.miss_main	SWAP D1				; right mask
		MOVE.W D1,D0
		NOT.W D1
.chunkmod3	OR D0,(A0)+
		OR D0,(A0)+			; mask last word
		AND.W D1,(A0)+			; (self modifyed)
		AND.W D1,(A0)+
.next_line	LEA 160(A6),A6			; next screen line
		DBF D7,.scan_draw_lp
poly_done	RTS

; Multplication gradient table for poly edges

grad_table	dc.w	$FF5D,$FF5C,$FF5B,$FF5A,$FF59,$FF58,$FF58,$FF57 
		dc.w	$FF56,$FF55,$FF54,$FF53,$FF52,$FF51,$FF50,$FF4F 
		dc.w	$FF4E,$FF4D,$FF4C,$FF4B,$FF4A,$FF49,$FF48,$FF47 
		dc.w	$FF46,$FF45,$FF44,$FF43,$FF42,$FF41,$FF40,$FF3F 
		dc.w	$FF3D,$FF3C,$FF3B,$FF3A,$FF39,$FF37,$FF36,$FF35 
		dc.w	$FF34,$FF32,$FF31,$FF30,$FF2E,$FF2D,$FF2C,$FF2A 
		dc.w	$FF29,$FF28,$FF26,$FF25,$FF23,$FF22,$FF20,$FF1F 
		dc.w	$FF1D,$FF1B,$FF1A,$FF18,$FF16,$FF15,$FF13,$FF11 
		dc.w	$FF10,$FF0E,$FF0C,$FF0A,$FF08,$FF06,$FF04,$FF02 
		dc.w	$FF01,$FEFE,$FEFC,$FEFA,$FEF8,$FEF6,$FEF4,$FEF2 
		dc.w	$FEEF,$FEED,$FEEB,$FEE8,$FEE6,$FEE4,$FEE1,$FEDF 
		dc.w	$FEDC,$FED9,$FED7,$FED4,$FED1,$FECE,$FECB,$FEC8 
		dc.w	$FEC5,$FEC2,$FEBF,$FEBC,$FEB9,$FEB6,$FEB2,$FEAF 
		dc.w	$FEAB,$FEA8,$FEA4,$FEA0,$FE9C,$FE98,$FE94,$FE90 
		dc.w	$FE8C,$FE88,$FE83,$FE7F,$FE7A,$FE76,$FE71,$FE6C 
		dc.w	$FE67,$FE62,$FE5C,$FE57,$FE51,$FE4C,$FE46,$FE40 
		dc.w	$FE39,$FE33,$FE2C,$FE26,$FE1F,$FE17,$FE10,$FE08 
		dc.w	$FE01,$FDF8,$FDF0,$FDE7,$FDDE,$FDD5,$FDCC,$FDC2 
		dc.w	$FDB7,$FDAD,$FDA2,$FD96,$FD8A,$FD7E,$FD71,$FD64 
		dc.w	$FD56,$FD47,$FD38,$FD28,$FD18,$FD06,$FCF4,$FCE1 
		dc.w	$FCCD,$FCB8,$FCA2,$FC8B,$FC72,$FC58,$FC3D,$FC20 
		dc.w	$FC01,$FBE0,$FBBC,$FB97,$FB6E,$FB43,$FB14,$FAE2 
		dc.w	$FAAB,$FA70,$FA2F,$F9E8,$F99A,$F944,$F8E4,$F879 
		dc.w	$F801,$F778,$F6DC,$F628,$F556,$F45E,$F334,$F1C8 
		dc.w	$F001,$EDB7,$EAAB,$E667,$E001,$D556,$C001,$8001 
		dc.w	$0000,$7FFF,$3FFF,$2AAA,$1FFF,$1999,$1555,$1249 
		dc.w	$0FFF,$0E38,$0CCC,$0BA2,$0AAA,$09D8,$0924,$0888 
		dc.w	$07FF,$0787,$071C,$06BC,$0666,$0618,$05D1,$0590 
		dc.w	$0555,$051E,$04EC,$04BD,$0492,$0469,$0444,$0420 
		dc.w	$03FF,$03E0,$03C3,$03A8,$038E,$0375,$035E,$0348 
		dc.w	$0333,$031F,$030C,$02FA,$02E8,$02D8,$02C8,$02B9 
		dc.w	$02AA,$029C,$028F,$0282,$0276,$026A,$025E,$0253 
		dc.w	$0249,$023E,$0234,$022B,$0222,$0219,$0210,$0208 
		dc.w	$01FF,$01F8,$01F0,$01E9,$01E1,$01DA,$01D4,$01CD 
		dc.w	$01C7,$01C0,$01BA,$01B4,$01AF,$01A9,$01A4,$019E 
		dc.w	$0199,$0194,$018F,$018A,$0186,$0181,$017D,$0178 
		dc.w	$0174,$0170,$016C,$0168,$0164,$0160,$015C,$0158 
		dc.w	$0155,$0151,$014E,$014A,$0147,$0144,$0141,$013E 
		dc.w	$013B,$0138,$0135,$0132,$012F,$012C,$0129,$0127 
		dc.w	$0124,$0121,$011F,$011C,$011A,$0118,$0115,$0113 
		dc.w	$0111,$010E,$010C,$010A,$0108,$0106,$0104,$0102 
		dc.w	$00FF,$00FE,$00FC,$00FA,$00F8,$00F6,$00F4,$00F2 
		dc.w	$00F0,$00EF,$00ED,$00EB,$00EA,$00E8,$00E6,$00E5 
		dc.w	$00E3,$00E1,$00E0,$00DE,$00DD,$00DB,$00DA,$00D8 
		dc.w	$00D7,$00D6,$00D4,$00D3,$00D2,$00D0,$00CF,$00CE 
		dc.w	$00CC,$00CB,$00CA,$00C9,$00C7,$00C6,$00C5,$00C4 
		dc.w	$00C3,$00C1,$00C0,$00BF,$00BE,$00BD,$00BC,$00BB 
		dc.w	$00BA,$00B9,$00B8,$00B7,$00B6,$00B5,$00B4,$00B3 
		dc.w	$00B2,$00B1,$00B0,$00AF,$00AE,$00AD,$00AC,$00AB 
		dc.w	$00AA,$00A9,$00A8,$00A8,$00A7,$00A6,$00A5,$00A4 
		dc.w	$00A3 

; Self-modify bits and solid colour data.

Colour_SMC
.col0		AND D4,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		DC.L $00000000,$00000000
		AND D1,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		DS.L 2

.col1		OR D0,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		DC.L $FFFF0000,$00000000
		OR D0,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		DS.L 2

.col2		AND D4,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		DC.L $0000FFFF,$00000000
		AND D1,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		DS.L 2

.col3		OR D0,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		DC.L $FFFFFFFF,$00000000
		OR D0,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		DS.L 2

.col4		AND D4,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		DC.L $00000000,$FFFF0000
		AND D1,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		DS.L 2

.col5		OR D0,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		DC.L $FFFF0000,$FFFF0000
		OR D0,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		DS.L 2

.col6		AND D4,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		DC.L $0000FFFF,$FFFF0000
		AND D1,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		DS.L 2

.col7		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		DC.L $FFFFFFFF,$FFFF0000
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		DS.L 2

.col8		AND D4,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		DC.L $00000000,$0000FFFF
		AND D1,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		DS.L 2

.col9		OR D0,(A0)+
		AND D4,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
	 	DC.L $FFFF0000,$0000FFFF
		OR D0,(A0)+
		AND D1,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		DS.L 2

.col10		AND D4,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		DC.L $0000FFFF,$0000FFFF
		AND D1,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		DS.L 2

.col11		OR D0,(A0)+
		OR D0,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		DC.L $FFFFFFFF,$0000FFFF
		OR D0,(A0)+
		OR D0,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		DS.L 2

.col12		AND D4,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $00000000,$FFFFFFFF
		AND D1,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DS.L 2

.col13		OR D0,(A0)+
		AND D4,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $FFFF0000,$FFFFFFFF
		OR D0,(A0)+
		AND D1,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DS.L 2

.col14		AND D4,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $0000FFFF,$FFFFFFFF
		AND D1,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DS.L 2

.col15		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $FFFFFFFF,$FFFFFFFF
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DS.L 2

x1s		DS.W 210
x2s		DS.W 210
col		DS.W 1

; End masks and screen offset tables for normal fill.
		
i		SET 0
ch_vectl	
		REPT 20
		DC.W %1111111111111111,i
		DC.W %0111111111111111,i
		DC.W %0011111111111111,i
		DC.W %0001111111111111,i
		DC.W %0000111111111111,i
		DC.W %0000011111111111,i
		DC.W %0000001111111111,i
		DC.W %0000000111111111,i
		DC.W %0000000011111111,i
		DC.W %0000000001111111,i
		DC.W %0000000000111111,i
		DC.W %0000000000011111,i
		DC.W %0000000000001111,i
		DC.W %0000000000000111,i
		DC.W %0000000000000011,i
		DC.W %0000000000000001,i
i		SET i+4
		ENDR

i		SET 0
ch_vectr	
		REPT 20
		DC.W %1000000000000000,-i
		DC.W %1100000000000000,-i
		DC.W %1110000000000000,-i
		DC.W %1111000000000000,-i
		DC.W %1111100000000000,-i
		DC.W %1111110000000000,-i
		DC.W %1111111000000000,-i
		DC.W %1111111100000000,-i
		DC.W %1111111110000000,-i
		DC.W %1111111111000000,-i
		DC.W %1111111111100000,-i
		DC.W %1111111111110000,-i
		DC.W %1111111111111000,-i
		DC.W %1111111111111100,-i
		DC.W %1111111111111110,-i
		DC.W %1111111111111111,-i
i		SET i+4
		ENDR

		SECTION BSS
bigtable	DS.L 16384
screens		DS.B 256
		DS.W 42240/2
		DS.W 42240/2
		DS.B 256

		DS.L 249
stack		DS.L 3

