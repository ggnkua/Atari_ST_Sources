         TTL - SUB4 - Display Some Specific Items V15 - 19 Jul 91

* DM19JUL : INPDRV/ROW

         INCLUDE  'EQU.ASM'
         INCLUDE  'TOS.ASM'

TPLAN    EQU      (ITDVLEN+ITSKLEN)/4
         XDEF     DSPSPD,DSPSCO,DSPSCR,DSPLAP,DSPSTG,DSPTIM
         XDEF     DSPTMR,DSPTMQ,DSPGP,INSADIG
         XDEF     DSPPRO,DSPLIG,DSPVRO,DSPTXT
         XDEF     DSPINI,INPINI,DSPDRV,INPDRV,DSPMSG

         XREF     DSPITN,DSPITN0,DSPITE,ERAITE,DSPMED,FLIPFLOP
         XREF     ACTSCR,CURSCR,MPLAY
         XREF     ALPHA,JOY,CNVASCI
         XREF     SYNC
         XREF     BUFRECE,PNTRECE       

* Item Table Entry Definition for Non Erasable Items (32 Bytes)

* Road Independant Item V6 (32)
*        0     DC.L  Line Address Offset in Screen #1 (y)
*        4     DC.L  Line Address Offset in Screen #2 (y)
*        8     DS.W  1 (Dummy)
*        10    DC.L  Position in Line in Pixels on Screen #1 (x)
*        14    DC.L  Position in Line in Pixels on Screen #2 (x)
*        18    DS.W  2 (Dummy)
*        22    DC.L  Item Address in Item Screen (Bottom Left)
*        26    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        27    DC.B  Width in 4*Words Units
*        28    DC.W  Heigth-1 in # of Lines
*        30    DC.W  End of Line Position if Moving Item

* Item Table Entry Definition for Erasable Items (32 Bytes)
*
*        0     DC.L  Line Address Offset in Screen #1 (y)
*        4     DC.L  Line Address Offset in Screen #2 (y)
*        8     DC.L  Position in Line in Pixels on Screen #1 (x)
*        12    DC.L  Position in Line in Pixels on Screen #2 (x)
*        16    DC.L  End Position in Line (#) in Pixels (x)
*        20    DS.W  1 (Dummy)
*        22    DC.L  Item Address in Item Screen (Bottom Left)
*        26    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        27    DC.B  Width in 4*Words Units
*        28    DC.W  Heigth-1 in # of Lines
*        30    DS.W  1 Dummy

* DSPSPD - Display Speed
*          A0 Points to SPEDIG

DSPSPD: LEA.L  NUMSPD(PC),A5
        CLR.W   D0
        CLR.W   D1
        CLR.W   D2
        CLR.W   D3
        CLR.W   D4
        MOVE.W  (A0)+,D5
        CMP.W   #10,D5
        BEQ.S   CHIF2
        ADD.W   D5,D5
        ADD.W   D5,D5
        MOVE.L  0(A5,D5.W),A1
        MOVE.W  (A1),D4
        LSR.W   #5,D4
        MOVE.W  -40(A1),D3
        LSR.W   #5,D3
        MOVE.W  -80(A1),D2
        LSR.W   #5,D2
        MOVE.W  -120(A1),D1
        LSR.W   #5,D1
        MOVE.W  -160(A1),D0
        LSR.W   #5,D0
CHIF2:
        MOVE.W  (A0)+,D5
        CMP.W   #10,D5
        BEQ.S   CHIF3
        ADD.W   D5,D5
        ADD.W   D5,D5
        MOVE.L  0(A5,D5.W),A1
        MOVE.B  (A1),D4
        LSR.B   #1,D4
        MOVE.B  -40(A1),D3
        LSR.B   #1,D3
        MOVE.B  -80(A1),D2
        LSR.B   #1,D2
        MOVE.B  -120(A1),D1
        LSR.B   #1,D1
        MOVE.B  -160(A1),D0
        LSR.B   #1,D0
CHIF3:
        MOVE.W  (A0),D5
        ADD.W   D5,D5
        ADD.W   D5,D5
        MOVE.L  0(A5,D5.W),A1
        MOVE.B  (A1),D5
        ROL.B   #3,D5
        OR.B    D5,D4
        MOVE.B  -40(A1),D5
        ROL.B   #3,D5
        OR.B    D5,D3
        MOVE.B  -80(A1),D5
        ROL.B   #3,D5
        OR.B    D5,D2
        MOVE.B  -120(A1),D5
        ROL.B   #3,D5
        OR.B    D5,D1
        MOVE.B  -160(A1),D5
        ROL.B   #3,D5
        OR.B    D5,D0
        MOVE.L  CURSCR,A0
        ADD.W   #30800,A0
        MOVEQ   #0,D5
        MOVE.W  D4,(A0)+
        MOVE.L  D5,(A0)+
        MOVE.W  D4,(A0)
        LEA.L   -166(A0),A0
        MOVE.W  D3,(A0)+
        MOVE.L  D5,(A0)+
        MOVE.W  D3,(A0)
        LEA.L   -166(A0),A0
        MOVE.W  D2,(A0)+
        MOVE.L  D5,(A0)+
        MOVE.W  D2,(A0)
        LEA.L   -166(A0),A0
        MOVE.W  D1,(A0)+
        MOVE.L  D5,(A0)+
        MOVE.W  D1,(A0)
        LEA.L   -166(A0),A0
        MOVE.W  D0,(A0)+
        MOVE.L  D5,(A0)+
        MOVE.W  D0,(A0)
        RTS

NUMSPD   DC.L     ITDVEQU+31*160/4+104/4  0 
         DC.L     ITDVEQU+31*160/4+112/4  1
         DC.L     ITDVEQU+31*160/4+120/4  2
         DC.L     ITDVEQU+31*160/4+128/4  3
         DC.L     ITDVEQU+31*160/4+136/4  4
         DC.L     ITDVEQU+31*160/4+144/4  5
         DC.L     ITDVEQU+41*160/4+104/4  6
         DC.L     ITDVEQU+41*160/4+112/4  7 
         DC.L     ITDVEQU+41*160/4+120/4  8
         DC.L     ITDVEQU+59*160/4+120/4  9 
         DC.L     ITDVEQU+31*160/4+24/4  Space

* DSPSCO - Display Scores in Vroom Screen
*        Input :  A5 Points to NUMSCO
*                 A0 Points to SCODIG
*                 D0 Contains Line in Screen

DSPSCO
         MOVE.L   A0,-(A7)    Save Registers
         MOVE.L   A5,-(A7)    .
         MOVE.L   D0,-(A7)
         MOVE     (A0),D5     Get Ten Thousands
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #102,10(A5,D3)
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   4(A7),A5    Restore Registers
         MOVE.L   8(A7),A0    .
         MOVE     2(A0),D5    Get Thousands
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #110,10(A5,D3) 
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   4(A7),A5    Restore Registers
         MOVE.L   8(A7),A0    .
         MOVE     4(A0),D5    Get Hundreds
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #118,10(A5,D3)
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   4(A7),A5    Restore Registers
         MOVE.L   8(A7),A0    .
         MOVE     6(A0),D5    Get Tens
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #126,10(A5,D3) 
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   (A7)+,D0
         MOVE.L   (A7)+,A5    Restore Registers and Stack
         MOVE.L   (A7)+,A0    .
         MOVE     8(A0),D5    Get Units
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #134,10(A5,D3) 
         MOVE.L   D0,0(A5,D3)
         JSR      DSPITN0
         RTS

* DSPTIM - Display TIM in Med Res
*        Input :  A5 Points to NUMMED*
*                 A0 Points to TIMDIG
*                 D0.L Contains Line*160 in Screen
*                 D1.L Contains Column in Screen

DSPTIM
         MOVE.L   A0,-(A7)    Save Registers
         MOVE.L   A5,-(A7)    .
         MOVE.L   D0,-(A7)
         MOVE.L   D1,-(A7)
         MOVE     (A0),D5     Get Ten Minutes
         CMPI     #10,D5      Space?
         BEQ.S    DSPTIM0
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
DSPTIM0  MOVE.L   8(A7),A5    Restore Registers
         MOVE.L   12(A7),A0    .
         MOVE     2(A0),D5    Get Minutes
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)     Advance in Line
         MOVE.L   (A7),10(A5,D3) 
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   8(A7),A5
         MOVE     #11,D5      Get '
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)     Advance in Line
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   8(A7),A5    Restore Registers
         MOVE.L   12(A7),A0    .
         MOVE     4(A0),D5    Get Ten Seconds
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   8(A7),A5    Restore Registers
         MOVE.L   12(A7),A0    .
         MOVE     6(A0),D5    Get Seconds
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)
         MOVE.L   (A7),10(A5,D3) 
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   8(A7),A5
         MOVE     #12,D5      Get "
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)     Advance in Line
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   8(A7),A5    Restore Registers
         MOVE.L   12(A7),A0    .
         MOVE     8(A0),D5    Get Dixiemes
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,(A7)
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
         MOVE.L   (A7)+,D1
         MOVE.L   (A7)+,D0
         MOVE.L   (A7)+,A5    Restore Registers
         MOVE.L   (A7)+,A0    .
         MOVE     10(A0),D5   Get Centiemes
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,D1
         MOVE.L   D1,10(A5,D3)
         MOVE.L   D0,0(A5,D3)
         JSR      DSPMED
         RTS

* DSPGP - Display GP in Med Res
*        Input :  A5 Points to NUMMED*
*                 A0 Points to Tens/units Table (2 Words)
*                 D0.L Contains Line*160 in Screen
*                 D1.L Contains Column in Screen

DSPGP
         MOVE.L   A0,-(A7)    Save Registers
         MOVE.L   A5,-(A7)    .
         MOVE.L   D0,-(A7)
         MOVE.L   D1,-(A7)
         MOVE     (A0),D5     Get Tens
         CMPI     #10,D5      Space
         BEQ.S    DSPGP1
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   (A7),10(A5,D3)
         MOVE.L   4(A7),0(A5,D3)
         JSR      DSPMED
DSPGP1   MOVE.L   (A7)+,D1
         MOVE.L   (A7)+,D0
         MOVE.L   (A7)+,A5    Restore Registers
         MOVE.L   (A7)+,A0    .
         MOVE     2(A0),D5    Get Units
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         ADDI.L   #6,D1
         MOVE.L   D1,10(A5,D3)
         MOVE.L   D0,0(A5,D3)
         JSR      DSPMED
         RTS

* DSPSCR - Display Scores in Game Screen
*        Input :  A5 Points to NUMSCR
*                 A0 Points to SCODIG

DSPSCR
         MOVE.W   ECDIG(PC),D0
         EOR.W    #$8,D0
         MOVE.W   D0,ECDIG
         LEA.L    SAVDIG(PC),A4
         ADD.W    D0,A4
         CLR.W   D0
         CLR.W   D1
         CLR.W   D2
         CLR.W   D3
         CLR.W   D4
         MOVE.W   4(A0),D5
         CMP.W    (A4),D5
         BNE.S    SCRGCH
         ADDQ.W   #4,A0
         BRA      SCRDRT
SCRGCH:  MOVE.W   D5,(A4)
         MOVE     (A0)+,D5     Get Ten Thousands
         CMP.W    #10,D5
         BEQ.S    SCR1
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         LSR.W    #3,D0
         MOVE.W   -40(A2),D1
         LSR.W    #3,D1
         MOVE.W   -80(A2),D2
         LSR.W    #3,D2
         MOVE.W   -120(A2),D3
         LSR.W    #3,D3
         MOVE.W   -160(A2),D4
         LSR.W    #3,D4
SCR1:    MOVE     (A0)+,D5     Get Thousands
         CMP.W    #10,D5
         BEQ.S    SCR2
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D0
         LSR.B    #1,D0
         MOVE.B   -40(A2),D1
         LSR.B    #1,D1
         MOVE.B   -80(A2),D2
         LSR.B    #1,D2
         MOVE.B   -120(A2),D3
         LSR.B    #1,D3
         MOVE.B   -160(A2),D4
         LSR.B    #1,D4
SCR2:    MOVE     (A0),D5     Get hundreds
         CMP.W    #10,D5
         BEQ.S    SCR3
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVEQ    #0,D5
         MOVE.W   (A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D0
         MOVEQ    #0,D5
         MOVE.W   -40(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D1
         MOVEQ    #0,D5
         MOVE.W   -80(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D2
         MOVEQ    #0,D5
         MOVE.W   -120(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D3
         MOVEQ    #0,D5
         MOVE.W   -160(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D4
SCR3:    MOVE.L   CURSCR,A3
         ADD.W    #(35*160)+88,A3
         BSR      AFDIG
         CLR.W   D0
         CLR.W   D1
         CLR.W   D2
         CLR.W   D3
         CLR.W   D4
SCRDRT   MOVE     (A0)+,D5     Get hundreds right
         CMP.W    #10,D5
         BEQ.S    SCR4
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         ADD.W    D0,D0
         MOVE.W   -40(A2),D1
         ADD.W    D1,D1
         MOVE.W   -80(A2),D2
         ADD.W    D2,D2
         MOVE.W   -120(A2),D3
         ADD.W    D3,D3
         MOVE.W   -160(A2),D4
         ADD.W    D4,D4
SCR4:    MOVE     (A0)+,D5     Get Tens
         CMP.W    #10,D5
         BEQ.S    SCR5
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #5,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D4
SCR5:    MOVE     (A0),D5     Get units
         CMP.W    #10,D5
         BEQ.S    SCR6
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D5
         LSR.B    #3,D5
         OR.B     D5,D0
         MOVE.B   -40(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D1
         MOVE.B   -80(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D4
SCR6:    MOVE.L   CURSCR,A3
         ADD.W    #(35*160)+96,A3
         BSR      AFDIG
         RTS

AFDIG:   MOVE.W   D0,D5
         NOT.W    D5
         MOVE.W   D5,(A3)
         MOVE.W   D0,4(A3)
         MOVE.W   D1,D5
         NOT.W    D5
         MOVE.W   D5,-160(A3)
         MOVE.W   D1,-160+4(A3)
         MOVE.W   D2,D5
         NOT.W    D5
         MOVE.W   D5,-320(A3)
         MOVE.W   D2,-320+4(A3)
         MOVE.W   D3,D5
         NOT.W    D5
         MOVE.W   D5,-480(A3)
         MOVE.W   D3,-480+4(A3)
         MOVE.W   D4,D5
         NOT.W    D5
         MOVE.W   D5,-640(A3)
         MOVE.W   D4,-640+4(A3)
         RTS
* DSPTMR - Display Times in Racing Screen
*        Input :  A5 Points to NUMSCR
*                 A0 Points to TIMDIG
*                 D0.L Contains Line*160 in Screen

DSPTMR
         MOVE.L   D0,D7
         MOVE.W   ECDIG(PC),D0
         EOR.W    #$8,D0
         MOVE.W   D0,ECDIG
         LEA.L    SAVDIG(PC),A4
         ADD.W    D0,A4
         CLR.W    D0
         CLR.W    D1
         CLR.W    D2
         CLR.W    D3
         CLR.W    D4
         MOVE.W   2(A0),D5
         CMP.W    (A4),D5
         BNE.S    TMRGC1
         ADDQ.W   #4,A0
         BRA      TMRDR1
TMRGC1:  MOVE.W   D5,(A4)
         MOVE     (A0)+,D5     Get Ten minutes
         CMP.W    #10,D5
         BEQ.S    TMR1
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         LSR.W    #4,D0
         MOVE.W   -40(A2),D1
         LSR.W    #4,D1
         MOVE.W   -80(A2),D2
         LSR.W    #4,D2
         MOVE.W   -120(A2),D3
         LSR.W    #4,D3
         MOVE.W   -160(A2),D4
         LSR.W    #4,D4
TMR1:    MOVE     (A0)+,D5     Get minutes
*         CMP.W    #10,D5
*         BEQ.S    TMR2
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D5
         LSR.B    #2,D5
         OR.B     D5,D0
         MOVE.B   -40(A2),D5
         LSR.B    #2,D5
         OR.B     D5,D1
         MOVE.B   -80(A2),D5
         LSR.B    #2,D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         LSR.B    #2,D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         LSR.B    #2,D5
         OR.B     D5,D4
TMR2:    MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #96,A3
         BSR      AFDIG
         CLR.W   D0
         CLR.W   D1
         CLR.W   D2
         CLR.W   D3
         CLR.W   D4
TMRDR1   MOVE.W   2(A0),D5
         CMP.W    2(A4),D5
         BNE.S    TMRGC2
         ADDQ.W   #4,A0
         BRA      TMRDR2
TMRGC2:  MOVE.W   D5,2(A4)
         MOVE     #11*32,D5     Get '
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   -80(A2),D2
         ADD.W    D2,D2
         ADD.W    D2,D2
         MOVE.W   -120(A2),D3
         ADD.W    D3,D3
         ADD.W    D3,D3
         MOVE.W   -160(A2),D4
         ADD.W    D4,D4
         ADD.W    D4,D4
         MOVE     (A0)+,D5     Get Ten seconds
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #3,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D4
TMR3:    MOVE     (A0)+,D5     Get seconds
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D0
         LSR.B    #1,D0
         MOVE.B   -40(A2),D1
         LSR.B    #1,D1
         MOVE.B   -80(A2),D2
         LSR.B    #1,D2
         MOVE.B   -120(A2),D3
         LSR.B    #1,D3
         MOVE.B   -160(A2),D4
         LSR.B    #1,D4
TMR4:    MOVE     #12*32,D5     Get "
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVEQ    #0,D5
         MOVE.W   -80(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D2
         MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #104,A3
         BSR      AFDIG
         CLR.W   D0
         CLR.W   D1
         CLR.W   D2
         CLR.W   D3
         CLR.W   D4
TMRDR2   MOVE     #12*32,D5     Get "
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   -80(A2),D2
         ADD.W    D2,D2
         MOVE.W   -120(A2),D3
         ADD.W    D3,D3
         MOVE.W   -160(A2),D4
         ADD.W    D4,D4
         MOVE     (A0)+,D5     Get Ten cents
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #5,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D4
TMR5:    MOVE     (A0),D5     Get cents
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D5
         LSR.B    #3,D5
         OR.B     D5,D0
         MOVE.B   -40(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D1
         MOVE.B   -80(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         LSR.B    #3,D5
         OR.B     D5,D4
TMR6:    MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #112,A3
         BSR      AFDIG
         RTS

* DSPTMQ - Display Times in Qualif Screen
*        Input :  A5 Points to NUMSCR
*                 A0 Points to TIMDIG
*                 D0.L Contains Line*160 in Screen
             
DSPTMQ
         MOVE.L   D0,D7
         MOVE.W   ECDIG(PC),D0
         EOR.W    #$8,D0
         MOVE.W   D0,ECDIG
         LEA.L    SAVDIG(PC),A4
         ADD.W    D0,A4
         MOVEQ    #0,D0
         MOVEQ    #0,D1
         MOVEQ    #0,D2
         MOVEQ    #0,D3
         MOVEQ    #0,D4
         MOVE.W   (A0),D5
         CMP.W    (A4),D5
         BEQ.S    TMQDR0
         MOVE.W   D5,(A4)
         CMP.W    #10,D5
         BEQ.S    TMQDR0
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         ADD.L    D0,D0
         ADD.L    D0,D0
         SWAP     D0
         MOVE.W   -40(A2),D1
         ADD.L    D1,D1
         ADD.L    D1,D1
         SWAP     D1
         MOVE.W   -80(A2),D2
         ADD.L    D2,D2
         ADD.L    D2,D2
         SWAP     D2
         MOVE.W   -120(A2),D3
         ADD.L    D3,D3
         ADD.L    D3,D3
         SWAP     D3
         MOVE.W   -160(A2),D4
         ADD.L    D4,D4
         ADD.L    D4,D4
         SWAP     D4
         MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #80,A3
         BSR      AFDIG
TMQDR0   MOVE.W   4(A0),D5
         CMP.W    2(A4),D5
         BNE.S    TMQGC1
         ADDQ.W   #4,A0
         BRA      TMQDR1
TMQGC1:  MOVE.W   D5,2(A4)
         MOVE     (A0)+,D5     Get Ten minutes
         CMP.W    #10,D5
         BEQ.S    TMQ2
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         LSL.W    #2,D0
         MOVE.W   -40(A2),D1
         LSL.W    #2,D1
         MOVE.W   -80(A2),D2
         LSL.W    #2,D2
         MOVE.W   -120(A2),D3
         LSL.W    #2,D3
         MOVE.W   -160(A2),D4
         LSL.W    #2,D4
TMQ2     MOVE     (A0)+,D5     Get minutes
*         CMP.W    #10,D5
*         BEQ.S    TMQ3
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #4,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #4,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #4,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #4,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #4,D5
         OR.W     D5,D4
TMQ3     MOVE     #11*32,D5     Get '
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   -80(A2),D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         OR.B     D5,D4
         MOVE     (A0),D5     Get ten seconds
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   (A2),D5
         LSR.B    #5,D5
         OR.B     D5,D0
         MOVE.B   -40(A2),D5
         LSR.B    #5,D5
         OR.B     D5,D1
         MOVE.B   -80(A2),D5
         LSR.B    #5,D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         LSR.B    #5,D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         LSR.B    #5,D5
         OR.B     D5,D4
         MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #88,A3
         BSR      AFDIG
TMQDR1   MOVE.W   4(A0),D5
         CMP.W    4(A4),D5
         BNE.S    TMQGC2
         ADDQ.W   #4,A0
         BRA      TMQDR2
TMQGC2:  MOVE.W   D5,4(A4)
         MOVE     (A0)+,D5     Get ten seconds
         LSL.W    #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         LSL.W    #3,D0
         MOVE.W   -40(A2),D1
         LSL.W    #3,D1
         MOVE.W   -80(A2),D2
         LSL.W    #3,D2
         MOVE.W   -120(A2),D3
         LSL.W    #3,D3
         MOVE.W   -160(A2),D4
         LSL.W    #3,D4
         MOVE     (A0)+,D5     Get seconds
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #3,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #3,D5
         OR.W     D5,D4
         MOVE     #12*32,D5     Get "
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.B   -80(A2),D5
         LSR.B    #1,D5
         OR.B     D5,D2
         MOVE.B   -120(A2),D5
         LSR.B    #1,D5
         OR.B     D5,D3
         MOVE.B   -160(A2),D5
         LSR.B    #1,D5
         OR.B     D5,D4
         MOVE     (A0),D5     Get ten cents
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVEQ    #0,D5
         MOVE.W   (A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D0
         MOVEQ    #0,D5
         MOVE.W   -40(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D1
         MOVEQ    #0,D5
         MOVE.W   -80(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D2
         MOVEQ    #0,D5
         MOVE.W   -120(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D3
         MOVEQ    #0,D5
         MOVE.W   -160(A2),D5
         ADD.L    D5,D5
         SWAP     D5
         OR.W     D5,D4
         MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #96,A3
         BSR      AFDIG
TMQDR2   MOVE     (A0)+,D5     Get ten cents
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D0
         ADD.W    D0,D0
         MOVE.W   -40(A2),D1
         ADD.W    D1,D1
         MOVE.W   -80(A2),D2
         ADD.W    D2,D2
         MOVE.W   -120(A2),D3
         ADD.W    D3,D3
         MOVE.W   -160(A2),D4
         ADD.W    D4,D4
         MOVE     (A0),D5     Get cents
         LSL      #5,D5
         MOVE.L   22(A5,D5.W),A2
         ADD.W    #TPLAN,A2
         MOVE.W   (A2),D5
         LSR.W    #5,D5
         OR.W     D5,D0
         MOVE.W   -40(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D1
         MOVE.W   -80(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D2
         MOVE.W   -120(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D3
         MOVE.W   -160(A2),D5
         LSR.W    #5,D5
         OR.W     D5,D4
         MOVE.L   CURSCR,A3
         ADD.L    D7,A3
         ADD.W    #104,A3
         BSR      AFDIG
         RTS
*
* DSPLAP - Display Lap Number
*        Input :  A5 Points to NUMSCR
*                 D5 Contains LAP
*                 D6 Contains MGAME

DSPLAP   CMPI     #-8,D6      If Qualif, No Lap Display
         BNE.S    DSPLAP0     If NE, No 
         RTS
DSPLAP0  EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   CURSCR,A4
         ADDA.L   #35*160+144,A4
         TST.L    D6            Train in VR2?
         BLT.S    DSPLAP0A      If LT, Yes
         CMPI.L   #24,D6        Train in VR1?        
         BNE.S    DSPLAP1       If NE, Racing/Demo/Arcade
DSPLAP0A ADDA.L   #13*160,A4    Train (35+13=48)
DSPLAP1  MOVE.L   #$FFFFFFFF,D4
         MOVEQ    #$00000000,D5
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         SUBA.L   #160,A4
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         SUBA.L   #160,A4
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         SUBA.L   #160,A4
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         SUBA.L   #160,A4
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         SUBA.L   #160,A4
         MOVE.L   D4,(A4)
         MOVE.L   D5,4(A4)
         MOVE.L   ACTSCR,D3
         MOVE.L   #35*160,0(A5,D3) Line
         MOVE.L   #292,10(A5,D3) Column 
         TST.L    D6            Arcade?
         BEQ.S    DSPLAP4       IF EQ, Yes
         BLT.S    DSPLAP2       Train in VR2
         CMPI.L   #24,D6        Train in VR1?
         BNE.S    DSPLAP3       If NE, Racing/Demo
DSPLAP2  MOVE.L   #48*160,0(A5,D3) Train         
DSPLAP3  MOVE.L   #294,10(A5,D3) Column
DSPLAP4  JSR      DSPITN0
         RTS
          
*
* DSPSTG - Display Stage Number
*        Input :  A5 Points to NUMSCR
*                 D5 Contains Stage
*                 D6 Contains Arcade/Racing/Qualif/Train

DSPSTG   EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5
         MOVE.L   ACTSCR,D3
         MOVE.L   #35*160,0(A5,D3) Line
         MOVE.L   #256,10(A5,D3) Column
         TST.L    D6             Arcade?
         BEQ.S    DSPSTG1        If EQ, Arcade
         BLT.S    DSPSTG0A       If LT, Qualif
         CMPI.L   #24,D6         Training
         BNE.S    DSPSTG0B
         MOVE.L   #56*160,0(A5,D3) Training
         BRA.S    DSPSTG0C
DSPSTG0A MOVE.L   #52*160,0(A5,D3) Line Qualif
         MOVE.L   #259,10(A5,D3) Column       
         BRA.S    DSPSTG1                          
DSPSTG0B MOVE.L   #43*160,0(A5,D3) Line Racing/Demo
DSPSTG0C MOVE.L   #294,10(A5,D3) Column         
DSPSTG1  JSR      DSPITN0        Display Stage
         RTS

* DSPMSG - Display Message in Low Res (Ex : Communication)
*        Input :  A0 Points to Message byte string

DSPMSG   LEA.L    ACTSCR,A5     Blank 7 Lines
         MOVE.L   (A5),D5       .
         MOVE.L   4(A5,D5),A1   .
         ADDA.L   #(200-7)*160,A1    
         MOVE.L   #(7*20)-1,D1       
DSPMSG1  MOVE.L   #$0000FFFF,(A1)+
         MOVE.L   #$FFFFFFFF,(A1)+     .
         DBF      D1,DSPMSG1    .
         MOVE.L   #0,DSPMSG6    Init Position in Line
DSPMSG3  MOVEQ    #0,D5
         TST.B    (A0)          End of message
         BLT.S    DSPMSG5
         MOVE.B   (A0)+,D5      Get Initial
         MOVE.L   A0,-(A7)
         LEA.L    ALPHA,A5     
         LSL      #5,D5         Size of Item
         ADDA.L   D5,A5         .
         MOVE.L   ACTSCR,D3
         ADDI.L   #7,DSPMSG6
         MOVE.L   DSPMSG6,10(A5,D3) Poisition in Line
         MOVE.L   #199*160,0(A5,D3) Bottom Line
         JSR      DSPITN0
         MOVE.L   (A7)+,A0
         MOVE.L   #10000,D0         Waiting loop
DSPMSG4  DBF      D0,DSPMSG4
         BRA      DSPMSG3
DSPMSG5  RTS
DSPMSG6  DC.L     0

* DSPINI - Display Players in Vroom Screen
*        Input :  A5 Points to ALPHA
*                 A0 Points to Players 4 Words
*                 D0 Contains Line in Screen
DSPINI
         MOVE.L   A0,-(A7)    Save Registers
         MOVE.L   A5,-(A7)    .
         MOVE.L   D0,-(A7)
         MOVE     (A0),D5     Get First Initial
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #236,10(A5,D3) 
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   4(A7),A5    Restore Registers
         MOVE.L   8(A7),A0
         MOVE     2(A0),D5    Get Second Initial
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #244,10(A5,D3) 
         MOVE.L   (A7),0(A5,D3)
         JSR      DSPITN0
         MOVE.L   (A7)+,D0    Restore Registers
         MOVE.L   (A7)+,A5    .
         MOVE.L   (A7)+,A0    .
         MOVE     4(A0),D5    Get Third Initial
         EXT.L    D5
         LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
         MOVE.L   ACTSCR,D3
         MOVE.L   #252,10(A5,D3) 
         MOVE.L   D0,0(A5,D3)
         JSR      DSPITN0
         RTS

* INPINI - Input Players Initials on Vroom Screen
*        Input :  Parameters on Stack

INPINI   BSR      RAW            Fisrt Letter
         TST      D0
         BLT.S    INPINI         If LT, BS
         BNE.S    INPINI13       If NE, CR
INPINI3  ADDI.L   #8,10(A7)      Advance on Line
         ADDI.L   #2,30(A7)      Advance in PLAYERS
INPINI4  BSR      RAW            Second Letter
         BEQ.S    INPINI6        If EQ, Letter
         BPL.S    INPINI13       If PL, CR
         SUBI.L   #8,10(A7)      BS on Line
         SUBI.L   #2,30(A7)      BS in PLAYERS
         BRA.S    INPINI
INPINI6  ADDI.L   #8,10(A7)      Advance on Line
         ADDI.L   #2,30(A7)      Advance in PLAYERS
INPINI7  BSR      RAW            Third Letter
         BEQ.S    INPINI9        If EQ, Letter
         BPL.S    INPINI13       If PL, CR
         SUBI.L   #8,10(A7)      BS on Line
         SUBI.L   #2,30(A7)      BS in PLAYERS
         BRA.S    INPINI4
INPINI9  MOVEQ    #0,D0
         MOVE     #$FF,-(A7)     Rawconio
         TOS      $6,1           .
         ADDQ.L   #4,A7
INPINI19 MOVE     JOY+6,D0       Any Character?
         BEQ.S    INPINI9
         CMP      #$E,D0         BS?
         BEQ.S    INPINI7        If EQ, Yes
INPINI10 CMP      #$1C,D0        CR?
         BNE.S    INPINI9        If NE, No
INPINI13 RTS

RAW      MOVE     JOY+6,D0       Any Character?
         BNE.S    RAW4
RAW2     SUBI     #1,8(A7)
         BNE.S    RAW3
         EORI.L   #$20,18(A7)     Switch Between Space and -
         MOVE     #400,8(A7)
RAW3     LEA.L     ACTSCR,A5      .
         MOVE.L   (A5),D5         .
         MOVE.L   22(A7),A5       Display Space or -
         ADDA.L   18(A7),A5       .
         MOVE.L   10(A7),0(A5,D5)  .
         MOVE.L   14(A7),10(A5,D5) .
         JSR      DSPITN0         .
         BRA.S    RAW
RAW4     CLR      JOY+6
         CMP      #$1C,D0         CR?
         BNE.S    RAW5            If NE, No
         MOVE     #1,D0
         RTS
RAW5     CMP      #$E,D0          BS?
         BNE.S    RAW6            If NE, No
         MOVE     #-1,D0
         RTS
RAW6     JSR      CNVASCI         Convert to ASCCI
         SUBI     #$41,D6         Test Between A and Z
         BLT.S    RAW             If LT, <A
         CMPI     #26,D6
         BPL.S    RAW             If PL, >Z
         MOVE.L   34(A7),A3       Store Letter in Player Initials
         MOVE     D6,(A3)         .
         LSL      #5,D6           *32
         LEA.L    ACTSCR,A5       .
         MOVE.L   (A5),D5         .
         MOVE.L   26(A7),A5       Display Space
         LEA.L    26*32(A5),A5    ADDA.L   #26*32,A5       .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         MOVE.L   D6,-(A7)        .
         JSR      DSPITN0         .
         MOVE.L   (A7)+,D6
         LEA.L    ACTSCR,A5       .
         MOVE.L   (A5),D5         .
         MOVE.L   26(A7),A5       Display Letter
         ADDA.L   D6,A5           .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         JSR      DSPITN0         .
         CLR      D0
         RTS                            

* DSPDRV - Display Driver in Medium Res Screen
*        Input :  A5 Points to ALPWHIT or ALPGREN 
*                 A0 Points to Driver 8 Bytes
*                 D0.L Contains Line*160
*                 D1.L Contains Column

DSPDRV
         MOVE.L   A5,DSPDRV2   Save Alphabet Address
         MOVE.L   D0,DSPDRV3   Line on Screen 
         MOVE.L   D1,DSPDRV4   Position in Line     
         MOVEQ    #8-1,D1      Init Loop on Initials
DSPDRV0  MOVE.B   (A0)+,D5     Get Initial
         BLT.S    DSPDRV1      If LT, End
         MOVE.L   A0,-(A7)
         MOVE.L   D1,-(A7)
         EXT      D5
         EXT.L    D5
         LSL      #5,D5        Size of Item
         MOVE.L   DSPDRV2,A5   Alpha
         ADDA.L   D5,A5        .
         MOVE.L   ACTSCR,D3
         ADDI.L   #7,DSPDRV4
         MOVE.L   DSPDRV4,10(A5,D3) 
         MOVE.L   DSPDRV3,0(A5,D3) Line
         JSR      DSPMED
         MOVE.L   (A7)+,D1
         MOVE.L   (A7)+,A0
         DBF      D1,DSPDRV0
DSPDRV1  RTS
DSPDRV2  DC.L     0
DSPDRV3  DC.L     0
DSPDRV4  DC.L     0


* INPDRV - Input Driver Initials in Visible Screen
*        Input :  Parameters on Stack

INPDRV   BSR      ROWI           Fisrt Letter
         TST      D0
         BEQ.S    INPDRV3        If EQ, Character
         BPL.S    INPDRV         If PL, BS       
         RTS                     If LT, CR or F1 or ESC : Exit
INPDRV3  ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV4  BSR      ROWJ           Second Letter
         BEQ.S    INPDRV6        If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV
INPDRV6  ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV7  BSR      ROWJ           Third Letter
         BEQ.S    INPDRV8        If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA      INPDRV4
INPDRV8  ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV9  BSR      ROWJ           Fourth Letter
         BEQ.S    INPDRV10       If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV7
INPDRV10 ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV11 BSR      ROWJ           Fifth Letter
         BEQ.S    INPDRV12       If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV9
INPDRV12 ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV13 BSR      ROWJ           Sixth Letter
         BEQ.S    INPDRV14       If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV11
INPDRV14 ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV15 BSR      ROWJ           Seventh Letter
         BEQ.S    INPDRV16       If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV13
INPDRV16 ADDI.L   #6,10(A7)      Advance on Line
         ADDI.L   #1,30(A7)      Advance in DRIVER

INPDRV17 BSR      ROWJ           Eigth Letter
         BEQ.S    INPDRV19       If EQ, Letter
         BLT      INPDRV20       If LT, CR or F1 or ESC
         SUBI.L   #6,10(A7)      BS on Line
         SUBI.L   #1,30(A7)      BS in DRIVER
         MOVE.L   30(A7),A3
         MOVE.B   #-1,(A3)
         BRA.S    INPDRV15

INPDRV19 MOVE     JOY+6,D0       Any Character?
         BEQ.S    INPDRV19       If EQ, No
         CMP      #$E,D0         BS?
         BEQ.S    INPDRV17       If EQ, Yes
         CMP      #$1C,D0        CR?
         BNE.S    INPDRV19       If NE, No
         MOVE     #-1,D0         Say CR
INPDRV20 RTS

ROWI     CLR      ROWIND
         BRA.S    ROW
ROWJ     MOVE     #1,ROWIND     
ROW      CMPI     #1,SYNC        Communication?
         BNE.S    ROW1
         CMPI     #8,PNTRECE
         BLT.S    ROW1
         MOVE.L   #BUFRECE,A5
         MOVE     #0,D0
         MOVE.B   (A5),D0       
         CMPI.B   #-11,D0        Escape Done by Other?
         BNE.S    ROW0
         MOVE     #-21,D0        Say ESC by Other
         RTS
ROW0     MOVE.B   (A5),D0        Fn done By Other? 
         BPL.S    ROW1
         EXT      D0
         SUBI     #10,D0         Say Fn by Other (-12 to -20)
         RTS
ROW1     MOVE     JOY+6,D0       Any Character?
         BNE.S    ROW4           If NE, Yes
ROW2     SUBI     #1,8(A7)
         BNE.S    ROW3
         EORI.L   #$20,18(A7)     Switch Between Space and -
         MOVE     #400,8(A7)
ROW3     LEA.L     ACTSCR,A5      .
         MOVE.L   (A5),D5         .
         MOVE.L   22(A7),A5       Display Space or -
         ADDA.L   18(A7),A5       .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         JSR      DSPMED          .
         BRA.S    ROW
ROW4     CLR      JOY+6           
         CMP      #$1C,D0         CR?
         BNE.S    ROW5            If NE, No
         LEA.L    ACTSCR,A5       Display Space
         MOVE.L   (A5),D5         .
         MOVE.L   26(A7),A5       .
         LEA.L    26*32(A5),A5    ADDA.L   #26*32,A5       .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         JSR      DSPMED          .
         MOVE     #-1,D0          Say CR
         RTS
ROW5     CMP      #$E,D0          BS?
         BNE.S    ROW6            If NE, No
         MOVE     #1,D0
         RTS
ROW6     CMP      #$3B,D0         F1 to F9?
         BLT.S    ROW7            If NE, No
         CMP      #$43,D0         
         BGT.S    ROW7
         TST      ROWIND          Fn only on First Char          
         BNE      ROW
         TST      MPLAY+2         Do not Restore if not all Circuits
         BNE.S    ROW7            
         SUBI     #$39,D0         Say Fn (-2=F1 to -10=F9)
         NEG      D0
         BRA.S    ROW7A
ROW7     CMP      #$01,D0         ESC?
         BNE.S    ROW8            If NE, No
         TST      ROWIND          ESC Only on First Char
         BNE      ROW
         MOVE     #-11,D0         Say ESC
ROW7A    
   
         RTS             
ROW8     JSR      CNVASCI         Convert to ASCII
         SUBI     #$41,D6         Test Between A and Z
         BLT      ROW             If LT, <A
         CMPI     #26,D6
         BPL      ROW             If PL, >Z
         MOVE.L   34(A7),A3       Store Letter in Player Initials
         MOVE.B   D6,(A3)         .
         LSL      #5,D6           *32
         LEA.L    ACTSCR,A5       .
         MOVE.L   (A5),D5         .
         MOVE.L   26(A7),A5       Display Space
         LEA.L    26*32(A5),A5    ADDA.L   #26*32,A5       .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         MOVE.L   D6,-(A7)        .
         JSR      DSPMED         .
         MOVE.L   (A7)+,D6
         LEA.L    ACTSCR,A5       .
         MOVE.L   (A5),D5         .
         MOVE.L   26(A7),A5       Display Letter
         ADDA.L   D6,A5           .
         MOVE.L   10(A7),0(A5,D5) .
         MOVE.L   14(A7),10(A5,D5) .
         JSR      DSPMED         .
         CLR      D0
         RTS          
ROWIND   DC.W     0

* DSPPRO - Display Profile Car
*        Input :A5 Points to PRFCAR Item Description

DSPPRO
         MOVE.L   A5,-(A7)        
         MOVE.L   #314,D0
         MOVE.L   #320,D1
         MOVE.L   ACTSCR,D5
         BEQ.S    DSPPRO1
         MOVE.L   #320,D0
         MOVE.L   #314,D1
DSPPRO1  MOVE.L   D0,10(A5)     Init Positions
         MOVE.L   D1,14(A5)     in
         ADDI.L   #128,D0       .
         ADDI.L   #128,D1       .
         MOVE.L   D0,42(A5)     Screen 1
         MOVE.L   D1,46(A5)     &
         MOVE.L   D0,74(A5)     Screen 2
         MOVE.L   D1,78(A5)     .

DSPPRO2  JSR      FLIPFLOP      Flip-Flop Screens
         MOVE.L   ACTSCR,D3
         MOVE.L   (A7),A5       PROCAR Pointer
         MOVE.L   10(A5,D3),D0  .
         CMP      30(A5),D0     .
         BEQ.S    DSPPRO3A      .
         SUB.L    #12,D0        Six pixels at a Time (2*6)
         CMP      30(A5),D0     .
         BPL.S    DSPPRO3       .
         MOVE     30(A5),D0     End With Item in Both Screens
DSPPRO3  MOVE.L   D0,10(A5,D3)
         MOVEM.L  D3/A5,-(A7)
         JSR      DSPITN0       Display First Part of Car
         MOVEM.L  (A7)+,D3/A5
DSPPRO3A ADDA.L   #32,A5        Point to Second part of Car
         MOVE.L   D3,D4
         LSL.L    #3,D4         *32
         ADDA.L   D4,A5
         MOVE.L   10(A5,D3),D0
         CMP      30(A5),D0     .
         BEQ.S    DSPPRO5       .
         SUB.L    #12,D0        Six pixels at a Time (2*6)
         CMP      30(A5),D0     .
         BPL.S    DSPPRO4       .
         MOVE     30(A5),D0     End With Item in Both Screens
DSPPRO4  MOVE.L   D0,10(A5,D3)
         JSR      DSPITN0       Display Second Part of Car
         BRA      DSPPRO2       .
DSPPRO5  ADDQ.L   #4,A7         Restore Stack
         RTS

* DSPVRO - Display Vroom Panning
*        Input : A5 Points to VROOM Item Description

DSPVRO
         MOVE     #0,30(A5)
         MOVE.L   A5,-(A7)
DSPVRO1  JSR      FLIPFLOP
         MOVE.L   (A7),A5         GAMPRO Pointer
         ADDQ     #5,30(A5)
         CMP      #116,30(A5)
         BPL.S    DSPVROF
         BSR      DSPIP          Display Item Panning Right
         BRA.S    DSPVRO1
DSPVROF  ADDQ     #4,A7
         RTS

* DSPIP - Pan Display for VROOM Message
*        INPUT :  A5 Points to VROOM Description
*                 A3 Points to ACTSCR

PLANEQU  EQU      (ITDVLEN+ITSKLEN)/4

DSPIP    MOVE.L   ACTSCR,D3   Get ACTSCR (0 or 4)
         MOVEQ    #0,D7       Wash D7
         MOVE.L   A5,A0       Point to Entry...
         MOVE.L   0(A0,D3),A1 Get Line Address Offset of Active Screen
         ADDA.L   CURSCR,A1   Get Line Address of Screen
         MOVE.L   A1,D0       Important!
         MOVE.L   10(A0,D3),D1 Get Position in Line
         MOVEQ    #0,D4       Wash D4
         MOVE     D1,D4
         LSR      #4,D4       Make it 4*Word Boundary
         LSL      #3,D4       .
         ADDA.L   D4,A1       Points to W. Addr.
         MOVE     28(A0),D7   Heigth-1 in # of Lines
         MOVE.L   22(A0),A4   Address of Item in Mem
DSPIP6   SWAP     D7          D7 High Now Contains Heigth-1
         CLR      D7
         MOVE.B   27(A0),D7   Get Width-1 in 4*Words Unit
         SUBQ     #1,D7       .
         MOVE.L   A1,A3       Save Screen Address
         MOVE.L   A4,A2       Save Item Addr. in Mem
         MOVE     30(A5),D5   Width in Pixels
DSPIP7   SUBI     #16,D5
         BLT.S    DSPIP8
         MOVE     (A2),(A3)+
         MOVE     1*PLANEQU(A2),(A3)+
         MOVE     2*PLANEQU(A2),(A3)+
         MOVE     3*PLANEQU(A2),(A3)+
         ADDQ.L   #2,A2
         DBF      D7,DSPIP7
         BRA.S    DSPIP9
DSPIP8   NEG      D5
         MOVE     (A2),D2
         LSR      D5,D2
         LSL      D5,D2
         SWAP     D2
         MOVE     1*PLANEQU(A2),D2
         LSR      D5,D2
         LSL      D5,D2
         MOVE     2*PLANEQU(A2),D3
         LSR      D5,D3
         LSL      D5,D3
         SWAP     D3
         MOVE     3*PLANEQU(A2),D3
         LSR      D5,D3
         LSL      D5,D3
         MOVE.L   D2,(A3)+
         MOVE.L   D3,(A3)+
DSPIP9   LEA.L    -160(A1),A1 SUBA.L   #160,A1 Next Line on Screen
         LEA.L    -40(A4),A4  SUBA.L   #40,A4  Next Line in Item
         SUB.L    #160,D0     Next Line Addres on Screen
         SWAP     D7          D7 Now Contains Heigth-1
         DBF      D7,DSPIP6   Previous Line
         RTS

* DSPLIG - Display Traffic Light
*        Input :A0 Points to LIG
*               A5 Points to LIGHT Item Description

DSPLIG   MOVE.L   A5,-(A7)
         TST      (A0)
         BLT      DSPLIG2        If LT, Display Green OFF, Red ON,Yellow Off
         SUBQ     #1,(A0)
         BLT.S    DSPLIG1        If LT, Display Green ON
         MOVEQ    #2,D5          Display Orange ON in Current Screen
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch to Previous Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7),A5        Display Orange ON in Previous Screen
         MOVEQ    #2,D5          .
         JSR      DSPITN         .
         MOVE.L   (A7),A5        Display Red OFF in Previous Screen
         MOVEQ    #1,D5          .
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch Back to Current Screen
         MOVE.L   (A3),D3
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .
         MOVE.L   (A7)+,A5       Display Red OFF in Current Screen       
         MOVEQ    #1,D5          .
         JSR      DSPITN         .
         RTS
DSPLIG1  MOVEQ    #4,D5          Display Green ON in Current Screen
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch to Previous Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7),A5        Display Green ON in Previous Screen
         MOVEQ    #4,D5          .
         JSR      DSPITN         .
         MOVE.L   (A7),A5        Display Orange OFF in Previous Screen
         MOVEQ    #3,D5          .
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch Back to Current Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7)+,A5       Display Orange OFF in Current Screen
         MOVEQ    #3,D5          .
         JSR      DSPITN         .
         RTS
DSPLIG2  MOVEQ    #0,D5          Display Red ON in Current Screen
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch to Previous Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7),A5        Display Red ON in Previous Screen
         MOVEQ    #0,D5          .
         JSR      DSPITN         .
         MOVE.L   (A7),A5        Display Orange OFF in Previous Screen
         MOVEQ    #3,D5          .
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch Back to Current Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7),A5        Display Orange OFF in Current Screen
         MOVEQ    #3,D5          .
         JSR      DSPITN         .
         MOVE.L   (A7),A5        Display Green OFF in Current Screen
         MOVEQ    #5,D5          .
         JSR      DSPITN         .
         LEA.L    ACTSCR,A3      Switch Back to Previous Screen
         MOVE.L   (A3),D3        .
         EORI.L   #4,D3          .
         MOVE.L   D3,(A3)        .
         MOVE.L   4(A3,D3),CURSCR .       
         MOVE.L   (A7)+,A5       Display Green OFF in Previous Screen
         MOVEQ    #5,D5          .
         JSR      DSPITN         .
         RTS

* DSPTXT - Display Text (GAME OVER and NEXT CIRCUIT)
*        Input :A5 Points to Txt Item Description

DSPTXT   MOVE     (A5)+,D0       Get # of Letters-1
         MOVE.L   A5,-(A7)       .
DSPTXT0  MOVE.L   (A7),A5
         MOVE     D0,-(A7)
         MOVE.L   ACTSCR,D3      Test Current
         BNE.S    DSPTXT1          .
         MOVE.L   #314,8(A5)     Screen #1
         MOVE.L   #320,12(A5)    .
         BRA      DSPTXT2
DSPTXT1  MOVE.L   #320,8(A5)     Screen #2
         MOVE.L   #314,12(A5)    .
DSPTXT2  JSR      FLIPFLOP       Flip Flop Screens
         MOVE.L   ACTSCR,D3
         MOVE.L   2(A7),A5       .
         MOVE.L   8(A5,D3),D0    .
         CMP.L    16(A5),D0      .
         BEQ.S    DSPTXT4        .
         SUB.L    #12,D0         Six pixels at a Time (2*6)
         CMP.L    16(A5),D0      .
         BPL.S    DSPTXT3        .
         MOVE.L   16(A5),D0      End With letter in Both Screens
DSPTXT3  MOVE.L   D0,8(A5,D3)
         CLR.L    D5             Erase Letter (G,A,...,E,R)
         LEA.L    ERASE,A4
         MOVE.L   2(A7),A5       GAMTXT Pointer
         JSR      ERAITE         .
         CLR.L    D5             Display Letter
         LEA.L    ERASE,A4
         MOVE.L   2(A7),A5       GAMTXT Pointer
         JSR      DSPITE         .
         BRA      DSPTXT2        .
DSPTXT4  LEA.L    ERASE,A4
         CLR.L    (A4)           Say erased in Screen 1
         CLR.L    4(A4)          and in Screen 2
         ADD.L    #32,2(A7)      Next Pointer in GAMTXT
         MOVE     (A7)+,D0
         DBF      D0,DSPTXT0
         ADDA.L   #4,A7          Restore Stack
         MOVE     #10,D0         Wait Loop
DSPTXT5  MOVE     #32000,D1      .
DSPTXT6  DBF      D1,DSPTXT6     .
         DBF      D0,DSPTXT5     .
         RTS
INSADIG  MOVE.L   #-1,SAVDIG
         MOVE.l   #-1,SAVDIG+4
         MOVE.L   #-1,SAVDIG+8
         MOVE.l   #-1,SAVDIG+12
         RTS
ECDIG    DC.W     0
SAVDIG   DC.l     -1,-1,-1,-1
ERASE    DC.L  0       Address for Later Erase in Screen #1
         DC.L  0       Address for Later Erase in Screen #2
         DC.L  ER1EQU  Address of Save Area #1
         DC.L  ER2EQU  Address of Save Area #2

         END
