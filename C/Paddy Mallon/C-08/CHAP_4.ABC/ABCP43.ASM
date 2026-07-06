*/*  ABC p43   eg 4.4             */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP43 GST QC Compiler 00:00 Wednesday 03/12/86 
        OPT ABS
*/*   case                        */
*/*  tested and working 23/11/86  */
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
*     char reply;
*     char let;
*          printf("gimme a letter.....");
C.3     EQU     4
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          scanf("%c",&reply); printf("%c\n",reply);
        PEA     C.2+20(PC)
        PEA     -1(A6)
        MOVEQ   #2,D2
        JSR     SCANF-M$(A4)
        ADDQ.L  #8,SP
        PEA     C.2+23(PC)
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          printf("grade is ..%d\n",vowel(reply));
        PEA     C.2+27(PC)
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     VOWEL-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          printf("finished\n");
        PEA     C.2+42(PC)
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
C.2:    DC.B    103,105,109,109,101,32,97,32,108,101
        DC.B    116,116,101,114,46,46,46,46,46,0
        DC.B    37,99,0,37,99,10,0,103,114,97
        DC.B    100,101,32,105,115,32,46,46,37,100
        DC.B    10,0,102,105,110,105,115,104,101,100
        DC.B    10,0
*
*vowel(ch)
        DS.W    0

        XDEF    VOWEL
VOWEL:
*          char ch ;
*     {
        LINK    A6,#-C.5
*          switch(ch)
C.5     EQU     0
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        BRA     C.8
*               {
*                   default: return(0);
C.9:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*
*                   case 'u': case 'U':return(5);
C.10:
C.11:
        LEA     5,A0
        UNLK    A6
        RTS
*                   case 'a': case 'A':return(1);
C.12:
C.13:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                   case 'e': case 'E':return(2);
C.14:
C.15:
        LEA     2,A0
        UNLK    A6
        RTS
*                   case 'i': case 'I':return(3);
C.16:
C.17:
        LEA     3,A0
        UNLK    A6
        RTS
*                   case 'o': case 'O':return(4);
C.18:
C.19:
        LEA     4,A0
        UNLK    A6
        RTS
*               }
        BRA     C.7
C.8:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.10-*,117
        DC.L    C.11-*,85
        DC.L    C.12-*,97
        DC.L    C.13-*,65
        DC.L    C.14-*,101
        DC.L    C.15-*,69
        DC.L    C.16-*,105
        DC.L    C.17-*,73
        DC.L    C.18-*,111
        DC.L    C.19-*,79
        DC.L    0
        BRA     C.9
C.7:
*     }
        UNLK    A6
        RTS
*
        XREF    DELAY
        XREF    PRINTF
        XREF    SCANF
        END
