MODULE TextFile;

(*
*)
FROM Terminal IMPORT WriteLn, WriteString, Write, Read, ReadString;
FROM Strings IMPORT StrEqual;
IMPORT Files, Text, Directory;

CONST name = "\tmp\test.txt";

VAR f: Files.File;
    i,a:CARDINAL;
    ch:CHAR;
    s1:ARRAY [0..19] OF CHAR;
    s2:ARRAY [0..4] OF CHAR;
    s0:ARRAY [0..1] OF CHAR;
    res: INTEGER;

PROCEDURE check (REF s1,s2: ARRAY OF CHAR);
  BEGIN
    IF NOT StrEqual (s1,s2) THEN
      WriteString (s1); WriteString (' <> '); WriteString (s2);
      HALT
    END
  END check;
  
BEGIN
  Files.Create (f, name, Files.writeSeqTxt, Files.replaceOld);
  Text.WriteString (f, "123 45  678 ");
  Text.WriteLn (f);
  Text.WriteString (f, " 9012");
  Files.Close (f);
  Files.Open (f, name, Files.readSeqTxt);
  Text.ReadFromLine (f, s0);
  check (s0, "12");
  Text.ReadFromLine (f, s1);
  check (s1, "3 45  678 ");
  Text.ReadLn (f);
  Text.ReadFromLine (f, s1);
  check (s1, " 9012");
  Files.Close (f);
  Files.Open (f, name, Files.readSeqTxt);
  Text.ReadToken (f, s1);
  check (s1, "123");
  Text.ReadToken (f, s1);
  check (s1, "45");
  Text.ReadToken (f, s1);
  check (s1, "678");
  Text.ReadToken (f, s1);
  check (s1, "9012");
  (*
  Text.ReadToken (f, s1);
  check (s1, "9012");
  *)
  Files.Close (f);
  Directory.Delete (name, res)
END TextFile.
