( Gebirge.fth
  A 3-d fractal demo. There's a lot of parameters you can play with in this
  one. As this is the analogy to a 2-d fractal program, the surface
  doesn't close. But it looks neat.
  This doesn't use a window just to show that you needn't always have
  windows.)

decimal

( ===================== Trig functions ===================)

	INCLUDE" Trig.asm"
	
	
	
FORTH DEFINITIONS
ALSO GEM 


( ==== Constants and Variables ======  )

DECIMAL
1500 3000 background MountainT	( heavily recursive so much subroutine stack)

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


( entries in the matrix)

VARIABLE A11  
VARIABLE A12  
VARIABLE A13
VARIABLE A31  
VARIABLE A32  
VARIABLE A33

VARIABLE iters 				( ~5)
VARIABLE scaling 			( ~700)



( ===================== 3D plotting stuff ================)

CODE 3Dup ( a b c  -  a b c a b c  )
	MOVE.L 8(A6),-(A6)
	MOVE.L 8(A6),-(A6)
	MOVE.L 8(A6),-(A6)
	RTS
END-CODE


( === Utility Words ====== )

DECIMAL

: DoSins 
	pitchAngle @ DUP 
	SIN sinAlpha ! 
	COS cosAlpha !
	
	rollAngle @ DUP 
	SIN sinBeta ! 
	COS cosBeta !
	
	yawAngle @ DUP 
	SIN sinGamma ! 
	COS cosGamma ! ;


: DoTerms
	cosGamma @ cosBeta @ 10000 */  A11 !
	sinGamma @ cosBeta @ 10000 */  A12 !
	sinBeta @ -1 *  A13 !
	cosAlpha @ sinBeta @ 10000 */ cosGamma @ 10000 */
	sinAlpha @ sinGamma @ 10000 */ +  A31 !
	cosAlpha @ sinBeta @ 10000 */ sinGamma @ 10000 */
	sinAlpha @ cosGamma @ -10000 */ +  A32 !
	cosAlpha @ cosBeta @ 10000 */  A33 ! ;
	
	
: 3D>2D ( x y z  -  x y = x z  )
	3DUP
	ROT A31 @ * ROT A32 @ * ROT A33 @ * + + 10000 /  zOff @ + >R
	ROT A11 @ * ROT A12 @ * ROT A13 @ * + + 10000 /  xOff @ + R> ;


: 3DMoveTo  ( x y z  -   )
	3D>2D MoveTo ;
	
( ****** NOTE!!!
	when executed from a no-window task, LINETO will use the raw
	a-line trap to draw a line with. It uses the PenLoc user variable
	to see where to draw from)

: 3DLineTo  ( x y z  -   )
	3D>2D  LineTo ;


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


: Scale ( n  -  n*s  )
	scaling @ 1000 */ ;
	
	
: Ran100 (  - -50<to<50  )
	CALL Random 
	L_EXT 50 * 32767 / ;
	

( === Main Code ======   )

: Mount RECURSIVE ( no PAUSE's- for speed)
{ x1 y1 z1 x2 y2 z2 x3 y3 z3 x4 y4 z4 k | x5 y5 z5 x6 y6 z6 x7 y7 z7 x8 y8 z8 x9 y9 z9 }
	
	k 0=
	IF	
		x3 y3 z3 3DMoveTo
		x1 y1 z1 3DLineTo
		x2 y2 z2 3DLineTo
		x4 y4 z4 3DLineTo
	ELSE		
		z1 z2 z3 z4 + + + 2/ 2/  Ran100 x1 x2 - 2/ 100 */  Scale + -> z5
		z1 z2 + 2/  Ran100 x1 x2 - 2/ 100 */  Scale + -> z6
		z4 z2 + 2/  Ran100 x1 x2 - 2/ 100 */  Scale + -> z7
		z4 z3 + 2/  Ran100 x1 x2 - 2/ 100 */  Scale + -> z8
		z1 z3 + 2/  Ran100 x1 x2 - 2/ 100 */  Scale + -> z9

		x1 x2 x3 x4 + + + 2/ 2/ -> x5
		x1 x2 + 2/ -> x6
		x2 x4 + 2/ -> x7
		x4 x3 + 2/ -> x8
		x1 x3 + 2/ -> x9
	
		y1 y2 y3 y4 + + + 2/ 2/ -> y5
		y1 y2 + 2/ -> y6
		y2 y4 + 2/ -> y7
		y4 y3 + 2/ -> y8
		y1 y3 + 2/ -> y9

		x1 y1 z1 x6 y6 z6 x9 y9 z9 x5 y5 z5 k 1- Mount
		x2 y2 z2 x7 y7 z7 x6 y6 z6 x5 y5 z5 k 1- Mount
		x4 y4 z4 x8 y8 z8 x7 y7 z7 x5 y5 z5 k 1- Mount
		x3 y3 z3 x9 y9 z9 x8 y8 z8 x5 y5 z5 k 1- Mount
	THEN	;
	
	
: SetUpView		( here are some parameters to play with)
	5 iters !		( how fine the grid will be)
	700 scaling !		( bumpiness)
	45 xOff !  		( initial positioning of the plane)
	80 zOff !
	20 pitch  
	20 roll  
	20 yaw ;


: Draw	recursive
	call vHideC	( hide the cursor)
	CLS		( clear the entire screen. CLS will do a
			'call vEeos' and 'call vCurHome' if a 0 is in
			the TaskWindow user
			variable, i.e., if called by a background task)
	1 call vswrmode drop
	2 call vslcolor drop
	5 5 0 305 5 0 5 305 0 305 305 0 iters @ Mount ( parms to play with)
	1 call vShowC	( restore mouse cursor)
	call vCurHome	( if a background task, homes its text cursor)
	." <cr> to continue"	( if a no-window task uses EMIT, the
				output goes straight to the CRT unless
				you've redirected I/O)
	call cConin		( wait for a keypress)
	31 and 13 =
	 IF draw ELSE quit THEN	( change to 'bye' if you want to
	 			make an application)
	;
	


( === Initializations ====== )

: Run 
	ACTIVATE
	SetupView  
	Draw
	;
: INITM
	MountainT BUILD 		( build the background task )
	;
	
	
: BootM 
	initM 
	MountainT Run ;



CR 
.( To execute this program type  BOOTM  ) 
CR
.( To make it an application type  TURNKEY BOOTM Mount )