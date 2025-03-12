*********************************************************
* LOGIC.S CONTAINS CONTROL ROUTINES FOR THE FOLLOWING   *
* GAME PARTS						*
*********************************************************
*
* 1.	EXPLOSION HANDLING			
* 2.	GROUND OBJECTS (EG TREES)
* 3.	STANDARD SHIP FIRE
* 4.	HOMING AND STRAIGHT ENEMY FIRE
* 5.	LASER GATES				1
* 6.	MOVING WALLS				2
* 7.	TANKS (ROAD MAP FOLLOWING)		3
* 8.	GUN TURRETS				4
* 9.	SPRINGING EMEMIES			5
* 10.	BASE GAURDIAN				6
* 11.	VERTICAL LASERS				7
* 12.	SHOOTABLE WALLS				8
* 13.	MINE LAYERS				9
* 14.	PARACHUTE_MINES				10
* 15.   VELOCITY OVERRIDES!
* 16. 	MOVING GUN TURRETS(LEFT/RIGHT)		11
* 17.   WAVERS (SPLIT INTO SAUCERS WHEN SHOT)	12
* 18.   SAUCERS					13
* 19.   SI COMMANDER (CONTROLS SI'S)	
* 20.	SPACE INVADER
*
*********************************************************
* THE FOLLOWING ROUTINES ARE THOSE THAT CONTROL THE WAY *
* IN WHICH DIFFERENT GAME OBJECTS BEHAVE                *
*********************************************************
*
*	A0 = PROJ_DIVU TABLE
*	A1 = THINGS TO DO LIST
*	A2 =
*	A3 = DP1 (LIST OF DRAWPOINTERS)
*	A4 = 
* 	A5 = DEPTH LIST
*	A6 =
*	A7 =
*
*	D0 =
*	D1 =
*	D2 =
*	D3 =
*	D4 =
*	D5 = CURRENT POS X
*	D6 = LAST Z MOVEMENT
*	D7 =
*
***** A LIST OF RTHE SCORES YOU GET FOR DESTROYING EACH TYPE OF ENEMY

SC_VERT_LASER:		EQU	100
SC_GUN_TURRET:		EQU	250
SC_LASER_GATE:		EQU	150
SC_SPRING_BUG:		EQU	300
SC_SHOOT_WALL:		EQU	50
SC_BASE:		EQU	1000
SC_TANK:		EQU	500
SC_MINE_LAYER:		EQU	500
SC_PARACHUTE:		EQU	50
SC_MOVING_GUN:		EQU	350
SC_WAVER:		EQU	750
SC_SAUCER:		EQU	200
SC_SI_COMMANDER:	EQU	1000
SC_SI:			EQU	100

NO_OBJECT:
	RTS

******************************************
* EXPLOSION ROUTINE                      *
******************************************
*
* 0  object handling routine
* 4  explosion list pointer
* 8  x, y, z
* 30 current status (alive/dead etc)
* 31 shootability
*

ADD_AN_EXPLOSION:
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
.FIND_SLOT_LOOP:
	TST.W	(A2)			get a free slot
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.FIND_SLOT_LOOP	
.GOT_FREE_SLOT:
	MOVE.W	#1,(A2)+		fill the slot
	MOVE.L	(A2)+,A4		find data pos
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	SF	30(A4)			exp. is not dead
	SF	31(A4)			and cannot be destroyed
	MOVE.L	#EXPLODE_ROUTINE,(A4)+	uses explode rout
	MOVE.L	D4,(A4)+		explosion table
	MOVEM.W	D0-D2,(A4)		x,y,z pos
	MOVE.W	D3,6(A4)
	MOVE.L	D7,8(A4)
	RTS

EXPLODE_ROUTINE:
	MOVE.L	(A2),A6			get explosion frame
	MOVE.L	(A6)+,D4		get exp. data
	BMI.S	.REMOVE_OBJECT		if end of table then remove
	MOVE.L	A6,(A2)+		put back pointer
	TST.L	D4			if 0 then nothing to draw
	BEQ.S	.OFF_SCREEN
	MOVEM.W	(A2)+,D0-D2		x,y,z data
	MOVE.L	D4,6(A2)		position for draw data
	ADD.W	D6,D2			add last z movement
	BMI.S	.REMOVE_OBJECT		if out of range remove from ob list
	MOVE.W	D2,-2(A2)		put back z
	SUB.W	D5,D0			subtract left boundary
	CMP.W	#10*64,D0		check if its visible
	BHI.S	.OFF_SCREEN		nope!
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	SUB.W	OFFSET_ADDS+4(PC),D3
	CMP.W	#8*64,D3
	BHI.S	.OFF_SCREEN
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		get projdivu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#4,D3			
	AND.W	#%1111111111111100,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	MOVE.L	(A3,D3.W),A6		get address of draw buffer
	MOVE.L	A2,(A6)+		data address
	MOVE.W	D0,(A6)+		x pos
	MOVE.W	D1,(A6)+		y pos
	MOVE.L	A6,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

******************************************
* ROUTINE FOR SCENERY OBJECTS            *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_GROUND_OBJECTS:
	MOVE.W	#1,(A1)			fill object slot
	SF	30(A2)			not dead
	ST	31(A2)			destructible
	MOVE.L	(A3)+,(A2)+		get rout type from list
	MOVE.L	A3,(A2)+		address of list data
	MOVE.W	D5,(A2)+		x
	MOVE.W	(A4),D0			ground height
	ADD.W	2(A4),D0
	ASR.W	#1,D0			(average)
	MOVE.W	D0,(A2)+		y
	MOVE.W	D6,(A2)+		z
	RTS

GROUND_OBJECTS:
	MOVE.L	(A2)+,A6		base of object list		
	MOVEM.W	(A2)+,D0-D2		x,y,z
	ADD.W	D6,D2			add last z movement
	BMI.S	.REMOVE_OBJECT		out of range so remove
	MOVE.W	D2,-(A2)		replace z
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check if its visible
	BHI.S	.OFF_SCREEN		
	SUB.W	#(5*64)+32,D0		give + and - range
	CMP.W	#9*64,D2		of the back?
	BHI.S	.OFF_SCREEN
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		get projdivu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen missle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprirte size offset
	LEA	(A6,D2.W),A4		get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)		take it off object list
	RTS

*******************************************
* CONVENTIONAL MISSILE ROUTINE            *
*******************************************
*
* 0  object handling routine
* 4  address of graphics list
* 8  x, y, z
* 30 current status (alive/dead etc)
* 31 shootability
*

MISSILE_SPEED:	DC.W	32
MISSILE_COUNT:	DC.W	0

MISSILE1_ROUTINE:
	MOVE.L	(A2)+,A6		base of object list		
	MOVEM.W	(A2)+,D0-D2		x,y,z data
	ADD.W	MISSILE_SPEED(PC),D2	add z movement of missile
	CMP.W	#936-424+128,D2
	BGE.S	.REMOVE_OBJECT		if out of range then remove
	MOVE.W	D2,-(A2)		put back z
	BSR.S	FIND_GROUND_HEIGHT	(result in d7)
	CMP.W	D7,D1			did it hit land?
	BGE.S	.REMOVE_OBJECT
	MOVE.L	MISSILE_INFORMATION,A4
	MOVE.L	A1,(A4)+		info for collision detect routine
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D2,(A4)+
	MOVE.L	A4,MISSILE_INFORMATION	
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	SUB.W	OFFSET_ADDS+4(PC),D3
	CMP.W	#8*64,D3
	BHI.S	.OFF_SCREEN
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x1
	SWAP	D4			perspected x2
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x1
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

FIND_GROUND_HEIGHT:
	MOVE.W	D2,-(A7)
	ADD.W	OFFSET_ADDS+6(PC),D2
	SUBQ.W	#1,D2			
	MOVE.L	BASE_MAP_POS(PC),A4	get base map position
	MOVE.W	D0,D4		
	LSR.W	#5,D4
	AND.L	#%1111111111111110,D4
	ADD.L	D4,A4			get x map pos of point
	MOVE.W	#576+64,D4
	SUB.W	D2,D4			get y pos on the map	
	LSR.W	#6,D4			
	MULU	#66,D4			
	ADD.L	D4,A4			

	MOVE.W	D0,D4			calc x point 1
	AND.W	#%111111,D4	
	ADD.W	D4,D4		
	LSL.W	#8,D4		
	MOVE.W	2(A4),D7	
	SUB.W	(A4),D7		
	MULS	D4,D7		
	ADD.L	D7,D7		
	SWAP	D7		
	ADD.W	(A4),D7			point #1
	MOVE.W	66+2(A4),D3	
	SUB.W	66(A4),D3	
	MULS	D4,D3		
	ADD.L	D3,D3		
	SWAP	D3		
	ADD.W	66(A4),D3		point #2

	MOVE.W	D2,D4			work out final point
	AND.W	#%111111,D4	
	ADD.W	D4,D4		
	LSL.W	#8,D4		
	SUB.W	D3,D7		
	MULS	D4,D7		
	ADD.L	D7,D7		
	SWAP	D7		
	ADD.W	D3,D7			height is d7
	MOVE.W	(A7)+,D2		height at d0,d2 is d7
	RTS

*****************************************
* ROUTINE FOR LASER GATES               *
*****************************************
*
* 0  address of handling routine
* 4  address of object list data
* 8  x, y, z
* 14 indicator if right tower is alive(left tower only)
* 16 pointer to right tower
* 22 laser line 1
* 24	"   "   2
* 26	"   "   3
* 28	"   "   4
* 30 current status (alive/dead etc)
* 31 shootability
* 

INIT_LASER_GATE:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
***********LEFT TOWER************
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	(A4),D0
	ADD.W	2(A4),D0
	ASR.W	#1,D0
	MOVE.W	D0,(A2)+		Y ALWAYS ON FLOOR
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#0,(A2)
	MOVE.L	D5,-(A7)
	MOVE.L	A0,-(A7)
	MOVE.B	-1(A0),D0
	ADDQ.W	#1,D0			GET RIGHT DATA
	ADD.W	#64,D5
.LOOP:	CMP.B	(A0)+,D0
	BEQ.S	.STORE_RIGHT_TOWER
	ADD.W	#64,D5
	BRA.S	.LOOP
.STORE_RIGHT_TOWER:
.NEXT_SLOT:
	ADDQ.W	#6,A1
	TST.W	(A1)
	BPL.S	.NEXT_SLOT
	MOVE.W	#1,(A1)
	MOVE.L	2(A1),A0
	MOVE.L	A0,2(A2)
************RIGHT TOWER*************
	SF	30(A0)			NOT DEAD
	ST	31(A0)			CAN BE DESTROYED!
	MOVE.L	#RIGHT_LASER_GATE,(A0)+	TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A0)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A0)+		X
	MOVE.W	(A4),D0
	ADD.W	2(A4),D0
	ASR.W	#1,D0
	MOVE.W	D0,(A0)+		Y ALWAYS ON FLOOR
	MOVE.W	D6,(A0)+		Z
	MOVE.W	#0,(A0)+
	MOVE.L	A2,(A0)+		POINTER TO LEFT DATA
	LEA	6(A2),A2
	MOVEQ	#25,D1
	ASR.W	#2,D0
	MOVE.W	D1,(A0)+		LASER LINE ONE HEIGHT
	MOVE.W	D1,(A2)+
	ADD.W	D0,D1
	MOVE.W	D1,(A0)+		LASER LINE TWO HEIGHT
	MOVE.W	D1,(A2)+
	ADD.W	D0,D1
	MOVE.W	D1,(A0)+		LASER LINE THREE HEIGHT
	MOVE.W	D1,(A2)+
	ADD.W	D0,D1
	MOVE.W	D1,(A0)+		LASER LINE FOUR HEIGHT
	MOVE.W	D1,(A2)+
	MOVE.L	(A7)+,A0
	MOVE.L	(A7)+,D5
	RTS

LEFT_LASER_GATE:
	TST.B	30-4(A2)
	BNE	KILL_LASER_GATE
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z,X2 DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	D2,-2(A2)		PUT BACK Z
	CMP.W	#9*64,D2
	BGE	.OFF_SCREEN
	SUB.W	D5,D0			subtract left x boundary
	BMI	.CHECK_RIGHT
	CMP.W	#(10*64)+32,D0		check to see if it is
	BGT	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D4			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0		
	MULS	D2,D1			Y BOTTOM
	SWAP	D0			perspected x
	SWAP	D1			perspected y BOTTOM
	ADD.W	#160,D0			screen middle x
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	TST.B	(A2)
	BEQ.S	.NEED_LASER_LINES
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	MOVE.W	D1,D3			
	SUB.W	#13,D3			GET ACTUAL HEIGHT DATA
	ADD.W	#Y_MIDDLE,D1		screen middle y
	ADD.W	D4,D4
	MOVE.L	(A3,D4.W),A2		get address of draw buffer

	MOVE.L	A4,(A2)+		data address	(LEFT PILLAR)
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.W	D3,(A2)+

	MOVE.L	A2,(A3,D4.W)		increment pointer
	RTS

.NEED_LASER_LINES:
	MOVE.L	2(A2),A4
	MOVE.W	8(A4),D3
	SUB.W	D5,D3
	CMP.W	#(10*64)+32,D3
	BHI.S	.OFF_RIGHT
	SUB.W	#(5*64)+32,D3
	BRA.S	.CONTINUE
.OFF_RIGHT:
	MOVE.W	#(5*64)+16,D3
.CONTINUE:
	MULS	D2,D3
	SWAP	D3
	ADD.W	#160,D3
	MOVE.W	(A5,D4.W),D7		get sprite size offset
	LEA	(A6,D7.W),A4		thus get sprite data address
	MOVE.L	A4,D7			**OOPS NEED A4!
	ADD.W	#Y_MIDDLE,D1		screen middle y
	ADD.W	D4,D4
	MOVE.L	(A3,D4.W),A4		get address of draw buffer

	MOVE.L	D7,40(A4)		data address	(LEFT PILLAR)
	MOVE.W	D0,44(A4)		x pos
	MOVE.W	D1,46(A4)		y pos
	SUB.W	#Y_MIDDLE+13,D1
	MOVE.W	D1,48(A4)

	MOVE.L	#LASER_LINE,D7
	SUB.W	D0,D3			GET RIGHT EDGE DATA
	LEA	6(A2),A2
	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		1 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		2 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		3 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		4 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	LEA	10(A4),A4
	MOVE.L	A4,(A3,D4.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	TST.B	(A2)			ARE LASERS ON?
	BNE.S	.NO_COL
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.L	2(A2),A6		GET COLLISION WIDTH
	MOVE.W	8(A6),D3
	SUB.W	D0,D3
	MOVE.W	D0,(A4)+		MISSILE MIGHT HIT SHIP!
	MOVE.W	D3,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	#200,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.NO_COL:
	MOVE.W	#-1,-2(A1)
	RTS

.CHECK_RIGHT:
	TST.B	(A2)
	BNE.S	.OFF_SCREEN
	MOVE.L	2(A2),A4
	MOVE.W	8(A4),D3
	SUB.W	D5,D3
	BMI.S	.OFF_SCREEN
	CMP.W	#(10*64)+32,D3
	BLT.S	.ON_SCREEN		NO LASER LINES!
	MOVE.W	#(10*64)+48,D3		PUT ON RIGHT EDGE ARTIFICIAL
.ON_SCREEN:
	MOVE.W	#-((5*64)+32),D0
	SUB.W	#(5*64)+32,D3
	MOVE.W	D2,D4			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0			X LEFT
	MULS	D2,D3			X RIGHT
	SWAP	D0			perspected x LEFT
	SWAP	D3			perspected x RIGHT
	ADD.W	#160,D0			screen middle x
	ADD.W	#160,D3			screen middle x
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	ADD.W	D4,D4
	MOVE.L	(A3,D4.W),A4		get address of draw buffer

	MOVE.L	#LASER_LINE,D7
	SUB.W	D0,D3			GET RIGHT EDGE DATA

	LEA	6(A2),A2
	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		1 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		2 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		3 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.W	(A2)+,D1
	MULS	D2,D1
	SWAP	D1
	ADD.W	#Y_MIDDLE,D1
	MOVE.L	D7,(A4)+		4 LASER BEAM
	MOVE.W	D0,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	D3,(A4)+

	MOVE.L	A4,(A3,D4.W)		increment pointer
	RTS

RIGHT_LASER_GATE:
	TST.B	30-4(A2)
	BNE.S	KILL_LASER_GATE
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z,X2 DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI.S	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	D2,-2(A2)		PUT BACK Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#(10*64)+32,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D4			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0		
	MULS	D2,D1			Y BOTTOM
	SWAP	D0			perspected x
	SWAP	D1			perspected y BOTTOM
	ADD.W	#160,D0			screen middle x
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	MOVE.W	D1,D3
	SUB.W	#13,D3
	ADD.W	#Y_MIDDLE,D1		screen middle y
	ADD.W	D4,D4
	MOVE.L	(A3,D4.W),A2		get address of draw buffer

	MOVE.L	A4,(A2)+		data address	(LEFT PILLAR)
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.W	D3,(A2)+		HEIGHT OF TOWER
	MOVE.L	A2,(A3,D4.W)		increment pointer
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
.OFF_SCREEN:
	RTS

KILL_LASER_GATE:
	ADD.L	#SC_LASER_GATE,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	12(A2),A4
	LEA	16(A2),A6
	ST	(A4)
	MOVE.L	#EXPLOSION_LIST1+(5*4),D4
	MOVEQ	#16,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_16,D7		SPRITE_ROUT
	MOVE.W	(A6)+,D1
	BSR	ADD_AN_EXPLOSION
	MOVE.W	(A6)+,D1
	BSR	ADD_AN_EXPLOSION
	MOVE.W	(A6)+,D1
	BSR	ADD_AN_EXPLOSION
	MOVE.W	(A6)+,D1
	BSR	ADD_AN_EXPLOSION
	RTS

********************************************
* ROUTINE FOR MOVING WALLS ON MAP          *
********************************************
*
* 0  address of handling routine
* 4  moving data start position 
* 8  effective z position
* 10 position of map data to be altered
* 14 piece of data to replace in map after rout end
* 16 number of moving bits
* 30 current status (alive/dead etc)
* 31 shootability
*
 
INIT_MOVING_WALL:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	SF	31(A2)			CANNOT BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A0,-(A7)
	MOVE.L	(A3)+,A0
	MOVE.L	A0,(A2)+		TELL IT MOVE DATA START POINT
	MOVE.W	D6,(A2)+		AND MOVE DATA END POINT
	MOVE.L	A4,(A2)+		AND MEMORy posITION OF WALL
	MOVE.W	(A0)+,(A2)+		REPLACEMENT DATA 
	MOVE.L	(A7)+,A0
	MOVE.B	-1(A0),D0
	MOVEQ	#0,D1
.FIND_LOOP:
	CMP.B	(A0)+,D0
	BNE.S	.END_LOOP
	ADDQ.W	#1,D1
	ADD.W	#64,D5
	ADDQ.W	#2,A4			
	SUBQ.W	#1,D7
	BMI.S	.END_LOOP
	BRA.S	.FIND_LOOP
.END_LOOP:
	LEA	-1(A0),A0
	MOVE.W	D1,(A2)+
	RTS

MOVING_WALL_ROUTINE:
	MOVE.L	(A2)+,A4		START OF MOVE LIST
	MOVE.W	(A2)+,D2		END OF MOVE LIST
	ADD.W	D6,D2
	CMP.W	#-192,D2
	BLE.S	.REMOVE_OBJECT
	MOVE.W	D2,-2(A2)
	MOVE.W	(A4)+,D0		GET NEXT DATA
	CMP.W	#1234,D0		AT END OF LIST
	BNE.S	.NOT_END
	MOVE.L	(A4)+,A4		BACK TO BEGINNING
	MOVE.W	(A4)+,D0
.NOT_END:
	MOVE.L	A4,-6(A2)		PUT BACK POINTER
	MOVE.W	6(A2),D7
	MOVE.L	(A2)+,A2		MEMORy posITION OF WALL		
.LOOP:
	MOVE.W	D0,-66(A2)
	MOVE.W	D0,(A2)+
	DBF	D7,.LOOP
	RTS
.REMOVE_OBJECT:
	MOVE.L	(A2)+,A4		PUT BACK DATA TO AVOID FLICK
	MOVE.W	(A2)+,D0		PROBLEM
	MOVE.W	(A2)+,D7
.LOOP1:
	MOVE.W	D0,-66(A4)
	MOVE.W	D0,(A4)+
	DBF	D7,.LOOP1
	MOVE.W	#-1,-2(A1)
	RTS

WALL_MOVEMENT1:
	DC.W	-20,-5,10,25,40,55,70,85,100,115,130,145,160,175
	DC.W	190,205,220,235
WALL_MOVEMENT1B
	DC.W	235,220,205,190,175,160,145,130,115,100,85,70,55,40
	DC.W	25,10,-5,-20
	DC.W	1234
	DC.L	WALL_MOVEMENT1

**************************************************
* ROUTINE FOR MOVING BUGGY TO FOLLOW ROAD LAYOUT *
**************************************************
*
* 0  address of handling routine
* 4  
* 8  x,y,z
* 14 0,1,2,3 = LEFT, UP, RIGHT,DOWN
* 16 counter until next movement check
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_BUGGY1:
	MOVEQ	#0*8,D0
	BRA.S	REST_OF_INIT_BUGGY
INIT_BUGGY2:
	MOVEQ	#1*8,D0
	BRA.S	REST_OF_INIT_BUGGY
INIT_BUGGY3:
	MOVEQ	#2*8,D0
	BRA.S	REST_OF_INIT_BUGGY
INIT_BUGGY4:
	MOVEQ	#3*8,D0
REST_OF_INIT_BUGGY:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	ADDQ.L	#4,A2
	MOVE.W	D5,(A2)+		X
	MOVE.W	#0,(A2)+		(CALULATED BY ROUTINE)
	MOVE.W	D6,(A2)+		Z
	MOVE.W	D0,(A2)+
	MOVE.W	#4,(A2)+		1 SQUARE MOVEMENT UNTIL BUGGY CHECK
	RTS

BUGGY_MOVEMENT_TABLE:		*BUGGY VELOCITIES
	DC.W	-16,0
	DC.L	TANK_LEFT
	DC.W	0,16
	DC.L	TANK_UP
	DC.W	16,0
	DC.L	TANK_RIGHT
	DC.W	0,-16
	DC.L	TANK_DOWN

BUGGY_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_BUGGY
	ADDQ.L	#4,A2
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	MOVE.W	(A2),D3
	MOVE.L	BUGGY_MOVEMENT_TABLE+4(PC,D3.W),A6
	MOVE.L	A6,-10(A2)		FILL IN FOR HIT DETECT
 	MOVE.L	BUGGY_MOVEMENT_TABLE(PC,D3.W),D3
	ADD.W	D3,D2			ADD Z CAR MOVEMENT
	SWAP	D3
	ADD.W	D3,D0			ADD X CAR MOVEMENT
	CMP.W	#32*64,D0
	BHI.S	.REMOVE_OBJECT		IF IT GOES OFF LEFT OR RIGHT THEN LOSE IT
	CMP.W	#30*64,D2		IF ITS 20 SQUARES AHEAD
	BGE.S	.REMOVE_OBJECT		LOSE IT
	CMP.W	#-20*64,D2		IF ITS 10 SQUARES BEHIND
	BLE.S	.REMOVE_OBJECT		LOSE IT
	SUBQ.W	#1,2(A2)		DECREMENT COUNTER
	BNE.S	.NO_DIRECTION_CHECK
	BSR	DIRECTION_CHECK		
.NO_DIRECTION_CHECK:
	MOVE.W	D2,-(A2)		PUT BACK Z
	BSR	FIND_GROUND_HEIGHT	GET HEIGHT AT X,Z
	MOVE.W	D7,-(A2)		PUT BACK IN ROUT FOR COLL ETC
	MOVE.W	D0,-(A2)
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	MOVE.W	D2,D4
	SUB.W	OFFSET_ADDS+4(PC),D3
	CMP.W	#8*64,D3
	BHI.S	.OFF_SCREEN
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D7
	SWAP	D0			perspected x
	SWAP	D7			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D7		screen middle y
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	LSR.W	#4,D3
	AND.W	#%1111100,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D7,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.KILL_BUGGY:
	ADD.L	#SC_TANK,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
	SUB.W	#16,D0
	BSR	ADD_AN_EXPLOSION
	ADD.W	#64,D0
	BSR	ADD_AN_EXPLOSION
	RTS

DIRECTION_CHECK:
	MOVE.W	#4,2(A2)		RESET COUNTER
	MOVEQ	#0,D3
	MOVE.W	CURRENT_POS_Z,D3	GET OFFSET INTO CURRENT MAP FRAME
	LSL.L	#5,D3
	LEA	OBJECT_ARRAY,A4
	ADD.L	D3,A4
	MOVEQ	#0,D3
	MOVE.W	D0,D3
	LSR.W	#6,D3			GET X OFFSET INTO FRAME
	ADD.L	D3,A4
	MOVE.W	#576,D3
	SUB.W	D2,D3			
	ASR.W	#1,D3			
	EXT.L	D3
	AND.L	#%11111111111111111111111111100000,D3
	ADD.L	D3,A4			ISOLATE OBJECT POSITION
	MOVE.W	(A2),D4
	MOVE.L	A4,-(A7)
	MOVE.L	.CHECK_LIST(PC,D4.W),A4
	JMP	(A4)

.CHECK_LIST:
	DC.L	.LEFT,.LEFT,.UP,.UP,.RIGHT,.RIGHT,.DOWN,.DOWN

.LEFT:	MOVE.L	(A7)+,A4
	CMP.B	#11,-1(A4)
	BNE.S	.FIND_DIR_FL
	MOVE.W	#0*8,(A2)
	RTS

.UP:	MOVE.L	(A7)+,A4
	CMP.B	#11,-32(A4)
	BNE.S	.FIND_DIR_FU
	MOVE.W	#1*8,(A2)
	RTS

.RIGHT:	MOVE.L	(A7)+,A4
	CMP.B	#11,1(A4)
	BNE.S	.FIND_DIR_FR
	MOVE.W	#2*8,(A2)
	RTS

.DOWN:	MOVE.L	(A7)+,A4
	CMP.B	#11,32(A4)
	BNE.S	.FIND_DIR_FD
	MOVE.W	#3*8,(A2)
	RTS

.FIND_DIR_FL:
	CMP.B	#11,-32(A4)
	BNE.S	.1FL
	MOVE.W	#1*8,(A2)
	RTS
.1FL	CMP.B	#11,32(A4)
	BNE.S	.2FL
	MOVE.W	#3*8,(A2)
	RTS
.2FL	MOVE.W	#2*8,(A2)
	RTS

.FIND_DIR_FU:
	CMP.B	#11,-1(A4)
	BNE.S	.1FU
	MOVE.W	#0*8,(A2)
	RTS
.1FU	CMP.B	#11,1(A4)
	BNE.S	.2FU
	MOVE.W	#2*8,(A2)
	RTS
.2FU	MOVE.W	#3*8,(A2)
	RTS

.FIND_DIR_FR:
	CMP.B	#11,-32(A4)
	BNE.S	.1FR
	MOVE.W	#1*8,(A2)
	RTS
.1FR	CMP.B	#11,32(A4)
	BNE.S	.2FR
	MOVE.W	#3*8,(A2)
	RTS
.2FR	MOVE.W	#0*8,(A2)
	RTS

.FIND_DIR_FD:
	CMP.B	#11,-1(A4)
	BNE.S	.1FD
	MOVE.W	#0*8,(A2)
	RTS
.1FD	CMP.B	#11,1(A4)
	BNE.S	.2FD
	MOVE.W	#2*8,(A2)
	RTS
.2FD	MOVE.W	#1*8,(A2)
	RTS

******************************************
* GUN TURRET ROUTINE WITH FIRING ROUT    *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 fire repeat counter
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_GUN_TURRET:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	(A4),D0			TAKE GROUND HEIGHT FOR Y
	ADD.W	2(A4),D0
	ASR.W	#1,D0
	MOVE.W	D0,(A2)+		Y
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#5,(A2)+		FIRE SPEED
	MOVE.W	FIRE_REPEAT(PC),(A2)+	FIRE_SPEED REFILL
	RTS

TURRET_ROUTINE:
	TST.B	30-4(A2)
	BNE.S	.KILL_TURRET
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI.S	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	D2,-2(A2)		PUT BACK Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	SUBQ.W	#1,(A2)
	BNE.S	.BACK_FROM_FIRING
	MOVEM.W	D0-D2,-(A7)
	ADD.W	#18,D0			OFFSET TO FIRE POSITION
	SUB.W	#40,D1
	MOVE.W	2(A2),(A2)
	BSR	FIRE_TRACKING_SHOT
	MOVEM.W	(A7)+,D0-D2
.BACK_FROM_FIRING:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS
.KILL_TURRET:
	ADD.L	#SC_GUN_TURRET,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
	SUB.W	#16,D0
	BSR	ADD_AN_EXPLOSION
	MOVE.L	#EXPLOSION_LIST1+(1*4),D4
	MOVEQ	#16,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_16,D7		SPRITE_ROUT
	SUB.W	#32,D1
	ADD.W	#16,D0
	BSR	ADD_AN_EXPLOSION
	RTS

********************************************
* ROUTINE FOR STARTING TRACKING SHOTS      *
********************************************

FIRE_TRACKING_SHOT:
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
.FIND_SLOT_LOOP:
	TST.W	(A2)
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.FIND_SLOT_LOOP	
.GOT_FREE_SLOT:
	MOVE.W	#1,(A2)+
	MOVE.L	(A2)+,A4		GET SLOT DATA POS
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	SF	30(A4)			NOT DEAD
	SF	31(A4)			CANNOT BE DESTROYED!
	MOVE.L	#BULLET1_ROUTINE,(A4)+	TELL IT WHAT ROUTINE TO USE
	MOVE.L	#BULLET_LIST,(A4)+	OBJECT LIST POINTER
	MOVEM.W	D0-D2,(A4)
	ADDQ.W	#6,A4
	MOVE.W	SHIP_X_REAL(PC),D3
	SUB.W	D0,D3
	ASR.W	#5,D3
	MOVE.W	D3,(A4)+		X MOVEMENT
	MOVE.W	CURRENT_POS_Y(PC),D3
	SUB.W	D1,D3
	ASR.W	#5,D3
	MOVE.W	D3,(A4)+		Y MOVEMENT
	NEG.W	D2
	BEQ.S	.REMOVE_OBJECT2
	ASR.W	#5,D2
	MOVE.W	D2,(A4)+		Z MOVEMENT	
	RTS
.REMOVE_OBJECT2:
	MOVE.W	#-1,-6(A2)
	RTS

********************************************
* ROUTINE FOR STRAIGHT SHOTS	           *
********************************************

FIRE_STRAIGHT_SHOT:
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
.FIND_SLOT_LOOP:
	TST.W	(A2)
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.FIND_SLOT_LOOP	
.GOT_FREE_SLOT:
	MOVE.W	#1,(A2)+
	MOVE.L	(A2)+,A4		GET SLOT DATA POS
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	SF	30(A4)			NOT DEAD
	SF	31(A4)			CANNOT BE DESTROYED!
	MOVE.L	#BULLET1_ROUTINE,(A4)+	TELL IT WHAT ROUTINE TO USE
	MOVE.L	#BULLET_LIST,(A4)+	OBJECT LIST POINTER
	MOVEM.W	D0-D2,(A4)
	ADDQ.W	#6,A4
	MOVE.W	#0,(A4)+		X MOVEMENT
	MOVE.W	#0,(A4)+		Y MOVEMENT
	MOVE.W	#-16,(A4)+		Z MOVEMENT	
	RTS

******************************************
* ROUTINE FOR NORMAL BULLETS (ENEMY!)    *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x, y, z movement data
* 30 current status (alive/dead etc)
* 31 shootability
*

BULLET1_ROUTINE:
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	ADD.W	(A2)+,D0		DO MOVEMENT STUFF
	ADD.W	(A2)+,D1
	CMP.W	#-16,D1			TEMP TEST (NOT NEEDED WHEN FULLY DONE)
	BLE.S	.REMOVE_OBJECT
	ADD.W	(A2)+,D2
	BMI.S	.REMOVE_OBJECT_WC	IF OUT OF RANGE, REMOVE MOVE LIST
	MOVEM.W	D0-D2,-12(A2)		PUT BACK X,Y,Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT_WC:
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	D0,(A4)+		MISSILE MIGHT HIT SHIP!
	MOVE.W	#16,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	#16,(A4)+
	MOVE.W	#10,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

******************************************
* ROUTINE FOR HIGHLY SPRUNG BUG!         *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x, y, z velocity
* 20 fire repeat time
* 22 fire repeat refill
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_SPRING_BUG:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	#0,(A2)+		Y AT 0
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#0,(A2)+		X VELOCITY
	MOVE.W	#0,(A2)+		Y VELOCITY
	MOVE.W	#0,(A2)+		Z VELOCITY
	MOVE.W	#5,(A2)+		FIRE SPEED
	MOVE.W	FIRE_REPEAT(PC),(A2)+	FIRE_SPEED REFILL
	RTS

SPRING_BUG_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_SPRING_BUG
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	SHIP_X_REAL(PC),D3	GET SHIP POSITION
	CMP.W	D0,D3
	BGT.S	.RIGHT_V		ADJUST X VELOCITY ACCORDING TO POSITION
	SUBQ.W	#1,(A2)
	BRA.S	.AFTER_X_INT
.RIGHT_V:
	ADDQ.W	#1,(A2)
.AFTER_X_INT:
	ADD.W	(A2)+,D0		ADD X VELOCITY
	CMP.W	#32*64,D0		OUT OF RANGE?
	BLS.S	.NO_BOUNCE_X
	MOVE.W	#0,-2(A2)
.NO_BOUNCE_X:
	ADDQ.W	#4,(A2)			ADD GRAVITY TO Y VELOCITY
	ADD.W	(A2)+,D1		ADD Y VELOCITY
	ADD.W	(A2)+,D2		ADD Z VELOCITY
	BSR	FIND_GROUND_HEIGHT	IS IT BOUNCING ON THE GROUND?
	CMP.W	D7,D1
	BLT.S	.NO_BOUNCE_Y
	NEG.W	-4(A2)			THEN REVERSE Y VELOCITY
	ADD.W	-4(A2),D1		
.NO_BOUNCE_Y:
	MOVEM.W	D0-D2,-12(A2)		PUT BACK X,Y AND Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	SUBQ.W	#1,(A2)
	BNE.S	.NO_FIRE
	MOVEM.W	D0-D2,-(A7)		TIME TO DO SOME FIRING
	ADD.W	#18,D0			OFFSET TO FIRE POSITION
	SUB.W	#20,D1
	MOVE.W	2(A2),(A2)		REFILL FIRE COUNTER	
	BSR	FIRE_STRAIGHT_SHOT
	MOVEM.W	(A7)+,D0-D2
.NO_FIRE:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS
.KILL_SPRING_BUG:
	ADD.L	#SC_SPRING_BUG,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
*	ADD.W	#24,D1
	BSR	ADD_AN_EXPLOSION
	RTS

******************************************
* ROUTINE FOR BASE PROTECTOR             *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 fire_repeat/2
* 16 fire_repeat/2 (refill)
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_BASE:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	(A4),D0			TAKE GROUND HEIGHT FOR Y
	ADD.W	2(A4),D0
	ASR.W	#1,D0
	MOVE.W	D0,(A2)+		Y
	MOVE.W	D6,(A2)+		Z
	MOVE.W	FIRE_REPEAT(PC),D0
	LSR.W	#1,D0
	MOVE.W	D0,(A2)+
	MOVE.W	D0,(A2)+
	RTS

BASE_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_BASE
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI.S	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	D2,-2(A2)		PUT BACK Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	TST.B	31-14(A2)
	BEQ.S	.NO_FIRE		if dead then no fire
	SUBQ.W	#1,(A2)			COUNT DOWN FIRE TIMER
	BNE.S	.NO_FIRE
	MOVEM.W	D0-D2,-(A7)		TIME TO DO SOME FIRING
	MOVE.W	2(A2),(A2)		REFILL FIRE COUNTER	
	BSR	FIRE_STRAIGHT_SHOT
	ADD.W	#64,D0
	BSR 	FIRE_STRAIGHT_SHOT
	SUB.W	#20,D1
	SUB.W	#32,D0
	BSR	FIRE_TRACKING_SHOT
	MOVEM.W	(A7)+,D0-D2
.NO_FIRE:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS
.KILL_BASE:
	ADD.L	#SC_BASE,SCORE
	MOVE.L	#BASE_DEAD,(A2)
	SF	30-4(A2)
	SF	31-4(A2)
	MOVEM.W	4(A2),D0-D2		get x,y,z
	ADD.W	D6,D2	
	MOVE.W	D2,8(A2)		put back z		
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			size of explosion
	MOVE.L	#SPRITE_32,D7		sprite rout
	BSR	ADD_AN_EXPLOSION
	MOVE.L	#EXPLOSION_LIST1,D4
	MOVEQ	#16,D3			size of explosion
	MOVE.L	#SPRITE_16,D7		sprite rout
	ADD.W	#25,D0
	BSR	ADD_AN_EXPLOSION
	SUB.W	#12,D0
	SUB.W	#15,D1
	BSR	ADD_AN_EXPLOSION
	RTS

******************************************
* ROUTINE FOR VERTICAL LASER TOWERS      *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 counter till next status change
* 16 refill for status counter
* 18 laser on/off
* 20 current laser position
* 22 dir of change
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_VERTICAL_LASER:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	#240,(A2)+		TAKE GROUND HEIGHT FOR Y
	MOVE.W	D6,(A2)+		Z
	MOVE.W	FIRE_REPEAT(PC),D0
	LSR.W	#1,D0
	MOVE.W	#1,(A2)+		LASER COUNTDOWN
	MOVE.W	D0,(A2)+		REFILL LASER COUNTDOWN
	MOVE.W	#-1,(A2)+		LASER STARTS OFF
	MOVE.W	#0,(A2)+		POS 0
	RTS

VERT_LASER_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_VERT_LASER
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI.S	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	MOVE.W	D2,-2(A2)		PUT BACK Z
	CMP.W	#9*64,D2
	BGE.S	.OFF_SCREEN
	SUBQ.W	#1,(A2)
	BNE.S	.NO_REFILL
	MOVE.W	2(A2),(A2)
	NOT.W	4(A2)
	MOVE.W	#1,8(A2)
	MOVE.W	#-1,6(A2)
.NO_REFILL:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	TST.W	4(A2)
	BNE.S	.LASER_ON
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.LASER_ON:
	CMP.W	#64,D2
	BHI.S	.NO_COL
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	-6(A2),(A4)+		MISSILE MIGHT HIT SHIP!
	MOVE.W	#32,(A4)+
	MOVE.W	-4(A2),(A4)+
	MOVE.W	#240,(A4)+
	MOVE.W	#20,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.NO_COL:
	MOVE.W	6(A2),D4
	ADD.W	8(A2),D4
	CMP.W	#3,D4
	BLT.S	.OK
	MOVE.W	#0,8(A2)
	CMP.W	#4,(A2)
	BNE.S	.OK
	MOVE.W	#-1,8(A2)
.OK:	MOVE.W	D4,6(A2)
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D0,D4
	ADD.W	#20,D4
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D4			X FOR LASER BEAM
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D4			perspected x FOR LASER
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#160,D4			screen middle x
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	LEA	VERT_LASER_LIST(PC),A6
	ADD.W	D2,A6
	MOVE.W	D1,D7
	SUB.W	#13,D7
	CMP.W	#3,6(A2)
	BEQ.S	.3
	CMP.W	#2,6(A2)
	BEQ.S	.2
	CMP.W	#1,6(A2)
	BEQ.S	.1
	LSR.W	#2,D7
	BRA.S	.3
.1:	LSR.W	#1,D7
	BRA.S	.3
.2	MOVE.W	D7,D2
	LSR.W	#2,D2
	SUB.W	D2,D7
.3	
	ADD.W	#Y_MIDDLE,D1		screen middle y
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A6,(A2)+
	MOVE.W	D4,(A2)+
	MOVE.W	D1,(A2)+
	MOVE.W	D7,(A2)+		HEIGHT OF LASER
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
	RTS

.KILL_VERT_LASER:
	ADD.L	#SC_VERT_LASER,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
*	ADD.W	#24,D1
	BSR	ADD_AN_EXPLOSION
	RTS

********************************************
* ROUTINE FOR WALLS THAT CAN BE SHOT       *
********************************************
*
* 0  address of handling routine
* 4  address of wall base (for collision!)
* 8  X, Y and Z positions
* 14  position of map data 
* 30 current status (alive/dead etc)
* 31 shootability
*
 
INIT_SHOOTABLE_WALL:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+
	MOVE.W	D5,(A2)+		X
	MOVE.W	#240,(A2)+		Y
	MOVE.W	D6,D0
	SUB.W	#32,D0
	MOVE.W	D0,(A2)+		Z
	MOVE.L	A4,(A2)+		POSITION OF MAP DATA
	RTS

SHOOTABLE_WALL_ROUTINE:
	TST.B	30-4(A2)
	BNE.S	.DESTROY_WALL
	MOVE.W	8(A2),D2		GET Z DATA
	ADD.W	D6,D2
	CMP.W	#-192,D2
	BLE.S	.REMOVE_OBJECT
	MOVE.W	D2,8(A2)
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS
.DESTROY_WALL:
	SF	31-4(A2)		SWITCH OFF 'CAN BE DESTROYED'
	ADD.W	D6,8(A2)		AS ITS ALREADY DEAD!
	MOVE.L	10(A2),A4
	MOVE.W	(A4),D2
	ADD.W	#16,D2
	CMP.W	#240,D2
	BLT.S	.MOVE_IT
	MOVE.W	#240,D2
	MOVE.W	D2,(A4)
	MOVE.W	D2,-66(A4)
	ADD.L	#SC_SHOOT_WALL,SCORE
	BRA.S	.REMOVE_OBJECT
.MOVE_IT:
	MOVE.W	D2,(A4)
	MOVE.W	D2,-66(A4)
	RTS

******************************************
* ROUTINE FOR MINE LAYERS                *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x velocity
* 16 z velocity
* 18 parachute_count
* 20 count refill
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_MINE_LAYER:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	#0,(A2)+		Y
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#-24,(A2)+		X VELOCITY
	MOVE.W	#0,(A2)+		Z VELOCITY
	MOVE.W	FIRE_REPEAT(PC),D0
	LSR.W	#2,D0
	BNE.S	.OK
	MOVEQ	#1,D0
.OK:	MOVE.W	D0,(A2)+		PARCHUTE DROP TIME
	MOVE.W	D0,(A2)+		REFILL 
	RTS

MINE_LAYER_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_MINE_LAYER
	ADDQ.L	#4,A2
	MOVEM.W	(A2)+,D0-D2		x,y,z data
	ADD.W	D6,D2			add last z movement
	ADD.W	(A2),D0			add x layer movement
	ADD.W	2(A2),D2		add z layer movement
	BMI	.REMOVE_OBJECT
	CMP.W	#32*64,D0
	BLS.S	.NO_REVERSE		if it goes off left or right then reverse
	NEG.W	(A2)
	ADD.W	(A2),D0
.NO_REVERSE:
	CMP.W	#30*64,D2		if its 20 squares ahead
	BGE.S	.REMOVE_OBJECT		lose it
	MOVE.W	D2,-2(A2)		put back x
	MOVE.W	D0,-6(A2)		put back z
	TST.W	(A2)
	BPL.S	.RIGHT
.LEFT	LEA	MINE_LAYER_LEFT,A6
	BRA.S	.P_R
.RIGHT:	LEA	MINE_LAYER_RIGHT,A6
.P_R	SUBQ.W	#1,4(A2)
	BNE.S	.NO_PARA_DROP
	MOVE.W	6(A2),4(A2)
	BSR.S	DROP_A_PARACHUTE
.NO_PARA_DROP:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	MOVE.W	D2,D4
	SUB.W	OFFSET_ADDS+4(PC),D3
	CMP.W	#8*64,D3
	BHI.S	.OFF_SCREEN
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	SWAP	D0			perspected x
	ADD.W	#160,D0			screen middle x
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	LSR.W	#4,D3
	AND.W	#%1111100,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	#Y_MIDDLE,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.KILL_MINE_LAYER:
	ADD.L	#SC_MINE_LAYER,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
	BSR	ADD_AN_EXPLOSION
	RTS

*******************************************
* ROUTINES FOR PARCHUTES                  *
*******************************************

DROP_A_PARACHUTE:
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
.FIND_SLOT_LOOP:
	TST.W	(A2)
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.FIND_SLOT_LOOP	
.GOT_FREE_SLOT:
	MOVE.W	#1,(A2)+
	MOVE.L	(A2)+,A4		GET SLOT DATA POS
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	SF	30(A4)			NOT DEAD
	ST	31(A4)			CAN BE DESTROYED!
	MOVE.L	#PARACHUTE_ROUTINE,(A4)+	TELL IT WHAT ROUTINE TO USE
	MOVE.L	#PARACHUTE_LIST,(A4)+	OBJECT LIST POINTER
	MOVEM.W	D0-D2,(A4)
	ADDQ.W	#6,A4
	MOVE.W	#8,(A4)+		Y MOVEMENT	
	RTS

PARACHUTE_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_PARACHUTE
	MOVE.L	(A2),A6
	MOVEM.W	4(A2),D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI	.REMOVE_OBJECT
	ADD.W	10(A2),D1			ADD X LAYER MOVEMENT
	BSR	FIND_GROUND_HEIGHT
	CMP.W	D1,D7
	BLE	.KILL_PARACHUTE_NO_SCORE
	CMP.W	#64,D2
	BHI.S	.NO_COLLISION
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	D0,(A4)+		MISSILE MIGHT HIT SHIP!
	MOVE.W	#32,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	#32,(A4)+
	MOVE.W	#10,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.NO_COLLISION:
	MOVE.W	D1,6(A2)
	MOVE.W	D2,8(A2)
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D3			copy up z
	MOVE.W	D2,D4
	SUB.W	OFFSET_ADDS+4(PC),D3
	CMP.W	#8*64,D3
	BHI.S	.OFF_SCREEN
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#Y_MIDDLE,D1
	ADD.W	#160,D0			screen middle x
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	LSR.W	#4,D3
	AND.W	#%1111100,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.KILL_PARACHUTE:
	ADD.L	#SC_PARACHUTE,SCORE
.KILL_PARACHUTE_NO_SCORE:
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST1+(5*4),D4
	MOVEQ	#16,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_16,D7		SPRITE_ROUT
	BSR	ADD_AN_EXPLOSION
	RTS

*************************************************
* ROUTINES TO DEAL WITH COMPUTER SET VELOCITIES *
*************************************************

INIT_VELOCITY_OVERRIDE:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	LEA	ACC_TABLE+8(PC),A6
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A6,D0.W),TARGET_VELOCITY
 	ST	VEL_OVERRIDE
	SUBQ.W	#1,D7
	ADD.W	#64,D5
	ADDQ.W	#2,A4			
	RTS

REMOVE_VELOCITY_OVERRIDE:
	SF	VEL_OVERRIDE
	RTS

**************************************************
* ROUTINE FOR MOVING GUN TURRET                  *
**************************************************
*
* 0  address of handling routine
* 4  
* 8  x,y,z
* 14 0,1 = LEFT, RIGHT
* 16 counter until next movement check
* 18 fire counter
* 20 fire repeat counter
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_MOVING_GUN:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	ADDQ.L	#4,A2
	MOVE.W	D5,(A2)+		X
	MOVE.W	#0,(A2)+		(CALULATED BY ROUTINE)
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#0,(A2)+
	MOVE.W	#1,(A2)+		1 SQUARE MOVEMENT UNTIL BUGGY CHECK
	MOVE.W	#5,(A2)+		FIRE SPEED
	MOVE.W	FIRE_REPEAT(PC),(A2)+	FIRE_SPEED REFILL
	RTS

GUN_MOVEMENT_TABLE:		*BUGGY VELOCITIES
	DC.W	-16
	DC.L	GUN_GRAPHIX
	DC.W	16
	DC.L	GUN_GRAPHIX

MOVING_GUN_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_MOVING_GUN
	ADDQ.L	#4,A2
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI	.REMOVE_OBJECT
	SUBQ.W	#1,2(A2)		DECREMENT COUNTER
	BNE.S	.NO_DIRECTION_CHECK
	BSR	.DIRECTION_CHECK		
.NO_DIRECTION_CHECK:
	MOVE.W	(A2),D3
	MOVE.L	GUN_MOVEMENT_TABLE+2(PC,D3.W),A6
	MOVE.L	A6,-10(A2)		FILL IN FOR HIT DETECT
 	ADD.W	GUN_MOVEMENT_TABLE(PC,D3.W),D0	ADD X MOVEMENT
	CMP.W	#32*64,D0
	BHI.S	.REMOVE_OBJECT		IF IT GOES OFF LEFT OR RIGHT THEN LOSE IT
	MOVE.W	D2,-(A2)		PUT BACK Z
	BSR	FIND_GROUND_HEIGHT	GET HEIGHT AT X,Z
	MOVE.W	D7,-(A2)		PUT BACK IN ROUT FOR COLL ETC
	MOVE.W	D0,-(A2)
	CMP.W	#9*64,D2		
	BGE.S	.OFF_SCREEN		
	SUBQ.W	#1,10(A2)		FIRE ROUTINE
	BNE.S	.BACK_FROM_FIRING
	MOVEM.W	D0-D2,-(A7)
	ADD.W	#18,D0			OFFSET TO FIRE POSITION
	SUB.W	#40,D1
	MOVE.W	12(A2),10(A2)
	BSR	FIRE_TRACKING_SHOT
	MOVEM.W	(A7)+,D0-D2
.BACK_FROM_FIRING:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	MOVE.W	D2,D4
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D7
	SWAP	D0			perspected x
	SWAP	D7			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D7		screen middle y
	LSR.W	#6,D4			z/64
	ADD.W	D4,D4
	MOVE.W	(A5,D4.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D4,D4
	MOVE.L	(A3,D4.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D7,(A2)+		y pos
	MOVE.L	A2,(A3,D4.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.KILL_MOVING_GUN:
	ADD.L	#SC_MOVING_GUN,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
	SUB.W	#16,D0
	BSR	ADD_AN_EXPLOSION
	MOVE.L	#EXPLOSION_LIST1+(1*4),D4
	MOVEQ	#16,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_16,D7		SPRITE_ROUT
	SUB.W	#32,D1
	ADD.W	#16,D0
	BSR	ADD_AN_EXPLOSION
	RTS

.DIRECTION_CHECK:
	MOVE.W	#4,2(A2)		RESET COUNTER
	MOVEQ	#0,D3
	MOVE.W	CURRENT_POS_Z,D3	GET OFFSET INTO CURRENT MAP FRAME
	LSL.L	#5,D3
	LEA	OBJECT_ARRAY,A4
	ADD.L	D3,A4
	MOVEQ	#0,D3
	MOVE.W	D0,D3
	LSR.W	#6,D3			GET X OFFSET INTO FRAME
	ADD.L	D3,A4
	MOVE.W	#576,D3
	SUB.W	D2,D3			
	ASR.W	#1,D3			
	EXT.L	D3
	AND.W	#%1111111111100000,D3
	ADD.L	D3,A4			ISOLATE OBJECT POSITION
	MOVE.W	(A2),D4
	MOVE.L	A4,-(A7)
	MOVE.L	.CHECK_LIST(PC,D4.W),A4
	JMP	(A4)

.CHECK_LIST:
	DC.L	.LEFT
	DC.W	0
	DC.L	.RIGHT
	DC.W	0

.LEFT:	MOVE.L	(A7)+,A4
	CMP.B	#19,-1(A4)		GUN ITSELF
	BEQ.S	.GO_LEFT
	CMP.B	#11,-1(A4)		ROAD MARKER
	BNE.S	.GO_RIGHT
.GO_LEFT:
	MOVE.W	#0*6,(A2)
	RTS

.RIGHT:	MOVE.L	(A7)+,A4
	CMP.B	#19,1(A4)		GUN ITSELF
	BEQ.S	.GO_RIGHT
	CMP.B	#11,1(A4)		ROAD MARKER
	BNE.S	.GO_LEFT
.GO_RIGHT:
	MOVE.W	#1*6,(A2)
	RTS

******************************************
* ROUTINE FOR WAVERS OBJECTS             *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x vel
* 16 x change
* 18 counter, refill
* 20 y vel
* 22 y change
* 24 counter, refill
* 30 current status (alive/dead etc)
* 31 shootability
*

INIT_WAVER:
	MOVE.W	#1,(A1)			FILL OBJECT SLOT!
	SF	30(A2)			NOT DEAD
	ST	31(A2)			CAN BE DESTROYED!
	MOVE.L	(A3)+,(A2)+		TAKE ROUT TYPE FROM OBJECT LIST
	MOVE.L	A3,(A2)+		ADDRESS OF OBJECT LIST DATA
	MOVE.W	D5,(A2)+		X
	MOVE.W	#100,(A2)+		Y AT 100
	MOVE.W	D6,(A2)+		Z
	MOVE.W	#40,(A2)+		INIT X VELOCITY
	MOVE.W	#-4,(A2)+		X DECEL FACTOR
	MOVE.B	#20,(A2)+		COUNTER
	MOVE.B	#20,(A2)+		COUNTER REFILL

	MOVE.W	#11,(A2)+		INIT Y VELOCITY
	MOVE.W	#-1,(A2)+		Y DECEL FACTOR
	MOVE.B	#22,(A2)+		COUNTER
	MOVE.B	#22,(A2)+		COUNTER REFILL
	RTS

WAVER_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_WAVER
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST

	ADD.W	(A2)+,D0		ADD X VEL
	MOVE.W	(A2)+,D3		CHANGE X VEL
	ADD.W	D3,-4(A2)
	SUBQ.B	#1,(A2)
	BNE.S	.NO_CH_X
	MOVE.B	1(A2),(A2)
	NEG.W	-2(A2)
.NO_CH_X:
	ADDQ.L	#2,A2

	ADD.W	(A2)+,D1		ADD Y VEL
	MOVE.W	(A2)+,D3		CHANGE X VEL
	ADD.W	D3,-4(A2)
	SUBQ.B	#1,(A2)
	BNE.S	.NO_CH_Y
	MOVE.B	1(A2),(A2)
	NEG.W	-2(A2)
.NO_CH_Y:
	ADDQ.L	#2,A2

	MOVEM.W	D0-D2,-18(A2)

	CMP.W	#64,D2
	BHI.S	.NO_COLL
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	D0,(A4)+		WAVER MIGHT HIT SHIP!
	MOVE.W	#40,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	#40,(A4)+
	MOVE.W	#20,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.NO_COLL:
	SUB.W	D5,D0
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range
	CMP.W	#9*64,D2
	BHI.S	.OFF_SCREEN
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.KILL_WAVER:
	ADD.L	#SC_WAVER,SCORE
	MOVE.W	#-1,-2(A1)
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
	MOVE.L	#EXPLOSION_LIST2+(5*4),D4
	MOVEQ	#24,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_32,D7		SPRITE_ROUT
	BSR	ADD_AN_EXPLOSION

ADD_8_SAUCERS:
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
	LEA	SAUCER_DATA(PC),A6
	MOVEQ	#7,D7
.ADD_SAUCER_LOOP:
	TST.W	(A2)
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.ADD_SAUCER_LOOP
.GOT_FREE_SLOT:
	MOVE.W	#1,(A2)+
	MOVE.L	(A2)+,A4		GET SLOT DATA POS
	SF	30(A4)			NOT DEAD
	ST	31(A4)			CANNOT BE DESTROYED!
	MOVE.L	#SAUCER_ROUTINE,(A4)+	TELL IT WHAT ROUTINE TO USE
	MOVE.L	#SAUCER_DEFINITION,(A4)+
	MOVEM.W	D0-D2,(A4)
	MOVE.W	(A6)+,6(A4)
	MOVE.W	(A6)+,8(A4)
	MOVE.B	#0,10(A4)		NOT BYTE
	DBF	D7,.ADD_SAUCER_LOOP
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	RTS

SAUCER_DATA:
	DC.W	8,-4
	DC.W	-6,4
	DC.W	0,-2
	DC.W	6,-6
	DC.W	-2,4
	DC.W	2,2
	DC.W	4,6
	DC.W	-4,-6

******************************************
* ROUTINE FOR SAUCERS                    *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x vel
* 16 y vel
* 18 not byte
* 30 current status (alive/dead etc)
* 31 shootability
*

SAUCER_ROUTINE:
	TST.B	30-4(A2)
	BNE	.KILL_SAUCER
	MOVE.L	(A2)+,A6		BASE OF OBJECT LIST		
	MOVEM.W	(A2)+,D0-D2		X,Y,Z DATA
	CMP.W	SHIP_X_REAL(PC),D0
	BGT.S	.MINUS
.PLUS:	ADDQ.W	#1,(A2)
	BRA.S	.DO_Y
.MINUS:	SUBQ.W	#1,(A2)
.DO_Y:
	MOVE.W	CURRENT_POS_Y(PC),D3
	SUB.W	#16,D3
	CMP.W	D3,D1
	BGT.S	.MINUS2
.PLUS2:	ADDQ.W	#2,2(A2)
	BRA.S	.DONE_EM
.MINUS2:
	SUBQ.W	#1,2(A2)
.DONE_EM:
	ADD.W	(A2),D0
	ADD.W	2(A2),D1
.NO_ADD:
	ADDQ.L	#4,A2
	ADD.W	#-8,D2
	ADD.W	D6,D2			ADD LAST Z MOVEMENT
	BMI.S	.REMOVE_OBJECT		IF OUT OF RANGE, REMOVE MOVE LIST
	BSR	FIND_GROUND_HEIGHT	(RESULT IN D7)
	CMP.W	D7,D1			DID IT HIT LAND?
	BGE	.KILL_SAUCER_NO_SCORE
	MOVEM.W	D0-D2,-10(A2)		PUT BACK Z
	CMP.W	#64,D2
	BHI.S	.MORE_TEST
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	D0,(A4)+		SAUCER MIGHT HIT SHIP!
	MOVE.W	#40,(A4)+
	MOVE.W	D1,(A4)+
	MOVE.W	#40,(A4)+
	MOVE.W	#5,(A4)+		ENERGY LOSS
	MOVE.L	A4,COLLISION_INFORMATION
.MORE_TEST:
	SUB.W	D5,D0			subtract left x boundary
	CMP.W	#10*64,D0		check to see if it is
	BHI.S	.OFF_SCREEN		visible
	SUB.W	#(5*64)+32,D0		give number + and - range

	CMP.W	#9*64,D2
	BHI.S	.OFF_SCREEN
	MOVE.W	D2,D3			copy up z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		proj divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		thus get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		increment pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS
.KILL_SAUCER:
	ADD.L	#SC_SAUCER,SCORE
	MOVEM.W	4(A2),D0-D2		GET X,Y,Z
.KILL_SAUCER_NO_SCORE:
	MOVE.W	#-1,-2(A1)
	MOVE.L	#EXPLOSION_LIST1+(5*4),D4
	MOVEQ	#16,D3			SIZE OF EXPLO
	MOVE.L	#SPRITE_16,D7		SPRITE_ROUT
	BSR	ADD_AN_EXPLOSION
	RTS

************************************************
* SPACE INVADER COMMANDER.  THE ROUTINE THAT   *
* LOOKS AFTER ALL THE LITTLE SPACE INVADERS AND*
* TELLS THEM WHAT THE HELL THEY SHOULD BE DOING*
* NEXT IN THERE SHORT AND TROUBLED LIVES       *
************************************************
*
* 0  object handling routine
* 4  current_mode:- 0 = creating invaders
*		    1 = waiting for position
*		    2 = waiting for death
*
* 6  number of little invaders currently active
* 8  counter until pos reached
* 10 velocity when moving
* 12 counter for movement (till next change)
* 14 refill for above
* 16 any z change
*

INIT_SI_COMMANDER:
	MOVE.W	#1,(A1)			fill object slot!
	SF	30(A2)			not dead
	SF	31(A2)			cannot be destroyed
	MOVE.L	(A3)+,(A2)+		copy rout address
	MOVE.W	#0,(A2)+		in mode 0
	MOVE.W	#18,(A2)+		15 little si's
	MOVE.W	#50,(A2)+		counter for position
	MOVE.W	#8,(A2)+		x vel
	MOVE.W	#32,(A2)+		counter
	MOVE.W	#64,(A2)+		counter refill
	RTS

SI_COMMANDER_ROUTINE:
	TST.W	2(A2)			are all si's dead?
	BEQ	.KILL_COMMANDER		then kill commander
	TST.W	(A2)			in creation mode?
	BEQ.S	.CREATE_SI
	CMP.W	#1,(A2)			in wait mode?
	BEQ.S	.WAIT_FOR_POSITION
	CMP.W	#2,(A2)			in move mode?
	BEQ.S	.MOVING_LEFT_RIGHT
	RTS

.MOVING_LEFT_RIGHT:
	MOVE.W	#0,12(A2)	
	SUBQ.W	#1,8(A2)		count down
	BNE.S	.NO_CHANGE		0?
	MOVE.W	10(A2),8(A2)		refill counter
	NOT.W	6(A2)			change direction
	MOVE.W	#-32,12(A2)		forward by 32
.NO_CHANGE:
	RTS

.WAIT_FOR_POSITION:
	SUBQ.W	#1,4(A2)		count down
	BNE.S	.NOT_YET_REACHED_POS	reached 0?
	MOVE.W	#2,(A2)			switch commander to moving
	LEA	SI_INFO(PC),A4		get address of si's
	MOVEQ	#17,D7			15 to do
.LOOP:	MOVE.L	(A4)+,A6		get data address
	CMP.L	#SI_ROUTINE,(A6)	is si still there
	BNE.S	.NOT_SI			nope!
	MOVE.W	#1,20(A6)		switch to moving left/right
.NOT_SI:
	DBF	D7,.LOOP		loop
.NOT_YET_REACHED_POS:
	RTS

.CREATE_SI:
	MOVE.L	A2,D0
	ADDQ.W	#2,D0			take address of variables 
	MOVE.W	#1,(A2)
	MOVE.L	THINGS_TO_DO_LIST_POINT(PC),A2
	LEA	SI_INFO(PC),A4		get address of si buffer
	LEA	SI_DATA(PC),A6		get si data
	MOVEQ	#17,D7			15 to do
.ADD_SI_LOOP:
	TST.W	(A2)			find a free object space
	BMI.S	.GOT_FREE_SLOT
	ADDQ.L	#6,A2
	BRA.S	.ADD_SI_LOOP
.GOT_FREE_SLOT:
	MOVE.L	2(A2),(A4)+		record object address
	MOVE.L	A4,-(A7)	
	MOVE.W	#1,(A2)+		fill object slot
	MOVE.L	(A2)+,A4		get data pos
	SF	30(A4)			not dead
	ST	31(A4)			can be destroyed
	MOVE.L	#SI_ROUTINE,(A4)+	routine to use
	MOVE.L	#SI_DEFINITION,(A4)+	graphics address
	MOVE.W	(A6)+,(A4)+		x
	MOVE.W	(A6)+,(A4)+		y
	MOVE.W	(A6)+,(A4)+		z
	MOVE.W	(A6)+,(A4)+		x destination
	MOVE.L	D0,(A4)+		commander variable address
	MOVE.W	#0,(A4)+		set operating mode to 0
	MOVE.L	(A7)+,A4
	DBF	D7,.ADD_SI_LOOP
	MOVE.L	A2,THINGS_TO_DO_LIST_POINT
	RTS

.KILL_COMMANDER:
	ADD.L	#SC_SI_COMMANDER,SCORE	add bonus for killing all si
	MOVE.W	#-1,-2(A1)		object slot set to free
	RTS

SI_DATA:
	DC.W	0,50,512-64,10*64
	DC.W	0,50,512-64,12*64
	DC.W	0,50,512-64,14*64
	DC.W	0,50,512-64,16*64
	DC.W	0,50,512-64,18*64
	DC.W	0,50,512-64,20*64

	DC.W	32*64,100,512-128,10*64
	DC.W	32*64,100,512-128,12*64
	DC.W	32*64,100,512-128,14*64
	DC.W	32*64,100,512-128,16*64
	DC.W	32*64,100,512-128,18*64
	DC.W	32*64,100,512-128,20*64

	DC.W	0,150,512-192,10*64
	DC.W	0,150,512-192,12*64
	DC.W	0,150,512-192,14*64
	DC.W	0,150,512-192,16*64
	DC.W	0,150,512-192,18*64
	DC.W	0,150,512-192,20*64

*COPY OF ALL SI ADDRESSES

SI_INFO:	
	DS.L	20			max number of si's

******************************************
* ROUTINE FOR SPACE INVADERS             *
******************************************
*
* 0  object handling routine
* 4  address of graphics data
* 8  x, y, z
* 14 x destination
* 16 address of counter in commander
* 20 operating mode
* 30 current status (alive/dead etc)
* 31 shootability
*

SI_ROUTINE:
	TST.B	30-4(A2)		is si dead?
	BNE	.KILL_SI		yep!
	CMP.W	#1,20-4(A2)		is it in move mode
	BEQ.S	.SI_MOVING
	MOVE.L	(A2)+,A6		base of object list	
	MOVEM.W	(A2)+,D0-D2		x, y, z data
	CMP.W	(A2),D0			reached dest point
	BEQ.S	.REACHED_DEST		yep!
	BLT.S	.GOING_RIGHT		
.GOING_LEFT:
	SUB.W	#32,D0			move left
	BRA.S	.REACHED_DEST
.GOING_RIGHT
	ADD.W	#32,D0			move right
.REACHED_DEST:
	MOVEM.W	D0-D2,-6(A2)		put back data
.NORMAL_END:
	SUB.W	D5,D0			subtract left boundary
	CMP.W	#10*64,D0		is it visible
	BHI.S	.OFF_SCREEN		
	SUB.W	#(5*64)+32,D0		give number + and - range
	CMP.W	#9*64,D2
	BHI.S	.OFF_SCREEN		off back edge?
	MOVE.W	D2,D3			copy z
	ADD.W	D2,D2
	MOVE.W	(A0,D2.W),D2		get proj and divu data
	MULS	D2,D0
	MULS	D2,D1
	SWAP	D0			perspected x
	SWAP	D1			perspected y
	ADD.W	#160,D0			screen middle x
	ADD.W	#Y_MIDDLE,D1		screen middle y
	LSR.W	#6,D3			z/64
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D2		get sprite size offset
	LEA	(A6,D2.W),A4		get sprite data address
	ADD.W	D3,D3
	MOVE.L	(A3,D3.W),A2		get address of draw buffer
	MOVE.L	A4,(A2)+		data address
	MOVE.W	D0,(A2)+		x pos
	MOVE.W	D1,(A2)+		y pos
	MOVE.L	A2,(A3,D3.W)		replace pointer
.OFF_SCREEN:
	RTS
.REMOVE_OBJECT:
	MOVE.W	#-1,-2(A1)
	RTS

.SI_MOVING:
	MOVE.L	(A2)+,A6		base of object list
	MOVEM.W	(A2)+,D0-D2		x,y,z data
	MOVE.L	2(A2),A4		get commander variable address
	ADD.W	4(A4),D0		add movement data
	ADD.W	10(A4),D2		
	BPL.S	.OK
	MOVEQ	#0,D2
.OK:
	MOVEM.W	D0-D2,-6(A2)		put back data
	CMP.W	#64,D2			in collision range
	BHI.S	.MORE_TEST
	MOVE.L	COLLISION_INFORMATION,A4
	MOVE.W	D0,(A4)+		si might hit ship
	MOVE.W	#40,(A4)+		
	MOVE.W	D1,(A4)+
	MOVE.W	#40,(A4)+
	MOVE.W	#5,(A4)+		energy loss
	MOVE.L	A4,COLLISION_INFORMATION
.MORE_TEST:
	BRA	.NORMAL_END

.KILL_SI:
	ADD.L	#SC_SI,SCORE		score for si
	MOVEM.W	4(A2),D0-D2		get x,y,z
	MOVE.L	12(A2),A6
	SUBQ.W	#1,(A6)			tell comm 1 less si
	MOVE.W	#-1,-2(A1)
	MOVE.L	#EXPLOSION_LIST1+(5*4),D4
	MOVEQ	#16,D3			size of explosion
	MOVE.L	#SPRITE_16,D7		rout to use
	BSR	ADD_AN_EXPLOSION	put on explosion
	RTS
