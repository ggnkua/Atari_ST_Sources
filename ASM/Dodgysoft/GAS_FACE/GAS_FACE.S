 TEXT 
Begin:
      DC.B      '#',$CF 
      DC.L      L0000 
      DC.B      'O',$F8,' ',$00,'#',$F9 
      DC.L      L00AE 
      DC.L      PALT1 
      DC.B      '#',$F9 
      DC.L      L00AF 
      DC.L      PALT2 
      DC.B      '#',$F9 
      DC.L      L00B0 
      DC.L      PALT3 
      DC.B      '#',$F9 
      DC.L      L00B1 
      DC.L      PALT4 
      DC.B      '#',$F9 
      DC.L      L00B2 
      DC.L      PALT5 
      DC.B      '#',$F9 
      DC.L      L00B3 
      DC.L      PALT6 
      DC.B      '#',$F9 
      DC.L      L00B4 
      DC.L      PALT7 
      DC.B      '#',$F9 
      DC.L      L00B5 
      DC.L      PALT8 
      DC.B      'Hz',$00,',?<',$00,'&'
      DC.B      'NN\O.y'
      DC.L      L0000 
      DC.B      'Bg/9'
      DC.L      L002F 
      DC.B      '/',$17,'?<',$00,$05,'NN' 
      DC.B      'O',$EF,$00,$0C,'B',$A7,'NA'
L0000:DCB.W     2,0 
      MOVE.W    #2,-(A7)
      TRAP      #$E 
      ADDQ.W    #2,A7 
      MOVE.L    D0,L002F
      MOVEM.L   FONTPALT,D0-D7		;MOVE FONT PALETTE INTO DATA REGISTERS 
      MOVEM.L   D0-D7,$FFFF8240.W 	;MOVE D0 TO D7 INTO PALETTE MEMORY
      MOVE.B    $484.W,L002E
      CLR.B     $484.W
      MOVE.L    #1,D0 
      BSR       MUSIC 
      CLR.W     -(A7) 
      PEA       $78018
      MOVE.L    (A7),-(A7)
      MOVE.W    #5,-(A7)
      TRAP      #$E 
      LEA       12(A7),A7 
      LEA       $70000,A0 
L0001:CLR.W     (A0)+ 
      CMPA.L    #$80000,A0
      BNE.B     L0001 
      BSR       L0032 
      BSR       L003F 
      MOVE.L    #L001B,L001A
      MOVE.L    $70.W,-(A7) 
      MOVE.L    #L0017,$70.W
      LEA       TEXT1,A0
      BSR       L0005 
      MOVE.L    #$FA,D1 
      BSR       L0006 
      LEA       TEXT2,A0
      BSR       L0005 
      MOVE.L    #$96,D1 
      BSR       L0006 
      LEA       TEXT3,A0
      BSR       L0005 
      MOVE.L    #$96,D1 
      BSR       L0006 
      LEA       TEXT4,A0
      BSR       L0005 
      MOVE.L    #$96,D1 
      BSR       L0006 
      LEA       TEXT5,A0
      BSR       L0005 
      MOVE.L    #L004A,L0045
L0002:MOVE.W    #8,-(A7)
      TRAP      #1
      ADDQ.W    #2,A7 
      CMP.B     #$30,D0 
      BNE.B     L0003 
      BCHG      #1,$FFFF820A.W
L0003:CMP.B     #$20,D0 
      BNE.B     L0002 
      MOVE.L    (A7)+,$70.W 
      BSR       L002D 
      MOVE.B    L002E,$484.W
      LEA       $FFFF8240.W,A0
      CLR.W     (A0)+ 
      MOVEQ     #$E,D0
L0004:MOVE.W    #$777,(A0)+ 
      DBF       D0,L0004
      RTS 
L0005:MOVEA.L   #$70000,A1
      BSR       L0029 
      BSR       L0021 
      RTS 
L0006:MOVE.W    L001D,D0
L0007:CMP.W     L001D,D0
      BEQ.B     L0007 
      DBF       D1,L0006
      RTS 


FONTHEADER:DC.B      $00,$00 
PALT1:DCB.W     2,0 
PALT2:DCB.W     2,0 
PALT3:DCB.W     2,0 
PALT4:DCB.W     2,0 
PALT5:DCB.W     2,0 
PALT6:DCB.W     2,0 
PALT7:DCB.W     2,0 
PALT8:DCB.W     2,0 

L0011:MOVE.W    D0,FONTHEADER
      TST.W     D0
      BEQ       L0013 
      CMP.W     #$F,D0
      BLE       L0012 
      MOVE.W    #$F,D0
L0012:MOVE.L    PALT1,(A5)
      MOVE.L    PALT2,4(A5) 
      MOVE.L    PALT3,8(A5) 
      MOVE.L    PALT4,12(A5)
      MOVE.L    PALT5,160(A5) 
      MOVE.L    PALT6,164(A5) 
      MOVE.L    PALT7,168(A5) 
      MOVE.L    PALT8,172(A5) 
      LEA       -1760(A5),A5
      DBF       D0,L0012
L0013:MOVE.W    #$F,D5
      SUB.W     FONTHEADER,D5
      BMI       L0015 
L0014:CLR.L     (A5)
      CLR.L     4(A5) 
      CLR.L     8(A5) 
      CLR.L     12(A5)
      CLR.L     160(A5) 
      CLR.L     164(A5) 
      CLR.L     168(A5) 
      CLR.L     172(A5) 
      LEA       -1760(A5),A5
      DBF       D5,L0014
L0015:RTS 
L0016:CLR.W     D0
      MOVE.B    #9,$FF8800.L
      MOVE.B    $FF8800.L,D0
      LEA       $7EE00,A5 
      JSR       L0011 
      CLR.W     D0
      MOVE.B    #$A,$FF8800.L 
      MOVE.B    $FF8800.L,D0
      LEA       $7EE90,A5 
      JSR       L0011 
      RTS 
L0017:MOVEM.L   A0-A6/D0-D7,-(A7) 
      MOVE      SR,-(A7)
      MOVE      #$2700,SR 
      ADDQ.W    #1,L001D
      BSR       PLAYROUT 
      BSR       L0016 
      BSR       L0040 
      MOVE      (A7)+,SR
      NEG.W     L001C 
      TST.W     L001C 
      BMI       L0019 
      MOVEA.L   L001A,A0
      MOVE.W    $FFFF8252.L,$FFFF8250.L 
      MOVE.W    $FFFF8254.L,$FFFF8252.L 
      MOVE.W    $FFFF8256.L,$FFFF8254.L 
      MOVE.W    $FFFF8258.L,$FFFF8256.L 
      MOVE.W    $FFFF825A.L,$FFFF8258.L 
      MOVE.W    $FFFF825C.L,$FFFF825A.L 
      MOVE.W    $FFFF825E.L,$FFFF825C.L 
      MOVE.W    (A0),$FFFF825E.L
      ADDA.L    #2,A0 
      CMPA.L    #L001C,A0 
      BNE       L0018 
      MOVEA.L   #L001B,A0 
L0018:MOVE.L    A0,L001A
L0019:MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTE 
L001A:DCB.W     2,0 
L001B:DC.B      $00,$07,$00,$06,$00,$05,$00,$04 
      DC.B      $00,$03,$00,$02,$00,$01,$00,$10 
      DC.B      $00,' ',$00,'0',$00,'@',$00,'P' 
      DC.B      $00,'`',$00,'p',$00,'q',$00,'r' 
      DC.B      $00,'s',$00,'t',$00,'u',$00,'v' 
      DC.B      $00,'w',$07,'q',$07,'q',$07,'s' 
      DC.B      $07,'t',$07,'u',$07,'v',$07,'w' 
      DC.B      $06,'g',$05,'W',$04,'G',$03,'7' 
      DC.B      $02,$27,$01,$17 
L001C:DC.B      $00,$01 
L001D:DC.B      $00,$00 
L001E:DC.B      $00,$00 
L001F:DC.B      $00,$00 
L0020:DCB.W     2,0 
L0021:MOVE.W    #1,L001E
      MOVE.L    #$6680,L0020
L0022:MOVE.W    L001E,L001F 
      LEA       $70000,A5 
      LEA       $78018,A6 
      ADDA.L    L0020,A5
      MOVE.W    L001D,D0
L0023:CMP.W     L001D,D0
      BEQ.B     L0023 
L0024:MOVEM.L   (A5)+,A0-A4/D0-D7 
      MOVEM.L   A0-A4/D0-D7,(A6)
      MOVEM.L   (A5)+,A0-A4/D0-D7 
      MOVEM.L   A0-A4/D0-D7,52(A6)
      MOVE.L    (A5),104(A6)
      MOVE.L    4(A5),108(A6) 
      LEA       56(A5),A5 
      LEA       160(A6),A6
      SUBQ.W    #1,L001F
      BNE.B     L0024 
      SUBI.L    #$A0,L0020
      ADDQ.W    #1,L001E
      CMPI.W    #$B4,L001E
      BNE.B     L0022 
      LEA       $70000,A0 
      MOVE.L    #$1F40,D0 
L0025:CLR.L     (A0)+ 
      DBF       D0,L0025
      RTS 
L0026:DCB.W     2,0 
L0027:DCB.W     2,0 
L0028:RTS 
L0029:MOVE.L    A1,L0026
      MOVE.L    A1,L0027
L002A:TST.B     (A0)
      BMI.B     L0028 
      CLR.L     D0
      MOVE.B    (A0)+,D0
      CMP.B     #$D,D0
      BNE.B     L002B 
      MOVE.L    L0027,L0026 
      ADDI.L    #$960,L0026 
      ADDI.L    #$960,L0027 
      BRA.B     L002A 
L002B:SUBI.B    #$20,D0 
      ASL.W     #2,D0 
      LEA       L0031,A6
      MOVEA.L   0(A6,D0.W),A5 
      ADDA.L    #FONTDATA,A5 
      MOVEA.L   L0026,A6
      MOVEQ     #$F,D0
L002C:MOVE.L    (A5),(A6) 
      MOVE.W    4(A5),4(A6) 
      LEA       160(A5),A5
      LEA       160(A6),A6
      DBF       D0,L002C
      ADDQ.L    #8,L0026
      BRA.B     L002A 
L002D:MOVE.L    #$8080000,$FFFF8800.W 
      MOVE.L    #$9090000,$FFFF8800.W 
      MOVE.L    #$A0A0000,$FFFF8800.W 
      RTS 
      DCB.W     2,0 
L002E:DCB.W     17,0
L002F:DCB.W     2,0 
L0030:DCB.W     2,0 
L0031:DCB.W     126,0 
L0032:MOVEQ     #$1F,D0 
      LEA       L0031(PC),A3
L0033:ADDQ.L    #1,D0 
      MOVE.L    D0,D1 
      BSR.B     L0034 
      SUBI.L    #$20,D1 
      ASL.W     #4,D1 
      ADD.L     L0030,D1
      MOVE.L    D1,(A3)+
      CMP.L     #$5E,D0 
      BNE.B     L0033 
      RTS 
L0034:CMP.B     #$52,D1 
      BLT.B     L0035 
      MOVE.L    #$60E0,L0030
      RTS 
L0035:CMP.B     #$48,D1 
      BLT.B     L0036 
      MOVE.L    #$4D80,L0030
      RTS 
L0036:CMP.B     #$3E,D1 
      BLT.B     L0037 
      MOVE.L    #$3A20,L0030
      RTS 
L0037:CMP.B     #$34,D1 
      BLT.B     L0038 
      MOVE.L    #$26C0,L0030
      RTS 
L0038:CMP.B     #$2A,D1 
      BLT.B     L0039 
      MOVE.L    #$1360,L0030
      RTS 
L0039:CLR.L     L0030 
      RTS 

TEXT1:DC.B      '<><><><><><><>',$0D
      DC.B      '>            <',$0D
      DC.B      '< AUTOMATION >',$0D
      DC.B      '>            <',$0D
      DC.B      '<   COMPACT  >',$0D
      DC.B      '>    DISK    <',$0D
      DC.B      '<            >',$0D
      DC.B      '>   NUMBER   <',$0D 
      DC.B      '<   479.     >',$0D
      DC.B      '>            <',$0D
      DC.B      '<><><><><><><>',$0D,$FF

TEXT2:DC.B      '<><><><><><><>',$0D
      DC.B	'>            <',$0D
      DC.B	'<   HEROS    >',$0D
      DC.B      '>   OF THE   <',$0D
      DC.B	'<   LANCE.   >',$0D
      DC.B	'>            <',$0D
      DC.B	'<    ONE     >',$0D
      DC.B	'>    DISK    <',$0D 
      DC.B      '<   VERSION  >',$0D
      DC.B      '>            <',$0D
      DC.B      '<><><><><><><>',$0D,$FF

TEXT3:DC.B      '<><><><><><><>',$0D
      DC.B      '>            <',$0D
      DC.B      '<  HACK AND  >',$0D
      DC.B      '>  PACK BY:  <',$0D
      DC.B      '<            >',$0D
      DC.B	'> SHAREZ JEK <',$0D
      DC.B      '<            >',$0D
      DC.B      '> (GOODAY    <',$0D 
      DC.B      '<     BRUCE) >',$0D
      DC.B      '>            <',$0D
      DC.B      '<><><><><><><>',$0D,$FF

TEXT4:DC.B      '<><><><>'
      DC.B      '<><><>',$0D,'>'
      DC.B      '        '
      DC.B      '    <',$0D,'< '
      DC.B      '  CODING'
      DC.B      '   >',$0D,'>  '
      DC.B      '   BY:  '
      DC.B      '  <',$0D,'<  T'
      DC.B      'HE LAW! '
      DC.B      ' >',$0D,'>    '
      DC.B      '        '
      DC.B      '<',$0D,'<    I'
      DC.B      'DEA    >'
      DC.B      $0D,'>     B' 
      DC.B      'Y:    <',$0D 
      DC.B      '< THE FL'
      DC.B      'AVE! >',$0D,'>'
      DC.B      '        '
      DC.B      '    <',$0D,'<>'
      DC.B      '<><><><>'
      DC.B      '<><>',$0D,$FF
TEXT5:DC.B      '<><><><>'
      DC.B      '<><><>',$0D,'>'
      DC.B      '        '
      DC.B      '    <',$0D,'< '
      DC.B      'HIT SPAC'
      DC.B      'E! >',$0D,'>  '
      DC.B      '        '
      DC.B      '  <',$0D,'<   '
      DC.B      ' AND    '
      DC.B      ' >',$0D,'>    '
      DC.B      '        '
      DC.B      '<',$0D,'<  ENJ'
      DC.B      'OY...! >'
      DC.B      $0D,'>      ' 
      DC.B      '      <',$0D 
      DC.B      '< THE FL'
      DC.B      'AVE! >',$0D,'>'
      DC.B      '        '
      DC.B      '    <',$0D,'<>'
      DC.B      '<><><><>'
      DC.B      '<><>',$0D,$FF
L003F:MOVE.L    #L0049,L0045
      MOVE.L    #FONTDATA,L0048
      MOVE.L    #$7F300,L0047 
      RTS 
L0040:SUBQ.W    #1,L0044
      BNE       L0042 
      MOVE.W    #2,L0044
      MOVEQ     #0,D1 
      MOVEA.L   L0045,A0
      MOVE.B    (A0),D1 
      SUBI.B    #$20,D1 
      CMP.B     #$DF,D1 
      BNE.B     L0041 
      CLR.B     D1
      MOVE.L    #L004A,L0045
L0041:ADDQ.L    #1,L0045
      ASL.W     #2,D1 
      LEA       L0031(PC),A3
      MOVE.L    0(A3,D1.W),D1 
      MOVEA.L   L0048,A5
      ADDA.L    D1,A5 
      LEA       L0046(PC),A4
      MOVEM.L   (A5),D4-D7
      MOVEM.L   D4-D7,(A4)
      MOVEM.L   160(A5),D4-D7 
      MOVEM.L   D4-D7,160(A4) 
      MOVEM.L   320(A5),D4-D7 
      MOVEM.L   D4-D7,320(A4) 
      MOVEM.L   480(A5),D4-D7 
      MOVEM.L   D4-D7,480(A4) 
      LEA       640(A5),A5
      LEA       640(A4),A4
      MOVEM.L   (A5),D4-D7
      MOVEM.L   D4-D7,(A4)
      MOVEM.L   160(A5),D4-D7 
      MOVEM.L   D4-D7,160(A4) 
      MOVEM.L   320(A5),D4-D7 
      MOVEM.L   D4-D7,320(A4) 
      MOVEM.L   480(A5),D4-D7 
      MOVEM.L   D4-D7,480(A4) 
      LEA       640(A5),A5
      LEA       640(A4),A4
      MOVEM.L   (A5),D4-D7
      MOVEM.L   D4-D7,(A4)
      MOVEM.L   160(A5),D4-D7 
      MOVEM.L   D4-D7,160(A4) 
      MOVEM.L   320(A5),D4-D7 
      MOVEM.L   D4-D7,320(A4) 
      MOVEM.L   480(A5),D4-D7 
      MOVEM.L   D4-D7,480(A4) 
      LEA       640(A5),A5
      LEA       640(A4),A4
      MOVEM.L   (A5),D4-D7
      MOVEM.L   D4-D7,(A4)
      MOVEM.L   160(A5),D4-D7 
      MOVEM.L   D4-D7,160(A4) 
      MOVEM.L   320(A5),D4-D7 
      MOVEM.L   D4-D7,320(A4) 
      MOVEM.L   480(A5),D4-D7 
      MOVEM.L   D4-D7,480(A4) 
      LEA       640(A5),A5
      LEA       640(A4),A4
      MOVEM.L   (A5),D4-D7
      MOVEM.L   D4-D7,(A4)
      MOVEM.L   160(A5),D4-D7 
      MOVEM.L   D4-D7,160(A4) 
      MOVEM.L   320(A5),D4-D7 
      MOVEM.L   D4-D7,320(A4) 
      MOVEM.L   480(A5),D4-D7 
      MOVEM.L   D4-D7,480(A4) 
      LEA       640(A5),A5
      LEA       640(A4),A4
L0042:MOVEA.L   L0047,A1
      LEA       L0046(PC),A3
      MOVEQ     #$14,D6 
L0043:MOVEP.L   1(A1),D0
      MOVEP.L   D0,0(A1)
      MOVEP.L   8(A1),D0
      MOVEP.L   D0,1(A1)
      MOVEP.L   9(A1),D0
      MOVEP.L   D0,8(A1)
      MOVEP.L   16(A1),D0 
      MOVEP.L   D0,9(A1)
      MOVEP.L   17(A1),D0 
      MOVEP.L   D0,16(A1) 
      MOVEP.L   24(A1),D0 
      MOVEP.L   D0,17(A1) 
      MOVEP.L   25(A1),D0 
      MOVEP.L   D0,24(A1) 
      MOVEP.L   32(A1),D0 
      MOVEP.L   D0,25(A1) 
      MOVEP.L   33(A1),D0 
      MOVEP.L   D0,32(A1) 
      MOVEP.L   40(A1),D0 
      MOVEP.L   D0,33(A1) 
      MOVEP.L   41(A1),D0 
      MOVEP.L   D0,40(A1) 
      MOVEP.L   48(A1),D0 
      MOVEP.L   D0,41(A1) 
      MOVEP.L   49(A1),D0 
      MOVEP.L   D0,48(A1) 
      MOVEP.L   56(A1),D0 
      MOVEP.L   D0,49(A1) 
      MOVEP.L   57(A1),D0 
      MOVEP.L   D0,56(A1) 
      MOVEP.L   64(A1),D0 
      MOVEP.L   D0,57(A1) 
      MOVEP.L   65(A1),D0 
      MOVEP.L   D0,64(A1) 
      MOVEP.L   72(A1),D0 
      MOVEP.L   D0,65(A1) 
      MOVEP.L   73(A1),D0 
      MOVEP.L   D0,72(A1) 
      MOVEP.L   80(A1),D0 
      MOVEP.L   D0,73(A1) 
      MOVEP.L   81(A1),D0 
      MOVEP.L   D0,80(A1) 
      MOVEP.L   88(A1),D0 
      MOVEP.L   D0,81(A1) 
      MOVEP.L   89(A1),D0 
      MOVEP.L   D0,88(A1) 
      MOVEP.L   96(A1),D0 
      MOVEP.L   D0,89(A1) 
      MOVEP.L   97(A1),D0 
      MOVEP.L   D0,96(A1) 
      MOVEP.L   104(A1),D0
      MOVEP.L   D0,97(A1) 
      MOVEP.L   105(A1),D0
      MOVEP.L   D0,104(A1)
      MOVEP.L   112(A1),D0
      MOVEP.L   D0,105(A1)
      MOVEP.L   113(A1),D0
      MOVEP.L   D0,112(A1)
      MOVEP.L   120(A1),D0
      MOVEP.L   D0,113(A1)
      MOVEP.L   121(A1),D0
      MOVEP.L   D0,120(A1)
      MOVEP.L   128(A1),D0
      MOVEP.L   D0,121(A1)
      MOVEP.L   129(A1),D0
      MOVEP.L   D0,128(A1)
      MOVEP.L   136(A1),D0
      MOVEP.L   D0,129(A1)
      MOVEP.L   137(A1),D0
      MOVEP.L   D0,136(A1)
      MOVEP.L   144(A1),D0
      MOVEP.L   D0,137(A1)
      MOVEP.L   145(A1),D0
      MOVEP.L   D0,144(A1)
      MOVEP.L   152(A1),D0
      MOVEP.L   D0,145(A1)
      MOVEP.L   153(A1),D0
      MOVEP.L   D0,152(A1)
      MOVEP.L   0(A3),D0
      MOVEP.L   D0,153(A1)
      LEA       160(A3),A3
      LEA       160(A1),A1
      SUBQ.W    #1,D6 
      BNE       L0043 
      LEA       L0046(PC),A1
      MOVEP.L   1(A1),D0
      MOVEP.L   D0,0(A1)
      MOVEP.L   8(A1),D0
      MOVEP.L   D0,1(A1)
      MOVEP.L   9(A1),D0
      MOVEP.L   D0,8(A1)
      MOVEP.L   16(A1),D0 
      MOVEP.L   D0,9(A1)
      MOVEP.L   161(A1),D0
      MOVEP.L   D0,160(A1)
      MOVEP.L   168(A1),D0
      MOVEP.L   D0,161(A1)
      MOVEP.L   169(A1),D0
      MOVEP.L   D0,168(A1)
      MOVEP.L   176(A1),D0
      MOVEP.L   D0,169(A1)
      MOVEP.L   321(A1),D0
      MOVEP.L   D0,320(A1)
      MOVEP.L   328(A1),D0
      MOVEP.L   D0,321(A1)
      MOVEP.L   329(A1),D0
      MOVEP.L   D0,328(A1)
      MOVEP.L   336(A1),D0
      MOVEP.L   D0,329(A1)
      MOVEP.L   481(A1),D0
      MOVEP.L   D0,480(A1)
      MOVEP.L   488(A1),D0
      MOVEP.L   D0,481(A1)
      MOVEP.L   489(A1),D0
      MOVEP.L   D0,488(A1)
      MOVEP.L   496(A1),D0
      MOVEP.L   D0,489(A1)
      MOVEP.L   641(A1),D0
      MOVEP.L   D0,640(A1)
      MOVEP.L   648(A1),D0
      MOVEP.L   D0,641(A1)
      MOVEP.L   649(A1),D0
      MOVEP.L   D0,648(A1)
      MOVEP.L   656(A1),D0
      MOVEP.L   D0,649(A1)
      MOVEP.L   801(A1),D0
      MOVEP.L   D0,800(A1)
      MOVEP.L   808(A1),D0
      MOVEP.L   D0,801(A1)
      MOVEP.L   809(A1),D0
      MOVEP.L   D0,808(A1)
      MOVEP.L   816(A1),D0
      MOVEP.L   D0,809(A1)
      MOVEP.L   961(A1),D0
      MOVEP.L   D0,960(A1)
      MOVEP.L   968(A1),D0
      MOVEP.L   D0,961(A1)
      MOVEP.L   969(A1),D0
      MOVEP.L   D0,968(A1)
      MOVEP.L   976(A1),D0
      MOVEP.L   D0,969(A1)
      MOVEP.L   1121(A1),D0 
      MOVEP.L   D0,1120(A1) 
      MOVEP.L   1128(A1),D0 
      MOVEP.L   D0,1121(A1) 
      MOVEP.L   1129(A1),D0 
      MOVEP.L   D0,1128(A1) 
      MOVEP.L   1136(A1),D0 
      MOVEP.L   D0,1129(A1) 
      MOVEP.L   1281(A1),D0 
      MOVEP.L   D0,1280(A1) 
      MOVEP.L   1288(A1),D0 
      MOVEP.L   D0,1281(A1) 
      MOVEP.L   1289(A1),D0 
      MOVEP.L   D0,1288(A1) 
      MOVEP.L   1296(A1),D0 
      MOVEP.L   D0,1289(A1) 
      MOVEP.L   1441(A1),D0 
      MOVEP.L   D0,1440(A1) 
      MOVEP.L   1448(A1),D0 
      MOVEP.L   D0,1441(A1) 
      MOVEP.L   1449(A1),D0 
      MOVEP.L   D0,1448(A1) 
      MOVEP.L   1456(A1),D0 
      MOVEP.L   D0,1449(A1) 
      MOVEP.L   1601(A1),D0 
      MOVEP.L   D0,1600(A1) 
      MOVEP.L   1608(A1),D0 
      MOVEP.L   D0,1601(A1) 
      MOVEP.L   1609(A1),D0 
      MOVEP.L   D0,1608(A1) 
      MOVEP.L   1616(A1),D0 
      MOVEP.L   D0,1609(A1) 
      MOVEP.L   1761(A1),D0 
      MOVEP.L   D0,1760(A1) 
      MOVEP.L   1768(A1),D0 
      MOVEP.L   D0,1761(A1) 
      MOVEP.L   1769(A1),D0 
      MOVEP.L   D0,1768(A1) 
      MOVEP.L   1776(A1),D0 
      MOVEP.L   D0,1769(A1) 
      MOVEP.L   1921(A1),D0 
      MOVEP.L   D0,1920(A1) 
      MOVEP.L   1928(A1),D0 
      MOVEP.L   D0,1921(A1) 
      MOVEP.L   1929(A1),D0 
      MOVEP.L   D0,1928(A1) 
      MOVEP.L   1936(A1),D0 
      MOVEP.L   D0,1929(A1) 
      MOVEP.L   2081(A1),D0 
      MOVEP.L   D0,2080(A1) 
      MOVEP.L   2088(A1),D0 
      MOVEP.L   D0,2081(A1) 
      MOVEP.L   2089(A1),D0 
      MOVEP.L   D0,2088(A1) 
      MOVEP.L   2096(A1),D0 
      MOVEP.L   D0,2089(A1) 
      MOVEP.L   2241(A1),D0 
      MOVEP.L   D0,2240(A1) 
      MOVEP.L   2248(A1),D0 
      MOVEP.L   D0,2241(A1) 
      MOVEP.L   2249(A1),D0 
      MOVEP.L   D0,2248(A1) 
      MOVEP.L   2256(A1),D0 
      MOVEP.L   D0,2249(A1) 
      MOVEP.L   2401(A1),D0 
      MOVEP.L   D0,2400(A1) 
      MOVEP.L   2408(A1),D0 
      MOVEP.L   D0,2401(A1) 
      MOVEP.L   2409(A1),D0 
      MOVEP.L   D0,2408(A1) 
      MOVEP.L   2416(A1),D0 
      MOVEP.L   D0,2409(A1) 
      MOVEP.L   2561(A1),D0 
      MOVEP.L   D0,2560(A1) 
      MOVEP.L   2568(A1),D0 
      MOVEP.L   D0,2561(A1) 
      MOVEP.L   2569(A1),D0 
      MOVEP.L   D0,2568(A1) 
      MOVEP.L   2576(A1),D0 
      MOVEP.L   D0,2569(A1) 
      MOVEP.L   2721(A1),D0 
      MOVEP.L   D0,2720(A1) 
      MOVEP.L   2728(A1),D0 
      MOVEP.L   D0,2721(A1) 
      MOVEP.L   2729(A1),D0 
      MOVEP.L   D0,2728(A1) 
      MOVEP.L   2736(A1),D0 
      MOVEP.L   D0,2729(A1) 
      MOVEP.L   2881(A1),D0 
      MOVEP.L   D0,2880(A1) 
      MOVEP.L   2888(A1),D0 
      MOVEP.L   D0,2881(A1) 
      MOVEP.L   2889(A1),D0 
      MOVEP.L   D0,2888(A1) 
      MOVEP.L   2896(A1),D0 
      MOVEP.L   D0,2889(A1) 
      MOVEP.L   3041(A1),D0 
      MOVEP.L   D0,3040(A1) 
      MOVEP.L   3048(A1),D0 
      MOVEP.L   D0,3041(A1) 
      MOVEP.L   3049(A1),D0 
      MOVEP.L   D0,3048(A1) 
      MOVEP.L   3056(A1),D0 
      MOVEP.L   D0,3049(A1) 
      RTS 
L0044:DC.B      $00,$01 
L0045:DCB.W     2,0 
L0046:DCB.W     1600,0
L0047:DCB.W     2,0 
L0048:DCB.W     130,0 

L0049:DC.B      ' NEON LIGHTS MODS DISK ONE!!!!                       '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '

L004A:DC.B      ' HELLO DUDES, WELCOME.........        '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      ' '
      DC.B      $FF

MUSIC: INCBIN A:\JOCHEN.MUS
PLAYROUT: EQU MUSIC+8
      
FONTPALT: INCBIN 'A:\FONT.PI1"
FONTDATA: EQU FONTPALT+34

L00AE:DC.B      $19,$99,$07,$87 
L00AF:DC.B      $00,$7F,$FF,$FF 
L00B0:DC.B      $CC,$CC,$F0,$F0 
L00B1:DC.B      $FF,$00,$FF,$FF,$00,$00,$00,$00 
      DCB.W     70,0
L00B2:DC.B      '33',$0F,$0F
L00B3:DC.B      $00,$FF,$FF,$FF 
L00B4:DC.B      $E6,'f',$F8,'x' 
L00B5:DC.B      $FF,$80,$FF,$FF,$00,$00,$00,$00 
      DCB.W     71,0
      DC.B      $00,$04,$00,$08,$00,$0C,$00,$03 
      DC.B      $00,$07,$00,$0B,$00,$0F,$00,$01 
      DC.B      $00,$01,$00,$01,$00,$01,$00,$80 
      DC.B      $00,'T',$00,'*',$00,$00 
ZUEND: END
