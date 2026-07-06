*/*  ABC p41   eg 4.2               */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP41 GST QC Compiler 23:45 Tuesday   02/12/86 
        OPT ABS
*/* grade using if--then--else      */
*/* tested and working 23/11/86     */
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
*     int reply;
*     char let;
*          printf("gimme a number..(0-100)...");
C.3     EQU     6
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          scanf("%2d",&reply); printf("%2d\n",reply);
        PEA     C.2+27(PC)
        PEA     -4(A6)
        MOVEQ   #2,D2
        JSR     SCANF-M$(A4)
        ADDQ.L  #8,SP
        PEA     C.2+31(PC)
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          let = grade(reply);
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #1,D2
        JSR     GRADE-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,D0
        MOVE.B  D0,-5(A6)
*          printf("grade is ..%c\n",let);
        PEA     C.2+36(PC)
        MOVE.B  -5(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          printf("finished\n");
        PEA     C.2+51(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    103,105,109,109,101,32,97,32,110,117
        DC.B    109,98,101,114,46,46,40,48,45,49
        DC.B    48,48,41,46,46,46,0,37,50,100
        DC.B    0,37,50,100,10,0,103,114,97,100
        DC.B    101,32,105,115,32,46,46,37,99,10
        DC.B    0,102,105,110,105,115,104,101,100,10
        DC.B    0
*
*grade(mark)
        DS.W    0

        XDEF    GRADE
GRADE:
*     int mark;
*     {
        LINK    A6,#-C.5
*          char g ;
*          if (mark<0) g = NULL;
C.5     EQU     2
        TST.L   8(A6)
        BGE     C.6
        MOVE.L  D7,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  if (mark<20)  g = 'e';
        BRA     C.7
C.6:
        MOVE.L  8(A6),A1
        LEA     20,A0
        CMP.L   A0,A1
        BGE     C.8
        LEA     101,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  if (mark<40)  g = 'd';
        BRA     C.9
C.8:
        MOVE.L  8(A6),A1
        LEA     40,A0
        CMP.L   A0,A1
        BGE     C.10
        LEA     100,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  if (mark<60)  g = 'c';
        BRA     C.11
C.10:
        MOVE.L  8(A6),A1
        LEA     60,A0
        CMP.L   A0,A1
        BGE     C.12
        LEA     99,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  if (mark<80)  g = 'b';
        BRA     C.13
C.12:
        MOVE.L  8(A6),A1
        LEA     80,A0
        CMP.L   A0,A1
        BGE     C.14
        LEA     98,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  if (mark<100) g = 'a';
        BRA     C.15
C.14:
        MOVE.L  8(A6),A1
        LEA     100,A0
        CMP.L   A0,A1
        BGE     C.16
        LEA     97,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*          else  g = NULL;
        BRA     C.17
C.16:
        MOVE.L  D7,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
C.17:
C.15:
C.13:
C.11:
C.9:
C.7:
*          return(g);
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        UNLK    A6
        RTS
*     }
*
        XREF    DELAY
        XREF    PRINTF
        XREF    SCANF
        END
