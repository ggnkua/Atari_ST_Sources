MODULE MediaChange;

IMPORT MOSGlobals, Files, Directory;
FROM InOut IMPORT WriteString, WriteLn, Read;

VAR error: INTEGER;
    drive: Directory.Drive;
    ch: CHAR;
    driveStr: MOSGlobals.DriveStr;
    text: ARRAY [0..99] OF CHAR;

TYPE CHARSET = SET OF CHAR;

BEGIN
  WriteString ("Forced Media Change"); WriteLn;
  WriteString ("Geschrieben von Laurenz PrÅssner & Thomas Tempelmann");
  WriteLn; WriteString ("Laufwerk (A-P) oder Default-LW (Leertaste) ?");
  REPEAT Read (ch); UNTIL CAP (ch) IN CHARSET {'A'..'P'};
  WriteLn;
  driveStr [0]:= ch;
  driveStr [1]:= ':';
  Directory.ForceMediaChange (Directory.StrToDrive (driveStr));
END MediaChange.
