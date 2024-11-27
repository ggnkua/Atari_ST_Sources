         TTL - SUB3 - Display Items with no Erase - V15 - 31 JUN 91

*DM31JUN : A faire chez JLL
 
         INCLUDE  'EQU.ASM'

         XDEF     DSPIS,DSPITN,DSPITN0
         XDEF     DSPITE,ERAITE,DSPMED

         XREF     adscrol,ACTSCR,CURSCR

PLANEQU  EQU      (ITDVLEN+ITSKLEN)/4

* DSPITN - Display Road Independant Non Erasable Item
*        Input :  D5 Item # (0,1,2,3,...)  for Non-Road Item (Long)
*                 A5 Points to Item Table           

* Road Independant Non Erasable Item (32)
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
*

DSPITN   LSL      #5,D5       Size of Item
         ADDA.L   D5,A5       .
DSPITN0  SUB.L    A1,A1       Clear A1
         MOVE.L   ACTSCR,D5   Screen #
         ADDA.L   0(A5,D5),A1 Point to Line Address of Item on Screen
         MOVE.W   12(A5,D5),D1 Get Position in Line  (Low Word)
         ADDA.L   #22,A5
         MOVE.L   CURSCR,A4
         ADDA.L   A4,A1
         ADDA.L   #32000-160,A4
         MOVE.L   (A5)+,A0    Address of Item in Mem
         CLR      D4
         MOVE.B   (A5)+,D4    Get Width in bytes
         LSL.W    #1,D4
         CLR      D5
         MOVE.B   (A5)+,D5    Get Width in 4 Words Units
         MOVE     (A5),D7     Heigth-1 in # of Lines
         ANDI     #$7FFF,D7   Skip Square Bit - DM31JUN
         BRA      DSPITN5B    DM31JUN

* DSPIS - Display Sky Item

DSPIS    MOVE.L   adscrol,A1
         SUBA.L   #160*HBCKEQU,A1 Point to Line Below Sky
         MOVE.L   ACTSCR,D5   Screen #
         ADDA.L   0(A5,D5),A1 Point to Line Address of Item on Screen
         MOVE.W   12(A5,D5),D1 Get Position in Line  (Low Word)
         ADDA.L   #22,A5
         MOVE.L   CURSCR,A4
         ADDA.L   A4,A1
         ADDA.L   #32000-160,A4
         MOVE.L   (A5)+,A0    Address of Item in Mem
         CLR      D4
         MOVE.B   (A5)+,D4    Get Width in bytes
         LSL.W    #1,D4
         CLR      D5
         MOVE.B   (A5)+,D5    Get Width in 4 Words Units
         MOVE     (A5),D7     Heigth-1 in # of Lines
         ANDI     #$7FFF,D7   Skip Square Bit - DM31JUN
DSPITN5  CMPA.L   A4,A1       Test Below Screen
         BLE.S    DSPITN5A    If LE, NO
         MOVE.L   A1,D6       
         SUB.L    A4,D6
         MOVE.L   A4,A1       Adjust Address in Screen
         LSR.L    #2,D6       and  
         SUB.L    D6,A0       in Item
         DIVU     #40,D6      Recompute # of Lines
         SUB.W    D6,D7       .  
         BLT      DSPITN2     If LT, None

DSPITN5A MOVE.L   A1,A4       Test for Display in Banner       
         MOVE     D7,D6       Sub Heigth-1
         MULU     #160,D6     .
         SUBA.L   D6,A4       .
         SUBA.L   CURSCR,A4
         MOVE.L   A4,D6
         SUBI.L   #TSKYEQU,D6 Top of Item Higher than Top of Sky?
         BPL.S    DSPITN5B    If PL, No
         DIVS     #160,D6     D6 is <0
         ADD      D6,D7       New # of Lines
         BLT      DSPITN2     If LT, None  
         
DSPITN5B TST.W    (A5)        Test Square
         BLT      DSPXTN5B    If LT, Yes

DSPITN5C MOVEQ    #2,D3
         MOVE.W   #$3A12,DEBRA1
         MOVE.W   #$2A12,DSPITN8
         MOVE.W   #$7A00,DEBRA3
         MOVE.W   #$7A00,DEBRA1B
         MOVE.W   #$2A12,XSPITN8
         MOVE.W   #$3A12,DEBRA3B
         TST      D1
         BPL.S    DSPITN3
         ADD.W    D1,D4
         BLE.S    DSPITN2
         MOVE.W   D1,D4
         ASR.W    #4,D4
         ADDQ.W   #1,D4
         SUB.W    D4,D3
         ASL.W    #1,D4
         EXT.L    D4
         SUB.L    D4,A0
         MOVE.W   #$603E,DEBRA1
         MOVE.W   #$6046,DEBRA1B
         AND.W    #$F,D1
         MOVE.W   #16,D2
         SUB.W    D1,D2
         BRA.S    DSPITN4
DSPITN2  RTS

DSPITN3
         CMP.W    #320,D1
         BGE.S    DSPITN2
         ADD.W    D1,D4
         SUB.W    #320,D4
         BLE.S    DSPITN3B
         LSR.W    #4,D4
         ADD.W    D4,D3
         MOVE.W   #$6042,DEBRA3
         MOVE.W   #$603A,DEBRA3B
DSPITN3B
         MOVEQ    #0,D4       Wash D4
         MOVE     D1,D4
         LSR      #1,D4       Make it 4*Word Boundary
         ANDI     #$FFF8,D4   .
         ADDA.L   D4,A1       Points to W. Addr.
         AND.W    #$F,D1
         MOVE     #16,D2
         SUB      D1,D2
DSPITN4
         TST.W    D1
         BNE.S    DSPITN4B
         MOVE.W   #$6042,DEBRA3
         MOVE.W   #$603A,DEBRA3B
DSPITN4B
         SUB.W    D3,D5
         BGE.S    DSPITN4C
         MOVE.W   #$6048,DSPITN8
         MOVE.W   #$6048,XSPITN8
DSPITN4C
         MOVE.W   D5,DSPITN66
         MOVE.W   D5,XSPITN66
         CMP.W    D2,D1
         BLE.S    DSPITN6
         EXG      D1,D2
         BRA      XSPITN6
DSPITN6
         SWAP     D7          D7 High Now Contains Heigth-1
         DC.W     $3E3C       MOVE Width,D7
DSPITN66 DC.W     0           Computed Instruction (Contains Width in 4*W)
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A0,A2       Save Item Addr. in Mem
DEBRA1
         MOVE.W   (A2),D5 Mixt 1st Part of Screen
         LSR.W    D1,D5       With Item in Mem
         SWAP     D5          .
         MOVE.W   1*PLANEQU(A2),D5 .
         LSR.W    D1,D5       .

         MOVE.W   2*PLANEQU(A2),D6
         LSR.W    D1,D6       .
         SWAP     D6          .
         MOVE.W   3*PLANEQU(A2),D6
         LSR.W    D1,D6       .

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BNE.S    DSP1TN10    If EQ, Not All Black

DSP1TN9  ADDQ.L   #8,A3
         BRA.S    DSPITN8

DSP1TN10 NOT.L    D2
         BEQ.S    DSP1TN11    If EQ, Not Any Black
         MOVE.L   (A3),D3     Some Black
         MOVE.L   4(A3),D4    Get Screen Value
         AND.L    D2,D3       and mix it
         AND.L    D2,D4       .
         OR.L     D3,D5       with Item
         OR.L     D4,D6       .

DSP1TN11 MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .

DSPITN8
         MOVE.L   (A2),D5 Mixt 1st Part of Screen
         LSR.L    D1,D5       With Item in Mem
         SWAP     D5          .
         MOVE.L   1*PLANEQU(A2),D2 .
         LSR.L    D1,D2       .
         MOVE.W   D2,D5       .

         MOVE.L   2*PLANEQU(A2),D6
         LSR.L    D1,D6       .
         SWAP     D6          .
         MOVE.L   3*PLANEQU(A2),D2
         LSR.L    D1,D2       .
         MOVE.W   D2,D6       .

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BNE.S    DSPITN10    If EQ, Not All Black

DSPITN9  ADDQ.L   #8,A3
         BRA.S    DSPITN12

DSPITN10 NOT.L    D2
         BEQ.S    DSPITN11    If EQ, Not Any Black
         MOVE.L   (A3),D3     Some Black
         MOVE.L   4(A3),D4    Get Screen Value
         AND.L    D2,D3       and mix it
         AND.L    D2,D4       .
         OR.L     D3,D5       with Item
         OR.L     D4,D6       .

DSPITN11 MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .
DSPITN12 ADDQ.L   #2,A2
         DBF      D7,DSPITN8  Advance in Width
DEBRA3
         MOVEQ    #0,D5
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         ROR.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         CLR.W    D2
         LSR.L    D1,D2       .
         MOVE.W   D2,D5

         MOVEQ    #0,D6
         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         ROR.L    D1,D6       With Item in Mem
         MOVE.L   3*PLANEQU(A2),D2
         CLR.W    D2          .
         LSR.L    D1,D2       .
         MOVE.W   D2,D6

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BEQ.S    DSPITN18    If EQ, All Black
         NOT.L    D2          .
         BEQ.S    DSPITN17    If EQ, Not Any Black

         MOVE.L   (A3),D3     Get Screen High Double Word
         MOVE.L   4(A3),D4    Get Screen Low Double Word
         AND.L    D2,D3       .
         AND.L    D2,D4       .
         OR.L     D3,D5       .
         OR.L     D4,D6       .

DSPITN17 MOVE.L   D5,(A3)+    .
         MOVE.L   D6,(A3)+    .

DSPITN18 LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,DSPITN6  Previous Line
         BRA.L    DSPITNF

XSPITN6
         SWAP     D7          D7 High Now Contains Heigth-1
         DC.W     $3E3C       MOVE Width,D7
XSPITN66 DC.W     0           Computed Instruction (Contains Width in 4*W)
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A0,A2       Save Item Addr. in Mem
DEBRA1B
         MOVEQ    #0,D5
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         LSL.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         CLR.W    D2          .
         ROL.L    D1,D2       .
         MOVE.W   D2,D5

         MOVEQ    #0,D6
         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         LSL.L    D1,D6       With Item in Mem
         MOVE.L   3*PLANEQU(A2),D2
         CLR.W    D2          .
         ROL.L    D1,D2       .
         MOVE.W   D2,D6

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BNE.S    XSP1TN10    If EQ, Not All Black

XSP1TN9  ADDQ.L   #8,A3
         BRA.S    XSPITN8

XSP1TN10 NOT.L    D2
         BEQ.S    XSP1TN11    If EQ, Not Any Black
         MOVE.L   (A3),D3     Some Black
         MOVE.L   4(A3),D4    Get Screen Value
         AND.L    D2,D3       and mix it
         AND.L    D2,D4       .
         OR.L     D3,D5       with Item
         OR.L     D4,D6       .

XSP1TN11 MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .

XSPITN8
         MOVE.L   (A2),D5     Mixt 1st Part of Screen
         LSL.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         LSL.L    D1,D2       .
         SWAP     D2          .
         MOVE.W   D2,D5       .

         MOVE.L   2*PLANEQU(A2),D6
         LSL.L    D1,D6       .
         MOVE.L   3*PLANEQU(A2),D2
         LSL.L    D1,D2       .
         SWAP     D2          .
         MOVE.W   D2,D6       .

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BNE.S    XSPITN10    If EQ, Not All Black

XSPITN9  ADDQ.L   #8,A3
         BRA.S    XSPITN12

XSPITN10 NOT.L    D2
         BEQ.S    XSPITN11    If EQ, Not Any Black
         MOVE.L   (A3),D3     Some Black
         MOVE.L   4(A3),D4    Get Screen Value
         AND.L    D2,D3       and mix it
         AND.L    D2,D4       .
         OR.L     D3,D5       with Item
         OR.L     D4,D6       .

XSPITN11 MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .
XSPITN12 ADDQ.L   #2,A2
         DBF      D7,XSPITN8  Advance in Width
DEBRA3B
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         LSL.W    D1,D5       With Item in Mem
         SWAP     D5          .
         MOVE.W   1*PLANEQU(A2),D5 .
         LSL.W    D1,D5       .

         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         LSL.W    D1,D6       With Item in Mem
         SWAP     D6          .
         MOVE.W   3*PLANEQU(A2),D6
         LSL.W    D1,D6       .

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BEQ.S    XSPITN18    If EQ, All Black
         NOT.L    D2          .
         BEQ.S    XSPITN17    If EQ, Not Any Black

         MOVE.L   (A3),D3     Get Screen High Double Word
         MOVE.L   4(A3),D4    Get Screen Low Double Word
         AND.L    D2,D3       .
         AND.L    D2,D4       .
         OR.L     D3,D5       .
         OR.L     D4,D6       .

XSPITN17 MOVE.L   D5,(A3)+    .
         MOVE.L   D6,(A3)+    .

XSPITN18 LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,XSPITN6  Previous Line
         BRA.L    DSPITNF

DSPXTN5B
         MOVE.L   A0,A2       Display Square Item
         MOVE.W   D4,D6
         LSR.W    #3,D6
         ADD.W    D6,A2
         SUBQ.L   #2,A2
         MOVEQ    #0,D6
         MOVEQ    #2,D3
         MOVE.W   #$3A12,DEBRX1
         MOVE.W   #$2A12,DSPXTN8
         MOVE.W   #$7A00,DEBRX3
         MOVE.W   #$7A00,DEBRX1B
         MOVE.W   #$2A12,XSPXTN8
         MOVE.W   #$3A12,DEBRX3B
         TST      D1
         BPL.S    DSPXTN3
         ADD.W    D1,D4
         BLE.S    DSPXTN2
         MOVE.W   D1,D4
         ASR.W    #4,D4
         ADDQ.W   #1,D4
         SUB.W    D4,D3
         ASL.W    #1,D4
         EXT.L    D4
         SUB.L    D4,A0
         MOVE.W   #$6022,DEBRX1
         MOVE.W   #$602A,DEBRX1B
         AND.W    #$F,D1
         MOVE.W   #16,D2
         SUB.W    D1,D2
         BRA.S    DSPXTN4
DSPXTN2  RTS
DSPXTN3
         CMP.W    #320,D1
         BGE.S    DSPXTN2
         ADD.W    D1,D4
         SUB.W    #320,D4
         BLE.S    DSPXTN3B
         LSR.W    #4,D4
         MOVE.W   D4,D6
         ADD.W    D4,D3
         MOVE.W   #$602A,DEBRX3
         MOVE.W   #$6022,DEBRX3B
DSPXTN3B
         MOVEQ    #0,D4       Wash D4
         MOVE     D1,D4
         LSR      #1,D4       Make it 4*Word Boundary
         ANDI     #$FFF8,D4   .
         ADDA.L   D4,A1       Points to W. Addr.
         AND.W    #$F,D1
         MOVE     #16,D2
         SUB      D1,D2
DSPXTN4
         TST.W    D1
         BNE.S    DSPXTN4B
         MOVE.W   #$602A,DEBRX3
         MOVE.W   #$6022,DEBRX3B
DSPXTN4B

         MOVEQ    #0,D4       M3 Computation
         MOVE.W   (A2),D4
         OR.W     1*PLANEQU(A2),D4
         OR.W     2*PLANEQU(A2),D4
         OR.W     3*PLANEQU(A2),D4
         ROR.L    D1,D4
         MOVE.L   D4,D0
         SWAP     D0
         MOVE.W   D0,D4
         NOT.L    D4
         CMPI.L   #-1,D4
         BNE.S    MASK3OK
         TST.W    D6
         BNE.S    MASK3OK

         SUBQ.L   #2,A2       M2 Computation
         MOVE.L   (A2),D4
         OR.L     1*PLANEQU(A2),D4
         OR.L     2*PLANEQU(A2),D4
         OR.L     3*PLANEQU(A2),D4
         LSR.L    D1,D4
         MOVE.W   D4,D0
         SWAP     D4
         MOVE.W   D0,D4
         NOT.L    D4
         ADDQ.W   #1,D3
         MOVE.W   #-1,D6
         MOVE.W   #$603C,DEBRX3      *603A
         MOVE.W   #$6034,DEBRX3B     *6032
MASK3OK
         MOVE.W   (A0),D0     First Mask Computation *A0
         OR.W     1*PLANEQU(A0),D0      *A0
         OR.W     2*PLANEQU(A0),D0      *A0
         OR.W     3*PLANEQU(A0),D0      *A0
         LSR.W   D1,D0
         SWAP    D7
         MOVE.W  D0,D7
         SWAP    D0
         MOVE.W  D7,D0
         SWAP    D7         *+NOL.L D0
         NOT.L   D0
         SUB.W    D3,D5
         BGE.S    DSPXTN4C
         MOVE.W   #$6022,DSPXTN8 No Central Part
         MOVE.W   #$6026,XSPXTN8
         TST.W    D6
         BGE.S    DSPXTN4C
         MOVE.W   #$604E,DSPXTN8 NO Right Part
         MOVE.W   #$604A,XSPXTN8
DSPXTN4C
         MOVE.W   D5,DSPXTN66
         MOVE.W   D5,XSPXTN66
         CMP.W    D2,D1
         BLE.S    DSPXTN6
         EXG      D1,D2
         BRA      XSPXTN6    
DSPXTN6
         SWAP     D7          D7 High Now Contains Heigth-1
         DC.W     $3E3C       MOVE Width,D7
DSPXTN66 DC.W     0           Computed Instruction (Contains Width in 4*W)
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A0,A2       Save Item Addr. in Mem
DEBRX1
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         LSR.W    D1,D5       With Item in Mem
         SWAP     D5          .
         MOVE.W   1*PLANEQU(A2),D5 .
         LSR.W    D1,D5       .

         MOVE.W   2*PLANEQU(A2),D6
         LSR.W    D1,D6       .
         SWAP     D6          .
         MOVE.W   3*PLANEQU(A2),D6
         LSR.W    D1,D6       .

         AND.L    D0,(A3)
         AND.L    D0,4(A3)
         OR.L     D5,(A3)+
         OR.L     D6,(A3)+

DSPXTN8
         MOVE.L   (A2),D5     Mixt 1st Part of Screen
         LSR.L    D1,D5       With Item in Mem
         MOVE     D5,(A3)+    .
         MOVE.L   1*PLANEQU(A2),D5 .
         LSR.L    D1,D5       .
         MOVE     D5,(A3)+    .

         MOVE.L   2*PLANEQU(A2),D6
         LSR.L    D1,D6       .
         MOVE     D6,(A3)+    .
         MOVE.L   3*PLANEQU(A2),D6
         LSR.L    D1,D6       .
         MOVE.W   D6,(A3)+    .

         ADDQ.L   #2,A2
         DBF      D7,DSPXTN8  Advance in Width
DEBRX3
         MOVEQ    #0,D5
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         ROR.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         CLR.W    D2          .
         LSR.L    D1,D2       .
         MOVE.W   D2,D5

         MOVEQ    #0,D6
         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         ROR.L    D1,D6       With Item in Mem
         MOVE.L   3*PLANEQU(A2),D2
         CLR.W    D2          .
         LSR.L    D1,D2       .
         MOVE.W   D2,D6       .

         AND.L    D4,(A3)     .
         AND.L    D4,4(A3)    .
         OR.L     D5,(A3)+    .
         OR.L     D6,(A3)     .

         LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,DSPXTN6  Previous Line
         BRA.L    DSPITNF
DEBRX2
         MOVE.L   (A2),D5     Mixt 1st Part of Screen
         LSR.L    D1,D5       With Item in Mem
         SWAP     D5          .
         MOVE.L   1*PLANEQU(A2),D2 .
         LSR.L    D1,D2       .
         MOVE     D2,D5       .

         MOVE.L   2*PLANEQU(A2),D6
         LSR.L    D1,D6       .
         SWAP     D6
         MOVE.L   3*PLANEQU(A2),D2
         LSR.L    D1,D2       .
         MOVE.W   D2,D6       .

         AND.L    D4,(A3)     .
         AND.L    D4,4(A3)    .
         OR.L     D5,(A3)+    .
         OR.L     D6,(A3)     .

         LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,DSPXTN6  Previous Line
         BRA.L    DSPITNF

XSPXTN6
         SWAP     D7          D7 High Now Contains Heigth-1
         DC.W     $3E3C       MOVE Width,D7
XSPXTN66 DC.W     0           Computed Instruction (Contains Width in 4*W)
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A0,A2       Save Item Addr. in Mem
DEBRX1B
         MOVEQ    #0,D5
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         LSL.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         CLR.W    D2          .
         ROL.L    D1,D2       .
         MOVE.W   D2,D5       .

         MOVEQ    #0,D6
         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         LSL.L    D1,D6       With Item in Mem
         MOVE.L   3*PLANEQU(A2),D2
         CLR.W    D2          .
         ROL.L    D1,D2       .
         MOVE.W   D2,D6       .

         AND.L    D0,(A3)     and mix it
         AND.L    D0,4(A3)    .
         OR.L     D5,(A3)+    .
         OR.L     D6,(A3)+    .

XSPXTN8
         MOVE.L   (A2),D5     Mixt 1st Part of Screen
         LSL.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         LSL.L    D1,D2       .
         SWAP     D2
         MOVE.W   D2,D5       .

         MOVE.L   2*PLANEQU(A2),D6
         LSL.L    D1,D6       .
         MOVE.L   3*PLANEQU(A2),D2
         LSL.L    D1,D2       .
         SWAP     D2          .
         MOVE.W   D2,D6       .

         MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .
         ADDQ.L   #2,A2
         DBF      D7,XSPXTN8  Advance in Width
DEBRX3B
         MOVE.W   (A2),D5     Mixt 1st Part of Screen
         LSL.W    D1,D5       With Item in Mem
         SWAP     D5
         MOVE.W   1*PLANEQU(A2),D5 .
         LSL.W    D1,D5       .

         MOVE.W   2*PLANEQU(A2),D6 Mixt 1st Part of Screen
         LSL.W    D1,D6       With Item in Mem
         SWAP     D6
         MOVE.W   3*PLANEQU(A2),D6
         LSL.W    D1,D6       .

         AND.L    D4,(A3)     .
         AND.L    D4,4(A3)    .
         OR.L     D5,(A3)+    .
         OR.L     D6,(A3)     .

         LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,XSPXTN6  Previous Line
         BRA.L    DSPITNF

DEBRX2B
         MOVE.L   (A2),D5     Mixt 1st Part of Screen
         LSL.L    D1,D5       With Item in Mem
         MOVE.L   1*PLANEQU(A2),D2 .
         LSL.L    D1,D2       .
         SWAP     D2
         MOVE.W   D2,D5       .

         MOVE.L   2*PLANEQU(A2),D6
         LSL.L    D1,D6       .
         MOVE.L   3*PLANEQU(A2),D2
         LSL.L    D1,D2       .
         SWAP     D2          .
         MOVE.W   D2,D6       .

         AND.L    D4,(A3)
         AND.L    D4,4(A3)
         OR.L     D5,(A3)+
         OR.L     D6,(A3)

         LEA.L    -160(A1),A1 SUBA.L   #160,A1     Next Line on Screen
         LEA.L    -40(A0),A0  SUBA.L   #160,A0     Next Line in Item
         SWAP     D7          D7 Low Now Contains Heigth-1
         DBF      D7,XSPXTN6  Previous Line
DSPITNF  RTS

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

* ERAITE - Erase Item
*        Input :  A5 Points to Item                  Destroyed
*                 A4 Points to ERASE

ERAITE   MOVE.L   ACTSCR,D5     Get ACTSCR (0 or 4)
         MOVE.L   A5,A0       Point to Proper Entry
         MOVE.L   0(A4,D5),D0 Test Screen Offset Address for Erase
         BEQ.S    ERAITE6     If EQ, Nothing has been Saved
         MOVE.L   D0,A1
         CLR.L    0(A4,D5)    Say Erased
         MOVE.L   0(A0,D5),D0 Get Line Address Offset of Active Screen
         ADD.L    CURSCR,D0 Add Active Screen Address
         MOVE     28(A0),D7   Get Heigth-1 in Lines
         MOVE.L   8(A4,D5),A2 Get Save Area Address (Source)

ERAITE2  SWAP     D7          D7 High Contains Heigth-1
         CLR      D7
         MOVE.B   27(A0),D7   D7 Low Contains Width
         MOVE.L   A1,A3       Save Target (Screen)
ERAITE3
         MOVE.L   A3,D4       Test Out of Screen
         SUB.L    D0,D4       .
         BLT.S    ERAITE4     If LT, Out of Screen on the Left
         SUB.L    #160,D4     Test For Out on the Right
         BPL.S    ERAITE4     If PL, Out on the Right
         MOVE.L   (A2),(A3)   Restore Screen
         MOVE.L   4(A2),4(A3)
ERAITE4  ADDA.L   #8,A2
         ADDA.L   #8,A3
ERAITE5  DBF      D7,ERAITE3  .
         SUBA.L   #160,A1     Next Line Up
         SUB.L    #160,D0     .
         SWAP     D7          D7 Low Contains Heigth
         DBF      D7,ERAITE2  .
ERAITE6  RTS

* DISPITE - Display Item
*        Input :  A5 Points to Item Table              Destroyed
*                 A4 Points to ERASE

DSPITE   MOVE.L   ACTSCR,D5   Get ACTSCR (0 or 4)
         MOVEQ.L  #0,D7       Wash D7
         MOVE.L   A5,A0       Point to Entry...
         MOVE.L   0(A0,D5),A1 Get Line Address Offset of Active Screen
         ADDA.L   CURSCR,A1   Get Line Address of Screen
         MOVE.L   A1,D0       Important!
         MOVE.L   8(A0,D5),D1 Get Position in Line
         MOVEQ.L  #0,D4       Wash D4
         MOVE     D1,D4
         LSR      #4,D4       Make it 4*Word Boundary
         LSL      #3,D4       .
         ADDA.L   D4,A1       Points to W. Addr.
         ADD      D4,D4
         SUB      D4,D1       Compute Shift in D1
DSPITE3  MOVE     D1,D2
         SWAP     D1
         MOVE     D2,D1
         SUB      #16,D1
         NEG      D1
         CLR      D4
         MOVE.B   26(A0),D4   Get Width in bytes (Multiple of 4*Words)
         MOVE     28(A0),D7   Heigth-1 in # of Lines
         MOVE.L   A1,0(A4,D5) Save Screen Address for Later Erase
         MOVE.L   8(A4,D5),A5 Point to Saving Area Address
         MOVE.L   22(A0),A4   Address of Item in Mem

DSPITE6  SWAP     D7          D7 High Now Contains Heigth-1
         CLR      D7
         MOVE.B   27(A0),D7   Get Width-1 in 4*Words Unit
         SUBQ     #1,D7       .
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A4,A2       Save Item Addr. in Mem
         MOVE.L   (A3),(A5)+  Save Screen in Save Area
         MOVE.L   4(A3),(A5)+ .
         MOVEQ.L  #0,D5
         MOVEQ.L  #0,D6
         MOVE.L   A3,D4       Test Out of Screen
         SUB.L    D0,D4       .
         BLT.S    DSPITE9     If LT, Out of Screen on the Left
         SUB.L    #160,D4     Test For Out on the Right
         BLT.S    DSPITE8     If LT, In
         BRA      DSPITE9     Out on the Right
DSPITE7
         TST      D3          Test Out
         BNE.S    DSPITE9     If NE, Yes

DSPITE8  SWAP     D1
         MOVE     1*PLANEQU(A2),D2 Mixt 1st Part of Screen
         LSR      D1,D2       With Item in Mem
         OR       D2,D5       .
         SWAP     D5          .
         MOVE     (A2),D2     .
         LSR      D1,D2       .
         OR       D2,D5       .
         MOVE     3*PLANEQU(A2),D2
         LSR      D1,D2       .
         OR       D2,D6       .
         SWAP     D6          .
         MOVE     2*PLANEQU(A2),D2
         LSR      D1,D2       .
         OR       D2,D6       .
         SWAP     D1

*         MOVE.L   D6,D2       Black Detection
*         OR.L     D5,D2
*         MOVE.L   D2,D3
*         SWAP     D3          .
*         OR.L     D3,D2
*         BNE.S    DSPITE10    If EQ, Not All Black

         MOVE.L   D6,D2       Black Detection
         SWAP     D6          .
         OR.L     D6,D2       .
         MOVE.L   D5,D3       **
         SWAP     D5          **
         OR.L     D5,D3       **
         OR.L     D3,D2       .
         BNE.S    DSPITE10    If NE, Not All Black 


DSPITE9  ADDA.L   #8,A3
         BRA      DSPITE12

DSPITE10 NOT.L    D2
         BEQ.S    DSPITE11    If EQ, Not Any Black 
         MOVE.L   (A3),D3     Some Black
         MOVE.L   4(A3),D4    Get Screen Value
         AND.L    D2,D3       and mix it
         AND.L    D2,D4       .
         OR.L     D3,D5       with Item
         OR.L     D4,D6       .

DSPITE11 MOVE.L   D5,(A3)+    And put Item on Screen
         MOVE.L   D6,(A3)+    .

DSPITE12
         MOVE.L   (A3),(A5)+  Save In Save Area
         MOVE.L   4(A3),(A5)+ .
         CLR      D3          Assume In
         MOVE.L   A3,D4       Test Out of Screen
         SUB.L    D0,D4       .
         BLT.S    DSPITE13    If LT, Out of Screen on the Left
         SUB.L    #160,D4     Test For Out on the Right
         BLT.S    DSPITE14    If LT, In
DSPITE13 MOVEQ    #1,D3       Say Out
         ADDQ.L   #2,A2       Advance 1W in Mem ***
         BRA      DSPITE15

DSPITE14
         MOVE     (A2),D5     Mixt 2nd Part of Item in Mem
         LSL      D1,D5       With Screen
         SWAP     D5          .
         MOVE     1*PLANEQU(A2),D5
         LSL      D1,D5       .
         MOVE     2*PLANEQU(A2),D6
         LSL      D1,D6       .
         SWAP     D6          .
         MOVE     3*PLANEQU(A2),D6
         LSL      D1,D6       .
         ADDQ.L   #2,A2       Advance 1W in Mem ***

DSPITE15 DBF      D7,DSPITE7  Advance in Width

         TST      D3          Test Out
         BNE.S    DSPITE18    If NE, Out

         MOVE.L   D6,D2       Black Detection
         OR.L     D5,D2
         MOVE.L   D2,D3
         SWAP     D3          .
         OR.L     D3,D2
         BEQ.S    DSPITE18    If EQ, All Black
         NOT.L    D2          .
         BEQ.S    DSPITE17    If EQ, Not Any Black

*         MOVE.L   D6,D2       Black Detection
*         SWAP     D6          .
*         OR.L     D6,D2       .
*         SWAP     D6          .
*         MOVE.L   D5,D3       **
*         SWAP     D5          **
*         OR.L     D5,D3       **
*         SWAP     D5          **
*         OR.L     D5,D2
*         BEQ.S    DSPITE18    If EQ, All Black
*         NOT.L    D2          .
*         BEQ.S    DSPITE17    If EQ, Not Any Black


         MOVE.L   (A3),D3     Get Screen High Double Word
         MOVE.L   4(A3),D4    Get Screen Low Double Word
         AND.L    D2,D3       .
         AND.L    D2,D4       .
         OR.L     D3,D5       .
         OR.L     D4,D6       .

DSPITE17 MOVE.L   D5,(A3)+    .
         MOVE.L   D6,(A3)+    .

DSPITE18
         SUBA.L   #160,A1     Next Line on Screen
         SUBA.L   #40,A4      Next Line in Item ***
         SUB.L    #160,D0     Next Line Addres on Screen
         SWAP     D7          D7 Now Contains Heigth-1
         DBF      D7,DSPITE6  Previous Line
         RTS

* DSPMED - Display Item in Medium Resolution
*        Input :  A5 Points to Item Table           
*                 Mid Res Items are Splitted in 4 Planes (a la AMIGA) 
*                 as if they were Low Res Items.
*
* Medium Resolution Item (32)
*        0     DC.L  Line Address Offset in Screen #1 (y)
*        4     DC.L  Line Address Offset in Screen #2 (y)
*        8     DS.W  Erase Mode
*        10    DC.L  Position in Line in Pixels on Screen #1 (x)
*        14    DC.L  Positi/on in Line in Pixels on Screen #2 (x)
*        18    DS.W  2 (Dummy)
*        22    DC.L  Item Address in Item Screen (Bottom Left)
*        26    DC.B  Width in Bytes (Multiple of 4*Words Units)
*        27    DC.B  Width in 4*Words Units
*        28    DC.W  Heigth-1 in # of Lines
*        30    DC.W  End of Line Position if Moving Item
*

DSPMED   MOVE.L   ACTSCR,D5   Get ACTSCR (0 or 4)
         MOVEQ.L  #0,D7       Wash D7
         MOVE.L   A5,A0       Point to Entry...
         MOVE.L   0(A0,D5),A1 Get Line Address Offset of Active Screen
         ADDA.L   CURSCR,A1   Get Line Address of Screen
         MOVE.L   10(A0,D5),D1 Get Position in Line
         MOVEQ.L  #0,D4       Wash D4
         MOVE     D1,D4
         LSR      #4,D4       Make it 2*Word Boundary ***MED***
         LSL      #2,D4       .
         ADDA.L   D4,A1       Points to W. Addr.
         LSL      #2,D4       ***MED***
         SUB      D4,D1       Compute Shift in D1
DSPMED3  MOVE     D1,D2  
         SWAP     D1
         MOVE     D2,D1
         SUB      #16,D1     
         NEG      D1
         CLR      D4
         MOVE.B   26(A0),D4   Get Width in bytes (Multiple of 4*Words)
         MOVE     28(A0),D7   Heigth-1 in # of Lines
         MOVE.L   22(A0),A4   Address of Item in Mem

DSPMED6  SWAP     D7          D7 High Now Contains Heigth-1
         CLR      D7
         MOVE.B   27(A0),D7   Get Width-1 in 2*Words Unit
         LSL      #1,D7       ***MED***
         SUBQ     #1,D7       .
         MOVE.L   A1,A3       Save Screen Addr.
         MOVE.L   A4,A2       Save Item Addr. in Mem
         MOVEQ    #0,D5
         MOVEQ    #0,D6
         CLR      D0          Flip-Flop Flag

DSPMED7  SWAP     D1
         EORI     #1,D0
         BEQ.S    DSPMED4
         MOVE     (A2),D2     Mixt 1st Part of Screen 
         LSR      D1,D2       With Item in Mem
         OR       D2,D5
         MOVE     1*PLANEQU(A2),D2
         LSR      D1,D2       .
         OR       D2,D6       .
         BRA.S    DSPMED5
DSPMED4  MOVE     2*PLANEQU(A2),D2 Mixt 1st Part of Screen
         LSR      D1,D2       With Item in Mem
         OR       D2,D5
         MOVE     3*PLANEQU(A2),D2
         LSR      D1,D2       .
         OR       D2,D6       .
DSPMED5  SWAP     D1

         MOVE     D6,D2       Black Detection
         OR       D5,D2       .
         BNE.S    DSPMED10    If NE, Not All Black 

DSPMED9  ADDA.L   #4,A3
         BRA      DSPMED12

DSPMED10 NOT      D2
         BEQ.S    DSPMED11    If EQ, Not Any Black ****************
         MOVE     (A3),D3     Some Black
         MOVE     2(A3),D4    Get Screen Value
         AND      D2,D3       and mix it
         AND      D2,D4       .
         OR       D3,D5       with Item
         OR       D4,D6       .

DSPMED11 MOVE     D5,(A3)+    And put Item on Screen
         MOVE     D6,(A3)+    .

DSPMED12 TST      D0
         BEQ.S    DSPMED13
         MOVE     (A2),D5     Mixt 2nd Part of Screen 
         LSL      D1,D5       With Item in Mem
         MOVE     1*PLANEQU(A2),D6
         LSL      D1,D6       .
         BRA.S    DSPMED15
DSPMED13 MOVE     2*PLANEQU(A2),D5 Mixt 2nd Part of Screen
         LSL      D1,D5       With Item in Mem
         MOVE     3*PLANEQU(A2),D6
         LSL      D1,D6       .
         ADDQ.L   #2,A2       Advance 1W in Mem ***

DSPMED15 DBF      D7,DSPMED7  Advance in Width

         MOVE     D6,D2       Black Detection
         OR       D5,D2       .
         BEQ.S    DSPMED18    If EQ, All Black 
         NOT      D2
         BEQ.S    DSPMED17    If EQ, Not Any Black 
         MOVE     (A3),D3     Some Black
         MOVE     2(A3),D4    Get Screen Value
         AND      D2,D3       and mix it
         AND      D2,D4       .
         OR       D3,D5       with Item
         OR       D4,D6       .

DSPMED17 MOVE     D5,(A3)+    And put Item on Screen
         MOVE     D6,(A3)+    .

DSPMED18
         SUBA.L   #160,A1     Next Line on Screen
         SUBA.L   #40,A4      Next Line in Item ***
         SWAP     D7          D7 Now Contains Heigth-1
         DBF      D7,DSPMED6  Previous Line
         RTS

         END
