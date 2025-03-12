	MOVEM.L   A0-A6/D1-D7,-(A7) 
	move.l	a1,a5
  MOVEA.L   A0,A1 
  BSR       .rnc111B 
  CMP.L     #$524E4301,D0 
  BNE.S     .rnc1103 
  BSR       .rnc111B 
  LEA       4(A0),A4
  LEA       0(A5,D0.L),A2 
  MOVEA.L   A2,A3 
  BSR       .rnc111B 
  LEA       0(A4,D0.L),A6 
  MOVE.B    -(A6),D3
.rnc1100:
  BSR       .rnc1106 
  ADDQ.W    #1,D5 
  CMPA.L    A4,A6 
  BLE.S     .rnc1102 
  BSR       .rnc110E 
  BSR       .rnc1114 
  SUBQ.W    #1,D6 
  LEA       0(A3,D7.W),A0 
  EXT.L     D6
  ADDA.L    D6,A0 
  TST.W     D7
  BNE.S     .rnc1101 
  LEA       1(A3),A0
.rnc1101:
  MOVE.B    -(A0),-(A3) 
  DBF       D6,.rnc1101
  BRA.S     .rnc1100 
.rnc1102:
  MOVE.L    A2,D0 
  SUB.L     A3,D0 
  MOVEA.L   A3,A0 
  BRA       .rnc111D 
.rnc1103:
  MOVEQ     #0,D0 
  BRA       .rnc111D 
.rnc1104:
  LSL.B     #1,D3 
  BNE.S     .rnc1105 
  MOVE.B    -(A6),D3
  ROXL.B    #1,D3 
.rnc1105:
  RTS 
.rnc1106:
  MOVEQ     #-1,D5
  BSR       .rnc1104 
  BCC.S     .rnc110C 
  MOVEQ     #0,D5 
  BSR       .rnc1104 
  BCC.S     .rnc110A 
  LEA       .rnc110D(PC),A0
  MOVEQ     #3,D1 
.rnc1107:
  CLR.W     D5
  MOVE.B    0(A0,D1.W),D0 
  EXT.W     D0
  MOVEQ     #-1,D2
  LSL.W     D0,D2 
  NOT.W     D2
  SUBQ.W    #1,D0 
.rnc1108:
  BSR       .rnc1104 
  ROXL.W    #1,D5 
  DBF       D0,.rnc1108
  TST.W     D1
  BEQ.S     .rnc1109 
  CMP.W     D5,D2 
  DBNE      D1,.rnc1107
.rnc1109:
  MOVE.B    4(A0,D1.W),D0 
  EXT.W     D0
  ADD.W     D0,D5 
.rnc110A:
  MOVE.W    D5,-(A7)
.rnc110B:
  MOVE.B    -(A6),-(A3) 
  DBF       D5,.rnc110B
  MOVE.W    (A7)+,D5
.rnc110C:
  RTS 
.rnc110D:
  DC.B      $0A,$03,$02,$02,$0E,$07,$04,$01 
.rnc110E:
  LEA       .rnc1113(PC),A0
  MOVEQ     #3,D0 
.rnc110F:
  BSR       .rnc1104 
  BCC.S     .rnc1110 
  DBF       D0,.rnc110F
.rnc1110:
  CLR.W     D6
  ADDQ.W    #1,D0 
  MOVE.B    0(A0,D0.W),D1 
  BEQ.S     .rnc1112 
  EXT.W     D1
  SUBQ.W    #1,D1 
.rnc1111:
  BSR       .rnc1104 
  ROXL.W    #1,D6 
  DBF       D1,.rnc1111
.rnc1112:
  MOVE.B    5(A0,D0.W),D1 
  EXT.W     D1
  ADD.W     D1,D6 
  RTS 
.rnc1113:
  DC.B      $0A,$02,$01,$00,$00,$0A,$06,$04 
  DC.B      $03,$02 
.rnc1114:
  MOVEQ     #0,D7 
  CMP.W     #2,D6 
  BEQ.S     .rnc1118 
  MOVEQ     #1,D0 
.rnc1115:
  BSR       .rnc1104 
  BCC.S     .rnc1116 
  DBF       D0,.rnc1115
.rnc1116:
  ADDQ.W    #1,D0 
  LEA       .rnc111A(PC),A0
  MOVE.B    0(A0,D0.W),D1 
  EXT.W     D1
.rnc1117:
  BSR       .rnc1104 
  ROXL.W    #1,D7 
  DBF       D1,.rnc1117
  LSL.W     #1,D0 
  ADD.W     4(A0,D0.W),D7 
  RTS 
.rnc1118:
  MOVEQ     #5,D0 
  CLR.W     D1
  BSR       .rnc1104 
  BCC.S     .rnc1119 
  MOVEQ     #8,D0 
  MOVEQ     #$40,D1 
.rnc1119:
  BSR       .rnc1104 
  ROXL.W    #1,D7 
  DBF       D0,.rnc1119
  ADD.W     D1,D7 
  RTS 
.rnc111A:
  DC.B      $0B,$04,$07,$00,$01,' ',$00,$00 
  DC.B      $00,' ',$00,$00 
.rnc111B:
  MOVEQ     #3,D1 
.rnc111C:
  LSL.L     #8,D0 
  MOVE.B    (A0)+,D0
  DBF       D1,.rnc111C
  RTS 
.rnc111D:
  MOVE.L    A0,D2 
  SUB.L     A1,D2 
  MOVE.L    D0,D1 
  BEQ.S     .rnc1120 
.rnc111E:
  MOVE.B    (A0)+,(A1)+ 
  SUBQ.L    #1,D1 
  BNE.S     .rnc111E 
.rnc111F:
  CLR.B     (A1)+ 
  SUBQ.L    #1,D2 
  BNE.S     .rnc111F 
.rnc1120:
  MOVEM.L   (A7)+,A0-A6/D1-D7 
  RTS 
