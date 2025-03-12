	movem.l	d0-a6,-(a7)
  SUBQ.W    #8,A0 
  MOVEA.L   -(A0),A2
  ADDA.L    A1,A2 
  MOVE.L    -(A0),D0
.grem02:
  ADD.L     D0,D0 
  BNE.S     .grem03 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem03:
  BCS.S     .grem0A 
  MOVEQ     #3,D1 
  MOVEQ     #0,D3 
  ADD.L     D0,D0 
  BNE.S     .grem04 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem04:
  BCS.S     .grem06 
  MOVEQ     #1,D3 
  MOVEQ     #8,D1 
  BRA.S     .grem0E 
.grem05:
  MOVEQ     #8,D1 
  MOVEQ     #8,D3 
.grem06:
  BSR.S     .grem11 
  ADD.W     D2,D3 
.grem07:
  MOVEQ     #7,D1 
.grem08:
  ADD.L     D0,D0 
  BNE.S     .grem09 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem09:
  ADDX.W    D2,D2 
  DBF       D1,.grem08
  MOVE.B    D2,-(A2)
  DBF       D3,.grem07
  BRA.S     .grem10 
.grem0A:
  MOVEQ     #0,D2 
  ADD.L     D0,D0 
  BNE.S     .grem0B 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem0B:
  ADDX.W    D2,D2 
  ADD.L     D0,D0 
  BNE.S     .grem0C 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem0C:
  ADDX.W    D2,D2 
  CMPI.B    #2,D2 
  BLT.S     .grem0D 
  CMPI.B    #3,D2 
  BEQ.S     .grem05 
  MOVEQ     #8,D1 
  BSR.S     .grem11 
  MOVE.W    D2,D3 
  MOVE.W    #$C,D1
  BRA.S     .grem0E 
.grem0D:
  MOVEQ     #2,D3 
  ADD.W     D2,D3 
  MOVE.W    #9,D1 
  ADD.W     D2,D1 
.grem0E:
  BSR.S     .grem11 
  LEA       1(A2,D2.W),A3 
.grem0F:
  MOVE.B    -(A3),-(A2) 
  DBF       D3,.grem0F
.grem10:
  CMPA.L    A2,A1 
  BLT       .grem02 
	movem.l	(a7)+,d0-a6
  RTS 
.grem11:
  SUBQ.W    #1,D1 
  CLR.W     D2
.grem12:
  ADD.L     D0,D0 
  BNE.S     .grem13 
  MOVE.L    -(A0),D0
  MOVE      #-1,CCR 
  ADDX.L    D0,D0 
.grem13:
  ADDX.W    D2,D2 
  DBF       D1,.grem12
  RTS 
