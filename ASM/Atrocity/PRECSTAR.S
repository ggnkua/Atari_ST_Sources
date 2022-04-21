L0000 EQU Begin-$100
 TEXT 
Begin:
      LEA     L0000(PC),A0
      LEA     256(A0),A7
      JSR     L007E 
      LEA     L0193,A2
      MOVE.L  A2,D0 
      MOVE.L  D0,-32752(A5) 
      MOVE.L  #$6400,D0 
      MOVEQ   #1,D7 
      LEA     -32692(A5),A0 
      BSR     L0160 
      MOVEQ   #0,D4 
      MOVEA.L -32692(A5),A0 
      LEA     4(A0,D4.L),A0 
      MOVE.L  A0,D0 
      MOVE.L  D0,-32756(A5) 
      MOVEQ   #0,D0 
      MOVEQ   #0,D1 
      BSR     L00CB 
      MOVEQ   #0,D0 
      MOVEQ   #$F,D1
      BSR     L00CB 
      BSR     L00FF 
      CLR.W   -32758(A5)
      MOVE.L  #-$61000000,D0
      MOVEQ   #0,D1 
      MOVE.W  #$406,D2
      LEA     -32764(A5),A0 
      BSR     L00DF 
      BNE.S   L0002 
L0001:LEA     -32764(A5),A0 
      BSR     L00E8 
      BSR     L0028 
      MOVE.L  D0,-(A7)
      MOVEQ   #$F,D0
      MOVEQ   #0,D2 
      MOVE.L  (A7)+,D1
      BSR     L00BB 
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      MOVE.L  D0,-(A7)
      MOVE.L  #-$60000000,D0
      MOVEQ   #0,D1 
      MOVE.W  #$406,D2
      LEA     -32764(A5),A0 
      BSR     L0044 
      BSR     L0028 
      ADD.L   -32756(A5),D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$A0,D0 
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      BSR     L00E1 
      BNE.S   L0001 
L0002:LEA     -14(A3),A3
      ADDI.L  #$6360,-32756(A5) 
      MOVE.W  #$777,D0
      MOVEQ   #$F,D1
      BSR     L00CB 
      MOVEA.L -32768(A5),A2 
      CLR.W   (A2)
L0003:MOVEA.L -32768(A5),A2 
      MOVE.W  (A2),-(A7)
      JSR     L0004 
      MOVEA.L -32768(A5),A2 
      MOVE.W  (A2),D0 
      EXT.L   D0
      ADDI.L  #$A0,D0 
      MOVE.L  #$6400,D1 
      BSR     L0074 
      MOVEA.L -32768(A5),A2 
      MOVE.W  D0,(A2) 
      MOVEQ   #7,D0 
      MOVEQ   #0,D1 
      BSR     L00CB 
      BSR     L0139 
      MOVEQ   #0,D0 
      MOVEQ   #0,D1 
      BSR     L00CB 
      BSR     L010E 
      MOVEQ   #$20,D0 
      BSR     L00C6 
      BEQ.S   L0003 
      MOVE.W  #$777,D0
      MOVEQ   #0,D1 
      BSR     L00CB 
      MOVEQ   #0,D0 
      MOVEQ   #$F,D1
      BSR     L00CB 
      BSR     L00B1 
L0004:BSR     L0136 
      LEA     -32768(A5),A0 
      BSR     L010C 
      MOVEA.L -32768(A5),A2 
      MOVE.W  (A2),D0 
      EXT.L   D0
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #2,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$A0,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #4,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$140,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #6,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1E0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #8,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$280,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$A,D0
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$320,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$C,D0
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$3C0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$E,D0
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$460,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$10,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$500,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$12,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$5A0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$14,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$640,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$16,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$6E0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$18,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$780,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$1A,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$820,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$1C,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$8C0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$1E,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$960,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$20,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$A00,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$22,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$AA0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$24,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$B40,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$26,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$BE0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$28,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$C80,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$2A,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$D20,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$2C,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$DC0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$2E,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$E60,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$30,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$F00,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$32,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$FA0,D0
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$34,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1040,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$36,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$10E0,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$38,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1180,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$3A,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1220,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$3C,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$12C0,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$3E,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1360,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$40,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1400,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$42,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$14A0,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$44,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1540,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$46,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$15E0,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$48,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1680,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$4A,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      MOVE.W  -32730(A5),D0 
      EXT.L   D0
      SUB.L   -32756(A5),D0 
      NEG.L   D0
      MOVE.L  D0,-(A7)
      MOVE.W  #2,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      ADDI.L  #$1720,D0 
      MOVEA.L D0,A1 
      MOVE.L  #$A0,D0 
      MOVEA.L (A7)+,A0
      BSR     L0088 
      MOVEQ   #$4C,D0 
      MOVEA.L -32768(A5),A2 
      MOVEA.W (A2),A2 
      ADD.L   A2,D0 
      ADD.L   -32752(A5),D0 
      MOVEA.L D0,A0 
      MOVE.W  (A0),D0 
      MOVE.W  D0,-32730(A5) 
      BRA     L0133 
      BSR     L00B1 
L0005:MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
L0006:MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
      CMP.W   D2,D5 
      BEQ.S   L0008 
      BGT.S   L000B 
L0007:MOVEQ   #0,D0 
      RTS 
L0008:MOVE.W  D2,D6 
      BGT.S   L0009 
      BEQ.S   L0007 
      CMP.L   D3,D0 
      BNE.S   L000A 
      CMP.W   D4,D1 
      BLS.S   L0007 
      MOVEQ   #-1,D0
      RTS 
L0009:CMP.L   D0,D3 
      BNE.S   L000A 
      CMP.W   D1,D4 
L000A:BLS.S   L0007 
L000B:MOVEQ   #-1,D0
      RTS 
      NEG.W   D5
      MOVEQ   #0,D4 
      BSR     L002E 
      BRA.S   L000E 
      NEG.W   D5
      BSR     L002E 
      BRA.S   L000E 
      BSR.S   L000D 
      MOVE.W  D2,-(A0)
      MOVE.W  D1,-(A0)
      MOVE.L  D0,-(A0)
      RTS 
      BSR.S   L000C 
      MOVE.W  D2,-(A0)
      MOVE.W  D1,-(A0)
      MOVE.L  D0,-(A0)
      RTS 
      MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
      MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
      NEG.W   D5
      BRA.S   L000E 
      MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
L000C:MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
      NEG.W   D2
      BRA.S   L000E 
      BSR     L002E 
      MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
      NEG.W   D5
      BRA.S   L000E 
      NEG.W   D5
      MOVEQ   #0,D4 
      BRA.S   L000E 
      BSR     L002E 
      BRA.S   L000D 
      MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
L000D:MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
L000E:EXT.L   D2
      BGT.S   L000F 
      BEQ.S   L0017 
      NEG.W   D2
L000F:EXT.L   D5
      BGT.S   L0010 
      BEQ.S   L0015 
      NEG.W   D5
L0010:MOVEQ   #$10,D7 
      MOVE.W  D2,D6 
      SUB.W   D5,D6 
      BGT.S   L0011 
      BEQ.S   L0014 
      EXG     D0,D3 
      EXG     D1,D4 
      EXG     D2,D5 
      NEG.W   D6
L0011:SUB.W   D7,D6 
      BLS.S   L0013 
      SUB.W   D7,D6 
      BLS.S   L0012 
      CMP.W   D7,D6 
      BHI.S   L0015 
      MOVE.L  D3,D4 
      MOVEQ   #0,D3 
      SWAP    D4
      LSR.W   D6,D4 
      BRA.S   L0014 
L0012:ADD.W   D7,D6 
      LSR.L   D6,D3 
      MOVE.W  D3,D4 
      CLR.W   D3
      SWAP    D3
      BRA.S   L0014 
L0013:ADD.W   D7,D6 
      SWAP    D4
      MOVE.W  D3,D4 
      SWAP    D4
      LSR.L   D6,D3 
      LSR.L   D6,D4 
L0014:EOR.L   D2,D5 
      BMI.S   L0019 
      ADDX.W  D4,D1 
      ADDX.L  D3,D0 
      BCC.S   L0015 
      ROXR.L  #1,D0 
      ROXR.W  #1,D1 
      ADDQ.W  #1,D2 
      CMPI.W  #$1FFF,D2 
      BHI.S   L0018 
L0015:TST.L   D2
      BPL.S   L0016 
      NEG.W   D2
L0016:RTS 
L0017:MOVE.L  D3,D0 
      EXG     D4,D1 
      EXG     D5,D2 
      RTS 
L0018:MOVEQ   #1,D0 
      JMP     (A6)
L0019:SUBX.W  D4,D1 
      SUBX.L  D3,D0 
      BPL.S   L001A 
      BCC.S   L001C 
      EOR.L   D5,D2 
      NEG.W   D1
      NEGX.L  D0
L001A:CMPI.L  #$FFFF,D0 
      BLS.S   L0020 
L001B:ADD.W   D1,D1 
      ADDX.L  D0,D0 
      DBMI    D2,L001B
      SUBQ.W  #1,D2 
      BLE.S   L001E 
L001C:TST.L   D2
      BPL.S   L001D 
      NEG.W   D2
L001D:RTS 
L001E:MOVEQ   #0,D1 
L001F:MOVEQ   #0,D0 
      MOVEQ   #0,D2 
      RTS 
L0020:SWAP    D0
      BEQ.S   L0024 
      MOVE.W  D1,D0 
      TST.L   D0
      BRA.S   L0022 
L0021:ADD.L   D0,D0 
L0022:DBMI    D2,L0021
      MOVEQ   #0,D1 
      SUB.W   D7,D2 
      BLE.S   L001F 
      TST.L   D2
      BPL.S   L0023 
      NEG.W   D2
L0023:RTS 
L0024:MOVE.W  D1,D0 
      BNE.S   L0026 
      MOVEQ   #0,D2 
      RTS 
L0025:ADD.W   D0,D0 
L0026:DBMI    D2,L0025
      MOVEQ   #0,D1 
      SUBI.W  #$20,D2 
      BLE.S   L001F 
      SWAP    D0
      TST.L   D2
      BPL.S   L0027 
      NEG.W   D2
L0027:RTS 
      MOVE.L  (A0)+,D0
      MOVE.L  (A0)+,D2
L0028:EXT.L   D2
      BMI.S   L002A 
      SUBI.W  #$3FF,D2
      BMI.S   L0029 
      SUBI.W  #$1F,D2 
      BPL.S   L002D 
      NEG.W   D2
      LSR.L   D2,D0 
      RTS 
L0029:MOVEQ   #0,D0 
      RTS 
L002A:NEG.W   D2
      SUBI.W  #$3FF,D2
      BMI.S   L0029 
      SUBI.W  #$1F,D2 
      BPL.S   L002C 
      NEG.W   D2
      LSR.L   D2,D0 
      NEG.L   D0
L002B:RTS 
L002C:BNE.S   L002D 
      CMPI.L  #-$80000000,D0
      BEQ.S   L002B 
L002D:MOVEQ   #2,D0 
      BRA     L0060 
      BSR.S   L002E 
      MOVE.L  D0,(A0)+
      MOVE.W  D1,(A0)+
      MOVE.W  D2,(A0)+
      RTS 
L002E:MOVEQ   #0,D1 
      MOVE.L  D0,D2 
      BLE.S   L0033 
      CMPI.L  #$FFFF,D0 
      BHI.S   L0031 
      MOVE.W  #$40D,D2
      TST.W   D0
      BMI.S   L0030 
L002F:ADD.W   D0,D0 
      DBMI    D2,L002F
      SWAP    D0
      RTS 
L0030:SWAP    D0
      ADDQ.W  #1,D2 
      RTS 
L0031:MOVE.W  #$41D,D2
L0032:ADD.L   D0,D0 
      DBMI    D2,L0032
      RTS 
L0033:NEG.L   D0
      BEQ.S   L0039 
      BMI.S   L0038 
      CMPI.L  #$FFFF,D0 
      BHI.S   L0036 
      MOVE.W  #$40D,D2
      TST.W   D0
      BMI.S   L0035 
L0034:ADD.W   D0,D0 
      DBMI    D2,L0034
      SWAP    D0
      NEG.W   D2
      RTS 
L0035:SWAP    D0
      ADDQ.W  #1,D2 
      NEG.W   D2
      RTS 
L0036:MOVE.W  #$41D,D2
L0037:ADD.L   D0,D0 
      DBMI    D2,L0037
      NEG.W   D2
      RTS 
L0038:MOVE.W  #-$41E,D2 
L0039:RTS 
      MOVEQ   #0,D1 
      MOVE.W  #$406,D2
      ASL.W   #8,D0 
      BNE.S   L003B 
      MOVEQ   #0,D2 
      RTS 
      EXT.L   D0
      BMI     L002E 
      MOVEQ   #0,D1 
      MOVE.W  #$40E,D2
      TST.W   D0
      BNE.S   L003B 
      MOVEQ   #0,D2 
      RTS 
L003A:ADD.W   D0,D0 
L003B:DBMI    D2,L003A
      SWAP    D0
      MOVE.W  D1,D0 
      RTS 
L003C:TST.W   D4
      BEQ.S   L003E 
      MOVE.W  D3,D1 
      BEQ.S   L003D 
      MULU    D0,D1 
      MOVEQ   #0,D6 
      SWAP    D3
      SWAP    D0
      MULU    D0,D4 
      MOVE.W  D3,D5 
      MULU    D0,D5 
      ADD.L   D4,D1 
      ADDX.L  D6,D5 
      MOVE.W  D3,D6 
      SWAP    D3
      MOVE.W  D0,D7 
      SWAP    D0
      MULU    D6,D0 
      MULU    D7,D3 
      ADD.L   D3,D0 
      BCC     L004F 
      ADDI.L  #$10000,D5
      BRA     L004F 
L003D:SWAP    D3
      SWAP    D0
      MULU    D0,D4 
      MOVE.W  D3,D5 
      MULU    D0,D5 
      MOVE.L  D4,D1 
      MOVE.W  D0,D7 
      SWAP    D0
      MULU    D3,D0 
      BRA     L004F 
L003E:MOVE.W  D3,D1 
      BEQ.S   L003F 
      MULU    D0,D1 
      SWAP    D3
      SWAP    D0
      MOVE.W  D3,D5 
      MULU    D0,D5 
      MOVE.W  D3,D6 
      SWAP    D3
      MOVE.W  D0,D7 
      SWAP    D0
      MULU    D6,D0 
      MULU    D7,D3 
      ADD.L   D3,D0 
      BCC     L004F 
      ADDI.L  #$10000,D5
      BRA     L004F 
L003F:SWAP    D3
      SWAP    D0
      MOVE.W  D3,D5 
      MULU    D0,D5 
      SWAP    D0
      MULU    D3,D0 
      MOVEQ   #0,D1 
      BRA     L004F 
L0040:BEQ.S   L0043 
      NEG.W   D2
      BEQ.S   L0043 
      BMI.S   L0041 
      NEG.W   D5
      BRA.S   L0046 
L0041:NEG.W   D2
      NEG.W   D5
      BSR.S   L0046 
      NEG.W   D2
      RTS 
L0042:BEQ.S   L0043 
      NEG.W   D2
      BSR.S   L0046 
      NEG.W   D2
      RTS 
L0043:MOVEQ   #0,D2 
      RTS 
      BSR.S   L0044 
      MOVE.W  D2,-(A0)
      MOVE.W  D1,-(A0)
      MOVE.L  D0,-(A0)
      RTS 
      MOVEQ   #0,D4 
      BRA.S   L0045 
      MOVEQ   #0,D4 
      BSR     L002E 
      BRA.S   L0045 
      BSR     L002E 
      BRA.S   L0044 
      MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
L0044:MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
L0045:EXT.L   D5
      BLE.S   L0040 
      EXT.L   D2
      BLE.S   L0042 
L0046:ADD.W   D5,D2 
      SUBI.W  #$3FE,D2
      TST.W   D1
      BEQ     L003C 
      TST.W   D4
      BNE.S   L004D 
      MOVE.W  D3,D5 
      BEQ.S   L0047 
      MULU    D0,D5 
      MOVEQ   #0,D6 
      SWAP    D3
      MULU    D3,D1 
      ADD.L   D5,D1 
      SWAP    D0
      MOVE.W  D3,D5 
      MULU    D0,D5 
      ADDX.L  D6,D5 
      MOVE.W  D3,D6 
      SWAP    D3
      MOVE.W  D0,D7 
      SWAP    D0
      MULU    D6,D0 
      MULU    D7,D3 
      ADD.L   D3,D0 
      BCC     L004F 
      ADDI.L  #$10000,D5
      BRA.S   L004F 
L0047:SWAP    D3
      MULU    D3,D1 
      SWAP    D0
      MOVE.W  D3,D5 
      MULU    D0,D5 
      SWAP    D0
      MULU    D3,D0 
      BRA.S   L004F 
L0048:BEQ.S   L004B 
      NEG.W   D2
      BEQ.S   L004B 
      BMI.S   L0049 
      NEG.W   D5
      BRA.S   L004C 
L0049:NEG.W   D2
      NEG.W   D5
      BSR.S   L004C 
      NEG.W   D2
      RTS 
L004A:BEQ.S   L004B 
      NEG.W   D2
      BSR.S   L004C 
      NEG.W   D2
      RTS 
L004B:MOVEQ   #0,D2 
      RTS 
      EXT.L   D5
      BLE.S   L0048 
      EXT.L   D2
      BLE.S   L004A 
L004C:ADD.W   D5,D2 
      SUBI.W  #$3FE,D2
L004D:MOVEQ   #0,D5 
      MOVE.W  D3,D5 
      BEQ.S   L004E 
      MULU    D0,D5 
L004E:MOVEQ   #0,D6 
      SWAP    D3
      MULU    D3,D1 
      ADD.L   D5,D1 
      SWAP    D0
      MULU    D0,D4 
      MOVE.W  D3,D5 
      MULU    D0,D5 
      ADDX.L  D6,D5 
      ADD.L   D4,D1 
      ADDX.L  D6,D5 
      MOVE.W  D3,D6 
      SWAP    D3
      MOVE.W  D0,D7 
      SWAP    D0
      MULU    D6,D0 
      MULU    D7,D3 
      ADD.L   D3,D0 
      BCC.S   L004F 
      ADDI.L  #$10000,D5
L004F:SWAP    D1
      ADD.W   D0,D1 
      CLR.W   D0
      SWAP    D0
      ADDX.L  D5,D0 
      BMI.S   L0050 
      SWAP    D1
      ADD.L   D1,D1 
      SWAP    D1
      ADDX.L  D0,D0 
      SUBQ.W  #1,D2 
L0050:CMPI.W  #$1FFF,D2 
      BHI.S   L0051 
      RTS 
L0051:TST.W   D2
      BPL     L005D 
      MOVEQ   #0,D2 
      RTS 
      BMI.S   L0058 
L0052:BEQ.S   L0059 
      TST.W   D2
      BPL.S   L0056 
      NEG.W   D2
L0053:ADD.W   D1,D1 
      ADDX.L  D0,D0 
      DBMI    D2,L0053
L0054:SUBQ.W  #1,D2 
      NEG.W   D2
      BPL.S   L0055 
      RTS 
L0055:MOVEQ   #0,D2 
      RTS 
L0056:ADD.W   D1,D1 
      ADDX.L  D0,D0 
      DBMI    D2,L0056
L0057:SUBQ.W  #1,D2 
      BMI.S   L0055 
L0058:RTS 
      TST.L   D0
      BGE.S   L0052 
      RTS 
L0059:MOVE.W  D1,D0 
      BEQ.S   L0055 
      SWAP    D0
      MOVEQ   #0,D1 
      TST.W   D2
      BMI.S   L005B 
      SUBI.W  #$20,D2 
      TST.L   D0
      BMI.S   L0058 
L005A:ADD.L   D0,D0 
      DBMI    D2,L005A
      BRA.S   L0057 
L005B:NEG.W   D2
L005C:ADD.L   D0,D0 
      DBMI    D2,L005C
      BRA.S   L0054 
L005D:TST.B   59(A6)
      BEQ.S   L005E 
      ST      58(A6)
      MOVEQ   #-1,D0
      MOVEQ   #-1,D1
      MOVE.W  #$1FFF,D2 
      RTS 
L005E:MOVEQ   #1,D0 
      BRA     L0060 
L005F:DS.W    6,0 
      DC.L    L0194 
      BSR     L0073 
      MOVEQ   #$45,D0 
L0060:MOVE.B  D0,L0196
      CMPA.L  #L0199,A6 
      BEQ.S   L0061 
      ST      L0197 
      BRA.S   L0062 
L0061:MOVEM.L L005F(PC),D1-D3 
      TST.L   D1
      BEQ.S   L0062 
      MOVEA.L D2,A3 
      MOVEA.L D3,A7 
      BRA.S   L0063 
L0062:BSR.S   L0066 
L0063:BSR.S   L0067 
      MOVE.L  L0198,D5
      BNE.S   L0064 
      BSR.S   L006B 
      MOVE.L  A1,4396(A6) 
      MOVE.W  #1,4316(A6) 
      MOVEQ   #$34,D0 
      BSR     L0073 
L0064:PEA     L0065(PC) 
      MOVE.L  L0198,D5
      BEQ.S   L0065 
      MOVEA.L D5,A0 
      JMP     (A0)
L0065:MOVEQ   #-1,D0
      MOVE.B  L0196,D0
      BRA     L00B2 
L0066:MOVEA.L (A7)+,A0
      BSR.S   L0067 
      MOVEA.L 26(A6),A3 
      LEA     14980(A6),A7
      JMP     (A0)
L0067:LEA     L0199,A6
      LEA     L0005,A4
      LEA     L0195,A5
      MOVE.L  #$8000,D2 
      ADDA.L  D2,A4 
      ADDA.L  D2,A5 
      RTS 
L0068:DC.B   '[1][Erro' 
      DC.B   'r ' 
L0069:DC.B   '+111' 
L006A:DC.B   '][Return' 
      DC.B   ']',$00
L006B:LEA     L0194,A2
L006C:MOVE.B  (A2)+,D1
      CMPI.B  #$7F,D1 
      BEQ.S   L006E 
      CMP.B   D0,D1 
      BEQ.S   L0070 
L006D:TST.B   (A2)+ 
      BNE.S   L006D 
      BRA.S   L006C 
L006E:LEA     L0069(PC),A0
      MOVEQ   #$20,D1 
      EXT.W   D0
      BPL.S   L006F 
      MOVEQ   #$2D,D1 
      NEG.W   D0
L006F:MOVE.B  D1,(A0)+
      EXT.L   D0
      DIVU    #$64,D0 
      ORI.B   #$30,D0 
      MOVE.B  D0,(A0)+
      SWAP    D0
      EXT.L   D0
      DIVU    #$A,D0
      ORI.B   #$30,D0 
      MOVE.B  D0,(A0)+
      SWAP    D0
      ORI.B   #$30,D0 
      MOVE.B  D0,(A0)+
      LEA     L0068(PC),A1
      RTS 
L0070:LEA     70(A6),A0 
      MOVEA.L A0,A1 
      MOVE.L  #$5B315D5B,(A0)+
L0071:MOVE.B  (A2)+,(A0)+ 
      BNE.S   L0071 
      SUBQ.L  #1,A0 
      LEA     L006A(PC),A2
L0072:MOVE.B  (A2)+,(A0)+ 
      BNE.S   L0072 
      RTS 
L0073:PEA     (A1)
      MOVE.W  #9,-(A7)
      TRAP    #1
      ADDQ.L  #6,A7 
      RTS 
      EXG     D0,D1 
L0074:MOVE.L  D1,D3 
      BEQ.S   L007D 
      BMI.S   L0077 
      CMP.L   D0,D1 
      BCC.S   L0075 
      EXT.L   D3
      CMP.L   D1,D3 
      BNE.S   L0077 
      DIVS    D1,D0 
      BVS.S   L0077 
      SWAP    D0
      EXT.L   D0
      RTS 
L0075:BEQ.S   L0076 
      BLT.S   L0077 
      RTS 
L0076:MOVEQ   #0,D0 
      RTS 
L0077:MOVEQ   #0,D5 
      MOVE.L  D1,D3 
      BGE.S   L0078 
      NEG.L   D3
      BSR.S   L0078 
      NEG.L   D0
      RTS 
L0078:TST.L   D0
      BGE.S   L0079 
      NEG.L   D0
L0079:MOVEQ   #1,D4 
      CMP.L   D3,D0 
      BCS.S   L007C 
L007A:ADD.L   D3,D3 
      ADD.L   D4,D4 
      CMP.L   D3,D0 
      BCC.S   L007A 
      BRA.S   L007C 
L007B:CMP.L   D3,D0 
      BCS.S   L007C 
      OR.L    D4,D5 
      SUB.L   D3,D0 
L007C:LSR.L   #1,D3 
      LSR.L   #1,D4 
      BNE.S   L007B 
      RTS 
L007D:MOVEQ   #0,D0 
      JMP     (A6)
L007E:MOVEA.L (A7)+,A1
      LEA     L0195,A5
      LEA     L0199,A6
      LEA     L0005,A4
      LEA     14980(A6),A7
      PEA     (A1)
      MOVE.L  #$8000,D0 
      ADDA.L  D0,A5 
      ADDA.L  D0,A4 
      MOVE.L  A0,42(A6) 
      MOVE.L  #$60064EF9,(A6)+
      MOVE.L  #L0060,(A6)+
      MOVE.W  #$4EF9,(A6)+
      MOVE.L  #L0087,(A6)+
      LEA     -14(A6),A6
      ST      358(A6) 
      MOVEA.L 12(A0),A2 
      ADDA.L  20(A0),A2 
      ADDA.L  28(A0),A2 
      ADDA.W  #$100,A2
      MOVE.L  A2,D0 
      ADD.L   A0,D0 
      MOVE.L  D0,46(A6) 
      PEA     (A2)
      PEA     (A0)
      CLR.W   -(A7) 
      MOVE.W  #$4A,-(A7)
      TRAP    #1
      LEA     12(A7),A7 
      DC.B   $A0,$00
      MOVEM.L A0-A1,50(A6)
      MOVE.W  #$D,356(A6) 
      BSR     L00B3 
      MOVE.W  #$2E2C,1558(A6) 
      PEA     -1.S
      MOVE.W  #$48,-(A7)
      TRAP    #1
      SUBI.L  #$4000,D0 
      ADDQ.L  #6,A7 
      MOVEQ   #-2,D1
      ANDI.L  #-1,D1
      CMP.L   D1,D0 
      BCS.S   L007F 
      MOVE.L  D1,D0 
L007F:MOVE.L  D0,D6 
      MOVE.L  D0,-(A7)
      MOVE.W  #$48,-(A7)
      TRAP    #1
      ADDQ.L  #6,A7 
      MOVE.L  D0,22(A6) 
      ADD.L   D6,D0 
      MOVE.L  D0,38(A6) 
      MOVE.L  #$30002,D3
      MOVE.W  #$1B,-(A7)
      MOVE.L  D3,-(A7)
      TRAP    #$D 
      ADDQ.L  #6,A7 
      MOVE.W  #$66,-(A7)
      MOVE.L  D3,-(A7)
      TRAP    #$D 
      ADDQ.L  #6,A7 
      BSR     L00B5 
      LEA     L0192,A0
      LEA     -32768(A5),A1 
      MOVEA.L A1,A2 
      MOVE.L  (A0),D0 
      LSR.L   #1,D0 
      BRA.S   L0081 
L0080:CLR.W   (A1)+ 
L0081:DBF     D0,L0080
      MOVEA.L A2,A1 
      ADDA.L  (A0)+,A2
      MOVEQ   #1,D1 
      MOVEQ   #0,D0 
      BRA.S   L0084 
L0082:MOVE.L  A2,(A1)+
L0083:SF      (A2)+ 
      SUBQ.B  #1,D0 
      BNE.S   L0083 
L0084:MOVE.B  (A0)+,D0
      BEQ.S   L0085 
      CMP.B   D1,D0 
      BNE.S   L0082 
      BTST    #0,(A0) 
      BNE.S   L0082 
      MOVE.L  A2,D2 
      AND.W   D1,D2 
      BNE.S   L0082 
      ADD.W   D1,D0 
      BRA.S   L0082 
L0085:MOVEA.L 22(A6),A3 
      MOVE.L  A3,26(A6) 
      MOVE.L  A3,30(A6) 
      MOVE.L  38(A6),34(A6) 
      LEA     4980(A6),A0 
      MOVE.W  #$3E7,D0
      MOVEQ   #-1,D1
L0086:ADDQ.L  #4,A0 
      MOVE.W  D1,(A0)+
      DBF     D0,L0086
      LEA     L0194,A2
      MOVE.L  A2,18(A6) 
      RTS 
L0087:DC.B   ' ',$17,'H',$F9,$88,$01
      DC.L    L005F 
      DC.B   'Nu',$00,$00,$00,$00 
L0088:BSR     L00B6 
      TST.L   D0
      BLE.S   L008D 
      MOVE.L  A1,D1 
      MOVE.L  A0,D2 
      OR.L    D2,D1 
      OR.L    D0,D1 
      LSR.W   #1,D1 
      BCC.S   L0093 
      CMPA.L  A1,A0 
      BHI.S   L008E 
      ADDA.L  D0,A0 
      ADDA.L  D0,A1 
      LSR.L   #1,D0 
      BCC.S   L0089 
      MOVE.B  -(A0),-(A1) 
L0089:LSR.L   #1,D0 
      BCC.S   L008C 
      BRA.S   L008B 
L008A:MOVE.B  -(A0),-(A1) 
      MOVE.B  -(A0),-(A1) 
L008B:MOVE.B  -(A0),-(A1) 
      MOVE.B  -(A0),-(A1) 
L008C:DBF     D0,L008A
      SUBI.L  #$10000,D0
      BPL.S   L008A 
L008D:RTS 
L008E:LSR.L   #1,D0 
      BCC.S   L008F 
      MOVE.B  (A0)+,(A1)+ 
L008F:LSR.L   #1,D0 
      BCC.S   L0092 
      BRA.S   L0091 
L0090:MOVE.B  (A0)+,(A1)+ 
      MOVE.B  (A0)+,(A1)+ 
L0091:MOVE.B  (A0)+,(A1)+ 
      MOVE.B  (A0)+,(A1)+ 
L0092:DBF     D0,L0090
      SUBI.L  #$10000,D0
      BPL.S   L0090 
      RTS 
L0093:CMPA.L  A1,A0 
      BHI     L00A5 
      ADDA.L  D0,A0 
      ADDA.L  D0,A1 
      BRA     L0098 
L0094:MOVEA.L A0,A2 
      MOVE.L  (A2),D2 
      MOVE.L  D0,D3 
      MOVEA.L A3,A0 
      MOVE.L  A3,30(A6) 
      LEA     0(A0,D0.L),A1 
      CMPA.L  34(A6),A1 
      BCS.S   L0095 
      BSR     L011F 
      CMPA.L  34(A6),A1 
      BCC.S   L0097 
L0095:MOVE.L  A0,D0 
      SUB.L   D2,D0 
      BSR.S   L0098 
      LEA     34(A6),A0 
L0096:ADD.L   D3,(A2)+
      CMPA.L  A0,A2 
      BNE.S   L0096 
      MOVEA.L D2,A0 
      MOVE.L  D3,D0 
      MOVEA.L 30(A6),A3 
      RTS 
L0097:MOVEQ   #8,D0 
      JMP     2(A6) 
L0098:MOVEM.L A2-A6/D1-D7,-(A7) 
      LSR.L   #1,D0 
      BCC.S   L0099 
      MOVE.B  -(A0),-(A1) 
L0099:LSR.L   #1,D0 
      BCC.S   L009A 
      MOVE.W  -(A0),-(A1) 
L009A:LSR.L   #1,D0 
      BCC.S   L009B 
      MOVE.L  -(A0),-(A1) 
L009B:LSR.L   #1,D0 
      BCC.S   L009C 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
L009C:LSR.L   #1,D0 
      BCC.S   L009D 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
L009D:LSR.L   #1,D0 
      BCC.S   L009E 
      LEA     -32(A0),A0
      MOVEM.L (A0),A2/D1-D7 
      MOVEM.L A2/D1-D7,-(A1)
L009E:LSR.L   #1,D0 
      BCC.S   L009F 
      LEA     -64(A0),A0
      MOVEM.L 32(A0),A2/D1-D7 
      MOVEM.L A2/D1-D7,-(A1)
      MOVEM.L (A0),A2/D1-D7 
      MOVEM.L A2/D1-D7,-(A1)
L009F:LSR.L   #1,D0 
      BCC.S   L00A0 
      LEA     -128(A0),A0 
      MOVEM.L 96(A0),A2/D1-D7 
      MOVEM.L A2/D1-D7,-(A1)
      MOVEM.L 48(A0),A2-A6/D1-D7
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L (A0),A2-A6/D1-D7
      MOVEM.L A2-A6/D1-D7,-(A1) 
L00A0:LSR.L   #1,D0 
      BCC.S   L00A3 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      LEA     -240(A0),A0 
      BRA.S   L00A2 
L00A1:LEA     -512(A0),A0 
      MOVEM.L 480(A0),A2/D1-D7
      MOVEM.L A2/D1-D7,-(A1)
      MOVEM.L 432(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 384(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 336(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 288(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 240(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
L00A2:MOVEM.L 192(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 144(A0),A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 96(A0),A2-A6/D1-D7
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L 48(A0),A2-A6/D1-D7
      MOVEM.L A2-A6/D1-D7,-(A1) 
      MOVEM.L (A0),A2-A6/D1-D7
      MOVEM.L A2-A6/D1-D7,-(A1) 
L00A3:DBF     D0,L00A1
      MOVEM.L (A7)+,A2-A6/D1-D7 
      RTS 
      MOVEA.L A0,A2 
      MOVE.L  (A2),D2 
      MOVE.L  D0,D3 
      MOVEA.L D2,A1 
      LEA     0(A1,D0.L),A0 
      MOVE.L  A3,D0 
      MOVE.L  A3,30(A6) 
      SUB.L   A0,D0 
      BSR.S   L00A5 
      ADDQ.L  #4,A2 
      LEA     34(A6),A0 
L00A4:SUB.L   D3,(A2)+
      CMPA.L  A0,A2 
      BNE.S   L00A4 
      MOVEA.L D2,A0 
      MOVE.L  D3,D0 
      MOVEA.L 30(A6),A3 
      RTS 
L00A5:MOVEM.L A2-A6/D1-D7,-(A7) 
      LSR.L   #1,D0 
      BCC.S   L00A6 
      MOVE.B  (A0)+,(A1)+ 
L00A6:LSR.L   #1,D0 
      BCC.S   L00A7 
      MOVE.W  (A0)+,(A1)+ 
L00A7:LSR.L   #1,D0 
      BCC.S   L00A8 
      MOVE.L  (A0)+,(A1)+ 
L00A8:LSR.L   #1,D0 
      BCC.S   L00A9 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
L00A9:LSR.L   #1,D0 
      BCC.S   L00AA 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
L00AA:LSR.L   #1,D0 
      BCC.S   L00AB 
      MOVEM.L (A0)+,A2/D1-D7
      MOVEM.L A2/D1-D7,(A1) 
      LEA     32(A1),A1 
L00AB:LSR.L   #1,D0 
      BCC.S   L00AC 
      MOVEM.L (A0)+,A2/D1-D7
      MOVEM.L A2/D1-D7,(A1) 
      MOVEM.L (A0)+,A2/D1-D7
      MOVEM.L A2/D1-D7,32(A1) 
      LEA     64(A1),A1 
L00AC:LSR.L   #1,D0 
      BCC.S   L00AD 
      MOVEM.L (A0)+,A2/D1-D7
      MOVEM.L A2/D1-D7,(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,32(A1)
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,80(A1)
      LEA     128(A1),A1
L00AD:LSR.L   #1,D0 
      BCC.S   L00B0 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
      MOVE.L  (A0)+,(A1)+ 
      LEA     -272(A1),A1 
      BRA.S   L00AF 
L00AE:MOVEM.L (A0)+,A2/D1-D7
      MOVEM.L A2/D1-D7,(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,32(A1)
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,80(A1)
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,128(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,176(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,224(A1) 
L00AF:MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,272(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,320(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,368(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,416(A1) 
      MOVEM.L (A0)+,A2-A6/D1-D7 
      MOVEM.L A2-A6/D1-D7,464(A1) 
      LEA     512(A1),A1
L00B0:DBF     D0,L00AE
      MOVEM.L (A7)+,A2-A6/D1-D7 
      RTS 
      BSR     L00B5 
      BRA     L00B5 
L00B1:MOVEQ   #0,D0 
L00B2:MOVE.W  D0,-(A7)
      BSR.S   L00B4 
      BSR     L00B5 
      MOVE.W  #$4C,-(A7)
      TRAP    #1
L00B3:RTS 
L00B4:RTS 
L00B5:RTS 
      SF      358(A6) 
L00B6:PEA     (A2)
      MOVEA.L 50(A6),A2 
      TST.W   -598(A2)
      BEQ.S   L00B7 
      MOVEA.L (A7)+,A2
      RTS 
L00B7:MOVEM.L A0-A1/D0-D2,-(A7) 
      DC.B   $A0,$0A
      MOVEM.L (A7)+,A0-A2/D0-D2 
      RTS 
      ST      358(A6) 
      TST.B   358(A6) 
      BEQ.S   L00BA 
      PEA     (A2)
      MOVEA.L 50(A6),A2 
      TST.W   -598(A2)
      BNE.S   L00B9 
      MOVEA.L (A7)+,A2
      RTS 
L00B8:DC.B   $00,$00
L00B9:MOVEM.L A0-A1/D0-D2,-(A7) 
      LEA     L00B8(PC),A1
      MOVE.L  8(A2),-(A7) 
      MOVE.L  A1,8(A2)
      DC.B   $A0,$09
      MOVEA.L 50(A6),A2 
      MOVE.L  (A7)+,8(A2) 
      MOVEM.L (A7)+,A0-A2/D0-D2 
L00BA:RTS 
L00BB:BSR     L00B6 
      MOVEA.L 50(A6),A0 
      MOVEA.L 12(A0),A1 
      MOVEA.L 8(A0),A2
      MOVE.W  D1,(A1)+
      MOVE.W  D2,(A1)+
      MOVE.W  D0,(A2) 
      DC.B   $A0,$01
      RTS 
      MOVE.B  D0,-(A7)
      PEA     (A0)
      MOVE.W  4(A0),D0
      ADDQ.W  #1,D0 
      BMI.S   L00C3 
      BSR     L0119 
      MOVE.L  A0,D0 
      MOVEA.L A1,A2 
      MOVEA.L (A7)+,A0
      BSR     L012F 
      LSR.W   #1,D1 
      SCS     D2
      BCC.S   L00BC 
      MOVE.W  (A1)+,(A2)+ 
L00BC:LSR.W   #1,D1 
      BCC.S   L00BD 
      MOVE.W  (A1)+,(A2)+ 
L00BD:LSR.W   #1,D1 
      BCC.S   L00BE 
      MOVE.L  (A1)+,(A2)+ 
L00BE:LSR.W   #1,D1 
      BCC.S   L00C1 
      BRA.S   L00C0 
L00BF:MOVE.L  (A1)+,(A2)+ 
      MOVE.L  (A1)+,(A2)+ 
L00C0:MOVE.L  (A1)+,(A2)+ 
      MOVE.L  (A1)+,(A2)+ 
L00C1:DBF     D1,L00BF
      MOVEA.L D0,A0 
      TST.B   D2
      BNE.S   L00C2 
      MOVE.B  (A7)+,(A2)+ 
      RTS 
L00C2:MOVE.B  (A7)+,-(A2) 
      RTS 
L00C3:MOVEQ   #$A,D0
      BRA     L0060 
L00C4:BSR     L012F 
      SUBQ.W  #1,D1 
      BNE.S   L00C5 
      CMP.B   (A1),D0 
L00C5:RTS 
L00C6:BSR.S   L00C4 
      BEQ.S   L00C7 
      BRA.S   L00C8 
      BSR.S   L00C4 
      BNE.S   L00C7 
      BRA.S   L00C8 
      BSR.S   L00C9 
      BCS.S   L00C7 
      BRA.S   L00C8 
      BSR.S   L00C9 
      BLS.S   L00C7 
      BRA.S   L00C8 
      BSR.S   L00C9 
      BLS.S   L00C8 
L00C7:MOVEQ   #-1,D0
      RTS 
      BSR.S   L00C9 
      BCC.S   L00C7 
L00C8:MOVEQ   #0,D0 
      RTS 
L00C9:BSR     L012F 
      SUBQ.W  #1,D1 
      BMI.S   L00CA 
      CMP.B   (A1),D0 
      BNE.S   L00CA 
      TST.W   D1
L00CA:RTS 
      MOVEQ   #$F,D7
      AND.W   D7,D2 
      AND.W   D7,D3 
      AND.W   D7,D0 
      ASL.W   #8,D2 
      ASL.W   #4,D3 
      OR.W    D3,D0 
      OR.W    D2,D0 
L00CB:ANDI.W  #$FFF,D0
      MOVE.W  D0,-(A7)
      MOVE.W  D1,-(A7)
      MOVE.W  #7,-(A7)
      TRAP    #$E 
      ADDQ.L  #6,A7 
      RTS 
L00CC:MOVE.L  (A0)+,D0
      MOVEM.W (A0),D1-D2
      MOVEQ   #0,D4 
      MOVE.W  D2,D3 
      BLE.S   L00D2 
      SUBI.W  #$3FF,D3
      BCS.S   L00D1 
      NOT.W   D3
      BSET    D3,D4 
      CMPI.W  #$41F,D2
      BCC.S   L00CE 
      ADD.L   D4,D0 
      BCS.S   L00CF 
      MOVE.L  D0,-(A0)
L00CD:RTS 
L00CE:CMPI.W  #$42F,D2
      BCC.S   L00CD 
      SWAP    D4
      ADD.W   D4,D1 
      BCC.S   L00D3 
      ADDQ.L  #1,D0 
      BCC.S   L00D0 
L00CF:ROXR.L  #1,D0 
      ROXR.W  #1,D1 
      ADDQ.W  #1,D2 
L00D0:MOVEM.W D1-D2,(A0)
      MOVE.L  D0,-(A0)
      RTS 
L00D1:MOVE.L  #-$80000000,D3
      MOVE.W  #$3FF,D5
      BSR     L000E 
      BRA.S   L00D0 
L00D2:BEQ.S   L00D1 
      CMPI.W  #-$3FF,D2 
      BHI.S   L00D1 
      SUBQ.W  #2,D3 
      BSET    D3,D4 
      CMPI.W  #-$41F,D2 
      BLS.S   L00D4 
      SUB.L   D4,D0 
      BPL.S   L00D5 
      MOVE.L  D0,-(A0)
      RTS 
L00D3:MOVE.W  D1,(A0) 
      RTS 
L00D4:CMPI.W  #-$42F,D2 
      BLS.S   L00CD 
      SWAP    D4
      SUB.W   D4,D1 
      BCC.S   L00D3 
      SUBQ.L  #1,D0 
      BMI.S   L00D0 
L00D5:BEQ.S   L00D7 
L00D6:ADDQ.W  #1,D2 
      ADD.W   D1,D1 
      ADDX.L  D0,D0 
      BPL.S   L00D6 
      BRA.S   L00D0 
L00D7:MOVE.W  D1,D0 
      BNE.S   L00D8 
      CLR.L   (A0)
      RTS 
L00D8:ADDI.W  #$20,D2 
      SWAP    D0
      MOVE.L  D0,D1 
      BPL.S   L00D6 
      BRA.S   L00D0 
      LEA     6(A3),A2
      CMPA.L  34(A6),A2 
      BCS.S   L00DA 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCS.S   L00DA 
L00D9:MOVEQ   #8,D0 
      BRA     L0060 
L00DA:MOVE.L  D0,(A3)+
      MOVE.W  #-4,(A3)+ 
      RTS 
      LEA     10(A3),A2 
      CMPA.L  34(A6),A2 
      BCS.S   L00DB 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC.S   L00D9 
L00DB:MOVE.L  D0,(A3)+
      MOVE.L  D1,(A3)+
      MOVE.W  #-8,(A3)+ 
      RTS 
      LEA     4(A3),A2
      CMPA.L  34(A6),A2 
      BCS.S   L00DC 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC.S   L00D9 
L00DC:MOVE.W  D0,(A3)+
      MOVE.W  #-2,(A3)+ 
      RTS 
      LEA     6(A3),A2
      CMPA.L  34(A6),A2 
      BCS.S   L00DD 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC.S   L00D9 
L00DD:MOVE.W  D0,(A3)+
      MOVE.W  D1,(A3)+
      MOVE.W  #-4,(A3)+ 
      RTS 
      MOVE.B  D0,D1 
      LEA     4(A3),A2
      CMPA.L  34(A6),A2 
      BCS.S   L00DE 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC.S   L00D9 
L00DE:MOVE.B  D1,(A3)+
      MOVE.B  D0,(A3)+
      MOVE.W  #-2,(A3)+ 
      RTS 
L00DF:LEA     14(A3),A2 
      CMPA.L  34(A6),A2 
      BCS.S   L00E0 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC     L00D9 
L00E0:MOVE.L  D0,(A3)+
      MOVE.W  D1,(A3)+
      MOVE.W  D2,(A3)+
      MOVE.L  A0,(A3)+
      MOVE.W  #-$C,(A3)+
      BRA     L0006 
      MOVE.L  (A1)+,D0
      MOVE.W  (A1)+,D1
      MOVE.W  (A1)+,D2
      BRA.S   L00E2 
L00E1:MOVEA.L -6(A3),A0 
      BSR     L00CC 
      LEA     -14(A3),A0
L00E2:MOVE.L  (A0)+,D3
      MOVE.W  (A0)+,D4
      MOVE.W  (A0)+,D5
      CMP.W   D2,D5 
      BEQ.S   L00E4 
      BGT.S   L00E7 
L00E3:MOVEQ   #0,D0 
      RTS 
L00E4:MOVE.W  D2,D6 
      BGT.S   L00E5 
      BEQ.S   L00E7 
      CMP.L   D3,D0 
      BNE.S   L00E6 
      CMP.W   D4,D1 
      BCS.S   L00E3 
      MOVEQ   #-1,D0
      RTS 
L00E5:CMP.L   D0,D3 
      BNE.S   L00E6 
      CMP.W   D1,D4 
L00E6:BCS.S   L00E3 
L00E7:MOVEQ   #-1,D0
      RTS 
L00E8:MOVE.L  (A0)+,D0
      MOVE.W  (A0)+,D1
      MOVE.W  (A0)+,D2
      TST.W   D2
      BLE.S   L00EA 
      ADDQ.W  #1,D2 
      BMI.S   L00ED 
L00E9:RTS 
L00EA:BEQ.S   L00E9 
      SUBQ.W  #1,D2 
      BMI.S   L00E9 
      BRA.S   L00ED 
      MOVE.L  (A0)+,D0
      MOVE.W  (A0)+,D1
      MOVE.W  (A0)+,D2
      TST.W   D2
      BLE.S   L00EC 
      ADD.W   D3,D2 
      BMI.S   L00ED 
L00EB:RTS 
L00EC:BEQ.S   L00EB 
      SUB.W   D3,D2 
      BMI.S   L00EB 
L00ED:BRA     L005D 
L00EE:MOVEQ   #$64,D7 
      CMP.W   D7,D0 
      BCC.S   L00EF 
      LEA     498(A6),A2
      ADDA.W  D0,A2 
      MOVE.B  (A2),D7 
      EXT.W   D7
      MOVE.W  D7,D6 
      RTS 
L00EF:MOVEQ   #$17,D0 
      BRA     L0060 
L00F0:MOVE.W  D6,D0 
      ADD.W   D0,D0 
      ADD.W   D6,D0 
      ADD.W   D0,D0 
      LEA     956(A6),A0
      ADDA.W  D0,A0 
      TST.W   4(A0) 
      BEQ.S   L00F1 
      MOVEA.L (A0),A0 
      MOVEM.W (A0),D0-D2
      RTS 
L00F1:BRA     L0060 
L00F2:MOVEM.W (A0),D0-D2
      TST.L   D0
      BEQ.S   L00F3 
      PEA     (A0)
      CLR.L   (A0)+ 
      BCLR    #7,(A0) 
      PEA     6(A0) 
      MOVE.L  D0,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.W  #$40,-(A7)
      TRAP    #1
      ADDQ.L  #4,A7 
      MOVEM.L (A7)+,A0/D1-D2
      CMP.L   D0,D1 
      BNE.S   L00F4 
      ADD.L   D0,6(A0)
      MOVEM.W (A0),D0-D2
L00F3:RTS 
L00F4:TST.L   D0
      BMI.S   L00F5 
      MOVEQ   #$25,D0 
L00F5:BRA     L0060 
      BSR     L00F0 
      TST.W   D2
      BPL.S   L00F6 
      BSR.S   L00F2 
L00F6:MOVE.L  #-$100A,4106(A0)
      MOVE.W  D6,-(A7)
      MOVE.W  #$3E,-(A7)
      TRAP    #1
      ADDQ.W  #4,A7 
      TST.L   D0
      BMI.S   L00F5 
      MOVEQ   #0,D0 
      RTS 
      MOVE.W  #$D0A,D0
      BSR.S   L00FB 
      BRA.S   L00F8 
L00F7:MOVE.W  #$D0A,D0
L00F8:LEA     326(A6),A1
      MOVE.W  D0,(A1) 
      MOVEQ   #2,D0 
      BRA     L0101 
      MOVEQ   #$20,D0 
      BSR.S   L00FB 
      BRA.S   L00F9 
      MOVEQ   #$20,D0 
L00F9:LEA     326(A6),A1
      MOVE.B  D0,(A1) 
      MOVEQ   #1,D0 
      BRA     L0101 
      BSR.S   L00FB 
      LEA     326(A6),A1
      MOVE.L  D0,(A1) 
      MOVEQ   #4,D0 
      BRA     L0101 
      PEA     L00F7(PC) 
      BSR.S   L00FB 
      BRA.S   L00FA 
      PEA     L00F7(PC) 
L00FA:MOVEA.L A2,A1 
      BRA     L0101 
L00FB:CLR.B   64(A6)
      MOVE.W  #-4,68(A6)
      RTS 
      BSR.S   L00FB 
      MOVE.B  64(A6),D1 
      NOT.B   D1
      MOVEQ   #$F,D0
      AND.W   D1,D0 
      ADDQ.W  #1,D0 
      LEA     L00FC(PC),A1
      BRA     L0101 
L00FC:MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      MOVE.L  -(A0),D0
      CLR.B   64(A6)
      MOVE.W  #-7,68(A6)
      RTS 
L00FD:CLR.B   64(A6)
      BSR     L00EE 
      MOVE.W  D7,68(A6) 
      BEQ.S   L00FE 
      RTS 
L00FE:MOVEQ   #$18,D0 
      BRA     L0060 
      BSR     L00FD 
      BRA.S   L0100 
L00FF:BSR     L00FB 
L0100:LEA     70(A6),A1 
      MOVE.L  #$1B450D00,(A1) 
      MOVEQ   #3,D0 
      BRA     L0101 
L0101:ADD.B   D0,64(A6) 
      MOVE.W  68(A6),D6 
      LEA     368(A6),A0
      ADDA.W  D6,A0 
      MOVE.B  (A0),D7 
      MOVEA.L A1,A2 
      MOVE.L  D0,D1 
      MOVEQ   #$D,D2
L0102:DBF     D1,L0103
      SUBI.L  #$10000,D1
      BMI.S   L0105 
L0103:ADDQ.W  #1,D7 
      CMP.B   (A2)+,D2
      BCS.S   L0102 
      BNE.S   L0104 
      MOVEQ   #0,D7 
      BRA.S   L0102 
L0104:SUBQ.W  #1,D7 
      CMPI.B  #$A,-1(A2)
      BEQ.S   L0102 
      CMPI.B  #8,-1(A2) 
      BNE.S   L0102 
      SUBQ.W  #1,D7 
      BRA.S   L0102 
L0105:MOVE.B  D7,(A0) 
      MOVE.W  68(A6),D6 
      BPL.S   L010A 
      ADDQ.W  #6,D6 
      BMI.S   L0109 
      TST.W   4704(A6)
      BEQ.S   L0106 
      CMPI.W  #2,D6 
      BEQ.S   L010B 
      CMPI.W  #5,D6 
      BEQ.S   L010B 
L0106:PEA     (A3)
      MOVEA.L A1,A3 
      MOVE.L  D0,D7 
      BSR     L00B6 
      DBF     D7,L0107
      BRA.S   L0108 
L0107:MOVEQ   #0,D0 
      MOVE.B  (A3)+,D0
      MOVE.W  D0,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.W  #3,-(A7)
      TRAP    #$D 
      ADDQ.L  #6,A7 
      DBF     D7,L0107
L0108:SUBI.L  #$10000,D7
      BPL.S   L0107 
      MOVEA.L (A7)+,A3
      RTS 
L0109:PEA     (A1)
      MOVE.L  D0,-(A7)
      MOVE.W  #-3,-(A7) 
      MOVE.W  #$40,-(A7)
      TRAP    #1
      LEA     12(A7),A7 
      RTS 
L010A:BRA     L013F 
      MOVE.W  4704(A6),-(A7)
      CLR.W   4704(A6)
      BSR     L0101 
      MOVE.W  (A7)+,4704(A6)
      RTS 
      BRA     L010B 
L010B:RTS 
L010C:LEA     12(A3),A2 
      CMPA.L  34(A6),A2 
      BCS.S   L010D 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BHI     L0138 
L010D:MOVE.L  A3,D0 
      MOVEA.L (A7)+,A1
      MOVE.W  (A7)+,(A3)+ 
      MOVE.L  (A0),(A3)+
      MOVE.L  D0,(A0) 
      MOVE.L  A0,(A3)+
      MOVE.W  #6,(A3)+
      JMP     (A1)
L010E:BSR     L010F 
      BEQ     L0111 
      TST.B   D0
      BNE     L011D 
      SWAP    D0
      ANDI.W  #$FF,D0 
      BRA     L011E 
L010F:PEA     $00010002 
      TRAP    #$D 
      ADDQ.L  #4,A7 
      TST.L   D0
      BEQ.S   L0110 
      PEA     $00020002 
      TRAP    #$D 
      ADDQ.L  #4,A7 
      TST.L   D0
L0110:RTS 
L0111:MOVEQ   #0,D0 
      BRA.S   L0119 
      BSR.S   L0119 
      BRA.S   L0113 
L0112:MOVE.B  (A2)+,(A1)+ 
L0113:DBF     D0,L0112
      RTS 
      MOVE.B  D0,D2 
      MOVEQ   #1,D0 
      BSR.S   L0114 
      MOVE.B  D2,(A1) 
      RTS 
      MOVE.W  D0,D2 
      MOVEQ   #2,D0 
      BSR.S   L0114 
      MOVE.W  D2,(A1) 
      RTS 
      MOVE.L  D0,D2 
      MOVEQ   #4,D0 
      BSR.S   L0114 
      MOVE.L  D2,(A1) 
      RTS 
      MOVEQ   #0,D0 
L0114:MOVE.W  4(A0),D1
      BEQ.S   L0115 
      MOVEA.L (A0),A1 
      CMP.W   D0,D1 
      BEQ.S   L0117 
      ADDQ.W  #1,D1 
      ANDI.B  #-2,D1
      ADDA.W  D1,A1 
      NEG.W   D1
      EXT.L   D1
      MOVE.L  D1,(A1) 
L0115:MOVEA.L 34(A6),A1 
      MOVEQ   #0,D1 
      MOVE.W  D0,D1 
      BEQ.S   L0118 
      ADDQ.W  #5,D1 
      ANDI.B  #-2,D1
      SUBA.L  D1,A1 
      CMPA.L  A3,A1 
      BCS.S   L011C 
L0116:MOVE.L  A1,(A0) 
      MOVE.W  D0,4(A0)
      MOVE.L  A0,-4(A1,D1.L)
      MOVE.L  A1,34(A6) 
L0117:RTS 
L0118:MOVE.W  D0,4(A0)
      RTS 
L0119:LEA     4980(A6),A0 
      MOVE.W  #$3E7,D1
L011A:ADDQ.L  #4,A0 
      TST.W   (A0)+ 
      DBMI    D1,L011A
      BPL.S   L011B 
      SUBQ.L  #6,A0 
      BRA.S   L0115 
L011B:MOVEQ   #$E,D0
      BRA     L0060 
L011C:BSR.S   L011F 
      MOVEA.L 34(A6),A1 
      SUBA.L  D1,A1 
      CMPA.L  A3,A1 
      BCC.S   L0116 
      MOVEQ   #8,D0 
      BRA     L0060 
L011D:MOVE.B  D0,-(A7)
      MOVEQ   #1,D0 
      BSR.S   L0119 
      MOVE.B  (A7)+,(A1)
      RTS 
L011E:MOVE.W  D0,-(A7)
      MOVEQ   #2,D0 
      BSR.S   L0119 
      MOVE.W  (A7)+,(A1)
      RTS 
      MOVE.L  D0,-(A7)
      MOVEQ   #4,D0 
      BSR.S   L0119 
      MOVE.L  (A7)+,(A1)
      RTS 
L011F:MOVEM.L A0-A3/D0-D7,-(A7) 
      MOVEA.L 38(A6),A0 
      MOVEA.L 34(A6),A2 
L0120:MOVEA.L A0,A1 
      CMPA.L  A0,A2 
      BEQ.S   L012C 
      MOVE.L  -(A0),D0
      BMI.S   L0121 
      MOVEA.L D0,A3 
      MOVEA.L (A3),A0 
      BRA.S   L0120 
L0121:ADDA.L  D0,A0 
      CMPA.L  A0,A2 
      BEQ.S   L012B 
L0122:MOVE.L  -(A0),D0
      BMI.S   L0121 
      MOVE.L  D0,-(A1)
      MOVEA.L D0,A3 
      MOVE.W  4(A3),D0
      LSR.W   #1,D0 
      BCC.S   L0123 
      MOVE.W  -(A0),-(A1) 
L0123:LSR.W   #1,D0 
      BCC.S   L0124 
      MOVE.W  -(A0),-(A1) 
L0124:LSR.W   #1,D0 
      BCC.S   L0125 
      MOVE.L  -(A0),-(A1) 
L0125:LSR.W   #1,D0 
      BCC.S   L0126 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
L0126:LSR.W   #1,D0 
      BCC.S   L0127 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
      MOVE.L  -(A0),-(A1) 
L0127:LSR.W   #1,D0 
      BCC.S   L012A 
      BRA.S   L0129 
L0128:MOVE.L  -(A0),-(A1) 
      LEA     -28(A0),A0
      MOVEM.L (A0),D1-D7
      MOVEM.L D1-D7,-(A1) 
L0129:MOVE.L  -(A0),-(A1) 
      LEA     -28(A0),A0
      MOVEM.L (A0),D1-D7
      MOVEM.L D1-D7,-(A1) 
L012A:DBF     D0,L0128
      MOVE.L  A1,(A3) 
      CMPA.L  A0,A2 
      BNE.S   L0122 
L012B:MOVE.L  A1,34(A6) 
L012C:MOVEM.L (A7)+,A0-A3/D0-D7 
      RTS 
      BSR     L011F 
      MOVE.L  34(A6),D0 
      SUB.L   A3,D0 
      RTS 
      BSR.S   L012F 
      TST.W   D1
      BNE.S   L012D 
      LEA     L012E(PC),A1
L012D:RTS 
L012E:DS.W    2,0 
L012F:MOVEA.L (A0)+,A1
      MOVE.W  (A0),D1 
      CMPA.L  A6,A0 
      BCS.S   L0130 
      CMPA.L  A7,A0 
      BHI.S   L0130 
      ST      (A0)
      MOVE.W  D1,D3 
      BEQ.S   L0130 
      EXT.L   D3
      ADDQ.W  #1,D3 
      ANDI.B  #-2,D3
      MOVE.L  D3,D4 
      NEG.L   D3
      MOVE.L  D3,0(A1,D4.L) 
L0130:RTS 
L0131:ILLEGAL 
L0132:LEA     0(A3,D3.W),A3 
L0133:MOVE.W  -(A3),D3
      BNE.S   L0134 
      MOVE.L  -(A3),D3
      BLE.S   L0131 
      MOVE.L  A3,30(A6) 
      MOVEA.L D3,A1 
      JMP     (A1)
L0134:BMI.S   L0132 
      MOVEA.L -(A3),A1
      MOVE.L  -(A3),(A1)
      SUBA.W  D3,A3 
      CMPI.W  #$A,D3
      BEQ.S   L0135 
      ADDQ.L  #2,A3 
      MOVE.W  (A3),D3 
      BNE.S   L0134 
      MOVE.L  -(A3),D3
      BLE.S   L0131 
      MOVE.L  A3,30(A6) 
      MOVEA.L D3,A1 
      JMP     (A1)
L0135:ADDQ.L  #8,A3 
      MOVEQ   #0,D3 
      MOVE.W  (A3),D3 
      MOVEA.L -(A3),A1
      BEQ.S   L0133 
      ADDQ.W  #1,D3 
      ANDI.W  #-2,D3
      MOVE.L  D3,D4 
      NEG.L   D4
      MOVE.L  D4,0(A1,D3.L) 
      BRA.S   L0133 
L0136:LEA     6(A3),A2
      CMPA.L  34(A6),A2 
      BCS.S   L0137 
      BSR     L011F 
      CMPA.L  34(A6),A2 
      BCC.S   L0138 
L0137:MOVEA.L (A7)+,A1
      MOVE.L  (A7)+,(A3)+ 
      CLR.W   (A3)+ 
      JMP     (A1)
L0138:MOVEQ   #$5A,D0 
      BRA     L0060 
L0139:MOVE.W  #$25,-(A7)
      TRAP    #$E 
      ADDQ.L  #2,A7 
      RTS 
L013A:LEA     L013D(PC),A1
      MOVE.B  D0,(A1) 
      MOVEQ   #1,D0 
L013B:PEA     (A1)
      MOVE.L  D0,-(A7)
      PEA     $00400001 
      TRAP    #1
      ADDA.W  #$C,A7
      RTS 
L013C:LEA     L013D(PC),A1
      MOVEQ   #1,D0 
      BSR.S   L013E 
      MOVE.B  L013D(PC),D0
      RTS 
L013D:DC.B   $00,$00
L013E:PEA     (A1)
      MOVE.L  D0,-(A7)
      PEA     $003F0000 
      TRAP    #1
      ADDA.W  #$C,A7
      RTS 
L013F:MOVE.L  D0,D3 
      BEQ.S   L0143 
      CMPI.W  #1,D6 
      BEQ.S   L013B 
      BSR     L00F0 
      BTST    #1,D2 
      BEQ     L014F 
      TST.W   D1
      BEQ.S   L0140 
      BSR     L0150 
L0140:BSET    #7,4(A0)
      MOVE.W  #$1000,D1 
L0141:MOVE.B  (A1)+,10(A0,D0.W) 
      ADDQ.W  #1,D0 
      CMP.W   D1,D0 
      BCC.S   L0144 
L0142:SUBQ.L  #1,D3 
      BNE.S   L0141 
      MOVE.W  D0,(A0) 
L0143:RTS 
L0144:MOVE.W  D0,(A0) 
      BSR     L00F2 
      MOVEQ   #0,D0 
      CMPI.W  #$1000,D3 
      BCS.S   L0142 
      BRA     L015D 
      MOVE.L  D0,D3 
      BEQ.S   L0148 
      CMPI.W  #1,D6 
      BEQ.S   L013E 
      BSR     L00F0 
      TST.W   D2
      BPL.S   L0145 
      BSR     L00F2 
L0145:BTST    #0,D2 
      BEQ.S   L014C 
L0146:CMP.W   D1,D0 
      BCS.S   L0147 
      CMPI.W  #$1000,D3 
      BHI     L015C 
      BSR     L0154 
L0147:MOVE.B  10(A0,D0.W),(A1)+ 
      ADDQ.W  #1,D0 
      SUBQ.L  #1,D3 
      BNE.S   L0146 
      MOVE.W  D0,(A0) 
L0148:RTS 
      CMPI.W  #1,D6 
      BEQ     L013C 
      BSR     L00F0 
      BTST    #0,D2 
      BEQ.S   L014C 
      TST.W   D2
      BPL.S   L0149 
      BSR     L00F2 
L0149:CMP.W   D1,D0 
      BCS.S   L014A 
      BSR     L0154 
      TST.W   D1
      BEQ.S   L014B 
L014A:ADDQ.W  #1,(A0) 
      MOVE.B  10(A0,D0.W),D1
      MOVEQ   #0,D0 
      MOVE.B  D1,D0 
L014B:RTS 
L014C:BRA     L0060 
      CMPI.W  #1,D6 
      BEQ     L013A 
      MOVE.W  D0,D3 
      BSR     L00F0 
      BTST    #1,D2 
      BEQ.S   L014F 
      TST.W   D1
      BEQ.S   L014D 
      BSR.S   L0150 
L014D:CMPI.W  #$1000,D0 
      BCS.S   L014E 
      BSR     L00F2 
L014E:ADDQ.W  #1,(A0) 
      MOVE.B  D3,10(A0,D0.W)
      BSET    #7,4(A0)
      RTS 
L014F:MOVEQ   #$D,D0
      JMP     (A6)
L0150:MOVEM.L A0-A1,-(A7) 
      SUB.L   D1,D0 
      ADD.L   D0,6(A0)
      CLR.L   (A0)
      MOVE.W  #1,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.L  D0,-(A7)
      MOVE.W  #$42,-(A7)
      TRAP    #1
      LEA     10(A7),A7 
      TST.L   D0
      BMI     L015F 
      MOVEM.L (A7)+,A0-A1 
      MOVEM.W (A0),D0-D2
      RTS 
      MOVE.L  D0,D3 
      MOVE.W  D1,D4 
      BSR     L00F0 
      TST.W   D2
      BPL.S   L0151 
      BSR     L00F2 
L0151:TST.W   D1
      BEQ.S   L0152 
      CMPI.W  #1,D4 
      BNE.S   L0152 
      MOVE.L  D0,D5 
      ADD.L   D3,D5 
      BMI.S   L0152 
      CMP.L   D1,D5 
      BCC.S   L0152 
      MOVE.W  D5,(A0) 
      RTS 
L0152:CMPI.W  #1,D4 
      BNE.S   L0153 
      SUB.L   D1,D3 
      ADD.L   D0,D3 
L0153:CLR.L   (A0)
      MOVEM.L A0-A1,-(A7) 
      MOVE.W  D4,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.L  D3,-(A7)
      MOVE.W  #$42,-(A7)
      TRAP    #1
      LEA     10(A7),A7 
      MOVEM.L (A7)+,A0-A1 
      TST.L   D0
      BMI     L015F 
      MOVE.L  D0,6(A0)
      RTS 
L0154:MOVEM.L A0-A1,-(A7) 
      CLR.L   (A0)
      PEA     10(A0)
      PEA     $1000.S 
      MOVE.W  D6,-(A7)
      MOVE.W  #$3F,-(A7)
      TRAP    #1
      LEA     12(A7),A7 
      MOVEM.L (A7)+,A0-A1 
      TST.L   D0
      BLE.S   L0156 
L0155:MOVE.L  D0,(A0) 
      ADD.L   D0,6(A0)
      MOVEM.W (A0),D0-D2
      RTS 
L0156:BMI.S   L0158 
      MOVE.B  L015B(PC),D1
      BNE.S   L0155 
L0157:MOVEQ   #$1A,D0 
L0158:BRA.S   L015F 
L0159:BMI.S   L0158 
L015A:MOVE.B  L015B(PC),D1
      BEQ.S   L0157 
      MOVE.L  D0,(A0) 
      ADD.L   D0,6(A0)
      RTS 
L015B:DC.B   $00,$00
L015C:CLR.L   (A0)
      PEA     (A0)
      PEA     (A1)
      MOVE.L  D3,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.W  #$3F,-(A7)
      TRAP    #1
      LEA     12(A7),A7 
      MOVEA.L (A7)+,A0
      TST.L   D0
      BLE.S   L0159 
      ADD.L   D0,6(A0)
      CMP.L   D3,D0 
      BNE.S   L015A 
      RTS 
L015D:CLR.L   (A0)
      PEA     (A0)
      PEA     (A1)
      SUBQ.L  #1,D3 
      MOVE.L  D3,-(A7)
      MOVE.W  D6,-(A7)
      MOVE.W  #$40,-(A7)
      TRAP    #1
      ADDQ.L  #4,A7 
      MOVEM.L (A7)+,A0/D1-D2
      CMP.L   D0,D1 
      BNE.S   L015E 
      ADD.L   D0,6(A0)
      RTS 
L015E:TST.L   D0
      BMI.S   L015F 
      MOVEQ   #$25,D0 
L015F:BRA     L0060 
      LEA     -2.S,A1 
      BRA.S   L0161 
      LEA     -1.S,A1 
      BRA.S   L0161 
L0160:SUBA.L  A1,A1 
      BRA.S   L0161 
      LEA     1.S,A1
      BRA.S   L0161 
      LEA     3.S,A1
      BRA.S   L0161 
      LEA     2.S,A1
L0161:TST.W   4(A0) 
      BNE     L0173 
      TST.L   14(A6)
      BNE.S   L0162 
      ADDQ.L  #1,D0 
      ADDQ.L  #1,D1 
      ADDQ.L  #1,D2 
      ADDQ.L  #1,D3 
      ADDQ.L  #1,D4 
      ADDQ.L  #1,D5 
      ADDQ.L  #1,D6 
L0162:PEA     (A0)
      MOVE.W  A1,-(A7)
      EXG     D0,D7 
      LEA     70(A6),A1 
      MOVEM.L D1-D6,(A1)
      MOVE.W  D0,D4 
      MOVE.W  D4,D5 
      ASL.W   #2,D5 
      MOVE.L  D7,-4(A1,D5.W)
      MOVE.L  #$FFFF,D3 
      MOVE.W  (A7),D1 
      MOVE.L  (A1)+,D0
      BRA.S   L0164 
L0163:CMP.L   D3,D0 
      BHI     L0173 
      MOVE.L  (A1)+,D2
      CMP.L   D3,D2 
      BHI     L0173 
      MULU    D2,D0 
L0164:SUBQ.W  #4,D5 
      BNE.S   L0163 
      BRA.S   L0168 
L0165:ADDQ.W  #1,D1 
      BNE.S   L0166 
      MOVEQ   #$F,D1
      ADD.L   D1,D0 
      LSR.L   #4,D0 
      ADD.L   D0,D0 
      BRA.S   L016A 
L0166:ADD.L   D0,D0 
      BCS.S   L0167 
      MOVE.L  D0,D1 
      ADD.L   D0,D0 
      BCS.S   L0167 
      ADD.L   D1,D0 
      BCC.S   L016A 
L0167:MOVEQ   #8,D0 
      BRA     L0060 
L0168:TST.W   D1
      BMI.S   L0165 
      BNE.S   L0169 
      BTST    #0,D0 
      BEQ.S   L0169 
      ADDQ.L  #1,D0 
L0169:ASL.L   D1,D0 
      BCS.S   L0167 
L016A:MOVEQ   #8,D1 
      MOVE.W  D4,-(A7)
      ASL.W   #2,D4 
      ADD.W   D4,D1 
      ADD.L   D1,D0 
      BSR     L0174 
      LEA     26(A6),A0 
      BSR     L0094 
      MOVE.W  (A7)+,D4
      MOVEA.L A0,A2 
      ADDQ.L  #4,A0 
      MOVE.L  D0,(A0)+
      MOVE.W  D4,D5 
      LEA     70(A6),A1 
      ASL.W   #2,D5 
      ADDA.W  D5,A1 
      BRA.S   L016C 
L016B:MOVE.L  -(A1),(A0)+ 
L016C:SUBQ.W  #4,D5 
      BPL.S   L016B 
      ADDQ.L  #2,A7 
      MOVEA.L (A7)+,A1
      MOVE.L  A1,(A2) 
      ADDQ.L  #8,A2 
      MOVE.L  A2,(A1)+
      MOVE.W  D4,(A1)+
      MOVEQ   #0,D2 
      MOVEQ   #8,D1 
      ASL.W   #2,D4 
      ADD.W   D4,D1 
      SUB.L   D1,D0 
      LSR.L   #2,D0 
      BCC.S   L016D 
      MOVE.W  D2,(A0)+
L016D:LSR.L   #1,D0 
      BCC.S   L016E 
      MOVE.L  D2,(A0)+
L016E:LSR.L   #1,D0 
      BCC.S   L016F 
      MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
L016F:LSR.L   #1,D0 
      BCC.S   L0172 
      BRA.S   L0171 
L0170:MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
L0171:MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
      MOVE.L  D2,(A0)+
L0172:DBF     D0,L0170
      SUBI.L  #$10000,D0
      BPL.S   L0170 
      RTS 
L0173:BRA     L0060 
      BSR     L0187 
      NEG.L   D0
      BSR.S   L0175 
      NEG.L   D0
      RTS 
L0174:MOVEA.L 26(A6),A0 
      BSR.S   L017F 
L0175:MOVEA.L A3,A0 
      MOVEA.L 26(A6),A1 
L0176:CMPA.L  A0,A1 
      BEQ.S   L017B 
L0177:MOVE.W  -(A0),D1
      MOVEA.L -(A0),A2
      BEQ.S   L0176 
      BMI.S   L017C 
      MOVEA.L A0,A3 
      SUBA.W  D1,A3 
      CMPA.L  (A2),A3 
      BEQ.S   L0178 
      CMPI.W  #4,D1 
      BNE.S   L0179 
      CMPA.L  (A2),A1 
      BCC.S   L0179 
      CMPA.L  (A2),A0 
      BCS.S   L0179 
L0178:ADD.L   D0,(A2) 
L0179:MOVEA.L -(A0),A2
      CMPA.L  A1,A2 
      BCS.S   L017A 
      CMPA.L  A0,A2 
      BHI.S   L017A 
      ADD.L   D0,(A0) 
L017A:SUBA.W  D1,A0 
      ADDQ.L  #4,A0 
      CMPA.L  A0,A1 
      BNE.S   L0177 
L017B:MOVEA.L 30(A6),A3 
      RTS 
L017C:CMPI.W  #-1,D1
      BEQ.S   L017E 
      CMPA.L  A1,A2 
      BCS.S   L017D 
      CMPA.L  A0,A2 
      BHI.S   L017D 
      ADD.L   D0,(A0) 
L017D:LEA     4(A0,D1.W),A0 
      BRA.S   L0176 
L017E:SUBA.L  A2,A0 
      BRA.S   L0176 
L017F:MOVE.L  A3,30(A6) 
      MOVEQ   #-2,D4
      MOVE.L  A0,D2 
      MOVEA.L 38(A6),A0 
      MOVEA.L 34(A6),A2 
L0180:MOVEA.L A0,A1 
      CMPA.L  A0,A2 
      BEQ.S   L0186 
      MOVE.L  -(A0),D1
      MOVEA.L D1,A3 
      BMI.S   L0182 
      CMP.L   D2,D1 
      BLS.S   L0181 
      ADD.L   D0,(A0) 
L0181:MOVEA.L (A3),A0 
      BRA.S   L0180 
L0182:ADDA.L  D1,A0 
      CMPA.L  A0,A2 
      BEQ.S   L0186 
L0183:MOVE.L  -(A0),D1
      BMI.S   L0182 
      MOVE.L  D1,-(A1)
      MOVEA.L D1,A3 
      CMP.L   D2,D1 
      BLS.S   L0184 
      ADD.L   D0,(A1) 
L0184:MOVE.W  4(A3),D1
      SUBQ.W  #1,D1 
      LSR.W   #1,D1 
L0185:MOVE.W  -(A0),-(A1) 
      DBF     D1,L0185
      MOVE.L  A1,(A3) 
      CMPA.L  A0,A2 
      BNE.S   L0183 
L0186:MOVE.L  A1,34(A6) 
      MOVEA.L 30(A6),A3 
      RTS 
L0187:MOVE.L  A3,30(A6) 
      MOVEQ   #-2,D4
      MOVE.L  A0,D2 
      MOVE.L  D2,D3 
      ADD.L   D0,D3 
      MOVEA.L 38(A6),A0 
      MOVEA.L 34(A6),A2 
L0188:MOVEA.L A0,A1 
      CMPA.L  A0,A2 
      BEQ.S   L0191 
      MOVE.L  -(A0),D1
      BMI.S   L018B 
      MOVEA.L D1,A3 
      CMP.L   D2,D1 
      BLS.S   L018A 
      CMP.L   D3,D1 
      BHI.S   L0189 
      MOVEA.L (A3),A0 
      BRA.S   L018C 
L0189:SUB.L   D0,(A0) 
L018A:MOVEA.L (A3),A0 
      BRA.S   L0188 
L018B:ADDA.L  D1,A0 
L018C:CMPA.L  A0,A2 
      BEQ.S   L0191 
L018D:MOVE.L  -(A0),D1
      BMI.S   L018B 
      MOVE.L  D1,-(A1)
      MOVEA.L D1,A3 
      CMP.L   D2,D1 
      BLS.S   L018F 
      CMP.L   D3,D1 
      BHI.S   L018E 
      MOVEQ   #1,D1 
      ADD.W   4(A3),D1
      AND.B   D4,D1 
      SUBA.L  D1,A0 
      ADDQ.L  #4,A1 
      BRA.S   L018C 
L018E:SUB.L   D0,(A1) 
L018F:MOVE.W  4(A3),D1
      SUBQ.W  #1,D1 
      LSR.W   #1,D1 
L0190:MOVE.W  -(A0),-(A1) 
      DBF     D1,L0190
      MOVE.L  A1,(A3) 
      CMPA.L  A0,A2 
      BNE.S   L018D 
L0191:MOVE.L  A1,34(A6) 
      MOVEA.L 30(A6),A3 
      RTS 
 DATA 
L0192:DC.B   $00,$00,$00,'X',$02,$00
L0193:DC.B   $1A,'@I',$C0,'!',$C0,'b',$C0 
      DC.B   $0F,$00,'=',$E0,'4',$80,$15,$E0
      DC.B   'K',$00,'"`',$17,' O`' 
      DC.B   $1E,$A0,',`',$12,$C0,'H',$80 
      DC.B   $19,$A0,'9',$80,$0A,$00,$27,'`'
      DC.B   'a',$80,$15,$E0,'<',$00,$1C,$C0
      DC.B   '.@D',$C0,$02,$80,'G@' 
      DC.B   '8',$E0,$0F,$A0,'>',$80,'F',$A0
      DC.B   '[',$E0,$01,$E0,'B@',$1C,' ' 
      DC.B   '2',$00,'#',$00,$11,$80,'C',$80
      DC.B   $0B,$E0,'=@ ',$80,'] ' 
      DC.B   $16,$80,'3',$E0,'1`9',$80
      DC.B   'P',$00,$01,$E0,$10,'@4',$80 
      DC.B   '4',$80,'A',$A0,$1A,'@',$0E,'`'
      DC.B   $05,$A0,'W',$80,'+',$C0,'5 ' 
      DC.B   '?',$C0,'I',$C0,'Q',$E0,$04,'`'
      DC.B   ':',$C0,'>',$80,'<',$A0,'S',$C0
      DC.B   '0 $@',$1F,$E0,'K',$00 
      DC.B   'S',$C0,$18,'`=@#',$A0 
      DC.B   'Q@5 `',$E0,$06,$E0
      DC.B   $1C,' K',$00,'$@',$00,$00
      DC.B   $10,$E0,'?',$C0,'6`',$18,'`' 
      DC.B   'M',$80,'$@',$18,'`P',$A0
      DC.B   $1F,$E0,'-',$A0,$14,$00,'K',$00
      DC.B   $1C,' ;`',$0C,$80,')@' 
      DC.B   $00,$00,$17,' =@',$1E,$00
      DC.B   '/',$80,'F',$A0,$03,$C0,'I',$C0
      DC.B   ': ',$11,$80,'@`I '
      DC.B   '^`',$04,'`C',$80,$1E,$A0
      DC.B   '3@$',$E0,$12,$C0,'E`' 
      DC.B   $0E,'`>',$80,'"`^`'
      DC.B   $17,$C0,'5',$C0,'2',$A0,':',$C0
      DC.B   'R',$80,$03,' ',$12,' 6`'
      DC.B   '6`C',$80,$1B,$80,$10,$E0
      DC.B   $07,$80,'Y`.@6`' 
      DC.B   'B@L@T`',$05,$A0 
      DC.B   '<',$00,'?',$C0,'>',$80,'U',$A0
      DC.B   '2',$A0,'& "`L@' 
      DC.B   'U',$00,$19,$A0,'?',$C0,'& ' 
      DC.B   'S',$C0,'7',$A0,'c`',$08,' ' 
      DC.B   $1E,$00,'L@&',$C0,$01,'@'
      DC.B   $12,$C0,'A',$A0,'8@',$1A,$E0 
      DC.B   'P',$00,'& ',$19,$A0,'Q',$E0 
      DC.B   '! .',$E0,$15,'@M',$80 
      DC.B   $1E,$A0,'=@',$0F,$00,'+ '
      DC.B   $02,$80,$18,'`>',$80,$1F,'@' 
      DC.B   '0',$C0,'H',$80,$05,$00,'L@' 
      DC.B   ';`',$13,'`B@K',$A0
      DC.B   '`',$E0,$06,$E0,'D',$C0,'! ' 
      DC.B   '4',$80,'&',$C0,$14,$00,'G@' 
      DC.B   $10,$E0,'?',$C0,'$@_',$A0
      DC.B   $19,$00,'7',$A0,'3',$E0,'<',$00
      DC.B   'U',$00,$04,'`',$14,$00,'8@' 
      DC.B   '8@E`',$1C,$C0,$13,'`' 
      DC.B   $09,'`[@0',$C0,'7',$A0 
      DC.B   'D',$C0,'N',$C0,'V',$E0,$06,$E0
      DC.B   '=@A',$00,'@`W',$80
      DC.B   '5 (',$00,'$',$E0,'M',$80
      DC.B   'V@',$1A,$E0,'B@(',$A0 
      DC.B   'V@: ',$01,$E0,$09,'`' 
      DC.B   $1F,$E0,'M',$80,')@',$02,$80 
      DC.B   $14,$A0,'C',$80,': ',$1D,'`' 
      DC.B   'R',$80,'(',$00,$1A,$E0,'S ' 
      DC.B   '"`0 ',$16,$80,'P',$00 
      DC.B   '! ? ',$11,$80,'-',$00 
      DC.B   $05,$00,$19,$A0,'?',$C0,' ',$80
      DC.B   '2',$00,'J`',$06,'@N',$C0
      DC.B   '<',$A0,$15,'@D N '
      DC.B   'c`',$09,'`F',$00,'#',$A0
      DC.B   '5',$C0,'(',$A0,$15,'@I '
      DC.B   $13,'`A',$00,'& `',$E0 
      DC.B   $1A,'@9',$80,'5 =@'
      DC.B   'W',$80,$05,$A0,$15,$E0,': ' 
      DC.B   ': G@',$1E,$00,$15,$E0 
      DC.B   $0B,'@] 3@8',$E0 
      DC.B   'G@Q@Y`',$08,' ' 
      DC.B   '>',$80,'B@B@Y`' 
      DC.B   '7',$A0,')',$E0,$27,'`N',$C0 
      DC.B   'W',$80,$1C,' D',$C0,'+ '
      DC.B   'X',$C0,'<',$A0,$04,'`',$0A,$A0
      DC.B   '!',$C0,'N',$C0,'+',$C0,$03,$C0
      DC.B   $16,$80,'E`<',$00,$1F,$E0
      DC.B   'U',$00,')',$E0,$1C,' T`'
      DC.B   '#',$A0,'1`',$17,$C0,'R',$80 
      DC.B   '#',$A0,'A',$00,$14,$00,'.',$E0
      DC.B   $07,$80,$1A,$E0,'A',$00,'!',$C0
      DC.B   '3@L@',$07,$80,'Q@'
      DC.B   '=',$E0,$17,' F',$00,'P',$A0 
      DC.B   $01,$E0,$0B,$E0,'G@& ' 
      DC.B   '7',$00,'*',$80,$16,$80,'K',$00
      DC.B   $15,$E0,'B@(',$00,'b ' 
      DC.B   $1B,$80,';`6`>',$80
      DC.B   'Z',$00,$06,$E0,$17,$C0,'<',$00
      DC.B   '<',$00,'I ',$1F,'@',$18,'`' 
      DC.B   $0D,' _',$00,'5',$C0,': '
      DC.B   'I',$C0,'S',$C0,'[',$E0,$09,'`'
      DC.B   '?',$C0,'C',$80,'D [@' 
      DC.B   ': +',$C0,')',$E0,'P',$00
      DC.B   'X',$C0,$1D,'`G@-',$A0 
      DC.B   '[@? ',$06,$E0,$0B,$E0 
      DC.B   '#',$A0,'P',$00,'.@',$05,$00 
      DC.B   $18,'`G@=',$E0,'"`'
      DC.B   'W',$80,'+',$C0,$1D,'`U',$A0 
      DC.B   '$',$E0,'2',$A0,$19,$00,'U',$00
      DC.B   '& B',$E0,$16,$80,'0',$C0
      DC.B   $0A,$00,$1C,' B@#',$00 
      DC.B   '4',$80,'N ',$08,$C0,'S',$C0 
      DC.B   '? ',$19,$00,'G',$E0,'S '
      DC.B   $04,'`',$0E,'`H',$80,'(',$A0 
      DC.B   '8@,`',$17,$C0,'L',$E0 
      DC.B   $18,'`C',$80,')',$E0,'c`'
      DC.B   $1C,$C0,'=@7',$A0,'?',$C0
      DC.B   '\',$80,$08,' ',$19,$A0,'=',$E0
      DC.B   '=',$E0,'K',$00,' ',$80,$1A,$E0
      DC.B   $0F,$00,'`',$E0,'8@;`' 
      DC.B   'L@V@^`',$0A,$A0 
      DC.B   'A',$00,'D',$C0,'F',$00,'] ' 
      DC.B   '<',$A0,'-',$A0,',`Q@' 
      DC.B   'Z',$00,$1E,$A0,'I',$C0,'0 ' 
      DC.B   ']',$C0,'A',$A0,$09,'`',$0D,' '
      DC.B   '%',$80,'Q@0',$C0,$06,'@'
      DC.B   $1A,'@I ?',$C0,'$',$E0 
      DC.B   'Z',$00,'-',$A0,$1E,$A0,'V',$E0
      DC.B   '& 3',$E0,$1A,'@W',$80 
      DC.B   '(',$A0,'D',$C0,$19,$00,'2',$A0
      DC.B   $0C,$80,$1D,'`C',$80,'$@'
      DC.B   '5',$C0,'P',$00,$0A,$00,'V@' 
      DC.B   '@`',$1A,$E0,'I',$C0,'U',$A0 
      DC.B   $06,$E0,$10,$E0,'I',$C0,'+ ' 
      DC.B   '9',$80,'.@',$19,$00,'N',$C0 
      DC.B   $1A,$E0,'D',$C0,'+',$C0,$00,$A0
      DC.B   $1E,$00,'? 8',$E0,'A',$00
      DC.B   '_',$00,$09,'`',$1B,$80,'?',$C0
      DC.B   '?',$C0,'L',$E0,'!',$C0,$1D,'`'
      DC.B   $10,$E0,'b',$C0,':',$C0,'<',$A0
      DC.B   'N',$C0,'X',$C0,'`',$E0,$0B,$E0
      DC.B   'B@F',$00,'G',$E0,'_',$00
      DC.B   '? /',$80,'.',$E0,'R',$80
      DC.B   '[@',$1F,$E0,'L@2',$A0 
      DC.B   '`@D ',$0B,$E0,$0E,'`' 
      DC.B   $27,'`R',$80,'3@',$07,$80
      DC.B   $1C,' K',$00,'A',$A0,$27,'`' 
      DC.B   '\',$80,'/',$80,$1F,$E0,'X ' 
      DC.B   $27,'`5 ',$1B,$80,'Z',$00
      DC.B   '+ F',$A0,$1B,$80,'4',$80
      DC.B   $0F,$00,$1E,$A0,'D',$C0,'%',$80
      DC.B   '7',$00,'Q',$E0,$0B,'@X',$C0 
      DC.B   'A',$A0,$1C,$C0,'K',$A0,'X ' 
      DC.B   $09,'`',$13,'`K',$00,'-',$A0 
      DC.B   ':',$C0,'0 ',$1A,'@P',$A0
      DC.B   $1D,'`F',$00,'-',$A0,$01,$E0 
      DC.B   $1F,'@A',$00,': B@'
      DC.B   'a',$80,$0A,$A0,$1D,'`A',$A0 
      DC.B   'A',$A0,'N',$C0,'#',$00,$1F,$E0
      DC.B   $12,$C0,$00,$A0,'=@=',$E0
      DC.B   'Q@[@c`',$0D,' ' 
      DC.B   'C',$80,'G@I',$C0,'`',$E0
      DC.B   'A',$A0,'1`1`S',$C0
      DC.B   '\',$80,'! N',$C0,'5 ' 
      DC.B   'b',$C0,'F',$A0,$0E,'`',$0F,$A0
      DC.B   ')@S',$C0,'5',$C0,$08,$C0
      DC.B   $1E,$00,'L',$E0,'C',$80,')',$E0
      DC.B   '_',$00,'1`! Y`' 
      DC.B   '(',$A0,'6`',$1C,$C0,'\',$80 
      DC.B   '-',$A0,'H',$80,$1E,$00,'6`' 
      DC.B   $11,$80,$1F,$E0,'F',$00,'&',$C0
      DC.B   '8@S',$C0,$0C,$80,'[@' 
      DC.B   'B',$E0,$1E,$A0,'M',$80,'Z',$A0
      DC.B   $0B,$E0,$15,$E0,'L@0 ' 
      DC.B   '<',$00,'2',$00,$1B,$80,'R',$80
      DC.B   $1F,$E0,'G@/',$80,$03,' '
      DC.B   ' ',$80,'B',$E0,';`C',$80
      DC.B   $00,$00,$0B,$E0,$1F,'@C',$80 
      DC.B   'C',$80,'P',$A0,'$@"`' 
      DC.B   $14,$A0,$02,$80,'?',$C0,'? ' 
      DC.B   'S',$C0,']',$C0,$01,$E0,$0E,'`'
      DC.B   'D',$C0,'H',$80,'K',$A0,'b',$C0
      DC.B   'D 3@3',$E0,'U',$00
      DC.B   ']',$C0,'"`Q@7',$A0
      DC.B   $01,'@I ',$10,$E0,$10,$E0
      DC.B   '+ U',$00,'8@',$0A,$00 
      DC.B   $1F,$E0,'N',$C0,'E`,`' 
      DC.B   'a',$80,'3@"`Z',$A0
      DC.B   ')',$E0,'7',$A0,$1E,$00,'_',$00
      DC.B   '0 J` ',$80,'8@' 
      DC.B   $14,$00,'! G@(',$00
      DC.B   '9',$80,'U',$A0,$0D,$C0,']',$C0
      DC.B   'D  ',$80,'O`] ' 
      DC.B   $0E,'`',$18,'`M',$80,'2',$A0 
      DC.B   '=@3',$E0,$1C,$C0,'T`' 
      DC.B   '"`H',$80,'1`',$04,'`' 
      DC.B   '!',$C0,'D',$C0,'<',$A0,'D',$C0
      DC.B   $02,$80,$0D,' ! E`'
      DC.B   'E`R',$80,'%',$80,'$',$E0
      DC.B   $16,$80,$04,'`B@@`'
      DC.B   'V@`@',$04,'`',$0F,$A0 
      DC.B   'F',$00,'I',$C0,'M',$80,$00,$A0
      DC.B   'F',$A0,'5 6`V@' 
      DC.B   '_',$00,'#',$A0,'S',$C0,': ' 
      DC.B   $03,$C0,'K',$A0,$13,'`',$12,' '
      DC.B   '-',$00,'V@:',$C0,$0B,'@'
      DC.B   '!',$C0,'P',$A0,'G@.',$E0
      DC.B   $00,$00,'5 #',$A0,'[',$E0
      DC.B   '+ 8',$E0,$1F,'@a',$80 
      DC.B   '2',$A0,'L@#',$00,': ' 
      DC.B   $16,$80,'"`H',$80,')@' 
      DC.B   ':',$C0,'W',$80,$0F,$00,'`@' 
      DC.B   'E`"`Q@_',$A0
      DC.B   $10,$E0,$1A,$E0,'N',$C0,'5 ' 
      DC.B   '>',$80,'5',$C0,$1E,$00,'V@' 
      DC.B   '$',$E0,'I',$C0,'3@',$05,$A0 
      DC.B   '#',$00,'F',$A0,'=',$E0,'F',$00
      DC.B   $05,$00,$0E,'`#',$00,'G@'
      DC.B   'G@T`&',$C0,$27,'`'
      DC.B   $18,'`',$06,'@D',$C0,'A',$A0 
      DC.B   'X',$C0,'b',$C0,$06,$E0,$10,$E0
      DC.B   'G@K',$00,'O`',$02,$80 
      DC.B   'I 7',$00,'8',$E0,'W',$80
      DC.B   '`@$',$E0,'V@<',$A0
      DC.B   $06,'@N ',$15,$E0,$13,'`'
      DC.B   '.',$E0,'W',$80,'=@',$0C,$80 
      DC.B   '#',$A0,'R',$80,'I 1`' 
      DC.B   $02,$80,'7',$00,'$',$E0,'] ' 
      DC.B   ',`:  ',$80,$00,$00
      DC.B   '5 N %',$80,'<',$00
      DC.B   $19,$00,'#',$A0,'I',$C0,'*',$80
      DC.B   '<',$00,'Y`',$10,'@b',$C0
      DC.B   'F',$A0,'$@S b ' 
      DC.B   $13,'`',$1D,'`P',$00,'7',$A0 
      DC.B   '?',$C0,'7',$A0,$1F,'@X '
      DC.B   $27,'`K',$00,'5 ',$06,$E0
      DC.B   '$@H',$80,'? G@' 
      DC.B   $07,$80,$0F,$A0,'$',$E0,'I ' 
      DC.B   'I V@(',$00,')',$E0
      DC.B   $1A,'@',$08,' G@B',$E0 
      DC.B   '[@',$01,'@',$09,'`',$12,' ' 
      DC.B   'H',$80,'L@Q@',$04,'`' 
      DC.B   'K',$A0,'8',$E0,';`X',$C0
      DC.B   'a',$80,'& X',$C0,'? ' 
      DC.B   $08,$C0,'P',$A0,$18,'`',$14,$A0
      DC.B   '0',$C0,'X',$C0,'?',$C0,$0D,$C0
      DC.B   '%',$80,'T`K',$00,'3',$E0
      DC.B   $05,$00,'8',$E0,'& ^`' 
      DC.B   '-',$A0,';`!',$C0,$02,$80
      DC.B   '7',$A0,'P',$00,'(',$00,'=',$E0
      DC.B   $1B,$80,'$',$E0,'K',$00,'+',$C0
      DC.B   '=@[@',$11,$80,$01,'@' 
      DC.B   'G',$E0,'& U',$00,$00,$A0
      DC.B   $15,$E0,$1F,$E0,'Q@: ' 
      DC.B   'A',$00,'9',$80,' ',$80,'Z',$00
      DC.B   ')',$E0,'L@7',$00,$08,' '
      DC.B   '%',$80,'J`@`H',$80
      DC.B   $0A,$00,$10,$E0,'&',$C0,'K',$00
      DC.B   'K',$00,'X )@,`' 
      DC.B   $1C,' ',$0A,$00,'I',$C0,'D ' 
      DC.B   ']',$C0,$03,$C0,$0B,$E0,$13,'`'
      DC.B   'I',$C0,'M',$80,'S ',$06,'@' 
      DC.B   'N :',$C0,'=',$E0,'Z',$00
      DC.B   'b',$C0,$27,'`[@A',$A0 
      DC.B   $0B,'@S ',$1A,$E0,$15,$E0
      DC.B   '2',$A0,'Z',$00,'B@',$0F,$00 
      DC.B   $27,'`V@L',$E0,'6`'
      DC.B   $07,$80,':',$C0,$27,'`_',$A0 
      DC.B   '.',$E0,'<',$A0,'#',$00,$05,$00
      DC.B   ': Q',$E0,'*',$80,'?',$C0
      DC.B   $1E,$00,'& L@-',$00
      DC.B   '>',$80,'] ',$12,$C0,$03,$C0 
      DC.B   'I (',$00,'V',$E0,$03,' '
      DC.B   $18,'`"`R',$80,'<',$A0 
      DC.B   'B@;`!',$C0,'[',$E0
      DC.B   ',`M',$80,'8',$E0,$09,'`'
      DC.B   '&',$C0,'L@A',$A0,'I',$C0
      DC.B   $0C,$80,$12,' (',$A0,'L',$E0 
      DC.B   'L',$E0,'Z',$00,'*',$80,'.',$E0
      DC.B   $1E,$00,$0B,$E0,'L@E`' 
      DC.B   '`@',$06,'@',$0E,'`',$14,$A0 
      DC.B   'K',$00,'N',$C0,'U',$00,$08,' '
      DC.B   'P',$A0,'<',$A0,'@`[@' 
      DC.B   $00,$00,'(',$A0,']',$C0,'D ' 
      DC.B   $0D,$C0,'U',$A0,$1D,'`',$17,' '
      DC.B   '4',$80,'[@D',$C0,$10,'@'
      DC.B   ')@X N',$C0,'8',$E0
      DC.B   $0A,$00,'<',$A0,'(',$A0,'`',$E0
      DC.B   '0 =',$E0,'$@',$07,$80 
      DC.B   '<',$A0,'S',$C0,'-',$00,'A',$A0
      DC.B   ' ',$80,$27,'`M',$80,'.@'
      DC.B   '?',$C0,'_',$00,$14,$00,$06,'@'
      DC.B   'J`)',$E0,'X',$C0,$05,$A0
      DC.B   $1A,$E0,'$',$E0,'S',$C0,'? ' 
      DC.B   'C',$80,'=@#',$00,']',$C0
      DC.B   '.',$E0,'N',$C0,':',$C0,$0A,$A0
      DC.B   '(',$00,'N B',$E0,'K',$00
      DC.B   $0F,$00,$13,'`*',$80,'N',$C0 
      DC.B   'N',$C0,'[',$E0,'+',$C0,'1`' 
      DC.B   $1F,$E0,$0D,$C0,'N',$C0,'F',$A0
      DC.B   'b',$C0,$08,$C0,$10,$E0,$15,$E0
      DC.B   'L@P',$00,'V',$E0,$0A,$00
      DC.B   'S >',$80,'B',$E0,'\',$80
      DC.B   $01,'@)',$E0,'`@F',$A0 
      DC.B   $10,'@X ',$1F,$E0,$18,'`'
      DC.B   '6`\',$80,'G@',$11,$80 
      DC.B   '+ Z',$00,'P',$A0,';`' 
      DC.B   $0C,$80,'>',$80,')',$E0,'b ' 
      DC.B   '1`? %',$80,$0A,$00
      DC.B   '? U',$A0,'/',$80,'C',$80
      DC.B   '#',$00,'(',$A0,'N',$C0,'/',$80
      DC.B   'A',$00,'`',$E0,$15,'@',$08,$C0
      DC.B   'K',$A0,'+',$C0,'Z',$A0,$08,' '
      DC.B   $1D,'`',$27,'`U',$00,'A',$A0 
      DC.B   'D',$C0,'? $@_',$A0
      DC.B   '1`P',$00,'<',$A0,$0B,$E0
      DC.B   ')@P',$00,'D L@' 
      DC.B   $11,$80,$14,$A0,',`P',$A0
      DC.B   'P',$A0,']',$C0,'-',$00,'3',$E0
      DC.B   '!',$C0,$0F,$A0,'Q@G',$E0
      DC.B   $01,'@',$0B,'@',$13,'`',$17,' '
      DC.B   'M',$80,'Q@X',$C0,$0B,$E0
      DC.B   'U',$A0,'@`E`]',$C0
      DC.B   $02,$80,'+ b',$C0,'I ' 
      DC.B   $12,$C0,'Z',$A0,'"`',$19,$A0 
      DC.B   '8@]',$C0,'I',$C0,$12,$C0
      DC.B   '-',$00,'[',$E0,'R',$80,'=',$E0
      DC.B   $0F,$00,'@`+ c`' 
      DC.B   '2',$A0,'@`&',$C0,$0C,$80
      DC.B   'A',$A0,'W',$80,'2',$00,'E`' 
      DC.B   '%',$80,')',$E0,'P',$00,'0',$C0
      DC.B   'B@b',$C0,$16,$80,$0B,'@'
      DC.B   'L',$E0,'-',$A0,'\',$80,$0A,$A0
      DC.B   $1F,$E0,')',$E0,'V@D ' 
      DC.B   'F',$00,'A',$00,'%',$80,'a',$80
      DC.B   '3',$E0,'Q@>',$80,$0D,' '
      DC.B   '*',$80,'Q',$E0,'E`M',$80
      DC.B   $14,$00,$15,$E0,'.@R',$80
      DC.B   'R',$80,'_',$A0,'.@6`' 
      DC.B   '#',$A0,$11,$80,'S',$C0,'I ' 
      DC.B   $03,$C0,$0D,$C0,$15,$E0,$18,'`'
      DC.B   'N',$C0,'R',$80,'Z',$A0,$0D,$C0
      DC.B   'X B@G',$E0,'_',$00
      DC.B   $03,$C0,',`',$01,'@K',$A0
      DC.B   $15,'@] $',$E0,$1A,$E0 
      DC.B   ': _',$00,'L@',$14,$00 
      DC.B   '.',$E0,']',$C0,'T`@`' 
      DC.B   $11,$80,'B@,`',$00,$A0 
      DC.B   '3',$E0,'A',$A0,'(',$00,$0F,$00
      DC.B   'D Y`4',$80,'G@' 
      DC.B   '(',$00,'+ Q@2',$00
      DC.B   'C',$80,$00,$A0,$17,$C0,$0D,$C0
      DC.B   'N /',$80,'^`',$0D,' ' 
      DC.B   '"`,`W',$80,'F',$A0
      DC.B   'G@B',$E0,'&',$C0,'c`' 
      DC.B   '6`R',$80,'@`',$0E,'`' 
      DC.B   '+',$C0,'S',$C0,'F',$A0,'N',$C0
      DC.B   $16,$80,$17,' 0 T`'
      DC.B   'T`a',$80,'/',$80,'8',$E0
      DC.B   '%',$80,$13,'`V@J`'
      DC.B   $06,'@',$10,'@',$18,'`',$19,$A0
      DC.B   'P',$00,'S',$C0,'\',$80,$0F,$A0
      DC.B   'Z',$A0,'D J``@' 
      DC.B   $05,$00,'-',$A0,$03,$C0,'N ' 
      DC.B   $17,$C0,'_',$A0,$27,'`',$1C,' '
      DC.B   '<',$00,'`@N',$C0,$15,'@'
      DC.B   '0',$C0,'_',$A0,'V@B',$E0
      DC.B   $14,$00,'D -',$A0,$01,$E0
      DC.B   '5 B',$E0,')@',$11,$80 
      DC.B   'F',$A0,'[@7',$00,'I ' 
      DC.B   '*',$80,',`R',$80,'3@' 
      DC.B   'D',$C0,$02,$80,$19,$00,$10,'@'
      DC.B   'O`1``@',$0F,$A0 
      DC.B   '$',$E0,'.',$E0,'X',$C0,'I ' 
      DC.B   'H',$80,'D',$C0,'(',$00,$01,'@'
      DC.B   '8',$E0,'S',$C0,'B@',$0F,$A0 
      DC.B   '-',$00,'U',$A0,'G',$E0,'P',$00
      DC.B   $19,$00,$18,'`2',$00,'V@'
      DC.B   'V@c`0',$C0,';`' 
      DC.B   $27,'`',$15,'@X',$C0,'K',$A0 
      DC.B   $08,$C0,$12,$C0,$1A,$E0,$1A,$E0
      DC.B   'Q@U',$00,'^`',$11,$80 
      DC.B   '] F',$00,'L',$E0,'a',$80
      DC.B   $06,'@.',$E0,$06,'@P',$A0
      DC.B   $1A,'@b )',$E0,$1D,'`' 
      DC.B   '=',$E0,'a',$80,'Q@',$16,$80 
      DC.B   '2',$A0,'a',$80,'X E`' 
      DC.B   $16,$80,'F',$00,'.',$E0,$03,' '
      DC.B   '6`D *',$80,$14,$00
      DC.B   'I ] 9',$80,'K',$00
      DC.B   '-',$00,'-',$A0,'S',$C0,'4',$80
      DC.B   'F',$00,$04,'`',$1A,'@',$12,$C0
      DC.B   'P',$A0,'3@b ',$12,' ' 
      DC.B   $27,'`1`Z',$00,'K',$A0 
      DC.B   'I',$C0,'F',$A0,')@',$03,' ' 
      DC.B   ';`U',$00,'D ',$10,$E0 
      DC.B   '.@W',$80,'I Q@' 
      DC.B   $1B,$80,$19,$A0,'3',$E0,'X ' 
      DC.B   'X ',$01,'@2',$00,'=',$E0
      DC.B   ')@',$17,' [@L',$E0
      DC.B   $0B,'@',$15,'@',$1D,'`',$1C,' '
      DC.B   'R',$80,'V@`@',$13,'`' 
      DC.B   '_',$A0,'G',$E0,'O`b',$C0
      DC.B   $07,$80,'0 ',$08,$C0,'S '
      DC.B   $1C,$C0,$00,$A0,',`',$1E,$A0 
      DC.B   '?',$C0,'b',$C0,'S',$C0,$17,$C0
      DC.B   '4',$80,'c`Z',$00,'G',$E0
      DC.B   $19,$00,'G',$E0,'0 ',$04,'`' 
      DC.B   '7',$A0,'E`+',$C0,$16,$80
      DC.B   'K',$A0,'_',$00,'<',$00,'L',$E0
      DC.B   '/',$80,'.',$E0,'U',$00,'5',$C0
      DC.B   'G@',$06,'@',$1B,$80,$15,'@' 
      DC.B   'Q',$E0,'5 ',$00,$00,$14,$A0 
      DC.B   ')',$E0,'3',$E0,'[@N ' 
      DC.B   'K',$00,'H',$80,'*',$80,$05,$00
      DC.B   '=',$E0,'V@F',$00,$12,' '
      DC.B   '/',$80,'Y`J`R',$80
      DC.B   $1E,$00,$1A,$E0,'5',$C0,'Z',$00
      DC.B   'Z',$00,$03,' 3@@`'
      DC.B   '+ ',$19,$00,']',$C0,'N '
      DC.B   $0D,$C0,$17,$C0,$1F,$E0,$1D,'`'
      DC.B   'S',$C0,'W',$80,'b ',$15,'@' 
      DC.B   'b I',$C0,'Q',$E0,$00,$00
      DC.B   $08,$C0,'1`',$0B,'@U',$A0
      DC.B   $1F,'@',$03,' .',$E0,$1F,$E0 
      DC.B   'A',$A0,$00,$00,'V@',$19,$00 
      DC.B   '6`',$01,'@[',$E0,'J`' 
      DC.B   $1B,$80,'I',$C0,'1`',$05,$A0 
      DC.B   '8',$E0,'F',$A0,'-',$00,$19,$00
      DC.B   'N `',$E0,'>',$80,'N',$C0
      DC.B   '2',$00,'0 V@7',$00
      DC.B   'H',$80,$08,' ',$1C,$C0,$17,$C0
      DC.B   'S 7',$00,$01,$E0,$17,' '
      DC.B   ',`6`\',$80,'P',$A0
      DC.B   'L@J`+',$C0,$06,$E0
      DC.B   '@`W',$80,'G',$E0,$13,'`'
      DC.B   '0',$C0,'[@K',$A0,'S',$C0
      DC.B   ' ',$80,$1C,' 7',$A0,'[',$E0 
      DC.B   '[',$E0,$05,$00,'4',$80,'B',$E0
      DC.B   '-',$00,$1A,$E0,'`@O`' 
      DC.B   $10,'@',$1A,'@"`',$1E,$A0
      DC.B   'U',$00,'X',$C0,$00,$00,$17,' '
      DC.B   $00,$A0,'K',$A0,'T`',$01,'@' 
      DC.B   $0A,$00,'2',$A0,$0D,$C0,'X ' 
      DC.B   '!',$C0,$05,$A0,'1`! ' 
      DC.B   'C',$80,$01,'@X',$C0,$1A,'@' 
      DC.B   '8@',$03,' ]',$C0,'L',$E0
      DC.B   $1E,$00,'K',$A0,'2',$A0,$06,$E0
      DC.B   ': G',$E0,'.@',$1B,$80 
      DC.B   'P',$A0,'b',$C0,'A',$00,'P',$A0
      DC.B   '4',$80,'1`W',$80,'8@' 
      DC.B   'I',$C0,$0A,$00,$1E,$00,$1A,'@'
      DC.B   'T`8',$E0,$03,$C0,$19,$A0
      DC.B   '.',$E0,'8',$E0,']',$C0,'S ' 
      DC.B   'M',$80,'L@-',$00,$08,$C0
      DC.B   'B',$E0,'X',$C0,'I',$C0,$14,$A0
      DC.B   '2',$00,'] L',$E0,'U',$00
      DC.B   '#',$00,$1D,'`9',$80,']',$C0 
      DC.B   ']',$C0,$06,$E0,'5',$C0,'E`' 
      DC.B   '.',$E0,$1C,$C0,'b',$C0,'P',$A0
      DC.B   $12,$C0,$1C,$C0,'$',$E0,$1F,$E0
      DC.B   'V@Z',$00,$01,$E0,$19,$00
      DC.B   $03,' M',$80,'V',$E0,$02,$80 
      DC.B   $0B,'@3',$E0,$10,'@Z',$A0
      DC.B   '$@',$08,' 3',$E0,'"`' 
      DC.B   'E`',$02,$80,'[@',$1B,$80
      DC.B   ': ',$05,$00,'_',$A0,'O`'
      DC.B   ' ',$80,'M',$80,'3',$E0,$08,' '
      DC.B   ';`I /',$80,$1E,$00
      DC.B   'S ',$00,$A0,'C',$80,'R',$80 
      DC.B   '7',$00,'2',$A0,'X',$C0,'9',$80
      DC.B   'K',$00,$0B,$E0,$1F,'@',$1C,$C0
      DC.B   'U',$A0,':',$C0,$05,$A0,$1C,' '
      DC.B   '1`;`_',$00,'U',$A0
      DC.B   'N',$C0,'N .@',$0A,$A0 
      DC.B   'E`Z',$00,'K',$A0,$15,$E0
      DC.B   '3@_',$00,'N V@' 
      DC.B   '%',$80,$1E,$A0,';`_',$A0
      DC.B   '_',$A0,$08,$C0,'7',$00,'G',$E0
      DC.B   '0',$C0,$1E,$A0,$01,'@Q',$E0 
      DC.B   $15,'@',$1F,'@',$27,'`! '
      DC.B   'W',$80,'[@',$03,$C0,$1A,$E0 
      DC.B   $05,$A0,'O`Y`',$03,$C0 
      DC.B   $0C,$80,'5 ',$12,$C0,'] '
      DC.B   '&',$C0,$0A,$A0,'6`#',$A0
      DC.B   'G@',$03,$C0,']',$C0,$1C,$C0 
      DC.B   '<',$00,$06,$E0,'a',$80,'Q',$E0
      DC.B   '#',$00,'O`5 ',$09,'`' 
      DC.B   '<',$A0,'J`0',$C0,' ',$80
      DC.B   'U',$A0,$02,$80,'F',$00,'T`' 
      DC.B   '9',$80,'3',$E0,'Z',$00,':',$C0
      DC.B   'L@',$0D,$C0,' ',$80,$1F,'@' 
      DC.B   'V',$E0,'<',$A0,$07,$80,$1E,$A0
      DC.B   '3',$E0,'=',$E0,'`@X ' 
      DC.B   'P',$00,'P',$00,'/',$80,$0C,$80
      DC.B   'G',$E0,'[@M',$80,$17,' '
      DC.B   '4',$80,'`',$E0,'O`W',$80
      DC.B   '(',$00,$1F,$E0,'=@a',$80
      DC.B   'a',$80,$0A,$A0,'8@J`' 
      DC.B   '2',$A0,' ',$80,$03,$C0,'S ' 
      DC.B   $17,$C0,'!',$C0,')',$E0,'"`' 
      DC.B   'X',$C0,'\',$80,$05,$A0,$1C,$C0
      DC.B   $08,' Q@[',$E0,$05,$00 
      DC.B   $0D,$C0,'6`',$15,'@_',$A0
      DC.B   ')@',$0D,' 8',$E0,'$',$E0
      DC.B   'I ',$05,$00,'`@',$1E,$00
      DC.B   '=',$E0,$08,$C0,'c`T`' 
      DC.B   '%',$80,'Q@6`',$0A,$A0 
      DC.B   '=',$E0,'K',$A0,'2',$00,'#',$00
      DC.B   'X ',$04,'`H',$80,'V@' 
      DC.B   '<',$00,'5 [@<',$00
      DC.B   'M',$80,$0F,$A0,'!',$C0,'!',$C0
      DC.B   'X >',$80,$09,'`! '
      DC.B   '6`@`a',$80,'Z',$A0
      DC.B   'Q@Q',$E0,'0',$C0,$0E,'`'
      DC.B   'J`\',$80,'O`',$18,'`' 
      DC.B   '5',$C0,'b',$C0,'P',$A0,'X',$C0
      DC.B   '*',$80,'! ? c`' 
      DC.B   'c`',$0C,$80,'9',$80,'L',$E0 
      DC.B   '4',$80,'"`',$06,'@T`' 
      DC.B   $1A,'@$@,`#',$A0 
      DC.B   'Z',$00,']',$C0,$07,$80,$1E,$A0
      DC.B   $0A,$A0,'S ^`',$06,'@' 
      DC.B   $0F,$00,'7',$A0,$17,$C0,'b ' 
      DC.B   '+',$C0,$0F,$A0,';`& ' 
      DC.B   'K',$00,$06,'@b',$C0,$1F,'@' 
      DC.B   '?',$C0,$0A,$A0,$01,'@V',$E0 
      DC.B   '(',$00,'S 7',$A0,$0B,$E0
      DC.B   '? L',$E0,'3@%',$80
      DC.B   'Z',$A0,$06,'@K',$00,'X '
      DC.B   '>',$80,'6`\',$80,'=@' 
      DC.B   'N',$C0,$11,$80,'#',$00,'$@' 
      DC.B   'Y`@`',$0B,'@#',$A0
      DC.B   '8',$E0,'B',$E0,'b',$C0,'] ' 
      DC.B   'R',$80,'S',$C0,'2',$00,$10,'@'
      DC.B   'L',$E0,']',$C0,'Q@',$19,$A0 
      DC.B   '7',$00,$00,$A0,'Q',$E0,'Z',$00
      DC.B   '-',$00,'"`A',$00,$01,'@'
      DC.B   $01,'@',$0E,'`:',$C0,'O`'
      DC.B   '6`$@',$08,$C0,'U',$A0 
      DC.B   $1C,$C0,'&',$C0,'.',$E0,'$',$E0
      DC.B   '[@_',$00,$09,'` ',$80 
      DC.B   $0D,' U',$00,'`',$E0,$07,$80 
      DC.B   $10,'@8',$E0,$1A,'@',$00,$A0 
      DC.B   '.@',$12,' =',$E0,$27,'`'
      DC.B   'L',$E0,$07,$80,$01,'@ ',$80 
      DC.B   'A',$A0,$0C,$80,$03,' Y`'
      DC.B   '*',$80,'U',$00,'8',$E0,$0D,' '
      DC.B   '@`N 4',$80,'(',$00
      DC.B   '] ',$08,' M',$80,'Z',$00
      DC.B   'A',$00,'7',$A0,']',$C0,'>',$80
      DC.B   'P',$00,$13,'`$@&',$C0 
      DC.B   'Z',$A0,'B@',$0D,' & ' 
      DC.B   ';`E`',$00,$00,'_',$A0 
      DC.B   'S',$C0,'U',$A0,'3@',$12,' ' 
      DC.B   'O`_',$00,'S ',$1A,$E0 
      DC.B   '8@',$02,$80,'S [@'
      DC.B   '/',$80,'#',$A0,'B',$E0,$03,' '
      DC.B   $03,' ',$10,'@<',$00,'Q',$E0 
      DC.B   '8@& ',$0B,'@V',$E0
      DC.B   $1F,'@)@1`& '
      DC.B   '\',$80,'`@',$0B,'@"`' 
      DC.B   $0F,$A0,'V',$E0,'c`',$08,$C0 
      DC.B   $11,$80,': ',$1C,$C0,$03,' ' 
      DC.B   '0',$C0,$14,$A0,'@`(',$A0
      DC.B   'N',$C0,$08,$C0,$03,$C0,'!',$C0
      DC.B   'C',$80,$0E,'`',$05,$00,'[',$E0
      DC.B   '-',$00,'V',$E0,': ',$0E,'`' 
      DC.B   'A',$A0,'O`5',$C0,'*',$80
      DC.B   '_',$A0,$0A,$00,'P',$00,'[',$E0
      DC.B   'C',$80,'8',$E0,'_',$00,'?',$C0
      DC.B   'Q@',$15,'@%',$80,')@' 
      DC.B   '[',$E0,'D ',$0F,$00,'(',$A0 
      DC.B   '=',$E0,'G',$E0,$01,'@b '
      DC.B   'U',$00,'W',$80,'4',$80,$14,$00
      DC.B   'Q',$E0,'`@U',$00,$1C,' '
      DC.B   '9',$80,$04,'`T`\',$80 
      DC.B   '2',$00,'$',$E0,'D',$C0,$05,$00
      DC.B   $05,$00,$12,' =@T`'
      DC.B   ': (',$00,$0D,$C0,'X ' 
      DC.B   '!',$C0,'+',$C0,'3',$E0,$27,'`'
      DC.B   ']',$C0,'a',$80,$0D,' $@'
      DC.B   $12,' X',$C0,$01,$E0,$0A,$00 
      DC.B   $12,$C0,';`',$1F,'@',$05,$A0 
      DC.B   '3@',$17,' B',$E0,')',$E0
      DC.B   'P',$A0,$0A,$00,$06,'@#',$00 
      DC.B   'E`',$10,'@',$06,$E0,'^`'
      DC.B   '/',$80,'X',$C0,';`',$0F,$A0 
      DC.B   'B',$E0,'P',$A0,'7',$00,'-',$00
      DC.B   'b ',$0B,$E0,'R',$80,']',$C0 
      DC.B   'F',$00,': `@A',$00
      DC.B   'R',$80,$17,' &',$C0,'+',$C0 
      DC.B   '] F',$00,$10,$E0,'+ ' 
      DC.B   '@`J`',$02,$80,$00,$A0 
      DC.B   'V@Y`5',$C0,$15,$E0
      DC.B   'T`a',$80,'V',$E0,$1D,'`'
      DC.B   ':',$C0,$06,'@U',$A0,']',$C0 
      DC.B   '4',$80,'& F',$A0,$06,$E0
      DC.B   $06,$E0,$14,$00,'>',$80,'V',$E0
      DC.B   '<',$00,')',$E0,$10,'@Y`'
      DC.B   '$@.@6`(',$A0
      DC.B   '_',$00,'b',$C0,$0F,$00,'& ' 
      DC.B   $14,$A0,'Z',$A0,$04,'`',$0B,'@'
      DC.B   $14,$00,'<',$A0,'!',$C0,$08,' '
      DC.B   '5',$C0,$19,$A0,'E`+ ' 
      DC.B   'R',$80,$0B,'@',$08,$C0,'$@' 
      DC.B   'G@',$12,' ',$08,$C0,'`',$E0 
      DC.B   '2',$00,'Z',$A0,'<',$A0,$10,$E0
      DC.B   'D Q',$E0,'8@/',$80
      DC.B   $00,$A0,$0D,$C0,'U',$00,'_',$A0
      DC.B   'H',$80,';`a',$80,'B@' 
      DC.B   'S',$C0,$19,$00,'(',$00,'.@' 
      DC.B   '^`G',$E0,$12,$C0,'-',$A0
      DC.B   'B',$E0,'L',$E0,$03,$C0,$03,' '
      DC.B   'W',$80,'[@7',$00,$17,$C0
      DC.B   'V',$E0,'b',$C0,'X',$C0,$1E,$A0
      DC.B   '<',$00,$08,' V',$E0,'_',$00 
      DC.B   '7',$00,$27,'`H',$80,$08,$C0 
      DC.B   $08,$C0,$15,$E0,'?',$C0,'Y`' 
      DC.B   '=',$E0,'+',$C0,$12,$C0,'Z',$A0
      DC.B   '&',$C0,'0',$C0,'8',$E0,')',$E0
      DC.B   '`@',$00,$00,$10,$E0,'(',$00 
      DC.B   $17,' \',$80,$06,$E0,$0C,$80 
      DC.B   $15,'@=',$E0,'$@',$0A,$A0
      DC.B   '8@',$1C,' G',$E0,',`' 
      DC.B   'T`',$0C,$80,$0B,'@%',$80
      DC.B   'I ',$14,$00,$0A,$A0,'c`'
      DC.B   '4',$80,'\',$80,'=',$E0,$12,' '
      DC.B   'E`S 9',$80,'2',$00
      DC.B   $03,' ',$0F,$A0,'W',$80,'a',$80
      DC.B   'K',$00,'<',$A0,'b',$C0,'C',$80
      DC.B   'U',$00,$1A,$E0,')@0',$C0
      DC.B   '_',$A0,'I',$C0,$14,$A0,'0 ' 
      DC.B   'E`O`',$05,$00,$05,$A0 
      DC.B   'X',$C0,'] 8@',$19,$A0 
      DC.B   'Y`',$00,$00,'Z',$A0,$1F,$E0 
      DC.B   '=@',$0A,$00,'X `@'
      DC.B   '9',$80,'(',$A0,'J`',$0A,$A0 
      DC.B   $0A,$A0,$17,$C0,'A',$00,'[',$E0
      DC.B   '?',$C0,'-',$A0,$15,'@[',$E0 
      DC.B   ')@3@;`+ ' 
      DC.B   'a',$80,$01,'@',$12,$C0,')',$E0
      DC.B   $19,$A0,'^`',$09,'`',$0D,$C0 
      DC.B   $16,$80,'? &',$C0,$0D,' '
      DC.B   ':',$C0,$1E,$A0,'J`-',$A0
      DC.B   'V@',$0D,$C0,$0D,$C0,'&',$C0 
      DC.B   'K',$00,$15,$E0,$0C,$80,$01,$E0
      DC.B   '7',$00,'^`? ',$13,'`' 
      DC.B   'F',$A0,'T`:',$C0,'4',$80
      DC.B   $05,$A0,$11,$80,'Z',$00,'c`' 
      DC.B   'M',$80,'=',$E0,$00,$00,'D',$C0
      DC.B   'V@',$1C,$C0,'*',$80,'3@'
      DC.B   '`',$E0,'K',$A0,$16,$80,'2',$A0
      DC.B   'G',$E0,'Q',$E0,$06,'@',$08,' '
      DC.B   'Z',$00,'_',$00,'9',$80,$1B,$80
      DC.B   '[',$E0,$01,'@\',$80,'! '
      DC.B   '>',$80,$0B,$E0,'Y`a',$80
      DC.B   '<',$00,')',$E0,'L@',$0C,$80 
      DC.B   $0C,$80,$19,$A0,'B@^`' 
      DC.B   'A',$A0,'/',$80,$17,$C0,'] ' 
      DC.B   '+',$C0,'5',$C0,'=',$E0,',`' 
      DC.B   'b',$C0,$02,$80,$14,$A0,'+',$C0
      DC.B   $1C,' `@',$0B,$E0,$0F,$00
      DC.B   $17,$C0,'@`)@',$0F,$A0 
      DC.B   '=@! L',$E0,'.',$E0
      DC.B   'X ',$0F,$00,$10,'@(',$00
      DC.B   'L',$E0,$17,$C0,$0E,'`',$04,'`'
      DC.B   '9',$80,'`@@`',$14,$A0 
      DC.B   'G',$E0,'U',$A0,'<',$00,'7',$00
      DC.B   $08,' ',$13,'`\',$80,$01,'@' 
      DC.B   'P',$00,'? ',$01,'@F',$00
      DC.B   'W',$80,$1E,$A0,'+',$C0,'5',$C0
      DC.B   'b M',$80,$18,'`5 '
      DC.B   'J`T`',$07,$80,$0A,$A0 
      DC.B   '[@`',$E0,':',$C0,$1D,'`'
      DC.B   '^`',$02,$80,'^`"`'
      DC.B   '?',$C0,$0D,$C0,'Z',$A0,'b',$C0
      DC.B   '>',$80,'+ N ',$0E,'`' 
      DC.B   $0E,'`',$1B,$80,'C',$80,'`',$E0
      DC.B   'C',$80,'1`',$1A,'@^`' 
      DC.B   '.@8@@`-',$A0
      DC.B   $00,$00,$03,$C0,$16,$80,'-',$A0
      DC.B   $1E,$A0,'b ',$0E,'`',$10,'@' 
      DC.B   $19,$00,'A',$A0,'+',$C0,$12,' '
      DC.B   '?',$C0,'#',$A0,'O`0 ' 
      DC.B   'Z',$00,$10,'@',$12,$C0,')@' 
      DC.B   'N',$C0,$19,$A0,$10,'@',$06,$E0
      DC.B   '<',$00,'b A',$A0,$15,$E0
      DC.B   'I V',$E0,'=@9',$80
      DC.B   $0A,$A0,$15,'@_',$00,$03,' ' 
      DC.B   'R',$80,'@`',$02,$80,'G@'
      DC.B   'X',$C0,' ',$80,'-',$00,'8@' 
      DC.B   'c`O`',$1A,'@7',$A0
      DC.B   'L',$E0,'V',$E0,$08,$C0,$0D,' '
      DC.B   '\',$80,'b',$C0,'<',$00,$1F,'@'
      DC.B   '`',$E0,$03,$C0,'`@#',$A0
      DC.B   'A',$00,$0F,$A0,'[',$E0,$00,$00
      DC.B   'A',$00,',`P',$00,$10,'@'
      DC.B   $10,'@',$1D,'`D',$C0,'c`'
      DC.B   'E`3@',$1C,$C0,'_',$A0 
      DC.B   '0',$C0,':',$C0,'B',$E0,'.',$E0
      DC.B   $01,'@',$05,$00,$18,'`/',$80 
      DC.B   '! ',$00,$00,$10,$E0,$11,$80 
      DC.B   $1A,'@B',$E0,'.@',$14,$A0
      DC.B   'B@& Q',$E0,'1`' 
      DC.B   '[',$E0,$11,$80,$15,'@*',$80 
      DC.B   'P',$A0,$1B,$80,$12,' ',$09,'`'
      DC.B   '>',$80,$00,$00,'B',$E0,$17,' '
      DC.B   'J`X >',$80,'<',$00
      DC.B   $0D,' ',$17,' a',$80,$05,$00 
      DC.B   'U',$00,'A',$A0,$03,$C0,'H',$80
      DC.B   'Z',$00,'"`.@:',$C0
      DC.B   $00,$A0,'Q@',$1C,' : ' 
      DC.B   'O`Y`',$0A,$00,$0F,$A0 
      DC.B   ']',$C0,$00,$A0,'=@! ' 
      DC.B   'c`',$05,$00,'b $',$E0 
      DC.B   'B@',$11,$80,'] ',$01,'@'
      DC.B   'C',$80,'-',$A0,'Q',$E0,$12,' '
      DC.B   $12,' ',$1F,'@F',$00,$01,$E0 
      DC.B   'G@5 ',$1F,'@`',$E0
      DC.B   '3@=@E`0 ' 
      DC.B   $02,$80,$06,'@',$1A,'@1`'
      DC.B   '#',$A0,$01,$E0,$13,'`',$12,$C0
      DC.B   $1B,$80,'D 0',$C0,$17,' '
      DC.B   'D',$C0,'(',$A0,'T`2',$A0
      DC.B   ']',$C0,$12,$C0,$17,$C0,'+',$C0
      DC.B   'R',$80,$1D,'`',$14,$00,$0B,$E0
      DC.B   'A',$00,$01,$E0,'D ',$18,'`' 
      DC.B   'K',$A0,'Y`?',$C0,'>',$80
      DC.B   $0F,$A0,$19,$00,$00,$00,$06,$E0
      DC.B   'W',$80,'B',$E0,$05,$00,'I',$C0
      DC.B   '[@$@/',$80,'=@' 
      DC.B   $01,$E0,'S ',$1E,$00,'<',$A0 
      DC.B   'Q',$E0,'[',$E0,$0B,'@',$12,' '
      DC.B   '_',$00,$02,$80,'>',$80,'#',$00
      DC.B   $01,$E0,$06,'@',$00,$00,'& ' 
      DC.B   'C',$80,$13,'`^`',$02,$80
      DC.B   'F',$00,'.',$E0,'S',$C0,$14,$00
      DC.B   $14,$00,'! G@',$04,'`' 
      DC.B   'I 7',$00,'!',$C0,'b ' 
      DC.B   '5',$C0,'?',$C0,'G',$E0,'1`' 
      DC.B   $03,$C0,$07,$80,$1C,' 3@'
      DC.B   '& ',$03,$C0,$15,$E0,$14,$00 
      DC.B   $1C,$C0,'E`3@',$19,$A0 
      DC.B   'G@+ V',$E0,'3',$E0
      DC.B   '_',$A0,$14,$00,$1A,'@-',$00 
      DC.B   'T`',$1F,'@',$15,$E0,$0E,'`' 
      DC.B   'C',$80,$03,$C0,'E`',$19,$A0 
      DC.B   'L',$E0,'Z',$A0,'A',$00,'A',$00
      DC.B   $12,' ',$1A,$E0,$02,$80,$08,$C0
      DC.B   'Z',$00,'D ',$06,'@K',$00
      DC.B   '\',$80,'& 0',$C0,'?',$C0
      DC.B   $03,' U',$00,$1F,$E0,'? '
      DC.B   'T`^`',$0C,$80,$14,$A0 
      DC.B   '`@',$04,'`?',$C0,'$',$E0
      DC.B   $04,'`',$07,$80,$01,$E0,$27,'`'
      DC.B   'D',$C0,$15,'@_',$A0,$03,$C0 
      DC.B   'H',$80,'0 U',$A0,$15,$E0
      DC.B   $15,$E0,'#',$00,'H',$80,$06,$E0
      DC.B   'K',$00,'8',$E0,'$@c`' 
      DC.B   '8@B@J`2',$A0
      DC.B   $05,$00,$08,$C0,$1E,$00,'5 ' 
      DC.B   '(',$A0,$05,$A0,$18,'`',$15,'@'
      DC.B   $1E,$00,'F',$A0,'5',$C0,$1C,' '
      DC.B   'I',$C0,'-',$A0,'Y`5 ' 
      DC.B   'a',$80,$15,'@',$1C,$C0,'.@' 
      DC.B   'V@! ',$17,$C0,$10,$E0 
      DC.B   'F',$00,$05,$A0,'F',$A0,$1A,$E0
      DC.B   'N [',$E0,'B@C',$80
      DC.B   $14,$A0,$1C,$C0,$05,$00,$0A,$A0
      DC.B   '\',$80,'E`',$07,$80,'L@'
      DC.B   ']',$C0,'(',$00,'2',$00,'B@' 
      DC.B   $04,'`V',$E0,'!',$C0,'A',$A0 
      DC.B   'V',$E0,'`',$E0,$0D,$C0,$17,' '
      DC.B   'a',$80,$06,'@A',$00,'&',$C0 
      DC.B   $06,$E0,$08,$C0,$03,$C0,'(',$A0
      DC.B   'F',$00,$17,' `',$E0,$05,$00 
      DC.B   'K',$00,'1`W',$80,$17,$C0
      DC.B   $17,$C0,'$',$E0,'I',$C0,$09,'`'
      DC.B   'L',$E0,':',$C0,'&',$C0,$00,$A0
      DC.B   ':',$C0,'D',$C0,'L',$E0,'3',$E0
      DC.B   $06,'@',$0A,$00,$1F,$E0,'7',$00
      DC.B   '+ ',$07,$80,$1A,$E0,$16,$80 
      DC.B   $1F,'@G',$E0,'8@',$1E,$A0
      DC.B   'L@0 [',$E0,'6`' 
      DC.B   'c`',$16,$80,$1F,'@/',$80
      DC.B   'X #',$00,$19,$A0,$13,'`'
      DC.B   'H',$80,$07,$80,'G',$E0,$1C,' '
      DC.B   'O`] C',$80,'F',$00
      DC.B   $17,' ',$1E,$A0,$07,$80,$0C,$80
      DC.B   '_',$00,'F',$A0,$08,$C0,'M',$80
      DC.B   '_',$00,')',$E0,'3@D',$C0
      DC.B   $05,$A0,'X',$C0,'#',$A0,'D ' 
      DC.B   'Y`c`',$0F,$00,$19,$A0 
      DC.B   'b',$C0,$08,' B@(',$A0 
      DC.B   $09,'`',$0A,$00,$05,$A0,')',$E0
      DC.B   'G@',$19,$00,'b ',$06,'@'
      DC.B   'M',$80,'2',$A0,'Y`',$19,$A0 
      DC.B   $19,$A0,'&',$C0,'K',$00,$0B,$E0
      DC.B   'N',$C0,'<',$A0,')@',$01,$E0 
      DC.B   '=@G@O`5 ' 
      DC.B   $07,$80,$0B,'@!',$C0,'8',$E0 
      DC.B   '-',$A0,$09,'`',$1D,'`',$17,$C0
      DC.B   ' ',$80,'I :',$C0,'! ' 
      DC.B   'N',$C0,'2',$A0,'^`7',$A0
      DC.B   $01,'@',$17,$C0,'!',$C0,'0',$C0
      DC.B   'Z',$00,'$',$E0,$1B,$80,$15,$E0
      DC.B   'K',$00,$09,'`I ',$1D,'`'
      DC.B   'P',$A0,'^`D',$C0,'H',$80
      DC.B   $19,$A0,' ',$80,$0A,$00,$0E,'`'
      DC.B   'a',$80,'G',$E0,$0A,$00,'N',$C0
      DC.B   '`@+',$C0,'4',$80,'G@' 
      DC.B   $06,$E0,'Z',$A0,'%',$80,'F',$A0
      DC.B   '[',$E0,$01,$E0,$10,'@',$1C,' '
      DC.B   $00,$00,$0A,$00,'C',$80,'*',$80
      DC.B   $0B,$E0,$0B,'@',$07,$80,'+ ' 
      DC.B   'H',$80,$1A,$E0,'c`',$07,$80 
      DC.B   'P',$00,'3',$E0,'[@',$1B,$80 
      DC.B   $1B,$80,'(',$A0,'L@',$0E,'`' 
      DC.B   'P',$A0,'>',$80,'+',$C0,$03,' '
      DC.B   '?',$C0,'I',$C0,'Q',$E0,'6`' 
      DC.B   $08,$C0,$0C,$80,'#',$A0,':',$C0
      DC.B   '0 ',$0B,'@',$1F,$E0,$19,$00 
      DC.B   '!',$C0,'J`=@#',$A0
      DC.B   'Q@5 `',$E0,'8',$E0
      DC.B   $03,' ',$19,$00,'$@2',$00
      DC.B   '[',$E0,'&',$C0,$1D,'`',$18,'`'
      DC.B   'M',$80,$0B,'@J`',$1E,$A0
      DC.B   'Q',$E0,'_',$A0,'F',$00,'K',$00
      DC.B   $1C,' "`',$0C,$80,$10,'@'
      DC.B   $00,$00,'I ',$0B,'@P',$00
      DC.B   'a',$80,'-',$A0,'5',$C0,'I',$C0
      DC.B   $08,' \',$80,$27,'`I ' 
      DC.B   '^`',$04,'`',$11,$80,$1E,$A0 
      DC.B   $01,'@',$0B,$E0,'D',$C0,',`' 
      DC.B   $0E,'`',$0C,$80,$09,'`,`'
      DC.B   'I',$C0,$1C,$C0,$00,$A0,$08,$C0
      DC.B   'R',$80,'5 ] ',$1D,'`' 
      DC.B   $1D,'`*',$80,'M',$80,$10,$E0 
      DC.B   'R',$80,'@`.@',$04,'`' 
      DC.B   'B@L@T`7',$A0
      DC.B   $0A,$00,$0D,$C0,'%',$80,'<',$A0
      DC.B   '2',$A0,$0D,' "`',$1A,'@'
      DC.B   '#',$00,'K',$A0,'?',$C0,'& ' 
      DC.B   'S',$C0,'7',$A0,'c`: ' 
      DC.B   $05,$00,$1A,'@&',$C0,'3@'
      DC.B   ']',$C0,'(',$A0,$1F,'@',$1A,$E0
      DC.B   'P',$00,$0D,' K',$A0,$1F,$E0 
      DC.B   'S `',$E0,'G@M',$80
      DC.B   $1E,$A0,'$@',$0F,$00,$12,' ' 
      DC.B   $02,$80,'J`',$0C,$80,'Q@'
      DC.B   'b',$C0,'/',$80,'7',$00,'L@' 
      DC.B   $09,'`^`)@K',$A0 
      DC.B   '`',$E0,$06,$E0,$12,$C0,'! ' 
      DC.B   $02,$80,$0D,$C0,'F',$00,'.@' 
      DC.B   $10,$E0,$0D,$C0,$0B,'@-',$A0 
      DC.B   'K',$00,$1E,$A0,$01,$E0,$0A,$00
      DC.B   'U',$00,'6`_',$00,$1F,'@'
      DC.B   $1F,'@,`N',$C0,$13,'`' 
      DC.B   'T`B@0',$C0,$05,$A0
      DC.B   'D',$C0,'N',$C0,'V',$E0,'8',$E0
      DC.B   $0B,'@',$0F,$00,$27,'`>',$80 
      DC.B   '5 ',$0F,$00,'$',$E0,$1B,$80 
      DC.B   '$@L',$E0,'B@(',$A0
      DC.B   'V@: ',$01,$E0,';`'
      DC.B   $06,$E0,$1B,$80,')@4',$80
      DC.B   '_',$A0,'*',$80,'! ',$1D,'`' 
      DC.B   'R',$80,$0F,$00,'L',$E0,'! ' 
      DC.B   'T`b H',$80,'P',$00
      DC.B   '! & ',$11,$80,$14,$00 
      DC.B   $05,$00,'K',$A0,$0D,$C0,'R',$80
      DC.B   $00,$00,'1`8@N',$C0
      DC.B   $0A,$A0,'`@+ N ' 
      DC.B   'c`',$09,'`',$14,$00,'#',$A0 
      DC.B   $03,$C0,$0F,$A0,'G@0 ' 
      DC.B   $13,'`',$0F,$00,$0D,' .',$E0 
      DC.B   'L@ ',$80,$03,' ',$0B,'@'
      DC.B   'W',$80,'7',$A0,'`',$E0,'! ' 
      DC.B   '! .@P',$00,$15,$E0
      DC.B   'V@D 3@',$06,$E0 
      DC.B   'G@Q@Y`: ' 
      DC.B   $0C,$80,$10,'@)@@`'
      DC.B   '7',$A0,$10,$E0,$27,'`',$1C,$C0
      DC.B   '%',$80,'N D',$C0,'+ ' 
      DC.B   'X',$C0,'<',$A0,$04,'`<',$A0 
      DC.B   $08,$C0,$1C,$C0,'+',$C0,'5',$C0
      DC.B   'a',$80,',`#',$00,$1F,$E0
      DC.B   'U',$00,$10,$E0,'N "`' 
      DC.B   'U',$A0,'c`I',$C0,'R',$80
      DC.B   '#',$A0,'(',$00,$14,$00,$15,$E0
      DC.B   $07,$80,'L',$E0,$0F,$00,'S',$C0
      DC.B   $01,'@3@9',$80,'Q@'
      DC.B   $0B,$E0,'b -',$00,'P',$A0
      DC.B   $01,$E0,$0B,$E0,$15,'@& '
      DC.B   $05,$00,$11,$80,'H',$80,'2',$00
      DC.B   $15,$E0,$10,'@',$0F,$00,'0 ' 
      DC.B   'M',$80,'"`',$04,'`',$0C,$80 
      DC.B   'Z',$00,'8',$E0,'b',$C0,'#',$00
      DC.B   '#',$00,'0 Q@',$18,'`' 
      DC.B   'X F',$00,'5',$C0,$08,' '
      DC.B   'I',$C0,'S',$C0,'[',$E0,';`' 
      DC.B   $0D,$C0,$11,$80,'+ B@' 
      DC.B   ': ',$12,$C0,')',$E0,$1E,$00 
      DC.B   '&',$C0,'O`G@-',$A0
      DC.B   '[@? ',$06,$E0,'=',$E0 
      DC.B   $0A,$A0,$1E,$00,'.@7',$00
      DC.B   'c`.@$',$E0,'"`' 
      DC.B   'W',$80,$12,$C0,'O`#',$A0
      DC.B   'V',$E0,$00,$A0,'K',$00,'U',$00
      DC.B   '& )',$E0,$16,$80,$17,$C0
      DC.B   $0A,$00,'N ',$10,'@U',$00
      DC.B   $02,$80,'5 :',$C0,'S',$C0
      DC.B   $0D,' ',$00,$00,'.',$E0,'S ' 
      DC.B   $04,'`',$0E,'`',$16,$80,'(',$A0
      DC.B   $06,'@',$13,'`I',$C0,'3',$E0 
      DC.B   $18,'`',$11,$80,$10,$E0,'1`' 
      DC.B   'N',$C0,'$@',$05,$A0,$0D,$C0 
      DC.B   '\',$80,': ',$00,$A0,'$',$E0 
      DC.B   '$',$E0,'2',$00,'R',$80,$1A,$E0
      DC.B   'Z',$00,'G',$E0,'8@',$09,'`' 
      DC.B   'L@V@^`<',$A0
      DC.B   $0F,$00,$12,$C0,'-',$00,'D ' 
      DC.B   '<',$A0,$14,$A0,',`',$1F,'@' 
      DC.B   '(',$00,'P',$A0,'I',$C0,'0 ' 
      DC.B   ']',$C0,'A',$A0,$09,'`? '
      DC.B   $0C,$80,$1F,'@0',$C0,'8@'
      DC.B   $01,'@0 &',$C0,'$',$E0 
      DC.B   'Z',$00,$14,$A0,'P',$A0,'$',$E0
      DC.B   'X ',$01,$E0,'L@W',$80 
      DC.B   '(',$A0,'+',$C0,$19,$00,$19,$A0
      DC.B   $0C,$80,'O`',$11,$80,'V@'
      DC.B   $03,$C0,'7',$00,'<',$00,'V@' 
      DC.B   $0E,'`',$01,$E0,'0',$C0,'U',$A0
      DC.B   $06,$E0,$10,$E0,$17,$C0,'+ ' 
      DC.B   $07,$80,$15,'@K',$00,'5',$C0 
      DC.B   $1A,$E0,$12,$C0,$12,$C0,'2',$A0
      DC.B   'P',$00,'& ',$06,$E0,$0F,$00 
      DC.B   '_',$00,';`',$02,$80,'&',$C0 
      DC.B   '&',$C0,'3',$E0,'S',$C0,$1D,'`'
      DC.B   '[',$E0,'I',$C0,':',$C0,$0A,$A0
      DC.B   'N',$C0,'X',$C0,'`',$E0,'=',$E0
      DC.B   $10,'@',$14,$00,'.',$E0,'F',$00
      DC.B   '? ',$16,$80,'.',$E0,' ',$80 
      DC.B   ')@Q',$E0,'L@2',$A0
      DC.B   '`@D ',$0B,$E0,'@`'
      DC.B   $0E,'` ',$80,'3@9',$80 
      DC.B   $03,' 2',$00,'(',$A0,$27,'`' 
      DC.B   '\',$80,$16,$80,'Q',$E0,'& ' 
      DC.B   'Y`',$03,' M',$80,'Z',$00
      DC.B   '+ -',$A0,$1B,$80,$1B,$80
      DC.B   $0F,$00,'P',$A0,$12,$C0,'W',$80
      DC.B   $05,$00,'8',$E0,'=@X',$C0
      DC.B   $0F,$A0,$03,$C0,'2',$A0,'X ' 
      DC.B   $09,'`',$13,'`',$19,$00,'-',$A0
      DC.B   $08,$C0,$17,' L@7',$A0 
      DC.B   $1D,'`',$14,$00,$14,$A0,'3',$E0
      DC.B   'Q@(',$00,$08,' ',$10,'@'
      DC.B   'a',$80,'<',$A0,$04,'`(',$A0 
      DC.B   '(',$A0,'5',$C0,'U',$00,$1F,$E0
      DC.B   ']',$C0,'K',$A0,'=@',$0B,$E0 
      DC.B   'Q@[@c`? ' 
      DC.B   $11,$80,$15,'@0',$C0,'G',$E0 
      DC.B   'A',$A0,$18,'`1`!',$C0 
      DC.B   '*',$80,'S N',$C0,'5 ' 
      DC.B   'b',$C0,'F',$A0,$0E,'`A',$A0 
      DC.B   $10,'@!',$C0,'5',$C0,':',$C0 
      DC.B   $05,$00,'3',$E0,'*',$80,')',$E0
      DC.B   '_',$00,$18,'`S ',$27,'`'
      DC.B   'Z',$A0,$04,'`N',$C0,'\',$80 
      DC.B   '-',$A0,'/',$80,$1E,$00,$1D,'`'
      DC.B   $11,$80,'Q',$E0,$14,$00,'X',$C0
      DC.B   $06,'@:',$C0,'>',$80,'[@'
      DC.B   $10,$E0,$05,$A0,'4',$80,'Z',$A0
      DC.B   $0B,$E0,$15,$E0,$1A,'@0 '
      DC.B   $0A,$00,$19,$00,'M',$80,'9',$80
      DC.B   $1F,$E0,$15,'@',$16,$80,'5 ' 
      DC.B   'R',$80,')',$E0,$09,'`',$11,$80
      DC.B   $00,$00,'=',$E0,$06,'@*',$80 
      DC.B   '*',$80,'7',$A0,'V@"`' 
      DC.B   '_',$A0,'M',$80,'?',$C0,$0D,' '
      DC.B   'S',$C0,']',$C0,$01,$E0,'@`' 
      DC.B   $12,$C0,$16,$80,'2',$A0,'I',$C0
      DC.B   'D ',$1A,'@3',$E0,'#',$00
      DC.B   '+',$C0,'T`Q@7',$A0
      DC.B   $01,'@I ',$10,$E0,'B',$E0
      DC.B   $12,' #',$00,'8@<',$00 
      DC.B   $06,$E0,'5',$C0,',`,`' 
      DC.B   'a',$80,$1A,'@T`(',$A0 
      DC.B   '[',$E0,$05,$A0,'P',$00,'_',$00
      DC.B   '0 1` ',$80,$1F,'@'
      DC.B   $14,$00,'S ',$15,'@Z',$00
      DC.B   $07,$80,'<',$A0,'?',$C0,']',$C0
      DC.B   $12,' ',$07,$80,'6`] ' 
      DC.B   $0E,'`',$18,'`',$1B,$80,'2',$A0
      DC.B   $0B,'@',$1A,$E0,'N',$C0,';`' 
      DC.B   '"`',$16,$80,$18,'`6`' 
      DC.B   'S',$C0,'+',$C0,$0A,$A0,$12,$C0
      DC.B   $02,$80,'? ',$08,' ,`' 
      DC.B   ',`9',$80,'W',$80,'$',$E0
      DC.B   'a',$80,'O`B@',$0E,'`' 
      DC.B   'V@`@',$04,'`A',$A0
      DC.B   $14,$00,$17,$C0,'4',$80,'K',$A0
      DC.B   'F',$A0,$1C,' 6`$@'
      DC.B   '-',$00,'U',$A0,'S',$C0,': ' 
      DC.B   $03,$C0,'K',$A0,$13,'`D '
      DC.B   $14,$00,'$@:',$C0,'=@' 
      DC.B   $08,$C0,'7',$A0,'.@.',$E0
      DC.B   $00,$00,$1C,' U',$A0,')',$E0 
      DC.B   '] ',$06,$E0,'Q@a',$80 
      DC.B   '2',$A0,'3@#',$00,'! ' 
      DC.B   $16,$80,'T`',$16,$80,'[@'
      DC.B   $08,$C0,'>',$80,'A',$00,'`@' 
      DC.B   $13,'`',$09,'`8@_',$A0 
      DC.B   $10,$E0,$1A,$E0,$1C,$C0,'5 ' 
      DC.B   $0C,$80,$1C,$C0,'P',$00,'=@' 
      DC.B   '$',$E0,$17,$C0,$1A,'@7',$A0 
      DC.B   'U',$00,'-',$A0,$0B,$E0,$14,$00
      DC.B   $05,$00,'@`',$0A,$00,'.@'
      DC.B   '.@;`X',$C0,$27,'`'
      DC.B   'c`Q@D',$C0,$0F,$A0
      DC.B   'X',$C0,'b',$C0,$06,$E0,'B',$E0
      DC.B   $15,'@',$19,$00,'6`M',$80
      DC.B   'I ',$1E,$00,'8',$E0,'%',$80 
      DC.B   '.@V',$E0,'V@<',$A0
      DC.B   $06,'@N ',$15,$E0,'E`' 
      DC.B   $15,$E0,'%',$80,'=@>',$80
      DC.B   $0A,$A0,'9',$80,'0 1`' 
      DC.B   $02,$80,$1E,$00,'V',$E0,'+ ' 
      DC.B   '^`',$08,' R',$80,$00,$00
      DC.B   '5 5 %',$80,'#',$00
      DC.B   $19,$00,'U',$A0,$17,$C0,'\',$80
      DC.B   $0A,$00,'@`B@b',$C0
      DC.B   $14,$A0,$0B,'@: b '
      DC.B   $13,'`',$1D,'`',$1E,$00,'7',$A0
      DC.B   $0D,$C0,$1E,$A0,'Q@? ' 
      DC.B   $27,'`',$19,$00,$1C,' 8',$E0 
      DC.B   'V@/',$80,$0D,' ',$15,'@'
      DC.B   $07,$80,'A',$A0,$0B,$E0,'0 ' 
      DC.B   '0 =@Z',$00,')',$E0
      DC.B   $01,'@S G@',$10,$E0
      DC.B   '[@',$01,'@',$09,'`D ' 
      DC.B   $16,$80,$1A,'@8@O`'
      DC.B   'K',$A0,$1F,$E0,';`&',$C0
      DC.B   '/',$80,'X X',$C0,'? ' 
      DC.B   $08,$C0,'P',$A0,$18,'`F',$A0 
      DC.B   $17,$C0,'&',$C0,'?',$C0,'?',$C0
      DC.B   $0C,$80,';`2',$00,'3',$E0
      DC.B   $05,$00,$1F,$E0,'X ,`' 
      DC.B   '_',$A0,$09,'`S',$C0,$02,$80 
      DC.B   '7',$A0,'7',$00,'(',$00,'$',$E0
      DC.B   $1B,$80,'V',$E0,$19,$00,']',$C0
      DC.B   $0B,'@B@C',$80,$01,'@' 
      DC.B   $15,$E0,$0D,' <',$00,$00,$A0 
      DC.B   $15,$E0,$1F,$E0,$1F,'@: '
      DC.B   $0F,$00,' ',$80,'R',$80,'A',$00
      DC.B   ')',$E0,$1A,'@',$1E,$00,': ' 
      DC.B   'W',$80,'1`',$0E,'`',$16,$80 
      DC.B   $0A,$00,'B',$E0,$0D,$C0,'2',$00
      DC.B   '2',$00,'? [@,`' 
      DC.B   $03,' U',$00,'I',$C0,$12,' ' 
      DC.B   ']',$C0,$03,$C0,$0B,$E0,'E`' 
      DC.B   $17,$C0,$1B,$80,': Q@' 
      DC.B   'N !',$C0,'=',$E0,'(',$00
      DC.B   '0',$C0,'Y`[@A',$A0
      DC.B   $0B,'@S ',$1A,$E0,'G',$E0
      DC.B   $19,$A0,'(',$00,'B@A',$00
      DC.B   $0E,'`=@3',$E0,'6`'
      DC.B   $07,$80,'!',$C0,'Y`-',$A0
      DC.B   '`',$E0,$0A,$A0,'U',$00,$05,$00
      DC.B   ': 8',$E0,'*',$80,'&',$C0
      DC.B   $1E,$00,'X ',$1A,'@_',$00
      DC.B   $0C,$80,'D D',$C0,$03,$C0
      DC.B   $17,' ',$0F,$00,'=',$E0,$03,' '
      DC.B   $18,'`"` ',$80,'<',$A0 
      DC.B   $10,'@"`S',$C0,'B',$E0 
      DC.B   ',`',$1B,$80,$1F,$E0,';`'
      DC.B   'X',$C0,'3@',$0F,$A0,$17,$C0 
      DC.B   $0C,$80,'D ',$0F,$A0,'3',$E0 
      DC.B   '3',$E0,'A',$00,'\',$80,'.',$E0
      DC.B   $05,$00,'V',$E0,'L@',$13,'`' 
      DC.B   '`@',$06,'@',$0E,'`F',$A0
      DC.B   $19,$00,$1C,$C0,'<',$00,'S ' 
      DC.B   'P',$A0,'#',$A0,'@`)@' 
      DC.B   '2',$00,'Z',$A0,']',$C0,'D ' 
      DC.B   $0D,$C0,'U',$A0,$1D,'`I '
      DC.B   $1B,$80,')@D',$C0,'B@' 
      DC.B   $10,'@? 5',$C0,'8',$E0 
      DC.B   $0A,$00,'#',$A0,'Z',$A0,'.',$E0
      DC.B   'b ',$0B,$E0,'V@',$07,$80
      DC.B   '<',$A0,':',$C0,'-',$00,'(',$A0
      DC.B   ' ',$80,'Y`',$1B,$80,'`@'
      DC.B   $0D,$C0,'F',$00,'F',$00,$06,'@'
      DC.B   $18,'`',$10,$E0,'?',$C0,$05,$A0
      DC.B   $1A,$E0,'$',$E0,'!',$C0,'? ' 
      DC.B   $11,$80,'$@U',$00,'D',$C0
      DC.B   '.',$E0,$1C,$C0,'!',$C0,'<',$A0
      DC.B   'Z',$00,'5 ',$10,$E0,$19,$00 
      DC.B   $0F,$00,'E`',$11,$80,'5',$C0 
      DC.B   '5',$C0,'B',$E0,']',$C0,'1`' 
      DC.B   $06,$E0,'X',$C0,'N',$C0,$14,$A0
      DC.B   'b',$C0,$08,$C0,$10,$E0,'G',$E0
      DC.B   $1A,'@',$1E,$00,'=',$E0,'U',$00
      DC.B   'S %',$80,'B',$E0,'*',$80
      DC.B   '3@[',$E0,'`@F',$A0
      DC.B   $10,'@X ',$1F,$E0,'J`' 
      DC.B   $1D,'`*',$80,'G@C',$80 
      DC.B   $12,' A',$00,'7',$A0,';`'
      DC.B   $0C,$80,'%',$80,'[',$E0,'0 ' 
      DC.B   'c`',$0D,' W',$80,$0A,$00
      DC.B   '? <',$A0,'/',$80,'*',$80
      DC.B   '#',$00,'Z',$A0,$1C,$C0,'a',$80
      DC.B   $0F,$00,'G',$E0,'G@',$08,$C0 
      DC.B   $19,$A0,$12,$C0,'A',$A0,$08,' '
      DC.B   $1D,'`',$27,'`#',$00,'A',$A0 
      DC.B   $12,$C0,'& V@F',$A0
      DC.B   '1`',$1E,$00,'#',$A0,'=',$E0 
      DC.B   '[@7',$00,$12,' ',$1A,'@'
      DC.B   $11,$80,'F',$A0,$13,'`7',$A0 
      DC.B   '7',$A0,'D',$C0,'_',$00,'3',$E0
      DC.B   $08,$C0,'Z',$A0,'Q@',$15,$E0 
      DC.B   $01,'@',$0B,'@',$13,'`I '
      DC.B   $1B,$80,$1F,'@?',$C0,'V',$E0 
      DC.B   'U',$A0,$27,'`E`+',$C0 
      DC.B   '4',$80,'] b',$C0,'I ' 
      DC.B   $12,$C0,'Z',$A0,'"`K',$A0
      DC.B   $1F,'@+',$C0,'I',$C0,'D',$C0 
      DC.B   $14,$00,'B',$E0,'9',$80,'=',$E0
      DC.B   $0F,$00,$27,'`] 1`'
      DC.B   $00,$A0,$0E,'`X',$C0,$0C,$80 
      DC.B   'A',$A0,'>',$80,'2',$00,',`' 
      DC.B   '%',$80,'[',$E0,$1E,$00,'b',$C0
      DC.B   $10,'@I',$C0,'H',$80,$0B,'@' 
      DC.B   $1A,$E0,$14,$A0,'C',$80,$0A,$A0
      DC.B   $1F,$E0,')',$E0,'$@D ' 
      DC.B   $14,$00,'(',$00,'W',$80,'H',$80
      DC.B   '3',$E0,$1F,'@%',$80,'? '
      DC.B   '\',$80,'8',$E0,$13,'`',$1B,$80
      DC.B   $14,$00,'G',$E0,$15,'@9',$80 
      DC.B   '9',$80,'F',$A0,'`@6`' 
      DC.B   $0A,$A0,'\',$80,'S',$C0,$17,' '
      DC.B   $03,$C0,$0D,$C0,$15,$E0,'J`' 
      DC.B   $1C,$C0,' ',$80,'A',$A0,'X',$C0
      DC.B   'X )@G',$E0,'-',$00
      DC.B   '5',$C0,'^`',$01,'@K',$A0
      DC.B   $15,'@] $',$E0,'L',$E0 
      DC.B   '! -',$00,'L@F',$00
      DC.B   $15,$E0,'D',$C0,';`@`' 
      DC.B   $11,$80,')@^`2',$A0
      DC.B   $01,$E0,$0F,$A0,'Z',$00,$0F,$00
      DC.B   'D @`4',$80,'.@' 
      DC.B   '(',$00,'] ',$1F,'@',$00,$00 
      DC.B   $11,$80,'K',$A0,'I',$C0,$0D,$C0
      DC.B   $1C,' ',$16,$80,'E`',$0D,' ' 
      DC.B   '"`,`%',$80,'F',$A0
      DC.B   $15,'@)',$E0,'X',$C0,'J`'
      DC.B   '6` ',$80,$27,'`@`'
      DC.B   ']',$C0,':',$C0,$14,$A0,$1C,$C0
      DC.B   $16,$80,'I ',$17,' ;`' 
      DC.B   ';`H',$80,'a',$80,'8',$E0
      DC.B   $0C,$80,'^`V@',$18,'`' 
      DC.B   $06,'@',$10,'@',$18,'`K',$A0 
      DC.B   $1E,$00,'!',$C0,'C',$80,'Z',$A0
      DC.B   'Z',$A0,'+ J`.@' 
      DC.B   '7',$00,'_',$A0,$03,$C0,'N ' 
      DC.B   $17,$C0,'_',$A0,$27,'`N '
      DC.B   '#',$00,'.@N',$C0,'G@' 
      DC.B   $17,$C0,'F',$A0,'=@B',$E0
      DC.B   $14,$00,'+ _',$A0,'3',$E0
      DC.B   $03,' ',$10,$E0,'[@',$11,$80 
      DC.B   'F',$A0,'B@7',$00,'0 ' 
      DC.B   '*',$80,'^` ',$80,$01,'@'
      DC.B   $12,$C0,'M',$80,'K',$00,$10,'@'
      DC.B   $1D,'`',$18,'`G@',$0F,$A0
      DC.B   '$',$E0,'.',$E0,'&',$C0,'I ' 
      DC.B   $16,$80,'+',$C0,'Z',$00,'L@' 
      DC.B   '8',$E0,'!',$C0,')@A',$A0
      DC.B   '_',$00,'<',$A0,$15,$E0,$1E,$00
      DC.B   $19,$00,'J`',$19,$00,'=@'
      DC.B   '=@J`b',$C0,';`' 
      DC.B   $0E,'``@X',$C0,$19,$A0 
      DC.B   $08,$C0,$12,$C0,$1A,$E0,'L',$E0
      DC.B   $1F,'@#',$00,'E`\',$80 
      DC.B   '] -',$00,'L',$E0,'/',$80
      DC.B   '8@`',$E0,$06,'@P',$A0 
      DC.B   $1A,'@b )',$E0,'O`'
      DC.B   '$',$E0,'/',$80,'Q@H',$80
      DC.B   $19,$A0,'H',$80,'? E`' 
      DC.B   $16,$80,'-',$00,'`',$E0,'5 ' 
      DC.B   $04,'`',$12,' \',$80,$14,$00 
      DC.B   'I D 9',$80,'2',$00
      DC.B   '-',$00,'_',$A0,'!',$C0,$02,$80
      DC.B   $14,$00,'O`L@',$12,$C0 
      DC.B   $1E,$A0,$1A,'@I ',$12,' '
      DC.B   $27,'`1`(',$00,'K',$A0 
      DC.B   $17,$C0,'-',$A0,'[@N ' 
      DC.B   ';`#',$00,'+ B',$E0
      DC.B   '`@>',$80,$17,' ',$1F,'@'
      DC.B   $1B,$80,'K',$A0,$1A,$E0,'? ' 
      DC.B   '? L@',$00,$00,'=',$E0 
      DC.B   $10,'@b [@',$1A,$E0
      DC.B   $0B,'@',$15,'@',$1D,'`N '
      DC.B   ' ',$80,'$@G@^`' 
      DC.B   '_',$A0,'.',$E0,'O`0',$C0
      DC.B   '9',$80,'b ',$08,$C0,'S '
      DC.B   $1C,$C0,$00,$A0,',`P',$A0
      DC.B   '&',$C0,'0',$C0,'S',$C0,'I',$C0
      DC.B   $1B,$80,'J`A',$00,'G',$E0
      DC.B   $19,$00,'.',$E0,'b 6`' 
      DC.B   $05,$A0,$13,'`]',$C0,$16,$80 
      DC.B   'K',$A0,'F',$00,'<',$00,'3',$E0
      DC.B   '/',$80,'`',$E0,'#',$00,$03,$C0
      DC.B   $15,'@Q@M',$80,$15,'@' 
      DC.B   $1F,$E0,$1C,' K',$00,$14,$A0 
      DC.B   ')',$E0,'3',$E0,')@N ' 
      DC.B   $19,$00,'/',$80,'\',$80,'P',$00
      DC.B   '=',$E0,'$@-',$00,'D ' 
      DC.B   'a',$80,'@`',$18,'` ',$80
      DC.B   $1E,$00,'L',$E0,$1C,$C0,'A',$00
      DC.B   'A',$00,'N ',$01,'@@`' 
      DC.B   $12,' ',$00,$00,']',$C0,$1C,' '
      DC.B   $0D,$C0,$17,$C0,$1F,$E0,'O`' 
      DC.B   '!',$C0,'%',$80,'I `@' 
      DC.B   'b 0',$C0,'Q',$E0,'2',$00
      DC.B   ':',$C0,'c`',$0B,'@U',$A0
      DC.B   $1F,'@',$03,' .',$E0,'Q',$E0 
      DC.B   '(',$A0,'2',$00,'V@K',$00
      DC.B   $1D,'`L@B',$E0,'J`'
      DC.B   $1B,$80,'0',$C0,'c`7',$A0
      DC.B   $06,$E0,$14,$A0,'_',$00,$19,$00
      DC.B   'N G',$E0,'>',$80,'5',$C0
      DC.B   '2',$00,'b $@',$05,$00 
      DC.B   $16,$80,'S N',$C0,$17,$C0
      DC.B   '! ',$1E,$00,'L',$E0,$17,' ' 
      DC.B   ',`6`*',$80,'P',$A0
      DC.B   $1A,'@1`]',$C0,'Q',$E0 
      DC.B   '@`%',$80,'.',$E0,'E`' 
      DC.B   'b',$C0,'B@',$19,$A0,'!',$C0 
      DC.B   ' ',$80,'N ',$1E,$A0,'B',$E0 
      DC.B   'B',$E0,'P',$00,$02,$80,'B',$E0
      DC.B   $14,$00,$01,$E0,'`@',$1D,'`' 
      DC.B   $10,'@',$1A,'@"`P',$A0 
      DC.B   '#',$00,'&',$C0,'K',$00,'b ' 
      DC.B   $00,$A0,'2',$A0,'T`3@' 
      DC.B   '<',$00,$00,$A0,$0D,$C0,'X ' 
      DC.B   '!',$C0,$05,$A0,'1`S ' 
      DC.B   '*',$80,'3@X',$C0,'L@' 
      DC.B   $1F,'@N D',$C0,'L',$E0 
      DC.B   $1E,$00,'2',$A0,$00,$A0,'8',$E0
      DC.B   $08,' ',$15,$E0,'`@',$1B,$80 
      DC.B   'P',$A0,'I',$C0,'A',$00,'7',$A0
      DC.B   '4',$80,'c`%',$80,$06,'@'
      DC.B   $17,$C0,'U',$00,'P',$00,$1A,'@'
      DC.B   '"`',$1F,$E0,'N',$C0,$19,$A0 
      DC.B   '.',$E0,'8',$E0,'+',$C0,'S ' 
      DC.B   $1B,$80,'3@_',$00,'S',$C0
      DC.B   'B',$E0,'&',$C0,'0',$C0,'F',$A0
      DC.B   $00,$00,'D ',$1A,$E0,'#',$00 
      DC.B   '#',$00,'O` ',$80,'D',$C0
      DC.B   'D',$C0,'Q',$E0,$03,$C0,'E`' 
      DC.B   $15,$E0,$03,$C0,'b',$C0,$1E,$A0
      DC.B   $12,$C0,$1C,$C0,'$',$E0,'Q',$E0
      DC.B   '$@(',$00,'L',$E0,$00,$00
      DC.B   $03,' 4',$80,'V',$E0,'4',$80 
      DC.B   '=@',$01,$E0,$10,'@Z',$A0
      DC.B   '$@',$08,' 3',$E0,'T`' 
      DC.B   ',`4',$80,'[@M',$80
      DC.B   '! P',$00,'F',$A0,'O`' 
      DC.B   ' ',$80,'4',$80,$01,$E0,': ' 
      DC.B   $09,'`',$17,' a',$80,$1E,$00 
      DC.B   'S K',$A0,'C',$80,'9',$80
      DC.B   '7',$00,$00,$A0,'&',$C0,$07,$80
      DC.B   $19,$00,'V',$E0,'Q@',$1C,$C0 
      DC.B   '#',$A0,'!',$C0,'P',$A0,$1C,' '
      DC.B   '1`;`-',$00,'U',$A0
      DC.B   $1C,$C0,'5 `@U',$A0
      DC.B   'E`(',$00,'2',$A0,'G',$E0
      DC.B   $01,'@F',$00,$1C,' $@' 
      DC.B   '%',$80,'P',$A0,'"`F',$A0
      DC.B   'F',$A0,'S',$C0,$05,$00,'G',$E0
      DC.B   $17,$C0,$05,$A0,$01,'@',$1F,$E0
      DC.B   $15,'@',$1F,'@',$27,'`S '
      DC.B   '%',$80,')@N',$C0,$01,$E0
      DC.B   $05,$A0,'6`Y`5',$C0
      DC.B   '>',$80,$03,' ',$12,$C0,'] ' 
      DC.B   '&',$C0,$0A,$A0,'6`U',$A0
      DC.B   '.@5',$C0,']',$C0,'N',$C0
      DC.B   '#',$00,'Q',$E0,'H',$80,'Q',$E0
      DC.B   '#',$00,'6`',$03,' ;`' 
      DC.B   $0A,$A0,$18,'`b',$C0,' ',$80 
      DC.B   'U',$A0,'M',$80,'F',$00,';`' 
      DC.B   '9',$80,$01,$E0,'(',$00,$08,$C0
      DC.B   $1A,'@X',$C0,'R',$80,$1F,'@' 
      DC.B   '$',$E0,'#',$A0,'R',$80,$1E,$A0
      DC.B   '3',$E0,'=',$E0,'.@X ' 
      DC.B   $1E,$00,'7',$00,'a',$80,'W',$80
      DC.B   'G',$E0,')@4',$80,'I ' 
      DC.B   $02,$80,'G',$E0,$1D,'`%',$80 
      DC.B   '(',$00,'Q',$E0,'$@H',$80
      DC.B   'H',$80,'U',$A0,$06,'@J`'
      DC.B   $19,$A0,$07,$80,$03,$C0,'! ' 
      DC.B   $17,$C0,'!',$C0,')',$E0,'T`' 
      DC.B   '&',$C0,'*',$80,'P',$A0,$03,$C0
      DC.B   $08,' 8@[',$E0,'7',$00 
      DC.B   '?',$C0,$04,'`',$15,'@_',$A0 
      DC.B   ')@',$0D,' 8',$E0,'V',$E0
      DC.B   '0 7',$00,'`@P',$00
      DC.B   '$',$E0,'S',$C0,'J`T`' 
      DC.B   '%',$80,'8@',$04,'`<',$A0
      DC.B   $0B,$E0,$19,$A0,$00,$00,'#',$00
      DC.B   'X O`H',$80,'=@' 
      DC.B   '<',$00,$03,' )@',$0A,$00
      DC.B   $1B,$80,'Z',$A0,'S',$C0,'!',$C0
      DC.B   '& %',$80,'T`! ' 
      DC.B   '6`@`/',$80,'Z',$A0
      DC.B   $1F,'@8',$E0,'b',$C0,'Y`'
      DC.B   'J`*',$80,'6`J`' 
      DC.B   $03,$C0,'I',$C0,$1E,$A0,'&',$C0
      DC.B   '*',$80,'S & J`' 
      DC.B   'J`W',$80,$07,$80,'L',$E0
      DC.B   $1B,$80,$09,'`',$06,'@"`'
      DC.B   $1A,'@$@,`U',$A0 
      DC.B   '(',$00,'+',$C0,'R',$80,$05,$A0
      DC.B   $0A,$A0,': ^`8@' 
      DC.B   'A',$00,$05,$A0,$17,$C0,'b ' 
      DC.B   '+',$C0,$0F,$A0,';`X ' 
      DC.B   '2',$00,'8@b',$C0,'Q@' 
      DC.B   '&',$C0,'U',$A0,'L@V',$E0
      DC.B   '(',$00,': ',$05,$A0,'=',$E0 
      DC.B   $0D,' ',$1A,$E0,$01,'@%',$80 
      DC.B   'Z',$A0,'Q@K',$00,'? ' 
      DC.B   '>',$80,$04,'`*',$80,$0B,'@' 
      DC.B   $1C,$C0,'\',$80,'U',$00,'$@' 
      DC.B   $27,'`',$27,'`V@#',$A0 
      DC.B   '8',$E0,'B',$E0,'0',$C0,'] ' 
      DC.B   ' ',$80,':',$C0,$00,$00,'[@' 
      DC.B   'L',$E0,'+',$C0,'8@K',$A0
      DC.B   $05,$00,'K',$A0,$1F,$E0,'(',$00
      DC.B   '-',$00,'T`(',$00,'L@' 
      DC.B   'L@Y`',$08,$C0,'O`'
      DC.B   $1D,'`',$0B,'@',$08,$C0,'#',$A0
      DC.B   $1C,$C0,'&',$C0,'.',$E0,'V',$E0
      DC.B   ')@-',$00,'T`',$07,$80 
      DC.B   $0D,' <',$00,'`',$E0,'9',$80 
      DC.B   'B@',$06,$E0,$1A,'@',$00,$A0 
      DC.B   '.@',$12,' =',$E0,'Y`' 
      DC.B   '3',$E0,'9',$80,$01,'@R',$80 
      DC.B   '(',$A0,'W',$80,'N Y`' 
      DC.B   '*',$80,'<',$00,$06,$E0,'? ' 
      DC.B   $0E,'`',$1C,' ',$02,$80,'(',$00
      DC.B   '] S M',$80,'A',$00
      DC.B   'A',$00,$05,$A0,'+',$C0,$0C,$80
      DC.B   $1E,$00,'^`V@&',$C0
      DC.B   '(',$A0,')@X & ' 
      DC.B   ';`E`2',$00,'_',$A0
      DC.B   '!',$C0,'<',$A0,$01,'@] '
      DC.B   'O`-',$00,': L',$E0
      DC.B   $06,'@M',$80,'! )@'
      DC.B   '/',$80,'U',$A0,')',$E0,'N ' 
      DC.B   'N [@',$0A,$00,'Q',$E0 
      DC.B   $1F,'@',$0D,' ',$0B,'@$',$E0 
      DC.B   $1F,'@)@1`X '
      DC.B   '*',$80,'.@V@',$09,'`' 
      DC.B   $0F,$A0,'=',$E0,'c`:',$C0
      DC.B   'C',$80,$08,' ',$1C,$C0,$03,' '
      DC.B   '0',$C0,$14,$A0,'@`Z',$A0
      DC.B   '5',$C0,':',$C0,$03,$C0,'S',$C0
      DC.B   '*',$80,'Y`P',$00,'[',$E0
      DC.B   '-',$00,'=',$E0,$08,' @`'
      DC.B   $0F,$A0,$1D,'`',$03,$C0,'*',$80
      DC.B   '_',$A0,'U',$00,'P',$00,'B',$E0
      DC.B   'C',$80,$06,$E0,'-',$00,$0D,$C0
      DC.B   $1F,'@`@W',$80,')@'
      DC.B   ')',$E0,'+ Z',$00,'(',$A0
      DC.B   '=',$E0,'G',$E0,'3@b ' 
      DC.B   '#',$00,'>',$80,$02,$80,'_',$00
      DC.B   'Q',$E0,'.@<',$00,'N ' 
      DC.B   $07,$80,'O`"`*',$80
      DC.B   '2',$00,'V',$E0,'+',$C0,'P',$00
      DC.B   'P',$00,'] ',$0B,'@T`' 
      DC.B   '! ',$0F,$00,$0D,$C0,'& '
      DC.B   '!',$C0,'+',$C0,'3',$E0,'Y`' 
      DC.B   '+',$C0,'/',$80,'X ',$0B,'@' 
      DC.B   $12,' ?',$C0,$01,$E0,'<',$00 
      DC.B   'D',$C0,$09,'`',$1F,'@',$05,$A0
      DC.B   '3@',$17,' B',$E0,'[',$E0
      DC.B   '7',$A0,'<',$00,$06,'@U',$00 
      DC.B   ',`[@Q',$E0,'^`' 
      DC.B   '/',$80,'?',$C0,$09,'`A',$A0 
      DC.B   $10,$E0,$1E,$A0,$05,$00,'-',$00
      DC.B   'b V',$E0,'R',$80,'D',$C0
      DC.B   'F',$00,$08,' .@',$0F,$00
      DC.B   ' ',$80,'b X',$C0,'+',$C0
      DC.B   '+ -',$00,'[',$E0,'+ ' 
      DC.B   '@`J`4',$80,$00,$A0
      DC.B   '$@@`',$03,$C0,'`',$E0 
      DC.B   'T`/',$80,'=',$E0,'O`' 
      DC.B   $08,$C0,'Q@#',$A0,'+',$C0
      DC.B   '4',$80,'X -',$A0,'Q',$E0
      DC.B   'Q',$E0,'_',$00,$0C,$80,'V',$E0
      DC.B   '#',$00,$10,$E0,$10,'@',$27,'`'
      DC.B   '$@.@6`Z',$A0
      DC.B   '-',$00,'0',$C0,'Z',$00,$0D,' '
      DC.B   $14,$A0,'A',$A0,$04,'`=@'
      DC.B   'F',$00,$0A,$A0,'!',$C0,$08,' '
      DC.B   '5',$C0,$19,$A0,'E`] ' 
      DC.B   '9',$80,'=@',$08,$C0,'V@'
      DC.B   '.@] S',$C0,'`',$E0
      DC.B   '2',$00,'A',$A0,$0A,$A0,'B',$E0
      DC.B   $12,' ',$1F,$E0,$06,'@/',$80 
      DC.B   $00,$A0,'X',$C0,'U',$00,'F',$A0
      DC.B   'H',$80,$09,'`/',$80,$10,'@' 
      DC.B   '!',$C0,$00,$00,'Z',$00,'.@' 
      DC.B   ',`.',$E0,']',$C0,'-',$A0
      DC.B   'B',$E0,'L',$E0,'5',$C0,$03,' '
      DC.B   '%',$80,'B@',$05,$00,'b',$C0 
      DC.B   'V',$E0,'0',$C0,'?',$C0,'P',$A0
      DC.B   $0A,$00,'S $',$E0,'-',$00
      DC.B   '7',$00,'Y`/',$80,'S',$C0
      DC.B   'S',$C0,'`',$E0,$0D,$C0,'Y`' 
      DC.B   '$',$E0,$12,$C0,$12,$C0,'(',$A0
      DC.B   '&',$C0,'0',$C0,'8',$E0,'[',$E0
      DC.B   '.@2',$00,'[',$E0,$0F,$00
      DC.B   $17,' C',$80,$06,$E0,'>',$80 
      DC.B   'G@',$0B,$E0,'$@',$0A,$A0
      DC.B   '8@',$1C,' G',$E0,'^`' 
      DC.B   ';`>',$80,$0B,'@W',$80 
      DC.B   '0 _',$00,'U',$A0,'c`' 
      DC.B   '4',$80,'C',$80,$0B,$E0,'D ' 
      DC.B   $13,'`! ',$07,$80,'2',$00
      DC.B   $03,' Z',$A0,'W',$80,'H',$80 
      DC.B   'K',$00,$0A,$A0,'0',$C0,$11,$80
      DC.B   '#',$00,$01,$E0,'[@0',$C0
      DC.B   '-',$A0,'0',$C0,'_',$A0,'0 ' 
      DC.B   'E`O`7',$00,$05,$A0
      DC.B   '&',$C0,'D ',$06,'@',$00,$A0 
      DC.B   'Y`2',$00,'A',$A0,'Q',$E0
      DC.B   $0B,'@U',$00,'& .@'
      DC.B   '9',$80,'Z',$A0,'1`U',$A0
      DC.B   'U',$A0,'b',$C0,$0F,$00,'[',$E0
      DC.B   '&',$C0,$14,$A0,$15,'@)',$E0 
      DC.B   ')@3@;`] ' 
      DC.B   '/',$80,'3@]',$C0,$10,$E0
      DC.B   $19,$A0,'E`',$09,'`?',$C0
      DC.B   'H',$80,$0D,' &',$C0,$0D,' ' 
      DC.B   ':',$C0,$1E,$A0,'J`_',$A0
      DC.B   '=@?',$C0,$0D,$C0,'X',$C0
      DC.B   '2',$00,'`',$E0,'W',$80,$01,$E0
      DC.B   '7',$00,'E`',$0D,' E`' 
      DC.B   $14,$A0,'"`',$08,$C0,'4',$80 
      DC.B   $05,$A0,'\',$80,'Z',$00,'J`' 
      DC.B   'M',$80,$0B,$E0,'2',$00,$12,$C0
      DC.B   '$@',$03,$C0,'\',$80,'3@'
      DC.B   '.',$E0,'2',$A0,'a',$80,'2',$A0
      DC.B   'G',$E0,'Q',$E0,'8@',$08,' ' 
      DC.B   '(',$00,'F',$00,$07,$80,$02,$80
      DC.B   '[',$E0,'3@C',$80,'S ' 
      DC.B   $0C,$80,'V',$E0,$27,'`/',$80 
      DC.B   '<',$00,'[',$E0,'3@W',$80
      DC.B   'W',$80,$00,$A0,$10,'@^`'
      DC.B   '(',$A0,$16,$80,$17,$C0,'+ ' 
      DC.B   '+',$C0,'5',$C0,'=',$E0,'^`' 
      DC.B   '0',$C0,'4',$80,'_',$A0,$12,$C0
      DC.B   $1C,' G@',$0B,$E0,'A',$00
      DC.B   'I',$C0,$0E,'`)@',$0F,$A0
      DC.B   '=@! L',$E0,'`',$E0
      DC.B   '? A',$00,$10,'@Z',$00 
      DC.B   '3',$E0,'b',$C0,'Y`',$04,'`' 
      DC.B   '9',$80,'G@',$0E,'`F',$A0
      DC.B   $15,$E0,'#',$A0,$0A,$00,'7',$00
      DC.B   $08,' ^`\',$80,'L@'
      DC.B   'P',$00,$0D,' 3@',$14,$00
      DC.B   '%',$80,$05,$A0,']',$C0,'5',$C0
      DC.B   '0 4',$80,'c`5 ' 
      DC.B   'J`T`9',$80,$0A,$A0
      DC.B   ')@G',$E0,$08,$C0,$04,'`'
      DC.B   '^`4',$80,'E`T`' 
      DC.B   $0D,$C0,'X',$C0,'(',$A0,'0',$C0
      DC.B   '>',$80,'] 5 Y`' 
      DC.B   'Y`',$02,$80,$11,$80,'`',$E0 
      DC.B   '*',$80,$18,'`',$1A,'@,`'
      DC.B   '.@8@@`_',$A0
      DC.B   '2',$00,'5',$C0,'a',$80,$14,$A0
      DC.B   $1E,$A0,'I ',$0E,'`B@' 
      DC.B   'K',$00,$0F,$A0,'+',$C0,$12,' '
      DC.B   '?',$C0,'#',$A0,'O`b ' 
      DC.B   'A',$00,'B@',$12,$C0,'[@'
      DC.B   '5',$C0,$00,$A0,'[@',$06,$E0 
      DC.B   '<',$00,'I ',$0F,$A0,'G',$E0 
      DC.B   $17,' $',$E0,$0B,'@9',$80
      DC.B   $0A,$A0,'`@_',$00,'N ' 
      DC.B   'R',$80,$0E,'`4',$80,$15,'@' 
      DC.B   '&',$C0,$07,$80,'_',$00,'8@' 
      DC.B   '1`6`',$01,'@7',$A0
      DC.B   'L',$E0,'V',$E0,':',$C0,$0D,' '
      DC.B   '*',$80,'I',$C0,$0A,$00,$06,'@'
      DC.B   '`',$E0,'5',$C0,'G@U',$A0
      DC.B   $0F,$00,'Z',$A0,')',$E0,'2',$00
      DC.B   'A',$00,'^`7',$00,'[@' 
      DC.B   '[@',$04,'`',$12,$C0,'c`'
      DC.B   ',`',$1A,'@',$1C,$C0,'-',$A0 
      DC.B   '0',$C0,':',$C0,'B',$E0,'`',$E0
      DC.B   '3@7',$00,'c`',$16,$80 
      DC.B   '! K',$00,$10,$E0,'C',$80
      DC.B   'L@',$10,$E0,'.@',$14,$A0
      DC.B   'B@& Q',$E0,'c`' 
      DC.B   'B',$E0,'C',$80,$15,'@\',$80 
      DC.B   '7',$A0,$02,$80,'] ',$09,'`' 
      DC.B   '>',$80,'K',$00,$10,$E0,'I ' 
      DC.B   $18,'`& ',$0C,$80,'<',$00
      DC.B   $0D,' b a',$80,'P',$00 
      DC.B   'U',$00,$0F,$A0,'5',$C0,$16,$80
      DC.B   '(',$00,$09,'``@:',$C0 
      DC.B   '2',$A0,'8@',$03,' : ' 
      DC.B   'O`Y`<',$00,$0F,$A0
      DC.B   '+',$C0,'K',$A0,$0B,'@',$08,' '
      DC.B   'c`7',$00,'I V',$E0
      DC.B   $10,'@\',$80,'+ 3@'
      DC.B   'C',$80,'_',$A0,'8',$E0,'] ' 
      DC.B   '] ',$06,'@',$14,$00,$01,$E0 
      DC.B   '.@',$1C,' ',$1F,'@.',$E0
      DC.B   '3@=@E`b ' 
      DC.B   '4',$80,'8@',$01,'@',$18,'`' 
      DC.B   '#',$A0,'L',$E0,$13,'`D',$C0 
      DC.B   'M',$80,$12,' 0',$C0,$17,' ' 
      DC.B   'D',$C0,'(',$A0,'T`',$00,$A0 
      DC.B   'D',$C0,'D',$C0,$17,$C0,']',$C0
      DC.B   '9',$80,$04,'`_',$00,$0B,$E0 
      DC.B   'A',$00,'L',$E0,$12,' J`'
      DC.B   $19,$A0,$27,'`',$0D,$C0,'>',$80
      DC.B   $0F,$A0,$00,$00,$00,$00,'Q',$E0
      DC.B   'W',$80,$10,$E0,'7',$00,$17,$C0
      DC.B   ')@',$0B,'@a',$80,'=@' 
      DC.B   '3',$E0,': ',$05,$00,'<',$A0 
      DC.B   'Q',$E0,'[',$E0,'=@',$12,' ' 
      DC.B   '-',$00,'M',$80,$0C,$80,$0A,$00
      DC.B   $01,$E0,'8@K',$00,'X ' 
      DC.B   $11,$80,'^`,`4',$80
      DC.B   'F',$00,'`',$E0,':',$C0,'_',$00
      DC.B   '_',$00,$08,' ',$15,'@',$04,'`'
      DC.B   '0 ',$1E,$00,'!',$C0,'0 '
      DC.B   '5',$C0,'?',$C0,'G',$E0,'c`' 
      DC.B   '5',$C0,'9',$80,$03,' ',$1A,'@'
      DC.B   '& N',$C0,$15,$E0,'F',$00
      DC.B   'N',$C0,$13,'`3@',$19,$A0
      DC.B   'G@+ V',$E0,$01,$E0
      DC.B   'F',$A0,'F',$00,$1A,'@_',$00 
      DC.B   ';`',$06,'@`',$E0,$0E,'`'
      DC.B   'C',$80,'N',$C0,$13,'`K',$A0 
      DC.B   $1A,$E0,'(',$A0,$0F,$00,'A',$00
      DC.B   $12,' ',$01,$E0,$02,$80,'S',$C0
      DC.B   'Z',$00,$12,' 8@',$19,$00
      DC.B   '*',$80,$0D,' b',$C0,'?',$C0 
      DC.B   '5 <',$00,$06,$E0,'? ' 
      DC.B   'T`^`>',$80,$14,$A0
      DC.B   '.@O`',$0D,$C0,$0B,$E0 
      DC.B   $04,'`9',$80,'L',$E0,'Y`'
      DC.B   $12,$C0,'`@-',$A0,'5',$C0
      DC.B   'H',$80,'b <',$A0,'`',$E0
      DC.B   '`',$E0,$0A,$00,$16,$80,$06,$E0
      DC.B   '2',$00,$1F,$E0,'$@1`' 
      DC.B   '8@B@J`',$00,$A0 
      DC.B   '7',$00,':',$C0,$05,$00,$1C,' '
      DC.B   '(',$A0,'P',$A0,$18,'`G@'
      DC.B   'P',$00,$14,$A0,'5',$C0,$1C,' '
      DC.B   'I',$C0,'-',$A0,'Y`',$03,' ' 
      DC.B   'H',$80,'G@',$1C,$C0,'`@'
      DC.B   '=@',$08,' b',$C0,$10,$E0
      DC.B   'F',$00,'P',$A0,$14,$A0,'L',$E0
      DC.B   $1C,' )',$E0,$10,'@C',$80
      DC.B   $14,$A0,$03,$C0,$05,$00,'U',$A0
      DC.B   '\',$80,$13,'`9',$80,$1A,'@' 
      DC.B   '+',$C0,$0F,$00,$00,$00,'B@' 
      DC.B   '6`=',$E0,$08,$C0,'A',$A0
      DC.B   'V',$E0,'`',$E0,'?',$C0,$17,' '
      DC.B   '/',$80,'Q@',$0F,$00,$0D,$C0 
      DC.B   $06,$E0,':',$C0,'N',$C0,'Z',$A0
      DC.B   $14,$00,'b .',$E0,'7',$00
      DC.B   'K',$00,'c`>',$80,'b',$C0
      DC.B   'b',$C0,$0B,$E0,$17,$C0,$09,'`'
      DC.B   '3',$E0,'!',$C0,'&',$C0,'2',$A0
      DC.B   ':',$C0,'D',$C0,'L',$E0,$01,$E0
      DC.B   '8@<',$00,$06,$E0,$1E,$00
      DC.B   '+ R',$80,$1A,$E0,'H',$80
      DC.B   'Q@',$15,$E0,'8@',$1E,$A0
      DC.B   'L@0 [',$E0,$04,'`'
      DC.B   'J`H',$80,$1F,'@a',$80 
      DC.B   '? ',$0A,$00,$00,$A0,$13,'`' 
      DC.B   'H',$80,'R',$80,$15,$E0,'N ' 
      DC.B   $1D,'`+ ',$11,$80,'F',$00
      DC.B   $17,' ',$05,$A0,$07,$80,'W',$80
      DC.B   '_',$00,$14,$A0,':',$C0,$1B,$80
      DC.B   '-',$00,$10,$E0,$01,'@D',$C0 
      DC.B   '7',$A0,'?',$C0,$0A,$A0,'D ' 
      DC.B   'Y`c`A',$00,$19,$A0
      DC.B   '0',$C0,'S ',$10,'@',$0F,$A0 
      DC.B   $09,'`<',$00,'P',$A0,'[',$E0 
      DC.B   $15,'@',$00,$00,'0 8@' 
      DC.B   'M',$80,$00,$A0,'@`',$00,$A0 
      DC.B   $00,$A0,$0D,$C0,$19,$00,$0B,$E0
      DC.B   '5',$C0,'#',$A0,')@3',$E0
      DC.B   '=@G@O`',$03,' ' 
      DC.B   '9',$80,'=@',$08,$C0,$1F,$E0 
      DC.B   '-',$A0,'T`',$1D,'`I',$C0
      DC.B   'R',$80,$17,' :',$C0,'! '
      DC.B   'N',$C0,'2',$A0,'^`',$05,$A0 
      DC.B   'L@I',$C0,'!',$C0,'b',$C0
      DC.B   'A',$00,$0B,$E0,$02,$80,$15,$E0
      DC.B   'K',$00,'T`',$17,' O`' 
      DC.B   $1E,$A0,',`',$12,$C0,'H',$80 
      DC.B   $19,$A0,$07,$80,$0A,$00,'Y`' 
      DC.B   'a',$80,$15,$E0,'<',$00,$1C,$C0
      DC.B   '.@',$12,$C0,$02,$80,'G@'
      DC.B   '8',$E0,'A',$A0,$0C,$80,'F',$A0
      DC.B   '[',$E0,$01,$E0,'B@',$1C,' ' 
      DC.B   '2',$00,'U',$00,$11,$80,$11,$80
      DC.B   $0B,$E0,'=@R',$80,'] ' 
      DC.B   $16,$80,$01,$E0,'1`9',$80
      DC.B   'P',$00,$01,$E0,'B@',$02,$80 
      DC.B   $02,$80,$0F,$A0,$1A,'@',$0E,'`'
      DC.B   '7',$A0,'%',$80,'+',$C0,'5 ' 
      DC.B   '?',$C0,'I',$C0,'Q',$E0,$04,'`'
      DC.B   ':',$C0,'>',$80,$0A,$A0,'!',$C0
      DC.B   '0 V@',$1F,$E0,'K',$00 
      DC.B   'S',$C0,$18,'`=@#',$A0 
      DC.B   'Q@5 `',$E0,$06,$E0
      DC.B   'N K',$00,'$@',$00,$00 
      DC.B   'B',$E0,$0D,$C0,$04,'`',$18,'`'
      DC.B   'M',$80,'V@',$18,'`P',$A0
      DC.B   $1F,$E0,'-',$A0,$14,$00,'K',$00
      DC.B   $1C,' ',$09,'`',$0C,$80,'[@' 
      DC.B   $00,$00,$17,' =@',$1E,$00
      DC.B   '/',$80,$14,$A0,$03,$C0,'I',$C0
      DC.B   ': C',$80,$0E,'`I '
      DC.B   '^`',$04,'`C',$80,$1E,$A0
      DC.B   '3@V',$E0,$12,$C0,$13,'`'
      DC.B   $0E,'`>',$80,'T`^`'
      DC.B   $17,$C0,$03,$C0,'2',$A0,':',$C0
      DC.B   'R',$80,$03,' D ',$04,'`'
      DC.B   $04,'`',$11,$80,$1B,$80,$10,$E0
      DC.B   '9',$80,$27,'`.@6`'
      DC.B   'B@L@T`',$05,$A0 
      DC.B   '<',$00,'?',$C0,$0C,$80,'#',$A0
      DC.B   '2',$A0,'X "`L@' 
      DC.B   'U',$00,$19,$A0,'?',$C0,'& ' 
      DC.B   'S',$C0,'7',$A0,'c`',$08,' ' 
      DC.B   'P',$00,'L@&',$C0,$01,'@'
      DC.B   'D',$C0,$0F,$A0,$06,'@',$1A,$E0
      DC.B   'P',$00,'X ',$19,$A0,'Q',$E0 
      DC.B   '! .',$E0,$15,'@M',$80 
      DC.B   $1E,$A0,$0B,'@',$0F,$00,'] ' 
      DC.B   $02,$80,$18,'`>',$80,$1F,'@' 
      DC.B   '0',$C0,$16,$80,$05,$00,'L@' 
      DC.B   ';`E`',$10,'@K',$A0
      DC.B   '`',$E0,$06,$E0,'D',$C0,'! ' 
      DC.B   '4',$80,'X',$C0,$14,$00,$15,'@'
      DC.B   $10,$E0,'?',$C0,'V@_',$A0
      DC.B   $19,$00,$05,$A0,'3',$E0,'<',$00
      DC.B   'U',$00,$04,'`F',$00,$06,'@' 
      DC.B   $06,'@',$13,'`',$1C,$C0,$13,'`'
      DC.B   ';`)@0',$C0,'7',$A0
      DC.B   'D',$C0,'N',$C0,'V',$E0,$06,$E0
      DC.B   '=@A',$00,$0E,'`%',$80 
      DC.B   '5 Z',$00,'$',$E0,'M',$80
      DC.B   'V@',$1A,$E0,'B@(',$A0 
      DC.B   'V@: ',$01,$E0,$09,'`' 
      DC.B   'Q',$E0,'M',$80,')@',$02,$80 
      DC.B   'F',$A0,$11,$80,$08,' ',$1D,'`'
      DC.B   'R',$80,'Z',$00,$1A,$E0,'S ' 
      DC.B   '"`0 ',$16,$80,'P',$00 
      DC.B   '! ',$0D,' ',$11,$80,'_',$00 
      DC.B   $05,$00,$19,$A0,'?',$C0,' ',$80
      DC.B   '2',$00,$18,'`',$06,'@N',$C0 
      DC.B   '<',$A0,'G@',$12,' N ' 
      DC.B   'c`',$09,'`F',$00,'#',$A0
      DC.B   '5',$C0,'Z',$A0,$15,'@',$17,' '
      DC.B   $13,'`A',$00,'X `',$E0 
      DC.B   $1A,'@',$07,$80,'5 =@' 
      DC.B   'W',$80,$05,$A0,'G',$E0,$08,' '
      DC.B   $08,' ',$15,'@',$1E,$00,$15,$E0
      DC.B   '=@+ 3@8',$E0
      DC.B   'G@Q@Y`',$08,' ' 
      DC.B   '>',$80,'B@',$10,'@',$27,'`' 
      DC.B   '7',$A0,'[',$E0,$27,'`N',$C0 
      DC.B   'W',$80,$1C,' D',$C0,'+ '
      DC.B   'X',$C0,'<',$A0,$04,'`',$0A,$A0
      DC.B   'S',$C0,'N',$C0,'+',$C0,$03,$C0
      DC.B   'H',$80,$13,'`',$0A,$00,$1F,$E0
      DC.B   'U',$00,'[',$E0,$1C,' T`'
      DC.B   '#',$A0,'1`',$17,$C0,'R',$80 
      DC.B   '#',$A0,$0F,$00,$14,$00,'`',$E0
      DC.B   $07,$80,$1A,$E0,'A',$00,'!',$C0
      DC.B   '3@',$1A,'@',$07,$80,'Q@'
      DC.B   '=',$E0,'I ',$14,$00,'P',$A0 
      DC.B   $01,$E0,$0B,$E0,'G@& ' 
      DC.B   '7',$00,'\',$80,$16,$80,$19,$00
      DC.B   $15,$E0,'B@Z',$00,'b ' 
      DC.B   $1B,$80,$09,'`6`>',$80 
      DC.B   'Z',$00,$06,$E0,'I',$C0,$0A,$00
      DC.B   $0A,$00,$17,' ',$1F,'@',$18,'`'
      DC.B   '? -',$00,'5',$C0,': ' 
      DC.B   'I',$C0,'S',$C0,'[',$E0,$09,'`'
      DC.B   '?',$C0,'C',$80,$12,' )@'
      DC.B   ': ]',$C0,')',$E0,'P',$00
      DC.B   'X',$C0,$1D,'`G@-',$A0 
      DC.B   '[@? ',$06,$E0,$0B,$E0 
      DC.B   'U',$A0,'P',$00,'.@',$05,$00 
      DC.B   'J`',$15,'@',$0B,$E0,'"`'
      DC.B   'W',$80,']',$C0,$1D,'`U',$A0 
      DC.B   '$',$E0,'2',$A0,$19,$00,'U',$00
      DC.B   '& ',$10,$E0,$16,$80,'b',$C0 
      DC.B   $0A,$00,$1C,' B@#',$00 
      DC.B   '4',$80,$1C,' ',$08,$C0,'S',$C0
      DC.B   '? K',$00,$15,$E0,'S ' 
      DC.B   $04,'`',$0E,'`H',$80,'(',$A0 
      DC.B   '8@^`',$17,$C0,$1A,$E0 
      DC.B   $18,'`C',$80,'[',$E0,'c`'
      DC.B   $1C,$C0,$0B,'@7',$A0,'?',$C0 
      DC.B   '\',$80,$08,' K',$A0,$0B,$E0 
      DC.B   $0B,$E0,$19,$00,' ',$80,$1A,$E0
      DC.B   'A',$00,'.',$E0,'8@;`' 
      DC.B   'L@V@^`',$0A,$A0 
      DC.B   'A',$00,'D',$C0,$14,$00,'+ ' 
      DC.B   '<',$A0,'_',$A0,',`Q@' 
      DC.B   'Z',$00,$1E,$A0,'I',$C0,'0 ' 
      DC.B   ']',$C0,'A',$A0,$09,'`',$0D,' '
      DC.B   'W',$80,'Q@0',$C0,$06,'@'
      DC.B   'L@',$17,' ',$0D,$C0,'$',$E0 
      DC.B   'Z',$00,'_',$A0,$1E,$A0,'V',$E0
      DC.B   '& 3',$E0,$1A,'@W',$80 
      DC.B   '(',$A0,$12,$C0,$19,$00,$00,$A0
      DC.B   $0C,$80,$1D,'`C',$80,'$@'
      DC.B   '5',$C0,$1E,$00,$0A,$00,'V@' 
      DC.B   '@`L',$E0,$17,$C0,'U',$A0
      DC.B   $06,$E0,$10,$E0,'I',$C0,'+ ' 
      DC.B   '9',$80,'`@',$19,$00,$1C,$C0 
      DC.B   $1A,$E0,'D',$C0,']',$C0,$00,$A0
      DC.B   $1E,$00,$0D,' 8',$E0,'A',$00 
      DC.B   '_',$00,$09,'`M',$80,$0D,$C0 
      DC.B   $0D,$C0,$1A,$E0,'!',$C0,$1D,'`'
      DC.B   'B',$E0,'0',$C0,':',$C0,'<',$A0
      DC.B   'N',$C0,'X',$C0,'`',$E0,$0B,$E0
      DC.B   'B@F',$00,$15,$E0,'-',$00
      DC.B   '? a',$80,'.',$E0,'R',$80
      DC.B   '[@',$1F,$E0,'L@2',$A0 
      DC.B   '`@D ',$0B,$E0,$0E,'`' 
      DC.B   'Y`R',$80,'3@',$07,$80 
      DC.B   'N ',$19,$00,$0F,$A0,$27,'`' 
      DC.B   '\',$80,'a',$80,$1F,$E0,'X ' 
      DC.B   $27,'`5 ',$1B,$80,'Z',$00
      DC.B   '+ ',$14,$A0,$1B,$80,$02,$80 
      DC.B   $0F,$00,$1E,$A0,'D',$C0,'%',$80
      DC.B   '7',$00,$1F,$E0,$0B,'@X',$C0 
      DC.B   'A',$A0,'N',$C0,$19,$A0,'X ' 
      DC.B   $09,'`',$13,'`K',$00,'-',$A0 
      DC.B   ':',$C0,'b ',$1A,'@',$1E,$A0 
      DC.B   $1D,'`F',$00,'_',$A0,$01,$E0 
      DC.B   $1F,'@',$0F,$00,': B@' 
      DC.B   'a',$80,$0A,$A0,'O`',$0F,$A0 
      DC.B   $0F,$A0,$1C,$C0,'#',$00,$1F,$E0
      DC.B   'D',$C0,'2',$A0,'=@=',$E0
      DC.B   'Q@[@c`',$0D,' ' 
      DC.B   'C',$80,'G@',$17,$C0,'.',$E0 
      DC.B   'A',$A0,'c`1`S',$C0
      DC.B   '\',$80,'! N',$C0,'5 ' 
      DC.B   'b',$C0,'F',$A0,$0E,'`',$0F,$A0
      DC.B   '[@S',$C0,'5',$C0,$08,$C0
      DC.B   'P',$00,$1A,$E0,$11,$80,')',$E0
      DC.B   '_',$00,'c`! Y`' 
      DC.B   '(',$A0,'6`',$1C,$C0,'\',$80 
      DC.B   '-',$A0,$16,$80,$1E,$00,$04,'`'
      DC.B   $11,$80,$1F,$E0,'F',$00,'&',$C0
      DC.B   '8@!',$C0,$0C,$80,'[@' 
      DC.B   'B',$E0,'P',$A0,$1B,$80,'Z',$A0
      DC.B   $0B,$E0,$15,$E0,'L@0 ' 
      DC.B   '<',$00,$00,$00,$1B,$80,' ',$80
      DC.B   $1F,$E0,'G@a',$80,$03,' '
      DC.B   ' ',$80,$10,$E0,';`C',$80
      DC.B   $00,$00,$0B,$E0,'Q@',$11,$80 
      DC.B   $11,$80,$1E,$A0,'$@"`' 
      DC.B   'F',$A0,'4',$80,'?',$C0,'? ' 
      DC.B   'S',$C0,']',$C0,$01,$E0,$0E,'`'
      DC.B   'D',$C0,'H',$80,$19,$A0,'0',$C0
      DC.B   'D ',$01,'@3',$E0,'U',$00
      DC.B   ']',$C0,'"`Q@7',$A0
      DC.B   $01,'@I ',$10,$E0,$10,$E0
      DC.B   '] U',$00,'8@',$0A,$00 
      DC.B   'Q',$E0,$1C,$C0,$13,'`,`'
      DC.B   'a',$80,$01,'@"`Z',$A0 
      DC.B   ')',$E0,'7',$A0,$1E,$00,'_',$00
      DC.B   '0 ',$18,'` ',$80,$06,'@'
      DC.B   $14,$00,'! G@(',$00
      DC.B   '9',$80,'#',$A0,$0D,$C0,']',$C0
      DC.B   'D R',$80,$1D,'`] '
      DC.B   $0E,'`',$18,'`M',$80,'2',$A0 
      DC.B   '=@',$01,$E0,$1C,$C0,'"`'
      DC.B   '"`H',$80,'c`',$04,'`' 
      DC.B   '!',$C0,$12,$C0,'<',$A0,'D',$C0
      DC.B   $02,$80,$0D,' S ',$13,'`'
      DC.B   $13,'` ',$80,'%',$80,'$',$E0 
      DC.B   'H',$80,'6`B@@`' 
      DC.B   'V@`@',$04,'`',$0F,$A0 
      DC.B   'F',$00,'I',$C0,$1B,$80,'2',$A0
      DC.B   'F',$A0,$03,' 6`V@'
      DC.B   '_',$00,'#',$A0,'S',$C0,': ' 
      DC.B   $03,$C0,'K',$A0,$13,'`',$12,' '
      DC.B   '_',$00,'V@:',$C0,$0B,'@'
      DC.B   'S',$C0,$1E,$A0,$15,'@.',$E0 
      DC.B   $00,$00,$03,' #',$A0,'[',$E0 
      DC.B   '+ 8',$E0,$1F,'@a',$80 
      DC.B   '2',$A0,$1A,'@#',$00,$08,' ' 
      DC.B   $16,$80,'"`H',$80,')@' 
      DC.B   ':',$C0,'%',$80,$0F,$00,'`@' 
      DC.B   'E`T`',$1F,'@_',$A0
      DC.B   $10,$E0,$1A,$E0,'N',$C0,'5 ' 
      DC.B   '>',$80,$03,$C0,$1E,$00,'$@' 
      DC.B   '$',$E0,'I',$C0,$01,'@',$05,$A0
      DC.B   '#',$00,$14,$A0,'=',$E0,'F',$00
      DC.B   $05,$00,$0E,'`U',$00,$15,'@' 
      DC.B   $15,'@"`&',$C0,$27,'`' 
      DC.B   'J`8@D',$C0,'A',$A0
      DC.B   'X',$C0,'b',$C0,$06,$E0,$10,$E0
      DC.B   'G@K',$00,$1D,'`4',$80 
      DC.B   'I ',$05,$00,'8',$E0,'W',$80 
      DC.B   '`@$',$E0,'V@<',$A0
      DC.B   $06,'@N ',$15,$E0,$13,'`'
      DC.B   '`',$E0,'W',$80,'=@',$0C,$80 
      DC.B   'U',$A0,' ',$80,$17,' 1`'
      DC.B   $02,$80,$05,$00,'$',$E0,'] ' 
      DC.B   ',`:  ',$80,$00,$00
      DC.B   '5 ',$1C,' %',$80,$0A,$00
      DC.B   $19,$00,'#',$A0,'I',$C0,'*',$80
      DC.B   '<',$00,$27,'`',$10,'@b',$C0 
      DC.B   'F',$A0,'V@! b ' 
      DC.B   $13,'`',$1D,'`P',$00,'7',$A0 
      DC.B   '?',$C0,$05,$A0,$1F,'@& '
      DC.B   $27,'`K',$00,$03,' ',$06,$E0 
      DC.B   '$@',$16,$80,'? G@'
      DC.B   $07,$80,$0F,$A0,'V',$E0,$17,' '
      DC.B   $17,' $@(',$00,')',$E0 
      DC.B   'L@: G@B',$E0
      DC.B   '[@',$01,'@',$09,'`',$12,' ' 
      DC.B   'H',$80,'L@',$1F,'@6`' 
      DC.B   'K',$A0,$06,$E0,';`X',$C0
      DC.B   'a',$80,'& X',$C0,'? ' 
      DC.B   $08,$C0,'P',$A0,$18,'`',$14,$A0
      DC.B   'b',$C0,'X',$C0,'?',$C0,$0D,$C0
      DC.B   'W',$80,'"`',$19,$00,'3',$E0 
      DC.B   $05,$00,$06,$E0,'& ^`' 
      DC.B   '-',$A0,';`!',$C0,$02,$80
      DC.B   '7',$A0,$1E,$00,'(',$00,$0B,$E0
      DC.B   $1B,$80,'$',$E0,'K',$00,'+',$C0
      DC.B   '=@)@',$11,$80,$01,'@' 
      DC.B   'G',$E0,'X #',$00,$00,$A0
      DC.B   $15,$E0,$1F,$E0,'Q@: ' 
      DC.B   'A',$00,$07,$80,' ',$80,'(',$00
      DC.B   ')',$E0,'L@',$05,$00,$08,' ' 
      DC.B   '%',$80,$18,'`@`H',$80 
      DC.B   $0A,$00,$10,$E0,'X',$C0,$19,$00
      DC.B   $19,$00,'& )@,`' 
      DC.B   'N <',$00,'I',$C0,'D ' 
      DC.B   ']',$C0,$03,$C0,$0B,$E0,$13,'`'
      DC.B   'I',$C0,'M',$80,'! 8@' 
      DC.B   'N ',$08,$C0,'=',$E0,'Z',$00 
      DC.B   'b',$C0,$27,'`[@A',$A0 
      DC.B   $0B,'@S ',$1A,$E0,$15,$E0
      DC.B   $00,$A0,'Z',$00,'B@',$0F,$00 
      DC.B   'Y`$@',$1A,$E0,'6`'
      DC.B   $07,$80,$08,$C0,$27,'`_',$A0 
      DC.B   '.',$E0,'<',$A0,'#',$00,$05,$00
      DC.B   ': ',$1F,$E0,'*',$80,$0D,$C0 
      DC.B   $1E,$00,'& L@-',$00
      DC.B   '>',$80,'+ ',$12,$C0,$03,$C0 
      DC.B   'I Z',$00,'$',$E0,$03,' '
      DC.B   $18,'`"`R',$80,'<',$A0 
      DC.B   'B@',$09,'`!',$C0,')',$E0
      DC.B   ',`M',$80,$06,$E0,$09,'`'
      DC.B   '&',$C0,$1A,'@A',$A0,'I',$C0 
      DC.B   $0C,$80,$12,' Z',$A0,$1A,$E0 
      DC.B   $1A,$E0,'(',$00,'*',$80,'.',$E0
      DC.B   'P',$00,'=',$E0,'L@E`' 
      DC.B   '`@',$06,'@',$0E,'`',$14,$A0 
      DC.B   'K',$00,'N',$C0,'#',$00,': ' 
      DC.B   'P',$A0,$0A,$A0,'@`[@' 
      DC.B   $00,$00,'(',$A0,']',$C0,'D ' 
      DC.B   $0D,$C0,'U',$A0,$1D,'`',$17,' '
      DC.B   $02,$80,'[@D',$C0,$10,'@'
      DC.B   '[@& ',$1C,$C0,'8',$E0 
      DC.B   $0A,$00,$0A,$A0,'(',$A0,'`',$E0
      DC.B   '0 =',$E0,'$@',$07,$80 
      DC.B   '<',$A0,'!',$C0,'-',$00,$0F,$A0
      DC.B   ' ',$80,$27,'`M',$80,'.@'
      DC.B   '?',$C0,'-',$00,$14,$00,$06,'@'
      DC.B   'J`[',$E0,'&',$C0,$05,$A0
      DC.B   $1A,$E0,'$',$E0,'S',$C0,'? ' 
      DC.B   'C',$80,$0B,'@#',$00,'+',$C0 
      DC.B   '.',$E0,'N',$C0,$08,$C0,$0A,$A0
      DC.B   '(',$00,$1C,' B',$E0,'K',$00 
      DC.B   $0F,$00,$13,'`\',$80,$1C,$C0 
      DC.B   $1C,$C0,')',$E0,'+',$C0,'1`' 
      DC.B   'Q',$E0,'?',$C0,'N',$C0,'F',$A0
      DC.B   'b',$C0,$08,$C0,$10,$E0,$15,$E0
      DC.B   'L@P',$00,'$',$E0,'<',$00
      DC.B   'S ',$0C,$80,'B',$E0,'\',$80 
      DC.B   $01,'@)',$E0,'`@F',$A0 
      DC.B   $10,'@X ',$1F,$E0,$18,'`'
      DC.B   $04,'`\',$80,'G@',$11,$80
      DC.B   '] (',$00,$1E,$A0,';`' 
      DC.B   $0C,$80,$0C,$80,')',$E0,'b ' 
      DC.B   '1`? %',$80,$0A,$00
      DC.B   '? #',$A0,'/',$80,$11,$80
      DC.B   '#',$00,'(',$A0,'N',$C0,'/',$80
      DC.B   'A',$00,'.',$E0,$15,'@',$08,$C0
      DC.B   'K',$A0,']',$C0,'(',$A0,$08,' '
      DC.B   $1D,'`',$27,'`U',$00,'A',$A0 
      DC.B   'D',$C0,$0D,' $@-',$A0 
      DC.B   '1`P',$00,$0A,$A0,$0B,$E0
      DC.B   ')@',$1E,$00,'D L@'
      DC.B   $11,$80,$14,$A0,'^`',$1E,$A0 
      DC.B   $1E,$A0,'+',$C0,'-',$00,'3',$E0
      DC.B   'S',$C0,'A',$A0,'Q@G',$E0
      DC.B   $01,'@',$0B,'@',$13,'`',$17,' '
      DC.B   'M',$80,'Q@&',$C0,'=',$E0
      DC.B   'U',$A0,$0E,'`E`]',$C0 
      DC.B   $02,$80,'+ b',$C0,'I ' 
      DC.B   $12,$C0,'Z',$A0,'"`',$19,$A0 
      DC.B   $06,'@]',$C0,'I',$C0,$12,$C0 
      DC.B   '_',$00,')',$E0,' ',$80,'=',$E0
      DC.B   $0F,$00,$0E,'`+ c`'
      DC.B   '2',$A0,'@`&',$C0,$0C,$80
      DC.B   'A',$A0,'%',$80,'2',$00,$13,'`'
      DC.B   '%',$80,')',$E0,'P',$00,'0',$C0
      DC.B   'B@0',$C0,$16,$80,$0B,'@'
      DC.B   'L',$E0,'_',$A0,'*',$80,$0A,$A0
      DC.B   $1F,$E0,')',$E0,'V@D ' 
      DC.B   'F',$00,$0F,$00,'%',$80,'/',$80
      DC.B   '3',$E0,'Q@',$0C,$80,$0D,' ' 
      DC.B   '*',$80,$1F,$E0,'E`M',$80
      DC.B   $14,$00,$15,$E0,'`@ ',$80
      DC.B   ' ',$80,'-',$A0,'.@6`' 
      DC.B   'U',$A0,'C',$80,'S',$C0,'I ' 
      DC.B   $03,$C0,$0D,$C0,$15,$E0,$18,'`'
      DC.B   'N',$C0,'R',$80,'(',$A0,'?',$C0
      DC.B   'X ',$10,'@G',$E0,'_',$00
      DC.B   $03,$C0,',`',$01,'@K',$A0
      DC.B   $15,'@] $',$E0,$1A,$E0 
      DC.B   $08,' _',$00,'L@',$14,$00
      DC.B   '`',$E0,'+',$C0,'"`@`' 
      DC.B   $11,$80,$10,'@,`',$00,$A0
      DC.B   '3',$E0,'A',$A0,'(',$00,$0F,$00
      DC.B   'D ',$27,'`4',$80,$15,'@'
      DC.B   '(',$00,'+ Q@2',$00
      DC.B   'C',$80,'2',$A0,$17,$C0,$0D,$C0
      DC.B   'N a',$80,',`',$0D,' ' 
      DC.B   '"`,`W',$80,'F',$A0
      DC.B   'G@',$10,$E0,'&',$C0,'1`'
      DC.B   '6`R',$80,$0E,'`',$0E,'`'
      DC.B   '+',$C0,'!',$C0,'F',$A0,'N',$C0
      DC.B   $16,$80,$17,' b "`'
      DC.B   '"`/',$80,'/',$80,'8',$E0
      DC.B   'W',$80,'E`V@J`' 
      DC.B   $06,'@',$10,'@',$18,'`',$19,$A0
      DC.B   'P',$00,'S',$C0,'*',$80,'A',$A0
      DC.B   'Z',$A0,$12,' J``@'
      DC.B   $05,$00,'-',$A0,$03,$C0,'N ' 
      DC.B   $17,$C0,'_',$A0,$27,'`',$1C,' '
      DC.B   $0A,$00,'`@N',$C0,$15,'@'
      DC.B   'b',$C0,'-',$A0,'$@B',$E0
      DC.B   $14,$00,$12,' -',$A0,$01,$E0 
      DC.B   '5 B',$E0,')@',$11,$80 
      DC.B   'F',$A0,')@7',$00,$17,' '
      DC.B   '*',$80,',`R',$80,'3@' 
      DC.B   'D',$C0,'4',$80,$19,$00,$10,'@'
      DC.B   'O`c`.@',$0F,$A0 
      DC.B   '$',$E0,'.',$E0,'X',$C0,'I ' 
      DC.B   'H',$80,$12,$C0,'(',$00,'3@' 
      DC.B   '8',$E0,'S',$C0,$10,'@',$0F,$A0
      DC.B   '-',$00,'#',$A0,'G',$E0,'P',$00
      DC.B   $19,$00,$18,'`',$00,$00,'$@' 
      DC.B   '$@1`0',$C0,';`' 
      DC.B   'Y`G@X',$C0,'K',$A0
      DC.B   $08,$C0,$12,$C0,$1A,$E0,$1A,$E0
      DC.B   'Q@U',$00,',`C',$80
      DC.B   '] ',$14,$00,'L',$E0,'a',$80 
      DC.B   $06,'@.',$E0,$06,'@P',$A0
      DC.B   $1A,'@b )',$E0,$1D,'`' 
      DC.B   $0B,$E0,'a',$80,'Q@',$16,$80 
      DC.B   $00,$A0,'/',$80,'& E`' 
      DC.B   $16,$80,$14,$00,'.',$E0,$03,' '
      DC.B   '6`D *',$80,$14,$00
      DC.B   'I + 9',$80,$19,$00
      DC.B   '-',$00,'-',$A0,'S',$C0,'4',$80
      DC.B   'F',$00,'6`',$1A,'@',$12,$C0 
      DC.B   'P',$A0,$01,'@0 ',$12,' '
      DC.B   $27,'`1`Z',$00,'K',$A0 
      DC.B   'I',$C0,$14,$A0,')@5 ' 
      DC.B   ';`U',$00,$12,' ',$10,$E0
      DC.B   '.@%',$80,'I Q@' 
      DC.B   $1B,$80,$19,$A0,$01,$E0,'& ' 
      DC.B   '& 3@2',$00,'=',$E0
      DC.B   '[@I [@L',$E0
      DC.B   $0B,'@',$15,'@',$1D,'`',$1C,' '
      DC.B   'R',$80,'V@.@E`' 
      DC.B   '_',$A0,$15,$E0,'O`b',$C0
      DC.B   $07,$80,'0 ',$08,$C0,'S '
      DC.B   $1C,$C0,$00,$A0,',`',$1E,$A0 
      DC.B   $0D,$C0,'b',$C0,'S',$C0,$17,$C0
      DC.B   $02,$80,'1`(',$00,'G',$E0
      DC.B   $19,$00,$15,$E0,'0 ',$04,'`' 
      DC.B   '7',$A0,'E`+',$C0,$16,$80
      DC.B   'K',$A0,'-',$00,'<',$00,$1A,$E0
      DC.B   '/',$80,'.',$E0,'U',$00,'5',$C0
      DC.B   'G@8@',$1B,$80,$15,'@' 
      DC.B   'Q',$E0,$03,' 2',$00,$14,$A0 
      DC.B   ')',$E0,'3',$E0,'[@N ' 
      DC.B   'K',$00,$16,$80,'*',$80,'7',$00
      DC.B   '=',$E0,'V@',$14,$00,$12,' ' 
      DC.B   '/',$80,$27,'`J`R',$80 
      DC.B   $1E,$00,$1A,$E0,$03,$C0,'(',$00
      DC.B   '(',$00,'5 3@@`' 
      DC.B   '] K',$00,']',$C0,'N ' 
      DC.B   $0D,$C0,$17,$C0,$1F,$E0,$1D,'`'
      DC.B   'S',$C0,'W',$80,'0 G@' 
      DC.B   'b ',$17,$C0,'Q',$E0,$00,$00 
      DC.B   $08,$C0,'1`',$0B,'@U',$A0
      DC.B   $1F,'@',$03,' .',$E0,$1F,$E0 
      DC.B   $0F,$A0,$00,$00,'V@',$19,$00 
      DC.B   $04,'`3@)',$E0,'J`'
      DC.B   $1B,$80,$17,$C0,'1`',$05,$A0 
      DC.B   '8',$E0,'F',$A0,'-',$00,$19,$00
      DC.B   'N .',$E0,'>',$80,$1C,$C0
      DC.B   '2',$00,'0 V@7',$00
      DC.B   'H',$80,': ',$1C,$C0,$17,$C0 
      DC.B   'S ',$05,$00,'3',$E0,$17,' ' 
      DC.B   ',`6`\',$80,'P',$A0
      DC.B   'L@',$18,'`+',$C0,'8',$E0
      DC.B   '@`W',$80,$15,$E0,$13,'`'
      DC.B   '0',$C0,')@K',$A0,'S',$C0
      DC.B   ' ',$80,$1C,' ',$05,$A0,')',$E0
      DC.B   ')',$E0,'7',$00,'4',$80,'B',$E0
      DC.B   '_',$00,'L',$E0,'`@O`' 
      DC.B   $10,'@',$1A,'@"`',$1E,$A0
      DC.B   'U',$00,'X',$C0,'2',$00,'I ' 
      DC.B   $00,$A0,$19,$A0,'T`',$01,'@' 
      DC.B   $0A,$00,'2',$A0,$0D,$C0,'X ' 
      DC.B   '!',$C0,$05,$A0,'1`! ' 
      DC.B   $11,$80,$01,'@X',$C0,$1A,'@' 
      DC.B   $06,'@5 +',$C0,'L',$E0 
      DC.B   $1E,$00,$19,$A0,'2',$A0,$06,$E0
      DC.B   ': G',$E0,'.@',$1B,$80 
      DC.B   'P',$A0,'0',$C0,'A',$00,$1E,$A0
      DC.B   '4',$80,'1`W',$80,'8@' 
      DC.B   'I',$C0,'<',$00,$1E,$00,$1A,'@'
      DC.B   'T`',$06,$E0,'5',$C0,$19,$A0 
      DC.B   '.',$E0,'8',$E0,']',$C0,'S ' 
      DC.B   'M',$80,$1A,'@-',$00,':',$C0 
      DC.B   'B',$E0,'X',$C0,$17,$C0,$14,$A0
      DC.B   '2',$00,'+ L',$E0,'U',$00
      DC.B   '#',$00,$1D,'`',$07,$80,'+',$C0
      DC.B   '+',$C0,'8',$E0,'5',$C0,'E`' 
      DC.B   '`',$E0,'N',$C0,'b',$C0,'P',$A0
      DC.B   $12,$C0,$1C,$C0,'$',$E0,$1F,$E0
      DC.B   'V@Z',$00,'3',$E0,'K',$00
      DC.B   $03,' ',$1B,$80,'V',$E0,$02,$80
      DC.B   $0B,'@3',$E0,$10,'@Z',$A0
      DC.B   '$@',$08,' 3',$E0,'"`' 
      DC.B   $13,'`',$02,$80,'[@',$1B,$80 
      DC.B   $08,' 7',$00,'-',$A0,'O`'
      DC.B   ' ',$80,$1B,$80,'3',$E0,$08,' '
      DC.B   ';`I /',$80,$1E,$00
      DC.B   'S 2',$A0,'C',$80,' ',$80
      DC.B   '7',$00,'2',$A0,'X',$C0,'9',$80
      DC.B   'K',$00,'=',$E0,$1F,'@',$1C,$C0
      DC.B   'U',$A0,$08,$C0,'7',$A0,$1C,' '
      DC.B   '1`;`_',$00,'U',$A0
      DC.B   'N',$C0,$1C,' .@<',$A0 
      DC.B   'E`Z',$00,$19,$A0,$15,$E0
      DC.B   '3@-',$00,'N V@' 
      DC.B   '%',$80,$1E,$A0,$09,'`-',$A0 
      DC.B   '-',$A0,':',$C0,'7',$00,'G',$E0
      DC.B   'b',$C0,'P',$A0,$01,'@Q',$E0 
      DC.B   $15,'@',$1F,'@',$27,'`! '
      DC.B   'W',$80,'[@5',$C0,'L',$E0
      DC.B   $05,$A0,$1D,'`Y`',$03,$C0
      DC.B   $0C,$80,'5 ',$12,$C0,'] '
      DC.B   '&',$C0,$0A,$A0,'6`#',$A0
      DC.B   $15,'@',$03,$C0,']',$C0,$1C,$C0
      DC.B   $0A,$00,'8',$E0,'/',$80,'Q',$E0
      DC.B   '#',$00,$1D,'`5 ',$09,'`'
      DC.B   '<',$A0,'J`0',$C0,' ',$80
      DC.B   'U',$A0,'4',$80,'F',$00,'"`' 
      DC.B   '9',$80,'3',$E0,'Z',$00,':',$C0
      DC.B   'L@?',$C0,' ',$80,$1F,'@'
      DC.B   'V',$E0,$0A,$A0,'9',$80,$1E,$A0
      DC.B   '3',$E0,'=',$E0,'`@X ' 
      DC.B   'P',$00,$1E,$00,'/',$80,'>',$80
      DC.B   'G',$E0,'[@',$1B,$80,$17,' ' 
      DC.B   '4',$80,'.',$E0,'O`W',$80
      DC.B   '(',$00,$1F,$E0,$0B,'@/',$80 
      DC.B   '/',$80,'<',$A0,'8@J`' 
      DC.B   $00,$A0,'R',$80,$03,$C0,'S ' 
      DC.B   $17,$C0,'!',$C0,')',$E0,'"`' 
      DC.B   'X',$C0,'\',$80,'7',$A0,'N',$C0
      DC.B   $08,' ',$1F,'@[',$E0,$05,$00 
      DC.B   $0D,$C0,'6`',$15,'@_',$A0
      DC.B   ')@',$0D,' 8',$E0,'$',$E0
      DC.B   $17,' ',$05,$00,'`@',$1E,$00 
      DC.B   $0B,$E0,':',$C0,'1`T`' 
      DC.B   '%',$80,$1F,'@6`',$0A,$A0
      DC.B   '=',$E0,'K',$A0,'2',$00,'#',$00
      DC.B   'X 6`H',$80,'$@' 
      DC.B   '<',$00,'5 [@<',$00
      DC.B   'M',$80,'A',$A0,'!',$C0,'!',$C0
      DC.B   'X ',$0C,$80,';`! '
      DC.B   '6`@`a',$80,'Z',$A0
      DC.B   'Q@',$1F,$E0,'0',$C0,'@`'
      DC.B   'J`\',$80,$1D,'`',$18,'`'
      DC.B   '5',$C0,'0',$C0,'P',$A0,'X',$C0
      DC.B   '*',$80,'! ',$0D,' 1`' 
      DC.B   '1`>',$80,'9',$80,'L',$E0
      DC.B   $02,$80,'T`',$06,'@T`' 
      DC.B   $1A,'@$@,`#',$A0 
      DC.B   'Z',$00,']',$C0,'9',$80,'P',$A0
      DC.B   $0A,$A0,'! ^`',$06,'@' 
      DC.B   $0F,$00,'7',$A0,$17,$C0,'b ' 
      DC.B   '+',$C0,$0F,$A0,';`& ' 
      DC.B   $19,$00,$06,'@b',$C0,$1F,'@' 
      DC.B   $0D,$C0,'<',$A0,'3@V',$E0
      DC.B   '(',$00,'! 7',$A0,$0B,$E0
      DC.B   '? L',$E0,'3@%',$80
      DC.B   'Z',$A0,'8@K',$00,'& ' 
      DC.B   '>',$80,'6`\',$80,'=@' 
      DC.B   'N',$C0,'C',$80,'#',$00,'$@' 
      DC.B   'Y`',$0E,'`=@#',$A0
      DC.B   '8',$E0,'B',$E0,'b',$C0,'] ' 
      DC.B   'R',$80,'!',$C0,'2',$00,'B@' 
      DC.B   'L',$E0,']',$C0,$1F,'@',$19,$A0
      DC.B   '7',$00,'2',$A0,'Q',$E0,'Z',$00
      DC.B   '-',$00,'"`',$0F,$00,'3@'
      DC.B   '3@@`:',$C0,'O`' 
      DC.B   $04,'`V@',$08,$C0,'U',$A0
      DC.B   $1C,$C0,'&',$C0,'.',$E0,'$',$E0
      DC.B   '[@_',$00,';`R',$80
      DC.B   $0D,' #',$00,'`',$E0,$07,$80 
      DC.B   $10,'@8',$E0,$1A,'@',$00,$A0 
      DC.B   '.@',$12,' =',$E0,$27,'`'
      DC.B   $1A,$E0,$07,$80,$01,'@ ',$80 
      DC.B   $0F,$A0,'>',$80,'5 Y`' 
      DC.B   '*',$80,'#',$00,'8',$E0,$0D,' '
      DC.B   '@`N 4',$80,'(',$00
      DC.B   '] : M',$80,'(',$00
      DC.B   'A',$00,'7',$A0,']',$C0,'>',$80
      DC.B   'P',$00,'E`$@&',$C0
      DC.B   'Z',$A0,$10,'@? & '
      DC.B   ';`E`',$00,$00,'_',$A0 
      DC.B   'S',$C0,'#',$A0,'3@D ' 
      DC.B   'O`_',$00,'! ',$1A,$E0 
      DC.B   '8@4',$80,'S [@' 
      DC.B   '/',$80,'#',$A0,$10,$E0,'5 ' 
      DC.B   '5 B@<',$00,'Q',$E0
      DC.B   $06,'@X ',$0B,'@V',$E0 
      DC.B   $1F,'@)@1`& '
      DC.B   '\',$80,'`@=@T`' 
      DC.B   $0F,$A0,'$',$E0,'c`',$08,$C0 
      DC.B   $11,$80,': ',$1C,$C0,$03,' ' 
      DC.B   '0',$C0,$14,$A0,'@`(',$A0
      DC.B   $1C,$C0,$08,$C0,$03,$C0,'!',$C0
      DC.B   $11,$80,'@`7',$00,'[',$E0
      DC.B   '-',$00,'$',$E0,': ',$0E,'`' 
      DC.B   'A',$A0,'O`5',$C0,'*',$80
      DC.B   '_',$A0,'<',$00,'P',$00,')',$E0
      DC.B   'C',$80,'8',$E0,'_',$00,'?',$C0
      DC.B   'Q@G@%',$80,')@' 
      DC.B   '[',$E0,$12,' A',$00,'(',$A0 
      DC.B   '=',$E0,'G',$E0,$01,'@b '
      DC.B   'U',$00,'%',$80,'4',$80,'F',$00
      DC.B   'Q',$E0,'`@#',$00,$1C,' '
      DC.B   '9',$80,'6`T`\',$80
      DC.B   '2',$00,'$',$E0,$12,$C0,'7',$00
      DC.B   '7',$00,'D =@T`' 
      DC.B   $08,' Z',$00,$0D,$C0,'X '
      DC.B   '!',$C0,'+',$C0,'3',$E0,$27,'`'
      DC.B   ']',$C0,'a',$80,'? V@' 
      DC.B   $12,' &',$C0,$01,$E0,$0A,$00 
      DC.B   $12,$C0,';`',$1F,'@',$05,$A0 
      DC.B   '3@',$17,' B',$E0,')',$E0
      DC.B   $1E,$A0,$0A,$00,$06,'@#',$00 
      DC.B   $13,'`B@8',$E0,'^`'
      DC.B   '/',$80,'&',$C0,';`',$0F,$A0 
      DC.B   'B',$E0,'P',$A0,'7',$00,'-',$00
      DC.B   'b =',$E0,'R',$80,'+',$C0
      DC.B   'F',$00,': `@A',$00
      DC.B   'R',$80,'I &',$C0,'+',$C0
      DC.B   '] ',$14,$00,'B',$E0,'+ '
      DC.B   '@`J`',$02,$80,$00,$A0 
      DC.B   'V@',$27,'`5',$C0,'G',$E0
      DC.B   'T`a',$80,'$',$E0,$1D,'`'
      DC.B   ':',$C0,'8@U',$A0,']',$C0
      DC.B   '4',$80,'& ',$14,$A0,'8',$E0 
      DC.B   '8',$E0,'F',$00,'>',$80,'V',$E0
      DC.B   $0A,$00,'[',$E0,$10,'@Y`'
      DC.B   '$@.@6`(',$A0
      DC.B   '_',$00,'b',$C0,'A',$00,'X ' 
      DC.B   $14,$A0,'(',$A0,$04,'`',$0B,'@'
      DC.B   $14,$00,'<',$A0,'!',$C0,$08,' '
      DC.B   '5',$C0,$19,$A0,'E`+ ' 
      DC.B   ' ',$80,$0B,'@',$08,$C0,'$@' 
      DC.B   $15,'@D :',$C0,'`',$E0 
      DC.B   '2',$00,'(',$A0,'<',$A0,$10,$E0
      DC.B   'D Q',$E0,'8@/',$80
      DC.B   $00,$A0,'?',$C0,'U',$00,'-',$A0
      DC.B   'H',$80,';`a',$80,'B@' 
      DC.B   'S',$C0,'K',$00,'(',$00,'.@' 
      DC.B   '^`',$15,$E0,'D',$C0,'-',$A0 
      DC.B   'B',$E0,'L',$E0,$03,$C0,$03,' '
      DC.B   'W',$80,')@7',$00,'I',$C0
      DC.B   'V',$E0,'b',$C0,'&',$C0,$1E,$A0
      DC.B   '<',$00,': V',$E0,'_',$00
      DC.B   '7',$00,$27,'`',$16,$80,':',$C0
      DC.B   ':',$C0,'G',$E0,'?',$C0,'Y`' 
      DC.B   $0B,$E0,']',$C0,$12,$C0,'Z',$A0
      DC.B   '&',$C0,'0',$C0,'8',$E0,')',$E0
      DC.B   '`@',$00,$00,'B',$E0,'Z',$00 
      DC.B   $17,' *',$80,$06,$E0,$0C,$80 
      DC.B   $15,'@=',$E0,'$@',$0A,$A0
      DC.B   '8@',$1C,' G',$E0,',`' 
      DC.B   '"`',$0C,$80,$0B,'@%',$80
      DC.B   $17,' F',$00,'<',$A0,'c`'
      DC.B   '4',$80,'*',$80,'=',$E0,$12,' '
      DC.B   'E`S 9',$80,'2',$00
      DC.B   $03,' A',$A0,'W',$80,'/',$80 
      DC.B   'K',$00,'<',$A0,'b',$C0,'C',$80
      DC.B   'U',$00,'L',$E0,')@0',$C0
      DC.B   '_',$A0,$17,$C0,'F',$A0,'0 ' 
      DC.B   'E`O`',$05,$00,$05,$A0 
      DC.B   'X',$C0,'+ 8@K',$A0
      DC.B   'Y`',$00,$00,'(',$A0,$1F,$E0 
      DC.B   '=@<',$00,'X `@' 
      DC.B   '9',$80,'(',$A0,$18,'`<',$A0 
      DC.B   '<',$A0,'I',$C0,'A',$00,'[',$E0
      DC.B   $0D,$C0,'_',$A0,$15,'@[',$E0 
      DC.B   ')@3@;`+ ' 
      DC.B   'a',$80,$01,'@D',$C0,'[',$E0 
      DC.B   $19,$A0,',`',$09,'`',$0D,$C0 
      DC.B   $16,$80,'? &',$C0,$0D,' '
      DC.B   ':',$C0,$1E,$A0,'J`-',$A0
      DC.B   '$@',$0D,$C0,$0D,$C0,'&',$C0 
      DC.B   $19,$00,'G',$E0,'>',$80,$01,$E0
      DC.B   '7',$00,',`? ',$13,'`' 
      DC.B   'F',$A0,'T`:',$C0,'4',$80
      DC.B   $05,$A0,'C',$80,'Z',$00,'1`' 
      DC.B   'M',$80,'=',$E0,$00,$00,'D',$C0
      DC.B   'V@N',$C0,'*',$80,'3@' 
      DC.B   '`',$E0,$19,$A0,'H',$80,'2',$A0
      DC.B   'G',$E0,'Q',$E0,$06,'@',$08,' '
      DC.B   'Z',$00,'-',$00,'9',$80,'M',$80
      DC.B   '[',$E0,$01,'@*',$80,'! '
      DC.B   '>',$80,'=',$E0,'Y`a',$80
      DC.B   '<',$00,')',$E0,$1A,'@>',$80 
      DC.B   '>',$80,'K',$A0,'B@^`' 
      DC.B   $0F,$A0,'a',$80,$17,$C0,'] ' 
      DC.B   '+',$C0,'5',$C0,'=',$E0,',`' 
      DC.B   'b',$C0,$02,$80,'F',$A0,']',$C0
      DC.B   $1C,' .@',$0B,$E0,$0F,$00
      DC.B   $17,$C0,'@`)@',$0F,$A0 
      DC.B   '=@! L',$E0,'.',$E0
      DC.B   '& ',$0F,$00,$10,'@(',$00
      DC.B   $1A,$E0,'I',$C0,'@`',$04,'`' 
      DC.B   '9',$80,'.@@`',$14,$A0 
      DC.B   'G',$E0,'U',$A0,'<',$00,'7',$00
      DC.B   $08,' E`\',$80,'3@'
      DC.B   'P',$00,'? ',$01,'@F',$00
      DC.B   'W',$80,'P',$A0,'+',$C0,'5',$C0
      DC.B   'b ',$1B,$80,'J`5 '
      DC.B   'J`T`',$07,$80,$0A,$A0 
      DC.B   '[@.',$E0,':',$C0,'O`' 
      DC.B   '^`',$02,$80,',`"`'
      DC.B   '?',$C0,'?',$C0,'Z',$A0,'b',$C0
      DC.B   '>',$80,'+ ',$1C,' @`' 
      DC.B   '@`M',$80,'C',$80,'`',$E0
      DC.B   $11,$80,'c`',$1A,'@^`' 
      DC.B   '.@8@@`-',$A0
      DC.B   $00,$00,$03,$C0,'H',$80,'_',$A0
      DC.B   $1E,$A0,'0 ',$0E,'`',$10,'@' 
      DC.B   $19,$00,'A',$A0,'+',$C0,$12,' '
      DC.B   '?',$C0,'#',$A0,'O`0 ' 
      DC.B   '(',$00,$10,'@',$12,$C0,')@' 
      DC.B   $1C,$C0,'K',$A0,'B@',$06,$E0 
      DC.B   '<',$00,'0 A',$A0,$15,$E0
      DC.B   'I V',$E0,'=@9',$80
      DC.B   $0A,$A0,'G@_',$00,'5 ' 
      DC.B   'R',$80,'@`',$02,$80,'G@'
      DC.B   'X',$C0,'R',$80,'-',$00,'8@' 
      DC.B   'c`',$1D,'`L@7',$A0
      DC.B   'L',$E0,'V',$E0,$08,$C0,$0D,' '
      DC.B   '\',$80,'0',$C0,'<',$00,'Q@' 
      DC.B   '`',$E0,$03,$C0,'.@#',$A0
      DC.B   'A',$00,'A',$A0,'[',$E0,$00,$00
      DC.B   'A',$00,',`',$1E,$00,'B@'
      DC.B   'B@O`D',$C0,'c`' 
      DC.B   $13,'`',$01,'@',$1C,$C0,'_',$A0
      DC.B   '0',$C0,':',$C0,'B',$E0,'.',$E0
      DC.B   $01,'@',$05,$00,'J`a',$80
      DC.B   '! 2',$00,$10,$E0,$11,$80
      DC.B   $1A,'@B',$E0,'.@',$14,$A0
      DC.B   'B@& Q',$E0,'1`' 
      DC.B   ')',$E0,$11,$80,$15,'@*',$80 
      DC.B   $1E,$A0,'M',$80,'D ',$09,'`' 
      DC.B   '>',$80,'2',$00,'B',$E0,$17,' '
      DC.B   'J`X >',$80,'<',$00
      DC.B   $0D,' I a',$80,'7',$00 
      DC.B   'U',$00,'A',$A0,$03,$C0,'H',$80
      DC.B   'Z',$00,'T`.@:',$C0
      DC.B   $00,$A0,$1F,'@N : '
      DC.B   'O`Y`',$0A,$00,$0F,$A0 
      DC.B   ']',$C0,'2',$A0,'=@S ' 
      DC.B   'c`',$05,$00,'0 $',$E0 
      DC.B   'B@C',$80,'] ',$01,'@' 
      DC.B   'C',$80,'-',$A0,$1F,$E0,'D ' 
      DC.B   'D Q@F',$00,$01,$E0
      DC.B   $15,'@',$03,' ',$1F,'@`',$E0 
      DC.B   '3@=@E`0 ' 
      DC.B   $02,$80,$06,'@L@c`'
      DC.B   '#',$A0,'3',$E0,$13,'`',$12,$C0
      DC.B   $1B,$80,'D 0',$C0,$17,' '
      DC.B   'D',$C0,'(',$A0,'T`2',$A0
      DC.B   '+',$C0,$12,$C0,$17,$C0,'+',$C0
      DC.B   ' ',$80,'O`F',$00,$0B,$E0
      DC.B   'A',$00,'3',$E0,'D ',$18,'`' 
      DC.B   'K',$A0,'Y`?',$C0,'>',$80
      DC.B   $0F,$A0,'K',$00,$00,$00,'8',$E0
      DC.B   'W',$80,'B',$E0,$05,$00,'I',$C0
      DC.B   '[@V@/',$80,'=@' 
      DC.B   $01,$E0,'! P',$00,'<',$A0
      DC.B   'Q',$E0,'[',$E0,$0B,'@',$12,' '
      DC.B   '_',$00,'4',$80,'>',$80,'U',$00
      DC.B   $01,$E0,$06,'@2',$00,'& '
      DC.B   'C',$80,'E`^`',$02,$80 
      DC.B   'F',$00,'.',$E0,'!',$C0,'F',$00
      DC.B   'F',$00,'S G@',$04,'`' 
      DC.B   $17,' ',$05,$00,'!',$C0,'b ' 
      DC.B   '5',$C0,'?',$C0,'G',$E0,'1`' 
      DC.B   $03,$C0,$07,$80,'N ',$01,'@' 
      DC.B   '& 5',$C0,$15,$E0,$14,$00
      DC.B   $1C,$C0,'E`3@',$19,$A0 
      DC.B   'G@+ V',$E0,'3',$E0
      DC.B   '-',$A0,$14,$00,$1A,'@-',$00 
      DC.B   '"`Q@G',$E0,$0E,'`'
      DC.B   'C',$80,'5',$C0,'E`',$19,$A0 
      DC.B   'L',$E0,'Z',$A0,'A',$00,'A',$00
      DC.B   $12,' L',$E0,$02,$80,':',$C0 
      DC.B   'Z',$00,'D ',$06,'@K',$00
      DC.B   '\',$80,'X 0',$C0,'?',$C0
      DC.B   $03,' #',$00,'Q',$E0,'? '
      DC.B   'T`^`',$0C,$80,$14,$A0 
      DC.B   '`@6`?',$C0,'V',$E0
      DC.B   $04,'`',$07,$80,'3',$E0,$27,'`'
      DC.B   'D',$C0,'G@_',$A0,$03,$C0
      DC.B   'H',$80,'0 #',$A0,'G',$E0
      DC.B   'G',$E0,'U',$00,'H',$80,$06,$E0
      DC.B   $19,$00,$06,$E0,'$@c`' 
      DC.B   '8@B@J`2',$A0
      DC.B   $05,$00,$08,$C0,'P',$00,$03,' '
      DC.B   '(',$A0,'7',$A0,$18,'`',$15,'@'
      DC.B   $1E,$00,'F',$A0,'5',$C0,$1C,' '
      DC.B   'I',$C0,'-',$A0,'Y`5 ' 
      DC.B   '/',$80,$15,'@',$1C,$C0,'.@' 
      DC.B   '$@S I',$C0,$10,$E0
      DC.B   'F',$00,'7',$A0,'F',$A0,$1A,$E0
      DC.B   'N [',$E0,'B@C',$80
      DC.B   $14,$A0,'N',$C0,$05,$00,'<',$A0
      DC.B   '\',$80,'E`',$07,$80,'L@'
      DC.B   ']',$C0,'Z',$00,'2',$00,'B@' 
      DC.B   $04,'`$',$E0,'S',$C0,'A',$A0 
      DC.B   'V',$E0,'`',$E0,$0D,$C0,$17,' '
      DC.B   'a',$80,'8@A',$00,'X',$C0
      DC.B   $06,$E0,$08,$C0,'5',$C0,'(',$A0
      DC.B   'F',$00,'I `',$E0,$05,$00
      DC.B   'K',$00,'1`%',$80,'I',$C0
      DC.B   'I',$C0,'V',$E0,'I',$C0,$09,'`'
      DC.B   $1A,$E0,$08,$C0,'&',$C0,$00,$A0
      DC.B   ':',$C0,'D',$C0,'L',$E0,'3',$E0
      DC.B   $06,'@',$0A,$00,'Q',$E0,$05,$00
      DC.B   '+ 9',$80,$1A,$E0,$16,$80
      DC.B   $1F,'@G',$E0,'8@',$1E,$A0
      DC.B   'L@0 [',$E0,'6`' 
      DC.B   '1`',$16,$80,$1F,'@/',$80
      DC.B   '& U',$00,'K',$A0,$13,'`'
      DC.B   'H',$80,'9',$80,'G',$E0,$1C,' '
      DC.B   'O`] C',$80,'F',$00
      DC.B   $17,' P',$A0,$07,$80,'>',$80 
      DC.B   '_',$00,'F',$A0,$08,$C0,'M',$80
      DC.B   '_',$00,'[',$E0,'3@D',$C0
      DC.B   $05,$A0,'&',$C0,'U',$A0,'D ' 
      DC.B   'Y`c`',$0F,$00,$19,$A0 
      DC.B   'b',$C0,': B@Z',$A0
      DC.B   $09,'`',$0A,$00,'7',$A0,')',$E0
      DC.B   'G@K',$00,'b ',$06,'@' 
      DC.B   'M',$80,'2',$A0,$27,'`K',$A0 
      DC.B   'K',$A0,'X',$C0,'K',$00,$0B,$E0
      DC.B   $1C,$C0,$0A,$A0,')@',$01,$E0 
      DC.B   '=@G@O`5 ' 
      DC.B   $07,$80,$0B,'@S',$C0,$06,$E0 
      DC.B   '-',$A0,';`',$1D,'`',$17,$C0 
      DC.B   ' ',$80,'I :',$C0,'! ' 
      DC.B   'N',$C0,'2',$A0,'^`7',$A0
      DC.B   '3@',$17,$C0,'!',$C0,'0',$C0 
      DC.B   '(',$00,'V',$E0,'M',$80,$15,$E0
      DC.B   'K',$00,';`I ',$1D,'`' 
      DC.B   'P',$A0,'^`D',$C0,'H',$80
      DC.B   $19,$A0,'R',$80,$0A,$00,'@`' 
      DC.B   'a',$80,'G',$E0,$0A,$00,'N',$C0
      DC.B   '`@]',$C0,'4',$80,'G@' 
      DC.B   $06,$E0,'(',$A0,'W',$80,'F',$A0
      DC.B   '[',$E0,$01,$E0,$10,'@',$1C,' '
      DC.B   $00,$00,'<',$00,'C',$80,'\',$80
      DC.B   $0B,$E0,$0B,'@9',$80,'+ '
      DC.B   'H',$80,'L',$E0,'c`',$07,$80 
      DC.B   'P',$00,'3',$E0,')@M',$80
      DC.B   'M',$80,'Z',$A0,'L@',$0E,'`' 
      DC.B   $1E,$A0,$0C,$80,'+',$C0,$03,' '
      DC.B   '?',$C0,'I',$C0,'Q',$E0,'6`' 
      DC.B   $08,$C0,$0C,$80,'U',$A0,$08,$C0
      DC.B   '0 =@',$1F,$E0,$19,$00 
      DC.B   '!',$C0,'J`=@#',$A0
      DC.B   'Q@5 `',$E0,'8',$E0
      DC.B   '5 ',$19,$00,'$@2',$00 
      DC.B   ')',$E0,'X',$C0,'O`',$18,'`' 
      DC.B   'M',$80,'=@J`',$1E,$A0 
      DC.B   'Q',$E0,'_',$A0,'F',$00,'K',$00
      DC.B   $1C,' T`',$0C,$80,'B@' 
      DC.B   $00,$00,'I ',$0B,'@P',$00
      DC.B   'a',$80,'_',$A0,'5',$C0,'I',$C0
      DC.B   $08,' *',$80,'Y`I '
      DC.B   '^`',$04,'`',$11,$80,$1E,$A0 
      DC.B   $01,'@=',$E0,'D',$C0,'^`'
      DC.B   $0E,'`',$0C,$80,';`,`' 
      DC.B   'I',$C0,'N',$C0,$00,$A0,$08,$C0
      DC.B   'R',$80,'5 + O`' 
      DC.B   'O`\',$80,'M',$80,$10,$E0
      DC.B   ' ',$80,$0E,'`.@',$04,'`'
      DC.B   'B@L@T`7',$A0
      DC.B   $0A,$00,$0D,$C0,'W',$80,$0A,$A0
      DC.B   '2',$A0,'? "`',$1A,'@' 
      DC.B   '#',$00,'K',$A0,'?',$C0,'& ' 
      DC.B   'S',$C0,'7',$A0,'c`: ' 
      DC.B   '7',$00,$1A,'@&',$C0,'3@'
      DC.B   '+',$C0,'Z',$A0,'Q@',$1A,$E0 
      DC.B   'P',$00,'? K',$A0,$1F,$E0
      DC.B   'S `',$E0,'G@M',$80
      DC.B   $1E,$A0,'V@',$0F,$00,'D '
      DC.B   $02,$80,'J`',$0C,$80,'Q@'
      DC.B   'b',$C0,'a',$80,'7',$00,'L@' 
      DC.B   $09,'`,`[@K',$A0 
      DC.B   '`',$E0,$06,$E0,$12,$C0,'! ' 
      DC.B   $02,$80,'?',$C0,'F',$00,'`@' 
      DC.B   $10,$E0,$0D,$C0,'=@-',$A0
      DC.B   'K',$00,'P',$A0,$01,$E0,$0A,$00
      DC.B   'U',$00,'6`-',$00,'Q@' 
      DC.B   'Q@^`N',$C0,$13,'`'
      DC.B   '"`',$10,'@0',$C0,$05,$A0
      DC.B   'D',$C0,'N',$C0,'V',$E0,'8',$E0
      DC.B   $0B,'@',$0F,$00,'Y`',$0C,$80 
      DC.B   '5 A',$00,'$',$E0,$1B,$80
      DC.B   '$@L',$E0,'B@(',$A0
      DC.B   'V@: ',$01,$E0,';`'
      DC.B   '8',$E0,$1B,$80,')@4',$80
      DC.B   '-',$A0,'\',$80,'S ',$1D,'`' 
      DC.B   'R',$80,'A',$00,'L',$E0,'! ' 
      DC.B   'T`b H',$80,'P',$00
      DC.B   '! X ',$11,$80,'F',$00 
      DC.B   $05,$00,'K',$A0,$0D,$C0,'R',$80
      DC.B   $00,$00,'c`8@N',$C0
      DC.B   $0A,$A0,'.@] N ' 
      DC.B   'c`',$09,'`',$14,$00,'#',$A0 
      DC.B   $03,$C0,'A',$A0,'G@b ' 
      DC.B   $13,'`',$0F,$00,'? .',$E0
      DC.B   'L@R',$80,$03,' ',$0B,'@'
      DC.B   'W',$80,'7',$A0,'.',$E0,'S ' 
      DC.B   'S `@P',$00,$15,$E0
      DC.B   '$@',$12,' 3@',$06,$E0 
      DC.B   'G@Q@Y`: ' 
      DC.B   $0C,$80,$10,'@[@',$0E,'`'
      DC.B   '7',$A0,'B',$E0,$27,'`',$1C,$C0
      DC.B   '%',$80,'N D',$C0,'+ ' 
      DC.B   'X',$C0,'<',$A0,$04,'`<',$A0 
      DC.B   ':',$C0,$1C,$C0,'+',$C0,'5',$C0
      DC.B   '/',$80,'^`U',$00,$1F,$E0
      DC.B   'U',$00,'B',$E0,'N "`' 
      DC.B   'U',$A0,'c`I',$C0,'R',$80
      DC.B   '#',$A0,'Z',$00,$14,$00,'G',$E0
      DC.B   $07,$80,'L',$E0,$0F,$00,'S',$C0
      DC.B   $01,'@',$01,'@9',$80,'Q@'
      DC.B   $0B,$E0,'0 _',$00,'P',$A0
      DC.B   $01,$E0,$0B,$E0,$15,'@& '
      DC.B   $05,$00,'C',$80,'H',$80,$00,$00
      DC.B   $15,$E0,$10,'@A',$00,'0 '
      DC.B   'M',$80,'T`',$04,'`',$0C,$80 
      DC.B   'Z',$00,'8',$E0,'0',$C0,'U',$00
      DC.B   'U',$00,'b Q@',$18,'`' 
      DC.B   '& ',$14,$00,'5',$C0,$08,' ' 
      DC.B   'I',$C0,'S',$C0,'[',$E0,';`' 
      DC.B   $0D,$C0,$11,$80,'] ',$10,'@' 
      DC.B   ': D',$C0,')',$E0,$1E,$00
      DC.B   '&',$C0,'O`G@-',$A0
      DC.B   '[@? ',$06,$E0,'=',$E0 
      DC.B   '<',$A0,$1E,$00,'.@7',$00
      DC.B   '1``@V',$E0,'"`' 
      DC.B   'W',$80,'D',$C0,'O`#',$A0
      DC.B   'V',$E0,$00,$A0,'K',$00,'U',$00
      DC.B   '& [',$E0,$16,$80,'I',$C0
      DC.B   $0A,$00,'N ',$10,'@U',$00
      DC.B   $02,$80,$03,' :',$C0,'S',$C0 
      DC.B   $0D,' 2',$00,'`',$E0,'S '
      DC.B   $04,'`',$0E,'`',$16,$80,'(',$A0
      DC.B   $06,'@E`I',$C0,$01,$E0 
      DC.B   $18,'`',$11,$80,'B',$E0,'1`' 
      DC.B   'N',$C0,'V@',$05,$A0,$0D,$C0 
      DC.B   '\',$80,': 2',$A0,'V',$E0
      DC.B   'V',$E0,$00,$00,'R',$80,$1A,$E0
      DC.B   '(',$00,$15,$E0,'8@',$09,'`' 
      DC.B   'L@V@^`<',$A0
      DC.B   $0F,$00,$12,$C0,'_',$00,$12,' '
      DC.B   '<',$A0,'F',$A0,',`',$1F,'@' 
      DC.B   '(',$00,'P',$A0,'I',$C0,'0 ' 
      DC.B   ']',$C0,'A',$A0,$09,'`? '
      DC.B   '>',$80,$1F,'@0',$C0,'8@'
      DC.B   '3@b X',$C0,'$',$E0
      DC.B   'Z',$00,'F',$A0,'P',$A0,'$',$E0
      DC.B   'X ',$01,$E0,'L@W',$80 
      DC.B   '(',$A0,']',$C0,$19,$00,'K',$A0
      DC.B   $0C,$80,'O`',$11,$80,'V@'
      DC.B   $03,$C0,$05,$00,'<',$00,'V@' 
      DC.B   $0E,'`3',$E0,'b',$C0,'U',$A0 
      DC.B   $06,$E0,$10,$E0,$17,$C0,'+ ' 
      DC.B   $07,$80,'G@K',$00,$03,$C0
      DC.B   $1A,$E0,$12,$C0,'D',$C0,'2',$A0
      DC.B   'P',$00,'X ',$06,$E0,$0F,$00 
      DC.B   '_',$00,';`4',$80,'X',$C0
      DC.B   'X',$C0,$01,$E0,'S',$C0,$1D,'`'
      DC.B   ')',$E0,$17,$C0,':',$C0,$0A,$A0
      DC.B   'N',$C0,'X',$C0,'`',$E0,'=',$E0
      DC.B   $10,'@',$14,$00,'`',$E0,$14,$00
      DC.B   '? H',$80,'.',$E0,' ',$80
      DC.B   ')@Q',$E0,'L@2',$A0
      DC.B   '`@D ',$0B,$E0,'@`'
      DC.B   '@` ',$80,'3@9',$80
      DC.B   '5 ',$00,$00,'Z',$A0,$27,'`' 
      DC.B   '\',$80,'H',$80,'Q',$E0,'& ' 
      DC.B   'Y`',$03,' M',$80,'Z',$00
      DC.B   '+ _',$A0,$1B,$80,'M',$80
      DC.B   $0F,$00,'P',$A0,$12,$C0,'W',$80
      DC.B   $05,$00,$06,$E0,'=@X',$C0
      DC.B   $0F,$A0,'5',$C0,$00,$A0,'X ' 
      DC.B   $09,'`',$13,'`',$19,$00,'-',$A0
      DC.B   $08,$C0,'I L@',$05,$A0 
      DC.B   $1D,'`',$14,$00,'F',$A0,'3',$E0
      DC.B   'Q@Z',$00,$08,' ',$10,'@'
      DC.B   'a',$80,'<',$A0,'6`Z',$A0
      DC.B   'Z',$A0,$03,$C0,'U',$00,$1F,$E0
      DC.B   '+',$C0,$19,$A0,'=@',$0B,$E0 
      DC.B   'Q@[@c`? ' 
      DC.B   $11,$80,$15,'@b',$C0,$15,$E0 
      DC.B   'A',$A0,'J`1`!',$C0
      DC.B   '*',$80,'S N',$C0,'5 ' 
      DC.B   'b',$C0,'F',$A0,$0E,'`A',$A0 
      DC.B   'B@!',$C0,'5',$C0,':',$C0
      DC.B   '7',$00,$01,$E0,'\',$80,')',$E0
      DC.B   '_',$00,'J`S ',$27,'`' 
      DC.B   'Z',$A0,$04,'`N',$C0,'\',$80 
      DC.B   '-',$A0,'a',$80,$1E,$00,'O`' 
      DC.B   $11,$80,'Q',$E0,$14,$00,'X',$C0
      DC.B   $06,'@',$08,$C0,'>',$80,'[@' 
      DC.B   $10,$E0,'7',$A0,$02,$80,'Z',$A0
      DC.B   $0B,$E0,$15,$E0,$1A,'@0 '
      DC.B   $0A,$00,'K',$00,'M',$80,$07,$80
      DC.B   $1F,$E0,$15,'@H',$80,'5 '
      DC.B   'R',$80,'[',$E0,$09,'`',$11,$80
      DC.B   $00,$00,'=',$E0,'8@\',$80
      DC.B   '\',$80,$05,$A0,'V@"`' 
      DC.B   '-',$A0,$1B,$80,'?',$C0,$0D,' '
      DC.B   'S',$C0,']',$C0,$01,$E0,'@`' 
      DC.B   $12,$C0,$16,$80,$00,$A0,$17,$C0
      DC.B   'D L@3',$E0,'#',$00
      DC.B   '+',$C0,'T`Q@7',$A0
      DC.B   $01,'@I ',$10,$E0,'B',$E0
      DC.B   'D #',$00,'8@<',$00
      DC.B   '8',$E0,$03,$C0,'^`,`' 
      DC.B   'a',$80,'L@T`(',$A0
      DC.B   '[',$E0,$05,$A0,'P',$00,'_',$00
      DC.B   '0 c` ',$80,'Q@' 
      DC.B   $14,$00,'S ',$15,'@Z',$00
      DC.B   $07,$80,$0A,$A0,'?',$C0,']',$C0
      DC.B   $12,' 9',$80,$04,'`] ' 
      DC.B   $0E,'`',$18,'`',$1B,$80,'2',$A0
      DC.B   $0B,'@L',$E0,'N',$C0,$09,'`' 
      DC.B   '"`',$16,$80,'J`6`'
      DC.B   'S',$C0,']',$C0,$0A,$A0,$12,$C0
      DC.B   $02,$80,'? : ^`' 
      DC.B   '^`',$07,$80,'W',$80,'$',$E0 
      DC.B   '/',$80,$1D,'`B@',$0E,'`'
      DC.B   'V@`@',$04,'`A',$A0
      DC.B   $14,$00,$17,$C0,$02,$80,$19,$A0
      DC.B   'F',$A0,'N 6`$@' 
      DC.B   '-',$00,'U',$A0,'S',$C0,': ' 
      DC.B   $03,$C0,'K',$A0,$13,'`D '
      DC.B   'F',$00,'$@:',$C0,'=@' 
      DC.B   ':',$C0,$05,$A0,'`@.',$E0
      DC.B   $00,$00,'N U',$A0,')',$E0
      DC.B   '] ',$06,$E0,'Q@a',$80 
      DC.B   '2',$A0,$01,'@#',$00,'S '
      DC.B   $16,$80,'T`',$16,$80,'[@'
      DC.B   $08,$C0,$0C,$80,'A',$00,'`@' 
      DC.B   $13,'`;`',$06,'@_',$A0 
      DC.B   $10,$E0,$1A,$E0,$1C,$C0,'5 ' 
      DC.B   $0C,$80,'N',$C0,'P',$00,$0B,'@'
      DC.B   '$',$E0,$17,$C0,'L@7',$A0
      DC.B   'U',$00,'_',$A0,$0B,$E0,$14,$00
      DC.B   $05,$00,'@`<',$00,'`@' 
      DC.B   '`@',$09,'`X',$C0,$27,'`'
      DC.B   '1`',$1F,'@D',$C0,$0F,$A0
      DC.B   'X',$C0,'b',$C0,$06,$E0,'B',$E0
      DC.B   $15,'@',$19,$00,$04,'`',$1B,$80
      DC.B   'I P',$00,'8',$E0,'%',$80
      DC.B   '.@V',$E0,'V@<',$A0
      DC.B   $06,'@N ',$15,$E0,'E`' 
      DC.B   'G',$E0,'%',$80,'=@>',$80
      DC.B   '<',$A0,$07,$80,'b 1`' 
      DC.B   $02,$80,'P',$00,'V',$E0,'+ ' 
      DC.B   '^`',$08,' R',$80,$00,$00
      DC.B   '5 ',$03,' %',$80,'U',$00
      DC.B   $19,$00,'U',$A0,$17,$C0,'\',$80
      DC.B   $0A,$00,$0E,'`B@b',$C0 
      DC.B   $14,$A0,'=@',$08,' b ' 
      DC.B   $13,'`',$1D,'`',$1E,$00,'7',$A0
      DC.B   $0D,$C0,'P',$A0,'Q@',$0D,' ' 
      DC.B   $27,'`',$19,$00,'N 8',$E0
      DC.B   'V@a',$80,$0D,' ',$15,'@'
      DC.B   $07,$80,'A',$A0,'=',$E0,'b ' 
      DC.B   'b ',$0B,'@Z',$00,')',$E0
      DC.B   '3@! G@',$10,$E0 
      DC.B   '[@',$01,'@',$09,'`D ' 
      DC.B   $16,$80,$1A,'@',$06,'@',$1D,'`'
      DC.B   'K',$A0,'Q',$E0,';`&',$C0
      DC.B   '/',$80,'X X',$C0,'? ' 
      DC.B   $08,$C0,'P',$A0,$18,'`F',$A0 
      DC.B   'I',$C0,'&',$C0,'?',$C0,'?',$C0
      DC.B   '>',$80,$09,'`',$00,$00,'3',$E0
      DC.B   $05,$00,'Q',$E0,'X ,`' 
      DC.B   '_',$A0,$09,'`S',$C0,$02,$80 
      DC.B   '7',$A0,$05,$00,'(',$00,'V',$E0
      DC.B   $1B,$80,'V',$E0,$19,$00,']',$C0
      DC.B   $0B,'@',$10,'@C',$80,$01,'@' 
      DC.B   $15,$E0,'? ',$0A,$00,$00,$A0 
      DC.B   $15,$E0,$1F,$E0,$1F,'@: '
      DC.B   $0F,$00,'R',$80,'R',$80,$0F,$00
      DC.B   ')',$E0,$1A,'@P',$00,': '
      DC.B   'W',$80,'c`',$0E,'`',$16,$80 
      DC.B   $0A,$00,'B',$E0,'?',$C0,$00,$00
      DC.B   $00,$00,$0D,' [@,`'
      DC.B   '5 #',$00,'I',$C0,$12,' '
      DC.B   ']',$C0,$03,$C0,$0B,$E0,'E`' 
      DC.B   $17,$C0,$1B,$80,$08,' ',$1F,'@'
      DC.B   'N S',$C0,'=',$E0,'(',$00
      DC.B   '0',$C0,'Y`[@A',$A0
      DC.B   $0B,'@S ',$1A,$E0,'G',$E0
      DC.B   'K',$A0,'(',$00,'B@A',$00
      DC.B   '@`',$0B,'@',$01,$E0,'6`'
      DC.B   $07,$80,'S',$C0,'Y`-',$A0
      DC.B   '`',$E0,$0A,$A0,'U',$00,$05,$00
      DC.B   ': ',$06,$E0,'*',$80,'X',$C0 
      DC.B   $1E,$00,'X ',$1A,'@_',$00
      DC.B   $0C,$80,$12,' D',$C0,$03,$C0 
      DC.B   $17,' A',$00,$0B,$E0,$03,' ' 
      DC.B   $18,'`"` ',$80,'<',$A0 
      DC.B   $10,'@T`S',$C0,$10,$E0 
      DC.B   ',`',$1B,$80,'Q',$E0,';`'
      DC.B   'X',$C0,$01,'@',$0F,$A0,$17,$C0
      DC.B   $0C,$80,'D A',$A0,$01,$E0
      DC.B   $01,$E0,$0F,$00,'\',$80,'.',$E0
      DC.B   '7',$00,'$',$E0,'L@',$13,'`' 
      DC.B   '`@',$06,'@',$0E,'`F',$A0
      DC.B   $19,$00,$1C,$C0,$0A,$00,'! ' 
      DC.B   'P',$A0,'U',$A0,'@`)@' 
      DC.B   '2',$00,'Z',$A0,']',$C0,'D ' 
      DC.B   $0D,$C0,'U',$A0,$1D,'`I '
      DC.B   'M',$80,')@D',$C0,'B@' 
      DC.B   'B@',$0D,' ',$03,$C0,'8',$E0 
      DC.B   $0A,$00,'U',$A0,'Z',$A0,'.',$E0
      DC.B   'b ',$0B,$E0,'V@',$07,$80
      DC.B   '<',$A0,$08,$C0,'-',$00,'Z',$A0
      DC.B   ' ',$80,'Y`',$1B,$80,'`@'
      DC.B   $0D,$C0,$14,$00,'F',$00,$06,'@'
      DC.B   $18,'`B',$E0,$0D,$C0,$05,$A0 
      DC.B   $1A,$E0,'$',$E0,'!',$C0,'? ' 
      DC.B   $11,$80,'V@U',$00,$12,$C0
      DC.B   '.',$E0,$1C,$C0,'S',$C0,'<',$A0
      DC.B   'Z',$00,$03,' ',$10,$E0,$19,$00
      DC.B   $0F,$00,'E`C',$80,$03,$C0
      DC.B   $03,$C0,$10,$E0,']',$C0,'1`' 
      DC.B   '8',$E0,'&',$C0,'N',$C0,$14,$A0
      DC.B   'b',$C0,$08,$C0,$10,$E0,'G',$E0
      DC.B   $1A,'@',$1E,$00,$0B,$E0,'#',$00
      DC.B   'S W',$80,'B',$E0,'*',$80
      DC.B   '3@[',$E0,'`@F',$A0
      DC.B   $10,'@X ',$1F,$E0,'J`' 
      DC.B   'O`*',$80,'G@C',$80
      DC.B   'D ',$0F,$00,$05,$A0,';`'
      DC.B   $0C,$80,'W',$80,'[',$E0,'0 ' 
      DC.B   'c`',$0D,' W',$80,$0A,$00
      DC.B   '? ',$0A,$A0,'/',$80,'\',$80 
      DC.B   '#',$00,'Z',$A0,$1C,$C0,'a',$80
      DC.B   $0F,$00,$15,$E0,'G@',$08,$C0 
      DC.B   $19,$A0,'D',$C0,$0F,$A0,$08,' '
      DC.B   $1D,'`',$27,'`#',$00,'A',$A0 
      DC.B   $12,$C0,'X V@',$14,$A0 
      DC.B   '1`',$1E,$00,'U',$A0,'=',$E0 
      DC.B   '[@',$05,$00,$12,' ',$1A,'@' 
      DC.B   $11,$80,'F',$A0,'E`',$05,$A0 
      DC.B   $05,$A0,$12,$C0,'_',$00,'3',$E0
      DC.B   ':',$C0,'(',$A0,'Q@',$15,$E0 
      DC.B   $01,'@',$0B,'@',$13,'`I '
      DC.B   $1B,$80,$1F,'@',$0D,$C0,'$',$E0
      DC.B   'U',$A0,'Y`E`+',$C0
      DC.B   '4',$80,'] b',$C0,'I ' 
      DC.B   $12,$C0,'Z',$A0,'"`K',$A0
      DC.B   'Q@+',$C0,'I',$C0,'D',$C0
      DC.B   'F',$00,$10,$E0,$07,$80,'=',$E0
      DC.B   $0F,$00,'Y`] 1`' 
      DC.B   $00,$A0,$0E,'`X',$C0,$0C,$80 
      DC.B   'A',$A0,$0C,$80,'2',$00,'^`' 
      DC.B   '%',$80,'[',$E0,$1E,$00,'b',$C0
      DC.B   $10,'@',$17,$C0,'H',$80,$0B,'@'
      DC.B   $1A,$E0,'F',$A0,$11,$80,$0A,$A0
      DC.B   $1F,$E0,')',$E0,'$@D ' 
      DC.B   $14,$00,'Z',$00,'W',$80,$16,$80
      DC.B   '3',$E0,$1F,'@W',$80,'? '
      DC.B   '\',$80,$06,$E0,$13,'`',$1B,$80
      DC.B   $14,$00,'G',$E0,'G@',$07,$80 
      DC.B   $07,$80,$14,$A0,'`@6`' 
      DC.B   '<',$A0,'*',$80,'S',$C0,$17,' '
      DC.B   $03,$C0,$0D,$C0,$15,$E0,'J`' 
      DC.B   $1C,$C0,' ',$80,$0F,$A0,'&',$C0
      DC.B   'X [@G',$E0,'-',$00
      DC.B   '5',$C0,'^`',$01,'@K',$A0
      DC.B   $15,'@] $',$E0,'L',$E0 
      DC.B   'S -',$00,'L@F',$00
      DC.B   'G',$E0,$12,$C0,$09,'`@`'
      DC.B   $11,$80,'[@^`2',$A0
      DC.B   $01,$E0,$0F,$A0,'Z',$00,$0F,$00
      DC.B   'D ',$0E,'`4',$80,'`@' 
      DC.B   '(',$00,'] ',$1F,'@',$00,$00 
      DC.B   $11,$80,$19,$A0,'I',$C0,$0D,$C0
      DC.B   $1C,' H',$80,$13,'`',$0D,' ' 
      DC.B   '"`,`%',$80,'F',$A0
      DC.B   $15,'@[',$E0,'X',$C0,$18,'`' 
      DC.B   '6` ',$80,'Y`@`' 
      DC.B   ']',$C0,$08,$C0,$14,$A0,$1C,$C0
      DC.B   $16,$80,'I I ',$09,'`' 
      DC.B   $09,'`',$16,$80,'a',$80,'8',$E0
      DC.B   '>',$80,',`V@',$18,'`' 
      DC.B   $06,'@',$10,'@',$18,'`K',$A0 
      DC.B   $1E,$00,'!',$C0,$11,$80,'(',$A0
      DC.B   'Z',$A0,'] J`.@' 
      DC.B   '7',$00,'_',$A0,$03,$C0,'N ' 
      DC.B   $17,$C0,'_',$A0,$27,'`N '
      DC.B   'U',$00,'.@N',$C0,'G@' 
      DC.B   'I',$C0,$14,$A0,$0B,'@B',$E0 
      DC.B   $14,$00,'] _',$A0,'3',$E0
      DC.B   $03,' ',$10,$E0,'[@',$11,$80 
      DC.B   'F',$A0,$10,'@7',$00,'b '
      DC.B   '*',$80,'^` ',$80,$01,'@'
      DC.B   $12,$C0,$1B,$80,'K',$00,$10,'@'
      DC.B   $1D,'`J`',$15,'@',$0F,$A0
      DC.B   '$',$E0,'.',$E0,'&',$C0,'I ' 
      DC.B   $16,$80,']',$C0,'Z',$00,$1A,'@'
      DC.B   '8',$E0,'!',$C0,'[@A',$A0
      DC.B   '_',$00,$0A,$A0,$15,$E0,$1E,$00
      DC.B   $19,$00,'J`K',$00,$0B,'@'
      DC.B   $0B,'@',$18,'`b',$C0,';`'
      DC.B   '@`.@X',$C0,$19,$A0
      DC.B   $08,$C0,$12,$C0,$1A,$E0,'L',$E0
      DC.B   $1F,'@#',$00,$13,'`*',$80
      DC.B   '] _',$00,'L',$E0,'/',$80
      DC.B   '8@`',$E0,$06,'@P',$A0 
      DC.B   $1A,'@b )',$E0,'O`'
      DC.B   'V',$E0,'/',$80,'Q@H',$80
      DC.B   'K',$A0,$16,$80,$0D,' E`'
      DC.B   $16,$80,'_',$00,'`',$E0,'5 ' 
      DC.B   $04,'`',$12,' \',$80,$14,$00 
      DC.B   'I ',$12,' 9',$80,$00,$00
      DC.B   '-',$00,'_',$A0,'!',$C0,$02,$80
      DC.B   $14,$00,$1D,'`L@',$12,$C0
      DC.B   $1E,$A0,'L@',$17,' ',$12,' ' 
      DC.B   $27,'`1`(',$00,'K',$A0 
      DC.B   $17,$C0,'_',$A0,'[@',$1C,' ' 
      DC.B   ';`#',$00,'] B',$E0
      DC.B   '`@',$0C,$80,$17,' ',$1F,'@' 
      DC.B   $1B,$80,'K',$A0,'L',$E0,$0D,' '
      DC.B   $0D,' ',$1A,'@',$00,$00,'=',$E0
      DC.B   'B@0 [@',$1A,$E0 
      DC.B   $0B,'@',$15,'@',$1D,'`N '
      DC.B   ' ',$80,'$@',$15,'@,`' 
      DC.B   '_',$A0,'`',$E0,'O`0',$C0
      DC.B   '9',$80,'b ',$08,$C0,'S '
      DC.B   $1C,$C0,$00,$A0,',`P',$A0
      DC.B   'X',$C0,'0',$C0,'S',$C0,'I',$C0
      DC.B   'M',$80,$18,'`',$0F,$00,'G',$E0
      DC.B   $19,$00,'`',$E0,'b 6`' 
      DC.B   $05,$A0,$13,'`]',$C0,$16,$80 
      DC.B   'K',$A0,$14,$00,'<',$00,$01,$E0
      DC.B   '/',$80,'`',$E0,'#',$00,$03,$C0
      DC.B   $15,'@',$1F,'@M',$80,$15,'@' 
      DC.B   $1F,$E0,'N ',$19,$00,$14,$A0 
      DC.B   ')',$E0,'3',$E0,')@N ' 
      DC.B   $19,$00,'a',$80,'\',$80,$1E,$00
      DC.B   '=',$E0,'$@_',$00,'D ' 
      DC.B   'a',$80,$0E,'`',$18,'` ',$80 
      DC.B   $1E,$00,'L',$E0,'N',$C0,$0F,$00
      DC.B   $0F,$00,$1C,' ',$01,'@@`'
      DC.B   'D 2',$00,']',$C0,$1C,' '
      DC.B   $0D,$C0,$17,$C0,$1F,$E0,'O`' 
      DC.B   '!',$C0,'%',$80,$17,' .@'
      DC.B   'b b',$C0,'Q',$E0,'2',$00
      DC.B   ':',$C0,'c`',$0B,'@U',$A0
      DC.B   $1F,'@',$03,' .',$E0,'Q',$E0 
      DC.B   'Z',$A0,'2',$00,'V@K',$00
      DC.B   'O`',$1A,'@',$10,$E0,'J`'
      DC.B   $1B,$80,'b',$C0,'c`7',$A0
      DC.B   $06,$E0,$14,$A0,'_',$00,$19,$00
      DC.B   'N ',$15,$E0,'>',$80,$03,$C0 
      DC.B   '2',$00,'b $@',$05,$00 
      DC.B   $16,$80,'! N',$C0,$17,$C0
      DC.B   '! P',$00,$1A,$E0,$17,' '
      DC.B   ',`6`*',$80,'P',$A0
      DC.B   $1A,'@c`]',$C0,$1F,$E0 
      DC.B   '@`%',$80,'`',$E0,'E`' 
      DC.B   'b',$C0,$10,'@',$19,$A0,'!',$C0
      DC.B   ' ',$80,'N P',$A0,$10,$E0
      DC.B   $10,$E0,$1E,$00,$02,$80,'B',$E0
      DC.B   'F',$00,'3',$E0,'`@',$1D,'`' 
      DC.B   $10,'@',$1A,'@"`P',$A0 
      DC.B   '#',$00,'&',$C0,$19,$00,'0 ' 
      DC.B   $00,$A0,$00,$A0,'T`3@' 
      DC.B   '<',$00,$00,$A0,$0D,$C0,'X ' 
      DC.B   '!',$C0,$05,$A0,'1`S ' 
      DC.B   '\',$80,'3@X',$C0,'L@' 
      DC.B   'Q@',$1C,' ',$12,$C0,'L',$E0 
      DC.B   $1E,$00,$00,$A0,$00,$A0,'8',$E0
      DC.B   $08,' ',$15,$E0,'`@',$1B,$80 
      DC.B   'P',$A0,$17,$C0,'A',$00,$05,$A0
      DC.B   '4',$80,'c`%',$80,$06,'@'
      DC.B   $17,$C0,'#',$00,'P',$00,$1A,'@'
      DC.B   '"`Q',$E0,$1C,$C0,$19,$A0
      DC.B   '.',$E0,'8',$E0,'+',$C0,'S ' 
      DC.B   $1B,$80,$01,'@_',$00,'!',$C0 
      DC.B   'B',$E0,'&',$C0,'b',$C0,'F',$A0
      DC.B   $00,$00,$12,' ',$1A,$E0,'#',$00
      DC.B   '#',$00,'O`R',$80,$12,$C0
      DC.B   $12,$C0,$1F,$E0,$03,$C0,'E`' 
      DC.B   'G',$E0,'5',$C0,'b',$C0,$1E,$A0
      DC.B   $12,$C0,$1C,$C0,'$',$E0,'Q',$E0
      DC.B   '$@(',$00,$1A,$E0,'2',$00
      DC.B   $03,' ',$02,$80,'V',$E0,'4',$80
      DC.B   '=@',$01,$E0,$10,'@Z',$A0
      DC.B   '$@',$08,' 3',$E0,'T`' 
      DC.B   '^`4',$80,'[@M',$80
      DC.B   'S ',$1E,$00,$14,$A0,'O`'
      DC.B   ' ',$80,$02,$80,$01,$E0,': ' 
      DC.B   $09,'`',$17,' a',$80,$1E,$00 
      DC.B   'S ',$19,$A0,'C',$80,$07,$80 
      DC.B   '7',$00,$00,$A0,'&',$C0,$07,$80
      DC.B   $19,$00,'$',$E0,'Q@',$1C,$C0 
      DC.B   '#',$A0,'S',$C0,$1E,$A0,$1C,' '
      DC.B   '1`;`-',$00,'U',$A0
      DC.B   $1C,$C0,$03,' `@#',$A0 
      DC.B   'E`(',$00,$00,$A0,'G',$E0
      DC.B   $01,'@',$14,$00,$1C,' $@'
      DC.B   '%',$80,'P',$A0,'T`',$14,$A0 
      DC.B   $14,$A0,'!',$C0,$05,$00,'G',$E0
      DC.B   'I',$C0,'7',$A0,$01,'@',$1F,$E0
      DC.B   $15,'@',$1F,'@',$27,'`S '
      DC.B   '%',$80,')@',$1C,$C0,'3',$E0 
      DC.B   $05,$A0,$04,'`Y`5',$C0 
      DC.B   '>',$80,$03,' ',$12,$C0,'] ' 
      DC.B   '&',$C0,$0A,$A0,'6`U',$A0
      DC.B   '`@5',$C0,']',$C0,'N',$C0
      DC.B   'U',$00,$1F,$E0,$16,$80,'Q',$E0
      DC.B   '#',$00,$04,'`',$03,' ;`'
      DC.B   $0A,$A0,$18,'`b',$C0,' ',$80 
      DC.B   'U',$A0,$1B,$80,'F',$00,$09,'`'
      DC.B   '9',$80,$01,$E0,'(',$00,$08,$C0
      DC.B   $1A,'@&',$C0,'R',$80,$1F,'@' 
      DC.B   '$',$E0,'U',$A0,' ',$80,$1E,$A0
      DC.B   '3',$E0,'=',$E0,'.@X ' 
      DC.B   $1E,$00,$05,$00,'a',$80,'%',$80
      DC.B   'G',$E0,')@',$02,$80,'I '
      DC.B   $02,$80,$15,$E0,$1D,'`%',$80 
      DC.B   '(',$00,'Q',$E0,'V@',$16,$80 
      DC.B   $16,$80,'#',$A0,$06,'@J`'
      DC.B   'K',$A0,'9',$80,$03,$C0,'! ' 
      DC.B   $17,$C0,'!',$C0,')',$E0,'T`' 
      DC.B   '&',$C0,'*',$80,$1E,$A0,'5',$C0
      DC.B   $08,' ',$06,'@[',$E0,'7',$00 
      DC.B   '?',$C0,$04,'`',$15,'@_',$A0 
      DC.B   ')@',$0D,' 8',$E0,'V',$E0
      DC.B   'b 7',$00,'`@P',$00
      DC.B   'V',$E0,'!',$C0,$18,'`T`'
      DC.B   '%',$80,$06,'@',$04,'`<',$A0 
      DC.B   $0B,$E0,$19,$A0,$00,$00,'#',$00
      DC.B   'X ',$1D,'`H',$80,$0B,'@'
      DC.B   '<',$00,$03,' )@',$0A,$00
      DC.B   $1B,$80,'(',$A0,'S',$C0,'!',$C0
      DC.B   '& W',$80,'"`! ' 
      DC.B   '6`@`/',$80,'Z',$A0
      DC.B   $1F,'@',$06,$E0,'b',$C0,$27,'`'
      DC.B   'J`*',$80,$04,'`J`'
      DC.B   $03,$C0,$17,$C0,$1E,$A0,'&',$C0
      DC.B   '*',$80,'S X ',$18,'`' 
      DC.B   $18,'`%',$80,$07,$80,'L',$E0 
      DC.B   'M',$80,';`',$06,'@"`' 
      DC.B   $1A,'@$@,`U',$A0 
      DC.B   '(',$00,'+',$C0,' ',$80,'7',$A0
      DC.B   $0A,$A0,$08,' ^`8@'
      DC.B   'A',$00,$05,$A0,$17,$C0,'b ' 
      DC.B   '+',$C0,$0F,$A0,';`X ' 
      DC.B   $00,$00,'8@b',$C0,'Q@' 
      DC.B   'X',$C0,'#',$A0,$1A,'@V',$E0 
      DC.B   '(',$00,$08,' ',$05,$A0,'=',$E0
      DC.B   $0D,' ',$1A,$E0,$01,'@%',$80 
      DC.B   'Z',$A0,$1F,'@K',$00,$0D,' ' 
      DC.B   '>',$80,$04,'`*',$80,$0B,'@' 
      DC.B   $1C,$C0,'*',$80,'U',$00,'$@' 
      DC.B   $27,'`Y`$@#',$A0 
      DC.B   '8',$E0,'B',$E0,'0',$C0,'] ' 
      DC.B   ' ',$80,$08,$C0,$00,$00,')@' 
      DC.B   'L',$E0,'+',$C0,$06,'@K',$A0 
      DC.B   $05,$00,$19,$A0,$1F,$E0,'(',$00
      DC.B   '-',$00,'T`Z',$00,$1A,'@'
      DC.B   $1A,'@',$27,'`',$08,$C0,'O`' 
      DC.B   'O`=@',$08,$C0,'#',$A0 
      DC.B   $1C,$C0,'&',$C0,'.',$E0,'V',$E0
      DC.B   ')@-',$00,'"`9',$80
      DC.B   $0D,' ',$0A,$00,'`',$E0,'9',$80
      DC.B   'B@',$06,$E0,$1A,'@',$00,$A0 
      DC.B   '.@',$12,' =',$E0,'Y`' 
      DC.B   $01,$E0,'9',$80,$01,'@R',$80 
      DC.B   'Z',$A0,'%',$80,$1C,' Y`'
      DC.B   '*',$80,$0A,$00,$06,$E0,'? ' 
      DC.B   $0E,'`',$1C,' ',$02,$80,'(',$00
      DC.B   '] ! M',$80,$0F,$00
      DC.B   'A',$00,$05,$A0,'+',$C0,$0C,$80
      DC.B   $1E,$00,',`V@&',$C0
      DC.B   '(',$A0,'[@& & ' 
      DC.B   ';`E`2',$00,'_',$A0
      DC.B   '!',$C0,$0A,$A0,$01,'@+ '
      DC.B   'O`-',$00,$08,' L',$E0 
      DC.B   $06,'@',$1B,$80,'! )@' 
      DC.B   '/',$80,'U',$A0,'[',$E0,$1C,' '
      DC.B   $1C,' )@',$0A,$00,'Q',$E0
      DC.B   'Q@? ',$0B,'@$',$E0
      DC.B   $1F,'@)@1`X '
      DC.B   '*',$80,'.@$@;`' 
      DC.B   $0F,$A0,$0B,$E0,'c`:',$C0
      DC.B   'C',$80,$08,' ',$1C,$C0,$03,' '
      DC.B   '0',$C0,$14,$A0,'@`Z',$A0
      DC.B   $03,$C0,':',$C0,$03,$C0,'S',$C0
      DC.B   '\',$80,$27,'`',$1E,$00,'[',$E0
      DC.B   '-',$00,$0B,$E0,$08,' @`'
      DC.B   $0F,$A0,$1D,'`',$03,$C0,'*',$80
      DC.B   '_',$A0,'#',$00,'P',$00,$10,$E0
      DC.B   'C',$80,$06,$E0,'-',$00,$0D,$C0
      DC.B   $1F,'@.@W',$80,')@'
      DC.B   ')',$E0,'] (',$00,'(',$A0
      DC.B   '=',$E0,'G',$E0,'3@b ' 
      DC.B   '#',$00,$0C,$80,$02,$80,'-',$00
      DC.B   'Q',$E0,'.@',$0A,$00,'N '
      DC.B   $07,$80,$1D,'`"`*',$80 
      DC.B   '2',$00,'V',$E0,']',$C0,$1E,$00
      DC.B   $1E,$00,'+ ',$0B,'@T`' 
      DC.B   'S A',$00,$0D,$C0,'& ' 
      DC.B   '!',$C0,'+',$C0,'3',$E0,'Y`' 
      DC.B   '+',$C0,'/',$80,'& =@' 
      DC.B   $12,' ',$0D,$C0,$01,$E0,'<',$00
      DC.B   'D',$C0,$09,'`',$1F,'@',$05,$A0
      DC.B   '3@',$17,' B',$E0,'[',$E0
      DC.B   $05,$A0,'<',$00,$06,'@U',$00 
      DC.B   '^`)@',$1F,$E0,'^`'
      DC.B   '/',$80,$0D,$C0,$09,'`A',$A0 
      DC.B   $10,$E0,$1E,$A0,$05,$00,'-',$00
      DC.B   'b $',$E0,'R',$80,$12,$C0
      DC.B   'F',$00,$08,' .@',$0F,$00
      DC.B   ' ',$80,'0 X',$C0,'+',$C0
      DC.B   '+ _',$00,')',$E0,'+ ' 
      DC.B   '@`J`4',$80,$00,$A0
      DC.B   '$@',$0E,'`',$03,$C0,'.',$E0 
      DC.B   'T`/',$80,$0B,$E0,'O`' 
      DC.B   $08,$C0,$1F,'@#',$A0,'+',$C0 
      DC.B   '4',$80,'X _',$A0,$1F,$E0
      DC.B   $1F,$E0,'-',$00,$0C,$80,'V',$E0
      DC.B   'U',$00,'B',$E0,$10,'@',$27,'`'
      DC.B   '$@.@6`Z',$A0
      DC.B   '-',$00,'0',$C0,'(',$00,'? ' 
      DC.B   $14,$A0,$0F,$A0,$04,'`=@'
      DC.B   'F',$00,$0A,$A0,'!',$C0,$08,' '
      DC.B   '5',$C0,$19,$A0,'E`] ' 
      DC.B   $07,$80,'=@',$08,$C0,'V@'
      DC.B   '`@+ !',$C0,'`',$E0
      DC.B   '2',$00,$0F,$A0,$0A,$A0,'B',$E0
      DC.B   $12,' ',$1F,$E0,$06,'@/',$80 
      DC.B   $00,$A0,'&',$C0,'U',$00,$14,$A0
      DC.B   'H',$80,$09,'`/',$80,$10,'@' 
      DC.B   '!',$C0,'2',$00,'Z',$00,'.@' 
      DC.B   ',``',$E0,'+',$C0,'-',$A0
      DC.B   'B',$E0,'L',$E0,'5',$C0,$03,' '
      DC.B   '%',$80,$10,'@',$05,$00,'0',$C0
      DC.B   'V',$E0,'0',$C0,$0D,$C0,'P',$A0
      DC.B   $0A,$00,'! $',$E0,'-',$00
      DC.B   '7',$00,'Y`a',$80,'!',$C0
      DC.B   '!',$C0,'.',$E0,$0D,$C0,'Y`' 
      DC.B   'V',$E0,'D',$C0,$12,$C0,'(',$A0
      DC.B   '&',$C0,'0',$C0,'8',$E0,'[',$E0
      DC.B   '.@2',$00,')',$E0,'A',$00
      DC.B   $17,' ',$11,$80,$06,$E0,'>',$80
      DC.B   'G@',$0B,$E0,'$@',$0A,$A0
      DC.B   '8@',$1C,' G',$E0,'^`' 
      DC.B   $09,'`>',$80,$0B,'@W',$80
      DC.B   'b -',$00,'#',$A0,'c`' 
      DC.B   '4',$80,$11,$80,$0B,$E0,'D ' 
      DC.B   $13,'`! ',$07,$80,'2',$00
      DC.B   $03,' (',$A0,'W',$80,$16,$80 
      DC.B   'K',$00,$0A,$A0,'0',$C0,$11,$80
      DC.B   '#',$00,'3',$E0,'[@0',$C0
      DC.B   '-',$A0,'b',$C0,'-',$A0,'0 ' 
      DC.B   'E`O`7',$00,$05,$A0
      DC.B   '&',$C0,$12,' ',$06,'@2',$A0 
      DC.B   'Y`2',$00,$0F,$A0,'Q',$E0
      DC.B   $0B,'@#',$00,'& .@'
      DC.B   '9',$80,'Z',$A0,'c`#',$A0
      DC.B   '#',$A0,'0',$C0,$0F,$00,'[',$E0
      DC.B   'X',$C0,'F',$A0,$15,'@)',$E0 
      DC.B   ')@3@;`] ' 
      DC.B   '/',$80,'3@+',$C0,'B',$E0
      DC.B   $19,$A0,$13,'`',$09,'`?',$C0 
      DC.B   'H',$80,$0D,' &',$C0,$0D,' ' 
      DC.B   ':',$C0,$1E,$A0,'J`_',$A0
      DC.B   $0B,'@?',$C0,$0D,$C0,'X',$C0 
      DC.B   $00,$00,'.',$E0,'%',$80,$01,$E0
      DC.B   '7',$00,$13,'`',$0D,' E`'
      DC.B   $14,$A0,'"`',$08,$C0,'4',$80 
      DC.B   $05,$A0,'*',$80,'Z',$00,$18,'`'
      DC.B   'M',$80,$0B,$E0,'2',$00,$12,$C0
      DC.B   '$@5',$C0,'\',$80,'3@' 
      DC.B   '.',$E0,$00,$A0,'/',$80,'2',$A0
      DC.B   'G',$E0,'Q',$E0,'8@',$08,' ' 
      DC.B   '(',$00,$14,$00,$07,$80,'4',$80
      DC.B   '[',$E0,'3@',$11,$80,'S '
      DC.B   $0C,$80,'$',$E0,$27,'`/',$80 
      DC.B   '<',$00,'[',$E0,$01,'@%',$80 
      DC.B   '%',$80,'2',$A0,$10,'@^`'
      DC.B   'Z',$A0,'H',$80,$17,$C0,'+ ' 
      DC.B   '+',$C0,'5',$C0,'=',$E0,'^`' 
      DC.B   '0',$C0,'4',$80,'-',$A0,'D',$C0
      DC.B   $1C,' ',$15,'@',$0B,$E0,'A',$00
      DC.B   'I',$C0,$0E,'`)@',$0F,$A0
      DC.B   '=@! L',$E0,'`',$E0
      DC.B   $0D,' A',$00,$10,'@Z',$00
      DC.B   $01,$E0,'0',$C0,$27,'`',$04,'`'
      DC.B   '9',$80,$15,'@',$0E,'`F',$A0 
      DC.B   $15,$E0,'#',$A0,$0A,$00,'7',$00
      DC.B   $08,' ,`\',$80,$1A,'@' 
      DC.B   'P',$00,$0D,' 3@',$14,$00
      DC.B   '%',$80,'7',$A0,']',$C0,'5',$C0
      DC.B   '0 ',$02,$80,'1`5 '
      DC.B   'J`T`9',$80,$0A,$A0
      DC.B   ')@',$15,$E0,$08,$C0,'6`'
      DC.B   '^`4',$80,$13,'`T`'
      DC.B   $0D,$C0,'&',$C0,'(',$A0,'0',$C0
      DC.B   '>',$80,'] ',$03,' ',$27,'`' 
      DC.B   $27,'`4',$80,$11,$80,'`',$E0 
      DC.B   '\',$80,'J`',$1A,'@,`' 
      DC.B   '.@8@@`_',$A0
      DC.B   '2',$00,'5',$C0,'/',$80,'F',$A0
      DC.B   $1E,$A0,$17,' ',$0E,'`B@'
      DC.B   'K',$00,$0F,$A0,'+',$C0,$12,' '
      DC.B   '?',$C0,'#',$A0,'O`b ' 
      DC.B   $0F,$00,'B@',$12,$C0,'[@'
      DC.B   $03,$C0,'2',$A0,')@',$06,$E0 
      DC.B   '<',$00,$17,' ',$0F,$A0,'G',$E0
      DC.B   $17,' $',$E0,$0B,'@9',$80
      DC.B   $0A,$A0,'.@_',$00,$1C,' '
      DC.B   'R',$80,$0E,'`4',$80,$15,'@' 
      DC.B   '&',$C0,'9',$80,'_',$00,'8@' 
      DC.B   '1`',$04,'`3@7',$A0
      DC.B   'L',$E0,'V',$E0,':',$C0,$0D,' '
      DC.B   '*',$80,$17,$C0,$0A,$00,'8@' 
      DC.B   '`',$E0,'5',$C0,$15,'@U',$A0 
      DC.B   $0F,$00,'(',$A0,')',$E0,'2',$00
      DC.B   'A',$00,'^`',$05,$00,')@'
      DC.B   ')@6`',$12,$C0,'c`'
      DC.B   '^`L@',$1C,$C0,'-',$A0 
      DC.B   '0',$C0,':',$C0,'B',$E0,'`',$E0
      DC.B   '3@7',$00,'1`H',$80
      DC.B   '! ',$19,$00,$10,$E0,'C',$80 
      DC.B   'L@',$10,$E0,'.@',$14,$A0
      DC.B   'B@& Q',$E0,'c`' 
      DC.B   $10,$E0,'C',$80,$15,'@\',$80 
      DC.B   $05,$A0,'4',$80,'+ ',$09,'`' 
      DC.B   '>',$80,$19,$00,$10,$E0,'I ' 
      DC.B   $18,'`& ',$0C,$80,'<',$00
      DC.B   $0D,' 0 a',$80,$1E,$00 
      DC.B   'U',$00,$0F,$A0,'5',$C0,$16,$80
      DC.B   '(',$00,';``@:',$C0
      DC.B   '2',$A0,$06,'@5 : '
      DC.B   'O`Y`<',$00,$0F,$A0
      DC.B   '+',$C0,$19,$A0,$0B,'@: '
      DC.B   'c`7',$00,$17,' V',$E0 
      DC.B   $10,'@*',$80,'+ 3@'
      DC.B   'C',$80,'_',$A0,$06,$E0,'+ ' 
      DC.B   '+ 8@',$14,$00,$01,$E0 
      DC.B   '`@N ',$1F,'@.',$E0
      DC.B   '3@=@E`b ' 
      DC.B   '4',$80,'8@3@J`' 
      DC.B   '#',$A0,$1A,$E0,$13,'`D',$C0 
      DC.B   'M',$80,$12,' 0',$C0,$17,' ' 
      DC.B   'D',$C0,'(',$A0,'T`',$00,$A0 
      DC.B   $12,$C0,'D',$C0,$17,$C0,']',$C0
      DC.B   $07,$80,'6`-',$00,$0B,$E0
      DC.B   'A',$00,$1A,$E0,$12,' J`'
      DC.B   $19,$A0,$27,'`',$0D,$C0,'>',$80
      DC.B   $0F,$A0,'2',$00,$00,$00,$1F,$E0
      DC.B   'W',$80,$10,$E0,'7',$00,$17,$C0
      DC.B   ')@=@a',$80,'=@' 
      DC.B   '3',$E0,$08,' 7',$00,'<',$A0 
      DC.B   'Q',$E0,'[',$E0,'=@',$12,' ' 
      DC.B   '-',$00,$1B,$80,$0C,$80,'<',$00
      DC.B   $01,$E0,'8@',$19,$00,'X '
      DC.B   $11,$80,',`,`4',$80
      DC.B   'F',$00,'`',$E0,$08,$C0,'-',$00
      DC.B   '-',$00,': ',$15,'@',$04,'`' 
      DC.B   'b P',$00,'!',$C0,'0 ' 
      DC.B   '5',$C0,'?',$C0,'G',$E0,'c`' 
      DC.B   '5',$C0,'9',$80,'5 L@' 
      DC.B   '& ',$1C,$C0,$15,$E0,'F',$00 
      DC.B   'N',$C0,$13,'`3@',$19,$A0
      DC.B   'G@+ V',$E0,$01,$E0
      DC.B   $14,$A0,'F',$00,$1A,'@_',$00 
      DC.B   $09,'`8@.',$E0,$0E,'`' 
      DC.B   'C',$80,$1C,$C0,$13,'`K',$A0 
      DC.B   $1A,$E0,'(',$A0,$0F,$00,'A',$00
      DC.B   $12,' 3',$E0,$02,$80,'!',$C0 
      DC.B   'Z',$00,$12,' 8@',$19,$00
      DC.B   '*',$80,'? b',$C0,'?',$C0
      DC.B   '5 ',$0A,$00,'8',$E0,'? '
      DC.B   'T`^`>',$80,$14,$A0
      DC.B   '.@',$1D,'`',$0D,$C0,'=',$E0 
      DC.B   $04,'`9',$80,$1A,$E0,'Y`'
      DC.B   $12,$C0,'.@-',$A0,'5',$C0
      DC.B   'H',$80,'b ',$0A,$A0,'.',$E0 
      DC.B   '.',$E0,'<',$00,$16,$80,$06,$E0
      DC.B   $00,$00,'Q',$E0,'$@1`' 
      DC.B   '8@B@J`',$00,$A0 
      DC.B   '7',$00,':',$C0,'7',$00,'N ' 
      DC.B   '(',$A0,$1E,$A0,$18,'`G@'
      DC.B   'P',$00,$14,$A0,'5',$C0,$1C,' '
      DC.B   'I',$C0,'-',$A0,'Y`',$03,' ' 
      DC.B   $16,$80,'G@',$1C,$C0,'`@'
      DC.B   $0B,'@: 0',$C0,$10,$E0 
      DC.B   'F',$00,$1E,$A0,$14,$A0,'L',$E0
      DC.B   $1C,' )',$E0,$10,'@C',$80
      DC.B   $14,$A0,'5',$C0,$05,$00,'#',$A0
      DC.B   '\',$80,$13,'`9',$80,$1A,'@' 
      DC.B   '+',$C0,'A',$00,$00,$00,'B@' 
      DC.B   '6`',$0B,$E0,':',$C0,'A',$A0 
      DC.B   'V',$E0,'`',$E0,'?',$C0,$17,' '
      DC.B   '/',$80,$1F,'@',$0F,$00,'?',$C0
      DC.B   $06,$E0,':',$C0,$1C,$C0,'Z',$A0
      DC.B   $14,$00,'0 .',$E0,'7',$00
      DC.B   'K',$00,'c`',$0C,$80,'0',$C0 
      DC.B   '0',$C0,'=',$E0,$17,$C0,$09,'`'
      DC.B   $01,$E0,'S',$C0,'&',$C0,'2',$A0
      DC.B   ':',$C0,'D',$C0,'L',$E0,$01,$E0
      DC.B   '8@<',$00,'8',$E0,'P',$00
      DC.B   '+  ',$80,$1A,$E0,'H',$80
      DC.B   'Q@',$15,$E0,'8@',$1E,$A0
      DC.B   'L@0 [',$E0,$04,'`'
      DC.B   $18,'`H',$80,$1F,'@a',$80
      DC.B   $0D,' <',$00,'2',$A0,$13,'`' 
      DC.B   'H',$80,' ',$80,$15,$E0,'N ' 
      DC.B   $1D,'`+ ',$11,$80,'F',$00
      DC.B   $17,' 7',$A0,$07,$80,'%',$80 
      DC.B   '_',$00,$14,$A0,':',$C0,$1B,$80
      DC.B   '-',$00,'B',$E0,$01,'@D',$C0 
      DC.B   '7',$A0,$0D,$C0,'<',$A0,'D ' 
      DC.B   'Y`c`A',$00,$19,$A0
      DC.B   '0',$C0,'! ',$10,'@A',$A0
      DC.B   $09,'`<',$00,$1E,$A0,'[',$E0 
      DC.B   $15,'@2',$00,'0 8@'
      DC.B   'M',$80,$00,$A0,$0E,'`2',$A0 
      DC.B   '2',$A0,'?',$C0,$19,$00,$0B,$E0
      DC.B   $03,$C0,'U',$A0,')@3',$E0
      DC.B   '=@G@O`',$03,' ' 
      DC.B   '9',$80,'=@:',$C0,'Q',$E0
      DC.B   '-',$A0,'"`',$1D,'`I',$C0
      DC.B   'R',$80,$17,' :',$C0,'! '
      DC.B   'N',$C0,'2',$A0,'^`',$05,$A0 
L0194:DC.B   '' 
 BSS
L0195:DS.B    96
L0196:DS.W    1 
L0197:DS.B    10
L0198:DS.B    8 
L0199:DS.B    14980 
ZUEND: END
