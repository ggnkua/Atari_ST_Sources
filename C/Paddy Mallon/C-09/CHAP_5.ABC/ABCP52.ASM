*/*  ABC p 52 eg 5.6                    */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP52 GST QC Compiler 20:30 Wednesday 03/12/86 
        OPT ABS
*/*  perfect numbers                    */
*/*  tested and working 27/11/86        */
*
*
*#define  LO 6
*#define  HI 1000
*int ticks = 300;
        SECTION S.GLOB

        XDEF    TICKS
TICKS:
        DC.L    300
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {
        LINK    A6,#-C.3
*          int num,sum,factor;
*     
*          printf("  perfect numbers \n");
C.3     EQU     12
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          for (num = LO; num<=HI; num+=2)
        LEA     6,A0
        MOVE.L  A0,-4(A6)
C.6:
        MOVE.L  -4(A6),A1
        LEA     1000,A0
        CMP.L   A0,A1
        BGT     C.5
        BRA     C.7
C.4:
        MOVE.L  -4(A6),A0
        LEA     2,A1
        ADD.L   A1,A0
        MOVE.L  A0,-4(A6)
        BRA     C.6
C.7:
*          { 
*               sum = 1;
        MOVE.L  D6,A0
        MOVE.L  A0,-8(A6)
*               for (factor=2; factor<num; factor++)
        LEA     2,A0
        MOVE.L  A0,-12(A6)
C.10:
        MOVE.L  -12(A6),A1
        MOVE.L  -4(A6),A0
        CMP.L   A0,A1
        BGE     C.9
        BRA     C.11
C.8:
        MOVE.L  -12(A6),A0
        ADDQ.L  #1,-12(A6)
        BRA     C.10
C.11:
*                    if ( num%factor == 0) sum+=factor;
        XREF    C.DIV
        MOVE.L  -4(A6),A1
        MOVE.L  -12(A6),A0
        JSR     C.DIV-M$(A4)
        MOVE.L  A1,A0   ;
        MOVE.L  A0,D0
        BNE     C.12
        MOVE.L  -8(A6),A1
        MOVE.L  -12(A6),A0
        ADD.L   A1,A0
        MOVE.L  A0,-8(A6)
*               if ( sum == num ) printf("%4d\n",num);
C.12:
        BRA     C.8
C.9:
        MOVE.L  -8(A6),A1
        MOVE.L  -4(A6),A0
        CMP.L   A0,A1
        BNE     C.13
        PEA     C.2+20(PC)
        MOVE.L  -4(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*          }
C.13:
        BRA     C.4
C.5:
*     delay(ticks);
        MOVE.L  TICKS-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    32,32,112,101,114,102,101,99,116,32
        DC.B    110,117,109,98,101,114,115,32,10,0
        DC.B    37,52,100,10,0
*
        XREF    DELAY
        XREF    PRINTF
        END
