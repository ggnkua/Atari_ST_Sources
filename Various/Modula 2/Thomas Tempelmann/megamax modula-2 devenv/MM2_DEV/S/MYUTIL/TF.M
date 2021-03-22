MODULE TF; (*$E MOS *)

IMPORT Files, Text, Binary, Terminal,NumberIO;
FROM StrConv IMPORT CardToStr;
FROM Terminal IMPORT WriteString, WriteLn;

VAR a:CARDINAL;
    ok:BOOLEAN;
    ch:CHAR;
    f:Files.File;
    s:ARRAY [0..79] OF CHAR;

BEGIN
  Files.Open (f,'MODULA.ERR',Files.readOnly);
  IF Files.State (f) # 0 THEN
    Files.GetStateMsg (Files.State(f),s);
    WriteLn;
    WriteString (s);
    RETURN
  END;
  WriteString ('Size: ');
  WriteString (CardToStr (Binary.FileSize (f),0));
  WriteLn;
  WriteString ('Pos: ');
  WriteString (CardToStr (Binary.FilePos (f),0));
  WriteLn;
  NumberIO.ReadCard (f, a, ok);
  WriteString ('Numb: ');
  WriteString (CardToStr (a,0));
  WriteLn;
  Text.ReadString (f,s);
  WriteString (s);
  WriteLn;
  WriteString ('Pos: ');
  WriteString (CardToStr (Binary.FilePos (f),0));
  WriteLn;
  Terminal.Read(s[0])
END TF.

(* $FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$000001DD$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8$FFFBC1B8Ä$0000030DT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFF6B07E$FFF6B07E$FFF6B07E$000002BE$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07E$FFF6B07EêÄÄ*)
