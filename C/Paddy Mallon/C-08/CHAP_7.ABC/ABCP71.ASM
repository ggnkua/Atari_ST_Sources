*/* ABC p71  eg. 7.7                                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP71 GST QC Compiler 19:33 Wednesday 10/12/86 
        OPT ABS
*/*  arrays - has some differences to the book due to GST C and typos */
*/*  tested and working 10/12/86                    */
*
*/* Soundex code generator:   to transform a string */
*/* into a code that tends to bring together all    */
*/* variants of the same name (usually surname).    */
*/*     -[Knuth. 1973]                              */
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
*static char code[]="01230120022455012623010202";

CODE:
        DC.B    48,49,50,51,48,49,50,48,48,50
        DC.B    50,52,53,53,48,49,50,54,50,51
        DC.B    48,49,48,50,48,50,0
*
*main()
        DS.W    0
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     { char str[20];
        LINK    A6,#-C.3
*          printf("\ncharacter string? ");
C.3     EQU     20
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          scanf("%s",str);
        PEA     C.2+20(PC)
        PEA     -20(A6)
        MOVEQ   #2,D2
        JSR     SCANF-M$(A4)
        ADDQ.L  #8,SP
*
*          encode(str);
        PEA     -20(A6)
        MOVEQ   #1,D2
        JSR     ENCODE-M$(A4)
        ADDQ.L  #4,SP
*
*          dumpdups(str);
        PEA     -20(A6)
        MOVEQ   #1,D2
        JSR     DUMPDUPS-M$(A4)
        ADDQ.L  #4,SP
*
*          dumpzeros(str);
        PEA     -20(A6)
        MOVEQ   #1,D2
        JSR     DUMPZERO-M$(A4)
        ADDQ.L  #4,SP
*
*          fixup(str);
        PEA     -20(A6)
        MOVEQ   #1,D2
        JSR     FIXUP-M$(A4)
        ADDQ.L  #4,SP
*
*          printf("\nSoundex code is  :  %s\n",str);
        PEA     C.2+23(PC)
        PEA     -20(A6)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    10,99,104,97,114,97,99,116,101,114
        DC.B    32,115,116,114,105,110,103,63,32,0
        DC.B    37,115,0,10,83,111,117,110,100,101
        DC.B    120,32,99,111,100,101,32,105,115,32
        DC.B    32,58,32,32,37,115,10,0
*
*encode(s)
        DS.W    0

        XDEF    ENCODE
ENCODE:
*     char *s;
*
*     {
        LINK    A6,#-C.5
*
*          while(*++s) *s=code[*s-'a'];
C.5     EQU     0
C.6:
        ADDQ.L  #1,8(A6)
        MOVE.L  8(A6),A0
        TST.B   (A0)
        BEQ     C.7
        MOVE.L  8(A6),-(SP)
        PEA     CODE-G$(A5)
        MOVE.L  8(A6),A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A1
        LEA     97,A0
        SUB.L   A0,A1
        MOVE.L  A1,A0   ;
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  (SP)+,A1
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.6
C.7:
*     }
        UNLK    A6
        RTS
*
*dumpdups(s)

        XDEF    DUMPDUPS
DUMPDUPS:
*     char *s;
*     {
        LINK    A6,#-C.9
*          char *t;
*          while(*s)
C.9     EQU     4
C.10:
        MOVE.L  8(A6),A0
        TST.B   (A0)
        BEQ     C.11
*               if(*s==*(s+1))
        MOVE.L  8(A6),A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVE.L  8(A6),A0
        MOVE.L  D6,A1
        ADD.L   A1,A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  (SP)+,A1
        CMP.L   A0,A1
        BNE     C.12
*                    {
*                         t=s+1;
        MOVE.L  8(A6),A0
        MOVE.L  D6,A1
        ADD.L   A1,A0
        MOVE.L  A0,-4(A6)
*                         while(*t=*(t+1)) t++;
C.13:
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -4(A6),A0
        MOVE.L  D6,A1
        ADD.L   A1,A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  (SP)+,A1
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        MOVE.L  A0,D0
        BEQ     C.14
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.13
C.14:
*                    }
*               else
        BRA     C.15
C.12:
*                         s++;
        MOVE.L  8(A6),A0
        ADDQ.L  #1,8(A6)
C.15:
        BRA     C.10
C.11:
*     }
        UNLK    A6
        RTS
*
*dumpzeros(s)

        XDEF    DUMPZERO
DUMPZERO:
*     char *s;
*     {
        LINK    A6,#-C.17
*          char *t;
*          while(*s)
C.17    EQU     4
C.18:
        MOVE.L  8(A6),A0
        TST.B   (A0)
        BEQ     C.19
*               if (*s=='0')
        MOVE.L  8(A6),A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     48,A1
        CMP.L   A0,A1
        BNE     C.20
*                    {
*                         t=s;
        MOVE.L  8(A6),A0
        MOVE.L  A0,-4(A6)
*                         while(*t=*(t+1)) t++;
C.21:
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -4(A6),A0
        MOVE.L  D6,A1
        ADD.L   A1,A0
        MOVE.B  (A0),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  (SP)+,A1
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        MOVE.L  A0,D0
        BEQ     C.22
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.21
C.22:
*                    }
*                else 
        BRA     C.23
C.20:
*                         s++;
        MOVE.L  8(A6),A0
        ADDQ.L  #1,8(A6)
C.23:
        BRA     C.18
C.19:
*     }
        UNLK    A6
        RTS
*
*fixup(s)

        XDEF    FIXUP
FIXUP:
*     char *s;
*     {
        LINK    A6,#-C.25
*          int i ;
*          for(i=1;*++s && i<4; i++);
C.25    EQU     4
        MOVE.L  D6,A0
        MOVE.L  A0,-4(A6)
C.28:
        ADDQ.L  #1,8(A6)
        MOVE.L  8(A6),A0
        TST.B   (A0)
        BEQ     C.30
        MOVE.L  -4(A6),A1
        LEA     4,A0
        CMP.L   A0,A1
        BGE     C.30
        MOVE.L  D6,A0
        BRA     C.31
C.30:
        MOVE.L  D7,A0
C.31:
        MOVE.L  A0,D0
        BEQ     C.27
        BRA     C.29
C.26:
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.28
C.29:
        BRA     C.26
C.27:
*          for( ;i<4;i++) *s++ ='0';
C.34:
        MOVE.L  -4(A6),A1
        LEA     4,A0
        CMP.L   A0,A1
        BGE     C.33
        BRA     C.35
C.32:
        MOVE.L  -4(A6),A0
        ADDQ.L  #1,-4(A6)
        BRA     C.34
C.35:
        MOVE.L  8(A6),A0
        ADDQ.L  #1,8(A6)
        MOVE.L  A0,A1   ;;
        LEA     48,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
        BRA     C.32
C.33:
*          *s=('0');
        MOVE.L  8(A6),A1
        LEA     48,A0
        MOVE.L  A0,D0
        MOVE.B  D0,(A1)
*     }
        UNLK    A6
        RTS
*
*
*
*     
*
        XREF    DELAY
        XREF    PRINTF
        XREF    SCANF
        END
