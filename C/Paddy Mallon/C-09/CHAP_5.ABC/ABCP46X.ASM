*/*  ABC p46                    */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP46X GST QC Compiler 19:41 Wednesday 03/12/86 
        OPT ABS
*/*  operators  ++ and  !       */
*/*  works ok  24/11/86         */
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
*     int count;
*     char ch;
*     
*          count = 0;
C.3     EQU     6
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
*          ch = getchar();
        MOVEQ   #0,D2
        JSR     GETCHAR-M$(A4)
        MOVE.L  A0,D0
        MOVE.B  D0,-5(A6)
*          while ( ch!='\n')
C.4:
        MOVE.B  -5(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     10,A1
        CMP.L   A0,A1
        BEQ     C.5
*               { 
*                    count++;
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
*                    ch = getchar();
        MOVEQ   #0,D2
        JSR     GETCHAR-M$(A4)
        MOVE.L  A0,D0
        MOVE.B  D0,-5(A6)
*               }
        BRA     C.4
C.5:
*       printf("count = %d\n",count);   
        PEA     C.2+0(PC)
        MOVE.L  -4(A6),-(SP)
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
C.2:    DC.B    99,111,117,110,116,32,61,32,37,100
        DC.B    10,0
*
*
*
        XREF    DELAY
        XREF    PRINTF
        XREF    GETCHAR
        END
