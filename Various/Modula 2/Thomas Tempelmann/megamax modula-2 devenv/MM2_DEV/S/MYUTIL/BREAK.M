MODULE Break;
(*$N+*)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        BREAK
        CLR.W   -(A7)
        TRAP    #1
  END
END Break.
