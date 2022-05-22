 	OPT	O1+,O2+,ow-
STRUCT_NCOORDS	EQU	0
STRUCT_PCOORDS	EQU	2
STRUCT_XANGLE	EQU	6
STRUCT_YANGLE	EQU	8
STRUCT_ZANGLE	EQU	10
STRUCT_NPARTS	EQU	12
STRUCT_PPPARTS	EQU	14

SCREEN		EQU	$f8000
SCREEN1		EQU	$f0000

top		CLR.L	-(SP)
		MOVE	#$20,-(SP)
		TRAP	#1
		ADD	#6,SP

		MOVEQ	#0,D0
		JSR	MUS

		MOVE.L	#SCREEN,A0
		MOVE.L	#SCREEN1,A1
		MOVE	#8000,D0
.CLOOP		CLR.L	(A0)+
		CLR.L	(A1)+
		DBF	D0,.CLOOP
	
		CLR.B	$FF8260

		MOVE.L	$70,OLDVB
		MOVE.L	#NEWVB,$70
		
WAIT		MOVE	VB_NOW,D0
.LOOP		CMP	VB_NOW,D0
		BEQ.S	.LOOP
		
		JSR	EQUALIZE
		
		JSR	CLEARSCREEN
		
		JSR	DOSEQUENCE
		
		MOVE.L	POBJECT,A0
		JSR	ROTATE
		MOVE.L	POBJECT,A0
		JSR	DRAWOBJECT
		
		JSR	DOSCROLL

		JSR	SWAPSCREENS

		CMPI.B	#$39,$FFFC02
		BNE.S	WAIT
		
		MOVE.L	OLDVB,$70
		
		JSR	MUS+28
		
		CLR	$FF8240
		MOVE	#-1,$FF8246

		CLR	-(SP)
		TRAP	#1
		
			 ********************
TEXT		DC.B	'  S  H  A  D  O  W  '
		DC.B	'OF THE WORLD FAMOUS '
		DC.B	'    DYNAMIC  DUO    '
		DC.B	'      PRESENTS      '
		DC.B	'FILLED THREED VECTOR'
		DC.B	'GOOD DAY ALEXIS WELL'
		DC.B	'HERE IT IS A BIT    '
		DC.B	'LATE AS ALWAYS      '
		DC.B	' PLEASE DONT SPREAD '
		DC.B	' PLEASE DONT SPREAD '
		DC.B	' PLEASE DONT SPREAD '
		DC.B	' PLEASE DONT SPREAD '
		DC.B	' PLEASE DONT SPREAD '
		DC.B	0

* -------------------------------------------------------------*
CUBE		DC.W	8
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	0
		DC.L	.PPARTS
.COORDS		DC.W	0,0,0

		DC.W	-100,-100,100
		DC.W	100,-100,100
		DC.W	100,100,100
		DC.W	-100,100,100
		DC.W	-100,-100,-100
		DC.W	100,-100,-100
		DC.W	100,100,-100
		DC.W	-100,100,-100
		
.PPARTS		DC.L	.PART1
.PART1		DC.W	5
		DC.W	4,7,0,1,2,3
		DC.W	4,2,4,5,1,0
		DC.W	4,3,1,5,6,2
		DC.W	4,4,3,2,6,7
		DC.W	4,5,4,0,3,7
		DC.W	4,6,5,4,7,6
* -------------------------------------------------------------*
BIG_D		DC.W	29
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	5
		DC.L	.PPARTS
.COORDS		DC.W	-250,0,0
		DC.W	-100,-350,0
		DC.W	100,-225,0
		DC.W	150,0,0
		DC.W	100,225,0
		DC.W	-100,350,0

		DC.W	-300,400,50
		DC.W	50,400,50
		DC.W	200,50,50
		DC.W	200,-50,50
		DC.W	50,-400,50
		DC.W	-300,-400,50
		DC.W	-200,300,50
		DC.W	0,300,50
		DC.W	100,50,50
		DC.W	100,-50,50
		DC.W	0,-300,50
		DC.W	-200,-300,50
		DC.W	-300,400,-50
		DC.W	50,400,-50
		DC.W	200,50,-50
		DC.W	200,-50,-50
		DC.W	50,-400,-50
		DC.W	-300,-400,-50
		DC.W	-200,300,-50
		DC.W	0,300,-50
		DC.W	100,50,-50
		DC.W	100,-50,-50
		DC.W	0,-300,-50
		DC.W	-200,-300,-50
		
.PPARTS		DC.L	.PART1
		DC.L	.PART2
		DC.L	.PART3
		DC.L	.PART4
		DC.L	.PART5
		DC.L	.PART6
.PART1		DC.W	3
		DC.W	4,4,5,11,6,0
		DC.W	4,2,17,5,0,12
		DC.W	4,2,11,23,18,6
		DC.W	4,7,23,17,12,18
.PART2		DC.W	3
		DC.W	4,4,5,4,10,11
		DC.W	4,3,17,16,4,5
		DC.W	4,3,11,10,22,23
		DC.W	4,7,16,17,23,22
.PART3		DC.W	3
		DC.W	4,4,4,3,9,10
		DC.W	4,4,16,15,3,4
		DC.W	4,4,10,9,21,22
		DC.W	4,7,15,16,22,21
.PART4		DC.W	3
		DC.W	4,4,9,3,2,8
		DC.W	4,5,3,15,14,2
		DC.W	4,5,21,9,8,20
		DC.W	4,7,15,21,20,14
.PART5		DC.W	3
		DC.W	4,4,8,2,1,7
		DC.W	4,6,2,14,13,1
		DC.W	4,6,19,20,8,7
		DC.W	4,7,14,20,19,13
.PART6		DC.W	3
		DC.W	4,4,6,7,1,0
		DC.W	4,6,0,1,13,12
		DC.W	4,7,18,19,7,6
		DC.W	4,7,19,18,12,13
* -------------------------------------------------------------*
PLANE		DC.W	71
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	12
		DC.L	.PPARTS
.COORDS		
		DC.W	-20,105,-15		*A
		DC.W	-130,70,0		*B	
		DC.W	-20,105,-15		*C
		DC.W	-20,-105,-15		*D
		DC.W	-130,-70,0		*E
		DC.W	-30,-35,0		*F
		DC.W	-30,0,0			*G
		DC.W	-30,35,0		*H
		DC.W	145,0,-52		*I
		DC.W	150,0,-5		*J
		DC.W	-20,-105,-15		*K
		DC.W	-85,80,-75		*L
		DC.W	-85,-80,-75		*M
			
		DC.W	-80,170,-15	*0
		DC.W	-40,160,-15
		DC.W	40,80,-15		
		DC.W	100,50,-15	
		DC.W	-20,50,-15
		DC.W	-20,-50,-15
		DC.W	100,-50,-15	
		DC.W	40,-80,-15	
		DC.W	-40,-160,-15
		DC.W	-80,-170,-15 
		DC.W	-140,50,0		*1
		DC.W	-160,90,0
		DC.W	-140,90,0
		DC.W	-100,50,0
		DC.W	-140,-50,0
		DC.W	-160,-90,0
		DC.W	-140,-90,0
		DC.W	-100,-50,0
		DC.W	-160,40,-15
		DC.W	-170,40,-55
		DC.W	-150,40,-55	*2
		DC.W	-100,40,-15
		DC.W	-160,-40,-15
		DC.W	-170,-40,-55
		DC.W	-150,-40,-55
		DC.W	-100,-40,-15
		DC.W	100,20,-20
		DC.W	170,15,-17
		DC.W	170,-15,-17
		DC.W	100,-20,-20
		DC.W	100,20,10		*3
		DC.W	170,15,7
		DC.W	170,-15,7
		DC.W	100,-20,10
		DC.W	230,0,-5
		DC.W	150,-10,-18
		DC.W	150,10,-18
		DC.W	130,10,-23
		DC.W	100,10,-20
		DC.W	100,-10,-20
		DC.W	130,-10,-23	*4
		DC.W	-160,50,-15
		DC.W	-160,20,-15
		DC.W	-160,-20,-15
		DC.W	-160,-50,-15
		DC.W	100,-50,-15
		DC.W	100,50,-15
		DC.W	-160,50,15
		DC.W	-160,20,15
		DC.W	-160,-20,15
		DC.W	-160,-50,15	*5
		DC.W	60,-50,18
		DC.W	60,50,18
		DC.W	-160,20,0
		DC.W	-160,-20,0
		DC.W	100,20,-15
		DC.W	100,-20,-15
		DC.W	60,-20,18
		DC.W	60,20,18
		
.PPARTS		
		DC.L	.PARTA
		DC.L	.PARTB
		DC.L	.PARTC
		DC.L	.PARTD
		DC.L	.PARTE
		DC.L	.PARTF
		DC.L	.PARTG
		DC.L	.PARTH
		DC.L	.PARTI
		DC.L	.PARTJ
		DC.L	.PARTK
		DC.L	.PARTL
		DC.L	.PARTM
		
.PARTA		DC.W	1
		DC.W	4,4,4,2,1,0
		DC.W	4,4,2,4,0,1
.PARTB		DC.W	1
		DC.W	4,3,10,13,12,11
		DC.W	4,3,11,12,13,10
.PARTC		DC.W	1
		DC.W	3,5,4,3,2
		DC.W	3,5,2,3,4
.PARTD		DC.W	1
		DC.W	4,4,9,8,7,5
		DC.W	4,4,5,7,8,9
.PARTE		DC.W	1
		DC.W	4,3,15,16,17,14
		DC.W	4,3,14,17,16,15
.PARTF		DC.W	5
		DC.W	4,3,43,56,45,44
		DC.W	4,4,44,45,51,50
		DC.W	4,5,49,57,56,43
		DC.W	4,6,57,49,50,51
		DC.W	4,15,50,49,43,44
		DC.W	4,2,56,57,51,45
.PARTG		DC.W	3
		DC.W	4,2,26,29,54,53
		DC.W	4,3,53,54,33,30
		DC.W	3,4,54,29,33
		DC.W	3,5,53,30,26
.PARTH		DC.W	5
		DC.W	4,3,42,41,46,55
		DC.W	4,4,42,55,58,48
		DC.W	4,5,52,46,41,47
		DC.W	4,6,52,47,48,58
		DC.W	4,15,47,41,42,48
		DC.W	4,2,46,52,58,55
.PARTI		DC.W	3
		DC.W	4,8,38,37,40,39
		DC.W	4,9,37,36,35,40
		DC.W	3,10,40,35,39
		DC.W	3,11,36,37,38
.PARTJ		DC.W	7
		DC.W	4,2,26,27,28,29
		DC.W	4,3,29,28,32,33
		DC.W	4,4,30,31,27,26
		DC.W	4,5,31,30,33,32
		DC.W	3,2,27,34,28
		DC.W	3,4,31,34,27
		DC.W	3,3,32,28,34
		DC.W	3,5,31,32,34
.PARTK		DC.W	1
		DC.W	3,5,5,7,6
		DC.W	3,5,6,7,5
.PARTL		DC.W	1
		DC.W	4,7,19,20,21,18
		DC.W	4,7,18,21,20,19
.PARTM		DC.W	1
		DC.W	4,7,23,24,25,22
		DC.W	4,7,22,25,24,23

* -------------------------------------------------------------*
HOUSE		DC.W	12
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	0
		DC.L	.PPARTS
.COORDS		DC.W	0,0,0

		DC.W	-150,100,100
		DC.W	150,100,100
		DC.W	150,-100,100
		DC.W	150,-150,0
		DC.W	-150,-150,0
		DC.W	-150,-100,100
		DC.W	50,100,100
		DC.W	100,100,100
		DC.W	100,0,100
		DC.W	50,0,100
		DC.W	-150,-100,-100
		DC.W	-150,100,-100
		
.PPARTS		DC.L	.PART1
.PART1		DC.W	3
		DC.W	4,2,4,3,2,5
		DC.W	4,3,5,2,1,0
		DC.W	5,4,10,4,5,0,11
		DC.W	4,0,9,8,7,6
		
* -------------------------------------------------------------*
CHIP		DC.W	18
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	2
		DC.L	.PPARTS
.COORDS		DC.W	0,0,0
		DC.W	0,20,100
		DC.W	0,20,-100
		
		DC.W	-150,20,100
		DC.W	150,20,100
		DC.W	150,-20,100
		DC.W	-150,-20,100
		DC.W	-140,40,100
		DC.W	140,40,100
		DC.W	140,0,100
		DC.W	-140,0,100
		DC.W	-150,20,-100
		DC.W	150,20,-100
		DC.W	150,-20,-100
		DC.W	-150,-20,-100
		DC.W	-140,40,-100
		DC.W	140,40,-100
		DC.W	140,0,-100
		DC.W	-140,0,-100
.PPARTS		DC.L	.PART1
		DC.L	.PART2
		DC.L	.PART3
.PART1		DC.W	5
		DC.W	4,2,3,2,1,0
		DC.W	4,3,11,3,0,8
		DC.W	4,3,2,10,9,1
		DC.W	4,4,11,10,2,3
		DC.W	4,5,0,1,9,8
		DC.W	4,2,10,11,8,9
.PART2		DC.W	1
		DC.W	4,6,7,6,5,4
		DC.W	4,6,4,5,6,7
.PART3		DC.W	1
		DC.W	4,6,15,14,13,12
		DC.W	4,6,12,13,14,15

* -------------------------------------------------------------*
DESK		DC.W	50
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	6
		DC.L	.PPARTS
.COORDS		
		DC.W	-137,75,100
		DC.W	-137,75,-100
		DC.W	137,75,100
		DC.W	137,75,-100
		DC.W	0,-10,0
		DC.W	0,-40,5  
		DC.W	0,-60,2

		DC.W	-140,150,100
		DC.W	-135,150,100
		DC.W	-135,0,100
		DC.W	-140,0,100
		DC.W	135,150,100
		DC.W	140,150,100
		DC.W	140,0,100
		DC.W	135,0,100
		DC.W	-150,0,100
		DC.W	-150,-20,100
		DC.W	150,-20,100
		DC.W	150,0,100
		DC.W	-50,-30,90
		DC.W	50,-30,90
		DC.W	50,-20,90	
		DC.W	-50,-20,90
		DC.W	-140,150,-100
		DC.W	-135,150,-100
		DC.W	-135,0,-100
		DC.W	-140,0,-100
		DC.W	135,150,-100
		DC.W	140,150,-100
		DC.W	140,0,-100
		DC.W	135,0,-100
		DC.W	-150,0,-100
		DC.W	-150,-20,-100
		DC.W	150,-20,-100
		DC.W	150,0,-100
		DC.W	-50,-30,55
		DC.W	50,-30,55
		DC.W	50,-20,55
		DC.W	-50,-20,55
		DC.W	-50,-20,45
		DC.W	50,-20,45
		DC.W	50,-100,45
		DC.W	-50,-100,45
		DC.W	-40,-25,45
		DC.W	40,-25,45
		DC.W	40,-95,45
		DC.W	-40,-95,45
		DC.W	-50,-20,-40
		DC.W	50,-20,-40
		DC.W	50,-100,-40
		DC.W	-50,-100,-40
.PPARTS		DC.L	.PART1
		DC.L	.PART2
		DC.L	.PART3
		DC.L	.PART4
		DC.L	.PART5
		DC.L	.PART6
		DC.L	.PART7
.PART1		DC.W	1
		DC.W	4,3,3,2,1,0
		DC.W	4,3,0,1,2,3
.PART2		DC.W	1
		DC.W	4,3,19,18,17,16
		DC.W	4,3,16,17,18,19
.PART3		DC.W	1
		DC.W	4,3,7,6,5,4
		DC.W	4,3,4,5,6,7
.PART4		DC.W	1
		DC.W	4,3,23,22,21,20
		DC.W	4,3,20,21,22,23
.PART5		DC.W	5
		DC.W	4,5,9,10,11,8
		DC.W	4,4,10,26,27,11
		DC.W	4,3,25,9,8,24
		DC.W	4,4,25,26,10,9
		DC.W	4,2,8,11,27,24
		DC.W	4,5,26,25,24,27
.PART6		DC.W	4
		DC.W	4,11,12,13,14,15
		DC.W	4,8,13,29,30,14
		DC.W	4,9,28,12,15,31
		DC.W	4,10,28,29,13,12
		DC.W	4,11,29,28,31,30
.PART7		DC.W	5
		DC.W	4,7,35,34,33,32
		DC.W	4,12,39,38,37,36 
		DC.W	4,8,34,42,41,33
		DC.W	4,9,43,35,32,40
		DC.W	4,10,43,42,34,35
		DC.W	4,7,42,43,40,41

* -------------------------------------------------------------*
GUN		DC.W	27
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	3
		DC.L	.PPARTS
.COORDS		DC.W	107,0,0
		DC.W	22,-66,0
		DC.W	-5,-110,0
		DC.W	10,-16,0
		
		DC.W	75,100,20
		DC.W	150,100,20
		DC.W	140,-100,20
		DC.W	65,-100,20
		DC.W	-30,-100,20
		DC.W	-250,-100,20
		DC.W	-250,-140,20
		DC.W	140,-140,20
		DC.W	-20,-33,20
		DC.W	69,-33,20
		DC.W	10,-33,0
		DC.W	20,-33,0
		DC.W	0,0,0
		DC.W	10,0,0
		DC.W	75,100,-20
		DC.W	150,100,-20
		DC.W	140,-100,-20
		DC.W	140,-140,-20
		DC.W	-250,-140,-20
		DC.W	-250,-100,-20
		DC.W	-30,-100,-20
		DC.W	65,-100,-20
		DC.W	69,-33,-20
		DC.W	-20,-30,-20

.PPARTS		DC.L	.PART1
		DC.L	.PART2
		DC.L	.PART3
		DC.L	.PART4
		
.PART1		DC.W	4
		DC.W	4,4,3,2,1,0
		DC.W	4,2,0,1,15,14
		DC.W	4,4,9,0,14,22
		DC.W	4,5,2,16,15,1
		DC.W	4,3,16,21,14,15

.PART2		DC.W	3
		DC.W	4,6,4,3,9,8
		DC.W	4,7,4,8,23,20
		DC.W	4,8,8,9,22,23
		DC.W	4,9,21,20,23,22


.PART3		DC.W	5
		DC.W	4,11,6,7,2,5
		DC.W	4,7,7,17,16,2
		DC.W	4,8,18,17,7,6
		DC.W	4,9,5,4,20,19
		DC.W	4,10,16,17,18,19
		DC.W	4,6,6,5,19,18

.PART4		DC.W	1
		DC.W	4,8,10,11,13,12
		DC.W	4,8,11,10,12,13

* -------------------------------------------------------------*
FLOOR		DC.W	16
		DC.L	.COORDS
		DC.W	0,0,0
		DC.W	3
		DC.L	.PPARTS
	
.PPARTS		DC.L	.PART1
		DC.L	.PART2
		DC.L	.PART3
		DC.L	.PART4
		
.PART1		DC.W	4
		DC.W	3,2,0,1,3
		DC.W	3,3,3,1,6
		DC.W	3,4,5,3,6
		DC.W	3,5,0,3,5
		DC.W	4,14,1,0,5,6
		
.PART2		DC.W	4
		DC.W	3,6,1,2,4
		DC.W	3,7,2,7,4
		DC.W	3,8,4,7,6
		DC.W	3,9,1,4,6
		DC.W	4,14,2,1,6,7
		
.PART3		DC.W	4
		DC.W	3,10,5,6,8
		DC.W	3,11,5,8,10
		DC.W	3,12,10,8,11
		DC.W	3,13,8,6,11
		DC.W	4,14,6,5,10,11
		
.PART4		DC.W	4
		DC.W	3,14,6,7,9
		DC.W	3,15,9,7,12
		DC.W	3,1,9,12,11
		DC.W	3,15,6,9,11
		DC.W	4,14,7,6,11,12
.COORDS	
		DC.W	-100,-100,0
		DC.W	100,-100,0
		DC.W	-100,100,0
		DC.W	100,100,0

		DC.W	-200,-200,0
		DC.W	0,-200,0
		DC.W	200,-200,0
CH1		DC.W	-100,-100,0
CH2		DC.W	100,-100,0
		DC.W	-200,0,0
		DC.W	0,0,0
		DC.W	200,0,0
CH3		DC.W	-100,100,0
CH4		DC.W	100,100,0
		DC.W	-200,200,0
		DC.W	0,200,0
		DC.W	200,200,0

* TIMER.W,OBJECT_ADDRESS.L,INC_XANGLE.W,INC_YANGLE.W,INC_ZANGLE.W
* INC_XOFFSET.W,INC_YOFFSET.W,INC_ZOFFSET.W,INC_DIST.W
* INC_X0.W,INC_Y0.W,COLOUR 0.W,1.W,2.W......,CLIPFLAG
SEQUENCES
* -- 
		DC.W	1
		DC.L	HOUSE
		DC.W	0,620,0
		DC.W	0,100,0
		DC.W	0
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	1,1
* -- 
		DC.W	60
		DC.L	HOUSE
		DC.W	0,2,0
		DC.W	0,-2,0
		DC.W	-15
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	1,0
* -- 
		DC.W	26
		DC.L	HOUSE
		DC.W	0,0,0
		DC.W	-2,0,0
		DC.W	-80
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	1,0
* -- 
		DC.W	25
		DC.L	HOUSE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-180
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	DESK
		DC.W	0,150,0
		DC.W	0,0,0
		DC.W	0
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	1,1
* -- 
		DC.W	40
		DC.L	DESK
		DC.W	0,-2,0
		DC.W	0,0,0
		DC.W	-10
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	1,0
* -- 
		DC.W	35
		DC.L	DESK
		DC.W	0,-2,0
		DC.W	0,2,0
		DC.W	-20
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	1,0
* -- 
		DC.W	40
		DC.L	DESK
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-70
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	CHIP
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	1,1
* -- 
		DC.W	20
		DC.L	CHIP
		DC.W	12,14,16
		DC.W	0,0,0
		DC.W	-20
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	100
		DC.L	CHIP
		DC.W	12,14,16
		DC.W	0,0,0
		DC.W	0
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	100
		DC.L	CHIP
		DC.W	0,14,0
		DC.W	0,2,0
		DC.W	-26
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,120,0
		DC.W	-100
		DC.W	300,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	1,1
* -- 
		DC.W	50
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-2
		DC.W	-4,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	90
		DC.L	GUN
		DC.W	0,720-2,0
		DC.W	0,0,0
		DC.W	-14
		DC.W	-1,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	140
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-40
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	PLANE
		DC.W	720-180,180,0
		DC.W	0,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,1
* -- 
		DC.W	50
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,1
		DC.W	-10   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	20
		DC.L	PLANE
		DC.W	2,0,0
		DC.W	0,0,-3
		DC.W	-30   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	30
		DC.L	PLANE
		DC.W	2,0,0
		DC.W	0,0,-3
		DC.W	-50   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	PLANE
		DC.W	-80,180,0
		DC.W	-600,0,80
		DC.W	2200   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	40
		DC.L	PLANE
		DC.W	14,0,0
		DC.W	30,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	PLANE
		DC.W	180,0,180
		DC.W	-900,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	30
		DC.L	PLANE
		DC.W	14,0,0
		DC.W	30,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	PLANE
		DC.W	0,720-180,180
		DC.W	0,0,30
		DC.W	-7000
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,1
* -- 
		DC.W	5
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	1000   
		DC.W	0,-1
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	2
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	500   
		DC.W	0,-1
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	3
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	250   
		DC.W	0,-2
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	35
		DC.L	PLANE
		DC.W	0,720-4,0
		DC.W	0,0,0
		DC.W	10   
		DC.W	0,-5
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	FLOOR
		DC.W	150,0,0
		DC.W	0,100,0
		DC.W	0   
		DC.W	0,30
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	1,1
* -- 
		DC.W	100
		DC.L	FLOOR
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-4   
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	1,0
* -- 
		DC.W	360*3
		DC.L	FLOOR
		DC.W	0,2,0
		DC.W	0,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	0,0
* -- 
		DC.W	15
		DC.L	FLOOR
		DC.W	2,0,0
		DC.W	0,0,-2
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	1,0
* -- 
		DC.W	50
		DC.L	FLOOR
		DC.W	0,0,0
		DC.W	0,0,-2
		DC.W	-20   
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	BIG_D
		DC.W	0,0,0
		DC.W	40,0,0
		DC.W	-2000   
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,1
* -- 
		DC.W	180
		DC.L	BIG_D
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10   
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	120
		DC.L	BIG_D
		DC.W	4,0,0
		DC.W	0,0,0
		DC.W	-4   
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	500
		DC.L	BIG_D
		DC.W	2,2,2
		DC.W	0,0,0
		DC.W	0   
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	34
		DC.L	BIG_D
		DC.W	2,2,2
		DC.W	0,0,0
		DC.W	20   
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	DESK
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	0,1
* -- 
		DC.W	35
		DC.L	DESK
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	DESK
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	0,0
* -- 
		DC.W	35
		DC.L	DESK
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,$70,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	CHIP
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	0,1
* -- 
		DC.W	35
		DC.L	CHIP
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	CHIP
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	35
		DC.L	CHIP
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$666,0,0,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	0,1
* -- 
		DC.W	30
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	GUN
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	30
		DC.L	GUN
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,$310,$421,$532,$643,$111,$222,$333,$444,$555,$666,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	0,1
* -- 
		DC.W	35
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	PLANE
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	0,0
* -- 
		DC.W	35
		DC.L	PLANE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,$111,$222,$333,$444,$555,$666,$7,$6,$5,$4,0,0,0,$700
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	FLOOR
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	0,1
* -- 
		DC.W	26
		DC.L	FLOOR
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	FLOOR
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	0,0
* -- 
		DC.W	26
		DC.L	FLOOR
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,6,5,4,3,$60,$50,$40,$30,$600,$500,$400,$300,$333,$555
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	BIG_D
		DC.W	0,0,0
		DC.W	40,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	0,1
* -- 
		DC.W	15
		DC.L	BIG_D
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	BIG_D
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	0,0
* -- 
		DC.W	15
		DC.L	BIG_D
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,$700,$600,$500,$400,$300,$200,$100,0,0,0,0,0,0,0
		DC.W	1,0
* -- 
		DC.W	1
		DC.L	CUBE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,2,3,4,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	0,1
* -- 
		DC.W	50
		DC.L	CUBE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	-10  
		DC.W	0,0
		DC.W	0,-1,2,3,4,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	0,0
* -- 
		DC.W	500
		DC.L	CUBE
		DC.W	4,6,8
		DC.W	0,0,0
		DC.W	0  
		DC.W	0,0
		DC.W	0,-1,2,3,4,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	0,0
* -- 
		DC.W	50
		DC.L	CUBE
		DC.W	0,0,0
		DC.W	0,0,0
		DC.W	10  
		DC.W	0,0
		DC.W	0,-1,2,3,4,5,6,7,$11,$22,$33,$44,$55,$66,$77,1
		DC.W	1,0
* -- 
		DC.W	0
		
*************************************************************
*	ROUTINES				*
*************************************************************
* UPDATE POINTS FOR GRAFIC EQUALIZER *
EQUALIZE		CMP.L	#FLOOR,POBJECT
		BEQ.S	.DOIT
		RTS
.DOIT		CLR	D0
		MOVE.B	#6,$FF8800
		MOVE.B	$FF8800,D0
		LSL	#3,D0
		MOVE.B	D0,CH1+5
		CLR	D0
.NOCH		MOVE.B	#8,$FF8800
		MOVE.B	$FF8800,D0
		LSL	#3,D0
		MOVE.B	D0,CH2+5
		CLR	D0
		MOVE.B	#9,$FF8800
		MOVE.B	$FF8800,D0
		LSL	#3,D0
		MOVE.B	D0,CH3+5
		CLR	D0
		MOVE.B	#10,$FF8800
		MOVE.B	$FF8800,D0
		LSL	#3,D0
		MOVE.B	D0,CH4+5
		
		TST	CH1+4
		BEQ.S	.NT1
		SUB	#4,CH1+4
.NT1		TST	CH2+4
		BEQ.S	.NT2
		SUB	#4,CH2+4
.NT2		TST	CH3+4
		BEQ.S	.NT3
		SUB	#4,CH3+4
.NT3		TST	CH4+4
		BEQ.S	.NT4
		SUB	#4,CH4+4
.NT4		RTS

* CHECK STATUS FOR CLIP AND THEN DO A QUICK BOUNDARY CHECK AND CLIP POLY

CLIP_POLY_CHECK	TST	CLIPFLAG
		BNE.S	.CLIPON
		RTS
.CLIPON		LEA	WINDOW_BOUNDARIES(PC),A6
		MOVE.L	A0,A1
		MOVE	D7,D0
		LSL	#2,D0
		LEA	-4(A1,D0),A2
		MOVEM	(A2)+,D0/D1
		MOVE	D0,D2
		MOVE	D1,D3
		MOVE	2(A6),D6
		CMP	D6,D3
		BGE.S	.NEXT_CP1_T
		BRA.S	.NEXT_CP2_T
.CP_LP1_T	MOVEM	(A1)+,D0/D1
		CMP	D6,D1
		BGE.S	.CP1_T
		BSR	.HORIZ_CROSS
		MOVEQ	#-1,D4
		BRA.S	.NEXT_CP2_T
.CP3_T		BSR	.HORIZ_CROSS	
.CP1_T		MOVE	D0,(A2)+
		MOVE	D1,(A2)+
		MOVE	D0,D2
		MOVE	D1,D3
.NEXT_CP1_T	DBRA	D7,.CP_LP1_T
		BRA.S	.CP5_T
.CP_LP2_T	MOVE	D0,D2
		MOVE	D1,D3
		MOVEM	(A1)+,D0/D1
		CMP	D6,D1
.NEXT_CP2_T	DBGE	D7,.CP_LP2_T
		BEQ.S	.CP1_T
		BGT.S	.CP3_T
.CP5_T		SUBQ.L	#4,A2
		MOVE	(A2)+,D0
		MOVE	(A2)+,D1
		MOVE	D0,D2
		MOVE	D1,D3
		MOVE.L	A2,D7
		SUB.L	A1,D7
		BEQ	.CP_OFF
		LSR	#2,D7
		MOVE	(A6),D6
		CMP	D6,D2
		BGE.S	.NEXT_CP1_L
		BRA.S	.NEXT_CP2_L
.CP_LP1_L	MOVEM	(A1)+,D0/D1
		CMP	D6,D0
		BGE.S	.CP1_L
		BSR 	.VERT_CROSS
		MOVEQ	#-1,D4
		BRA.S	.NEXT_CP2_L
.CP3_L		BSR	.VERT_CROSS
.CP1_L		MOVE	D0,(A2)+
		MOVE	D1,(A2)+
		MOVE	D0,D2
		MOVE	D1,D3
.NEXT_CP1_L	DBRA	D7,.CP_LP1_L
		BRA.S	.CP5_L
.CP_LP2_L	MOVE	D0,D2
		MOVE	D1,D3
		MOVEM	(A1)+,D0/D1
		CMP	D6,D0
.NEXT_CP2_L	DBGE	D7,.CP_LP2_L
		BEQ.S	.CP1_L
		BGT.S	.CP3_L
.CP5_L		SUBQ.L	#4,A2
		MOVE	(A2)+,D0
		MOVE	(A2)+,D1
		MOVE	D0,D2
		MOVE	D1,D3
		MOVE.L	A2,D7
		SUB.L	A1,D7
		BEQ	.CP_OFF
		LSR	#2,D7
		MOVE	6(A6),D6
		CMP	D6,D3
		BLE.S	.NEXT_CP1_B
		BRA.S	.NEXT_CP2_B
.CP_LP1_B	MOVEM	(A1)+,D0/D1
		CMP	D6,D1
		BLE.S	.CP1_B
		BSR	.HORIZ_CROSS
		MOVEQ	#1,D4
		BRA.S	.NEXT_CP2_B
.CP3_B		BSR	.HORIZ_CROSS
.CP1_B		MOVE	D0,(A2)+
		MOVE	D1,(A2)+
		MOVE	D0,D2
		MOVE	D1,D3
.NEXT_CP1_B	DBRA	D7,.CP_LP1_B
		BRA.S	.CP5_B
.CP_LP2_B	MOVE	D0,D2
		MOVE	D1,D3
		MOVEM	(A1)+,D0/D1
		CMP	D6,D1
.NEXT_CP2_B	DBLE	D7,.CP_LP2_B
		BEQ.S	.CP1_B
		BLT.S	.CP3_B
.CP5_B		SUBQ.L	#4,A2
		MOVE	(A2)+,D0
		MOVE	(A2)+,D1
		MOVE	D0,D2
		MOVE	D1,D3
		MOVE.L	A2,D7
		SUB.L	A1,D7
		BEQ	.CP_OFF
		LSR	#2,D7
		MOVE.L	A0,A2
		MOVE	4(A6),D6
		CMP	D6,D2
		BLE.S	.NEXT_CP1_R
		BRA.S	.NEXT_CP2_R
.CP_LP1_R	MOVEM	(A1)+,D0/D1
		CMP	D6,D0
		BLE.S	.CP1_R
		BSR	.VERT_CROSS
		MOVEQ	#1,D4
		BRA.S	.NEXT_CP2_R
.CP3_R		BSR.S	.VERT_CROSS
.CP1_R		MOVE	D0,(A2)+
		MOVE	D1,(A2)+
		MOVE	D0,D2
		MOVE	D1,D3
.NEXT_CP1_R	DBRA	D7,.CP_LP1_R
		BRA.S	.CP5_R
.CP_LP2_R	MOVE	D0,D2
		MOVE	D1,D3
		MOVEM	(A1)+,D0/D1
		CMP	D6,D0
.NEXT_CP2_R	DBLE	D7,.CP_LP2_R
		BEQ.S	.CP1_R
		BLT.S	.CP3_R
.CP5_R		MOVE.L	A2,D7
		SUB.L	A0,D7
		BEQ.S	.CP_OFF
		LSR	#2,D7
		MOVEQ	#0,D0
		RTS
.CP_OFF		MOVEQ	#-1,D0
		RTS
.HORIZ_CROSS	MOVE	D0,D4
		SUB	D2,D4
		MOVE	D1,D5
		SUB	D6,D5
		MULS	D5,D4
		MOVE	D1,D5
		SUB	D3,D5
		DIVS	D5,D4
		NEG	D4
		ADD	D0,D4
		MOVE	D4,(A2)+
		MOVE	D6,(A2)+
		RTS
.VERT_CROSS	MOVE	D1,D4
		SUB	D3,D4
		MOVE	D0,D5
		SUB	D6,D5
		MULS	D5,D4
		MOVE	D0,D5
		SUB	D2,D5
		DIVS	D5,D4
		NEG	D4
		ADD	D1,D4
		MOVE	D6,(A2)+
		MOVE	D4,(A2)+
		RTS	
		
******************************************************************
		
DOSEQUENCE		ADD	#1,TIMERSEQUENCE
		MOVE	TIMERSEQUENCE,D0
		CMP	NEXTSEQUENCE,D0
		BNE	.ENDSEQUENCE
		CLR	TIMERSEQUENCE
		MOVE.L	PSEQUENCES,A0
		TST	(A0)
		BNE	.NOTENDSEQUENCES
		MOVE.L	#SEQUENCES,PSEQUENCES
		MOVE.L	PSEQUENCES,A0
.NOTENDSEQUENCES
		MOVE	(A0)+,NEXTSEQUENCE
		MOVE.L	(A0)+,POBJECT
		MOVE	(A0)+,INCXANGLE
		MOVE	(A0)+,INCYANGLE
		MOVE	(A0)+,INCZANGLE
		MOVE	(A0)+,INCXOFFSET
		MOVE	(A0)+,INCYOFFSET
		MOVE	(A0)+,INCZOFFSET
		MOVE	(A0)+,INCDIST
		MOVE	(A0)+,INCX0
		MOVE	(A0)+,INCY0
		MOVE.L	#$FF8240,A1
		REPT	8
		MOVE.L	(A0)+,(A1)+
		ENDR
		MOVE	(A0)+,CLIPFLAG
		MOVE	(A0)+,D0
		ADD.L	#60,PSEQUENCES
		TST	D0
		BEQ.S	.ENDSEQUENCE
		MOVE.L	POBJECT,A0
		CLR	STRUCT_XANGLE(A0)
		CLR	STRUCT_YANGLE(A0)
		CLR	STRUCT_ZANGLE(A0)
		CLR	XOFFSET
		CLR	YOFFSET
		CLR	ZOFFSET
		MOVE	#160,X0
		MOVE	#90,Y0
		MOVE	#999,DIST
.ENDSEQUENCE	MOVE.L	POBJECT,A0
		MOVE	INCXANGLE,D0
		ADD	D0,STRUCT_XANGLE(A0)
		MOVE	INCYANGLE,D0
		ADD	D0,STRUCT_YANGLE(A0)
		MOVE	INCZANGLE,D0
		ADD	D0,STRUCT_ZANGLE(A0)
		MOVE	INCXOFFSET,D0
		ADD	D0,XOFFSET
		MOVE	INCYOFFSET,D0
		ADD	D0,YOFFSET
		MOVE	INCZOFFSET,D0
		ADD	D0,ZOFFSET
		MOVE	INCDIST,D0
		ADD	D0,DIST
		MOVE	INCX0,D0
		ADD	D0,X0
		MOVE	INCY0,D0
		ADD	D0,Y0
		RTS

DOSCROLL	ADD	#1,LINENOW
		CMPI	#50,LINENOW
		BEQ	.DOLINE
		RTS
.DOLINE		CLR	LINENOW
		MOVE.L	PTXT,A0
		TST.B	(A0)
		BNE.S	.NOTENDTEXT
		MOVE.L	#TEXT,PTXT
		MOVE.L	PTXT,A0
.NOTENDTEXT	MOVE	#19,D7
		LEA	FONT,A6
		LEA	40(A6),A6
		MOVE.L	LOGSCREEN,A2
		LEA	160*183(A2),A2
		MOVEQ	#0,D0
.LOOP		MOVE.L	A6,A5
		MOVE.B	(A0)+,D0
		CMPI.B	#32,D0
		BNE.S	.NOSPACE
		ADDI.B	#33+38,D0	
.NOSPACE	SUBI.B	#65,D0
		CMPI.B	#20,D0
		BLT.S	.NONEXTLINE
		ADDA	#40*15,A5
.NONEXTLINE	ADD.B	D0,D0
		ADD	D0,A5
SHIT		SET 0
		REPT	15
		MOVE	SHIT(A5),SHIT*4(A2)
SHIT		SET SHIT+40
		ENDR
		LEA	8(A2),A2
		DBRA	D7,.LOOP
		MOVE.L	A0,PTXT
		MOVE.L	LOGSCREEN,A0
		LEA	160*183(A0),A0
		MOVE.L	PHYSCREEN,A1
		LEA	160*183(A1),A1
SHIT 		SET 0
		REPT	300
		MOVE	SHIT(A0),SHIT(A1)
SHIT		SET SHIT+8
		ENDR
		RTS

LINENOW		DC.W	49
PTXT		DC.L	TEXT
		
DRAWOBJECT	TST	STRUCT_NPARTS(A0)
		BNE.S	.MORETHAN1PART
		MOVE.L	STRUCT_PPPARTS(A0),A1
		MOVE.L	(A1),PSTORAGE
		BRA.S	.ONEOBJECT
.MORETHAN1PART	LEA	PSTORAGE(PC),A1
		MOVE.L	STRUCT_PPPARTS(A0),A2
		MOVE	STRUCT_NPARTS(A0),D7
.ALOOP		MOVE.L	(A2)+,(A1)+
		DBRA	D7,.ALOOP
.BUBBLE_SORT	LEA	PSTORAGE(PC),A1
		LEA	ZBUFFER(PC),A2
		MOVE	STRUCT_NPARTS(A0),D7
		SUBI	#1,D7
		CLR	D0
.BLOOP		MOVE	0(A2),D3
		CMP	2(A2),D3
		BLE.S	.NOSWAP
		MOVE	2(A2),D1
		MOVE	0(A2),2(A2)
		MOVE	D1,0(A2)
		MOVE.L	4(A1),D1
		MOVE.L	0(A1),4(A1)
		MOVE.L	D1,0(A1)
		MOVE.B	#1,D0
.NOSWAP		LEA	2(A2),A2
		LEA	4(A1),A1
		DBRA	D7,.BLOOP
		TST	D0
		BNE.S	.BUBBLE_SORT
.ONEOBJECT	MOVE	STRUCT_NPARTS(A0),D6
		LEA	PSTORAGE(PC),A1
		LEA	STORAGEA(PC),A5
		MOVE	#1,D5
		ADD	D6,D5
		LSL	#2,D5
		LEA	(A5,D5),A5
.ELOOP		MOVE.L	(A1)+,A3
		MOVE	(A3)+,D5
.DLOOP		LEA	STORAGEB(PC),A4
		MOVE	(A3)+,D7
		MOVE	(A3)+,D0
		MOVE	D7,D4
		SUBI	#1,D4
.CLOOP		MOVE	(A3)+,D3
		LSL	#2,D3
		MOVE.L	(A5,D3),(A4)+
		DBRA	D4,.CLOOP
		LEA	STORAGEB(PC),A0
		MOVEM.L	D5/D6/A1/A3/A5,-(SP)
		MOVE	D0,COLOR
		JSR	CLIP_POLY_CHECK
		BMI.S	.NODRAW
		MOVE	COLOR,D0
		JSR	DRAW_POLYGON
.NODRAW		MOVEM.L	(SP)+,D5/D6/A1/A3/A5
		DBRA	D5,.DLOOP
		DBRA	D6,.ELOOP
		RTS
COLOR		DC.W	0

* ROTATE COORDINATES AND CALCULATE PERSPECTIVE
* AND STORE IN NEW BUFFER
ROTATE		CMP	#720,STRUCT_XANGLE(A0)
		BLT	.YCH
		SUB	#720,STRUCT_XANGLE(A0)
.YCH		CMP	#720,STRUCT_YANGLE(A0)
		BLT	.ZCH
		SUB	#720,STRUCT_YANGLE(A0)
.ZCH		CMP	#720,STRUCT_ZANGLE(A0)
		BLT	.NCH
		SUB	#720,STRUCT_ZANGLE(A0)
.NCH		MOVE	STRUCT_NCOORDS(A0),D7
		LEA	STRUCT_XANGLE(A0),A3
		MOVE.L	STRUCT_PCOORDS(A0),A0
		LEA	STORAGEA(PC),A1
		LEA	SINCOS_TABLE(PC),A2
		LEA	180(A2),A4
		LEA	ZBUFFER(PC),A6
.LOOP
.XROTATION		MOVEM	2(A0),D4/D5		;Y,Z
		ADD	YOFFSET,D4
		ADD	ZOFFSET,D5
		MOVE	(A3),D0		;XANGLE
		MOVE	(A2,D0),D1		;SIN
		MOVE	(A4,D0),D0		;COS
		MULS	D0,D4
		MULS	D1,D5
		SUB.L	D5,D4
		LSL.L	#2,D4
		SWAP	D4		;Y1
		MOVEM	2(A0),D5/D6		;Y,Z
		ADD	YOFFSET,D5
		ADD	ZOFFSET,D6
		MULS	D0,D6
		MULS	D1,D5
		ADD.L	D6,D5
		LSL.L	#2,D5
		SWAP	D5		;Z1
* -- D4 = Y1 D5 = Z1
.YROTATION		MOVE	D5,4(A1)		;STORE Z
		MOVE	(A0),D3		;X
		ADD	XOFFSET,D3		
		MOVE	2(A3),D0		;YANGLE
		MOVE	(A2,D0),D1		;SIN
		MOVE	(A4,D0),D0		;COS
		MULS	D0,D3
		MULS	D1,D5
		SUB.L	D5,D3
		LSL.L	#2,D3
		SWAP	D3		;X1
		MOVE	4(A1),D5		;GET Z
		MOVE	(A0),D6		;X
		ADD	XOFFSET,D6		
		MULS	D0,D5
		MULS	D1,D6
		ADD.L	D5,D6
		LSL.L	#2,D6
		SWAP	D6		;Z1
* -- D4 = Y1 D3 = X1 D6 = Z1
.ZROTATION		MOVEM	D3/D4,(A1)		;SAVE X,Y
		MOVE	4(A3),D0		;XANGLE
		MOVE	(A2,D0),D1		;SIN
		MOVE	(A4,D0),D0		;COS
		MULS	D0,D3
		MULS	D1,D4
		SUB.L	D4,D3
		LSL.L	#2,D3
		SWAP	D3		;X1
		MOVEM	(A1),D4/D5		;GET X,Y
		MULS	D0,D5
		MULS	D1,D4
		ADD.L	D4,D5
		LSL.L	#2,D5
		SWAP	D5		;Y1
.PERSPECTIVE	MOVEM	D3/D5/D6,(A1)	;SAVE X,Y,Z
		MOVE	D6,(A6)+
		MOVE	D6,D5
		MOVE	DIST,D4
		SUB	D5,D4
		EXT.L	D4
		LSL.L	#8,D4
		MOVE	ZOBS,D3
		EXT.L	D3
		SUB.L	D6,D3
		BNE	.PERS1
		MOVE	#0,D1
		MOVE	D1,(A1)
		MOVE	D1,2(A1)
		BRA	.PEREND1
.PERS1		DIVS	D3,D4
		MOVE	D4,D3
		MOVE	(A1),D1
		MOVE	D1,D2
		NEG	D1
		MULS	D1,D3
		LSR.L	#8,D3
		ADD	D3,D2
		ADD	X0,D2
		MOVE	D2,(A1)
		MOVE	2(A1),D1
		MOVE	D1,D2
		NEG	D1
		MULS	D1,D4
		LSR.L	#8,D4
		ADD	D4,D2
		ADD	Y0,D2
		MOVE	D2,2(A1)
.PEREND1		LEA	4(A1),A1	
		LEA	6(A0),A0	
		DBRA	D7,.LOOP
		RTS
		
***************************************************************
* Routine that will select and draw
* only clockwise polygons.Polygons
* whose vertices run anti-clockwise
* cannot possibly be seen.
* A0 points to D7 co-ords,D0 colour.
* Polyfill coded with self-modifying
* colour routines for extra speed...
***************************************************************
DRAW_POLYGON	MOVE 	D7,D4
		ADD 	D4,D4
		ADD 	D4,D4
		MOVE.L 	A0,A2
		ADDA.W 	D4,A2
		MOVE.L 	A2,A3
		ADDA.W 	D4,A3
Init_coords		MOVE 	#$8000,D1
		MOVE 	#$7FFF,D2
		SUBQ 	#1,D7
coord_lp		MOVE.L 	(A0)+,D3
		CMP 	D2,D3
		BGE.S 	not_top
		MOVE 	D3,D2
		MOVE.L 	A0,A4
not_top		CMP 	D3,D1
		BGE.S 	not_bot
		MOVE 	D3,D1	
not_bot		MOVE.L 	D3,(A2)+
		MOVE.L 	D3,(A3)+
		DBF 	D7,coord_lp
		MOVE.L 	(A0),(A2)
		ADDA 	D4,A4
		SUB 	-(A4),D1
		BEQ.S 	abort_poly
		MOVE 	D1,-(SP)
		SUBQ.L 	#2,A4
Clock_test		MOVEM.W -4(A4),D1-D6
		CMP 	D3,D1
		BGT.S 	Case_1
		BLT.S 	Case_2
		CMP 	D3,D5
		BLT.S 	Anticlkcase
		BRA.S 	Polyfill
Case_2		CMP D3,D5
		BGE.S 	Polyfill
		SUB 	D4,D2
		NEG 	D5
		ADD 	D3,D5
		MULU 	D5,D2
		SUB 	D4,D6
		SUB 	D1,D3
		MULU 	D3,D6
		CMP.L 	D6,D2
		BLE.S 	Polyfill
Anticlkcase		ADDQ.L 	#2,SP
abort_poly		RTS
Case_1		CMP D3,D5
		BLE.S 	Anticlkcase
		SUB 	D4,D2
		SUB 	D3,D5
		MULU 	D5,D2
		SUB 	D4,D6
		SUB 	D3,D1
		MULU 	D1,D6
		CMP.L 	D6,D2
		BLT.S 	Anticlkcase 

Polyfill		LSL 	#4,D0
		MOVEM.L col0(PC,D0),D1/D2/D7/A5
		LEA 	first_chunk(PC),A2
		MOVE.L 	D1,(A2)+
		MOVE.L 	D2,(A2)
		LEA 	end_chunk(PC),A2
		MOVE.L	D1,(A2)+
		MOVE.L 	D2,(A2)
flat_check		MOVE.L 	A4,A3
		MOVE.L 	(A4)+,D0
flat_ch_1		CMP 	2(A4),D0
		BNE.S 	flat_ch_2
		ADDQ.L 	#4,A4
flat_ch_2		CMP 	-2(A3),D0
		BNE.S 	flat_done
		SUBQ.L 	#4,A3
flat_done		MOVE.L 	LOGSCREEN,A6	screen base
		MOVE 	D0,D1
		ADD	D0,D0
		ADD 	D0,D0
		ADD 	D1,D0
		LSL 	#5,D0
		ADDA 	D0,A6
		MOVEQ 	#0,D6
		BRA 	Left_rchd

col0		AND 	D2,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		DC.L 	$00000000,$00000000
col1		OR 	D1,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		DC.L 	$FFFF0000,$00000000
col2		AND 	D2,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		DC.L 	$0000FFFF,$00000000
col3		OR 	D1,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		DC.L 	$FFFFFFFF,$00000000
col4		AND 	D2,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		DC.L 	$00000000,$FFFF0000
col5		OR 	D1,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
 		DC.L 	$FFFF0000,$FFFF0000
col6		AND 	D2,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		DC.L 	$0000FFFF,$FFFF0000
col7		OR 	D1,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		DC.L 	$FFFFFFFF,$FFFF0000
col8		AND 	D2,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		DC.L 	$00000000,$0000FFFF
col9		OR 	D1,(A0)+
		AND 	D2,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
	 	DC.L 	$FFFF0000,$0000FFFF
col10		AND 	D2,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		DC.L 	$0000FFFF,$0000FFFF
col11		OR 	D1,(A0)+
		OR 	D1,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		DC.L 	$FFFFFFFF,$0000FFFF
col12		AND 	D2,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		DC.L 	$00000000,$FFFFFFFF
col13		OR 	D1,(A0)+
		AND 	D2,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		DC.L 	$FFFF0000,$FFFFFFFF
col14		AND 	D2,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		DC.L 	$0000FFFF,$FFFFFFFF
col15		OR 	D1,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		OR 	D1,(A0)+
		DC.L 	$FFFFFFFF,$FFFFFFFF

polyfill_lp		MOVE.L 	D3,D0
		SWAP 	D0
		MOVE.L 	D4,D1
		SWAP 	D1
		ADD.L 	A1,D3
		ADD.L 	A2,D4
* Draw a horizontal scan line
Hline		MOVE 	D0,D2
		SUB	D0,D1
		AND.B 	#$F0,D2		stuff!
		LSR 	#1,D2			usual
		MOVE.L 	A6,A0
		ADDA.W 	D2,A0
		AND 	#15,D0
		MOVEQ 	#-1,D2		
		LSR 	D0,D2
		ADD 	D1,D0			split
		SUB 	#16,D0			over
		BPL.S	multi_chunk		two chunks?
		NOT 	D0
		MOVEQ 	#-1,D1		one		
		LSL 	D0,D1			chunk
		AND 	D1,D2			case
		MOVE 	D2,D1
		NOT 	D2
		BRA.S 	end_chunk				
multi_chunk		MOVE 	D2,D1			split case			
		NOT 	D2
first_chunk		DS.W 	4
		ADDQ 	#1,D0
		MOVE 	D0,D1
		AND.B 	#$F0,D0
		LSR 	#2,D0
		NEG 	D0
		JMP 	miss_main(PC,D0)
chunks_20		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+		
chunks_19		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_18		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_17		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_16		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_15		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_14		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_13		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_12		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_11		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_10		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_9		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_8		MOVE.L	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_7		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_6		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_5		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_4		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_3		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_2		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
chunks_1		MOVE.L 	D7,(A0)+
		MOVE.L 	A5,(A0)+
miss_main		ADD 	D1,D1
		MOVE 	e_masks(PC,D1),D1 
		MOVE 	D1,D2
		NOT 	D2
end_chunk		DS.W 	4
hline_done		SUBQ 	#1,D5
		BMI 	Left_rchd
		SUBQ 	#1,D6
		BMI 	Right_rchd
		LEA 	160(A6),A6
		SUBQ 	#1,(SP)
		BNE 	polyfill_lp
poly_done		ADDQ.L 	#2,SP 
		RTS

e_masks		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE
		DC.L $00008000,$C000E000,$F000F800,$FC00FE00,$FF00FF80,$FFC0FFE0,$FFF0FFF8,$FFFCFFFE

* Calculate new gradient when vertex
* is reached on the left or right.

gradient		MACRO
		DIVU 	D0,D1		
		SWAP 	D0		
		MOVE 	D1,D0		
		SWAP 	D0		
		CLR 	D1		
		DIVU	D0,D1		
		MOVE 	D1,D0		
		ENDM

Left_rchd 		SUB.L 	A2,D4
		MOVE.L 	(A3),D3
		MOVE 	-(A3),D5
		SUB 	D3,D5
		CLR 	D3
		MOVEQ 	#0,D0
		MOVE 	D5,D0
		MOVEQ 	#0,D1
		MOVE 	-(A3),D1
		SUB 	4(A3),D1
Get_grad_l		BEQ.S 	vert_grad_l
		BMI.S 	neg_grad_l
		gradient
l_done_1		MOVE.L 	D0,A1
		CMP 	#1,D6
		BMI.S 	two_verts
		BRA 	polyfill_lp
vert_grad_l		MOVEQ 	#0,D0
l_done_2		MOVE.L 	D0,A1
		CMP 	#1,D6
		BMI.S 	two_verts
		BRA 	polyfill_lp
neg_grad_l		NEG 	D1
		gradient
		NEG.L 	D0
l_done_3		MOVE.L 	D0,A1
		CMP 	#1,D6
		BMI.S 	two_verts
		BRA 	polyfill_lp

Right_rchd		ADDQ 	#1,D5
		SUB.L 	A1,D3
two_verts		MOVE.L 	-4(A4),D4
		MOVEQ 	#0,D1
		MOVE 	(A4)+,D1
		MOVE 	(A4)+,D6
		SUB 	D4,D6
		CLR 	D4
		MOVEQ 	#0,D0
		MOVE 	D6,D0
		SUB 	-8(A4),D1
Get_grad_r		BEQ.S 	vert_grad_r
		BMI.S 	neg_grad_r
		gradient
		MOVE.L 	D0,A2
r_done_1		BRA 	polyfill_lp
vert_grad_r		MOVEQ 	#0,D0
r_done_2		MOVE.L 	D0,A2
		BRA 	polyfill_lp
neg_grad_r		NEG 	D1
		gradient
		NEG.L 	D0
r_done_3		MOVE.L	D0,A2
		BRA 	polyfill_lp

SWAPSCREENS		MOVE.L	PHYSCREEN,D0
		MOVE.L	LOGSCREEN,PHYSCREEN
		MOVE.L	D0,LOGSCREEN
		MOVE.B	PHYSCREEN+1,$FF8201
		MOVE.B	PHYSCREEN+2,$FF8203
		RTS

CLEARSCREEN		LEA	CLEAR_LIST,A6
		MOVEM.L	(A6)+,D0-D7/A0-A5
		MOVE.L	LOGSCREEN,A6
SHIT		SET 0
		REPT 520
		MOVEM.L	D0-D7/A0-A5,SHIT(A6) 
SHIT		SET SHIT+56
		ENDR
		MOVEM.L	D0-D5,SHIT(A6)
		RTS

CLEAR_LIST		DCB.L	14,0
STORAGEA		DS.W	(3*100)
STORAGEB		DS.W	(3*100)*3
PSTORAGE		DS.L	20
ZBUFFER		DS.W	100
OLDVB		DC.L	0
NEWVB		NEG	VB_NOW
		JSR	MUS+14
		RTE
VB_NOW		DC.W	1
LOGSCREEN		DC.L	SCREEN
PHYSCREEN		DC.L	SCREEN1
X0		DC.W	160
Y0		DC.W	90
ZOBS		DC.W	1000
DIST		DC.W	999
XOFFSET		DC.W	0
YOFFSET		DC.W	0
ZOFFSET		DC.W	0
PSEQUENCES		DC.L	SEQUENCES
POBJECT		DC.L	0
INCXANGLE		DC.W	0
INCYANGLE		DC.W	0
INCZANGLE		DC.W	0
INCXOFFSET		DC.W	0
INCYOFFSET		DC.W	0
INCZOFFSET		DC.W	0
INCDIST		DC.W	0
INCX0		DC.W	0
INCY0		DC.W	0
CLIPFLAG		DC.W	1
NEXTSEQUENCE	DC.W	1
TIMERSEQUENCE	DC.W	0
WINDOW_BOUNDARIES	DC.W	1,1,319,180

SINCOS_TABLE	DC.W 0,286,572,857,1143,1428,1713,1997
		DC.W 2280,2563,2845,3126,3406,3686,3964,4240
		DC.W 4516,4790,5063,5334,5604,5872,6138,6402
		DC.W 6664,6924,7182,7438,7692,7943,8192,8438
		DC.W 8682,8923,9162,9397,9630,9860,10087,10311
		DC.W 10531,10749,10963,11174,11381,11585,11786,11982
		DC.W 12176,12365,12551,12733,12911,13085,13255,13421
		DC.W 13583,13741,13894,14044,14189,14330,14466,14598
		DC.W 14726,14849,14968,15082,15191,15296,15396,15491
		DC.W 15582,15668,15749,15826,15897,15964,16026,16083
		DC.W 16135,16182,16225,16262,16294,16322,16344,16362
		DC.W 16374,16382,16384,16382,16374,16362,16344,16322
		DC.W 16294,16262,16225,16182,16135,16083,16026,15964
		DC.W 15897,15826,15749,15668,15582,15491,15396,15296
		DC.W 15191,15082,14968,14849,14726,14598,14466,14330
		DC.W 14189,14044,13894,13741,13583,13421,13255,13085
		DC.W 12911,12733,12551,12365,12176,11982,11786,11585
		DC.W 11381,11174,10963,10749,10531,10311,10087,9860
		DC.W 9630,9397,9162,8923,8682,8438,8193,7943
		DC.W 7692,7438,7182,6924,6664,6402,6138,5871
		DC.W 5604,5334,5063,4790,4516,4240,3964,3686
		DC.W 3406,3126,2845,2563,2280,1997,1713,1428
		DC.W 1143,857,572,286,0,-285,-571,-857
		DC.W -1142,-1427,-1712,-1996,-2280,-2563,-2845,-3126
		DC.W -3406,-3685,-3963,-4240,-4516,-4790,-5062,-5334
		DC.W -5603,-5871,-6137,-6401,-6663,-6924,-7182,-7438
		DC.W -7691,-7943,-8192,-8438,-8682,-8923,-9161,-9397
		DC.W -9630,-9860,-10086,-10310,-10531,-10748,-10963,-11173
		DC.W -11381,-11585,-11785,-11982,-12175,-12365,-12550,-12732
		DC.W -12910,-13084,-13254,-13420,-13582,-13740,-13894,-14043
		DC.W -14188,-14329,-14466,-14598,-14725,-14848,-14967,-15081
		DC.W -15190,-15295,-15395,-15491,-15582,-15668,-15749,-15825
		DC.W -15897,-15964,-16025,-16082,-16135,-16182,-16224,-16261
		DC.W -16294,-16321,-16344,-16361,-16374,-16381,-16384,-16381
		DC.W -16374,-16361,-16344,-16321,-16294,-16261,-16224,-16182
		DC.W -16135,-16082,-16025,-15964,-15897,-15825,-15749,-15668
		DC.W -15582,-15491,-15395,-15295,-15190,-15081,-14967,-14848
		DC.W -14725,-14598,-14466,-14329,-14188,-14043,-13894,-13740
		DC.W -13582,-13420,-13254,-13084,-12910,-12732,-12550,-12365
		DC.W -12175,-11982,-11785,-11585,-11381,-11173,-10963,-10748
		DC.W -10531,-10310,-10086,-9860,-9630,-9397,-9161,-8923
		DC.W -8682,-8438,-8191,-7943,-7691,-7438,-7182,-6924
		DC.W -6663,-6401,-6137,-5871,-5603,-5334,-5062,-4790
		DC.W -4516,-4240,-3963,-3685,-3406,-3126,-2845,-2563
		DC.W -2280,-1996,-1712,-1427,-1142,-857,-571,-285
		DC.W 0,286,572,857,1143,1428,1713,1997
		DC.W 2280,2563,2845,3126,3406,3686,3964,4240
		DC.W 4516,4790,5063,5334,5604,5872,6138,6402
		DC.W 6664,6924,7182,7438,7692,7943,8192,8438
		DC.W 8682,8923,9162,9397,9630,9860,10087,10311
		DC.W 10531,10749,10963,11174,11381,11585,11786,11982
		DC.W 12176,12365,12551,12733,12911,13085,13255,13421
		DC.W 13583,13741,13894,14044,14189,14330,14466,14598
		DC.W 14726,14849,14968,15082,15191,15296,15396,15491
		DC.W 15582,15668,15749,15826,15897,15964,16026,16083
		DC.W 16135,16182,16225,16262,16294,16322,16344,16362
		DC.W 16374,16382,16384,16382,16374,16362,16344,16322
		DC.W 16294,16262,16225,16182,16135,16083,16026,15964
		DC.W 15897,15826,15749,15668,15582,15491,15396,15296
		DC.W 15191,15082,14968,14849,14726,14598,14466,14330
		DC.W 14189,14044,13894,13741,13583,13421,13255,13085
		DC.W 12911,12733,12551,12365,12176,11982,11786,11585
		DC.W 11381,11174,10963,10749,10531,10311,10087,9860
		DC.W 9630,9397,9162,8923,8682,8438,8193,7943
		DC.W 7692,7438,7182,6924,6664,6402,6138,5871
		DC.W 5604,5334,5063,4790,4516,4240,3964,3686
		DC.W 3406,3126,2845,2563,2280,1997,1713,1428
		DC.W 1143,857,572,286,0,-285,-571,-857
FONT		INCBIN 	FONT
MUS		INCBIN 	WEIRD.MUS
