*/*  ABC p66  eg 7.4                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP66X GST QC Compiler 11:37 Sunday    07/12/86 
        OPT ABS
*/*    arrays as parameters         */
*/*    This program had to be changed to implement the 2 dimensional
*      array - as this cannot be passed as a parameter in GST C , I 
*      have passed an array of pointers to the single dimension array
*      "letter[]" . This index can then be used with offsets to simulate
*      a 2 dimensional array.                                           */
*/*   Tested and working 7/12/86    */
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
**#define ROWMAX 7
*#define COLMAX 5
*
*int ticks = 200;
        SECTION S.GLOB

        XDEF    TICKS
TICKS:
        DC.L    200
*/* char letter[ROWMAX][COLMAX]; This cannot be used   */
*int row,col;

        XDEF    ROW
ROW:
        DC.L    0

        XDEF    COL
COL:
        DC.L    0
*char *index[ROWMAX];

        XDEF    INDEX
INDEX:
        DC.L    0,0,0,0,0,0,0
*char letter[36];

        XDEF    LETTER
LETTER:
        DC.B    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0,0,0
*
*main()
        DS.W    0
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*/* *******must add this to simulate 2 dim array***********************/
*   
*     int i;
*     for (i=0; i<ROWMAX; i++) index[i]=&letter[COLMAX*i];
C.3     EQU     4
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
C.6:
        MOVE.L  -4(A6),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.5
        BRA     C.7
C.4:
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.6
C.7:
        XREF    C.MULT
        LEA     INDEX-G$(A5),A1
        MOVE.L  -4(A6),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        PEA     LETTER-G$(A5)
        MOVE.L  -4(A6),A0
        LEA     5,A1
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  (SP)+,A1
        MOVE.L  A0,(A1)
        BRA     C.4
C.5:
*
*/*********************************************************************/
*/*   fill the array with spaces                                      */
*
*     for (row=0;row<ROWMAX;row++)
        MOVE.L  D7,A0
        MOVE.L  A0,ROW-G$(A5)
C.10:
        MOVE.L  ROW-G$(A5),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.9
        BRA     C.11
C.8:
        MOVE.L  ROW-G$(A5),A0
        ADDQ.L  #1,ROW-G$(A5)
        BRA     C.10
C.11:
*          for(col=0;col<COLMAX;index[row][col++]=' ');
        MOVE.L  D7,A0
        MOVE.L  A0,COL-G$(A5)
C.14:
        MOVE.L  COL-G$(A5),A1
        LEA     5,A0
        CMP.L   A0,A1
        BGE     C.13
        BRA     C.15
C.12:
        LEA     INDEX-G$(A5),A1
        MOVE.L  ROW-G$(A5),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  COL-G$(A5),A0
        ADDQ.L  #1,COL-G$(A5)
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        LEA     32,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.14
C.15:
        BRA     C.12
C.13:
        BRA     C.8
C.9:
*/********************************************************************/
*
*     makeH(index);
        PEA     INDEX-G$(A5)
        MOVEQ   #1,D2
        JSR     MAKEH-M$(A4)
        ADDQ.L  #4,SP
*
*/********************************************************************/
*/*  print the array on screen          */
*
*     for (row=0; row<ROWMAX;row++)
        MOVE.L  D7,A0
        MOVE.L  A0,ROW-G$(A5)
C.18:
        MOVE.L  ROW-G$(A5),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.17
        BRA     C.19
C.16:
        MOVE.L  ROW-G$(A5),A0
        ADDQ.L  #1,ROW-G$(A5)
        BRA     C.18
C.19:
*     {
*     for (col=0; col<COLMAX; printf("%c",index[row][col++]));
        MOVE.L  D7,A0
        MOVE.L  A0,COL-G$(A5)
C.22:
        MOVE.L  COL-G$(A5),A1
        LEA     5,A0
        CMP.L   A0,A1
        BGE     C.21
        BRA     C.23
C.20:
        PEA     C.2+0(PC)
        LEA     INDEX-G$(A5),A1
        MOVE.L  ROW-G$(A5),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  COL-G$(A5),A0
        ADDQ.L  #1,COL-G$(A5)
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
*     printf("\n");
        PEA     C.2+3(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*     }
        BRA     C.16
C.17:
*
*/********************************************************************/
*
*     printf("finished\n");
        PEA     C.2+5(PC)
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
C.2:    DC.B    37,99,0,10,0,102,105,110,105,115
        DC.B    104,101,100,10,0
*
*makeH(mat)
        DS.W    0

        XDEF    MAKEH
MAKEH:
*     
*     char *mat[];
*     {
        LINK    A6,#-C.25
*          fillcol(0,mat);
C.25    EQU     0
        MOVE.L  D7,-(SP)
        MOVE.L  8(A6),-(SP)
        MOVEQ   #2,D2
        JSR     FILLCOL-M$(A4)
        ADDQ.L  #8,SP
*          fillcol(COLMAX-1,mat);
        PEA     4
        MOVE.L  8(A6),-(SP)
        MOVEQ   #2,D2
        JSR     FILLCOL-M$(A4)
        ADDQ.L  #8,SP
*          fillrow(3,mat);
        PEA     3
        MOVE.L  8(A6),-(SP)
        MOVEQ   #2,D2
        JSR     FILLROW-M$(A4)
        ADDQ.L  #8,SP
*     }
        UNLK    A6
        RTS
*
*fillrow(row,matrix)

        XDEF    FILLROW
FILLROW:
*     int row;
*     char *matrix[];
*     {
        LINK    A6,#-C.27
*          int c;
*          for ( c=0; c<COLMAX; matrix[row][c++]='*');
C.27    EQU     4
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
C.30:
        MOVE.L  -4(A6),A1
        LEA     5,A0
        CMP.L   A0,A1
        BGE     C.29
        BRA     C.31
C.28:
        MOVE.L  8(A6),A1
        MOVE.L  12(A6),A0
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        LEA     42,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.30
C.31:
        BRA     C.28
C.29:
*     }
        UNLK    A6
        RTS
*
*fillcol(col,matrix)

        XDEF    FILLCOL
FILLCOL:
*     int col;
*     char *matrix[];
*     {
        LINK    A6,#-C.33
*          int r;
*          for ( r=0; r<ROWMAX; matrix[r++][col]='*');
C.33    EQU     4
        MOVE.L  D7,A0
        MOVE.L  A0,-4(A6)
C.36:
        MOVE.L  -4(A6),A1
        LEA     7,A0
        CMP.L   A0,A1
        BGE     C.35
        BRA     C.37
C.34:
        MOVE.L  8(A6),A1
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        ADD.L   A0,A0
        ADD.L   A0,A0
        ADD.L   A1,A0
        MOVE.L  (A0),A1
        MOVE.L  12(A6),A0
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        LEA     42,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.36
C.37:
        BRA     C.34
C.35:
*     }
        UNLK    A6
        RTS
*
*
        XREF    DELAY
        XREF    PRINTF
        END
