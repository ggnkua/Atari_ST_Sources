MODULE SymKey;  (* Stephan Junker  19.12.93 *)

(* setzt den Key einer Symboldatei in einer anderen ein *)

IMPORT SYSTEM, Fsel, FN:=Filename, File;

VAR
  path, name1, name2 : FN.path;
  count, key : LONGINT;
  d : BOOLEAN;
  handle1, handle2 : INTEGER;
  date : File.datime;

BEGIN
  path[0] := 0X;
  name1[0] := 0X;
  name2[0] := 0X;

  IF Fsel.ExInput(path, name1, "Alte Symboldatei") AND
     Fsel.ExInput(path, name2, "Neue Symboldatei") AND
     File.Open(name1, File.read, handle1) AND
     File.Open(name2, File.write, handle2) THEN

    d := File.Seek(handle1, 4, File.absbeg, key);
    d := File.Seek(handle2, 4, File.absbeg, key);

    count := 4;
    d := File.Read(handle1, count, SYSTEM.ADR(key) );
    d := File.Write(handle2, count, SYSTEM.ADR(key) );

    File.Datime( handle1, date, File.get);
    File.Datime( handle2, date, File.set);

    File.Close(handle1);
    File.Close(handle2);

  END;
END SymKey.