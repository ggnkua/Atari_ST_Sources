*/*  ABC p42     eg 4.3             */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP42 GST QC Compiler 23:51 Tuesday   02/12/86 
        OPT ABS
*/*  switch                         */
*/*  tested and works  23/11/86     */
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
*          printf("grade is ..%c\n",grade(reply));
        PEA     C.2+36(PC)
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #1,D2
        JSR     GRADE-M$(A4)
        ADDQ.L  #4,SP
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
*          switch(mark/20)
C.5     EQU     2
        XREF    C.DIV
        MOVE.L  8(A6),A1
        LEA     20,A0
        JSR     C.DIV-M$(A4)
        BRA     C.8
*               {
*                   case 0:  g = 'e'; break;
C.9:
        LEA     101,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.7
*                   case 1:  g = 'd'; break;
C.10:
        LEA     100,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.7
*                   case 2:  g = 'c'; break;
C.11:
        LEA     99,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.7
*                   case 3:  g = 'b'; break;
C.12:
        LEA     98,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.7
*                   case 4:  g = 'a'; break;
C.13:
        LEA     97,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.7
*               }
        BRA     C.7
C.8:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.9-*,0
        DC.L    C.10-*,1
        DC.L    C.11-*,2
        DC.L    C.12-*,3
        DC.L    C.13-*,4
        DC.L    0
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
