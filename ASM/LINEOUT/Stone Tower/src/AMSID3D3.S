 TEXT 
Begin:
L0000:
  BRA       L0098 
  BRA       L0001 
  BRA       L0006 
  BRA       L0004 
  BRA       L0005 
  BRA       L000D 
  BRA       L000C 
  BRA       L0017 
  DC.B      'SSD-Play'
  DC.B      'er by An'
  DC.B      'imal Min'
  DC.B      'e!  fixe'
  DC.B      'd by .de'
  DC.B      'fjam./.c'
  DC.B      'heckpoin'
  DC.B      't.  Falc'
  DC.B      'on-fix b'
  DC.B      'y FroST '
L0001:
  TST.B     $C3.L 
  BEQ.S     L0003 
  MOVEM.L   A0-A6/D0-D7,-(A7) 
  BSR       L001D 
  TST.B     $C2.L 
  BEQ.S     L0002 
  MOVE      #$2700,SR 
  BSR       L0015 
  BSR       L000B 
  SF        $C3.L 
  MOVE      #$2300,SR 
L0002:
  MOVEM.L   (A7)+,A0-A6/D0-D7 
L0003:
  RTS 
L0004:
  BSR       L0015 
  ST        $C2.L 
  RTS 
L0005:
  BSR       L000C 
  SF        $C2.L 
  ST        $C3.L 
  RTS 
  DC.B      $00,$00 
L0006:
  BSR       L000B 
  BSR       L0011 
  MOVE      #$2700,SR 
  BSR       L0015 
  MOVE      #$2300,SR 
  RTS 
L0007:
  MOVE      #$2700,SR 
  LEA       L0009(PC),A0
  MOVE.B    $FFFFFA07.W,(A0)+ 
  MOVE.B    $FFFFFA09.W,(A0)+ 
  MOVE.B    $FFFFFA13.W,(A0)+ 
  MOVE.B    $FFFFFA15.W,(A0)+ 
  MOVE.B    $FFFFFA17.W,(A0)+ 
  MOVE.B    $FFFFFA19.W,(A0)+ 
  MOVE.B    $FFFFFA1B.W,(A0)+ 
  MOVE.B    $FFFFFA1D.W,(A0)+ 
  BCLR      #5,$FFFFFA07.W
  BCLR      #5,$FFFFFA09.W
  BCLR      #4,$FFFFFA09.W
  BCLR      #5,$FFFFFA13.W
  BCLR      #5,$FFFFFA15.W
  BCLR      #4,$FFFFFA15.W
  LEA       L000A(PC),A0
  MOVE.L    $110.W,(A0)+
  MOVE.L    $114.W,(A0)+
  MOVE.L    $134.W,(A0)+
  MOVE.L    $60.W,(A0)+ 
  BCLR      #3,$FFFFFA17.W
  LEA       L0008(PC),A0
  MOVE.L    A0,$60.W
  MOVE.L    A0,$110.W 
  MOVE.L    A0,$114.W 
  MOVE.L    A0,$134.W 
  MOVE      #$2300,SR 
  RTS 
L0008:
  DC.B      'Ns'
L0009:
  DCB.W     8,0 
L000A:
  DCB.W     16,0
L000B:
  MOVE      #$2700,SR 
  BCLR      #5,$FFFFFA07.W
  BCLR      #5,$FFFFFA09.W
  BCLR      #4,$FFFFFA09.W
  BCLR      #5,$FFFFFA13.W
  BCLR      #5,$FFFFFA15.W
  BCLR      #4,$FFFFFA15.W
  LEA       L0009(PC),A0
  MOVE.B    (A0)+,$FFFFFA07.W 
  MOVE.B    (A0)+,$FFFFFA09.W 
  MOVE.B    (A0)+,$FFFFFA13.W 
  MOVE.B    (A0)+,$FFFFFA15.W 
  MOVE.B    (A0)+,$FFFFFA17.W 
  MOVE.B    (A0)+,$FFFFFA19.W 
  MOVE.B    (A0)+,$FFFFFA1B.W 
  MOVE.B    (A0)+,$FFFFFA1D.W 
  MOVE.B    #$C0,$FFFFFA23.W
  LEA       L000A(PC),A0
  MOVE.L    (A0)+,$110.W
  MOVE.L    (A0)+,$114.W
  MOVE.L    (A0)+,$134.W
  MOVE.L    (A0)+,$60.W 
  MOVE      #$2300,SR 
  RTS 
L000C:
  MOVE      #$2700,SR 
  MOVE.L    #$15A,$60.W 
  BSR       L0013 
  MOVE.L    #$240,$110.W
  ANDI.B    #$F0,$FFFFFA1D.W
  ORI.B     #1,$FFFFFA1D.W
  MOVE.B    #$FF,$FFFFFA25.W
  BSET      #4,$FFFFFA15.W
  BCLR      #4,$FFFFFA09.W
  MOVE.L    #$200,$114.W
  ANDI.B    #$F,$FFFFFA1D.W 
  ORI.B     #$38,$FFFFFA1D.W
  MOVE.B    #$FF,$FFFFFA23.W
  BSET      #5,$FFFFFA15.W
  BCLR      #5,$FFFFFA09.W
  MOVE.L    #$220,$134.W
  CLR.B     $FFFFFA19.W 
  MOVE.B    #$FF,$FFFFFA1F.W
  BSET      #5,$FFFFFA13.W
  BCLR      #5,$FFFFFA07.W
  BCLR      #3,$FFFFFA17.W
  MOVE      #$2300,SR 
  RTS 
L000D:
  MOVE      #$2700,SR 
  LEA       L0008(PC),A0
  MOVE.L    A0,$60.W
  MOVE.L    A0,$110.W 
  CLR.B     $FFFFFA1D.W 
  MOVE.B    #$FF,$FFFFFA25.W
  BCLR      #4,$FFFFFA15.W
  BCLR      #4,$FFFFFA09.W
  MOVE.L    A0,$114.W 
  CLR.B     $FFFFFA1D.W 
  MOVE.B    #$FF,$FFFFFA23.W
  BCLR      #5,$FFFFFA15.W
  BCLR      #5,$FFFFFA09.W
  MOVE.L    A0,$134.W 
  CLR.B     $FFFFFA19.W 
  MOVE.B    #$FF,$FFFFFA1F.W
  BCLR      #5,$FFFFFA13.W
  BCLR      #5,$FFFFFA07.W
  MOVE      #$2300,SR 
  RTS 
L000E:
  MOVE      #$2700,SR 
  LEA       $200.W,A0 
  LEA       L0012(PC),A1
L000F:
  MOVE.W    #$3F,D0 
L0010:
  MOVE.L    (A0)+,(A1)+ 
  DBF       D0,L0010
  MOVE      #$2300,SR 
  RTS 
L0011:
  MOVE      #$2700,SR 
  LEA       $200.W,A1 
  LEA       L0012(PC),A0
  BRA.S     L000F 
L0012:
  DCB.W     128,0 
L0013:
  LEA       L005B(PC),A0
  LEA       $200.W,A1 
  MOVE.W    #$5F,D0 
L0014:
  MOVE.B    (A0)+,(A1)+ 
  DBF       D0,L0014
  RTS 
L0015:
  MOVE.B    #$A,$FFFF8800.W 
  CLR.B     $FFFF8802.W 
  MOVE.B    #9,$FFFF8800.W
  CLR.B     $FFFF8802.W 
  MOVE.B    #8,$FFFF8800.W
  CLR.B     $FFFF8802.W 
  MOVE.B    #7,$FFFF8800.W
  MOVE.B    $FFFF8802.W,D0
  MOVE.B    #$C0,$FFFF8802.W
  MOVEQ     #6,D0 
L0016:
  MOVE.B    D0,$FFFF8800.W
  CLR.B     $FFFF8802.W 
  DBF       D0,L0016
  CLR.B     $FFFF8800.W 
  CLR.B     $FFFF8802.W 
  MOVE.B    #7,$FFFF8800.W
  MOVE.B    #$FF,$FFFF8802.W
  RTS 
L0017:
  MOVE.L    D0,$476.L 
  RTS 
L0018:
  DC.B      $00,$00,$00,'2' 
L0019:
  DCB.W     2,0 
L001A:
  DCB.W     2,0 
L001B:
  DCB.W     2,0 
L001C:
  DC.B      $00,$00 
L001D:
  MOVE.L    L0018(PC),D1
  CMP.B     #$32,D1 
  BEQ.S     L0020 
  CMP.L     L001B(PC),D1
  BEQ.S     L001E 
  MOVE.L    D1,$482.L 
  MOVE.L    #$C350,D0 
  DIVU      D1,D0 
  ANDI.L    #$FFFF,D0 
  MOVE.L    D0,$47A.L 
  CLR.L     $47E.L
L001E:
  MOVE.L    L001A(PC),D0
  ADD.L     L0019(PC),D0
  CMP.L     #$C350,D0 
  BLT.S     L001F 
  SUBI.L    #$C350,D0 
L001F:
  MOVE.L    D0,$47E.L 
  DIVU      #$3E8,D0
  MOVE.W    L001C(PC),D1
  MOVE.W    D0,$486.L 
  SUB.W     D1,D0 
  TST.W     D0
  BNE.S     L0020 
  RTS 
L0020:
  MOVEQ     #0,D4 
  LEA       $FFFF8800.W,A5
  SUBQ.W    #1,$222E.L
  BNE.S     L0024 
  MOVE.W    $4F8.L,$222E.L
  MOVEA.L   L00B4(PC),A1
  MOVE.W    L00B5(PC),D0
  MOVE.W    D0,D1 
  LSL.W     #3,D0 
  LSL.W     #2,D1 
  ADD.W     D1,D0 
  ADDA.W    D0,A1 
  MOVE.L    A1,$2220.L
  TST.B     $1C5A.L 
  BPL.S     L0021 
  MOVEQ     #$41,D0 
  SF        $1C5A.L 
  BRA.S     L0022 
L0021:
  ADDQ.W    #1,$221E.L
L0022:
  CMPI.W    #$40,$221E.L
  BNE.S     L0023 
  BSR       L00A3 
L0023:
  LEA       L00B0(PC),A0
  BSR       L003E 
  LEA       L00AE(PC),A0
  BSR       L003E 
  LEA       L00AF(PC),A0
  BSR       L003E 
L0024:
  LEA       L00AE(PC),A0
  BSR       L006B 
  BSR       L005C 
  BSR       L0060 
  LEA       L00AF(PC),A0
  BSR       L006B 
  BSR       L005C 
  BSR       L0060 
  LEA       L00B0(PC),A0
  BSR       L006B 
  BSR       L005C 
  BSR       L0060 
  MOVE      #$2700,SR 
  LEA       L00B0(PC),A0
  TST.B     58(A0)
  BNE.S     L0028 
  TST.W     $15AE.L 
  BPL.S     L0028 
  CMPI.B    #5,63(A0) 
  BGT.S     L0028 
  CMPI.B    #3,63(A0) 
  BLT.S     L0028 
  LEA       L00A6(PC),A6
  MOVE.W    0(A0),D1
L0025:
  TST.W     (A6)
  BMI.S     L0028 
  CMP.W     (A6)+,D1
  BLT.S     L0026 
  ADDQ.L    #4,A6 
  BRA.S     L0025 
L0026:
  MOVE.W    (A6)+,D2
  MOVE.W    (A6)+,D3
  MOVE.L    #$1900000,D0
  MULU      #$A3,D2 
  DIVU      D2,D0 
  MULU      D1,D0 
  TST.W     $15A8.L 
  BNE.S     L0027 
  ADDI.L    #$2000,D0 
L0027:
  ADDI.L    #$2000,D0 
  ADD.L     D0,D0 
  ADD.L     D0,D0 
  SWAP      D0
  MOVE.B    14(A0),$214.W 
  MOVE.B    D0,$FFFFFA23.W
  LSL.W     #4,D3 
  ANDI.B    #7,$FFFFFA1D.W
  OR.B      D3,$FFFFFA1D.W
  BSET      #5,$FFFFFA09.W
  BRA.S     L0029 
L0028:
  BCLR      #5,$FFFFFA09.W
  CMPI.B    #5,63(A0) 
  BGT.S     L0029 
  CMPI.B    #3,63(A0) 
  BLT.S     L0029 
  BCLR      #0,44(A0) 
L0029:
  LEA       L00AE(PC),A0
  TST.B     58(A0)
  BNE.S     L002D 
  TST.W     $15B0.L 
  BPL.S     L002D 
  CMPI.B    #5,63(A0) 
  BGT.S     L002D 
  CMPI.B    #3,63(A0) 
  BLT.S     L002D 
  LEA       $15B4.L,A6
  MOVE.W    0(A0),D1
L002A:
  TST.W     (A6)
  BMI.S     L002D 
  CMP.W     (A6)+,D1
  BLT.S     L002B 
  ADDQ.L    #4,A6 
  BRA.S     L002A 
L002B:
  MOVE.W    (A6)+,D2
  MOVE.W    (A6)+,D3
  MOVE.L    #$1900000,D0
  MULU      #$A3,D2 
  DIVU      D2,D0 
  MULU      D1,D0 
  TST.W     $15AA.L 
  BNE.S     L002C 
  ADDI.L    #$2000,D0 
L002C:
  ADDI.L    #$2000,D0 
  LSL.L     #2,D0 
  SWAP      D0
  MOVE.B    14(A0),$234.W 
  MOVE.B    D0,$FFFFFA1F.W
  MOVE.B    D3,$FFFFFA19.W
  BSET      #5,$FFFFFA07.W
  BRA.S     L002E 
L002D:
  BCLR      #5,$FFFFFA07.W
  CMPI.B    #5,63(A0) 
  BGT.S     L002E 
  CMPI.B    #3,63(A0) 
  BLT.S     L002E 
  BCLR      #0,44(A0) 
L002E:
  LEA       L00AF(PC),A0
  TST.B     58(A0)
  BNE.S     L0032 
  TST.W     $15B2.L 
  BPL.S     L0032 
  CMPI.B    #5,63(A0) 
  BGT.S     L0032 
  CMPI.B    #3,63(A0) 
  BLT.S     L0032 
  LEA       L00A6(PC),A6
  MOVE.W    0(A0),D1
L002F:
  TST.W     (A6)
  BMI.S     L0032 
  CMP.W     (A6)+,D1
  BLT.S     L0030 
  ADDQ.L    #4,A6 
  BRA.S     L002F 
L0030:
  MOVE.W    (A6)+,D2
  MOVE.W    (A6)+,D3
  MOVE.L    #$1900000,D0
  MULU      #$A3,D2 
  DIVU      D2,D0 
  MULU      D1,D0 
  TST.W     $15AC.L 
  BNE.S     L0031 
  ADDI.L    #$2000,D0 
L0031:
  ADDI.L    #$2000,D0 
  LSL.L     #2,D0 
  SWAP      D0
  MOVE.B    14(A0),$254.W 
  ANDI.B    #$F0,$FFFFFA1D.W
  OR.B      D3,$FFFFFA1D.W
  MOVE.B    D0,$FFFFFA25.W
  BSET      #4,$FFFFFA09.W
  BRA.S     L0033 
L0032:
  BCLR      #4,$FFFFFA09.W
  CMPI.B    #5,63(A0) 
  BGT.S     L0033 
  CMPI.B    #3,63(A0) 
  BLT.S     L0033 
  BCLR      #0,44(A0) 
L0033:
  MOVE      #$2300,SR 
  MOVE.B    #$FF,D0 
  LEA       L00AF(PC),A0
  MOVEQ     #2,D6 
  MOVEQ     #5,D7 
  BSR       L0064 
  LEA       L00AE(PC),A0
  MOVEQ     #1,D6 
  MOVEQ     #4,D7 
  BSR       L0064 
  LEA       L00B0(PC),A0
  BTST      #1,58(A0) 
  BNE.S     L0034 
  MOVEQ     #0,D6 
  MOVEQ     #3,D7 
  BSR       L0064 
L0034:
  MOVE.W    #$700,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  LEA       L00B0(PC),A0
  BTST      #1,58(A0) 
  BNE.S     L0037 
  MOVE.W    0(A0),D0
  MOVE.B    0(A0),D1
  MOVEQ     #0,D7 
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$100,D7
  MOVE.B    D1,D7 
  MOVEP.W   D7,0(A5)
  TST.B     58(A0)
  BNE.S     L0035 
  TST.B     80(A0)
  BEQ.S     L0035 
  BTST      #2,44(A0) 
  BEQ.S     L0035 
  BTST      #3,44(A0) 
  BEQ.S     L0035 
  LSR.W     #4,D0 
  MOVE.W    #$B00,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$C00,D7
  MOVEP.W   D7,0(A5)
L0035:
  TST.W     $15AE.L 
  BPL.S     L0036 
  CMPI.B    #3,63(A0) 
  BLT.S     L0036 
  CMPI.B    #5,63(A0) 
  BGT.S     L0036 
  BRA.S     L0037 
L0036:
  MOVE.W    #$800,D7
  MOVE.B    14(A0),D7 
  MOVEP.W   D7,0(A5)
L0037:
  LEA       L00AE(PC),A0
  MOVE.W    0(A0),D0
  MOVE.B    0(A0),D1
  MOVE.W    #$200,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$300,D7
  MOVE.B    D1,D7 
  MOVEP.W   D7,0(A5)
  TST.B     58(A0)
  BNE.S     L0038 
  TST.B     80(A0)
  BEQ.S     L0038 
  BTST      #2,44(A0) 
  BEQ.S     L0038 
  BTST      #3,44(A0) 
  BEQ.S     L0038 
  LSR.W     #4,D0 
  MOVE.W    #$B00,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$C00,D7
  MOVEP.W   D7,0(A5)
L0038:
  TST.W     $15B0.L 
  BPL.S     L0039 
  CMPI.B    #3,63(A0) 
  BLT.S     L0039 
  CMPI.B    #5,63(A0) 
  BGT.S     L0039 
  BRA.S     L003A 
L0039:
  MOVE.W    #$900,D7
  MOVE.B    14(A0),D7 
  MOVEP.W   D7,0(A5)
L003A:
  LEA       L00AF(PC),A0
  MOVE.W    0(A0),D0
  MOVE.B    0(A0),D1
  MOVE.W    #$400,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$500,D7
  MOVE.B    D1,D7 
  MOVEP.W   D7,0(A5)
  TST.B     58(A0)
  BNE.S     L003B 
  TST.B     80(A0)
  BEQ.S     L003B 
  BTST      #2,44(A0) 
  BEQ.S     L003B 
  BTST      #3,44(A0) 
  BEQ.S     L003B 
  LSR.W     #4,D0 
  MOVE.W    #$B00,D7
  MOVE.B    D0,D7 
  MOVEP.W   D7,0(A5)
  MOVE.W    #$C00,D7
  MOVEP.W   D7,0(A5)
L003B:
  TST.W     $15B2.L 
  BPL.S     L003C 
  CMPI.B    #3,63(A0) 
  BLT.S     L003C 
  CMPI.B    #5,63(A0) 
  BGT.S     L003C 
  BRA.S     L003D 
L003C:
  MOVE.W    #$A00,D7
  MOVE.B    14(A0),D7 
  MOVEP.W   D7,0(A5)
L003D:
  RTS 
L003E:
  TST.B     (A1)
  BEQ       L0045 
  BMI       L0055 
  MOVE.B    2(A1),D1
  CMPI.B    #$3F,D1 
  BHI       L0042 
  MOVE.B    D1,57(A0) 
  MOVE.W    D4,76(A0) 
  MOVE.B    D4,56(A0) 
  LEA       L00B1(PC),A6
  MOVEQ     #0,D0 
  MOVE.B    57(A0),D0 
  ADD.W     D0,D0 
  ADD.W     D0,D0 
  MOVE.L    0(A6,D0.W),D0 
  MOVE.L    D0,60(A0) 
  LSR.L     #8,D0 
  TST.B     D0
  BEQ.S     L003F 
  LEA       L00AA(PC),A6
  MOVEQ     #0,D1 
  MOVE.B    D0,D1 
  SUBQ.B    #1,D1 
  ADD.W     D1,D1 
  ADD.W     D1,D1 
  MOVE.L    0(A6,D1.W),72(A0) 
L003F:
  LSR.L     #8,D0 
  TST.B     D0
  BEQ.S     L0040 
  LEA       L00A9(PC),A6
  MOVEQ     #0,D1 
  MOVE.B    D0,D1 
  SUBQ.B    #1,D1 
  ADD.W     D1,D1 
  ADD.W     D1,D1 
  MOVE.L    0(A6,D1.W),68(A0) 
L0040:
  LSR.W     #8,D0 
  TST.B     D0
  BEQ.S     L0041 
  LEA       L00A8(PC),A6
  MOVEQ     #0,D1 
  MOVE.B    D0,D1 
  SUBQ.W    #1,D1 
  ADD.W     D1,D1 
  ADD.W     D1,D1 
  MOVE.L    0(A6,D1.W),64(A0) 
L0041:
  MOVE.B    57(A0),D1 
  ANDI.W    #$3F,D1 
  LEA       $98A.L,A2 
  ASL.W     #8,D1 
  ADDA.W    D1,A2 
  MOVE.W    0(A2),D0
  MOVE.W    D0,42(A0) 
  MOVE.B    2(A2),44(A0)
  MOVE.W    4(A2),46(A0)
  MOVE.B    3(A2),45(A0)
  MOVE.L    6(A2),10(A0)
  MOVE.L    252(A2),48(A0)
  MOVE.W    D4,20(A0) 
  MOVE.L    10(A2),22(A0) 
  MOVE.W    14(A2),26(A0) 
  LEA       16(A2),A3 
  MOVE.L    A3,16(A0) 
  MOVE.W    D4,32(A0) 
  MOVE.L    240(A2),34(A0)
  MOVE.W    244(A2),38(A0)
  LEA       128(A2),A3
  MOVEQ     #0,D0 
  MOVE.B    (A1),D0 
  MOVE.W    D0,D1 
  LSR.W     #4,D1 
  LEA       L00AD(PC),A2
  ANDI.W    #$F,D0
  MOVE.L    A3,28(A0) 
  ST        40(A0)
  ANDI.W    #$F,D0
  MOVE.W    D0,D2 
  ADD.W     D2,D2 
  MOVE.W    0(A2,D2.W),D2 
  LSR.W     D1,D2 
  MOVE.W    D2,2(A0)
  MOVE.W    D0,D3 
  ADD.W     48(A0),D3 
  ADD.W     D3,D3 
  MOVE.W    0(A2,D3.W),D3 
  LSR.W     D1,D3 
  SUB.W     D2,D3 
  MOVE.W    D3,52(A0) 
  ADD.W     50(A0),D0 
  ADD.W     D0,D0 
  MOVE.W    0(A2,D0.W),D0 
  LSR.W     D1,D0 
  SUB.W     D2,D0 
  MOVE.W    D0,54(A0) 
L0042:
  MOVE.B    1(A1),D1
  BEQ.S     L0043 
  SUB.W     4(A0),D2
  EXT.L     D2
  ANDI.L    #$FF,D1 
  MULS      $A48.L,D1 
  DIVS      D1,D2 
  BEQ.S     L0043 
  MOVE.W    D2,6(A0)
  BRA.S     L0044 
L0043:
  MOVE.W    2(A0),4(A0) 
  MOVE.W    D4,6(A0)
L0044:
  MOVE.B    3(A1),D0
  ANDI.W    #$1F,D0 
  MOVE.B    D0,15(A0) 
L0045:
  ADDQ.L    #3,A1 
  MOVE.B    (A1)+,D1
  LSR.B     #6,D1 
  TST.B     D1
  BEQ.S     L0048 
  BTST      #2,44(A0) 
  BNE.S     L0049 
  CMPI.B    #1,D1 
  BEQ.S     L0047 
  CMPI.B    #2,D1 
  BEQ.S     L0046 
  MOVE.W    24(A0),20(A0) 
  MOVE.W    36(A0),32(A0) 
  BCLR      #0,58(A0) 
  ST        40(A0)
  RTS 
L0046:
  MOVE.W    22(A0),20(A0) 
  MOVE.W    34(A0),32(A0) 
  BCLR      #0,58(A0) 
  ST        40(A0)
  RTS 
L0047:
  MOVE.W    D4,8(A0)
  MOVE.W    D4,20(A0) 
  MOVE.W    D4,32(A0) 
  BCLR      #0,58(A0) 
  ST        40(A0)
  BCLR      #1,58(A0) 
L0048:
  RTS 
L0049:
  MOVEQ     #$B,D7
  MOVEQ     #$C,D6
  MOVEQ     #$D,D5
  TST.B     D1
  BEQ.S     L004E 
  CMPI.B    #2,D1 
  BEQ.S     L004F 
  CMPI.B    #3,D1 
  BEQ       L0054 
  MOVE      #$2700,SR 
  BTST      #3,44(A0) 
  BNE.S     L004A 
  MOVE.B    D7,(A5) 
  MOVE.B    47(A0),2(A5)
  MOVE.B    D6,(A5) 
  MOVE.B    46(A0),2(A5)
L004A:
  MOVE.B    D5,(A5) 
  BTST      #0,45(A0) 
  BNE.S     L004B 
  MOVE.B    (A5),D0 
  CMP.B     45(A0),D0 
  BEQ.S     L004C 
L004B:
  MOVE.B    45(A0),2(A5)
L004C:
  MOVE.W    D4,8(A0)
  MOVE.W    D4,32(A0) 
  ST        40(A0)
  BCLR      #0,58(A0) 
  BCLR      #1,58(A0) 
  BEQ.S     L004D 
  BCLR      #5,$FFFFFA07.W
  BCLR      #0,$FFFFFA07.W
L004D:
  MOVE      #$2300,SR 
L004E:
  RTS 
L004F:
  MOVE      #$2700,SR 
  BTST      #3,44(A0) 
  BNE.S     L0050 
  MOVE.B    D7,(A5) 
  MOVE.B    47(A0),2(A5)
  MOVE.B    D6,(A5) 
  MOVE.B    46(A0),2(A5)
L0050:
  MOVE.B    D5,(A5) 
  BTST      #0,45(A0) 
  BNE.S     L0051 
  MOVE.B    (A5),D0 
  CMP.B     45(A0),D0 
  BEQ.S     L0052 
L0051:
  MOVE.B    45(A0),2(A5)
L0052:
  MOVE.W    D4,8(A0)
  MOVE.W    34(A0),32(A0) 
  ST        40(A0)
  BCLR      #0,58(A0) 
  BCLR      #1,58(A0) 
  BEQ.S     L0053 
  BCLR      #5,$FFFFFA07.W
  BCLR      #0,$FFFFFA07.W
L0053:
  MOVE      #$2300,SR 
  RTS 
L0054:
  BSET      #0,58(A0) 
  RTS 
L0055:
  BTST      #2,58(A0) 
  BNE.S     L0058 
  CMPI.B    #$E,2(A1) 
  BNE.S     L0056 
  MOVE.W    #$FFFF,$1C5A.L
  BRA.S     L0057 
L0056:
  CMPI.B    #$F,2(A1) 
  BNE.S     L0057 
  MOVE.W    #$FFFF,$1C5C.L
L0057:
  MOVE.B    2(A1),D0
  ANDI.W    #$F,D0
  ASL.W     #2,D0 
  TST.W     $1C5C.L 
  BMI.S     L0059 
  MOVEQ     #0,D0 
  MOVE.B    3(A1),D0
  EXT.W     D0
  ADD.W     D0,D0 
  ADD.W     D0,D0 
  MOVEA.L   L005A(PC,D0.W),A6 
  JSR       (A6)
L0058:
  ADDQ.L    #4,A1 
  RTS 
L0059:
  MOVE.B    3(A1),D0
  EXT.W     D0
  MOVE.W    D0,$A4A.L 
  ADDQ.L    #4,A1 
  MOVE.W    D4,$1C5C.L
  RTS 
L005A:
  DC.B      $00,$00,$12,$E2,$00,$00,$12,'H' 
  DC.B      $00,$00,$12,'P',$00,$00,$12,'X' 
  DC.B      $00,$00,$12,'`',$00,$00,$12,$90 
  DC.B      $00,$00,$12,'p',$00,$00,$12,$A0 
  DC.B      $00,$00,$12,$80,$00,$00,$12,$B0 
  DC.B      $00,$00,$12,$C0,$00,$00,$12,$CC 
  DC.B      $00,$00,$12,$D8,$00,$00,$12,$E4 
  DC.B      $00,$00,$12,$E2,$00,$00,$12,$E2 
L005B:
  MOVE.L    #$8080000,$FFFF8800.W 
  MOVE.W    #$210,$116.W
  RTE 
  MOVE.L    #$8080000,$FFFF8800.W 
  MOVE.W    #$200,$116.W
  RTE 
  MOVE.L    #$9090000,$FFFF8800.W 
  MOVE.W    #$230,$136.W
  RTE 
  MOVE.L    #$9090000,$FFFF8800.W 
  MOVE.W    #$220,$136.W
  RTE 
  MOVE.L    #$A0A0000,$FFFF8800.W 
  MOVE.W    #$250,$112.W
  RTE 
  MOVE.L    #$A0A0000,$FFFF8800.W 
  MOVE.W    #$240,$112.W
  RTE 
  RTE 
L005C:
  MOVE.L    #$1010100,D6
  TST.B     61(A0)
  BEQ.S     L005E 
  MOVEA.L   68(A0),A6 
  MOVEQ     #0,D1 
  MOVE.B    (A6)+,D1
  CMP.B     #$FF,D1 
  BNE.S     L005D 
  MOVEQ     #0,D1 
  CMP.B     #$FE,D1 
  BNE.S     L005D 
  SUBQ.L    #1,A6 
  MOVE.B    -1(A6),D1 
L005D:
  MOVE.L    A6,68(A0) 
  ADD.W     D1,D1 
  ADD.W     D1,D1 
  MOVE.L    L005F(PC,D1.W),D7 
  MOVE.L    D7,78(A0) 
  RTS 
L005E:
  MOVE.L    D6,78(A0) 
  RTS 
L005F:
  DCB.W     2,0 
  DC.B      $01,$00,$00,$00,$00,$01,$00,$00 
  DC.B      $01,$01,$00,$00,$00,$00,$01,$00 
  DC.B      $01,$00,$01,$00,$01,$01,$01,$00 
L0060:
  TST.B     62(A0)
  BEQ.S     L0063 
  MOVEA.L   72(A0),A6 
  MOVE.B    (A6)+,D1
  CMPI.B    #$FF,D1 
  BEQ.S     L0062 
  CMPI.B    #$FE,D1 
  BNE.S     L0061 
  SUBQ.B    #1,D1 
  MOVE.B    -1(A6),D1 
L0061:
  MOVE.L    A6,72(A0) 
  TST.B     D1
  BNE.S     L0063 
L0062:
  BCLR      #2,44(A0) 
L0063:
  RTS 
L0064:
  BTST      #0,44(A0) 
  BEQ.S     L0066 
  TST.B     61(A0)
  BNE.S     L0065 
  TST.B     79(A0)
  BEQ.S     L0066 
L0065:
  BCLR      D6,D0 
L0066:
  BTST      #1,44(A0) 
  BEQ.S     L006A 
  TST.B     60(A0)
  BNE.S     L0067 
  MOVE.W    #$600,D5
  MOVE.B    43(A0),D5 
  MOVEP.W   D5,0(A5)
  BRA.S     L0069 
L0067:
  MOVEA.L   64(A0),A6 
  MOVE.B    (A6)+,D1
  CMPI.B    #$FF,D1 
  BEQ.S     L006A 
  CMPI.B    #$FE,D1 
  BNE.S     L0068 
  SUBQ.L    #1,A6 
  MOVE.B    -1(A6),D1 
L0068:
  MOVE.L    A6,64(A0) 
  MOVE.W    #$600,D5
  MOVE.B    D1,D5 
  MOVEP.W   D5,0(A5)
  TST.B     78(A0)
  BEQ.S     L006A 
L0069:
  BCLR      D7,D0 
L006A:
  RTS 
L006B:
  TST.B     58(A0)
  BNE       L008D 
  BTST      #2,44(A0) 
  BEQ.S     L006F 
  CMPI.B    #$D,63(A0)
  BNE.S     L006E 
  MOVEQ     #1,D7 
L006C:
  MOVEA.W   #$8800,A6 
  MOVEQ     #0,D0 
  MOVE.B    0(A0),D0
  ADD.B     83(A0),D0 
  LEA       L008E(PC),A2
  ANDI.W    #$3F,D0 
  MOVE.B    #$B,(A6)
  MOVE.B    0(A2,D0.W),2(A6)
  MOVE.B    #$C,(A6)
  MOVE.B    #0,2(A6)
  ADDQ.B    #1,83(A0) 
  CMPI.B    #$3F,83(A0) 
  BLE.S     L006D 
  MOVE.B    D4,83(A0) 
L006D:
  BRA.S     L0072 
L006E:
  MOVE.B    D4,83(A0) 
  MOVE.B    #$10,14(A0) 
  BRA.S     L0072 
L006F:
  MOVE.W    20(A0),D0 
  MOVEA.L   16(A0),A2 
  MOVE.B    0(A2,D0.W),D1 
  MOVE.B    15(A0),D2 
  ASL.B     #4,D2 
  ADD.B     D1,D2 
  ANDI.W    #$FF,D2 
  LEA       L00AC(PC),A2
  MOVE.B    0(A2,D2.W),14(A0) 
  ADDQ.W    #1,D0 
  CMP.W     24(A0),D0 
  BNE.S     L0070 
  MOVE.W    22(A0),D0 
L0070:
  CMP.W     26(A0),D0 
  BCS.S     L0071 
  BSET      #0,58(A0) 
L0071:
  MOVE.W    D0,20(A0) 
L0072:
  MOVE.W    6(A0),D0
  BEQ.S     L0076 
  BMI.S     L0074 
  ADD.W     4(A0),D0
  CMP.W     2(A0),D0
  BLT.S     L0073 
  MOVE.W    D4,6(A0)
  MOVE.W    2(A0),D0
L0073:
  MOVE.W    D0,4(A0)
  BRA.S     L0076 
L0074:
  ADD.W     4(A0),D0
  CMP.W     2(A0),D0
  BGT.S     L0075 
  MOVE.W    D4,6(A0)
  MOVE.W    2(A0),D0
L0075:
  MOVE.W    D0,4(A0)
L0076:
  MOVE.W    8(A0),D1
  ADD.W     10(A0),D1 
  CMPI.W    #$3B,D1 
  BLS.S     L0077 
  MOVEQ     #0,D1 
L0077:
  MOVE.W    D1,8(A0)
  ADD.W     D1,D1 
  LEA       L00AB(PC),A2
  MOVE.W    0(A2,D1.W),D1 
  MOVE.W    12(A0),D2 
  ASR.W     D2,D1 
  ADD.W     4(A0),D1
  CMPI.B    #1,63(A0) 
  BNE.S     L0078 
  LEA       L008F(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #1,76(A0) 
  BLT.S     L0078 
  MOVE.B    #1,76(A0) 
L0078:
  CMPI.B    #4,63(A0) 
  BNE.S     L0079 
  LEA       L008F(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #1,76(A0) 
  BLT.S     L0079 
  MOVE.B    #1,76(A0) 
L0079:
  CMPI.B    #5,63(A0) 
  BNE.S     L007A 
  LEA       L0092(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #2,77(A0) 
  CMPI.B    #$C,77(A0)
  BLT       L0084 
  MOVE.B    D4,77(A0) 
L007A:
  CMPI.B    #6,63(A0) 
  BNE.S     L007B 
  LEA       L0090(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #$40,76(A0) 
  BLT.S     L007B 
  MOVE.B    #1,76(A0) 
L007B:
  CMPI.B    #7,63(A0) 
  BNE.S     L007C 
  LEA       L0091(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #2,77(A0) 
  CMPI.B    #$20,77(A0) 
  BLT.S     L007C 
  MOVE.B    #2,77(A0) 
L007C:
  CMPI.B    #8,63(A0) 
  BNE.S     L007D 
  LEA       L0093(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #$30,76(A0) 
  BLT.S     L007D 
  MOVE.B    D4,76(A0) 
L007D:
  CMPI.B    #9,63(A0) 
  BNE.S     L007E 
  LEA       L0094(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,77(A0) 
  CMPI.B    #$20,77(A0) 
  BLT.S     L007E 
  MOVE.B    D4,77(A0) 
L007E:
  CMPI.B    #$A,63(A0)
  BNE.S     L0080 
  LEA       L0094(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,77(A0) 
  CMPI.B    #$20,77(A0) 
  BLT.S     L007F 
  MOVE.B    D4,77(A0) 
L007F:
  LEA       L0092(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #4,76(A0) 
  BLT.S     L0080 
  MOVE.B    D4,76(A0) 
L0080:
  CMPI.B    #$B,63(A0)
  BNE.S     L0082 
  LEA       L0096(PC),A1
  MOVE.B    76(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,76(A0) 
  CMPI.B    #$10,76(A0) 
  BLT.S     L0081 
  MOVE.B    D4,76(A0) 
L0081:
  LEA       L0091(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #1,77(A0) 
  CMPI.B    #$12,77(A0) 
  BLT.S     L0082 
  MOVE.B    D4,77(A0) 
L0082:
  CMPI.B    #$C,63(A0)
  BNE.S     L0083 
  TST.B     58(A0)
  BNE.S     L0083 
  BTST      #2,44(A0) 
  BEQ.S     L0083 
  LEA       L0095(PC),A1
  MOVE.B    82(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),D0 
  MOVE.B    D0,56(A0) 
  ANDI.W    #$3F,D0 
  ADD.W     D0,32(A0) 
  ADDQ.B    #1,82(A0) 
  CMPI.B    #$2A,82(A0) 
  BLT.S     L0083 
  MOVE.B    D4,82(A0) 
L0083:
  CMPI.B    #2,63(A0) 
  BNE.S     L0084 
  LEA       L0092(PC),A1
  MOVE.B    77(A0),D7 
  EXT.W     D7
  MOVE.B    0(A1,D7.W),56(A0) 
  ADDQ.B    #2,77(A0) 
  CMPI.B    #$C,77(A0)
  BLT.S     L0084 
  MOVE.B    D4,77(A0) 
L0084:
  MOVE.B    56(A0),D0 
  BEQ.S     L0086 
  CMPI.B    #1,D0 
  BEQ.S     L0085 
  ADD.W     54(A0),D1 
  MOVE.B    D4,56(A0) 
  BRA.S     L0087 
L0085:
  ADD.W     52(A0),D1 
L0086:
  ADDQ.B    #1,56(A0) 
L0087:
  TST.B     40(A0)
  BEQ.S     L008B 
  MOVE.W    32(A0),D0 
  MOVEA.L   28(A0),A2 
  MOVE.B    0(A2,D0.W),D2 
  EXT.W     D2
  TST.B     60(A0)
  BEQ.S     L0088 
  ADD.W     D2,D1 
  ADD.W     D2,D1 
  ADD.W     D2,D1 
L0088:
  ADD.W     D2,D1 
  ADDQ.W    #1,D0 
  CMP.W     36(A0),D0 
  BNE.S     L0089 
  MOVE.W    34(A0),D0 
L0089:
  CMP.W     38(A0),D0 
  BCS.S     L008A 
  MOVE.B    D4,40(A0) 
L008A:
  MOVE.W    D0,32(A0) 
L008B:
  MOVE.W    D1,0(A0)
  CMPI.B    #$D,63(A0)
  BNE.S     L008C 
  DBF       D7,L006C
L008C:
  MOVEQ     #0,D7 
  RTS 
L008D:
  MOVE.B    D4,14(A0) 
  RTS 
L008E:
  DC.B      $F0,$E2,$D4,$C8,$BE,$B2,$A8,$9E 
  DC.B      $96,$8E,$86,'~xqjd' 
  DC.B      '_YTOKGC?'
  DC.B      '<852/-*('
  DC.B      '&$" ',$1E,$1C,$1B,$19
  DC.B      $18,$16,$15,$14,$13,$12,$11,$10 
  DC.B      $0F,$0E,$0D,$0C,$0B,$0A,$09,$08 
  DC.B      $07,$06,$05,$04,$03,$02,$01,$00 
L008F:
  DC.B      $01,$00,$FF 
L0090:
  DC.B      $01,$00,$01,$00,$02,$00,$02,$00,$03 
  DC.B      $00,$FF 
L0091:
  DC.B      $00,$00,$01,$01,$02,$02,$03,$03 
  DC.B      $04,$04,$05,$05,$06,$06,$05,$05 
  DC.B      $04,$04,$03,$03,$02,$02,$01,$01 
  DC.B      $00,$00,$FF 
L0092:
  DC.B      $00,$00,$01,$01,$02,$02,$FF 
L0093:
  DC.B      $09,$09,$05,$05,$03,$03,$01,$01 
  DC.B      $02,$01,$01,$02,$02,$03,$03,$03 
  DC.B      $04,$04,$05,$00,$01,$02,$FF 
L0094:
  DC.B      $00,$08,$00,$07,$00,$06,$00,$05,$00 
  DC.B      $04,$00,$03,$00,$02,$00,$01,$00 
  DC.B      $01,$01,$00,$02,$00,$03,$00,$04 
  DC.B      $00,$05,$00,$06,$00,$FF,$01,$01 
  DC.B      $01,$00,$00,$00,$02,$02,$02,$00 
  DC.B      $00,$00,$03,$03,$03,$00,$00,$00 
  DC.B      $04,$04,$04,$00,$00,$00,$05,$05 
  DC.B      $05,$FF 
L0095:
  DC.B      $10,$0F,$10,$0E,$10,$0D,$10,$0C 
  DC.B      $10,$0B,$10,$0A,$10,$09,$10,$08 
  DC.B      $10,$07,$10,$06,$10,$05,$10,$04 
  DC.B      $10,$03,$10,$02,$10,$01,$10,$10 
  DC.B      $10,$10,$09,$08,$06,$04,$02,$00 
  DC.B      $02,$FF 
L0096:
  DC.B      $00,$09,$00,$08,$00,$07,$00,$06 
  DC.B      $00,$05,$00,$04,$00,$03,$00,$02 
  DC.B      $00,$01,$00,$01,$02,$03,$04,$05 
  DC.B      $06,$07,$08,$09,$FF,$00,'Fy'
  DC.B      $00,$00,$15,$A8,'NuFy'
  DC.B      $00,$00,$15,$AA,'NuFy'
  DC.B      $00,$00,$15,$AC,'Nu!',$FC 
  DC.B      $00,$00,$02,$00,$01,$14,'P',$F9 
  DC.B      $00,$00,$15,$AE,'Nu!',$FC 
  DC.B      $00,$00,$02,' ',$01,'4P',$F9
  DC.B      $00,$00,$15,$B0,'Nu!',$FC 
  DC.B      $00,$00,$02,'@',$01,$10,'P',$F9 
  DC.B      $00,$00,$15,$B2,'Nu!',$FC 
  DC.B      $00,$00,$0C,$C4,$01,$14,'Q',$F9 
  DC.B      $00,$00,$15,$AE,'Nu!',$FC 
  DC.B      $00,$00,$0C,$C4,$01,'4Q',$F9
  DC.B      $00,$00,$15,$B0,'Nu!',$FC 
  DC.B      $00,$00,$0C,$C4,$01,$10,'Q',$F9 
  DC.B      $00,$00,$15,$B2,'Nu#',$FC 
  DC.B      $00,$00,$15,$B4,$00,$00,$06,'L' 
  DC.B      'Nu#',$FC,$00,$00,$15,$E0 
  DC.B      $00,$00,$06,'LNu#',$FC
  DC.B      $00,$00,$16,':',$00,$00,$06,'L' 
  DC.B      'Nu#',$FC,$00,$00,$15,$B4 
  DC.B      $00,$00,$06,'L3',$FA,$09,'n'
  DC.B      $00,$00,$1C,'XP',$F9,$00,$00
  DC.B      $15,$A8,'P',$F9,$00,$00,$15,$AA 
  DC.B      'P',$F9,$00,$00,$15,$AC,'P',$F9 
  DC.B      $00,$00,$15,$AE,'P',$F9,$00,$00 
  DC.B      $15,$B0,'P',$F9,$00,$00,$15,$B2 
  DC.B      'Nu'
L0097:
  DC.B      $00,$00 
L0098:
  MOVEM.L   A0-A1,-(A7) 
  LEA       L0097(PC),A3
  TST.W     (A3)
  BNE.S     L0099 
  ST        (A3)
  BSR       L00B9 
  BSR       L0007 
  BSR       L000E 
L0099:
  MOVEM.L   (A7)+,A0-A1 
  MOVEQ     #0,D0 
  MOVE.W    D0,$1C56.L
  MOVE      #$2700,SR 
  MOVE.L    A0,$2234.L
  MOVE.L    A1,$2230.L
  MOVEA.L   L00B8(PC),A0
  LEA       516(A0),A0
  MOVE.L    A0,$98C.L 
  MOVEA.L   L00B7(PC),A0
  ADDQ.L    #4,A0 
  MOVE.W    (A0),$1C5E.L
  MOVE.L    A0,$4FA.L 
  MOVE.L    A0,$A4A.L 
  ADDQ.L    #2,A0 
  MOVE.L    A0,$1574.L
  ADDQ.L    #2,A0 
  MOVE.L    A0,$156C.L
  ADDQ.L    #2,A0 
  MOVE.L    A0,$14EA.L
  ADDQ.L    #2,A0 
  MOVE.L    A0,$1580.L
  LEA       120(A0),A0
  MOVE.L    A0,$14F2.L
  MOVE.L    A0,$151A.L
  MOVE.L    A0,$1524.L
  LEA       L00B1(PC),A1
  MOVEA.L   L00B8(PC),A0
  LEA       16900(A0),A0
  CMPI.L    #$494E464F,(A0)+
  BEQ.S     L009A 
  LEA       L00A7(PC),A0
L009A:
  MOVEQ     #$1F,D0 
L009B:
  MOVE.L    (A0)+,(A1)+ 
  MOVE.L    (A0)+,(A1)+ 
  DBF       D0,L009B
  BSR       L009F 
  BCLR      #3,$FFFFFA17.W
  BSR       L0013 
  MOVE.L    #$240,$110.W
  ANDI.B    #$F0,$FFFFFA1D.W
  ORI.B     #1,$FFFFFA1D.W
  CLR.B     $FFFFFA25.W 
  BSET      #4,$FFFFFA15.W
  BCLR      #4,$FFFFFA09.W
  MOVE.L    #$200,$114.W
  ANDI.B    #$F,$FFFFFA1D.W 
  ORI.B     #$38,$FFFFFA1D.W
  CLR.B     $FFFFFA23.W 
  BSET      #5,$FFFFFA15.W
  BCLR      #5,$FFFFFA09.W
  MOVE.L    #$220,$134.W
  CLR.B     $FFFFFA19.W 
  MOVE.B    #1,$FFFFFA19.W
  MOVE.B    #1,$FFFFFA1F.W
  BSET      #5,$FFFFFA13.W
  BCLR      #5,$FFFFFA07.W
  BSR.S     L009C 
  ST        $C3.L 
  SF        $C2.L 
  MOVE      #$2300,SR 
  RTS 
L009C:
  LEA       L00AE(PC),A0
  BCLR      #5,$FFFFFA07.W
  BCLR      #4,$FFFFFA09.W
  BSET      #0,224(A0)
  BCLR      #1,224(A0)
  BSET      #0,60(A0) 
  BSET      #0,142(A0)
  ST        223(A0) 
  ST        59(A0)
  ST        141(A0) 
  LEA       $FFFF8800.W,A0
  LEA       L009E(PC),A1
  MOVEQ     #$C,D1
L009D:
  MOVE.W    (A1)+,D0
  MOVEP.W   D0,0(A0)
  DBF       D1,L009D
  MOVE.B    #7,(A0) 
  MOVE.B    (A0),D0 
  ANDI.B    #$C0,D0 
  ORI.B     #$3F,D0 
  MOVE.B    D0,2(A0)
  RTS 
L009E:
  DC.B      $00,$00,$01,$00,$02,$00,$03,$00 
  DC.B      $04,$00,$05,$00,$06,$00,$08,$00 
  DC.B      $09,$00,$0A,$00,$0B,$00,$0C,$00 
  BTST      D6,D0 
L009F:
  BSR.S     L00A0 
  CLR.W     $221E.L 
  CLR.B     $234.W
  BRA       L00A5 
L00A0:
  MOVE.W    #1,$14E6.L
  MOVEQ     #$1F,D0 
  LEA       $14F0.L,A0
  MOVE.L    #$20005,D7
  LEA       L00B3(PC),A1
L00A1:
  MOVE.L    A0,(A1)+
  LEA       768(A0),A0
  DBF       D0,L00A1
  MOVE.W    #1,$222E.L
  CLR.W     $2036.L 
  MOVE.L    #$1518,$2220.L
  MOVE.L    #$1522,$221A.L
  LEA       L00B6(PC),A1
  LEA       L00AE(PC),A0
  MOVEQ     #9,D1 
  MOVEQ     #2,D2 
L00A2:
  CLR.B     46(A0)
  MOVE.L    A1,16(A0) 
  MOVE.L    D7,24(A0) 
  MOVE.W    D1,28(A0) 
  MOVE.L    A1,30(A0) 
  MOVE.L    D7,36(A0) 
  MOVE.W    D1,40(A0) 
  LEA       82(A0),A0 
  DBF       D2,L00A2
  RTS 
L00A3:
  MOVE.W    D4,$221E.L
  MOVE.W    L00B2(PC),D0
  ADDQ.W    #1,D0 
  CMP.W     $156A.L,D0
  BLS.S     L00A4 
  MOVE.W    $1572.L,D0
L00A4:
  MOVE.W    D0,$2036.L
L00A5:
  LEA       $157E.L,A0
  MOVE.W    L00B2(PC),D0
  MOVE.B    0(A0,D0.W),D0 
  ANDI.W    #$7F,D0 
  MOVE.W    D0,$2038.L
  LEA       L00B3(PC),A0
  ADD.W     D0,D0 
  ADD.W     D0,D0 
  MOVE.L    0(A0,D0.W),$221A.L
  RTS 
  DC.B      $00,$01,$00,$01,$00,$01,$FF,$FF 
  DC.B      $FF,$FF,$FF,$FF 
L00A6:
  DC.B      $00,'h',$00,$04,$00,$01,$01,$05 
  DC.B      $00,$0A,$00,$02,$01,$A2,$00,$10 
  DC.B      $00,$03,$05,$1A,$00,'2',$00,$04 
  DC.B      $06,$88,$00,'@',$00,$05,$0A,'5' 
  DC.B      $00,'d',$00,$06,$0E,$EF,$00,$C8 
  DC.B      $00,$07,$FF,$FF,$00,'h',$00,$04 
  DC.B      $00,$01,$01,$05,$00,$14,$00,$02 
  DC.B      $01,$A0,$00,$10,$00,$03,$05,$19 
  DC.B      $00,'d',$00,$04,$03,'@',$00,'@' 
  DC.B      $00,$05,$0A,'2',$00,$C8,$00,$06 
  DC.B      $0E,$A0,$01,$00,$00,$07,$0F,'K' 
  DC.B      $00,'h',$00,$04,$00,$01,$01,$05 
  DC.B      $00,$14,$00,$02,$01,$A0,$00,$10 
  DC.B      $00,$03,$05,$19,$00,'d',$00,$04 
  DC.B      $03,'@',$00,'@',$00,$05,$0A,'2' 
  DC.B      $00,$C8,$00,$06,$0E,$A0,$01,$00 
  DC.B      $00,$07,$0F,'K',$FF,$FF,$00,'h' 
  DC.B      $00,$04,$00,$01,$01,$05,$00,$1E 
  DC.B      $00,$02,$01,$A0,$00,$10,$00,$03 
  DC.B      $05,$19,$00,$96,$00,$04,$03,'@' 
  DC.B      $00,'@',$00,$05,$0A,'2',$01,',' 
  DC.B      $00,$06,$0E,$A0,$01,$00,$00,$07 
  DC.B      $0F,'K',$00,'h',$00,$04,$00,$01 
  DC.B      $01,$05,$00,$1E,$00,$02,$01,$A0 
  DC.B      $00,$10,$00,$03,$05,$19,$00,$96 
  DC.B      $00,$04,$03,'@',$00,'@',$00,$05 
  DC.B      $0A,'2',$01,',',$00,$06,$0E,$A0 
  DC.B      $01,$00,$00,$07,$0F,'K',$FF,$FF 
L00A7:
  DC.B      $01,$01,$00,$00,$02,$02,$00,$00 
  DC.B      $00,$00,$01,$00,$00,$00,$00,$03 
  DC.B      $00,$00,$00,$03,$03,$03,$00,$01 
  DC.B      $00,$00,$00,$01,$00,$00,$00,$02 
  DC.B      $00,$00,$00,$02,$00,$00,$00,$02 
  DC.B      $00,$00,$00,$02,$00,$00,$00,$01 
  DC.B      $00,$00,$00,$03,$00,$00,$00,$00 
  DCB.W     17,0
  DC.B      $00,$03,$00,$00,$00,$00,$00,$00 
  DCB.W     77,0
L00A8:
  DC.B      $00,$00,$19,'4',$00,$00,$19,'6' 
  DC.B      $00,$00,$19,'>',$00,$00,$19,'@' 
  DC.B      $00,$00,$19,'B',$00,$00,$19,'E' 
  DC.B      $00,$00,$19,'I',$00,$00,$19,'N' 
  DC.B      $00,$00,$19,'W',$00,$00,$19,'Y' 
  DC.B      $00,$00,$19,'[',$00,$00,$19,']' 
  DC.B      $00,$00,$19,'`',$00,$00,$19,'c' 
  DC.B      $00,$00,$19,'i',$00,$00,$19,'r' 
  DC.B      $00,$00,$19,$82,$00,$00,$19,$8C 
  DC.B      $00,$00,$19,$8F,$00,$00,$19,$92 
  DC.B      $00,$00,$19,$94,$00,$00,$19,$9E 
  DC.B      $00,$00,$19,$A0,$00,$00,$19,$A8 
  DC.B      $00,$00,$19,$AE,$00,$00,$19,$B6 
  DC.B      $00,$00,$19,$B9,$00,$00,$19,$C0 
  DC.B      $00,$00,$19,$C4,$00,$00,$19,$CC 
  DC.B      $00,$00,$19,$CF,$00,$00,$19,$D7 
  DC.B      $00,$00,$19,$D9,$00,$00,$19,$E2 
  DC.B      $00,$00,$19,$E9,$00,$00,$19,$EC 
  DC.B      $00,$00,$19,$EE,$00,$00,$19,$F6 
  DC.B      $00,$00,$19,$F8,$00,$00,$19,$FB 
  DC.B      $00,$00,$1A,$00,$00,$00,$1A,$06 
  DC.B      $00,$00,$1A,$08,$00,$00,$1A,$0D 
  DC.B      $00,$00,$1A,$16,$00,$00,$1A,$1A 
  DC.B      $00,$00,$1A,$1F 
L00A9:
  DC.B      $00,$00,$1A,',',$00,$00,$1A,'/' 
  DC.B      $00,$00,$1A,'6',$00,$00,$1A,'9' 
  DC.B      $00,$00,$1A,'@',$00,$00,$1A,'N' 
  DC.B      $00,$00,$1A,'Y',$00,$00,$1A,'f' 
  DC.B      $00,$00,$1A,'p',$00,$00,$1A,'w' 
  DC.B      $00,$00,$1A,$7F,$00,$00,$1A,$8D 
  DC.B      $00,$00,$1A,$93,$00,$00,$1A,$9A 
  DC.B      $00,$00,$1A,$A0,$00,$00,$1A,$A6 
  DC.B      $00,$00,$1A,$AA,$00,$00,$1A,$AD 
  DC.B      $00,$00,$1A,$BD,$00,$00,$1A,$C0 
  DC.B      $00,$00,$1A,$CF,$00,$00,$1A,$D2 
  DC.B      $00,$00,$1A,$E1,$00,$00,$1A,$E4 
  DC.B      $00,$00,$1A,$EB,$00,$00,$1A,$F1 
  DC.B      $00,$00,$1A,$F8,$00,$00,$1B,$00 
  DC.B      $00,$00,$1B,$14,$00,$00,$1B,'&' 
  DC.B      $00,$00,$1B,';',$00,$00,$1B,'J' 
  DC.B      $00,$00,$1B,'O',$00,$00,$1B,'U' 
L00AA:
  DC.B      $00,$00,$1B,'X',$00,$00,$1B,'\' 
  DC.B      $00,$00,$1B,'_',$00,$00,$1B,'a' 
  DC.B      $00,$00,$1B,'f',$00,$00,$1B,'m' 
  DC.B      $00,$00,$1B,'s',$00,$00,$1B,'z' 
  DC.B      $00,$00,$1B,$82,$00,$00,$1B,$8B 
  DC.B      $00,$00,$1B,$94,$00,$00,$1B,$9D 
  DC.B      $00,$00,$1B,$A6,$00,$00,$1B,$AF 
  DC.B      $00,$00,$1B,$B8,$00,$00,$1B,$B8 
  DC.B      $00,$00,$1B,$B8,$00,$00,$1B,$B8 
  DC.B      $00,$00,$1B,$B8,$00,$00,$1B,$B8 
  DC.B      $00,$00,$1B,$B8,$00,$00,$1B,$B8 
  DC.B      $00,$00,$1B,$B8,$00,$00,$1B,$B8 
  DC.B      $10,$FF,$0A,$11,$0F,$11,$0D,$0C 
  DC.B      $08,$FF,$04,$FF,$03,$FF,'  '
  DC.B      $FF,$09,'  ',$FF,' ',$09,$0C
  DC.B      ' ',$FF,' ',$04,$08,$0E,$12,$16 
  DC.B      $1A,$1E,$FE,' ',$FE,' ',$FE,$11 
  DC.B      $FE,' ',$08,$FE,$0D,$09,$FE,$13 
  DC.B      $0E,$0C,$0B,$04,$FE,'  ',$19
  DC.B      $0A,$05,$03,$02,$01,$FE,$01,$02 
  DC.B      $03,$04,$05,$06,$07,$08,$07,$06 
  DC.B      $05,$04,$03,$02,$01,$FE,$0D,$03 
  DC.B      $0D,$05,$0D,$11,$06,$11,$06,$FE 
  DC.B      $0E,$15,$FE,$0F,$18,$FE,$18,$FF 
  DC.B      $06,$15,$0C,$15,$07,$15,$04,$15 
  DC.B      $08,$FF,' ',$FF,$0F,$16,$14,$16 
  DC.B      $12,$11,$0D,$FF,'  ',$18,$10
  DC.B      $08,$FF,$14,$1B,$19,$1B,$17,$16 
  DC.B      $12,$FF,'0',$08,$FF,'/',$05,'/' 
  DC.B      $03,'*',$01,$FF,$08,$10,'P',$FF 
  DC.B      $14,$12,$10,$0E,$0C,$0A,$08,$FF 
  DC.B      $12,$08,$FF,$16,$12,'(+*' 
  DC.B      ')(',$FF,$04,$FF,$02,$12,'1'
  DC.B      $01,'%',$05,'6',$06,$FF,$0A,$0B 
  DC.B      $0C,$0D,$0E,$0F,$FF,')',$01,$FF 
  DC.B      $0B,$FF,$0A,$00,$00,$00,$0E,$04 
  DC.B      $04,$FF,'+',$FF,$15,$02,$FF,$0C 
  DC.B      $01,$02,$01,$FF,$0D,$0D,$0D,$01 
  DC.B      $03,$FF,$01,$FF,$14,$04,$0A,$02 
  DC.B      $FF,$0C,$01,$04,$0E,$04,$10,$04 
  DC.B      $12,$FF,$00,$00,$09,$FF,$00,$00 
  DC.B      $09,$0C,$FF,$00,$00,$00,$01,$01 
  DC.B      $01,$00,$00,$01,$01,$00,$01,$FF 
  DC.B      $01,$02,$FE,$03,$02,$02,$02,$01 
  DC.B      $01,$FE,$03,$02,$FE,$07,$04,$04 
  DC.B      $04,$02,$02,$FF,$01,$00,$00,$00 
  DC.B      $01,$00,$0E,$0F,$0F,$0E,$0C,$08 
  DC.B      $00,$FE,$00,$02,$02,$02,$02,$03 
  DC.B      $00,$0E,$0D,$0C,$FE,$03,$00,$0E 
  DC.B      $00,$0D,$0B,$09,$07,$05,$03,$01 
  DC.B      $00,$FE,$02,$0E,$00,$00,$02,$02 
  DC.B      $00,$01,$10,$FE,$0C,$04,$00,$00 
  DC.B      $0C,$0D,$FE,$02,$03,$03,$00,$00 
  DC.B      $0C,$0D,$FE,$01,$00,$00,$00,$02 
  DC.B      $00,$0F,$0F,$0E,$0D,$0C,$0C,$00 
  DC.B      $FE,$06,$00,$00,$00,$00,$FE,$19 
  DC.B      $14,$0F,$0A,$05,$00,$FE,$00,$01 
  DC.B      $00,$07,$0C,$FE,$00,$00,$18,$0C 
  DC.B      $00,$FE,$14,$0A,$00,$FE,$03,$04 
  DC.B      $FE,$08,$05,$05,$05,$05,$05,$05 
  DC.B      $04,$04,$04,$03,$03,$02,$02,$01 
  DC.B      $FE,$08,$07,$FE,$05,$04,$03,$02 
  DC.B      $01,$02,$03,$04,$05,$06,$07,$08 
  DC.B      $09,$0A,$FE,$08,$0A,$FE,$09,$08 
  DC.B      $08,$08,$08,$08,$08,$08,$07,$07 
  DC.B      $07,$06,$06,$05,$FE,$09,$06,$FE 
  DC.B      $0A,$0B,$0C,$0D,$0E,$0F,$FE,$0B 
  DC.B      $0C,$0D,$0E,$0F,$FE,$01,$0B,$01 
  DC.B      $0C,$01,$0D,$FE,'(',$04,'(',$04 
  DC.B      '(',$04,'(',$FE,$01,$02,$03,$04 
  DC.B      $05,$06,$07,$08,$09,$0A,$09,$08 
  DC.B      $07,$06,$05,$04,$03,$02,$01,$FE 
  DC.B      $09,$08,$07,$06,$05,$04,$03,$02 
  DC.B      $01,$02,$03,$04,$05,$06,$07,$08 
  DC.B      $09,$FE,$0A,$00,$09,$00,$08,$00 
  DC.B      $07,$00,$06,$00,$05,$00,$04,$00 
  DC.B      $03,$00,$02,$00,$01,$00,$FE,$14 
  DC.B      $12,$10,$0E,$0C,$0A,$08,$07,$06 
  DC.B      $05,$04,$03,$02,$01,$FE,' ',$01 
  DC.B      $10,$02,$FE,$0A,$14,$00,$14,$0A 
  DC.B      $FE,$0A,$05,$FE,$01,$01,$01,$FF 
  DC.B      $01,$01,$FF,$01,$FF,$01,$01,$01 
  DC.B      $01,$FE,$0A,$0B,$0C,$0D,$0E,$0F 
  DC.B      $FE,$01,$01,$01,$01,$01,$FE,$01 
  DC.B      $01,$01,$01,$01,$01,$FE,'(('
  DC.B      '(((((',$FE,$01,$01 
  DC.B      $01,$01,$01,$01,$01,$01,$FE,$01 
  DC.B      $02,$01,$02,$01,$02,$01,$02,$FE 
  DC.B      $02,$01,$02,$01,$02,$01,$02,$01 
  DC.B      $FE,$01,$03,$01,$03,$01,$03,$01 
  DC.B      $03,$FE,$03,$01,$03,$01,$03,$01 
  DC.B      $03,$01,$FE,$01,$04,$01,$04,$01 
  DC.B      $04,$01,$04,$FE,$01,$01,$04,$01 
  DC.B      $04,$01,$04,$01,$FE,$01,$01,$04 
  DC.B      $01,$04,$01,$04,$01,$FE,$01,$01 
  DC.B      $04,$01,$04,$01,$04,$01,$FE,$01 
  DC.B      $01,$04,$01,$04,$01,$04,$01,$FE 
L00AB:
  DC.B      $00,$00,$01,$AC,$03,'T',$04,$F2 
  DC.B      $06,$82,$08,$00,$09,'h',$0A,$B5 
  DC.B      $0B,$E4,$0C,$F2,$0D,$DB,$0E,$9E 
  DC.B      $0F,'8',$0F,$A6,$0F,$EA,$10,$00 
  DC.B      $0F,$EA,$0F,$A6,$0F,'8',$0E,$9E 
  DC.B      $0D,$DB,$0C,$F2,$0B,$E4,$0A,$B5 
  DC.B      $09,'h',$08,$00,$06,$82,$04,$F2 
  DC.B      $03,'T',$01,$AC,$00,$00,$FE,'T' 
  DC.B      $FC,$AC,$FB,$0E,$F9,'~',$F8,$00 
  DC.B      $F6,$98,$F5,'K',$F4,$1C,$F3,$0E 
  DC.B      $F2,'%',$F1,'b',$F0,$C8,$F0,'Z' 
  DC.B      $F0,$16,$F0,$00,$F0,$16,$F0,'Z' 
  DC.B      $F0,$C8,$F1,'b',$F2,'%',$F3,$0E 
  DC.B      $F4,$1C,$F5,'K',$F6,$98,$F8,$00 
  DC.B      $F9,'~',$FB,$0E,$FC,$AC,$FE,'T' 
  DCB.W     6,0 
L00AC:
  DCB.W     12,0
  DC.B      $01,$01,$01,$01,$01,$01,$01,$01 
  DCB.W     2,0 
  DC.B      $01,$01,$01,$01,$01,$01,$01,$01 
  DC.B      $02,$02,$02,$02,$00,$00,$00,$01 
  DC.B      $01,$01,$01,$01,$02,$02,$02,$02 
  DC.B      $02,$03,$03,$03,$00,$00,$01,$01 
  DC.B      $01,$01,$02,$02,$02,$02,$03,$03 
  DC.B      $03,$03,$04,$04,$00,$00,$01,$01 
  DC.B      $01,$02,$02,$02,$03,$03,$03,$04 
  DC.B      $04,$04,$05,$05,$00,$00,$01,$01 
  DC.B      $02,$02,$02,$03,$03,$04,$04,$04 
  DC.B      $05,$05,$06,$06,$00,$00,$01,$01 
  DC.B      $02,$02,$03,$03,$04,$04,$05,$05 
  DC.B      $06,$06,$07,$07,$00,$01,$01,$02 
  DC.B      $02,$03,$03,$04,$04,$05,$05,$06 
  DC.B      $06,$07,$07,$08,$00,$01,$01,$02 
  DC.B      $02,$03,$04,$04,$05,$05,$06,$07 
  DC.B      $07,$08,$08,$09,$00,$01,$01,$02 
  DC.B      $03,$03,$04,$05,$05,$06,$07,$07 
  DC.B      $08,$08,$09,$0A,$00,$01,$01,$02 
  DC.B      $03,$04,$04,$05,$06,$07,$07,$08 
  DC.B      $09,$0A,$0A,$0B,$00,$01,$02,$02 
  DC.B      $03,$04,$05,$06,$06,$07,$08,$09 
  DC.B      $0A,$0A,$0B,$0C,$00,$01,$02,$03 
  DC.B      $03,$04,$05,$06,$07,$08,$09,$0A 
  DC.B      $0A,$0B,$0C,$0D,$00,$01,$02,$03 
  DC.B      $04,$05,$06,$07,$07,$08,$09,$0A 
  DC.B      $0B,$0C,$0D,$0E,$00,$01,$02,$03 
  DC.B      $04,$05,$06,$07,$08,$09,$0A,$0B 
  DC.B      $0C,$0D,$0E,$0F,$FF,$00 
L00AD:
  DC.B      $0F,$D1,$0E,$EE,$0E,$17,$0D,'M' 
  DC.B      $0C,$BE,$0B,$D9,$0B,'/',$0A,$8E 
  DC.B      $09,$F7,$09,'g',$08,$E0,$08,'a' 
  DC.B      $07,$E8,$07,'w',$07,$0C,$06,$A7 
  DC.B      $06,'G',$05,$ED,$05,$98,$05,'G' 
  DC.B      $04,$FC,$04,$B4,$04,'p',$04,'1' 
  DC.B      $03,$F4,$03,$BB,$03,$85,$03,'S' 
  DC.B      $03,'#',$02,$F6,$02,$CB,$02,$A3 
  DC.B      $02,'}',$02,'Y',$02,'8',$02,$18 
  DC.B      $01,$FA,$01,$DD,$01,$C2,$01,$A9 
  DC.B      $01,$91,$01,'{',$01,'e',$01,'Q' 
  DC.B      $01,'>',$01,',',$01,$1C,$01,$0C 
  DC.B      $00,$FD,$00,$EE,$00,$E1,$00,$D4 
  DC.B      $00,$C8,$00,$BD,$00,$B2,$00,$A8 
  DC.B      $00,$9F,$00,$96,$00,$8E,$00,$86 
  DC.B      $00,'~',$00,'w',$00,'p',$00,'j' 
  DC.B      $00,'d',$00,'^',$00,'Y',$00,'T' 
  DC.B      $00,'O',$00,'K',$00,'G',$00,'C' 
  DC.B      $00,'?',$00,';',$00,'8',$00,'5' 
  DC.B      $00,'2',$00,'/',$00,',',$00,'*' 
  DC.B      $00,$27,$00,'%',$00,'#',$00,'!' 
  DC.B      $00,$1F,$00,$1D,$00,$1C,$00,$1A 
  DC.B      $00,$19,$00,$17,$00,$16,$00,$15 
  DC.B      $00,$13,$00,$12,$00,$11,$00,$10 
  DC.B      $00,$0F,$00,$0E,$00,$0D,$00,$0C 
  DC.B      $00,$0B,$00,$0A,$00,$09,$00,$08 
  DC.B      $00,$07,$00,$06,$00,$05,$00,$04 
  DC.B      $00,$03,$00,$02,$00,$01,$00,$00 
  DC.B      $00,$00 
L00AE:
  DCB.W     41,0
L00AF:
  DCB.W     41,0
L00B0:
  DCB.W     41,0
L00B1:
  DCB.W     126,0 
L00B2:
  DCB.W     2,0 
L00B3:
  DCB.W     240,0 
L00B4:
  DCB.W     2,0 
L00B5:
  DCB.W     3,0 
L00B6:
  DCB.W     6,0 
L00B7:
  DCB.W     2,0 
L00B8:
  DCB.W     2,0 
L00B9:
  MOVEM.L   A0-A3/D0-D1,-(A7) 
  LEA       L00BE(PC),A3
  TST.W     (A3)
  BNE.S     L00BD 
  ST        (A3)
  LEA       L0000(PC),A3
  MOVE.L    A3,D0 
  LEA       L00BF(PC),A1
  ADDA.L    #0,A1 
  ADDA.L    (A1)+,A3
  MOVEQ     #0,D1 
L00BA:
  ADD.L     D0,(A3) 
L00BB:
  MOVE.B    (A1)+,D1
  BEQ.S     L00BD 
  CMP.W     #2,D1 
  BCS.S     L00BC 
  ADDA.W    D1,A3 
  BRA.S     L00BA 
L00BC:
  LEA       254(A3),A3
  BRA.S     L00BB 
L00BD:
  MOVEM.L   (A7)+,A0-A3/D0-D1 
  RTS 
L00BE:
  DC.B      $00,$00 
L00BF:
  DC.B      $00,$00,$00,'r',$10,$14,$14,$0C 
  DC.B      $06,$01,'D',$01,$01,'v*',$14
  DC.B      $06,$1C,$0E,$14,$08,$04,$18,$06 
  DC.B      $0A,$08,$08,'b>^',$18,'(' 
  DC.B      'T>',$E4,'vv',$B6,$BE,$01 
  DC.B      $88,$12,$10,'$',$08,$06,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$01,$01,$01 
  DC.B      $01,$01,$F4,$08,$08,$10,$10,$10 
  DC.B      $08,$08,$08,$08,$08,$08,$08,$04 
  DC.B      $08,$04,$08,$04,$08,$04,$08,$06 
  DC.B      $06,$06,$06,$06,$06,'*',$0A,$06 
  DC.B      $0E,$0C,$06,$06,$08,$08,$08,$08 
  DC.B      $0A,$06,$06,$A4,$06,$84,$10,$08 
  DC.B      $1C,$06,$06,$04,$06,$04,'8',$0C 
  DC.B      $08,$06,$06,$12,$10,$01,$F0,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$04 
  DC.B      $04,$04,$04,$04,$04,$04,$04,$00 
ZUEND: END
