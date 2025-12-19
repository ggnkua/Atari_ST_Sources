'-----------------------------------------------------------------------------
' Program : SHELLGEN.BAS (QB 3)
' Function : Generates a basic script file for DKB Ray Tracer
'            consisting of series of spheres arranged in a logarithmic
'            spiral.  The guts of the code (subroutine SHELLGEN) was converted
'            from C source code from Clifford Pickover's book "Computers,
'            Pattern, Chaos, and Beauty" (St. Martin's Press) and was
'            reprinted in Ray Tracing News, Vol. 3, No. 3.
'
' Updated to DKB 2.11 by Aaron A. Collins on 5/1/91 - fixed write of a blanked
' out (unintentional, I'm sure...) SPHERE at the end of the list...
'-----------------------------------------------------------------------------

FALSE = 0: TRUE = NOT FALSE

COLS=640 : ROWS = 350
XCENTER = COLS/2 : YCENTER = ROWS/2

'          ---  FORMAT A NUMERIC STRING
DEF FNFMT$ (A#)
    FORM$="-####.######"
	STATIC SIGN, S$, P, A$, DEC, W$, F$, WF$, FF$, PAD$, ADD$
'
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

DEF FNMIN(A, B)
	IF B < A THEN FNMIN= B ELSE FNMIN = A
END DEF
DEF FNMAX(A, B)
    IF B > A THEN FNMAX= B ELSE FNMAX = A
END DEF

'---------------------------
'   ---
'   --- Some constants and default variables
'   ---
PAINTFLAG       =  FALSE
PI              =  3.1415
DEF.FORMULA     =  1
DEF.ORIENTATION =  1
DEF.GAMMA       =  1.0
DEF.ALPHA       =  1.1
DEF.BETA        =  2.0
DEF.STEPS       =  600
DEF.EXPONENT    =  0.15
DEF.MAG         =  1
DEF.VIEWER      =  150   ' DISTANCE FROM VIEWER TO SCREEN PLANE (Z0)
MAG.ADJUST      =  0.125

FORMULA     =  DEF.FORMULA
ORIENTATION =  DEF.ORIENTATION
GAMMA       =  DEF.GAMMA
ALPHA       =  DEF.ALPHA
BETA        =  DEF.BETA
STEPS       =  DEF.STEPS
EXPONENT    =  DEF.EXPONENT
VIEWER      =  DEF.VEWIER
MAG         =  DEF.MAG

ORG.FORMULA$     =  "Original formula used was 1."
ORG.ORIENTATION$ =  "Original value used was 1."
ORG.GAMMA$       =  "Try 0.01 to 3. Default was 1.  Affects ratio of largest to smallest."
ORG.ALPHA$       =  "Value greater than 1 is advised.  Used in calculating Z."
ORG.BETA$        =  "Stay somewhere near -2.0 to 2.0.  Used in calculating Z."
ORG.STEPS$       =  "Default value was 600 steps."
ORG.EXPONENT$    =  "0.15 (Stay pretty close).  Affects radius."
ORG.MAG$         =  "1    Scale the overall image size."
ORG.VIEWER$      =  "150  Larger values are similar to using a telephoto lens."

DO
    CLS
    GOSUB GET.PARMS
    GOSUB SHELLGEN
    GOSUB SORT.QUEUE
    GOSUB DISPLAY
    CALL CLEARKBUFF
	WHAT.TO.DO$=""
    LOCATE 1,1 : PRINT " [S]ave   [M]ore   [P]aint  [Q]uit    ";
    LINE INPUT WHAT.TO.DO$
	IF WHAT.TO.DO$ = "" THEN WHAT.TO.DO$="M"
    IF INSTR("Ss",WHAT.TO.DO$) >0 THEN
        GOSUB WRITE.FILE
	ELSEIF INSTR("Qq",WHAT.TO.DO$) > 0 THEN
		EXIT DO
	ELSEIF INSTR("Pp",WHAT.TO.DO$) > 0 THEN
		PAINTFLAG = TRUE
		GOSUB DISPLAY
		PAINTFLAG = FALSE
        CALL CLEARLINE("1")
        LOCATE 1,1: PRINT "Press any key to continue ...";
        CALL WAITKEY
    END IF
	SCREEN 0: WIDTH 80
LOOP WHILE TRUE                             ' GET.PARMS QUITS IF FORMULA=3

SCREEN 0 :WIDTH 80: CLS
SYSTEM

'
'   --- Generate the X, Y, Z, and radius for the image and store data
'       in a buffer for later sorting and drawing.
SHELLGEN:
	LOCATE 25, 1: PRINT "Generating...";

	LOW = -STEPS*2/3 :HI = STEPS/3
	NDATA = ABS(LOW) + HI

    '   --- QUEUE array : 1 == X, 2 == Y, 3 == X,
    '                     4 == Adjusted Radius, 5 == Real Radius
    '   --- INDEX array will contain sorted pointers to Z element of QUEUE.
    REDIM QUEUE(NDATA, 5) : REDIM INDEX(NDATA)
    '   --- INIT BOUNDING DIMENSIONS
    MIN.X = 0: MAX.X = 0 : MIN.Y=0 : MAX.Y = 0 : MIN.Z = 0 : MAX.Z = 0


	COUNTER = 0
	FOR I = LOW TO HI					 ' AAC - WAS HI - 1
		COUNTER = COUNTER+1
		INDEX(COUNTER) = COUNTER         ' INITIALIZE SORT ARRAY
        ANGLE = 3! * 6! * PI * I / STEPS
        R = (MAG) * EXP(EXPONENT * ANGLE)
        A$ = FNFMT$(R * SIN(ANGLE))
        B$ = FNFMT$(R * COS(ANGLE))
        IF FORMULA = 1 THEN
            C$ = FNFMT$(BETA * R)
        ELSE
            C$ = FNFMT$(ALPHA * ANGLE)
        END IF
        RAD$ = FNFMT$(R / GAMMA)
        GOSUB ORIENT.XYZ                         ' DETERMINE XY&Z VALUES
        QUEUE(COUNTER ,5) = VAL(RAD$)            ' SAVE UN-ADJUSTED RADIUS
        GOSUB SCALE.RADIUS                       ' SCALE R BASED ON DISTANCE
	QUEUE(COUNTER, 1) = X: QUEUE(COUNTER, 2) = Y
	QUEUE(COUNTER, 3) = Z: QUEUE(COUNTER, 4) = R
        GOSUB MAXBOUNDS
    NEXT I
RETURN

'   ---
'   --- Keep track of the smallest and largest XYZs
'   ---
MAXBOUNDS:
    MIN.X = FNMIN(MIN.X, X-R) : MAX.X = FNMAX(MAX.X, X+R)
    MIN.Y = FNMIN(MIN.Y, Y-R) : MAX.Y = FNMAX(MAX.Y, Y+R)
    MIN.Z = FNMIN(MIN.Z, Z-R) : MAX.Z = FNMAX(MAX.Z, Z+R)
RETURN


'   ---
'   --- Scale radius based upon distance from viewer
'   ---
SCALE.RADIUS:
    R = TAN(ATN(R / ABS(VIEWER - Z))) * VIEWER
RETURN

'   ---
'   --- Convert XYZ and Radius formatted strings into values
'   --- Orient the axis in the specified plane
'   ---
ORIENT.XYZ:
    IF ORIENTATION = 1 THEN
        Z = VAL(A$): Y = VAL(B$): X = VAL(C$)    ' Center in X Plane
    ELSEIF ORIENTATION = 2 THEN
        Y = VAL(C$): Z = VAL(B$): X = VAL(A$)    ' Center in Y Plane
    ELSE
        X = VAL(A$): Y = VAL(B$): Z = VAL(C$)    ' Center in Z Plane
    END IF
    R = VAL(RAD$)
RETURN

'   ---
'   --- Sort the circles on Z, from most distant to closest for simple
'       "hidden line removal".  Farthest will be drawn first and overlapped
'       by the nearer circles.
'   ---
SORT.QUEUE:
    LOCATE 25, 1: PRINT "Sorting ...  ";
    OFFSET = NDATA
    DO WHILE OFFSET > 1
        OFFSET = INT(OFFSET / 2)
        DO
            INORDER = TRUE
            FOR J = 1 TO (NDATA - OFFSET)
                I = J + OFFSET
                IF QUEUE(INDEX(I), 3) > QUEUE(INDEX(J), 3) THEN
                    SWAP INDEX(I), INDEX(J)
                    INORDER = FALSE
                END IF
            NEXT J
        LOOP UNTIL INORDER
    LOOP     ' While offset > 1
    LOCATE 25, 1: PRINT "             ";
RETURN


'   ---
'   --- Here is where we draw the image, using sorted index of Z elements
'       to draw most distant circles first.
'   ---
DISPLAY:
	SCREEN 9
    FOR I = 1 TO NDATA
        X = QUEUE(INDEX(I), 1)
        Y = QUEUE(INDEX(I), 2)
        Z = QUEUE(INDEX(I), 3)
        R = QUEUE(INDEX(I), 4)
		KOLOR = ABS(Z) MOD 3 +1
		XPOINT = XCENTER + X: YPOINT = YCENTER + Y
		CIRCLE (XPOINT, YPOINT), R, KOLOR
		IF PAINTFLAG = TRUE THEN
			IF XPOINT >= COLS THEN XPOINT = COLS -1
			IF XPOINT < 1     THEN XPOINT = 1
			IF YPOINT >= ROWS THEN YPOINT = ROWS -1
			IF YPOINT < 1     THEN YPOINT = 1
			PAINT  (XPOINT, YPOINT), KOLOR
		END IF
	NEXT I
RETURN

'   ---
'   --- Get user input for various parameters.
'   ---
GET.PARMS:
    CALL SHOW.DEFAULTS (ORG.FORMULA$,DEF.FORMULA)
	PRINT " Formula to use for calculating Z "
    PRINT " 1) [z=beta*r]    2) [z=alpha*angle]    3) QUIT: ";
    INPUT FORMULA
	IF FORMULA = 3 THEN END

    CALL SHOW.DEFAULTS (ORG.ORIENTATION$,DEF.ORIENTATION)
	PRINT " Center Axis Orientation "
	PRINT " ( 1=X  2=Y  3=Z ) : ";
    INPUT ORIENTATION

	PRINT
    CALL SHOW.DEFAULTS (ORG.GAMMA$,DEF.GAMMA)
	PRINT " Value of GAMMA    : ";
    INPUT GAMMA

    CALL SHOW.DEFAULTS (ORG.STEPS$,DEF.STEPS)
    PRINT " Number of steps   : ";
    INPUT STEPS

    IF FORMULA = 1 THEN
        CALL SHOW.DEFAULTS(ORG.BETA$,DEF.BETA)
        PRINT " Value of BETA     : ";
        INPUT BETA
    ELSE
        CALL SHOW.DEFAULTS(ORG.ALPHA$,DEF.ALPHA)
        PRINT " Value of ALPHA    : ";
        INPUT ALPHA
    END IF

    CALL SHOW.DEFAULTS(ORG.EXPONENT$,DEF.EXPONENT)
    PRINT " Exponential Scale : ";
	INPUT EXPONENT

	CALL SHOW.DEFAULTS(ORG.MAG$,DEF.MAG)
    PRINT " Magnification     : ";
	INPUT MAG

    CALL SHOW.DEFAULTS(ORG.VIEWER$,DEF.VIEWER)
    PRINT " Viewer Distance   : ";
    INPUT VIEWER

    IF ORIENTATION = 0 OR ORIENTATION > 3 THEN ORIENTATION = DEF.ORIENTATION
    IF FORMULA  =  0 THEN FORMULA  = DEF.FORMULA
    IF STEPS    =  0 THEN STEPS    = DEF.STEPS
	IF BETA     =  0 THEN BETA     = DEF.BETA
	IF ALPHA    =  0 THEN ALPHA    = DEF.ALPHA
	IF GAMMA    =  0 THEN GAMMA    = DEF.GAMMA
	IF EXPONENT =  0 THEN EXPONENT = DEF.EXPONENT
	IF VIEWER   <  1 THEN VIEWER   = DEF.VIEWER
	IF MAG      =  0 THEN MAG      = DEF.MAG

	DEF.FORMULA =  FORMULA
    DEF.ORIENTATION = ORIENTATION
    DEF.GAMMA    =  GAMMA
    DEF.ALPHA    =  ALPHA
    DEF.BETA     =  BETA
    DEF.STEPS    =  STEPS
    DEF.EXPONENT =  EXPONENT
	DEF.VIEWER   =  VIEWER
	DEF.MAG      =  MAG
    CALL CLEARLINE("24")
    CALL CLEARLINE("25")

RETURN

WRITE.FILE:

	INCLUDE.FILE$="DKBSHELL.INC"
    CALL CLEARLINE("1")
	LOCATE 1,1: PRINT " Name of include file? (Default = "+INCLUDE.FILE$+") : " ;
	LINE INPUT INCLUDE.FILE$
	IF INCLUDE.FILE$="" THEN INCLUDE.FILE$="DKBSHELL.INC"

	OUTFILE$="DKBSHELL.DAT"
    CALL CLEARLINE("1")
	LOCATE 1,1: PRINT " Name for generated database? (Default = "+OUTFILE$+") : ";
    LINE INPUT OUTFILE$
    IF OUTFILE$="" THEN OUTFILE$="DKBSHELL.DAT"
    OPEN "O",#1, OUTFILE$
        
    IF INCLUDE.FILE$ <> "" THEN GOSUB WRITE.INCLUDE
    GOSUB WRITE.HEADER
    GOSUB WRITE.BODY
	GOSUB WRITE.FOOTER
	CLOSE #1 : CLOSE #2

    CALL CLEARLINE("1")
	LOCATE 1,1: PRINT " Finished.  Press any key...";
    CALL WAITKEY
RETURN

WRITE.HEADER:
    PRINT #1, "{"
    PRINT #1, " SHELLGEN generated DKB script for Pickover seashell."
    PRINT #1, ""   
    PRINT #1, " Parameters used : "
    PRINT #1, "     Gamma :";GAMMA
    PRINT #1, "     Steps :";STEPS
    PRINT #1, "     Exponent :";A
    PRINT #1, "     Relative Size :";K
    PRINT #1, "     Number of spheres generated :"; NDATA
    PRINT #1, "     X-bounds = ";MIN.X; " to "; MAX.X
    PRINT #1, "     Y-bounds = ";MIN.Y; " to "; MAX.Y
    PRINT #1, "     Z-bounds = ";MIN.Z; " to "; MAX.Z
    
    IF FORMULA=1 THEN
        PRINT #1, "     Beta  :";BETA
        PRINT #1, "     Z = BETA * R"
    ELSE
        PRINT #1, "     Alpha :";ALPHA
        PRINT #1, "     Z = ALPHA * ANGLE"
    END IF    

    PRINT #1, "}"    
    PRINT #1, "{ *** Define the Shell object *** } "
    PRINT #1, "DECLARE Shell = OBJECT"
    PRINT #1, "    UNION"
RETURN

WRITE.BODY:
    FOR I = 1 TO NDATA             ' PRINT UNSORTED, STRING-FORMATTED DATA
        X$ = FNFMT$(QUEUE(I, 1))
        Y$ = FNFMT$(QUEUE(I, 2))
        Z$ = FNFMT$(QUEUE(I, 3))
        R$ = FNFMT$(QUEUE(I, 5))   ' UN-ADJUSTED RADIUS
		PRINT #1, "       SPHERE < ";X$;" ";Y$;" ";Z$;" > "; R$; " END_SPHERE"
    NEXT I    
RETURN


WRITE.FOOTER:
        PRINT #1, "    END_UNION"
        PRINT #1, "    TEXTURE"
        PRINT #1, " {  Edit the following 6 lines to change surface quality   }"
        PRINT #1, "       AMBIENT 0.3"
		PRINT #1, "       DIFFUSE 0.7"
        PRINT #1, "       REFRACTION 1.0 { A little translucency              }"
        PRINT #1, "       IOR 1.0        { without any actual refraction      }"       
        PRINT #1, "       PHONG 1.0      { Might try replacing these next two }"     
        PRINT #1, "       PHONGSIZE 20.0 { with the SPECULAR keyword.         }"
		PRINT #1, "       COLOUR RED 1.0 GREEN 0.498039 BLUE 0.0 ALPHA 0.4 { Coral }"
        PRINT #1, "    END_TEXTURE"  
		PRINT #1, "    COLOUR RED 1.0 GREEN 0.498039 BLUE 0.0 ALPHA 0.4 { Coral }"
        PRINT #1, "END_OBJECT"
        PRINT #1, " "
        PRINT #1, "{   This is where we actually position the shell object.   }"
        PRINT #1, "OBJECT"
        PRINT #1, "    Shell"
        PRINT #1, "    SCALE     < 1.0  1.0  1.0 >"
        PRINT #1, "    ROTATE    < 0.0  0.0  0.0 >"
        PRINT #1, "    TRANSLATE < 0.0  0.0  0.0 >"
		PRINT #1, "END_OBJECT"
RETURN

' Add an include file into the script
WRITE.INCLUDE:
    OPEN "I", #2, INCLUDE.FILE$ 
    WHILE NOT EOF(2)
        LINE INPUT #2,ASTRING$
        PRINT #1, ASTRING$
    WEND
RETURN

SUB SHOW.DEFAULTS (ORG.VALUE$, DEF.VALUE) STATIC
	AROW = CSRLIN
	ACOL = POS(0)
    CALL CLEARLINE("24")
    CALL CLEARLINE("25")
	LOCATE 24,4: PRINT ORG.VALUE$;
	LOCATE 25,4: PRINT "Hit <ENTER> to use "; DEF.VALUE;
	LOCATE AROW,ACOL
END SUB

SUB CLEARLINE(WHATLINE$) STATIC
    WHATLINE=VAL(WHATLINE$)
	AROW = CSRLIN
	ACOL = POS(0)
    LOCATE WHATLINE,1: PRINT SPACE$(80);
	LOCATE AROW,ACOL
END SUB

SUB WAITKEY STATIC
    CALL CLEARKBUFF
    WHILE INKEY$ =  "" : WEND
END SUB

SUB CLEARKBUFF STATIC
    WHILE INKEY$ <> "" :WEND
END SUB
