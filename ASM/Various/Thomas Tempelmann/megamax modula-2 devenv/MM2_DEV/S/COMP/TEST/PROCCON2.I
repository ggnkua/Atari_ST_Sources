IMPLEMENTATION MODULE P2;
(*$N+,S-*)
FROM SYSTEM IMPORT ASSEMBLER;

IMPORT InOut;

VAR c: CHAR;

BEGIN
  (*
  ASSEMBLER BREAK END;
  *)
  WS ("<Wr> ");
  InOut.WriteString ("Hua!");
  InOut.WriteLn;
END P2.
