*/*   ABC  p16  eg 2.3                 */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP16 GST QC Compiler 15:46 Sunday    30/11/86 
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
*              int ticks= 300;
        LEA     300,A0
        MOVE.L  A0,-4(A6)
*
*                         bigH(); gap;
C.3     EQU     4
        MOVEQ   #0,D2
        JSR     BIGH-M$(A4)
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*                         bigI(); gap;
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
*               endstars();endstars();endstars();
C.5     EQU     0
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
*               allstars();
        MOVEQ   #0,D2
        JSR     ALLSTARS-M$(A4)
*               endstars();endstars();endstars();
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     ENDSTARS-M$(A4)
*          }
        UNLK    A6
        RTS
*     bigI()

        XDEF    BIGI
BIGI:
*          {   
        LINK    A6,#-C.7
*               allstars();
C.7     EQU     0
        MOVEQ   #0,D2
        JSR     ALLSTARS-M$(A4)
*               midstars(); midstars();midstars();
        MOVEQ   #0,D2
        JSR     MIDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     MIDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     MIDSTARS-M$(A4)
*               midstars(); midstars();
        MOVEQ   #0,D2
        JSR     MIDSTARS-M$(A4)
        MOVEQ   #0,D2
        JSR     MIDSTARS-M$(A4)
*               allstars();
        MOVEQ   #0,D2
        JSR     ALLSTARS-M$(A4)
*          }          
        UNLK    A6
        RTS
*
*     allstars()

        XDEF    ALLSTARS
ALLSTARS:
*               { printf("*****\n"); }
        LINK    A6,#-C.9
C.9     EQU     0
        PEA     C.8+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
        UNLK    A6
        RTS
C.8:    DC.B    42,42,42,42,42,10,0
*
*     endstars()
        DS.W    0

        XDEF    ENDSTARS
ENDSTARS:
*               { printf("*   *\n");}
        LINK    A6,#-C.11
C.11    EQU     0
        PEA     C.10+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
        UNLK    A6
        RTS
C.10:   DC.B    42,32,32,32,42,10,0
*
*     midstars()
        DS.W    0

        XDEF    MIDSTARS
MIDSTARS:
*               { printf("  *  \n");}
        LINK    A6,#-C.13
C.13    EQU     0
        PEA     C.12+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
        UNLK    A6
        RTS
C.12:   DC.B    32,32,42,32,32,10,0
*
*
*
        XREF    DELAY
        XREF    PRINTF
        END
