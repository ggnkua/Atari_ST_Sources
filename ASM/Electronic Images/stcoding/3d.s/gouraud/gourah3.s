;-----------------------------------------------------------------------;
;									;
;   Fast Gouraud shading polygon routines,				;
; 				    by Martin Griffiths December 1991	;
;									;
; - Interpolation with "Moire" patterns - slower than solid colour	;
;   shading, but looks a lot better!					;
;									;
;-----------------------------------------------------------------------;

		OPT O+,OW-

demo		EQU 0

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
		ENDC

letsgo		MOVE.L SP,oldsp
		LEA my_stack,SP
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		IFNE demo
		JSR $508
		ENDC

		BSR flush
		BSR makegradtab
		BSR Initscreens
		LEA oldmfp(PC),A0
		MOVE.L $14.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA23.W,(A0)+
		LEA anrte(PC),A0
		MOVE.L A0,$14.W
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		LEA tc_ratecounter(PC),A0
		MOVE.L A0,$114.W 
		MOVE.B #$70,$FFFFFA1D.W
		CLR.B $FFFFFA1B.W
		MOVE.L #ltext_hbl,$120.W
		MOVE.B #1,$FFFFFA07.W
		MOVE.B #$20,$fffffa09.W 
		MOVE.B #1,$FFFFFA13.W
		MOVE.B #$20,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 
		LEA G_Sequence,A0
		LEA (A0),A1
		BSR Init_Seq	
		BSR wait_vbl
		CLR.W vbl_timer
		CLR.W tc_count
		BSR readrate 

.vbl_lp		BSR ClearIt
	  	BSR Matrix_make
		BSR Do_Sequence
		MOVE.L g_objptr(PC),A0 
		BSR Draw_GObj
		BSR SwapScreens
		IFEQ demo
		CMP.B #$39,$FFFFFC02.W
		BEQ.S .exit
		ENDC

		TST.B demo_finished
		BEQ.S .vbl_lp

.exit		MOVE #$2700,SR 
		LEA oldmfp(PC),A0
		MOVE.L (A0)+,$14.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$120.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA23.W
		MOVE.B #$C0,$FFFFFA23.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		MOVE.W #$2300,SR
		
		IFEQ demo
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
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
oldres		DC.W 0
oldbase		DC.L 0
		ENDC
		MOVE.L oldsp(PC),SP
		RTS
oldsp		DS.L 1

oldmfp		DS.L 22

; Initialise 3 screens.

Initscreens	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		ADD.L #32000,D0
		MOVE.L D0,(A1)+
		ADD.L #32000,D0
		MOVE.L D0,(A1)+
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Clear screen very quickly.

ClearIt		MOVE.L log_base(PC),A0
		LEA (36*160)+48(A0),A0
		MOVEQ #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,D7
i		SET 0
		REPT 128
		MOVEM.L D0-D7,i(A0) 
		MOVEM.L D0-D7,i+32(A0) 
i		SET i+160
		ENDR
		RTS

; Swap Screen ptrs and set hware reg.

SwapScreens    	
.wait		TST vbl_timer
		BEQ.s .wait
		CLR.W vbl_timer
		MOVE.W #$2700,SR
		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,-8(A0)
		MOVE.L (A0),-4(A0) 
		MOVE.L D0,(A0) 
		LEA $FFFF8201.W,A0
		LSR.L #8,D0 
		MOVEP.W D0,(A0) 
		MOVE.W #$2300,SR
		RTS 

wait_vbl	MOVE.W vbl_timer(PC),D0
.waitvb		CMP.W vbl_timer(PC),D0	
		BEQ.S .waitvb
		RTS

; space station

pal6	  	DC.W $000,$410,$520,$630,$740,$750,$760,$770
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

pal1	  	DC.W $000,$103,$203,$303,$403,$503,$603,$703
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

pal2	  	DC.W $000,$001,$002,$003,$004,$005,$006,$007
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

pal3	  	DC.W $000,$012,$123,$234,$345,$456,$567,$677
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

pal4	  	DC.W $000,$120,$231,$342,$453,$564,$675,$776
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

pal5	  	DC.W $000,$012,$022,$032,$042,$052,$062,$072
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

; Little old vbl..

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.B #190,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L #ltext_hbl,$120.W
		MOVEM.L currpal(PC),D0-D7 
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		BSR littletext
		BSR fadein
		BSR fadeout
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer  	
		RTE 
currpal		DS.W 16

vbl_timer	DC.W 0

ltext_hbl	MOVE.W ltext_struc(PC),$FFFF8242.W
		CLR.B $FFFFFA1B.W
		RTE

; Little text rout.

base_offy	EQU 192*160

		RSRESET
plane1col	RS.W 1
text_tmr	RS.W 1
text_ptr	RS.L 1
tis_fade	RS.W 1
curr_x		RS.W 1
ltext_strucsize	RS.B 0

littletext	LEA ltext_struc(PC),A5
		TST.B tis_fade(A5)
		BEQ.S .notfade
		CMP.B #1,tis_fade(A5)
		BEQ.S .cse1
		CMP.B #2,tis_fade(A5)
		BEQ.S .cse2
		CMP.B #3,tis_fade(A5)
		BEQ.S .cse3

.cse1		ADD #$111,plane1col(A5)
		CMP #$777,plane1col(A5)
		BNE.S .nodone1
		MOVE.W #185,text_tmr(A5)
		MOVE.B #2,tis_fade(A5)	
.nodone1	RTS

.cse2		SUBQ #1,text_tmr(A5)
		BGE.S .nodone2
		MOVE.B #3,tis_fade(A5)
.nodone2	RTS

.cse3		SUB #$111,plane1col(A5)
		BNE.S .nodone3
		MOVE.B #0,tis_fade(A5)	
.nodone3	RTS

.notfade	MOVE.W curr_x(A5),D0
		LEA textofftab(PC),A3
		ADD.W D0,D0
		MOVE.W (A3,D0),D0
		MOVE.L log_base(PC),A0	
		MOVE.L log_base+4(PC),A1	
		MOVE.L log_base+8(PC),A2
		LEA base_offy(A0),A0
		LEA base_offy(A1),A1
		LEA base_offy(A2),A2
		ADD.W D0,A0
		ADD.W D0,A1
		ADD.W D0,A2
		LEA ltext(PC),A3
		ADD.L text_ptr(A5),A3
		CLR D0
		MOVE.B (A3)+,D0
		SUB.B #32,D0
		LSL #3,D0
		LEA font8(PC),A3
		ADD.W D0,A3
i		SET 0
		REPT 8
		MOVE.B (A3)+,D0
		MOVE.B D0,i(A0)
		MOVE.B D0,i(A1)
		MOVE.B D0,i(A2)
i		SET i+160
		ENDR

		ADDQ.L #1,text_ptr(A5)
		ADDQ #1,curr_x(A5)
		CMP.W #40,curr_x(A5)
		BNE.S .nodoanything
		CLR.W curr_x(A5)
		MOVE.B #1,tis_fade(A5)
.nodoanything	RTS
font8		INCBIN D:\GRAPHICS\FONTS__8.RAW\MET_09.FN8

;		DC.B "0123456789012345678901234567890123456789"
ltext		DC.B "                                        "
		DC.B "    REALTIME GOURAUD POLYGON FILLING    "  
		DC.B "             BROUGHT TO YOU             "
		DC.B "     BY GRIFF OF ELECTRONIC IMAGES.     "
		DC.B "  ALL OBJECTS RUN BETWEEN 8 AND 25 FPS  "
		DC.B "  NO TRICKS ARE USED,JUST BRUTE FORCE.  "
		DC.B "  ON A TT ALL OBJECTS RUN AT 50 FPS!!!  "
		DC.B "                                        "
		DC.B "  YOU CAN CONTACT US BY WRITING TO :-   "
		DC.B "            MARTIN GRIFFITHS            "
		DC.B "              6, THE GREEN              "
		DC.B "                 BLEAN                  "
		DC.B "             KENT.(ENGLAND)             "
		DC.B "                                        "
		DC.B "     AND NOW ENJOY THE FINAL SHAPE,     "
		DC.B "                                        "
		DC.B "                                        "
		DC.B "                                        "
		DC.B "                                        "
		DC.B "                                        "
		DC.B "                                        "
		DC.B 0
		EVEN

i		SET 0
textofftab
		REPT 20
		DC.W i
		DC.W i+1
i		SET i+8
		ENDR

ltext_struc	DC.W $000
		DC.W 0
		DS.B ltext_strucsize
		EVEN

; Timer C frame rate counter (used for frame compensation)

tc_ratecounter	SUBQ.B #1,tc_count 
anrte		RTE 

readrate  	MOVE.W tc_count(PC),D0 
		MOVE.B $FFFFFA23.W,D0
		MOVE.W oldtc_count(PC),D1 
		MOVE.W D0,oldtc_count 
		SUB.W D0,D1 
		BPL.S .ok
		MOVEQ #0,D1 
.ok	   	RTS 

tc_count	DC.W 0
oldtc_count 	DC.W 0

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
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeinflag
.notendfade	move.w d0,fadein_tim
.endfade	rts

fadeout:	tst.b fadeoutflag
		beq.s .endfade
		move.l fadeout_pal_ptr(pc),a0
		move.l fadeout_cur_ptr(pc),a1
		moveq #$10,d0
		sub.w fadeout_tim(pc),d0
		move.w fadeout_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		move.w fadeout_tim(pc),d0
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeoutflag
.notendfade	move.w d0,fadeout_tim
.endfade	rts

calc1		move.w (a0)+,d1
		move.w d1,d2
		and #$007,d1
		mulu d0,d1
		lsr #4,d1
		move.w d1,d3
		move.w d2,d1
		and #$070,d1
		mulu d0,d1
		lsr #4,d1
		and #$070,d1
		or.w d1,d3
		and #$700,d2
		mulu d0,d2
		lsr #4,d2
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


log_base 	DS.L 3
g_objptr	DC.L gpyramid
v_angles	DS.W 3
xyz_offys	
x_offy		DS.W 1
y_offy		DS.W 1
z_offy		DS.W 1

; Calculate a translation matrix, from the angle data pointed by A5.
; D0-D7/A0-A3 smashed.

Matrix_make	LEA trig_tab,A0		;sine table
		LEA 512(A0),A2		;cosine table
		MOVEM.W v_angles(PC),D5-D7    	
		LSR #6,D5
		LSR #6,D6
		LSR #6,D7
		ADD D5,D5
		ADD D6,D6
		ADD D7,D7
		MOVE (A0,D5),D0		;sin(xd)
		MOVE (A2,D5),D1		;cos(xd)
		MOVE (A0,D6),D2		;sin(yd)
		MOVE (A2,D6),D3		;cos(yd)
		MOVE (A0,D7),D4		;sin(zd)
		MOVE (A2,D7),D5		;cos(zd)
		LEA M11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6		;sinx
		MULS D4,D6		;sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6		;cosx
		MULS D4,D6		;sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6		;cosy
		MULS D1,D6		;cosy*cosx
		MOVE A3,D7		;sinz*sinx
		MULS D2,D7		;siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6		;siny*cosx
		MOVE A3,D7		;sinz*sinx
		MULS D3,D7		;cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6		;cosz
		MULS D0,D6		;cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6		;siny
		MULS D5,D6		;siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6		;cosy
		MULS D5,D6		;cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6		;cosy
		MULS D0,D6		;cosy*sinx
		MOVE A4,D7		;sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			;siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
		MOVE D6,ML1-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2		;siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
		MOVE D2,ML2-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5			;cosz*cosx
		MOVE D5,M33-M11(A1)
		MOVE D5,ML3-M11(A1)
		RTS				

; Draw Gouraud Shaded Object, D0-D7/A0-A6 smashed.

Draw_GObj	MOVE.W (A0)+,D7         ; verts-1
		LEA new_crds(PC),A1
		MOVE #160,A3		; centre x
		MOVE #100,A4		; centre y
trans_lp	MOVEM.W (A0)+,D0-D2	; x,y,z
		MOVE D0,D3	
		MOVE D1,D4		; dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4		; mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1		; mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4		; mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
		ASR.L #8,D0
		ASR.L #8,D1
		ADD.L D2,D2
		SWAP D2
		ADD.W z_offy(PC),D2
		DIVS D2,D0		; x/z
		DIVS D2,D1		; y/z
		ADD A3,D0		; x scr centre
		ADD A4,D1		; y scr centre
		MOVE D0,(A1)+		; new x co-ord
		MOVE D1,(A1)+		; new y co-ord
		MOVEM.W (A0)+,D0-D2 	; fetch normal
ML1		MULS #0,D0
ML2		MULS #0,D1		; mat mult
ML3		MULS #0,D2
		ADD.L D1,D0 
		ADD.L D2,D0 
		ADD.L D0,D0 
		SWAP D0			; magnitude
		NEG.W D0
		BPL.S .ok
		CLR.W D0
.ok	   	MOVE.W D0,(A1)+		; store intensity
		DBF D7,trans_lp
; A0 -> 'no. of faces-1' in object data.
		MOVE.W (A0)+,D6
.draw_face_lp 	LEA new_crds(PC),A6
		MOVEM.W (A0),D0-D2
		MOVEM.W 0(A6,D0.W),D4/D0
		MOVEM.W 0(A6,D2.W),D5/D2
		MOVE.L 0(A6,D1.W),D1 
		SUB.W D1,D4 
		SUB.W D1,D5 
		SWAP D1
		SUB.W D1,D0 
		SUB.W D1,D2 
		MULS D2,D4 
		MULS D0,D5 
		SUB.L D4,D5 
		BMI.S .is_seen
		ADD.W D6,D6 
		ADD.W D6,A0 
		MOVE.W (A0)+,D6
		BPL.S .draw_face_lp
		RTS 
.is_seen      	BSR GDraw_Poly
		MOVE.L USP,A0
		MOVE.W (A0)+,D6
		BPL.S .draw_face_lp
		RTS 
;-----------------------------------------------------------------------;
;                 Gouraud Shaded Polygon Routine.			;
; A0 -> D6 coords (offsets into 'new_crds' in form X,Y,INTENSITY CONST) ;
;-----------------------------------------------------------------------;

GDraw_Poly	LEA trans_crds(PC),A1 
		LEA new_crds(PC),A6
		MOVE D6,D0
		ADD D6,D6
		ADD D0,D6
		ADD D6,D6
		MOVE.L A1,A5
		ADDA.W D6,A5
		MOVE.L A5,A2
		ADDA.W D6,A2
Init_coords	SUBQ #2,D0
		MOVE.W (A0)+,D7
		MOVE.W 4(A6,D7),D5
		MOVE.L (A6,D7),D7
		MOVE D7,D2
		MOVE.L A5,A4
		MOVE.L D7,(A1)+		; dup first coord
		MOVE.W D5,(A1)+
		MOVE.L D7,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D7,(A5)+
		MOVE.W D5,(A5)+
.coord_lp	MOVE.W (A0)+,D3
		MOVE.W 4(A6,D3),D5
		MOVE.L (A6,D3),D3
		CMP D2,D3
		BGE.S .not_top
		MOVE D3,D2
		MOVE.L A5,A4
.not_top	CMP D3,D7
		BGE.S .not_bot
		MOVE D3,D7	
.not_bot	MOVE.L D3,(A1)+		; dup for rest
		MOVE.W D5,(A1)+
		MOVE.L D3,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D3,(A5)+
		MOVE.W D5,(A5)+
		DBF D0,.coord_lp
		MOVE.L A0,USP
		MOVE.L A4,A5
		SUB D2,D7		;d2 - lowest y  d7 - greatest y
		BEQ polydone
		MOVE D2,-(SP)
		MOVE D7,-(SP)

CALCS		LEA grad_table+640(PC),A0
; Calc x's down left side of poly
Do_left		LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #6,A4
		MOVEM.W (A4),D1-D2		;x1,y1
		MOVEM.W 4(A4),D0/D3-D5		;I2,x2,y2,I1
		SUB D4,D2			;dy
		SUB D3,D1			;dx
		SUB D2,D7			;remaining lines-dy
		SUB D5,D0			;DI
		EXT.L D0
		DIVS D2,D0			
		ADD D2,D2
		MULS (A0,D2),D1
		ADD.L D1,D1
		MOVE.W D1,D4			; frac part
		SWAP D1				; whole part
		MOVE.W D2,D6
		ADD D2,D2
		ADD D2,D2
		ADD D6,D2			; *10
		NEG D2
		CLR.W D6
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADD.W D4,D6
		ADDX.W D1,D3
		MOVE.W D5,(A3)+
		ADD.W D0,D5
		ENDR
LEFTJMP		TST D7
		BGT Left_lp

; Calc x's down right side of poly

Do_right	MOVE.W (SP),D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM.W (A5)+,D1-D2/D5		;x1,y1,I2
		MOVEM.W (A5),D3-D4/D6		;x2,y2,I1
		SUB D2,D4			;dy
		SUB D1,D3			;dx
		SUB D4,D7			;remaining lines-dy
		SUB D5,D6			;DI
		EXT.L D6
		DIVS D4,D6			
		ADD D4,D4
		MULS (A0,D4),D3
		ADD.L D3,D3
		MOVE.W D3,D2			; frac part	
		SWAP D3				; whole part
		MOVE.W D4,D0
		ADD D4,D4
		ADD D4,D4
		ADD D0,D4			; *10
		NEG D4
		CLR.W D0
		JMP (A2,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADD.W D2,D0
		ADDX.W D3,D1
		MOVE.W D5,(A3)+
		ADD.W D6,D5
		ENDR
RIGHTJMP	TST D7
		BGT Right_lp

maskit		MACRO
		NOT.W D3
		AND.W D3,(A4)
		AND.W D3,2(A4)
		AND.W D3,4(A4)
		NOT.W D3
		ENDM

; Dither MACROS. 

Wcol01		MACRO			; dither 0 and 1
		maskit
		AND.W D5,D3
		OR.W D3,(A4)
		MOVEQ #-1,D3
		ENDM

Wcol12		MACRO			; dither 1 and 2
		maskit
		MOVE.W D3,D4
		AND.W D5,D3
		EOR.W D3,D4
		OR.W D4,(A4)
		OR.W D3,2(A4)
		MOVEQ #-1,D3
		ENDM

Wcol23		MACRO			; dither 2 and 3
		maskit
		OR.W D3,2(A4)
		AND.W D5,D3
		OR.W D3,(A4)
		MOVEQ #-1,D3
		ENDM

Wcol34		MACRO
		maskit
		MOVE.W D3,D4		; dither 3 and 4
		AND.W D5,D3
		OR.W D3,4(A4)
		EOR.W D3,D4
		OR.W D4,(A4)
		OR.W D4,2(A4)
		MOVEQ #-1,D3
		ENDM

Wcol45		MACRO
		maskit
		OR.W D3,4(A4)		; dither 4 and 5
		AND.W D5,D3
		OR.W D3,(A4)
		MOVEQ #-1,D3
		ENDM

Wcol56		MACRO
		maskit
		MOVE.W D3,D4		; dither 5 and 6
		AND.W D5,D4
		OR.W D4,2(A4)
		OR.W D3,4(A4)
		EOR.W D4,D3
		OR.W D3,(A4)
		MOVEQ #-1,D3
		ENDM

Wcol67		MACRO			; dither 6 and 7
		maskit
		OR.W D3,2(A4)
		OR.W D3,4(A4)
		AND.W D5,D3
		OR.W D3,(A4)
		MOVEQ #-1,D3
		ENDM

Wcol7		MACRO
		maskit
		OR.W D3,(A4)
		OR.W D3,2(A4)
		OR.W D3,4(A4)
		MOVEQ #-1,D3
		ENDM


do1col		MACRO
pix_lp\@	ADD.W D3,D3
		ADD.W D1,D0
		ADDX D5,D5
		SUBQ #1,D2
		BEQ.S .nl\@
.cont\@		ADD.W A5,D1
 		DBCS D6,pix_lp\@
		LSL.W D2,D5
		NOT.W D3
		LSL.W D2,D3
		Wcol\1
		SUBQ #1,D6
		BGE.S .ok\@
		BRA.W nextline
.nl\@		NOT.W D3
		Wcol\1
		ADDQ.W #8,A4
		MOVEQ #16,D2
		BRA.S .cont\@ 
.ok\@
		ENDM

do1colN		MACRO
pix_lp\@	ADD.W D3,D3
		SUBQ #1,D2
		BNE.S .ok\@
		NOT.W D3
		Wcol\1
		ADDQ.W #8,A4
		MOVEQ #16,D2
.ok\@		DBF D6,pix_lp\@
		NOT.W D3
		LSL.W D2,D3
		Wcol\1
		ENDM

; Now draw on screen

.gofordraw 	MOVE (SP)+,D7		; DY
		MOVE (SP)+,D0		; MIN Y
		SUBQ #1,D7
		MOVE.L log_base(PC),A6
		MULU #$A0,D0 
		ADDA.W D0,A6 
		LEA x1s(PC),A1
		LEA x2s(PC),A2

Gdraw_lp    	MOVE.W (A1)+,D0		; x1
		MOVE.W (A2)+,D6		; x2
		MOVE.W (A1)+,D1	 	; Intensity 1
		MOVE.W (A2)+,D2		; Intensity 2
		SUB.W D0,D6 
		BLE DS2 
		EXT.L D1
		SUB.W D1,D2 		
		BMI DSD 
DSU		LSL.L #4,D1 
		MOVE.W D6,D3
		ADD D3,D3
		MULU (A0,D3),D2
		CMP.L #%00000111111111111111111111111111,D2
		BLO.S .ok
		MOVEQ #-1,D2
		BRA.S contdu

; Dither up.

.ok		LSL.L #5,D2
		SWAP D2
contdu	     	MOVE.W D2,A5 
		MOVEQ #$F,D2
		AND.W D0,D2
		SUB.W D2,D0 
		LSR.W #1,D0 
		MOVE.L A6,A4
		ADDA.W D0,A4
		NEG D2 
		ADD #16,D2
		MOVEQ #-1,D3
		move.l d1,d4
		swap d4
		add.w d4,d4
		move.w #-$8000,d0
		move.w jmptab2(pc,d4),d4
		jmp ducol0(pc,d4)
jmptab2		dc.w ducol0-ducol0,ducol1-ducol0,ducol2-ducol0,ducol3-ducol0
		dc.w ducol4-ducol0,ducol5-ducol0,ducol6-ducol0,ducol7-ducol0

ducol0		do1col 01 
ducol1		do1col 12 
ducol2		do1col 23 
ducol3		do1col 34
ducol4		do1col 45 
ducol5		do1col 56 
ducol6		do1col 67 
ducol7		do1colN 7 
DS2      	LEA 160(A6),A6
		DBF D7,Gdraw_lp
polydone	RTS 

do1colD		MACRO
pix_lp\@	ADD.W D3,D3
		ADD.W D1,D0
		ADDX D5,D5
		SUBQ #1,D2
		BEQ.S .nl\@
.cont\@		ADD.W A5,D1
 		DBCC D6,pix_lp\@
		LSL.W D2,D5
		NOT.W D3
		LSL.W D2,D3
		Wcol\1
		SUBQ #1,D6
		BGE.S .ok\@
		BRA.W nextline
.nl\@		NOT.W D3
		Wcol\1
		ADDQ.W #8,A4
		MOVEQ #16,D2
		BRA.S .cont\@ 
.ok\@
		ENDM

do1colDN	MACRO
pix_lp\@	ADD.W D3,D3
		ADD.W D1,D0
		ADDX D5,D5
		SUBQ #1,D2
		BNE.S .ok\@
		NOT.W D3
		Wcol\1
		ADDQ.W #8,A4
		MOVEQ #16,D2
.ok\@		ADD.W A5,D1
		DBF D6,pix_lp\@
		LSL.W D2,D5
		NOT.W D3
		LSL.W D2,D3
		Wcol\1
		ENDM

; Dither down.

DSD      	LSL.L #4,D1 
		MOVE.W D6,D3
		ADD D3,D3
		NEG D2
		MULU (A0,D3),D2
		CMP.L #%00000111111111111111111111111111,D2
		BLO.S .ok
		MOVEQ #-1,D2
		BRA.S .cont
.ok		LSL.L #5,D2
		SWAP D2
.cont		NEG.W D2
		BEQ contdu 
		MOVE.W D2,A5 
	   	MOVEQ #$F,D2
		AND.W D0,D2 
		SUB.W D2,D0 
		LSR.W #1,D0 
		MOVE.L A6,A4
		ADDA.W D0,A4
		NEG D2 
		ADD #16,D2
		MOVEQ #-1,D3
		move.l d1,d4
		swap d4
		add.w d4,d4
		move.w jmptab1(pc,d4),d4
		MOVE.W #-$8000,D0
		jmp ddcol0(pc,d4)
jmptab1		dc.w ddcol7-ddcol0,ddcol6-ddcol0,ddcol5-ddcol0,ddcol4-ddcol0
		dc.w ddcol3-ddcol0,ddcol2-ddcol0,ddcol1-ddcol0,ddcol0-ddcol0
ddcol0		do1colD 7 
ddcol1		do1colD 67 
ddcol2		do1colD 56 
ddcol3		do1colD 45 
ddcol4		do1colD 34 
ddcol5		do1colD 23 
ddcol6		do1colD 12
ddcol7		do1colDN 01 
nextline     	LEA 160(A6),A6
		DBF D7,Gdraw_lp
		RTS


; Create Multplication gradient table for poly edges

makegradtab	LEA grad_table(PC),A0
		MOVE #-320,D0
.lp1		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #-1,D0
		BNE.S .lp1
		MOVE.W #-32768,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #32767,(A0)+
		MOVEQ #2,D0
.lp2		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #321,D0
		BNE.S .lp2
		RTS		

grad_table	ds.w 642

x1s		DS.L 201
x2s		DS.L 201

trig_tab     	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

; Heres The 3D Sequencer!
; commands 0 - Set new object, initial offset X,Y,Z .Ws 
;	       View angles ptr.L Offsets ptr.L(in object to sequence!)
;          1 - Set X,Y and Z Rotation speeds and X,Y,Z offset adds.
; 	       TIMER (.W) X,Y,Z rot vals (.W) X,Y,Z offset (.W)
;          2 = Sets a Waveform to be added to X,Y,Z centres each update.
;	       Waveform size .W (in bytes),Initial offset .W
;              Waveform ptr.L
;          3 = Stop Waveform - no parameters
;          4 - Restart Sequence

SetNewObj	EQU 0*4
SetXYZstuff	EQU 1*4
SetWaveformON	EQU 2*4
SetWaveformOFF	EQU 3*4
SetRestart	EQU 4*4
SetFadeDown	EQU 5*4
SetFadeIn	EQU 6*4

		RSRESET
Seq_ptr		RS.L 1			; Ptr to Sequence!
Restart_ptr	RS.L 1			; Ptr to Place to Restart Seq.
Seq_Timer	RS.W 1			; Sequence Timer
Object_ptrA	RS.L 1			; Ptr to Object (angles)
Object_ptrO	RS.L 1			; Ptr to Object (offsets)
OffsetXYZ	RS.W 0
OffsetX		RS.W 1			; Offset X
OffsetY		RS.W 1			;    "   Y
OffsetZ		RS.W 1			;    "   Z
XYZang		RS.W 0
Xang		RS.W 1			;
Yang		RS.W 1			; Current View Angles (X,Y,Z)
Zang		RS.W 1			;
XYZadd		RS.W 0
Xadd		RS.W 1			; X rotation addition 
Yadd		RS.W 1			; Y rotation    "
Zadd		RS.W 1                  ; Z rotation    "
XYZaddOffset	RS.W 0
XaddOffset	RS.W 1			; X offset addition
YaddOffset	RS.W 1			; Y offset addition
ZaddOffset	RS.W 1			; Z offset addition
Waveform_flag	RS.W 1			; Waveform Flag(0=no wave <>0 wave)
Waveform_ptr	RS.L 1			; Waveform base PTR
Waveform_offptr	RS.W 1			; offset in Waveform
Waveform_Size	RS.W 1                  ; Size(in bytes) of waveform

SeqStrucSize	RS.B 1			; size of struc

; Initialise Sequence... A0-> Sequence Data A1-> Restart Data.

Init_Seq	LEA SeqStructure(PC),A5
		MOVE.L A0,Seq_ptr(A5)
		MOVE.L A1,Restart_ptr(A5)
		RTS

; This is the sequencer - Call once every object update.

Do_Sequence	LEA SeqStructure(PC),A5
		SUBQ #1,Seq_Timer(A5)
		BGT.S seqdone
		MOVE.L Seq_ptr(A5),A0	; get seq ptr
morethisframe	MOVE.W (A0)+,D0		; get next command in sequence
		JMP .SeqCommandList(PC,D0.W)
.SeqCommandList	BRA.W SetNewObject	; init new object.
		BRA.W SetXYZ_addStuff	; set movement vals(rot+offset)
		BRA.W SetWaveform_ON
		BRA.W SetWaveform_OFF
		BRA.W Restart_Seq	; restart sequence
		BRA.W Set_FadeDown
		BRA.W Set_FadeIn

endthisframe:	MOVE.L A0,Seq_ptr(A5)	; store seq ptr.
seqdone		MOVEM XYZaddOffset(A5),D0-D2
		ADD.W D0,OffsetX(A5)
		ADD.W D1,OffsetY(A5)	; update offsets!
		ADD.W D2,OffsetZ(A5)
		MOVEM XYZadd(A5),D3-D5
		BSR readrate 
		MOVE.W D1,D0
		MOVE.W D1,D2
		MULU D3,D0 
		SWAP D0
		MULU D4,D1 
		SWAP D1
		MULU D5,D2 
		SWAP D2
		ADD.W D0,Xang(A5)
		ADD.W D1,Yang(A5)	; update view angles!
		ADD.W D2,Zang(A5)
		MOVE.L Object_ptrA(A5),A1  
		MOVEM XYZang(A5),D0-D2
		MOVEM D0-D2,(A1)	; store view angs in object
		MOVEM OffsetXYZ(A5),D0-D2
		TST.B Waveform_flag(A5)
		BEQ.S .noaddwaveform
		MOVE.L Waveform_ptr(A5),A1
		MOVE.W Waveform_offptr(A5),D3
		MOVEM.W (A1,D3),D4-D6
		ADD.W D4,D0
		ADD.W D5,D1		; update offsets!
		ADD.W D6,D2
		ADDQ #6,D3
		CMP.W Waveform_Size(A5),D3
		BNE.S .nowrapwaveform
		CLR D3
.nowrapwaveform	MOVE.W D3,Waveform_offptr(A5)
.noaddwaveform	MOVE.L Object_ptrO(A5),A1  
		MOVEM D0-D2,(A1)	; store view offsets in object 
		RTS

; Set New Object initial X,Y,Z offsets, X,Y,Z angles,Obj Angle/offset ptrs.

SetNewObject	MOVE.W (A0)+,OffsetX(A5)
		MOVE.W (A0)+,OffsetY(A5)
		MOVE.W (A0)+,OffsetZ(A5)
		MOVE.W (A0)+,Xang(A5)
		MOVE.W (A0)+,Yang(A5)
		MOVE.W (A0)+,Zang(A5)
		MOVE.L (A0)+,Object_ptrA(A5)
		MOVE.L (A0)+,Object_ptrO(A5)
		MOVE.L (A0)+,g_objptr
		BRA.W morethisframe	

; Set X,Y,Z rotation speed and offset movement speeds.

SetXYZ_addStuff	MOVE.W (A0)+,Seq_Timer(A5)
		MOVE.W (A0)+,Xadd(A5)
		MOVE.W (A0)+,Yadd(A5)
		MOVE.W (A0)+,Zadd(A5)
		MOVE.W (A0)+,XaddOffset(A5)
		MOVE.W (A0)+,YaddOffset(A5)
		MOVE.W (A0)+,ZaddOffset(A5)
		BRA.W endthisframe		

; Set a waveform on e.g values to be added each update to X,Y,Z.

SetWaveform_ON	MOVE.W (A0)+,Waveform_Size(A5)
		MOVE.W (A0)+,Waveform_offptr(A5)
		MOVE.L (A0)+,Waveform_ptr(A5)
		ST Waveform_flag(A5)
		BRA.W morethisframe	

; Set a waveform off...

SetWaveform_OFF	SF Waveform_flag(A5)
		BRA.W morethisframe	

; Restart the Sequence

Restart_Seq	MOVE.L Restart_ptr(A5),A0
		ST.B demo_finished
		BRA.W endthisframe		

Set_FadeDown	MOVE.L (A0)+,fadeout_pal_ptr
		MOVE.L (A0)+,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST fadeoutflag
		BRA.W morethisframe	

Set_FadeIn	MOVE.L (A0)+,fadein_pal_ptr
		MOVE.L (A0)+,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST fadeinflag
		BRA.W morethisframe	

SeqStructure	DS.B SeqStrucSize
demo_finished	DS.B 1
		EVEN

; Sequence for the cube

G_Sequence	DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gpyramid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,123,$7777,$9999,$eeee,0,0,-30
		DC.W SetXYZstuff,213,$7777,$9999,$eeee,0,0,0
		DC.W SetXYZstuff,73,$7777,$9999,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,50,$7777,$9999,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gcube
		DC.W SetFadeIn
		DC.L pal2,currpal
		DC.W SetXYZstuff,123,$9999,$aaaa,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$9999,$aaaa,$eeee,0,0,0
		DC.W SetXYZstuff,83,$9999,$aaaa,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal2,currpal
		DC.W SetXYZstuff,40,$9999,$aaaa,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,$190,0,0
		DC.L v_angles,xyz_offys,gthargoid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,108,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,68,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gstation
		DC.W SetFadeIn
		DC.L pal6,currpal
		DC.W SetXYZstuff,120,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,80,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal6,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gasteriod
		DC.W SetFadeIn
		DC.L pal5,currpal
		DC.W SetXYZstuff,118,$cccc,$9999,$eeee,0,0,-30
		DC.W SetXYZstuff,130,$cccc,$9999,$eeee,0,0,0
		DC.W SetXYZstuff,78,$cccc,$9999,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal5,currpal
		DC.W SetXYZstuff,40,$cccc,$9999,$eeee,0,0,30
		DC.W SetRestart

; Gouraud Cube

gcube 		DC.W 8-1
		DC.W -100,100,100
		DC.W -18500,18500,18500
		DC.W -100,100,-100
		DC.W -18500,18500,-18500
		DC.W 100,100,-100
		DC.W 18500,18500,-18500
		DC.W 100,100,100
		DC.W 18500,18500,18500
		DC.W -100,-100,100
		DC.W -18500,-18500,18500
		DC.W -100,-100,-100
		DC.W -18500,-18500,-18500
		DC.W 100,-100,-100
		DC.W 18500,-18500,-18500
		DC.W 100,-100,100
		DC.W 18500,-18500,18500
		DC.W 4,0*6,1*6,2*6,3*6
		DC.W 4,7*6,6*6,5*6,4*6
		DC.W 4,2*6,6*6,7*6,3*6
		DC.W 4,0*6,3*6,7*6,4*6
		DC.W 4,1*6,0*6,4*6,5*6
		DC.W 4,1*6,5*6,6*6,2*6
		DC.W -1

gpyramid	DC.W 5-1
		DC.W -100,-100,-100
		DC.W -19000,-16000,-19000
		DC.W 100,-100,-100
		DC.W 19000,-16000,-19000
		DC.W 100,-100,100
		DC.W 19000,-16000,19000
		DC.W -100,-100,100
		DC.W -19000,-16000,19000
		DC.W 0,100,0
		DC.W 0,29000,0
		DC.W 4,3*6,2*6,1*6,00*6
		DC.W 3,0*6,1*6,4*6
		DC.W 3,1*6,2*6,4*6
		DC.W 3,2*6,3*6,4*6
		DC.W 3,3*6,0*6,4*6
		DC.W -1

gstation	DC.W 12-1
		DC.W 0,-120,120
		DC.W 0,-22000,22000

		DC.W 120,0,120
		DC.W 22000,0,22000

		DC.W 120,-120,0
		DC.W 22000,-22000,0

		DC.W 0,120,120
		DC.W 0,22000,22000

		DC.W 120,0,-120
		DC.W 22000,0,-22000

		DC.W -120,-120,0
		DC.W -22000,-22000,0

		DC.W 0,-120,-120
		DC.W 0,-22000,-22000

		DC.W -120,0,120
		DC.W -22000,0,22000

		DC.W 120,120,0
		DC.W 22000,22000,0

		DC.W 0,120,-120
		DC.W 0,22000,-22000

		DC.W -120,0,-120
		DC.W -22000,0,-22000

		DC.W -120,120,0
		DC.W -22000,22000,0

		DC.W 3,00*6,01*6,02*6
		DC.W 3,09*6,11*6,10*6
		DC.W 3,04*6,08*6,09*6
		DC.W 3,01*6,03*6,08*6
		DC.W 3,03*6,07*6,11*6
		DC.W 3,00*6,05*6,07*6
		DC.W 3,05*6,06*6,10*6
		DC.W 3,02*6,04*6,06*6
		DC.W 4,00*6,02*6,06*6,05*6
		DC.W 4,04*6,02*6,01*6,08*6
		DC.W 4,00*6,07*6,03*6,01*6
		DC.W 4,07*6,05*6,10*6,11*6
		DC.W 4,08*6,03*6,11*6,09*6
		DC.W 4,06*6,04*6,09*6,10*6
		DC.W -1


gasteriod	DC.W 12-1
		DC.W 0,-75,150
		DC.W 0,14755,-24414

		DC.W 150,0,75
		DC.W -24414,-1,-14755		

		DC.W 75,-150,0
		DC.W -14755,24414,0

		DC.W 0,75,150
		DC.W 0,-14755,-24414

		DC.W 150,0,-75
		DC.W -24414,-1,14755

		DC.W -75,-150,0
		DC.W 14755,24414,0		

		DC.W 0,-75,-150
		DC.W 0,14755,24414

		DC.W -150,0,75
		DC.W 24414,-1,-14755

		DC.W 75,150,0
		DC.W -14755,-24414,0		

		DC.W 0,75,-150
		DC.W 0,-14755,24414

		DC.W -150,0,-75
		DC.W 24414,0,14755

		DC.W -75,150,0
		DC.W 14755,-24414,-1

		DC.W 3,01*6,02*6,04*6
		DC.W 3,01*6,00*6,02*6
		DC.W 3,02*6,00*6,05*6
		DC.W 3,02*6,05*6,06*6
		DC.W 3,02*6,06*6,04*6
		DC.W 3,04*6,06*6,09*6
		DC.W 3,04*6,09*6,08*6
		DC.W 3,01*6,04*6,08*6
		DC.W 3,03*6,01*6,08*6
		DC.W 3,00*6,01*6,03*6
		DC.W 3,07*6,11*6,10*6
		DC.W 3,00*6,07*6,05*6
		DC.W 3,10*6,05*6,07*6
		DC.W 3,06*6,05*6,10*6
		DC.W 3,06*6,10*6,09*6
		DC.W 3,09*6,10*6,11*6
		DC.W 3,08*6,09*6,11*6
		DC.W 3,03*6,08*6,11*6
		DC.W 3,03*6,11*6,07*6
		DC.W 3,00*6,03*6,07*6
		DC.W -1

gthargoid	DC.W 16-1
		DC.W 0,200,0
		DC.W 0,11026,28307

		DC.W 140,140,0
		DC.W 7875,7875,28307

		DC.W 200,0,0
		DC.W 11026,0,28307

		DC.W 140,-140,0
		DC.W 7875,-7875,28307

		DC.W 0,-200,0
		DC.W 0,-11026,28307

		DC.W -140,-140,0
		DC.W -7875,-7875,28307

		DC.W -200,0,0
		DC.W -11026,0,28307		

		DC.W -140,140,0
		DC.W -7875,7875,28307

		DC.W 0,360,-100
		DC.W 0,11026,-16974

		DC.W 252,252,-100
		DC.W 7875,7875,-16974

		DC.W 360,0,-100
		DC.W 11026,0,-16974

		DC.W 252,-252,-100
		DC.W 7875,-7875,-16974

		DC.W 0,-360,-100		
		DC.W 0,-11026,-6974

		DC.W -252,-252,-100
		DC.W -7875,-7875,-16974

		DC.W -360,0,-100
		DC.W -11026,0,-16974

		DC.W -252,252,-100
		DC.W -7875,7875,-16974

		DC.W 8,00*6,01*6,02*6,03*6,04*6,05*6,06*6,07*6
		DC.W 8,15*6,14*6,13*6,12*6,11*6,10*6,09*6,08*6
		DC.W 4,06*6,14*6,15*6,07*6
		DC.W 4,05*6,13*6,14*6,06*6
		DC.W 4,04*6,12*6,13*6,05*6
		DC.W 4,03*6,11*6,12*6,04*6
		DC.W 4,02*6,10*6,11*6,03*6
		DC.W 4,01*6,09*6,10*6,02*6
		DC.W 4,00*6,08*6,09*6,01*6
		DC.W 4,07*6,15*6,08*6,00*6
		DC.W -1
	
		SECTION BSS
		DS.L 399
my_stack	DS.L 3
trans_crds    	DS.W 200
new_crds     	DS.W 200 
FastClsList	DS.L 580

screens		DS.B 256
		DS.B 96000
