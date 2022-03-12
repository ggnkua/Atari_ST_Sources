( Plane.fth   ---   Simple 3D graphics
  Mach2 Demo

  Requires the file Trig.asm.  )
  
INCLUDE" grafTrig.asm"

ONLY FORTH DEFINITIONS
ALSO gem
ALSO ASSEMBLER


DECIMAL

NEW.WINDOW Nomad 				( Nomad is a new window)
75 100 225 250 Nomad BOUNDS
TitleBar MoveBox + Nomad ITEMS
" Nomad" Nomad TITLE

2000 2000 TERMINAL PlaneT 			( PlaneT is a task w/ 2000 
						  bytes of return and 
						  parameter stack)

DECIMAL


( using the y axis as the negative z axis)

VARIABLE pitchAngle  
VARIABLE rollAngle  
VARIABLE yawAngle 				( for the x,y,z)

VARIABLE sinAlpha  
VARIABLE cosAlpha
VARIABLE sinBeta   
VARIABLE cosBeta
VARIABLE sinGamma  
VARIABLE cosGamma

VARIABLE xOff  
VARIABLE zOff

: DoSins 
	pitchAngle @ 
	DUP 
	sin sinAlpha ! cos cosAlpha !
	
	rollAngle @ 
	DUP
	sin sinBeta ! cos cosBeta !
	
	yawAngle @ 
	DUP 
	sin sinGamma ! cos cosGamma ! ;


( entries in a 3-D transformation matrix)

VARIABLE A11  	VARIABLE A12  	VARIABLE A13
VARIABLE A31  	VARIABLE A32  	VARIABLE A33

: DoTerms
	cosGamma @ cosBeta  @ 10000 */  A11 !
	sinGamma @ cosBeta  @ 10000 */  A12 !
	sinBeta  @ negate A13 !
	cosAlpha @ sinBeta  @ 10000 */ cosGamma @ 10000 */
	sinAlpha @ sinGamma @ 10000 */ +  A31 !
	cosAlpha @ sinBeta  @ 10000 */ sinGamma @ 10000 */
	sinAlpha @ cosGamma @ -10000 */ +  A32 !
	cosAlpha @ cosBeta  @ 10000 */  A33 ! ;
	
	
: 3D>2D { x y z | x2d z2d -- x y = x z }
	x A31 @ *
	y A32 @ *
	z A33 @ * + + 10000 / zOff @ + -> z2d
	x A11 @ *
	y A12 @ *
	z A13 @ * + + 10000 / xOff @ + -> x2d
	x2d z2d
	;

( Set an absolute angle and redo the matrix)

: pitch 
	D>R pitchAngle ! 
	DoSins 
	DoTerms ;
	
: roll 
	D>R rollAngle ! 
	DoSins 
	DoTerms ;
	
: yaw 
	D>R yawAngle ! 
	DoSins 
	DoTerms ;


( Increment the angles and redo the matrix)

: +pitch 
	D>R 
	pitchAngle @ + 62832 MOD pitchAngle ! 
	DoSins 
	DoTerms ;
	
: +roll 
	D>R 
	rollAngle @ + 62832 MOD rollAngle ! 
	DoSins 
	DoTerms ;
	
: +yaw 
	D>R 
	yawAngle @ + 62832 MOD yawAngle ! 
	DoSins 
	DoTerms ;


( will MOVE to the first point and then LINE to each)

Create PlaneCoords	( use create so it can be referenced w/o [']) 
	DC.L	30,0,-25   ( x,y,z)
	DC.L	45,0,-25
	DC.L	59,5,-25
	DC.L	44,5,-25
	DC.L	30,0,-25
	DC.L	45,3,25
	DC.L	59,5,-25
	DC.L	45,0,-25
	DC.L	45,3,25
	DC.L	44,5,-25
	DC.L	30,0,-25
	
	
DECIMAL

: DrawPlane
	0 10 DO
	  PlaneCoords I 12 * + 0 + @  		( x)
	  PlaneCoords I 12 * + 4 + @  		( y)
	  PlaneCoords I 12 * + 8 + @ 		( z)
	  3D>2D  
	-1 +loop 
	
	CLS
	MoveTo
	
	10 0 DO LineTo LOOP ;
	
	
: SetUpPlane 
	75 xOff !  
	80 zOff !
	105 pitch  
	0 roll  
	-20 yaw ;

: SpinPlane  
	BEGIN 
		5 
		+roll 
		DrawPlane
	?TERMINAL 
	UNTIL ;
	
	  
: Run 
	ACTIVATE 
	SetUpPlane 
	SpinPlane 
	quit 	 ;
	
	
: Fly
	Nomad ADD
	Nomad PlaneT BUILD 		( Nomad is PlaneT's window)
	PlaneT Run  ;

CR    .( To execute, type  FLY )
CR CR .( To make an application, type  TURNKEY Fly AirPlane )