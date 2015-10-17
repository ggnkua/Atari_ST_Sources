MODULE Hello;
(*$N+,R-*)

FROM StorBase IMPORT MemAvail;
FROM SYSTEM IMPORT ASSEMBLER;

VAR l: LONGCARD;

BEGIN
  ASSEMBLER BREAK END;
  l:= MemAvail();
END Hello.
