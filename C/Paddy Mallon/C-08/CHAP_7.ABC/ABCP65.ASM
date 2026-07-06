*/*  ABC p65  eg 7.3                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP65 GST QC Compiler 15:38 Saturday  06/12/86 
        OPT ABS
*/*    fill array with spaces       */
*/*    only one dimensional arrays implemented in GST C.          */
*/*    This can be overcome using an index into the table(letter)
*      with an offset following it ie.  index[row][col]           */
*/*    tested and working    5/12/86                              */
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
**#define ROWMAX 7
*#define COLMAX 5
*
*int ticks = 200;
        SECTION S.GLOB

        XDEF    TICKS
TICKS:
        DC.L    200
*char  *index[ROWMAX];

        XDEF    INDEX
INDEX:
        DC.L    0,0,0,0,0,0,0
*/* This will not work in GST C
*               char letter[ROWMAX][COLMAX];
**/
*char letter[35];

        XDEF    LETTER
LETTER:
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0
*
*main()
        DS.W    0
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*     int row,col;
*
*/* ****** must add this to simulate 2 dim array***********************/
*
*     int i;
*     for (i=0; i<ROWMAX; i++)
C.3     EQU     12
        MOVE.L  D7,A0
        MOVE.L  A0,-12(A6)
C.6:
        MOVE.L  -12(A6),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.5
        BRA     C.7
C.4:
        MOVE.L  -12(A6),A0
        ADDQ.L  #1,-12(A6)
        BRA     C.6
C.7:
*          index[i]=&letter[COLMAX*i];
        XREF    C.MULT
        LEA     INDEX-G$(A5),A1
        MOVE.L  -12(A6),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        PEA     LETTER-G$(A5)
        MOVE.L  -12(A6),A0
        LEA     5,A1
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  (SP)+,A1
        MOVE.L  A0,(A1)
        BRA     C.4
C.5:
*
*/******* array can now be accessed using:      index[a][b]; **********/
*
*          for (row= 0;row<ROWMAX;row++)
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
C.10:
        MOVE.L  -4(A6),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.9
        BRA     C.11
C.8:
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.10
C.11:
*               for (col=0;col<COLMAX;col++) index[row][col]='z';
        MOVE.L  D7,A0
        MOVE.L  A0,-8(A6)
C.14:
        MOVE.L  -8(A6),A1
        LEA     5,A0
        CMP.L   A0,A1
        BGE     C.13
        BRA     C.15
C.12:
        MOVE.L  -8(A6),A0
        ADDQ.L  #1,-8(A6)
        BRA     C.14
C.15:
        LEA     INDEX-G$(A5),A1
        MOVE.L  -4(A6),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  -8(A6),A0
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        LEA     122,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.12
C.13:
        BRA     C.8
C.9:
*
*          for (row=0;row<ROWMAX;row++) 
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
C.18:
        MOVE.L  -4(A6),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.17
        BRA     C.19
C.16:
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.18
C.19:
*            { 
*               for (col=0;col<COLMAX;printf("%c",index[row][col++]));
        MOVE.L  D7,A0
        MOVE.L  A0,-8(A6)
C.22:
        MOVE.L  -8(A6),A1
        LEA     5,A0
        CMP.L   A0,A1
        BGE     C.21
        BRA     C.23
C.20:
        PEA     C.2+0(PC)
        LEA     INDEX-G$(A5),A1
        MOVE.L  -4(A6),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  -8(A6),A0
        ADDQ.L  #1,-8(A6)
        ADD.L   A1,A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.22
C.23:
        BRA     C.20
C.21:
*               printf("\n");
        PEA     C.2+3(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*           
*            }
        BRA     C.16
C.17:
*          printf("x\n");
        PEA     C.2+5(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    37,99,0,10,0,120,10,0
*
        XREF    DELAY
        XREF    PRINTF
        END
