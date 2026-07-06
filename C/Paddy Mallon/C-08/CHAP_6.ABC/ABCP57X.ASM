*/*  ABC p 57                         */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP57X GST QC Compiler 16:44 Saturday  06/12/86 
        OPT ABS
*/*  tested and working 28/11/86      */
*/*  now prints the day and number    */
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
*     {    int day,month,year,k;
        LINK    A6,#-C.3
*          
*          char day0[]= "sunday";
        LEA     C.2+0(PC),A0
        MOVE.L  A0,-20(A6)
*          char day1[]= "monday";
        LEA     C.2+7(PC),A0
        MOVE.L  A0,-24(A6)
*          char day2[]= "tuesday";
        LEA     C.2+14(PC),A0
        MOVE.L  A0,-28(A6)
*          char day3[]= "wednesday";
        LEA     C.2+22(PC),A0
        MOVE.L  A0,-32(A6)
*          char day4[]= "thursday";
        LEA     C.2+32(PC),A0
        MOVE.L  A0,-36(A6)
*          char day5[]= "friday";
        LEA     C.2+41(PC),A0
        MOVE.L  A0,-40(A6)
*          char day6[]= "saturday";
        LEA     C.2+48(PC),A0
        MOVE.L  A0,-44(A6)
*          
*             printf(" gimme a date:...");
C.3     EQU     44
        PEA     C.2+57(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*             scanf("%2d %2d %4d",&day,&month,&year);
        PEA     C.2+75(PC)
        PEA     -4(A6)
        PEA     -8(A6)
        PEA     -12(A6)
        MOVEQ   #4,D2
        JSR     SCANF-M$(A4)
        ADD.W   #16,SP
*             printf(" %d\n",zeller(day,month,year));
        PEA     C.2+87(PC)
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
*             k = zeller(day,month,year);
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -8(A6),-(SP)
        MOVE.L  -12(A6),-(SP)
        MOVEQ   #3,D2
        JSR     ZELLER-M$(A4)
        ADD.W   #12,SP
        MOVE.L  A0,-16(A6)
*             switch(k)
        MOVE.L  -16(A6),A0
        BRA     C.6
*               {
*                    case 0: printf("%s\n",day0);break;
C.7:
        PEA     C.2+92(PC)
        MOVE.L  -20(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 1: printf("%s\n",day1);break;
C.8:
        PEA     C.2+96(PC)
        MOVE.L  -24(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 2: printf("%s\n",day2);break;
C.9:
        PEA     C.2+100(PC)
        MOVE.L  -28(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 3: printf("%s\n",day3);break;
C.10:
        PEA     C.2+104(PC)
        MOVE.L  -32(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 4: printf("%s\n",day4);break;
C.11:
        PEA     C.2+108(PC)
        MOVE.L  -36(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 5: printf("%s\n",day5);break;
C.12:
        PEA     C.2+112(PC)
        MOVE.L  -40(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                    case 6: printf("%s\n",day6);break;
C.13:
        PEA     C.2+116(PC)
        MOVE.L  -44(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
        BRA     C.5
*                }
        BRA     C.5
C.6:
        XREF    C.SWITCH
        JSR     C.SWITCH-M$(A4)
        DC.L    C.7-*,0
        DC.L    C.8-*,1
        DC.L    C.9-*,2
        DC.L    C.10-*,3
        DC.L    C.11-*,4
        DC.L    C.12-*,5
        DC.L    C.13-*,6
        DC.L    0
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
C.2:    DC.B    115,117,110,100,97,121,0,109,111,110
        DC.B    100,97,121,0,116,117,101,115,100,97
        DC.B    121,0,119,101,100,110,101,115,100,97
        DC.B    121,0,116,104,117,114,115,100,97,121
        DC.B    0,102,114,105,100,97,121,0,115,97
        DC.B    116,117,114,100,97,121,0,32,103,105
        DC.B    109,109,101,32,97,32,100,97,116,101
        DC.B    58,46,46,46,0,37,50,100,32,37
        DC.B    50,100,32,37,52,100,0,32,37,100
        DC.B    10,0,37,115,10,0,37,115,10,0
        DC.B    37,115,10,0,37,115,10,0,37,115
        DC.B    10,0,37,115,10,0,37,115,10,0
*zeller(day,month,year)
        DS.W    0

        XDEF    ZELLER
ZELLER:
*     int day,month,year;
*     {
        LINK    A6,#-C.15
*          int temp,yr1,yr2;
*     
*     if (month<3){ month+=10;year-=1;}
C.15    EQU     12
        MOVE.L  12(A6),A1
        LEA     3,A0
        CMP.L   A0,A1
        BGE     C.16
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
        BRA     C.17
C.16:
        MOVE.L  12(A6),A1
        LEA     2,A0
        SUB.L   A0,A1
        MOVE.L  A1,A0   ;
        MOVE.L  A0,12(A6)
C.17:
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
