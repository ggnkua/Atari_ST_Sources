MODULE T;

FROM InOut IMPORT WriteLn, WriteString, Write, OpenInput, OpenOutput, Read,
       RedirectInput, CloseOutput, ReadString;

VAR i,a:CARDINAL;
    ch:CHAR;
    s1:ARRAY [0..19] OF CHAR;
    s2:ARRAY [0..4] OF CHAR;

BEGIN
  RedirectInput ('B.TXT');
  WriteLn;
  Write ('1');
  WriteLn;
  WriteString ('1234 ?');
  WriteLn;
  s1:= 'l”sdkfl”1k”e    qkd';
  ReadString (s1);
  WriteLn;
  WriteString (s1);
  WriteLn;
  Read (ch)
END T.

