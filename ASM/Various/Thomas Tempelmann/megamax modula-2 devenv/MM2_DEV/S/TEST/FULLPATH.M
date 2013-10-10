MODULE TP;

(*$E MOS *)
FROM Directory IMPORT MakeFullPath, DefaultPath;
FROM Terminal IMPORT WriteLn, WriteString, Read;
FROM Strings IMPORT String;

VAR ch: CHAR;
 i: INTEGER;
 s: String;
 
BEGIN
  WriteString (DefaultPath ());
  WriteLn;
  MakeFullPath (s, i);
  WriteString (DefaultPath ());
  WriteLn;
  WriteString (s);
  WriteLn;
  Read (ch)
END TP.
