 TEXT 
Begin:
L0000:PEA       L0018(PC) 
      MOVE.W    #9,-(A7)
      TRAP      #1
      ADDQ.L    #6,A7 
L0001:MOVE.W    #7,-(A7)
      TRAP      #1
      ADDQ.L    #4,A7 
      TST.W     D0
      BEQ.S     L0001 
      CMP.W     #$51,D0 
      BEQ.S     L0006 
      CMP.W     #$71,D0 
      BEQ.S     L0006 
      CMP.W     #$43,D0 
      BEQ.S     L0002 
      CMP.W     #$63,D0 
      BEQ.S     L0002 
      CMP.W     #$44,D0 
      BEQ.S     L0003 
      CMP.W     #$64,D0 
      BEQ.S     L0003 
      BRA.S     L0000 
L0002:MOVE.W    #1,L001A
      BRA.S     L0004 
L0003:MOVE.W    #0,L001A
L0004:MOVE.W    #8,D6 
      BSR.S     L0007 
      LEA       L001B(PC),A6
      MOVE.W    #$601C,(A6) 
      MOVE.B    #$49,3(A6)
      MOVE.L    #$424D2020,4(A6)
      ADDA.L    #$1E,A6 
      LEA       L000A(PC),A5
      LEA       L0018(PC),A4
      SUBA.L    A5,A4 
      MOVE.L    A4,D3 
      SUBQ.L    #1,D3 
L0005:MOVE.B    (A5)+,(A6)+ 
      DBF       D3,L0005
      BSR.S     L0008 
      MOVE.W    #9,D6 
      BSR.S     L0007 
      BRA       L0000 
L0006:CLR.W     -(A7) 
      TRAP      #1
L0007:MOVE.W    #1,-(A7)
      CLR.W     -(A7) 
      CLR.W     -(A7) 
      MOVE.W    #1,-(A7)
      CLR.W     -(A7) 
      CLR.L     -(A7) 
      PEA       L001B(PC) 
      MOVE.W    D6,-(A7)
      TRAP      #$E 
      ADDA.L    #$14,A7 
      TST.W     D0
      BMI.S     L0009 
      RTS 
L0008:MOVE.W    L001A(PC),-(A7) 
      MOVE.W    #-1,-(A7) 
      MOVE.L    #-1,-(A7) 
      PEA       L001B(PC) 
      MOVE.W    #$12,-(A7)
      TRAP      #$E 
      ADDA.L    #$E,A7
      RTS 
L0009:PEA       L0019(PC) 
      MOVE.W    #9,-(A7)
      TRAP      #1
      ADDQ.L    #6,A7 
      MOVE.W    #7,-(A7)
      TRAP      #1
      ADDQ.L    #4,A7 
      BRA       L0000 
L000A:LEA       -$7DC0.w,A6 
      MOVE.W    #$777,30(A6)
      LEA       L0013(PC),A0
      BSR       L0012 
      MOVEA.L   $42E.w,A0 
      CMPA.L    #$3FFFFC,A0 
      BLE.S     L000B 
      LEA       -4(A0),A0 
L000B:MOVEA.L   A0,A1 
      CMPI.L    #$12123456,(A1)+
      BEQ.S     L000F 
      LEA       -512(A0),A0 
      CMPA.L    #0,A0 
      BGT.S     L000B 
      CMPI.L    #$31415926,$426.w 
      BEQ.S     L000E 
      MOVE.W    #$0,(A6)
      LEA       L0014(PC),A0
      BSR.S     L0012 
      MOVE.L    #$50000,D0
L000C:SUBQ.L    #1,D0 
      BNE.S     L000C 
      MOVE.L    #$263C0000,$140.w 
L000D:MOVE.W    #$0,(A6)
      MOVE.W    #0,30(A6) 
      RTS 
L000E:MOVE.W    #$400,(A6)
      LEA       L0015(PC),A0
      BSR.S     L0012 
      CLR.W     D7
      BRA.S     L0010 
L000F:MOVEA.L   A0,A5 
      MOVE.W    #$400,(A6)
      MOVE.W    #1,D7 
      LEA       L0016(PC),A0
      BSR.S     L0012 
L0010:LEA       L0017(PC),A0
      BSR.S     L0012 
L0011:MOVE.W    #7,-(A7)
      TRAP      #1
      ADDQ.L    #2,A7 
      SWAP      D0
      CMPI.B    #$3B,D0 
      BEQ.S     L000D 
      CMPI.B    #$3C,D0 
      BNE.S     L0011 
      CLR.L     $426.w
      CLR.L     $42A.w
      CMP.W     #0,D0 
      BEQ.S     L000D 
      CLR.L     (A5)+ 
      MOVEA.L   4.w,A0
      JMP       (A0)
L0012:MOVE.L    A0,-(A7)
      MOVE.W    #9,-(A7)
      TRAP      #1
      ADDQ.L    #6,A7 
      RTS 
      DC.B      '?<',$00,$07,'NAT',$8F
      DC.B      'H@'
L0013:DC.B      $1B,'E',$1B,'f',$1B,'Y %' 
      DC.B      'The Medw'
      DC.B      'ay Boys '
      DC.B      'Protecto'
      DC.B      'r IV',$1B,'Y"*'
      DC.B      'Improved'
      DC.B      ' By The '
      DC.B      'BBC!',$00
L0014:DC.B      $1B,'Y*(You a'
      DC.B      're FREE '
      DC.B      'of virus'
      DC.B      'es !',$00
L0015:DC.B      $1B,'Y&#The R'
      DC.B      'ESET VEC'
      DC.B      'TOR has '
      DC.B      'been cha'
      DC.B      'nged',$1B,'Y(+'
      DC.B      'It MAY b'
      DC.B      'e a viru'
      DC.B      's',$00 
L0016:DC.B      $1B,'Y&-RESE' 
      DC.B      'T RESIDE'
      DC.B      'NT prog '
      DC.B      'in memor'
      DC.B      'y',$1B,'Y(+It '
      DC.B      'is MORE '
      DC.B      'than lik'
      DC.B      'ely a VI'
      DC.B      'RUS !!',$00
L0017:DC.B      $1B,'Y,,F1 Co'
      DC.B      'ntinue',$1B,'Y'
      DC.B      '.,F2 Cle'
      DC.B      'ar',$00
L0018:DC.B      $1B,'E',$1B,'f',$1B,'w   '
      DC.B      'MEDWAY B'
      DC.B      'OYS VIRU'
      DC.B      'S FREE V'
      DC.B      'ERSION I'
      DC.B      'V',$0D,$0A,'   ==' 
      DC.B      '========'
      DC.B      '========'
      DC.B      '========'
      DC.B      '=======',$0D 
      DC.B      $0A,$0D,$0A,'     ' 
      DC.B      ' IMPROVE'
      DC.B      'D BY XER'
      DC.B      ' OF THE '
      DC.B      'BBC!!',$0D,$0A,$0D 
      DC.B      $0A,' PRESS ' 
      DC.B      ':- C TO '
      DC.B      'CREATE A'
      DC.B      ' NEW BOO'
      DC.B      'TSECTOR',$0D 
      DC.B      $0A,'       ' 
      DC.B      ' - D TO '
      DC.B      'DELETE A'
      DC.B      'N OLD BO'
      DC.B      'OTSECTOR'
      DC.B      $0D,$0A,' PRESS'
      DC.B      '  - Q TO'
      DC.B      ' QUIT',$0D,$0A,$00 
      DC.B      $00 
L0019:DC.B      '**ERROR I' 
      DC.B      'N LOADIN'
      DC.B      'G/STORIN'
      DC.B      'G BOOTSE'
      DC.B      'CTOR**',$0D,$0A
      DC.B      $00,$00 
 BSS
L001A:DS.W      1 
L001B:DS.B      512 
ZUEND: END
