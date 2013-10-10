MODULE RealTest; (*$E MOS *)

FROM SYSTEM IMPORT ADR, NEWPROCESS, ADDRESS, ASSEMBLER;
IMPORT SYSTEM;

IMPORT GEMDOSIO;
FROM InOut IMPORT WriteString, Write, WriteLn, WriteReal, ReadReal;

PROCEDURE loc;

VAR r1, r2: REAL;

BEGIN
  (*$X+*)
  ASSEMBLER BREAK FMOVE #$0000F400,FPCR (* s.o.*) END;
  r1:= 1.E18;
  r2:= 2.;
  WriteReal (r1, 10, 2);
  WriteReal (r2, 10, 2);
  WriteLn;
  r1:= r1*r1;
  WriteLn;
  WriteString ('main:');
  WriteReal (r1, 10, 2);
  WriteReal (r2, 10, 2);
END loc;

BEGIN
  loc
END RealTest.
