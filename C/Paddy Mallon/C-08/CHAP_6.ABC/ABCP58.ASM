*/*  ABC p58 ex 6.2                    */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP58 GST QC Compiler 16:19 Saturday  06/12/86 
        OPT ABS
*/*  pseudo random numbers             */
*/*  tested and working 29/11/86       */
*
*#define MAXINT 32767
*#define PSHIFT 4
*#define QSHIFT 11
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
*static int n=1;

N:
        DC.L    1
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {    int k= 200,i;
        LINK    A6,#-C.3
        LEA     200,A0
        MOVE.L  A0,-4(A6)
*        for (i=0;i<10;i++)
C.3     EQU     8
        MOVE.L  D7,A0
        MOVE.L  A0,-8(A6)
C.6:
        MOVE.L  -8(A6),A1
        LEA     10,A0
        CMP.L   A0,A1
        BGE     C.5
        BRA     C.7
C.4:
        MOVE.L  -8(A6),A0
        ADDQ.L  #1,-8(A6)
        BRA     C.6
C.7:
*          {  
*            printf("number = %3d\n",random(200));
        PEA     C.2+0(PC)
        PEA     200
        MOVEQ   #1,D2
        JSR     RANDOM-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          }
        BRA     C.4
C.5:
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    110,117,109,98,101,114,32,61,32,37
        DC.B    51,100,10,0
*
*random(range)
        DS.W    0

        XDEF    RANDOM
RANDOM:
*     int range;
*         
*     {
        LINK    A6,#-C.9
*/*          static int n=1;       */
*          
*          n=n^n>>PSHIFT;
C.9     EQU     0
        XREF    C.ASR
        XREF    C.XOR
        MOVE.L  N-G$(A5),-(SP)
        MOVE.L  N-G$(A5),A1
        LEA     4,A0
        JSR     C.ASR-M$(A4)
        MOVE.L  (SP)+,A1
        JSR     C.XOR-M$(A4)
        MOVE.L  A0,N-G$(A5)
*          n=(n^n<<QSHIFT)&MAXINT;
        XREF    C.ASL
        XREF    C.AND
        MOVE.L  N-G$(A5),-(SP)
        MOVE.L  N-G$(A5),A1
        LEA     11,A0
        JSR     C.ASL-M$(A4)
        MOVE.L  (SP)+,A1
        JSR     C.XOR-M$(A4)
        LEA     32767,A1
        JSR     C.AND-M$(A4)
        MOVE.L  A0,N-G$(A5)
*
*          return(n%(range+1));
        XREF    C.DIV
        MOVE.L  N-G$(A5),-(SP)
        MOVE.L  8(A6),A0
        MOVE.L  D6,A1
        ADD.L   A1,A0
        MOVE.L  (SP)+,A1
        JSR     C.DIV-M$(A4)
        MOVE.L  A1,A0   ;
        UNLK    A6
        RTS
*     }
*
        XREF    DELAY
        XREF    PRINTF
        END
