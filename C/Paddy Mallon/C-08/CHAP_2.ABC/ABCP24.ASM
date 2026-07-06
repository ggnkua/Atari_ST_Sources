*/* p24 eg2.7  ABC  */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP24 GST QC Compiler 15:55 Sunday    30/11/86 
        OPT ABS
*/* tested 22/11/86 this version runs ok   */
*
* 
*
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {         int length,width,depth,area;
        LINK    A6,#-C.3
*               int ticks=200;
        LEA     200,A0
        MOVE.L  A0,-20(A6)
*      
*    
*
*          length = 20; width = 26 ; depth = 4;
C.3     EQU     20
        LEA     20,A0
        MOVE.L  A0,-4(A6)
        LEA     26,A0
        MOVE.L  A0,-8(A6)
        LEA     4,A0
        MOVE.L  A0,-12(A6)
*          surface(length,width,depth,&area);
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -8(A6),-(SP)
        MOVE.L  -12(A6),-(SP)
        PEA     -16(A6)
        MOVEQ   #4,D2
        JSR     SURFACE-M$(A4)
        ADD.W   #16,SP
*          printf("surface area = %d\n",area);
        PEA     C.2+0(PC)
        MOVE.L  -16(A6),-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*             
*         
*          delay(ticks);
        MOVE.L  -20(A6),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    115,117,114,102,97,99,101,32,97,114
        DC.B    101,97,32,61,32,37,100,10,0
*
*surface(len,wid,dep,addr)
        DS.W    0

        XDEF    SURFACE
SURFACE:
*     int len,wid,dep,*addr;
*     { *addr = (2*(len*wid + wid*dep + dep*len));}
        LINK    A6,#-C.5
C.5     EQU     0
        XREF    C.MULT
        MOVE.L  8(A6),-(SP)
        MOVE.L  20(A6),A1
        MOVE.L  16(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  A0,-(SP)
        MOVE.L  16(A6),A1
        MOVE.L  12(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        MOVE.L  12(A6),A1
        MOVE.L  20(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        LEA     2,A1
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        MOVE.L  A0,(A1)
        UNLK    A6
        RTS
*
*
        XREF    DELAY
        XREF    PRINTF
        END
