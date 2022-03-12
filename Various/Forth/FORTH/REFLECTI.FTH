( Reflections.fth)
( Mach2 Demo)

( How it works: (xx1,yy1) and (xx2,yy2) are two points that travel around
  the reflections window. Their speeds are the delta values held in the
  DOT variables. When a point runs into a wall, it's x or y speed is
  negated so that it bounces off the wall. All the while a line is
  drawn between the two points and the line drawn 20 steps ago is erased.)
  
ONLY FORTH DEFINITIONS
ALSO GEM

DECIMAL


( =================== BUILDING STRUCTURES ==================== )

NEW.WINDOW Reflections			( reflections is a new window)
30 30 185 195 Reflections BOUNDS
9  Reflections ITEMS
" Reflections" Reflections TITLE
2000 2000 TERMINAL Demo3 ( demo3 is a task w/ 2000 b of return and parm stack)


( =================== DEFINING UTILITY WORDS ================= )

: RANGE ( n min max - n bool) ( true if n between min and max )
	{ value lo hi } value
	  hi value >
	  lo value < and ;
	
: 4DUP { n1 n2 n3 n4 - n1 n2 n3 n4 n1 n2 n3 n4 }
	n1 n2 n3 n4
	n1 n2 n3 n4
	;
	

( =================== MAIN BODY OF CODE ====================== )
	
DECIMAL
( postion, velocity)
VARIABLE xx1	VARIABLE xx1DOT
VARIABLE yy1	VARIABLE yy1DOT
VARIABLE xx2	VARIABLE xx2DOT
VARIABLE yy2	VARIABLE yy2DOT

: SetupReflect ( erase the window and initialize the variables)
	CLS
	 40 xx1 !   3 xx1DOT !
	150 yy1 !  -4 yy1DOT !
	 90 xx2 !   4 xx2DOT !
	150 yy2 !  -3 yy2DOT !   ;
	
: NewCoords ( - xx1 yy1 xx2 yy2 ) ( leaves coords of a new line on stack)
	xx1Dot @ xx1 +! ( Increment the line position)
	yy1Dot @ yy1 +!
	xx2Dot @ xx2 +!
	yy2Dot @ yy2 +!
	xx1 @ 1 149 RANGE 0= IF xx1Dot @ NEGATE xx1Dot ! THEN ( xx1 on )
	yy1 @ 1 149 RANGE 0= IF yy1Dot @ NEGATE yy1Dot ! THEN ( and yy1 on )
	xx2 @ 1 149 RANGE 0= IF xx2Dot @ NEGATE xx2Dot ! THEN ( and xx2 on )
	yy2 @ 1 149 RANGE 0= IF yy2Dot @ NEGATE yy2Dot ! THEN ( and yy2 on ) ;
	
: First20Lines ( leaves 40 coord pairs on stack and draws 1st twenty lines)
	cls
	20 0 DO
		NewCoords 4DUP
		2 call vslcolor drop
		MoveTo LineTo
	LOOP ;

: exit? ( - f )
	?TERMINAL	( stop on ^C)
	IF KEY 3 =
		IF quit THEN ( change quit to bye when making applications)
	THEN ;

: LinesForever
	BEGIN
		NewCoords 4DUP ( draw a red line)
		2 call vslcolor drop	( usually a red line)
		MoveTo LineTo ( 21 complete sets on => 84 values)

		83 ROLL 83 ROLL 83 ROLL 83 ROLL
				( and white out the n-21st line)
		0 call vslcolor drop
		MoveTo LineTo
		( can change line mode here so that windows move nicely)
		1 call vslcolor drop
	exit?
	AGAIN  ;
		
: Reflect
	SetUpReflect
	First20Lines
	LinesForever ;
	

( ==================== INITIALIZATION ==================== )
	

GLOBAL
: BOOTLINES
	Reflections ADD			( Making the window )
	Reflections Demo3 BUILD 	( Linking the window to the
					  terminal task )
  	Demo3 ACTIVATE Reflect ;	( Assigning code to the task )


( ==================== INSTRUCTIONS ====================== )

CR .( To execute this program type 'BOOTLINES' <cr> ) 
CR .( To TURNKEY this program type 'TURNKEY BOOTLINES LINES' )
