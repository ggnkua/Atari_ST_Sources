'------------------ USER-DEFINED FUNCTIONS
DEF FNLTRIM$(X$)
    WHILE LEFT$(X$,1)=SPACE$(1)
        X$=MID$(X$,2)
    WEND
    FNLTRIM$=X$
END DEF
DEF FNRTRIM$(X$)
    WHILE RIGHT$(X$,1)=SPACE$(1)
        X$=LEFT$(X$,LEN(X$)-1)
    WEND
    FNRTRIM$=X$
END DEF

DEF FNTRIM$(X$)=FNLTRIM$(FNRTRIM$(X$))

DEF FNWORD$(X$)
    ASPACE=INSTR(X$,SPACE$(1))
    IF ASPACE > 0 THEN
        FNWORD$=LEFT$(X$,ASPACE-1)
    ELSE
        FNWORD$=X$
    END IF
END DEF

'          ---  FORMAT A NUMERIC STRING
DEF FNFMT$ (A#)
    FORM$="-####.#"
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
