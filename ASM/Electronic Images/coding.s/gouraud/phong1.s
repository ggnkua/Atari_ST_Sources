 ;-----------------------------------------------------------------------;
;									;
;   Fast Phong shading polygon routines,				;
; 				 by Martin Griffiths August 1993	;
;									;
; - Normal Interpolation with "Moire" dither shading			;
;									;
;-----------------------------------------------------------------------;

linewidth	equ 768

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

		OPT O+,OW-

demo		EQU 0

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
		
		BSR Initscreens
		BSR load_dspprog	
		MOVE.L D0,$FFFFA204.W	;stobe to continue
		MOVEC.L CACR,D0
		MOVE.L D0,oldCACR
		MOVE.L #ENABLE_CACHE+ENABLE_DATA_CACHE,D0
		MOVEC.L D0,CACR
 

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
		BSR wait_vbl
		BSR SetScreen
		BSR wait_vbl
		;MOVE.W #VGA+VERTFLAG+BPS16+OVERSCAN,-(SP)
		MOVE.W #PAL+BPS16+OVERSCAN,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

;		CLR.L $ffff9800.w
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

		LEA ls_angles,A5
	  	BSR Matrix_make
		LEA ls(PC),A0		
		LEA ls_transd(PC),A1
		MOVEQ #1,D7
		BSR Trans_coords
		ADD.W #200,ls_angles
		ADD.W #500,ls_angles+2
		ADD.W #800,ls_angles+4
		TST.W ls_transd+4
		BPL.S .ok1
		BSR Draw_ls
.ok1
		LEA v_angles,A5
	  	BSR Matrix_make
		BSR Do_Sequence
		MOVE.L g_objptr(PC),A0 
		BSR Draw_GObj
		TST.W ls_transd+4
		BMI.S .ok2
		BSR Draw_ls
.ok2

		BSR SwapScreens
		CMP.B #$39,$FFFFFC02.W
		BNE.S .vbl_lp

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
		MOVE.L oldCACR(PC),d0
		MOVEC.L D0,CACR
		
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		CLR -(SP)
		TRAP #1

oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1
oldCACR		DS.L 1
oldmfp		DS.L 22

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
;		not.l $ffff9800.w
;		MOVE.L $466.W,D0
;.wait		CMP.L $466.W,D0
;		BEQ.S .wait
;		not.l $ffff9800.w
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

; Little old vbl..

vbl		ADDQ.L #1,$466.W
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

ls		DC.W $0,$0,$7FFF
ls_transd	DS.W 3
ls_angles	DS.W 3
tc_count	DC.W 0
oldtc_count 	DC.W 0

log_base 	DS.L 3
g_objptr	DC.L gpyramid
v_angles	DS.W 3
xyz_offys	
x_offy		DS.W 1
y_offy		DS.W 1
z_offy		DS.W 1

Draw_ls		MOVE #192,A3		; centre x
		MOVE #120,A4		; centre y
		MOVEM.W ls_transd(PC),D0-D2	; x,y,z
		;MULS #600,D0
		;MULS #600,D1
		;MULS #600,D2
		;SWAP D0
		;SWAP D1
		;SWAP D2
		;EXT.L D0
		;EXT.L D1
		;ASL.L #8,D0
		;ASL.L #8,D1
		;ADD.W z_offy(PC),D2
		;DIVS D2,D0		; x/z
		MOVEQ #9,D2
		ASR.W D2,D0
		ASR.W D2,D1
		;DIVS D2,D1		; y/z
		ADD A3,D0		; x scr centre
		ADD A4,D1		; y scr centre
		MULU #linewidth,D1
		MOVE.L log_base(PC),A0
		ADD.L D1,A0
		LEA (A0,D0*2),A0
		MOVE.L #-1,(A0)
		MOVE.L #-1,4(A0)
		MOVE.L #-1,linewidth(A0)
		MOVE.L #-1,linewidth+4(A0)
		MOVE.L #-1,(linewidth*2)(A0)
		MOVE.L #-1,(linewidth*2)+4(A0)
		MOVE.L #-1,(linewidth*3)(A0)
		MOVE.L #-1,(linewidth*3)+4(A0)
		RTS


; A routine to find the square root of a long word N in d7
; in three iterations using the formula
; squrt = 1/2(squrt + n/squrt)
; approximate starting value found from the highest bit in d0
; Result passed in d0.w

sqrt:		moveq   #0,D7
                tst.l   D6
                beq.s   sqrt2           ; quit if 0
                moveq   #31,D5          ; 31 bits to examine
sqrt1:          btst    D5,D6           ; is this bit set?
                dbne    D5,sqrt1
                lsr.w   #1,D5           ; bit is set; 2^d7/2 approx root
                bset    D5,D7           ; raise 2 to this power
                REPT 4
                move.l  D6,D5
                divu    D7,D5           ; n/squrt
                add.w   D5,D7           ; squrt+N/squrt
                lsr.w   #1,D7           ; /2 gives new trial value
                ENDR
                moveq   #0,D5
                addx.w  D5,D7
sqrt2:          rts


; Calculate a translation matrix, from the angle data pointed by A5.
; D0-D7/A0-A3 smashed.

Matrix_make	LEA trig_tab,A0		;sine table
		LEA 512(A0),A2		;cosine table
		MOVEM.W (A5),D5-D7    	
		LSR #6,D5
		LSR #6,D6
		LSR #6,D7
		MOVE (A0,D5*2),D0	;sin(xd)
		MOVE (A2,D5*2),D1	;cos(xd)
		MOVE (A0,D6*2),D2	;sin(yd)
		MOVE (A2,D6*2),D3	;cos(yd)
		MOVE (A0,D7*2),D4	;sin(zd)
		MOVE (A2,D7*2),D5	;cos(zd)
		LEA matrix(PC),A1
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
		MOVE D6,(A1)+
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6		;siny*cosx
		MOVE A3,D7		;sinz*sinx
		MULS D3,D7		;cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)+
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6		;cosz
		MULS D0,D6		;cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-cosz*sinx
		MOVE D6,(A1)+
* Matrix(1,2) -siny*cosz
		MOVE D2,D6		;siny
		MULS D5,D6		;siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-siny*cosz
		MOVE D6,(A1)+
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6		;cosy
		MULS D5,D6		;cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,(A1)+
* Matrix(3,2) sinz 
		MOVE D4,(A1)+
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6		;cosy
		MULS D0,D6		;cosy*sinx
		MOVE A4,D7		;sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			;siny*(sinz*cosx)
		MOVE D6,(A1)+
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2		;siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,(A1)+
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5			;cosz*cosx
		MOVE D5,(A1)+
		RTS				

; Translate co-ords.
; D7 co-ords X,Y,Z at A0 ->  XNEW,YNEW,ZNEW at A1
; D0-D7/A2 trashed.

Trans_coords	SUBQ #1,D7		; -1
trans_lp	LEA matrix(PC),A2
		MOVEM.W (A0)+,D0-D2	; x,y,z
		MOVE D0,D3	
		MOVE D1,D4		; dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS (A2)+,D0			
M21		MULS (A2)+,D4		; mat mult
M31		MULS (A2)+,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS (A2)+,D3
M22		MULS (A2)+,D1		; mat mult
M32		MULS (A2)+,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
M13		MULS (A2)+,D6
M23		MULS (A2)+,D4		; mat mult
M33		MULS (A2)+,D2
		ADD.L D6,D2
		ADD.L D4,D2
		MOVEQ #15,D5
		ASR.L D5,D0
		ASR.L D5,D1
		ASR.L D5,D2
		MOVE D0,(A1)+		; new x co-ord
		MOVE D1,(A1)+		; new y co-ord
		MOVE D2,(A1)+		; new z co-ord
		DBF D7,trans_lp
		RTS
matrix		DS.W 9

; Draw Gouraud Shaded Object, D0-D7/A0-A6 smashed.

Draw_GObj	MOVE.W (A0)+,D7         ; verts
		MOVE.W D7,-(SP)
		ADD.W D7,D7		; *2
		LEA translated_crds,A1
		BSR Trans_coords	
.pers_intense	MOVE.W (SP)+,D4
		SUBQ #1,D4
		LEA translated_crds,A1
		LEA pers_crds,A2
		MOVE #192,A3		; centre x
		MOVE #120,A4		; centre y
		MOVEQ #8,D3
.norm_lp	MOVEM.W (A1)+,D0-D2	; x,y,z
		EXT.L D0
		EXT.L D1
		ASL.L D3,D0
		ASL.L D3,D1
		ADD.W z_offy(PC),D2
		DIVS D2,D0		; x/z
		DIVS D2,D1		; y/z
		ADD A3,D0		; x scr centre
		ADD A4,D1		; y scr centre
		MOVE D0,(A2)+		; new x co-ord
		MOVE D1,(A2)+		; new y co-ord
		MOVEM.W (A1)+,D0-D2	; 
		MOVEM.W D0-D2,(A2)	; store i,j,k
		ADDQ.L #6,A2
		DBF D4,.norm_lp

; A0 -> 'no. of faces-1' in object data.
		MOVE.W (A0)+,D6
.draw_face_lp 	LEA pers_crds,A6
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
		BLE.S .is_seen
		LEA (A0,D6*2),A0
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
; A0 -> D6 coords (offsets into 'translated_crds' in form X,Y,INTENSITY CONST) ;
;-----------------------------------------------------------------------;

wait_tosend	MACRO
.wait\@		BTST.B #1,-4(A3)
		BEQ.S .wait\@
		ENDM

wait_torec	MACRO
.wait1\@	BTST.B #0,-4(A3)
		BEQ.S .wait1\@
		ENDM

GDraw_Poly	
		LEA polydupspace,A1 
		LEA pers_crds,A6
		MOVE D6,D0
		LSL.W #2,D6
		ADD D0,D6
		LEA (A1,D6*2),A5
Init_coords	SUBQ #2,D0
		MOVE.W (A0)+,D7
		MOVE.W 8(A6,D7),D4	; lo
		MOVE.L 4(A6,D7),D5	; lm,ln
		MOVE.L (A6,D7),D7	; xy
		MOVE D7,D2
		MOVE.L A1,A4
		MOVE.L D7,(A1)+		;  
		MOVE.L D5,(A1)+
		MOVE.W D4,(A1)+
		MOVE.L D7,(A5)+		; dup
		MOVE.L D5,(A5)+
		MOVE.W D4,(A5)+
.coord_lp	MOVE.W (A0)+,D3
		MOVE.W 8(A6,D3),D4
		MOVE.L 4(A6,D3),D5
		MOVE.L (A6,D3),D3
		CMP D2,D3
		BGE.S .not_top
		MOVE D3,D2
		MOVE.L A1,A4
.not_top	CMP D3,D7
		BGE.S .not_bot
		MOVE D3,D7	
.not_bot	MOVE.L D3,(A1)+		; dup for rest
		MOVE.L D5,(A1)+
		MOVE.W D4,(A1)+
		MOVE.L D3,(A5)+
		MOVE.L D5,(A5)+
		MOVE.W D4,(A5)+
		DBF D0,.coord_lp
		LEA (A4,D6*2),A5
		MOVE.L A0,USP
		SUB D2,D7		;d2 - lowest y  d7 - greatest y
		BEQ polydone
		MOVE D2,-(SP)
CALCS		LEA $FFFFA206.W,A3
		wait_tosend	
		MOVE.W ls_transd+0(PC),D0
		EXT.L D0
		ASR.L #1,D0
		MOVE.L D0,-2(A3)
		MOVE.W ls_transd+2(PC),D0
		EXT.L D0
		ASR.L #1,D0
		MOVE.L D0,-2(A3)
		MOVE.W ls_transd+4(PC),D0
		EXT.L D0
		ASR.L #1,D0
		MOVE.L D0,-2(A3)
		wait_tosend	
		CLR.B -1(A3)
		MOVE.W D7,(A3)			; send dy
; Calc x's down left side of poly
Do_left		MOVE D7,D6
Left_lp 	LEA -10(A5),A5
		MOVEM.W (A5),D0-D1		;x2,y2
		MOVEM.W 10(A5),D2-D3		;x1,y1
		SUB D3,D1			;dy
		BEQ .nonetodo
		SUB D2,D0			;dx
		EXT.L D1
		EXT.L D0
		EXT.L D2
		MOVEM.W 4(A5),D3-D5		; i2,j2,k2
		SUB.W 10+4(A5),D3
		SUB.W 10+6(A5),D4
		SUB.W 10+8(A5),D5
		EXT.L D3
		EXT.L D4
		EXT.L D5
		wait_tosend	
		MOVE.L D1,-2(A3)		; Dy
		wait_tosend	
		MOVE.L D0,-2(A3)		; Dx
		wait_tosend
		MOVE.L D3,-2(A3)		; Di
		wait_tosend	
		MOVE.L D2,-2(A3)		; x1
		MOVE.W 10+4(A5),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; i1

		wait_tosend	
		MOVE.L D4,-2(A3)		; Dj
		wait_tosend
		MOVE.L D5,-2(A3)		; Dk
		MOVE.W 10+6(A5),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; j1
		MOVE.W 10+8(A5),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; k1

.nonetodo	SUB D1,D6			; remaining lines-dy
		BGT Left_lp

; Calc x's down right side of poly

Do_right	MOVE.W D7,D6
Right_lp	MOVEM.W (A4),D2-D3		;x1,y1
		MOVEM.W 10(A4),D0-D1		;x2,y2
		SUB D3,D1			;dy
		BEQ .nonetodo
		SUB D2,D0			;dx
		EXT.L D1
		EXT.L D0
		EXT.L D2
		MOVEM.W 10+4(A4),D3-D5		; i2,j2,k2
		SUB.W 4(A4),D3
		SUB.W 6(A4),D4
		SUB.W 8(A4),D5
		EXT.L D3
		EXT.L D4
		EXT.L D5
		wait_tosend	
		MOVE.L D1,-2(A3)		; Dy
		wait_tosend	
		MOVE.L D0,-2(A3)		; Dx
		wait_tosend	
		MOVE.L D3,-2(A3)		; Di
		wait_tosend	
		MOVE.L D2,-2(A3)		; x1
		MOVE.W 4(A4),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; i1

		wait_tosend	
		MOVE.L D4,-2(A3)		; Dj
		wait_tosend	
		MOVE.L D5,-2(A3)		; Dk
		MOVE.W 6(A4),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; j1
		MOVE.W 8(A4),D3
		EXT.L D3
		wait_tosend	
		MOVE.L D3,-2(A3)		; k1

.nonetodo	LEA 10(A4),A4
		SUB D1,D6			;remaining lines-dy
		BGT Right_lp

; Now draw on screen

.gofordraw 	MOVE (SP)+,D0		; MIN Y
		MULU #linewidth,D0 
		SUBQ #1,D7
		MOVE.L log_base(PC),A6
		ADDA.L D0,A6 
		wait_torec	
Gdraw_lp    	MOVE.W (A3),D0
		LEA (A6,D0.W*2),A0
		MOVE.W (A3),D6
		BRA.S .cont
.Glp		wait_torec	
		MOVE.W (A3),(A0)+
.cont		DBF D6,.Glp
DS2      	LEA linewidth(A6),A6
		DBF D7,Gdraw_lp
polydone	RTS 


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
pal1
pal2
pal3
pal4
pal5
pal6

; Sequence for the cube

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gpyramid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,120,$7777,$9999,$eeee,0,0,-30

		DC.W SetXYZstuff,213,$7777,$9999,$eeee,0,0,0
		DC.W SetXYZstuff,73,$7777,$9999,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,50,$7777,$9999,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gcube
		DC.W SetFadeIn
		DC.L pal2,currpal
		DC.W SetXYZstuff,110,$9999,$aaaa,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$9999,$aaaa,$eeee,0,0,0
		DC.W SetXYZstuff,83,$9999,$aaaa,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal2,currpal
		DC.W SetXYZstuff,40,$9999,$aaaa,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,$190,0,0
		DC.L v_angles,xyz_offys,gthargoid
		DC.W SetFadeIn
		DC.L pal1,currpal
		DC.W SetXYZstuff,90,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,68,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal1,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gstation
		DC.W SetFadeIn
		DC.L pal6,currpal
		DC.W SetXYZstuff,100,$7777,$cccc,$eeee,0,0,-30
		DC.W SetXYZstuff,210,$0,$0,$0,0,0,0
		DC.W SetXYZstuff,210,$7777,$cccc,$eeee,0,0,0
		DC.W SetXYZstuff,80,$7777,$cccc,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal6,currpal
		DC.W SetXYZstuff,40,$7777,$cccc,$eeee,0,0,30

G_Sequence	
		DC.W SetNewObj,0,0,$1000,0,0,0
		DC.L v_angles,xyz_offys,gasteriod
		DC.W SetFadeIn
		DC.L pal5,currpal
		DC.W SetXYZstuff,108,$cccc,$9999,$eeee,0,0,-30
		DC.W SetXYZstuff,1300,$cccc,$9999,$eeee,0,0,0
		DC.W SetXYZstuff,78,$cccc,$9999,$eeee,0,0,30
		DC.W SetFadeDown
		DC.L pal5,currpal
		DC.W SetXYZstuff,40,$cccc,$9999,$eeee,0,0,30
		DC.W SetRestart

; Gouraud Cube

gcube 		DC.W 8
		DC.W -100,100,100
		DC.W -8192,8192,8192
		DC.W -100,100,-100
		DC.W -8192,8192,-8192
		DC.W 100,100,-100
		DC.W 8192,8192,-8192
		DC.W 100,100,100
		DC.W 8192,8192,8192
		DC.W -100,-100,100
		DC.W -8192,-8192,8192
		DC.W -100,-100,-100
		DC.W -8192,-8192,-8192
		DC.W 100,-100,-100
		DC.W 8192,-8192,-8192
		DC.W 100,-100,100
		DC.W 8192,-8192,8192		;18500
		DC.W 4,0*10,1*10,2*10,3*10
		DC.W 4,7*10,6*10,5*10,4*10
		DC.W 4,2*10,6*10,7*10,3*10
		DC.W 4,0*10,3*10,7*10,4*10
		DC.W 4,1*10,0*10,4*10,5*10
		DC.W 4,1*10,5*10,6*10,2*10
		DC.W -1

gpyramid	DC.W 5
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
		DC.W 4,3*10,2*10,1*10,00*10
		DC.W 3,0*10,1*10,4*10
		DC.W 3,1*10,2*10,4*10
		DC.W 3,2*10,3*10,4*10
		DC.W 3,3*10,0*10,4*10
		DC.W -1

gstation	
	DC.W	12
	DC.W	0,-200,200
	DC.W	0,11585,-11585
	DC.W	200,0,200
	DC.W	-11585,0,-11585
	DC.W	200,-200,0
	DC.W	-11585,11585,0
	DC.W	0,200,200
	DC.W	0,-11585,-11585
	DC.W	200,0,-200
	DC.W	-11585,0,11585
	DC.W	-200,-200,0
	DC.W	11585,11585,0
	DC.W	0,-200,-200
	DC.W	0,11585,11585
	DC.W	-200,0,200
	DC.W	11585,0,-11585
	DC.W	200,200,0
	DC.W	-11585,-11585,0
	DC.W	0,200,-200
	DC.W	0,-11585,11585
	DC.W	-200,0,-200
	DC.W	11585,0,11585
	DC.W	-200,200,0
	DC.W	11585,-11585,0

		DC.W 3,00*10,01*10,02*10
		DC.W 3,09*10,11*10,10*10
		DC.W 3,04*10,08*10,09*10
		DC.W 3,01*10,03*10,08*10
		DC.W 3,03*10,07*10,11*10
		DC.W 3,00*10,05*10,07*10
		DC.W 3,05*10,06*10,10*10
		DC.W 3,02*10,04*10,06*10
		DC.W 4,00*10,02*10,06*10,05*10
		DC.W 4,04*10,02*10,01*10,08*10
		DC.W 4,00*10,07*10,03*10,01*10
		DC.W 4,07*10,05*10,10*10,11*10
		DC.W 4,08*10,03*10,11*10,09*10
		DC.W 4,06*10,04*10,09*10,10*10
		DC.W -1


gasteriod	
	DC.W	12
	DC.W	0,-100,200
	DC.W	0,-8474,14022
	DC.W	200,0,100
	DC.W	14022,0,8474
	DC.W	100,-200,0
	DC.W	8474,-14022,0
	DC.W	0,100,200
	DC.W	0,8474,14022
	DC.W	200,0,-100
	DC.W	14022,0,-8474
	DC.W	-100,-200,0
	DC.W	-8474,-14022,0
	DC.W	0,-100,-200
	DC.W	0,-8474,-14022
	DC.W	-200,0,100
	DC.W	-14022,0,8474
	DC.W	100,200,0
	DC.W	8474,14022,0
	DC.W	0,100,-200
	DC.W	0,8474,-14022
	DC.W	-200,0,-100
	DC.W	-14022,0,-8474
	DC.W	-100,200,0
	DC.W	-8474,14022,0

		DC.W 3,01*10,02*10,04*10
		DC.W 3,01*10,00*10,02*10
		DC.W 3,02*10,00*10,05*10
		DC.W 3,02*10,05*10,06*10
		DC.W 3,02*10,06*10,04*10
		DC.W 3,04*10,06*10,09*10
		DC.W 3,04*10,09*10,08*10
		DC.W 3,01*10,04*10,08*10
		DC.W 3,03*10,01*10,08*10
		DC.W 3,00*10,01*10,03*10
		DC.W 3,07*10,11*10,10*10
		DC.W 3,00*10,07*10,05*10
		DC.W 3,10*10,05*10,07*10
		DC.W 3,06*10,05*10,10*10
		DC.W 3,06*10,10*10,09*10
		DC.W 3,09*10,10*10,11*10
		DC.W 3,08*10,09*10,11*10
		DC.W 3,03*10,08*10,11*10
		DC.W 3,03*10,11*10,07*10
		DC.W 3,00*10,03*10,07*10
		DC.W -1

gthargoid	DC.W 16
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

		DC.W 8,00*10,01*10,02*10,03*10,04*10,05*10,06*10,07*10
		DC.W 8,15*10,14*10,13*10,12*10,11*10,10*10,09*10,08*10
		DC.W 4,06*10,14*10,15*10,07*10
		DC.W 4,05*10,13*10,14*10,06*10
		DC.W 4,04*10,12*10,13*10,05*10
		DC.W 4,03*10,11*10,12*10,04*10
		DC.W 4,02*10,10*10,11*10,03*10
		DC.W 4,01*10,09*10,10*10,02*10
		DC.W 4,00*10,08*10,09*10,01*10
		DC.W 4,07*10,15*10,08*10,00*10
		DC.W -1

; Dsp loader

load_dspprog	MOVE.W #1,-(A7)		; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)		; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		RTS

DspProg		incbin phong1.bin
DspProgEnd
		EVEN

		SECTION BSS

		DS.L 499
my_stack	DS.L 3
polydupspace    DS.W 5*2*32		; space for 32 sided poly!
translated_crds DS.W 3*100 		; space for translated co-ords
pers_crds	DS.W 3*100
		
		DS.W 768
screens		DS.B 256
		DS.W 768*480
		DS.W 768
