 		******************************
	     ******                        ******
           ****        SURFACE MAPPING         ****
	  ****     ROUTINES FOR USE IN CD-I 	****
           ****	        STUFF FOR SPC          ****
             ******                        ******
                ******************************

			OPT	O+,W-

*****************************USEFUL EQUATES**********************************

max_height:	EQU	200

logbase:	DC.L	0
physbase:	DC.L	0
logbase2	DC.L	0

screen1_lines:	DZ.L	480
screen2_lines:	DZ.L	480
screen3_lines:	DZ.L	480

offset_table:
x_angle:	DC.W	0
y_angle:	DC.W	0
z_angle:	DC.W	0
x_offset:	DC.W	0
y_offset:	DC.W	0
z_offset:	DC.W	1500

coordata:
	DC.W	-300,-300,-300
	DC.W	300,-300,-300
	DC.W	300,330,-300
	DC.W	-300,330,-300
	DC.W	-300,-300,300
	DC.W	300,-300,300
	DC.W	300,330,300
	DC.W	-300,330,300

surface_list:
	DC.W	0*4,0,0,1*4,103,0,2*4,103,118*256,3*4,0,118*256
	DC.L	GFX_DATA
	DC.W	1*4,0,0,5*4,103,0,6*4,103,118*256,2*4,0,118*256
	DC.L	GFX_DATA
	DC.W	4*4,0,0,5*4,103,0,1*4,103,118*256,0*4,0,118*256
	DC.L	GFX_DATA
	DC.W	3*4,0,0,2*4,103,0,6*4,103,118*256,7*4,0,118*256
	DC.L	GFX_DATA
	DC.W	5*4,0,0,4*4,103,0,7*4,103,118*256,6*4,0,118*256
	DC.L	GFX_DATA
	DC.W	4*4,0,0,0*4,103,0,3*4,103,118*256,7*4,0,118*256
	DC.L	GFX_DATA

final_points:	DZ.W	2*8

current_gfx:	DC.L	0
safe_place:	DC.L	0

points:
		DS.W	4*4*2

sintab:		dz.b	1440

trigbuff:	DZ.W 	6
matrix:		DZ.W 	9
polygon_img:	DZ.W	400
x_gfx_gradient:	DZ.W	400
y_gfx_gradient:	DZ.W	400
gfx_data:	DZ.B	(120*256)		height of gfx!!!
divutab:	DZ.B	16384

grad_table:	INCBIN	A:\TEXTURE\GRAD_TAB.DAT

mapping_gfx:		here must come the gfx!!

**************************END OF USEFUL EQUATES******************************

*IN THE BEGINNING THERE WAS NOTHING.................

START:

init_asm:

Things that will be needed.

A routine to pad all gfx out to 256 bytes per line.
A routine to create a sin table values -32767 to +32767 (2*360deg)
A routine to initialise 3 screens of LCTs
convert the grad_table into a liost of dc.bs!!!

	BSR	create_projivu

	RTS

test_asm:
	MOVEM.L	logbase(a6),D0-D2		rotate screen  pointers
	MOVEM.L	D0-D1,logbase+4(a6)
	MOVE.L	D2,logbase(a6)

*	BSR	CLEAR_LOGBASE

	BSR	transform_coordinates
	BSR	draw_textured_surface

	BRA.S	test_asm

*********************************************
* ROUTINE TO DRAW A PIECE OF GRAPHICS ONTO  *
* A 2D SURFACES WITH 4 POINTS SPECIFIED     *
*********************************************

draw_textured_surface:
	LEA	surface_list(a6),A1
	MOVEQ	#5,D7
surface_loop:
	LEA	points(a6),A0
	LEA	final_points(a6),A5
	MOVE.W	(A1)+,D0		POINT 1
	MOVE.L	(A5,D0.W),(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.W	(A1)+,D0		POINT 2
	MOVE.L	(A5,D0.W),(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.W	(A1)+,D0		POINT 3
	MOVE.L	(A5,D0.W),(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.W	(A1)+,D0		POINT 4
	MOVE.L	(A5,D0.W),(A0)+
	MOVE.L	(A1)+,(A0)+

	MOVE.L	(A1)+,current_gfx(a6)

	MOVE.L	A1,-(A7)
	MOVE.W	D7,-(A7)

	MOVE.W	-32(A0),D0
	MOVE.W	-30(A0),D1
	MOVE.W	-24(A0),D2
	MOVE.W	-22(A0),D3
	MOVE.W	-16(A0),D4
	MOVE.W	-14(A0),D5
	SUB.W	D0,D4			CHECK VISIBILITY
	SUB.W	D1,D5
	SUB.W	D0,D2
	SUB.W	D1,D3
	MULS	D4,D3
	MULS	D5,D2
	SUB.L	D2,D3
	BPL	nothing_to_draw

	LEA	-32(A0),A0
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,32(A0)

	MOVE.L	(A0),D4
	ADDQ.L	#8,A0
	MOVE.L	D4,D1
	MOVE.L	A0,A4

	MOVE.L 	(A0),D3
	ADDQ.L	#8,A0
	CMP.W 	D3,D4
	BGE.S	lab1
	MOVE.W 	D3,D4
	BRA.S	lab2
lab1:	MOVE.L	A0,A4
	MOVE.W	D3,D1
lab2:
	MOVE.L 	(A0),D3
	ADDQ.L	#8,A0
	CMP.W 	D3,D4
	BGE.S	lab3
	MOVE.W 	D3,D4
	BRA.S	lab4
lab3:
	CMP.W	D3,D1
	BLE.S	lab4
	MOVE.L	A0,A4
	MOVE.W	D3,D1
lab4:
	MOVE.L 	(A0),D3
	ADDQ.L	#8,A0
	CMP.W 	D3,D4
	BGE.S	lab5
	MOVE.W 	D3,D4
	BRA.S	lab6
lab5:
	CMP.W	D3,D1
	BLE.S	lab6
	MOVE.L	A0,A4
	MOVE.W	D3,D1
lab6:

	LEA	24(A4),A3
	SUBQ.L	#8,A4

	SUB.W 	2(A4),D4		*ADDRESS OF TOP MOST POINT
	BEQ 	abort_poly		*0 LINES TO DRAW!!

	MOVE.L 	(A4),D0
	ADDQ.L	#8,A4
	CMP.W 	2(A4),D0		*CHECK TO SEE IF BOTTOM IS FLAT
	BNE.S 	lab7
	ADDQ.L 	#8,A4			*YEP IT IS 
lab7:
	CMP.W 	-6(A3),D0
	BNE.S 	lab8
	SUBQ.L 	#8,A3
lab8:

	MOVE.L 	logbase(a6),A5		GET SCREEN ADDRESS
	LSL.W	#7,D0			Y*384
	ADD.W	D0,A5
	ADD.W	D0,D0
	ADD.W	D0,A5
	MOVE.L	A5,-(A7)

	LEA	polygon_img(a6),A0
	LEA	y_gfx_gradient(a6),A5
	MOVE.L	A5,safe_place1(A6)
	LEA	x_gfx_gradient(a6),A5
	LEA	grad_table+640(a6),A1
	MOVE.W	D4,D6
left_again:
	MOVE.L 	(A3),D3
	SUBQ.L	#4,A3
	MOVE.W 	-(A3),D5
	SUB.W 	D3,D5
	CLR.W 	D3
	MOVE.W 	D5,D0
	MOVE.W 	-(A3),D1
	SUB.W 	8(A3),D1
	ADD.W	D0,D0
	MULS	(A1,D0.W),D1
	ADD.L	D1,D1

	SUB.W	D5,D6
	SWAP	D1
	SWAP	D3
	ADD.W	D5,D5	
	ADD.W	D5,D5
	NEG.W	D5
	LEA	calc_tablea1(PC),A2
	JMP	(A2,D5.W)
	REPT	max_height
	ADDX.L	D1,D3
	MOVE.W	D3,(A0)+
	ENDR
calc_tablea1:

	MOVE.W	4(A3),D7		X LIGHT GRADIENT
	SUB.W	12(A3),D7
	BEQ.S	lab9
	MOVEQ	#0,D1
	MOVE.W	12(A3),D1
	MULS	(A1,D0.W),D7
	ADD.L	D7,D7
	SWAP	D7

	LEA	calc_table2(pc),A2
	JSR	(A2,D5.W)
	BRA.S	lab10
lab9:
	LEA	calc_table4(PC),A2
	MOVE.W	D5,D1
	ASR.W	#1,D1
	MOVE.W	12(A3),D7
	JSR	(A2,D1.W)
lab10:
	MOVE.W	6(A3),D7		X LIGHT GRADIENT
	SUB.W	14(A3),D7
	BEQ.S	lab11
	MOVEQ	#0,D1
	MOVE.W	14(A3),D1
	MULS	(A1,D0.W),D7
	ADD.L	D7,D7
	SWAP	D7

	MOVE.L	a4,-(a7)
	MOVE.L	safe_place1(a6),a4
	LEA	calc_table3(PC),A2
	JSR	(A2,D5.W)
	BRA.S	lab12
lab11:
	MOVE.L	a4,-(a7)
	MOVE.l	safe_place1(a6),a4
	LEA	calc_table5(PC),A2
	MOVE.W	D5,D1
	ASR.W	#1,D1
	MOVE.W	14(A3),D7
	JSR	(A2,D1.W)
lab12:
	MOVE.L	a4,safe_place1(a6)
	MOVE.L	(a7)+,a4

	TST.W	D6
	BNE	left_again
	
*DO RIGHT HAND OF POLYGON
	LEA	polygon_img+400(a6),A0
	LEA	y_gfx_gradient+400(a6),A5
	MOVE.L	a5,safe_place1(a6)
	LEA	x_gfx_gradient+400(a6),A5
	MOVE.W	D4,D6
	
right_again:
	MOVE.L 	-8(A4),D3
	MOVE.W  (A4),D1
	MOVE.W  2(A4),D5
	ADDQ.L	#8,A4
	SUB.W   D3,D5
	CLR.W   D3
	MOVE.W  D5,D0
	SUB.W   -16(A4),D1
	ADD.W	D0,D0
	MULS	(A1,D0.W),D1
	ADD.L	D1,D1

	SUB.W	D5,D6
	SWAP	D1
	SWAP	D3
	ADD.W	D5,D5	
	ADD.W	D5,D5
	NEG.W	D5
	LEA	calc_tableb1(PC),A2
	JMP	(A2,D5.W)
	REPT	max_height
	ADDX.L	D1,D3
	MOVE.W	D3,(A0)+
	ENDR
calc_tableb1:

	MOVE.W	-4(A4),D7
	SUB.W	-12(A4),D7
	BEQ.S	lab13
	MULS	(A1,D0.W),D7
	ADD.L	D7,D7
	SWAP	D7
	MOVEQ	#0,D1
	MOVE.W	-12(A4),D1

	LEA	calc_table2(PC),A2
	JSR	(A2,D5.W)
	BRA.S	lab14
lab13:
	LEA	calc_table4(PC),A2
	MOVE.W	D5,D1
	ASR.W	#1,D1
	MOVE.W	-12(A4),D7
	JSR	(A2,D1.W)
lab14:

	MOVE.W	-2(A4),D7
	SUB.W	-10(A4),D7
	BEQ.S	lab15
	MULS	(A1,D0.W),D7
	ADD.L	D7,D7
	SWAP	D7
	MOVEQ	#0,D1
	MOVE.W	-10(A4),D1

	MOVE.L	a4,-(a7)
	MOVE.L	safe_place1(a6),a4
	LEA	calc_table3(PC),A2
	JSR	(A2,D5.W)
	BRA.S	lab16
lab15:
	MOVE.L	a4,-(a7)
	MOVE.L	safe_place1(a6),a4
	LEA	calc_table5(PC),A2
	MOVE.W	D5,D1
	ASR.W	#1,D1
	MOVE.W	-10(A4),D7
	JSR	(A2,D1.W)
lab16:
	MOVE.L	a4,safe_place1(a6)
	MOVE.L	(a7)+,a4

	TST.W	D6
	BNE	right_again

	MOVE.L	(A7)+,A4
	LEA	polygon_img(a6),A0
	MOVE.L	current_gfx(a6),A1
	LEA	grad_table+640(a6),A2
	LEA	x_gfx_gradient(a6),A3
	MOVEQ	#0,D1
	SUBQ.W	#1,D4
	MOVEQ	#0,D0
line_loop:
	MOVE.W	(A0)+,D3
	MOVE.W	398(A0),D5
	SUB.W	D3,D5			D5 IS WIDTH
	MOVE.W	400(A3),D6
	SUB.W	(A3)+,D6		GET X DISTANCE (GFX)

	MOVE.W	798+400(A3),D7		GET Y DISTANCE (GFX)
	SUB.W	798(A3),D7

	MOVE.W	D5,D2
	ADD.W	D2,D2
	MULS	(A2,D2.W),D6
	ADD.L	D6,D6
	SWAP	D6			X GFX GRADIENT
	MULS	(A2,D2.W),D7
	ADD.L	D7,D7
	SWAP	D7			Y GFX GRADIENT

	SUBQ.W	#1,D5
	BMI.S	forget_it

	LEA	(A4,D3.W),A5

	MOVEQ	#0,D2			GET INTIAL X GFX
	MOVE.W	-2(A3),D2
	MOVEQ	#0,D1			GET INTIAL Y GFX
	MOVE.W	798(A3),D1

	MOVEQ	#0,D3

	MOVE.W	D1,D3
	MOVE.B	D2,D3

	MOVE.W	D4,-(A7)
	MOVEQ	#0,D4
	MOVE.B	(A1,D3.W),(A5)+
	BSR	the_plotter	
	MOVE.W	(A7)+,D4
forget_it:
	LEA	384(A4),A4	
	DBF	D4,line_loop
nothing_to_draw:
	MOVE.W	(A7)+,D7
	MOVE.L	(A7)+,A1
	DBF	D7,surface_loop
	RTS

	REPT	max_height
	ADDX.L	D7,D1
	MOVE.W	D1,(A5)+
	ENDR
calc_table2:
	RTS

	REPT	max_height
	ADDX.L	D7,D1
	MOVE.W	D1,(A5)+
	ENDR
calc_table3:
	RTS

	REPT	max_height
	MOVE.W	D7,(A5)+
	ENDR
calc_table4:
	RTS

	REPT	max_height
	MOVE.W	D7,(A5)+
	ENDR
calc_table5:
	RTS

the_plotter:
	ADD.L	D7,D1
	ADDX.W	D0,D1
	MOVE.W	D1,D3
	ADD.L	D6,D2
	ADDX.W	D0,D2
	MOVE.B	D2,D3
	MOVE.B	(A1,D3.W),(A5)+
	DBF	D5,the_plotter
	RTS

abort_poly:	RTS

*****************************************************	
*	THIS IS THE COORDINATE CALCULATION ROUTINE
*****************************************************

TRANSFORM_COORDINATES:
	LEA 	trigbuff(PC),A2	
	LEA 	sintab(PC),A0		GET SINE TABLE
	LEA 	180(A0),A1		COS= SIN + 90 DEGREES! (HARD THAT ONE!)
	LEA	offset_table(PC),A3
	MOVEM.W (A3),D0-D2	  	GET THE X,Y,Z ANGLE OF OBJECT  	
	ADD.W 	D0,D0			MAKE WORD LENGTH
	MOVE.W 	(A0,D0.W),(A2)+		PUTIN BUFFER
	MOVE.W 	(A1,D0.W),(A2)+
	ADD.W 	D1,D1
	MOVE.W 	(A0,D1.W),(A2)+
	MOVE.W 	(A1,D1.W),(A2)+	
	ADD.W 	D2,D2
	MOVE.W 	(A0,D2.W),(A2)+
	MOVE.W 	(A1,D2.W),(A2)
	LEA 	-10(A2),A0		BACK TO START OF SIN AND COS VALUES FOR 

	LEA 	matrix(a6),A1		GET MATRIX STORE
* sinz*sinx(used twice) - D3
	MOVE 	8(A0),D0		sinz
	MOVE 	(A0),D3			sinx
	MULS 	D0,D3
	ADD.L 	D3,D3
	SWAP 	D3			SINX * SINZ
* sinz*cosx(used twice) - D4
	MOVE 	2(A0),D4 		cosx(d0=sinz already)
	MULS 	D0,D4
	ADD.L 	D4,D4
	SWAP 	D4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
	MOVE 	6(A0),D0  		cosy
	MOVE 	2(A0),D1  		cosx
	MULS 	D1,D0			cosy*cosx
	MOVE 	4(A0),D1		siny
	MULS 	D3,D1			
	SUB.L 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			siny*(sinz*sinx)
	MOVE 	D0,(A1)+
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
	MOVE 	4(A0),D0		siny
	MOVE 	2(A0),D1		cosx
	MULS 	D1,D0			siny*cosx
	MOVE 	6(A0),D1		cosy
	MULS 	D3,D1			
	ADD.L 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			cosy*(sinz*sinx)
	MOVE 	D0,(A1)+
* Matrix(3,1) -cosz*sinx
	MOVE 	10(A0),D0		cosz
	NEG D0
	MOVE 	(A0),D1			sinx
	MULS 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			cosz*sinx
	MOVE 	D0,(A1)+
* Matrix(1,2) -siny*cosz
	MOVE 	4(A0),D0		siny
	NEG 	D0			-siny
	MOVE 	10(A0),D1		cosz
	MULS 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			siny*cosz
	MOVE 	D0,(A1)+
* Matrix(2,2) cosy*cosz		
	MOVE 	6(A0),D0		cosy
	MOVE 	10(A0),D1		cosz
	MULS 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0
	MOVE 	D0,(A1)+
* Matrix(3,2) sinz 
	MOVE 	8(A0),(A1)+
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
	MOVE 	6(A0),D0		cosy
	MOVE 	(A0),D1			sinx
	MULS 	D1,D0			cosy*sinx
	MOVE 	4(A0),D1		siny
	MULS 	D4,D1
	ADD.L 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			siny*(sinz*cosx)
	MOVE 	D0,(A1)+
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
	MOVE 	4(A0),D0		siny
	MOVE 	(A0),D1		sinx
	MULS 	D1,D0			siny*sinx		
	MOVE 	6(A0),D1		cosy
	MULS 	D4,D1	
	SUB.L 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			cosy*(sinz*cosx)
	MOVE 	D0,(A1)+
* Matrix(3,3) cosz*cosx
	MOVE 	10(A0),D0		cosz
	MOVE 	2(A0),D1		cosx
	MULS 	D1,D0
	ADD.L 	D0,D0
	SWAP 	D0			cosz*cosx
	MOVE 	D0,(A1)

	LEA 	matrix(a6),A2		POINTER FOR ROTATION MATRIX
	MOVEA 	#192,A3			CENTRE	X
	LEA	divutab(a6),a4
	MOVE.W 	#7,D7			NUMBER OF POINTS
	LEA 	coordata(a6),A0
	LEA 	offset_table+6(a6),A5	OFFSET POSITIONS
	LEA	final_points(a6),A1
translate:
	MOVEM.W (A0),D0-D2	
	ADD.W 	(A5),D0
	ADD.W 	2(A5),D1
	MOVE.W 	D0,D3	
	MOVE.W 	D1,D4			
	MOVE.W 	D2,D5
	MULS 	(A2)+,D0			
	MULS 	(A2)+,D1		
	MULS 	(A2)+,D2
	ADD.L 	D1,D0
	ADD.L 	D2,D0
	ADD.L 	D0,D0
	SWAP 	D0			
	MULS 	(A2)+,D3
	MULS 	(A2)+,D4		
	MULS 	(A2)+,D5
	ADD.L 	D4,D3
	ADD.L 	D5,D3
	ADD.L 	D3,D3
	SWAP 	D3			
	MOVEM.W (A0)+,D1/D2/D4
	MULS 	(A2)+,D1
	MULS 	(A2)+,D2		
	MULS 	(A2)+,D4
	ADD.L 	D1,D4
	ADD.L 	D2,D4
	ADD.L 	D4,D4
	SWAP 	D4			
	ADD.W 	4(A5),D4

	ADD.W	D4,D4			*
	MOVE.W	(A4,D4.W),D1		*PERSPECTIVE
	MULS	D1,D0			*CALCULATION
	MULS	D1,D3			*USING TABLE
	SWAP	D0			*
	SWAP	D3			*

	ADD.W	A3,D0			ADD CENTREX
	ADD.W	#120,D3			ADD CENTREY

	MOVE.W 	D0,(A1)+
	MOVE.W 	D3,(A1)+
	LEA 	-18(A2),A2		
	DBF 	D7,translate
	RTS

create_projdivu:
	LEA	divutab(a6),A0
	MOVE.L	#(16777216*3)/2,D1
	MOVE.L	#16384,D2
	MOVE.W	#16383,D0
proj_loop:
	MOVE.L	D2,D3
	SUB.L	D0,D3
	LSL.L	#1,D3
	MOVE.L	D1,D4
	DIVU	D3,D4
	MOVE.W	D4,(A0)+
	SUBQ.W	#1,D0
	CMP.W	#8192,D0
	BNE.S	proj_loop
	RTS


