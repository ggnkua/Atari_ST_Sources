***************************************
*       Display a directory listing   *
*       By R.A.Waddilove              *
*       (c) Atari ST User             *
***************************************

* Get the current DTA pointer and save it
        MOVE #47,-(A7)          f_getdta - get old DTA
        TRAP #1                 GEMDOS
        ADDQ.L #2,A7            tidy stack
        LEA olddta(PC),A0       A0 points to olddta
        MOVE.L D0,(A0)          save old DTA pointer

* Set the DTA pointer to my buffer
        PEA dta(PC)             set my DTA buffer
        MOVE #26,-(A7)          f_setdta
        TRAP #1                 GEMDOS
        ADDQ.L #6,A7            tidy stack

* Read the first file in the directory
        MOVE #0,-(A7)           normal read/write files
        PEA fname(PC)           filespec - "*.*"
        MOVE #78,-(A7)          f_sfirst
        TRAP #1                 GEMDOS
        ADDQ.L #8,A7            tidy stack
        BSR print               print filename

* Repeatedly read the next one until no more left
loop    MOVE #79,-(A7)          f_snext - get next file
        TRAP #1                 GEMDOS
        ADDQ.L #2,A7            tidy stack
        TST D0                  D0<>0 means no more files
        BNE exit                exit if no more
        BSR print               print filename
        BRA loop                loop round again

* Restore the original DTA pointer
exit    MOVE.L dta(PC),-(A7)    restore old DTA pointer
        MOVE #26,-(A7)          f_setdta
        TRAP #1                 GEMDOS
        ADDQ.L #6,A7            tidy stack

* Wait for a key to be pressed
        MOVE #8,-(A7)           wait for keypress
        TRAP #1                 GEMDOS
        ADDQ.L #2,A7            tidy stack

* Return to the desktop
        CLR -(A7)               p_term0 - exit to desktop
        TRAP #1                 GEMDOS

***************************************
* Subroutine to print filename in DTA *
*     buffer starting at byte 30      *
***************************************
print   LEA dta(PC),A6          A6 --> my DTA buffer
        ADDA.L #30,A6           A6 --> to filename
        CLR D7
ploop   MOVE.B (A6)+,D7         get character
        BEQ crlf                0 = end of name marker
        MOVE D7,-(A7)           print it
        MOVE #2,-(A7)           c_conout
        TRAP #1                 GEMDOS
        ADDQ.L #4,A7            tidy stack
        BRA ploop               another letter?
crlf    MOVE #13,-(A7)          print CR
        MOVE #2,-(A7)
        TRAP #1
        ADDQ.L #4,A7
        MOVE #10,-(A7)          print LF
        MOVE #2,-(A7)
        TRAP #1
        ADDQ.L #4,A7
        RTS

olddta  DC.L 0                  store old DTA pointer
dta     DS.B 46                 DTA buffer
fname   DC.B '*.*',0            filespec to search for
        EVEN

