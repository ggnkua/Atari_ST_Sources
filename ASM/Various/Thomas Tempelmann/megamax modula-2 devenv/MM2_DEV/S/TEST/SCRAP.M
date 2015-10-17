MODULE Scrap;

(*
 * Testet Scrap-Funktionen in EasyGEM1
 *)

FROM Strings IMPORT String;

FROM InOut IMPORT WriteString, Write, WriteLn, Read;

IMPORT EasyGEM1;

VAR name: String;
    ch: CHAR;

BEGIN
  EasyGEM1.MakeScrapName ('TST', name);
  WriteString (name);
  Read (ch);
  IF CAP (ch) = 'C' THEN
    EasyGEM1.ClearScrap;
    Read (ch);
  END
END Scrap.
