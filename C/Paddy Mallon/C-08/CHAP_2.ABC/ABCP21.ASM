*/* p21  ABC  */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP21 GST QC Compiler 15:52 Sunday    30/11/86 
        OPT ABS
*/* tested and working ok 23/11/86             */
*
*main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*     {         int length,width,depth;
        LINK    A6,#-C.3
*               int ticks=200;
        LEA     200,A0
        MOVE.L  A0,-16(A6)
*      
*    
*
*          length = 20; width = 26 ; depth = 4;
C.3     EQU     16
        LEA     20,A0
        MOVE.L  A0,-4(A6)
        LEA     26,A0
        MOVE.L  A0,-8(A6)
        LEA     4,A0
        MOVE.L  A0,-12(A6)
*          printf("surface area = ");
        PEA     C.2+0(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*          printf("%d\n",surface(length,width,depth));
        PEA     C.2+16(PC)
        MOVE.L  -4(A6),-(SP)
        MOVE.L  -8(A6),-(SP)
        MOVE.L  -12(A6),-(SP)
        MOVEQ   #3,D2
        JSR     SURFACE-M$(A4)
        ADD.W   #12,SP
        MOVE.L  A0,-(SP)
        MOVEQ   #2,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #8,SP
*             
*         
*          delay(ticks);
        MOVE.L  -16(A6),-(SP)
        MOVEQ   #1,D2
        JSR     DELAY-M$(A4)
        ADDQ.L  #4,SP
*     }
        UNLK    A6
        RTS
C.2:    DC.B    115,117,114,102,97,99,101,32,97,114
        DC.B    101,97,32,61,32,0,37,100,10,0
*
*surface(len,wid,dep)
        DS.W    0

        XDEF    SURFACE
SURFACE:
*     int len,wid,dep;
*     { return(2*(len*wid + wid*dep + dep*len));}
        LINK    A6,#-C.5
C.5     EQU     0
        XREF    C.MULT
        MOVE.L  16(A6),A1
        MOVE.L  12(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  A0,-(SP)
        MOVE.L  12(A6),A1
        MOVE.L  8(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        MOVE.L  A0,-(SP)
        MOVE.L  8(A6),A1
        MOVE.L  16(A6),A0
        JSR     C.MULT-M$(A4)
        MOVE.L  (SP)+,A1
        ADD.L   A1,A0
        LEA     2,A1
        JSR     C.MULT-M$(A4)
        UNLK    A6
        RTS
*
*
        XREF    DELAY
        XREF    PRINTF
        END
