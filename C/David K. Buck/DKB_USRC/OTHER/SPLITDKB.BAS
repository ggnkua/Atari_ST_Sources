'---------------------
' SPLITDKB.BAS
' Creates a series of batchfiles to run strips of DKB data files on
' mulitple computers.
' Concept by Randy Antler.
' Written by Dan Farmer.
'---------------------
' Released 03/10/91
' Post-release changes:
'     Convert COMMAND$ Switches to lower-case!
'---------------------

DEFINT A-Z
FALSE = 0 : TRUE = NOT FALSE

'          ---  REMOVE LEADING AND TRAILING SPACES
DEF FNTrim$(x$)
    WHILE LEFT$(x$,1)=" "
        x$=MID$(x$,2)
	WEND
    WHILE RIGHT$(x$,1)=" "
        x$=LEFT$(x$,LEN(x$)-1)
	WEND
    FNTrim$=x$
END DEF

'       --- Convert from a number to a trimmed string in one step.
DEF FNN2S$(n) = FNTrim$(STR$(n))

'          ---  Convert string to lower case
DEF FNLower$(X$)
    STATIC A$,I%
    IF LEN(X$) >0 THEN
        FOR I% = 1 TO LEN(X$)
            A$ = MID$(X$,I%,1)
            IF A$ >= "A" AND A$ <= "Z" THEN_
                MID$(X$,I%,1) = CHR$(ASC(A$)+32)
        NEXT I%
	END IF
	FNLower$ = X$
END DEF


CLS
CMD$=FNTrim$(COMMAND$)
ASPACE = INSTR(CMD$," ")
IF ASPACE THEN
    DATAFILE$ = LEFT$(CMD$,ASPACE-1)
    SWITCH$=FNLower$(FNTrim$(MID$(CMD$,ASPACE+1)))
ELSE
    DATAFILE$=CMD$
    SWITCH$= "dkbno87 -p -a -v +d"
END IF

IF DATAFILE$="" THEN
    LOCATE 1,1 : PRINT "SPLITDKB creates batchfiles for running a DKB script on multiple"
	LOCATE 2,1 : PRINT "computers."
    LOCATE 3,1 : PRINT "USAGE: SPLITDKB datafile[.dat] [switch string]"
	LOCATE 4,1 : PRINT "       Default switches are : DKBNO87 -p -a -v +d"
	LOCATE 5,1 : PRINT "To specify where to send the output files, SET GLUE=directory."
	LOCATE 6,1 : PRINT "To specify where to get the data file, SET DATA=directory."
	SYSTEM                            ' END
ELSE
    LOCATE 1,1 : PRINT "SPLITDKB: Create batchfiles for running " + DATAFILE$ + ".DAT"
END IF
' GET THE DIRECTORYS FROM THE ENVIRONMENT VARIABLE "GLUE"
GLUEDIR$ = FNTrim$(ENVIRON$("GLUE"))  ' Where to put the OUTPUT files.
DATADIR$ = FNTrim$(ENVIRON$("DATA"))  ' Where to get the INPUT file.

' Add trailing backslashes, if any
IF GLUEDIR$ <> "" THEN
    IF RIGHT$(GLUEDIR$,1) <> "\" THEN GLUEDIR$=GLUEDIR$ + "\"
END IF
IF DATADIR$ <> "" THEN
    IF RIGHT$(DATADIR$,1) <> "\" THEN DATADIR$=DATADIR$ + "\"
END IF

LOCATE 3,1 : PRINT "Glue Directory = " + GLUEDIR$
LOCATE 4,1 : PRINT "Data Dirctory = " + DATADIR$

' Trim extension if provided...
ADOT = INSTR(DATAFILE$,".")
IF NOT ADOT THEN ROOT$ = DATAFILE$: DATAFILE$ = DATAFILE$ + ".DAT"
IF ADOT THEN ROOT$ = LEFT$(DATAFILE$,ADOT-1)


LOCATE 6,1 : PRINT "Number of cols [320]"
LOCATE 7,1 : PRINT "Number of rows [200]"
LOCATE 8,1 : PRINT "How many parts? [1] (max=9) "

LOCATE 6,22: INPUT COLS
IF COLS  = 0 THEN COLS  = 320

NEWROWS$ = FNN2S$(COLS*0.625)
LOCATE 7,1: PRINT SPACE$(80);
LOCATE 7,1 : PRINT "Number of rows ["+NEWROWS$+"]"
LOCATE 7,22: INPUT ROWS
IF ROWS  = 0 THEN ROWS  = VAL(NEWROWS$)


LOCATE 8,31: INPUT PARTS
IF PARTS = 0 THEN PARTS =   1
IF PARTS > 9 THEN PARTS = 9 ' Avoid overflow of some of the PRINT USING formats

COLS$  = " -w"+FNN2S$(COLS)
ROWS$  = " -h"+FNN2S$(ROWS)
PARTS$ = FNN2S$(PARTS)

START.ROW = 0
END.ROW   = 0
ABLOCK    = ROWS/PARTS
LASTROW   = ROWS        ' LAST BATCH FILE FINISHES
DATAFILE$ = " -i" + DATADIR$ + DATAFILE$

FOR I = 1 TO PARTS
	START.ROW = END.ROW
    IF I < PARTS THEN END.ROW = END.ROW + ABLOCK ELSE END.ROW = LASTROW

	BATCHFILE.NAME$ ="PART"+FNN2S$(I)+".BAT"       ' PART1.BAT, etc.
    PRINT "Writing " + BATCHFILE.NAME$
    CLOSE #1: OPEN BATCHFILE.NAME$ FOR OUTPUT AS #1
    TGA$="PART"+FNN2S$(I)+".TGA"
    START$ = " -s" + FNN2S$(START.ROW)
    END$   = " -e" + FNN2S$(END.ROW)

    PRINT #1, "rem " + BATCHFILE.NAME$
    PRINT #1, SWITCH$ + ROWS$ + COLS$ + DATAFILE$ + " -o" + GLUEDIR$ + TGA$ + START$ + END$
    PRINT #1, USING "ECHO Done. > TGA#DONE.FLG";I
	IF END.ROW = LASTROW THEN
        IF GLUEDIR$ <> "" THEN PRINT #1, "CD " + MID$(GLUEDIR$,1,LEN(GLUEDIR$)-1)
        PRINT #1, "CALL " + GLUEDIR$ +"GLUE.BAT"
    END IF

NEXT I

' Now, write GLUE.BAT to put all the pieces back together
PRINT "Writing " + GLUEDIR$ + "GLUE.DAT"
CLOSE #1 : OPEN GLUEDIR$ + "GLUE.BAT" FOR OUTPUT AS #1
    PRINT #1, "@ECHO OFF"
    PRINT #1,":WAIT"
    PRINT #1,"ECHO Waiting for all parts to finish..."
    FOR I = 1 TO PARTS
        PRINT #1, USING "IF NOT EXIST TGA#DONE.FLG GOTO WAIT";I
    NEXT I

	IF PARTS > 1 THEN
        PRINT #1, "IF EXIST GLUETGA.EXE GLUETGA "+ ROOT$;
        FOR I = 1 TO PARTS
            PRINT #1, USING " PART#.TGA";I;
        NEXT I
    ELSE
        PRINT #1, "COPY PART1.TGA " + ROOT$ + ".TGA"
    END IF

	PRINT #1,""
    PRINT #1, "IF EXIST PROCESS.BAT CALL PROCESS.BAT " + ROOT$
    FOR I = 1 TO PARTS
        PRINT #1, USING "DEL TGA#DONE.FLG";I
		PRINT #1, USING "DEL PART#.TGA";I
    NEXT I
    IF GLUEDIR$ <> "" THEN PRINT #1, "CD.."
    PRINT #1, "ECHO " + CHR$(7)
    PRINT #1, "EXIT"
CLOSE #1
END
