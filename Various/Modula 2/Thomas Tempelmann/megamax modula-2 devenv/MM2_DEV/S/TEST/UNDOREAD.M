
MODULE TestFile; (*$E MOS *)

IMPORT Files, TOSIO, InOut, Text;

VAR f    : Files.File;
    ch   : CHAR;
    str1 : ARRAY [0..0] OF CHAR; (* 2.Fall z.B.: [0..3] *)

BEGIN
  Files.Open (f, "TEST.DAT", Files.readSeqTxt);
  LOOP
    Text.ReadString (f, str1);
    InOut.WriteString (str1);
    IF Text.EOL(f) THEN
      InOut.WriteLn;
    END;
    IF Files.EOF(f) THEN EXIT END;
    Text.Read (f, ch);
    IF Files.EOF(f) THEN EXIT END;
    IF Text.EOL(f) THEN
      InOut.WriteLn;
    ELSE
      Text.UndoRead (f);
    END (* IF *);
  END;
  Files.Close(f);
  InOut.Read (ch);
END TestFile.
