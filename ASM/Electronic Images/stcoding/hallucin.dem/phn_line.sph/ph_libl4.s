;----------------------------------------------------------------------
;                         Hallucinations demo.
;
; 'The Big Bouncing Sphere made from 98, points / 182 LINES!!!!!(25 FPS)
; ST/STE conversion by Griff of Electronic Images. (The Inner Circle)
;----------------------------------------------------------------------

demo		EQU 0				; 0=gem 1=from DMA disk

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
		MOVE #$200,$ffff8240.W
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
		MOVEQ #4,D4
		MOVEQ #32-1,D1
.y_lp		MOVEQ #32-1,D0
.x_lp		MOVE.L A0,(A2)+
		ADD.W D4,A0
		DBF D0,.x_lp
		ADDQ #4,D4
		DBF D1,.y_lp
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
clearscreen	
		LEA $FFFF8A00.W,A5
		MOVE.B #0,HOP(A5)
		MOVE.B #0,OP(A5)
		MOVE.W #8,dst_xinc(A5)
		MOVE.W #64+8,dst_yinc(A5)
		MOVE.W #12,x_count(A5)

		MOVE.L A0,dst_addr(A5)
		MOVE.W #200-32,y_count(A5)
		MOVE.B #%11000000,line_num(A5)	
		ADDQ.L #2,A0
		MOVE.L A0,dst_addr(A5)
		MOVE.W #200-32,y_count(A5)
		MOVE.B #%11000000,line_num(A5)	

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
		LEA translated_crds,A0
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
		MULS #$6610,D3
		MULS #$6610,D4
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

Draw_lines	LEA $FFFF8A00.W,A6
		MOVE.B #2,HOP(A6)
		MOVE.B #7,OP(A6)
		MOVE.W #-1,endmask2(A6)
		MOVE.W #2,src_xinc(A6)
		MOVE.W #2,src_yinc(A6)
		MOVE.W #3,x_count(A6)
		MOVE.W #8,dst_xinc(A6)
		MOVE.B #%11000000,D7

		LEA linejmps,A2
		LEA mul160(PC),A3
		LEA bnce_sclog(PC),A4
		TST.W frame_switch
		BEQ.S .cse2
		LEA bnce_scphy(PC),A4
.cse2		MOVE.L (A4),A4
		LEA translated_crds,A5

dl		MACRO
		MOVEM.W \1(A5),D0-D1
		MOVEM.W \2(A5),D2-D3
		LEA (A4),A1
		TST.W \2+4(A5)
		BGT.S .ok\@
		ADDQ.L #2,A1
.ok\@		BSR Drawline
		ENDM

		dl	$0000,$0008
		dl	$0008,$0010
		dl	$0010,$0018
		dl	$0018,$0020 
		dl	$0020,$0028
		dl	$0028,$0030
		dl	$0030,$0038
		dl	$0038,$0040 
		dl	$0040,$0048
		dl	$0048,$0050
		dl	$0050,$0058
		dl	$0058,$0060 
		dl	$0060,$0068
		dl	$0068,$0000
		dl	$0070,$0078
		dl	$0078,$0080 
		dl	$0080,$0088
		dl	$0088,$0090
		dl	$0090,$0098
		dl	$0098,$00A0 
		dl	$00A0,$00A8
		dl	$00A8,$00B0
		dl	$00B0,$00B8
		dl	$00B8,$00C0 
		dl	$00C0,$00C8
		dl	$00C8,$00D0
		dl	$00D0,$00D8
		dl	$00D8,$0070 
		dl	$00E0,$00E8
		dl	$00E8,$00F0
		dl	$00F0,$00F8
		dl	$00F8,$0100 
		dl	$0100,$0108
		dl	$0108,$0110
		dl	$0110,$0118
		dl	$0118,$0120 
		dl	$0120,$0128
		dl	$0128,$0130
		dl	$0130,$0138
		dl	$0138,$0140 
		dl	$0140,$0148
		dl	$0148,$00E0
		dl	$0150,$0158
		dl	$0158,$0160 
		dl	$0160,$0168
		dl	$0168,$0170
		dl	$0170,$0178
		dl	$0178,$0180 
		dl	$0180,$0188
		dl	$0188,$0190
		dl	$0190,$0198
		dl	$0198,$01A0 
		dl	$01A0,$01A8
		dl	$01A8,$01B0
		dl	$01B0,$01B8
		dl	$01B8,$0150 
		dl	$01C0,$01C8
		dl	$01C8,$01D0
		dl	$01D0,$01D8
		dl	$01D8,$01E0 
		dl	$01E0,$01E8
		dl	$01E8,$01F0
		dl	$01F0,$01F8
		dl	$01F8,$0200 
		dl	$0200,$0208
		dl	$0208,$0210
		dl	$0210,$0218
		dl	$0218,$0220 
		dl	$0220,$0228
		dl	$0228,$01C0
		dl	$0230,$0238
		dl	$0238,$0240 
		dl	$0240,$0248
		dl	$0248,$0250
		dl	$0250,$0258
		dl	$0258,$0260 
		dl	$0260,$0268
		dl	$0268,$0270
		dl	$0270,$0278
		dl	$0278,$0280 
		dl	$0280,$0288
		dl	$0288,$0290
		dl	$0290,$0298
		dl	$0298,$0230 
		dl	$02A0,$02A8
		dl	$02A8,$02B0
		dl	$02B0,$02B8
		dl	$02B8,$02C0 
		dl	$02C0,$02C8
		dl	$02C8,$02D0
		dl	$02D0,$02D8
		dl	$02D8,$02E0 
		dl	$02E0,$02E8
		dl	$02E8,$02F0
		dl	$02F0,$02F8
		dl	$02F8,$0300 
		dl	$0300,$0308
		dl	$0308,$02A0
		dl	$0000,$0070
		dl	$0070,$00E0 
		dl	$00E0,$0150
		dl	$0150,$01C0
		dl	$01C0,$0230
		dl	$0230,$02A0 
		dl	$0008,$0078
		dl	$0078,$00E8
		dl	$00E8,$0158
		dl	$0158,$01C8 
		dl	$01C8,$0238
		dl	$0238,$02A8
		dl	$0010,$0080
		dl	$0080,$00F0 
		dl	$00F0,$0160
		dl	$0160,$01D0
		dl	$01D0,$0240
		dl	$0240,$02B0 
		dl	$0018,$0088
		dl	$0088,$00F8
		dl	$00F8,$0168
		dl	$0168,$01D8 
		dl	$01D8,$0248
		dl	$0248,$02B8
		dl	$0020,$0090
		dl	$0090,$0100 
		dl	$0100,$0170
		dl	$0170,$01E0
		dl	$01E0,$0250
		dl	$0250,$02C0 
		dl	$0028,$0098
		dl	$0098,$0108
		dl	$0108,$0178
		dl	$0178,$01E8 
		dl	$01E8,$0258
		dl	$0258,$02C8
		dl	$0030,$00A0
		dl	$00A0,$0110 
		dl	$0110,$0180
		dl	$0180,$01F0
		dl	$01F0,$0260
		dl	$0260,$02D0 
		dl	$0038,$00A8
		dl	$00A8,$0118
		dl	$0118,$0188
		dl	$0188,$01F8 
		dl	$01F8,$0268
		dl	$0268,$02D8
		dl	$0040,$00B0
		dl	$00B0,$0120 
		dl	$0120,$0190
		dl	$0190,$0200
		dl	$0200,$0270
		dl	$0270,$02E0 
		dl	$0048,$00B8
		dl	$00B8,$0128
		dl	$0128,$0198
		dl	$0198,$0208 
		dl	$0208,$0278
		dl	$0278,$02E8
		dl	$0050,$00C0
		dl	$00C0,$0130 
		dl	$0130,$01A0
		dl	$01A0,$0210
		dl	$0210,$0280
		dl	$0280,$02F0 
		dl	$0058,$00C8
		dl	$00C8,$0138
		dl	$0138,$01A8
		dl	$01A8,$0218 
		dl	$0218,$0288
		dl	$0288,$02F8
		dl	$0060,$00D0
		dl	$00D0,$0140 
		dl	$0140,$01B0
		dl	$01B0,$0220
		dl	$0220,$0290
		dl	$0290,$0300 
		dl	$0068,$00D8
		dl	$00D8,$0148
		dl	$0148,$01B8
		dl	$01B8,$0228 
		dl	$0228,$0298
		dl	$0298,$0308 
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
		ADD D5,D5
		ADD D5,D5
		MOVE.L xtab(PC,D5),D5
		LSR #1,D0			; x word offset
		SUB.W D1,D3			; dy
		MOVE.W D3,D4
		BGE.S posdy
.negdy		NEG D4
		ADDQ.W #1,D4
		MOVE.W D4,y_count(A6)
		ADD.W D1,D1			; y*2
		ADD.W (A3,D1),D0		; scr offset
		ADD.W D0,A0			; scrbase
		ASL.W #5,D3			; dy*16
		SUB.W D3,D2			; x -- dy (so x+dy!!)
		ADD.W D2,D2
		ADD.W D2,D2
		MOVE.L (A2,D2.W),src_addr(A6)
		MOVE.L A0,dst_addr(A6)
		MOVE.W #-(160+16),dst_yinc(A6)
		MOVE.B D5,skew(A6)
		MOVE.W D5,endmask1(A6)
		NOT D5
		MOVE.W D5,endmask3(A6)
		MOVE.B D7,line_num(A6)	
		RTS
xtab		
		DC.W $FFFF,64+0
		DC.W $7FFF,64+1
		DC.W $3FFF,64+2
		DC.W $1FFF,64+3
		DC.W $0FFF,64+4
		DC.W $07FF,64+5
		DC.W $03FF,64+6
		DC.W $01FF,64+7
		DC.W $00FF,64+8
		DC.W $007F,64+9
		DC.W $003F,64+10
		DC.W $001F,64+11
		DC.W $000F,64+12
		DC.W $0007,64+13
		DC.W $0003,64+14
		DC.W $0001,64+15

posdy		ADDQ.W #1,D4
		MOVE.W D4,y_count(A6)
		ADD.W D1,D1			; y*2
		ADD.W (A3,D1),D0		; scr offset
		ADD.W D0,A0			; scrbase
		ASL.W #5,D3			; dy*16
		ADD.W D3,D2
		ADD.W D2,D2
		ADD.W D2,D2
		MOVE.L (A2,D2.W),src_addr(A6)
		MOVE.L A0,dst_addr(A6)
		MOVE.W #160-16,dst_yinc(A6)
		MOVE.B D5,skew(A6)
		MOVE.W D5,endmask1(A6)
		NOT D5
		MOVE.W D5,endmask3(A6)
		MOVE.B D7,line_num(A6)	
		RTS


i		SET 0
mul160		
		REPT 50
		dc i,i+160,i+320,i+480
i		SET i+640
		ENDR


;-----------------------------------------------------------------------;
bnce_sclog	DC.L screens+256+16000
bnce_scphy	DC.L screens+256+16000
bnce_ptr	DC.W 44
bnce_tab	INCBIN SPH_BNCE.DAT

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

sin128_tab	INCBIN  SIN128.TAB
linedat		INCBIN line3232.dat

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
linejmps	DS.L 32*32
