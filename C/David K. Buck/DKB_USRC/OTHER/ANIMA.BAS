' Program: ANIMA.BAS
' By: Dan Farmer
' Function: Create a sequence of DKB Raytracer script files by replacing
'           tokens in a skeleton file with incremented values specified
'           in a rules list.
'


COMMON SHARED DEBUG,MAX.LINE.LEN
FALSE=0 : TRUE = NOT FALSE
'DEBUG = TRUE
MAX.LINE.LEN = 80
MAXPARMS = 9                           ' Allow 9 replaceable tokens
MAXCODE = 200                          ' Lines of skeleton code allowed.
REM $INCLUDE: 'ANIMA.INC'               ' LOAD UDFs (trim, pad, etc.)


' Get the root filename from the command line, display usage if no command$
ROOT$=FNTRIM$(COMMAND$)
IF ROOT$="" THEN
    PRINT "ANIMATE By Dan Farmer"
    PRINT "    Usage:"
    PRINT "        ANIMATE filename[.DAT]"
    PRINT "        Where filename is the 5 letter name of the input script"
    PRINT "        file and the root of the numbered output file."
    PRINT "    Example: ANIMATE ANIMA reads file ANIMA.DAT and creates DKB scripts"
    PRINT "             named ANIMA001.DAT, ANIMA002.DAT, etc.
    SYSTEM
END IF


MAIN:

' Dimension 2 arrays, RULES$(2) dimensioned to hold 2 values for MAXPARMS
'  replaceable parameters, and CODE$(1), dimensioned to buffer MAXCODE
'  lines of code.
    DIM RULES$(MAXPARMS,2) :  DIM CODE$(MAXCODE)

' Initialize indices to the RULE$() array structure
    VALUE=1 : JUMP=2 :

' Parse root name of input file, trimming extension if neccessary.
    IF INSTR(ROOT$,".") THEN ROOT$ = LEFT$(ROOT$,INSTR(ROOT$,".")-1)
    INFILE$=ROOT$+".DAT"
    PRINT "Opening skeleton file ";INFILE$
    OPEN INFILE$ FOR INPUT AS #1               ' OPEN INPUT FILE

' Read number of iterations to perform from 1st line of input file
    A$=""
    WHILE FNTRIM$(A$)=""               ' Skip over blank lines
        LINE INPUT #1, A$
    WEND
    ITERS = VAL(FNTRIM$(MID$(A$,INSTR(A$,"=")+1)))
    IF ITERS = 0 THEN
        CLS
        PRINT "ERROR: Number of iterations was not specified"
        PRINT "       or was specified incorrectly."
        CLOSE
        SYSTEM
    END IF


' Input until we come to the block named "RULES:"
    CALL GET.BLOCK.NAMED(1%,A$,"RULES:")


' Input until we come to the block named "END_RULES:" and parse out the
' values of the rules.  The values come in two flavors: the starting value
' for this particular parameter, and the step rate for it to increase or
' decrease at.
    RULE.COUNT=0
    WHILE FNTRIM$(A$) <> "END_RULES:"
        IF A$ <> "" AND A$ <> "END_RULES:" THEN

            ' Trim any comments from the string
            COMMENT = INSTR(A$,"{")
            IF COMMENT THEN
                A$=LEFT$(A$,COMMENT-1)   ' Trim to the left of the { character.
            END IF

            ' Find initial value for this RP (Default is 1 if not specified)
            TOKEN = INSTR(A$,"=")
            IF TOKEN  THEN
                RULE.COUNT=RULE.COUNT+1
                RULES$(RULE.COUNT,VALUE)=FNWORD$(FNLTRIM$(MID$(A$,TOKEN+1)))
            ELSE
                RULES$(RULE.COUNT,VALUE)="1"
            END IF

            ' Find the step rate for this RP (Default is 1 if not specified)
            ' Token separator is the $ sign. ( Single characters are easy to
            ' parse because you only need to use the INSTR function.)
            TOKEN = INSTR(A$,"$")
            IF TOKEN THEN
                RULES$(RULE.COUNT,JUMP)=FNWORD$(FNLTRIM$(MID$(A$,TOKEN+1)))
            ELSE
                RULES$(RULE.COUNT,JUMP)="1"
            END IF

        END IF
        LINE INPUT #1, A$
    WEND      ' end of input rules routine


    ' Now, input and buffer the skeleton code block into the CODE$ array.
    CODE.LINES=0
    CALL GET.BLOCK.NAMED(1%,A$,"SKELETON:")

    ' Input until end of skeleton block label is found
    WHILE FNTRIM$(A$) <> "END_SKELETON:"
        IF A$ > "" THEN                ' Skip blank lines
            CODE.LINES=CODE.LINES+1    ' Keep track of how many lines of code
            CODE$(CODE.LINES)=A$       ' Buffer the code in CODE$() array.
        END IF
        LINE INPUT #1, A$
    WEND

' This is where we actually write out each DKB script file called for by
' the memvar ITERS.
FOR J = 1 TO ITERS

    ' Increment the filename counter (ANIMA001.DAT ANIMA002.DAT, etc)

    ITER$=RIGHT$("000"+FNLTRIM$(STR$(J)),3)    ' Zero pad the filename counter
    OUTFILE$=LEFT$(ROOT$,4)+ITER$+".DAT"       ' Append the counter to root
    CLOSE #2 : OPEN OUTFILE$ FOR OUTPUT AS #2  ' open new output file
    PRINT "Creating file " ;OUTFILE$


    ' For the 1st created file only, write the rules used out for future
    ' reference.  No sense writing copies to all files, though.

    IF J = 1 THEN
        ' First, print the rules given...
        PRINT #2,"{ Rules used for this animation:"
        PRINT #2,"        Iterations = ";ITERS
        FOR I = 1 TO RULE.COUNT
            PRINT #2,"        Increment %";FNLTRIM$(STR$(I));
            PRINT #2," starting at "; RULES$(I,VALUE);" in steps of ";
            PRINT #2,RULES$(I,JUMP)
        NEXT I
        ' Next print the actual skeleton code that was used.
        PRINT #2, " The skelton code used :"
        FOR I=1 TO CODE.LINES
            PRINT #2,CODE$(I)
        NEXT I
        PRINT #2,"*** end of skeleton code *** }"
    END IF


    ' Replace parameter tokens with actual values and write the skeleton
    ' code out with the new values plugged in.

    FOR I = 1 TO CODE.LINES        ' Loop for each line in CODE$()
        TEMP$=CODE$(I)             ' Copy this line of code to a work string
        TOKEN = 0                  ' Initialize a pointer to token in TEMP$

        DO WHILE INSTR(TEMP$,"%") > 0  ' Loop for each token in the line
            TOKEN=INSTR(TEMP$,"%")     ' Locate position of token in string

            IF TOKEN > 0 THEN          ' If a token was indeed found,

                ' The next line uses the value of the replaceable token
                ' as an index to the RULES$() array (%1 points to RULE$(1,n)
                INDEX=VAL(MID$(TEMP$,TOKEN+1,1))

                ' ---  Get value from RULES$() array
                VAL$=FNLTRIM$(FNFMT$(VAL(RULES$(INDEX,VALUE))))

        ' ---  Replace all occurances of this parameter with value
                CALL REPLACE("%"+FNLTRIM$(STR$(INDEX)),VAL$,TEMP$)

            END IF  ' token was found
        LOOP        ' while another token in this line

        IF DEBUG THEN PRINT TEMP$      ' Show me what I just did
        PRINT #2, TEMP$                ' Write this line to the output file.
    NEXT I                             ' Next line of skeleton code

    ' --- Increment value in RULES$ array for all replaceable tokens.
    FOR I = 1 TO MAXPARMS
        IF RULES$(I,VALUE) > "" THEN
            NEW.VAL = VAL(RULES$(I,VALUE)) + VAL(RULES$(I,JUMP))
            RULES$(I,VALUE)=STR$(NEW.VAL)
        END IF
    NEXT I


    IF DEBUG THEN
        PRINT "Press any key"
        WHILE INKEY$="":WEND
    END IF
NEXT J                                 ' Next output file


' --- Replace all occurances of FIND$ with REPL$ in TARGET$
'
SUB REPLACE(FIND$,REPL$,TARGET$) STATIC
    FOR I = 1 TO 80' LEN(TARGET$)
        IF MID$(TARGET$,I,2) = FIND$ THEN
            TARGET$=LEFT$(TARGET$,I-1)+REPL$+MID$(TARGET$,I+2)
        END IF
    NEXT I
END SUB

'===============================
' Reads from Fileno and discards input until TOKEN is found.
SUB GET.BLOCK.NAMED (FILENO%,X$,TOKEN$) STATIC
    WHILE FNTRIM$(X$) <> TOKEN$
        LINE INPUT #FILENO%, X$
    WEND
    X$=""
END SUB
