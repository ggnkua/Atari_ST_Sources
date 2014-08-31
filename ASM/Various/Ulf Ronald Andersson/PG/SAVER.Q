 TEXT 
Begin:
  LEA       L0030,A7
  DC.B      $A0,$00,$A0,$0A 
  CLR.L     -(A7) 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.L    D0,L0026
  MOVEA.L   $42E.W,A0 
  ADDI.L    #$8000,$42E.W 
  MOVEA.L   A0,A5 
  LEA       32032(A0),A0
  LEA       L001C,A1
  MOVEQ     #$F,D0
L0000:
  CMPM.B    (A0)+,(A1)+ 
  BNE       L0008 
  DBF       D0,L0000
  PEA       L0024 
  MOVE.W    #$3B,-(A7) 	;DSETPATH 
  TRAP      #1
  ADDQ.L    #6,A7 
  LEA       L001E,A6
  BSR       L001A 
  BSR       L001B 
  LEA       L0028,A4
  MOVEQ     #$F,D3
L0001:
  MOVEQ     #$F,D0
  SUB.L     D3,D0 
  MOVE.W    #-1,-(A7) 
  MOVE.W    D0,-(A7)
  MOVE.W    #7,-(A7) 	;SETCOLOR 
  TRAP      #$E 
  ADDQ.L    #6,A7 
  MOVE.W    D0,(A4)+
  DBF       D3,L0001
  MOVE.W    #2,-(A7) 	;PHYSBASE 
  TRAP      #$E 
  ADDQ.L    #2,A7 
  MOVEA.L   D0,A2 
  MOVEA.L   A5,A0 
  MOVE.L    #$3E7F,D0 
  LEA       L0027,A1
L0002:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0002
  MOVEQ     #$F,D0
  LEA       L0029,A1
L0003:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0003
  LEA       L0027,A1
  MOVE.L    #$3E7F,D0 
L0004:
  MOVE.W    (A1)+,(A2)+ 
  DBF       D0,L0004
  PEA       L0029 
  MOVE.W    #6,-(A7) 	;SETPALLETE 
  TRAP      #$E 
  ADDQ.L    #6,A7 
  BSR       L001B 
  LEA       L001F,A6
  BSR       L001A 
L0005:
  BSR       L001B 
  CMP.B     #$26,D0 
  BEQ.S     L000A 
  CMP.B     #$32,D0 
  BEQ       L0010 
  CMP.B     #$23,D0 
  BEQ       L0011 
  CMP.B     #$10,D0 
  BNE.S     L0005 
L0006:
  PEA       L0028 
  MOVE.W    #6,-(A7) 	;SETPALLETE 
  TRAP      #$E 
  ADDQ.L    #6,A7 
  LEA       L0025,A6
  BSR       L001A 
L0007:
  BSR       L001B 
  CMP.B     #$15,D0 
  BEQ.S     L0009 
  CMP.B     #$31,D0 
  BNE.S     L0007 
  SUBI.L    #$8000,$42E.W 
  BRA.S     L0009 
L0008:
  LEA       L001D,A6
  BSR       L001A 
  BSR       L001B 
  SUBI.L    #$8000,$42E.W 
L0009:
  DC.B      $A0,$09 
  MOVE.L    L0026,-(A7) 
  MOVE.W    #$20,-(A7) 	;SUPER
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.W    #$5047,-(A7)
  MOVE.W    #$4C,-(A7) 	;PTERM
  TRAP      #1
L000A:
  LEA       L0020,A6
  BSR       L001A 
L000B:
  BSR       L001B 
  CMP.B     #$20,D0 
  BEQ.S     L000F 
  CMP.B     #$31,D0 
  BEQ.S     L000C 
  BRA.S     L000B 
L000C:
  LEA       L002B,A1
  LEA       L0029,A0
  MOVEQ     #$F,D0
L000D:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L000D
  LEA       L0027,A0
  LEA       L002C,A1
  MOVE.L    #$3E7F,D0 
L000E:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L000E
  LEA       L0022,A6
  BSR       L001A 
  MOVE.L    #$7D80,D5 
  BSR.S     L0015 
  BRA       L0006 
L000F:
  LEA       L002A,A1
  CLR.W     (A1)+ 
  BSR.S     L0012 
  BRA       L0006 
L0010:
  LEA       L002A,A1
  MOVE.W    #1,(A1)+
  BSR.S     L0012 
  BRA       L0006 
L0011:
  LEA       L002A,A1
  MOVE.W    #2,(A1)+
  BSR.S     L0012 
  BRA       L0006 
L0012:
  LEA       L0029,A0
  MOVEQ     #$F,D0
L0013:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0013
  LEA       L0027,A0
  MOVE.L    #$3E7F,D0 
L0014:
  MOVE.W    (A0)+,(A1)+ 
  DBF       D0,L0014
  LEA       L0022,A6
  BSR       L001A 
  MOVE.L    #$7D22,D5 
  BSR.S     L0015 
  RTS 
L0015:
  LEA       L002D,A0
  MOVE.B    #$28,(A0) 
  PEA       L002D 
  MOVE.W    #$A,-(A7) 	;CCONRS
  TRAP      #1
  ADDQ.L    #6,A7 
  PEA       L002F 
  MOVE.W    #$1A,-(A7) 	;DSETDTA
  TRAP      #1
  ADDQ.L    #6,A7 
  MOVE.W    #-1,-(A7) 
  PEA       L002E 
  MOVE.W    #$4E,-(A7) 	;FSFIRST
  TRAP      #1
  ADDQ.L    #8,A7 
  TST.W     D0
  BMI       L0017 
  LEA       L0023,A6
  BSR.S     L001A 
L0016:
  BSR.S     L001B 
  CMP.B     #$18,D0 
  BEQ.S     L0017 
  CMP.B     #$10,D0 
  BEQ.S     L0018 
  CMP.B     #$31,D0 
  BNE.S     L0016 
  LEA       L0022,A6
  BSR.S     L001A 
  BRA.S     L0015 
L0017:
  DC.B      $A0,$09 
  CLR.W     -(A7) 
  PEA       L002E 
  MOVE.W    #$3C,-(A7) 	;FCREATE
  TRAP      #1
  ADDQ.L    #8,A7 
  TST.W     D0
  BMI       L0019 
  MOVE.W    D0,D3 
  PEA       L002A 
  MOVE.L    D5,-(A7)
  MOVE.W    D3,-(A7)
  MOVE.W    #$40,-(A7) 	;FWRITE 
  TRAP      #1
  LEA       12(A7),A7 
  TST.W     D0
  BMI       L0019 
  MOVE.W    D3,-(A7)
  MOVE.W    #$3E,-(A7) 	;FCLOSE 
  TRAP      #1
  ADDQ.L    #4,A7 
  DC.B      $A0,$0A 
L0018:
  RTS 
L0019:
  LEA       L0021,A6
  BSR.S     L001A 
  BSR.S     L001B 
  RTS 
L001A:
  MOVE.L    A6,-(A7)
  MOVE.W    #9,-(A7) 	;CCONWS 
  TRAP      #1
  ADDQ.L    #6,A7 
  RTS 
L001B:
  MOVE.W    #7,-(A7) 	;CRAWCIN
  TRAP      #1
  ADDQ.L    #2,A7 
  SWAP      D0
  RTS 
 DATA 
L001C:
  DC.B      'Picture '
  DC.B      'Grabber!'
L001D:
  DC.B      $1B,'EAre yo' 
  DC.B      'u sure y'
  DC.B      'ou have '
  DC.B      'grabbed '
  DC.B      'a',$0A,$0D,'pictu' 
  DC.B      're ? The'
  DC.B      're are n'
  DC.B      'o pictur'
  DC.B      'e',$0A,$0D,'there' 
  DC.B      ' it shou'
  DC.B      'ld be ..'
  DC.B      '. ',$0A,$0D,'Than' 
  DC.B      'ks for r'
  DC.B      'unning m'
  DC.B      'e anyway'
  DC.B      '!',$00 
L001E:
  DC.B      $1B,'E******' 
  DC.B      '******* '
  DC.B      'Saver v.'
  DC.B      ' 2.0 ***'
  DC.B      '********'
  DC.B      '**',$0A,$0D,$0A,$0D,'10' 
  DC.B      '0 % Asse'
  DC.B      'mbly Lan'
  DC.B      'guage (W'
  DC.B      'ow !!!)',$0A 
  DC.B      $0D,'(I did ' 
  DC.B      'it becau'
  DC.B      'se I wan'
  DC.B      'ted to c'
  DC.B      'ode some'
  DC.B      $0A,$0D,'not go'
  DC.B      'od looki'
  DC.B      'ng code.'
  DC.B      '..)',$0A,$0D,$0A,$0D,$0A 
  DC.B      $0D,'Hi to e' 
  DC.B      'verybody'
  DC.B      ' ..., ',$27,'s'
  DC.B      'pecially'
  DC.B      ' myself!'
  DC.B      $0A,$0D,$0A,$0D,'PATH'
  DC.B      ' = A:\',$1B,'Y'
  DC.B      '7.Press '
  DC.B      'A Key!',$0A,$0D
  DC.B      $00 
L001F:
  DC.B      $1B,'HWhat re'
  DC.B      'sulotion'
  DC.B      ' is this'
  DC.B      ' picture'
  DC.B      ' ?',$1B,'K',$0A,$0D,'(L' 
  DC.B      ')ow, (M)'
  DC.B      'edium, ('
  DC.B      'H)igh or'
  DC.B      ' (Q)uit '
  DC.B      $1B,'K',$00 
L0020:
  DC.B      $0A,$0D,'What pi' 
  DC.B      'cture fo'
  DC.B      'rmat ? ',$1B 
  DC.B      'K',$0A,$0D,'(N)eo' 
  DC.B      'chrome o'
  DC.B      'r (D)ega'
  DC.B      's',$1B,'K',$00,$1B,'E',$00 
L0021:
  DC.B      $1B,'ECan',$27,'t w'
  DC.B      'rite to '
  DC.B      'disc',$0A,$0D,'th' 
  DC.B      'e right '
  DC.B      'way, so '
  DC.B      'I',$27,'ll qui'
  DC.B      't.',$00
L0022:
  DC.B      $0A,$0D,'Enter f' 
  DC.B      'ilename '
  DC.B      '(if no p'
  DC.B      'ath, A:\'
  DC.B      ' is',$1B,'K',$0A,$0D,'p' 
  DC.B      'resumed,'
  DC.B      ' max 40 '
  DC.B      'letters)'
  DC.B      ' Filenam'
  DC.B      'e :',$1B,'K',$0A,$0D,$1B 
  DC.B      'K',$00 
L0023:
  DC.B      $0A,$0D,'The fi'
  DC.B      'le speci'
  DC.B      'fied exi'
  DC.B      'sts !!!',$1B 
  DC.B      'K',$0A,$0D,'(O)ve' 
  DC.B      'rwrite ('
  DC.B      'N)ew Nam'
  DC.B      'e or (Q)'
  DC.B      'uit',$1B,'K',$00 
L0024:
  DC.B      'A:\',$00 
L0025:
  DC.B      $1B,'EGoodby' 
  DC.B      'e & Than'
  DC.B      'k you fo'
  DC.B      'r using '
  DC.B      'me',$0A,$0D,'Rele' 
  DC.B      'ase memo'
  DC.B      'ry used '
  DC.B      'by pictu'
  DC.B      're ?',$0A,$0D,'(Y' 
  DC.B      ')es or ('
  DC.B      'N)o',$00,'Disc'
  DC.B      ' is writ'
  DC.B      'e protec'
  DC.B      'ted.',$1B,'K',$0A,$0D
  DC.B      '(R)etry '
  DC.B      'or (C)an'
  DC.B      'cel',$1B,'K',$00 
 BSS
L0026:
  DS.L      1 
L0027:
  DS.B      32000 
L0028:
  DS.B      32
L0029:
  DS.B      32
L002A:
  DS.L      1 
L002B:
  DS.B      124 
L002C:
  DS.B      32000 
L002D:
  DS.W      1 
L002E:
  DS.B      42
L002F:
  DS.B      1044
L0030:
  DS.B      14
ZUEND: END
