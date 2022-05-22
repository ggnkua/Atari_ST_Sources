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

; Blitter Equates 

halftone	EQU 0
src_xinc	EQU $20
src_yinc	EQU $22
src_addr	EQU $24
endmask1	EQU $28
endmask2	EQU $2A
endmask3	EQU $2C
dst_xinc	EQU $2E
dst_yinc	EQU $30
dst_addr	EQU $32
x_count		EQU $36
y_count		EQU $38
HOP		EQU $3A
OP		EQU $3B
line_num	EQU $3C
skew		EQU $3D

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
		BSR make160table
		
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
;		MOVE #$300,$ffff8240.W
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
		;MOVE.B #199,$FFFFFA21.W
		;MOVE.B #8,$FFFFFA1B.W
		;LEA bot_bord(PC),A0
		;MOVE.L A0,$120.W
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
framelogbase	DC.L screens+256

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
bnce_tab	INCBIN SPH_BNCE.DAT
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
		asr.w #5,d1
		BLE notseen
		CMP.W #7,D1
		BLE.S .inrange
		MOVEQ #7,D1
.inrange	MOVE.W D1,col
		MOVE (A0)+,d7				; no of vertices
		BSR Draw_poly				; return usp
		MOVE.L USP,A0		
		SUBQ #1,(SP)
		BNE.S avfacelp
		BRA doneobj

translated_crds	DS.W 3*190

notseen		MOVE.W (A0)+,D7
		ADD D7,D7
		ADD D7,A0
		SUBQ #1,(SP)
		BNE avfacelp
doneobj		ADDQ.l #2,SP
		
		LEA $FFFF8A00.W,A4    	
		MOVE.L framelogbase(PC),A5
		lea (34*160)+40(a5),a5
		LEA 160(A5),A6
		MOVE.L #-1,endmask1(a4)
		MOVE.W #-1,endmask3(a4)	; set end masks
		MOVE.L A5,src_addr(A4)  ; source address
		MOVE.L A6,dst_addr(A4)  ; dest address
		MOVE.W #40,x_count(A4)	; no of words to write		
		MOVE.W #134-1,y_count(A4)  ; 
		MOVE.W #2,dst_xinc(A4)
		MOVE.W #82,dst_yinc(A4)
		MOVE.W #2,src_xinc(A4)
		MOVE.W #82,src_yinc(A4)
		MOVE.B #2,HOP(A4)      ; hop
		MOVE.B #6,OP(A4)       ; replace
		move.b #%00000000,skew(a4)
		MOVE.b #%11000000,line_num(A4)	
		RTS

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.	;
; D0-D3 holds x1,y1/x2,y2       D0-D6/A0 smashed.       		;
;-----------------------------------------------------------------------;

xmax		EQU 319
ymax		EQU 199

DrawLine	MOVE.L framelogbase(PC),A6
		BTST.B #0,col+1
		beq.s .cse1
		bsr drawl
.cse1		lea 2(a6),a6
		BTST.B #1,col+1
		beq.s .cse2
		bsr drawl
.cse2		lea 2(a6),a6
		BTST.B #2,col+1
		beq.s .cse3
		bsr drawl
.cse3

		rts

drawl		MOVEM.W D0-D3,-(SP)
		bsr draw
		MOVEM.W (SP)+,D0-D3
		rts

draw		MOVE.L A6,A0
cliponx		CMP.W D0,D2			; CLIP ON X				
		BGE.S .gofordraw
		EXG D0,D2			; reorder
		EXG D1,D3
.gofordraw	MOVE.W D2,D4
		SUB.W D0,D4			; dx
		MOVE.W D3,D5
		SUB.W D1,D5			; dy
		ADD D2,D2
		ADD D2,D2
		LEA bit_offs(PC),A2
		MOVE.L (A2,D2),D6		; mask/chunk offset
		ADD D3,D3
		LEA blmul_160(PC),A2
		ADD (A2,D3),D6			; add scr line
		ADDA.W D6,A0			; a0 -> first chunk of line
		SWAP D6				; get mask
		MOVE.W #-160,D3
		TST.W D5			; draw from top to bottom?
		BGE.S bottotop
		NEG.W D5			; no so negate vals
		NEG.W D3
bottotop	CMP.W D4,D5			; dy>dx?
		BLT dxbiggerdy

; DY>DX Line drawing case

dybiggerdx	MOVE.W D5,D1			; yes!
		BEQ nodraw			; dy=0 nothing to draw(!)
		ASR.W #1,D1			; e=dy/2
		MOVE.W D5,D2
		SUBQ.W #1,D2			; lines to draw-1(dbf)

dydx1		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx2		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx3		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx4		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx5		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx6		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
dydx7		EOR.W D6,(A0)
.lp		ADDA.W D3,A0
		SUB.W D4,D1
		BGT.S .nostep
		EOR.W D6,(A0)
		ADD.W D5,D1
		ADD.W D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ #1,D6
.nostep		DBF D2,.lp
.drawn		EOR.W D6,(A0)
		RTS
nodraw		RTS

; DX>DY Line drawing case

dxbiggerdy	CLR.W D2
		MOVE.W D4,D1
		ASR.W #1,D1			; e=dx/2
		MOVE.W D4,D0
		SUBQ.W #1,D0
dxdy1		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS
dxdy2		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS
dxdy3		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS
dxdy4		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS
dxdy5		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS
dxdy6		EOR.W D6,(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		RTS

dxdy7		EOR.W D6,(A0)
		EOR.W D6,2(A0)
		EOR.W D6,4(A0)
.lp		OR.W D6,D2
		SUB.W D5,D1
		BGE.S .nostep
		EOR.W D2,(A0)
		EOR.W D2,2(A0)
		EOR.W D2,4(A0)
		ADDA.W D3,A0
		ADD.W D4,D1
		CLR.W D2
.nostep		ADD.W D6,D6
		DBCS D0,.lp
		BCC.S .drawn
.wrchnk		EOR.W D2,(A0)
		EOR.W D2,2(A0)
		EOR.W D2,4(A0)
		SUBQ.W #8,A0
		CLR.W D2
		MOVEQ #1,D6
		DBF D0,.lp
.drawn		OR.W D6,D2
		EOR.W D2,(A0)
		EOR.W D2,2(A0)
		EOR.W D2,4(A0)
		RTS



i		SET 0
bit_offs	
		REPT 20
		DC.W $8000,i
		DC.W $4000,i
		DC.W $2000,i
		DC.W $1000,i
		DC.W $0800,i
		DC.W $0400,i
		DC.W $0200,i
		DC.W $0100,i
		DC.W $0080,i
		DC.W $0040,i
		DC.W $0020,i
		DC.W $0010,i
		DC.W $0008,i
		DC.W $0004,i
		DC.W $0002,i
		DC.W $0001,i
i		SET i+8
		ENDR

;----------------------------- Polyfill --------------------------------;
; D7 vertices -> A0 (list from translated co-ordinates)
; On exit USP points to end of vertice list(ready for next poly...)

Draw_poly	MOVE.L A0,A5
		MOVE.L A5,A3
		LEA translated_crds(PC),A4
		NEG.W D7
		ADD.W #13,D7
		mulu #20,d7
		JMP .ere(PC,D7)			
.ere		
		REPT 12
		MOVE (A5)+,D0
		MOVEM.W (A4,D0),D0/D1
		MOVE (A5),D7
		MOVEM.W (A4,D7),D2/D3
		BSR DrawLine
		ENDR

		MOVE (A5)+,D7
		MOVEM.W (A4,D7),D0/D1
		MOVE (A3),D7
		MOVEM.W (A4,D7),D2/D3
		BSR DrawLine
	
		MOVE.L A5,USP
		RTS

col		DS.W 1

make160table	lea blmul_160(pc),a0		; create *160 lookup
		moveq #0,d0
		move #200-1,d1
.lp		move.w d0,(a0)+
		add #160,d0
		dbf d1,.lp
		rts
blmul_160	ds.w 200

		SECTION BSS
bigtable	DS.L 16384
screens		DS.B 256
		DS.W 42240/2
		DS.W 42240/2
		DS.B 256

		DS.L 399
stack		DS.L 3

