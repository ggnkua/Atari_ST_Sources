*/*  ABC p47       eg 5.3           */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP48 GST QC Compiler 19:53 Wednesday 03/12/86 
        OPT ABS
*/*  escaping from loops            */
*/*  works -- except for BELL does not ring
*     24/11/86                      */
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
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*     int kount;
*     char ch;
*     
*     
*       printf("REPLY = %d\n",replyisyes());   
C.3     EQU     6
        PEA     C.2+0(PC)
        MOVEQ   #0,D2
        JSR     REPLYISY-M$(A4)
        MOVE.L  A0,-(SP)
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
C.2:    DC.B    82,69,80,76,89,32,61,32,37,100
        DC.B    10,0
*replyisyes()
        DS.W    0

        XDEF    REPLYISY
REPLYISY:
*     {    
        LINK    A6,#-C.5
*          char ch;
*          while(1)
C.5     EQU     2
C.6:
*               {
*                  ch= getchar();
        MOVEQ   #0,D2
        JSR     GETCHAR-M$(A4)
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*                    switch(ch)
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        BRA     C.10
*                    {    default: putchar(BELL);break;
C.11:
        PEA     7
        MOVEQ   #1,D2
        JSR     PUTCHAR-M$(A4)
        ADDQ.L  #4,SP
        BRA     C.9
*                         case 'y': case'Y': return(1);
C.12:
C.13:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                         case 'n': case'N': return(0);
C.14:
C.15:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*                    }
        BRA     C.9
C.10:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.12-*,121
        DC.L    C.13-*,89
        DC.L    C.14-*,110
        DC.L    C.15-*,78
        DC.L    0
        BRA     C.11
C.9:
*               }
        BRA     C.6
C.7:
*     }
        UNLK    A6
        RTS
*
*
        XREF    DELAY
        XREF    PRINTF
        XREF    PUTCHAR
        XREF    GETCHAR
        END
