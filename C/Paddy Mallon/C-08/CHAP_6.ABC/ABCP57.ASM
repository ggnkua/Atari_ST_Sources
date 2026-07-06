*/*  ABC p 57  eg 6.1                */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP57 GST QC Compiler 16:12 Saturday  06/12/86 
        OPT ABS
*/*  zellers congruence              */
*/*  returns a number(0-6) representing the day of the week for 
*     a given date (ddmmyyyy). 0 = sunday                         */
*/*   tested and working /11/86      */
*
*
*int ticks = 300;
        SECTION S.GLOB

        XDEF    TICKS
TICKS:
        DC.L    300
*
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {    int day,month,year;
        LINK    A6,#-C.3
*
*          printf(" gimme a date:...");
C.3     EQU     12
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          scanf("%2d %2d %4d",&day,&month,&year);
        PEA     C.2+18(PC)
        PEA     -4(A6)
        PEA     -8(A6)
        PEA     -12(A6)
        MOVEQ   #4,D2
        JSR     SCANF-M$(A4)
        ADD.W   #16,SP
*          printf(" %d\n",zeller(day,month,year));
        PEA     C.2+30(PC)
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -8(A6),-(SP)
        MOVE.L  -12(A6),-(SP)
        MOVEQ   #3,D2
        JSR     ZELLER-M$(A4)
        ADD.W   #12,SP
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
C.2:    DC.B    32,103,105,109,109,101,32,97,32,100
        DC.B    97,116,101,58,46,46,46,0,37,50
        DC.B    100,32,37,50,100,32,37,52,100,0
        DC.B    32,37,100,10,0
*zeller(day,month,year)
        DS.W    0

        XDEF    ZELLER
ZELLER:
*     int day,month,year;
*     {
        LINK    A6,#-C.5
*          int temp,yr1,yr2;
*     
*     if (month<3){ month+=10;year-=1;}
C.5     EQU     12
        MOVE.L  12(A6),A1
        LEA     3,A0
        CMP.L   A0,A1
        BGE     C.6
        MOVE.L  12(A6),A0
        LEA     10,A1
        ADD.L   A1,A0
        MOVE.L  A0,12(A6)
        MOVE.L  8(A6),A1
        MOVE.L  D6,A0
        SUB.L   A0,A1
        MOVE.L  A1,A0   ;
        MOVE.L  A0,8(A6)
*     else month-=2;
        BRA     C.7
C.6:
        MOVE.L  12(A6),A1
        LEA     2,A0
        SUB.L   A0,A1
        MOVE.L  A1,A0   ;
        MOVE.L  A0,12(A6)
C.7:
*
*     yr1=year/100; yr2=year%100;
        XREF    C.DIV
        MOVE.L  8(A6),A1
        LEA     100,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  A0,-8(A6)
        MOVE.L  8(A6),A1
        LEA     100,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  A1,A0   ;
        MOVE.L  A0,-12(A6)
*
*     temp = (26*month-1)/10;
        XREF    C.MULT
        MOVE.L  12(A6),A0
        LEA     26,A1
        JSR     C.MULT-M$(A4)
        MOVE.L  A0,A1   ;;
        MOVE.L  D6,A0
        SUB.L   A0,A1
        LEA     10,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  A0,-4(A6)
*
*     return((day+temp+yr2+yr2/4+yr1/4-2*yr1+49)%7);
        MOVE.L  16(A6),A1
        MOVE.L  -4(A6),A0
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        MOVE.L  -12(A6),A0
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        MOVE.L  -12(A6),A1
        LEA     4,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        MOVE.L  -8(A6),A1
        LEA     4,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        MOVE.L  -8(A6),A0
        LEA     2,A1
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        SUB.L   A0,A1
        MOVE.L  A1,A0   ;
        LEA     49,A1
        ADD.L   A1,A0
        MOVE.L  A0,A1   ;;
        LEA     7,A0
        JSR     C.DIV-M$(A4)
        MOVE.L  A1,A0   ;
        UNLK    A6
        RTS
*     }
*
        XREF    DELAY
        XREF    PRINTF
        XREF    SCANF
        END
