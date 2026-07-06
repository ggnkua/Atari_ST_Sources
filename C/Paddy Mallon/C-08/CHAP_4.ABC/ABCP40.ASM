*/*   ABC p40                        */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP40 GST QC Compiler 23:39 Tuesday   02/12/86 
        OPT ABS
*/*   decisions                      */
*/* works ok -     23/11/86          */
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
*     {    char ch,string[20];
        LINK    A6,#-C.3
*          int ans;
*
*          printf("gimme a letter...(y/n)");
C.3     EQU     26
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          scanf("%c",&ch);
        PEA     C.2+23(PC)
        PEA     -1(A6)
        MOVEQ   #2,D2
        JSR     SCANF-M$(A4)
        ADDQ.L  #8,SP
*          ans = affirmative(ch);
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     AFFIRMAT-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,-26(A6)
*          if (ans)
        TST.L   -26(A6)
        BEQ     C.4
*               { printf("yes!\n");}
        PEA     C.2+26(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          else
        BRA     C.5
C.4:
*               {printf("no - not yes\n");}
        PEA     C.2+32(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
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
C.2:    DC.B    103,105,109,109,101,32,97,32,108,101
        DC.B    116,116,101,114,46,46,46,40,121,47
        DC.B    110,41,0,37,99,0,121,101,115,33
        DC.B    10,0,110,111,32,45,32,110,111,116
        DC.B    32,121,101,115,10,0
*affirmative(ch)
        DS.W    0

        XDEF    AFFIRMAT
AFFIRMAT:
*     char ch;
*     { if ( ch == 'y' ) return(1);
        LINK    A6,#-C.7
C.7     EQU     0
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     121,A1
        CMP.L   A0,A1
        BNE     C.8
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*       else if ( ch =='Y') return(1);
C.8:
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     89,A1
        CMP.L   A0,A1
        BNE     C.10
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*            else return(0);
C.10:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
C.11:
C.9:
*     }
        UNLK    A6
        RTS
*
        XREF    DELAY
        XREF    PRINTF
        XREF    SCANF
        END
