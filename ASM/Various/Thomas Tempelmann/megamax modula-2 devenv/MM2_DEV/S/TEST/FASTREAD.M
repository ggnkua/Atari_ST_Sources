
MODULE FastRead; (*$E MOS *)

IMPORT TOSIO, InOut;

VAR str1  : ARRAY [0..10] OF CHAR;
    ch    : CHAR;
    count : INTEGER;

BEGIN
  InOut.RedirectInput ("D:\TMP\T.DAT");
  LOOP
    InOut.ReadString (str1);
    IF NOT InOut.Done THEN
      EXIT
    END;
    InOut.WriteString (str1);
    IF InOut.termCH = InOut.EOL THEN
      InOut.WriteLn
    END
  END (* LOOP *);
  InOut.CloseInput;
  InOut.Read (ch);
END FastRead.
