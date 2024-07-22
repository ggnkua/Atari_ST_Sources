  MOVEQ     #0,D0 
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  LEA       spbuf(PC),A6
  MOVEA.L   A0,A1 
  CMPI.L    #$53507633,(A1)+
  BNE.S     .SP301 
  TST.W     (A1)
  BNE.S     .SP301 
  MOVE.L    (A1)+,D5
  MOVE.L    (A1)+,D0
  MOVE.L    (A1)+,(A7)
  MOVEA.L   A0,A2 
  ADDA.L    D0,A0 
  MOVE.L    -(A0),-(A1) 
  MOVE.L    -(A0),-(A1) 
  MOVE.L    -(A0),-(A1) 
  MOVE.L    -(A0),-(A1) 
  ADDA.L    (A7),A1 
  LEA       $192(A6),A3 
  MOVEQ     #$7F,D0 
.SP300:
  MOVE.L    (A2)+,(A3)+ 
  DBF       D0,.SP300
  SUBA.L    A2,A3 
  MOVE.L    A3,-(A7)
  BSR.S     .SP302 
  BSR       .SP312 
  MOVE.B    -(A0),D0
  ADDA.L    (A7)+,A0
  MOVE.B    D0,(A0)+
  LEA       $192(A6),A2 
  BSR       .SP313 
  BSR       .SP30D 
.SP301:
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
.SP302:
  CLR.W     D5
  MOVE.W    -(A0),D6
  LEA       4(A6),A3
  MOVE.B    D6,(A3)+
  MOVEQ     #1,D3 
  MOVEQ     #6,D4 
.SP303:
  CMP.B     D6,D3 
  BNE.S     .SP304 
  ADDQ.W    #2,D3 
.SP304:
  MOVE.B    D3,(A3)+
  ADDQ.W    #2,D3 
  DBF       D4,.SP303
  MOVEQ     #$10,D4 
  MOVE.B    -(A0),(A3)+ 
  MOVE.B    D4,(A3)+
  MOVE.B    -(A0),(A3)+ 
  MOVE.B    D4,(A3)+
  MOVE.B    -(A0),D4
  MOVE.W    D4,(A6) 
  LEA       $111(A6),A5 
  MOVE.B    -(A0),D4
  LEA       1(A5,D4.W),A3 
.SP305:
  MOVE.B    -(A0),-(A3) 
  DBF       D4,.SP305
  MOVE.B    -(A0),-(A3) 
  BEQ.S     .SP306 
  SUBA.W    D4,A0 
.SP306:
  MOVEQ     #0,D2 
  MOVE.B    -(A0),D2
  MOVE.W    D2,D3 
  MOVE.B    -(A0),D7
.SP307:
  BSR.S     .SP308 
  BSR.S     .SP308 
  DBF       D2,.SP307
  RTS 
.SP308:
  NOT.W     D4
  ADD.B     D7,D7 
  BNE.S     .SP309 
  MOVE.B    -(A0),D7
  ADDX.B    D7,D7 
.SP309:
  BCS.S     .SP30A 
  MOVE.W    D2,D0 
  SUBQ.W    #1,D3 
  SUB.W     D3,D0 
  ADD.W     D0,D0 
  ADD.W     D4,D0 
  ADD.W     D0,D0 
  NEG.W     D0
  MOVE.W    D0,-(A3)
  RTS 
.SP30A:
  MOVEQ     #2,D1 
  BSR       .SP328 
  ADD.W     D0,D0 
  BEQ.S     .SP30B 
  MOVE.B    D0,-(A3)
  MOVEQ     #2,D1 
  BSR       .SP328 
  ADD.W     D0,D0 
  MOVE.B    D0,-(A3)
  RTS 
.SP30B:
  MOVEQ     #2,D1 
  BSR       .SP328 
  MOVE.W    $C(A6),D1 
  ADD.W     D0,D0 
  BEQ.S     .SP30C 
  MOVE.W    $E(A6),D1 
.SP30C:
  OR.W      D1,D0 
  MOVE.W    D0,-(A3)
  RTS 
.SP30D:
  TST.W     D6
  BPL.S     .SP311 
  MOVEA.L   A1,A2 
  MOVEA.L   A1,A3 
  ADDA.L    4(A7),A3
.SP30E:
  MOVEQ     #3,D6 
.SP30F:
  MOVE.W    (A2)+,D0
  MOVEQ     #3,D5 
.SP310:
  ADD.W     D0,D0 
  ADDX.W    D1,D1 
  ADD.W     D0,D0 
  ADDX.W    D2,D2 
  ADD.W     D0,D0 
  ADDX.W    D3,D3 
  ADD.W     D0,D0 
  ADDX.W    D4,D4 
  DBF       D5,.SP310
  DBF       D6,.SP30F
  CMPA.L    A2,A3 
  BLT.S     .SP311 
  MOVEM.W   D1-D4,-8(A2)
  CMPA.L    A2,A3 
  BNE.S     .SP30E 
.SP311:
  RTS 
.SP312:
  MOVE.B    -(A0),-(A1) 
.SP313:
  SWAP      D5
  LEA       $10E(A6),A3 
  CMPA.L    A0,A2 
  BLT.S     .SP315 
  RTS 
.SP314:
  ADDA.W    D3,A3 
.SP315:
  ADD.B     D7,D7 
  BCC.S     .SP318 
  BEQ.S     .SP317 
.SP316:
  MOVE.W    (A3),D3 
  BMI.S     .SP314 
  BRA.S     .SP319 
.SP317:
  MOVE.B    -(A0),D7
  ADDX.B    D7,D7 
  BCS.S     .SP316 
.SP318:
  MOVE.W    -(A3),D3
  BMI.S     .SP314 
.SP319:
  EXT.W     D3
  JMP       .SP31A(PC,D3.W)
.SP31A:
  BRA.S     .SP31A 
  BRA.S     .SP325 
  BRA.S     .SP325 
  BRA.S     .SP325 
  BRA.S     .SP325 
  BRA.S     .SP325 
  BRA.S     .SP321 
  BRA.S     .SP320 
  BRA.S     .SP31C 
  BRA.S     .SP31D 
  BRA.S     .SP31B 
  BRA.S     .SP31E 
  BRA.S     .SP312 
.SP31B:
  MOVE.B    (A5),-(A1)
  BRA.S     .SP313 
.SP31C:
  BSR.S     .SP327 
  MOVE.B    1(A5,D0.W),-(A1)
  BRA.S     .SP313 
.SP31D:
  BSR.S     .SP327 
  ADD.W     (A6),D0 
  MOVE.B    1(A5,D0.W),-(A1)
  BRA.S     .SP313 
.SP31E:
  MOVEQ     #3,D1 
  BSR.S     .SP328 
  LSR.W     #1,D0 
  BCC.S     .SP31F 
  NOT.W     D0
.SP31F:
  MOVE.B    (A1),D1 
  ADD.W     D0,D1 
  MOVE.B    D1,-(A1)
  BRA.S     .SP313 
.SP320:
  LEA       -$24(A6),A4 
  BSR.S     .SP32C 
  ADDI.W    #$10,D0 
  LEA       1(A1,D0.W),A3 
  MOVE.B    -(A3),-(A1) 
  MOVE.B    -(A3),-(A1) 
  BRA       .SP313 
.SP321:
  MOVEQ     #3,D1 
  BSR.S     .SP328 
  TST.W     D0
  BEQ.S     .SP322 
  ADDQ.W    #5,D0 
  BRA.S     .SP324 
.SP322:
  MOVE.B    -(A0),D0
  BEQ.S     .SP323 
  ADDI.W    #$14,D0 
  BRA.S     .SP324 
.SP323:
  MOVEQ     #$D,D1
  BSR.S     .SP328 
  ADDI.W    #$114,D0
.SP324:
  MOVE.W    D0,D3 
  ADD.W     D3,D3 
.SP325:
  LEA       -$22(A6),A4 
  BSR.S     .SP32C 
  LSR.W     #1,D3 
  LEA       1(A1,D0.W),A3 
  MOVE.B    -(A3),-(A1) 
.SP326:
  MOVE.B    -(A3),-(A1) 
  DBF       D3,.SP326
  BRA       .SP313 
.SP327:
  MOVEQ     #0,D1 
  MOVE.B    (A3),D1 
.SP328:
  MOVEQ     #0,D0 
  CMPI.W    #7,D1 
  BPL.S     .SP32B 
.SP329:
  ADD.B     D7,D7 
  BEQ.S     .SP32A 
  ADDX.W    D0,D0 
  DBF       D1,.SP329
  RTS 
.SP32A:
  MOVE.B    -(A0),D7
  ADDX.B    D7,D7 
  ADDX.W    D0,D0 
  DBF       D1,.SP329
  RTS 
.SP32B:
  MOVE.B    -(A0),D0
  SUBQ.W    #8,D1 
  BPL.S     .SP329 
  RTS 
.SP32C:
  MOVEQ     #0,D1 
  MOVE.B    (A3),D1 
  ADDA.W    D1,A4 
  MOVE.W    (A4),D1 
  BSR.S     .SP328 
  TST.B     D6
  BEQ.S     .SP32F 
  MOVE.W    D0,D4 
  ANDI.W    #-$10,D4
  ANDI.W    #$F,D0
  BEQ.S     .SP32E 
  LSR.W     #1,D0 
  BEQ.S     .SP32D 
  ROXR.B    #1,D7 
  BCC.S     .SP32E 
  MOVE.B    D7,(A0)+
  MOVEQ     #-$80,D7
  BRA.S     .SP32E 
.SP32D:
  MOVEQ     #2,D1 
  BSR.S     .SP328 
  ADD.W     D0,D0 
  OR.W      D4,D0 
  BRA.S     .SP32F 
.SP32E:
  LEA       4(A6),A3
  OR.B      0(A3,D0.W),D4 
  MOVE.W    D4,D0 
.SP32F:
  ADD.W     $12(A4),D0
  RTS 
  DC.B      $00,$03,$00,$04,$00,$05,$00,$07 
  DC.B      $00,$08,$00,$09,$00,$0A,$00,$0B 
  DC.B      $00,$0C,$FF,$F0,$00,$00,$00,' ' 
  DC.B      $00,'`',$01,'`',$03,'`',$07,'`' 
  DC.B      $0F,'`',$1F,'`' 
spbuf:	DS.L	512

