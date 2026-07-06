*/*  ABC p12  -   main() and #define
*                    delay() is used to pause the display.  
*                            a count of 60 is approx. 1 second.    */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP12 GST QC Compiler 20:26 Sunday    30/11/86 
        OPT ABS
*
*     #include stdio.h
*/*--------------------------------------------------------------------+
*|                                                                     |
*|    STDIO.H - Standard I/O Definitions Header File for Atari ST      |
*|                                                                     |
*+--------------------------------------------------------------------*/
*
        XREF    STDIN
        XREF    STDOUT
        XREF    STDERR
*
**     #define STARS printf("*****************\n")
*     main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*          {    int ticks = 200;
        LINK    A6,#-C.3
        LEA     200,A0
        MOVE.L  A0,-4(A6)
*               STARS;
C.3     EQU     4
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("the answer is 42\n");
        PEA     C.2+19(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               STARS;
        PEA     C.2+37(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*
*               delay(ticks);
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*          }
        UNLK    A6
        RTS
C.2:    DC.B    42,42,42,42,42,42,42,42,42,42
        DC.B    42,42,42,42,42,42,42,10,0,116
        DC.B    104,101,32,97,110,115,119,101,114,32
        DC.B    105,115,32,52,50,10,0,42,42,42
        DC.B    42,42,42,42,42,42,42,42,42,42
        DC.B    42,42,42,42,10,0
*
*
*
*
        XREF    DELAY
        XREF    PRINTF
        END
