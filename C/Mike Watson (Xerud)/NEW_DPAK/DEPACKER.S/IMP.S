  MOVEM.L   d0-a6,-(A7) 
  CMPI.L    #$494D5021,(A0) 
  BNE.S     .imp02 
  MOVEA.L   A0,A3 
  MOVEA.L   A1,A4 
  MOVEA.L   A1,A5 
  TST.L     (A0)+ 
  ADDA.L    (A0)+,A4
  ADDA.L    (A0)+,A3
  MOVEA.L   A3,A2 
  MOVE.L    (A2)+,-(A0) 
  MOVE.L    (A2)+,-(A0) 
  MOVE.L    (A2)+,-(A0) 
  MOVE.L    (A2)+,D2
  MOVE.W    (A2)+,D3
  BMI.S     .imp00 
  SUBQ.L    #1,A3 
.imp00:
  LEA       -$1C(A7),A7 
  MOVEA.L   A7,A1 
  MOVEQ     #6,D0 
.imp01:
  MOVE.L    (A2)+,(A1)+ 
  DBF       D0,.imp01
  MOVEA.L   A7,A1 
  BRA       .imp03 
.imp02:
  MOVEQ     #0,D0 
  RTS 
.imp03:
  TST.L     D2
  BEQ.S     .imp05 
.imp04:
  MOVE.B    -(A3),-(A4) 
  SUBQ.L    #1,D2 
  BNE.S     .imp04 
.imp05:
  CMPA.L    A4,A5 
  BCS.S     .imp07 
  LEA       $1C(A7),A7
  MOVEQ     #-1,D0
  CMPA.L    A3,A5 
  BEQ.S     .imp06 
  MOVEQ     #0,D0 
.imp06:
  MOVEM.L   (A7)+,d0-a6 
  RTS 
.imp07:
  ADD.B     D3,D3 
  BNE.S     .imp08 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp08:
  BCC.S     .imp14 
  ADD.B     D3,D3 
  BNE.S     .imp09 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp09:
  BCC.S     .imp13 
  ADD.B     D3,D3 
  BNE.S     .imp0A 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp0A:
  BCC.S     .imp12 
  ADD.B     D3,D3 
  BNE.S     .imp0B 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp0B:
  BCC.S     .imp11 
  MOVEQ     #0,D4 
  ADD.B     D3,D3 
  BNE.S     .imp0C 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp0C:
  BCC.S     .imp0D 
  MOVE.B    -(A3),D4
  MOVEQ     #3,D0 
  SUBQ.B    #1,D4 
  BRA.S     .imp15 
.imp0D:
  ADD.B     D3,D3 
  BNE.S     .imp0E 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp0E:
  ADDX.B    D4,D4 
  ADD.B     D3,D3 
  BNE.S     .imp0F 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp0F:
  ADDX.B    D4,D4 
  ADD.B     D3,D3 
  BNE.S     .imp10 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp10:
  ADDX.B    D4,D4 
  ADDQ.B    #5,D4 
  MOVEQ     #3,D0 
  BRA.S     .imp15 
.imp11:
  MOVEQ     #4,D4 
  MOVEQ     #3,D0 
  BRA.S     .imp15 
.imp12:
  MOVEQ     #3,D4 
  MOVEQ     #2,D0 
  BRA.S     .imp15 
.imp13:
  MOVEQ     #2,D4 
  MOVEQ     #1,D0 
  BRA.S     .imp15 
.imp14:
  MOVEQ     #1,D4 
  MOVEQ     #0,D0 
.imp15:
  MOVEQ     #0,D5 
  MOVE.W    D0,D1 
  ADD.B     D3,D3 
  BNE.S     .imp16 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp16:
  BCC.S     .imp19 
  ADD.B     D3,D3 
  BNE.S     .imp17 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp17:
  BCC.S     .imp18 
  MOVE.B    .imp23(PC,D0.W),D5 
  ADDQ.B    #8,D0 
  BRA.S     .imp19 
.imp18:
  MOVEQ     #2,D5 
  ADDQ.B    #4,D0 
.imp19:
  MOVE.B    .imp24(PC,D0.W),D0 
.imp1A:
  ADD.B     D3,D3 
  BNE.S     .imp1B 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp1B:
  ADDX.W    D2,D2 
  SUBQ.B    #1,D0 
  BNE.S     .imp1A 
  ADD.W     D5,D2 
  MOVEQ     #0,D5 
  MOVEA.L   D5,A2 
  MOVE.W    D1,D0 
  ADD.B     D3,D3 
  BNE.S     .imp1C 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp1C:
  BCC.S     .imp1F 
  ADD.W     D1,D1 
  ADD.B     D3,D3 
  BNE.S     .imp1D 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp1D:
  BCC.S     .imp1E 
  MOVEA.W   8(A1,D1.W),A2 
  ADDQ.B    #8,D0 
  BRA.S     .imp1F 
.imp1E:
  MOVEA.W   0(A1,D1.W),A2 
  ADDQ.B    #4,D0 
.imp1F:
  MOVE.B    $10(A1,D0.W),D0 
.imp20:
  ADD.B     D3,D3 
  BNE.S     .imp21 
  MOVE.B    -(A3),D3
  ADDX.B    D3,D3 
.imp21:
  ADDX.L    D5,D5 
  SUBQ.B    #1,D0 
  BNE.S     .imp20 
  ADDQ.W    #1,A2 
  ADDA.L    D5,A2 
  ADDA.L    A4,A2 
.imp22:
  MOVE.B    -(A2),-(A4) 
  DBF       D4,.imp22
  BRA       .imp03 
.imp23:
  DC.B      $06,$0A,$0A,$12 
.imp24:
  DC.B      $01,$01,$01,$01,$02,$03,$03,$04 
  DC.B      $04,$05,$07,$0E 
