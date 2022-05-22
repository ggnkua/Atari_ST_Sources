; 3D Object Rotation routine V7.0
; by Martin Griffiths 	 	
; (C) SEPTEMBER 1989 - MAY 1990
; Updated/improved :-
; Fully clipped         - Jan 1990
; New ultra hline routine using lots
; of bloody tables      - March 1990
; Better gradient calcs - May 1990
; More Accurate/faster translation
; and perspective rout  - June 1990 
; New gradient calc routine which
; only uses one muls!!! - June 1990
		
		OPT O+,OW-

; Clip window boundaries

xmin		EQU 0
ymin		EQU 0
xmax		EQU 319
ymax		EQU 149

init		CLR.W -(SP)
		PEA $FFFFFFFF.W
		MOVE.L (SP),-(SP)
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA stack(PC),SP
		MOVE #$2700,SR

cls		MOVE.L log_base(PC),A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L $70.W,old_vbl
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
		
Rotate	LEA smsphere(PC),A5
		ADDQ #8,(A5)
		AND #$3FF,(A5)
		ADDQ #5,2(A5)
		AND #$3FF,2(A5)
		ADDQ #6,4(A5)
		AND #$3FF,4(A5)
		move.l #$9000000,16(a5)
		BSR Show_obj
		BSR sw_clr
		CMP.B #$39,$FFFFFC02.W
		BNE Rotate

		MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L old_vbl(PC),$70.W
flush		btst.b #0,$fffffc00.w
		beq.s fldone
		move.b $fffffc02.w,d0
		bra.s flush
fldone	MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

; Routine to calculate and draw
; a solid convex 3d object.
; A5 points to shape data.
; D0-D7/A0-A6 smashed(everything!!).

Show_obj	BSR Matrix_make		rotmat
		MOVE (A5)+,D7		no of verts
		LEA 12(A5),A0		a5 - offsets
		LEA new_coords(PC),A1	new x,y co-ords
		BSR Trans_verts		translate
* A0 - no. of faces in shape data.
		LEA startvc(PC),A3
draw_faces	MOVE (A0)+,-(SP)
face_lp	MOVE (A0)+,col
		MOVE (A0)+,D6
		MOVE.L A0,-(SP)	
		BSR Draw_poly		draw face
		MOVE.L (SP)+,A0
		MOVE -2(A0),D7
		ADD D7,D7
		ADDA.W D7,A0
next_face	SUBQ #1,(SP)
		BNE.S face_lp
		ADDQ.L #2,SP
		RTS

; Calculate a rotational matrix,
; from the angle data pointed by A5.
; D0-D4/A0-A3 smashed.

Matrix_make	LEA trig_tab(PC),A0	cosine table
		LEA trig_tab+512(PC),A2	sine   table
		LEA trig_buf(PC),A1	
		LEA M11+2(PC),A3
		MOVEM.W (A5)+,D0-D2    	
		ADD D0,D0
		ADD D1,D1			
		ADD D2,D2
		MOVE (A0,D0),(A1)+	sin(xd)
		MOVE (A2,D0),(A1)+	cos(xd)
		MOVE (A0,D1),(A1)+	sin(yd)
		MOVE (A2,D1),(A1)+	cos(yd)
		MOVE (A0,D2),(A1)+	sin(zd)
		MOVE (A2,D2),(A1)+	cos(zd)
		LEA -12(A1),A0		sin & cos values
* sinz*sinx(used twice) - D3
		MOVE (A0),D3		sinx
		MULS 8(A0),D3		sinz*sinx
		ADD.L D3,D3
		SWAP D3
* sinz*cosx(used twice) - D4
		MOVE 2(A0),D4 		cosx
		MULS 8(A0),D4		sinz*cosx
		ADD.L D4,D4
		SWAP D4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE 6(A0),D0  		cosy
		MULS 2(A0),D0		cosy*cosx
		MOVE 4(A0),D1		siny
		MULS D3,D1			
		SUB.L D1,D0
		ADD.L D0,D0
		SWAP D0			siny*(sinz*sinx)
		MOVE D0,(A3)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE 4(A0),D0		siny
		MULS 2(A0),D0		siny*cosx
		MOVE 6(A0),D1		cosy
		MULS D3,D1			
		ADD.L D1,D0
		ADD.L D0,D0
		SWAP D0			cosy*(sinz*sinx)
		MOVE D0,M21-M11(A3)
* Matrix(3,1) -cosz*sinx
		MOVE 10(A0),D0		cosz
		MULS (A0),D0		cosz*sinx
		ADD.L D0,D0
		SWAP D0			cosz*sinx
		NEG D0			negate
		MOVE D0,M31-M11(A3)
* Matrix(1,2) -siny*cosz
		MOVE 4(A0),D0		siny
		MULS 10(A0),D0		siny*cosz
		ADD.L D0,D0
		SWAP D0			adjust
		NEG D0			negate
		MOVE D0,M12-M11(A3)
* Matrix(2,2) cosy*cosz		
		MOVE 6(A0),D0		cosy
		MULS 10(A0),D0		cosy*sinz
		ADD.L D0,D0
		SWAP D0
		MOVE D0,M22-M11(A3)
* Matrix(3,2) sinz 
		MOVE 8(A0),M32-M11(A3)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE 6(A0),D0		cosy
		MULS (A0),D0		cosy*sinx
		MOVE 4(A0),D1		siny
		MULS D4,D1
		ADD.L D1,D0
		ADD.L D0,D0
		SWAP D0			siny*(sinz*cosx)
		MOVE D0,M13-M11(A3)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MOVE 4(A0),D0		siny
		MULS (A0),D0			siny*sinx		
		MOVE 6(A0),D1		cosy
		MULS D4,D1	
		SUB.L D1,D0
		ADD.L D0,D0
		SWAP D0			cosy*(sinz*cosx)
		MOVE D0,M23-M11(A3)
* Matrix(3,3) cosz*cosx
		MOVE 10(A0),D0		cosz
		MULS 2(A0),D0		cox*cosz
		ADD.L D0,D0
		SWAP D0			cosz*cosx
		MOVE D0,M33-M11(A3)
		RTS				

; Transform and perspect co-ords.
; A0 points to D7 source co-ords
; x,y,z.A1 points to a storage place
; for the resultant x,y co-ords.
; A5 - x,y,z offsets for co-ords.
; D0-D7/A0-A4 smashed.

Trans_verts	MOVE.L (A5),addoffx+2
		MOVE.L 4(A5),addoffy+2
		MOVE.L 8(A5),addoffz+2
		MOVEA #160,A3		centre x
		MOVEA #75,A4		centre y
		SUBQ #1,D7			verts-1
trans_lp	MOVEM.W (A0)+,D0-D2	x,y,z
		MOVE D0,D3	
		MOVE D1,D4			dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4			mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1			mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4			mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
addoffx	ADD.L #0,D0
addoffy	ADD.L #0,D1
addoffz	ADD.L #0,D2
* Combine and Perspect (more accurate than previous method!)
		ASR.L #8,D0						
		ASR.L #8,D1			
		SWAP D2
		DIVS D2,D0			x/z
		DIVS D2,D1			y/z
		ADD A3,D0			x scr centre
		ADD A4,D1			y scr centre
		MOVE D0,(A1)+		new x co-ord
		MOVE D1,(A1)+		new y co-ord
		DBF D7,trans_lp
		RTS

; Routine that will select and draw
; only clockwise polygons.Polygons
; whose vertices run anti-clockwise
; cannot possibly be seen.
; A0 points to D6 coords,taken from
; the translated co-ords "new_coords"
; Polygon is clipped if necessary.
; Polygon drawn in colour 'col'.
; Polyfill coded with self-modifying
; colour routines for extra speed.

* First clock sense test to decide
* whether to draw face or not.

Draw_poly	LEA new_coords(PC),A5
		MOVE.L A5,A6
		ADDA.W (A0),A6
		MOVE (A6)+,D1	
		MOVE (A6),D2	
		MOVE.L A5,A6
		ADDA.W 2(A0),A6
		MOVE (A6)+,D3
		MOVE (A6),D4	
		SUB D3,D1
		SUB D4,D2
		MOVE.L A5,A6
		ADDA.W 4(A0),A6
		SUB (A6)+,D3		
		SUB (A6),D4		
		MULS D4,D1
		MULS D2,D3
		SUB.L	D3,D1
		BMI poly_done1

* First get co-ord from offset list
* and check if it is outside the
* clipping area.If all vertices are
* inside window then no clipping is
* required - quicker!

Test_Clip	LEA p_space(PC),A2
		MOVE.L A2,A1
		MOVEQ #xmin,D0
		MOVEQ #ymin,D1
		MOVE #xmax,D2
		MOVE #ymax,D3
		MOVE D6,D7
		SUBQ #3,D7
		MOVE (A0)+,D4
		MOVE.L (A5,D4),D4
		MOVE.L D4,(A2)+
		CMP D1,D4
		BLT needs_clip
		CMP D3,D4
		BGT needs_clip
		SWAP D4
		CMP D0,D4
		BLT needs_clip
		CMP D2,D4
		BGT needs_clip
		MOVE (A0)+,D4
		MOVE.L (A5,D4),D4
		MOVE.L D4,(A2)+
		CMP D1,D4
		BLT needs_clip
		CMP D3,D4
		BGT needs_clip
		SWAP D4
		CMP D0,D4
		BLT needs_clip
		CMP D2,D4
		BGT needs_clip
dup_lp1	MOVE (A0)+,D4
		MOVE.L (A5,D4),D4
		MOVE.L D4,(A2)+
		CMP D1,D4
		BLT needs_clip
		CMP D3,D4
		BGT needs_clip
		SWAP D4
		CMP D0,D4
		BLT needs_clip
		CMP D2,D4
		DBGT D7,dup_lp1
		BGT needs_clip
		MOVE.L A1,A0

**************************************************************************
				
* This is the polyfiller itself!
* now this is super fast!!!

Polyfill	MOVE D6,D4
		ADD D4,D4
		ADD D4,D4
		ADDA.W D4,A1
		MOVE.L A1,A2
		ADDA.W D4,A2
Init_coords	SUBQ #3,D6
		MOVEM.L (A0)+,D2-D3
		MOVE.W D2,D7
		MOVE.L A1,A4
		MOVE.L D2,(A1)+
		MOVE.L D2,(A2)+
		CMP D2,D3
		BGE.S not_top1
		MOVE D3,D2
		MOVE.L A1,A4
not_top1	CMP D3,D7
		BGE.S not_bot1
		MOVE D3,D7	
not_bot1	MOVE.L D3,(A1)+
		MOVE.L D3,(A2)+

coord_lp	MOVE.L (A0)+,D3
		CMP D2,D3
		BGE.S not_top2
		MOVE D3,D2
		MOVE.L A1,A4
not_top2	CMP D3,D7
		BGE.S not_bot2
		MOVE D3,D7	
not_bot2	MOVE.L D3,(A1)+
		MOVE.L D3,(A2)+
		DBF D6,coord_lp
		SUB D2,D7
		SUBQ #1,D7
		BMI poly_done1
		MOVE.L A4,Left_rchd+2
		MOVE.L (A4)+,D5
flat_check	CMP 2(A4),D5
		BNE.S flat_done
		ADDQ.L #4,A4
flat_done	MOVE.L A4,Right_rchd+2
modify_col	MOVE col(PC),D0
		MOVEM.L col0(PC,D0),D1/D2/A4/A5
		LEA f_chunk(PC),A2
		MOVEM.L D1-D2,(A2)
		MOVEM.L D1-D2,e_chunk-f_chunk(A2)
		MOVEM.L D1-D2,chunk1-f_chunk(A2)
get_line	LEA log_base(PC),A2
		MOVE.L (A2),A6
		ADD D5,D5
		ADD 12(A2,D5),A6
		MOVEQ #0,D6
		BRA Left_rchd

col0		AND D2,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		DC.L $00000000,$00000000
col1		OR D0,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		DC.L $FFFF0000,$00000000
col2		AND D2,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		DC.L $0000FFFF,$00000000
col3		OR D0,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		DC.L $FFFFFFFF,$00000000
col4		AND D2,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		DC.L $00000000,$FFFF0000
col5		OR D0,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
 		DC.L $FFFF0000,$FFFF0000
col6		AND D2,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		DC.L $0000FFFF,$FFFF0000
col7		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		DC.L $FFFFFFFF,$FFFF0000
col8		AND D2,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		DC.L $00000000,$0000FFFF
col9		OR D0,(A0)+
		AND D2,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
	 	DC.L $FFFF0000,$0000FFFF
col10		AND D2,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		DC.L $0000FFFF,$0000FFFF
col11		OR D0,(A0)+
		OR D0,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		DC.L $FFFFFFFF,$0000FFFF
col12		AND D2,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $00000000,$FFFFFFFF
col13		OR D0,(A0)+
		AND D2,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $FFFF0000,$FFFFFFFF
col14		AND D2,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $0000FFFF,$FFFFFFFF
col15		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		DC.L $FFFFFFFF,$FFFFFFFF

polyfill_lp	SUBQ #1,D5			; rows left on left
		BMI Left_rchd		;	
r1		SUBQ #1,D6			; rows left on right
		BMI Right_rchd		;
		MOVE.l D3,D0		; 
		MOVE.l D4,D1		; 
		swap d0
		swap d1
		MOVEQ #-4,D2
		and D2,d0
		and D2,d1
		ADD.L A1,D3			; 
		ADD.L A2,D4			;
Hline		SUB D0,D1			; dx
		MOVEQ #63,D2		; (63 AND X1)
		AND D0,D2			; 
		ADD D2,D1			; add to remaining pixels 
		MOVE.L (A3,D0),D2		; get mask and line offset
		MOVE.L A6,A0		; get scr base
		ADDA.W D2,A0		; add line offset
		SWAP D2			; top word has mask
		CMP #63,D1			; is hline over one chunk?
		BLE one_case		; yes then goto special case
		MOVE D2,D0			; otherwise 
		NOT D0			; d0 = data d2 = mask
f_chunk	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+			; mask to screen
		OR D0,(A0)+
		MOVE.L ch_vect(PC,D1),D2 ; get jump offset and end mask
		JMP miss_main(PC,D2.W)	; jump backwards thru solid colour routine
		MOVE.L A4,(A0)+		; write one chunk of solid
		MOVE.L A5,(A0)+		; colour data(4 planes=2 longs!)
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
		MOVE.L A4,(A0)+
		MOVE.L A5,(A0)+
miss_main	SWAP D2			; top word has mask
		MOVE D2,D0			
		NOT D0			; d0 = data d2 = mask	
e_chunk	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+			; mask end chunk
		OR D0,(A0)+
next_line	LEA 160(A6),A6		; next screen line
		DBF D7,polyfill_lp	; carry on filling all lines...
poly_done1	RTS				; finished!

; End masks and solid colour jump offsets.
		
i		SET 4
ch_vect	REPT 20
		DC.W $7FFF,i
		DC.W $3FFF,i
		DC.W $1FFF,i
		DC.W $0FFF,i
		DC.W $07FF,i
		DC.W $03FF,i
		DC.W $01FF,i
		DC.W $00FF,i
		DC.W $007F,i
		DC.W $003F,i
		DC.W $001F,i
		DC.W $000F,i
		DC.W $0007,i
		DC.W $0003,i
		DC.W $0001,i
		DC.W $0000,i
i		SET i-4
		ENDR

; Hline over one chunk case

one_case	OR e_masks+2(PC,D1.W),D2 		; combine end mask with start mask
		MOVE D2,D0				
		NOT D0				; d0 = data d2 = mask
chunk1	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		LEA 160(A6),A6			; next screen line
		DBF D7,polyfill_lp		; and continue plotting.
		RTS
		DCB.l 20,$FFFF
e_masks	DC.l $7FFF,$3FFF,$1FFF,$0FFF
		DC.l $07FF,$03FF,$01FF,$00FF
		DC.l $007F,$003F,$001F,$000F
		DC.l $0007,$0003,$0001,$0000

; Start masks and screen line offsets

i		SET 0
startvc	REPT 20
		DC.W $0000,i
		DC.W $8000,i
		DC.W $C000,i
		DC.W $E000,i
		DC.W $F000,i
		DC.W $F800,i
		DC.W $FC00,i
		DC.W $FE00,i
		DC.W $FF00,i
		DC.W $FF80,i
		DC.W $FFC0,i
		DC.W $FFE0,i
		DC.W $FFF0,i
		DC.W $FFF8,i
		DC.W $FFFC,i
		DC.W $FFFE,i
i		SET i+8
		ENDR

; Vertex reached on the left.

Left_rchd 	LEA Left_rchd,A0
		MOVE.L (A0),D3
		MOVE -(A0),D5
		MOVE -(A0),D1
		SUB D3,D5
		CLR D3
		MOVE D5,D0
		SWAP D3
		SUB D3,D1
		ADD D3,D3	
		ADD D3,D3
		SWAP D3	
		ADD #320,D0
		ADD D0,D0
		MULS grad_table(PC,D0),D1
		asl.l #2,d1
		MOVE.L D1,A1
		MOVE.L A0,Left_rchd+2
		TST D6
		BPL polyfill_lp

; Vertex reached on the right.

Right_rchd	LEA Right_rchd,A0
		MOVE.L -4(A0),D4
		MOVE (A0)+,D1
		MOVE (A0)+,D6
		SUB D4,D6
		CLR D4
		MOVE D6,D0
		SWAP D4
		SUB D4,D1
		ADD D4,D4
		ADD D4,D4
		SWAP D4
		ADD #320,D0
		ADD D0,D0
		MULS grad_table(PC,D0),D1
		asl.l #2,d1
		MOVE.L D1,A2
		MOVE.L A0,Right_rchd+2
		BRA r1

grad_table	INCBIN GRADTAB.DAT

***************************************************************************

***************************************************************************

; Yes folks here comes the Polygon
; clipper.This is only quite fast!!
; (and that is only because its from ST world!)

; Macros for line intersection (which isn't even accurate!)
 
horiz_cross	MACRO
		MOVE D0,D4
		SUB D2,D4
		MOVE D1,D5
		SUB D6,D5
		MULS D5,D4
		MOVE D1,D5
		SUB D3,D5
		DIVS D5,D4
		NEG D4
		ADD D0,D4
		MOVE D4,(A2)+
		MOVE D6,(A2)+
		ENDM

vert_cross	MACRO
		MOVE D1,D4
		SUB D3,D4
		MOVE D0,D5
		SUB D6,D5
		MULS D5,D4
		MOVE D0,D5
		SUB D2,D5
		DIVS D5,D4
		NEG D4
		ADD D1,D4
		MOVE D6,(A2)+
		MOVE D4,(A2)+
		ENDM

; Polygon needs clipping...

dup_lp2	MOVE (A0)+,D4
		MOVE.L (A5,D4),(A2)+
needs_clip	DBF D7,dup_lp2	
		MOVE.L A1,A0
		MOVE.W D6,D7

; Clip to TOP of window
		
		MOVEM.W -4(A2),D0/D1
		MOVE D0,D2
		MOVE D1,D3
		SUBQ #1,D7
		MOVEQ #ymin,D6
		CMP D6,D3
		BLT.S CP_lp2_t
CP_lp1_t	MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D1
		BGE.S CP1_t
		horiz_cross
		MOVEQ #-1,D4
		BRA.S next_CP2_t
CP3_t		horiz_cross
CP1_t		MOVE D0,(A2)+
		MOVE D1,(A2)+
		MOVE D0,D2
		MOVE D1,D3
next_CP1_t	DBF D7,CP_lp1_t
		BRA.S CP5_t
CP_lp2_t	MOVE D0,D2
		MOVE D1,D3
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D1
next_CP2_t	DBGE D7,CP_lp2_t
		BEQ.S CP1_t
		BGT.S CP3_t

; Clip to LEFT of window.

CP5_t		MOVEM.W -4(A2),D0/D1
		MOVE D0,D2
		MOVE D1,D3
		MOVE.L A2,D7
		SUB.L A1,D7
		BEQ poly_done1
		LSR #2,D7
		SUBQ #1,D7
		MOVEQ #xmin,D6
		CMP D6,D2
		BLT.S CP_lp2_l
CP_lp1_l	MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D0
		BGE.S CP1_l
		vert_cross
		MOVEQ #-1,D4
		BRA.S next_CP2_l
CP3_l		vert_cross
CP1_l		MOVE D0,(A2)+
		MOVE D1,(A2)+
		MOVE D0,D2
		MOVE D1,D3
next_CP1_l	DBF D7,CP_lp1_l
		BRA.S CP5_l
CP_lp2_l	MOVE D0,D2
		MOVE D1,D3
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D0
next_CP2_l	DBGE D7,CP_lp2_l
		BEQ.S CP1_l
		BGT.S CP3_l

; Clip to BOTTOM of window

CP5_l		MOVEM.W -4(A2),D0/D1
		MOVE D0,D2
		MOVE D1,D3
		MOVE.L A2,D7
		SUB.L A1,D7
		BEQ poly_done1
		LSR #2,D7
		SUBQ #1,D7
		MOVE #ymax,D6
		CMP D6,D3
		BGT.S CP_lp2_b
CP_lp1_b	MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D1
		BLE.S CP1_b
		horiz_cross
		MOVEQ #1,D4
		BRA.S next_CP2_b
CP3_b		horiz_cross
CP1_b		MOVE D0,(A2)+
		MOVE D1,(A2)+
		MOVE D0,D2
		MOVE D1,D3
next_CP1_b	DBF D7,CP_lp1_b
		BRA.S CP5_b
CP_lp2_b	MOVE D0,D2
		MOVE D1,D3
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D1
next_CP2_b	DBLE D7,CP_lp2_b
		BEQ.S CP1_b
		BLT.S CP3_b

; Clip to RIGHT of window

CP5_b		MOVEM.W -4(A2),D0/D1
		MOVE D0,D2
		MOVE D1,D3
		MOVE.L A2,D7
		SUB.L A1,D7
		BEQ poly_done1
		LSR #2,D7
		SUBQ #1,D7
		MOVE.L A0,A2
		MOVE #xmax,D6
		CMP D6,D2
		BGT.S CP_lp2_r
CP_lp1_r	MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D0
		BLE.S CP1_r
		vert_cross
		MOVEQ #1,D4
		BRA.S next_CP2_r
CP3_r		vert_cross
CP1_r		MOVE D0,(A2)+
		MOVE D1,(A2)+	
		MOVE D0,D2
		MOVE D1,D3
next_CP1_r	DBF D7,CP_lp1_r		
		BRA.S CP5_r
CP_lp2_r	MOVE D0,D2
		MOVE D1,D3
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		CMP D6,D0
next_CP2_r	DBLE D7,CP_lp2_r
		BEQ.S CP1_r
		BLT.S CP3_r
CP5_r		MOVE.L A2,D6
		SUB.L A0,D6
		BEQ poly_done1
		LSR #2,D6
		MOVE.L A0,A1
		BRA Polyfill

***************************************************************************

; Swap screens and clear screens

sw_clr  	LEA log_base(PC),A0
		MOVE.L (A0)+,D5
		MOVE.L (A0)+,D6
		MOVE.L (A0)+,D7
		MOVE.L D6,-(A0)
		MOVE.L D5,-(A0)
		MOVE.L D7,-(A0)
		LSR #8,D5
		MOVE.L D5,$FFFF8200.W
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S wait_vbl
	 	
clearscreen	MOVE.L D7,A0
		LEA 24000(A0),A0
		MOVEQ #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,D7
		MOVE.L D0,A1
		MOVE.L D0,A2
		MOVE.L D0,A3
		MOVE.L D0,A4
		MOVE.L D0,A5
		MOVE.L D0,A6
		REPT 432
		MOVEM.L D0-D7/A1-A6,-(A0)
		ENDR
		RTS

* My little VBL!

my_vbl	ADDQ #1,vbl_timer
		RTE

; Shape data
smsphere	incbin smsphere.g3d
*sphere	incbin sphere.g3d
*ship1	incbin ship1.g3d
*disk1	incbin disk1.g3d
*ic		incbin ic.g3d
*disk		incbin disk.g3d

cube		DC.W 0,0,0
		DC.W 8
		DC.L 0,0,$2C00000
		DC.W -200,-200,-200
		DC.W 200,-200,-200
		DC.W 200,-200,200
		DC.W -200,-200,200
		DC.W -200,200,-200
		DC.W 200,200,-200
		DC.W 200,200,200
		DC.W -200,200,200
		DC.W 6
		DC.W 09*16,4,03*4,02*4,01*4,00*4
		DC.W 10*16,4,02*4,06*4,05*4,01*4
		DC.W 11*16,4,03*4,07*4,06*4,02*4
		DC.W 12*16,4,06*4,07*4,04*4,05*4
		DC.W 13*16,4,01*4,05*4,04*4,00*4
		DC.W 14*16,4,04*4,07*4,03*4,00*4

thargoid	DC.W 0,0,0	
		DC.W 16
		DC.L 0,0,$3000000
		DC.W 0,200,0
		DC.W 140,140,0
		DC.W 200,0,0
		DC.W 140,-140,0
		DC.W 0,-200,0
		DC.W -140,-140,0
		DC.W -200,0,0
		DC.W -140,140,0
		DC.W 0,360,-100
		DC.W 252,252,-100
		DC.W 360,0,-100
		DC.W 252,-252,-100
		DC.W 0,-360,-100
		DC.W -252,-252,-100
		DC.W -360,0,-100
		DC.W -252,252,-100
		DC.W 10
		DC.W 1*16,8,00*4,01*4,02*4,03*4,04*4,05*4,06*4,07*4
		DC.W 2*16,8,15*4,14*4,13*4,12*4,11*4,10*4,09*4,08*4
		DC.W 3*16,4,06*4,14*4,15*4,07*4
		DC.W 4*16,4,05*4,13*4,14*4,06*4
		DC.W 5*16,4,04*4,12*4,13*4,05*4
		DC.W 6*16,4,03*4,11*4,12*4,04*4
		DC.W 3*16,4,02*4,10*4,11*4,03*4
		DC.W 4*16,4,01*4,09*4,10*4,02*4
		DC.W 5*16,4,00*4,08*4,09*4,01*4
		DC.W 6*16,4,07*4,15*4,08*4,00*4

station	DC.W 0,0,0
		DC.W 12
		DC.L 0,0,$3000000
		DC.W 0,-200,200
		DC.W 200,0,200
		DC.W 200,-200,0
		DC.W 0,200,200
		DC.W 200,0,-200
		DC.W -200,-200,0
		DC.W 0,-200,-200
		DC.W -200,0,200
		DC.W 200,200,0
		DC.W 0,200,-200
		DC.W -200,0,-200
		DC.W -200,200,0
		DC.W 14
		DC.W 13*16,3,00*4,01*4,02*4
		DC.W 14*16,3,09*4,11*4,10*4
		DC.W 13*16,3,04*4,08*4,09*4
		DC.W 14*16,3,01*4,03*4,08*4
		DC.W 13*16,3,03*4,07*4,11*4
		DC.W 14*16,3,00*4,05*4,07*4
		DC.W 13*16,3,05*4,06*4,10*4
		DC.W 14*16,3,02*4,04*4,06*4
		DC.W 15*16,4,00*4,02*4,06*4,05*4
		DC.W 09*16,4,04*4,02*4,01*4,08*4
		DC.W 11*16,4,00*4,07*4,03*4,01*4
		DC.W 09*16,4,07*4,05*4,10*4,11*4
		DC.W 15*16,4,08*4,03*4,11*4,09*4
		DC.W 11*16,4,06*4,04*4,09*4,10*4

asteriod	DC.W 0,0,0
		DC.W 12
		DC.L 0,0,$1000000
		DC.W 0,-100,200
		DC.W 200,0,100
		DC.W 100,-200,0
		DC.W 0,100,200
		DC.W 200,0,-100
		DC.W -100,-200,0
		DC.W 0,-100,-200
		DC.W -200,0,100
		DC.W 100,200,0
		DC.W 0,100,-200
		DC.W -200,0,-100
		DC.W -100,200,0
		DC.W 20
		DC.W 01*16,3,01*4,02*4,04*4
		DC.W 14*16,3,01*4,00*4,02*4
		DC.W 15*16,3,02*4,00*4,05*4
		DC.W 01*16,3,02*4,05*4,06*4
		DC.W 10*16,3,02*4,06*4,04*4
		DC.W 11*16,3,04*4,06*4,09*4
		DC.W 13*16,3,04*4,09*4,08*4
		DC.W 10*16,3,01*4,04*4,08*4
		DC.W 01*16,3,03*4,01*4,08*4
		DC.W 09*16,3,00*4,01*4,03*4
		DC.W 10*16,3,07*4,11*4,10*4
		DC.W 13*16,3,00*4,07*4,05*4
		DC.W 01*16,3,10*4,05*4,07*4
		DC.W 10*16,3,06*4,05*4,10*4
		DC.W 09*16,3,06*4,10*4,09*4
		DC.W 14*16,3,09*4,10*4,11*4
		DC.W 15*16,3,08*4,09*4,11*4
		DC.W 10*16,3,03*4,08*4,11*4
		DC.W 01*16,3,03*4,11*4,07*4
		DC.W 11*16,3,00*4,03*4,07*4

Ship		DC.W 0,0,0
		DC.W 7	
		DC.L 0,0,$1500000
		DC.W -200,0,0
		DC.W 0,50,0
		DC.W 200,0,0
		DC.W 50,-50,0
		DC.W 0,-100,0
		DC.W -50,-50,0
		DC.W 0,0,-300
		DC.W 10	
		DC.W 1*16,3,0*4,1*4,5*4
		DC.W 2*16,3,1*4,3*4,5*4
		DC.W 3*16,3,1*4,2*4,3*4
		DC.W 4*16,3,5*4,3*4,4*4
		DC.W 5*16,3,6*4,2*4,1*4
		DC.W 6*16,3,6*4,1*4,0*4
		DC.W 7*16,3,4*4,3*4,6*4
		DC.W 8*16,3,5*4,4*4,6*4
		DC.W 9*16,3,3*4,2*4,6*4
		DC.W 10*16,3,0*4,5*4,6*4
	
House		DC.W 0,0,0
		DC.W 10
		DC.L 0,0,$2400000
		DC.W -200,100,150
		DC.W 200,100,150
		DC.W 200,-80,150
		DC.W -200,-80,150
		DC.W -200,100,-150
		DC.W 200,100,-150
		DC.W 200,-80,-150
		DC.W -200,-80,-150
		DC.W -200,150,0
		DC.W 200,150,0
		DC.W 7
		DC.W 1*16,4,0*4,1*4,2*4,3*4
		DC.W 2*16,4,7*4,6*4,5*4,4*4
		DC.W 3*16,5,0*4,3*4,7*4,4*4,8*4
		DC.W 3*16,5,1*4,9*4,5*4,6*4,2*4
		DC.W 4*16,4,8*4,9*4,1*4,0*4
		DC.W 5*16,4,4*4,5*4,9*4,8*4
		DC.W 7*16,4,6*4,7*4,3*4,2*4

trig_tab	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
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

log_base	DC.L $68000
phy_base	DC.L $70000
		DC.L $78000

i		SET 0
tmul_160	REPT 200
		DC.W i
i		SET i+160
		ENDR
pal		DC.L $00000111
		DC.L $02220333
		DC.L $04440555
		DC.L $06660777
		DC.L $06660555
		DC.L $04440333
		DC.L $02220111
		DC.L $07770777

		SECTION BSS
old_mfp	DS.L 3
old_vbl	DS.L 1
vbl_timer	DS.W 1
col		DS.W 1
new_coords	DS.W 2000
p_space	DS.W 100      
trig_buf	DS.W 6
		DS.L 199
stack		DS.W 1
