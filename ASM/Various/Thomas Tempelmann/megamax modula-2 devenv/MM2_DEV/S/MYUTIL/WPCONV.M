MODULE WPConv;

FROM Files IMPORT File, Access, ReplaceMode, Open, Create, State, Close, EOF;
FROM Text IMPORT ReadString, WriteString, WriteLn, ReadLn, Write, EOL;
FROM Strings IMPORT Empty;
IMPORT InOut;

VAR in, out: File;
    n1, n2: ARRAY [0..64] OF CHAR;
    line: ARRAY [0..255] OF CHAR;
    paragraph: BOOLEAN;

BEGIN
  InOut.WriteString ('Input file: ');
  InOut.ReadString (n1);
  IF NOT InOut.Done THEN RETURN END;
  InOut.WriteString ('Output file: ');
  InOut.ReadString (n2);
  IF NOT InOut.Done THEN RETURN END;
  Open (in, n1, readSeqTxt);
  Create (out, n2, writeSeqTxt, replaceOld);
  paragraph:= FALSE;
  REPEAT
    ReadString (in, line);
    IF EOL (in) THEN
      ReadLn (in);
      IF Empty (line) THEN
        WriteLn (out)
      ELSE
        Write (out, ' ');
        WriteString (out, line);
      END;
    END
  UNTIL EOF (in);
  Close (out);
  Close (in);
END WPConv.

(* $FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C$FFF2F12C€$00000360........T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFF2F12C$000002E9$00000360$FFF2F12C$000002E9$000002DA$00000395$FFF2F12C$0000037F$0000038F$0000037A$0000038A$000002AE$00000356$0000032C$FFF2F12CŒ€€*)
