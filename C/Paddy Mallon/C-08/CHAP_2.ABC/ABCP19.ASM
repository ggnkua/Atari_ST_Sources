*/*   abc p19/20 eg2.4                 */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP19 GST QC Compiler 15:49 Sunday    30/11/86 
        OPT ABS
*/*   tested & run 22/11/86            */
*
*         #include <stdio.h>
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
**         #define gap printf("\n\n\n\n\n");
*        
*     main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*
*           {
        LINK    A6,#-C.3
*              long ticks;
*               ticks = 300;
C.3     EQU     4
        LEA     300,A0
        MOVE.L  A0,-4(A6)
*
*                         bigH('H');
        PEA     72
        MOVEQ   #1,D2
        JSR     BIGH-M$(A4)
        ADDQ.L  #4,SP
*                         bigI('I');
        PEA     73
        MOVEQ   #1,D2
        JSR     BIGI-M$(A4)
        ADDQ.L  #4,SP
*
*              delay(ticks);
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*           }
        UNLK    A6
        RTS
*
*     bigH(ch)

        XDEF    BIGH
BIGH:
*          char ch;
*          {    gap;
        LINK    A6,#-C.5
C.5     EQU     0
        PEA     C.4+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               endstars(ch);endstars(ch);endstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
*               allstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ALLSTARS-M$(A4)
        ADDQ.L  #4,SP
*               endstars(ch);endstars(ch);endstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ENDSTARS-M$(A4)
        ADDQ.L  #4,SP
*          }
        UNLK    A6
        RTS
C.4:    DC.B    10,10,10,10,10,0
*     bigI(ch)
        DS.W    0

        XDEF    BIGI
BIGI:
*          char ch;
*          {    gap;
        LINK    A6,#-C.7
C.7     EQU     0
        PEA     C.6+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               allstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ALLSTARS-M$(A4)
        ADDQ.L  #4,SP
*               midstars(ch); midstars(ch);midstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     MIDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     MIDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     MIDSTARS-M$(A4)
        ADDQ.L  #4,SP
*               midstars(ch); midstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     MIDSTARS-M$(A4)
        ADDQ.L  #4,SP
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     MIDSTARS-M$(A4)
        ADDQ.L  #4,SP
*               allstars(ch);
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     ALLSTARS-M$(A4)
        ADDQ.L  #4,SP
*          }          
        UNLK    A6
        RTS
C.6:    DC.B    10,10,10,10,10,0
*
*     allstars(ch)
        DS.W    0

        XDEF    ALLSTARS
ALLSTARS:
*          char ch;
*               { printf("%c%c%c%c%c\n",ch,ch,ch,ch,ch); }
        LINK    A6,#-C.9
C.9     EQU     0
        PEA     C.8+0(PC)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #6,D2
        JSR     PRINTF-M$(A4)
        ADD.W   #24,SP
        UNLK    A6
        RTS
C.8:    DC.B    37,99,37,99,37,99,37,99,37,99
        DC.B    10,0
*
*     endstars(ch)
        DS.W    0

        XDEF    ENDSTARS
ENDSTARS:
*          char(ch);
*               {printf("%c   %c\n",ch,ch);}
        LINK    A6,#-C.11
C.11    EQU     0
        PEA     C.10+0(PC)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #3,D2
        JSR     PRINTF-M$(A4)
        ADD.W   #12,SP
        UNLK    A6
        RTS
C.10:   DC.B    37,99,32,32,32,37,99,10,0
*
*     midstars(ch)
        DS.W    0

        XDEF    MIDSTARS
MIDSTARS:
*          char ch;
*               { printf("  %c  \n",ch);}
        LINK    A6,#-C.13
C.13    EQU     0
        PEA     C.12+0(PC)
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        UNLK    A6
        RTS
C.12:   DC.B    32,32,37,99,32,32,10,0
*
*
*
        XREF    DELAY
        XREF    PRINTF
        END
