*/*  ABC p51  eg 5.5                 */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP51 GST QC Compiler 20:24 Wednesday 03/12/86 
        OPT ABS
*/*  continue statment and  passes() */
*/*  tested and working 27/11/86     */
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
*int sum,n,i,totpas;

        XDEF    SUM
SUM:
        DC.L    0

        XDEF    N
N:
        DC.L    0

        XDEF    I
I:
        DC.L    0

        XDEF    TOTPAS
TOTPAS:
        DC.L    0
*FILE *fptr;

        XDEF    FPTR
FPTR:
        DC.L    0
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*/*   A file (TEXT3.DAT) must be set up containing first the number of
*     marks in the file, and then the actual marks which are to be graded.
*     Do this using 1st_word or set up a file as outlined in the last 
*     program.
**/
*     fptr = fopen("TEXT3.DAT","r");
C.3     EQU     0
        PEA     C.2+0(PC)
        PEA     C.2+10(PC)
        MOVEQ   #2,D2
        JSR     FOPEN-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  A0,FPTR-G$(A5)
*
*     if ( fptr == NULL)
        TST.L   FPTR-G$(A5)
        BNE     C.4
*          {    printf("error on open file\n");}
        PEA     C.2+12(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*     else
        BRA     C.5
C.4:
*      {  
*          printf("total passes = %d\n",passes());
        PEA     C.2+32(PC)
        MOVEQ   #0,D2
        JSR     PASSES-M$(A4)
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          
*          fclose(fptr); 
        MOVE.L  FPTR-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     FCLOSE-M$(A4)
        ADDQ.L  #4,SP
*      }         
C.5:
*
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    84,69,88,84,51,46,68,65,84,0
        DC.B    114,0,101,114,114,111,114,32,111,110
        DC.B    32,111,112,101,110,32,102,105,108,101
        DC.B    10,0,116,111,116,97,108,32,112,97
        DC.B    115,115,101,115,32,61,32,37,100,10
        DC.B    0
*
*passes()
        DS.W    0

        XDEF    PASSES
PASSES:
*     { 
        LINK    A6,#-C.7
*     char g;
*     int listsize,mark,m,psum=0;
        MOVE.L  D7,A0
        MOVE.L  A0,-18(A6)
*
*     if (fscanf(fptr,"%d",&listsize)< 1) return(-1);
C.7     EQU     18
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+0(PC)
        PEA     -6(A6)
        MOVEQ   #3,D2
        JSR     FSCANF-M$(A4)
        ADD.W   #12,SP
        MOVE.L  A0,A1   ;;
        MOVE.L  D6,A0
        CMP.L   A0,A1
        BGE     C.8
        XREF    C.NEG
        LEA     -1,A0
        UNLK    A6
        RTS
*
*     for (m=1;m<=listsize;m++)
C.8:
        MOVE.L  D6,A0
        MOVE.L  A0,-14(A6)
C.11:
        MOVE.L  -14(A6),A1
        MOVE.L  -6(A6),A0
        CMP.L   A0,A1
        BGT     C.10
        BRA     C.12
C.9:
        MOVE.L  -14(A6),A0
        ADDQ.L  #1,-14(A6)
        BRA     C.11
C.12:
*          {
*           if (fscanf(fptr,"%d",&mark)>0)
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+3(PC)
        PEA     -10(A6)
        MOVEQ   #3,D2
        JSR     FSCANF-M$(A4)
        ADD.W   #12,SP
        MOVE.L  A0,D0
        BLE     C.13
*               { 
*                    if ((g=grade(mark)) == NULL) continue;
        MOVE.L  -10(A6),-(SP)
        MOVEQ   #1,D2
        JSR     GRADE-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        MOVE.L  A0,D0
        BNE     C.14
        BRA     C.9
*                    if (g == 'e') continue;
C.14:
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     101,A1
        CMP.L   A0,A1
        BNE     C.15
        BRA     C.9
*                    printf("grade = %c\n",g);
C.15:
        PEA     C.6+6(PC)
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*                    psum++;
        MOVE.L  -18(A6),A0
        ADDQ.L  #1,-18(A6)
*               }
*           else 
        BRA     C.16
C.13:
*               return(-1);
        LEA     -1,A0
        UNLK    A6
        RTS
C.16:
*          }
        BRA     C.9
C.10:
*     return(psum);
        MOVE.L  -18(A6),A0
        UNLK    A6
        RTS
*     }
C.6:    DC.B    37,100,0,37,100,0,103,114,97,100
        DC.B    101,32,61,32,37,99,10,0
*
*grade(mark)
        DS.W    0

        XDEF    GRADE
GRADE:
*     int mark;
*     {
        LINK    A6,#-C.18
*          char g ;
*          switch(mark/20)
C.18    EQU     2
        XREF    C.DIV
        MOVE.L  8(A6),A1
        LEA     20,A0
        JSR     C.DIV-M$(A4)
        BRA     C.21
*               {
*                   case 0:  g = 'e'; break;
C.22:
        LEA     101,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.20
*                   case 1:  g = 'd'; break;
C.23:
        LEA     100,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.20
*                   case 2:  g = 'c'; break;
C.24:
        LEA     99,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.20
*                   case 3:  g = 'b'; break;
C.25:
        LEA     98,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.20
*                   case 4:  g = 'a'; break;
C.26:
        LEA     97,A0
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
        BRA     C.20
*               }
        BRA     C.20
C.21:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.22-*,0
        DC.L    C.23-*,1
        DC.L    C.24-*,2
        DC.L    C.25-*,3
        DC.L    C.26-*,4
        DC.L    0
C.20:
*          return(g);
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        UNLK    A6
        RTS
*     }
*
        XREF    FCLOSE
        XREF    DELAY
        XREF    FSCANF
        XREF    PRINTF
        XREF    FOPEN
        END
