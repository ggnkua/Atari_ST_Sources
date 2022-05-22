;-----------------------------------------------------------------------;		
; 3D Object Rotation routine V8.0							;
; by Martin Griffiths (C) SEPTEMBER 1989 to .....				;
; Updated/improved :-									;		
; Fully clipped (arghh! stolen from ST world)  		  - Jan 1990	;
; New ultra hline routine using lots of bloody tables   - March 1990	;
; More Accurate/faster translation and perspective rout - June 1990	;
; New gradient calc routine which only uses one muls!!! - June 1990	;
;-----------------------------------------------------------------------;		
;-----------------------------------------------------------------------;
; This version uses a backface AND treesort for Hidden face e.g         ;
; The faces are backfaced and then the remaining faces sorted by z.	;
;-----------------------------------------------------------------------;

		OPT O+,OW-

; Clip window boundaries

xmin		EQU 0
ymin		EQU 0
xmax		EQU 319
ymax		EQU 149

init		CLR.W -(SP)
		PEA -1.W
		MOVE.L (SP),-(SP)
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA stack,SP
		MOVE #$2700,SR

cls		MOVE.L log_base,A0
		MOVE #3999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		MOVEM.L pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
		BSR flush
		
Rotate		LEA mug(pc),A5
		ADDQ #8,(A5)
		AND #$3FF,(A5)
		ADDQ #5,2(A5)
		AND #$3FF,2(A5)
		ADDQ #6,4(A5)
		AND #$3FF,4(A5)
		BSR Show_object
		BSR sw_clr
		CMP.B #$39,$FFFFFC02.W
		BNE Rotate

		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		MOVE #$2300,SR
		BSR flush
		CLR -(SP)
		TRAP #1

flush		BTST.B #0,$fffffc00.w
		BEQ.S fldone
		MOVE.B $fffffc02.w,d0
		BRA.S flush
fldone	RTS

; Routine to translate,perspect and draw a solid 3d object.
; A5 points to shape data.D0-D7/A0-A6 smashed(everything!!).

Show_object	BSR Matrix_make		rotmat
		MOVE (A5)+,D7		no of verts
		LEA new_coords,A1		new x,y co-ords
		BSR Trans_verts		translate

; A0 -> no. of faces in shape data.
; Test each face and only insert faces which CAN be seen(backfacing).

Backface	LEA new_coords,A4		
		LEA averagezs,A1
		MOVE.W (A0)+,D5		no of faces
		SUBQ #1,D5
		CLR.L root			init tree
avfacelp	MOVEM 4(A0),D0/D6/D7	1st three vertice ptrs
		MOVEM (A4,D0),D1-D2	x1,y1
		MOVEM (A4,D6),D3-D4	x2,y2
		SUB D3,D1			(x1-x2)
		SUB D4,D2			(y1-y2)
		SUB (A4,D7),D3		x2-x3
		SUB 2(A4,D7),D4		y2-y3
		MULS D4,D1			(x1-x2)*(y2-y3)
		MULS D2,D3			(y1-y2)*(x2-x3)
		SUB.L	D3,D1
		Bmi notinsert
		MOVE.L A0,faceptr(a1)
		MOVE.L (A0)+,D1		COL\no of verts
		MOVE.W D1,D3
		ADDQ #6,A0
totalz	MOVE.W 4(A4,D0),D0
		ADD.W 4(A4,D6),D0
		ADD.W 4(A4,D7),D0		total of first three vertices
		SUBQ #4,D1
		BMI.S avy			was it a triangle?
		BEQ.S casequck4		or quadrilateral?
totalzlp	MOVE.W (A0)+,D2
		ADD.W 4(A4,D2),D0
		DBF D1,totalzlp
avy		EXT.L D0
		DIVS D3,D0			/ no of verts = average z
		BRA.S insert
casequck4	MOVE.W (A0)+,D2		quick case for quadrilateral
		ADD.W 4(A4,D2),D0
 		ASR #2,D0			/ 4 verts = average z quick!!

; Insert node into the binary tree
; d0 = distance away for this object
; a1 = pointer to object structure
; root = pointer to the root of the binary tree

insert	move.w d0,(a1)			;this objects depth
		moveq	#0,d1
		move.l d1,lptr(a1)
		move.l d1,rptr(a1)		;terminal node
		move.l root(pc),d1
		beq.s	.empty			;test for empty tree
.nextnode	move.l d1,a2
		cmp.w	(a2),d0
		bgt.s	.try_right
		move.l lptr(a2),d1		;empty left node?
		bne.s	.nextnode
		move.l a1,lptr(a2)
.inserted1	LEA obsize(a1),a1
		DBF D5,avfacelp
		BRA.S go
.empty	lea root(pc),a2
		move.l a1,(a2) 			;object is first entry
.inserted2	LEA obsize(a1),a1
		DBF D5,avfacelp
		BRA.S go
.try_right	move.l rptr(a2),d1		;empty right node?
		bne.s	.nextnode
		move.l a1,rptr(a2)
.inserted3	LEA obsize(a1),a1
		DBF D5,avfacelp
		BRA.S go
notinsert	MOVE.L (A0)+,D1			no of verts
		ADD D1,D1
		ADD D1,A0
		DBF D5,avfacelp
go		

;(fall through to sort)

; Treesort

		rsreset
depth		rs.w	1
faceptr	rs.l  1
lptr		rs.l	1
rptr		rs.l	1
obsize	rs.b	1

; Perform an inorder traversal on the binary
; tree constructed by the above procedure 'insert'
; root = pointer to the root of the binary tree

treesort	move.l root(pc),d0
goright	move.l d0,a1
		move.l a1,-(sp)		;save pointer to this node
		move.l rptr(a1),d0
		beq.s	noright
		bsr.s	goright		;recursive descent
		MOVE.L (SP),A1
noright	MOVE.L faceptr(a1),a0
		MOVE (a0)+,col
		MOVE (a0)+,d6
		BSR Draw_poly
		MOVE.L (sp)+,a1		;pointer to current
		MOVE.L lptr(a1),d0	;node
		BNE.S	goright
empty		RTS

root		dc.l	0

; Calculate a rotational matrix,
; from the angle data pointed by A5.
; D0-D4/A0-A3 smashed.

Matrix_make	LEA trig_buf,A1	
		LEA 12(A1),A0		cosine table
		LEA 512(A0),A2		sine   table
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

; Translate and perspect co-ords.
; A5 - x,y,z.l offsets for co-ords.
; followed by D7 co-ords to translate. 
; D0-D7/A0-A5 smashed.
; Returns A0 pointing to 'no of faces' in object data.

Trans_verts	MOVE.L (A5)+,daddx+2
		MOVE.L (A5)+,daddy+2
		MOVE.L (A5)+,daddz+2
		MOVE #160,A3		centre x
		MOVE #75,A4			centre y
		SUBQ #1,D7			verts-1
		LEA (A5),A0
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
daddx		ADD.L #0,D0
daddy		ADD.L #0,D1
daddz		ADD.L #0,D2

		ASR.L #8,D0
		ASR.L #8,D1
		ADD.L D2,D2
		SWAP D2
		DIVS D2,D0
		DIVS D2,D1
		ADD A3,D0			x scr centre
		ADD A4,D1			y scr centre
		MOVE D0,(A1)+		new x co-ord
		MOVE D1,(A1)+		new y co-ord
		MOVE D2,(A1)+		new z co-ord	
		DBF D7,trans_lp
		RTS

;-----------------------------------------------------------------------;
;----------------------------- Polyfill --------------------------------;
; A0 points to D6 coords,taken from the translated co-ords "new_coords"	;
; Polygon is clipped if necessary. Polygon drawn in colour "col".		;
; Polyfill coded with self-modifying colour routines for extra speed.	;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

Draw_poly	LEA new_coords(PC),A5

; First get co-ord from offset list and check if it is outside the
; clipping area.If all vertices are inside window then no clipping
; is required - quicker for majority of poly's (which are inside window).

Test_Clip	LEA p_space(PC),A2
		MOVE.L A2,A1
		MOVEQ #xmin,D0
		MOVEQ #ymin,D1
		MOVE #xmax,D2
		MOVE #ymax,D3
		MOVE D6,D7
		SUBQ #1,D6
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
		DBGT D6,dup_lp1
		BGT needs_clip
		MOVE.L A1,A0
		MOVE D7,D6
				
Polyfill	MOVE D6,D4
		ADD D4,D4
		ADD D4,D4
		MOVE.L A0,A1
		ADDA.W D4,A1
		MOVE.L A1,A2
		ADDA.W D4,A2
Init_coords	SUBQ #2,D6
		MOVE.L (A0)+,D7
		MOVE D7,D2
		MOVE.L A1,A4
		MOVE.L D7,(A1)+
		MOVE.L D7,(A2)+
coord_lp	MOVE.L (A0)+,D3
		CMP D2,D3
		BGE.S not_top
		MOVE D3,D2
		MOVE.L A1,A4
not_top	CMP D3,D7
		BGE.S not_bot
		MOVE D3,D7	
not_bot	MOVE.L D3,(A1)+
		MOVE.L D3,(A2)+
		DBF D6,coord_lp
		SUB D2,D7			;d2 - lowest y  d7 - greatest y
		MOVE.L A4,A5
		MOVE D2,-(SP)

CALCS		MOVE D7,-(SP)
		MOVEQ #0,D5
		LEA grad_table+400(PC),A0
; Calc x's down left side of poly
Do_left	LEA LEFTJMP(PC),A6
		LEA x1s(PC),A2
Left_lp 	SUBQ #4,A4
		MOVEM.W (A4),D1-D4
		SUB D4,D2
		SUB D3,D1
		MOVE.L A2,A3
		ADD D4,D4
		ADD D4,A3
		MOVE D2,D6
		ADD D2,D2
		MULS (A0,D2),D1
		ADD.L D1,D1
		SWAP D1
		ADD D6,D2
		ADD D2,D2			dy*6(quick)
		NEG D2
		JMP (A6,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADD.L D1,D3
		ADDX D5,D3
		ENDR
LEFTJMP	MOVE.W D3,(A3)+
		SUB D6,D7
		BGT Left_lp
		MOVE #-1,(A3)+
; Calc x's down right side of poly
Do_right	MOVE (SP)+,D7
		LEA RIGHTJMP(PC),A6
		LEA x2s(PC),A2
Right_lp	MOVEM (A5),D1-D4
		ADDQ #4,A5
		SUB D2,D4
		SUB D1,D3
		MOVE.L A2,A3
		ADD D2,D2
		ADD D2,A3
		MOVE D4,D6
		ADD D4,D4
		MULS (A0,D4),D3
		ADD.L D3,D3
		SWAP D3
		ADD D6,D4
		ADD D4,D4			dy*6(quick)
		NEG D4
		JMP (A6,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADD.L D3,D1
		ADDX D5,D1
		ENDR
RIGHTJMP	MOVE.W D1,(A3)+
		SUB D6,D7
		BGT Right_lp

modify_col	MOVE (SP)+,D2
		LEA col(PC),A4
		ADD (A4)+,A4
		MOVEM.L (A4),D1/D5/A4/A5
		LEA f_chunk(PC),A2
		MOVEM.L D1/D5,(A2)
		MOVEM.L D1/D5,e_chunk-f_chunk(A2)
		MOVEM.L D1/D5,chunk1-f_chunk(A2)
get_line	LEA log_base(PC),A2
		MOVE.L (A2),A6
		ADD D2,D2
		ADD 12(A2,D2),A6
		LEA x1s(PC),a1
		ADD D2,A1
		LEA x2s(PC),a2
		ADD D2,A2
		LEA startvc(PC),A3
		MOVEQ #15,D3
		MOVE (A1)+,D0
polyfill_lp	MOVE (A2)+,D1
		SUB D0,D1			dx
		MOVE D3,D2			(15 AND X1)
		AND D0,D2			
		ADD D2,D1			add to remaining pixels 
		SUB D0,D2
		ASR #1,D2
		MOVE.L A6,A0		get scr base
		SUB.W D2,A0			sub -ve line offset - and - =+!!!!
		ADD D0,D0			 
		MOVE (A3,D0),D0		get mask and line offset
		CMP D3,D1			is hline over one chunk?
		BLE one_case		yes then goto special case
		MOVE D0,D2			otherwise 
		NOT D2			d0 = data d2 = mask
f_chunk	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+			mask to screen
		OR D0,(A0)+
		ADD D1,D1
		ADD D1,D1			(remaining pixels)*4
		MOVE.L ch_vect(PC,D1),D0 get jump offset and end mask
		JMP miss_main(PC,D0.W)	jump backwards thru solid colour routine
		MOVE.L A4,(A0)+		write one chunk of solid
		MOVE.L A5,(A0)+		colour data(4 planes=2 longs!)
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
miss_main	SWAP D0			top word has mask
		MOVE D0,D2			
		NOT D2			d0 = data d2 = mask	
e_chunk	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+			mask end chunk
		OR D0,(A0)+
next_line	LEA 160(A6),A6		next screen line
		MOVE (A1)+,D0
		BPL polyfill_lp
poly_done1	RTS				finished!

; End masks and solid colour jump offsets.
		
i		SET 4
ch_vect	REPT 20
		DC.W %1000000000000000,i
		DC.W %1100000000000000,i
		DC.W %1110000000000000,i
		DC.W %1111000000000000,i
		DC.W %1111100000000000,i
		DC.W %1111110000000000,i
		DC.W %1111111000000000,i
		DC.W %1111111100000000,i
		DC.W %1111111110000000,i
		DC.W %1111111111000000,i
		DC.W %1111111111100000,i
		DC.W %1111111111110000,i
		DC.W %1111111111111000,i
		DC.W %1111111111111100,i
		DC.W %1111111111111110,i
		DC.W %1111111111111111,i
i		SET i-4
		ENDR

; Hline over one chunk case

one_case	ADD D1,D1			remaining pixels(0-15)
		AND e_masks(PC,D1.W),D0	combine end mask with start mask
		MOVE D0,D2			
		NOT D2			d0 = data d2 = mask
chunk1	OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		OR D0,(A0)+
		LEA 160(A6),A6		next screen line
		MOVE (A1)+,D0
		BPL polyfill_lp
		RTS
		DS.L 10
e_masks	DC.W %1000000000000000
		DC.W %1100000000000000
		DC.W %1110000000000000
		DC.W %1111000000000000
		DC.W %1111100000000000
		DC.W %1111110000000000
		DC.W %1111111000000000
		DC.W %1111111100000000
		DC.W %1111111110000000
		DC.W %1111111111000000
		DC.W %1111111111100000
		DC.W %1111111111110000
		DC.W %1111111111111000
		DC.W %1111111111111100
		DC.W %1111111111111110
		DC.W %1111111111111111

; Start masks and screen line offsets

startvc	REPT 20
		DC.W $FFFF,$7FFF,$3FFF,$1FFF
		DC.W $0FFF,$07FF,$03FF,$01FF
		DC.W $00FF,$007F,$003F,$001F
		DC.W $000F,$0007,$0003,$0001
		ENDR

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

col		DS.W 1
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
x1s		DS.W 210
x2s		DS.W 210

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
needs_clip	DBF D6,dup_lp2	
		MOVE.L A1,A0

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
		BRA Polyfill

***************************************************************************

; Swap screens and clear screens

sw_clr  	LEA log_base(PC),A0
		MOVEM.L (A0)+,D5-D7
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
		REPT 428
		MOVEM.L D0-D7/A1-A6,-(A0)
		ENDR
		MOVEM.L D0-D7,-(A0)
		RTS

* My little VBL!

my_vbl	ADDQ #1,vbl_timer
		RTE

; Shape data

Grid		DC.W 0,0,0
		DC.W 49
		DC.L 0,0,$1B00000
		DC.W -600,600,0
		DC.W -400,600,0
		DC.W -200,600,0
		DC.W 0,600,0
		DC.W 200,600,0
		DC.W 400,600,0
		DC.W 600,600,0
		DC.W -600,400,0
		DC.W -400,400,0
		DC.W -200,400,0
		DC.W 0,400,0
		DC.W 200,400,0
		DC.W 400,400,0
		DC.W 600,400,0
		DC.W -600,200,0
		DC.W -400,200,0
		DC.W -200,200,0
		DC.W 0,200,0
		DC.W 200,200,0
		DC.W 400,200,0
		DC.W 600,200,0
		DC.W -600,0,0
		DC.W -400,0,0
		DC.W -200,0,0
		DC.W 0,0,0
		DC.W 200,0,0
		DC.W 400,0,0
		DC.W 600,0,0
		DC.W -600,-200,0
		DC.W -400,-200,0
		DC.W -200,-200,0
		DC.W 0,-200,0
		DC.W 200,-200,0
		DC.W 400,-200,0
		DC.W 600,-200,0
		DC.W -600,-400,0
		DC.W -400,-400,0
		DC.W -200,-400,0
		DC.W 0,-400,0
		DC.W 200,-400,0
		DC.W 400,-400,0
		DC.W 600,-400,0
		DC.W -600,-600,0
		DC.W -400,-600,0
		DC.W -200,-600,0
		DC.W 0,-600,0
		DC.W 200,-600,0
		DC.W 400,-600,0
		DC.W 600,-600,0
		DC.W 72
		DC.W 1*16,4,00*6,01*6,08*6,07*6
		DC.W 3*16,4,01*6,02*6,09*6,08*6
		DC.W 1*16,4,02*6,03*6,10*6,09*6
		DC.W 3*16,4,03*6,04*6,11*6,10*6
		DC.W 1*16,4,04*6,05*6,12*6,11*6
		DC.W 3*16,4,05*6,06*6,13*6,12*6
		DC.W 3*16,4,07*6,08*6,15*6,14*6
		DC.W 1*16,4,08*6,09*6,16*6,15*6
		DC.W 3*16,4,09*6,10*6,17*6,16*6
		DC.W 1*16,4,10*6,11*6,18*6,17*6
		DC.W 3*16,4,11*6,12*6,19*6,18*6
		DC.W 1*16,4,12*6,13*6,20*6,19*6
		DC.W 1*16,4,14*6,15*6,22*6,21*6
		DC.W 3*16,4,15*6,16*6,23*6,22*6
		DC.W 1*16,4,16*6,17*6,24*6,23*6
		DC.W 3*16,4,17*6,18*6,25*6,24*6
		DC.W 1*16,4,18*6,19*6,26*6,25*6
		DC.W 3*16,4,19*6,20*6,27*6,26*6
		DC.W 3*16,4,21*6,22*6,29*6,28*6
		DC.W 1*16,4,22*6,23*6,30*6,29*6
		DC.W 3*16,4,23*6,24*6,31*6,30*6
		DC.W 1*16,4,24*6,25*6,32*6,31*6
		DC.W 3*16,4,25*6,26*6,33*6,32*6
		DC.W 1*16,4,26*6,27*6,34*6,33*6
		DC.W 1*16,4,28*6,29*6,36*6,35*6
		DC.W 3*16,4,29*6,30*6,37*6,36*6
		DC.W 1*16,4,30*6,31*6,38*6,37*6
		DC.W 3*16,4,31*6,32*6,39*6,38*6
		DC.W 1*16,4,32*6,33*6,40*6,39*6
		DC.W 3*16,4,33*6,34*6,41*6,40*6
		DC.W 3*16,4,35*6,36*6,43*6,42*6
		DC.W 1*16,4,36*6,37*6,44*6,43*6
		DC.W 3*16,4,37*6,38*6,45*6,44*6
		DC.W 1*16,4,38*6,39*6,46*6,45*6
		DC.W 3*16,4,39*6,40*6,47*6,46*6
		DC.W 1*16,4,40*6,41*6,48*6,47*6

		DC.W 5*16,4,07*6,08*6,01*6,00*6
		DC.W 7*16,4,08*6,09*6,02*6,01*6
		DC.W 5*16,4,09*6,10*6,03*6,02*6
		DC.W 7*16,4,10*6,11*6,04*6,03*6
		DC.W 5*16,4,11*6,12*6,05*6,04*6
		DC.W 7*16,4,12*6,13*6,06*6,05*6
		DC.W 7*16,4,14*6,15*6,08*6,07*6
		DC.W 5*16,4,15*6,16*6,09*6,08*6
		DC.W 7*16,4,16*6,17*6,10*6,09*6
		DC.W 5*16,4,17*6,18*6,11*6,10*6
		DC.W 7*16,4,18*6,19*6,12*6,11*6
		DC.W 5*16,4,19*6,20*6,13*6,12*6
		DC.W 5*16,4,21*6,22*6,15*6,14*6
		DC.W 7*16,4,22*6,23*6,16*6,15*6
		DC.W 5*16,4,23*6,24*6,17*6,16*6
		DC.W 7*16,4,24*6,25*6,18*6,17*6
		DC.W 5*16,4,25*6,26*6,19*6,18*6
		DC.W 7*16,4,26*6,27*6,20*6,19*6
		DC.W 7*16,4,28*6,29*6,22*6,21*6
		DC.W 5*16,4,29*6,30*6,23*6,22*6
		DC.W 7*16,4,30*6,31*6,24*6,23*6
		DC.W 5*16,4,31*6,32*6,25*6,24*6
		DC.W 7*16,4,32*6,33*6,26*6,25*6
		DC.W 5*16,4,33*6,34*6,27*6,26*6
		DC.W 5*16,4,35*6,36*6,29*6,28*6
		DC.W 7*16,4,36*6,37*6,30*6,29*6
		DC.W 5*16,4,37*6,38*6,31*6,30*6
		DC.W 7*16,4,38*6,39*6,32*6,31*6
		DC.W 5*16,4,39*6,40*6,33*6,32*6
		DC.W 7*16,4,40*6,41*6,34*6,33*6
		DC.W 7*16,4,42*6,43*6,36*6,35*6
		DC.W 5*16,4,43*6,44*6,37*6,36*6
		DC.W 7*16,4,44*6,45*6,38*6,37*6
		DC.W 5*16,4,45*6,46*6,39*6,38*6
		DC.W 7*16,4,46*6,47*6,40*6,39*6
		DC.W 5*16,4,47*6,48*6,41*6,40*6

Grid1		DC.W 0,0,0
		DC.W 49
		DC.L 0,0,$1B00000
		DC.W 192,600,0
		DC.W 96,600,166
		DC.W -96,600,166
		DC.W -192,600,0
		DC.W -96,600,-166
		DC.W 96,600,-166
		DC.W 192,600,0
		DC.W 192,400,0
		DC.W 96,400,166
		DC.W -96,400,166
		DC.W -192,400,0
		DC.W -96,400,-166
		DC.W 96,400,-166
		DC.W 192,400,0
		DC.W 192,200,0
		DC.W 96,200,166
		DC.W -96,200,166
		DC.W -192,200,0
		DC.W -96,200,-166
		DC.W 96,200,-166
		DC.W 192,200,0
		DC.W 192,0,0
		DC.W 96,0,166
		DC.W -96,0,166
		DC.W -192,0,0
		DC.W -96,0,-166
		DC.W 96,0,-166
		DC.W 192,0,0
		DC.W 192,-200,0
		DC.W 96,-200,166
		DC.W -96,-200,166
		DC.W -192,-200,0
		DC.W -96,-200,-166
		DC.W 96,-200,-166
		DC.W 192,-200,0
		DC.W 192,-400,0
		DC.W 96,-400,166
		DC.W -96,-400,166
		DC.W -192,-400,0
		DC.W -96,-400,-166
		DC.W 96,-400,-166
		DC.W 192,-400,0
		DC.W 192,-600,0
		DC.W 96,-600,166
		DC.W -96,-600,166
		DC.W -192,-600,0
		DC.W -96,-600,-166
		DC.W 96,-600,-166
		DC.W 192,-600,0
		DC.W 72
		DC.W 1*16,4,00*6,01*6,08*6,07*6
		DC.W 3*16,4,01*6,02*6,09*6,08*6
		DC.W 1*16,4,02*6,03*6,10*6,09*6
		DC.W 3*16,4,03*6,04*6,11*6,10*6
		DC.W 1*16,4,04*6,05*6,12*6,11*6
		DC.W 3*16,4,05*6,06*6,13*6,12*6
		DC.W 3*16,4,07*6,08*6,15*6,14*6
		DC.W 1*16,4,08*6,09*6,16*6,15*6
		DC.W 3*16,4,09*6,10*6,17*6,16*6
		DC.W 1*16,4,10*6,11*6,18*6,17*6
		DC.W 3*16,4,11*6,12*6,19*6,18*6
		DC.W 1*16,4,12*6,13*6,20*6,19*6
		DC.W 1*16,4,14*6,15*6,22*6,21*6
		DC.W 3*16,4,15*6,16*6,23*6,22*6
		DC.W 1*16,4,16*6,17*6,24*6,23*6
		DC.W 3*16,4,17*6,18*6,25*6,24*6
		DC.W 1*16,4,18*6,19*6,26*6,25*6
		DC.W 3*16,4,19*6,20*6,27*6,26*6
		DC.W 3*16,4,21*6,22*6,29*6,28*6
		DC.W 1*16,4,22*6,23*6,30*6,29*6
		DC.W 3*16,4,23*6,24*6,31*6,30*6
		DC.W 1*16,4,24*6,25*6,32*6,31*6
		DC.W 3*16,4,25*6,26*6,33*6,32*6
		DC.W 1*16,4,26*6,27*6,34*6,33*6
		DC.W 1*16,4,28*6,29*6,36*6,35*6
		DC.W 3*16,4,29*6,30*6,37*6,36*6
		DC.W 1*16,4,30*6,31*6,38*6,37*6
		DC.W 3*16,4,31*6,32*6,39*6,38*6
		DC.W 1*16,4,32*6,33*6,40*6,39*6
		DC.W 3*16,4,33*6,34*6,41*6,40*6
		DC.W 3*16,4,35*6,36*6,43*6,42*6
		DC.W 1*16,4,36*6,37*6,44*6,43*6
		DC.W 3*16,4,37*6,38*6,45*6,44*6
		DC.W 1*16,4,38*6,39*6,46*6,45*6
		DC.W 3*16,4,39*6,40*6,47*6,46*6
		DC.W 1*16,4,40*6,41*6,48*6,47*6

		DC.W 5*16,4,07*6,08*6,01*6,00*6
		DC.W 7*16,4,08*6,09*6,02*6,01*6
		DC.W 5*16,4,09*6,10*6,03*6,02*6
		DC.W 7*16,4,10*6,11*6,04*6,03*6
		DC.W 5*16,4,11*6,12*6,05*6,04*6
		DC.W 7*16,4,12*6,13*6,06*6,05*6
		DC.W 7*16,4,14*6,15*6,08*6,07*6
		DC.W 5*16,4,15*6,16*6,09*6,08*6
		DC.W 7*16,4,16*6,17*6,10*6,09*6
		DC.W 5*16,4,17*6,18*6,11*6,10*6
		DC.W 7*16,4,18*6,19*6,12*6,11*6
		DC.W 5*16,4,19*6,20*6,13*6,12*6
		DC.W 5*16,4,21*6,22*6,15*6,14*6
		DC.W 7*16,4,22*6,23*6,16*6,15*6
		DC.W 5*16,4,23*6,24*6,17*6,16*6
		DC.W 7*16,4,24*6,25*6,18*6,17*6
		DC.W 5*16,4,25*6,26*6,19*6,18*6
		DC.W 7*16,4,26*6,27*6,20*6,19*6
		DC.W 7*16,4,28*6,29*6,22*6,21*6
		DC.W 5*16,4,29*6,30*6,23*6,22*6
		DC.W 7*16,4,30*6,31*6,24*6,23*6
		DC.W 5*16,4,31*6,32*6,25*6,24*6
		DC.W 7*16,4,32*6,33*6,26*6,25*6
		DC.W 5*16,4,33*6,34*6,27*6,26*6
		DC.W 5*16,4,35*6,36*6,29*6,28*6
		DC.W 7*16,4,36*6,37*6,30*6,29*6
		DC.W 5*16,4,37*6,38*6,31*6,30*6
		DC.W 7*16,4,38*6,39*6,32*6,31*6
		DC.W 5*16,4,39*6,40*6,33*6,32*6
		DC.W 7*16,4,40*6,41*6,34*6,33*6
		DC.W 7*16,4,42*6,43*6,36*6,35*6
		DC.W 5*16,4,43*6,44*6,37*6,36*6
		DC.W 7*16,4,44*6,45*6,38*6,37*6
		DC.W 5*16,4,45*6,46*6,39*6,38*6
		DC.W 7*16,4,46*6,47*6,40*6,39*6
		DC.W 5*16,4,47*6,48*6,41*6,40*6

Ship		DC.W 0,0,0
		DC.W 7	
		DC.L 0,0,$7300000
		DC.W -1600,0,0
		DC.W 0,400,0
		DC.W 1600,0,0
		DC.W 400,-400,0
		DC.W 0,-800,0
		DC.W -400,-400,0
		DC.W 0,0,-2400
		DC.W 10	
		DC.W 2*16,3,0*6,1*6,5*6
		DC.W 1*16,3,1*6,3*6,5*6
		DC.W 2*16,3,1*6,2*6,3*6
		DC.W 7*16,3,5*6,3*6,4*6
		DC.W 3*16,3,6*6,2*6,1*6
		DC.W 5*16,3,6*6,1*6,0*6
		DC.W 5*16,3,4*6,3*6,6*6
		DC.W 6*16,3,5*6,4*6,6*6
		DC.W 4*16,3,3*6,2*6,6*6
		DC.W 4*16,3,0*6,5*6,6*6

mug		DC.W 0,0,0
		DC.W 74	
		DC.L 0,0,$8300000
	dc.w	$0000,$0000,$F888
	dc.w	$0456,$0128,$F888
	dc.w	$0456,$0128,$0878
	dc.w	$05C8,$018B,$0878
	dc.w	$05C8,$018B,$0778
	dc.w	$054C,$016A,$06F8
	dc.w	$054C,$016A,$F788
	dc.w	$0000,$0000,$F788
	dc.w	$032B,$032C,$F888
	dc.w	$032B,$032C,$0878
	dc.w	$043B,$043C,$0878
	dc.w	$043B,$043C,$0778
	dc.w	$03E0,$03E0,$06F8
	dc.w	$03E0,$03E0,$F788
	dc.w	$0128,$0456,$F888
	dc.w	$0128,$0456,$0878
	dc.w	$018B,$05C8,$0878
	dc.w	$018B,$05C8,$0778
	dc.w	$016A,$054C,$06F8
	dc.w	$016A,$054C,$F788
	dc.w	$FED8,$0456,$F888
	dc.w	$FED8,$0456,$0878
	dc.w	$FE75,$05C8,$0878
	dc.w	$FE75,$05C8,$0778
	dc.w	$FE96,$054C,$06F8
	dc.w	$FE96,$054C,$F788
	dc.w	$FCD5,$032C,$F888
	dc.w	$FCD5,$032C,$0878
	dc.w	$FBC5,$043B,$0878
	dc.w	$FBC5,$043B,$0778
	dc.w	$FC21,$03E0,$06F8
	dc.w	$FC21,$03E0,$F788
	dc.w	$FBAB,$0128,$F888
	dc.w	$FBAB,$0128,$0878
	dc.w	$FA38,$018B,$0878
	dc.w	$FA38,$018B,$0778
	dc.w	$FAB4,$016A,$06F8
	dc.w	$FAB4,$016A,$F788
	dc.w	$FBAA,$FED8,$F888
	dc.w	$FBAA,$FED8,$0878
	dc.w	$FA38,$FE75,$0878
	dc.w	$FA38,$FE75,$0778
	dc.w	$FAB4,$FE96,$06F8
	dc.w	$FAB4,$FE96,$F788
	dc.w	$FCD5,$FCD5,$F888
	dc.w	$FCD5,$FCD5,$0878
	dc.w	$FBC5,$FBC5,$0878
	dc.w	$FBC5,$FBC5,$0778
	dc.w	$FC20,$FC21,$06F8
	dc.w	$FC20,$FC21,$F788
	dc.w	$FED8,$FBAB,$F888
	dc.w	$FED8,$FBAB,$0878
	dc.w	$FE75,$FA38,$0878
	dc.w	$FE75,$FA38,$0778
	dc.w	$FE96,$FAB4,$06F8
	dc.w	$FE96,$FAB4,$F788
	dc.w	$0128,$FBAA,$F888
	dc.w	$0128,$FBAA,$0878
	dc.w	$018B,$FA38,$0878
	dc.w	$018B,$FA38,$0778
	dc.w	$016A,$FAB4,$06F8
	dc.w	$016A,$FAB4,$F788
	dc.w	$032B,$FCD5,$F888
	dc.w	$032B,$FCD5,$0878
	dc.w	$043B,$FBC5,$0878
	dc.w	$043B,$FBC5,$0778
	dc.w	$03DF,$FC20,$06F8
	dc.w	$03DF,$FC20,$F788
	dc.w	$0455,$FED8,$F888
	dc.w	$0455,$FED8,$0878
	dc.w	$05C8,$FE75,$0878
	dc.w	$05C8,$FE75,$0778
	dc.w	$054C,$FE96,$06F8
	dc.w	$054C,$FE96,$F788
	dc.w 84
	dc.w 5*16,2+1,8*6,1*6,0*6
	dc.w 7*16,3+1,9*6,2*6,1*6,8*6
	dc.w 9*16,3+1,10*6,3*6,2*6,9*6
	dc.w 4*16,3+1,11*6,4*6,3*6,10*6
	dc.w 9*16,3+1,12*6,5*6,4*6,11*6
	dc.w 9*16,3+1,13*6,6*6,5*6,12*6
	dc.w 8*16,2+1,13*6,7*6,6*6
	dc.w 7*16,2+1,14*6,8*6,0*6
	dc.w 1*16,3+1,15*6,9*6,8*6,14*6
	dc.w 5*16,3+1,16*6,10*6,9*6,15*6
	dc.w 9*16,3+1,17*6,11*6,10*6,16*6
	dc.w 5*16,3+1,18*6,12*6,11*6,17*6
	dc.w 3*16,3+1,19*6,13*6,12*6,18*6
	dc.w 3*16,2+1,19*6,7*6,13*6
	dc.w 5*16,2+1,20*6,14*6,0*6
	dc.w 2*16,3+1,21*6,15*6,14*6,20*6
	dc.w 3*16,3+1,22*6,16*6,15*6,21*6
	dc.w 7*16,3+1,23*6,17*6,16*6,22*6
	dc.w 8*16,3+1,24*6,18*6,17*6,23*6
	dc.w 7*16,3+1,25*6,19*6,18*6,24*6
	dc.w 5*16,2+1,25*6,7*6,19*6
	dc.w 1*16,2+1,26*6,20*6,0*6
	dc.w 3*16,3+1,27*6,21*6,20*6,26*6
	dc.w 9*16,3+1,28*6,22*6,21*6,27*6
	dc.w 5*16,3+1,29*6,23*6,22*6,28*6
	dc.w 7*16,3+1,30*6,24*6,23*6,29*6
	dc.w 8*16,3+1,31*6,25*6,24*6,30*6
	dc.w 7*16,2+1,31*6,7*6,25*6
	dc.w 8*16,2+1,32*6,26*6,0*6
	dc.w 9*16,3+1,33*6,27*6,26*6,32*6
	dc.w 9*16,3+1,34*6,28*6,27*6,33*6
	dc.w 2*16,3+1,35*6,29*6,28*6,34*6
	dc.w 9*16,3+1,36*6,30*6,29*6,35*6
	dc.w 8*16,3+1,37*6,31*6,30*6,36*6
	dc.w 7*16,2+1,37*6,7*6,31*6
	dc.w 4*16,2+1,38*6,32*6,0*6
	dc.w 4*16,3+1,39*6,33*6,32*6,38*6
	dc.w 7*16,3+1,40*6,34*6,33*6,39*6
	dc.w 2*16,3+1,41*6,35*6,34*6,40*6
	dc.w 4*16,3+1,42*6,36*6,35*6,41*6
	dc.w 7*16,3+1,43*6,37*6,36*6,42*6
	dc.w 4*16,2+1,43*6,7*6,37*6
	dc.w 7*16,2+1,44*6,38*6,0*6
	dc.w 5*16,3+1,45*6,39*6,38*6,44*6
	dc.w 6*16,3+1,46*6,40*6,39*6,45*6
	dc.w 2*16,3+1,47*6,41*6,40*6,46*6
	dc.w 5*16,3+1,48*6,42*6,41*6,47*6
	dc.w 2*16,3+1,49*6,43*6,42*6,48*6
	dc.w 6*16,2+1,49*6,7*6,43*6
	dc.w 9*16,2+1,50*6,44*6,0*6
	dc.w 1*16,3+1,51*6,45*6,44*6,50*6
	dc.w 8*16,3+1,52*6,46*6,45*6,51*6
	dc.w 2*16,3+1,53*6,47*6,46*6,52*6
	dc.w 4*16,3+1,54*6,48*6,47*6,53*6
	dc.w 3*16,3+1,55*6,49*6,48*6,54*6
	dc.w 8*16,2+1,55*6,7*6,49*6
	dc.w 6*16,2+1,56*6,50*6,0*6
	dc.w 5*16,3+1,57*6,51*6,50*6,56*6
	dc.w 5*16,3+1,58*6,52*6,51*6,57*6
	dc.w 3*16,3+1,59*6,53*6,52*6,58*6
	dc.w 1*16,3+1,60*6,54*6,53*6,59*6
	dc.w 3*16,3+1,61*6,55*6,54*6,60*6
	dc.w 7*16,2+1,61*6,7*6,55*6
	dc.w 3*16,2+1,62*6,56*6,0*6
	dc.w 3*16,3+1,63*6,57*6,56*6,62*6
	dc.w 9*16,3+1,64*6,58*6,57*6,63*6
	dc.w 5*16,3+1,65*6,59*6,58*6,64*6
	dc.w 7*16,3+1,66*6,60*6,59*6,65*6
	dc.w 2*16,3+1,67*6,61*6,60*6,66*6
	dc.w 1*16,2+1,67*6,7*6,61*6
	dc.w 7*16,2+1,68*6,62*6,0*6
	dc.w 4*16,3+1,69*6,63*6,62*6,68*6
	dc.w 3*16,3+1,70*6,64*6,63*6,69*6
	dc.w 6*16,3+1,71*6,65*6,64*6,70*6
	dc.w 3*16,3+1,72*6,66*6,65*6,71*6
	dc.w 1*16,3+1,73*6,67*6,66*6,72*6
	dc.w 2*16,2+1,73*6,7*6,67*6
	dc.w 3*16,2+1,1*6,68*6,0*6
	dc.w 6*16,3+1,2*6,69*6,68*6,1*6
	dc.w 2*16,3+1,3*6,70*6,69*6,2*6
	dc.w 5*16,3+1,4*6,71*6,70*6,3*6
	dc.w 2*16,3+1,5*6,72*6,71*6,4*6
	dc.w 8*16,3+1,6*6,73*6,72*6,5*6
	dc.w 4*16,2+1,6*6,7*6,73*6

trig_buf	DS.W 6
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

log_base	DC.L $2c8000
phy_base	DC.L $2d0000
		DC.L $2d8000

i		SET 0
tmul_160	REPT 200
		DC.W i
i		SET i+160
		ENDR
pal		DC.L $00000111
		DC.L $02220333
		DC.L $04440555
		DC.L $06660777
		DC.L $01110222
		DC.L $03330444
		DC.L $05550666
		DC.L $07750777

		SECTION BSS
old_mfp	DS.L 3
vbl_timer	DS.W 1

new_coords	DS.W 2000
p_space		DS.W 100      
averagezs	DS.L 2400				average zs' storage place

		DS.L 399
stack		DS.W 1



