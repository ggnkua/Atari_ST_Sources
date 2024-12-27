;
; Aliens' DOC Displayer v5.9
; --------------------------
;
; Rippeth by Mentor of Special Flippin Xcess
;
; Hassles, Moaning, Awful Puns and Occasional Coffee by Slasher
;
; Frequent Coffee Making by: Slashers' Boss


                  BRA.B     L0001 
L0000:            DC.B      'Hunter / Lotus 2 / Head Over Heels docs',0 
L0001:            CLR.L     -(A7) 
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  MOVE.L    $70.W,L0097 
                  CMPI.B    #2,$44C.W 
                  BNE.B     L0002 
                  MOVE.B    #$67,L009C
L0002:            BSR       L0169 
                  LEA       L01F0,A5
                  LEA       L01AB,A4
                  BSR       L009E 
                  LEA       L01F0,A5
                  LEA       L01AC,A4
                  BSR       L009E 
                  LEA       L01F2,A5
                  LEA       L01A6(PC),A4
                  BSR       L009E 
                  LEA       L01F2,A5
                  LEA       L01A7(PC),A4
                  BSR       L009E 
                  LEA       FONT_1,A0 
                  LEA       L020B,A1
                  LEA       FONT_2,A3 
                  LEA       L020C,A4
                  MOVE.L    A4,D0 
                  MOVE.L    A1,D1 
                  EOR.L     D1,D0 
                  MOVE.L    D0,L005B
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
                  MOVE.W    #$FF,D7 
                  MOVEA.L   A0,A2 
                  MOVEA.L   A3,A5 
L0003:            MOVEA.L   A2,A0 
                  MOVEA.L   A5,A3 
                  MOVEQ     #7,D6 
L0004:            MOVE.B    (A0),D0 
                  MOVE.B    (A3),D1 
                  MOVE.W    D0,(A1)+
                  MOVE.W    D1,(A4)+
                  LEA       256(A0),A0
                  LEA       256(A3),A3
                  DBF       D6,L0004
                  ADDQ.L    #1,A2 
                  ADDQ.L    #1,A5 
                  DBF       D7,L0003
L0005:            MOVEA.L   $42E.W,A0 
                  LEA       -8(A0),A7 
                  MOVE      A7,USP
                  MOVE      #$2300,SR 
                  MOVE.L    $44E.W,L0205
                  PEA       L0011(PC) 
L0006:            MOVE.B    $44C.W,D0 
                  CMP.B     #2,D0 
                  BNE.B     L0007 
                  MOVE.W    L000A(PC),L000B 
                  MOVE.W    #$280,L000D 
                  BRA.B     L0008 
L0007:            MOVE.W    #$5640,L000B
                  MOVE.W    #$500,L000D 
L0008:            LEA       L0201,A0
                  MOVEQ     #$27,D7 
                  MOVEQ     #0,D0 
L0009:            MOVE.W    D0,(A0)+
L000A:            ADDQ.W    #1,D0 
                  MOVE.W    D0,(A0)+
L000B:            ADDQ.W    #3,D0 
                  DBF       D7,L0009
                  LEA       L0202,A0
                  MOVEQ     #$31,D7 
                  MOVEQ     #0,D0 
L000C:            MOVE.W    D0,(A0)+
                  ADDI.W    #$500,D0
L000D             EQU       *-2 
                  DBF       D7,L000C
                  PEA       $F0001
                  MOVE.W    #$23,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #6,A7 
                  MOVE.L    #L009B,$70.W
                  MOVE.B    #6,$484.W 
                  MOVE.B    $FFFF820A.W,D0
                  BTST      #1,D0 
                  BNE.B     L000E 
                  MOVE.W    #$1E,L00FC
L000E:            MOVE.B    $44C.W,D0 
                  CMP.B     #2,D0 
                  BNE       L000F 
                  LEA       L01C0(PC),A5
                  LEA       L01A8(PC),A4
                  BSR       L009E 
                  LEA       L01BF(PC),A5
                  LEA       L01AA(PC),A4
                  BSR       L009E 
                  MOVE.W    #$23,L00FC
                  MOVE.W    #$13F,L001D 
                  MOVE.W    #$13F,L0020 
                  MOVE.W    #$7800,L001F
                  MOVE.W    #$50,L00B5
                  MOVE.W    #$A0,L00B6
                  MOVE.W    #$F0,L00B7
                  MOVE.W    #$140,L00B8 
                  MOVE.W    #$190,L00B9 
                  MOVE.W    #$1E0,L00BA 
                  MOVE.W    #$230,L00BB 
                  MOVEQ     #$2D,D1 
                  MOVE.W    D1,L0018
                  MOVE.W    D1,L0024
                  MOVE.W    D1,L0029
                  MOVE.W    D1,L002A
                  MOVE.W    D1,L003A
                  MOVE.W    D1,L003C
                  MOVE.W    D1,L0040
                  MOVE.W    D1,L0043
                  MOVE.W    D1,L004B
                  MOVE.W    D1,L0050
                  MOVE.W    D1,L0053
                  MOVE.W    D1,L0059
                  MOVE.W    D1,L005F
                  MOVE.W    D1,L0074
                  MOVE.W    D1,L0089
                  MOVE.W    D1,L008A
                  MOVE.W    D1,L008F
                  MOVE.W    D1,L0108
                  MOVE.W    D1,L0133
                  MOVE.W    D1,L013E
                  MOVE.W    D1,L005C
                  MOVE.W    D1,L0068
                  MOVE.W    D1,L006B
                  MOVE.W    D1,L013A
                  MOVE.B    D1,L010E
                  MOVEQ     #$31,D1 
                  MOVE.B    D1,L0027
                  MOVE.B    D1,L0047
                  MOVE.B    D1,L0063
                  MOVE.B    D1,L00C6
                  MOVE.B    D1,L00CD
                  MOVE.W    #$780,L002B 
                  MOVE.W    #$FD80,L002C
                  MOVE.W    #$16,L002D
                  MOVE.W    #$16,L0035
                  MOVE.B    #$F,L002F 
                  MOVE.B    #$F,L0037 
                  MOVE.B    #$2F,L0031
                  MOVE.W    #$7580,L0033
                  MOVE.W    #$280,L0034 
                  MOVE.W    #$5A,L0091
                  MOVE.W    #$500,L010B 
                  MOVE.W    #$2DF,L010C 
                  MOVEQ     #$2C,D1 
                  MOVE.W    D1,L0134
                  MOVE.W    D1,L013F
                  MOVE.W    #$2E,L0054
                  MOVE.W    #$2E,L0165
                  MOVEQ     #$23,D1 
                  MOVE.B    #$C,L00F6 
                  MOVE.B    D1,L00F7
                  MOVE.B    D1,L00F8
                  MOVE.B    D1,L00FD
                  MOVE.B    #$17,L0012
                  MOVE.W    #$9F,L00C4
                  MOVE.W    #$9F,L00E7
                  MOVE.W    #$7A80,L00C2
                  MOVE.W    #$7A80,L00C3
                  MOVE.W    #$7A80,L00E5
                  MOVE.W    #$7A80,L00E6
                  MOVEQ     #2,D0 
                  BRA       L0010 
L000F:            LEA       L01C1(PC),A5
                  LEA       L01A8(PC),A4
                  BSR       L009E 
                  LEA       L01C2(PC),A5
                  LEA       L01AA(PC),A4
                  BSR       L009E 
                  MOVE.W    #$27F,L001D 
                  MOVE.W    #$27F,L0020 
                  MOVE.W    #$7300,L001F
                  MOVE.W    #$A0,L00B5
                  MOVE.W    #$140,L00B6 
                  MOVE.W    #$1E0,L00B7 
                  MOVE.W    #$280,L00B8 
                  MOVE.W    #$320,L00B9 
                  MOVE.W    #$3C0,L00BA 
                  MOVE.W    #$460,L00BB 
                  MOVEQ     #$14,D1 
                  MOVE.W    D1,L0018
                  MOVE.W    D1,L0024
                  MOVE.W    D1,L0029
                  MOVE.W    D1,L002A
                  MOVE.W    D1,L003A
                  MOVE.W    D1,L003C
                  MOVE.W    D1,L0040
                  MOVE.W    D1,L0043
                  MOVE.W    D1,L004B
                  MOVE.W    D1,L0050
                  MOVE.W    D1,L0053
                  MOVE.W    D1,L0059
                  MOVE.W    D1,L005F
                  MOVE.W    D1,L0074
                  MOVE.W    D1,L0089
                  MOVE.W    D1,L008A
                  MOVE.W    D1,L008F
                  MOVE.W    D1,L0108
                  MOVE.W    D1,L0133
                  MOVE.W    D1,L013E
                  MOVE.W    D1,L005C
                  MOVE.W    D1,L0068
                  MOVE.W    D1,L006B
                  MOVE.W    D1,L013A
                  MOVE.B    D1,L010E
                  MOVEQ     #$18,D1 
                  MOVE.B    D1,L0027
                  MOVE.B    D1,L0047
                  MOVE.B    D1,L0063
                  MOVE.B    D1,L00C6
                  MOVE.B    D1,L00CD
                  MOVE.W    #$F00,L002B 
                  MOVE.W    #$FB00,L002C
                  MOVE.W    #$13,L002D
                  MOVE.W    #$13,L0035
                  MOVE.B    #$1F,L002F
                  MOVE.B    #$1F,L0037
                  MOVE.B    #$16,L0031
                  MOVE.W    #$6E00,L0033
                  MOVE.W    #$500,L0034 
                  MOVE.W    #$28,L0091
                  MOVE.W    #$A00,L010B 
                  MOVE.W    #$29F,L010C 
                  MOVEQ     #$13,D1 
                  MOVE.W    D1,L0134
                  MOVE.W    D1,L013F
                  MOVE.W    #$15,L0054
                  MOVE.W    #$15,L0165
                  MOVEQ     #$17,D1 
                  CLR.B     L00F6 
                  MOVE.B    D1,L00F7
                  MOVE.B    D1,L00F8
                  MOVE.B    D1,L00FD
                  MOVE.B    #$C,L0012 
                  MOVE.W    #$13F,L00C4 
                  MOVE.W    #$13F,L00E7 
                  MOVE.W    #$7800,L00C2
                  MOVE.W    #$7800,L00C3
                  MOVE.W    #$7800,L00E5
                  MOVE.W    #$7800,L00E6
                  MOVEQ     #1,D0 
L0010:            RTS 
L0011:            BSR       L0098 
                  MOVEM.L   L01D4,D0-D1 
                  MOVEM.L   D0-D1,$FFFF8240.W 
                  LEA       L01A3(PC),A6
                  MOVEQ     #$1B,D0 
                  MOVEQ     #$B,D1
L0012             EQU       *-1 
                  BSR       L00A1 
                  LEA       L01A5(PC),A4
                  LEA       L01BD(PC),A5
                  BSR       L009E 
                  LEA       L01A9(PC),A4
                  LEA       L01BE(PC),A5
                  BSR       L009E 
                  BSR       L0100 
                  TST.W     D0
                  BNE.B     L0013 
                  LEA       L01B4(PC),A4
                  LEA       L01BC(PC),A5
                  BSR       L009E 
L0013:            LEA       L0210,A1
                  LEA       DOC_FILE,A5 
L0014:            MOVE.L    A5,(A1)+
L0015:            TST.B     (A5)
                  BEQ.B     L0016 
                  CMPI.B    #$A,(A5)+ 
                  BNE.B     L0015 
                  BRA.B     L0014 
L0016:            SUBA.L    #L0210,A1 
                  MOVE.L    A1,D0 
                  LSR.W     #2,D0 
                  SUBQ.W    #1,D0 
                  MOVE.W    D0,L01FC
                  SUBQ.W    #1,D0 
                  TST.W     L0208 
                  BNE.B     L0017 
                  ST        L0208 
                  MOVE.W    D0,L01F6
L0017:            SUBI.W    #$14,D0 
L0018             EQU       *-2 
                  MOVE.W    D0,L0062
                  MOVE.W    L01FC,D0
                  LEA       L0193,A3
                  PEA       L001C(PC) 
L0019:            MOVEQ     #3,D7 
L001A:            DIVU      #$A,D0
                  SWAP      D0
                  MOVE.B    #$30,-(A3)
                  ADD.B     D0,(A3) 
                  CLR.W     D0
                  SWAP      D0
                  DBF       D7,L001A
                  CMPI.B    #$30,(A3) 
                  BNE.B     L001B 
                  MOVE.B    1(A3),(A3)
                  MOVE.B    2(A3),1(A3) 
                  MOVE.B    3(A3),2(A3) 
                  MOVE.B    #$20,3(A3)
                  CMPI.B    #$30,(A3) 
                  BNE.B     L001B 
                  MOVE.B    1(A3),(A3)
                  MOVE.B    2(A3),1(A3) 
                  MOVE.B    #$20,2(A3)
                  CMPI.B    #$30,(A3) 
                  BNE.B     L001B 
                  MOVE.B    1(A3),(A3)
                  MOVE.B    #$20,1(A3)
L001B:            RTS 
L001C:            MOVEA.L   L0205,A0
                  MOVE.W    #$27F,D0
L001D             EQU       *-2 
L001E:            MOVE.W    #$FFFF,(A0)+
                  DBF       D0,L001E
                  LEA       29440(A0),A0
L001F             EQU       *-2 
                  MOVE.W    #$27F,D0
L0020             EQU       *-2 
L0021:            MOVE.W    #$FFFF,(A0)+
                  DBF       D0,L0021
                  LEA       L018E(PC),A6
                  MOVE.B    #$40,82(A6) 
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
                  SF        L01F7 
                  BSR       L00A1 
                  CLR.B     L0192 
L0022:            LEA       DOC_FILE,A5 
                  MOVEQ     #0,D6 
L0023:            MOVEQ     #0,D7 
                  MOVE.W    #$6677,D4 
                  BSR       L0106 
                  CMP.W     #$14,D6 
L0024             EQU       *-2 
                  BGT.B     L0025 
                  LEA       L0194(PC),A6
                  MOVE.W    #$6674,L01FA
                  BRA.B     L0026 
L0025:            LEA       L0195(PC),A6
                  MOVE.W    #$6D74,L01FA
L0026:            SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #$18,D1 
L0027             EQU       *-1 
                  BSR       L00A1 
                  BRA       L0048 
L0028:            MOVE.W    #0,$484.L 
                  SUBI.W    #$14,D6 
L0029             EQU       *-2 
                  BSR       L0107 
                  ADDI.W    #$14,D6 
L002A             EQU       *-2 
                  CMP.W     #$6677,D4 
                  BNE       L0032 
                  MOVEA.L   L0205,A0
                  LEA       3840(A0),A0 
L002B             EQU       *-2 
                  LEA       -1280(A0),A1
L002C             EQU       *-2 
                  MOVEM.L   A2-A4/D0-D6,-(A7) 
                  MOVE.W    #$13,D7 
L002D             EQU       *-2 
L002E:            MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  MOVEM.L   (A0)+,A2-A4/D0-D6 
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  DBF       D7,L002E
                  MOVEM.L   L020F,A2-A4/D0-D6 
                  MOVEQ     #$1F,D7 
L002F             EQU       *-1 
L0030:            MOVEM.L   A2-A4/D0-D6,(A1)
                  LEA       40(A1),A1 
                  DBF       D7,L0030
                  MOVEM.L   (A7)+,A2-A4/D0-D6 
                  MOVEQ     #$16,D1 
L0031             EQU       *-1 
                  BRA       L0039 
L0032:            MOVEA.L   L0205,A0
                  LEA       28160(A0),A0
L0033             EQU       *-2 
                  LEA       1280(A0),A1 
L0034             EQU       *-2 
                  MOVEM.L   A2-A4/D0-D6,-(A7) 
                  MOVE.W    #$13,D7 
L0035             EQU       *-2 
L0036:            LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  LEA       -40(A0),A0
                  MOVEM.L   (A0),A2-A4/D0-D6
                  MOVEM.L   A2-A4/D0-D6,-(A1) 
                  DBF       D7,L0036
                  MOVEM.L   L020F,A2-A4/D0-D6 
                  MOVEQ     #$1F,D7 
L0037             EQU       *-1 
L0038:            LEA       -40(A1),A1
                  MOVEM.L   A2-A4/D0-D6,(A1)
                  DBF       D7,L0038
                  MOVEM.L   (A7)+,A2-A4/D0-D6 
                  MOVEQ     #2,D1 
L0039:            LEA       L0210,A1
                  CMP.W     #$626B,D4 
                  BNE.B     L003B 
                  SUBI.W    #$14,D6 
L003A             EQU       *-2 
L003B:            LSL.W     #2,D6 
                  MOVEA.L   0(A1,D6.W),A5 
                  LSR.W     #2,D6 
                  CMP.W     #$626B,D4 
                  BNE.B     L003D 
                  ADDI.W    #$14,D6 
L003C             EQU       *-2 
L003D:            LEA       L020D,A6
                  CMPA.L    L01DD,A5
                  BLT.B     L003E 
                  CMPA.L    L01DE,A5
                  BGE.B     L003E 
                  SF        L01F7 
                  BRA.B     L003F 
L003E:            ST        L01F7 
L003F:            MOVE.B    (A5)+,(A6)+ 
                  TST.B     (A5)
                  BEQ.B     L0041 
                  CMPI.B    #$A,-1(A6)
                  BNE.B     L003F 
                  CLR.B     (A6)+ 
                  LEA       L020D,A6
                  MOVEQ     #0,D0 
                  BSR       L00A1 
                  MOVE.W    L0062(PC),D0
                  ADDI.W    #$14,D0 
L0040             EQU       *-2 
                  CMP.W     D0,D6 
                  BEQ.B     L0041 
                  MOVEQ     #0,D7 
                  BRA.B     L0042 
L0041:            MOVEQ     #$21,D7 
                  CLR.B     (A6)+ 
                  LEA       L020D,A6
                  MOVEQ     #0,D0 
                  BSR       L00A1 
L0042:            CMP.W     #$14,D6 
L0043             EQU       *-2 
                  BEQ.B     L0044 
                  CMP.W     #$21,D7 
                  BEQ.B     L0045 
                  CMPI.W    #$6D74,L01FA
                  BEQ.B     L0048 
                  LEA       L0195(PC),A6
                  MOVE.W    #$6D74,L01FA
                  BRA.B     L0046 
L0044:            CMPI.W    #$6674,L01FA
                  BEQ.B     L0048 
                  LEA       L0194(PC),A6
                  MOVE.W    #$6674,L01FA
                  BRA.B     L0046 
L0045:            CMPI.W    #$6274,L01FA
                  BEQ.B     L0048 
                  LEA       L0196(PC),A6
                  MOVE.W    #$6274,L01FA
L0046:            SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #$18,D1 
L0047             EQU       *-1 
                  BSR       L00A1 
L0048:            MOVE.B    #6,$484.L 
                  BSR       L00EC 
                  SWAP      D0
                  BSR       L00A0 
                  CMP.L     #$50,D0 
                  BNE.B     L004A 
L0049:            CMPI.W    #$6274,L01FA
                  BEQ.B     L0048 
                  ST        L0207 
                  ADDQ.W    #1,D6 
                  MOVE.W    #$6677,D4 
                  BRA       L0028 
L004A:            CMP.W     #$1C,D0 
                  BEQ.B     L0049 
                  CMP.W     #$72,D0 
                  BEQ.B     L0049 
                  CMP.L     #$48,D0 
                  BNE.B     L004C 
                  CMP.W     #$14,D6 
L004B             EQU       *-2 
                  BEQ.B     L0048 
                  ST        L0207 
                  SUBQ.W    #1,D6 
                  MOVE.W    #$626B,D4 
                  BRA       L0028 
L004C:            CMP.W     #$39,D0 
                  BEQ       L0095 
                  CMP.W     #$66,D0 
                  BNE.B     L004D 
                  CMPI.B    #2,$44C.W 
                  BEQ.B     L0048 
                  EORI.B    #2,$FFFF820A.W
                  EORI.W    #7,L00FC
                  MOVE.W    L00FC(PC),L01D3 
                  BRA       L0048 
L004D:            CMP.W     #2,D0 
                  BLT.B     L0051 
                  CMP.W     #$B,D0
                  BGT.B     L0051 
                  LEA       L01A0(PC),A6
L004E:            SUBQ.B    #2,D0 
                  MOVE.B    #$31,(A6) 
                  ADD.B     D0,(A6) 
                  CMPI.B    #$3A,(A6) 
                  BNE.B     L004F 
                  MOVE.B    #$30,(A6) 
L004F:            ADD.W     D0,D0 
                  LEA       L01DF,A0
                  ADDA.W    D0,A0 
                  SWAP      D0
                  CMP.W     #$AAAA,D0 
                  BEQ.B     L0052 
                  MOVE.W    D6,(A0) 
                  SUBI.W    #$14,(A0) 
L0050             EQU       *-2 
                  LEA       L019F(PC),A6
                  SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BRA       L0048 
L0051:            CMP.W     #$78,D0 
                  BLT.B     L0055 
                  CMP.W     #$81,D0 
                  BGT.B     L0055 
                  SUBI.W    #$76,D0 
                  LEA       L01A2(PC),A6
                  BRA.B     L004E 
L0052:            MOVE.W    (A0),D5 
                  MOVE.W    D5,D0 
                  ADDI.W    #$14,D0 
L0053             EQU       *-2 
                  CMP.W     D0,D6 
                  BEQ       L0048 
                  ST        L0207 
                  MOVE.W    D5,D6 
                  LEA       L01A1(PC),A6
                  SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  MOVE.W    L01FC,D5
                  SUBI.W    #$15,D5 
L0054             EQU       *-2 
                  CMP.W     D5,D6 
                  BLE       L0023 
                  MOVE.W    D5,D6 
                  BRA       L0023 
L0055:            CMP.W     #$62,D0 
                  BNE.B     L0056 
                  BSR       L00F3 
                  BRA       L0048 
L0056:            CMP.L     #$3002E,D0
                  BNE.B     L0057 
                  EORI.L    #$7770777,$FFFF8240.W 
                  BRA       L0048 
L0057:            CMP.L     #$140014,D0 
                  BNE.B     L0058 
                  MOVE.W    L01F5,D6
                  ST        L0207 
                  BRA       L0023 
L0058:            CMP.L     #$20030,D0
                  BNE.B     L005A 
                  MOVE.W    L01F6,D6
                  SUBI.W    #$14,D6 
L0059             EQU       *-2 
                  ST        L0207 
                  BRA       L0023 
L005A:            CMP.L     #$60021,D0
                  BNE.B     L005D 
                  EORI.L    #0,L00A2
L005B             EQU       *-8 
                  SUBI.W    #$14,D6 
L005C             EQU       *-2 
                  BSR       L0106 
                  BRA       L0048 
L005D:            CMP.L     #$AAAA002E,D0 
                  BNE.B     L005E 
                  CMPI.B    #2,$44C.W 
                  BEQ       L0048 
                  BSR       L016C 
L005E:            CMP.L     #$AAAA0014,D0 
                  BNE.B     L0060 
                  CMP.W     #$14,D6 
L005F             EQU       *-2 
                  BEQ       L0048 
                  ST        L0207 
                  BRA       L0022 
L0060:            CMP.L     #$AAAA0030,D0 
                  BNE.B     L0064 
                  CMPI.W    #$6274,L01FA
                  BEQ       L0048 
                  ST        L0207 
L0061:            MOVE.W    #0,D6 
L0062             EQU       *-2 
                  BSR       L0106 
                  LEA       L0196(PC),A6
                  MOVE.W    #$6274,L01FA
                  SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #$18,D1 
L0063             EQU       *-1 
                  BSR       L00A1 
                  MOVEQ     #$21,D7 
                  BRA       L0048 
L0064:            CMP.L     #$AAAA0022,D0 
                  BNE.B     L0066 
                  MOVE.W    D6,L0065
                  BSR       L015A 
                  CMP.W     #0,D6 
L0065             EQU       *-2 
                  BEQ       L0048 
                  ST        L0207 
                  CMP.W     #$FFFF,D6 
                  BEQ.B     L0061 
                  BRA       L0023 
L0066:            CMP.L     #$AAAA0021,D0 
                  BNE.B     L0067 
                  SF        L01F7 
                  BSR       L0127 
                  BRA       L0048 
L0067:            CMP.L     #$AAAA0031,D0 
                  BNE.B     L006A 
                  TST.B     L01FB 
                  BEQ       L0048 
                  MOVE.W    #$101D,L0146
                  MOVE.W    #$4E71,L0148
                  MOVE.W    #$14,L013F
L0068             EQU       *-6 
                  MOVE.L    #L01F4,L0145
L0069:            BSR       L00A0 
                  LEA       L018B(PC),A6
                  MOVEQ     #$22,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L013B 
                  BRA       L0048 
L006A:            CMP.L     #$AAAA0019,D0 
                  BNE.B     L006C 
                  TST.B     L01FB 
                  BEQ       L0048 
                  SUBQ.L    #1,L0141
                  MOVE.W    #$1025,L0146
                  MOVE.W    #$528D,L0148
                  MOVE.L    #DOC_FILE,L0145 
                  MOVE.W    #$14,L013F
L006B             EQU       *-6 
                  BRA.B     L0069 
L006C:            CMP.W     #$40,D0 
                  BNE.B     L0070 
                  EORI.W    #1,L01F9
                  TST.W     L01F9 
                  BEQ.B     L006D 
                  LEA       L01F0(PC),A5
                  LEA       L01B1,A4
                  BSR       L009E 
                  LEA       L019D(PC),A6
                  LEA       L01B6(PC),A5
                  BRA.B     L006F 
L006D:            MOVE.B    #$4F,L01B1
                  LEA       L01EE(PC),A5
                  TST.W     L0209 
                  BEQ.B     L006E 
                  LEA       L01EF(PC),A5
L006E:            LEA       L01B2,A4
                  BSR       L009E 
                  LEA       L019E(PC),A6
                  LEA       L01B7(PC),A5
L006F:            LEA       L01AF(PC),A4
                  BSR       L009E 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00BD 
                  BRA       L0048 
L0070:            CMP.W     #$41,D0 
                  BNE.B     L0071 
                  BSR       L0110 
                  BRA       L0048 
L0071:            CMP.W     #$42,D0 
                  BNE.B     L0075 
                  EORI.W    #1,L01F8
                  TST.W     L01F8 
                  BEQ.B     L0072 
                  LEA       L01B6(PC),A5
                  BRA.B     L0073 
L0072:            LEA       L01B7(PC),A5
L0073:            LEA       L01AD(PC),A4
                  BSR       L009E 
                  SUBI.W    #$14,D6 
L0074             EQU       *-2 
                  BSR       L0106 
                  BRA       L0048 
L0075:            CMP.W     #$43,D0 
                  BNE       L0087 
                  BSR       L00A0 
                  LEA       L01C9(PC),A6
                  SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00BD 
L0076:            BSR       L00EC 
                  SWAP      D0
                  CMP.W     #$3B,D0 
                  BLT.B     L0076 
                  CMP.W     #$3C,D0 
                  BGT.B     L0076 
                  SUBI.W    #$3B,D0 
                  LSL.B     #4,D0 
                  BCLR      #4,L01D0
                  OR.B      D0,L01D0
                  TST.B     D0
                  BNE.B     L0077 
                  LEA       L01B8(PC),A5
                  BRA.B     L0078 
L0077:            LEA       L01B9(PC),A5
L0078:            LEA       L01AE,A4
                  BSR       L009E 
                  BSR       L00A0 
                  LEA       L01CA(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L0079:            BSR       L00EC 
                  SWAP      D0
                  CMP.W     #$3B,D0 
                  BLT.B     L0079 
                  CMP.W     #$3C,D0 
                  BGT.B     L0079 
                  SUBI.W    #$3B,D0 
                  LSL.B     #3,D0 
                  BCLR      #3,L01D0
                  OR.B      D0,L01D0
                  TST.B     D0
                  BEQ.B     L007A 
                  LEA       L01BB(PC),A5
                  BRA.B     L007B 
L007A:            LEA       L01BA(PC),A5
L007B:            LEA       L01B0,A4
                  BSR       L009E 
                  BSR       L00A0 
                  LEA       L01CB(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L007C:            BSR       L00EC 
                  SWAP      D0
                  CMP.W     #$3B,D0 
                  BLT.B     L007C 
                  CMP.W     #$3C,D0 
                  BGT.B     L007C 
                  SUBI.W    #$3B,D0 
                  MOVE.W    D0,L0209
                  LEA       L01EE(PC),A5
                  TST.W     D0
                  BEQ.B     L007D 
                  LEA       L01EF(PC),A5
L007D:            LEA       L01B2(PC),A4
                  BSR       L009E 
                  BSR       L00A0 
                  LEA       L01CC(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L007E:            MOVEQ     #0,D0 
                  MOVE.W    L01F1(PC),D0
                  MOVE.L    D0,D1 
                  LSL.W     #1,D1 
                  LSL.W     #2,D0 
                  LEA       L01C3(PC),A6
                  LEA       L01C8(PC),A5
                  MOVE.W    0(A5,D1.W),D1 
                  ANDI.B    #$F8,L01D0
                  OR.B      D1,L01D0
                  MOVEA.L   0(A6,D0.W),A6 
                  MOVEA.L   A6,A5 
                  LEA       L01B3(PC),A4
                  BSR       L009E 
                  MOVEQ     #$2C,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00EC 
                  SWAP      D0
                  CMP.W     #$48,D0 
                  BEQ.B     L0080 
                  CMP.W     #$50,D0 
                  BEQ.B     L007F 
                  SWAP      D0
                  CMP.W     #$D,D0
                  BEQ.B     L0081 
                  BRA.B     L007E 
L007F:            SUBQ.W    #1,L01F1
                  CMPI.W    #$FFFF,L01F1
                  BNE.B     L007E 
                  MOVE.W    #3,L01F1
                  BRA.B     L007E 
L0080:            ADDQ.W    #1,L01F1
                  CMPI.W    #4,L01F1
                  BNE       L007E 
                  CLR.W     L01F1 
                  BRA       L007E 
L0081:            BSR       L00A0 
                  LEA       L01CD(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L0082:            LEA       L01D1(PC),A6
                  MOVEQ     #0,D0 
                  MOVE.W    L01E0,D0
                  DIVU      #$A,D0
                  MOVE.W    #$3030,(A6) 
                  ADD.B     D0,(A6) 
                  SWAP      D0
                  ADD.B     D0,1(A6)
                  MOVEQ     #$42,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L0083:            BSR       L00EC 
                  SWAP      D0
                  CMP.W     #$48,D0 
                  BEQ.B     L0084 
                  CMP.W     #$50,D0 
                  BEQ.B     L0085 
                  SWAP      D0
                  CMP.W     #$D,D0
                  BEQ.B     L0086 
                  BRA.B     L0083 
L0084:            ADDQ.W    #1,L01E0
                  CMPI.W    #$64,L01E0
                  BNE.B     L0082 
                  MOVE.W    #2,L01E0
                  BRA.B     L0082 
L0085:            SUBQ.W    #1,L01E0
                  CMPI.W    #1,L01E0
                  BNE.B     L0082 
                  MOVE.W    #$63,L01E0
                  BRA.B     L0082 
L0086:            BSR       L00A0 
                  BRA       L0048 
L0087:            CMP.W     #$44,D0 
                  BNE.B     L0088 
                  BSR       L00BE 
                  BRA       L0048 
L0088:            CMP.W     #$3B,D0 
                  BNE.B     L008D 
                  SUBI.W    #$14,D6 
L0089             EQU       *-2 
                  CMP.W     L01F6,D6
                  BLE.B     L008C 
                  ADDI.W    #$14,D6 
L008A             EQU       *-2 
                  LEA       L019B(PC),A6
L008B:            SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00BD 
                  BRA       L0048 
L008C:            LSL.W     #2,D6 
                  LEA       L0210,A1
                  MOVE.L    0(A1,D6.W),L01DD
                  LSR.W     #2,D6 
                  MOVE.W    D6,L01F5
                  BSR       L0106 
                  BRA       L0048 
L008D:            CMP.W     #$3C,D0 
                  BNE.B     L0090 
                  CMP.W     L01F5,D6
                  BGE.B     L008E 
                  LEA       L019C(PC),A6
                  BRA.B     L008B 
L008E:            LSL.W     #2,D6 
                  LEA       L0211,A1
                  MOVE.L    0(A1,D6.W),L01DE
                  LSR.W     #2,D6 
                  MOVE.W    D6,L01F6
                  SUBI.W    #$14,D6 
L008F             EQU       *-2 
                  BSR       L0106 
                  BRA       L0048 
L0090:            CMP.L     #$380048,D0 
                  BNE.B     L0094 
                  CMPI.W    #$6674,L01FA
                  BEQ       L0048 
                  ST        L0207 
                  MOVEQ     #0,D7 
                  SUBI.W    #$28,D6 
L0091             EQU       *-2 
                  BMI.B     L0093 
L0092:            BSR       L0106 
                  BRA       L0042 
L0093:            MOVEQ     #0,D6 
                  BRA.B     L0092 
L0094:            CMP.L     #$AAAA0010,D0 
                  BEQ.B     L0096 
                  CMP.L     #$320050,D0 
                  BNE       L0048 
L0095:            CMPI.W    #$6274,L01FA
                  BEQ       L0048 
                  ST        L0207 
                  CMP.W     L0062,D6
                  BLT.B     L0092 
                  BRA       L0061 
L0096:            MOVE.B    #7,$484.L 
                  MOVE.L    #0,$70.W
L0097             EQU       *-6 
                  MOVE.L    4.W,-(A7) 
                  RTS 
L0098:            MOVE.W    D0,-(A7)
                  PEA       $FFFFFFFF.W 
                  MOVE.L    (A7),-(A7)
                  MOVE.W    #5,-(A7)
                  TRAP      #$E 
                  LEA       12(A7),A7 
                  RTS 
L0099:            MOVE.W    $468.W,D0 
L009A:            CMP.W     $468.W,D0 
                  BEQ.B     L009A 
                  RTS 
L009B:            ADDQ.W    #1,$468.W 
                  BTST      #7,$FFFFFA01.W
L009C:            BNE.B     L009D 
                  MOVE      #$2700,SR 
                  MOVE.L    #L009D,$70.W
                  EORI.B    #3,$44C.W 
                  EORI.B    #1,L009C
                  BRA       L0005 
L009D:            RTE 
L009E:            MOVE.B    (A5)+,D0
                  BEQ.B     L009F 
                  MOVE.B    D0,(A4)+
                  BRA.B     L009E 
L009F:            RTS 
L00A0:            MOVEM.L   A6/D0-D1,-(A7)
                  LEA       L01CE(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR.B     L00A1 
                  MOVEM.L   (A7)+,A6/D0-D1
                  RTS 
L00A1:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.W    D0,L0203
                  MOVE.W    D1,L0204
                  LEA       L0201,A1
                  LEA       L0202,A2
                  LEA       L020B,A4
L00A2             EQU       *-4 
                  MOVEA.L   L0205,A5
L00A3:            MOVEQ     #0,D0 
L00A4:            MOVE.B    (A6)+,D0
                  BEQ       L00BC 
                  CMP.W     #$40,D0 
                  BNE.B     L00AC 
                  MOVE.B    (A6)+,D0
                  CMP.W     #$2D,D0 
                  BNE.B     L00A5 
                  MOVE.B    (A6)+,D0
                  SUBI.B    #$30,D0 
                  MOVE.W    D0,L01EB
                  BRA.B     L00A4 
L00A5:            CMP.W     #$35,D0 
                  BEQ.B     L00A6 
                  CMP.W     #$34,D0 
                  BNE.B     L00A7 
L00A6:            SUBI.W    #$34,D0 
                  MOVE.W    D0,L01E7
                  BRA.B     L00A4 
L00A7:            CMP.W     #$48,D0 
                  BEQ.B     L00A8 
                  CMP.W     #$47,D0 
                  BNE.B     L00A9 
L00A8:            SUBI.W    #$47,D0 
                  MOVE.W    D0,L01E8
                  BRA.B     L00A4 
L00A9:            CMP.W     #$49,D0 
                  BEQ.B     L00AA 
                  CMP.W     #$4A,D0 
                  BNE.B     L00AB 
L00AA:            SUBI.W    #$49,D0 
                  MOVE.W    D0,L01E9
                  BRA.B     L00A4 
L00AB:            MOVEQ     #$40,D0 
                  SUBQ.L    #1,A6 
L00AC:            CMP.W     #9,D0 
                  BNE.B     L00AD 
                  ANDI.W    #$F8,L0203
                  ADDQ.W    #8,L0203
                  BRA       L00A3 
L00AD:            CMP.W     #$A,D0
                  BNE.B     L00AE 
                  ADDQ.W    #1,L0204
                  BRA       L00A3 
L00AE:            CMP.W     #$D,D0
                  BNE.B     L00AF 
                  MOVE.W    #0,L0203
                  BRA       L00A3 
L00AF:            MOVEA.L   A5,A0 
                  MOVE.W    L0203,D1
                  MOVE.W    L0204,D2
                  ADD.W     D1,D1 
                  ADD.W     D2,D2 
                  ADDA.W    0(A1,D1.W),A0 
                  ADDA.W    0(A2,D2.W),A0 
                  LSL.W     #4,D0 
                  LEA       0(A4,D0.W),A3 
                  MOVEM.W   (A3),D0-D7
                  TST.W     L01F8 
                  BNE.B     L00B2 
                  TST.W     L01EB 
                  BEQ.B     L00B0 
                  MOVE.W    #$FF,D7 
L00B0:            TST.W     L01E8 
                  BNE.B     L00B1 
                  MOVEM.W   D0-D7,-(A7) 
                  LSL.W     #1,D0 
                  LSL.W     #1,D1 
                  LSL.W     #1,D2 
                  LSL.W     #1,D3 
                  LSL.W     #1,D4 
                  LSL.W     #1,D5 
                  LSL.W     #1,D6 
                  LSL.W     #1,D7 
                  OR.W      (A7)+,D0
                  OR.W      (A7)+,D1
                  OR.W      (A7)+,D2
                  OR.W      (A7)+,D3
                  OR.W      (A7)+,D4
                  OR.W      (A7)+,D5
                  OR.W      (A7)+,D6
                  OR.W      (A7)+,D7
L00B1:            TST.W     L01E7 
                  BNE.B     L00B2 
                  LSR.W     #1,D0 
                  LSR.W     #1,D1 
                  LSR.W     #1,D2 
                  LSL.W     #1,D5 
                  LSL.W     #1,D6 
                  LSL.W     #1,D7 
L00B2:            TST.W     L01E9 
                  BNE.B     L00B3 
                  EORI.W    #$FFFF,D0 
                  EORI.W    #$FFFF,D1 
                  EORI.W    #$FFFF,D2 
                  EORI.W    #$FFFF,D3 
                  EORI.W    #$FFFF,D4 
                  EORI.W    #$FFFF,D5 
                  EORI.W    #$FFFF,D6 
                  EORI.W    #$FFFF,D7 
L00B3:            TST.W     L01F7 
                  BEQ.B     L00B4 
                  ANDI.W    #$55,D0 
                  ANDI.W    #$AA,D1 
                  ANDI.W    #$55,D2 
                  ANDI.W    #$AA,D3 
                  ANDI.W    #$55,D4 
                  ANDI.W    #$AA,D5 
                  ANDI.W    #$55,D6 
                  ANDI.W    #$AA,D7 
L00B4:            MOVE.B    D0,(A0) 
                  MOVE.B    D1,160(A0)
L00B5             EQU       *-2 
                  MOVE.B    D2,320(A0)
L00B6             EQU       *-2 
                  MOVE.B    D3,480(A0)
L00B7             EQU       *-2 
                  MOVE.B    D4,640(A0)
L00B8             EQU       *-2 
                  MOVE.B    D5,800(A0)
L00B9             EQU       *-2 
                  MOVE.B    D6,960(A0)
L00BA             EQU       *-2 
                  MOVE.B    D7,1120(A0) 
L00BB             EQU       *-2 
                  ADDQ.W    #1,L0203
                  BRA       L00A3 
L00BC:            MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L00BD:            PEA       $20007
                  MOVE.W    #3,-(A7)
                  TRAP      #$D 
                  ADDQ.L    #6,A7 
                  RTS 
L00BE:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  SF        L01F7 
                  BSR.B     L00BF 
                  TST.L     D0
                  BEQ.B     L00C1 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L00BF:            MOVE.W    #$11,-(A7)
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  TST.W     D0
                  BMI.B     L00C0 
                  LEA       L019A(PC),A6
                  MOVE.W    #$6E70,L01FA
                  SF        L01F7 
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR.B     L00BD 
                  MOVEQ     #-1,D0 
                  RTS 
L00C0:            MOVEQ     #0,D0 
                  RTS 
L00C1:            BSR       L00EA 
                  MOVEA.L   $44E.W,A0 
                  LEA       30720(A0),A0
L00C2             EQU       *-2 
                  LEA       L020E,A1
                  LEA       30720(A1),A1
L00C3             EQU       *-2 
                  MOVE.W    #$13F,D0
L00C4             EQU       *-2 
L00C5:            MOVE.L    (A0)+,(A1)+ 
                  DBF       D0,L00C5
                  BSR.B     L00BD 
                  BSR       L00EA 
                  LEA       L0197(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #$18,D1 
L00C6             EQU       *-1 
                  BSR       L00A1 
                  CLR.W     L01FD 
                  MOVE.W    #1,L020A
                  TST.W     L0209 
                  BNE.B     L00C8 
                  TST.W     L01F9 
                  BNE.B     L00C8 
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
                  MOVE.W    L01F6,D1
                  SUB.W     L01F5,D1
                  MOVE.W    L01E0,D0
                  SUBQ.W    #2,D0 
                  DIVU      D0,D1 
                  MOVE.W    D1,D0 
                  SWAP      D1
                  TST.W     D1
                  BEQ.B     L00C7 
                  ADDQ.W    #1,D0 
L00C7:            MOVE.W    D0,L00CF
                  BSR       L00CE 
L00C8:            MOVE.W    L01CF(PC),-(A7) 
                  MOVE.W    #$21,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  MOVE.W    L01F5,-(A7) 
L00C9:            LEA       L020E,A0
                  MOVE.W    #$13F,D0
L00CA:            MOVE.L    #0,(A0)+
                  DBF       D0,L00CA
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  CMPI.B    #2,$44C.W 
                  BEQ.B     L00CB 
                  MOVE.B    #2,$44C.W 
                  BSR       L0006 
                  CLR.B     $44C.W
L00CB:            MOVE.W    L01F5,D6
                  LEA       L0210,A6
                  LSL.W     #2,D6 
                  MOVEA.L   0(A6,D6.W),A5 
                  MOVEQ     #0,D1 
                  MOVE.L    #L020E,L0205
                  BSR       L0102 
                  TST.B     $44C.W
                  BNE.B     L00CC 
                  MOVE.B    #1,$44C.W 
                  BSR       L0006 
L00CC:            MOVE.L    $44E.W,L0205
                  MOVEQ     #0,D0 
                  MOVE.W    L01F6,D0
                  SUB.W     L01F5,D0
                  LEA       L0199(PC),A3
                  BSR       L0019 
                  MOVE.W    #$7072,L01FA
                  LEA       L0198(PC),A6
                  MOVEQ     #$18,D0 
                  MOVEQ     #$18,D1 
L00CD             EQU       *-1 
                  BSR       L00A1 
                  TST.W     L01F9 
                  BNE       L00D4 
                  MOVE.W    L01FD,D1
                  CMP.W     L01E0,D1
                  BNE       L00D4 
                  MOVEQ     #$C,D0
                  BSR       L00E9 
                  CLR.W     L01FD 
                  BNE       L00D4 
                  ADDQ.W    #1,L020A
                  PEA       L00D4(PC) 
L00CE:            TST.W     L0209 
                  BNE.B     L00D0 
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  ADDQ.W    #2,L01FD
                  LEA       L0000,A6
                  BSR.B     L00D1 
                  LEA       L01E1,A6
                  BSR.B     L00D1 
                  MOVE.W    L020A,D0
                  BSR.B     L00D2 
                  LEA       L01E2,A6
                  BSR.B     L00D1 
                  MOVE.W    #$4D2,D0
L00CF             EQU       *-2 
                  BSR.B     L00D2 
                  LEA       L01E3,A6
                  BSR.B     L00D1 
                  MOVE.W    L01F5,D0
                  BSR.B     L00D2 
                  LEA       L01E4,A6
                  BSR.B     L00D1 
                  MOVE.W    L01F5,D0
                  SUBQ.W    #2,D0 
                  ADD.W     L01E0,D0
                  BSR.B     L00D2 
                  LEA       L01E5,A6
                  BSR.B     L00D1 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
L00D0:            RTS 
L00D1:            MOVE.B    (A6)+,D0
                  BSR       L00E9 
                  TST.B     (A6)
                  BNE.B     L00D1 
                  RTS 
L00D2:            ANDI.L    #$FFFF,D0 
                  LEA       L01E6,A3
                  BSR       L0019 
                  MOVEA.L   A3,A6 
L00D3:            MOVE.B    (A6)+,D0
                  BSR       L00E9 
                  CMPI.B    #$20,-1(A6) 
                  BNE.B     L00D3 
                  RTS 
L00D4:            MOVEM.L   (A7)+,A0-A6/D0-D7 
                  LEA       L020D,A5
L00D5:            MOVEQ     #0,D0 
                  MOVE.B    (A5)+,D0
                  TST.B     D0
                  BEQ       L00E1 
                  CMP.B     #$60,D0 
                  BNE.B     L00D7 
                  CMPI.B    #$60,(A5) 
                  BNE.B     L00D6 
                  ADDQ.L    #1,A5 
                  BRA.B     L00D7 
L00D6:            ADDQ.L    #5,A5 
                  BRA.B     L00D5 
L00D7:            CMP.B     #$40,D0 
                  BNE.B     L00DB 
                  TST.W     L01F8 
                  BEQ.B     L00D8 
                  ADDQ.L    #1,A5 
                  BRA.B     L00D5 
L00D8:            CMPI.B    #$2D,(A5) 
                  BEQ.B     L00DA 
                  CMPI.B    #$34,(A5) 
                  BLT.B     L00DB 
                  CMPI.B    #$35,(A5) 
                  BGT.B     L00D9 
                  BRA.B     L00DA 
L00D9:            CMPI.B    #$47,(A5) 
                  BLT.B     L00DB 
                  CMPI.B    #$4A,(A5) 
                  BGT.B     L00DB 
                  CMPI.B    #$49,(A5) 
                  BLT.B     L00DA 
                  MOVE.B    (A5)+,D0
                  SUBI.B    #$49,D0 
                  MOVE.B    D0,L01EA
                  BRA.B     L00E0 
L00DA:            MOVEQ     #$1B,D0 
L00DB:            TST.B     L01EA 
                  BNE.B     L00DF 
                  CMP.B     #$20,D0 
                  BNE.B     L00DF 
                  CMPI.B    #$40,-3(A5) 
                  BNE.B     L00DC 
                  CMPI.B    #$49,-2(A5) 
                  BEQ.B     L00DE 
                  CMPI.B    #$A,-4(A5)
                  BNE.B     L00DF 
L00DC:            CMPI.B    #$40,(A5) 
                  BNE.B     L00DD 
                  CMPI.B    #$4A,1(A5)
                  BEQ.B     L00DE 
L00DD:            CMPI.B    #$20,(A5) 
                  BNE.B     L00DF 
L00DE:            MOVEQ     #$48,D0 
                  BSR       L00E9 
                  MOVEQ     #8,D0 
                  BSR.B     L00E9 
                  MOVEQ     #$49,D0 
L00DF:            BSR.B     L00E9 
L00E0:            PEA       $600FF
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  CMP.W     #$1B,D0 
                  BEQ.B     L00E2 
                  SWAP      D0
                  CMP.W     #$61,D0 
                  BEQ.B     L00E2 
                  BRA       L00D5 
L00E1:            ADDQ.W    #1,L01F5
                  ADDQ.W    #1,L01FD
                  MOVE.W    L01F5,D6
                  MOVE.W    L01F6,D7
                  CMP.W     D6,D7 
                  BGE       L00C9 
L00E2:            MOVE.W    (A7)+,L01F5 
                  MOVEQ     #5,D7 
L00E3:            MOVEQ     #7,D0 
                  BSR.B     L00E9 
                  DBF       D7,L00E3
                  TST.W     L01F9 
                  BNE.B     L00E4 
                  MOVEQ     #$C,D0
                  BSR.B     L00E9 
L00E4:            LEA       L020E,A0
                  LEA       30720(A0),A0
L00E5             EQU       *-2 
                  MOVEA.L   $44E.W,A1 
                  LEA       30720(A1),A1
L00E6             EQU       *-2 
                  MOVE.W    #$13F,D0
L00E7             EQU       *-2 
L00E8:            MOVE.L    (A0)+,(A1)+ 
                  DBF       D0,L00E8
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L00E9:            MOVE.W    D0,-(A7)
                  PEA       $30000
                  TRAP      #$D 
                  ADDQ.L    #6,A7 
                  RTS 
L00EA:            EORI.L    #$7770777,$FFFF8240.W 
                  MOVEQ     #-1,D0 
L00EB:            DBF       D0,L00EB
                  RTS 
L00EC:            MOVE.B    L01FE,D0
                  CMP.B     #$FA,D0 
                  BNE.B     L00ED 
                  MOVE.L    #$480038,D0 
                  RTS 
L00ED:            CMP.B     #$F9,D0 
                  BNE.B     L00EE 
                  MOVE.L    #$500032,D0 
                  RTS 
L00EE:            TST.W     L01FF 
                  BEQ.B     L00F1 
                  BMI.B     L00F0 
                  MOVE.L    #$500000,D0 
L00EF:            CLR.W     L01FF 
                  RTS 
L00F0:            MOVE.L    #$480000,D0 
                  BRA.B     L00EF 
L00F1:            PEA       $600FF
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.L     D0
                  BEQ.B     L00EC 
                  MOVE.L    D0,-(A7)
                  PEA       $BFFFF
                  TRAP      #$D 
                  ADDQ.L    #4,A7 
                  BTST      #3,D0 
                  BEQ.B     L00F2 
                  MOVE.L    (A7)+,D0
                  MOVE.W    #$AAAA,D0 
                  RTS 
L00F2:            MOVE.L    (A7)+,D0
                  RTS 
L00F3:            CLR.B     $484.W
                  MOVEA.L   $44E.W,A0 
                  LEA       L020E,A1
                  MOVE.W    #$3E7F,D0 
L00F4:            MOVE.W    (A0)+,(A1)+ 
                  DBF       D0,L00F4
                  MOVEA.L   $44E.W,A4 
                  MOVE.W    #$1F3F,D0 
L00F5:            CLR.L     (A4)+ 
                  DBF       D0,L00F5
                  LEA       L01A4(PC),A6
                  MOVE.B    L01D1(PC),1759(A6)
                  MOVE.B    L01D2(PC),1760(A6)
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
L00F6             EQU       *-1 
                  SF        L01F7 
                  BSR       L00A1 
                  LEA       L01B4,A6
                  MOVEQ     #$3C,D0 
                  MOVEQ     #$17,D1 
L00F7             EQU       *-1 
                  BSR       L00A1 
                  LEA       L01B5,A6
                  MOVEQ     #$4D,D0 
                  MOVEQ     #$17,D1 
L00F8             EQU       *-1 
                  BSR       L00A1 
L00F9:            LEA       L01B4,A6
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  BSR       L0100 
                  TST.W     D0
                  BEQ.B     L00FB 
                  MOVEQ     #0,D1 
                  MOVEQ     #0,D2 
                  MOVE.W    D0,D1 
                  MOVE.W    D0,D2 
                  ANDI.W    #$1F,D0 
                  ANDI.W    #$7E0,D1
                  ANDI.W    #$F800,D2 
                  LSR.W     #5,D1 
                  LSR.W     #8,D2 
                  LSR.W     #3,D2 
                  MOVEA.L   A6,A0 
                  MOVE.W    D2,D7 
                  BSR       L0101 
                  MOVE.W    D1,D7 
                  BSR       L0101 
                  MOVE.W    D0,D7 
                  BSR       L0101 
                  BSR       L0100 
                  SWAP      D0
                  MOVEQ     #0,D1 
                  MOVEQ     #0,D2 
                  MOVE.W    D0,D1 
                  MOVE.W    D0,D2 
                  ANDI.L    #$1F,D0 
                  ANDI.W    #$1E0,D1
                  ANDI.W    #$FE00,D2 
                  LSR.W     #5,D1 
                  LSR.W     #8,D2 
                  LSR.W     #1,D2 
                  MOVE.L    4.W,D7
                  CLR.B     D7
                  MOVEA.L   D7,A0 
                  TST.W     28(A0)
                  BNE.B     L00FA 
                  EXG       D1,D0 
L00FA:            LEA       9(A6),A0
                  MOVEQ     #0,D7 
                  MOVE.W    D0,D7 
                  BSR.B     L0101 
                  MOVE.W    D1,D7 
                  BSR.B     L0101 
                  MOVE.W    D2,D7 
                  ADDI.W    #$50,D7 
                  BSR.B     L0101 
L00FB:            MOVEM.L   (A7)+,A0-A6/D0-D7 
                  BSR       L0099 
                  SUBQ.W    #1,L01D3
                  BNE.B     L00FE 
                  MOVE.W    #$19,L01D3
L00FC             EQU       *-6 
                  CMPI.B    #$54,L01B4
                  BEQ.B     L00FE 
                  EORI.B    #$1A,2(A6)
                  EORI.B    #$1A,5(A6)
                  MOVEQ     #$3C,D0 
                  MOVEQ     #$17,D1 
L00FD             EQU       *-1 
                  BSR       L00A1 
L00FE:            PEA       $600FF
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.L     D0
                  BEQ       L00F9 
                  MOVEA.L   L0205,A0
                  LEA       L020E,A1
                  MOVE.W    #$3E7F,D0 
L00FF:            MOVE.W    (A1)+,(A0)+ 
                  DBF       D0,L00FF
                  MOVE.B    #6,$484.W 
                  RTS 
L0100:            MOVE.W    #$17,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  RTS 
L0101:            DIVU      #$A,D7
                  ADDI.B    #$30,D7 
                  MOVE.B    D7,(A0)+
                  SWAP      D7
                  ADDI.B    #$30,D7 
                  MOVE.B    D7,(A0)+
                  ADDQ.L    #1,A0 
                  MOVEQ     #0,D7 
                  RTS 
L0102:            LEA       L020D,A6
                  CMPA.L    L01DD,A5
                  BLT.B     L0103 
                  CMPA.L    L01DE,A5
                  BGE.B     L0103 
                  SF        L01F7 
                  BRA.B     L0104 
L0103:            ST        L01F7 
L0104:            TST.B     (A5)
                  BEQ.B     L0105 
                  MOVE.B    (A5)+,(A6)+ 
                  CMPI.B    #$A,-1(A6)
                  BNE.B     L0104 
                  MOVE.B    #0,(A6)+
L0105:            LEA       L020D,A6
                  MOVEQ     #0,D0 
                  BSR       L00A1 
                  RTS 
L0106:            MOVE.W    #0,$484.L 
                  PEA       L010A(PC) 
L0107:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVEQ     #0,D0 
                  MOVE.W    D6,D0 
                  LEA       L0190,A3
                  BSR       L0019 
                  MOVEQ     #0,D0 
                  MOVE.W    D6,D0 
                  ADDI.W    #$14,D0 
L0108             EQU       *-2 
                  CMP.W     L01FC,D0
                  BLT.B     L0109 
                  MOVE.W    L01FC,D0
                  SUBQ.W    #1,D0 
L0109:            LEA       L0191,A3
                  BSR       L0019 
                  LEA       L018F(PC),A6
                  SF        L01F7 
                  MOVEQ     #$3F,D0 
                  MOVEQ     #0,D1 
                  BSR       L00A1 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L010A:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVEA.L   L0205,A0
                  LEA       2560(A0),A0 
L010B             EQU       *-2 
                  MOVE.W    #$29F,D7
L010C             EQU       *-2 
                  MOVEM.L   L020F,A2-A4/D0-D6 
L010D:            MOVEM.L   A2-A4/D0-D6,(A0)
                  LEA       40(A0),A0 
                  DBF       D7,L010D
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  MOVEQ     #2,D1 
                  MOVEQ     #$14,D3 
L010E             EQU       *-1 
                  LSL.W     #2,D6 
L010F:            LEA       L0210,A2
                  MOVEA.L   0(A2,D6.W),A5 
                  BSR       L0102 
                  ADDQ.W    #1,D1 
                  ADDQ.L    #4,D6 
                  DBF       D3,L010F
                  LSR.W     #2,D6 
                  SUBQ.W    #1,D6 
                  MOVE.B    #6,$484.L 
                  RTS 
L0110:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.B    #7,$484.W 
                  MOVE.L    #$63686172,L0183
                  MOVE.L    #$61637465,L0184
L0111:            BSR       L00A0 
                  LEA       L0182(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  MOVEQ     #0,D5 
L0112:            LEA       L0186(PC),A6
                  MOVEQ     #$39,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  LEA       L0185(PC),A6
                  MOVE.B    #$DB,0(A6,D5.W) 
                  MOVE.B    #$20,1(A6,D5.W) 
                  CLR.B     2(A6,D5.W)
                  MOVEQ     #$2F,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L0113:            BSR       L00EC 
                  CMP.W     #$1B,D0 
                  BNE.B     L0114 
                  TST.W     D5
                  BNE.B     L0111 
                  BRA.B     L0113 
L0114:            TST.W     D5
                  BNE.B     L0115 
                  SF        L0181 
                  CMP.W     #$32,D0 
                  BGT.B     L0113 
L0115:            CMP.W     #1,D5 
                  BGT.B     L0116 
                  CMPI.B    #$32,L0185
                  BNE.B     L0116 
                  CMP.W     #$35,D0 
                  BGT.B     L0113 
L0116:            CMP.W     #2,D5 
                  BGT.B     L0117 
                  CMPI.W    #$3235,L0185
                  BNE.B     L0117 
                  CMP.W     #$36,D0 
                  BGT.B     L0113 
L0117:            CMP.W     #$D,D0
                  BNE.B     L0118 
                  TST.W     D5
                  BEQ       L011E 
                  CMP.W     #3,D5 
                  BNE.B     L0113 
                  BRA.B     L011C 
L0118:            CMP.W     #8,D0 
                  BNE.B     L0119 
                  TST.W     D5
                  BEQ.B     L0113 
                  SUBQ.W    #1,D5 
                  BRA       L0112 
L0119:            CMP.W     #$24,D0 
                  BNE.B     L011A 
                  TST.W     D5
                  BNE.B     L0113 
                  ST        L0181 
                  BRA.B     L011B 
L011A:            CMP.W     #$30,D0 
                  BLT       L0113 
                  CMP.W     #$39,D0 
                  BLE.B     L011B 
                  TST.W     L0181 
                  BEQ       L0113 
                  ORI.W     #$20,D0 
                  CMP.W     #$61,D0 
                  BLT       L0113 
                  CMP.W     #$66,D0 
                  BGT       L0113 
L011B:            LEA       L0185(PC),A6
                  MOVE.B    D0,0(A6,D5.W) 
                  CMP.W     #3,D5 
                  BEQ       L0112 
                  ADDQ.W    #1,D5 
                  BRA       L0112 
L011C:            LEA       L0185(PC),A6
                  BSR.B     L011F 
                  BSR       L00BF 
                  TST.L     D0
                  BMI.B     L011D 
                  BSR       L00E9 
L011D:            MOVE.L    #$6E657874,L0183
                  MOVE.L    #$20636861,L0184
                  BRA       L0111 
L011E:            BSR       L00A0 
                  MOVE.B    #6,$484.W 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L011F:            MOVEM.L   A6/D1-D2,-(A7)
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
                  MOVEQ     #0,D2 
                  MOVE.B    (A6)+,D0
                  CMP.B     #$24,D0 
                  BEQ.B     L0120 
                  SUBI.B    #$30,D0 
                  MULU      #$64,D0 
                  MOVE.B    (A6)+,D1
                  SUBI.B    #$30,D1 
                  MULU      #$A,D1
                  ADD.B     D1,D0 
                  MOVE.B    (A6)+,D1
                  SUBI.B    #$30,D1 
                  ADD.B     D1,D0 
                  BRA.B     L0126 
L0120:            MOVE.B    (A6)+,D0
                  CMP.B     #$39,D0 
                  BGT.B     L0122 
                  SUBI.B    #$30,D0 
L0121:            LSL.W     #4,D0 
                  BRA.B     L0123 
L0122:            SUBI.B    #$57,D0 
                  BRA.B     L0121 
L0123:            MOVE.B    (A6)+,D1
                  CMP.B     #$39,D1 
                  BGT.B     L0125 
                  SUBI.B    #$30,D1 
L0124:            ADD.B     D1,D0 
                  BRA.B     L0126 
L0125:            SUBI.B    #$57,D1 
                  BRA.B     L0124 
L0126:            MOVEM.L   (A7)+,A6/D1-D2
                  RTS 
L0127:            MOVE.B    #7,$484.W 
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
L0128:            LEA       L0187(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  MOVEQ     #0,D5 
L0129:            LEA       L0186(PC),A6
                  MOVEQ     #$39,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  LEA       L0188(PC),A6
                  MOVE.B    #$DB,0(A6,D5.W) 
                  MOVE.B    #$20,1(A6,D5.W) 
                  CLR.B     2(A6,D5.W)
                  MOVEQ     #$14,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L012A:            BSR       L00EC 
                  CMP.B     #$60,D0 
                  BEQ.B     L012A 
                  CMP.B     #$40,D0 
                  BEQ.B     L012A 
                  CMP.B     #$1B,D0 
                  BNE.B     L012B 
                  TST.W     D5
                  BNE.B     L0128 
                  BRA.B     L012A 
L012B:            CMP.B     #$D,D0
                  BNE.B     L012C 
                  TST.W     D5
                  BEQ       L0158 
                  CMP.W     #1,D5 
                  BEQ.B     L012A 
                  BRA.B     L012E 
L012C:            CMP.B     #8,D0 
                  BNE.B     L012D 
                  TST.W     D5
                  BEQ.B     L012A 
                  SUBQ.W    #1,D5 
                  BRA.B     L0129 
L012D:            CMP.B     #$20,D0 
                  BLT.B     L012A 
                  CMP.B     #$7F,D0 
                  BGT.B     L012A 
                  LEA       L0188(PC),A6
                  MOVE.B    D0,0(A6,D5.W) 
                  CMP.W     #$23,D5 
                  BEQ.B     L0129 
                  ADDQ.W    #1,D5 
                  BRA       L0129 
L012E:            BSR       L00A0 
                  LEA       L0189(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L012F:            BSR       L00EC 
                  CMP.W     #$D,D0
                  BEQ.B     L0130 
                  SWAP      D0
                  CMP.W     #$15,D0 
                  BNE.B     L0131 
L0130:            ST        L018A 
                  BRA.B     L0132 
L0131:            CMP.W     #$31,D0 
                  BNE.B     L012F 
                  SF        L018A 
L0132:            BSR       L00A0 
                  LEA       L018B(PC),A6
                  MOVEQ     #$22,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  MOVE.W    D6,-(A7)
                  CMP.W     #$14,D6 
L0133             EQU       *-2 
                  BLT.B     L0135 
                  SUBI.W    #$14,D6 
L0134             EQU       *-2 
L0135:            LSL.W     #2,D6 
                  LEA       L0210,A2
                  MOVEA.L   0(A2,D6.W),A5 
                  TST.W     L0207 
                  BNE.B     L0136 
                  LEA       DOC_FILE,A5 
L0136:            MOVE.W    (A7)+,D6
                  LEA       L0188(PC),A6
                  MOVEA.L   A6,A0 
                  MOVEQ     #0,D1 
L0137:            MOVE.B    (A0),D0 
                  CMP.B     #$DB,D0 
                  BEQ.B     L0139 
                  ADDQ.W    #1,D1 
                  TST.B     L018A 
                  BMI.B     L0138 
                  CMP.B     #$41,D0 
                  BLT.B     L0138 
                  CMP.B     #$5A,D0 
                  BGT.B     L0138 
                  ORI.B     #$20,D0 
L0138:            MOVE.B    D0,(A0)+
                  BRA.B     L0137 
L0139:            CLR.B     (A0)
                  MOVE.W    D1,L0206
                  SUBQ.W    #2,D1 
                  MOVE.L    A6,L013C
                  MOVE.W    D1,L013D
                  ST        L01FB 
                  MOVE.W    #$101D,L0146
                  MOVE.W    #$4E71,L0148
                  MOVE.L    #L01F4,L0145
                  MOVE.W    #$14,L013F
L013A             EQU       *-6 
                  BRA.B     L0143 
L013B:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  LEA       0.L,A6
L013C             EQU       *-4 
                  MOVE.L    #0,D1 
L013D             EQU       *-2 
                  MOVE.W    D6,-(A7)
                  CMP.W     #$14,D6 
L013E             EQU       *-2 
                  BLT.B     L0140 
                  SUBI.W    #$14,D6 
L013F             EQU       *-2 
L0140:            LSL.W     #2,D6 
                  LEA       L0210,A2
                  MOVEA.L   0(A2,D6.W),A5 
                  TST.W     L0207 
                  BNE.B     L0142 
                  LEA       DOC_FILE,A5 
L0141             EQU       *-4 
L0142:            MOVE.W    (A7)+,D6
L0143:            MOVE.B    (A6)+,D7
L0144:            CMPA.L    #L01F4,A5 
L0145             EQU       *-4 
                  BEQ       L0157 
L0146:            MOVE.B    (A5)+,D0
                  TST.B     L018A 
                  BMI.B     L0147 
                  CMP.B     #$41,D0 
                  BLT.B     L0147 
                  CMP.B     #$5A,D0 
                  BGT.B     L0147 
                  ORI.B     #$20,D0 
L0147:            CMP.B     D0,D7 
                  BNE.B     L0144 
                  MOVEM.L   A5-A6/D0-D2,-(A7) 
L0148:            ADDQ.L    #1,A5 
L0149:            MOVE.B    (A5)+,D0
                  TST.B     L018A 
                  BMI.B     L014A 
                  CMP.B     #$41,D0 
                  BLT.B     L014A 
                  CMP.B     #$5A,D0 
                  BGT.B     L014A 
                  ORI.B     #$20,D0 
L014A:            MOVE.B    (A6)+,D2
                  TST.B     L018A 
                  BMI.B     L014B 
                  CMP.B     #$41,D2 
                  BLT.B     L014B 
                  CMP.B     #$5A,D2 
                  BGT.B     L014B 
                  ORI.B     #$20,D2 
L014B:            CMP.B     D0,D2 
                  BNE       L0156 
                  DBF       D1,L0149
                  MOVEM.L   (A7)+,A0-A1/D0-D2 
                  SUBQ.L    #2,A5 
                  SUBA.L    D1,A5 
                  MOVE.L    A5,L014D
                  ADDQ.L    #1,A5 
                  MOVE.L    A5,L0141
                  CLR.W     L0207 
                  LEA       L0210,A6
L014C:            CMPI.L    #0,(A6)+
L014D             EQU       *-4 
                  BLE.B     L014C 
                  SUBQ.L    #8,A6 
                  SUBA.L    #L0210,A6 
                  MOVE.L    A6,D6 
                  LSR.W     #2,D6 
                  MOVE.W    D6,L014E
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  MOVE.W    #0,D6 
L014E             EQU       *-2 
                  MOVEQ     #0,D7 
                  MOVE.B    #2,L0155
                  MOVE.W    L0062(PC),D5
                  MOVE.W    D6,D0 
                  CMP.W     D5,D6 
                  BLE.B     L014F 
                  MOVEQ     #$21,D7 
                  SUB.W     D5,D0 
                  ADD.B     D0,L0155
                  MOVE.W    D5,D6 
L014F:            BSR       L0106 
                  LEA       L0210,A5
                  MOVE.W    L014E(PC),D0
                  LSL.W     #2,D0 
                  MOVEA.L   0(A5,D0.W),A5 
                  LEA       L020D,A6
                  PEA       (A6)
                  MOVEA.L   L014D(PC),A4
L0150:            CMPA.L    A4,A5 
                  BEQ.B     L0151 
                  MOVE.B    (A5)+,(A6)+ 
                  BRA.B     L0150 
L0151:            MOVE.B    #$40,(A6)+
                  MOVE.B    #$49,(A6)+
                  MOVE.W    L0206,D0
L0152:            MOVE.B    (A5)+,(A6)+ 
                  SUBQ.W    #1,D0 
                  BNE.B     L0152 
                  MOVE.B    #$40,(A6)+
                  MOVE.B    #$4A,(A6)+
L0153:            MOVE.B    (A5)+,(A6)+ 
                  CMPI.B    #$A,-1(A6)
                  BEQ.B     L0154 
                  CMPI.B    #0,-1(A6) 
                  BNE.B     L0153 
L0154:            CLR.B     (A6)+ 
                  MOVEQ     #0,D0 
                  MOVEQ     #0,D1 
L0155             EQU       *-1 
                  MOVEA.L   (A7)+,A6
                  BSR       L00A1 
                  SF        L01F7 
                  BSR       L00A0 
                  LEA       L018D(PC),A6
                  MOVEQ     #$22,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  ADDQ.L    #4,A7 
                  BRA       L0042 
L0156:            MOVEM.L   (A7)+,A5-A6/D0-D2 
                  BRA       L0144 
L0157:            SF        L01F7 
                  LEA       L018C(PC),A6
                  MOVEQ     #$20,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00BD 
                  BRA.B     L0159 
L0158:            BSR       L00A0 
L0159:            MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
L015A:            MOVEM.L   A0-A6/D7/D0-D5,-(A7)
                  MOVE.W    D6,L015F
                  MOVE.B    #7,$484.W 
L015B:            LEA       L017F(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  MOVEQ     #0,D5 
L015C:            LEA       L0180(PC),A6
                  MOVE.B    #$DB,0(A6,D5.W) 
                  MOVE.B    #$20,1(A6,D5.W) 
                  CLR.B     2(A6,D5.W)
                  MOVEQ     #$34,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L015D:            BSR       L00EC 
                  CMP.B     #$1B,D0 
                  BNE.B     L015E 
                  TST.W     D5
                  BNE.B     L015B 
                  BRA.B     L015D 
L015E:            CMP.W     #$D,D0
                  BNE       L0167 
                  BSR       L00A0 
                  TST.W     D5
                  BNE.B     L0160 
                  MOVE.W    #0,D6 
L015F             EQU       *-2 
                  MOVEM.L   (A7)+,A0-A6/D7/D0-D5
                  RTS 
L0160:            CMP.W     #4,D5 
                  BEQ.B     L0164 
                  SUBQ.W    #1,D5 
                  MOVE.W    D5,D0 
                  LEA       L0200,A0
                  MOVEA.L   A0,A1 
                  MOVEA.L   A6,A2 
L0161:            MOVE.B    (A2)+,(A1)+ 
                  DBF       D0,L0161
                  MOVEA.L   A6,A2 
                  MOVEQ     #2,D0 
                  SUB.W     D5,D0 
L0162:            MOVE.B    #$30,(A2)+
                  DBF       D0,L0162
L0163:            MOVE.B    (A0)+,(A2)+ 
                  DBF       D5,L0163
L0164:            MOVEQ     #0,D0 
                  MOVE.B    (A6)+,D0
                  SUBI.B    #$30,D0 
                  MULU      #$3E8,D0
                  MOVEQ     #0,D1 
                  MOVE.B    (A6)+,D1
                  SUBI.B    #$30,D1 
                  MULU      #$64,D1 
                  ADD.W     D1,D0 
                  MOVEQ     #0,D1 
                  MOVE.B    (A6)+,D1
                  SUBI.B    #$30,D1 
                  MULU      #$A,D1
                  ADD.W     D1,D0 
                  MOVEQ     #0,D1 
                  MOVE.B    (A6)+,D1
                  SUBI.B    #$30,D1 
                  ADD.W     D1,D0 
                  MOVE.W    D0,D6 
                  MOVE.W    L01FC,D5
                  SUBI.W    #$15,D5 
L0165             EQU       *-2 
                  CMP.W     D5,D6 
                  BLT.B     L0166 
                  MOVEQ     #-1,D6 
L0166:            MOVEM.L   (A7)+,A0-A6/D7/D0-D5
                  RTS 
L0167:            CMP.B     #8,D0 
                  BNE.B     L0168 
                  TST.W     D5
                  BEQ       L015D 
                  SUBQ.W    #1,D5 
                  BRA       L015C 
L0168:            CMP.B     #$30,D0 
                  BLT       L015D 
                  CMP.B     #$39,D0 
                  BGT       L015D 
                  MOVE.B    D0,0(A6,D5.W) 
                  CMP.W     #4,D5 
                  BEQ       L015C 
                  ADDQ.W    #1,D5 
                  BRA       L015C 
L0169:            BSR.B     L016A 
                  MOVE.L    #L016B,16(A0) 
                  RTS 
L016A:            MOVE.W    #$22,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  MOVEA.L   D0,A0 
                  RTS 
L016B:            MOVE.L    D0,-(A7)
                  MOVE.B    (A0),L01FE
                  MOVEQ     #0,D0 
                  MOVE.B    2(A0),D0
                  EXT.W     D0
                  MOVE.W    D0,L01FF
                  MOVE.L    (A7)+,D0
                  RTS 
L016C:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVEM.L   $FFFF8240.W,D6-D7 
                  ANDI.L    #$7770777,D6
                  ANDI.L    #$7770777,D7
                  MOVEM.L   D6-D7,L01D4 
                  LEA       L01DB(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #$17,D1 
                  SF        L01F7 
                  BSR       L00A1 
                  LEA       L01D6(PC),A6
                  MOVEQ     #$10,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
L016D:            MOVE.W    L01D5(PC),D7
                  MOVE.W    D7,D6 
                  MULU      #$E,D6
                  LEA       L01DC(PC),A6
                  LEA       0(A6,D6.W),A6 
                  MOVEQ     #$21,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  LEA       L01D4(PC),A0
                  ADD.W     D7,D7 
                  MOVE.W    0(A0,D7.W),D2 
                  MOVE.W    D2,D3 
                  MOVE.W    D2,D4 
                  ANDI.W    #$700,D2
                  ANDI.W    #$70,D3 
                  ANDI.W    #7,D4 
L016E:            MOVE.W    D2,D5 
                  MOVE.W    D3,D6 
                  MOVE.W    D4,D7 
                  LSR.W     #8,D5 
                  ADDI.B    #$30,D5 
                  MOVE.B    D5,L01D8
                  LSR.W     #4,D6 
                  ADDI.B    #$30,D6 
                  MOVE.B    D6,L01D9
                  ADDI.B    #$30,D7 
                  MOVE.B    D7,L01DA
                  LEA       L01D7(PC),A6
                  MOVEQ     #$32,D0 
                  MOVEQ     #1,D1 
                  BSR       L00A1 
                  BSR       L00EC 
                  CMP.W     #$D,D0
                  BEQ       L017E 
                  SWAP      D0
                  CMP.W     #$48,D0 
                  BNE.B     L016F 
                  SUBQ.W    #1,L01D5
                  CMPI.W    #$FFFF,L01D5
                  BNE       L016D 
                  MOVE.W    #3,L01D5
                  BRA       L016D 
L016F:            CMP.W     #$50,D0 
                  BNE.B     L0170 
                  ADDQ.W    #1,L01D5
                  CMPI.W    #4,L01D5
                  BNE       L016D 
                  CLR.W     L01D5 
                  BRA       L016D 
L0170:            CMP.W     #$67,D0 
                  BNE.B     L0173 
                  ADDI.W    #$100,D2
                  CMP.W     #$800,D2
                  BNE.B     L0171 
                  CLR.W     D2
L0171:            MOVE.W    D2,D0 
                  OR.W      D3,D0 
                  OR.W      D4,D0 
L0172:            MOVE.W    L01D5(PC),D1
                  ADD.W     D1,D1 
                  LEA       $FFFF8240.W,A0
                  LEA       L01D4(PC),A1
                  MOVE.W    D0,0(A0,D1.W) 
                  MOVE.W    D0,0(A1,D1.W) 
                  BRA       L016E 
L0173:            CMP.W     #$68,D0 
                  BNE.B     L0175 
                  ADDI.W    #$10,D3 
                  CMP.W     #$80,D3 
                  BNE.B     L0174 
                  CLR.W     D3
L0174:            MOVE.W    D3,D0 
                  OR.W      D2,D0 
                  OR.W      D4,D0 
                  BRA.B     L0172 
L0175:            CMP.W     #$69,D0 
                  BNE.B     L0177 
                  ADDQ.W    #1,D4 
                  CMP.W     #8,D4 
                  BNE.B     L0176 
                  CLR.W     D4
L0176:            MOVE.W    D4,D0 
                  OR.W      D2,D0 
                  OR.W      D3,D0 
                  BRA.B     L0172 
L0177:            CMP.W     #$6A,D0 
                  BNE.B     L0179 
                  SUBI.W    #$100,D2
                  CMP.W     #$FF00,D2 
                  BNE.B     L0178 
                  MOVE.W    #$700,D2
L0178:            MOVE.W    D2,D0 
                  OR.W      D3,D0 
                  OR.W      D4,D0 
                  BRA.B     L0172 
L0179:            CMP.W     #$6B,D0 
                  BNE.B     L017B 
                  SUBI.W    #$10,D3 
                  CMP.W     #$FFF0,D3 
                  BNE.B     L017A 
                  MOVEQ     #$70,D3 
L017A:            MOVE.W    D3,D0 
                  OR.W      D2,D0 
                  OR.W      D4,D0 
                  BRA       L0172 
L017B:            CMP.W     #$6C,D0 
                  BNE.B     L017D 
                  SUBQ.W    #1,D4 
                  CMP.W     #$FFFF,D4 
                  BNE.B     L017C 
                  MOVEQ     #7,D4 
L017C:            MOVE.W    D4,D0 
                  OR.W      D2,D0 
                  OR.W      D3,D0 
                  BRA       L0172 
L017D:            BRA       L016D 
L017E:            LEA       L01CE(PC),A6
                  MOVEQ     #0,D0 
                  MOVEQ     #$17,D1 
                  BSR       L00A1 
                  BSR       L00A0 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 

		SECTION	DATA 

L017F:            DC.B      '                        @GEnter line number to go to:@H ',0
L0180:            DC.B      $DB,' ',$00,$00,$00,$00,$00 
L0181:            DC.B      $00,$00 
L0182:            DC.B      '@GEnter code of '
L0183:            DC.B      'char'
L0184:            DC.B      'acter to be sent to printer:@H ',$00 
L0185:            DC.B      $DB,' ',$0D,$00,$00,$00,$00 
L0186:            DC.B      '@G(just Return to cancel)@H',$00 
L0187:            DC.B      '@GEnter t' 
                  DC.B      'ext to f'
                  DC.B      'ind:@H ',$00 
L0188:            DC.B      $DB,' ',$00,$00,$00,$00,$00,$00 
                  DCB.W     15,0
L0189:            DC.B      '@G',$09,$09,$09,'  Case sensitive search (Y/n)?@H',$00 
L018A:            DC.B      $00 
L018B:            DC.B      '@GSearchi' 
                  DC.B      'ng...@H',$00 
L018C:            DC.B      '@' 
                  DC.B      'GText not found!@H',$00
L018D:            DC.B      '@GFound '
                  DC.B      'text!@H',$00 
L018E:            DC.B      '@IDOC Displayer v5.9 by @GTHE@H ',$8D,$8E,$8F,$90,$91,$92,'. HELP for keys. Showing lines '
L018F:            DC.B      '@I0000'
L0190:            DC.B      '-0000' 
L0191:            DC.B      '@J'
L0192:            DC.B      '@I of 00'
                  DC.B      '00'
L0193:            DC.B      '@J',$00
L0194:            DC.B      '@I[Shift]',$02,':Forwards  Alt-Q:Quit  Alt-B:Last line  Ripped by MENTOR of Special FX ',$00
L0195:            DC.B      '@I[Shift'
                  DC.B      ']',$01,':Back '
                  DC.B      ' ['
                  DC.B      'Shift]',$02,':Forwards  Alt-Q:Quit  Alt-T:First line  Alt-B:Last line @J',$00
L0196:            DC.B      '@I                 [Shift]',$01,':Back    Alt-Q:Quit   Alt-T:First line                 @J',$00
L0197:            DC.B      '@I     Printing document:      lines left to print... Undo or Esc to cancel.      @J',$00
L0198:            DC.B      '@I0000'
L0199:            DC.B      '@J',$00
L019A:            DC.B      '@I                @GPrinter not responding! Is it connected? Online?@H                @J',$00
L019B:            DC.B      '@I                           Block @4START@5 after block @4END@5?                         @J',$00
L019C:            DC.B      '@I                           Block @4END@5 before block @4START@5?                        @J',$00
L019D:            DC.B      '@I                             Form feeds @Gdisabled@H.                               @J',$00
L019E:            DC.B      '@I                             Form feeds @Genabled.@H                                @J',$00
L019F:            DC.B      '@I                                 Marker #' 
L01A0:            DC.B      '0 set.                                 @J',$00 
L01A1:            DC.B      '@I      '
                  DC.B      '        '
                  DC.B      '        '
                  DC.B      '        '
                  DC.B      ' Marker '
                  DC.B      '#' 
L01A2:            DC.B      '0 recalle' 
                  DC.B      'd.      '
                  DC.B      '        '
                  DC.B      '        '
                  DC.B      '        '
                  DC.B      '@J',$00
L01A3:            DC.B      'Processing... please wait.',$00
L01A4:            DC.B      $09,'      @GThe@H ',$80,$81,$82,$83,$84,$85,' ',$86,$87,$88,$89,$8A,$8B,$8C,' @GDoc Displayer v5.9@H by @GTHE@H ',$8D,$8E,$8F,$90,$91,$92,$0D,$0A
                  DC.B      $DA,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C2,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$BF,$0D 
                  DC.B      $0A,$9F
                  DC.B      ' F1',$09,' Mark start of block to print ',$9F,' Control+C',$09,'       Invert Colours ',$9F,$0D,$0A
                  DC.B      $9F,' F2',$09,'   Mark end of block to print ',$9F,' Control+S',$09,' ' 
L01A5:            DC.B      'Speak block out loud ',$9F,$0D,$0A,$9F,' F3  ' 
L01A6:            DC.B      'Toggle gr' 
                  DC.B      'aphics p'
                  DC.B      'rinting on/off ',$9F,' Control+B',$09,' Goto bottom of block ',$9F,$0D,$0A,$9F,' F4  ' 
L01A7:            DC.B      'Toggle graphic text mode on/off ',$9F,' Control+T',$09,'    Goto top of block ',$9F,$0D,$0A
                  DC.B      $9F,' F6',$09,'      Toggle formfeeds on/off ',$9F,' Control+F',$09,' Toggle between fonts ',$9F,$0D,$0A
                  DC.B      $9F,' F7  Send a character to the printer '
                  DC.B      $C3,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$B4,$0D,$0A,$9F
                  DC.B      ' F8',$09,'Toggle @Gbold@H/@4italic@5/@-1underlined@-0 ',$9F,' Alternate+C',$09,$09,'  '
L01A8:            DC.B      'Set colours ',$9F,$0D,$0A
                  DC.B      $9F,' F9',$09,$09,'      Printer options ',$9F,' Alternate+G',$09,$09,'  Goto a line ',$9F,$0D,$0A
                  DC.B      $9F,' F10',$09,$09,'   Print marked block ',$9F,' Alternate+F',$09,$09,'    Find text ',$9F,$0D,$0A 
                  DC.B      $C3,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$B4
                  DC.B      ' Alternate+N',$09,$09,'    Find next ',$9F,$0D,$0A 
                  DC.B      $9F,' Numeric keys 1 to 0',$09,'  Set markers ',$9F,' Alternate+P',$09,$09,'Find previous ',$9F,$0D,$0A 
                  DC.B      $9F,' Alternate + 1 to 0   Recall markers ',$9F,' Alternate+B',$09,'   Goto bottom of doc ',$9F,$0D,$0A 
                  DC.B      $C3,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,' But. = mouse button ',$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$B4,' Alternate+T',$09,'      Goto top of doc ',$9F,$0D,$0A 
                  DC.B      $9F,' Shift+',$02,' / Space / RBut.   Page down ',$9F,' Alternate+Q',$09,$09,$09,' Quit ',$9F,$0D,$0A 
                  DC.B      $9F,' Shift+',$01,' / LBut.',$09,'      Page up '
                  DC.B      $C3,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4,$B4,$0D,$0A 
                  DC.B      $9F,' ',$02,' / Return / Mouse ',$02,$09,'    Line down ',$9F,' Esc or Undo   ' 
L01A9:            DC.B      'Abort printing/speaking ',$9F,$0D,$0A
                  DC.B      $9F,' ',$01,' / Mouse ',$01,$09,$09,'      Line up ',$9F,' * on keypad',$09,'   ' 
L01AA:            DC.B      'Toggle 50/60 Hertz '
                  DC.B      $9F,$0D,$0A,$C0,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C1,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$D9,$0D,$0A,$DA 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$BF,$0D,$0A
                  DC.B      $9F,' Graphics printing: '
L01AB:            DC.B      'ON   Grap' 
                  DC.B      'hic text'
                  DC.B      ' mode: ' 
L01AC:            DC.B      'OFF  Bold/ital/undrlin: '
L01AD:            DC.B      ' ENABLED ',$9F 
                  DC.B      $0D,$0A,$9F,' Print port: ' 
L01AE:            DC.B      'PARALLEL ' 
                  DC.B      ' Formfee'
                  DC.B      'ds: '
L01AF:            DC.B      ' ENABLED'
                  DC.B      '  Qualit'
                  DC.B      'y: ' 
L01B0:            DC.B      'DRAFT  Page titles: '
L01B1:            DC.B      'O' 
L01B2:            DC.B      'N  ',$9F,$0D,$0A 
                  DC.B      $9F,' Printer: '
L01B3:            DC.B      'EPSON BLACK & WHITE DOT MATRIX  Lines/page: 00   ',$00 
L01B4:            DC.B      '        ,' 
                  DC.B      '  /  /  '
                  DC.B      $00 
L01B5:            DC.B      ' ',$9F,$0D,$0A,$C0,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$C4,$C4,$C4,$C4,$C4,$C4,$C4 
                  DC.B      $C4,$D9,$00 
L01B6:            DC.B      'DIS',$00 
L01B7:            DC.B      ' EN',$00 
L01B8:            DC.B      'PARALLE',$00 
L01B9:            DC.B      '  SERIA',$00 
L01BA:            DC.B      'DRAFT',$00 
L01BB:            DC.B      'FINAL',$00 
L01BC:            DC.B      'TIME/DATE INVALID',$00 
L01BD:            DC.B      ' Not applicable here',$00
L01BE:            DC.B      '         Abort print',$00
L01BF:            DC.B      '        '
L01C0:            DC.B      'Colour only',$00 
L01C1:            DC.B      'Set colours',$00 
L01C2:            DC.B      'Toggle 50/60 Hertz',$00
L01C3:            DC.L      L01C4 
                  DC.L      L01C5 
                  DC.L      L01C6 
                  DC.L      L01C7 
L01C4:            DC.B      'ATARI BLACK & WHITE DOT MATRIX',$00
L01C5:            DC.B      'ATARI COL' 
                  DC.B      'OUR DOT MATRIX       ',$00 
L01C6:            DC.B      'ATARI BLACK & WHITE DAISYWHEEL',$00
L01C7:            DC.B      'EPSON BLACK & WHITE DOT MATRIX',$00
L01C8:            DC.B      $00,$00,$00,$02,$00,$01,$00,$04 
L01C9:            DC.B      '   Select printer port:    F1...Centronics (Parallel)    F2...RS-232 (Serial)   ',$00
L01CA:            DC.B      '           Select graphic print quality:    F1...Draft    F2...Final',$00
L01CB:            DC.B      '               Want page titles printed?    F1...Yes    F2...No',$00 
L01CC:            DC.B      '      Select printer using ',$01,', ',$02,' and Return: ',$00
L01CD:            DC.B      '           Select number of lines per page using ',$01,', ',$02,' and Return: ',$00
L01CE:            DC.B      '                                                                                '
L01CF:            DC.B      $00 
L01D0:            DC.B      $04 
L01D1:            DC.B      '5' 
L01D2:            DC.B      '5',$00,$00 
L01D3:            DC.B      $00,$01 
L01D4:            DC.B      $07,'w',$00,$00,$07,'u',$00,$05 
L01D5:            DC.B      $00,$00 
L01D6:            DC.B      'Colour selected: ',$00 
L01D7:            DC.B      'RGB value: ' 
L01D8:            DC.B      '0' 
L01D9:            DC.B      '0' 
L01DA:            DC.B      '0',$00 
L01DB:            DC.B      '@I@G',$01,' + ',$02,': select colour   Keypad 789/456: increase/decrease RGB    Return to finish@H@J',$00
L01DC:            DC.B      '0 (paper)    ',$00 
                  DC.B      '1 (ink)      ',$00 
                  DC.B      '2 (bar ink)  ',$00 
                  DC.B      '3 (bar paper)',$00 
L01DD:            DC.L      DOC_FILE
L01DE:            DC.L      L01F4 
L01DF:            DC.B      $03,$19,$03,$C4,$00,$00,$00,$00 
                  DCB.W     6,0 
L01E0:            DC.B      $00,'7' 
L01E1:            DC.B      ' : Page '
                  DC.B      $00 
L01E2:            DC.B      'of ',$00 
L01E3:            DC.B      ': Lines ',$00
L01E4:            DC.B      'to ',$00 
L01E5:            DC.B      $08,'.',$0D,$0A,$0A,$00,'00'
                  DC.B      '00'
L01E6:            DC.B      ' ',$00 
L01E7:            DC.B      $00,$01 
L01E8:            DC.B      $00,$01 
L01E9:            DC.B      $00,$01 
L01EA:            DC.B      $01,$00 
L01EB:            DC.B      $00,$00 

FONT_1            INCBIN    'FONT_1.BIN"
		  EVEN
	
FONT_2            INCBIN    'FONT_2.BIN"
	          EVEN

L01EE:            DC.B      'N ',$00
L01EF:            DC.B      'FF',$00
L01F0:            DC.B      'N/A',$00 
L01F1:            DC.B      $00,$03,$00,$00 
L01F2:            DC.B      'Not applicable in this document',$00 

;
; Doc File goes here
;

DOC_FILE	INCBIN	"hunter.doc"

END_OF_DOC	DC.B      $00 

	SECTION	BSS

L01F4:            DS.L      1 
L01F5:            DS.W      1 
L01F6:            DS.W      1 
L01F7:            DS.W      1 
L01F8:            DS.W      1 
L01F9:            DS.W      1 
L01FA:            DS.W      1 
L01FB:            DS.W      1 
L01FC:            DS.B      34
L01FD:            DS.W      1 
L01FE:            DS.W      1 
L01FF:            DS.W      1 
L0200:            DS.L      1 
L0201:            DS.B      160 
L0202:            DS.B      100 
L0203:            DS.W      1 
L0204:            DS.W      1 
L0205:            DS.L      1 
L0206:            DS.W      1 
L0207:            DS.W      1 
L0208:            DS.W      1 
L0209:            DS.W      1 
L020A:            DS.W      1 
L020B:            DS.B      4096
L020C:            DS.B      4096
L020D:            DS.B      128 
L020E:            DS.B      32000 
L020F:            DS.B      160 

L0210:		DS.L	1
L0211:		DS.L	1

ZUEND		END

