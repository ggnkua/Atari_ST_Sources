'*************************
' LISSAJOU.BAS
'     This program displays spherical Lissajous figures
'     and writes a DKB Ray Tracer data file.
'     Program written by Dan Farmer using algorithms from Clifford Pickover.
'     See Scientific American January 1991 and Omni February 1990 for
'     excellent examples by Pickover.
' COMPILING: QB3.0 or greater
'            Requires /e switch (on error).
' Revision:
'              Add EXPONENT variable
'              Bug Fix: CLOSE #1 when finished with it.
'              In WRITE.HEADER, use correct variable for R1 reference.
'
' 01/16/90 DMF Change most GOSUBS to SUBPROGRAMS and FUNCTIONS
'              Specify type of most integers. (Default is single precision)
'              Replace Shellsort with Quicksort
'              Allow pausing of display, with option to write only the
'              spheres displayed.
'              Use Fractint color map or specified color(s) for DKB script.
' 03/08/91 DMF Drop FRACTINT color map option.  Doubt if anyone uses it.
'              Make colors all color declarations and use the names in
'              the objects, rather than the values.  Easier to edit when
'              you have 100s of objects and several colors to change.
' 05/01/91 AAC Updated to DKB 2.11 by Aaron A. Collins
'*************************

' The following variables are public to all sub-programs:
'-----------------------------
COMMON SHARED S(2),F10$,FK10$,CU$,CD$,CR$,CL$,CSRL$,RTN$,ESC$,_
                  BS$,TB$,HOM$,EN$,PGUP$,PGDN$,ALPHAS$,NUMBERS$,P$
COMMON SHARED LABEL$(1),DATA$(1),TRUE%,FALSE%,GRMODE%
COMMON SHARED MAXCOLORS%, BG%,WINXCENTER%,WINYCENTER%
COMMON SHARED RADIUS, VIEWER
'-----------------------------

FALSE% = 0 : TRUE% = NOT FALSE%

'========================== USER-DEFINED FUNCTIONS
' FUNCTION:                  DESCRIPTION:
' -----------                ------------
' FNLOOKKEY$(X)          --- Wait for a keystroke (called by SUB GETKEY)
' FUNUPPER$(X$)          --- Convert X$ to upper case
' FNISBLANK(X$)          --- Boolean : is string X$ NULL?
' FNCOMPARE(X$,Y$)       --- Compare 2 strings for partial match
' FNPAD$(X$,LENG)        --- Right-pad X$ with spaces to length LENG
' FNUNPAD$(X$)           --- Remove leading & trailing spaces from string X$
' FNFMT$ (A#)            --- Create a string from float A#
' FNFORMAT$(A#,FORM$)   ---  Create a formatted string from float A#
' FNZSCALE (RADIUS,Z,VIEWER) --- Adjust RADIUS to simulate perspective.


'          ---  LOOK FOR A KEYSTROKE
DEF FNLOOKKEY$(X)
	STATIC A$
	A$=INKEY$
	IF LEN(A$)=2 THEN               ' FILTER UNUSED CONTROL CODES
		IF ASC(RIGHT$(A$,1)) > 81 THEN A$=""
	END IF
	FNLOOKKEY$=A$
END DEF

'          ---  CONVERT STRING TO UPPER CASE
DEF FNUPPER$(X$)
    STATIC A$,I%
    IF LEN(X$) >0 THEN
        FOR I% = 1 TO LEN(X$)
            A$ = MID$(X$,I%,1)
            IF A$ >= "a" AND A$ <= "z" THEN_
                MID$(X$,I%,1) = CHR$(ASC(A$)-32)
        NEXT I%
	END IF
    FNUPPER$ = X$
END DEF

'          ---  IS A STRING A BUNCH OF BLANKS?
DEF FNISBLANK(X$) = (X$=SPACE$(LEN(X$)))

'          ---  COMPARE STRINGS FOR PARTIAL MATCH
DEF FNCOMPARE(X$,Y$) = (LEFT$(X$,LEN(Y$))=Y$)
'
'          ---  LEFT-JUSTIFY, BLANK FILL A STRING
DEF FNPAD$(X$,LENG) = LEFT$(X$+SPACE$(LENG),LENG)

'          ---  REMOVE LEADING AND TRAILING SPACES
DEF FNUNPAD$(X$)
	WHILE LEFT$(X$,1)=" "
		X$=MID$(X$,2)
	WEND
	WHILE RIGHT$(X$,1)=" "
		X$=LEFT$(X$,LEN(X$)-1)
	WEND
	FNUNPAD$=X$
END DEF

'          ---  FORMAT A NUMERIC STRING, SIMPLE VERSION
DEF FNFMT$ (A#)
    FORM$="-####.######"
	STATIC SIGN, S$, P, A$, DEC, W$, F$, WF$, FF$, PAD$, ADD$
	SIGN = SGN(A#)
	A# = ABS(A#)
'          ---  SEPARATE WHOLE AND FRACTIONAL PARTS OF NUMBER
	W$ = MID$(STR$(INT(A#)), 2)
	IF W$ = "" THEN W$ = "0"
	S$ = STR$(1 + A#)
	P = INSTR(S$, ".")
	IF P = 0 THEN
		F$ = ""
	   ELSE F$ = MID$(S$, P + 1)
	END IF
'          ---  SEPARATE WHOLE AND FRACTION FORMAT STRINGS
	DEC = INSTR(FORM$, ".")
	IF DEC = 0 THEN
		WF$ = FORM$: FF$ = ""
	   ELSE WF$ = LEFT$(FORM$, DEC - 1)
		FF$ = MID$(FORM$, DEC + 1)
	END IF
	ADD$ = "": PAD$ = " "
'          ---  ADD SIGN CHARACTER
	IF LEFT$(WF$, 1) = "-" THEN
		WF$ = MID$(WF$, 2)
		IF SIGN = -1 THEN
			ADD$ = ADD$ + "-"
		   ELSE ADD$ = ADD$ + " "
		END IF
	END IF
'          ---  HANDLE NUMERIC OVERFLOW AND UNDERFLOW
	IF LEN(W$) > LEN(WF$) THEN W$ = "%" + RIGHT$(W$, LEN(WF$) - 1)
	IF LEN(F$) > LEN(FF$) THEN F$ = LEFT$(F$, LEN(FF$))
'          ---  FORMAT THE NUMBER STRING
	IF DEC > 0 THEN W$ = W$ + "." + F$ + STRING$(LEN(FF$) - LEN(F$), "0")
	FNFMT$ = ADD$ + W$
END DEF

'          ---  FORMAT A NUMERIC STRING, DELUXE VERSION, WITH FORMAT STRING
DEF FNFORMAT$(A#,FORM$)
'       A#:     A POSITIVE INTEGER OR FLOATING POINT NUMBER
'       FORM$:  #####           RIGHT JUSTIFY, BLANK FILL
'               0####           RIGHT JUSTIFY, ZERO FILL
'               $####           ADD DOLLAR SIGN
'               -####           ADD MINUS SIGN IF NEGATIVE
'               ##.##           FORMAT DECIMAL POINT
	STATIC SIGN,S$,P,A$,DEC,W$,F$,WF$,FF$,PAD$,ADD$
'
	SIGN=SGN(A#)
	A#=ABS(A#)
'          ---  SEPARATE WHOLE AND FRACTIONAL PARTS OF NUMBER
	W$=MID$(STR$(INT(A#)),2)
	S$=STR$(1+A#)
	P=INSTR(S$,".")
	IF P=0 THEN
		F$=""
	   ELSE F$=MID$(S$,P+1)
	END IF
'          ---  SEPARATE WHOLE AND FRACTION FORMAT STRINGS
	DEC=INSTR(FORM$,".")
	IF DEC=0 THEN
		WF$=FORM$ : FF$=""
	   ELSE WF$=LEFT$(FORM$,DEC-1)
		FF$=MID$(FORM$,DEC+1)
	END IF
'          ---  DECIDE ON A PAD CHARACTER
	IF LEFT$(WF$,1)="$" THEN
		WF$=MID$(WF$,2)
		ADD$="$"
	   ELSE ADD$=""
	END IF
'          ---  ADD SIGN CHARACTER
	IF LEFT$(WF$,1)="-" THEN
		WF$=MID$(WF$,2)
		IF SIGN=-1 THEN
			ADD$=ADD$+"-"
		   ELSE ADD$=ADD$+" "
		END IF
	END IF
	IF LEFT$(WF$,1)="0" THEN
		PAD$="0"
	   ELSE PAD$=" "
	END IF
'          ---  HANDLE NUMERIC OVERFLOW AND UNDERFLOW
	IF LEN(W$)>LEN(WF$) THEN W$="%"+RIGHT$(W$,LEN(WF$)-1)
	IF LEN(F$)>LEN(FF$) THEN F$=LEFT$(F$,LEN(FF$))
'          ---  FORMAT THE NUMBER STRING
	A$=STRING$(LEN(WF$)-LEN(W$),PAD$)+W$
	IF DEC>0 THEN A$=A$+"."+F$+STRING$(LEN(FF$)-LEN(F$),"0")
	FNFORMAT$=ADD$+A$
END DEF


'   ---
'   --- Scale radius based upon distance from viewer
'   ---
DEF FNZSCALE (RADIUS,Z,VIEWER)
	FNZSCALE = TAN(ATN(RADIUS / ABS(VIEWER - Z))) * VIEWER
END DEF


'------------------------------------------------------------------------------
    ' DATA INPUT VARIABLES
'          ---  CONTROL CODES
	CU$=CHR$(0)+CHR$(72)                    ' UP ARROW
	CD$=CHR$(0)+CHR$(80)                    ' DOWN ARROW
	CR$=CHR$(0)+CHR$(77)                    ' RIGHT ARROW
	CL$=CHR$(0)+CHR$(75)                    ' LEFT ARROW
	CSRL$=CHR$(29)                          ' CURSOR LEFT
	RTN$=CHR$(13)                           ' CARRIAGE RETURN
	ESC$=CHR$(27)                           ' ESCAPE
	BS$=CHR$(8)                             ' BACKSPACE
	TB$=CHR$(9)                             ' TAB
	BT$=CHR$(0)+CHR$(15)                    ' BACKTAB
    F10$=CHR$(0)+CHR$(68)                   ' FUNCTION KEY 10
	HOM$=CHR$(0)+CHR$(71)                   ' HOME
	EN$=CHR$(0)+CHR$(79)                    ' END
	PGUP$=CHR$(0)+CHR$(73)                  ' PAGE UP
	PGDN$=CHR$(0)+CHR$(81)                  ' PAGE DOWN
	ALPHAS$="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
	NUMBERS$="0123456789"
	P$=CHR$(250)                            ' DATA ENTRY FIELD PROMPT

'          ---  ENTRY SCREEN EDIT ARRAY
    MAXFIELD%=11                         ' SIZE OF FIELD SPEC TABLE
    PARMFIELDS% = 10                     ' NUMBER OF PARAMETER FIELD TO EDIT
	DIM DATA$(MAXFIELD%): DIM LABEL$(MAXFIELD%)
	DIM S(MAXFIELD%,3)                 ' DATA ENTRY FIELD SPECS
'
'
'
'          ---  DATA ENTRY/DISPLAY SCREEN TABLES
'   S(Y,Z) :=
'       Y := FIELD NUMBER
'       Z := FIELD SPECS:
'            1 := FIELD LENGTH

'            2 := FIELD TYPES AVAILABLE:
'                 1 := NUMERIC OR ALPHA
'                 2 := NUMERIC
'                 3 := ALPHA
'                 4 := SIGNED NUMERIC
'                 5 := DOLLAR

'            3 := Y-COORDINATE
'            4 := X-COORDINATE
'
'   Name      Fieldno      Len, Type, Row,  Col
SCREENDATA:
    R1FIELD     = 1  : DATA 3,  2,    04,   18
    AFIELD      = 2  : DATA 4,  5,    05,   18
    BFIELD      = 3  : DATA 4,  5,    06,   18
    XXFIELD     = 4  : DATA 1,  2,    07,   18
    YXFIELD     = 5  : DATA 1,  2,    08,   18
    ZXFIELD     = 6  : DATA 1,  2,    09,   18
    RADFIELD    = 7  : DATA 2,  2,    10,   18
    QTYFIELD    = 8  : DATA 4,  2,    11,   18
    AXISFIELD   = 9  : DATA 1,  3,    12,   18
    ALGOFIELD   =10  : DATA 1,  2,    13,   18
    ANGLEFIELD  =11  : DATA 4,  4,    24,   50

	RESTORE SCREENDATA
	FOR I=1 TO MAXFIELD%
		FOR J=0 TO 3
			READ S(I,J)
		NEXT J
	NEXT I

    ' Read default values into DATA$ array
	CALL SET.DATA.DEFAULTS (DATA$())

    ' Initialize labels for input fields
	LABEL$(1) = "     R Value = "
	LABEL$(2) = "     A Value = "
	LABEL$(3) = "     B Value = "
	LABEL$(4) = "  X-Exponent = "
	LABEL$(5) = "  Y-Exponent = "
	LABEL$(6) = "  Z-Exponent = "
	LABEL$(7) = "  Sphere Rad = "
	LABEL$(8) = "# of Spheres = "
	LABEL$(9) = "View (x,y,z) = "
	LABEL$(10)= "Method (1-5) = "
	LABEL$(11)= "Angle to rotate: "

'------------------------------------------------------------------------------
VIEWER = 300  ' FOR SCREEN PREVIEW ONLY (LOW VALUE="WIDE ANGLE" PERSPECTIVE)
PAINTFLAG%=TRUE%
BG% = 7                          ' SCREEN BACKGROUND COLOR (7 = gray)


COLS% = 640 : ROWS% = 350 :XCENTER%=COLS%/2 : YCENTER%=ROWS%/2
WINTOP%=16: WINBOTTOM%=ROWS%-50: WINLEFT%=XCENTER%/2+20: WINRIGHT%=COLS%-10
WINXCENTER%=(WINRIGHT%-WINLEFT%)/2 : WINYCENTER%=(WINBOTTOM%-WINTOP%)/2

MAXCOLORS% = 15
GRMODE% = 9

ON ERROR GOTO NOT.EGA          ' Trap errors before setting graphics mode
SCREEN GRMODE%,1,0,0           ' Initialize graphics mode, page
ON ERROR GOTO 0                ' Reset error trapping


' Create an GUI-looking window for the data entry fields.
CALL GUIPANEL (8%,WINTOP%,WINLEFT%-8,WINBOTTOM%,2%)           ' RAISED PANEL
CALL GUIPANEL (16%,190%,WINLEFT%-16,WINBOTTOM%-8,1%)          ' RAISED PANEL

' COLORED DOTS "LOGO"
CALL GUIBOLT( 65%, 240%, 10%, 1%)
CALL GUIBOLT( 90%, 240%, 10%, 1%)
CALL GUIBOLT(115%, 240%, 10%, 1%)
CIRCLE ( 65,240),8,2 : PAINT ( 65,240),2
CIRCLE ( 90,240),8,5 : PAINT ( 90,240),5
CIRCLE (115,240),8,9 : PAINT (115,240),9

' The sunken panel can be printed in from rows 15-20
' starting at column 4 for a length of 18 Characters.
'                   123456789012345678
LOCATE 15,4: PRINT "  3-D Lissajous  "
LOCATE 16,4: PRINT "    Generator    "
LOCATE 20,4: PRINT "  By Dan Farmer  "

CALL GUIBOLT(10%,8%,4%,1%)                       ' UPPER LEFT BOLT
CALL GUIBOLT(COLS%-10%,8%,4%,1%)                 ' UPPER RIGHT BOLT

' Create panel for messages at screen bottom
CALL GUIPANEL(8%,WINBOTTOM%+8%,WINRIGHT%,ROWS%-8%,2%)
CALL GUIBOLT(24%,ROWS%-24%,4%,1%)
CALL GUIBOLT(WINRIGHT%-24%,ROWS%-24%,4%,1%)


' Create a GUI-looking window for the image display
CALL GUIPANEL (WINLEFT%,WINTOP%,WINRIGHT%,WINBOTTOM%,-3%)      'SUNKEN PANEL

VIEW (WINLEFT%+8,WINTOP%+8)-(WINRIGHT%-8,WINBOTTOM%-8)
COLOR 8,BG%                                        ' BRITE WHITE

'FIRST.TIME%=TRUE%
DO WHILE TRUE%                                     ' GO RIGHT TO DISPLAY
  TOP:
	GOSUB EDIT.PARMS
	FIRST.TIME%=FALSE%                             ' NOW USER HAS CONTROL

	COUNTER%=0%
	ON ERROR GOTO TOO.BIG
    REDIM QUEUE(SPHERES%, 5) :  REDIM INDEX%(SPHERES%)
	ON ERROR GOTO 0

	COLOR ,7                                        ' CHANGE BG COLOR
	CALL DISPMSG("Generating...")


	FOR T% = 1 TO SPHERES%
		COUNTER%=COUNTER%+1%
		INDEX%(COUNTER%) = COUNTER%                  ' INITIALIZE SORT ARRAY

		ON ALGO GOSUB ALGO.ONE, ALGO.TWO,ALGO.THREE,ALGO.FOUR,ALGO.FIVE

		CALL ORIENT.XYZ(X,Y,Z,AXIS%)

        ' Scale radius for display
        SCALED.RADIUS=FNZSCALE(RADIUS,Z,VIEWER)

        '   Queue parameters for sorting for display (hidden line removal)
		QUEUE(COUNTER%, 1) = X: QUEUE(COUNTER%, 2) = Y
		QUEUE(COUNTER%, 3) = Z: QUEUE(COUNTER%, 4) = SCALED.RADIUS

	NEXT T%

	'   --- INDEX THE QUEUE ARRAY ON THE 4TH ELEMENT (Z)
	CALL DISPMSG("Sorting Array...")
	CALL QUICKSORT(QUEUE(),4,INDEX%())   ' SORTS THE INDEX, NOT THE QUEUE

	'   --- DRAW THE GRAPHICS IMAGE
	CALL DISPMSG("Drawing...")
	COLOR ,BG%                                    ' RESTORE BG COLOR
	QTY%=SPHERES%
	CALL DISPLAY(QUEUE(),INDEX%(),TRUE%,QTY%)
	IF QTY% > 0 THEN SPHERES%=QTY%

	A$=""
    DO WHILE A$ <> ESC$ AND A$ <> CHR$(13)
		CALL DISPMSG("Finished: [D]=DKB Script  [R]=Rotate  [CR]=More  [Esc]=Quit")
        A$="" : CALL KEYFLUSH : CALL GETKEY(A$) : CALL CLEARMSG
        IF A$= ESC$ THEN EXIT DO
		IF INSTR("Dd",A$) > 0 THEN GOSUB MAKE.DKB
        IF INSTR("Rr",A$) > 0 THEN CALL ROTATE (QUEUE(),INDEX%(),SPHERES%)
    LOOP
LOOP


ENDIT:
SCREEN 0: WIDTH 80: CLS
PRINT
PRINT "LISSAJOU.EXE  Version 1.1"
PRINT "Copyright 1991 by Dan Farmer."
PRINT "All rights reserved."
PRINT
END

MAXALGO = 5          ' CHANGE IF ALGORITHM VARIATIONS ARE ADDED
ALGO.ONE:
	X = R1*(SIN(A*T%)*COS(B*T%) ^EXPONENT.X)
	Y = R1*(SIN(A*T%)*SIN(B*T%) ^EXPONENT.Y)
	Z = R1*(COS(A*T%)           ^EXPONENT.Z)
RETURN
ALGO.TWO:
	X = R1*(SIN(A*T%)*COS(B*T%) ^EXPONENT.X)
	Y = R1*(COS(A*T%)*COS(B*T%) ^EXPONENT.Y)
	Z = R1*(SIN(A*T%)           ^EXPONENT.Z)
RETURN
ALGO.THREE:
	X = R1*(SIN(A*T%)*SIN(B*T%) ^EXPONENT.X)
	Y = R1*(SIN(A*T%)*COS(B*T%) ^EXPONENT.Y)
	Z = R1*(SIN(A*T%)           ^EXPONENT.Z)
RETURN
ALGO.FOUR:       ' THIS ONE'S A KEEPER
	PI = 3.1415
	X = R1/4 *  (A*SIN(2*(T%-PI/13)) ^EXPONENT.X)
	Y = R1/4 *  (-B*COS(T%)          ^EXPONENT.Y)
	Z = R1   * ((SIN(A*T%))          ^EXPONENT.Z)
RETURN
ALGO.FIVE:       ' THIS ONE'S A *KEEPER*!
	X = R1*(SIN(A*T%)*COS(A*T%) ^EXPONENT.X)
	Y = R1*(SIN(B*T%)*SIN(B*T%) ^EXPONENT.Y)
	Z = R1*(SIN(T%)             ^EXPONENT.Z)
RETURN


EDIT.PARMS:

'  --- DISPLAY THE DATA FROM THE FILE
	SHOW.DATA:
	CALL KEYFLUSH
    FOR FIELDPTR%=1 TO PARMFIELDS%
		LOCATE S(FIELDPTR%,2),3
		COLOR 14                            ' YELLOW TEXT
		PRINT LABEL$(FIELDPTR%)
		COLOR 8                             ' GRAY TEXT
        FILL$= "_"
		CALL DISPFIELD (FIELDPTR%,DATA$(FIELDPTR%),FILL$)
	NEXT FIELDPTR%
    CALL DISPMSG("Press F10 to reset default values.")

'  --- DO THE EDITING OF THE FIELDS
	FIELDPTR%=1
	DONE% = FALSE%

IF FIRST.TIME% GOTO END.EDIT.LOOP   ' OK, OK, C-BEES, YOU HAVE THEM, TOO!

	WHILE NOT DONE%
		EXIT$="":PEND$=""
		PRINT
		COLOR 15                              ' BRITE WHITE TEXT
		CALL FIELDINPUT(FIELDPTR%,DATA$(FIELDPTR%),PEND$,EXIT$)
		COLOR 8                               ' GRAY TEXT
		CALL DISPFIELD (FIELDPTR%,DATA$(FIELDPTR%),FILL$)

		IF EXIT$ = CU$  THEN
			FIELDPTR% = FIELDPTR% -1
			IF FIELDPTR% < 1 THEN FIELDPTR% = 1        'WRAP-AROUND
		ELSEIF EXIT$ = PGDN$ THEN DONE% = TRUE%
        ELSEIF EXIT$ = ESC$ THEN
			MSG$ = " Quit now "
			A$="Y"
			CALL VERIFY (MSG$,A$)
			IF A$ <>"" THEN
				CLS
				GOTO ENDIT
			END IF
			CALL DISPMSG("Press F10 to reset default values.")
		ELSEIF EXIT$ = F10$ THEN                 ' RESET TO DEFAULT VALUES
			CALL SET.DATA.DEFAULTS(DATA$())
			FIELDPTR%=1
			GOTO SHOW.DATA
		ELSE                                     ' ANY OTHER CASE
			FIELDPTR%=FIELDPTR% + 1
            IF FIELDPTR% >PARMFIELDS% THEN DONE% = TRUE%
		END IF
	WEND

END.EDIT.LOOP:

' Assign the data input string values to their related variables
    R1         = VAL(DATA$(1))
    A          = VAL(DATA$(2))
    B          = VAL(DATA$(3))
    EXPONENT.X = VAL(DATA$(4))
    EXPONENT.Y = VAL(DATA$(5))
    EXPONENT.Z = VAL(DATA$(6))
    RADIUS     = VAL(DATA$(7))
	SPHERES%   = VAL(DATA$(8))
    ALGO       = VAL(DATA$(10))
	AXIS$= DATA$(9)
	IF INSTR("Zz",AXIS$) > 0 THEN
		AXIS% = 1
	ELSEIF INSTR("Yy",AXIS$) > 0 THEN
		AXIS% = 2
	ELSEIF INSTR("Xx",AXIS$) > 0 THEN
		AXIS% = 3
	ELSE
		AXIS% = 1                            ' DEFAULT Z-AXIS VIEW
	END IF


	' Use default values if nothing entered
	IF R1=0 THEN R1=100
	IF A=0 THEN A=0.1
	IF B=0 THEN B=0.25
	IF EXPONENT.X = 0 THEN EXPONENT.X = 1
	IF EXPONENT.Y = 0 THEN EXPONENT.Y = 1
	IF EXPONENT.Z = 0 THEN EXPONENT.Z = 1
	IF RADIUS=0 THEN RADIUS=5
	IF SPHERES%=0 THEN SPHERES%=500
    IF ALGO = 0 THEN ALGO = 1: IF ALGO > MAXALGO THEN ALGO=1
RETURN

SUB SET.DATA.DEFAULTS (DATA$(1)) STATIC   ' takes a one-element array DATA$()
    ' SET DEFAULT VALUES
    DATA$(1) = "100"      ' R1
	DATA$(2) = "0.10"     ' A
	DATA$(3) = "0.25"     ' B
	DATA$(4) = "1"        ' X-EXPONENT
	DATA$(5) = "1"        ' Y-EXPONENT
	DATA$(6) = "1"        ' Z-EXPONENT
	DATA$(7) = " 8"       ' RADIUS
    DATA$(8) = " 500"     ' QTY SPHERES
	DATA$(9) = "Z"        ' AXIS
	DATA$(10)= "1"        ' ALGORITHM
	DATA$(11) = "  45"      ' ANGLE OF ROTATION
END SUB


'   --- Perform a simple 90 degrees rotation by swapping axis on
'   --- the object.
SUB ORIENT.XYZ (X,Y,Z,AXIS%) STATIC
STATIC X1,Y1,Z1

    X1=X : Y1=Y: Z1=Z            ' Work variables

    IF AXIS% = 1 THEN            ' AXIS$="Z"
    ELSEIF AXIS% = 2 THEN        ' AXIS$="Y"
		X = Z1 : Z = X1          ' SWAP X & Z AXIS (ROTATE 90 ON Y AXIS)
    ELSEIF AXIS% = 3 THEN          AXIS$="X"
		Y = Z1 : Z = Y1          ' SWAP Y & Z AXIS (ROTATE 90 ON X AXIS)
    END IF
END SUB

'
SUB ROTATE (QUEUE(2),INDEX%(1),SPHERES%) STATIC

    ' Get input from user (angle to rotate)
	LOCATE S(11,2),33,1 : PRINT LABEL$(11);
	CALL DISPFIELD(11%,DATA$(11),"-")
	CALL FIELDINPUT(11%,DATA$(11),"","")
    ANGLE = VAL(DATA$(11))


    FOR I% = 1 TO SPHERES%
		X = QUEUE(I%, 1) : Y = QUEUE(I%, 2)
		Z = QUEUE(I%, 3)

		YY=Y*COS(ANGLE) - Z*SIN(ANGLE)
		ZZ=Y*SIN(ANGLE) + Z*COS(ANGLE)
		Y = YY
		Z = ZZ

        ' Gotta rescale the radii now.
        SCALED.RADIUS=FNZSCALE(RADIUS,Z,VIEWER)

        '   Queue parameters for sorting for display (hidden line removal)
        QUEUE(I%, 1) = X: QUEUE(I%, 2) = Y
        QUEUE(I%, 3) = Z: QUEUE(I%, 4) = SCALED.RADIUS
	NEXT I%

    ' Sort the index (not the queue)
    CALL QUICKSORT(QUEUE(),4,INDEX%())
	QTY%=SPHERES%

    ' Show the new arrangement
	CALL DISPLAY(QUEUE(),INDEX%(),TRUE%,QTY%)
END SUB

'   ---
'   --- Sort the circles on Z, from most distant to closest for simple
'       "hidden line removal".  Farthest will be drawn first and overlapped
'       by the nearer circles.
'       Parms: ARRAY(2) = two element array of values needed sorting.
'              ELEMENT% = key element of ARRAY() to use for the sort.
'                         In this program the 4th element (z values) are
'                         used as the sort key.
'              INDEX%(1)= single dimension array of integers indexing ARRAY().
'   ---
SUB QUICKSORT (ARRAY(2),ELEMENT%,INDEX%(1)) STATIC
STATIC LEFT%,RIGHT%,I%,J%,MEDIAN,STACK%,MAXDATA%
DIM LSTACK%(50),RSTACK%(50)

	MAXDATA% = UBOUND(INDEX%)
	STACK.HEIGHT% =1 : LSTACK%(1) =1: RSTACK%(1) = MAXDATA%
    DO
        LEFT% = LSTACK%(STACK.HEIGHT%)
        RIGHT% = RSTACK%(STACK.HEIGHT%)
        STACK.HEIGHT% = STACK.HEIGHT%-1
        DO
            I% = LEFT% : J% = RIGHT%
			MEDIAN = ARRAY(INDEX%((LEFT%+RIGHT%)\2), ELEMENT%)
			DO
				WHILE ARRAY(INDEX%(I%),ELEMENT%) < MEDIAN
                    I% = I% +1
                WEND

				WHILE MEDIAN < ARRAY(INDEX%(J%),ELEMENT%)
					J% = J% -1
                WEND

				IF I% <= J% THEN
					SWAP INDEX%(I%), INDEX%(J%)
					I% = I% +1 : J% = J% -1
				END IF

			LOOP WHILE I% <= J%

            IF I% < RIGHT% THEN
                STACK.HEIGHT% = STACK.HEIGHT% +1
				LSTACK%(STACK.HEIGHT%) = I%
				RSTACK%(STACK.HEIGHT%) = RIGHT%
			END IF

            RIGHT% = J%
		LOOP WHILE LEFT% < RIGHT%

	LOOP WHILE STACK.HEIGHT% <> 0
END SUB


'   ---
'   --- Here is where we draw the image, using sorted index of Z elements
'       to draw most distant circles first.
'   ---
SUB DISPLAY (QUEUE(2),INDEX%(1),PAINTFLAG%, QTY.DRAWN%) STATIC
STATIC I%
	CALL DISPMSG("Press any key to pause drawing")
	CLS 1                                    ' CLEAR GRAPHICS WINDOW
	FOR I% = 1 TO UBOUND (INDEX%)            ' DISPLAY IN INDEXED ORDER

		X = QUEUE(INDEX%(I%), 1) : Y = QUEUE(INDEX%(I%), 2)
		Z = QUEUE(INDEX%(I%), 3) : R = QUEUE(INDEX%(I%), 4)

		KOLOR% = I% MOD MAXCOLORS% +1

		XPOINT = WINXCENTER% + X: YPOINT = WINYCENTER% + Y

		CIRCLE (XPOINT, YPOINT), R+1, 8        ' GRAY OUTLINE
		CIRCLE (XPOINT, YPOINT), R,   KOLOR%   ' BOUNDS FOR PAINT

		IF PAINTFLAG% = TRUE% THEN
			PAINT (XPOINT, YPOINT), KOLOR%
		END IF

        EXIT$=INKEY$
		IF EXIT$ <> "" THEN
			CALL VERIFY ("Paused: Stop at" + STR$(I%) + " spheres",EXIT$)
			IF EXIT$<>"" THEN QTY.DRAWN%=I%: EXIT SUB
			CALL CLEARMSG
		END IF

	NEXT I%
END SUB

' --- Write the DKB script
'
MAKE.DKB:
	SCREEN GRMODE%,1,1,1                  ' SWITCH SCREEN PAGES
	COLOR ,7                              ' LIGHT GRAY (WHITE) BACKGROUND
	CLS

	'   --- Get Output filename
  GET.OUTPUT.FILE:
	CALL DISPMSG ("Press <ENTER> to cancel")
	LOCATE 2,4
	PRINT "Name of output file: [.DAT] "
	LOCATE 2,32 :LINE INPUT OUTFILE$
	IF OUTFILE$="" THEN GOTO END.MAKE.DKB
	IF INSTR(OUTFILE$,".") = 0 THEN OUTFILE$=OUTFILE$ + ".DAT"

  GETCOLORS:
        '   --- GET COLOR NAMES FROM USER
		LOCATE 4,4: PRINT "How many colors would you like to use? ";
		LINE INPUT KOLOR.COUNT$ : KOLOR.COUNT = VAL(KOLOR.COUNT$)
		IF KOLOR.COUNT=0 THEN GOTO END.MAKE.DKB

        GET.COLORS:
		REDIM KOLOR$(KOLOR.COUNT)
        REDIM COLORNAME$(KOLOR.COUNT)
		LOCATE 5,4
		PRINT "Enter either standard DKB RGB values or a DECLARED color name."
		LOCATE 6,4: PRINT "(Leave a color blank to exit early)"
		ACTUAL.COLOR.COUNT=0
		ALINE% = 7
		FOR I% = 1 TO KOLOR.COUNT
			ALINE%=ALINE% + 1
            IF ALINE% = 24 THEN
				FOR J% = 6 TO 23
					LOCATE J%,1 : PRINT SPACE$(80);   ' CLEAR THE LINE
                NEXT J%
                ALINE% = 8
			END IF
			LOCATE ALINE%,8: PRINT "Color #"; I%; " = COLOR ";
			LINE INPUT KOLOR$(I%)
			IF KOLOR$(I%)="" THEN
				GOTO EXIT.GET.COLORS            ' LEAVE THE LOOP
			END IF
			ACTUAL.COLOR.COUNT=ACTUAL.COLOR.COUNT+1
		NEXT I%
		EXIT.GET.COLORS:
			KOLOR.COUNT=ACTUAL.COLOR.COUNT

        IF KOLOR.COUNT = 0 THEN GOTO END.MAKE.DKB

    '   --- Begin to write the data file
    OPEN OUTFILE$ FOR OUTPUT AS #1

    '   --- Write the VIEW, LIGHT SOURCE, and info data
	GOSUB WRITE.HEADER

    PRINT #1,"COMPOSITE"                         ' FOR EASY POSITIONING

    '   --- Write one SPHERE at a time
    LOW.X = VAL(X$) : HI.X = VAL(X$)
    LOW.Y = VAL(Y$) : HI.Y = VAL(Y$)
    LOW.Z = VAL(Z$) : HI.Z = VAL(Z$)
    FOR I%=1 TO SPHERES%
		X$ = FNFMT$(QUEUE(INDEX%(I%), 1))
		Y$ = FNFMT$(QUEUE(INDEX%(I%), 2))
		Z$ = FNFMT$(QUEUE(INDEX%(I%), 3))

        '   --- TRACK MINIMUM AND MAXIMUM VECTORS
        THIS.X = VAL(X$) : THIS.Y = VAL(Y$) : THIS.Z = VAL(Z$)
        IF THIS.X < LOW.X THEN LOW.X = THIS.X
        IF THIS.Y < LOW.Y THEN LOW.Y = THIS.Y
        IF THIS.Z < LOW.Z THEN LOW.Z = THIS.Z
        IF THIS.X > HI.X THEN HI.X = THIS.X
        IF THIS.Y > HI.Y THEN HI.Y = THIS.Y
        IF THIS.Z > HI.Z THEN HI.Z = THIS.Z

        RADIUS$=FNFMT$(RADIUS)
'       AKOLOR$=KOLOR$(I% MOD KOLOR.COUNT)         'COLOR VALUES
		COLORALIAS$=COLORNAME$(I% MOD KOLOR.COUNT+1) 'COLORNAME TO WRITE TO OBJECT
        GOSUB WRITE.DATA
	NEXT I%

    '   --- Write the end of the COMPOSITE
    PRINT #1, ""
    PRINT #1, "END_COMPOSITE"
    PRINT #1, "{"
    PRINT #1, "  Parameters used for this generation:"
    PRINT #1, "    R1 =";R1; "   A =";A;"   B =";B
    PRINT #1, "    X-Exponent =";EXPONENT.X
    PRINT #1, "    Y-Exponent =";EXPONENT.Y
    PRINT #1, "    Z-Exponent =";EXPONENT.Z
    PRINT #1, "    Sphere Radius =";RADIUS
    PRINT #1, "    Number of Spheres generated: ";SPHERES%
    PRINT #1, "    Axis = "; AXIS$
    PRINT #1, "    Algorithm = #"; ALGO
    PRINT #1, ""
    PRINT #1, "    Minimum X = ";LOW.X ; " Maximum X = ";HI.X
    PRINT #1, "    Minimum Y = ";LOW.Y ; " Maximum Y = ";HI.Y
    PRINT #1, "    Minimum Z = ";LOW.Z ; " Maximum Z = ";HI.Z
    PRINT #1, ""
    PRINT #1, "    (Min/Max XYZs with RADIUS figured in:)"
    PRINT #1, "    Leftmost Point = ";LOW.X-RADIUS ; " Rightmost Point = ";HI.X+RADIUS
    PRINT #1, "      Lowest Point = ";LOW.Y-RADIUS ; "   Highest Point = ";HI.Y+RADIUS
    PRINT #1, "     Nearest Point = ";LOW.Z-RADIUS ; "  Farthest Point = ";HI.Z+RADIUS
    PRINT #1, "}"
    PRINT #1, "{ *** End of ";OUTFILE$;" *** }"
	CLOSE #1

	CALL DISPMSG("DKB Script written as "+OUTFILE$+".  Press any key to resume." )
	CALL KEYFLUSH
	CALL GETKEY("")
	CALL CLEARMSG

  END.MAKE.DKB:
	CLOSE
	CLS 0
	SCREEN GRMODE%,1,0,0                              ' SWAP SCREEN PAGE
	COLOR ,BG%                                ' RESTORE BACKGROUND COLOR
RETURN


WRITE.HEADER:
    PRINT #1, "{ Lissajous figure DKB datafile "; OUTFILE$
    PRINT #1, "  Generated on ";DATE$;" at ";TIME$
    PRINT #1, "}"
    PRINT #1, ""
    PRINT #1, "INCLUDE ";CHR$(34);"shapes.dat" ;CHR$(34)
    PRINT #1, "INCLUDE ";CHR$(34);"colors.dat" ;CHR$(34)
    PRINT #1, "INCLUDE ";CHR$(34);"textures.dat" ;CHR$(34)
    PRINT #1, ""
    PRINT #1, "DECLARE Atexture = TEXTURE"
    PRINT #1, "    Shiny"
    PRINT #1, "    {Put further texture mods as needed here}"
	PRINT #1, "END_TEXTURE"
    PRINT #1, ""
    PRINT #1, "VIEW_POINT"
    PRINT #1, "   LOCATION <0.0  0.0  -250.0> {Modify as needed}"
    PRINT #1, "   DIRECTION <0.0 0.0  1.0>"
    PRINT #1, "   UP  <0.0  1.0  0.0>"
    PRINT #1, "   RIGHT <1.33333 0.0 0.0>"
    PRINT #1, "   LOOK_AT <0.0 0.0 0.0>"
    PRINT #1, "END_VIEW_POINT"
    PRINT #1, ""
    PRINT #1, "{ Basic Light source }"
    PRINT #1, "OBJECT"
    PRINT #1, "   SPHERE <0.0  0.0  0.0>  2.0 END_SPHERE"
	PRINT #1, "   TRANSLATE <100.0  100.0  -500.0>"
    PRINT #1, "   TEXTURE"
    PRINT #1, "      COLOUR White"
    PRINT #1, "      AMBIENT 1.0"
    PRINT #1, "      DIFFUSE 0.0"
    PRINT #1, "   END_TEXTURE"
    PRINT #1, "   LIGHT_SOURCE"
    PRINT #1, "   COLOUR White"
    PRINT #1, "END_OBJECT"
    PRINT #1, ""
    PRINT #1, "{ Put all colors into declarations for ease of changing }"
    FOR K=1 TO KOLOR.COUNT
        COLORNAME$(K)="Color" + FNUNPAD$(STR$(K))
        PRINT #1, "DECLARE " + COLORNAME$(K) + " = COLOR " + KOLOR$(K)
    NEXT K
	PRINT #1, ""
    FOR K=1 TO KOLOR.COUNT
        COLORNAME$(K)="Color" + FNUNPAD$(STR$(K))
        PRINT #1, "DECLARE " + COLORNAME$(K) + "_Tex = TEXTURE Atexture COLOR " + COLORNAME$(K) + " END_TEXTURE"
    NEXT K
	PRINT #1, ""
RETURN

WRITE.DATA:
    PRINT #1,"    OBJECT"
    PRINT #1,"        SPHERE <";X$;" ";Y$;" ";Z$;"> " RADIUS$;" END_SPHERE
    PRINT #1,"        TEXTURE " + COLORALIAS$ + "_Tex END_TEXTURE"
    PRINT #1,"        COLOR " + COLORALIAS$
    PRINT #1,"    END_OBJECT"
RETURN

TOO.BIG:
	LOCATE 24,1 : PRINT CHR$(7);
	PRINT "OOPS! Unable to allocate memory for that many spheres.";
	CALL DISPMSG("Press any key to continue")
	WHILE INKEY$="":WEND
	LOCATE 24,1: PRINT SPACE$(80);
	CALL CLEARMSG
	RESUME TOP                     ' TRY AGAIN
'          ***                          ***
'          ***  DATA ENTRY SUBROUTINES  ***
'          ***                          ***
'
'          ***  INPUT A STRING  ***
SUB FIELDINPUT(FIELDNO%,ST$,PEND$,EXIT$) STATIC
'               ST$    := INPUT FIELD
'               PEND$  := PENDING KEYSTROKE
	IF PEND$="" THEN
		A$=""
		CALL KEYFLUSH
	   ELSE A$=PEND$
		PEND$=""
	END IF
	FI1:                                        ' HOME CURSOR IN FIELD
	CALL DISPFIELD(FIELDNO%,ST$+STRING$(S(FIELDNO%,0)-LEN(ST$),P$),FILL$)
	CALL HOMECURSOR(FIELDNO%)
	ST=0
	IF A$<>"" THEN GOTO FI4                 ' PROCESS PENDING KEYSTROKE
	PRESS=FALSE%
	LOCATE ,,1                              ' TURN ON CURSOR
	CALL GETKEY(A$)
	IF ASC(A$)>=32 THEN ST$=""
	GOTO FI1
	FI2:
	LOCATE ,,1                              ' TURN ON CURSOR
	CALL GETKEY(A$)
    FI4:                                        ' FILTER CONTROL KEYS
	IF ASC(A$)<32 THEN GOTO CONTROLINPUT    ' CHECK CHR, PRINT IT, UPDATE
    FI5:
	IF ST=S(FIELDNO%,0) THEN
		CALL KEYFLUSH
	   ELSE GOSUB CHECKCHAR
		IF ERRMSG$<>"" THEN
			GOTO FI4
		   ELSE PRINT A$;
			ST=ST+1
			PRESS=TRUE%
		END IF
	END IF
	GOTO FI2
'          ---  HANDLE CONTROL AND FUNCTION KEYS
    CONTROLINPUT:
	IF A$=CR$ THEN                          ' CURSOR RIGHT
		IF ST<S(FIELDNO%,0) THEN
			A$=CHR$(SCREEN(CSRLIN,POS(0)))
			IF A$<>P$ THEN
				PRINT A$;
				ST=ST+1
			END IF
		END IF
	   ELSEIF A$=CL$ THEN                          ' CURSOR LEFT
		IF ST>0 THEN
			PRINT CSRL$;
			ST=ST-1
		END IF
	   ELSEIF A$=BS$ THEN                          ' DESTRUCTIVE BACKSPACE
		IF ST>0 AND (ST=S(FIELDNO%,0) _
		   OR CHR$(SCREEN(CSRLIN,POS(0)))=P$) THEN
			PRINT CSRL$;P$;CSRL$;
			ST=ST-1
			PRESS=TRUE%
		END IF
	   ELSEIF A$=ESC$ THEN                         ' ERASE FIELD
		   EXIT$=A$
		   EXIT SUB
		'ST$="" : ST=0 : A$=""
		'GOTO FI1
	END IF
'          ---  VALIDATE FIELD END EXIT
	IF PRESS THEN
		GOSUB CHECKWORD
		IF ERRMSG$<>"" THEN GOTO FI4
	END IF
	EXIT$=A$
	LOCATE ,,0
	EXIT SUB
'          ***  CHARACTER CHECKER  ***
CHECKCHAR:
	ERRMSG$=""
	ON S(FIELDNO%,1) GOSUB_
                 CHECKCHARALPHAORNUM,_
				 CHECKCHARNUM,_
				 CHECKCHARALPHA,_
				 CHECKCHARSIGNED,_
                 CHECKCHARBUX
	IF ERRMSG$<>"" THEN CALL DISPERR(ERRMSG$,A$)
	RETURN
    CHECKCHARALPHAORNUM:                        ' 1 := NUMERIC OR ALPHA
	IF ST$<>"" THEN
		IF VAL(ST$)>0 OR LEFT$(ST$,1)="0" THEN
			GOTO CHECKCHARNUM       ' FIELD ALREADY NUMERIC
		   ELSE GOTO CHECKCHARALPHA     ' FIELD ALREADY ALPHA
		END IF
	    ELSEIF INSTR(NUMBERS$,A$)=0 AND INSTR(ALPHAS$,A$)=0 THEN
		ERRMSG$="Please press <A to Z> or <0 to 9>"
	END IF
	RETURN

    CHECKCHARNUM:                               ' 2 := NUMERIC
	IF INSTR(NUMBERS$,A$)=0 THEN_
		ERRMSG$="Please press <0 to 9>"
	RETURN

    CHECKCHARAN:                                ' 3 := ALPHA/NUMERIC
	IF A$="?" THEN_
		ERRMSG$="Please press <A to Z> or <0 to 9>"
	RETURN

    CHECKCHARBUX:                               ' 4 := DOLLARS
	IF INSTR(NUMBERS$,A$)=0 AND A$<>"." THEN _
		IF NOT(A$="#" AND ST=0) THEN _
			ERRMSG$="Please press <0 to 9> or a period"
	RETURN

    CHECKCHARALPHA:                             ' 6 := ALPHA
	IF INSTR(ALPHAS$,A$)=0 THEN _
		ERRMSG$="Please press <A to Z>"
	RETURN

    CHECKCHARSIGNED:                            ' 9 := SIGNED NUMERIC
	IF INSTR("+-",A$)=0 OR ST>1 THEN _
		GOTO CHECKCHARNUM
	RETURN
'
'          ***  WORD CHECKER  ***
'          ---  ENTER WORD
CHECKWORD:
	CALL HOMECURSOR(FIELDNO%)
	ST$="" : ST=0
	FOR I=1 TO S(FIELDNO%,0)                 ' READ FIELD FROM SCREEN
		AA$=CHR$(SCREEN(CSRLIN,POS(0)))
		IF AA$<>P$ THEN
			IF S(FIELDNO%,1)<>7 OR INSTR(NUMBERS$,AA$)<>0 THEN
				ST$=ST$+AA$
				ST=ST+1
			END IF
			PRINT AA$;
		   ELSE I=I+999
		END IF
	NEXT I
	ST=0
	CALL HOMECURSOR(FIELDNO%)
'          ---  VALIDATE WORD
	ERRMSG$=""
	IF ST$<>"" THEN_
		ON S(FIELDNO%,1) GOSUB_
                       CHECKWORDTYPE,_
				       CHECKWORDTYPE,_
				       CHECKWORDTYPE,_
                       CHECKWORDTYPE,_
                       CHECKPRICETYPE
	IF ERRMSG$<>"" THEN CALL DISPERR(ERRMSG$,A$)
	RETURN
	CHECKPRICETYPE:
	  '  ST$=FNFORMAT$(VAL(ST$),RIGHT$("##########.##",S(FIELDNO%,0)))
        RETURN
    CHECKWORDTYPE:
        RETURN
END SUB



'          ***                     ***
'          ***  MISC. SUBROUTINES  ***
'          ***                     ***
'
'          ---  HOME CURSOR IN FIELD
SUB HOMECURSOR(FIELDNO%) STATIC
	LOCATE S(FIELDNO%,2),S(FIELDNO%,3)
END SUB
'
'          ---   CLEAR DATA ENTRY FIELD
SUB CLEARFIELD(FIELDNO%) STATIC
	CALL HOMECURSOR(FIELDNO%)
	PRINT SPACE$(S(FIELDNO%,0));
END SUB
'
'          ---   DISPLAY DATA ENTRY FIELD
SUB DISPFIELD(FIELDNO%,A$,FILL$) STATIC
	CALL CLEARFIELD(FIELDNO%)
	CALL HOMECURSOR(FIELDNO%)
	IF NOT FNISBLANK(A$) THEN               ' DON'T BOTHER WITH BLANK
		PRINT A$;
	ELSE PRINT STRING$(LEN(A$),FILL$)
	END IF
END SUB
'          ---  REMEMBER CURSOR POSITION
SUB SAVECURS(V,H) STATIC
	V=CSRLIN
	H=POS(0)
END SUB
'
'          ---  FLUSH KEYBOARD BUFFER
SUB KEYFLUSH STATIC
	WHILE INKEY$<>""
	WEND
END SUB
'
'          ---  GET KEYSTROKE
SUB GETKEY(A$) STATIC
	A$=""
	WHILE A$=""
		A$=FNLOOKKEY$(0)
	 WEND
END SUB
'
'          ---  DISPLAY A MESSAGE
SUB DISPMSG(MSG$) STATIC
STATIC LEFT%,MAXLEN%
	MAXLEN%=70%
	LEFT%=(80-MAXLEN%)/2
	MSG$=FNUNPAD$(MSG$)
	IF LEN(MSG$) > MAXLEN% THEN MSG$=LEFT$(MSG$,MAXLEN%)  ' TRUNCATE IF NEEDED

	CALL SAVECURS(V,H)                      ' SAVE CURSOR POSITION
	LOCATE 24,LEFT%
	PRINT SPC(MAXLEN%);
	LOCATE 24,40-LEN(MSG$)/2
	PRINT MSG$;
	LOCATE V,H,1
END SUB
'
'          ---  CLEAR MESSAGE AREA
SUB CLEARMSG STATIC
        CALL DISPMSG("")
END SUB
'          ---  DISPLAY ERROR MESSAGE
SUB DISPERR(MSG$,A$) STATIC
		    '  MSG$ := MESSAGE TO DISPLAY
		    '  A$   := CARRYOVER KEYSTROKE
        CALL DISPMSG(MSG$)
	PRINT BELL$;
	CALL KEYFLUSH
	CALL GETKEY(A$)
	CALL CLEARMSG
END SUB
'
'          ---  ASK OPERATOR A YES/NO QUESTION, RESET EXIT$ IF NO
SUB VERIFY(MSG$,EXIT$) STATIC
        CALL DISPERR(MSG$+" (Y or N)?",B$)
        IF B$<>"y" AND B$<>"Y" THEN EXIT$=""
END SUB

SUB GUIPANEL (WLEFT%,WTOP%,WRIGHT%,WBOTTOM%,TOGGLE%) STATIC
STATIC DEPTH, I,INSET
' Parameter TOGGLE := -1 FOR INSET, 1 FOR OUTSET
'                     -2 FOR INSET 2 DEEP, 3 TO OUTSET 3 DEEP, ETC.
DEPTH%=ABS(TOGGLE%)
INSET%=(TOGGLE% < 0)

FOR I% = 0 TO DEPTH% -1
	IF INSET% THEN                                 ' INSET PANEL
		LINE (WLEFT%+I%,  WTOP%+I%)    - (WLEFT%+I%,WBOTTOM%-I%),  8  ' LEFT SIDE
		LINE (WLEFT%+I%,  WTOP%+I%)    - (WRIGHT%-I%,WTOP%+I%),    8  ' TOP LINE
		LINE (WLEFT%+I%,  WBOTTOM%-I%) - (WRIGHT%-I%,WBOTTOM%-I%),15  ' BOTTOM LINE
		LINE (WRIGHT%-I%, WTOP%+I%)    - (WRIGHT%-I%,WBOTTOM%-I%),15  ' RIGHT SIDE
	ELSE                                             ' OUTSET PANEL
		LINE (WLEFT%+I%,  WTOP%+I%)    - (WLEFT%+I%,WBOTTOM%-I%) ,15  ' LEFT SIDE
		LINE (WLEFT%+I%,  WTOP%+I%)    - (WRIGHT%-I%,WTOP%+I%)   ,15  ' TOP LINE
		LINE (WLEFT%+I%,  WBOTTOM%-I%) - (WRIGHT%-I%,WBOTTOM%-I%), 8  ' BOTTOM LINE
		LINE (WRIGHT%-I%, WTOP%+I%)    - (WRIGHT%-I%,WBOTTOM%-I%), 8  ' RIGHT SIDE
    END IF
NEXT I%
END SUB

SUB GUIBOLT(X%,Y%,R%,TOGGLE%) STATIC
STATIC DEPTH, I,INSET
' Parameter TOGGLE := -1 FOR INSET, 1 FOR OUTSET
'                     -2 FOR INSET 2 DEEP, 3 TO OUTSET 3 DEEP, ETC.
DEPTH%=ABS(TOGGLE%)
INSET%=(TOGGLE% < 0)
PI#=4*ATN(1!)

FOR I% = 0 TO DEPTH% -1
    IF INSET% THEN                                 ' INSET BOLT
		CIRCLE (X%,Y%),R%-I%, 15, 0.5*PI#, 1.5*PI#
		CIRCLE (X%,Y%),R%-I%,  8, 1.5*PI#, 0
    ELSE
		CIRCLE (X%,Y%),R%-I%,  8, 0.5*PI#, 1.5*PI#
		CIRCLE (X%,Y%),R%-I%, 15, 1.5*PI#, 0
    END IF
NEXT I%
END SUB

NOT.EGA:       ' ERROR TRAP
    SCREEN 0 : WIDTH 80
    PRINT ""
    PRINT "Sorry, but Lissajou requires EGA minimum to run."
    PRINT ""
	END
RETURN
' --- END OF LISSAJUO.BAS
