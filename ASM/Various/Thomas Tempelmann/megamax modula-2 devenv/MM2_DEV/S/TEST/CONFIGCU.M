MODULE T;
(*$E MOS*)

FROM SYSTEM IMPORT ASSEMBLER;
FROM Console IMPORT WriteString, WriteLn, Read, KeyPressed;
FROM XBIOS IMPORT ConfigureCursor;

VAR c: INTEGER; ch: CHAR;

BEGIN
  c:= ConfigureCursor (-1, -1);
  ASSEMBLER MOVE c,D0 BREAK END;
  c:= ConfigureCursor (-1, 1);
  WriteString ("warte...");
  REPEAT UNTIL KeyPressed (); Read (ch); WriteLn;
  c:= ConfigureCursor (-1, 0);
  WriteString ("warte...");
  REPEAT UNTIL KeyPressed (); Read (ch); WriteLn;
  c:= ConfigureCursor (-1, 1);
  WriteString ("warte...");
  REPEAT UNTIL KeyPressed (); Read (ch); WriteLn;
  WriteString ("end.");
END T.
