 TEXT 
Begin:
      BRA.S   L0000 
      DC.B   'NEWline!' 
      DC.B   $F5,$00,$02,$02,$01,$00,$02,'p'
      DC.B   $00,'@',$06,$F9,$03,$00,$0A,$00
      DC.B   $02,$00,$00,$00,$00,$00,$00,$00
      DS.W    12,0
L0000:MOVEA.L 4(A7),A5
      MOVE.L  A5,D0 
      MOVE.L  12(A7),D0 
      ADD.L   20(A7),D0 
      ADD.L   28(A7),D0 
      ADDI.L  #$100,D0
      MOVE.L  D0,-(A7)
      MOVE.L  A5,-(A7)
      CLR.W   -(A7) 
      MOVE.W  #$4A,-(A7)
      TRAP    #1
      LEA     12(A7),A7 
      PEA     L0001(PC) 
      MOVE.W  #9,-(A7)
      TRAP    #1
      ADDQ.L  #6,A7 
      PEA     L0002(PC) 
      MOVE.W  #$20,-(A7)
      TRAP    #$E 
      ADDQ.L  #6,A7 
      RTS 
L0001:DC.B   $1B,'E',$1B,'pNEWL'
      DC.B   'INE VIRU' 
      DC.B   'S FREE!',$00
L0002:DC.B   $01,$00,$07,$FE,$08,$10,$0B,$CF
      DC.B   $0C,'X',$0D,$00,$80,$00,$81,$00
      DC.B   'G',$00,$FF,$00,$00,$00,$00,$00
      DS.W    169,0 
      DC.B   'V',$E1
ZUEND: END
