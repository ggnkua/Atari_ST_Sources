;-----------------------------------------------------------------------;
;   The Left donut demo							;
;   knocked up very quickly.						;
;   ;   September 1993 (ish)						;
;   (Fast Gouraud shading polygon routines,				;
; 				    July 1993)				;
;									;
;									;
;-----------------------------------------------------------------------;

;Badly written and not very well comment (but it was written in about
; 30 hours).

music		EQU 1
linewidth	equ 768

		OPT O+,OW-

demo		EQU 0

		OUTPUT LEFTDON.PRG

letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		LEA my_stack,SP
		BSR makegradtab
		
		move.l #$0,$ffff9800.w
		BSR Initscreens
		
		MOVE.W #0,-(SP)
		MOVE.L log_base(PC),-(SP)
		MOVE.L log_base(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP


		MOVE.W #$2700,SR
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
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #$20,$fffffa09.W 
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #$20,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 
		IFNE music
		BSR M_Setup
		BSR wait_vbl
		;bsr M_On
		ENDC

		BSR piccy
		BSR wait_vbl
		MOVE.W #$64,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		CLR.L $ffff9800.w
		BSR ClearScreens		
		BSR wait_vbl
		BSR flush

		LEA G_Sequence,A0
		LEA (A0),A1
		BSR Init_Seq	
		CLR.L $466.W
		CLR.W tc_count
		BSR readrate 

.vbl_lp		BSR ClearIt
	  	BSR Matrix_make
		BSR Do_Sequence
		MOVE.L g_objptr(PC),A0 
		BSR Draw_GObj
		BSR SwapScreens
		CMP.B #$39,$FFFFFC02.W
		BNE.S .vbl_lp

		IFNE music
		bsr M_Off
		ENDC

		MOVE #$2700,SR 
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
		
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

		MOVE.W #$0,-(SP)
		TRAP #1

oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1

oldmfp		DS.L 22


piccy		BSR wait_vbl
		MOVE.W #$16C,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

		move.l #$0,$ffff9800.w
		MOVEQ #40-1,D7
.lp		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		DBF D7,.lp
		
		LEA pic+128-4,A0
		MOVE.L log_base,A1
		LEA (A0),A2
		ADD.L #477*768*2,A2
		LEA (A1),A3
		ADD.L #478*768*2,A3
		MOVE.W #(480/4)-1,D6
plp		
		MOVE.W #(384*2)-1,D0
.lp1		MOVE.L (A0)+,(A1)+
		DBF D0,.lp1
		LEA 768*4(A0),A0
		LEA 768*4(A1),A1

		MOVE.W #(384*2)-1,D0
.lp2		MOVE.L (A2)+,(A3)+
		DBF D0,.lp2

		LEA 768*2*-6(A2),A2
		LEA 768*2*-6(A3),A3
		BSR wait_vbl
		DBF D6,plp

.wait_space	CMP.B #$39+$80,$FFFFFC02.W
		BNE.S .wait_space
		BSR wait_vbl

		MOVE.L log_base,A1
		LEA (A1),A3
		ADD.L #478*768*2,A3
		MOVE.W #(480/4)-1,D6
plp2	
		MOVE.W #(384*2)-1,D0
.lp1		MOVE.L #0,(A1)+
		DBF D0,.lp1
		LEA 768*4(A0),A0
		LEA 768*4(A1),A1

		MOVE.W #(384*2)-1,D0
.lp2		MOVE.L #0,(A3)+
		DBF D0,.lp2

		LEA 768*2*-6(A2),A2
		LEA 768*2*-6(A3),A3
		BSR wait_vbl
		DBF D6,plp2

		BRA wait_vbl

; Initialise 3 screens.

Initscreens	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		ADD.L #192000,D0
		MOVE.L D0,(A1)+
		ADD.L #192000,D0
		MOVE.L D0,(A1)+
		RTS

ClearScreens	MOVE.L log_base(PC),D0
		BSR cls
		MOVE.L log_base+4(PC),D0
		BSR cls
		MOVE.L log_base+8(PC),D0
		BRA cls


SetScreen	MOVE.L log_base(PC),D0
		MOVE.B D0,$FFFF820D.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8201.W
		RTS


cls		MOVE.L D0,A0
		MOVE.W #(250*linewidth)/16-1,D2
		MOVEQ #0,D1
.lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D2,.lp
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Clear screen very quickly.

ClearIt		MOVE.L log_base(PC),A0
		ADD.L #(250*linewidth)-80-(20*linewidth),A0
		MOVEQ #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVE.L D0,A2
		MOVE.L D0,A3
		MOVE.L D0,A4
		MOVE.L D0,A5
		MOVE.L D0,A6
		MOVE.W #210-1,D7
.lp		
		REPT 11
		MOVEM.L D0-D6/a1-A6,-(A0) 
		ENDR
		MOVEM.L D0-D6/a1-A2,-(A0) 
		LEA -160(A0),A0
		DBF D7,.lp
		RTS

; Swap Screen ptrs and set hware reg.

SwapScreens    	
.wait		TST.L $466.W
		BEQ.s .wait
		CLR.L $466.W
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

wait_vbl	MOVE.L $466.W,D0
.waitvb		CMP.L $466.W,D0	
		BEQ.S .waitvb
		RTS


pal6	  	
pal1	  	
pal2	  	
pal3	  	
pal4	  	
pal5	  	

; Little old vbl..

vbl		;MOVEM.L D0-D7/A0-A6,-(SP)
		;MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ.L #1,$466.W
		RTE 
currpal		DS.W 16


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
		LEA new_crds,A1
		MOVE #192,A3		; centre x
		MOVE #120,A4		; centre y
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
.draw_face_lp 	LEA new_crds,A6
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

GDraw_Poly	LEA trans_crds,A1 
		LEA new_crds,A6
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
		ADD.W D2,D2		
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
		ADD.W D4,D4			
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

; Now draw on screen

.gofordraw 	MOVE (SP)+,D7		; DY
		MOVE (SP)+,D0		; MIN Y
		SUBQ #1,D7
		LEA cols(PC),A5
		MOVE.L log_base(PC),A6
		MULU #linewidth,D0 
		ADDA.L D0,A6 
		LEA x1s(PC),A1
		LEA x2s(PC),A2
		MOVEQ #16-6,D3
		MOVE.W #linewidth,D4
		MOVEQ #0,D5
Gdraw_lp    	MOVE.W (A1)+,D0		; x1
		MOVE.W (A2)+,D6		; x2
		MOVE.W (A1)+,D1	 	; Intensity 1
		MOVE.W (A2)+,D2		; Intensity 2
		EXT.L D1
		EXT.L D2
		LEA (A6,D0.W*2),A0
		SUB.W D0,D6 
		BLE DS2 
		SUB.L D1,D2 		
		EXT.L D6
		SWAP D2
		DIVS.L D6,D2
		ASR.L D3,d2
		ASL.L #6,D1
		SWAP D1
		SWAP D2
		MOVEQ #31,D0
		AND.W D6,D0
		LSR.W #5,D6
		MOVE D5,CCR
		JMP ([jmptab,D0.W*4])
Glp		
		REPT 32
		MOVE.W (A5,D1*2),(A0)+
		ADDX.L D2,D1
		ENDR
g_jmp		DBF D6,Glp
DS2      	ADD.W D4,A6
		DBF D7,Gdraw_lp

polydone	RTS 


i		SET 0
jmptab		
		REPT 32
		DC.L g_jmp+i
i		SET i-6
		ENDR 
		DS.W 16
cols		
i		SET 0		
		REPT 32
		DC.W (20*32*32)+(i*32)+i
i		SET i+1
		ENDR
		DS.W 16

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

Set_FadeDown	ADDQ.L #8,A0
		;MOVE.L (A0)+,fadeout_pal_ptr
		;MOVE.L (A0)+,fadeout_cur_ptr
		;MOVE.W #16,fadeout_nocols
		;ST fadeoutflag
		BRA.W morethisframe	

Set_FadeIn	ADDQ.L #8,A0
		;MOVE.L (A0)+,fadein_pal_ptr
		;MOVE.L (A0)+,fadein_cur_ptr
		;MOVE.W #16,fadein_nocols
		;ST fadeinflag
		BRA.W morethisframe	

SeqStructure	DS.B SeqStrucSize
demo_finished	DS.B 1
		EVEN

; Sequence for the cube

G_Sequence	DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gpyramid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,126,$7777,$9999,$eeee,0,0,-30
		DC.W SetXYZstuff,213,$7777,$9999,$eeee,0,0,0
		DC.W SetXYZstuff,73,$7777,$9999,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,50,$7777,$9999,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gcube
		DC.W SetFadeIn
		DC.L pal2,currpal
		DC.W SetXYZstuff,126,$9999,$aaaa,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$9999,$aaaa,$eeee,0,0,0
		DC.W SetXYZstuff,83,$9999,$aaaa,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal2,currpal
		DC.W SetXYZstuff,40,$9999,$aaaa,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,$190,0,0
		DC.L v_angles,xyz_offys,gthargoid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,113,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,68,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gstation
		DC.W SetFadeIn
		DC.L pal6,currpal
		DC.W SetXYZstuff,127,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,80,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal6,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gasteriod
		DC.W SetFadeIn
		DC.L pal5,currpal
		DC.W SetXYZstuff,124,$cccc,$9999,$eeee,0,0,-30
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

		IFNE music

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; 50khz 4 channel ProTracker Player using DSP. (interpolated)		;
; By Martin Griffiths (C) June 1993					;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

freq		EQU 246
padsize		EQU 800

		RSRESET
vcaddr		RS.L 1
endoffy		RS.L 1
suboffy		RS.L 1
start_flag	RS.W 1
aud_addr	RS.L 1
aud_len		RS.W 1
aud_per		RS.W 1
aud_vol		RS.W 1
		RS.W 3

M_Setup		BRA Setup_Module 
M_On		BRA Int_On 
M_Off		BRA Int_Off 

Setup_Module	move.w #128,-(sp)
		trap #14		; locksound
		addq.l #2,sp
		MOVE.L $134.W,Old_A
		MOVE.W #1,-(A7)		; protocol	= disable handshake
		MOVE.W #0,-(A7)		; prescale	= 1
		MOVE.W #0,-(A7)		; srclk		= 25.175
		MOVE.W #8,-(A7)		; dst		= dac
		MOVE.W #1,-(A7)		; src		= dspxmit
		MOVE.W #$8B,-(A7)	; devconnect
		TRAP #14
		LEA 12(A7),A7
		MOVE.W #0,-(A7)		; tristate dsprec
		MOVE.W #1,-(A7)		; enable   dspxmit
		MOVE.W #$89,-(A7)	; dsptristate
		TRAP #14
		ADDQ.W #6,A7

		MOVE.W #1,-(A7)	; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)	; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		BSR mt_init 
		BRA prepare

Int_Off		MOVE.L Old_A(PC),$134.W
		MOVE.B Old_19(PC),$fffffa19.W
		MOVE.B Old_1f(PC),$fffffa1f.W
		BCLR #5,$fffffa07.W
		BCLR #5,$fffffa13.W
		MOVE.W #1,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #8,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #$8B,-(A7)	; devconnect
		TRAP #14
		LEA 12(A7),A7
		MOVE.W #1,-(A7)	;	 16 bit stereo
		MOVE.W #$84,-(A7)	; setmode
		TRAP #14
		ADDQ.W #4,A7
		move.w #129,-(sp)	; unlocksound	
		trap #14
		addq.l #2,sp
		RTS

Int_On		MOVE.B $fffffa19.W,Old_19
		MOVE.B $fffffa1f.W,Old_1f
		BCLR #3,$fffffa17.W
		BSET #5,$fffffa07.W
		BSET #5,$fffffa13.W
		MOVE.B #freq,$fffffa1f.W
		MOVE.B #7,$fffffa19.W
		MOVE.L #New_A,$134.W
		RTS

Old_A		DC.L 0
Old_19		DC.B 0
Old_1f		DC.B 0

New_A		MOVEM.L	A0-A6/D0-D7,-(A7)
		LEA $ffffa200.w,A6		
		CLR.B 7(A6)		; strobe -> signal dsp to continue.
		LEA ch1s(PC),A1
		BSR.S send_voice
		LEA ch2s(PC),A1
		BSR.S send_voice
		LEA ch3s(PC),A1
		BSR.S send_voice
		LEA ch4s(PC),A1
		BSR.S send_voice
		BSR mt_music
		MOVEM.L	(A7)+,A0-A6/D0-D7
		RTE

; Send 1 voice to the dsp.

send_voice	MOVE.B aud_vol+1(A1),5(A6)	; send volume
		CLR.W 6(A6)			;
		MOVEQ #0,D0
		MOVE.W aud_per(A1),D0
		MOVE.L #$24665268,D1
		DIVU.L D0,D1
		SWAP D1
		MOVE.B D1,5(A6)			; send frequency
		ROL.L #8,D1
		MOVE.B D1,6(A6)			; (fraction)
		ROL.L #8,D1
		MOVE.B D1,7(A6)			; (fraction)
		MOVEQ #0,D0
.1		BTST #0,2(A6)			; wait for ack to 
		BEQ.S .1			; receive
		MOVE.B 5(A6),D0			;
		LSL.L #8,D0			;
		MOVE.B 6(A6),D0			; receive
		LSL.L #8,D0			; the offset to add to the
		MOVE.B 7(A6),D0			; current sample i.e
		MOVE.L vcaddr(A1),D1		; add it.
		TST.W start_flag(A1)
		BNE.S .no_loop
.2		ADD.L D0,D1
		CMP.L endoffy(A1),D1		; check for loop.
		BCS.S .no_loop			;
		SUB.L suboffy(A1),D1		; loop.
.no_loop	MOVE.L D1,vcaddr(A1)		; store new ptr.
		MOVE.L D1,A2			; a2-> current position (in sample)
		MOVEQ #0,D0
.5		BTST #0,2(A6)			; wait for ack
		BEQ.S .5			; to receive
		MOVE.B 5(A6),D0			;
		LSL.L #8,D0			; receive 
		MOVE.B 6(A6),D0			; no. of samples that 
		LSL.L #8,D0			; need to be sent.
		MOVE.B 7(A6),D0			;
		MOVEQ #3,D2
		DIVU D2,D0			; / 3
		ADD.W #50,D0			; + 2 (round up)
		CLR.B 5(A6)			;
		ROL.W #8,D0			; send a word saying the 
		MOVE.B D0,6(A6)			; no. of samples we're gonna
		ROL.W #8,D0			; send to the dsp.
		MOVE.B D0,7(A6)			;
		AND.W D0,D2
		LSR.W #2,D0
		NEG D2
		JMP .send(PC,D2.W*8)
.send_lp		
		REPT 4
		MOVE.B	(A2)+,5(A6)		; and send 'em!
		MOVE.W	(A2)+,6(A6)		;
		ENDR
.send		DBF D0,.send_lp
		CLR.W start_flag(A1)
		RTS 

; Pad samps. (prepare module)

prepare	lea	workspc,a6
	movea.l	mt_SampleStarts(PC),A0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	LEA	mt_SampleStarts(PC),A2
	lea	Module,a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition
	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample
	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero

repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk
	bra.s	rep

repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0
	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st
	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6

rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#padsize,d1		; Must be > padsize
	blt.s	toosmal
	move.w	#padsize/2-1,d2
.last	move.w	(a5)+,(a0)+		; Safety padsize bytes
	dbra	d2,.last
done	add.w	d4,d4
	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)
samplok	lea	$1E(a1),a1
	dbra	d7,roop
	cmp.l	#workspc,a0
	bgt.s	.nospac
	rts

.nospac	illegal

end_of_samples	DC.L 0

;********************************************  ; 100% FIXED VERSION
;* ----- Protracker V1.1B Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1991  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

mt_init	LEA	module,A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3
	MOVE.L A2,end_of_samples
	OR.B	#2,shfilter
	MOVE.B	#6,mt_speed
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
mt_end	MOVE.W	#$0,dmactrl
	RTS

mt_music
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1t(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2t(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3t(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4t(PC),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	ch1t(PC),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2t(PC),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3t(PC),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4t(PC),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D7
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D7,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	MOVE.W	n_dmabit(A6),D0
	OR.W D0,dmactrl
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	mt_DMACONtemp(PC),D0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	mt_chan1temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	aud1lc(pc),grf1lc	;
	add.l 	aud1lc(pc),d1
	move.l	d1,grf1len		;
	move.l	d2,grf1rpt		;
	move.w #-1,grf1flag

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	mt_chan2temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	aud2lc(pc),grf2lc	;
	add.l 	aud2lc(pc),d1
	move.l	d1,grf2len		;
	move.l	d2,grf2rpt		;
	move.w #-1,grf2flag

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	mt_chan3temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	aud3lc(pc),grf3lc	;
	add.l 	aud3lc(pc),d1
	move.l	d1,grf3len		;
	move.l	d2,grf3rpt		;
	move.w #-1,grf3flag

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	mt_chan4temp+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	aud4lc(pc),grf4lc	;
	add.l 	aud4lc(pc),d1
	move.l	d1,grf4len		;
	move.l	d2,grf4rpt		;
	move.w #-1,grf4flag
wz_nch4

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D7
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.W	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound			
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
	AND.B	#$FD,shfilter
	OR.B	D0,shfilter
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.W	n_dmabit(A6),dmactrl	; Channel DMA off
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	MOVE.W	D0,dmactrl

	MOVE.L	n_loopstart(A6),(A5)
	MOVE.L	n_replen(A6),4(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,D1/A0
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0,0

mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 0

; Hardware-registers & data --

ch1s
grf1lc		DC.L dummy
grf1len		DC.L 0
grf1rpt		DC.L 0
grf1flag	DC.W 0
ch1t
aud1lc		DC.L dummy
aud1len		DC.W 8
aud1per		DC.W 8000
aud1vol		DC.W 0
		DS.W 3

ch2s
grf2lc		DC.L dummy
grf2len		DC.L 8
grf2rpt		DC.L 0
grf2flag	DC.W 0
ch2t
aud2lc		DC.L dummy
aud2len		DC.W 0
aud2per		DC.W 8000
aud2vol		DC.W 0
		DS.W 3

ch3s
grf3lc		DC.L dummy
grf3len		DC.L 8
grf3rpt		DC.L 0
grf3flag	DC.W 0
ch3t
aud3lc		DC.L dummy
aud3len		DC.W 0
aud3per		DC.W 8000
aud3vol		DC.W 0
		DS.W 3

ch4s
grf4lc		DC.L dummy
grf4len		DC.L 8
grf4rpt		DC.L 0
grf4flag	DC.W 0
ch4t
aud4lc		DC.L dummy
aud4len		DC.W 8
aud4per		DC.W 8000
aud4vol		DC.W 0
		DS.W 3

shfilter	DC.W 0
dmactrl		DC.W 0

dummy		DS.L 4

; Dsp Code

DspProg		incbin a56.bin
DspProgEnd
		EVEN

		ENDC

pic		INCBIN leftdon.Tpi

		IFNE music
Module		INCBIN "overload.mod"
		ENDC

		SECTION BSS
		IFNE music
		DS.B 60000
workspc		DS.W 1
		ENDC

		DS.L 599
my_stack	DS.L 3
trans_crds    	DS.W 200
new_crds     	DS.W 200 
		
		DS.W 768
screens		DS.B 256
		DS.W 768*480
		DS.W 768
