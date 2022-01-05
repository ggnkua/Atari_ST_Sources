	SECTION CSECT
	SECTION TEXT 

  BRA       L0000 
  BRA       L0003 
  BRA       L0005 
  BRA       L0006 
  BRA       L0007 
L0000:
  MOVE.W    #$80,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  TST.W     D0
  BMI       L0002 
  MOVE.W    #1,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #9,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #$8B,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  MOVE.W    #1,-(A7)
  MOVE.W    #$84,-(A7)
  TRAP      #$E 
  ADDQ.L    #4,A7 
  MOVE.W    #0,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #$89,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  BSR       L0008 
L0001:
  MOVEQ     #0,D0 
L0002:
  RTS 
L0003:
  PEA       (A0)
  LEA       L00C3,A0
  BSR       L0004 
  LEA       L00C4,A0
  BSR       L0004 
  LEA       L00C5,A0
  BSR       L0004 
  LEA       L00C6,A0
  BSR       L0004 
  LEA       L00C7,A0
  BSR       L0004 
  LEA       L00C8,A0
  BSR       L0004 
  MOVEA.L   (A7)+,A6
  JSR       L0022 
  JSR       L0029 
  BSR       L0009 
  MOVE.W    L00C0,D0
  BSR       L000A 
  RTS 
L0004:
  CLR.L     (A0)+ 
  CLR.W     (A0)+ 
  CLR.W     (A0)+ 
  CLR.W     (A0)+ 
  CLR.L     (A0)+ 
  CLR.W     (A0)+ 
  RTS 
L0005:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  LEA       L00BF,A0
  MOVE.L    $134.W,(A0)+
  MOVE.B    $FFFFFA07.W,(A0)+ 
  MOVE.B    $FFFFFA13.W,(A0)+ 
  MOVE.B    $FFFFFA19.W,(A0)+ 
  MOVE.B    $FFFFFA1F.W,(A0)+ 
  BSR       L0009 
  MOVE.B    #$C,$FFFF8900.W 
  MOVE.B    #-$50,$FFFF8901.W 
  LEA       L000B(PC),A0
  MOVE.L    A0,$134.W 
  CLR.B     $FFFFFA19.W 
  MOVE.B    #1,$FFFFFA1F.W
  MOVE.B    #8,$FFFFFA19.W
  BSET      #5,$FFFFFA07.W
  BSET      #5,$FFFFFA13.W
  BCLR      #3,$FFFFFA17.W
  MOVE      (A7)+,SR
  RTS 
L0006:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  LEA       L00BF,A0
  MOVE.L    (A0)+,$134.W
  MOVE.B    (A0)+,$FFFFFA07.W 
  MOVE.B    (A0)+,$FFFFFA13.W 
  MOVE.B    (A0)+,$FFFFFA19.W 
  MOVE.B    (A0)+,$FFFFFA1F.W 
  CLR.W     $FFFF8900.W 
  MOVE      (A7)+,SR
  RTS 
L0007:
  MOVE.W    #1,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #8,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$8B,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  MOVE.W    #0,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$89,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  MOVE.W    #$81,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  BRA       L0001 
L0008:
  MOVE.W    #1,-(A7)
  PEA       $1FF.W
  PEA       L00C1 
  MOVE.W    #$6E,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  BSR       L001D 
  MOVE.L    $FFFFA204.W,D0
  RTS 
L0009:
  MOVE.L    #L00CF,D0 
  MOVEQ     #0,D1 
  MOVE.W    L00BC,D1
  LEA       L00BD,A0
  MOVE.W    (A0,D1.W*2),D1
  LSL.L     #2,D1 
  BSET      #7,$FFFF8901.W
  ADD.L     D0,D1 
  MOVE.B    D0,$FFFF8907.W
  LSR.L     #8,D0 
  MOVE.B    D0,$FFFF8905.W
  LSR.L     #8,D0 
  MOVE.B    D0,$FFFF8903.W
  MOVE.B    D1,$FFFF8913.W
  LSR.L     #8,D1 
  MOVE.B    D1,$FFFF8911.W
  LSR.L     #8,D1 
  MOVE.B    D1,$FFFF890F.W
  RTS 
L000A:
  MOVE.L    A0,-(A7)
  LEA       L00C9,A0
  MOVE.W    D0,2(A0)
  LEA       L00CA,A0
  MOVE.W    D0,2(A0)
  LEA       L00CB,A0
  MOVE.W    D0,2(A0)
  LEA       L00CC,A0
  MOVE.W    D0,2(A0)
  MOVEA.L   (A7)+,A0
  RTS 
  MOVE.L    A0,-(A7)
  LEA       L00CD,A0
  MOVE.W    D0,2(A0)
  LEA       L00CE,A0
  MOVE.W    D0,2(A0)
  MOVEA.L   (A7)+,A0
  RTS 
L000B:
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  MOVE      #$2700,SR 
  BSR       L0009 
  BSR       L001E 
  MOVE.L    #$747261,$FFFFA204.W
  LEA       $FFFFA200.W,A6
  BSR       L001D 
  MOVE.L    $FFFFA204.W,D0
  MOVE.W    #0,L00BE
  LEA       L00C3,A0
  LEA       L00C9,A1
  MOVEQ     #6,D0 
  MOVE.L    D0,$FFFFA204.W
  SUBQ.W    #1,D0 
L000C:
  MOVEM.L   A0-A1/D0,-(A7)
  MOVE.W    L00BE,D0
  BSR       L000D 
  ADDQ.W    #1,L00BE
  MOVEM.L   (A7)+,A0-A1/D0
  LEA       $10(A0),A0
  LEA       $26(A1),A1
  DBF       D0,L000C
  JSR       L0029 
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTE 
L000D:
  BSR       L001D 
  MOVE.L    4(A6),D6
  ANDI.W    #-2,D6
  EXT.L     D6
  MOVEA.L   0(A0),A3
  MOVE.W    L00C2,D1
  BTST      D0,D1 
  BEQ.S     L000E 
  ST        $A(A0)
  TAS       0(A0) 
  BEQ       L0010 
  ADDA.L    D6,A3 
  ASR.L     #1,D6 
  MOVEQ     #0,D1 
  MOVE.W    4(A0),D1
  SUB.L     D6,D1 
  BPL.S     L000F 
  MOVEQ     #0,D2 
  MOVE.W    $E(A0),D2 
  BEQ.S     L000E 
  CMP.W     #1,D2 
  BEQ.S     L000E 
  MOVEA.L   $A(A0),A3 
  NEG.L     D1
  DIVU      D2,D1 
  SWAP      D1
  EXT.L     D1
  SUB.L     D1,D2 
  LEA       (A3,D1.W*2),A3
  MOVE.L    D2,D1 
  BRA.S     L000F 
L000E:
  MOVE.W    #1,D1 
  MOVEA.L   $A(A0),A3 
  MOVE.W    D1,$E(A0) 
L000F:
  MOVE.L    A3,0(A0)
  MOVE.W    D1,4(A0)
L0010:
  MOVEQ     #0,D1 
  MOVE.W    0(A1),D1
  ADD.W     4(A1),D1
  TST.L     D1
  BPL.S     L0011 
  MOVEQ     #0,D1 
L0011:
  CMP.L     #$7FFF,D1 
  BLT.S     L0012 
  MOVE.W    #$7FFF,D1 
L0012:
  MOVE.W    D1,0(A1)
  MOVE.W    8(A0),D0
  MOVE.W    #$7FFF,D2 
  SUB.W     D1,D2 
  MULU      D0,D1 
  MULU      D0,D2 
  SWAP      D1
  SWAP      D2
  MOVE.W    2(A1),D7
  MULU      D7,D1 
  MULU      D7,D2 
  LSL.L     #2,D1 
  LSL.L     #2,D2 
  BSR       L001E 
  MOVE.L    D2,4(A6)
  BSR       L001E 
  MOVE.L    D1,4(A6)
  MOVEQ     #0,D0 
  MOVEQ     #0,D2 
  MOVE.W    6(A0),D0
  CMP.W     #$6B,D0 
  BLT.S     L0013 
  MOVE.L    #$24665268,D2 
  DIVU.L    D0,D2 
L0013:
  BSR       L001E 
  MOVE.L    D2,4(A6)
  CLR.L     4(A6) 
  BSR       L001D 
  MOVE.L    4(A6),D0
  MOVE.W    D0,D3 
  ASR.W     #2,D0 
  ADDQ.W    #3,D0 
  MOVE.W    D0,D2 
  BSR       L001E 
  MOVE.L    D0,4(A6)
  LEA       6(A6),A5
  TST.L     D2
  BLE       L0016 
  MOVE.W    4(A0),D3
  CMP.W     D3,D2 
  BLT       L001A 
  CMPI.W    #1,$E(A0) 
  BLE       L0017 
  MOVE.W    $E(A0),D3 
  MOVE.W    4(A0),D0
L0014:
  MOVE.W    D0,D4 
  BSR       L001A 
  SUB.W     D4,D2 
  MOVEA.L   $A(A0),A3 
  CMP.W     D3,D2 
  BLE       L0015 
  MOVE.W    D3,D0 
  BRA       L0014 
L0015:
  MOVE.W    D2,D0 
  BSR       L001A 
L0016:
  RTS 
L0017:
  MOVE.W    4(A0),D0
  SUB.W     D0,D2 
  BSR       L001A 
  MOVEA.L   $A(A0),A3 
  MOVE.W    D2,D0 
  SUBQ.W    #1,D0 
  BMI       L0019 
L0018:
  MOVE.W    (A3),(A5) 
  DBF       D0,L0018
L0019:
  RTS 
L001A:
  SUBQ.W    #1,D0 
  BMI.S     L001C 
L001B:
  MOVE.W    (A3)+,(A5)
  DBF       D0,L001B
L001C:
  RTS 
L001D:
  BTST      #0,$FFFFA202.W
  BEQ.S     L001D 
  RTS 
L001E:
  BTST      #1,$FFFFA202.W
  BEQ.S     L001E 
  RTS 
L001F:
  MOVE.W    D0,-(A7)
  MOVE.W    6(A7),D0
  BTST      #15,D0
  BNE.S     L0020 
  NOT.W     D0
  AND.W     D0,L00C2
  BRA.S     L0021 
L0020:
  OR.W      D0,L00C2
L0021:
  MOVE.W    (A7)+,D0
  RTS 
L0022:
  MOVE.L    A6,L00B1
  LEA       $3B6(A6),A0 
  CMPM.B    (A0)+,(A0)+ 
  BLS.S     L0023 
  CLR.B     -1(A0)
L0023:
  MOVEQ     #$7F,D0 
  MOVEQ     #0,D1 
L0024:
  CMP.B     (A0)+,D1
  BHI.S     L0025 
  MOVE.B    -1(A0),D1 
L0025:
  DBF       D0,L0024
  ADDQ.L    #1,D1 
  MOVEQ     #$A,D0
  LSL.L     D0,D1 
  LEA       (A6),A0 
  LEA       $2A(A0),A1
  LEA       $43C(A0),A0 
  ADDA.L    D1,A0 
  LEA       L00A7(PC),A2
  MOVEQ     #$1E,D0 
  MOVEQ     #0,D2 
L0026:
  MOVE.L    A0,(A2)+
  MOVEQ     #0,D1 
  MOVE.W    (A1),D1 
  BEQ.S     L0027 
  LEA       (A0,D1.L*2),A0
  ADDQ.W    #1,D2 
L0027:
  LEA       $1E(A1),A1
  DBF       D0,L0026
  MOVE.B    #6,L00B4
  MOVE.W    #$7D,L00BC
  MOVEQ     #0,D0 
  LEA       L00C3,A0
  MOVE.W    D0,8(A0)
  MOVE.W    D0,$18(A0)
  MOVE.W    D0,$28(A0)
  MOVE.W    D0,$38(A0)
  CLR.B     L00B5 
  CLR.B     L00A8 
  CLR.W     L00AB 
  CLR.L     L00A8 
  MOVE.L    #6,L00A9
  MOVE.W    #0,L00AC
  MOVE.W    #$F,L00AD 
  CLR.L     L00B0 
  CLR.L     L00AE 
  CLR.L     L00AF 
  LEA       L00A3(PC),A0
  BSR       L0028 
  LEA       L00A4(PC),A0
  BSR       L0028 
  LEA       L00A5(PC),A0
  BSR       L0028 
  LEA       L00A6(PC),A0
  BSR       L0028 
  MOVE.W    #$F,-(A7) 
  BSR       L001F 
  ADDQ.W    #2,A7 
  RTS 
L0028:
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  TST.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  RTS 
L0029:
  MOVEA.L   L00B1(PC),A0
  ADDQ.L    #1,L00A8
  MOVE.L    L00A8(PC),D0
  CMP.L     L00A9(PC),D0
  BCS.S     L002A 
  CLR.L     L00A8 
  TST.B     L00BB 
  BEQ.S     L002C 
  BSR.S     L002B 
  BRA       L003B 
L002A:
  BSR.S     L002B 
  BRA       L0040 
L002B:
  LEA       L00A3(PC),A6
  LEA       L00C3,A5
  BSR       L0041 
  LEA       L00A4(PC),A6
  LEA       L00C4,A5
  BSR       L0041 
  LEA       L00A5(PC),A6
  LEA       L00C5,A5
  BSR       L0041 
  LEA       L00A6(PC),A6
  LEA       L00C6,A5
  BRA       L0041 
L002C:
  LEA       $C(A0),A3 
  LEA       $3B8(A0),A2 
  LEA       $43C(A0),A0 
  MOVEQ     #0,D1 
  MOVE.L    L00B0(PC),D0
  MOVE.B    0(A2,D0.W),D1 
  ASL.L     #8,D1 
  ASL.L     #2,D1 
  ADD.L     L00AF(PC),D1
  MOVE.L    D1,L00AE
  CLR.W     L00AC 
  LEA       L00C3,A5
  LEA       L00A3(PC),A6
  MOVEQ     #1,D2 
  BSR       L002E 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       L00C4,A5
  LEA       L00A4(PC),A6
  MOVEQ     #2,D2 
  BSR.S     L002E 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       L00C5,A5
  LEA       L00A5(PC),A6
  MOVEQ     #3,D2 
  BSR.S     L002E 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       L00C6,A5
  LEA       L00A6(PC),A6
  MOVEQ     #4,D2 
  BSR.S     L002E 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  BRA       L003A 
L002D:
  CMP.B     L00B3,D2
  BNE       L0043 
  MOVE.B    L00B2,D2
  BEQ       L0043 
  MOVE.L    L00AF,D3
  LSR.L     #4,D3 
  DIVU      D2,D3 
  SWAP      D3
  TST.W     D3
  BNE       L0043 
  ANDI.L    #$FFF,(A6)
  ORI.L     #$10D6F000,(A6) 
  RTS 
L002E:
  TST.L     (A6)
  BNE.S     L002F 
  BSR       L0044 
L002F:
  MOVE.L    0(A0,D1.L),(A6) 
  BSR.S     L002D 
  ADDQ.L    #4,D1 
  MOVEQ     #0,D2 
  MOVE.B    2(A6),D2
  ANDI.B    #-$10,D2
  LSR.B     #4,D2 
  MOVE.B    (A6),D0 
  ANDI.B    #-$10,D0
  OR.B      D0,D2 
  TST.B     D2
  BEQ.S     L0031 
  MOVEQ     #0,D3 
  LEA       L00A7(PC),A1
  MOVE.W    D2,D4 
  MOVE.B    D2,$2B(A6)
  SUBQ.L    #1,D2 
  LSL.L     #2,D2 
  MULU      #$1E,D4 
  MOVE.L    0(A1,D2.L),4(A6)
  MOVE.W    0(A3,D4.L),8(A6)
  MOVE.W    0(A3,D4.L),$28(A6)
  MOVE.B    2(A3,D4.L),$12(A6)
  MOVE.B    3(A3,D4.L),$13(A6)
  MOVE.W    4(A3,D4.L),D3 
  TST.W     D3
  BEQ.S     L0030 
  MOVE.L    4(A6),D2
  ASL.W     #1,D3 
  ADD.L     D3,D2 
  MOVE.L    D2,$A(A6) 
  MOVE.L    D2,$24(A6)
  MOVE.W    4(A3,D4.L),D0 
  ADD.W     6(A3,D4.L),D0 
  MOVE.W    D0,8(A6)
  MOVE.W    6(A3,D4.L),$E(A6) 
  BRA.S     L0031 
L0030:
  MOVE.L    4(A6),D2
  ADD.L     D3,D2 
  MOVE.L    D2,$A(A6) 
  MOVE.L    D2,$24(A6)
  MOVE.W    6(A3,D4.L),$E(A6) 
L0031:
  MOVE.W    (A6),D0 
  ANDI.W    #$FFF,D0
  BEQ       L0086 
  MOVE.W    2(A6),D0
  ANDI.W    #$FF0,D0
  CMP.W     #$E50,D0
  BEQ.S     L0032 
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  CMP.B     #3,D0 
  BEQ.S     L0033 
  CMP.B     #5,D0 
  BEQ.S     L0033 
  CMP.B     #9,D0 
  BNE.S     L0034 
  BSR       L0086 
  BRA.S     L0034 
L0032:
  BSR       L008B 
  BRA.S     L0034 
L0033:
  BSR       L0051 
  BRA       L0086 
L0034:
  MOVEM.L   A0-A1/D0-D1,-(A7) 
  MOVE.W    (A6),D1 
  ANDI.W    #$FFF,D1
  LEA       L00A2(PC),A1
  MOVEQ     #0,D0 
  MOVEQ     #$24,D7 
L0035:
  CMP.W     0(A1,D0.W),D1 
  BCC.S     L0036 
  ADDQ.L    #2,D0 
  DBF       D7,L0035
L0036:
  MOVEQ     #0,D1 
  MOVE.B    $12(A6),D1
  MULU      #$4A,D1 
  ADDA.L    D1,A1 
  MOVE.W    0(A1,D0.W),$10(A6)
  MOVEM.L   (A7)+,A0-A1/D0-D1 
  MOVE.W    2(A6),D0
  ANDI.W    #$FF0,D0
  CMP.W     #$ED0,D0
  BEQ       L0086 
  MOVE.W    $14(A6),-(A7) 
  BSR       L001F 
  ADDQ.W    #2,A7 
  BTST      #2,$1E(A6)
  BNE.S     L0037 
  CLR.B     $1B(A6) 
L0037:
  BTST      #6,$1E(A6)
  BNE.S     L0038 
  CLR.B     $1D(A6) 
L0038:
  MOVE.W    8(A6),4(A5) 
  MOVE.L    4(A6),(A5)
  BNE.S     L0039 
  CLR.L     $A(A6)
  MOVEQ     #1,D0 
  MOVE.W    D0,4(A5)
  MOVE.W    D0,$E(A6) 
L0039:
  MOVE.W    $10(A6),D0
  MOVE.W    D0,6(A5)
  ST        $2A(A6) 
  MOVE.W    $14(A6),D0
  OR.W      D0,L00AC
  BRA       L0086 
L003A:
  MOVE.W    L00AC,D0
  AND.W     L00AD,D0
  ORI.W     #-$8000,D0
  MOVE.W    D0,-(A7)
  BSR       L001F 
  ADDQ.W    #2,A7 
  LEA       L00C3,A5
  LEA       L00A6(PC),A6
  MOVE.L    $A(A6),$3A(A5)
  MOVE.W    $E(A6),$3E(A5)
  LEA       L00A5(PC),A6
  MOVE.L    $A(A6),$2A(A5)
  MOVE.W    $E(A6),$2E(A5)
  LEA       L00A4(PC),A6
  MOVE.L    $A(A6),$1A(A5)
  MOVE.W    $E(A6),$1E(A5)
  LEA       L00A3(PC),A6
  MOVE.L    $A(A6),$A(A5) 
  MOVE.W    $E(A6),$E(A5) 
L003B:
  ADDI.L    #$10,L00AF
  MOVE.B    L00BA,D0
  BEQ.S     L003C 
  MOVE.B    D0,L00BB
  CLR.B     L00BA 
L003C:
  TST.B     L00BB 
  BEQ.S     L003D 
  SUBQ.B    #1,L00BB
  BEQ.S     L003D 
  SUBI.L    #$10,L00AF
L003D:
  TST.B     L00B8 
  BEQ.S     L003E 
  SF        L00B8 
  MOVEQ     #0,D0 
  MOVE.B    L00B6(PC),D0
  LSL.W     #4,D0 
  MOVE.L    D0,L00AF
  CLR.B     L00B6 
L003E:
  CMPI.L    #$400,L00AF 
  BNE.S     L0040 
L003F:
  MOVEQ     #0,D0 
  MOVE.B    L00B6(PC),D0
  LSL.W     #4,D0 
  MOVE.L    D0,L00AF
  CLR.B     L00B6 
  CLR.B     L00B7 
  ADDQ.L    #1,L00B0
  ANDI.L    #$7F,L00B0
  MOVE.L    L00B0(PC),D1
  MOVEA.L   L00B1(PC),A0
  CMP.B     $3B6(A0),D1 
  BCS.S     L0040 
  CLR.L     L00B0 
L0040:
  TST.B     L00B7 
  BNE.S     L003F 
  RTS 
L0041:
  BSR.S     L0042 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  RTS 
L0042:
  BSR       L009D 
  MOVE.W    2(A6),D0
  ANDI.W    #$FFF,D0
  BEQ.S     L0043 
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  TST.B     D0
  BEQ.S     L0045 
  CMP.B     #1,D0 
  BEQ       L004C 
  CMP.B     #2,D0 
  BEQ       L004F 
  CMP.B     #3,D0 
  BEQ       L0056 
  CMP.B     #4,D0 
  BEQ       L005D 
  CMP.B     #5,D0 
  BEQ       L0067 
  CMP.B     #6,D0 
  BEQ       L0068 
  CMP.B     #$E,D0
  BEQ       L0087 
  MOVE.W    $10(A6),6(A5) 
  CMP.B     #7,D0 
  BEQ       L0069 
  CMP.B     #$A,D0
  BEQ       L0078 
L0043:
  RTS 
L0044:
  MOVE.W    $10(A6),6(A5) 
  RTS 
L0045:
  MOVEQ     #0,D0 
  MOVE.L    L00A8(PC),D0
  DIVS      #3,D0 
  SWAP      D0
  CMP.W     #1,D0 
  BEQ.S     L0046 
  CMP.W     #2,D0 
  BEQ.S     L0047 
  MOVE.W    $10(A6),D2
  BRA.S     L004A 
L0046:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  LSR.B     #4,D0 
  BRA.S     L0048 
L0047:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
L0048:
  ASL.W     #1,D0 
  MOVEQ     #0,D1 
  MOVE.B    $12(A6),D1
  MULU      #$4A,D1 
  LEA       L00A2(PC),A0
  ADDA.L    D1,A0 
  MOVEQ     #0,D1 
  MOVE.W    $10(A6),D1
  MOVEQ     #$24,D7 
L0049:
  MOVE.W    0(A0,D0.W),D2 
  CMP.W     (A0),D1 
  BCC.S     L004A 
  ADDQ.L    #2,A0 
  DBF       D7,L0049
  RTS 
L004A:
  MOVE.W    D2,6(A5)
  RTS 
L004B:
  TST.L     L00A8 
  BNE.S     L0043 
  MOVE.B    #$F,L00B9 
L004C:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  AND.B     L00B9,D0
  MOVE.B    #-1,L00B9 
  SUB.W     D0,$10(A6)
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  CMP.W     #$71,D0 
  BPL.S     L004D 
  ANDI.W    #-$1000,$10(A6) 
  ORI.W     #$71,$10(A6)
L004D:
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  MOVE.W    D0,6(A5)
  RTS 
L004E:
  TST.L     L00A8 
  BNE       L0043 
  MOVE.B    #$F,L00B9 
L004F:
  CLR.W     D0
  MOVE.B    3(A6),D0
  AND.B     L00B9,D0
  MOVE.B    #-1,L00B9 
  ADD.W     D0,$10(A6)
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  CMP.W     #$358,D0
  BMI.S     L0050 
  ANDI.W    #-$1000,$10(A6) 
  ORI.W     #$358,$10(A6) 
L0050:
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  MOVE.W    D0,6(A5)
  RTS 
L0051:
  MOVE.L    A0,-(A7)
  MOVE.W    (A6),D2 
  ANDI.W    #$FFF,D2
  MOVEQ     #0,D0 
  MOVE.B    $12(A6),D0
  MULU      #$4A,D0 
  LEA       L00A2(PC),A0
  ADDA.L    D0,A0 
  MOVEQ     #0,D0 
L0052:
  CMP.W     0(A0,D0.W),D2 
  BCC.S     L0053 
  ADDQ.W    #2,D0 
  CMP.W     #$4A,D0 
  BCS.S     L0052 
  MOVEQ     #$46,D0 
L0053:
  MOVE.B    $12(A6),D2
  ANDI.B    #8,D2 
  BEQ.S     L0054 
  TST.W     D0
  BEQ.S     L0054 
  SUBQ.W    #2,D0 
L0054:
  MOVE.W    0(A0,D0.W),D2 
  MOVEA.L   (A7)+,A0
  MOVE.W    D2,$18(A6)
  MOVE.W    $10(A6),D0
  CLR.B     $16(A6) 
  CMP.W     D0,D2 
  BEQ.S     L0055 
  BGE       L0043 
  MOVE.B    #1,$16(A6)
  RTS 
L0055:
  CLR.W     $18(A6) 
  RTS 
L0056:
  MOVE.B    3(A6),D0
  BEQ.S     L0057 
  MOVE.B    D0,$17(A6)
  CLR.B     3(A6) 
L0057:
  TST.W     $18(A6) 
  BEQ       L0043 
  MOVEQ     #0,D0 
  MOVE.B    $17(A6),D0
  TST.B     $16(A6) 
  BNE.S     L0058 
  ADD.W     D0,$10(A6)
  MOVE.W    $18(A6),D0
  CMP.W     $10(A6),D0
  BGT.S     L0059 
  MOVE.W    $18(A6),$10(A6) 
  CLR.W     $18(A6) 
  BRA.S     L0059 
L0058:
  SUB.W     D0,$10(A6)
  MOVE.W    $18(A6),D0
  CMP.W     $10(A6),D0
  BLT.S     L0059 
  MOVE.W    $18(A6),$10(A6) 
  CLR.W     $18(A6) 
L0059:
  MOVE.W    $10(A6),D2
  MOVE.B    $1F(A6),D0
  ANDI.B    #$F,D0
  BEQ.S     L005C 
  MOVEQ     #0,D0 
  MOVE.B    $12(A6),D0
  MULU      #$4A,D0 
  LEA       L00A2(PC),A0
  ADDA.L    D0,A0 
  MOVEQ     #0,D0 
L005A:
  CMP.W     0(A0,D0.W),D2 
  BCC.S     L005B 
  ADDQ.W    #2,D0 
  CMP.W     #$4A,D0 
  BCS.S     L005A 
  MOVEQ     #$46,D0 
L005B:
  MOVE.W    0(A0,D0.W),D2 
L005C:
  MOVE.W    D2,6(A5)
  RTS 
L005D:
  MOVE.B    3(A6),D0
  BEQ.S     L0060 
  MOVE.B    $1A(A6),D2
  ANDI.B    #$F,D0
  BEQ.S     L005E 
  ANDI.B    #-$10,D2
  OR.B      D0,D2 
L005E:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  BEQ.S     L005F 
  ANDI.B    #$F,D2
  OR.B      D0,D2 
L005F:
  MOVE.B    D2,$1A(A6)
L0060:
  MOVE.L    A4,-(A7)
  MOVE.B    $1B(A6),D0
  LEA       L00A1(PC),A4
  LSR.W     #2,D0 
  ANDI.W    #$1F,D0 
  MOVEQ     #0,D2 
  MOVE.B    $1E(A6),D2
  ANDI.B    #3,D2 
  BEQ.S     L0063 
  LSL.B     #3,D0 
  CMP.B     #1,D2 
  BEQ.S     L0061 
  MOVE.B    #-1,D2
  BRA.S     L0064 
L0061:
  TST.B     $1B(A6) 
  BPL.S     L0062 
  MOVE.B    #-1,D2
  SUB.B     D0,D2 
  BRA.S     L0064 
L0062:
  MOVE.B    D0,D2 
  BRA.S     L0064 
L0063:
  MOVE.B    0(A4,D0.W),D2 
L0064:
  MOVE.B    $1A(A6),D0
  ANDI.W    #$F,D0
  MULU      D0,D2 
  LSR.W     #7,D2 
  MOVE.W    $10(A6),D0
  TST.B     $1B(A6) 
  BMI.S     L0065 
  ADD.W     D2,D0 
  BRA.S     L0066 
L0065:
  SUB.W     D2,D0 
L0066:
  MOVE.W    D0,6(A5)
  MOVE.B    $1A(A6),D0
  LSR.W     #2,D0 
  ANDI.W    #$3C,D0 
  ADD.B     D0,$1B(A6)
  MOVEA.L   (A7)+,A4
  RTS 
L0067:
  BSR       L0057 
  BRA       L0078 
L0068:
  BSR.S     L0060 
  BRA       L0078 
L0069:
  MOVE.L    A4,-(A7)
  MOVE.B    3(A6),D0
  BEQ.S     L006C 
  MOVE.B    $1C(A6),D2
  ANDI.B    #$F,D0
  BEQ.S     L006A 
  ANDI.B    #-$10,D2
  OR.B      D0,D2 
L006A:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  BEQ.S     L006B 
  ANDI.B    #$F,D2
  OR.B      D0,D2 
L006B:
  MOVE.B    D2,$1C(A6)
L006C:
  MOVE.B    $1D(A6),D0
  LEA       L00A1(PC),A4
  LSR.W     #2,D0 
  ANDI.W    #$1F,D0 
  MOVEQ     #0,D2 
  MOVE.B    $1E(A6),D2
  LSR.B     #4,D2 
  ANDI.B    #3,D2 
  BEQ.S     L006F 
  LSL.B     #3,D0 
  CMP.B     #1,D2 
  BEQ.S     L006D 
  MOVE.B    #-1,D2
  BRA.S     L0070 
L006D:
  TST.B     $1B(A6) 
  BPL.S     L006E 
  MOVE.B    #-1,D2
  SUB.B     D0,D2 
  BRA.S     L0070 
L006E:
  MOVE.B    D0,D2 
  BRA.S     L0070 
L006F:
  MOVE.B    0(A4,D0.W),D2 
L0070:
  MOVE.B    $1C(A6),D0
  ANDI.W    #$F,D0
  MULU      D0,D2 
  LSR.W     #6,D2 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  TST.B     $1D(A6) 
  BMI.S     L0071 
  ADD.W     D2,D0 
  BRA.S     L0072 
L0071:
  SUB.W     D2,D0 
L0072:
  BPL.S     L0073 
  CLR.W     D0
L0073:
  CMP.W     #$40,D0 
  BLS.S     L0074 
  MOVE.W    #$40,D0 
L0074:
  MOVE.W    D0,8(A5)
  MOVE.B    $1C(A6),D0
  LSR.W     #2,D0 
  ANDI.W    #$3C,D0 
  ADD.B     D0,$1D(A6)
  MOVEA.L   (A7)+,A4
  ADDQ.L    #4,A7 
  RTS 
L0075:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  BEQ.S     L0076 
  MOVE.B    D0,$20(A6)
L0076:
  MOVE.B    $20(A6),D0
  LSL.W     #7,D0 
  CMP.W     8(A6),D0
  BGE.S     L0077 
  SUB.W     D0,8(A6)
  LSL.W     #1,D0 
  ADD.L     D0,4(A6)
  RTS 
L0077:
  MOVE.W    #1,8(A6)
  RTS 
L0078:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  LSR.B     #4,D0 
  TST.B     D0
  BEQ.S     L007B 
L0079:
  ADD.B     D0,$13(A6)
  CMPI.B    #$40,$13(A6)
  BMI.S     L007A 
  MOVE.B    #$40,$13(A6)
L007A:
  MOVE.B    $13(A6),D0
  RTS 
L007B:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
L007C:
  SUB.B     D0,$13(A6)
  BPL.S     L007D 
  CLR.B     $13(A6) 
L007D:
  MOVE.B    $13(A6),D0
  RTS 
L007E:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  SUBQ.B    #1,D0 
  MOVE.L    D0,L00B0
L007F:
  CLR.B     L00B6 
  ST        L00B7 
  RTS 
L0080:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  CMP.B     #$40,D0 
  BLS.S     L0081 
  MOVEQ     #$40,D0 
L0081:
  MOVE.B    D0,$13(A6)
  RTS 
L0082:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  MOVE.L    D0,D2 
  LSR.B     #4,D0 
  MULU      #$A,D0
  ANDI.B    #$F,D2
  ADD.B     D2,D0 
  CMP.B     #$3F,D0 
  BHI.S     L007F 
  MOVE.B    D0,L00B6
  ST        L00B7 
  RTS 
L0083:
  MOVE.B    3(A6),D0
  ANDI.W    #$FF,D0 
  BEQ.S     L0085 
  CMP.W     #$20,D0 
  BCS.S     L0084 
  MOVE.W    D0,L00BC
  RTS 
L0084:
  CLR.L     L00A8 
  MOVE.W    D0,L00AA
  RTS 
L0085:
  RTS 
L0086:
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  CMP.B     #9,D0 
  BEQ       L0075 
  CMP.B     #$B,D0
  BEQ       L007E 
  CMP.B     #$D,D0
  BEQ.S     L0082 
  CMP.B     #$E,D0
  BEQ.S     L0087 
  CMP.B     #$F,D0
  BEQ.S     L0083 
  CMP.B     #$C,D0
  BEQ       L0080 
  BRA       L0044 
L0087:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  LSR.B     #4,D0 
  BEQ.S     L0088 
  CMP.B     #1,D0 
  BEQ       L004B 
  CMP.B     #2,D0 
  BEQ       L004E 
  CMP.B     #3,D0 
  BEQ.S     L0089 
  CMP.B     #4,D0 
  BEQ       L008A 
  CMP.B     #5,D0 
  BEQ       L008B 
  CMP.B     #6,D0 
  BEQ       L008C 
  CMP.B     #7,D0 
  BEQ       L0090 
  CMP.B     #8,D0 
  BEQ       L0091 
  CMP.B     #$E,D0
  BEQ       L009B 
  CMP.B     #9,D0 
  BEQ       L0093 
  CMP.B     #$A,D0
  BEQ       L0097 
  CMP.B     #$B,D0
  BEQ       L0098 
  CMP.B     #$C,D0
  BEQ       L0099 
  CMP.B     #$D,D0
  BEQ       L009A 
  CMP.B     #$F,D0
  BEQ       L009C 
  RTS 
L0088:
  RTS 
L0089:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  ANDI.B    #-$10,$1F(A6) 
  OR.B      D0,$1F(A6)
  RTS 
L008A:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  ANDI.B    #-$10,$1E(A6) 
  OR.B      D0,$1E(A6)
  RTS 
L008B:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  MOVE.B    D0,$12(A6)
  RTS 
L008C:
  TST.L     L00A8 
  BNE       L0043 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BEQ.S     L008F 
  TST.B     $22(A6) 
  BEQ.S     L008E 
  SUBQ.B    #1,$22(A6)
  BEQ       L0043 
L008D:
  MOVE.B    $21(A6),L00B6 
  ST        L00B8 
  RTS 
L008E:
  MOVE.B    D0,$22(A6)
  BRA.S     L008D 
L008F:
  MOVE.L    L00AF,D0
  LSR.L     #4,D0 
  ANDI.B    #$3F,D0 
  MOVE.B    D0,$21(A6)
  RTS 
L0090:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  LSL.B     #4,D0 
  ANDI.B    #$F,$1E(A6) 
  OR.B      D0,$1E(A6)
  RTS 
L0091:
  MOVEM.L   A0-A1/D1-D2,-(A7) 
  MOVEA.L   $A(A6),A0 
  MOVEA.L   A0,A1 
  MOVE.W    $E(A6),D0 
  ADD.W     D0,D0 
  SUBQ.W    #2,D0 
L0092:
  MOVE.B    (A0),D1 
  EXT.W     D1
  MOVE.B    1(A0),D2
  EXT.W     D2
  ADD.W     D1,D2 
  ASR.W     #1,D2 
  MOVE.B    D2,(A0)+
  DBF       D0,L0092
  MOVE.B    (A0),D1 
  EXT.W     D1
  MOVE.B    (A1),D2 
  EXT.W     D2
  ADD.W     D1,D2 
  ASR.W     #1,D2 
  MOVE.B    D2,(A0) 
  MOVEM.L   (A7)+,A0-A1/D1-D2 
  RTS 
L0093:
  MOVE.L    D1,-(A7)
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BEQ       L0096 
  MOVE.L    L00A8,D1
  BNE.S     L0094 
  MOVE.W    0(A6),D1
  ANDI.W    #$FFF,D1
  BNE       L0096 
  MOVE.L    L00A8,D1
L0094:
  DIVU      D0,D1 
  SWAP      D1
  TST.W     D1
  BNE       L0096 
L0095:
  MOVE.L    4(A6),(A5)
  MOVE.W    8(A6),4(A5) 
  MOVE.W    $10(A6),6(A5) 
  MOVE.L    $A(A6),$A(A5) 
  MOVE.W    $E(A6),$E(A5) 
L0096:
  MOVE.L    (A7)+,D1
  RTS 
L0097:
  TST.L     L00A8 
  BNE       L0043 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BRA       L0079 
L0098:
  TST.L     L00A8 
  BNE       L0043 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BRA       L007C 
L0099:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  CMP.L     L00A8,D0
  BNE       L0043 
  CLR.B     $13(A6) 
  RTS 
L009A:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  CMP.L     L00A8,D0
  BNE       L0043 
  MOVE.W    (A6),D0 
  ANDI.W    #$FFF,D0
  BEQ       L0043 
  MOVE.L    D1,-(A7)
  BRA       L0095 
L009B:
  TST.L     L00A8 
  BNE       L0043 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  TST.B     L00BB 
  BNE       L0043 
  ADDQ.B    #1,D0 
  MOVE.B    D0,L00BA
  RTS 
L009C:
  TST.L     L00A8 
  BNE       L0043 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  LSL.B     #4,D0 
  ANDI.B    #$F,$1F(A6) 
  OR.B      D0,$1F(A6)
  TST.B     D0
  BEQ       L0043 
L009D:
  MOVEM.L   A0/D1,-(A7) 
  MOVEQ     #0,D0 
  MOVE.B    $1F(A6),D0
  LSR.B     #4,D0 
  BEQ.S     L009F 
  LEA       L00A0(PC),A0
  MOVE.B    0(A0,D0.W),D0 
  ADD.B     D0,$23(A6)
  BTST      #7,$23(A6)
  BEQ.S     L009F 
  CLR.B     $23(A6) 
  MOVE.L    $A(A6),D0 
  MOVEQ     #0,D1 
  MOVE.W    $E(A6),D1 
  ADD.L     D1,D0 
  ADD.L     D1,D0 
  MOVEA.L   $24(A6),A0
  ADDQ.L    #1,A0 
  CMPA.L    D0,A0 
  BCS.S     L009E 
  MOVEA.L   $A(A6),A0 
L009E:
  MOVE.L    A0,$24(A6)
  MOVEQ     #-1,D0
  SUB.B     (A0),D0 
  MOVE.B    D0,(A0) 
L009F:
  MOVEM.L   (A7)+,A0/D1 
  RTS 

	SECTION DATA 

L00A0:
  DC.B      0,5,6,7,8,$A,$B,$D,$10,$13,$16,$1A,$20,$2B,$40,-$80 
L00A1:
  DC.B      0,$18,$31,$4A,$61,$78,-$73,-$5F,-$4C,-$3B,-$2C,-$20,-$15,-$C,-6,-3,-1,-3,-6,-$C,-$15,-$20,-$2C,-$3B,-$4C,-$5F,-$73,$78,$61,$4A,$31,$18
L00A2:
  DC.B      3,$58,3,$28,2,-6,2,-$30,2,-$5A,2,-$80,2,$5C,2,$3A,2,$1A,1,-4,1,-$20,1,-$3B,1,-$54,1,-$6C,1,$7D,1,$68,1,$53,1,$40,1,$2E,1,$1D,1,$D,0,-2,0,-$10,0,-$1E,0,-$2A,0,-$36
  DC.B      0,-$42,0,-$4C,0,-$56,0,-$60,0,-$69,0,-$71,0,-$79,0,$7F,0,$78,0,$71,0,0,3,$52,3,$22,2,-$B,2,-$35,2,-$5E,2,$7D,2,$59,2,$37,2,$17,1,-7,1,-$23,1,-$3E,1,-$57,1,-$6F,1,$7B 
  DC.B      1,$65,1,$51,1,$3E,1,$2C,1,$1C,1,$C,0,-3,0,-$11,0,-$1F,0,-$2B,0,-$37,0,-$43,0,-$4D,0,-$57,0,-$61,0,-$6A,0,-$72,0,-$7A,0,$7E,0,$77,0,$71,0,0,3,$4C,3,$1C,2,-$10,2,-$3B
  DC.B      2,-$62,2,$78,2,$55,2,$33,2,$14,1,-$A,1,-$26,1,-$41,1,-$5A,1,-$72,1,$78,1,$63,1,$4F,1,$3C,1,$2A,1,$1A,1,$A,0,-5,0,-$13,0,-$20,0,-$2D,0,-$39,0,-$44,0,-$4F,0,-$59,0,-$62
  DC.B      0,-$6B,0,-$73,0,-$7B,0,$7D,0,$76,0,$70,0,0,3,$46,3,$17,2,-$16,2,-$40,2,-$67,2,$74,2,$50,2,$2F,2,$10,1,-$E,1,-$2A,1,-$44,1,-$5D,1,-$75,1,$75,1,$60,1,$4C,1,$3A,1,$28 
  DC.B      1,$18,1,8,0,-7,0,-$15,0,-$22,0,-$2F,0,-$3A,0,-$45,0,-$50,0,-$5A,0,-$63,0,-$6C,0,-$74,0,-$7C,0,$7D,0,$76,0,$6F,0,0,3,$40,3,$11,2,-$1B,2,-$45,2,-$6C,2,$6F,2,$4C,2,$2B
  DC.B      2,$C,1,-$11,1,-$2D,1,-$47,1,-$60,1,-$78,1,$72,1,$5E,1,$4A,1,$38,1,$26,1,$16,1,6,0,-9,0,-$17,0,-$24,0,-$30,0,-$3C,0,-$47,0,-$51,0,-$5B,0,-$64,0,-$6D,0,-$75,0,-$7D,0,$7C 
  DC.B      0,$75,0,$6E,0,0,3,$3A,3,$B,2,-$20,2,-$4A,2,-$71,2,$6B,2,$48,2,$27,2,8,1,-$15,1,-$31,1,-$4B,1,-$63,1,-$7A,1,$70,1,$5B,1,$48,1,$35,1,$24,1,$14,1,4,0,-$B,0,-$18 
  DC.B      0,-$25,0,-$32,0,-$3D,0,-$48,0,-$52,0,-$5C,0,-$65,0,-$6E,0,-$76,0,-$7E,0,$7B,0,$74,0,$6D,0,0,3,$34,3,6,2,-$26,2,-$4F,2,-$75,2,$66,2,$44,2,$23,2,4,1,-$19,1,-$34,1,-$4E 
  DC.B      1,-$66,1,-$7D,1,$6D,1,$59,1,$45,1,$33,1,$22,1,$12,1,2,0,-$C,0,-$1A,0,-$27,0,-$33,0,-$3F,0,-$49,0,-$54,0,-$5D,0,-$66,0,-$6F,0,-$77,0,-$7F,0,$7A,0,$73,0,$6D,0,0,3,$2E
  DC.B      3,0,2,-$2B,2,-$54,2,-$7A,2,$62,2,$3F,2,$1F,2,1,1,-$1C,1,-$37,1,-$51,1,-$69,1,-$80,1,$6B,1,$56,1,$43,1,$31,1,$20,1,$10,1,0,0,-$E,0,-$1C,0,-$28,0,-$34,0,-$40,0,-$4B
  DC.B      0,-$55,0,-$5F,0,-$68,0,-$70,0,-$78,0,-$80,0,$79,0,$72,0,$6C,0,0,3,-$75,3,$58,3,$28,2,-6,2,-$30,2,-$5A,2,-$80,2,$5C,2,$3A,2,$1A,1,-4,1,-$20,1,-$3B,1,-$54,1,-$6C,1,$7D 
  DC.B      1,$68,1,$53,1,$40,1,$2E,1,$1D,1,$D,0,-2,0,-$10,0,-$1E,0,-$2A,0,-$36,0,-$42,0,-$4C,0,-$56,0,-$60,0,-$69,0,-$71,0,-$79,0,$7F,0,$78,0,0,3,-$7C,3,$52,3,$22,2,-$B,2,-$35
  DC.B      2,-$5D,2,$7C,2,$59,2,$37,2,$17,1,-7,1,-$23,1,-$3E,1,-$57,1,-$6F,1,$7B,1,$65,1,$51,1,$3E,1,$2C,1,$1C,1,$C,0,-3,0,-$12,0,-$1F,0,-$2C,0,-$38,0,-$43,0,-$4D,0,-$57,0,-$61 
  DC.B      0,-$6A,0,-$72,0,-$7A,0,$7E,0,$77,0,0,3,$7E,3,$4C,3,$1C,2,-$10,2,-$3B,2,-$62,2,$78,2,$55,2,$33,2,$14,1,-$A,1,-$26,1,-$41,1,-$5A,1,-$72,1,$78,1,$63,1,$4F,1,$3C,1,$2A 
  DC.B      1,$1A,1,$A,0,-5,0,-$13,0,-$21,0,-$2D,0,-$39,0,-$44,0,-$4F,0,-$59,0,-$62,0,-$6B,0,-$73,0,-$7B,0,$7D,0,$76,0,0,3,$77,3,$46,3,$17,2,-$16,2,-$40,2,-$67,2,$74,2,$50,2,$2F 
  DC.B      2,$10,1,-$E,1,-$2A,1,-$44,1,-$5D,1,-$75,1,$75,1,$60,1,$4C,1,$3A,1,$28,1,$18,1,8,0,-7,0,-$15,0,-$22,0,-$2F,0,-$3A,0,-$45,0,-$50,0,-$5A,0,-$63,0,-$6C,0,-$74,0,-$7C,0,$7D 
  DC.B      0,$76,0,0,3,$71,3,$40,3,$11,2,-$1B,2,-$45,2,-$6C,2,$6F,2,$4C,2,$2B,2,$C,1,-$12,1,-$2D,1,-$47,1,-$60,1,-$78,1,$72,1,$5E,1,$4A,1,$38,1,$26,1,$16,1,6,0,-9,0,-$17
  DC.B      0,-$24,0,-$30,0,-$3C,0,-$47,0,-$51,0,-$5B,0,-$64,0,-$6D,0,-$75,0,-$7D,0,$7B,0,$75,0,0,3,$6B,3,$3A,3,$B,2,-$20,2,-$4A,2,-$71,2,$6B,2,$48,2,$27,2,8,1,-$15,1,-$31,1,-$4B
  DC.B      1,-$63,1,-$7A,1,$70,1,$5B,1,$48,1,$35,1,$24,1,$14,1,4,0,-$B,0,-$18,0,-$25,0,-$32,0,-$3D,0,-$48,0,-$52,0,-$5C,0,-$65,0,-$6E,0,-$76,0,-$7E,0,$7B,0,$74,0,0,3,$64,3,$34
  DC.B      3,6,2,-$26,2,-$4F,2,-$75,2,$66,2,$44,2,$23,2,4,1,-$19,1,-$34,1,-$4E,1,-$66,1,-$7D,1,$6D,1,$59,1,$45,1,$33,1,$22,1,$12,1,2,0,-$C,0,-$1A,0,-$27,0,-$33,0,-$3F,0,-$49
  DC.B      0,-$54,0,-$5D,0,-$66,0,-$6F,0,-$77,0,-$7F,0,$7A,0,$73,0,0,3,$5E,3,$2E,3,0,2,-$2B,2,-$54,2,-$7A,2,$62,2,$3F,2,$1F,2,1,1,-$1C,1,-$37,1,-$51,1,-$69,1,-$80,1,$6B,1,$56 
  DC.B      1,$43,1,$31,1,$20,1,$10,1,0,0,-$E,0,-$1C,0,-$28,0,-$35,0,-$40,0,-$4B,0,-$55,0,-$5F,0,-$68,0,-$70,0,-$78,0,-$80,0,$79,0,$72,0,0
L00A3:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00A4:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00A5:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00A6:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00A7:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00A8:
  DC.B      0,0,0,0 
L00A9:
  DC.B      0,0 
L00AA:
  DC.B      0,6 
L00AB:
  DC.B      0,0 
L00AC:
  DC.B      0,0 
L00AD:
  DC.B      0,$F
L00AE:
  DC.B      0,0,0,0 
L00AF:
  DC.B      0,0,0,0 
L00B0:
  DC.B      0,0,0,0 
L00B1:
  DC.B      0,0,0,0 
L00B2:
  DC.B      0 
L00B3:
  DC.B      0 
L00B4:
  DC.B      6 
L00B5:
  DC.B      0 
L00B6:
  DC.B      0 
L00B7:
  DC.B      0 
L00B8:
  DC.B      0 
L00B9:
  DC.B      0 
L00BA:
  DC.B      0 
L00BB:
  DC.B      0 
L00BC:
  DC.B      0,$7D 
L00BD:
  DC.B      0,0,-$20,$2A,-$10,$15,-$60,$E,$78,$A,$60,8,$50,7,$44,-$68,$3C,5,$35,$5A,$30,4,$2B,-$5A,$28,3,$24,-$11,$22,$4C,$20,2,$1E,2,$1C,$3E,$1A,-$53,$19,$45,$18,2,$16,-$23,$15,-$2D,$14,-$20,$14,1,$13,$34 
  DC.B      $12,$77,$11,-$38,$11,$26,$10,-$72,$10,1,$F,$7D,$F,1,$E,-$74,$E,$1F,$D,-$48,$D,$56,$C,-6,$C,-$5E,$C,$4F,$C,1,$B,-$4A,$B,$6E,$B,$2A,$A,-$17,$A,-$55,$A,$70,$A,$37,$A,0,9,-$34,9,-$66,9,$6A
  DC.B      9,$3B,9,$F,8,-$1C,8,-$46,8,-$6D,8,$6C,8,$47,8,$23,8,0,7,-$21,7,-$42,7,-$61,7,-$80,7,$63,7,$46,7,$2A,7,$F,6,-$B,6,-$24,6,-$3D,6,-$55,6,-$6D,6,$7D,6,$66,6,$51,6,$3C
  DC.B      6,$27,6,$13,6,0,5,-$13,5,-$25,5,-$38,5,-$49,5,-$5A,5,-$6B,5,-$7C,5,$74,5,$65,5,$55,5,$46,5,$38,5,$29,5,$1B,5,$D,5,0,4,-$D,4,-$1A,4,-$27,4,-$33,4,-$3F,4,-$4B,4,-$57 
  DC.B      4,-$63,4,-$6E,4,-$79,4,$7C,4,$72,4,$67,4,$5D,4,$53,4,$49,4,$3F,4,$36,4,$2C,4,$23,4,$1A,4,$11,4,8,4,0,3,-9,3,-$11,3,-$19,3,-$21,3,-$29,3,-$31,3,-$39,3,-$40,3,-$48 
  DC.B      3,-$4F,3,-$56,3,-$5D,3,-$64,3,-$6B,3,-$72,3,-$79,3,-$7F,3,$7A,3,$74,3,$6E,3,$67,3,$61,3,$5B,3,$55,3,$4F,3,$49,3,$44,3,$3E,3,$38,3,$33,3,$2E,3,$28,3,$23,3,$1E,3,$19 
  DC.B      3,$13,3,$E,3,9,3,5,3,0,2,-5,2,-$A,2,-$E,2,-$13,2,-$18,2,-$1C,2,-$20,2,-$25,2,-$29,2,-$2D,2,-$32,2,-$36,2,-$3A,2,-$3E,2,-$42,2,-$46,2,-$4A,2,-$4E,2,-$52,2,-$56,2,-$59 
  DC.B      2,-$5D,2,-$61,2,-$64,2,-$68,2,-$6C,2,-$6F,2,-$73,2,-$76,2,-$7A,2,-$7D,2,-$80,2,$7C,2,$79,2,$76,2,$73,2,$6F,2,$6C,2,$69,2,$66,2,$63,2,$60,2,$5D,2,$5A,2,$57,2,$54,2,$51
  DC.B      2,$4E,2,$4C,2,$49,2,$46,2,$43,2,$41,2,$3E,2,$3B,2,$39,2,$36,2,$33,2,$31,2,$2E,2,$2C,2,$29,2,$27,2,$24,2,$22,2,$1F,2,$1D,2,$1B,2,$18,2,$16,2,$14,2,$11,2,$F
  DC.B      2,$D,2,$B,2,8,2,6,2,4,2,2,2,0,1,-2,1,-5,1,-7,1,-9,1,-$B,1,-$D,1,-$F,1,-$11,1,-$13,1,-$15,1,-$17,1,-$19,1,-$1B,1,-$1D,1,-$1E 
L00BE:
  DC.B      0,0 
L00BF:
  DC.B      0,0,0,0,0,0,0,0,0,0 
L00C0:
  DC.B      -$16,$60,-$16,$60,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C1:
  DC.B      $C,0,$40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,-$21,-$11,0
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,-8,5,0,-$47,8,-$C,-$42,0,0,0,8,-$C,-$41,0 
  DC.B      $C,0,8,-$C,-$60,0,0,1,8,-$C,-$58,0,0,4,0,0,-$46,$65,-$C,0,0,0,0,$66,-$C,0,0,0,0,$67,-$C,0,0,0,0,5,-$C,$25,0,$F,-1,5,-$C,$26,0,$F,-1,5,-$C,$27,0,$F
  DC.B      -1,$20,0,$1B,$70,-$C,0,0,$10,0,6,-$28,$20,$5D,$5E,0,$60,-$C,0,0,$38,$1D,6,$40,-$60,$55,$58,0,$60,-$C,0,0,$10,$14,6,8,-$80,0,0,$66,6,-$18,-$5D,$5D,$58,0,0,0,0,$B,-$10,-$80
  DC.B      0,1,$3F,$A,-$58,$22,$44,-$C,0,$49,$4E,$49,$A,-$57,-$7F,0,0,$6C,8,-$3C,$2B,0,-$10,-$48,$44,-$C,0,$74,$72,$61,$A,-$57,-$80,0,0,$72,8,$4E,$2B,$20,0,$45,$E,$20,$72,$44,-$10,0,0,$38,$5E,$A 
  DC.B      -$57,-$7F,0,0,$79,8,-$3C,$2B,$22,-$12,0,$A,-$34,$20,0,0,$7C,$22,-$3C,0,$20,0,$44,$A,-$10,-$5D,0,0,-$7A,$45,-$C,0,0,$10,0,$20,0,$60,$20,0,$22,$56,$70,0,0,$38,$5E,$A,-$57,-$80,0,0 
  DC.B      -$77,8,$44,$2B,$44,$70,0,0,$38,$5F,$61,-$C,0,0,$10,$14,$60,-$C,0,0,$38,$1D,$76,-$10,0,0,$38,$5F,6,-$22,0,0,0,-$61,$60,$70,0,0,$38,$5D,$B,-$10,-$80,0,0,-$4C,$60,-$10,0,0,$38,$5D
  DC.B      $70,-$C,0,0,0,8,0,0,0,4,$48,$10,$60,-$C,0,0,$38,$1D,$61,-$C,0,0,0,-$1C,$76,-$10,0,0,$38,$5F,6,-$22,0,0,0,-$4F,$60,$70,0,0,$38,$5D,$B,-$1F,-$80,$60,-$10,0,0,$38,$5D,$70 
  DC.B      -$C,0,0,0,8,$61,-$C,0,0,0,-$E,4,$48,$10,$22,-$4A,0,$C,0,$6F,$A,-$57,-$7F,0,0,-$4C,$45,-$28,0,8,-$3B,$2B,$A,-$57,-$80,0,0,-$48,8,$45,$2B,$45,$58,0,$A,-$57,-$80,0,0,-$44,8,$45 
  DC.B      $2B,$45,$58,0,$A,-$57,-$80,0,0,-$40,8,$45,$2B,$45,$58,0,$44,-$10,0,0,$38,$5E,$20,0,-$58,$20,0,$3A,$A,-$57,-$80,0,0,-$38,8,$4E,$2B,$20,0,3,$A,-$10,-$56,0,0,-$2D,$20,0,$13,$56,$58,0 
  DC.B      $56,$58,0,$A,-$10,-$80,0,0,-$2B,$20,$58,0,$20,$58,0,$A,-$57,-$7F,0,0,-$2B,8,-$33,$2B,$A,-$57,-$80,0,0,-$28,8,$44,$2B,$44,$58,0,$61,$58,0,6,-$3C,0,0,0,-$1E,$A,-$57,-$80,0,0,-$21,8
  DC.B      $44,$2B,7,$59,-$7C,0,0,$C,$B,-$10,-$80,0,1,$22,$B,-$10,-$80,0,1,$B,6,-$28,0,0,0,-$11,$47,-$1E,0,$46,-$24,$28,$21,-$4E,-$50,$46,-$2C,0,$5C,$5D,-$50,$5C,$5D,0,$A,-$10,-$80,0,1,0,$B,-$10 
  DC.B      -$80,0,1,$22,$B,-$10,-$80,0,1,$B,6,-$28,0,0,0,-1,$47,-$1E,0,$5E,-$1B,0,$46,-$24,$28,$46,-$2C,-$4E,$5C,$5D,0,$5E,-$1B,0,$21,-$4E,-$4E,$5C,$5D,0,$51,$50,0,$22,$4D,0,$44,-$C,0,0,$38,$60
  DC.B      $20,0,$4C,$55,$63,0,$45,-$C,0,0,0,1,$20,0,$6E,$55,$60,0,0,0,$C,$22,$13,0,$20,$58,0,0,0,0,$22,$14,0,$20,$58,0,$20,$58,$13,$50,-$28,0,$20,0,$32,$21,-$7B,$1B,$21,4,0,$55
  DC.B      -$C,0,0,$38,$60,$47,-$28,0,$22,-$2B,$78,$51,-$20,0,$21,-$4E,0,$70,-$10,0,0,$38,$5E,$A,-$10,-$5E,0,1,$21,$70,-$C,0,0,0,1,0,0,$C,$70,-$C,0,0,0,6,$47,-$C,0,0,-$80,0,$71,-$18
  DC.B      0,$70,-$C,0,0,0,7,$62,-$C,0,0,$38,$60,$61,-$18,0,$62,-$C,0,0,$38,$60,$63,-$C,0,0,$38,$61,$72,-$C,0,0,0,2,$73,-$C,0,0,0,2,$45,-$C,0,0,0,-1,6,-$27,0,0,1,$3D
  DC.B      $4E,-$27,0,$20,0,-$50,$50,$4B,$66,$21,-$7C,0,$20,0,-$38,$51,$4A,0,0,0,$C,8,-$C,-$41,0,$C,0,8,-$C,-$41,0,$3C,0,8,-$C,-$54,0,$41,0,8,-$C,-$53,0,$58,0,8,-$C,-$5F,0,1,-8,8 
  DC.B      -$C,-$5D,0,0,0,0,-4,-$48,0,0,$C,0 
L00C2:
  DC.B      0,0 
L00C3:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C4:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C5:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C6:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C7:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C8:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00C9:
  DC.B      $10,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00CA:
  DC.B      $70,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00CB:
  DC.B      $50,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00CC:
  DC.B      $30,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00CD:
  DC.B      $10,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
L00CE:
  DC.B      $70,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 

	SECTION	BSS

L00CF:
  DS.B      8000

	END

