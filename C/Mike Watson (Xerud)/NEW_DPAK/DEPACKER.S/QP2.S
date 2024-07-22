	movem.l	d0-a6,-(a7)
  MOVEA.L   A1,A6 
  LEA       .qp229(PC),A2
  MOVEQ     #3,D0 
.qp200:
  CMPM.L    (A0)+,(A2)+ 
  BNE       .qp21D 
  DBF       D0,.qp200
  MOVEA.L   A1,A2 
  ADDA.L    (A0)+,A2
  MOVE.L    (A0)+,D7
  MOVEQ     #0,D6 
.qp201:
  ADD.L     D6,D6 
  BNE.S     .qp202 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp202:
  BCS       .qp211 
  ADD.L     D6,D6 
  BNE.S     .qp203 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp203:
  BCS       .qp210 
  MOVEQ     #0,D2 
  ADD.L     D6,D6 
  BNE.S     .qp204 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp204:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp205 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp205:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp206 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp206:
  ADDX.B    D2,D2 
.qp207:
  ADD.L     D6,D6 
  BNE.S     .qp208 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp208:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp209 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp209:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20A 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20A:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20B 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20B:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20C 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20C:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20D 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20D:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20E 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20E:
  ADDX.B    D0,D0 
  ADD.L     D6,D6 
  BNE.S     .qp20F 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp20F:
  ADDX.B    D0,D0 
  MOVE.B    D0,(A1)+
  DBF       D2,.qp207
  CMPA.L    A2,A1 
  BCS       .qp201 
  BRA.S     .qp21C 
.qp210:
  MOVEQ     #7,D1 
  MOVEQ     #1,D2 
  BRA.S     .qp217 
.qp211:
  ADD.L     D6,D6 
  BNE.S     .qp212 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp212:
  BCS.S     .qp215 
  ADD.L     D6,D6 
  BNE.S     .qp213 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp213:
  BCS.S     .qp214 
  MOVEQ     #8,D1 
  MOVEQ     #2,D2 
  BRA.S     .qp217 
.qp214:
  MOVEQ     #9,D1 
  MOVEQ     #3,D2 
  BRA.S     .qp217 
.qp215:
  ADD.L     D6,D6 
  BNE.S     .qp216 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp216:
  BCS.S     .qp21B 
  BSR.S     .qp220 
  ADDQ.W    #2,D2 
  MOVEQ     #$B,D1
.qp217:
  MOVEQ     #0,D0 
.qp218:
  ADD.L     D6,D6 
  BNE.S     .qp219 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp219:
  ADDX.W    D0,D0 
  DBF       D1,.qp218
  LEA       -1(A1),A3 
  SUBA.W    D0,A3 
.qp21A:
  MOVE.B    (A3)+,(A1)+ 
  DBF       D2,.qp21A
  CMPA.L    A2,A1 
  BCS       .qp201 
  BRA.S     .qp21C 
.qp21B:
  BSR.S     .qp220 
  ADDQ.W    #8,D2 
  BRA       .qp207 
.qp21C:
  BNE.S     .qp21F 
  MOVEA.L   A6,A0 
  MOVEA.L   A2,A1 
  MOVE.L    D7,D0 
  BNE.S     .qp21E 
	movem.l	(a7)+,d0-a6
  RTS 
.qp21D:
  MOVEQ     #1,D0 
  RTS 
.qp21E:
  MOVEQ     #2,D0 
  RTS 
.qp21F:
  MOVEQ     #3,D0 
  RTS 
.qp220:
  MOVEQ     #0,D2 
  ADD.L     D6,D6 
  BNE.S     .qp221 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp221:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp222 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp222:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp223 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp223:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp224 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp224:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp225 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp225:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp226 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp226:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp227 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp227:
  ADDX.B    D2,D2 
  ADD.L     D6,D6 
  BNE.S     .qp228 
  MOVE.L    (A0)+,D6
  EOR.L     D6,D7 
  MOVE      #$10,CCR
  ADDX.L    D6,D6 
.qp228:
  ADDX.B    D2,D2 
  RTS 
.qp229:
  SUBQ.W    #8,(A0) 
  DC.B      'AC2-JMP('
  DC.B      'C)1989',$00,$00
	even