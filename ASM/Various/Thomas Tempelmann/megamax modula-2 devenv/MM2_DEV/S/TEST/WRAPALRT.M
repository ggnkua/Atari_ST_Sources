MODULE WrapAlrt;

(*$E MOS *)

FROM Strings IMPORT PosLen, Insert, Length;

FROM Terminal IMPORT ReadString, WriteString, WriteLn, Read;

FROM EasyGEM0 IMPORT WrapAlert;

VAR s: ARRAY [0..99] OF CHAR;

BEGIN
  REPEAT
    WriteString ('? ');ReadString (s);
    WrapAlert (s, 4);
    WriteString ('> ');WriteString (s); WriteLn;
  UNTIL s[0]=0C
END WrapAlrt.
