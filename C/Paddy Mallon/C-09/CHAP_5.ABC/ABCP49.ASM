*/*  ABC p49       eg 5.4              */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP49 GST QC Compiler 20:06 Wednesday 03/12/86 
        OPT ABS
*/*  do                                */
*/*  tested and working     25/11/86   */       
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
*FILE *fptr,*fptr2;

        XDEF    FPTR
FPTR:
        DC.L    0

        XDEF    FPTR2
FPTR2:
        DC.L    0
*
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
*/* A data file must be set up for this program to process.
*   If you do not want to set one up using 1st_word then take the comment
*   marks (/*) from around the following code and this will do the 
*   business.
**/
*
*/*     fptr2 = fopen("text2.dat","w");      
*     if(fptr2 == NULL)                     
*          {printf("error on open 2\n");}   
*     else                                           
*          {fprintf(fptr2,"computer programmer\n"); 
*           fclose(fptr2);
*          }
* */    
*     fptr = fopen("text2.dat","r");
C.3     EQU     6
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
*     {
*     kount = syllables();
        MOVEQ   #0,D2
        JSR     SYLLABLE-M$(A4)
        MOVE.L  A0,-4(A6)
*     printf("kount = %d\n",kount);
        PEA     C.2+32(PC)
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*     fclose(fptr); 
        MOVE.L  FPTR-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     FCLOSE-M$(A4)
        ADDQ.L  #4,SP
*     }
C.5:
*
*  
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    116,101,120,116,50,46,100,97,116,0
        DC.B    114,0,101,114,114,111,114,32,111,110
        DC.B    32,111,112,101,110,32,102,105,108,101
        DC.B    10,0,107,111,117,110,116,32,61,32
        DC.B    37,100,10,0
*
*
*syllables()
        DS.W    0

        XDEF    SYLLABLE
SYLLABLE:
*     {    char ch;
        LINK    A6,#-C.7
*          int changes =0 ,previousvowel=0;
        MOVE.L  D7,A0
        MOVE.L  A0,-6(A6)
        MOVE.L  D7,A0
        MOVE.L  A0,-10(A6)
*
*          do
C.7     EQU     10
C.10:
*               {
*                  ch = getc(fptr);
        MOVE.L  FPTR-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     GETC-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,D0
        MOVE.B  D0,-1(A6)
*                    if (vowel(ch))
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     VOWEL-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,D0
        BEQ     C.11
*                         {    
*                          if ( !previousvowel) changes++;
        XREF    C.LNEG
        MOVE.L  -10(A6),A0
        JSR     C.LNEG-M$(A4)
        MOVE.L  A0,D0
        BEQ     C.12
        MOVE.L  -6(A6),A0
        ADDQ.L  #1,-6(A6)
*                              previousvowel = 1;
C.12:
        MOVE.L  D6,A0
        MOVE.L  A0,-10(A6)
*                         }
*                    else if (consonant(ch)) previousvowel = 0;
        BRA     C.13
C.11:
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        MOVE.L  A0,-(SP)
        MOVEQ   #1,D2
        JSR     CONSONAN-M$(A4)
        ADDQ.L  #4,SP
        MOVE.L  A0,D0
        BEQ     C.14
        MOVE.L  D7,A0
        MOVE.L  A0,-10(A6)
*               }
C.14:
C.13:
*          while ( ch != '\n');
C.8:
        MOVE.B  -1(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        LEA     10,A1
        CMP.L   A0,A1
        BEQ     C.9
        BRA     C.10
C.9:
*          return(changes);
        MOVE.L  -6(A6),A0
        UNLK    A6
        RTS
*     }
*vowel(ch)

        XDEF    VOWEL
VOWEL:
*          char ch ;
*     {
        LINK    A6,#-C.16
*          switch(ch)
C.16    EQU     0
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        BRA     C.19
*               {
*                   default: return(0);
C.20:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*
*                   case 'u': case 'U':return(1);
C.21:
C.22:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                   case 'a': case 'A':return(1);
C.23:
C.24:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                   case 'e': case 'E':return(1);
C.25:
C.26:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                   case 'i': case 'I':return(1);
C.27:
C.28:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*                   case 'o': case 'O':return(1);
C.29:
C.30:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*               }
        BRA     C.18
C.19:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.21-*,117
        DC.L    C.22-*,85
        DC.L    C.23-*,97
        DC.L    C.24-*,65
        DC.L    C.25-*,101
        DC.L    C.26-*,69
        DC.L    C.27-*,105
        DC.L    C.28-*,73
        DC.L    C.29-*,111
        DC.L    C.30-*,79
        DC.L    0
        BRA     C.20
C.18:
*     }
        UNLK    A6
        RTS
*consonant(ch)

        XDEF    CONSONAN
CONSONAN:
*          char ch;
*     {
        LINK    A6,#-C.32
*          switch(ch)
C.32    EQU     0
        MOVE.B  11(A6),D0
        EXT.W   D0
        MOVE.W  D0,A0
        BRA     C.35
*               {
*                   default: return(1);
C.36:
        MOVE.L  D6,A0
        UNLK    A6
        RTS
*
*                   case 'u': case 'U':return(0);
C.37:
C.38:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*                   case 'a': case 'A':return(0);
C.39:
C.40:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*                   case 'e': case 'E':return(0);
C.41:
C.42:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*                   case 'i': case 'I':return(0);
C.43:
C.44:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*                   case 'o': case 'O':return(0);
C.45:
C.46:
        MOVE.L  D7,A0
        UNLK    A6
        RTS
*               }
        BRA     C.34
C.35:
        JSR     C.SWITCH-M$(A4)
        DC.L    C.37-*,117
        DC.L    C.38-*,85
        DC.L    C.39-*,97
        DC.L    C.40-*,65
        DC.L    C.41-*,101
        DC.L    C.42-*,69
        DC.L    C.43-*,105
        DC.L    C.44-*,73
        DC.L    C.45-*,111
        DC.L    C.46-*,79
        DC.L    0
        BRA     C.36
C.34:
*     }
        UNLK    A6
        RTS
*
        XREF    FCLOSE
        XREF    DELAY
        XREF    PRINTF
        XREF    GETC
        XREF    FOPEN
        END
