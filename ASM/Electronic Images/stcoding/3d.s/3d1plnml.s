;-----------------------------------------------------------------------;		
; 3D Object Rotation routine V8.0							;
; by Martin Griffiths 									;
; Updated/improved :-									;		
; More Accurate/faster translation and perspective rout - June 1990	;
; New gradient calc routine which only uses one muls!!! - June 1990	;
; Now uses 'Russ Clip' !!! for faster polygon clipping  - Feb 1991      ;
;-----------------------------------------------------------------------;		
; This version is not sorted and handles convex objects only.
; The reason the cube isn't any bigger is because if it hits the edges
; of the screen, the clipper takes 5% of a frame to clip two polys!!
; Also this is best suited for demos since it uses muls perspective!
;

timing	EQU 0
dist		EQU 256		; viewpoint distance
		OPT O+,OW-

init		CLR.W -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA stack,SP
		MOVE #$2700,SR
		BSR Init3scrns
		BSR Initdraw
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
		
Rotate		LEA House2,A5
		ADD #10,(A5)
		ADD #8,2(A5)
		;ADD #6,4(A5)
		BSR Show_object
		BSR swap_clr
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

; Initialise the drawing rout

Initdraw	MOVE #198,D7
		LEA enddrawone(PC),A1
.lp2		LEA drawonehline(PC),A0
		MOVE.W #(hlinesize/2)-1,D0
.lp		MOVE.W (A0)+,(A1)+
		DBF D0,.lp
		DBF D7,.lp2
		MOVE #198,D7
hashinit	LEA henddrawone,A1
.lp2		LEA hdrawonehline,A0
		MOVE.W #(hhlinesize/2)-1,D0
.lp		MOVE.W (A0)+,(A1)+
		DBF D0,.lp
		DBF D7,.lp2
		LEA multable,A0
		MOVE #dist+1,D0
		MOVE #32768-dist-2,D1
.lp1		MOVE.L #32768*dist,D2
		DIVS D0,D2
		MOVE.W D2,(A0)+
		ADDQ #1,D0
		DBF D1,.lp1
		RTS

; Initialise the 3 screens.

Init3scrns	LEA log_base(PC),A0
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A0)+
		ADD.L #32000,D0
		MOVE.L D0,(A0)+
		ADD.L #32000,D0
		MOVE.L D0,(A0)+
		MOVE.L log_base(PC),A0
		MOVE #5999,D0
		MOVEQ #0,D1
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		RTS

; Swap screens and clear screens

swap_clr  	LEA log_base(PC),A0
		MOVEM.L (A0)+,D5-D7
		MOVE.L D6,-(A0)
		MOVE.L D5,-(A0)
		MOVE.L D7,-(A0)
		LSR #8,D5
		MOVE.L D5,$FFFF8200.W
		IFNE timing
		MOVE #$700,$FFFF8240.W
		ENDC
		LEA vbl_timer,A0
		MOVE (A0),D0
wait_vbl	CMP (A0),D0
		BEQ.S wait_vbl
		IFNE timing
		MOVE #$000,$FFFF8240.W
		ENDC
clearscreen	MOVE.L D7,A0
		LEA 32000-16(A0),A0
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
		REPT 100
		MOVEM.L D0-D7/A1-A3,-(A0)
		MOVEM.L D0-D7/A1-A3,-(A0)
		MOVEM.L D0-D7/A1-A2,-(A0)
		LEA -32(A0),A0
		MOVEM.L D0-D7/A1-A3,-(A0)
		MOVEM.L D0-D7/A1-A3,-(A0)
		MOVEM.L D0-D7/A1-A2,-(A0)
		LEA -32(A0),A0
		ENDR
		RTS

; My little VBL!

my_vbl	ADDQ #1,vbl_timer
		RTE

vbl_timer	DS.W 1
old_mfp	DS.L 3
log_base	DC.L 0
phy_base	DC.L 0
		DC.L 0

i		SET 0
tmul_160	REPT 200
		DC.W i
i		SET i+160
		ENDR
pal		DC.L $00000111
		DC.L $02220222
		DC.L $03330333
		DC.L $03330333
		DC.L $04440444
		DC.L $04440444
		DC.L $04440444
		DC.L $04440444

; Routine to translate,perspect and draw a solid 3d object.
; A5 points to shape data.D0-D7/A0-A6 smashed(everything!!).

Show_object	BSR Matrix_make		rotmat
		MOVE (A5)+,D7		no of verts
		LEA new_coords,A1		new x,y co-ords
		BSR Trans_verts		translate

; A0 -> no. of faces in shape data.
; Test each face and only insert faces which CAN be seen(backfacing).

Backface	MOVE.W (A0)+,-(SP)		; no of faces
avfacelp	MOVEM 4(A0),D0/D6/D7		; 1st three vertice ptrs
		MOVEM new_coords(PC,D0),D1-D2	; x1,y1
		MOVEM new_coords(PC,D6),D3-D4	; x2,y2
		SUB D3,D1				; (x1-x2)
		SUB D4,D2				; (y1-y2)
		SUB new_coords(PC,D7),D3   	; (x2-x3)
		SUB new_coords+2(PC,D7),D4 	; (y2-y3)
		MULS D4,D1				; (x1-x2)*(y2-y3)
		MULS D2,D3				; (y1-y2)*(x2-x3)
		SUB.L D3,D1				; can face be seen?
		BMI notseen		
		MOVE (a0)+,col			; colour(plane offset!)
		MOVE (a0)+,d7			; no of vertices
		BSR Draw_poly			; return usp
		MOVE.L USP,A0		
		SUBQ #1,(SP)
		BNE.S avfacelp
		ADDQ.W #2,SP
		RTS
notseen	MOVE.L (A0)+,D7
		ADD D7,D7
		ADD D7,A0
		SUBQ #1,(SP)
		BNE.S avfacelp
		ADDQ.W #2,SP
		RTS

new_coords	DS.W 200*6
p_space	DS.W 100      

; Calculate a translation matrix, from the angle data pointed by A5.
; D0-D7/A0-A3 smashed.

Matrix_make	LEA trig_tab,A0		sine table
		LEA 512(A0),A2		cosine table
		MOVEM.W (A5)+,D5-D7    	
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVE (A0,D5),D0		sin(xd)
		MOVE (A2,D5),D1		cos(xd)
		MOVE (A0,D6),D2		sin(yd)
		MOVE (A2,D6),D3		cos(yd)
		MOVE (A0,D7),D4		sin(zd)
		MOVE (A2,D7),D5		cos(zd)
		LEA M11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A3,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6			-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6			-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5			cosz*cosx
		MOVE D5,M33-M11(A1)
		RTS				

; Translate and perspect co-ords.
; A5 - x,y,z.l offsets for co-ords.
; followed by D7 co-ords to translate. 
; D0-D7/A0-A6 smashed.
; Returns A0 pointing to 'no of faces' in object data.

Trans_verts	LEA multable-((dist+1)*2),A6
		MOVE (A5)+,addoffx+2
		MOVE (A5)+,addoffy+2
		MOVE (A5)+,D0
		ADD D0,D0
		ADD D0,A6			zoffset
		MOVE #160,A3		centre x
		MOVE #100,A4		centre y
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
* Combine and Perspect. 
		ADD.L D0,D0
		ADD.L D1,D1
		ADD.L D2,D2
		SWAP D0
		SWAP D1
		SWAP D2
addoffx	ADD.W #0,D0
addoffy	ADD.W #0,D1
		ADD D2,D2
		MOVE (A6,D2),D2
		MULS D2,D0
		MULS D2,D1
		ADD.L D0,D0
		ADD.L D1,D1
		SWAP D0
		SWAP D1
		ADD A3,D0			x scr centre
		ADD A4,D1			y scr centre
		MOVE D0,(A1)+		new x co-ord
		MOVE D1,(A1)+		new y co-ord
		DBF D7,trans_lp
		RTS


coords_1	ds.l	31
coords_2	ds.l	31		;space for 30 pairs
coords_3	ds.l	31		;of x,y coordinates
coords_4	ds.l	31
dupe		ds.l	31		; My space for duplicate coords.

;-----------------------------------------------------------------------;
;----------------------------- Polyfill --------------------------------;
; A0 points to D6 coords,taken from the translated co-ords "new_coords"	;
; Polygon is clipped if necessary. Polygon drawn in colour "col".		;
; Polyfill coded with self-modifying colour routines for extra speed.	;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

Draw_poly	LEA p_space(PC),A2
		LEA new_coords(PC),A1
		MOVE.L A2,A5	; for clipper
		MOVE D7,D0
		SUBQ #1,D7
		MOVE #32767,D3
		MOVEQ #0,D4
		MOVE D3,D5
		MOVE D4,D6
dup_lp1	MOVE (A0)+,D2
		MOVE.L (A1,D2),D2
		MOVE.L D2,(A2)+
		CMP D2,D3
		BLE.S .nminy
		MOVE.W D2,D3
.nminy	CMP D2,D4
		BGE.S .nmaxy
		MOVE.W D2,D4
.nmaxy	SWAP D2
		CMP D2,D5
		BLE.S .nminx
		MOVE.W D2,D5
.nminx	CMP D2,D6
		BGE.S .nmaxx
		MOVE.W D2,D6
.nmaxx	DBF D7,dup_lp1
		MOVE.L A0,USP
		PEA Polyfill(PC)

ymax		equ	199
xmax		equ	319

;--------------------------------------------------------------------------
; polyclip
;
; d0.w = number of coordinate pairs
; a5.l = pointer to list of screenxy
; d3.w = min y val
; d4.w = max y val
; d5.w = min x val
; d6.w = max x val
;
; exits with
;
; d0.w = number of coordinate pairs
; a5.l = pointer to list of screenxy
;--------------------------------------------------------------------------

polyclip	lea	coords_1(pc),a1
		cmp.w	#ymax,d4
		ble.s	.onbot
		pea	clipbot(pc)
.onbot	tst.w	d3
		bpl.s	.ontop
		pea	cliptop(pc)
.ontop	cmp.w	#xmax,d6
		ble.s	.onright
		pea	clipright(pc)
.onright	tst.w	d5
		bpl.s	.onleft
		pea	clipleft(pc)
.onleft	cmp.w	d6,d5
		bvs.s	.bad_range
		cmp.w	d4,d3
		bvc.s	.range_ok
.bad_range	pea	fix_range(pc)
.range_ok 	rts

; Clipping routines:
;
; entry -
;	d0 = number of points
;	a5 = pointer to screenxy pairs
;	a1 = pointer to output area

initclip	macro
		subq.w	#2,d0			;1 for DBRA 1 for first
		bgt.s	.more2
		rts
.more2	move.l	a1,a6
		endm
nextclip	macro
		move.l	a6,a5
		move.l	a1,d0
		sub.l	a6,d0				;points = (end-start)/4
		asr.w	#2,d0
		lea	coords_2-coords_1(a6),a1
		endm
;
; the range of the coords exceeds 16 bits!
;
fix_range	move.w	d0,d6
		add.w	d6,d6				;coords in pairs
		subq.w	#1,d6
		move.l	#16383,d3
		move.l	#-16383,d4
		moveq	#0,d1
		move.l	a5,a6
.loop		move.w	(a6)+,d1
		ext.l	d1				;umm?
		bpl.s	.pos
		cmp.l	d4,d1
		bge.s	.next
		move.w	d4,-2(a6)
		dbra	d6,.loop
		rts
.pos		cmp.l	d3,d1
		ble.s	.next
		move.w	d3,-2(a6)		;max pos
.next		dbra	d6,.loop
		rts
;
; first clip to y=0 line
;
cliptop 	initclip
		move.l	(a5)+,d1
		move.l	d1,d7			;save 1st for closure
.loop		move.l	(a5)+,d2
		tst.w	d1
		bmi.s	.1_off
		tst.w	d2
		bmi.s	.1_on_2_off
		move.l	d1,(a1)+		;store 1st point
.next		move.l	d2,d1
		dbra	d0,.loop
		move.l	d7,d2			;close polygon
		tst.w	d1
		bmi.s	.1_off_a
		tst.w	d2
		bmi.s	.1_on_2_off_a
		move.l	d1,(a1)+		;store last point
.done		nextclip
		rts
.1_off	tst.w	d2
		bmi.s	.next				;1 off and 2 off
		bsr	cliptop_up			;output clipped
		bra.s	.next
.1_on_2_off	move.l	d1,(a1)+		;output first
		bsr	cliptop_down		;output clipped
		bra.s	.next
.1_off_a	tst.w	d2	
		bmi.s	.done				;1 off and 2 off
		bsr	cliptop_up			;output clipped
		bra.s	.done
.1_on_2_off_a	
		move.l	d1,(a1)+		;output first
		bsr	cliptop_down		;output clipped
		bra.s	.done

; cliptop_up - clip to top of screen and round up
;
; d1=x1,y1 (offscreen)
; d2=x2,y2 (onscreen)

cliptop_up	move.w	d2,d3
		beq.s	.top2
		move.w	d1,d4
		sub.w	d1,d3				;y2-y1
		neg.w	d4				;-y1
		swap	d1
		swap	d2
		move.w	d2,d5
		sub.w	d1,d5				;x2-x1
		beq.s	.topsame
		muls	d5,d4
		divs	d3,d4				;(0-y1)*(x2-x1)/(y2-y1)
		add.w	d1,d4
		cmp.w	#xmax,d4
		sne	d5
		and.w	#1,d5				;round up
		add.w	d5,d4
		swap	d1
		swap	d2
		move.w	d4,(a1)+		;output clipped x
		clr.w	(a1)+				;and y=0
		rts
.topsame	move.w	d1,(a1)+
		swap	d1
		swap	d2
		clr.w	(a1)+				;y=0
.top2		rts
;
; cliptop_down - clip to top of screen and round down
;
; d1=x1,y1 (onscreen)
; d2=x2,y2 (offscreen)
;
cliptop_down	
		move.w	d1,d4			;on the edge
		beq.s	.top2
		move.w	d2,d3
		sub.w	d1,d3				;y2-y1
		neg.w	d4				;-y1
		swap	d1
		swap	d2
		move.w	d2,d5
		sub.w	d1,d5				;x2-x1
		beq.s	.topsame
		muls	d5,d4
		divs	d3,d4				;(0-y1)*(x2-x1)/(y2-y1)
		add.w	d1,d4
		tst.w	d4
		sne	d5
		ext.w	d5				;round down!
		add.w	d5,d4
		swap	d1
		swap	d2
		move.w	d4,(a1)+		;output clipped x
		clr.w	(a1)+				;and y=0
		rts
.topsame	move.w	d1,(a1)+
		swap	d1
		swap	d2
		clr.w	(a1)+
.top2		rts
;
; clip to y=ymax line
;
clipbot 	initclip
		move.l	(a5)+,d1
		move.l	d1,d7			;save 1st for closure
		move.w	#ymax,d6
.loop		move.l	(a5)+,d2
		cmp.w	d6,d1
		bgt.s	.1_off
		cmp.w	d6,d2
		bgt.s	.1_on_2_off
		move.l	d1,(a1)+		;store 1st point
.next		move.l	d2,d1
		dbra	d0,.loop
		move.l	d7,d2			;close polygon
		cmp.w	d6,d1
		bgt.s	.1_off_a
		cmp.w	d6,d2
		bgt.s	.1_on_2_off_a
		move.l	d1,(a1)+		;store last point
.done		nextclip
		rts
.1_off	cmp.w	d6,d2
		bge.s	.next				;1 off and 2 off
		bsr	clipbot_down		;output clipped
		bra.s	.next
.1_on_2_off	move.l	d1,(a1)+		;output first
		bsr	clipbot_up			;output clipped
		bra.s	.next
.1_off_a	cmp.w	d6,d2
		bge.s	.done				;1 off and 2 off
		bsr	clipbot_down		;output clipped
		bra.s	.done
.1_on_2_off_a
		move.l	d1,(a1)+		;output first
		bsr	clipbot_up			;output clipped
		bra.s	.done
;
; clip to y=ymax line
;
; d1 = x1,y1 (offscreen)
; d2 = x2,y2 (onscreen)
;
;	yb,x = x1 + (x2-x1)*(ymax-y1)/(y2-y1)
; or	yb,x = x2 + (x1-x2)*(ymax-y2)/(y1-y2)
;
clipbot_down	
		move.w	d2,d3
		sub.w	d1,d3				;y2-y1
		move.w	d1,d4
		sub.w	d6,d4				;y1-ymax
		move.w	d6,d5
		sub.w	d2,d5				;ymax-y2
		swap	d1
		swap	d2
		cmp.w	d4,d5
		bgt.s	.p2max
		neg.w	d4				;ymax-y1
		move.w	d2,d5	
		sub.w	d1,d5				;x2-x1
		beq.s	.xsame
		muls	d5,d4
		divs	d3,d4
		add.w	d1,d4				;x1+xc
		swap	d1
		swap	d2
		move.w	d4,(a1)+
		move.w	d6,(a1)+		;ymax
		rts
.xsame	move.w	d2,(a1)+
		move.w	d6,(a1)+
		swap	d1
		swap	d2
		rts
.p2max	move.w	d1,d4
		sub.w	d2,d4				;x1-x2
		beq.s	.xsame
		neg.w	d3				;y1-y2
		muls	d5,d4
		divs	d3,d4
		add.w	d2,d4
		swap	d1
		swap	d2
		move.w	d4,(a1)+
		move.w	d6,(a1)+		;ymax
		rts

; clip to y=ymax line
;
; d1 = x1,y1 (onscreen)
; d2 = x2,y2 (offscreen)
;
;	yb,x = x1 + (x2-x1)*(ymax-y1)/(y2-y1)
; or	yb,x = x2 + (x1-x2)*(ymax-y2)/(y1-y2)

clipbot_up	cmp.w	d6,d1
		beq.s	.bot2
		move.w	d2,d3
		sub.w	d1,d3			;y2-y1
		move.w	d6,d4
		sub.w	d1,d4			;ymax-y1
		move.w	d2,d5
		sub.w	d6,d5			;y2-ymax
		swap	d1
		swap	d2
		cmp.w	d4,d5
		bgt.s	.p2max
		move.w	d2,d5
		sub.w	d1,d5				;x2-x1
		beq.s	.xsame
		muls	d5,d4
		divs	d3,d4
		add.w	d1,d4				;x1+xc
		swap	d1
		swap	d2
		move.w	d4,(a1)+
		move.w	d6,(a1)+		;ymax
		rts
.xsame	move.w	d2,(a1)+
		move.w	d6,(a1)+
		swap	d1
		swap	d2
		rts
.p2max	move.w	d1,d4
		sub.w	d2,d4				;x1-x2
		beq.s	.xsame
		neg.w	d5
		neg.w	d3				;y1-y2
		muls	d5,d4
		divs	d3,d4
		add.w	d2,d4
		swap	d1
		swap	d2
		move.w	d4,(a1)+
		move.w	d6,(a1)+		;ymax
.bot2		rts
;
; clip to x=0 line
;
clipleft	initclip
		move.l	(a5)+,d1
		move.l	d1,d7			;save 1st for closure
.loop		move.l	(a5)+,d2
		tst.l	d1
		bmi.s	.1_off
		tst.l	d2
		bmi.s	.1_on_2_off
		move.l	d1,(a1)+		;store 1st point
.next		move.l	d2,d1
		dbra	d0,.loop
		move.l	d7,d2			;close polygon
		tst.l	d1
		bmi.s	.1_off_a
		tst.l	d2
		bmi.s	.1_on_2_off_a
		move.l	d1,(a1)+		;store last point
.done		nextclip
		rts
.1_off	tst.l	d2
		bmi.s	.next				;1 off and 2 off
		bsr	clipleft_down		;output clipped
		bra.s	.next
.1_on_2_off	move.l	d1,(a1)+		;output first
		bsr	clipleft_up			;output clipped
		bra.s	.next
.1_off_a	tst.l	d2
		bmi.s	.done				;1 off and 2 off
		bsr	clipleft_down		;output clipped
		bra.s	.done
.1_on_2_off_a
		move.l	d1,(a1)+		;output first
		bsr	clipleft_up			;output clipped
		bra.s	.done
;
; clip to x=0 line,off to on must be the top of a convex poly
;
; d1=x1,y1 (offscreen)
; d2=x2,y2 (onscreen)
;
clipleft_down	
		move.w	d2,d3
		sub.w	d1,d3				;y2-y1
		beq.s	.ysame
		swap	d2
		move.w	d2,d4
		beq.s	.left2
		swap	d1
		move.w	d1,d5
		neg.w	d5				;-x1
		cmp.w	d2,d5
		bgt.s	.p1max
		neg.w	d3				;y1-y2
		neg.w	d4				;-x2
		muls	d4,d3
		move.w	d1,d4
		sub.w	d2,d4				;x1-x2
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d2,d3				;x2+xl
		clr.w	(a1)+
		move.w	d3,(a1)+
		rts
.p1max	muls	d5,d3				;-x1*(y2-y1)
		move.w	d2,d4
		sub.w	d1,d4
		divs	d4,d3				;/(x2-x1)
		swap	d1
		swap	d2
		add.w	d1,d3				;x1+xl
		clr.w	(a1)+
		move.w	d3,(a1)+
		rts
.ysame	swap	d2
		tst.w	d2				;onscreen = 0,?
		beq.s	.discard
		clr.w	(a1)+				;horiz
		move.w	d1,(a1)+
.discard	swap	d2
		rts
.left2	swap	d2				;onscreen = 0,?
		rts
;
; clip to x=0 line and round up
;
; d1=x1,y1 (onscreen)
; d2=x2,y2 (offscreen)
;
clipleft_up	move.w	d2,d3
		sub.w	d1,d3				;y2-y1
		beq.s	.ysame
		swap	d1
		move.w	d1,d4
		beq.s	.left2
		swap	d2
		move.w	d2,d5
		neg.w	d5				;-x2
		cmp.w	d1,d5
		bgt.s	.p2max
		neg.w	d4
		muls	d4,d3				;-x1*(y2-y1)
		move.w	d2,d4
		sub.w	d1,d4				;x2-x1
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d1,d3				;x1+xl
		clr.w	(a1)+
		move.w	d3,(a1)+
		rts
.p2max	neg.w	d3
		muls	d5,d3				;-x2*(y1-y2)
		move.w	d1,d4
		sub.w	d2,d4
		divs	d4,d3				;/(x1-x2)
		swap	d1
		swap	d2
		add.w	d2,d3				;x2+xl
		clr.w	(a1)+
		move.w	d3,(a1)+
		rts
.ysame	swap	d1
		tst.w	d1				;onscreen = 0,?
		beq.s	.discard
		clr.w	(a1)+				;horiz
		move.w	d2,(a1)+
.discard	swap	d1
		rts
.left2	swap	d1				;onscreen = 0,?
		rts
;
; clip to x=xmax line
;
clipright	initclip
		move.l	(a5)+,d1
		move.l	d1,d7			;save 1st for closure
		move.w	#xmax,a2
		moveq	#-1,d6
		move.w	a2,d6
		swap	d6				;faster comparisons
.loop		move.l	(a5)+,d2
		cmp.l	d6,d1
		bgt.s	.1_off
		cmp.l	d6,d2
		bgt.s	.1_on_2_off
		move.l	d1,(a1)+		;store 1st point
.next		move.l	d2,d1
		dbra	d0,.loop
		move.l	d7,d2			;close polygon
		cmp.l	d6,d1
		bgt.s	.1_off_a
		cmp.l	d6,d2
		bgt.s	.1_on_2_off_a
		move.l	d1,(a1)+		;store last point
.done		nextclip
		rts
.1_off	cmp.l	d6,d2
		bgt.s	.next				;1 off and 2 off
		bsr	clipright_down		;output clipped
		bra.s	.next
.1_on_2_off	move.l	d1,(a1)+		;output first
		bsr	clipright_up		;output clipped
		bra.s	.next
.1_off_a	cmp.l	d6,d2
		bgt.s	.done				;1 off and 2 off
		bsr	clipright_down		;output clipped
		bra.s	.done
.1_on_2_off_a
		move.l	d1,(a1)+	;output first
		bsr	clipright_up		;output clipped
		bra.s	.done
;
; clip to right edge for convex poly this must be the bottom edge
;
; d1=x1,y1 (offscreen)
; d2=x2,y2 (onscreen)
;
;	xr,y = (xmax-x1)*(y2-y1)/(x2-x1) + y1
; or	xr,y = (xmax-x2)*(y1-y2)/(x1-x2) + y2
;
clipright_down
		move.w	d2,d3
		sub.w	d1,d3			;y2-y1
		beq.s	.ysame
		swap	d2
		swap	d1
		move.w	a2,d5
		sub.w	d2,d5			;xmax-x2
		beq.s	.right2
		move.w	d1,d4
		sub.w	a2,d4			;x1-xmax
		cmp.w	d4,d5
		bgt.s	.p2max
		neg.w	d4			;xmax-x1
		muls	d4,d3
		move.w	d2,d4
		sub.w	d1,d4			;x2-x1
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d1,d3
		move.w	a2,(a1)+
		move.w	d3,(a1)+
		rts
.p2max	neg.w	d3			;y1-y2
		muls	d5,d3
		move.w	d1,d4
		sub.w	d2,d4			;x1-x2
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d2,d3
		move.w	a2,(a1)+
		move.w	d3,(a1)+
		rts
.right2 	swap	d1
		swap	d2
		rts
.ysame	swap	d2
		cmp.w	a2,d2			;at edge?
		beq.s	.discard
		move.w	a2,(a1)+
		move.w	d1,(a1)+
.discard	swap	d2
		rts
;
; clip to right edge, on to off must be the top of a convex poly
;
; d1=x1,y1 (onscreen)
; d2=x2,y2 (offscreen)
;
;	xr,y = (xmax-x1)*(y2-y1)/(x2-x1) + y1
; or	xr,y = (xmax-x2)*(y1-y2)/(x1-x2) + y2
;
clipright_up
		move.w	d2,d3
		sub.w	d1,d3			;y2-y1
		beq.s	.ysame
		swap	d2
		swap	d1
		move.w	a2,d4
		sub.w	d1,d4			;xmax-x1
		beq.s	.right2
		move.w	d2,d5
		sub.w	a2,d5			;x2-xmax
		cmp.w	d4,d5
		bgt.s	.p2max
		muls	d4,d3
		move.w	d2,d4
		sub.w	d1,d4			;x2-x1
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d1,d3
		move.w	a2,(a1)+
		move.w	d3,(a1)+
		rts
.p2max	neg.w	d3			;y1-y2
		neg.w	d5			;xmax-x2
		muls	d5,d3
		move.w	d1,d4
		sub.w	d2,d4			;x1-x2
		divs	d4,d3
		swap	d1
		swap	d2
		add.w	d2,d3
		move.w	a2,(a1)+
		move.w	d3,(a1)+
		rts
.right2 	swap	d1
		swap	d2
		rts
.ysame	swap	d1
		cmp.w	a2,d1			;at edge?
		beq.s	.discard
		move.w	a2,(a1)+
		move.w	d2,(a1)+
.discard	swap	d1
		rts
				
Polyfill	MOVE D0,D4
		ADD D4,D4
		ADD D4,D4
		MOVE.L A5,A1
		ADDA.W D4,A1
		MOVE.L A1,A2
		ADDA.W D4,A2
Init_coords	SUBQ #2,D0
		MOVE.L (A5)+,D7
		MOVE D7,D2
		MOVE.L A1,A4
		MOVE.L D7,(A1)+
		MOVE.L D7,(A2)+
coord_lp	MOVE.L (A5)+,D3
		CMP D2,D3
		BGE.S not_top
		MOVE D3,D2
		MOVE.L A1,A4
not_top	CMP D3,D7
		BGE.S not_bot
		MOVE D3,D7	
not_bot	MOVE.L D3,(A1)+
		MOVE.L D3,(A2)+
		DBF D0,coord_lp
		MOVE.L A4,A5
		SUB D2,D7			;d2 - lowest y  d7 - greatest y
		MOVE D2,-(SP)
CALCS		MOVE D7,D5
		LEA grad_table+400(PC),A0
; Calc x's down left side of poly
Do_left	LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #4,A4
		MOVEM.W (A4),D1-D4
		SUB D4,D2			;dy
		SUB D3,D1			;dx
		SUB D2,D7			;remaining lines-dy
		ADD D2,D2
		MULS (A0,D2),D1
		ASL.L #3,D1
		SWAP D1
		ADD D2,D2
		ADD D3,D3
		ADD D3,D3
		NEG D2
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADDX.L D1,D3
		ENDR
LEFTJMP	MOVE.W D3,(A3)
		TST D7
		BGT Left_lp
; Calc x's down right side of poly
Do_right	MOVE.W D5,D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM (A5),D1-D4
		ADDQ #4,A5
		SUB D2,D4			;dy
		SUB D1,D3			;dx
		SUB D4,D5			;remaining lines-dy
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
RIGHTJMP	MOVE.W D1,(A3)
		TST D5
		BGT Right_lp
; Now we actually get round to filling the polygon!
		LEA log_base(PC),A4
		MOVE.W (SP)+,D1		; restore minimum y
		LEA x1s(PC),a1		; ptr to left edge co-ord list
		LEA x2s(PC),a2		;   "    right   "          "
		MOVE col(PC),D0
		CMP #8,D0
		BGE.S hashedfill
; Normal Solid colour fill
normalfill	MOVE.L (A4),A6
		ADD D1,D1
		ADD 12(A4,D1),D0
		ADD D0,A6
		LEA ch_vectl(PC),A3	; left mask table
		LEA ch_vectr(PC),A4	; right mask table
		MOVEQ #-1,D2
		ADDQ #1,D7
		MULU #hlinesize,D7
		LEA poly_done1,A0
		SUB D7,A0
		JMP (A0)			; jump thru list
; 'Hashed' fill
hashedfill	MOVE.L (A4),A6
		SUBQ #8,D0
		MOVE.W #$AAAA,D2
		BTST #0,D1
		BEQ.S .notodd
		NOT.W D2
.notodd	ADD D1,D1
		ADD 12(A4,D1),D0
		ADD D0,A6
		LEA ch_vectl(PC),A3	; left mask table
		LEA ch_vectr(PC),A4	; right mask table
		ADDQ #1,D7
		MULU #hhlinesize,D7
		LEA poly_done2,A0
		SUB D7,A0
		JMP (A0)			; jump thru list
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

x1s		DS.W 210
x2s		DS.W 210
col		DS.W 1

; End masks and screen offset tables for normal fill.
		
i		SET 0
ch_vectl	REPT 20
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
i		SET i+8
		ENDR

i		SET 0
ch_vectr	REPT 20
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
i		SET i+8
		ENDR

drawonehline:	
		MOVEQ #-4,D0
		MOVEQ #-4,D1
		AND (A1)+,D0
		AND (A2)+,D1
		MOVE.L (A3,D0),D0		; left mask\offset
		MOVE.L (A4,D1),D1		; right mask\offset
		SUB D1,D0			; -ve difference!
		BLT.S bigcase		; same chunk?
; Hline over one chunk case
		BNE.S next_line		; negative case
		AND.L D1,D0
		SWAP D0
		OR.W D0,(A6,D1)		; write 1 chunk
		BRA.S next_line
bigcase	MOVE.L A6,A0		; hline over several chunks
		ADDA.W D1,A0 
		SWAP D1
		OR D1,(A0)			; write left edge
		ADD D0,A0
		ASR #1,D0			; asr because dx is -ve 
		JMP miss_main+4(PC,D0)	; jump back thru list
		MOVE.W D2,152(A0)
		MOVE.W D2,144(A0)
		MOVE.W D2,136(A0)
		MOVE.W D2,128(A0)
		MOVE.W D2,120(A0)
		MOVE.W D2,112(A0)
		MOVE.W D2,104(A0)
		MOVE.W D2,96(A0)
		MOVE.W D2,88(A0)
		MOVE.W D2,80(A0)		; solid colour
		MOVE.W D2,72(A0)
		MOVE.W D2,64(A0)
		MOVE.W D2,56(A0)
		MOVE.W D2,48(A0)
		MOVE.W D2,40(A0)
		MOVE.W D2,32(A0)
		MOVE.W D2,24(A0)
		MOVE.W D2,16(A0)
		MOVE.W D2,8(A0)
miss_main	SWAP D0			; right mask
		OR D0,(A0)			; and write right mask!!
next_line	LEA 160(A6),A6		; next screen line
enddrawone	

hlinesize	EQU enddrawone-drawonehline
		DS.B 199*hlinesize      ; Space for copy
poly_done1	RTS				; finished!

hdrawonehline:	
		MOVEQ #-4,D0
		MOVEQ #-4,D1
		AND (A1)+,D0
		AND (A2)+,D1
		MOVE.L (A3,D0),D0		; left mask\offset
		MOVE.L (A4,D1),D1		; right mask\offset
		SUB D1,D0			; -ve difference!
		BLT.S hbigcase		; same chunk?
; Hline over one chunk case
		BNE.S hnext_line		; negative case
		AND.L D1,D0
		SWAP D0
		AND D2,D0
		OR.W D0,(A6,D1)		; write 1 chunk
		BRA.S hnext_line
hbigcase	MOVE.L A6,A0		; hline over several chunks
		ADDA.W D1,A0 
		SWAP D1
		AND D2,D1
		OR D1,(A0)			; write left edge
		ADD D0,A0
		ASR #1,D0			; asr because dx is -ve 
		JMP hmiss_main+4(PC,D0)	; jump back thru list
		MOVE.W D2,152(A0)
		MOVE.W D2,144(A0)
		MOVE.W D2,136(A0)
		MOVE.W D2,128(A0)
		MOVE.W D2,120(A0)
		MOVE.W D2,112(A0)
		MOVE.W D2,104(A0)
		MOVE.W D2,96(A0)
		MOVE.W D2,88(A0)
		MOVE.W D2,80(A0)		; solid colour
		MOVE.W D2,72(A0)
		MOVE.W D2,64(A0)
		MOVE.W D2,56(A0)
		MOVE.W D2,48(A0)
		MOVE.W D2,40(A0)
		MOVE.W D2,32(A0)
		MOVE.W D2,24(A0)
		MOVE.W D2,16(A0)
		MOVE.W D2,8(A0)
hmiss_main	SWAP D0			; right mask
		AND D2,D0
		OR D0,(A0)			; and write right mask!!
hnext_line	LEA 160(A6),A6		; next screen line
		NOT D2
henddrawone	
hhlinesize	EQU henddrawone-hdrawonehline
		DS.B 199*hhlinesize     ; Space for copy
poly_done2	RTS				; finished!

; Shape data

cube		DC.W 0,0,0
		DC.W 8
		DC.W 0,0,$e00
		DC.W -800,-800,-800
		DC.W 800,-800,-800
		DC.W 800,-800,800
		DC.W -800,-800,800
		DC.W -800,800,-800
		DC.W 800,800,-800
		DC.W 800,800,800
		DC.W -800,800,800
		DC.W 6
		DC.W 04*2,4,03*4,02*4,01*4,00*4
		DC.W 01*2,4,02*4,06*4,05*4,01*4
		DC.W 05*2,4,03*4,07*4,06*4,02*4
		DC.W 02*2,4,06*4,07*4,04*4,05*4
		DC.W 06*2,4,01*4,05*4,04*4,00*4
		DC.W 03*2,4,04*4,07*4,03*4,00*4

pyramid	DC.W 0,0,0
		DC.W 5
		DC.W 0,0,$c00
		DC.W -800,-800,-800
		DC.W 800,-800,-800
		DC.W 800,-800,800
		DC.W -800,-800,800
		DC.W 0,800,0
		DC.W 5
		DC.W 04*2,4,03*4,02*4,01*4,00*4
		DC.W 00*2,3,00*4,01*4,04*4
		DC.W 01*2,3,01*4,02*4,04*4
		DC.W 02*2,3,02*4,03*4,04*4
		DC.W 03*2,3,03*4,00*4,04*4 ;

thargoid	DC.W 0,0,0	
		DC.W 16
		DC.L 0,0,$b000000
		DC.W 0*4,200*4,0*4
		DC.W 140*4,140*4,0*4
		DC.W 200*4,0*4,0*4
		DC.W 140*4,-140*4,0*4
		DC.W 0*4,-200*4,0*4
		DC.W -140*4,-140*4,0*4
		DC.W -200*4,0*4,0*4
		DC.W -140*4,140*4,0*4
		DC.W 0*4,360*4,-100*4
		DC.W 252*4,252*4,-100*4
		DC.W 360*4,0*4,-100*4
		DC.W 252*4,-252*4,-100*4
		DC.W 0*4,-360*4,-100*4
		DC.W -252*4,-252*4,-100*4
		DC.W -360*4,0*4,-100*4
		DC.W -252*4,252*4,-100*4
		DC.W 10
		DC.W 0*2,8,00*4,01*4,02*4,03*4,04*4,05*4,06*4,07*4
		DC.W 1*2,8,15*4,14*4,13*4,12*4,11*4,10*4,09*4,08*4
		DC.W 2*2,4,06*4,14*4,15*4,07*4
		DC.W 3*2,4,05*4,13*4,14*4,06*4
		DC.W 1*2,4,04*4,12*4,13*4,05*4
		DC.W 2*2,4,03*4,11*4,12*4,04*4
		DC.W 3*2,4,02*4,10*4,11*4,03*4
		DC.W 1*2,4,01*4,09*4,10*4,02*4
		DC.W 2*2,4,00*4,08*4,09*4,01*4
		DC.W 3*2,4,07*4,15*4,08*4,00*4

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
		DC.W 13*2,3,00*4,01*4,02*4
		DC.W 14*2,3,09*4,11*4,10*4
		DC.W 13*2,3,04*4,08*4,09*4
		DC.W 14*2,3,01*4,03*4,08*4
		DC.W 13*2,3,03*4,07*4,11*4
		DC.W 14*2,3,00*4,05*4,07*4
		DC.W 13*2,3,05*4,06*4,10*4
		DC.W 14*2,3,02*4,04*4,06*4
		DC.W 15*2,4,00*4,02*4,06*4,05*4
		DC.W 09*2,4,04*4,02*4,01*4,08*4
		DC.W 11*2,4,00*4,07*4,03*4,01*4
		DC.W 09*2,4,07*4,05*4,10*4,11*4
		DC.W 15*2,4,08*4,03*4,11*4,09*4
		DC.W 11*2,4,06*4,04*4,09*4,10*4

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
		DC.W 01*2,3,01*4,02*4,04*4
		DC.W 14*2,3,01*4,00*4,02*4
		DC.W 15*2,3,02*4,00*4,05*4
		DC.W 01*2,3,02*4,05*4,06*4
		DC.W 10*2,3,02*4,06*4,04*4
		DC.W 11*2,3,04*4,06*4,09*4
		DC.W 13*2,3,04*4,09*4,08*4
		DC.W 10*2,3,01*4,04*4,08*4
		DC.W 01*2,3,03*4,01*4,08*4
		DC.W 09*2,3,00*4,01*4,03*4
		DC.W 10*2,3,07*4,11*4,10*4
		DC.W 13*2,3,00*4,07*4,05*4
		DC.W 01*2,3,10*4,05*4,07*4
		DC.W 10*2,3,06*4,05*4,10*4
		DC.W 09*2,3,06*4,10*4,09*4
		DC.W 14*2,3,09*4,10*4,11*4
		DC.W 15*2,3,08*4,09*4,11*4
		DC.W 10*2,3,03*4,08*4,11*4
		DC.W 01*2,3,03*4,11*4,07*4
		DC.W 11*2,3,00*4,03*4,07*4

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
		DC.W 1*2,3,0*4,1*4,5*4
		DC.W 2*2,3,1*4,3*4,5*4
		DC.W 3*2,3,1*4,2*4,3*4
		DC.W 4*2,3,5*4,3*4,4*4
		DC.W 5*2,3,6*4,2*4,1*4
		DC.W 6*2,3,6*4,1*4,0*4
		DC.W 7*2,3,4*4,3*4,6*4
		DC.W 8*2,3,5*4,4*4,6*4
		DC.W 9*2,3,3*4,2*4,6*4
		DC.W 10*2,3,0*4,5*4,6*4
	
House		DC.W 0,0,0
		DC.W 10
		DC.w 0,0,$1000
		DC.W -200*4,100*4,150*4
		DC.W 200*4,100*4,150*4
		DC.W 200*4,-80*4,150*4
		DC.W -200*4,-80*4,150*4
		DC.W -200*4,100*4,-150*4
		DC.W 200*4,100*4,-150*4
		DC.W 200*4,-80*4,-150*4
		DC.W -200*4,-80*4,-150*4
		DC.W -200*4,150*4,0*4
		DC.W 200*4,150*4,0*4
		DC.W 7
		DC.W 0*2,4,0*4,1*4,2*4,3*4
		DC.W 1*2,4,7*4,6*4,5*4,4*4
		DC.W 2*2,5,0*4,3*4,7*4,4*4,8*4
		DC.W 3*2,5,1*4,9*4,5*4,6*4,2*4
		DC.W 2*2,4,8*4,9*4,1*4,0*4
		DC.W 1*2,4,4*4,5*4,9*4,8*4
		DC.W 0*2,4,6*4,7*4,3*4,2*4

House2		DC.W 0,0,0
		DC.W 10
		DC.w 0,0,$300
		DC.W -100,50,75
		DC.W 100,50,75
		DC.W 100,-80,75
		DC.W -100,-80,75
		DC.W -100,50,-75
		DC.W 100,50,-75
		DC.W 100,-80,-75
		DC.W -100,-80,-75
		DC.W -100,125,0
		DC.W 100,125,0
		DC.W 7
		DC.W 01*2,4,0*4,1*4,2*4,3*4
		DC.W 04*2,4,7*4,6*4,5*4,4*4
		DC.W 2*2,5,0*4,3*4,7*4,4*4,8*4
		DC.W 3*2,5,1*4,9*4,5*4,6*4,2*4
		DC.W 04*2,4,8*4,9*4,1*4,0*4
		DC.W 05*2,4,4*4,5*4,9*4,8*4
		DC.W 06*2,4,6*4,7*4,3*4,2*4


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

		SECTION BSS

		DS.L 399
stack		DS.L 1
screens	DS.B 256
		DS.B 32000
		DS.B 32000
		DS.B 32000
		DS.B 256
multable	DS.W 32768-dist


