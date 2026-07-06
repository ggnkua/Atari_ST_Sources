*/*   ABC p50                      */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP50 GST QC Compiler 20:15 Wednesday 03/12/86 
        OPT ABS
*/*   for loop                     */
*/*   works ok 27/11/86            */
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
*int sum,n,i;

        XDEF    SUM
SUM:
        DC.L    0

        XDEF    N
N:
        DC.L    0

        XDEF    I
I:
        DC.L    0
*
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {sum=0,n=20;
        LINK    A6,#-C.3
C.3     EQU     0
        MOVE.L  D7,A0
        MOVE.L  A0,SUM-G$(A5)
        LEA     20,A0
        MOVE.L  A0,N-G$(A5)
*         for (i = 1;i<=n;i++)sum=sum+i;
        MOVE.L  D6,A0
        MOVE.L  A0,I-G$(A5)
C.6:
        MOVE.L  I-G$(A5),A1
        MOVE.L  N-G$(A5),A0
        CMP.L   A0,A1
        BGT     C.5
        BRA     C.7
C.4:
        MOVE.L  I-G$(A5),A0
        ADDQ.L  #1,I-G$(A5)
        BRA     C.6
C.7:
        MOVE.L  SUM-G$(A5),A1
        MOVE.L  I-G$(A5),A0
        ADD.L   A1,A0
        MOVE.L  A0,SUM-G$(A5)
        BRA     C.4
C.5:
*         printf("answer = %3d\n",sum);
        PEA     C.2+0(PC)
        MOVE.L  SUM-G$(A5),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*
*     sum=0;
        MOVE.L  D7,A0
        MOVE.L  A0,SUM-G$(A5)
*     for(i=n;i>=1;i--)sum+=i;
        MOVE.L  N-G$(A5),A0
        MOVE.L  A0,I-G$(A5)
C.10:
        MOVE.L  I-G$(A5),A1
        MOVE.L  D6,A0
        CMP.L   A0,A1
        BLT     C.9
        BRA     C.11
C.8:
        MOVE.L  I-G$(A5),A0
        SUBQ.L  #1,I-G$(A5)
        BRA     C.10
C.11:
        MOVE.L  SUM-G$(A5),A1
        MOVE.L  I-G$(A5),A0
        ADD.L   A1,A0
        MOVE.L  A0,SUM-G$(A5)
        BRA     C.8
C.9:
*         printf("answer 2 = %3d\n",sum);
        PEA     C.2+14(PC)
        MOVE.L  SUM-G$(A5),-(SP)
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
C.2:    DC.B    97,110,115,119,101,114,32,61,32,37
        DC.B    51,100,10,0,97,110,115,119,101,114
        DC.B    32,50,32,61,32,37,51,100,10,0
*
        XREF    DELAY
        XREF    PRINTF
        END
