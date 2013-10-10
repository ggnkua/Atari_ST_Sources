MODULE T;

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        BREAK
        PEA     x(PC)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        RTS
      x MOVE.L  $4F2,A0
        MOVE.L  2(A0),D0
        MOVE.L  #$56EC,D1
        CMPI.W  #$0100,D0
        BEQ     ok
        MOVE.L  #$7E8E,D1
        CMPI.W  #$0102,D0
        BEQ     ok
        MOVE.L  #$5328,D1
        CMPI.W  #$0104,D0
        BEQ     ok
        MOVE.L  #$578E,D1
        CMPI.W  #$0205,D0
        BEQ     ok
        CLR.L   D1
      ok NOP
  END
END T.
