;-----------------------------------------------------------------------;		 
; 3D Solid Object Rotation routine V1.0					; 
; by Martin Griffiths (c) April 1991 					;
; ( 3 Plane version 0 )							;
;-----------------------------------------------------------------------;		 
; This is best suited for demos since it uses muls perspective! 
no_planes	EQU 3
planewidth	EQU 40
linewidth	EQU planewidth*no_planes

		org $10000

		dc.l start

		
; Blitter equates.

BLTCON0		EQU $40
BLTCON1		EQU $42
BLTAFWM		EQU $44
BLTSIZE		EQU $58
BLTAMOD		EQU $64
BLTBMOD		EQU $62
BLTCMOD		EQU $60
BLTDMOD		EQU $66
BLTADAT		EQU $74
BLTBDAT		EQU $72
BLTCDAT		EQU $70
BLTAPT		EQU $50
BLTBPT		EQU $4C
BLTCPT		EQU $48
BLTDPT		EQU $54
LINEMODE	equ	$1
SIGNFLAG	equ	$40
OCTANT8		equ	24
OCTANT7		equ	4
OCTANT6		equ	12
OCTANT5		equ	28
OCTANT4		equ	20
OCTANT3		equ	8
OCTANT2		equ	0
OCTANT1		equ	16
DMAB_BLTDONE	EQU	14

waitblit	macro
.waitblit\@	btst.b #DMAB_BLTDONE-8,2(A6)
		bne.s .waitblit\@
		endm

; Rout to save o.s and then kick it out.

start		lea $dff000,a6
		move.w #$7fff,$96(a6)		; dma off
		move.w #$7fff,$9a(a6)		; ints off
		lea stack,sp
		lea pl1_ptr+2(pc),a0
		move.l log_base(pc),d0
		bsr set_screen
		bsr Initdraw 

		lea $dff000,a6
		move.w #%1000001111000000,$96(a6)
		move.w #%1100000000110000,$9a(a6)
		move.l #my_vbl,$6c.w
		move.l #copper_list,$80(a6)
		move.w #0,$88(a6)
		move.w #$2200,sr
vb_loop		LEA $DFF000,A6
		BSR swap_screens
		LEA station,A5 
		ADD #10,(A5) 
		ADD #8,2(A5) 
		ADD #6,4(A5) 
		BSR Show_object 

.waitl		btst.b #6,$bfe001
		bne.s vb_loop

		lea $dff000,a6
		waitblit
		move.w #$7fff,$96(a6)
		move.w #$7fff,$9a(a6)
		lea old_vects(pc),a1
		move.l (a1)+,$80(a6)		; restore copper list ptr
		clr.w $88(a6)
		move.l (a1)+,$6c.w		; restore vbl ptr
		move.w (a1)+,$96(a6)		; restore dmacon
		move.w (a1)+,$9a(a6)		; restore dmaenable
		moveq #0,d0
		rts

; Little old vbl
	
my_vbl		addq #1,vbl_timer
		move.w #$20,$dff09c		; clear int request
		rte

vbl_timer:	dc.w 0

; Set screen with d0 ptr to screen to set in copper list ptr by a0.

set_screen:	moveq #40,d1
.set1		swap d0
		move.w d0,(a0) 
		swap d0
		move.w d0,4(a0) 
		add.l d1,d0
.set2		swap d0
		move.w d0,8(a0) 
		swap d0
		move.w d0,12(a0) 
		add.l d1,d0
.set3		swap d0
		move.w d0,16(a0) 
		swap d0
		move.w d0,20(a0) 
		add.l d1,d0
.set4		swap d0
		move.w d0,24(a0) 
		swap d0
		move.w d0,28(a0) 
		rts

old_vects:	ds.l 5
log_base	dc.l screen1
phy_base	dc.l screen2
switch		dc.w 0
i		SET 0 
tmul_160	REPT 200
		DC.W i 
i		SET i+linewidth 
		ENDR 

; Copper list!

copper_list:	dc.w $0201,$fffe
pl1_ptr		dc.w $00e0,$0000
		dc.w $00e2,$0000
		dc.w $00e4,$0000
		dc.w $00e6,$0000
		dc.w $00e8,$0000
		dc.w $00ea,$0000
		dc.w $00ec,$0000
		dc.w $00ee,$0000
setrez		dc.w $0100,%0011001000000000
		dc.w $0102,$0000
		dc.w $008e,($2c*256)+$81
		dc.w $0090,($f4*256)+$c1
		dc.w $0092,$0038
		dc.w $0094,$00d0
		dc.w $0108,linewidth-planewidth
		dc.w $010a,linewidth-planewidth
pal1		dc.w $0180,$0000
		dc.w $0182,$0111
		dc.w $0184,$0333
		dc.w $0186,$0555
		dc.w $0188,$0777
		dc.w $018a,$0999
		dc.w $018c,$0bbb
		dc.w $018e,$0ddd
		dc.w $0190,$0fff
		dc.w $0192,$0888
		dc.w $0194,$0888
		dc.w $0196,$0888
		dc.w $0198,$0888
		dc.w $019A,$0888
		dc.w $019c,$0888
		dc.w $019e,$0888

i		set $9601
j		set $000
		rept 15
		dc.w i,$fffe
		dc.w $0180,j
i		set i+$0100
j		set j+$111
		endr
 
		rept 15
		dc.w i,$fffe
		dc.w $0180,j
i		set i+$0100
j		set j-$111
		endr
 
		dc.l $ffff,$fffe
 
dist		EQU 256			; viewpoint distance 

; Initialise the drawing rout 
 
Initdraw	LEA multable,A0 
		MOVE #dist+1,D0 
		MOVE #32768-dist-2,D1 
.lp1		MOVE.L #32768*dist,D2 
		DIVS D0,D2 
		MOVE.W D2,(A0)+ 
		ADDQ #1,D0 
		DBF D1,.lp1 
		RTS 
 
; Swap screens and clear screens 
 
swap_screens 	LEA vbl_timer(PC),A0 
		MOVE #$770,$DFF180
		MOVE (A0),D0 
wait_vbl	CMP (A0),D0 
		BEQ.S wait_vbl 
		LEA log_base(PC),A0 
		MOVEM.L (A0)+,D5-D6
		NOT.W (a0)
		MOVE.L D5,-(A0) 
		MOVE.L D6,-(A0) 
		MOVE.L D5,D0
		LEA pl1_ptr+2(pc),a0
		bsr set_screen
 		waitblit
		MOVE.L #$01000000,BLTCON0(A6)
		MOVE.L D6,BLTDPT(A6)
		CLR.W BLTDMOD(A6)
		MOVE.W #(100*64)+60,BLTSIZE(A6)	; clear buffer
		MOVE.L D6,A0
		LEA 24000(A0),A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D7
		MOVE.L D7,A1
		MOVE.L D7,A2
		MOVE.L D7,A3
		MOVE.L D7,A4
		REPT 250
		MOVEM.L D0-D7/A1-A4,-(A0)
		ENDR
		RTS

; Routine to translate,perspect and draw a solid 3d object. 
; A5 points to shape data.D0-D7/A0-A6 smashed(everything!!). 
 
Show_object	MOVE.W #%1000010000000000,$DFF096 ; BLITTER hog
		BSR Matrix_make			; rotmat 
		MOVE (A5)+,D7			; no of verts 
		LEA new_coords(PC),A1		; new x,y co-ords 
		BSR Trans_verts			; translate 
 
; A0 -> no. of faces in shape data. 
; Test each face and only insert faces which CAN be seen(backfacing). 
 
Backface	MOVE.W (A0)+,-(SP)		; no of faces 
avfacelp	MOVEM 4(A0),D0/D6/D7		; 1st three vertice ptrs 
		MOVEM new_coords(PC,D0),D1-D2	; x1,y1 
		MOVEM new_coords(PC,D6),D3-D4	; x2,y2 
		SUB D3,D1			; (x1-x2) 
		SUB D4,D2			; (y1-y2) 
		SUB new_coords(PC,D7),D3   	; (x2-x3) 
		SUB new_coords+2(PC,D7),D4 	; (y2-y3) 
		MULS D4,D1			; (x1-x2)*(y2-y3) 
		MULS D2,D3			; (y1-y2)*(x2-x3) 
		SUB.L	D3,D1			; can face be seen? 
		BMI notseen		 
		MOVE (a0)+,col			; colour(plane offset!) 
		MOVE (a0)+,D7			; no of vertices 
		BSR Draw_poly			; return usp 
		MOVE.L aUSP(pc),A0		 
		SUBQ #1,(SP) 
		BNE.S avfacelp 
endobjdraw	ADDQ.W #2,SP 
		RTS 
notseen		MOVE.L (A0)+,D6 
		ADD D6,D6 
		ADD D6,A0 
		SUBQ #1,(SP) 
		BNE.S avfacelp 
		ADDQ.W #2,SP 
		MOVE.W #%0000010000000000,$DFF096 ;out of hog
		RTS 

aUSP		DC.L 0 
new_coords	DS.W 300 
p_space		DS.W 50       
 
; Calculate a translation matrix, from the angle data pointed by A5. 
; D0-D7/A0-A3 smashed. 
 
Matrix_make	LEA trig_tab,A0			sine table 
		LEA 512(A0),A2			cosine table 
		MOVEM.W (A5)+,D5-D7    	 
		AND #$7FE,D5 
		AND #$7FE,D6 
		AND #$7FE,D7 
		MOVE (A0,D5),D0			sin(xd) 
		MOVE (A2,D5),D1			cos(xd) 
		MOVE (A0,D6),D2			sin(yd) 
		MOVE (A2,D6),D3			cos(yd) 
		MOVE (A0,D7),D4			sin(zd) 
		MOVE (A2,D7),D5			cos(zd) 
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
		NEG D6				-cosz*sinx 
		MOVE D6,M31-M11(A1) 
* Matrix(1,2) -siny*cosz 
		MOVE D2,D6			siny 
		MULS D5,D6			siny*cosz 
		ADD.L D6,D6 
		SWAP D6 
		NEG D6				-siny*cosz 
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
		SWAP D6				siny*(sinz*cosx) 
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
		SWAP D5				cosz*cosx 
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
		ADD D0,A6		zoffset 
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
addoffx		ADD.W #0,D0 
addoffy		ADD.W #0,D1 
		ADD D2,D2 
		MOVE (A6,D2),D2 
		MULS D2,D0 
		MULS D2,D1 
		ADD.L D0,D0 
		ADD.L D1,D1 
		SWAP D0 
		SWAP D1 
		ADD A3,D0			; x scr centre 
		ADD A4,D1			; y scr centre 
		MOVE D0,(A1)+			; new x co-ord 
		MOVE D1,(A1)+			; new y co-ord 
		DBF D7,trans_lp 
		RTS 
 
 
coords_1	ds.l	31 
coords_2	ds.l	31		;space for 30 pairs 
coords_3	ds.l	31		;of x,y coordinates 
coords_4	ds.l	31 
dupe		ds.l	31		; My space for duplicate coords. 
 
;-----------------------------------------------------------------------; 
;----------------------------- Polyfill --------------------------------; 
; A0 points to D7 coords,taken from the translated co-ords "new_coords"	; 
; Polygon is clipped if necessary. Polygon drawn in colour "col".	; 
;-----------------------------------------------------------------------; 
;-----------------------------------------------------------------------; 
 
Draw_poly	LEA p_space(PC),A2 
		LEA new_coords(PC),A1 
		MOVE.L A2,A5			; for clipper 
		MOVE D7,D0 
		SUBQ #1,D7 
		MOVE #32767,D3			; min Y
		MOVEQ #0,D4			; max Y
		MOVE D3,D5			; min X
		MOVE D4,D6			; max X
dup_lp1		MOVE (A0)+,D1
		MOVE.L (A1,D1),D1
		MOVE.L D1,(A2)+	
		CMP.W D3,D1
		BGE.S .notminy
		MOVE.W D1,D3
.notminy	CMP.W D4,D1
		BLE.S .notmaxy
		MOVE.W D1,D4
.notmaxy	SWAP D1
		CMP.W D5,D1
		BGE.S .notminx
		MOVE.W D1,D5
.notminx	CMP.W D6,D1
		BLE.S .notmaxx
		MOVE.W D1,D6
.notmaxx	DBF D7,dup_lp1 
		MOVE.L A0,aUSP
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
.onbot		tst.w	d3 
		bpl.s	.ontop 
		pea	cliptop(pc) 
.ontop		cmp.w	#xmax,d6 
		ble.s	.onright 
		pea	clipright(pc) 
.onright	tst.w	d5 
		bpl.s	.onleft 
		pea	clipleft(pc) 
.onleft		cmp.w	d6,d5 
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
.more2		move.l	a1,a6 
		endm 
nextclip	macro 
		move.l	a6,a5 
		move.l	a1,d0 
		sub.l	a6,d0			;points = (end-start)/4 
		asr.w	#2,d0 
		lea	coords_2-coords_1(a6),a1 
		endm 
; 
; the range of the coords exceeds 16 bits! 
; 
fix_range	move.w	d0,d6 
		add.w	d6,d6			;coords in pairs 
		subq.w	#1,d6 
		move.l	#16383,d3 
		move.l	#-16383,d4 
		moveq	#0,d1 
		move.l	a5,a6 
.loop		move.w	(a6)+,d1 
		ext.l	d1			;umm? 
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
.1_off		tst.w	d2 
		bmi.s	.next			;1 off and 2 off 
		bsr	cliptop_up		;output clipped 
		bra.s	.next 
.1_on_2_off	move.l	d1,(a1)+		;output first 
		bsr	cliptop_down		;output clipped 
		bra.s	.next 
.1_off_a	tst.w	d2	 
		bmi.s	.done			;1 off and 2 off 
		bsr	cliptop_up		;output clipped 
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
		sub.w	d1,d3			;y2-y1 
		neg.w	d4			;-y1 
		swap	d1 
		swap	d2 
		move.w	d2,d5 
		sub.w	d1,d5			;x2-x1 
		beq.s	.topsame 
		muls	d5,d4 
		divs	d3,d4			;(0-y1)*(x2-x1)/(y2-y1) 
		add.w	d1,d4 
		cmp.w	#xmax,d4 
		sne	d5 
		and.w	#1,d5			;round up 
		add.w	d5,d4 
		swap	d1 
		swap	d2 
		move.w	d4,(a1)+		;output clipped x 
		clr.w	(a1)+			;and y=0 
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
		sub.w	d1,d3			;y2-y1 
		neg.w	d4			;-y1 
		swap	d1 
		swap	d2 
		move.w	d2,d5 
		sub.w	d1,d5			;x2-x1 
		beq.s	.topsame 
		muls	d5,d4 
		divs	d3,d4			;(0-y1)*(x2-x1)/(y2-y1) 
		add.w	d1,d4 
		tst.w	d4 
		sne	d5 
		ext.w	d5			;round down! 
		add.w	d5,d4 
		swap	d1 
		swap	d2 
		move.w	d4,(a1)+		;output clipped x 
		clr.w	(a1)+			;and y=0 
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
.1_off		cmp.w	d6,d2 
		bge.s	.next			;1 off and 2 off 
		bsr	clipbot_down		;output clipped 
		bra.s	.next 
.1_on_2_off	move.l	d1,(a1)+		;output first 
		bsr	clipbot_up		;output clipped 
		bra.s	.next 
.1_off_a	cmp.w	d6,d2 
		bge.s	.done			;1 off and 2 off 
		bsr	clipbot_down		;output clipped 
		bra.s	.done 
.1_on_2_off_a 
		move.l	d1,(a1)+		;output first 
		bsr	clipbot_up		;output clipped 
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
		sub.w	d1,d3			;y2-y1 
		move.w	d1,d4 
		sub.w	d6,d4			;y1-ymax 
		move.w	d6,d5 
		sub.w	d2,d5			;ymax-y2 
		swap	d1 
		swap	d2 
		cmp.w	d4,d5 
		bgt.s	.p2max 
		neg.w	d4			;ymax-y1 
		move.w	d2,d5	 
		sub.w	d1,d5			;x2-x1 
		beq.s	.xsame 
		muls	d5,d4 
		divs	d3,d4 
		add.w	d1,d4			;x1+xc 
		swap	d1 
		swap	d2 
		move.w	d4,(a1)+ 
		move.w	d6,(a1)+		;ymax 
		rts 
.xsame		move.w	d2,(a1)+ 
		move.w	d6,(a1)+ 
		swap	d1 
		swap	d2 
		rts 
.p2max		move.w	d1,d4 
		sub.w	d2,d4			;x1-x2 
		beq.s	.xsame 
		neg.w	d3			;y1-y2 
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
		sub.w	d1,d5			;x2-x1 
		beq.s	.xsame 
		muls	d5,d4 
		divs	d3,d4 
		add.w	d1,d4			;x1+xc 
		swap	d1 
		swap	d2 
		move.w	d4,(a1)+ 
		move.w	d6,(a1)+		;ymax 
		rts 
.xsame		move.w	d2,(a1)+ 
		move.w	d6,(a1)+ 
		swap	d1 
		swap	d2 
		rts 
.p2max		move.w	d1,d4 
		sub.w	d2,d4			;x1-x2 
		beq.s	.xsame 
		neg.w	d5 
		neg.w	d3			;y1-y2 
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
.1_off		tst.l	d2 
		bmi.s	.next			;1 off and 2 off 
		bsr	clipleft_down		;output clipped 
		bra.s	.next 
.1_on_2_off	move.l	d1,(a1)+		;output first 
		bsr	clipleft_up		;output clipped 
		bra.s	.next 
.1_off_a	tst.l	d2 
		bmi.s	.done			;1 off and 2 off 
		bsr	clipleft_down		;output clipped 
		bra.s	.done 
.1_on_2_off_a 
		move.l	d1,(a1)+		;output first 
		bsr	clipleft_up		;output clipped 
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
.p1max		muls	d5,d3				;-x1*(y2-y1) 
		move.w	d2,d4 
		sub.w	d1,d4 
		divs	d4,d3				;/(x2-x1) 
		swap	d1 
		swap	d2 
		add.w	d1,d3				;x1+xl 
		clr.w	(a1)+ 
		move.w	d3,(a1)+ 
		rts 
.ysame		swap	d2 
		tst.w	d2				;onscreen = 0,? 
		beq.s	.discard 
		clr.w	(a1)+				;horiz 
		move.w	d1,(a1)+ 
.discard	swap	d2 
		rts 
.left2		swap	d2				;onscreen = 0,? 
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
.p2max		neg.w	d3 
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
.ysame		swap	d1 
		tst.w	d1				;onscreen = 0,? 
		beq.s	.discard 
		clr.w	(a1)+				;horiz 
		move.w	d2,(a1)+ 
.discard	swap	d1 
		rts 
.left2		swap	d1				;onscreen = 0,? 
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
		swap	d6			;faster comparisons 
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
.1_off		cmp.l	d6,d2 
		bgt.s	.next			;1 off and 2 off 
		bsr	clipright_down		;output clipped 
		bra.s	.next 
.1_on_2_off	move.l	d1,(a1)+		;output first 
		bsr	clipright_up		;output clipped 
		bra.s	.next 
.1_off_a	cmp.l	d6,d2 
		bgt.s	.done			;1 off and 2 off 
		bsr	clipright_down		;output clipped 
		bra.s	.done 
.1_on_2_off_a 
		move.l	d1,(a1)+		;output first 
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
.p2max		neg.w	d3			;y1-y2 
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
.ysame		swap	d2 
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
.p2max		neg.w	d3			;y1-y2 
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
.ysame		swap	d1 
		cmp.w	a2,d1			;at edge? 
		beq.s	.discard 
		move.w	a2,(a1)+ 
		move.w	d2,(a1)+ 
.discard	swap	d1 
		rts 

; Fill a 3 plane polygon. a5 -> d0 vertices.
				 
Polyfill	CMP #1,D0
		BLE .endoffill			; poly is of screen?
		MOVE.W D0,D7			; no of edges
		ADD D0,D0 
		ADD D0,D0 			; *4
		MOVE.L (A5),(A5,D0) 		; last vert=first(line draw)
		SUBQ #1,D7			; edges-1
		LEA tmul_160(PC),A2
		LEA .max_x+2(PC),A3
		MOVE.W #$0000,(a3)
		MOVE.W #$7fff,.min_x-.max_x(a3)
		MOVE.W #$0000,.max_y-.max_x(a3)
		MOVE.W #$7fff,.min_y-.max_x(a3)
		LEA draw_buf(PC),A4		; draw buffer
		LEA $dff000,A6
		MOVEQ #-1,d5
		waitblit			; wait for bloody blitter!
		MOVE.L d5,BLTAFWM(A6)
		MOVE.W #linewidth,BLTCMOD(A6)
		MOVE.W #linewidth,BLTDMOD(A6)
		CLR.L BLTAPT(A6)
		MOVE.W #$8000,BLTADAT(A6)
		MOVE.W D5,BLTBDAT(A6)
.drawline_lp	MOVEM.W (A5),D0-D3		; get x1,y1,x2,y2
.max_x		CMP #0,D0 
		BLE.S .min_x 
		MOVE.W D0,(A3)
.min_x		CMP #32767,D0 
		BGE.S .max_y 
		MOVE.W D0,.min_x-.max_x(A3) 
.max_y		CMP #0,D1 
		BLE.S .min_y 
		MOVE.W D1,.max_y-.max_x(A3) 
.min_y		CMP #32767,D1 
		BGE.S .Drawline 
		MOVE.W D1,.min_y-.max_x(A3) 
.Drawline	CMP.W D1,D3			; lets go for draw!
		BHI .quadok
		EXG D0,D2
		EXG D1,D3
.quadok		SUB.W D1,D3			; dy
		SUB.W D0,D2			; dx
		BPL.S .toptwo
		NEG.W D2
		MOVE.L #$0B5A0000+$B,D4
		CMP.W D3,D2
		BCS.S .letsdraw
		MOVE.L #$0B5A0000+$17,D4
		EXG D2,D3
		BRA.S .letsdraw
.toptwo		MOVE.L #$0B5A0000+3,D4
		CMP.W D3,D2
		BCS.S .letsdraw
		MOVE.L #$0B5A0000+$13,D4
		EXG D2,D3
.letsdraw	ADD.W D2,D2
		MOVE.W D2,D5
		SUB.W D3,D5
		CMP.W D2,D3
		BCS .signok
		OR.W #$40,D4
.signok		MOVE.W D0,D6
		ROR.L #4,D0
		ADD D0,D0
		MOVE.L A4,A0
		ADD D1,D1
		ADD.W (A2,D1),D0
		ADD D0,A0
		ADD D6,D6
		MOVE.W .xmasks(PC,D6),D1
		CLR.W D0
		OR.L D0,D4
		waitblit
		EOR.W D1,(A0)
		MOVE.L A0,BLTCPT(A6)
		MOVE.L A0,BLTDPT(A6)
		MOVE.W D5,BLTAPT+2(A6)
		SUB.W D3,D5
		MOVE.W D5,BLTAMOD(A6)
		MOVE.W D2,BLTBMOD(A6)
		MOVE.L D4,BLTCON0(A6)
		ADDQ.W #1,D3
		LSL.W #6,D3
		ADDQ.W #2,D3
		MOVE.W D3,BLTSIZE(A6)
.line_drawn	ADDQ.W #4,A5
		DBF D7,.drawline_lp
		BRA .fillit

.xmasks		REPT 20
		DC.W $8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,$8,$4,$2,$1
		ENDR

; Now fill between the lines...

.fillit		MOVE.L log_base(PC),A3
		LEA draw_buf(PC),A4
		MOVE.W .max_y+2(pc),d1
		MOVE.W D1,D0
		SUB.W .min_y+2(pc),d0
		BEQ .endoffill
		MOVE.W .max_x+2(PC),D2
		MOVE.W .min_x+2(PC),D3
		LSR #4,D2			; max x chunk
		ADD D2,D2
		LSR #4,D3
		ADD D3,D3			; min x chunk
		ADD D1,D1
		MOVE.W (A2,D1),D1
		ADD D2,D1
		ADD D1,A4			; point source +dest
		ADD D1,A3			; to last word in last row
		SUB.W D3,D2
		ADDQ #2,D2
		MOVE #linewidth,D4
		SUB.W D2,D4			; modulo
		LSR #1,D2			; no of words
		LSL #6,D0
		ADD D2,D0
		waitblit
		MOVE.W D4,BLTAMOD(A6)
		MOVE.W D4,BLTCMOD(A6)
		MOVE.W D4,BLTDMOD(A6)
		MOVE.L #$9F00012,BLTCON0(A6)   
		MOVE.L A4,BLTAPT(A6)
		MOVE.L A4,BLTDPT(A6)	
		MOVE.W D0,BLTSIZE(A6)		; fill buffer
		waitblit

		MOVE.W col(pc),D2
		MOVE.W #$BFA,D1
		BTST #0,D2
		BNE.S .set1
		MOVE.W #$B0A,D1
.set1		MOVE.W #$0002,BLTCON1(A6)   
		MOVE.W D1,BLTCON0(A6)   
		MOVE.L A4,BLTAPT(A6)
		MOVE.L A3,BLTCPT(A6)
		MOVE.L A3,BLTDPT(A6)
		MOVE.W D0,BLTSIZE(A6)	
		LEA planewidth(A3),A3
		MOVE.W #$BFA,D1
		BTST #1,D2
		BNE.S .set2
		MOVE.W #$B0A,D1
.set2		MOVE.W D1,BLTCON0(A6)   
		MOVE.L A4,BLTAPT(A6)
		MOVE.L A3,BLTCPT(A6)
		MOVE.L A3,BLTDPT(A6)
		MOVE.W D0,BLTSIZE(A6)	
		LEA planewidth(A3),A3
		MOVE.W #$BFA,D1
		BTST #2,D2
		BNE.S .set3
		MOVE.W #$B0A,D1
.set3		MOVE.W D1,BLTCON0(A6) 
		MOVE.L A4,BLTAPT(A6)
		MOVE.L A3,BLTCPT(A6)
		MOVE.L A3,BLTDPT(A6)
		MOVE.W D0,BLTSIZE(A6)	
		waitblit
		MOVE.W #$100,BLTCON0(A6)
		MOVE.L A4,BLTDPT(A6)
		MOVE.W D0,BLTSIZE(A6)		; clear buffer
.endoffill	RTS

col		DS.W 1 
 
; Shape data 
 
cube		DC.W 0,0,0 
		DC.W 8 
		DC.W 0,0,$a00 
		DC.W -800,-800,-800 
		DC.W 800,-800,-800 
		DC.W 800,-800,800 
		DC.W -800,-800,800 
		DC.W -800,800,-800 
		DC.W 800,800,-800 
		DC.W 800,800,800 
		DC.W -800,800,800 
		DC.W 6 
		DC.W 07,4,04*4,07*4,03*4,00*4 
		DC.W 06,4,02*4,06*4,05*4,01*4 
		DC.W 05,4,03*4,07*4,06*4,02*4 
		DC.W 04,4,01*4,05*4,04*4,00*4 
		DC.W 03,4,03*4,02*4,01*4,00*4 
		DC.W 02,4,06*4,07*4,04*4,05*4 
 
thargoid	DC.W 0,0,0	 
		DC.W 16 
		DC.W 0,0,$1300 
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
		DC.W 7,8,00*4,01*4,02*4,03*4,04*4,05*4,06*4,07*4 
		DC.W 7,8,15*4,14*4,13*4,12*4,11*4,10*4,09*4,08*4 
		DC.W 1,4,06*4,14*4,15*4,07*4 
		DC.W 2,4,05*4,13*4,14*4,06*4 
		DC.W 3,4,04*4,12*4,13*4,05*4 
		DC.W 4,4,03*4,11*4,12*4,04*4 
		DC.W 5,4,02*4,10*4,11*4,03*4 
		DC.W 4,4,01*4,09*4,10*4,02*4 
		DC.W 3,4,00*4,08*4,09*4,01*4 
		DC.W 2,4,07*4,15*4,08*4,00*4 
 
station		DC.W 0,0,0 
		DC.W 12 
		DC.W 0,0,$500 
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
		DC.W 5,3,00*4,01*4,02*4 
		DC.W 4,3,09*4,11*4,10*4 
		DC.W 1,3,04*4,08*4,09*4 
		DC.W 2,3,01*4,03*4,08*4 
		DC.W 3,3,03*4,07*4,11*4 
		DC.W 4,3,00*4,05*4,07*4 
		DC.W 5,3,05*4,06*4,10*4 
		DC.W 7,3,02*4,04*4,06*4 
		DC.W 6,4,00*4,02*4,06*4,05*4 
		DC.W 5,4,04*4,02*4,01*4,08*4 
		DC.W 4,4,00*4,07*4,03*4,01*4 
		DC.W 3,4,07*4,05*4,10*4,11*4 
		DC.W 2,4,08*4,03*4,11*4,09*4 
		DC.W 1,4,06*4,04*4,09*4,10*4 
 
asteriod	DC.W 0,0,0 
		DC.W 12 
		DC.W 0,0,$200 
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
		DC.W 01*40,3,01*4,02*4,04*4 
		DC.W 00*40,3,01*4,00*4,02*4 
		DC.W 01*40,3,02*4,00*4,05*4 
		DC.W 00*40,3,02*4,05*4,06*4 
		DC.W 01*40,3,02*4,06*4,04*4 
		DC.W 02*40,3,04*4,06*4,09*4 
		DC.W 01*40,3,04*4,09*4,08*4 
		DC.W 01*40,3,01*4,04*4,08*4 
		DC.W 02*40,3,03*4,01*4,08*4 
		DC.W 00*40,3,00*4,01*4,03*4 
		DC.W 01*40,3,07*4,11*4,10*4 
		DC.W 02*40,3,00*4,07*4,05*4 
		DC.W 01*40,3,10*4,05*4,07*4 
		DC.W 00*40,3,06*4,05*4,10*4 
		DC.W 01*40,3,06*4,10*4,09*4 
		DC.W 02*40,3,09*4,10*4,11*4 
		DC.W 01*40,3,08*4,09*4,11*4 
		DC.W 00*40,3,03*4,08*4,11*4 
		DC.W 00*40,3,03*4,11*4,07*4 
		DC.W 01*40,3,00*4,03*4,07*4 
 
Ship		DC.W 0,0,0 
		DC.W 7	 
		DC.W 0,0,$150 
		DC.W -200,0,0 
		DC.W 0,50,0 
		DC.W 200,0,0 
		DC.W 50,-50,0 
		DC.W 0,-100,0 
		DC.W -50,-50,0 
		DC.W 0,0,-300 
		DC.W 10	 
		DC.W 1*40,3,0*4,1*4,5*4 
		DC.W 2*40,3,1*4,3*4,5*4 
		DC.W 3*40,3,1*4,2*4,3*4 
		DC.W 4*40,3,5*4,3*4,4*4 
		DC.W 5*40,3,6*4,2*4,1*4 
		DC.W 6*40,3,6*4,1*4,0*4 
		DC.W 7*40,3,4*4,3*4,6*4 
		DC.W 8*40,3,5*4,4*4,6*4 
		DC.W 9*40,3,3*4,2*4,6*4 
		DC.W 10*40,3,0*4,5*4,6*4 
	 
House		DC.W 0,0,0 
		DC.W 10 
		DC.W 0,0,$400 
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
		DC.W 0*40,4,0*4,1*4,2*4,3*4 
		DC.W 1*40,4,7*4,6*4,5*4,4*4 
		DC.W 2*40,5,0*4,3*4,7*4,4*4,8*4 
		DC.W 3*40,5,1*4,9*4,5*4,6*4,2*4 
		DC.W 2*40,4,8*4,9*4,1*4,0*4 
		DC.W 1*40,4,4*4,5*4,9*4,8*4 
		DC.W 0*40,4,6*4,7*4,3*4,2*4 
 
 
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

 		section bss
draw_buf	ds.l no_planes*10*256
screen1		ds.b 50000
screen2		ds.b 50000
multable	ds.b 65536
		ds.l 499
stack		ds.l 1