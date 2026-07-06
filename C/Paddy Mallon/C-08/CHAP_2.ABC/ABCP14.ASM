*/*   ABC p14    eg.2.1                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP14 GST QC Compiler 15:33 Sunday    30/11/86 
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
*                         bigH();  gap;
        MOVEQ   #0,D2
        JSR     BIGH-M$(A4)
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*                         bigI();  gap;
        MOVEQ   #0,D2
        JSR     BIGI-M$(A4)
        PEA     C.2+6(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
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
C.2:    DC.B    10,10,10,10,10,0,10,10,10,10
        DC.B    10,0
*
*     bigH()
        DS.W    0

        XDEF    BIGH
BIGH:
*          { 
        LINK    A6,#-C.5
*               printf("*   *\n"); 
C.5     EQU     0
        PEA     C.4+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*   *\n"); 
        PEA     C.4+7(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*   *\n"); 
        PEA     C.4+14(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*****\n"); 
        PEA     C.4+21(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*   *\n"); 
        PEA     C.4+28(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*   *\n");
        PEA     C.4+35(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*   *\n"); 
        PEA     C.4+42(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          }
        UNLK    A6
        RTS
C.4:    DC.B    42,32,32,32,42,10,0,42,32,32
        DC.B    32,42,10,0,42,32,32,32,42,10
        DC.B    0,42,42,42,42,42,10,0,42,32
        DC.B    32,32,42,10,0,42,32,32,32,42
        DC.B    10,0,42,32,32,32,42,10,0
*     bigI()
        DS.W    0

        XDEF    BIGI
BIGI:
*          {  
        LINK    A6,#-C.7
*               printf("*****\n"); 
C.7     EQU     0
        PEA     C.6+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("  *  \n"); 
        PEA     C.6+7(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("  *  \n"); 
        PEA     C.6+14(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("  *  \n"); 
        PEA     C.6+21(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("  *  \n"); 
        PEA     C.6+28(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               printf("*****\n"); 
        PEA     C.6+35(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          }          
        UNLK    A6
        RTS
C.6:    DC.B    42,42,42,42,42,10,0,32,32,42
        DC.B    32,32,10,0,32,32,42,32,32,10
        DC.B    0,32,32,42,32,32,10,0,32,32
        DC.B    42,32,32,10,0,42,42,42,42,42
        DC.B    10,0
*
*
*
*
*
        XREF    DELAY
        XREF    PRINTF
        END
