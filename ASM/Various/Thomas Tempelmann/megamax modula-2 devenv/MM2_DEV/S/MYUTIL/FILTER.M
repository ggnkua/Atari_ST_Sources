MODULE Filter;
(*$E MOS *)

(*
 l”scht jede 2. Leerzeile aus Text - kommt vor beim Pufferspeichern in RUFUS
*)

FROM Files IMPORT Open, Create, Access, replaceOld, Close, State, EOF, File;
IMPORT Text;
FROM Strings IMPORT String;
FROM Console IMPORT ReadLine, WriteString, Read, Write, WriteLn;
FROM StrConv IMPORT CardToStr;

VAR line: ARRAY [0..200] OF CHAR;
    s: String;
    in,out: File;
    ch: CHAR;
    lines: CARDINAL;

BEGIN
  REPEAT
    WriteLn;
    WriteString ('In: '); ReadLine (s);
    Open (in, s, readSeqTxt);
  UNTIL State (in) >= 0;
  REPEAT
    WriteLn;
    WriteString ('Out: '); ReadLine (s);
    Create (out, s, writeSeqTxt, replaceOld);
  UNTIL State (out) >= 0;
  WriteLn;
  WriteLn;
  WHILE NOT EOF (in) DO
    Text.ReadFromLine (in, line);
    Text.ReadLn (in);
    Text.WriteString (out, line);
    Text.WriteLn (out);
    Text.ReadFromLine (in, line);
    Text.ReadLn (in);
    IF line[0] # 0C THEN HALT END;
    INC (lines);
    Write (CHR(13));
    WriteString (CardToStr (lines, 5));
  END;
  Close (out);
  Close (in);
  Read (ch)
END Filter.
