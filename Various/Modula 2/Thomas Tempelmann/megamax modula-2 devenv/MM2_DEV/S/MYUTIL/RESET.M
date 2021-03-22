MODULE Reset;
(*$N+*)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        MOVE.L  $46E,A0
        JMP     (A0)
  END
END Reset.
