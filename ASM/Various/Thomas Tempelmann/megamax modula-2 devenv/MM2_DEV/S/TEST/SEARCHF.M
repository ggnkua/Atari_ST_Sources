MODULE SearchF;

IMPORT Paths, ShellMsg;

IMPORT TOSIO; (*$E MOS *)
FROM InOut IMPORT WriteString, Write, WriteLn, Read;

VAR ok: BOOLEAN;
    s: ARRAY [0..100] OF CHAR;
    
BEGIN
  WriteString ('HomePath: ');
  WriteString (Paths.HomePath ());
  WriteLn;
  WriteString ('Searching...');
  WriteLn;
  Paths.SearchFile ('RUNTIME.DEF', ShellMsg.DefPaths, Paths.fromStart,
        ok, s);
  WriteString (s);
  WriteLn;
  IF ok THEN
    WriteString ('OK')
  ELSE
    WriteString ('Not found!')
  END
END SearchF.
