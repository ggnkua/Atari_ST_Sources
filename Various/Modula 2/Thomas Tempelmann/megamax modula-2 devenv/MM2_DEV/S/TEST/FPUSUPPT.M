
MODULE FPUSuppTest;

FROM SYSTEM IMPORT LONGWORD, ASSEMBLER;
FROM FPUSupport IMPORT NewContext, SaveContext, RestoreContext, FPUContext;

VAR fpu: FPUContext; r: LONGREAL;

BEGIN
  NewContext (fpu);
  ASSEMBLER MOVE #3,$FFFA42 BREAK END;
  r:= 1.3;
  r:= r*r+r;
  r:= r*r+r;
  SaveContext (fpu);
  RestoreContext (fpu);
  (*
  SaveContext (fpu);
  RestoreContext (fpu);
  SaveContext (fpu);
  RestoreContext (fpu);
  SaveContext (fpu);
  RestoreContext (fpu);
  SaveContext (fpu);
  RestoreContext (fpu);
  *)
  ASSEMBLER BREAK END;
END (* MODULE *) FPUSuppTest.
