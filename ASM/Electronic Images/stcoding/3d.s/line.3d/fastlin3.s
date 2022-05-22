;-----------------------------------------------------------------------;
; 3D Vector rotation routine V5, By Martin Griffiths Jan 1990 June 1991.;				;
; Various updates/improvements:-					;
; January 90 - version of Bresenhams line algorithm implemented.	;
; March 90 - Calculation improvements taken from my solid 3d version.	;
; August 90 - Hyper-superdupa optimisation of Bresenhams - fast!!!	;
; October 90 - Even Faster line drawer with more cases developed        ;
; March 91 - New clipper not based on SH outcodes implemented 2* fast   ; 
;-----------------------------------------------------------------------;

xmin		EQU 0
ymin		EQU 0
xmax		EQU 319
ymax		EQU 199

dist		EQU 256
		
Init		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			;change rez
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)				
		TRAP #1				;super
		ADDQ.L #6,SP
		LEA stack,SP
		BSR Init_ints
		BSR makeperstab
		BSR makebit_offs
		BSR create160tb
		BSR Makelinedraw
		MOVE.L #$00000555,$FFFF8240.W	;quick palette
clear_scrns	MOVE.L log_base,A0
		MOVEQ #0,D0
		MOVE #4999,D1	
clr_all		MOVE.L D0,(A0)+			;clear screens
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,clr_all

; Main loop for rotation of object

Rotate		LEA dart,A5
		ADD #8,(A5)
		ADD #6,2(A5)			;add rotation factors
		ADD #7,4(A5)
		AND #$3FF,(A5)
		AND #$3FF,2(A5)			;mod 'em
		AND #$3FF,4(A5)
		BSR Show_obj			;draw it!
		BSR sw_clr			;swap'n'clear
		BTST.B #0,$FFFFFC00.W		
		BEQ Rotate
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0			;space pressed?
		BNE Rotate			;if not continue rotating

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W	;restore mfp
		MOVE.B (A0)+,$FFFFFA15.W		
		MOVE.L old_vbl,$70.W		;and vbl
		MOVE.L #$07770000,$FFFF8240.W	;palette
		MOVE #$2300,SR	
		CLR -(SP)			;bye...
		TRAP #1

Init_ints	MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+	;save mfp stuff
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W		;clear mfp(ints off)
		CLR.B $FFFFFA15.W
		MOVE.L $70.W,old_vbl
		MOVE.L #my_vbl,$70.W		;my vbl 
		MOVE #$2300,SR
		RTS

makeperstab	LEA PERSTABLE,A0
		MOVE #dist+1,D0
		MOVE #32768-dist-2,D1
.lp1		MOVE.L #32768*dist,D2
		DIVS D0,D2
		MOVE.W D2,(A0)+
		ADDQ #1,D0
		DBF D1,.lp1
		RTS

create160tb	LEA mul_tab,A0
		MOVEQ #0,D0			;create *160 table
		MOVE #199,D1
mke_t160_lp	MOVE D0,(A0)+
		ADD #160,D0
		DBF D1,mke_t160_lp
		RTS

makebit_offs	LEA bit_offs,A0
		MOVEQ #0,D1
		MOVEQ #19,D3
.lp1		MOVE.W #$8000,D0
		MOVEQ #15,D2
.lp2		MOVE.W D0,(A0)+
		MOVE.W D1,(A0)+
		LSR #1,D0
		DBF D2,.lp2
		ADDQ #8,D1
		DBF D3,.lp1
		RTS
Makelinedraw
Makesteepdown	LEA drawsteepd(PC),A0
		LEA 18(A0),A1
		MOVEQ #0,D0
		MOVE #199-1,D1
.msdlp		ADD #160,D0
		MOVE.W (A0)+,(A1)+
		MOVE.W D0,(A1)+
		ADDQ.L #2,A0
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.W (A0)+,(A1)+
		DBF D1,.msdlp
Makesteepup	LEA drawsteepu(PC),A0
		LEA 18(A0),A1
		MOVEQ #0,D0
		MOVE #199-1,D1
.msulp		SUB #160,D0
		MOVE.W (A0)+,(A1)+
		MOVE.W D0,(A1)+
		ADDQ.L #2,A0
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.W (A0)+,(A1)+
		DBF D1,.msulp
Makensteepdr	LEA notsteepdr(PC),A0
		LEA nsteep16size(A0),A1
		MOVEQ #19,D1
.mnslp		MOVE #(nsteep16size/2)-1,D2
.mnslp1		MOVE.W (A0)+,(A1)+
		DBF D2,.mnslp1
		DBF D1,.mnslp
		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; Routine to transform and draw a 3 dimensional Vectorline object.	;
; On entry:A5 points to shape data of shape to draw.				;
; On exit:D0-D7/A0-A6 Smashed!							;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Calculate a rotational matrix,from the angle data pointed by A5.
; D0-D4/A0-A1 smashed.(of no consequence since we only need to keep A5)

Show_obj	LEA trig_tab,A0			cosine table
		LEA 512(A0),A2			sine table
		LEA trig_buf(PC),A1	
		MOVEM.W (A5)+,D0-D2    		first 3 words - x,y,z (rotation in degrees)
		ADD D0,D0
		ADD D1,D1			
		ADD D2,D2
		MOVE (A0,D0),(A1)+		sin(xd)
		MOVE (A2,D0),(A1)+		cos(xd)
		MOVE (A0,D1),(A1)+		sin(yd)
		MOVE (A2,D1),(A1)+		cos(yd)
		MOVE (A0,D2),(A1)+		sin(zd)
		MOVE (A2,D2),(A1)+		cos(zd)
		LEA -12(A1),A0			sin & cos values
; sin(zd)*sin(xd) - used twice - D3
		MOVE (A0),D3			sin(xd)
		MULS 8(A0),D3			sin(zd)*sin(xd)
		ADD.L D3,D3				standard adjust
		SWAP D3				after multiply
; sin(zd)*cos(xd) - used twice - D4
		MOVE 2(A0),D4 			cos(xd)
		MULS 8(A0),D4			sin(zd)*cos(xd)
		ADD.L D4,D4
		SWAP D4
; Matrix(1,1) cos(yd)*cos(xd)-sin(yd)*sin(zd)*sin(xd)
		MOVE 6(A0),D0  			cos(yd)
		MULS 2(A0),D0			cos(yd)*cos(xd)
		MOVE 4(A0),D1			sin(yd)
		MULS D3,D1			
		SUB.L D1,D0
		ADD.L D0,D0
		SWAP D0				sin(yd)*sin(zd)*sin(xd)
		MOVE D0,M11+2
; Matrix(2,1) sin(yd)*cos(xd)+cos(yd)*sin(zd)*sin(xd) 
		MOVE 4(A0),D0			sin(yd)
		MULS 2(A0),D0			sin(yd)*cos(xd)
		MOVE 6(A0),D1			cos(yd)
		MULS D3,D1			
		ADD.L D1,D0
		ADD.L D0,D0
		SWAP D0				cos(yd)*sin(zd)*sin(xd)
		MOVE D0,M21+2
; Matrix(3,1) -cos(zd)*sin(xd)
		MOVE 10(A0),D0			
		NEG D0				-cos(zd)
		MULS (A0),D0			-cos(zd)*sin(xd)
		ADD.L D0,D0
		SWAP D0				
		MOVE D0,M31+2
; Matrix(1,2) -sin(yd)*cos(zd)
		MOVE 4(A0),D0
		NEG D0				-sin(yd)
		MULS 10(A0),D0			-sin(yd)*cos(zd)
		ADD.L D0,D0
		SWAP D0				
		MOVE D0,M12+2
; Matrix(2,2) cos(yd)*cos(zd)		
		MOVE 6(A0),D0			cos(yd)
		MULS 10(A0),D0			cos(yd)*sin(zd)
		ADD.L D0,D0
		SWAP D0
		MOVE D0,M22+2
; Matrix(3,2) sin(zd) 
		MOVE 8(A0),M32+2
; Matrix(1,3) cos(yd)*sin(xd)+sin(yd)*sin(zd)*cos(xd)
		MOVE 6(A0),D0			cos(yd)
		MULS (A0),D0			cos(yd)*sin(xd)
		MOVE 4(A0),D1			sin(yd)
		MULS D4,D1				sin(yd)*sin(zd)*cos(xd)
		ADD.L D1,D0
		ADD.L D0,D0
		SWAP D0
		MOVE D0,M13+2
; Matrix(2,3) sin(yd)*sin(xd)-cos(yd)*sin(zd)*cos(xd)
		MOVE 4(A0),D0			sin(yd)
		MULS (A0),D0			sin(yd)*sin(xd)		
		MOVE 6(A0),D1			cos(yd)
		MULS D4,D1				cos(yd)*sin(zd)*cos(xd)
		SUB.L D1,D0
		ADD.L D0,D0
		SWAP D0			
		MOVE D0,M23+2
; Matrix(3,3) cos(zd)*cos(xd)
		MOVE 10(A0),D0			cos(zd)
		MULS 2(A0),D0			cos(xd)*cos(zd)
		ADD.L D0,D0
		SWAP D0				
		MOVE D0,M33+2

; Transform and perspect co-ords.
; A5 -> x,y,z.w offsets for co-ords,D7 source co-ords x,y,z.w
; A1 -> to a storage place for the resultant x,y co-ords.
; D0-D7/A0-A4 smashed.

		MOVE (A5)+,D7			;no of verts
		LEA new_coords(PC),A1		;storage place new x,y co-ords

Trans_verts	MOVE.W (A5),addoffx+2
		MOVE.W 4(A5),addoffy+2
		MOVE.W 8(A5),addoffz+2		;(after this a5-> d7 x,y,z co-ords
		LEA 12(A5),A5
		MOVEA #160,A3			;centre x
		MOVEA #100,A4			;centre y
		SUBQ #1,D7			;verts-1
		LEA PERSTABLE,A6
trans_lp	MOVEM.W (A5)+,D0-D2		;x,y,z
		MOVE D0,D3	
		MOVE D1,D4			;dup
		MOVE D2,D5
; Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4			;Mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
; Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1			;Mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
; Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4			;Mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
; Combine and Perspect
		SWAP D0
		SWAP D1
		SWAP D2
addoffx		ADD.W #0,D0
addoffy		ADD.W #0,D1
addoffz		ADD.W #0,D2
		ADD D2,D2
		MOVE (A6,D2),D2
		MULS D2,D0
		MULS D2,D1
		SWAP D0
		SWAP D1
		ADD A3,D0			;x scr centre
		ADD A4,D1			;y scr centre
		MOVE D0,(A1)+			;new x co-ord
		MOVE D1,(A1)+			;new y co-ord
		DBF D7,trans_lp

; A5 -> total no of lines to draw. 

drawlines	MOVE (A5)+,D7
		SUBQ #1,D7			;(A5 -> line list)
		MOVE.L log_base(PC),A1
		LEA mul_tab(PC),A3
		LEA new_coords(PC),A6		;co-ords
drawline_lp	MOVE (A5)+,D1			;1st offset to vertex list
		MOVE (A5)+,D2			;2nd offset to vertex list
cont_line	MOVEM (A6,D1),D0-D1		;get x1,y1
		MOVEM (A6,D2),D2-D3		; "  x2,y2
		BSR Drawline
		DBF D7,drawline_lp
		RTS

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.	;
; D0-D3 holds x1,y1/x2,y2 A1 -> screen base. A3-> *160 table		;
;-----------------------------------------------------------------------;

Drawline
clipony		CMP.W D1,D3			; y2>=y1?
		BGE.S y2big
		EXG D1,D3			; re-order
		EXG D0,D2
y2big		TST D3				; CLIP ON Y
		BLT nodraw			; totally below window? <ymin
		CMP.W #ymax,D1
		BGT nodraw			; totally above window? >ymax
		CMP.W #ymax,D3			; CLIP ON YMAX
		BLE.S okmaxy			; check that y2<=ymax 
		MOVE #ymax,D5
		SUB.W D3,D5			; ymax-y
		MOVE.W D2,D4
		SUB.W D0,D4			; dx=x2-x1
		MULS D5,D4			; (ymax-y)*(x2-x1)
		MOVE.W D3,D5
		SUB.W D1,D5			; dy
		DIVS D5,D4			; (ymax-y)*(x2-x1)/(y2-y1)
		ADD.W D4,D2
		MOVE #ymax,D3			; y1=0
okmaxy		TST.W D1			; CLIP TO YMIN
		BGE.S cliponx
		MOVEQ #0,D5
		SUB.W D1,D5			; ymin-y
		MOVE.W D2,D4
		SUB.W D0,D4			; dx=x2-x1
		MULS D5,D4			; (ymin-y1)*(x2-x1)
		MOVE.W D3,D5
		SUB.W D1,D5			; dy
		DIVS D5,D4			; (ymin-y)*(x2-x1)/(y2-y1)
		ADD.W D4,D0
		MOVEQ #0,D1			; y1=0
cliponx		CMP.W D0,D2			; CLIP ON X				
		BGE.S x2big
		EXG D0,D2			; reorder
		EXG D1,D3
x2big		TST.W D2			; totally outside <xmim
		BLT nodraw
		CMP.W #xmax,D0			; totally outside >xmax
		BGT nodraw
		CMP.W #xmax,D2			; CLIP ON XMAX
		BLE.S okmaxx	
		MOVE.W #xmax,D5
		SUB.W D2,D5			; xmax-x2
		MOVE.W D3,D4
		SUB.W D1,D4			; y2-y1
		MULS D5,D4			; (xmax-x1)*(y2-y1)
		MOVE.W D2,D5
		SUB.W D0,D5			; x2-x1
		DIVS D5,D4			; (xmax-x1)*(y2-y1)/(x2-x1)
		ADD.W D4,D3
		MOVE.W #xmax,D2
okmaxx		TST.W D0
		BGE.S .gofordraw
		MOVEQ #0,D5			; CLIP ON XMIN
		SUB.W D0,D5			; xmin-x
		MOVE.W D3,D4
		SUB.W D1,D4			; y2-y1
		MULS D5,D4			; (xmin-x)*(y2-y1)
		MOVE.W D2,D5
		SUB.W D0,D5			; x2-x1
		DIVS D5,D4			; (xmin-x)*(y2-y1)/(x2-x1)
		ADD.W D4,D1
		MOVEQ #0,D0			; x=xmin
.gofordraw	MOVE.W #160,D6			; actual 1 bpl line plotter.
		MOVE.W D1,D5
		SUB.W D3,D5			;dy
		BPL.S .notnegy
		NEG.W D5			;abs(dy)
		NEG.W D6			;reverse vert draw direction
.notnegy	MOVE.W D2,D4
		SUB.W D0,D4			;dx(always +ve cus of clipper)
		ADD D2,D2			;startx(0-319) * 4
		ADD D2,D2			;(to get mask and offset) 
		LEA bit_offs(PC),A2		;point to mask and offset table
		MOVE.L (A2,D2),D0		;mask in msw,offset in lsw
		ADD D3,D3			;start y*2
		ADD (A3,D3),D0			;add scr line to line offset
		MOVE.L A1,A0
		ADDA.W D0,A0			;screen addr
		SWAP D0				;get scr plot mask in lsw
		CMP D4,D5			;is the line steep(dy>dx)
		BGE steep			;if it is goto steep case

**********************************
* Dx > Dy line case.(not steep!) *
**********************************

notsteep	MOVE.W D4,D3
		LSR.W #1,D3				
		LSR.W #1,d2
		MOVE #30,d1
		AND D1,d2
		SUB D2,D1
		MOVE D4,D2
		ADD D2,D2
		ADD D1,D2
		LEA littleoffy(pc),A2
		MOVE.W (A2,D1),D1
		MOVE.W (A2,D2),D2		;d2 = offset into code 
		LEA notsteepdr+4(PC,d2),A2	;a2 now jump addr 
		MOVE.W (A2),D2			;get instruction there
		MOVE.W #$4E75,(A2)		;put rts there
		JSR notsteepdr+4(PC,d1)		;go!
		MOVE.W D2,(A2)			;replace instruction
		OR.W d0,(A0)
nodraw		RTS

notsteepdr	ADDQ #1,D0
		SUB.W D5,D3
		BCC.S .ns1
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns1		ADDQ #2,D0
		SUB.W D5,D3
		BCC.S .ns2
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns2		ADDQ #4,D0
		SUB.W D5,D3
		BCC.S .ns3
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns3		ADDQ #8,D0
		SUB.W D5,D3
		BCC.S .ns4
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns4		OR.W #$10,D0
		SUB.W D5,D3
		BCC.S .ns5
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns5		OR.W #$20,D0
		SUB.W D5,D3
		BCC.S .ns6
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns6		OR.W #$40,D0
		SUB.W D5,D3
		BCC.S .ns7
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns7		TAS D0				;(quicker than ori #$80,d0)
		SUB.W D5,D3
		BCC.S .ns8
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns8		OR.W #$100,D0
		SUB.W D5,D3
		BCC.S .ns9
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns9		OR.W #$200,D0
		SUB.W D5,D3
		BCC.S .ns10
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns10		OR.W #$400,D0
		SUB.W D5,D3
		BCC.S .ns11
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns11		OR.W #$800,D0
		SUB.W D5,D3
		BCC.S .ns12
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns12		OR.W #$1000,D0
		SUB.W D5,D3
		BCC.S .ns13
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns13		OR.W #$2000,D0
		SUB.W D5,D3
		BCC.S .ns14
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns14		OR.W #$4000,D0
		SUB.W D5,D3
		BCC.S .ns15
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.ns15		OR.W #$8000,D0
		SUB.W D5,D3
		BCC.S .nsendchnk
		ADD.W D4,D3
		OR D0,(A0)
		ADD.W D6,A0
		CLR D0
.nsendchnk	OR D0,(A0)
		SUBQ.W #8,A0
		CLR D0
nsteep16size	EQU *-notsteepdr
		DS.W (20*nsteep16size)+1

i		SET 0
littleoffy	REPT 21
		DC.w i
i		SET i+14
		DC.w i
i		SET i+14
		DC.w i
i		SET i+14
		DC.w i
i		SET i+14
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+14
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16
		DC.w i
i		SET i+16+6
		ENDR

* STEEP Cases... As fast as is humanly possible!

**************************************
* Dy > Dx line case (down + steep!). *
**************************************

steep		TST D6
		BMI steepup
steepdown	MOVE.W D5,D3
		LSR #1,D3			;error thingy
		MOVE.W D5,D2
		ADD D2,D2
		LEA drawsteepd(PC),A2
		ADD mul18d(PC,D2),A2
		MOVE.W (A2),D1
		MOVE #$4E75,(A2)
		BSR drawsteepd
		MOVE.W D1,(A2)
		RTS
i		SET 4
mul18d		REPT 200
		DC.W i
i		SET i+18
		ENDR
		OPT O-
drawsteepd	OR.W D0,0(A0)
		SUB.W D4,D3
		DC.W $640A				bcc.s
		ADD.W D5,D3
		ADD.W D0,D0
		DC.W $6404				bcc.s
		MOVEQ #1,D0
		SUBQ.W #8,A0
		OPT O+
		DS.W 199*9

************************************
* Dy > Dx line case (up + steep!). *
************************************

steepup		MOVE.W D5,D3
		LSR #1,D3				error thingy
		MOVE.W D5,D2
		ADD D2,D2
		LEA drawsteepu(PC),A2
		ADD mul18u(PC,D2),A2
		MOVE.W (A2),D1
		MOVE #$4E75,(A2)
		JSR drawsteepu(PC)
		MOVE.W D1,(A2)
		RTS

i		SET 4
mul18u		REPT 200
		DC.W i
i		SET i+18
		ENDR

		OPT O-
drawsteepu	OR.W D0,0(A0)
		SUB.W D4,D3
		DC.W $640A				bcc.s
		ADD.W D5,D3
		ADD.W D0,D0
		DC.W $6404				bcc.s
		MOVEQ #1,D0
		SUBQ.W #8,A0
		DS.W 199*9
		OPT O+

new_coords	DS.W 60*3
trig_buf	DS.W 6

;-----------------------------------------------------------------------;

; Swap screens and clear old one.

sw_clr  	LEA log_base(PC),A0
		MOVEM.L (A0)+,D6-D7
		MOVE.L D6,-(A0)
		MOVE.L D7,-(A0)
		LSR #8,D6
		MOVE.L D6,$FFFF8200.W
		not $ffff8240.w
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S wait_vbl
		not $ffff8240.w
clearscreen	MOVE.L D7,A0
		MOVEQ #0,D0
		MOVE #199,D1
.clear_lp	MOVE D0,(A0)
		MOVE D0,8(A0)
		MOVE D0,16(A0)
		MOVE D0,24(A0)
		MOVE D0,32(A0)
		MOVE D0,40(A0)
		MOVE D0,48(A0)
		MOVE D0,56(A0)
		MOVE D0,64(A0)
		MOVE D0,72(A0)
		MOVE D0,80(A0)
		MOVE D0,88(A0)
		MOVE D0,96(A0)
		MOVE D0,104(A0)
		MOVE D0,112(A0)
		MOVE D0,120(A0)
		MOVE D0,128(A0)
		MOVE D0,136(A0)
		MOVE D0,144(A0)
		MOVE D0,152(A0)
		LEA 160(A0),A0
		DBF D1,.clear_lp
		RTS

my_vbl		ADDQ #1,vbl_timer
		RTE

coolship	DS.W 3
		DC.W 22
		DC.L 0,0,$9000000
		DC.W 150*16,-10*16,20*16
		DC.W 150*16,-10*16,-20*16
		DC.W 184*16,-10*16,0*16
		DC.W -32*16,-10*16,-30*16
		DC.W -32*16,-10*16,30*16
		DC.W -40*16,30*16,180*16
		DC.W -40*16,30*16,-180*16
		DC.W -70*16,30*16,-180*16
		DC.W -70*16,30*16,180*16
		DC.W 10*16,30*16,180*16
		DC.W 10*16,30*16,-180*16
		DC.W -70*16,-10*16,-30*16
		DC.W -70*16,-10*16,30*16
		DC.W 130*16,10*16,-10*16
		DC.W 130*16,10*16,10*16
		DC.W -32*16,10*16,-16*16
		DC.W -32*16,10*16,16*16
		DC.W -60*16,44*16,-180*16
		DC.W -60*16,44*16,180*16
		DC.W 250*16,-10*16,0*16
		DC.W -120*16,30*16,-180*16
		DC.W -120*16,30*16,180*16
		DC.W 25 
		DC.W (26-24)*4,(24-24)*4
		DC.W (24-24)*4,(28-24)*4
		DC.W (28-24)*4,(29-24)*4
		DC.W (33-24)*4,(45-24)*4
		DC.W (32-24)*4,(36-24)*4
		DC.W (36-24)*4,(35-24)*4
		DC.W (35-24)*4,(31-24)*4
		DC.W (34-24)*4,(44-24)*4
		DC.W (30-24)*4,(27-24)*4
		DC.W (27-24)*4,(25-24)*4
		DC.W (25-24)*4,(26-24)*4
		DC.W (39-24)*4,(37-24)*4
		DC.W (37-24)*4,(26-24)*4
		DC.W (26-24)*4,(38-24)*4
		DC.W (38-24)*4,(40-24)*4
		DC.W (40-24)*4,(39-24)*4
		DC.W (39-24)*4,(35-24)*4
		DC.W (35-24)*4,(27-24)*4
		DC.W (28-24)*4,(36-24)*4
		DC.W (36-24)*4,(40-24)*4
		DC.W (44-24)*4,(41-24)*4
		DC.W (41-24)*4,(34-24)*4
		DC.W (33-24)*4,(42-24)*4
		DC.W (42-24)*4,(45-24)*4
		DC.W (26-24)*4,(43-24)*4

dart	 	DS.W 3
		DC.W 27
		DC.L 0,0,$6000000
		DC.W 0*32,0*32,-60*32
		DC.W -5*32,0*32,-30*32
		DC.W 5*32,0*32,-30*32
		DC.W -10*32,0*32,10*32
		DC.W 10*32,0*32,10*32
		DC.W 2*32,0*32,60*32
		DC.W -2*32,0*32,60*32
		DC.W 25*32,0*32,70*32
		DC.W 25*32,0*32,90*32
		DC.W -25*32,0*32,90*32
		DC.W -25*32,0*32,70*32
		DC.W -2*32,0*32,98*32
		DC.W 2*32,0*32,98*32
		DC.W 2*32,0*32,90*32
		DC.W -2*32,0*32,90*32
		DC.W 0*32,10*32,-30*32
		DC.W 0*32,10*32,10*32
		DC.W 0*32,6*32,60*32
		DC.W 0*32,24*32,90*32
		DC.W 0*32,24*32,70*32
		DC.W 0*32,-10*32,-30*32
		DC.W 0*32,-10*32,10*32
		DC.W 0*32,-6*32,60*32
		DC.W 0*32,0*32,-80*32
		DC.W 0*32,-24*32,90*32
		DC.W 0*32,-24*32,70*32
		DC.W 2*32,0*32,60*32
		DC.W 42
		DC.W 09*4,14*4
		DC.W 08*4,13*4
		DC.W 08*4,07*4
		DC.W 07*4,05*4
		DC.W 09*4,10*4
		DC.W 10*4,06*4
		DC.W 11*4,06*4
		DC.W 06*4,03*4
		DC.W 03*4,01*4
		DC.W 01*4,00*4
		DC.W 00*4,02*4
		DC.W 02*4,04*4
		DC.W 04*4,05*4
		DC.W 05*4,12*4
		DC.W 12*4,11*4
		DC.W 17*4,16*4
		DC.W 16*4,15*4
		DC.W 00*4,15*4
		DC.W 18*4,19*4
		DC.W 19*4,17*4
		DC.W 14*4,18*4
		DC.W 18*4,13*4
		DC.W 22*4,21*4
		DC.W 21*4,20*4
		DC.W 20*4,00*4
		DC.W 23*4,00*4
		DC.W 24*4,25*4
		DC.W 25*4,22*4
		DC.W 14*4,24*4
		DC.W 24*4,13*4
		DC.W 03*4,16*4
		DC.W 16*4,04*4
		DC.W 02*4,15*4
		DC.W 15*4,01*4
		DC.W 01*4,20*4
		DC.W 20*4,02*4
		DC.W 04*4,21*4
		DC.W 21*4,03*4
		DC.W 17*4,05*4
		DC.W 06*4,17*4
		DC.W 22*4,05*4
		DC.W 06*4,22*4

old_mfp		DS.L 4		
old_vbl		DS.L 1
vbl_timer	DS.W 1
log_base	DC.L $C8000
		DC.L $D0000
		DC.L $D8000

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
		DS.L 149
stack		DS.L 2 
mul_tab		DS.W 200
bit_offs	DS.L 320
PERSTABLE	DS.W 32768-dist


