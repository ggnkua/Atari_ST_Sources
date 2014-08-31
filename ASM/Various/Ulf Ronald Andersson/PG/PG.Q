L008C EQU ZUEND+0 
 TEXT 
Begin:
  LEA       L007A,A7
  CLR.L     -(A7) 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.L    D0,L0076
  DC.B      $A0,$00,$A0,$0A 
  MOVE.L    $42E.W,L0077
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  PEA       L006E 
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
L0000:
  MOVE.W    #7,-(A7) 	;CRAWCIN
  TRAP      #1
  ADDQ.L    #2,A7 
  SWAP      D0
  CMP.B     #$17,D0 
  BNE.S     L0001 
  BCHG      #0,L0088
  CLR.L     D0
  MOVE.B    L0088,D0
  LSL.L     #2,D0 
  LEA       L0073,A1
  MOVEA.L   0(A1,D0.W),A0 
  PEA       (A0)
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
  BRA.S     L0000 
L0001:
  CMP.B     #$30,D0 	;#'0'
  BEQ.S     L0003 
  TST.B     L0088 
  BNE.S     L0002 
  BSR       L0008 
L0002:
  DC.B      $A0,$09 
  MOVE.L    L0076,-(A7) 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  CLR.W     -(A7) 
  MOVE.L    #$9088,-(A7)
  MOVE.W    #$31,-(A7) 	;PTERMRES 
  TRAP      #1
  ADDQ.L    #8,A7 
L0003:
  TST.B     L0088 
  BNE.S     L0004 
  BSR.S     L0008 
L0004:
  PEA       L0070 
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.W    #7,-(A7) 	;CRAWCIN
  TRAP      #1
  ADDQ.L    #2,A7 
  PEA       L0071 
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.W    #1,-(A7)
  CLR.W     -(A7) 
  CLR.W     -(A7) 
  MOVE.W    #1,-(A7)
  CLR.W     -(A7) 
  CLR.L     -(A7) 
  PEA       L007B 
  MOVE.W    #8,-(A7) 	;FLOPRD 
  TRAP      #$E 
  LEA       20(A7),A7 
  LEA       L007B,A0
  MOVE.W    #$FF,D1 
  MOVE.W    #$1234,D0 
L0005:
  SUB.W     (A0)+,D0
  DBF       D1,L0005
  TST.W     D0
  BNE.S     L0006 
  BSR       L007B 
  BRA.S     L0007 
L0006:
  PEA       L0072 
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.W    #7,-(A7) 	;CRAWCIN
  TRAP      #1
  ADDQ.L    #2,A7 
L0007:
  BRA       L0002 
L0008:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  TST.B     $134.W
  BNE.S     L0009 
  MOVE.L    $134.W,L0084
  MOVE.L    #L000C,$134.W 
  BRA.S     L000A 
L0009:
  MOVE.L    #L000B,-(A7)
  MOVE.W    #$FA,-(A7)
  MOVE.W    #7,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$1F,-(A7) 	;XBTIMER
  TRAP      #$E 
  LEA       12(A7),A7 
L000A:
  MOVE      (A7)+,SR
  BSR.S     L000D 
  BSR.S     L000F 
  BSR       L0011 
  BSR       L001C 
  BSR       L001E 
  BSR       L001D 
  RTS 
L000B:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  BCLR      #5,$FFFA0F.L
  RTE 
L000C:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    L0084,-(A7) 
  RTS 
L000D:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  MOVE.L    $120.W,L0085
  MOVE.L    #L000E,$120.W 
  MOVE      (A7)+,SR
  RTS 
L000E:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    L0085,-(A7) 
  RTS 
L000F:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  MOVE.L    $114.W,L0086
  MOVE.L    #L0010,$114.W 
  MOVE      (A7)+,SR
  RTS 
L0010:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    L0086,-(A7) 
  RTS 
L0011:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  MOVE.L    $110.W,L0087
  MOVE.L    #L0012,$110.W 
  MOVE      (A7)+,SR
  RTS 
L0012:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    L0087,-(A7) 
  RTS 
  MOVE.L    $84.W,L0015 
  MOVE.L    #L0013,$84.W
  MOVE.L    $B4.W,L0018 
  MOVE.L    #L0016,$B4.W
  MOVE.L    $B8.W,L001B 
  MOVE.L    #L0019,$B8.W
  MOVE.L    #L0013,$84.W
  MOVE.L    $B4.W,L0018 
  MOVE.L    #L0016,$B4.W
  MOVE.L    $B8.W,L001B 
  MOVE.L    #L0019,$B8.W
  RTS 
L0013:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    A0,-(A7)
  MOVE      USP,A0
  DC.B      $08,'/',$00,$0D,$00,$04 
  BEQ.S     L0014 
  MOVEA.L   A7,A0 
  ADDA.L    #$A,A0
L0014:
  MOVEA.L   (A7)+,A0
  JMP       L0022 
L0015 EQU       *-4 
L0016:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    A0,-(A7)
  MOVE      USP,A0
  DC.B      $08,'/',$00,$0D,$00,$04 
  BEQ.S     L0017 
  MOVEA.L   A7,A0 
  ADDA.L    #$A,A0
L0017:
  MOVEA.L   (A7)+,A0
  JMP       L0022 
L0018 EQU       *-4 
L0019:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVE.L    A0,-(A7)
  MOVE      USP,A0
  DC.B      $08,'/',$00,$0D,$00,$04 
  BEQ.S     L001A 
  MOVEA.L   A7,A0 
  ADDA.L    #$A,A0
L001A:
  MOVEA.L   (A7)+,A0
  JMP       L0022 
L001B EQU       *-4 
L001C:
  MOVE.L    $472.W,L0089
  MOVE.L    #L001F,$472.W 
  RTS 
L001D:
  MOVE.L    $476.W,L008A
  MOVE.L    #L0020,$476.W 
  RTS 
L001E:
  MOVE.L    $47E.W,L008B
  MOVE.L    #L0021,$47E.W 
  RTS 
L001F:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVEA.L   L0089,A0
  JMP       (A0)
L0020:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVEA.L   L008A,A0
  JMP       (A0)
L0021:
  MOVE.L    #L0022,$42A.W 
  MOVE.L    #$31415926,$426.W 
  MOVEA.L   L008B,A0
  JMP       (A0)
L0022:
  NOP 
  CLR.B     $FFFF8260.W 
  MOVE.B    #2,$FFFF820A.W
  LEA       L007A,A7
  MOVE.L    #L006B,$70.W
  MOVE.B    #$1A,$FFFC02.L
  MOVE.L    L0077,D7
  SUBI.L    #$8000,D7 
  MOVE.L    D7,L0078
  CLR.L     D0
  MOVE.L    #L007C,D0 
  ANDI.L    #-$100,D0 
  MOVE.L    D0,L007D
  LSL.L     #8,D0 
  LEA       $FFFF8201.W,A0
  MOVEP.L   D0,0(A0)
  MOVE.B    #$12,$FFFC02.L
  MOVE.L    L0077,L007E 
  SUBI.L    #$7D00,L007E
  MOVE.L    #$7D00,L007F
  MOVE.L    $44E.W,L0079
  MOVEA.L   L0079,A0
  MOVEA.L   L007D,A1
  MOVE.L    #$3E7F,D0 
L0023:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0023
  MOVE.B    #-1,L0080 
  MOVE      #$2300,SR 
  BSR       L006C 
  CLR.B     $FFFF8260.W 
  MOVE.B    #2,$FFFF820A.W
L0024:
  BSR       L006C 
  CLR.L     D0
  MOVE.B    $FFFC02.L,D0
  CMP.L     D0,D1 
  BEQ.S     L0024 
  CMP.B     #2,D0 
  BEQ       L002F 
  CMP.B     #3,D0 
  BEQ       L0030 
  CMP.B     #4,D0 
  BEQ       L0031 
  CMP.B     #5,D0 
  BEQ       L0032 
  CMP.B     #$70,D0 
  BEQ       L0033 
  CMP.B     #$6D,D0 
  BEQ       L0034 
  CMP.B     #$6E,D0 
  BEQ       L0035 
  CMP.B     #$6F,D0 
  BEQ       L0036 
  CMP.B     #$48,D0 
  BEQ       L0029 
  CMP.B     #$50,D0 
  BEQ       L002B 
  CMP.B     #$21,D0 
  BEQ       L0038 
  CMP.B     #$13,D0 
  BEQ       L0057 
  CMP.B     #$71,D0 
  BEQ       L0037 
  CMP.B     #$38,D0 
  BEQ       L002D 
  CMP.B     #$2A,D0 
  BEQ       L002E 
  CMP.B     #$3B,D0 
  BEQ       L0039 
  CMP.B     #$30,D0 	;#'0'
  BEQ       L0058 
  CMP.B     #$3C,D0 
  BEQ       L003A 
  CMP.B     #$3D,D0 
  BEQ       L003B 
  CMP.B     #$3E,D0 
  BEQ       L003C 
  CMP.B     #$3F,D0 
  BEQ       L003D 
  CMP.B     #$40,D0 
  BEQ       L003E 
  CMP.B     #$41,D0 	;#'A'
  BEQ       L003F 
  CMP.B     #$42,D0 
  BEQ       L0040 
  MOVE.L    D0,D1 
  CMP.B     #$39,D0 	;#'9'
  BNE       L0024 
  MOVE.L    #$3E7F,D0 
  MOVEA.L   L007D,A0
  MOVEA.L   L0078,A1
L0025:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0025
  LEA       $FFFF8240.W,A0
  MOVEQ     #$F,D0
L0026:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0026
  LEA       L006F,A0
  MOVEQ     #$F,D0
L0027:
  MOVE.B    (A0)+,(A1)+ 
  DBF       D0,L0027
  MOVE.L    L0078,$42E.W
  MOVE.L    L0078,$436.W
  CLR.L     $426.W
L0028:
  JMP       L0028 
L0029:
  MOVE.L    D0,D1 
  MOVE.L    L0079,D0
  ADD.L     L007F,D0
  CMP.L     L007E,D0
  BGT.S     L002A 
  MOVE.L    D0,L0079
  TST.B     L0081 
  BEQ       L0058 
  BRA       L0042 
L002A:
  MOVE.L    L007E,L0079 
  BSR       L0062 
  TST.B     L0081 
  BEQ       L0058 
  BRA       L0042 
L002B:
  MOVE.L    D0,D1 
  MOVE.L    L0079,D0
  SUB.L     L007F,D0
  BMI.S     L002C 
  MOVE.L    D0,L0079
  TST.B     L0081 
  BEQ       L0058 
  BRA       L0042 
L002C:
  CLR.L     L0079 
  BSR       L0062 
  TST.B     L0081 
  BEQ       L0058 
  BRA       L0042 
L002D:
  MOVE.L    D0,D1 
  BSR       L006C 
  BCHG      #0,$FFFF8260.W
  BRA       L0024 
L002E:
  MOVE.L    D0,D1 
  BSR       L006C 
  BCHG      #1,$FFFF820A.W
  BRA       L0024 
L002F:
  MOVE.L    D0,D1 
  BCHG      #0,L0080
  BRA       L0058 
L0030:
  MOVE.L    D0,D1 
  BCHG      #1,L0080
  BRA       L0058 
L0031:
  MOVE.L    D0,D1 
  BCHG      #2,L0080
  BRA       L0058 
L0032:
  MOVE.L    D0,D1 
  BCHG      #3,L0080
  BRA       L0058 
L0033:
  MOVE.L    D0,D1 
  BCHG      #0,L0082
  BCHG      #0,L0081
  BRA.S     L0038 
L0034:
  MOVE.L    D0,D1 
  BCHG      #1,L0082
  BCHG      #0,L0081
  BRA.S     L0038 
L0035:
  MOVE.L    D0,D1 
  BCHG      #2,L0082
  BCHG      #0,L0081
  BRA.S     L0038 
L0036:
  MOVE.L    D0,D1 
  BCHG      #3,L0082
  BCHG      #0,L0081
  BRA.S     L0038 
L0037:
  MOVE.L    D0,D1 
  BCHG      #0,L0083
  BCHG      #0,L0081
  NOP 
L0038:
  MOVE.L    D0,D1 
  BCHG      #0,L0081
  TST.B     L0081 
  BEQ       L0058 
  BRA       L0042 
L0039:
  MOVE.L    D0,D1 
  MOVE.L    #2,L007F
  BRA       L0024 
L003A:
  MOVE.L    D0,D1 
  MOVE.L    #8,L007F
  BRA       L0024 
L003B:
  MOVE.L    D0,D1 
  MOVE.L    #$28,L007F
  BRA       L0024 
L003C:
  MOVE.L    D0,D1 
  MOVE.L    #$A0,L007F
  BRA       L0024 
L003D:
  MOVE.L    D0,D1 
  MOVE.L    #$100,L007F 
  BRA       L0024 
L003E:
  MOVE.L    D0,D1 
  MOVE.L    #$500,L007F 
  BRA       L0024 
L003F:
  MOVE.L    D0,D1 
  MOVE.L    #$3C00,L007F
  BRA       L0024 
L0040:
  MOVE.L    D0,D1 
  MOVE.L    #$7D00,L007F
  BRA       L0024 
L0041:
  BRA       L0024 
L0042:
  MOVEA.L   L0079,A1
  MOVEA.L   L007D,A0
  MOVE.L    #$3E7F,D0 
L0043:
  CLR.W     (A0)+ 
  DBF       D0,L0043
  TST.B     L0083 
  BNE       L004F 
  MOVEA.L   L007D,A0
  MOVEQ     #5,D2 
L0044:
  MOVEQ     #9,D3 
L0045:
  MOVEQ     #$1F,D0 
L0046:
  BTST      #0,L0082
  BNE.S     L0047 
  MOVE.W    (A1)+,(A0)
L0047:
  BTST      #1,L0082
  BNE.S     L0048 
  MOVE.W    (A1)+,2(A0) 
L0048:
  BTST      #2,L0082
  BNE.S     L0049 
  MOVE.W    (A1)+,4(A0) 
L0049:
  BTST      #3,L0082
  BNE.S     L004A 
  MOVE.W    (A1)+,6(A0) 
L004A:
  BTST      #0,L0082
  BNE.S     L004B 
  MOVE.W    (A1)+,8(A0) 
L004B:
  BTST      #1,L0082
  BNE.S     L004C 
  MOVE.W    (A1)+,10(A0)
L004C:
  BTST      #2,L0082
  BNE.S     L004D 
  MOVE.W    (A1)+,12(A0)
L004D:
  BTST      #3,L0082
  BNE.S     L004E 
  MOVE.W    (A1)+,14(A0)
L004E:
  ADDA.L    #$A0,A0 
  DBF       D0,L0046
  SUBA.L    #$1400,A0 
  ADDA.L    #$10,A0 
  DBF       D3,L0045
  SUBA.L    #$A0,A0 
  ADDA.L    #$1400,A0 
  DBF       D2,L0044
  BRA       L0041 
L004F:
  MOVEA.L   L007D,A0
  MOVEQ     #$B,D2
L0050:
  MOVEQ     #$13,D3 
L0051:
  MOVEQ     #$F,D0
L0052:
  BTST      #0,L0082
  BNE.S     L0053 
  MOVE.W    (A1)+,(A0)
L0053:
  BTST      #1,L0082
  BNE.S     L0054 
  MOVE.W    (A1)+,2(A0) 
L0054:
  BTST      #2,L0082
  BNE.S     L0055 
  MOVE.W    (A1)+,4(A0) 
L0055:
  BTST      #3,L0082
  BNE.S     L0056 
  MOVE.W    (A1)+,6(A0) 
L0056:
  ADDA.L    #$A0,A0 
  DBF       D0,L0052
  SUBA.L    #$A00,A0
  ADDQ.L    #8,A0 
  DBF       D3,L0051
  SUBA.L    #$A0,A0 
  ADDA.L    #$A00,A0
  DBF       D2,L0050
  BRA       L0041 
L0057:
  MOVE.L    D0,D1 
  MOVE.B    #$F,L0080 
  CLR.B     L0081 
  MOVE.L    $44E.W,L0079
L0058:
  CLR.L     D0
  MOVEA.L   L0079,A0
  MOVEA.L   L007D,A1
  MOVE.L    #$F9F,D0
L0059:
  BTST      #0,L0080
  BEQ.S     L005A 
  MOVE.W    (A0),(A1) 
  BRA.S     L005B 
L005A:
  CLR.W     (A1)
L005B:
  BTST      #1,L0080
  BEQ.S     L005C 
  MOVE.W    2(A0),2(A1) 
  BRA.S     L005D 
L005C:
  CLR.W     2(A1) 
L005D:
  BTST      #2,L0080
  BEQ.S     L005E 
  MOVE.W    4(A0),4(A1) 
  BRA.S     L005F 
L005E:
  CLR.W     4(A1) 
L005F:
  BTST      #3,L0080
  BEQ.S     L0060 
  MOVE.W    6(A0),6(A1) 
  BRA.S     L0061 
L0060:
  CLR.W     6(A1) 
L0061:
  ADDQ.L    #8,A0 
  ADDQ.L    #8,A1 
  DBF       D0,L0059
  BRA       L0024 
L0062:
  MOVE.L    #$3400,$FF8800.L
  MOVE.L    #$1000000,$FF8800.L 
  MOVE.L    #$2000000,$FF8800.L 
  MOVE.L    #$3000000,$FF8800.L 
  MOVE.L    #$4000000,$FF8800.L 
  MOVE.L    #$5000000,$FF8800.L 
  MOVE.L    #$6000000,$FF8800.L 
  MOVE.L    #$700BE00,$FF8800.L 
  MOVE.L    #$8001000,$FF8800.L 
  MOVE.L    #$9000000,$FF8800.L 
  MOVE.L    #$A000000,$FF8800.L 
  MOVE.L    #$B000000,$FF8800.L 
  MOVE.L    #$C001600,$FF8800.L 
  MOVE.L    #$D000900,$FF8800.L 
  RTS 
  BTST      #1,L0080
  BNE.S     L0064 
  MOVEA.L   L007D,A0
  MOVE.L    #$F9F,D0
L0063:
  CLR.W     (A0)
  ADDQ.L    #8,A0 
  DBF       D0,L0063
L0064:
  BTST      #1,L0080
  BNE.S     L0066 
  MOVEA.L   L007D,A0
  ADDQ.L    #2,A0 
  MOVE.L    #$F9F,D0
L0065:
  CLR.W     (A0)
  ADDQ.L    #8,A0 
  DBF       D0,L0065
L0066:
  BTST      #2,L0080
  BNE.S     L0068 
  MOVEA.L   L007D,A0
  ADDQ.L    #4,A0 
  MOVE.L    #$F9F,D0
L0067:
  CLR.W     (A0)
  ADDQ.L    #8,A0 
  DBF       D0,L0067
L0068:
  BTST      #3,L0080
  BNE.S     L006A 
  MOVEA.L   L007D,A0
  ADDQ.L    #6,A0 
  MOVE.L    #$F9F,D0
L0069:
  CLR.W     (A0)
  ADDQ.L    #8,A0 
  DBF       D0,L0069
L006A:
  RTS 
L006B:
  CLR.W     L008C 
  RTE 
L006C:
  MOVE      SR,-(A7)
  MOVE.W    #-1,L008C 
  MOVE      #$2000,SR 
L006D:
  TST.W     L008C 
  BNE.S     L006D 
  MOVE      (A7)+,SR
  RTS 
 DATA 
L006E:
  DC.B      $1B,'E******' 
  DC.B      '* Pictur'
  DC.B      'e Grabbe'
  DC.B      'r V. 1.1'
  DC.B      '23 *****'
  DC.B      '**',$0A,$0D,$0A,$0D,'  ' 
  DC.B      '        '
  DC.B      '   Publi'
  DC.B      'c Domain'
  DC.B      '!       '
  DC.B      '      ',$0A,$0D
  DC.B      $0A,$0D,'Writte'
  DC.B      'n by:',$09,'Po'
  DC.B      'ntus Sk”'
  DC.B      'ld',$09,' ',$0A,$0D,$09,$09
  DC.B      'PL 521',$09,$09
  DC.B      $09,' ',$0A,$0D,$09,$09,'77'
  DC.B      '0 73 G-b'
  DC.B      'erg',$09,$09,' ',$0A,$0D 
  DC.B      $09,$09,'Sweden'
  DC.B      $09,$09,$09,' ',$0A,$0D,$0A,$0D 
  DC.B      ' Press I'
  DC.B      ' to togg'
  DC.B      'le inter'
  DC.B      'upts on '
  DC.B      '/ off...'
  DC.B      $0A,$0D,' Press'
  DC.B      ' B to bo'
  DC.B      'ot a dis'
  DC.B      'c...    '
  DC.B      '        '
  DC.B      '  ',$0A,$0D,' Pre' 
  DC.B      'ss any o'
  DC.B      'ther key'
  DC.B      ' to retu'
  DC.B      'rn to de'
  DC.B      'sk. ',$0A,$0D,$0A,$0D
  DC.B      ' Interup'
  DC.B      'ts are n'
  DC.B      'ow on!',$0A,$0D
  DC.B      $0A,$0D,' Read '
  DC.B      'the doc '
  DC.B      'file...',$07 
  DC.B      $1B,'YQ+Well' 
  DC.B      ', press '
  DC.B      'a key!',$00
L006F:
  DC.B      'Picture G' 
  DC.B      'rabber!' 
L0070:
  DC.B      $1B,'EPlease '
  DC.B      'insert d'
  DC.B      'isc to b'
  DC.B      'oot from'
  DC.B      '        '
  DC.B      ' ',$0A,$0D,'and b' 
  DC.B      'ash any '
  DC.B      'key ... '
  DC.B      $00 
L0071:
  DC.B      $1B,'E',$00 
L0072:
  DC.B      $1B,'EThis d' 
  DC.B      'isc hasn'
  DC.B      $27,'t got a' 
  DC.B      'n execut'
  DC.B      'eable',$0A,$0D,'b' 
  DC.B      'ootsecto'
  DC.B      'r !!! Bo'
  DC.B      'ot Abort'
  DC.B      'ed !!!',$00,$00
L0073:
  DC.L      L0074 
  DC.L      L0075 
L0074:
  DC.B      $1B,'Y-3on! ' 
  DC.B      $00 
L0075:
  DC.B      $1B,'Y-3off!',$00 
 BSS
L0076:
  DS.L      1 
L0077:
  DS.B      8 
L0078:
  DS.L      1 
L0079:
  DS.B      204 
L007A:
  DS.B      24
L007B:
  DS.B      512 
L007C:
  DS.B      32256 
L007D:
  DS.L      1 
L007E:
  DS.L      1 
L007F:
  DS.L      1 
L0080:
  DS.B      1 
L0081:
  DS.B      1 
L0082:
  DS.B      1 
L0083:
  DS.B      1 
L0084:
  DS.L      1 
L0085:
  DS.L      1 
L0086:
  DS.L      1 
L0087:
  DS.L      1 
L0088:
  DS.W      1 
L0089:
  DS.L      1 
L008A:
  DS.L      1 
L008B:
  DS.L      1 
ZUEND: END
