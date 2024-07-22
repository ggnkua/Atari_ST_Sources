  MOVEM.L   A0-A6/D0-D7,-(A7) 
	move.l	a1,a5
	moveq	#0,d0
	move.l	a0,a1
  MOVE.L    D0,D4 
  BSR       .rnc237 
  MOVEQ     #0,D1 
  CMPI.L    #$524E4302,D0 
  BNE       .rnc235 
  BSR       .rnc237 
  MOVE.L    D0,(A7) 
  LEA       $A(A0),A3 
  LEA       0(A5,D0.L),A6 
  BSR       .rnc237 
  LEA       0(A3,D0.L),A4 
  MOVEA.L   A3,A1 
  BSR       .rnc239 
  LEA       -6(A3),A0 
  BSR       .rnc237 
  MOVEQ     #-1,D1
  CMP.W     D2,D0 
  BNE       .rnc235 
  SWAP      D0
  MOVE.W    D0,-(A7)
  CLR.W     -(A7) 
  CMPA.L    A4,A5 
  BCC.S     .rnc205 
  MOVEQ     #0,D0 
  MOVE.B    -2(A3),D0 
  LEA       0(A6,D0.L),A0 
  CMPA.L    A4,A0 
  BLS.S     .rnc205 
  ADDQ.W    #2,A7 
  MOVE.L    A4,D0 
  BTST      #0,D0 
  BEQ.S     .rnc200 
  ADDQ.W    #1,A4 
  ADDQ.W    #1,A0 
.rnc200:
  MOVE.L    A0,D0 
  BTST      #0,D0 
  BEQ.S     .rnc201 
  ADDQ.W    #1,A0 
.rnc201:
  MOVEQ     #0,D0 
.rnc202:
  CMPA.L    A0,A6 
  BEQ.S     .rnc203 
  MOVE.B    -(A0),D1
  MOVE.W    D1,-(A7)
  ADDQ.B    #1,D0 
  BRA.S     .rnc202 
.rnc203:
  MOVE.W    D0,-(A7)
  ADDA.L    D0,A0 
  MOVE.W    D4,-(A7)
.rnc204:
  LEA       -$20(A4),A4 
  MOVEM.L   (A4),D0-D7
  MOVEM.L   D0-D7,-(A0) 
  CMPA.L    A3,A4 
  BHI.S     .rnc204 
  SUBA.L    A4,A3 
  ADDA.L    A0,A3 
  MOVE.W    (A7)+,D4
.rnc205:
  MOVEQ     #-$80,D7
  ADD.B     D7,D7 
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  ADD.B     D7,D7 
  BRA       .rnc223 
.rnc206:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc210 
.rnc207:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc213 
.rnc208:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc214 
.rnc209:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc215 
.rnc20A:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc217 
.rnc20B:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc218 
.rnc20C:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc219 
.rnc20D:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc21B 
.rnc20E:
  MOVEQ     #3,D5 
.rnc20F:
  ADD.B     D7,D7 
  BEQ.S     .rnc206 
.rnc210:
  ADDX.W    D6,D6 
  DBF       D5,.rnc20F
  ADDQ.W    #2,D6 
.rnc211:
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  DBF       D6,.rnc211
  ROR.W     #1,D4 
  BRA.S     .rnc223 
.rnc212:
  ADD.B     D7,D7 
  BEQ.S     .rnc207 
.rnc213:
  ADDX.W    D5,D5 
  ADD.B     D7,D7 
  BEQ.S     .rnc208 
.rnc214:
  BCC.S     .rnc216 
  SUBQ.W    #1,D5 
  ADD.B     D7,D7 
  BEQ.S     .rnc209 
.rnc215:
  ADDX.W    D5,D5 
  CMPI.B    #9,D5 
  BEQ.S     .rnc20E 
.rnc216:
  ADD.B     D7,D7 
  BEQ.S     .rnc20A 
.rnc217:
  BCC.S     .rnc21D 
  ADD.B     D7,D7 
  BEQ.S     .rnc20B 
.rnc218:
  ADDX.W    D6,D6 
  ADD.B     D7,D7 
  BEQ.S     .rnc20C 
.rnc219:
  BCS.S     .rnc229 
  TST.W     D6
  BNE.S     .rnc21C 
  ADDQ.W    #1,D6 
.rnc21A:
  ADD.B     D7,D7 
  BEQ.S     .rnc20D 
.rnc21B:
  ADDX.W    D6,D6 
.rnc21C:
  ROL.W     #8,D6 
.rnc21D:
  MOVE.B    (A3)+,D6
  MOVEA.L   A5,A0 
  SUBA.W    D6,A0 
  SUBQ.W    #1,A0 
  LSR.W     #1,D5 
  BCC.S     .rnc21E 
  MOVE.B    (A0)+,(A5)+ 
.rnc21E:
  SUBQ.W    #1,D5 
  TST.W     D6
  BNE.S     .rnc220 
  MOVE.B    (A0),D6 
.rnc21F:
  MOVE.B    D6,(A5)+
  MOVE.B    D6,(A5)+
  DBF       D5,.rnc21F
  BRA.S     .rnc223 
.rnc220:
  MOVE.B    (A0)+,(A5)+ 
  MOVE.B    (A0)+,(A5)+ 
  DBF       D5,.rnc220
  BRA.S     .rnc223 
.rnc221:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BCS.S     .rnc225 
.rnc222:
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  ROR.W     #1,D4 
.rnc223:
  ADD.B     D7,D7 
  BCS.S     .rnc224 
  MOVE.B    (A3)+,D0
  EOR.B     D4,D0 
  MOVE.B    D0,(A5)+
  ROR.W     #1,D4 
  ADD.B     D7,D7 
  BCC.S     .rnc222 
.rnc224:
  BEQ.S     .rnc221 
.rnc225:
  MOVEQ     #2,D5 
  MOVEQ     #0,D6 
  ADD.B     D7,D7 
  BEQ.S     .rnc22C 
.rnc226:
  BCC       .rnc212 
  ADD.B     D7,D7 
  BEQ.S     .rnc22D 
.rnc227:
  BCC.S     .rnc21D 
  ADDQ.W    #1,D5 
  ADD.B     D7,D7 
  BEQ.S     .rnc22E 
.rnc228:
  BCC       .rnc216 
  MOVE.B    (A3)+,D5
  BEQ.S     .rnc231 
  ADDQ.W    #8,D5 
  BRA       .rnc216 
.rnc229:
  ADD.B     D7,D7 
  BEQ.S     .rnc22F 
.rnc22A:
  ADDX.W    D6,D6 
  ORI.W     #4,D6 
  ADD.B     D7,D7 
  BEQ.S     .rnc230 
.rnc22B:
  BCS       .rnc21C 
  BRA       .rnc21A 
.rnc22C:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc226 
.rnc22D:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc227 
.rnc22E:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc228 
.rnc22F:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc22A 
.rnc230:
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
  BRA.S     .rnc22B 
.rnc231:
  ADD.B     D7,D7 
  BNE.S     .rnc232 
  MOVE.B    (A3)+,D7
  ADDX.B    D7,D7 
.rnc232:
  BCS.S     .rnc223 
  MOVE.W    (A7)+,D0
  BEQ.S     .rnc234 
  MOVEA.L   A5,A0 
.rnc233:
  MOVE.W    (A7)+,D1
  MOVE.B    D1,(A0)+
  SUBQ.B    #1,D0 
  BNE.S     .rnc233 
.rnc234:
  MOVE.L    2(A7),D0
  SUBA.L    D0,A5 
  MOVEA.L   A5,A1 
  BSR.S     .rnc239 
  MOVEQ     #-2,D1
  CMP.W     (A7)+,D2
  BEQ.S     .rnc236 
.rnc235:
  MOVE.L    D1,(A7) 
.rnc236:
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTS 
.rnc237:
  MOVEQ     #3,D1 
.rnc238:
  LSL.L     #8,D0 
  MOVE.B    (A0)+,D0
  DBF       D1,.rnc238
  RTS 
.rnc239:
  LEA       -$200(A7),A7
  MOVEA.L   A7,A0 
  MOVEQ     #0,D3 
.rnc23A:
  MOVE.L    D3,D1 
  MOVEQ     #7,D2 
.rnc23B:
  LSR.W     #1,D1 
  BCC.S     .rnc23C 
  EORI.W    #-$5FFF,D1
.rnc23C:
  DBF       D2,.rnc23B
  MOVE.W    D1,(A0)+
  ADDQ.B    #1,D3 
  BNE.S     .rnc23A 
  MOVEQ     #0,D2 
.rnc23D:
  MOVE.B    (A1)+,D1
  EOR.B     D1,D2 
  MOVE.W    D2,D1 
  ANDI.W    #$FF,D2 
  ADD.W     D2,D2 
  MOVE.W    0(A7,D2.W),D2 
  LSR.W     #8,D1 
  EOR.B     D1,D2 
  SUBQ.L    #1,D0 
  BNE.S     .rnc23D 
  LEA       $200(A7),A7 
  RTS 
