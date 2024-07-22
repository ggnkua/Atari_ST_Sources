  MOVEM.L   A0-A6/D0-D7,-(A7) 
  CMPI.L    #$41544F4D,(A0)+
  BNE       L001C 
  MOVE.L    (A0)+,D0
  MOVE.L    D0,-(A7)
  LEA       0(A1,D0.L),A5 
  PEA       (A5)
  MOVE.L    (A0)+,D0
  LEA       0(A0,D0.L),A6 
  MOVE.B    -(A6),D7
  BRA       L0013 
L0000:
  LEA       L0020(PC),A4
  MOVEQ     #1,D6 
  BSR.S     L000B 
  BRA.S     L000A 
L0001:
  MOVEQ     #6,D6 
L0002:
  ADD.B     D7,D7 
  BEQ.S     L0006 
L0003:
  DBCC      D6,L0002
  BCS.S     L0004 
  MOVEQ     #6,D5 
  SUB.W     D6,D5 
  BRA.S     L0008 
L0004:
  MOVEQ     #3,D6 
  BSR.S     L000B 
  BEQ.S     L0005 
  ADDQ.W    #6,D5 
  BRA.S     L0008 
L0005:
  MOVEQ     #7,D6 
  BSR.S     L000B 
  BEQ.S     L0007 
  ADDI.W    #$15,D5 
  BRA.S     L0008 
L0006:
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
  BRA.S     L0003 
L0007:
  MOVEQ     #$D,D6
  BSR.S     L000B 
  ADDI.W    #$114,D5
L0008:
  MOVE.W    D5,-(A7)
  BNE.S     L000F 
  LEA       L001F(PC),A4
  MOVEQ     #2,D6 
  BSR.S     L000B 
  CMP.W     #5,D5 
  BLT.S     L0010 
  ADDQ.W    #2,A7 
  SUBQ.W    #6,D5 
  BGT.S     L0000 
  MOVEA.L   A5,A4 
  BLT.S     L0009 
  ADDQ.W    #4,A4 
L0009:
  MOVEQ     #1,D6 
  BSR.S     L000B 
L000A:
  MOVE.B    0(A4,D5.W),-(A5)
  BRA.S     L0013 
L000B:
  CLR.W     D5
L000C:
  ADD.B     D7,D7 
  BEQ.S     L000E 
L000D:
  ADDX.W    D5,D5 
  DBF       D6,L000C
  TST.W     D5
  RTS 
L000E:
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
  BRA.S     L000D 
L000F:
  LEA       L001E(PC),A4
  MOVEQ     #2,D6 
  BSR.S     L000B 
L0010:
  MOVE.W    D5,D4 
  MOVE.B    $E(A4,D4.W),D6
  EXT.W     D6
  BSR.S     L000B 
  ADD.W     D4,D4 
  BEQ.S     L0011 
  ADD.W     -2(A4,D4.W),D5
L0011:
  LEA       1(A5,D5.W),A4 
  MOVE.W    (A7)+,D5
  MOVE.B    -(A4),-(A5) 
L0012:
  MOVE.B    -(A4),-(A5) 
  DBF       D5,L0012
L0013:
  MOVEQ     #$B,D6
  MOVEQ     #$B,D5
L0014:
  ADD.B     D7,D7 
  BEQ.S     L001D 
L0015:
  DBCC      D6,L0014
  BCS.S     L0016 
  SUB.W     D6,D5 
  BRA.S     L0018 
L0016:
  MOVEQ     #7,D6 
  BSR.S     L000B 
  BEQ.S     L0017 
  ADDQ.W    #8,D5 
  ADDQ.W    #3,D5 
  BRA.S     L0018 
L0017:
  MOVEQ     #2,D6 
  BSR.S     L000B 
  SWAP      D5
  MOVEQ     #$F,D6
  BSR.S     L000B 
  ADDQ.L    #8,D5 
  ADDQ.L    #3,D5 
L0018:
  SUBQ.W    #1,D5 
  BMI.S     L001A 
  MOVEQ     #1,D6 
  SWAP      D6
L0019:
  MOVE.B    -(A6),-(A5) 
  DBF       D5,L0019
  SUB.L     D6,D5 
  BPL.S     L0019 
L001A:
  CMPA.L    A6,A0 
L001B:
  BNE       L0001 
  CMP.B     #-$80,D7
  BNE.S     L001B 
  MOVEA.L   (A7)+,A0
  BSR.S     L0021 
  MOVE.L    (A7)+,D0
L001C:
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
L001D:
  MOVE.B    -(A6),D7
  ADDX.B    D7,D7 
  BRA.S     L0015 
L001E:
  DC.B      $00,' ',$00,'`',$01,'`',$03,'`' 
  DC.B      $07,'`',$0F,'`',$1F,'`',$04,$05 
  DC.B      $07,$08,$09,$0A,$0B,$0C 
L001F:
  DC.B      $00,' ',$00,'`',$00,$E0,$01,$E0 
  DC.B      $03,$E0,$05,$E0,$07,$E0,$04,$05 
  DC.B      $06,$07,$08,$08 
L0020:
  DC.B      '` ',$10,$08
L0021:
  MOVE.W    -(A0),D7
  CLR.W     (A0)
L0022:
  DBF       D7,L0023
  RTS 
L0023:
  MOVE.L    -(A0),D0
  CLR.L     (A0)
  LEA       0(A5,D0.L),A1 
  LEA       $7D00(A1),A2
L0024:
  MOVEQ     #3,D6 
L0025:
  MOVE.W    (A1)+,D0
  MOVEQ     #3,D5 
L0026:
  ADD.W     D0,D0 
  ADDX.W    D1,D1 
  ADD.W     D0,D0 
  ADDX.W    D2,D2 
  ADD.W     D0,D0 
  ADDX.W    D3,D3 
  ADD.W     D0,D0 
  ADDX.W    D4,D4 
  DBF       D5,L0026
  DBF       D6,L0025
  MOVEM.W   D1-D4,-8(A1)
  CMPA.L    A1,A2 
  BNE.S     L0024 
  BRA.S     L0022 
