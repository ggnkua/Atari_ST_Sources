***********************************************
*DOC DISPLAYER BY THE ALIEN. RIPPED BY ALCHEMY!
***********************************************

Begin:
      CLR.L     -(A7) 
      MOVE.W    #$20,-(A7) 	;SUPER
      TRAP      #1
      MOVE.L    #L0033,$70.W
      MOVE.W    #3,-(A7)
      PEA       $23000F 
      TRAP      #$E 
      ADDQ.L    #6,A7 
      MOVE.B    #6,$484.W 
      DC.B      $A0,$0A,$A0,$00 
      MOVEA.L   4(A1),A2
      MOVE.L    76(A2),D6 
      EORI.L    #L006E,D6 
      MOVE.L    D6,L001D
      MOVEQ     #1,D0 
      BSR       L0032 
      MOVE.L    #$7770000,-$7DC0.W
      CLR.L     -$7DBC.W
      MOVE.L    $44E.W,D0 
      ADDI.L    #$500,D0
      MOVE.L    D0,L0006
      MOVE.L    $44E.W,L007A
      LEA       L0060(PC),A6
      BSR       L0034 
      MOVEA.L   $44E.W,A0 
      MOVE.W    #$13F,D0
L0000:EORI.W    #-1,(A0)+ 
      ADDQ.L    #2,A0 
      DBF       D0,L0000
      LEA       L0081,A1
      LEA       L0072(PC),A5
L0001:MOVE.L    A5,(A1)+
L0002:TST.B     (A5)
      BEQ.S     L0003 
      CMPI.B    #$A,(A5)+ 
      BNE.S     L0002 
      BRA.S     L0001 
L0003:MOVE.L    #L0073,(A1)+
      SUBA.L    #L0081,A1 
      MOVE.L    A1,D0 
      LSR.W     #2,D0 
      SUBQ.L    #2,D0 
      MOVE.W    D0,L0075
      SUBI.W    #$15,D0 
      MOVE.W    D0,L0020
L0004:LEA       L0072(PC),A5
      MOVEQ     #0,D6 
      MOVEQ     #0,D7 
      MOVE.W    #$6677,D4 
      BSR       L005D 
      LEA       L0061(PC),A6
      MOVE.W    #$6674,L007E
      SF        L0076 
      BSR       L0034 
      BRA       L0018 
L0005:LEA       0.L,A4
L0006 EQU       *-4 
      MOVE.W    #$C7F,D0
      CMP.W     #$6677,D4 
      BNE.S     L0009 
      LEA       1280(A4),A4 
      MOVEA.L   A4,A3 
      LEA       1280(A4),A4 
L0007:MOVE.W    (A4)+,(A3)+ 
      MOVE.W    (A4)+,(A3)+ 
      MOVE.W    (A4)+,(A3)+ 
      MOVE.W    (A4)+,(A3)+ 
      DBF       D0,L0007
      MOVE.W    #$9F,D0 
L0008:MOVE.W    #0,(A3)+
      MOVE.W    #0,(A3)+
      MOVE.W    #0,(A3)+
      MOVE.W    #0,(A3)+
      DBF       D0,L0008
      BRA.S     L000C 
L0009:LEA       28160(A4),A4
      MOVEA.L   A4,A3 
      LEA       -1280(A3),A4
L000A:MOVE.W    -(A4),-(A3) 
      MOVE.W    -(A4),-(A3) 
      MOVE.W    -(A4),-(A3) 
      MOVE.W    -(A4),-(A3) 
      DBF       D0,L000A
      MOVE.W    #$9F,D0 
L000B:MOVE.W    #0,-(A3)
      MOVE.W    #0,-(A3)
      MOVE.W    #0,-(A3)
      MOVE.W    #0,-(A3)
      DBF       D0,L000B
L000C:CMP.W     #$6677,D4 
      BNE.S     L000D 
      LEA       L006B(PC),A6
      BRA.S     L000E 
L000D:LEA       L006C(PC),A6
L000E:BSR       L0034 
      LEA       L0081,A1
      CMP.W     #$626B,D4 
      BNE.S     L000F 
      SUBI.W    #$14,D6 
      CMP.W     #-1,D6
      BGT.S     L000F 
      ADDI.W    #$14,D6 
      BRA       L0018 
L000F:LSL.W     #2,D6 
      MOVEA.L   0(A1,D6.W),A5 
      LSR.W     #2,D6 
      CMP.W     #$626B,D4 
      BNE.S     L0010 
      ADDI.W    #$14,D6 
L0010:LEA       L007F,A6
      CMPA.L    L0070,A5
      BLT.S     L0011 
      CMPA.L    L0071,A5
      BGE.S     L0011 
      SF        L0076 
      BRA.S     L0012 
L0011:ST        L0076 
L0012:MOVE.B    (A5)+,(A6)+ 
      TST.B     (A5)
      BEQ.S     L0013 
      CMPI.B    #$A,-1(A6)
      BNE.S     L0012 
      MOVE.B    #0,(A6)+
      LEA       L007F,A6
      BSR       L0034 
      MOVEQ     #0,D7 
      BRA.S     L0014 
L0013:MOVEQ     #$21,D7 
L0014:CMP.W     #$14,D6 
      BEQ.S     L0015 
      CMP.W     #$21,D7 
      BEQ.S     L0016 
      CMPI.W    #$6D74,L007E
      BEQ.S     L0018 
      LEA       L0062(PC),A6
      MOVE.W    #$6D74,L007E
      BRA.S     L0017 
L0015:CMPI.W    #$6674,L007E
      BEQ.S     L0018 
      LEA       L0061(PC),A6
      MOVE.W    #$6674,L007E
      BRA.S     L0017 
L0016:CMPI.W    #$6274,L007E
      BEQ.S     L0018 
      LEA       L0063(PC),A6
      MOVE.W    #$6274,L007E
L0017:SF        L0076 
      BSR       L0034 
L0018:BSR       L0054 
      SWAP      D0
      CMP.W     #$62,D0 
      BNE.S     L001B 
      MOVEA.L   $44E.W,A0 
      LEA       2560(A0),A0 
      LEA       L0080,A1
      MOVE.W    #$397F,D0 
L0019:MOVE.W    (A0)+,(A1)+ 
      DBF       D0,L0019
      BSR       L0057 
      BSR       L0054 
      MOVEA.L   $44E.W,A0 
      LEA       2560(A0),A0 
      LEA       L0080,A1
      MOVE.W    #$397F,D0 
L001A:MOVE.W    (A1)+,(A0)+ 
      DBF       D0,L001A
      BRA.S     L0018 
L001B:CMP.L     #$3002E,D0
      BNE.S     L001C 
      EORI.L    #$7770777,-$7DC0.W
      BRA.S     L0018 
L001C:CMP.L     #$60021,D0
      BNE.S     L001E 
      EORI.L    #0,L0043
L001D EQU       *-8 
      SUBI.W    #$14,D6 
      BSR       L005D 
      BRA.S     L0018 
L001E:CMP.L     #-$5555FFEC,D0
      BNE.S     L001F 
      CMP.W     #$14,D6 
      BEQ       L0018 
      BRA       L0004 
L001F:CMP.L     #-$5555FFD0,D0
      BNE.S     L0021 
      CMPI.W    #$6274,L007E
      BEQ       L0018 
      MOVE.W    #0,D6 
L0020 EQU       *-2 
      BSR       L005D 
      LEA       L0063(PC),A6
      MOVE.W    #$6274,L007E
      SF        L0076 
      BSR       L0034 
      MOVEQ     #$21,D7 
      BRA       L0018 
L0021:CMP.W     #$42,D0 
      BNE.S     L0022 
      EORI.W    #1,L0079
      SUBI.W    #$14,D6 
      BSR       L005D 
      BRA       L0018 
L0022:CMP.W     #$43,D0 
      BNE.S     L0025 
      EORI.W    #1,L007D
      TST.W     L007D 
      BEQ.S     L0023 
      MOVE.W    #$14,-(A7)
      LEA       L0069(PC),A6
      BRA.S     L0024 
L0023:MOVE.W    #4,-(A7)
      LEA       L006A(PC),A6
L0024:BSR       L0034 
      BRA       L0018 
L0025:CMP.W     #$44,D0 
      BNE.S     L0026 
      BSR       L004B 
      BRA       L0018 
L0026:CMP.W     #$3B,D0 
      BNE.S     L0029 
      SUBI.W    #$14,D6 
      CMP.W     L0075,D6
      BLE.S     L0028 
      ADDI.W    #$14,D6 
      LEA       L0067(PC),A6
L0027:SF        L0076 
      BSR       L0034 
      BRA       L0018 
L0028:LSL.W     #2,D6 
      LEA       L0081,A1
      MOVE.L    0(A1,D6.W),L0070
      LSR.W     #2,D6 
      MOVE.W    D6,L0074
      BSR       L005D 
      BRA       L0018 
L0029:CMP.W     #$3C,D0 
      BNE.S     L002B 
      CMP.W     L0074,D6
      BGE.S     L002A 
      LEA       L0068(PC),A6
      BRA.S     L0027 
L002A:LSL.W     #2,D6 
      LEA       L0082,A1
      MOVE.L    0(A1,D6.W),L0071
      LSR.W     #2,D6 
      MOVE.W    D6,L0075
      SUBI.W    #$14,D6 
      BSR       L005D 
      BRA       L0018 
L002B:CMP.L     #$380048,D0 
      BNE.S     L002E 
      MOVEQ     #0,D7 
      SUBI.W    #$28,D6 
      BMI.S     L002D 
L002C:BSR       L005D 
      BRA       L0014 
L002D:MOVEQ     #0,D6 
      BRA.S     L002C 
L002E:CMP.W     #$48,D0 
      BNE.S     L002F 
      CMP.W     #$14,D6 
      BEQ       L0018 
      SUBQ.W    #1,D6 
      MOVE.W    #$626B,D4 
      BRA       L0005 
L002F:CMP.L     #-$5555FFF0,D0
      BEQ.S     L0031 
      CMP.L     #$320050,D0 
      BNE.S     L0030 
      CMP.W     L0020,D6
      BLE.S     L002C 
      MOVE.W    L0020(PC),D6
      BRA.S     L002C 
L0030:CMP.W     #$50,D0 
      BNE       L0018 
      CMP.B     #$21,D7 
      BEQ       L0018 
      ADDQ.W    #1,D6 
      MOVE.W    #$6677,D4 
      BRA       L0005 
L0031:MOVE.L    4.W,-(A7) 
      RTS 
L0032:MOVE.W    D0,-(A7)
      PEA       -1.W
      MOVE.L    (A7),-(A7)
      MOVE.W    #5,-(A7) 	;SETSCREEN
      TRAP      #$E 
      LEA       12(A7),A7 
      RTS 
L0033:ADDQ.W    #1,$468.W 
      RTE 
L0034:MOVEM.L   A0-A6/D0-D7,-(A7) 
L0035:MOVEQ     #0,D1 
      MOVE.B    (A6)+,D1
      BEQ       L0048 
      CMP.B     #9,D1 
      BNE.S     L0036 
      ANDI.B    #-$10,L007B 
      ADDI.L    #$10,L007A
      MOVE.W    #$52B9,L0047
      BRA.S     L0035 
L0036:CMP.B     #$A,D1
      BEQ.S     L0035 
      CMP.B     #$D,D1
      BNE.S     L0037 
      MOVE.L    L007A,D0
      SUB.L     $44E.W,D0 
      DIVU      #$A0,D0 
      ANDI.L    #$FFFF,D0 
      MULU      #$A0,D0 
      ADDI.L    #$500,D0
      ADD.L     $44E.W,D0 
      MOVE.L    D0,L007A
      MOVE.W    #$52B9,L0047
      BRA.S     L0035 
L0037:CMP.B     #$B,D1
      BNE.S     L0038 
      MOVE.L    $44E.W,L007A
      ADDI.L    #$6E00,L007A
      BRA       L0035 
L0038:CMP.B     #$C,D1
      BEQ       L0035 
      CMP.B     #$E,D1
      BNE.S     L0039 
      MOVE.L    $44E.W,L007A
      ADDI.L    #$A00,L007A 
      BRA       L0035 
L0039:CMP.B     #4,D1 
      BNE.S     L003B 
      MOVE.L    $44E.W,L007A
      ADDI.L    #$7800,L007A
L003A:MOVE.L    L007A,L007C 
      BRA       L0035 
L003B:CMP.B     #5,D1 
      BNE.S     L003C 
      MOVE.L    $44E.W,L007A
      ADDI.L    #$500,L007A 
      BRA.S     L003A 
L003C:CMP.B     #6,D1 
      BNE.S     L003D 
      MOVE.L    $44E.W,L007A
      ADDI.L    #$7300,L007A
      BRA.S     L003A 
L003D:CMP.B     #7,D1 
      BNE.S     L003E 
      BSR       L0056 
      BRA       L0035 
L003E:CMP.B     #$40,D1 
      BNE.S     L0042 
      MOVE.B    (A6)+,D1
      CMP.B     #$47,D1 
      BNE.S     L003F 
      ST        L0077 
      BRA       L0035 
L003F:CMP.B     #$48,D1 
      BNE.S     L0040 
      SF        L0077 
      BRA       L0035 
L0040:CMP.B     #$34,D1 
      BNE.S     L0041 
      ST        L0078 
      BRA       L0035 
L0041:CMP.B     #$35,D1 
      BNE.S     L0042 
      SF        L0078 
      BRA       L0035 
L0042:LEA       L006E,A0
L0043 EQU       *-4 
      ADDA.L    D1,A0 
      MOVEA.L   L007A,A1
      MOVEM.L   D0-D7,-(A7) 
      MOVE.B    (A0),D0 
      MOVE.B    256(A0),D1
      MOVE.B    512(A0),D2
      MOVE.B    768(A0),D3
      MOVE.B    1024(A0),D4 
      MOVE.B    1280(A0),D5 
      MOVE.B    1536(A0),D6 
      MOVE.B    1792(A0),D7 
      TST.W     L0076 
      BEQ.S     L0044 
      ANDI.W    #$55,D0 
      ANDI.W    #$AA,D1 
      ANDI.W    #$55,D2 
      ANDI.W    #$AA,D3 
      ANDI.W    #$55,D4 
      ANDI.W    #$AA,D5 
      ANDI.W    #$55,D6 
      ANDI.W    #$AA,D7 
L0044:TST.W     L0079 
      BNE.S     L0046 
      TST.W     L0077 
      BEQ.S     L0045 
      MOVE.W    D0,-(A7)
      LSR.B     #1,D0 
      OR.W      (A7)+,D0
      MOVE.W    D1,-(A7)
      LSR.B     #1,D1 
      OR.W      (A7)+,D1
      MOVE.W    D2,-(A7)
      LSR.B     #1,D2 
      OR.W      (A7)+,D2
      MOVE.W    D3,-(A7)
      LSR.B     #1,D3 
      OR.W      (A7)+,D3
      MOVE.W    D4,-(A7)
      LSR.B     #1,D4 
      OR.W      (A7)+,D4
      MOVE.W    D5,-(A7)
      LSR.B     #1,D5 
      OR.W      (A7)+,D5
      MOVE.W    D6,-(A7)
      LSR.B     #1,D6 
      OR.W      (A7)+,D6
      MOVE.W    D7,-(A7)
      LSR.B     #1,D7 
      OR.W      (A7)+,D7
L0045:TST.W     L0078 
      BEQ.S     L0046 
      LSR.B     #2,D0 
      LSR.B     #2,D1 
      LSR.B     #1,D2 
      LSR.B     #1,D3 
      LSR.B     #1,D4 
L0046:MOVE.B    D0,(A1) 
      MOVE.B    D1,160(A1)
      MOVE.B    D2,320(A1)
      MOVE.B    D3,480(A1)
      MOVE.B    D4,640(A1)
      MOVE.B    D5,800(A1)
      MOVE.B    D6,960(A1)
      MOVE.B    D7,1120(A1) 
      MOVEM.L   (A7)+,D0-D7 
L0047:ADDQ.L    #1,L007A
      EORI.W    #$400,L0047 
      BRA       L0035 
L0048:MOVEA.L   L007C,A0
      CMPA.L    #0,A0 
      BEQ.S     L004A 
      MOVE.W    #$13F,D0
L0049:EORI.W    #-1,(A0)+ 
      ADDQ.L    #2,A0 
      DBF       D0,L0049
      MOVE.L    #0,L007C
L004A:MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTS 
L004B:MOVEM.L   A0-A6/D0-D7,-(A7) 
      MOVE.W    #$11,-(A7) 	;CPRNOS 
      TRAP      #1
      ADDQ.L    #2,A7 
      TST.W     D0
      BMI.S     L004C 
      LEA       L0066(PC),A6
      MOVE.W    #$6E70,L007E
      SF        L0076 
      BSR       L0034 
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTS 
L004C:BSR.S     L0052 
      LEA       L0065(PC),A6
      MOVE.W    #$7072,L007E
      SF        L0076 
      BSR       L0034 
      BSR.S     L0052 
      MOVEA.L   L0070,A5
L004D:MOVE.B    (A5)+,D0
      CMP.B     #$40,D0 
      BNE.S     L004F 
      TST.W     L0079 
      BEQ.S     L004E 
      ADDQ.L    #1,A5 
      BRA.S     L004D 
L004E:MOVEQ     #$1B,D0 
      BSR.S     L0051 
      MOVE.B    (A5)+,D0
L004F:BSR.S     L0051 
      MOVEA.L   L0071,A0
      CMPA.L    A0,A5 
      BLT.S     L004D 
      MOVEQ     #5,D7 
L0050:MOVEQ     #7,D0 
      BSR.S     L0051 
      DBF       D7,L0050
      MOVEQ     #$C,D0
      BSR.S     L0051 
      MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTS 
L0051:MOVE.W    D0,-(A7)
      PEA       $30000
      TRAP      #$D 
      ADDQ.L    #6,A7 
      RTS 
L0052:EORI.L    #$7770777,-$7DC0.W
      MOVEQ     #-1,D0
L0053:DBF       D0,L0053
      RTS 
L0054:MOVE.W    #7,-(A7) 	;CRAWCIN
      TRAP      #1
      ADDQ.L    #2,A7 
      MOVE.L    D0,-(A7)
      PEA       $BFFFF
      TRAP      #$D 
      ADDQ.L    #4,A7 
      BTST      #3,D0 
      BEQ.S     L0055 
      MOVE.L    (A7)+,D0
      EORI.W    #-$5556,D0
      RTS 
L0055:MOVE.L    (A7)+,D0
      RTS 
L0056:MOVE.W    D1,-(A7)
      PEA       $30002
      TRAP      #$D 
      ADDQ.L    #6,A7 
      RTS 
L0057:MOVEA.L   L0006(PC),A4
      MOVE.W    #$DBF,D0
L0058:MOVE.W    #0,(A4)+
      MOVE.W    #0,(A4)+
      MOVE.W    #0,(A4)+
      MOVE.W    #0,(A4)+
      DBF       D0,L0058
      LEA       L006D(PC),A6
      SF        L0076 
      BSR       L0034 
      LEA       L0064(PC),A6
      BSR       L0034 
      RTS 
L0059:LEA       L007F,A6
      CMPA.L    L0070,A5
      BLT.S     L005A 
      CMPA.L    L0071,A5
      BGE.S     L005A 
      SF        L0076 
      BRA.S     L005B 
L005A:ST        L0076 
L005B:TST.B     (A5)
      BEQ.S     L005C 
      MOVE.B    (A5)+,(A6)+ 
      CMPI.B    #$A,-1(A6)
      BNE.S     L005B 
      MOVE.B    #0,(A6)+
L005C:LEA       L007F,A6
      BSR       L0034 
      RTS 
L005D:LEA       L006C(PC),A6
      BSR       L0034 
      MOVEA.L   $44E.W,A0 
      LEA       2560(A0),A0 
      MOVE.W    #$D1F,D0
L005E:MOVE.W    #0,(A0)+
      MOVE.W    #0,(A0)+
      MOVE.W    #0,(A0)+
      MOVE.W    #0,(A0)+
      DBF       D0,L005E
      MOVEQ     #$14,D3 
      LSL.W     #2,D6 
L005F:LEA       L0081,A2
      MOVEA.L   0(A2,D6.W),A5 
      BSR.S     L0059 
      ADDQ.L    #4,D6 
      DBF       D3,L005F
      LSR.W     #2,D6 
      SUBQ.W    #1,D6 
      RTS 
L0060:DC.B      'DOC Disp'
      DC.B      'layer v3'
      DC.B      '.8 by @G'
      DC.B      'The Alie'
      DC.B      'n@H.  F1'
      DC.B      ':Start B'
      DC.B      'lock, F2'
      DC.B      ':End Blo'
      DC.B      'ck, F10:'
      DC.B      'Print Bl'
      DC.B      'ock.',$0D,$0D,$0D,$0D
      DC.B      $0D,$0D,$0D,$0D,$0D,$0D,$0D,$09 
      DC.B      $09,$09,$09,'  Pro' 
      DC.B      'cessing.'
      DC.B      '..  ',$0D,$00
L0061:DC.B      $04,'       ' 
      DC.B      '        '
      DC.B      ' [Shift]'
      DC.B      $02,':Forwar' 
      DC.B      'ds   Alt'
      DC.B      '-Q:Quit '
      DC.B      '  Alt-B:'
      DC.B      'Last lin'
      DC.B      'e       '
      DC.B      '        '
      DC.B      ' ',$00 
L0062:DC.B      $04,'[Shift]' 
      DC.B      $01,':Back  ' 
      DC.B      '[Shift]',$02 
      DC.B      ':forward'
      DC.B      's  Alt-Q'
      DC.B      ':Quit  A'
      DC.B      'lt-T:Fir'
      DC.B      'st line '
      DC.B      ' Alt-B:L'
      DC.B      'ast line'
      DC.B      ' ',$00 
L0063:DC.B      $04,'       ' 
      DC.B      '        '
      DC.B      '  [Shift'
      DC.B      ']',$01,':Back '
      DC.B      '   Alt-Q'
      DC.B      ':Quit   '
      DC.B      'Alt-T:Fi'
      DC.B      'rst line'
      DC.B      '        '
      DC.B      '        '
      DC.B      ' ',$00 
L0064:DC.B      $04,'       ' 
      DC.B      '        '
      DC.B      '    > Pr'
      DC.B      'ess any '
      DC.B      'key to e'
      DC.B      'xit this'
      DC.B      ' help sc'
      DC.B      'reen <  '
      DC.B      '        '
      DC.B      '        '
      DC.B      ' ',$00 
L0065:DC.B      $04,$07,'      '
      DC.B      '        '
      DC.B      '        '
      DC.B      '  Printi'
      DC.B      'ng docum'
      DC.B      'ent... p'
      DC.B      'lease wa'
      DC.B      'it.     '
      DC.B      '        '
      DC.B      '        '
      DC.B      '  ',$00
L0066:DC.B      $04,$07,'       ' 
      DC.B      '        '
      DC.B      ' Printer'
      DC.B      ' not res'
      DC.B      'ponding!'
      DC.B      ' Is it c'
      DC.B      'onnected'
      DC.B      '? Online'
      DC.B      '?       '
      DC.B      '        '
      DC.B      ' ',$00 
L0067:DC.B      $07,$05,'      '
      DC.B      '        '
      DC.B      '        '
      DC.B      '     Blo'
      DC.B      'ck START'
      DC.B      ' after b'
      DC.B      'lock END'
      DC.B      '?       '
      DC.B      '        '
      DC.B      '        '
      DC.B      '  ',$00
L0068:DC.B      $07,$06,'       ' 
      DC.B      '        '
      DC.B      '        '
      DC.B      '    Bloc'
      DC.B      'k END be'
      DC.B      'fore blo'
      DC.B      'ck START'
      DC.B      '?       '
      DC.B      '        '
      DC.B      '        '
      DC.B      ' ',$00 
L0069:DC.B      $07,$05,'      '
      DC.B      '        '
      DC.B      '        '
      DC.B      '       S'
      DC.B      'erial pr'
      DC.B      'inter se'
      DC.B      'lected. '
      DC.B      '        '
      DC.B      '        '
      DC.B      '        '
      DC.B      '  ',$00
L006A:DC.B      $07,$05,'       ' 
      DC.B      '        '
      DC.B      '        '
      DC.B      '     Par'
      DC.B      'allel pr'
      DC.B      'inter se'
      DC.B      'lected. '
      DC.B      '        '
      DC.B      '        '
      DC.B      '        '
      DC.B      ' ',$00 
L006B:DC.B      $0B,$00 
L006C:DC.B      $0E,$00 
L006D:DC.B      $0E,$07,$09,$09,'    '
      DC.B      ' @GThe P'
      DC.B      'ompey Pi'
      DC.B      'rates Do'
      DC.B      'c Displa'
      DC.B      'yer v3.8'
      DC.B      '@H',$0D,$0A,$0D,$0A,$09,' '
      DC.B      '  @4All '
      DC.B      'coding b'
      DC.B      'y The Al'
      DC.B      'ien!    '
      DC.B      ' Ripped '
      DC.B      'by Alche'
      DC.B      'my (1991'
      DC.B      ')',$0D 
      DC.B      $0A,$0D,$0A,$09,'HELP'
      DC.B      $09,$09,'-',$09,$09,$09,'  '
      DC.B      '  Displa'
      DC.B      'y this s'
      DC.B      'creen',$0D,$0A,$09 
      DC.B      'F1',$09,$09,'-',$09,'  ' 
      DC.B      '    Mark'
      DC.B      ' start o'
      DC.B      'f block '
      DC.B      'to be pr'
      DC.B      'inted',$0D,$0A,$09 
      DC.B      'F2',$09,$09,'-',$09,$09,'M'
      DC.B      'ark end '
      DC.B      'of block'
      DC.B      ' to be p'
      DC.B      'rinted',$0D,$0A
      DC.B      $09,'F8',$09,$09,'-',$09,$09
      DC.B      '   Enabl'
      DC.B      'e/disabl'
      DC.B      'e @Gbold'
      DC.B      '@H & @4i'
      DC.B      'talic@5',$0D 
      DC.B      $0A,$09,'F9',$09,$09,'-',$09
      DC.B      $09,$09,'    Se'
      DC.B      'lect pri'
      DC.B      'nter typ'
      DC.B      'e',$0D,$0A,$09,'F10',$09 
      DC.B      $09,'-',$09,$09,$09,'   ' 
      DC.B      '  Print '
      DC.B      'marked b'
      DC.B      'lock',$0D,$0A,$09,'C'
      DC.B      'ontrol +'
      DC.B      ' C',$09,'-',$09,$09,$09,$09
      DC.B      '  Invert'
      DC.B      ' colors',$0D 
      DC.B      $0A,$09,'Contro'
      DC.B      'l + F',$09,'-',$09 
      DC.B      $09,'      T' 
      DC.B      'oggle no'
      DC.B      'rmal/cus'
      DC.B      'tom font'
      DC.B      $0D,$0A,$09,'Alter' 
      DC.B      'nate + B'
      DC.B      $09,'-',$09,$09,$09,' Go' 
      DC.B      ' to last'
      DC.B      ' line of'
      DC.B      ' doc',$0D,$0A,$09,'A'
      DC.B      'lternate'
      DC.B      ' + T',$09,'-',$09,$09
      DC.B      $09,'Go to f' 
      DC.B      'irst lin'
      DC.B      'e of doc'
      DC.B      $0D,$0A,$09,'Shift' 
      DC.B      ' + ',$02,$09,'-',$09,$09 
      DC.B      $09,'       ' 
      DC.B      'Forward '
      DC.B      'one page'
      DC.B      $0D,$0A,$09,'Shift' 
      DC.B      ' + ',$01,$09,'-',$09,$09 
      DC.B      $09,$09,'  Back'
      DC.B      ' one pag'
      DC.B      'e',$0D,$0A,$09,$02,$09,$09,'-' 
      DC.B      $09,$09,$09,'     ' 
      DC.B      '  Forwar'
      DC.B      'd one li'
      DC.B      'ne',$0D,$0A,$09,$01,$09,$09
      DC.B      '-',$09,$09,$09,$09,'  B' 
      DC.B      'ack one '
      DC.B      'line',$0D,$0A,$09,'A'
      DC.B      'lternate'
      DC.B      ' + Q',$09,'-',$09,$09
      DC.B      $09,$09,$09,'   Qu' 
      DC.B      'it',$0D,$0A,$00,$00
L006E:DC.B      $00,$18,'<',$18,$18,$FF,$F8,$FF 
      DC.B      $01,'~',$18,$18,$F0,$F0,$05,$A0 
      DC.B      '|',$06,'||',$C6,'|||'
      DC.B      '||',$00,'x',$07,$F0,$11,$04
      DC.B      $00,$18,'f',$00,'(cx',$18 
      DC.B      $04,' ',$10,$00,$00,$00,$00,$02 
      DC.B      '<',$18,'<~',$0C,'~<~'
      DC.B      '<<',$00,$00,$06,$00,'`<' 
      DC.B      '<<|<|~~<'
      DC.B      'f<',$06,'f'
L006F:BRA.S     L006F 
      DC.B      'f<|<|<~f'
      DC.B      'f',$DB,'ff~',$1E,'@x'
      DC.B      $10,$00,$00,$00,'`',$00,$06,$00 
      DC.B      $1E,$00,'`',$18,$0C,'`0',$00
      DS.W      6 
      DC.B      $00,$0E,$18,'p',$00,$00,'xq'
      DC.B      $86,$FC,'<',$C3,'x',$F3,$C0,'~' 
      DC.B      '>~',$E9,$01,$98,'#',$E6,$0C
      DC.B      $E9,$DF,$FF,$FF,$EE,$90,'ff'
      DC.B      'f',$18,$1C,'f',$1C,$18,$9F,$0C 
      DC.B      $0C,$0C,'44',$00,$00,$00,$00
      DC.B      $00,$C6,$C6,$00,$1B,$D8,'44'
      DC.B      $02,$00,$18,$18,'6',$00,$00,'6' 
      DC.B      '6',$00,'6<<',$E9,$18,$18 
      DC.B      $00,$18,$00,$18,$18,'66',$00
      DC.B      '6',$00,'6',$00,'6',$18,'6',$00 
      DC.B      $00,'60',$00,$00,'6',$18,$18
      DC.B      $00,$FF,$00,$0E,$00,'f',$00,$1C 
      DC.B      $00,$00,$FE,$00,$00,$00,'<',$00 
      DC.B      $00,$1C,$0C,$00,'><',$00,$18
      DC.B      '0',$0C,$00,$18,$18,$00,'88'
      DC.B      $00,$00,'88x',$00,$00,'<' 
      DC.B      '$',$1C,'8',$81,$8F,$89,$03,$C3 
      DC.B      '<',$1C,$C0,$C0,$05,$A0,$C6,$06 
      DC.B      $06,$06,$C6,$C0,$C0,$06,$C6,$C6 
      DC.B      $00,'`',$0F,$F8,$0B,'(',$00,$18 
      DC.B      'fl~',$96,$CC,$18,$08,$10 
      DC.B      'T',$18,$00,$00,$00,$06,'f8'
      DC.B      'f',$0C,$1C,'``',$06,'ff' 
      DC.B      $18,$18,$0C,$00,'0fff'
      DC.B      'fbf``bf',$18 
      DC.B      $06,'l`',$DB,'vfff' 
      DC.B      'fb',$18,'ff',$DB,'ff'
      DC.B      $06,$18,'`',$18,'8',$00,$C0,$00 
      DC.B      '`',$00,$06,$00,'0',$00,'`',$00 
      DC.B      $00,'`0',$00,$00,$00,$00,$00
      DC.B      $00,$00,$18,$00,$00,$00,$00,$00 
      DC.B      $00,$18,$18,$18,'`',$18,'~',$F9 
      DC.B      $C6,$FE,'~',$C6,'~o',$E3,'~'
      DC.B      '|',$FE,'O',$03,$98,'#',$07,$0C 
      DC.B      'O',$C0,$00,$00,$C4,$F0,$00,$00 
      DC.B      $00,$18,':f6',$18,$98,$18 
      DC.B      $18,$18,'XX<<',$18,$00
      DC.B      $00,$CC,$CC,$18,'6lXX'
      DC.B      '<',$02,$18,$18,'6',$00,$00,'6' 
      DC.B      '6',$00,'6BBO',$18,$18
      DC.B      $00,$18,$00,$18,$18,'66',$00
      DC.B      '6',$00,'6',$00,'6',$18,'6',$00 
      DC.B      $00,'60',$00,$00,'6',$18,$18
      DC.B      $00,$FF,$00,$1B,$10,$F7,$00,'6' 
      DC.B      $FE,$00,'f',$1E,$00,$00,$18,'<' 
      DC.B      '<6',$18,$10,'pf~',$18
      DC.B      $18,$18,$0E,$18,$18,'2l|' 
      DC.B      $00,$00,'ll',$0C,$FE,$00,'f'
      DC.B      '$',$F6,'o',$BD,$89,$89,$06,$D3 
      DC.B      '<',$16,$FE,$DF,$05,$A0,$C6,$06 
      DC.B      $06,$06,$C6,$C0,$C0,$06,$C6,$C6 
      DC.B      '<x',$1F,$EC,$0D,$D8,$00,$18
      DC.B      'f',$FE,$A8,'la',$10,$18,$18
      DC.B      '8',$18,$00,$00,$00,$0C,'n',$18 
      DC.B      $06,$18,'<|`',$0C,'ff'
      DC.B      $18,$18,$18,'~',$18,$06,'nf'
      DC.B      'f`f```f',$18 
      DC.B      $06,'x`',$DB,'~fff' 
      DC.B      'fp',$18,'ff',$DB,'ff'
      DC.B      $0C,$18,'0',$18,'l',$00,'`<'
      DC.B      '|<><|>|',$18 
      DC.B      $0C,'f0',$FE,'|<|>' 
      DC.B      'l><ff',$DB,'ff'
      DC.B      '~',$18,$18,$18,$F2,$18,'f',$CD 
      DC.B      $EF,'f',$C0,$FC,'f',$DC,'g',$98 
      DC.B      '`',$E0,'I',$07,$98,'s',$07,$8C 
      DC.B      'I',$C1,$90,$11,$84,$90,'f<'
      DC.B      'f<0<f',$18,$D8,$00 
      DS.W      2 
      DC.B      $06,'f',$00,$00,$00,$D8,$D8,$00 
      DC.B      'l6',$00,$00,'f<',$18,$F8 
      DC.B      '6',$FE,$F8,$F6,'6',$FE,$F6,$99 
      DC.B      $B9,'I',$18,$18,$00,$18,$00,$18 
      DC.B      $1F,'67?',$F7,$FF,'7',$FF 
      DC.B      $F7,$FF,'6',$FF,$00,'6??' 
      DC.B      $00,'6',$FF,$18,$00,$FF,$00,'<' 
      DC.B      '8™vff',$FE,'08'
      DC.B      'l~<ffx8|'
      DC.B      '`f',$00,'~',$0C,'0',$1B,$18
      DC.B      $00,'L88',$00,$0F,'l',$18 
      DC.B      '8',$00,$00,$C3,$E7,$83,$C1,$A5 
      DC.B      $F9,$F9,$8C,$D3,'<',$10,$D8,$DB 
      DC.B      $0D,$B0,$00,$00,'||||'
      DC.B      '|',$00,'||',$06,'`',$18,$04
      DC.B      $06,'(',$00,$18,$00,'l|',$18
      DC.B      $CE,$00,$18,$18,$FE,'~',$00,'~' 
      DC.B      $00,$18,'v',$18,$0C,$0C,'l',$06 
      DC.B      '|',$18,'<>',$00,$00,'0',$00
      DC.B      $0C,$0C,'j~|`f|'
      DC.B      '|n~',$18,$06,'p`',$DB
      DC.B      '~f|f|<',$18,'f'
      DC.B      'f',$DB,'<<',$18,$18,$18,$18
      DC.B      $C6,$00,'0Ff`ff'
      DC.B      '0ff',$18,$0C,'l0',$DB
      DC.B      'ffffp`',$18,'f'
      DC.B      'f',$DB,'ff',$0C,'0',$18,$0C
      DC.B      $9E,'4n',$C6,$FF,'|',$F0,'x'
      DC.B      'n',$D8,$CD,$98,$FC,'|I',$0D
      DC.B      $98,'s',$E6,$CC,'I',$C2,'H#'
      DC.B      $04,$90,'fff`|',$18 
      DC.B      '|',$18,$DF,'8<f|f' 
      DC.B      '>f',$18,'>|66',$18 
      DC.B      $D8,$1B,'<<nn',$18,$18
      DC.B      '6l',$18,$06,'6',$06,$06,$A1
      DC.B      $A5,'I',$18,$18,$00,$18,$00,$18 
      DC.B      $18,'600',$00,$00,'0',$00 
      DC.B      $00,$00,'6',$00,$00,'600' 
      DC.B      $00,'6',$18,$18,$00,$FF,$00,'f' 
      DC.B      'l',$99,$DC,'|bl',$18,'l' 
      DC.B      'l',$18,'f~f',$DC,'T',$D6 
      DC.B      '~f~',$18,$18,$18,$1B,$18 
      DC.B      '~',$00,$00,$00,$00,$18,'l0'
      DC.B      $0C,$00,$00,$E7,$C3,$83,$C1,$A5 
      DC.B      'A',$81,$D8,$DB,'~',$10,$DE,$FF 
      DC.B      $0D,$B0,$C6,$06,$C0,$06,$06,$06 
      DC.B      $C6,$06,$C6,$06,'~~',$18,$04
      DC.B      $07,$D0,$00,$18,$00,'l*6' 
      DC.B      $CC,$00,$18,$18,'8',$18,$00,$00 
      DC.B      $00,'0f',$18,$18,$06,'~',$06
      DC.B      'f0f',$06,$18,$18,$18,$00 
      DC.B      $18,$18,'nff`f`'
      DC.B      '`ff',$18,$06,'x`',$DB
      DC.B      'nf`ff',$0E,$18,'f' 
      DC.B      'f',$DB,'f',$18,'0',$18,$0C,$18 
      DC.B      $00,$00,$00,'>f`f~' 
      DC.B      '0ff',$18,$0C,'x0',$DB
      DC.B      'ffff`<',$18,'f'
      DC.B      'f',$DB,'<f',$18,$18,$18,$18
      DC.B      $0C,'4',$FD,$86,$DB,'y',$E0,'0' 
      DC.B      $FC,$CF,$99,$9C,$F8,$1F,$00,$19 
      DC.B      $98,'s',$06,'l',$00,$C7,$E5,'F' 
      DC.B      $00,$00,'fff`0<'
      DC.B      'f',$18,$D8,$18,'fffv'
      DC.B      'ff00',$0C,'kn',$18 
      DC.B      'l6',$06,'fvv',$F8,$F8
      DC.B      $F6,'l',$F8,$F6,'6',$F6,$FE,$A1 
      DC.B      $B9,$00,$1F,$FF,$FF,$1F,$FF,$FF 
      DC.B      $1F,'7?7',$FF,$F7,'7',$FF 
      DC.B      $F7,$FF,$FF,$FF,$FF,'???' 
      DC.B      $7F,$FF,$FF,$F8,$1F,$FF,$FF,'f' 
      DC.B      $C6,$EF,$C8,'f`l0l' 
      DC.B      'l',$18,'fff',$CC,'T',$D6 
      DC.B      '`f',$00,$18,'0',$0C,$18,$D8
      DC.B      $00,'2',$00,$00,$18,$D8,'l|'
      DC.B      'x',$00,$00,'$f',$F6,'o',$BD
      DC.B      'Ap',$C3,$10,'p',$18,$1E 
      DC.B      $19,$98,$C6,$06,$C0,$06,$06,$06 
      DC.B      $C6,$06,$C6,$06,'f',$18,$10,$04 
      DC.B      '.',$10,$00,$00,$00,$FE,$FC,'i' 
      DC.B      $CC,$00,$08,$10,'T',$18,'0',$00 
      DC.B      $18,'`f',$18,'0f',$0C,'f' 
      DC.B      'f0f',$0C,$18,$18,$0C,'~' 
      DC.B      '0',$00,'`ffbf`'
      DC.B      '`ff',$18,'Fl`',$DB 
      DC.B      'ff`ffF',$18,'f'
      DC.B      'l',$DA,'f',$18,'`',$18,$06,$18 
      DC.B      $00,$00,$00,'ff`f`' 
      DC.B      '0>f',$18,$0C,'l0',$DB
      DC.B      'ffff`',$06,$18,'f' 
      DC.B      'd',$DA,'f>0',$18,$18,$18 
      DC.B      $00,'b',$F1,$C6,$E3,'c',$8C,'`' 
      DC.B      $F1,$8F,$BF,$CC,$E0,$C7,$00,'?' 
      DC.B      $98,'s',$06,'<',$00,$C8,$12,$8C 
      DC.B      $00,$00,'>ff<0',$18 
      DC.B      'f',$18,$D8,$18,'fffn'
      DC.B      '><`0',$0C,$C3,$D6,$18
      DC.B      '6l~fff',$18,$18
      DC.B      '6l',$18,'666',$00,$99
      DC.B      $A5,$00,$00,$00,$18,$18,$00,$18 
      DC.B      $18,'6',$00,'6',$00,'66',$00
      DC.B      '6',$00,$00,$18,'6',$00,$00,'0' 
      DC.B      'l6',$18,$00,$18,$FF,$FF,'<'
      DC.B      $82,'f',$DC,'f`lfl' 
      DC.B      'l',$18,'<f$',$EC,'8',$D6 
      DC.B      'pf~',$00,$00,$00,$18,$D8 
      DC.B      $18,'L',$00,$00,$18,'p',$00,$00 
      DC.B      $00,$00,$00,'$<',$1C,'8' 
      DC.B      $7F,' ',$C3,'8',$F0,$18,$1B
      DC.B      'yž|',$06,'||',$06,'|'
      DC.B      '|',$06,'||<',$1E,$1E,'<' 
      DC.B      '9',$E0,$00,$18,$00,'l(',$C6
      DC.B      'x',$00,$04,' ',$10,$00,'0',$00 
      DC.B      $18,'@<',$18,'~<',$0C,'<' 
      DC.B      '<0<8',$00,$10,$06,$00
      DC.B      '`',$18,'>f|<|~'
      DC.B      '`>f<<f~',$DB 
      DC.B      'f<`<f<',$18,'<'
      DC.B      'x',$FC,'f',$18,'~',$1E,$02,'x' 
      DC.B      $00,$FE,$00,'>|<><' 
      DC.B      '0Ff',$18,'Lf',$18,$DB
      DC.B      'f<|>`|',$0C,'>'
      DC.B      'x',$FC,'fF~',$0E,$18,'p' 
      DC.B      $00,'~',$C0,$FE,'a',$E3,$FC,'`' 
      DC.B      $C1,$86,$D1,$CC,'~',$FE,$00,'a' 
      DC.B      $98,'#',$06,$1C,$00,$C0,$00,$18 
      DC.B      $00,$03,$06,'<>',$18,'~',$18
      DC.B      '|',$18,$98,'<<>ff' 
      DC.B      $00,$00,'f0',$0C,$86,$9F,$18
      DC.B      $1B,$D8,'><<<',$18,$18
      DC.B      '6l',$18,'666',$00,'B'
      DC.B      'B',$00,$00,$00,$18,$18,$00,$18 
      DC.B      $18,'6',$00,'6',$00,'66',$00
      DC.B      '6',$00,$00,$18,'6',$00,$00,'0' 
      DC.B      'l6',$18,$00,$18,$FF,$FF,$D8
      DC.B      $00,$00,'v|`l',$FE,'8'
      DC.B      $7F,$18,$18,'<fx0|' 
      DC.B      '>f',$00,'~~~',$18,'p'
      DC.B      $18,$00,$00,$00,$00,'0',$00,$00 
      DC.B      $00,$00,$00,'<',$18,$18,$18,$FF 
      DC.B      $00,$FF,$00,'~',$10,'`',$00,$00 
      DC.B      'q',$8E,$00,$00,$00,$00,$00,$00 
      DS.W      3 
      DC.B      $17,'T8',$00,$00,$00,$00,$00
      DS.W      4 
      DC.B      ' ',$00,$00,$00,$00,$00,$00,$00 
      DS.W      14
      DC.B      $00,$06,$00,$00,$00,$00,$00,$00 
      DS.W      7 
      DC.B      $00,'<',$00,$00,'8',$00,$00,$00 
      DC.B      $00,$00,'`',$06,$00,$00,$00,$00 
      DC.B      $00,$00,$00,'<',$00,$00,$18,$00 
      DC.B      $00,$00,$C0,'<a',$C1,$F8,$C0
      DC.B      $C3,$C6,'a',$CC,'<<',$00,$C1
      DC.B      $9F,'#',$E6,$0C,$00,$FF,$FF,$BF 
      DC.B      $E0,$03,'|',$00,$00,$18,$00,$00 
      DC.B      '`',$18,$9F,$00,$00,$00,$00,$00 
      DC.B      '<<<',$00,$00,$0F,$06,$18 
      DS.W      2 
      DC.B      '@@',$18,$18,'6',$00,$18,'6'
      DC.B      '66',$00,'<<',$00,$00,$00 
      DC.B      $18,$18,$00,$18,$18,'6',$00,'6' 
      DC.B      $00,'66',$00,'6',$00,$00,$18
      DC.B      '6',$00,$00,'0l6',$18,$00 
      DC.B      $18,$FF,$00,'p',$00,$00,$00,'`' 
      DC.B      $F8,'H',$00,$00,$C0,$10,'<',$00 
      DC.B      $00,$00,'`',$10,$00,$00,$00,$00 
      DC.B      $00,$00,$18,$00,$00,$00,$00,$00 
      DS.W      3 
L0070:DC.L      L0072 
L0071:DC.L      L0073 
**************************************************
L0072		INCBIN A:\DOCDISPL.AY\READ_ME.DOC
**************************************************

L0073:DS.W      2 
L0074:DC.B      $00,$00 
L0075:DC.B      $00,$00 
L0076:DC.B      $00,$00 
L0077:DC.B      $00,$00 
L0078:DC.B      $00,$00 
L0079:DC.B      $00,$00 
L007A:DC.B      $00,$00,$00 
L007B:DC.B      $00 
L007C:DS.W      2 
L007D:DC.B      $00,$00 
L007E:DC.B      $00,$00 
L007F:DS.W      64
L0080:DS.W      14720 
L0081:DS.W	100
L0082:DS.W	100
ZUEND: END
