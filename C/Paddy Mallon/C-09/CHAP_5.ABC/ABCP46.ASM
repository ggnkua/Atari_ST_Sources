*/*   ABC p46  eg 5.1                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP46 GST QC Compiler 19:36 Wednesday 03/12/86 
        OPT ABS
*/*   loops                          */ 
*/*     tested & working 24/11/86    */
*
*
*
*
*#include <stdio.h>
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
**int ticks = 200;
        SECTION S.GLOB

        XDEF    TICKS
TICKS:
        DC.L    200
*
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*     int kount;
*     char ch;
*     
*     
*       printf("kount = %d\n",counter());   
C.3     EQU     6
        PEA     C.2+0(PC)
        MOVEQ   #0,D2
        JSR     COUNTER-M$(A4)
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    107,111,117,110,116,32,61,32,37,100
        DC.B    10,0
*
*counter()
        DS.W    0

        XDEF    COUNTER
COUNTER:
*     {    char ch;
        LINK    A6,#-C.5
*          int count = 0;
        MOVE.L  D7,A0
        MOVE.L  A0,-6(A6)
*
*          while((ch=getchar()) != '\n') count++;
C.5     EQU     6
C.6:
        MOVEQ   #0,D2
        JSR     GETCHAR-M$(A4)
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        LEA     10,A1
        CMP.L   A0,A1
        BEQ     C.7
        MOVE.L  -6(A6),A0
        ADDQ.L  #1,-6(A6)
        BRA     C.6
C.7:
*          return(count);
        MOVE.L  -6(A6),A0
        UNLK    A6
        RTS
*     }
*
*
        XREF    DELAY
        XREF    PRINTF
        XREF    GETCHAR
        END
